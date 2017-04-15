-- httpserver
-- Author: Marcos Kirsch

-- Starts web server in the specified port.
return function (port)

   local s = net.createServer(net.TCP, 10) -- 10 seconds client timeout
   s:listen(
      port,
      function (connection)

         -- This variable holds the thread (actually a Lua coroutine) used for sending data back to the user.
         -- We do it in a separate thread because we need to send in little chunks and wait for the onSent event
         -- before we can send more, or we risk overflowing the mcu's buffer.
         local connectionThread

         local allowStatic = {GET=true, HEAD=true, POST=false, PUT=false, DELETE=false, TRACE=false, OPTIONS=false, CONNECT=false, PATCH=false}

         -- Pretty log function.
         local function log(connection, msg, optionalMsg)
            local port, ip = connection:getpeer()
            if(optionalMsg == nil) then
               print(ip .. ":" .. port, msg)
            else
               print(ip .. ":" .. port, msg, optionalMsg)
            end
         end

         local function startServing(fileServeFunction, connection, req, args)
            connectionThread = coroutine.create(function(fileServeFunction, bufferedConnection, req, args)
               fileServeFunction(bufferedConnection, req, args)
               -- The bufferedConnection may still hold some data that hasn't been sent. Flush it before closing.
               if not bufferedConnection:flush() then
                  connection:close()
                  connectionThread = nil
               end
            end)

            local BufferedConnectionClass = dofile("httpserver-connection.lc")
            local bufferedConnection = BufferedConnectionClass:new(connection)
            local status, err = coroutine.resume(connectionThread, fileServeFunction, bufferedConnection, req, args)
            if not status then log(connection, "Error: "..err) end
         end

         local function handleRequest(connection, req, handleError)
            collectgarbage()
            local method = req.method
            local uri = req.uri
            local fileServeFunction = nil

            if not allowStatic[method] and not uri.isScript then
               return handleError(connection, req, 405, "Allow: GET, HEAD")
            end
            
            if #(uri.file) > 32 then
               -- nodemcu-firmware cannot handle long filenames.
               return handleError(connection, req, 404)
            else
               local fileExists = file.open(uri.file, "r")
               file.close()

               if not fileExists then
                  -- gzip check
                  fileExists = file.open(uri.file .. ".gz", "r")
                  file.close()

                  if fileExists then
                     --print("gzip variant exists, serving that one")
                     uri.file = uri.file .. ".gz"
                     uri.isGzipped = true
                  end
               end

               if not fileExists then
                  return handleError(connection, req, 404)
               elseif uri.isScript then
                  fileServeFunction = dofile(uri.file)
               else
                  uri.args = {file = uri.file, ext = uri.ext, isGzipped = uri.isGzipped}
                  fileServeFunction = dofile("httpserver-static.lc")
               end
            end
            print(req)  -- has to be left in to workaround a bug in lua
            startServing(fileServeFunction, connection, req, uri.args)
         end

         local function handleError(connection, request, code, header)
            dofile("httpserver-geterrorpage.lua")(connection, request, code, header)
            handleRequest(connection, request, handleError)
         end

         local function onReceive(connection, payload)
            collectgarbage()
            local conf = dofile("httpserver-conf.lc")
            local auth
            local user = "Anonymous"

            -- as suggest by anyn99 (https://github.com/marcoskirsch/nodemcu-httpserver/issues/36#issuecomment-167442461)
            -- Some browsers send the POST data in multiple chunks.
            -- Collect data packets until the size of HTTP body meets the Content-Length stated in header
            if payload:find("Content%-Length:") or bBodyMissing then
               if fullPayload then fullPayload = fullPayload .. payload else fullPayload = payload end
               if (tonumber(string.match(fullPayload, "%d+", fullPayload:find("Content%-Length:")+16)) > #fullPayload:sub(fullPayload:find("\r\n\r\n", 1, true)+4, #fullPayload)) then
                  bBodyMissing = true
                  return
               else
                  --print("HTTP packet assembled! size: "..#fullPayload)
                  payload = fullPayload
                  fullPayload, bBodyMissing = nil
               end
            end
            collectgarbage()

            -- parse payload and decide what to serve.
            local req = dofile("httpserver-request.lc")(payload)
            if not req then
               -- create minimal req to allow geterrorpage to do its work
               req = {uri = {}}
               log(connection, "Empty request")
               return handleError(connection, req, 400)
            end
            log(connection, req.method, req.request)
            if conf.auth.enabled then
               auth = dofile("httpserver-basicauth.lc")
               user = auth.authenticate(payload) -- authenticate returns nil on failed auth
            end

            if user and req.methodIsValid and (req.method == "GET" or req.method == "POST" or req.method == "PUT") then
               handleRequest(connection, req, handleError)
            else
               if not user then  -- Not Authorized
                  return handleError(connection, req, 401, auth.authErrorHeader())
               elseif req.methodIsValid then  -- Not Implemented
                  return handleError(connection, req, 501)
               else  -- Bad Request
                  return handleError(connection, req, 400)
               end
            end
         end

         local function onSent(connection, payload)
            collectgarbage()
            if connectionThread then
               local connectionThreadStatus = coroutine.status(connectionThread)
               if connectionThreadStatus == "suspended" then
                  -- Not finished sending file, resume.
                  local status, err = coroutine.resume(connectionThread)
                  if not status then log(connection:getpeer(), "Error: " .. err) end
               elseif connectionThreadStatus == "dead" then
                  -- We're done sending file.
                  connection:close()
                  connectionThread = nil
               end
            end
         end

         local function onDisconnect(connection, payload)
            if connectionThread then
               connectionThread = nil
               collectgarbage()
            end
         end

         connection:on("receive", onReceive)
         connection:on("sent", onSent)
         connection:on("disconnection", onDisconnect)

      end
   )
   return s

end
