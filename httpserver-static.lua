-- httpserver-static.lua
-- Part of nodemcu-httpserver, handles sending static files to client.
-- Author: Marcos Kirsch

return function (connection, args, ishead)
   if ishead == 1 then
      dofile("httpserver-header.lc")(connection, 200, args.ext)
   end

   --print("Begin sending:", args.file)
   -- Send file in little chunks
   local bytesSent = connectionTable[connection].bytesSent

   collectgarbage()
   -- NodeMCU file API lets you open 1 file at a time.
   -- So we need to open, seek, close each time in order
   -- to support multiple simultaneous clients.
   file.open(args.file)
   file.seek("set", bytesSent)
   local chunk = file.read(256)
   file.close()
   if chunk == nil then
      return 0
   else
      connection:send(chunk)
      bytesSent = bytesSent + #chunk
      connectionTable[connection].bytesSent = bytesSent
      chunk = nil
      --print("Sent" .. args.file, bytesSent)
	  return 1
   end
end
