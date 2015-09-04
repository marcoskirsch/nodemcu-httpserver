return function (connection, req, args)
   connection:send("HTTP/1.0 200 OK\r\nContent-Type: text/html\r\nCache-Control: private, no-store\r\n\r\n")
   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Arguments</title></head>')
   connection:send('<body>')
   connection:send('<h1>Arguments</h1>')

   local form = [===[
   <form method="GET">
      First name:<br><input type="text" name="firstName"><br>
      Last name:<br><input type="text" name="lastName"><br>
      <input type="radio" name="sex" value="male" checked>Male<input type="radio" name="sex" value="female">Female<br>
      <input type="submit" value="Submit">
   </form>
   ]===]

   connection:send(form)

   connection:send('<h2>Received the following values:</h2>')
   connection:send("<ul>\n")
   for name, value in pairs(args) do
      connection:send('<li><b>' .. name .. ':</b> ' .. tostring(value) .. "<br></li>\n")
   end

   connection:send("</ul>\n")
   connection:send('</body></html>')
end
