-- Begin WiFi configuration

local wifiConfig = {}

-- wifi.STATION         -- station: join a WiFi network
-- wifi.SOFTAP          -- access point: create a WiFi network
-- wifi.wifi.STATIONAP  -- both station and access point
wifiConfig.mode = wifi.STATION

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
--print('set (mode='..wifi.getmode()..')')

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
-- This only happens the first time after server .lua files are uploaded.

local compileAndRemoveIfNeeded = function(f)
   if file.open(f) then
      file.close()
      print('Compiling:', f)
      node.compile(f)
      file.remove(f)
      collectgarbage()
   end
end

local serverFiles = {
   'httpserver.lua',
   'httpserver-b64decode.lua',
   'httpserver-basicauth.lua',
   'httpserver-conf.lua',
   'httpserver-connection.lua',
   'httpserver-error.lua',
   'httpserver-header.lua',
   'httpserver-request.lua',
   'httpserver-static.lua',
}
for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

compileAndRemoveIfNeeded = nil
serverFiles = nil
collectgarbage()

-- Connect to the WiFi access point.
-- Once the device is connected, start the HTTP server.

startServer = function(ip, hostname)
   local serverPort = 80
   if (dofile("httpserver.lc")(serverPort)) then
      print("nodemcu-httpserver running at:")
      print("   http://" .. ip .. ":" ..  serverPort)
      if (mdns) then
         mdns.register(hostname, { description="A tiny server", service="http", port=serverPort, location='Earth' })
         print ('   http://' .. hostname .. '.local.:' .. serverPort)
      end
   end
end

if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then
   local joinCounter = 0
   local joinMaxAttempts = 5
   tmr.alarm(0, 3000, 1, function()
      local ip = wifi.sta.getip()
      if (not ip) then ip = wifi.ap.getip() end
      if ip == nil and joinCounter < joinMaxAttempts then
         print('Connecting to WiFi Access Point ...')
         joinCounter = joinCounter + 1
      else
         print("IP = " .. ip)
         if joinCounter == joinMaxAttempts then
            print('Failed to connect to WiFi Access Point.')
         else
            if (not not wifi.sta.getip()) or (not not wifi.ap.getip()) then
               -- Second parameter is for mDNS (aka Zeroconf aka Bonjour) registration.
               -- If the mdns module is compiled in the firmware, advertise the server with this name.
               -- If no mdns is compiled, then parameter is ignored.
               startServer(ip, "nodemcu")
            end
         end
         tmr.stop(0)
         joinCounter = nil
         joinMaxAttempts = nil
         collectgarbage()
      end
   end)
else
   startServer()
end

