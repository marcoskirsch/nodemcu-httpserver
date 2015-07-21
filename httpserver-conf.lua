-- httpserver-conf.lua
-- Part of nodemcu-httpserver, contains static configuration for httpserver.
-- Author: Sam Dieck

local conf = {}

-- Basic Authentication Conf
local auth = {}
auth.enabled = false
auth.realm = "nodemcu-httpserver" -- displayed in the login dialog users get
auth.user = "user"
auth.password = "password" -- PLEASE change this
conf.auth = auth

return conf
