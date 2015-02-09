-- figuring out how to parse http header
--require "webServer"
--require "printTable"
--require "b64"

sep = "\r\n"
requestForGet =
   "GET /index.html HTTP/1.1" .. sep ..
   "Host: 10.0.7.15" .. sep ..
   "Accept-Encoding: gzip, deflate" .. sep ..
   "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" .. sep ..
   "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/600.3.18 (KHTML, like Gecko) Version/8.0.3 Safari/600.3.18" .. sep ..
   "Accept-Language: en-us" .. sep ..
   "Cache-Control: max-age=0" .. sep ..
   "Connection: keep-alive" .. sep ..
   ""
--print(enc(requestForGet))
--print(dec(enc(requestForGet)))

--parsedRequest = webServer.private.parseRequest(requestForGet)

function parseRequest(request)
   local result = {}
   local matchEnd = 0

   local matchBegin = matchEnd + 1
   matchEnd = string.find (requestForGet, " ", matchBegin)
   result.method = string.sub(requestForGet, matchBegin, matchEnd-1)

   matchBegin = matchEnd + 1
   matchEnd = string.find(requestForGet, " ", matchBegin)
   result.url = string.sub(requestForGet, matchBegin, matchEnd-1)

   matchBegin = matchEnd + 1
   matchEnd = string.find(requestForGet, "\r\n", matchBegin)
   result.version = string.sub(requestForGet, matchBegin, matchEnd-1)

   return result
end


--print(result.method)
--print(result.url)
--print(result.version)

--printTable(parsedRequest, 3)
--printTable(nodemcu-http-server, 3)
--parsedRequest = webServer.parseRequest(requestForGet)

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

--print(validateMethod("GET"))
--print(validateMethod("POST"))
--print(validateMethod("garbage"))

local function uriToFilename(uri)
   if uri == "/" then return "http/index.html" end
   return "http/" .. string.sub(uri, 2, -1)
end

print(uriToFilename("/index.html"))
print(uriToFilename("/"))

a = nil
if not a then print("hello") end
