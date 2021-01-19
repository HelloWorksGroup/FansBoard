
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
        if (code < 0) then
            print("HTTP request failed")
        else
            print(code, data)
            local parsed = sjson.decode(data)
            if (parsed.data~=sjson.NULL) then
                if (parsed.data.follower ~= sjson.NULL) then
					print("Fans:" .. parsed.data.follower)
					if fans < parsed.data.follower then
						display:update(tostring(parsed.data.follower), -1)
					else
						display:update(tostring(parsed.data.follower), 1)
					end
					fans = parsed.data.follower
                end
            end
        end
    end)
end)

api_tmr:start()
