-- Compile freshly uploaded nodemcu-httpserver lua files.
if file.exists("httpserver-compile.lc") then
   dofile("httpserver-compile.lc")
else
   dofile("httpserver-compile.lua")
end

-- Set up NodeMCU's WiFi
dofile("httpserver-wifi.lc")

-- Start nodemcu-httpsertver
dofile("httpserver-init.lc")
