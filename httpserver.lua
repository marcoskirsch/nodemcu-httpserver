-- httpserver
-- Author: Marcos Kirsch

module("httpserver", package.seeall)

-- Functions below aren't part of the public API
-- Clients don't need to worry about them.

-- given an HTTP method, returns it or if invalid returns nil
local function validateMethod(method)
   -- HTTP Request Methods.
   -- HTTP servers are required to implement at least the GET and HEAD methods
   -- http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
   local httpMethods = {"GET", "HEAD", "POST", "PUT", "DELETE", "TRACE", "OPTIONS", "CONNECT", "PATCH"}
   for i=1,#httpMethods do
      if httpMethods[i] == method then
         return method
      end
   end
   return nil
end

function parseRequest(request)
   local e = request:find("\r\n", 1, true)
   if not e then return nil end
   local line = request:sub(1, e - 1)
   local r = {}
   _, i, r.method, r.uri = line:find("^([A-Z]+) (.-) HTTP/[1-9]+.[1-9]+$")
   return r
end

local function uriToFilename(uri)
   if uri == "/" then return "http/index.html" end
   return "http/" .. string.sub(uri, 2, -1)
end

local function onError(connection, errorCode, errorString)
   print(errorCode .. ": " .. errorString)
   connection:send("HTTP/1.0 " .. errorCode .. " " .. errorString .. "\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n")
   connection:send("<html><head><title>" .. errorCode .. " - " .. errorString .. "</title></head><body><h1>" .. errorCode .. " - " .. errorString .. "</h1></body></html>\r\n")
   connection:close()
end

local function parseUri(uri)
   if uri == "/" then uri = "/index.html" end
   print ("uri is " .. uri)
   questionMarkPos, b, c, d, e, f = uri:find("?")
   r = {}
   if questionMarkPos == nil then
      r.file = uri:sub(1, questionMarkPos)
   else
      r.file = uri:sub(1, questionMarkPos - 1)
      r.args = uri:sub(questionMarkPos+1, #uri)
   end
   _, r.ext = r.file:match("(.+)%.(.+)")
   return r
end

local function getMimeType(ext)
   -- A few MIME types. No need to go crazy in this list. If you need something that is missing, let's add it.
   local mimeTypes = {}
   mimeTypes.css = "text/css"
   mimeTypes.gif = "image/gif"
   mimeTypes.htm = "text/html"
   mimeTypes.html = "text/html"
   mimeTypes.ico = "image/x-icon"
   mimeTypes.jpe = "image/jpeg"
   mimeTypes.jpeg = "image/jpeg"
   mimeTypes.jpg = "image/jpeg"
   mimeTypes.js = "application/javascript"
   mimeTypes.png = "image/png"
   mimeTypes.txt = "text/plain"
   if mimeTypes[ext] then return mimeTypes[ext] end
   -- default to text.
   return "text/plain"
end

local function onGet(connection, uri)
   print("onGet: requested uri is: " .. uri)
   local fileExists = file.open(uriToFilename(uri), "r")
   if not fileExists then
      onError(connection, 404, "Not Found")
   else
      uri = parseUri(uri)
      -- Use HTTP/1.0 to ensure client closes connection.
      connection:send("HTTP/1.0 200 OK\r\nContent-Type: " .. getMimeType(uri.ext) .. "\r\Cache-Control: private, no-store\r\n\r\n")
      -- Send file in little 128-byte chunks
      while true do
         local chunk = file.read(128)
         if chunk == nil then break end
         connection:send(chunk)
      end
      connection:close()
      file.close()
   end
end

local function onReceive(connection, payload)
   print ("onReceive: We have a customer!")
   --print(payload) -- for debugging
   -- parse payload and decide what to serve.
   parsedRequest = parseRequest(payload)
   parsedRequest.method = validateMethod(parsedRequest.method)
   if parsedRequest.method == nil then onError(connection, 400, "Bad Request")
   elseif parsedRequest.method == "GET" then onGet(connection, parsedRequest.uri)
   else onNotImplemented(connection, 501, "Not Implemented") end
end

local function onSent(connection)
   print ("onSent: Thank you, come again.")
end


local function handleRequest(connection)
   connection:on("receive", onReceive)
   connection:on("sent", onSent)
end

-- Starts web server in the specified port.
function httpserver.start(port, clientTimeoutInSeconds)
   server = net.createServer(net.TCP, clientTimeoutInSeconds)
   server:listen(port, handleRequest)
   print("nodemcu-httpserver running at " .. wifi.sta.getip() .. ":" ..  port)
   return server
end

-- Stops the server.
function httpserver.stop(server)
   server:close()
end


