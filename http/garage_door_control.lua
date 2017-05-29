-- garage_door_open.lua
-- Part of nodemcu-httpserver, example.
-- Author: Marcos Kirsch

local function pushTheButton(connection, pinConfig)
   -- push the button!
   -- The hardware in this case is a Wemos D1 Pro with two relay shields.
   -- The first relay is controlled with D1.
   -- The second one was modified to be controlled with D2.
   gpio.write(pinConfig["controlPin"], gpio.HIGH)
   gpio.mode(pinConfig["controlPin"], gpio.OUTPUT, gpio.FLOAT)
   tmr.delay(300000) -- in microseconds
   gpio.mode(pinConfig["controlPin"], gpio.INPUT, gpio.FLOAT)
   gpio.write(pinConfig["controlPin"], gpio.LOW)
end


local function readDoorStatus(pinConfig)
   -- When the garage door is closed, the reed relay closes, grounding the pin and causing us to read low (0).
   -- When the garage door is open, the reed relay is open, so due to pullup we read high (1).
   gpio.write(pinConfig["statusPin"], gpio.HIGH)
   gpio.mode(pinConfig["statusPin"], gpio.INPUT, gpio.PULLUP)
   if gpio.read(pinConfig["statusPin"]) == 1 then return 'open' else return 'closed' end
end


local function sendResponse(connection, httpCode, errorCode, action, pinConfig, message)

   -- Handle nil inputs
   if action == nil then action = '' end
   if pinConfig == nil then
      pinConfig = {}
      pinConfig["door"] = 0
      pinConfig["controlPin"] = 0
      pinConfig["statusPin"] = 0
   end
   if message == nil then message = '' end

   connection:send("HTTP/1.0 "..httpCode.." OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('{"error":'..errorCode..', "door":'..pinConfig["door"]..', "controlPin":'..pinConfig["controlPin"]..', "statusPin":'..pinConfig["statusPin"]..', "action":"'..action..'", "message":"'..message..'"}')
end


local function sendStatus(connection, pinConfig)
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('{"error":0, "door":'..pinConfig["door"]..', "controlPin":'..pinConfig["controlPin"]..', "statusPin":'..pinConfig["statusPin"]..', "action":"status"'..', "status":"'..readDoorStatus(pinConfig)..'"}')
end


local function openDoor(connection, pinConfig)
   local doorStatus = readDoorStatus(pinConfig)
   if doorStatus == 'open' then
      return false
   else
      pushTheButton(connection, pinConfig)
      return true
   end
end


local function closeDoor(connection, pinConfig)
   local doorStatus = readDoorStatus(pinConfig)
   if doorStatus == 'closed' then
      return false
   else
      pushTheButton(connection, pinConfig)
      return true
   end
end


return function (connection, req, args)

   -- The values for the configuration depend on how your Wemo D1 mini Pro is wired.
   -- In this example, there are two doors.
   -- Each door uses a pin to control a relay that mimics the push button on the garage door
   -- and another pin connected to a reed relay (the other wire of the relay goes to GND) to
   -- detect if the door is open or closed.
   pinConfig = {}
   pinConfig["1"] = {}
   pinConfig["1"]["door"] = 1
   pinConfig["1"]["controlPin"] = 1
   pinConfig["1"]["statusPin"] = 5
   pinConfig["2"] = {}
   pinConfig["2"]["door"] = 2
   pinConfig["2"]["controlPin"] = 2
   pinConfig["2"]["statusPin"] = 6

   if args.door == nil then
      sendResponse(connection, 400, -1, args.action, pinConfig[args.door], "No door specified")
      return
   end

   if pinConfig[args.door] == nil then
      sendResponse(connection, 400, -2, args.action, pinConfig[args.door], "Bad door specified")
      return
   end

   if args.action == "open" then
      if(openDoor(connection, pinConfig[args.door])) then
         sendResponse(connection, 200, 0, args.action, pinConfig[args.door], "Door opened")
      else
         sendResponse(connection, 400, -3, args.action, pinConfig[args.door], "Door was already open")
      end
      return
   end

   if args.action == "close" then
      if(closeDoor(connection, pinConfig[args.door])) then
         sendResponse(connection, 200, 0, args.action, pinConfig[args.door], "Door closed")
      else
         sendResponse(connection, 400, -4, args.action, pinConfig[args.door], "Door was already closed")
      end
      return
   end

   if args.action == "status" then
      sendStatus(connection, pinConfig[args.door])
      return
   end

   sendResponse(connection, 400, -5, args.action, pinConfig[args.door], "Bad action")

end
