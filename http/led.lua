local function sendResponse(connection, httpCode, status)
   connection:send("HTTP/1.0 "..httpCode.." OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('{"on":'..tostring(status)..'}')
end

return function (connection, req, args)
   ONBOARD_LED = 0

   if _G.led_value == nil then
      _G.led_value = gpio.HIGH
      gpio.mode(ONBOARD_LED, gpio.OUTPUT)
      gpio.write(ONBOARD_LED, _G.led_value)
   end

   if req.method == "GET" then
      sendResponse(connection, 200, _G.led_value == gpio.HIGH and "false" or "true")
      return
   end

   if req.method == "POST" then
      if args.on ~= nil then
         _G.led_value = args.on == "true" and gpio.LOW or gpio.HIGH
         gpio.write(ONBOARD_LED, _G.led_value)
         sendResponse(connection, 200, _G.led_value == gpio.HIGH and "false" or "true")
         return
      end
   end

   sendResponse(connection, 400, _G.led_value == gpio.HIGH and "false" or "true")

end
