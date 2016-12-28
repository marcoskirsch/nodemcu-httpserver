return function (connection, req, args)
   dofile('httpserver-header.lc')(connection, 200, 'html')

   edit_filename = 'adhoc'
   if req.method == 'GET' then
      connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>lua editor</title></head><body><h1>lua editor</h1>')
      connection:send('<p><textarea rows="20" cols="80" id="edit_text" name="edit_text">')

      collectgarbage()
      file.open('http/' .. edit_filename .. '.lua', 'r')
      buffer = file.read()
      repeat
         connection:send(buffer)
         buffer = file.read()
      until buffer == nil
      file.close()
      collectgarbage()

      connection:send([===[
</textarea></p>
<button id="save">Save</button>
<div id="local_status"></div>
<div id="remote_status"></div>
<script>
var block_size = 1024;
var edit_text;
var offset;
var xmlhttp;
var form = document.getElementById("form");
function handleRequestCallback() {
   if (xmlhttp.readyState==4 && xmlhttp.status==200)
   {
       document.getElementById("remote_status").innerHTML = xmlhttp.responseText;
       offset += block_size;
       if (offset < edit_text.length) {
          document.getElementById("local_status").innerHTML = "Sending: " + offset + "/" + edit_text.length + " bytes";
          params = "action=append&data=" + encodeURIComponent(edit_text.substring(offset, offset + block_size));
          xmlhttp=new XMLHttpRequest();
          xmlhttp.open("POST", "editor.lua", true);
          xmlhttp.onreadystatechange=handleRequestCallback;
          xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
          xmlhttp.setRequestHeader("Content-length", params.length);
          xmlhttp.setRequestHeader("Connection", "close");
          xmlhttp.send(params);
       } else {
          document.getElementById("local_status").innerHTML = "Saved " + edit_text.length + " bytes";
          params = "action=compile";
          xmlhttp=new XMLHttpRequest();
          xmlhttp.open("POST", "editor.lua", true);
          xmlhttp.onreadystatechange=handleCompileCallback;
          xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
          xmlhttp.setRequestHeader("Content-length", params.length);
          xmlhttp.setRequestHeader("Connection", "close");
          xmlhttp.send(params);
       }
   }
}
function handleCompileCallback() {
   if (xmlhttp.readyState==4 && xmlhttp.status==200)
   {
      document.getElementById("remote_status").innerHTML = xmlhttp.responseText;
   }
}

document.getElementById("save").addEventListener("click", function () {
   edit_text = document.getElementById("edit_text").value;
   offset = 0;
   document.getElementById("local_status").innerHTML = "Sending: " + offset + "/" + edit_text.length + " bytes";
   document.getElementById("remote_status").innerHTML = "";
   params = "action=save&data=" + encodeURIComponent(edit_text.substring(offset, offset + block_size));
   xmlhttp=new XMLHttpRequest();
   xmlhttp.open("POST", "editor.lua", true);
   xmlhttp.onreadystatechange=handleRequestCallback;
   xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
   xmlhttp.setRequestHeader("Content-length", params.length);
   xmlhttp.setRequestHeader("Connection", "close");
   xmlhttp.send(params);
});
</script>
</body></html>
]===])
   elseif req.method == 'POST' then
      local rd = req.getRequestData()
      if rd['action'] == 'save' then
         data = rd['data']
         file.open('http/' .. edit_filename .. '.lua', 'w+')
         file.write(data)
         file.close()
         collectgarbage()
         connection:send('initial write: ' .. string.len(data))
      elseif rd['action'] == 'append' then
         data = rd['data']
         file.open('http/' .. edit_filename .. '.lua', 'a+')
         file.seek("end")
         file.write(data)
         file.close()
         collectgarbage()
         connection:send('append: ' .. string.len(data))
      elseif rd['action'] == 'compile' then
         node.compile('http/' .. edit_filename .. '.lua')
         collectgarbage()
         connection:send('<a href=\"' .. edit_filename .. '.lc\">' .. edit_filename .. '.lc</a>')
      end
   else
      connection:send('ERROR WTF req.method is ', req.method)
   end
end
