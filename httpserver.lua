-- httpserver
-- Author: Marcos Kirsch

module("httpserver", package.seeall)

-- Functions below aren't part of the public API
-- Clients don't need to worry about them.

-- given an HTTP method, returns it or if invalid returns nil
local function validateMethod(method)
   local httpMethods = {GET=true, HEAD=true, POST=true, PUT=true, DELETE=true, TRACE=true, OPTIONS=true, CONNECT=true, PATCH=true}
   if httpMethods[method] then return method else return nil end
end

local function parseRequest(request)
   local e = request:find("\r\n", 1, true)
   if not e then return nil end
   local line = request:sub(1, e - 1)
   local r = {}
   _, i, r.method, r.uri = line:find("^([A-Z]+) (.-) HTTP/[1-9]+.[1-9]+$")
   return r
end

local function uriToFilename(uri)
   return "http/" .. string.sub(uri, 2, -1)
end

local function parseArgs(args)
   local r = {}; i=1
   if args == nil or args == "" then return r end
   for arg in string.gmatch(args, "([^&]+)") do
      local name, value = string.match(arg, "(.*)=(.*)")
      if name ~= nil then r[name] = value end
      i = i + 1
   end
   return r
end

local function parseUri(uri)
   local r = {}
   if uri == nil then return r end
   if uri == "/" then uri = "/index.html" end
   questionMarkPos, b, c, d, e, f = uri:find("?")
   if questionMarkPos == nil then
      r.file = uri:sub(1, questionMarkPos)
      r.args = {}
   else
      r.file = uri:sub(1, questionMarkPos - 1)
      r.args = parseArgs(uri:sub(questionMarkPos+1, #uri))
   end
   _, r.ext = r.file:match("(.+)%.(.+)")
   r.isScript = r.ext == "lua" or r.ext == "lc"
   r.file = uriToFilename(r.file)
   return r
end

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
            local uri = parseUri(uri)
            local fileExists = file.open(uri.file, "r")
            file.close()
            local fileServeFunction = nil
            if not fileExists then
               uri.args['code'] = 404
               fileServeFunction = dofile("httpserver-error.lc")
            elseif uri.isScript then
               collectgarbage()
               fileServeFunction = dofile(uri.file)
            else
               uri.args['file'] = uri.file
               uri.args['ext'] = uri.ext
               fileServeFunction = dofile("httpserver-static.lc")
            end
            connectionThread = coroutine.create(fileServeFunction)
            --print("Thread created", connectionThread)
            coroutine.resume(connectionThread, connection, uri.args)
         end

         local function onReceive(connection, payload)
            --print(payload) -- for debugging
            -- parse payload and decide what to serve.
            local req = parseRequest(payload)
            print("Requested URI: " .. req.uri)
            req.method = validateMethod(req.method)
            if req.method == "GET" then onGet(connection, req.uri)
            elseif req.method == nil then dofile("httpserver-static.lc")(conection, {code=400})
            else dofile("httpserver-static.lc")(conection, {code=501}) end
         end

         local function onSent(connection, payload)
            local connectionThreadStatus = coroutine.status(connectionThread)
            --print (connectionThread, "status is", connectionThreadStatus)
            if connectionThreadStatus == "dead" then
               -- We're done sending file.
               --print("Done sending file", connectionThread)
               connection:close()
               connectionThread = nil
            elseif connectionThreadStatus == "suspended" then
               -- Not finished sending file, resume.
               --print("Resume thread", connectionThread)
               coroutine.resume(connectionThread)
            else
               print ("Fatal error! I did not expect to hit this codepath")
               connection:close()
            end
         end

         connection:on("receive", onReceive)
         connection:on("sent", onSent)

      end
   )
   print("nodemcu-httpserver running at http://" .. wifi.sta.getip() .. ":" ..  port)
   return s

end
