local function storelist(t)
--      connection:send(cjson.encode(t))
--      print(cjson.encode(t))
      file.remove("http/aplist.json")
      file.open("http/aplist.json","w+")
      file.writeline(cjson.encode(t))
      file.close()
end

return function(connection,args) 
    wifi.sta.getap(storelist)
    connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
    connection:send('{"error":0, "message":"OK"}')
end
