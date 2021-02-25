
if not api then
	api = "http://quan.suning.com/getSysTime.do"
else
	return
end

display = require("display")

local api_tmr = tmr.create()
local time_disp_tmr = tmr.create()

display:update("READY", 1)
local timeStr_Hour = "--"
local timeStr_Min = "--"
local timeStr_flag = true

-- 是否从网络获取时间
local timeWifi = 0

time_disp_tmr:register(1000, tmr.ALARM_AUTO, 
function(t)
	local coma = " "
	if timeStr_flag then
		coma = ":"
	end
	if timeWifi == 0 then
		display:show_str("!"..timeStr_Hour..coma..timeStr_Min.."!")
	else
		timeWifi = timeWifi-1
		display:show_str(timeStr_Hour..coma..timeStr_Min)
	end
	timeStr_flag = not timeStr_flag
end)

local minute_tmr = tmr.create()
minute_tmr:register(60000, tmr.ALARM_SEMI,
function(t)
	local m = tonumber(timeStr_Min)
	local h = tonumber(timeStr_Hour)
	m = m+1
	if m>=60 then
		h = h+1
		if h>=24 then
			h = 0
		end
	end
	timeStr_Min = string.format("%02d",m)
	timeStr_Hour = string.format("%02d",h)
	minute_tmr:interval(60000)
	minute_tmr:start(true)
end
)

api_tmr:register(1000, tmr.ALARM_AUTO, 
function(t)
	api_tmr:interval(60000)
	print("update")
    http.get(api, nil, 
    function(code, data)
		print(code, data)
		if (code ~= 200) then
			print("HTTP RET"..tostring(code))
			-- display:update("HTTP RET", -1)
			-- display:update(tostring(code), -1)
        else
            local parsed = sjson.decode(data)
			if (parsed.sysTime2 ~= sjson.NULL) then
				print(parsed.sysTime2)
				timeStr_Hour = string.sub(parsed.sysTime2,-8,-7)
				timeStr_Min = string.sub(parsed.sysTime2,-5,-4)
				timeWifi = 210

				local timeStr_Sec = string.sub(parsed.sysTime2,-2,-1)
				print("Current sec:"..timeStr_Sec)
				print("Update After:"..(60-tonumber(timeStr_Sec)))
				minute_tmr:interval((60-tonumber(timeStr_Sec))*1000)
				minute_tmr:start(true)
			else
				display:update("ERROR X", -1)
            end
        end
    end)
end)
api_tmr:start()

time_disp_tmr:start()
