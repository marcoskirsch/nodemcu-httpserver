-- Begin WiFi configuration

local wifiConfig = {}

-- Possible modes:   wifi.STATION       : station: join a WiFi network
--                   wifi.SOFTAP        : access point: create a WiFi network
--                   wifi.wifi.STATIONAP: both station and access point
wifiConfig.mode = wifi.STATION

if (wifiConfig.mode == wifi.SOFTAP) or (wifiConfig.mode == wifi.STATIONAP) then
   wifiConfig.accessPointConfig = {}
   wifiConfig.accessPointConfig.ssid = "ESP-"..node.chipid()   -- Name of the SSID you want to create
   wifiConfig.accessPointConfig.pwd = "ESP-"..node.chipid()    -- WiFi password - at least 8 characters

   wifiConfig.accessPointIpConfig = {}
   wifiConfig.accessPointIpConfig.ip = "192.168.111.1"
   wifiConfig.accessPointIpConfig.netmask = "255.255.255.0"
   wifiConfig.accessPointIpConfig.gateway = "192.168.111.1"
end

if (wifiConfig.mode == wifi.STATION) or (wifiConfig.mode == wifi.STATIONAP) then
   wifiConfig.stationConfig = {}
   wifiConfig.stationConfig.ssid = "Kirsch Extreme"        -- Name of the WiFi network you want to join
   wifiConfig.stationConfig.pwd =  "1151511515"                -- Password for the WiFi network
end

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
    wifi.sta.config(wifiConfig.stationConfig.ssid, wifiConfig.stationConfig.pwd, 1)
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


-- Function for starting the server.
-- If you compiled the mdns module, then it will register the server with that name.
local startServer = function(ip, hostname)
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

   -- Connect to the WiFi access point and start server once connected.
   -- If the server loses connectivity, server will restart.
   wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(args)
      print("Connected to WiFi Access Point. Got IP: " .. args["IP"])
      startServer(args["IP"], "garage")
      wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(args)
         print("Lost connectivity! Restarting...")
         node.restart()
      end)
   end)

   -- What if after a while (30 seconds) we didn't connect? Restart and keep trying.
   local watchdogTimer = tmr.create()
   watchdogTimer:register(30000, tmr.ALARM_SINGLE, function (watchdogTimer)
      local ip = wifi.sta.getip()
      if (not ip) then ip = wifi.ap.getip() end
      if ip == nil then
         print("No IP after a while. Restarting...")
         node.restart()
      else
         --print("Successfully got IP. Good, no need to restart.")
         watchdogTimer:unregister()
      end
   end)
   watchdogTimer:start()


else

   startServer(wifi.ap.getip(), "nodemcu")

end

