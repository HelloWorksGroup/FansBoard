
api = "http://quan.suning.com/getSysTime.do"

print("app start")
print("heap3:" .. node.heap())
display = require("display")
print("heap4:" .. node.heap())
print("display init")

local api_tmr = tmr.create()

display:update("READY", 1)
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
				local timeStr = string.sub(parsed.sysTime2,-8,-4)
				print(timeStr)
				display:update(timeStr, 1)
			else
				display:update("ERROR X", -1)
            end
        end
    end)
end)

api_tmr:start()
