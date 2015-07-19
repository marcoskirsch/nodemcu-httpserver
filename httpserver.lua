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
            collectgarbage()
            local fileServeFunction = nil
            if #(uri.file) > 32 then
               -- nodemcu-firmware cannot handle long filenames.
               uri.args = {code = 400, errorString = "Bad Request"}
               fileServeFunction = dofile("httpserver-error.lc")
            else
               local fileExists = file.open(uri.file, "r")
               file.close()
               if not fileExists then
                  uri.args = {code = 404, errorString = "Not Found"}
                  fileServeFunction = dofile("httpserver-error.lc")
               elseif uri.isScript then
                  fileServeFunction = dofile(uri.file)
               else
                  uri.args = {file = uri.file, ext = uri.ext}
                  fileServeFunction = dofile("httpserver-static.lc")
               end
            end
            connectionThread = coroutine.create(fileServeFunction)
            coroutine.resume(connectionThread, connection, uri.args)
         end

         local function onReceive(connection, payload)
            collectgarbage()
            local conf = dofile("httpserver-conf.lc")
            local auth
            local user = "Anonymous"

            -- parse payload and decide what to serve.
            local req = dofile("httpserver-request.lc")(payload)
            print("Requested URI: " .. req.request)
            if conf.auth.enabled then
               auth = dofile("httpserver-basicauth.lc")
               user = auth.authenticate(payload) -- authenticate returns nil on failed auth
            end
            if user and req.methodIsValid and req.method == "GET" then
               onGet(connection, req.uri)
            else
               local args = {}
               local fileServeFunction = dofile("httpserver-error.lc")
               if not user then
                  args = {code = 401, errorString = "Not Authorized", headers = {auth.authErrorHeader()}}
               elseif req.methodIsValid then
                  args = {code = 501, errorString = "Not Implemented"}
               else
                  args = {code = 400, errorString = "Bad Request"}
               end
               connectionThread = coroutine.create(fileServeFunction)
               coroutine.resume(connectionThread, connection, args)
            end
         end

         local function onSent(connection, payload)
            collectgarbage()
            if connectionThread then
               local connectionThreadStatus = coroutine.status(connectionThread)
               if connectionThreadStatus == "suspended" then
                  -- Not finished sending file, resume.
                  coroutine.resume(connectionThread)
               elseif connectionThreadStatus == "dead" then
                  -- We're done sending file.
                  connection:close()
                  connectionThread = nil
               end
            end
         end

         connection:on("receive", onReceive)
         connection:on("sent", onSent)

      end
   )
   -- false and nil evaluate as false
   local ip = wifi.sta.getip()
   if not ip then ip = wifi.ap.getip() end
   print("nodemcu-httpserver running at http://" .. ip .. ":" ..  port)
   return s

end
