print('Setting up WIFI...')
wifi.setmode(wifi.STATION)
wifi.sta.config('testwifi', '123456789')
wifi.sta.connect()

tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()
	if wifi.sta.getip() == nil then
		print('Waiting for IP ...')
	else
		print('IP is ' .. wifi.sta.getip())
	tmr.stop(1)
	end
end)

-- Serving static files
dofile('httpServer.lua')
httpServer:listen(80)

-- Custom API
-- Get text/html
httpServer:use('/welcome', function(req, res)
	res:send('Hello ' .. req.query.name) -- /welcome?name=doge
end)

-- Get file
httpServer:use('/doge', function(req, res)
	res:sendFile('doge.jpg')
end)

-- Get json
httpServer:use('/json', function(req, res)
	res:type('application/json')
	res:send('{"doge": "smile"}')
end)

-- Redirect
httpServer:use('/redirect', function(req, res)
	res:redirect('doge.jpg')
end)