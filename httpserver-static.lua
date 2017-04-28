-- httpserver-static.lua
-- Part of nodemcu-httpserver, handles sending static files to client.
-- Author: Gregor Hartmann

return function (connection, req, args)

   local buffer = dofile("httpserver-buffer.lc"):new()
   dofile("httpserver-header.lc")(buffer, req.code or 200, args.ext, args.isGzipped)
   -- Send header and return fileInfo
   connection:send(buffer:getBuffer())
   
   return { file = args.file, sent = 0}
end
