-- httpserver-conf.lua
-- Part of nodemcu-httpserver, contains static configuration for httpserver. 
-- Author: Sam Dieck

conf = {}

-- WIFI
-- FIXME use these
--wifi = {}
--wifi.essid = "Internet"
--wifi.password = ""

-- Basic Authentication Conf
auth = {}
auth.enabled = false
auth.user = "user"
auth.password = "password"
conf.auth = auth

return conf
