-- httpserver-geterrorpage.lc
-- Part of nodemcu-httpserver, knows how to find an error page.
-- Author: Gregor Hartmann

return function(connection, req, code, header)

   local function getErrorHandler(code, ext)
      local filename = "error"
      if (code) then
         filename = filename .. "-" .. code
      end
      if (ext) then
         filename = filename .. "-" .. ext
      end
      -- TODO extend for arbitrary file extensions
      filename = filename..".html"

      -- TODO return filename and extension as we know them both here
      if (file.exists(filename)) then
         return filename
      else
         return nil
      end
   end

   local uri = req.uri
   
   req.originalUri = req.uri
   req.uri = {}
   req.code = code
   
   --print("uri: ", uri or "nil")
   local errorhandler = getErrorHandler(code,uri.ext) 
               or getErrorHandler(code)
               or getErrorHandler(uri.ext)
               or getErrorHandler()

   req.method = "GET"
   req.methodIsValid = true
   
   if (header) then
      req.headers = req.headers or {}
      table.insert(req.headers, header)
   end

   -- TODO: extend for arbitrary file extensions
   if (errorhandler) then
      req.uri.ext = "html"
   else
      req.uri.ext = "lc"
      errorhandler = "httpserver-error.lc"
   end
   req.uri.file = errorhandler
   local port, ip = connection:getpeer()
   print(ip .. ":" .. port, "Error " .. code .. " - Using errorhandler " .. errorhandler)
end

