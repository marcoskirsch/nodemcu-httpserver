-- httpserver-header.lua
-- Part of nodemcu-httpserver, knows how to send an HTTP header.
-- Author: Marcos Kirsch

return function(connection, code, extension, isGzipped, extraHeaders)

   local function getHTTPStatusString(code)
      local codez = { [200] = "OK", [400] = "Bad Request", [401] = "Unauthorized", [404] = "Not Found", [405] = "Method Not Allowed", [500] = "Internal Server Error", [501] = "Not Implemented", }
      local myResult = codez[code]
      -- enforce returning valid http codes all the way throughout?
      if myResult then return myResult else return "Not Implemented" end
   end

   local function getMimeType(ext)
      -- A few MIME types. Keep list short. If you need something that is missing, let's add it.
      local mt = {css = "text/css", gif = "image/gif", html = "text/html", ico = "image/x-icon", jpeg = "image/jpeg", 
         jpg = "image/jpeg", js = "application/javascript", json = "application/json", png = "image/png", xml = "text/xml"}
      if mt[ext] then return mt[ext] else return "text/plain" end
   end

   local mimeType = getMimeType(extension)
   local statusString = getHTTPStatusString(code)
   
   connection:send("HTTP/1.0 " .. code .. " " .. statusString .. "\r\nServer: nodemcu-httpserver\r\nContent-Type: " .. mimeType .. "\r\n")
   if isGzipped then
      connection:send("Cache-Control: private, max-age=2592000\r\nContent-Encoding: gzip\r\n")
   end
   if (extraHeaders) then
      for i, extraHeader in ipairs(extraHeaders) do
         connection:send(extraHeader .. "\r\n")
      end
   end

   connection:send("Connection: close\r\n\r\n")
   return statusString
end

