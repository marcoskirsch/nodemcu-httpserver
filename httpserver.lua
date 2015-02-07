-- httpserver
-- Author: Marcos Kirsch

module("httpserver", package.seeall)

require("TablePrinter")

-- Functions below aren't part of the public API
-- Clients don't need to worry about them.

-- given an HTTP request, returns the method (i.e. GET)
local function getRequestMethod(request)
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

---- given an HTTP request, returns a table with all the information.
--local function parseRequest(request)
--   parsedRequest = {}
--
--   -- First get the method
--   parsedRequest["method"] = getRequestMethod(request)
--   if parsedRequest["method"] == nil then
--      return nil
--   end
--   -- Now get each value out of the header, skip the first line
--   lineNumber = 0
--   for line in request:gmatch("[^\r\n]+") do
--      if lineNumber ~=0 then
--         -- tag / value are of the style "Host: 10.0.7.15". Break them up.
--         found, valueIndex = string.find(line, ": ")
--         if found == nil then
--            break
--         end
--         tag = string.sub(line, 1, found - 1)
--         value = string.sub(line, found + 2, #line)
--         parsedRequest[tag] = value
--      end
--      lineNumber = lineNumber + 1
--   end
--   return parsedRequest
--end

function parseRequest(request)
   local result = {}
   local matchEnd = 0

   local matchBegin = matchEnd + 1
   matchEnd = string.find (request, " ", matchBegin)
   result.method = string.sub(request, matchBegin, matchEnd-1)

   matchBegin = matchEnd + 1
   matchEnd = string.find(request, " ", matchBegin)
   result.url = string.sub(request, matchBegin, matchEnd-1)

   matchBegin = matchEnd + 1
   matchEnd = string.find(request, "\r\n", matchBegin)
   result.version = string.sub(request, matchBegin, matchEnd-1)

   return result
end

local function onReceive(connection, payload)
   print(payload) -- for debugging

   -- parse payload and decide what to serve.
   parsedRequest = parseRequest(payload)
   --TablePrinter.print(parsedRequest, 3)

   --generates HTML web site
   httpHeader200 = "HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n"
   html = "<h1>Hola mundo</h1>"
   connection:send(httpHeader200 .. html)
end

local function handleRequest(connection)
   connection:on("receive", onReceive)
   connection:on("sent", function(connection) connection:close() end)
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

return mymodule


