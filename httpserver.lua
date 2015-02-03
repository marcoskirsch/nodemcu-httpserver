-- httpserver
-- Author: Marcos Kirsch
-- This is a very simple HTTP server designed to work on nodemcu (http://nodemcu.com)
-- It can handle GET and POST.
require "printTable"


httpserver = {}


-- Starts web server in the specified port.
--function httpserver.start(port, clientTimeoutInSeconds, debug)
--   -- Server constants
--   server = net.createServer(net.TCP, clientTimeoutInSeconds) server:listen(port, private.handleRequest)
--end


httpserver.private = {} -- not part of the public API

function httpserver.private.onReceive(connection, payload)
   print(payload) -- for debugging

   -- parse payload and decide what to serve.
   parsedRequest = private.parseRequest(payload)
   httpserver.private.printTable(parsedRequest, 3)

   --generates HTML web site
   httpHeader200 = "HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n"
   html = "<h1>Hola mundo</h1>"
   connection:send(httpHeader200 .. html)
end

function httpserver.private.handleRequest(connection)
   connection:on("receive", onReceive)
   connection:on("sent",function(connection) connection:close() end)
end

-- given an HTTP request, returns the method (i.e. GET)
function httpserver.private.getRequestMethod(request)
   -- HTTP Request Methods.
   -- HTTP servers are required to implement at least the GET and HEAD methods
   -- http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
   httpMethods = {"GET", "HEAD", "POST", "PUT", "DELETE", "TRACE", "OPTIONS", "CONNECT", "PATCH"}
   method = nil
   for i=1,#httpMethods do
      found = string.find(request, httpMethods[i])
      if found == 1 then
         break
      end
   end
   return (httpMethods[found])
end

-- given an HTTP request, returns a table with all the information.
function httpserver.private.parseRequest(request)
   parsedRequest = {}
   -- First get the method

   parsedRequest["method"] = httpserver.private.getRequestMethod(request)
   if parsedRequest["method"] == nil then
      return nil
   end
   -- Now get each value out of the header, skip the first line
   lineNumber = 0
   for line in request:gmatch("[^\r\n]+") do
      if lineNumber ~=0 then
         -- tag / value are of the style "Host: 10.0.7.15". Break them up.
         found, valueIndex = string.find(line, ": ")
         if found == nil then
            break
         end
         tag = string.sub(line, 1, found - 1)
         value = string.sub(line, found + 2, #line)
         parsedRequest[tag] = value
      end
      lineNumber = lineNumber + 1
   end
   return parsedRequest
end
