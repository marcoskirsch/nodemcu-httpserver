-- httpserver
-- Author: Marcos Skirsch

connectionTable = {}

-- Starts web server in the specified port.
return function (port)

   local s = net.createServer(net.TCP, 10) -- 10 seconds client timeout
   s:listen(
      port,
      function (connection)

         local function onGet(connection, uri)
            collectgarbage()
            if #(uri.file) > 32 then
               -- nodemcu-firmware cannot handle long filenames.
               uri.args = {code = 400, errorString = "Bad Request"}
               dofile("httpserver-error.lc")(connection, uri.args)
			   connection:close()
            else
               local fileExists = file.open(uri.file, "r")
               file.close()
               if not fileExists then
                  uri.args = {code = 404, errorString = "Not Found"}
                  dofile("httpserver-error.lc")(connection, uri.args)
			      connection:close()
               elseif uri.isScript then
                  dofile(uri.file)(connection, uri.args)
			      connection:close()
               else
                  uri.args = {file = uri.file, ext = uri.ext}
                  connectionTable[connection] = {bytesSent = 0, args = uri.args}
                  -- print("create: ", connection) -- for debugging
                  if dofile("httpserver-static.lc")(connection, uri.args, 1) == 0 then
                     connectionTable[connection] = nil
                     connection:close()
                  end
               end
            end
         end

         local function onReceive(connection, payload)
            collectgarbage()
            -- print(payload) -- for debugging
            -- parse payload and decide what to serve.
            local req = dofile("httpserver-request.lc")(payload)
            print("Requested URI: " .. req.request)
            if req.methodIsValid and req.method == "GET" then
               onGet(connection, req.uri)
            else
               local args = {}
               if req.methodIsValid then
                  args = {code = 501, errorString = "Not Implemented"}
               else
                  args = {code = 400, errorString = "Bad Request"}
               end
               dofile("httpserver-error.lc")(connection, args)
			   connection:close()
            end
         end

         local function onSent(connection, payload)
            collectgarbage()
			local args = connectionTable[connection].args
            -- print("sent: ", connection) -- for debugging
            if dofile("httpserver-static.lc")(connection, args, 0) == 0 then
               connectionTable[connection] = nil
               connection:close()
            end
         end

         local function onDisconnection(connection, payload)
            connectionTable[connection] = nil
         end

         connection:on("receive", onReceive)
         connection:on("sent", onSent)
         connection:on("disconnection", onDisconnection)

      end
   )
   -- false and nil evaluate as false
   local ip = wifi.sta.getip() 
   if not ip then ip = wifi.ap.getip() end
   print("nodemcu-httpserver running at http://" .. ip .. ":" ..  port)
   return s

end
