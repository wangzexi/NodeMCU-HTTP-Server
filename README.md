# NodeMCU-HTTP-Server

A lightweight HTTP server for NodeMCU.
Inspired by [nodemcu_http_server](https://github.com/borischernov/nodemcu_http_server).

## Features

* Serving static files from NodeMCU file system
* Support for gzipped static files
* Support for GET query string parameter
* Redirects
* Support for index.html, 404.html
* Middleware models

## Example

``` lua
-- init.lua
print('Setting up WIFI...')
wifi.setmode(wifi.STATION)
wifi.sta.config('MY_SSID', 'MY_PASS')
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
```



## Request

### req.source

Contains the raw http header and body.

### req.ip

Contains the remote IP address of the request.

### req.method

Contains a string corresponding to the HTTP method of the request: GET, POST, PUT, and so on.

### req.query

This property is an table containing a property for each query string parameter in the route. If there is no query string, it is the empty table, {}.

### req.path

Contains the path part of the request URL.



## Response

### res:redirect(url [, status])

Redirects to the URL derived from the specified path, with specified status, a positive integer that corresponds to an HTTP status code . If not specified, status defaults to 302.

### res:type(type)

Sets the Content-Type HTTP header.

### res:status(status)

Sets the HTTP status for the response. 

### res:send(body)

Transfers the body, then close.

If not specified status code using **res:status()**, status defaults to 200.

If not specified Content-Type using **res:type()**, the Content-Type response HTTP header field will be 'text/html'.

### res:sendFile(filename)

Transfers the file, then close.

If the file doesn't exist, transfers 404.html.gz/404.html/'404 Not Found'.

If not specified Content-Type using **res:type()**, the Content-Type response HTTP header field will base on the filename’s extension.

If not specified status code using **res:status()**, status defaults to 200.

### res:close()

Ends the response process.



## Middleware models
request -> parseHeader -> **user middleware** -> staticFile

The order of middleware loading is important: middleware functions that are loaded first are also executed first.

If one of the user middleware functions has **nil/false** return value, the request process will be stopped.

### httpServer:use(url, callback)

The first parameter url is a lua pattern, i.e. **'\\foo.*'** can match '\foo.html', '\foo\bar.jpg'...



## Serving static files

If any request not processed by user middleware functions, serving static file will be attempted.

### Static files matching rule example

| url          | 1st try        | 2nd try     | 3th try     | 4th try  |
| :----------- | :------------- | :---------- | :---------- | :------- |
| /            | index.html.gz  | index.html  | 404.html.gz | 404.html |
| /foo.jpg     | foo.jpg.gz     | foo.jpg     | 404.html.gz | 404.html |
| /foo/bar.css | foo_bar.css.gz | foo_bar.css | 404.html.gz | 404.html |
| /foo         | foo.gz         | foo         | 404.html.gz | 404.html |

Slashes in request path are converted to underscores to get appropriate file name.

Static files may be gzipped to reduce used filesystem space. For a static file gzipped version is searched for first.

Server tries to guess content types for the most common file extensions used, see function **guessType()** for details.



## License

MIT