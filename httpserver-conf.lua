-- httpserver-conf.lua
-- Part of nodemcu-httpserver, contains static configuration for httpserver.
-- Author: Sam Dieck

local conf = {}

-- General server configuration.
local general = {}
-- TCP port in which to listen for incoming HTTP requests.
general.port = 80
conf.general = general

-- mDNS, applies if you compiled the mdns module in your firmware.
local mdns = {}
mdns.hostname = 'nodemcu' -- You will be able to access your server at "http://nodemcu.local."
mdns.location = 'Earth'
mdns.description = 'A tiny HTTP server'
conf.mdns = mdns

-- Basic HTTP Authentication.
local auth = {}
-- Set to true if you want to enable.
auth.enabled = false
-- Displayed in the login dialog users see before authenticating.
auth.realm = "nodemcu"
-- Add users and passwords to this table. Do not leave this unchanged if you enable authentication!
auth.users = {user1 = "password1", user2 = "password2", user3 = "password3"}
conf.auth = auth

return conf
