-- httpserver-error.lua
-- Part of nodemcu-httpserver, handles sending error pages to client.
-- Author: Marcos Kirsch

return function (connection, args)

   local function sendHeader(connection, code, errorString, mimeType)
      connection:send("HTTP/1.0 " .. code .. " " .. errorString .. "\r\nServer: nodemcu-httpserver\r\nContent-Type: " .. mimeType .. "\r\nConnection: close\r\n\r\n")
   end

   print("Error " .. args.code .. ": " .. args.errorString)
   sendHeader(connection, args.code, args.errorString, "text/html")
   connection:send("<html><head><title>" .. args.code .. " - " .. args.errorString .. "</title></head><body><h1>" .. args.code .. " - " .. args.errorString .. "</h1></body></html>\r\n")
end
