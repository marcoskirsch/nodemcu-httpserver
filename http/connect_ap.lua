-- Author: moononournation
-- Notes by Marcos: This example could be improved quite a bit.
-- We should provide a way to return available access points as JSON, then populated
-- a drop down list using JavaScript every 5-10 seconds. I'm not sure it's worth it,
-- however.

return function (connection, req, args)
    dofile('httpserver-header.lc')(connection, 200, 'html')

   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Connect AP</title></head><body><h1>Connect AP</h1>')

   if req.method == 'GET' then
      local ip = wifi.sta.getip()
      if not (ip == nil) then
         connection:send('<p>IP: ' .. ip .. '</p>')
      end
      connection:send('<form method="POST">SSID:<br><input type="text" name="ssid"><br>PWD:<br><input type="text" name="pwd"><br><input type="submit" name="submit" value="Submit"></form>')
   elseif req.method == 'POST' then
      local rd = req.getRequestData()

      collectgarbage()
      wifi.sta.config(rd['ssid'], rd['pwd'])
      wifi.sta.connect()
      local joinCounter = 0
      local joinMaxAttempts = 15
      tmr.alarm(0, 1000, 1, function()
         local ip = wifi.sta.getip()
         if ip == nil and joinCounter < joinMaxAttempts then
            joinCounter = joinCounter + 1
         else
            if joinCounter >= joinMaxAttempts then
               connection:send('<p>Failed to connect to WiFi Access Point.</p>')
            else
               connection:send('<p>IP: ' .. ip .. '</p>')
            end
            tmr.stop(0)
            joinCounter = nil
            joinMaxAttempts = nil
            collectgarbage()
         end
      end)
   end

   connection:send('</body></html>')
end
