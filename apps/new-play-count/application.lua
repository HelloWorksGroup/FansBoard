
api = "http://api.bilibili.com/x/space/arc/search?ps=1&pn=1&order=pubdate&jsonp=jsonp&mid="

print("app start")
print("heap3:" .. node.heap())
display = require("display")
print("heap4:" .. node.heap())
print("display init")

local api_tmr = tmr.create()

display:update("READY", 1)
fans = 0
api_tmr:register(2000, tmr.ALARM_AUTO, 
function(t)
	api_tmr:interval(10000+math.random(1000,6000))
    print("update")
    http.get(api..uid, nil, 
    function(code, data)
		-- print(code, data)
        if (code ~= 200) then
			display:update("HTTP RET", -1)
			display:update(tostring(code), -1)
        else
            local parsed = sjson.decode(data)
			if (parsed.code ~= sjson.NULL) then
				if (parsed.code ~= 0) then
					display:update("API RET", -1)
					display:update(tostring(parsed.code), -1)
				elseif (parsed.data~=sjson.NULL and parsed.data.list.vlist ~= sjson.NULL) then
					print("video:" .. parsed.data.list.vlist[1].bvid .. " - " .. parsed.data.list.vlist[1].play)
					display:update(tostring(parsed.data.list.vlist[1].play), -1)
					fans = parsed.data.follower
				else
					display:update("ERROR X", -1)
				end
            end
        end
    end)
end)

api_tmr:start()

-- 自动亮度调节
local adc_tmr = tmr.create()
local adc_tab = {}
local bright = 6
local auto_up = {
	10,80,160,300,500,800,9999
}
local auto_down = {
	5,40,120,200,360,600
}
function auto_bright(adc)
	if adc>auto_up[bright+1] then
		bright = bright+1
		display:set_duty(bright)
	elseif bright>0 and adc<auto_down[bright] then
		bright = bright-1
		display:set_duty(bright)
	end
end
if adc then
	adc.force_init_mode(adc.INIT_ADC)
	adc_tmr:register(250, tmr.ALARM_AUTO, 
	function(t)
		table.insert(adc_tab, adc.read(0))
		while(#adc_tab>8) do
			table.remove(adc_tab, 1)
		end
		local adc = 0
		for _,v in ipairs(adc_tab) do
			adc = adc+v
		end
		adc = adc / #adc_tab
		auto_bright(adc)
	end)
	adc_tmr:start()
end
