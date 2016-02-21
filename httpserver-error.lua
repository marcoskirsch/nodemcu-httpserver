-- httpserver-error.lua
-- Part of nodemcu-httpserver, handles sending error pages to client.
-- Author: Marcos Kirsch

return function (connection, req, args)

   -- @TODO: would be nice to use httpserver-header.lua
   local function getHeader(connection, code, errorString, extraHeaders, mimeType)
      local header = "HTTP/1.0 " .. code .. " " .. errorString .. "\r\nServer: nodemcu-httpserver\r\nContent-Type: " .. mimeType .. "\r\n"
      for i, extraHeader in ipairs(extraHeaders) do
         header = header .. extraHeader .. "\r\n"
      end
      header = header .. "connection: close\r\n\r\n"
      return header
   end

   print("Error " .. args.code .. ": " .. args.errorString)
   args.headers = args.headers or {}
   connection:send(getHeader(connection, args.code, args.errorString, args.headers, "text/html"))
   connection:send("<html><head><title>" .. args.code .. " - " .. args.errorString .. "</title></head><body><h1>" .. args.code .. " - " .. args.errorString .. "</h1></body></html>\r\n")

end
