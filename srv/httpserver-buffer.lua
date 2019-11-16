-- httpserver-buffer
-- Part of nodemcu-httpserver, provides a buffer that behaves like a connection object
-- that can handle multiple consecutive send() calls, and buffers small payloads up to 1400 bytes.
-- This is primarily user to collect the send requests done by the head script.
-- The owner is responsible to call getBuffer and send its result
-- Author: Gregor Hartmann

local Buffer = {}

-- parameter is the nodemcu-firmware connection
function Buffer:new()
   local newInstance = {}
   newInstance.size = 0
   newInstance.data = {}

   -- Returns true if there was any data to be sent.
   function newInstance:getBuffer()
      local buffer = table.concat(self.data, "")
      self.data = {}
      self.size = 0
      return buffer
   end

   function newInstance:getpeer()
      return "no peer"
   end

   function newInstance:send(payload)
      local flushThreshold = 1400
      if (not payload) then print("nop payload") end
      local newSize = self.size + payload:len()
      if newSize >= flushThreshold then
         print("Buffer is full. Cutting off "..newSize-flushThreshold.." chars")
         --STEP1: cut out piece from payload to complete threshold bytes in table
         local pieceSize = flushThreshold - self.size
         if pieceSize then
            payload = payload:sub(1, pieceSize)
         end
      end
      table.insert(self.data, payload)
      self.size = self.size + #payload
   end
   
   return newInstance

end

return Buffer
