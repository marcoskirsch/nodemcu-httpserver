return function (connection, req, args)
   dofile("httpserver-header.lc")(connection, 200, 'html')
   connection:send([===[
   <!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Arguments by GET</title></head><body><h1>Arguments by GET</h1>
   ]===])

   if args.submit == nil then
      connection:send([===[
         <form method="GET">
            First name:<br><input type="text" name="firstName"><br>
            Last name:<br><input type="text" name="lastName"><br>
            <input type="radio" name="sex" value="male" checked>Male<input type="radio" name="sex" value="female">Female<br>
            <input type="submit" name="submit" value="Submit">
         </form>
      ]===])
   else
      connection:send("<h2>Received the following values:</h2><ul>")
      for name, value in pairs(args) do
         connection:send('<li><b>' .. name .. ':</b> ' .. tostring(value) .. "<br></li>\n")
      end
      connection:send("</ul>\n")
   end
   connection:send("</body></html>")
end

