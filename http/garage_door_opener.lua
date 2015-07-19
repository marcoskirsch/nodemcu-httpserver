-- garage_door_opener.lua
-- Part of nodemcu-httpserver, example.
-- Author: Marcos Kirsch

local function pushTheButton(connection, pin)

   -- push the button!
   -- Note that the relays connected to the garage door opener are wired
   -- to close when the GPIO pin is low. This way they don't activate when
   -- the chip is reset and the GPIO pins are in input mode.
   gpio.write(pin, gpio.LOW)
   gpio.mode(pin, gpio.OUTPUT)
   gpio.write(pin, gpio.LOW)
   tmr.delay(300000) -- in microseconds
   gpio.write(pin, gpio.HIGH)
   gpio.mode(pin, gpio.INPUT)

   -- Send back JSON response.
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('{"error":0, "message":"OK"}')

end

return function (connection, args)
   print('Garage door button was pressed!', args.door)
   if     args.door == "1" then pushTheButton(connection, 1)   -- GPIO1
   elseif args.door == "2" then pushTheButton(connection, 2)   -- GPIO2
   else
      connection:send("HTTP/1.0 400 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
      connection:send('{"error":-1, "message":"Bad door"}')
   end
end
