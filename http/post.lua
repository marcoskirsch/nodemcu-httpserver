return function (connection, req, args)
   dofile("httpserver-header.lc")(connection, 200, 'html')
   connection:send([===[
      <!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Arguments by POST</title></head><body><h1>Arguments by POST</h1>
   ]===])

   if req.method == "GET" then
      connection:send([===[
      <form method="POST">
         First name:<br><input type="text" name="firstName"><br>
         Last name:<br><input type="text" name="lastName"><br>
         <input type="radio" name="sex" value="male" checked>Male<input type="radio" name="sex" value="female">Female<br>
         <input type="submit" name="submit" value="Submit">
      </form>
      ]===])
   elseif req.method == "POST" then
      local rd = req.getRequestData()
      connection:send('<h2>Received the following values:</h2>')
      connection:send("<ul>\n")
      for name, value in pairs(rd) do
          connection:send('<li><b>' .. name .. ':</b> ' .. tostring(value) .. "<br></li>\n")
      end
      connection:send("</ul>\n")
   else
      connection:send("ERROR WTF req.method is ", req.method)
   end

   connection:send('</body></html>')
end
