-- Begin WiFi configuration

local wifiConfig = {}

-- Possible modes:   wifi.STATION       : station: join a WiFi network
--                   wifi.SOFTAP        : access point: create a WiFi network
--                   wifi.STATIONAP     : both station and access point
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
   wifiConfig.stationConfig.ssid = "Internet"        -- Name of the WiFi network you want to join
   wifiConfig.stationConfig.pwd =  ""                -- Password for the WiFi network
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

-- Start nodemcu-httpsertver
if file.exists("httpserver-init.lc") then
   dofile("httpserver-init.lc")
else
   dofile("httpserver-init.lua")
end

