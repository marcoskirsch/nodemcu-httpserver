-- httpserver-static.lua
-- Part of nodemcu-httpserver, handles sending static files to client.
-- Author: Marcos Kirsch

return function (connection, req, args)
   --print("Begin sending:", args.file)
   --print("node.heap(): ", node.heap())
   dofile("httpserver-header.lc")(connection, 200, args.ext, args.isGzipped)
   -- Send file in little chunks
   local continue = true
   local size = file.list()[args.file]
   local bytesSent = 0
   -- Chunks larger than 1024 don't work.
   -- https://github.com/nodemcu/nodemcu-firmware/issues/1075
   local chunkSize = 1024
   while continue do
      collectgarbage()

      -- NodeMCU file API lets you open 1 file at a time.
      -- So we need to open, seek, close each time in order
      -- to support multiple simultaneous clients.
      file.open(args.file)
      file.seek("set", bytesSent)
      local chunk = file.read(chunkSize)
      file.close()

      connection:send(chunk)
      bytesSent = bytesSent + #chunk
      chunk = nil
      --print("Sent: " .. bytesSent .. " of " .. size)
      if bytesSent == size then continue = false end
   end
   --print("Finished sending: ", args.file)
end
