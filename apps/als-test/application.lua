
display = require("display")

local adc_tmr = tmr.create()
local adc_tab = {}
local bright = 0

gpio.mode(1, gpio.INT)
gpio.trig(1, "up", function()
	if bright<15 then
		bright = bright + 1
		display:set_duty(bright)
	end
end
)
gpio.mode(2, gpio.INT)
gpio.trig(2, "up", function()
	if bright>0 then
		bright = bright - 1
		display:set_duty(bright)
	end
end
)

adc.force_init_mode(adc.INIT_ADC)
display:set_duty(bright)
display:update("READY", 1)
adc_tmr:register(2000, tmr.ALARM_AUTO, 
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
	adc_tmr:interval(250)
	display:show_str(string.format("%04d",adc).." L"..string.format("%02d",bright))
end)
adc_tmr:start()
