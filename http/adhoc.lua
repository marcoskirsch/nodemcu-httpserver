return function (connection, req, args)
   dofile('httpserver-header.lc')(connection, 200, 'html')
   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>lua editor</title></head><body>')
   connection:send('<h1>Hello World!</h1>')
   connection:send('</body></html>')
end
