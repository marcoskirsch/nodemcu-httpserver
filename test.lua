-- figuring out how to parse http header
require "webServer"
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

parsedRequest = webServer.private.parseRequest(requestForGet)

--printTable(parsedRequest, 3)
--printTable(nodemcu-http-server, 3)
--parsedRequest = webServer.parseRequest(requestForGet)

