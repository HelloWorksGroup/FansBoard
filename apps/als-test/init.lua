
-- uart.setup(0, 460800, 8, 0, 1, 1 )
display = require("display")
display:update("BOOT", -1)
function startup()
	if file.open("init.lua") == nil then
		print("init.lua deleted or renamed")
	else
		print("Running")
		file.close("init.lua")
		dofile("application.lua")
	end
end
tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
