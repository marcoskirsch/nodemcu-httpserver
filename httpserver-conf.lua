-- httpserver-conf.lua
-- Part of nodemcu-httpserver, contains static configuration for httpserver.
-- Author: Sam Dieck

local conf = {}

-- Basic Authentication Conf
local auth = {}
auth.enabled = true
auth.realm = "nodemcu-httpserver" -- displayed in the login dialog users get
-- Add users and passwords to this table. Do not leave this unchanged if you enable authentication!
auth.users = {user1 = "password1", user2 = "password2", user3 = "password3"}
conf.auth = auth

return conf
