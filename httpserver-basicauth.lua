-- httpserver-basicauth.lua
-- Part of nodemcu-httpserver, authenticates a user using http basic auth.
-- Author: Sam Dieck

basicAuth = {}

-- Returns true if the user/password match one of the users/passwords in httpserver-conf.lua.
-- Returns false otherwise.
function loginIsValid(user, pwd, users)
   if user == nil then return false end
   if pwd == nil then return false end
   if users[user] == nil then return false end
   if users[user] ~= pwd then return false end
   return true
end

-- Parse basic auth http header.
-- Returns the username if header contains valid credentials,
-- nil otherwise.
function basicAuth.authenticate(header)
   local conf = dofile("httpserver-conf.lc")
   local credentials_enc = header:match("Authorization: Basic ([A-Za-z0-9+/=]+)")
   if not credentials_enc then
      return nil
   end
   local credentials = dofile("httpserver-b64decode.lc")(credentials_enc)
   local user, pwd = credentials:match("^(.*):(.*)$")
   if loginIsValid(user, pwd, conf.auth.users) then
      print("httpserver-basicauth: User \"" .. user .. "\": Authenticated.")
      return user
   else
      print("httpserver-basicauth: User \"" .. user .. "\": Access denied.")
      return nil
   end
end

function basicAuth.authErrorHeader()
   local conf = dofile("httpserver-conf.lc")
   return "WWW-Authenticate: Basic realm=\"" .. conf.auth.realm .. "\""
end

return basicAuth
