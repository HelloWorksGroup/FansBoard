
display = require("display")

local adc_tmr = tmr.create()
local adc_tab = {}
local bright = 6
-- 是否是自动调整模式
local auto = true
-- 手动调整显示闪烁
local auto_blink = true

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


gpio.mode(1, gpio.INT)
gpio.trig(1, "up", function()
	auto = false
	if bright<15 then
		bright = bright + 1
		display:set_duty(bright)
	end
end
)
gpio.mode(2, gpio.INT)
gpio.trig(2, "up", function()
	auto = false
	if bright>0 then
		bright = bright - 1
		display:set_duty(bright)
	end
end
)

adc.force_init_mode(adc.INIT_ADC)
display:update("READY", 1)
adc_tmr:register(2000, tmr.ALARM_AUTO, 
function(t)
	adc_tmr:interval(250)
	table.insert(adc_tab, adc.read(0))
	while(#adc_tab>8) do
		table.remove(adc_tab, 1)
	end
	local adc = 0
	for _,v in ipairs(adc_tab) do
		adc = adc+v
	end
	adc = adc / #adc_tab
	if auto then auto_bright(adc) else auto_blink = not auto_blink end
	if auto_blink then
		display:show_str(string.format("%04d",adc).." L"..string.format("%02d",bright))
	else
		display:show_str(string.format("%04d",adc).."  "..string.format("%02d",bright))
	end
end)
adc_tmr:start()
