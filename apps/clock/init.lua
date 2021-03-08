
-- uart.setup(0, 460800, 8, 0, 1, 1 )
display = require("display")

-- 避免由于断网重新联网导致的app重入
-- 以及显示混乱的问题
app_started = false

display:update("BOOT", -1)
if file.open("setting.lua") == nil then
	display:update("NOT SET", -1)
	tmr.softwd(5)
	return
else
	file.close("setting.lua")
	dofile("setting.lua")
end

function startup()
	if file.open("init.lua") == nil then
		print("init.lua deleted or renamed")
	else
		file.close("init.lua")
		app_started = true
		dofile("application.lua")
	end
end

-- Define WiFi station event callbacks
wifi_connect_event = function(T)
	if not app_started then
		display:update("CONNECT", -1)
	end
	print("Connection to AP("..T.SSID..") established!")
	print("Waiting for IP address...")
	if disconnect_ct ~= nil then disconnect_ct = nil end
end

wifi_got_ip_event = function(T)
	print("Wifi connection is ready! IP address is: "..T.IP)
	if not app_started then
		display:update("GET IP", -1)
		display:update("READY", 1)
	-- Note: Having an IP address does not mean there is internet access!
	-- Internet connectivity can be determined with net.dns.resolve().
		tmr.create():alarm(2000, tmr.ALARM_SINGLE, startup)
	end
end

wifi_disconnect_event = function(T)
	if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
		--the station has disassociated from a previously connected AP
		return
	end
	-- total_tries: how many times the station will attempt to connect to the AP. Should consider AP reboot duration.
	local total_tries = 7
	print("\nWiFi connection to AP("..T.SSID..") has failed!")

	--There are many possible disconnect reasons, the following iterates through
	--the list and returns the string corresponding to the disconnect reason.
	for key,val in pairs(wifi.eventmon.reason) do
		if val == T.reason then
			print("Disconnect reason: "..val.."("..key..")")
			break
		end
	end

	if disconnect_ct == nil then
		disconnect_ct = 1
	else
		disconnect_ct = disconnect_ct + 1
	end
	if not app_started then
		if disconnect_ct < total_tries then
			display:update("RETRY-" .. disconnect_ct, -1)
			print("Retrying connection...(attempt "..(disconnect_ct+1).." of "..total_tries..")")
		else
			wifi.sta.disconnect()
			print("Aborting connection to AP!")
			disconnect_ct = nil
			display:update("FAILED", -1)
			tmr.softwd(5)
		end
	else
	end
end

-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect_event)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)

display:update("WIFI", -1)
print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=SSID, pwd=PASSWORD})
