-- garage_door_opener.lua
-- Part of nodemcu-httpserver, example.
-- Author: Marcos Kirsch

local function pushTheButton(connection, pin)

   -- push the button!
   -- The hardware in this case is a Wemos D1 Pro with two relay shields.
   -- The first relay is controlled with D1.
   -- The second one was modified to be controlled with D2.
   gpio.write(pin, gpio.HIGH)
   gpio.mode(pin, gpio.OUTPUT, gpio.FLOAT)
   tmr.delay(300000) -- in microseconds
   gpio.mode(pin, gpio.INPUT, gpio.FLOAT)
   gpio.write(pin, gpio.LOW)

   -- Send back JSON response.
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('{"error":0, "message":"OK"}')

end

return function (connection, req, args)
   print('Garage door button was pressed!', args.door)
   if     args.door == "1" then pushTheButton(connection, 1)
   elseif args.door == "2" then pushTheButton(connection, 2)
   else
      connection:send("HTTP/1.0 400 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
      connection:send('{"error":-1, "message":"Bad door"}')
   end
end
