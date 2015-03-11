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
   file.open(args.file)
   -- Send file in little chunks
   while true do
      local chunk = file.read(1024)
      if chunk == nil then break end
      coroutine.yield()
      connection:send(chunk)
   end
   print("Finished sending:", args.file)
   file.close()
end
