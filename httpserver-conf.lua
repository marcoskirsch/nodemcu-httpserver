-- httpserver-conf.lua
-- Part of nodemcu-httpserver, contains static configuration for httpserver.
-- Author: Sam Dieck

local conf = {}

-- Basic HTTP Authentication Conf
conf.auth = {}
conf.auth.enabled = true
conf.auth.realm = "nodemcu-httpserver" -- displayed in the login dialog users get
conf.auth.user = "user"
conf.auth.password = "password" -- PLEASE change this

-- Configuration for WiFi AP / Client Modes
conf.wifi = {}
-- wifi.STATION         -- station: join a WiFi network
-- wifi.SOFTAP          -- access point: create a WiFi network
-- wifi.wifi.STATIONAP  -- both station and access point
conf.wifi.mode = wifi.STATIONAP  -- both station and access point

-- Access Point
conf.wifi.AP = {}
conf.wifi.AP.config = {}
conf.wifi.AP.config.ssid = "ESP-"..node.chipid()   -- Name of the SSID you want to create
conf.wifi.AP.config.pwd = conf.auth.password       -- marginally more secure than the SSID?

-- Access Point IP
conf.wifi.AP.ip = {}
conf.wifi.AP.ip.ip = "192.168.1.1"
conf.wifi.AP.ip.netmask = "255.255.255.0"
conf.wifi.AP.ip.gateway = "192.168.1.1"

-- Client config
conf.wifi.client = {}
conf.wifi.client.ssid = "YOUR_INTERNET" -- Name of the WiFi network you want to join
conf.wifi.client.pwd =  "YOUR_PASSWORD"	-- Password for the WiFi network

return conf
