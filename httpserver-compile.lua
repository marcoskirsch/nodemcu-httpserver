-- httpserver-compile.lua
-- Part of nodemcu-httpserver, compiles server code after upload.
-- Author: Marcos Kirsch

local compileAndRemoveIfNeeded = function(f)
   if file.exists(f) then
      print('Compiling:', f)
      node.compile(f)
      file.remove(f)
      collectgarbage()
   end
end

local serverFiles = {
   'httpserver.lua',
   'httpserver-b64decode.lua',
   'httpserver-basicauth.lua',
   'httpserver-compile.lua',
   'httpserver-conf.lua',
   'httpserver-connection.lua',
   'httpserver-error.lua',
   'httpserver-header.lua',
   'httpserver-init.lua',
   'httpserver-request.lua',
   'httpserver-static.lua',
   'httpserver-wifi.lua',
}
for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

compileAndRemoveIfNeeded = nil
serverFiles = nil
collectgarbage()

