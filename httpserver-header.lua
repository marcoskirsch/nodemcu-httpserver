-- httpserver-header.lua
-- Part of nodemcu-httpserver, knows how to send an HTTP header.
-- Author: Marcos Kirsch

return function (connection, code, extension)

   local function getHTTPStatusString(code)
      local codez = {[200]="OK", [400]="Bad Request", [404]="Not Found",}
      local myResult = codez[code]
      -- enforce returning valid http codes all the way throughout?
      if myResult then return myResult else return "Not Implemented" end
   end

   local function getMimeType(ext)
      local gzip = false
      -- A few MIME types. Keep list short. If you need something that is missing, let's add it.
      local mt = {css = "text/css", gif = "image/gif", html = "text/html", ico = "image/x-icon", jpeg = "image/jpeg", jpg = "image/jpeg", js = "application/javascript", json = "application/json", png = "image/png", xml = "text/xml"}
      -- add comressed flag if file ends with gz
      if ext:find("%.gz$") then
          ext = ext:sub(1, -4)
          gzip = true
      end
      if mt[ext] then contentType = mt[ext] else contentType = "text/plain" end
      return {contentType = contentType, gzip = gzip}
   end

   local mimeType = getMimeType(extension)

   connection:send("HTTP/1.0 " .. code .. " " .. getHTTPStatusString(code) .. "\r\nServer: nodemcu-httpserver\r\nContent-Type: " .. mimeType["contentType"] .. "\r\n")
   if mimeType["gzip"] then
       connection:send("Content-Encoding: gzip\r\n")
   end
   connection:send("Connection: close\r\n\r\n")
end

