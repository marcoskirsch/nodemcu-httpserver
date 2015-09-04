return function (connection, req, args)
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Arguments</title></head>')
   connection:send('<body>')
   connection:send('<h1>Arguments</h1>')

   local form = [===[
   <form method="POST">
      First name:<br><input type="text" name="firstName"><br>
      Last name:<br><input type="text" name="lastName"><br>
      <input type="radio" name="sex" value="male" checked>Male<input type="radio" name="sex" value="female">Female<br>
      <input type="submit" value="Submit">
   </form>
   ]===]
   
   if req.method == "GET" then
      connection:send(form)
   elseif req.method == "POST" then
     local rd = req.getRequestData()
   --   connection:send(cjson.encode(rd))
      connection:send('<h2>Received the following values:</h2>')
      connection:send("<ul>\n")
      for name, value in pairs(rd) do
          connection:send('<li><b>' .. name .. ':</b> ' .. tostring(value) .. "<br></li>\n")
      end

      connection:send("</ul>\n")
   else
      connection:send("NOT IMPLEMENTED")
   end
   
   connection:send('</body></html>')
end
