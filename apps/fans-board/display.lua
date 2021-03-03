

local pixel_map = pixel_map or {}

local function spi_send(tb)
	gpio.write(4, gpio.LOW)
	spi.send(1, unpack(tb))
	gpio.write(4, gpio.HIGH)
end

if display==nil then
	gpio.mode(4, gpio.OUTPUT)
	gpio.write(4, gpio.HIGH)
	spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)
	
	spi_send({0xC,0x1,0xC,0x1,0xC,0x1,0xC,0x1})	-- normal
	spi_send({0xB,0x7,0xB,0x7,0xB,0x7,0xB,0x7})	-- scan limit
	spi_send({0xA,0x2,0xA,0x2,0xA,0x2,0xA,0x2})	-- duty 5/32
	spi_send({0x9,0x0,0x9,0x0,0x9,0x0,0x9,0x0})	-- no decodes
	spi_send({0xF,0x0,0xF,0x0,0xF,0x0,0xF,0x0})	-- test off
	for i=1,32 do
		table.insert( pixel_map, 0x00 )
	end
end

display = display or {}

local asc_simple = asc_simple or {
	[0]={0x1E,0x11,0x0F}, -- 0
	[1]={0x08,0x1F,0x00}, -- 1
	[2]={0x13,0x15,0x19}, -- 2
	[3]={0x15,0x15,0x1A}, -- 3
	[4]={0x1C,0x04,0x1F}, -- 4
	[5]={0x19,0x15,0x12}, -- 5
	[6]={0x0F,0x15,0x16}, -- 6
	[7]={0x10,0x17,0x18}, -- 7
	[8]={0x1E,0x15,0x0F}, -- 8
	[9]={0x1D,0x15,0x0F}; -- 9
	["0"]={0x1E,0x11,0x0F}, -- 0
	["1"]={0x08,0x1F,0x00}, -- 1
	["2"]={0x13,0x15,0x19}, -- 2
	["3"]={0x15,0x15,0x1A}, -- 3
	["4"]={0x1C,0x04,0x1F}, -- 4
	["5"]={0x19,0x15,0x12}, -- 5
	["6"]={0x0F,0x15,0x16}, -- 6
	["7"]={0x10,0x17,0x18}, -- 7
	["8"]={0x1E,0x15,0x0F}, -- 8
	["9"]={0x1D,0x15,0x0F}, -- 9
	A={0x0F,0x14,0x0F},
	B={0x1F,0x15,0x0A},
	C={0x0E,0x11,0x11},
	D={0x1F,0x11,0x0E},
	E={0x1F,0x15,0x11},
	F={0x1F,0x14,0x10},
	G={0x0E,0x11,0x17},
	H={0x1F,0x04,0x1F},
	I={0x11,0x1F,0x11},
	J={0x02,0x01,0x1E},
	K={0x1F,0x04,0x1B},
	L={0x1F,0x01,0x01},
	M={0x1F,0x08,0x1F},
	N={0x1F,0x10,0x0F},
	O={0x0E,0x11,0x0E},
	P={0x1F,0x14,0x08},
	Q={0x0E,0x11,0x0F},
	R={0x1F,0x14,0x0B},
	S={0x09,0x15,0x12},
	T={0x10,0x1F,0x10},
	U={0x1F,0x01,0x1F},
	V={0x1E,0x01,0x1E},
	W={0x1F,0x02,0x1F},
	X={0x1B,0x04,0x1B},
	Y={0x18,0x07,0x18},
	Z={0x13,0x15,0x19},
	["#"]={0x0A,0x00,0x0A},
	["."]={0x00,0x02,0x00},
	["-"]={0x04,0x04,0x04},
	["+"]={0x04,0x0E,0x04},
	["/"]={0x02,0x04,0x08},
	["!"]={0x00,0x1D,0x00},
	[" "]={0x00,0x00,0x00},
}

local function bit8shift(num,n)
	if n == 0 then
		return num
	elseif n > 0 then
		return bit.band(bit.lshift(num,n),0xFF)
	else
		return bit.rshift(num,-n)
	end
end

function pixel_map:clear()
	for i=1,32 do
		self[i] = 0
	end
end

function pixel_map:set_chr(pos, chr)
	array = asc_simple[chr]
	if array==nil then
		return
	end
	for i=1,3 do
		self[pos+i] = bit.bor(self[pos+i],array[i])
	end
end

function pixel_map:set_chr_ex(pos, chr, shift)
	array = asc_simple[chr]
	local array_shift = array_shift or {}
	if array==nil then
		return
	end
	for i=1,3 do
		if(shift~=0) then
			if(shift > 0) then
				array_shift[i] = bit.lshift(array[i],shift)
			else
				array_shift[i] = bit.rshift(array[i],-shift)
			end
		else
			array_shift[i] = array[i]
		end
		self[pos+i] = bit.bor(self[pos+i],array_shift[i])
	end
end

if file.open("workaround001.lua") ~= nil then
	file.close("workaround001.lua")
	err_hw_workaround = dofile("workaround001.lua")
	print("workaround detected")
end

err_hw_workaround = err_hw_workaround or function(hex) return hex end

function pixel_map:send()
	for i=1,8 do
		-- spi_send({i,self[33-i],i,self[25-i],i,self[17-i],i,self[9-i]})
		spi_send({
			i,err_hw_workaround(self[33-i]),
			i,err_hw_workaround(self[25-i]),
			i,err_hw_workaround(self[17-i]),
			i,err_hw_workaround(self[9-i])
		})
	end
end

function pixel_map:bitr(n)
	if n > 0 then
		for i=1,32 do
			pixel_map[i] = bit.band(bit.lshift(pixel_map[i],n),0xFF)
		end
	else
		for i=1,32 do
			pixel_map[i] = bit.band(bit.rshift(pixel_map[i],-n),0xFF)
		end
	end
end

function wr_str_to_bitmap(str, bitmap)
	if string.len(str)>8 then
		str = string.sub(str, 1, 8)
	end
	local str_len = string.len(str)
	local width_left = 32 - str_len*4
	local str_pos = width_left / 2
	for i=1,str_len do
		local chr = string.sub(str,i,i)
		if asc_simple[chr]==nil then
			chr = " "
		end
		for i=1,3 do
			bitmap[str_pos+i] = bit.band(bit.lshift(asc_simple[chr][i],1),0xFF)
		end
		str_pos = str_pos+4
	end
end

local disp_prop = disp_prop or {
	dir = -1,
	step = 0,
	from = "",
	to = "",
	busy = false,
	queue = {},
	buffer = {},	-- bitmap buffer
	index = {},		-- update index array
}
function display:show_num(num)
	if num > 99999999 then
		print("exceed max num")
		return
	end
	disp_prop.from = tostring(num)
	display:show_str(tostring(num))
end

function display:show_str(str)
	disp_prop.from = str
	pixel_map:clear()
	wr_str_to_bitmap(str, pixel_map)
	pixel_map:send()
end

local update_num_tmr = tmr.create()
update_num_tmr:register(90, tmr.ALARM_SEMI, 
function(t)
	if disp_prop.step >= 8 then
		disp_prop.from = disp_prop.to
		display:go()
		return
	end
	disp_prop.step = disp_prop.step+1

	-- 替换不同的字符
	for _,v in ipairs(disp_prop.index) do
		pixel_map[v] = bit.bor(bit8shift(pixel_map[v],disp_prop.dir),
			bit8shift(disp_prop.buffer[v],(disp_prop.step-8)*disp_prop.dir))
	end
	pixel_map:send()
	update_num_tmr:start()
end)

function disp_prop:init()
	for i=1,32 do
		self.buffer[i] = 0
	end
	self.index = {}
end

function disp_prop:apply()
	wr_str_to_bitmap(self.to, self.buffer)
	-- 不同宽度则全部替换
	if string.len(self.from)~=string.len(self.to) then
		for i=1,32 do
			table.insert(self.index, i)
		end
	else
		-- 不同字符会有重合像素，此处比较字符而非像素
		local str_len = string.len(self.to)
		local width_left = 32 - str_len*4
		local str_pos = width_left / 2
		for i=1,string.len(self.to) do
			if string.sub(self.to,i,i)~=string.sub(self.from,i,i) then
				for j=1,3 do
					table.insert(self.index, str_pos+j)
				end
			end
			str_pos = str_pos+4
		end
	end
end

function display:go()
	if #disp_prop.queue==0 then
		disp_prop.busy = false
		return
	end
	disp_prop.busy = true
	local str
	local dir
	while true do
		str = disp_prop.queue[1].str
		dir = disp_prop.queue[1].dir
		table.remove(disp_prop.queue, 1)
		if str~=disp_prop.from then
			break
		end
		if #disp_prop.queue==0 then
			disp_prop.busy = false
			return
		end
	end
	disp_prop:init()
	disp_prop.dir = dir
	disp_prop.to = str
	disp_prop.step = 0
	disp_prop:apply()
	update_num_tmr:start()
end

-- 连续操作队列
function display:update(str,dir)
	table.insert(disp_prop.queue, {str=str,dir=dir})
	if not disp_prop.busy then
		display:go()
	end
end

return display

