
api = "http://quan.suning.com/getSysTime.do"

print("app start")
print("heap3:" .. node.heap())
display = require("display")
print("heap4:" .. node.heap())
print("display init")

local api_tmr = tmr.create()
local time_disp_tmr = tmr.create()

display:update("READY", 1)
local timeStr_Hour = "--"
local timeStr_Min = "--"
local timeStr_flag = true
time_disp_tmr:register(1000, tmr.ALARM_AUTO, 
function(t)
	if timeStr_flag then
		display:show_str(timeStr_Hour..":"..timeStr_Min)
	else
		display:show_str(timeStr_Hour.." "..timeStr_Min)
	end
	timeStr_flag = not timeStr_flag
end)

api_tmr:register(10000, tmr.ALARM_AUTO, 
function(t)
    print("update")
    http.get(api, nil, 
    function(code, data)
		print(code, data)
        if (code ~= 200) then
			display:update("HTTP RET", -1)
			display:update(tostring(code), -1)
        else
            local parsed = sjson.decode(data)
			if (parsed.sysTime2 ~= sjson.NULL) then
				print(parsed.sysTime2)
				timeStr_Hour = string.sub(parsed.sysTime2,-8,-7)
				timeStr_Min = string.sub(parsed.sysTime2,-5,-4)
			else
				display:update("ERROR X", -1)
            end
        end
    end)
end)

api_tmr:start()
time_disp_tmr:start()
