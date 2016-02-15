return function (connection, args)
   dofile("httpserver-header.lc")(connection, 200, 'html')

   connection:send([===[
   <!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Arguments</title></head><body><h1>Arguments</h1>
   <form method="GET">
      First name:<br><input type="text" name="firstName"><br>
      Last name:<br><input type="text" name="lastName"><br>
      <input type="radio" name="sex" value="male" checked>Male<input type="radio" name="sex" value="female">Female<br>
      <input type="submit" name="submit" value="Submit">
   </form>
   ]===])
   coroutine.yield()

   if args["submit"] ~= nil then
      connection:send("<h2>Received the following values:</h2><ul>")
      coroutine.yield()
      for name, value in pairs(args) do
         connection:send('<li><b>' .. name .. ':</b> ' .. tostring(value) .. "<br></li>\n")
         coroutine.yield()
      end
   end

   connection:send("</ul>\n</body></html>")
end
