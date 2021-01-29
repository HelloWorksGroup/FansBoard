
api = "http://api.bilibili.com/x/relation/stat?vmid="
uid = "895523"

print("app start")
print("heap3:" .. node.heap())
display = require("display")
print("heap4:" .. node.heap())
print("display init")

local api_tmr = tmr.create()

display:update("READY", 1)
fans = 0
api_tmr:register(7000, tmr.ALARM_AUTO, 
function(t)
    print("update")
    http.get(api..uid, nil, 
    function(code, data)
		print(code, data)
        if (code ~= 200) then
			display:update("HTTP RET", -1)
			display:update(tostring(code), -1)
        else
            local parsed = sjson.decode(data)
			if (parsed.code ~= sjson.NULL) then
				if (parsed.code ~= 0) then
					display:update("API RET", -1)
					display:update(tostring(parsed.code), -1)
				elseif (parsed.data~=sjson.NULL and parsed.data.follower ~= sjson.NULL) then
					print("Fans:" .. parsed.data.follower)
					if fans < parsed.data.follower then
						display:update(tostring(parsed.data.follower), -1)
					else
						display:update(tostring(parsed.data.follower), 1)
					end
					fans = parsed.data.follower
				else
					display:update("ERROR X", -1)
				end
            end
        end
    end)
end)

api_tmr:start()
