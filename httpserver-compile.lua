-- httpserver-compile.lua
-- Part of nodemcu-httpserver, compiles server code after upload.
-- Author: Marcos Kirsch

local compileAndRemoveIfNeeded = function(f)
   if file.exists(f) then
      local newf = f:gsub("%w+/", "")
      file.rename(f, newf)
      print('Compiling:', newf)
      node.compile(newf)
      file.remove(newf)
      collectgarbage()
   end
end

local serverFiles = {
   'srv/httpserver.lua',
   'srv/httpserver-b64decode.lua',
   'srv/httpserver-basicauth.lua',
   'srv/httpserver-buffer.lua',
   'srv/httpserver-connection.lua',
   'srv/httpserver-error.lua',
   'srv/httpserver-header.lua',
   'srv/httpserver-init.lua',
   'srv/httpserver-request.lua',
   'srv/httpserver-static.lua',
   'srv/httpserver-wifi.lua',
}

local lfsFiles = {
   'srv/_init.lua',
   'srv/dummy_strings.lua',
}
for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end
for i, f in ipairs(lfsFiles) do file.remove(f) end

compileAndRemoveIfNeeded = nil
serverFiles = nil
lfsFiles = nil
collectgarbage()
