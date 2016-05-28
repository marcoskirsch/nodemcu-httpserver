return function (connection, req, args)
   dofile('httpserver-header.lc')(connection, 200, 'html')

   connection:send([===[
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Hello World!</title>
</head>
<body>
<h1>Hello World!</h1>
</body>
</html>
]===])
end
