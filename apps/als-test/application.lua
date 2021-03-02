
display = require("display")

local adc_tmr = tmr.create()

adc.force_init_mode(adc.INIT_ADC)

display:update("READY", 1)
adc_tmr:register(2000, tmr.ALARM_AUTO, 
function(t)
	local adc = tostring(adc.read(0))
	adc_tmr:interval(250)
	print("adc:"..adc)
	display:show_str(adc)
end)
adc_tmr:start()
