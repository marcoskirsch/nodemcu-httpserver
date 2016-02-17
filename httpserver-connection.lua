-- httpserver-connection
-- Part of nodemcu-httpserver, provides a buffered connection object that can handle multiple
-- consecutive send() calls, and buffers small payloads to send once they get big.
-- For this to work, it must be used from a coroutine and owner is responsible for the final
-- flush() and for closing the connection.
-- Author: Philip Gladstone, Marcos Kirsch

BufferedConnection = {}

-- parameter is the nodemcu-firmware connection
function BufferedConnection:new(connection)
   local newInstance = {}
   newInstance.connection = connection
   newInstance.size = 0
   newInstance.data = {}

   function newInstance:flush()
      if self.size > 0 then
         self.connection:send(table.concat(self.data, ""))
         self.data = {}
         self.size = 0
         return true
      end
      return false
   end

   function newInstance:send(payload)
      local l = payload:len()
      if l + self.size > 1024 then
         -- Send what we have buffered so far, not including payload.
         if self:flush() then
            coroutine.yield()
         end
      end
      if l > 768 then
         -- Payload is big. Send it now rather than buffering it for later.
         self.connection:send(payload)
         coroutine.yield()
      else
         -- Payload is small. Save off payload for later sending.
         table.insert(self.data, payload)
         self.size = self.size + l
      end
   end

   return newInstance
end

return BufferedConnection
