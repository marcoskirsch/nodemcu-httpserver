-- httpserver-request
-- Part of nodemcu-httpserver, parses incoming client requests.
-- Author: Marcos Kirsch

local function validateMethod(method)
   local httpMethods = {GET=true, HEAD=true, POST=true, PUT=true, DELETE=true, TRACE=true, OPTIONS=true, CONNECT=true, PATCH=true}
   -- default for non-existent attributes returns nil, which evaluates to false
   return httpMethods[method]
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
   local filename
   local ext
   local fullExt = {}

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
   filename = r.file
   while filename:match("%.") do
      filename,ext = filename:match("(.+)%.(.+)")
      table.insert(fullExt,1,ext)
   end
   r.ext = table.concat(fullExt,".")
   r.isScript = r.ext == "lua" or r.ext == "lc"
   r.file = uriToFilename(r.file)
   return r
end

-- Parses the client's request. Returns a dictionary containing pretty much everything
-- the server needs to know about the uri.
return function (request)
   local e = request:find("\r\n", 1, true)
   if not e then return nil end
   local line = request:sub(1, e - 1)
   local r = {}
   _, i, r.method, r.request = line:find("^([A-Z]+) (.-) HTTP/[1-9]+.[0-9]+$")
   r.methodIsValid = validateMethod(r.method)
   r.uri = parseUri(r.request)
   return r
end
