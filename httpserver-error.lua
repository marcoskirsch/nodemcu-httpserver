-- httpserver-error.lua
-- Part of nodemcu-httpserver, handles sending error pages to client.
-- Author: Marcos Kirsch, Gregor Hartmann

return function (connection, req, args)
   local statusString = dofile("httpserver-header.lc")(connection, req.code, "html", false, req.headers)
   connection:send("<html><head><title>" .. req.code .. " - " .. statusString .. "</title></head><body><h1>" .. req.code .. " - " .. statusString .. "</h1></body></html>\r\n")
end
