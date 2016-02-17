-- httpserver-connection
-- Part of nodemcu-httpserver, provides a buffered connection object that can handle multiple
-- consecutive send() calls.
-- For this to work, it must be used from a coroutine.
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

   --@TODO What are the hardcoded 1000 and 800 about? Can we increase?
   function newInstance:send(payload)
      local l = payload:len()
      if l + self.size > 1000 then
         if self:flush() then
            coroutine.yield()
         end
      end
      if l > 800 then
         self.connection:send(payload)
         coroutine.yield()
      else
         table.insert(self.data, payload)
         self.size = self.size + l
      end
   end

   return newInstance
end


return BufferedConnection
