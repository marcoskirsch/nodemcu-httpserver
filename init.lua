-- Tel--l the chip to connect to the access point
--wifi.setmode(wifi.STATIONAP)
wifi.setmode(wifi.STATION)
print('set (mode='..wifi.getmode()..')')
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())

local joincounter = 0

cfg={}
cfg.ssid="ESP-"..node.chipid()
cfg.pwd="ESP-"..node.chipid()
wifi.ap.config(cfg)
cfg = nil

-- Compile server code and remove original .lua files.
-- This only happens the first time afer the .lua files are uploaded.

local compileAndRemoveIfNeeded = function(f)
   if file.open(f) then
      file.close()
      node.compile(f)
      file.remove(f)
   end
end

local serverFiles = {'httpserver.lua', 'httpserver-request.lua', 'httpserver-static.lua', 'httpserver-error.lua'}
for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

compileAndRemoveIfNeeded = nil
serverFiles = nil

-- Connect to the WiFi access point. Once the device is connected,
-- you may start the HTTP server.
tmr.alarm(0, 3000, 1, function()

   if wifi.sta.getip() == nil and joincounter < 5 then
      print("Connecting to AP...")
      joincounter = joincounter +1
   else 
      tmr.stop(0)
      -- print('IP: ',wifi.sta.getip())
      -- Uncomment to automatically start the server in port 80
      joincounter = nil
      collectgarbage()
      dofile("httpserver.lc")(80)
   end

end)

