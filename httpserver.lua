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

local function parseRequest(request)
   local result = {}
   local matchEnd = 0

   local matchBegin = matchEnd + 1
   matchEnd = string.find (request, " ", matchBegin)
   result.method = string.sub(request, matchBegin, matchEnd-1)

   matchBegin = matchEnd + 1
   matchEnd = string.find(request, " ", matchBegin)
   result.uri = string.sub(request, matchBegin, matchEnd-1)

   matchBegin = matchEnd + 1
   matchEnd = string.find(request, "\r\n", matchBegin)
   result.version = string.sub(request, matchBegin, matchEnd-1)

   return result
end

local function uriToFilename(uri)
   if uri == "/" then return "http/index.html" end
   return "http/" .. string.sub(uri, 2, -1)
end

local function on404NotFound(connection)
   print("onNotFound: The requested file was not found.")
   connection:send("HTTP/1.1 404 Not Found\r\nContent-Type: text/html\r\nContent-Length: " .. string.len(html) .. "\r\nConnection: close\r\n\r\n")
   connection:send("<html><head><title>404 - Not Found</title></head><body><h1>404 - Not Found</h1></body></html>\r\n")
   connection:close()
end

local function onGet(connection, uri)
   print("onGet: requested uri is: " .. uri)
   local fileExists = file.open(uriToFilename(uri), "r")
   if not fileExists then
      on404NotFound(connection)
   else
      connection:send("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\Cache-Control: private, no-store\r\n\r\n")
      connection:send(file.read())
      connection:close()
      file.close()
   end
end

local function onReceive(connection, payload)
   print ("onReceive: We have a customer!")
   print(payload) -- for debugging

   -- parse payload and decide what to serve.
   parsedRequest = parseRequest(payload)

   method = validateMethod(parsedRequest.method)

   if method == nil then
      onBadRequest(connection)
      return
   end

   if method == "GET" then
      onGet(connection, parsedRequest.uri)
      return
   end

   onNotImplemented(connection)

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
   return server
end

-- Stops the server.
function httpserver.stop(server)
   server:close()
end


