return function (connection, req, args)
   dofile("httpserver-header.lc")(connection, 200, 'html')

   connection:send([===[
      <!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Server File Listing</title></head>
      <body>
   <h1>Server File Listing</h1>
   ]===])

   local remaining, used, total=file.fsinfo()
   connection:send("<b>Total size: </b> " .. total .. " bytes<br/>\n" ..
                   "<b>In Use: </b> " .. used .. " bytes<br/>\n" ..
                   "<b>Free: </b> " .. remaining .. " bytes<br/>\n" ..
                   "<p>\n<b>Files:</b><br/>\n<ul>\n")

   for name, size in pairs(file.list()) do
      local isHttpFile = string.match(name, "(http/)") ~= nil
      if isHttpFile then
         local url = string.match(name, ".*/(.*)")
         connection:send('   <li><a href="' .. url .. '">' .. url .. "</a> (" .. size .. " bytes)</li>\n")
      end
   end
   connection:send("</ul>\n</p>\n</body></html>")
end

