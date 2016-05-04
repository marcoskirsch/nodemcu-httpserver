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
      local flushthreshold = 1400

      local newsize = self.size + payload:len()
      while newsize > flushthreshold do
          --STEP1: cut out piece from payload to complete threshold bytes in table
          local piecesize = flushthreshold - self.size
          local piece = payload:sub(1, piecesize)
          payload = payload:sub(piecesize + 1, -1)
          --STEP2: insert piece into table
          table.insert(self.data, piece)
          self.size = self.size + piecesize --size should be same as flushthreshold
          --STEP3: flush entire table
          if self:flush() then
              coroutine.yield()
          end
          --at this point, size should be 0, because the table was just flushed
          newsize = self.size + payload:len()
      end
            
      --at this point, whatever is left in payload should be <= flushthreshold
      local plen = payload:len()
      if plen == flushthreshold then
          --case 1: what is left in payload is exactly flushthreshold bytes (boundary case), so flush it
          table.insert(self.data, payload)
          self.size = self.size + plen
          if self:flush() then
              coroutine.yield()
          end
      elseif payload:len() then
          --case 2: what is left in payload is less than flushthreshold, so just leave it in the table
          table.insert(self.data, payload)
          self.size = self.size + plen
      --else, case 3: nothing left in payload, so do nothing
      end
   end

   return newInstance
end

return BufferedConnection
