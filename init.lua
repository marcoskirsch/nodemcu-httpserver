-- Begin WiFi configuration
conf = dofile("httpserver-conf.lc")

-- Tell the chip to connect to the access point

wifi.setmode(conf.wifi.mode)
print('Wifi Mode:'..wifi.getmode())

if (conf.wifi.mode == wifi.SOFTAP) or (conf.wifi.mode == wifi.STATIONAP) then
    print('AP MAC: '..wifi.ap.getmac())
    wifi.ap.config(conf.wifi.AP.config)
    wifi.ap.setip(conf.wifi.AP.ip)
end
if (conf.wifi.mode == wifi.STATION) or (conf.wifi.mode == wifi.STATIONAP) then
    print('Client MAC: '..wifi.sta.getmac())
    wifi.sta.config(conf.wifi.client.ssid, conf.wifi.client.pwd, 1)
end

print('Chip: '..node.chipid()..' Heap: '..node.heap())

conf = nil
collectgarbage()

-- End WiFi configuration

-- Compile server code and remove original .lua files.
-- This only happens the first time afer the .lua files are uploaded.

local compileAndRemoveIfNeeded = function(f)
   if file.open(f) then
      file.close()
      print('Compiling:', f)
      node.compile(f)
      file.remove(f)
      collectgarbage()
   end
end

local serverFiles = {'httpserver.lua', 'httpserver-basicauth.lua', 'httpserver-conf.lua', 'httpserver-b64decode.lua', 'httpserver-request.lua', 'httpserver-static.lua', 'httpserver-header.lua', 'httpserver-error.lua'}
for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

compileAndRemoveIfNeeded = nil
serverFiles = nil
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
    dofile("httpserver.lc")(80)    
end


