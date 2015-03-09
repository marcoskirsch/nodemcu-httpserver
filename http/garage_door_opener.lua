-- garage_door_opener.lua
-- Part of nodemcu-httpserver, example.
-- Author: Marcos Kirsch

local function pushTheButton(connection, pin)

   -- Redirect the user back to the static page where the garage door opener buttons are.
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\Cache-Control: private, no-store\r\n\r\n")
   connection:send('<script type="text/javascript">window.location.replace("/garage_door_opener.html");</script>')

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

end

return function (connection, args)
   print('Garage door button was pressed!')
   print('Door', args.door)
   if args.door == "1" then pushTheButton(connection, 3)             -- GPIO0
   elseif args.door == "2" then pushTheButton(connection, 4)         -- GPIO2
   else dofile("httpserver-error.lc")(connection, {code = 400}) end  -- Bad Request
end
