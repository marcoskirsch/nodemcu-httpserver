return function (connection, req, args)
   
   local function showCars(nr)
      if not nr then return end
      connection:send([===[<figure><img src="cars-ferrari.jpg" /><figcaption>Ferrari</figcaption></figure>]===])
      if nr == "1" then return end
      connection:send([===[<figure><img src="cars-lambo.jpg" /><figcaption>Lamborghini</figcaption></figure>]===])
      if nr == "2" then return end
      connection:send([===[<figure><img src="cars-mas.jpg" /><figcaption>Maserati</figcaption></figure>]===])
      if nr == "3" then return end
      connection:send([===[<figure><img src="cars-porsche.jpg" /><figcaption>Porsche</figcaption></figure>]===])
      if nr == "4" then return end
      connection:send([===[<figure><img src="cars-bugatti.jpg" /><figcaption>Bugatti</figcaption></figure>]===])
      if nr == "5" then return end
      connection:send([===[<figure><img src="cars-mercedes.jpg" /><figcaption>Mercedes</figcaption></figure>]===])
   end


   dofile("httpserver-header.lc")(connection, 200, 'html')
   connection:send([===[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
   <head>
      <meta http-equiv="content-type" content="text/html; charset=utf-8">
      <title>Nice cars</title>
   </head>
   <body>
      <h1>Nice cars!</h1>
      <p>
         This page loads "large" images of fancy cars. It is meant to serve as a stress test for nodemcu-httpserver.<br>
         It works with three embedded images of cars, but the server crashes with four. Select the number of cars you want to see below.<br>
         Whoever manages to modify nodemcu-httpserver to load all four images without crashing wins a prize!
      </p>
      <p>
         choose: <a href="?n=1">show one car</a>
         <a href="?n=2">show two cars</a>
         <a href="?n=3">show three cars</a>
         <a href="?n=4">show four cars</a>
         <a href="?n=5">show five cars</a>
         <a href="?n=6">show six cars</a>
      </p>
   ]===])

     showCars(args.n)
   
   connection:send([===[
   </body>
</html>
   ]===])
end

