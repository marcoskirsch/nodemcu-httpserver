local function storelist(table)
      file.remove("http/aplist.json")
      file.open("http/aplist.json","w")
      coroutine.yield()
      file.write(cjson.encode(table))
      file.close()
      print(cjson.encode(table))
end






local function sendHeader(connection)
    connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
    connection:send('{"error":0, "message":"OK"}')
end



return function(connection,args) 
    sendHeader(connection)
    wifi.sta.getap(storelist)
end
