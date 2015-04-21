-- httpserver-header.lua
-- Part of nodemcu-httpserver, knows how to send an HTTP header.
-- Author: Marcos Kirsch

return function (connection, code, extension)

   local function getHTTPStatusString(code)
      if code == 200 then return "OK" end
      if code == 404 then return "Not Found" end
      if code == 400 then return "Bad Request" end
      if code == 501 then return "Not Implemented" end
      return "Unknown HTTP status"
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

