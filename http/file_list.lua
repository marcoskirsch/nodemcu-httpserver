return function (connection, args)
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\Cache-Control: private, no-store\r\n\r\n")
   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Server File Listing</title></head>')
   connection:send('<body>')
   connection:send('<h1>Server File Listing</h1>')
   connection:send("<ul>\n")

   local l = file.list()
   for name, size in pairs(l) do

      local isHttpFile = string.match(name, "(http/)") ~= nil
      local url = string.match(name, ".*/(.*)")
      if isHttpFile then
         connection:send('   <li><a href="' .. url .. '">' .. url .. "</a> (" .. size .. " bytes)</li>\n")
      end

   end
   connection:send("</ul>\n")
   connection:send('</body></html>')
end
