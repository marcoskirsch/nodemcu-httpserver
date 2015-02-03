print('Welcome to GARAGE')
print('   Created by Marcos Kirsch')

require "webServer"

pinGarage = 4 -- GPIO2
clientTimeoutInSeconds = 10
port = 80

-- Prepare pins
function preparePin(pin)
   -- Pins start out configured for input, and the relay has a pulldown resistor
   -- in order to prevent from activating on reset. Makes ure to set pin to low
   -- BEFORE setting to output, less the relay see it as a toggle.
   gpio.write(pin, gpio.LOW)
   gpio.mode(pin, gpio.OUTPUT)
end
preparePin(pinGarage)

-- This functions emulates pushing the button for opening/closing the garage door.
function pushTheButton(pin)
   gpio.write(pin, gpio.HIGH)
   delayInMicroseconds = 500000 -- half a second should be enough
   tmr.delay(delayInMicroseconds)
   gpio.write(pin, gpio.LOW)
end

-- Read the "garage remote" HTML that is served
--file.open("remote.html", "r")
--html = file.read()

webServer.start(port, clientTimeoutInSeconds)

--
--server = net.createServer(net.TCP, clientTimeoutInSeconds) server:listen(port, function(connection)
--   --if server == nil
--   --   print("Server listening on port " .. port)
--   --   return
--   --end
--   connection:on("receive",function(connection,payload)
--   print(payload) -- for debugging only
--   --generates HTML web site
--   connection:send(httpHeader200 .. html)
--
--   pushTheButton(pinGarage)
--   connection:on("sent",function(connection) connection:close() end)
--   end)
--end)


