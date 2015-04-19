-- httpserver
-- Author: Marcos Kirsch

-- Starts web server in the specified port.
return function (port)

   local s = net.createServer(net.TCP, 10) -- 10 seconds client timeout
   s:listen(
      port,
      function (connection)

         -- This variable holds the thread used for sending data back to the user.
         -- We do it in a separate thread because we need to yield when sending lots
         -- of data in order to avoid overflowing the mcu's buffer.
         local connectionThread

         local function onGet(connection, uri)
            local fileServeFunction = nil
            if #(uri.file) > 32 then
               -- nodemcu-firmware cannot handle long filenames.
               uri.args['code'] = 400
               fileServeFunction = dofile("httpserver-error.lc")
            else
               local fileExists = file.open(uri.file, "r")
               file.close()
               collectgarbage()
               if not fileExists then
                  uri.args['code'] = 404
                  fileServeFunction = dofile("httpserver-error.lc")
               elseif uri.isScript then
                  fileServeFunction = dofile(uri.file)
               else
                  uri.args['file'] = uri.file
                  uri.args['ext'] = uri.ext
                  fileServeFunction = dofile("httpserver-static.lc")
               end
            end
            connectionThread = coroutine.create(fileServeFunction)
            --print("Thread created", connectionThread)
            coroutine.resume(connectionThread, connection, uri.args)
         end

         local function onReceive(connection, payload)
            -- print(payload) -- for debugging
            -- parse payload and decide what to serve.
            local req = dofile("httpserver-request.lc")(payload)
            print("Requested URI: " .. req.request)
            if req.methodIsValid and req.method == "GET" then
               onGet(connection, req.uri)
            else
               local args = {}
               if req.methodIsValid then args['code'] = 501 else args['code'] = 400 end
               dofile("httpserver-error.lc")(connection, args)
            end
         end

         local function onSent(connection, payload)
            local connectionThreadStatus = coroutine.status(connectionThread)
            -- print (connectionThread, "status is", connectionThreadStatus)
            if connectionThreadStatus == "suspended" then
               -- Not finished sending file, resume.
               -- print("Resume thread", connectionThread)
               coroutine.resume(connectionThread)
            elseif connectionThreadStatus == "dead" then
               -- We're done sending file.
               -- print("Done thread", connectionThread)
               connection:close()
               connectionThread = nil
            end
         end

         connection:on("receive", onReceive)
         connection:on("sent", onSent)

      end
   )
   local ip = nil
   if wifi.sta.getip() then ip = wifi.sta.getip() else ip = wifi.ap.getip() end
   print("nodemcu-httpserver running at http://" .. ip .. ":" ..  port)
   return s

end
