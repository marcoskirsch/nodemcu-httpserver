-- Begin WiFi configuration

local wifiConfig = {}

-- wifi.STATION         -- station: join a WiFi network
-- wifi.SOFTAP          -- access point: create a WiFi network
-- wifi.wifi.STATIONAP  -- both station and access point
wifiConfig.mode = wifi.STATIONAP  -- both station and access point

wifiConfig.accessPointConfig = {}
wifiConfig.accessPointConfig.ssid = "ESP-"..node.chipid()   -- Name of the SSID you want to create
wifiConfig.accessPointConfig.pwd = "ESP-"..node.chipid()    -- WiFi password - at least 8 characters

wifiConfig.accessPointIpConfig = {}
wifiConfig.accessPointIpConfig.ip = "192.168.111.1"
wifiConfig.accessPointIpConfig.netmask = "255.255.255.0"
wifiConfig.accessPointIpConfig.gateway = "192.168.111.1"

wifiConfig.stationPointConfig = {}
wifiConfig.stationPointConfig.ssid = "Internet"        -- Name of the WiFi network you want to join
wifiConfig.stationPointConfig.pwd =  ""                -- Password for the WiFi network

-- Tell the chip to connect to the access point

wifi.setmode(wifiConfig.mode)
print('set (mode='..wifi.getmode()..')')

if (wifiConfig.mode == wifi.SOFTAP) or (wifiConfig.mode == wifi.STATIONAP) then
    print('AP MAC: ',wifi.ap.getmac())
    wifi.ap.config(wifiConfig.accessPointConfig)
    wifi.ap.setip(wifiConfig.accessPointIpConfig)
end
if (wifiConfig.mode == wifi.STATION) or (wifiConfig.mode == wifi.STATIONAP) then
    print('Client MAC: ',wifi.sta.getmac())
    wifi.sta.config(wifiConfig.stationPointConfig.ssid, wifiConfig.stationPointConfig.pwd, 1)
end

print('chip: ',node.chipid())
print('heap: ',node.heap())

wifiConfig = nil
collectgarbage()

-- End WiFi configuration

-- Compile server code and remove original .lua files.
-- All files that names not starting from "httpserver-" will be moved (renamed) to http/(filename)
-- This only happens the first time afer the .lua files are uploaded.

local compileAndRemove = function()
	for name in pairs(file.list()) do
		local isHttpFile = string.match(name, "^(http/)")
		local isCompiled = string.match(name, ".+(\.lc)$")
		local isLuaScript = string.match(name, ".+(\.lua)$")
		
		if (name ~= 'init.lua') and (name ~= 'init_start.lua') and (name ~= 'LLbin.lua') then
			if (not isHttpFile) and (not isCompiled) then
				if isLuaScript then
					if file.open(name) then
						file.close(name)
						file.remove(string.sub(name, 0, -3) .. "lc")
						print('Compiling:', name)
						node.compile(name)
						file.remove(name)
					end
				end
			end
		end
	end
end

local renameAndRemove = function()
	for name in pairs(file.list()) do
		local isHttpFile = string.match(name, "^(http/)")
		local isServerFile = string.match(name, "^(httpserver)")
		
		if (name ~= 'init.lua') and (name ~= 'init_start.lua') and (name ~= 'LLbin.lua') then
			if (not isHttpFile) and (not isServerFile) then
				if file.open(name) then
					file.close(name)
					print('Moving:', name)
					file.remove("http/"..name)					
					file.rename(name,"http/"..name)
					file.remove(name)
				end
			end
		end
	end
end

compileAndRemove()
renameAndRemove()
compileAndRemove = nil
renameAndRemove = nil
collectgarbage()

-- Connect to the WiFi access point.
-- Once the device is connected, you may start the HTTP server.

if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then
    local joinCounter = 0
    local joinMaxAttempts = 5
    tmr.alarm(0, 3000, 1, function()
       local ip = wifi.sta.getip()
       if ip == nil and joinCounter < joinMaxAttempts then
          print('Connecting to WiFi Access Point ...')
          joinCounter = joinCounter +1
       else
          if joinCounter == joinMaxAttempts then
             print('Failed to connect to WiFi Access Point.')
          else
             print('IP: ',ip)
          end
          tmr.stop(0)
          joinCounter = nil
          joinMaxAttempts = nil
          collectgarbage()
       end
    end)
end

-- Uncomment to automatically start the server in port 80
if (not not wifi.sta.getip()) or (not not wifi.ap.getip()) then
    --dofile("httpserver.lc")(80)
end

