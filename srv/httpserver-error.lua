-- httpserver-error.lua
-- Part of nodemcu-httpserver, handles sending error pages to client.
-- Author: Marcos Kirsch, Gregor Hartmann

return function (connection, req, args)
   local statusString = dofile("httpserver-header.lc")(connection, args.code, "html", false, args.headers)
   connection:send("<html><head><title>" .. args.code .. " - " .. statusString .. "</title></head><body><h1>" .. args.code .. " - " .. statusString .. "</h1></body></html>\r\n")
end
