function startup()
	if file.exists("_init_.lua") then
		print('Starting source init.')
		dofile('_init_.lua')
	elseif file.exists("_init_.lc") then
		print('Starting bytecode init.')
		dofile('_init_.lc')
	else
		print('init not found. dropping to prompt.')
	end
end
print('Starting in five seconds...')
tmr.alarm(0,5000,0,startup)