-- httpserver-conf.lua
-- Part of nodemcu-httpserver, contains static configuration for httpserver.
-- Author: Sam Dieck

local conf = {}

-- Configure Basic HTTP Authentication.
local auth = {}
-- Set to true if you want to enable.
auth.enabled = false
-- Displayed in the login dialog users see before authenticating.
auth.realm = "nodemcu-httpserver"
-- Add users and passwords to this table. Do not leave this unchanged if you enable authentication!
auth.users = {user1 = "password1", user2 = "password2", user3 = "password3"}

conf.auth = auth
return conf
