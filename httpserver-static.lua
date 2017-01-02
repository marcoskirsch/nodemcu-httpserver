-- httpserver-static.lua
-- Part of nodemcu-httpserver, handles sending static files to client.
-- Author: Marcos Kirsch

return function (connection, req, args)
   dofile("httpserver-header.lc")(connection, 200, args.ext, args.isGzipped)
   -- Send file in little chunks
   local bytesRemaining = file.list()[args.file]
   -- Chunks larger than 1024 don't work.
   -- https://github.com/nodemcu/nodemcu-firmware/issues/1075
   local chunkSize = 1024
   fileHandle = file.open(args.file)
   while bytesRemaining > 0 do
      local bytesToRead = 0
      if bytesRemaining > chunkSize then bytesToRead = chunkSize else bytesToRead = bytesRemaining end
      local chunk = fileHandle:read(bytesToRead)
      connection:send(chunk)
      bytesRemaining = bytesRemaining - #chunk
      chunk = nil
      collectgarbage()
   end
   print("Finished sending: ", args.file)
   fileHandle:close()
end
