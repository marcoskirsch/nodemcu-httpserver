-- figuring out how to parse http header
--require "webServer"
printTable = dofile( "TablePrinter.lua")
--require "b64"

--[[
sep = "\r\n"
requestForGet =
   "GET /folder/index.html?query=5&b=6 HTTP/1.1" .. sep ..
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
--]]

local function validateMethod(method)
   -- HTTP Request Methods.
   -- HTTP servers are required to implement at least the GET and HEAD methods
   -- http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
   local httpMethods = {GET=true, HEAD=true, POST=true, PUT=true, DELETE=true, TRACE=true, OPTIONS=true, CONNECT=true, PATCH=true}
   if httpMethods[method] then return method else return nil end
end

print(validateMethod("GET"))
print(validateMethod("POST"))
print(validateMethod("FOO"))


--[[
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
--]]

--[[
function parseRequest(request)
   local e = request:find("\r\n", 1, true)
   if not e then return nil end
   local line = request:sub(1, e - 1)
   local r = {}
   _, i, r.method, r.url, r.x, r.y = line:find("^([A-Z]+) (.-) HTTP/[1-9]+.[1-9]+$")
   return r
end

--]]

local function parseArgs(args)
   r = {}; i=1
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
   return r
end



--uri = "/folder/index.html?query=5&b=6"
--uri = "/folder/index.html"
--uri = "/folder/index.lua?f=2&r=2"
uri = "/folder/index.lua?f="
r = parseUri(uri)

print("uri", uri)
print("r.file", r.file)
print("r.args", r.args)
print("r.ext", r.ext)
print("r.isScript", r.isScript)
for k,v in pairs(r.args) do print("name: "..k.."    val:"..v) end


--[[
local function parseArgs(args)
   local r = {}
   while args ~= nil do
      local arg = nil
      a, b = args:find("&")
      if a == nil then
         arg = args
         args = nil
      else
         arg = args:sub(1, b-1)
         args = args:sub(#arg + 2)
      end
      local splitArg = {}
      splitArg.attr, splitArg.val = arg:match("(.+)=(.+)")
      table.insert(r, splitArg)
   end
   return r
end

r = parseArgs("arg1=44&arg2=55&arg3=66")
printTable(r)
--]]

--[[
name = "http/button.css"
local isHttpFile, url = string.match(name, "(http)/(%g+)")
print ("Moshe was here")
print (isHttpFile, url)
]]--

--[[
   local l = file.list()
   for name, size in pairs(l) do
      local isHttpFile = string.match(name, "(http)") ~= nil
      local url = string.match(name, ".*/(.*)")
      print("name", name)
      print("isHttpFile", isHttpFile)
      print("url", url)
--      if isHttpFile and url then
--         connection:send('   <li><a href="' .. url .. '">' .. url .. "</a> (" .. size .. " bytes)</li>\n")
--      end
   end
--]]



--print(result.method)
--print(result.url)
--print(result.version)

--printTable(parsedRequest, 3)
--printTable(nodemcu-http-server, 3)

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

--[[
r = parseRequest(requestForGet)
print(r.method)
print(r.url)
print(r.x)
print(r.y)
--]]

--[[
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
]]--
