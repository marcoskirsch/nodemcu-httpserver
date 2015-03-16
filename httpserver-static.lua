-- httpserver-static.lua
-- Part of nodemcu-httpserver, handles sending static files to client.
-- Author: Marcos Kirsch

local function getMimeType(ext)
   -- A few MIME types. Keep list short. If you need something that is missing, let's add it.
   local mt = {css = "text/css", gif = "image/gif", html = "text/html", ico = "image/x-icon", jpeg = "image/jpeg", jpg = "image/jpeg", js = "application/javascript", josn="application/json", png = "image/png"}
   if mt[ext] then return mt[ext] else return "text/plain" end
end

local function sendHeader(connection, code, codeString, mimeType)
   connection:send("HTTP/1.0 " .. code .. " " .. codeString .. "\r\nServer: nodemcu-httpserver\r\nContent-Type: " .. mimeType .. "\r\nConnection: close\r\n\r\n")
end

return function (connection, args)
   sendHeader(connection, 200, "OK", getMimeType(args.ext))
   --print("Begin sending:", args.file)
   -- Send file in little chunks
   local continue = true
   local bytesSent = 0
   while continue do
      -- NodeMCU file API lets you open 1 file at a time.
      -- So we need to open, seek, close each time in order
      -- to support multiple simultaneous clients.
      file.open(args.file)
      file.seek("set", bytesSent)
      local chunk = file.read(512)
      file.close()
      if chunk == nil then
         continue = false
      else
         coroutine.yield()
         connection:send(chunk)
         bytesSent = bytesSent + #chunk
         --print("Sent" .. args.file, bytesSent)
      end
   end
   --print("Finished sending:", args.file)
end
