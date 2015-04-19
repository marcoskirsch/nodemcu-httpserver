-- httpserver-error.lua
-- Part of nodemcu-httpserver, handles sending error pages to client.
-- Author: Marcos Kirsch

local function getHTTPStatusString(code)
   if code == 404 then return "Not Found" end
   if code == 400 then return "Bad Request" end
   if code == 501 then return "Not Implemented" end
   return "Unknown HTTP status"
end

local function sendHeader(connection, code, codeString, mimeType)
   connection:send("HTTP/1.0 " .. code .. " " .. codeString .. "\r\nServer: nodemcu-httpserver\r\nContent-Type: " .. mimeType .. "\r\nConnection: close\r\n\r\n")
end

return function (connection, args)
   local errorString = getHTTPStatusString(args.code)
   print("Error " .. args.code .. ": " .. errorString)
   sendHeader(connection, args.code, errorString, "text/html")
   connection:send("<html><head><title>" .. args.code .. " - " .. errorString .. "</title></head><body><h1>" .. args.code .. " - " .. errorString .. "</h1></body></html>\r\n")
end
