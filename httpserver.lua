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

local function onError(connection, errorCode, errorString)
   print(errorCode .. ": " .. errorString)
   connection:send("HTTP/1.0 " .. errorCode .. " " .. errorString .. "\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n")
   connection:send("<html><head><title>" .. errorCode .. " - " .. errorString .. "</title></head><body><h1>" .. errorCode .. " - " .. errorString .. "</h1></body></html>\r\n")
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

local function getMimeType(ext)
   -- A few MIME types. No need to go crazy in this list. If you need something that is missing, let's add it.
   local mt = {}
   mt.css = "text/css"
   mt.gif = "image/gif"
   mt.html = "text/html"
   mt.ico = "image/x-icon"
   mt.jpeg = "image/jpeg"
   mt.jpg = "image/jpeg"
   mt.js = "application/javascript"
   mt.png = "image/png"
   if mt[ext] then return mt[ext] end
   -- default to text.
   return "text/plain"
end

local function onGet(connection, uri)
   local uri = parseUri(uri)
   local fileExists = file.open(uri.file, "r")
   if not fileExists then
      onError(connection, 404, "Not Found")
   else
      if uri.isScript then
         file.close()
         collectgarbage()
         dofile(uri.file)(connection, uri.args)
      else
         -- Use HTTP/1.0 to ensure client closes connection.
         connection:send("HTTP/1.0 200 OK\r\nContent-Type: " .. getMimeType(uri.ext) .. "\r\Cache-Control: private, no-store\r\n\r\n")
         -- Send file in little 128-byte chunks
         while true do
            local chunk = file.read(128)
            if chunk == nil then break end
            connection:send(chunk)
         end
         file.close()
      end
   end
   collectgarbage()
end

local function onReceive(connection, payload)
   --print(payload) -- for debugging
   -- parse payload and decide what to serve.
   local req = parseRequest(payload)
   print("Requested URI: " .. req.uri)
   req.method = validateMethod(req.method)
   if req.method == nil then onError(connection, 400, "Bad Request")
   elseif req.method == "GET" then onGet(connection, req.uri)
   else onError(connection, 501, "Not Implemented") end
   connection:close()
end

local function handleRequest(connection)
   connection:on("receive", onReceive)
end

-- Starts web server in the specified port.
function httpserver.start(port, clientTimeoutInSeconds)
   s = net.createServer(net.TCP, clientTimeoutInSeconds)
   s:listen(port, handleRequest)
   print("nodemcu-httpserver running at " .. wifi.sta.getip() .. ":" ..  port)
   return s
end


