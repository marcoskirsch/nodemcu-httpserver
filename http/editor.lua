return function (connection, req, args)
   dofile('httpserver-header.lc')(connection, 200, 'html')

   if req.user == nil then
      --print("prompt not authenticated")
      connection:send([===[
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>lua editor</title>
</head>
<body>
<h1>This Page only for authenticated user</h1>
Please enable authentication in "httpserver-conf.lua".
</body>
</html>
]===])
   elseif req.method == 'GET' then
      --print('GET method')
      connection:send([===[
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>lua editor</title>
</head>
<body>
<h1>lua editor</h1>
<p>Load file: <input type="text" id="loadFile" value="hello_world.lua"><button id='load'>Load</button></p>
<p><textarea rows="20" cols="80" id="editText" name="editText">
</textarea></p>
<p>Save file: <input type="text" id="saveFile" value=""><button id='save'>Save</button></p>
<div id="localStatus"></div>
<div id="remoteStatus"></div>

<script>
var blockSize = 512;
var editText;
var filename;
var offset;
var xhr;

function handleSaveCallback() {
   if (xhr.readyState===4 && xhr.status==200)
   {
       document.getElementById("remoteStatus").innerHTML = xhr.responseText;
       offset += blockSize;
       if (offset < editText.length) {
          document.getElementById("localStatus").innerHTML = "Sending: " + offset + "/" + editText.length + " bytes";
          var params = "action=append&filename=" + filename + "&data=" + encodeURIComponent(editText.substring(offset, offset + blockSize));
          xhr=new XMLHttpRequest();
          xhr.open("POST", "editor.lua", true);
          xhr.onreadystatechange=handleSaveCallback;
          xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
          xhr.send(params);
       } else {
          document.getElementById("localStatus").innerHTML = "Saved " + editText.length + " bytes";
          document.getElementById("remoteStatus").innerHTML = "";
          if (filename.split(".").pop() == "lua") {
             params = "action=compile&filename=" + filename;
             xhr=new XMLHttpRequest();
             xhr.open("POST", "editor.lua", true);
             xhr.onreadystatechange=handleCompileCallback;
             xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
             xhr.send(params);
          }
       }
   }
}

function handleCompileCallback() {
   if (xhr.readyState==4 && xhr.status==200)
   {
      document.getElementById("remoteStatus").innerHTML = xhr.responseText;
   }
}

document.getElementById("load").addEventListener("click", function () {
   var loadFile = document.getElementById("loadFile");
   var saveFile = document.getElementById("saveFile");
   document.getElementById("localStatus").innerHTML = "Loading: " + loadFile.value;
   saveFile.value = loadFile.value;
   var params = "action=load&filename=" + loadFile.value
   var rxhr = new XMLHttpRequest();
   rxhr.open("POST", "editor.lua", true);
   rxhr.onreadystatechange=function() {
      if (rxhr.readyState === 4) {
         var et = document.getElementById("editText");
         et.value = rxhr.responseText;
         document.getElementById("localStatus").innerHTML = "Loaded: " + loadFile.value;
      }
   }
   rxhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
   rxhr.send(params);
});

document.getElementById("save").addEventListener("click", function () {
   editText = document.getElementById("editText").value;
   filename = encodeURIComponent(document.getElementById("saveFile").value);
   offset = 0;
   document.getElementById("localStatus").innerHTML = "Sending: " + offset + "/" + editText.length + " bytes";
   document.getElementById("remoteStatus").innerHTML = "";
   var params = "action=save&filename=" + filename + "&data=" + encodeURIComponent(editText.substring(offset, offset + blockSize));
   xhr=new XMLHttpRequest();
   xhr.open("POST", "editor.lua", true);
   xhr.onreadystatechange=handleSaveCallback;
   xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
   xhr.send(params);
});
</script>
</body>
</html>
]===])
   elseif req.method == 'POST' then
      --print('POST method')
      local rd = req.getRequestData()
      --print(node.heap())
      collectgarbage()
      --print(node.heap())
      if rd['action'] == 'load' then
         --print('load')
         file.open('http/' .. rd['filename'], 'r')
         local buffer = file.read()
         while buffer ~= nil do
            connection:send(buffer)
            buffer = file.read()
         end
         file.close()
      elseif rd['action'] == 'save' then
         --print('save')
         local data = rd['data']
         file.open('http/' .. rd['filename'], 'w+')
         file.write(data)
         file.close()
         connection:send('initial write: ' .. string.len(data))
      elseif rd['action'] == 'append' then
         --print('append')
         local data = rd['data']
         file.open('http/' .. rd['filename'], 'a+')
         file.seek('end')
         file.write(data)
         file.close()
         connection:send('append: ' .. string.len(data))
      elseif rd['action'] == 'compile' then
         --print('compile')
         node.compile('http/' .. rd['filename'])
         connection:send('<a href=\"' .. string.sub(rd['filename'], 1, -5) .. '.lc\">' .. string.sub(rd['filename'], 1, -5) .. '.lc</a>')
      end
   end
   collectgarbage()
end
