local urest = require('urest');

local restServer = {};

function restServer.init()
    collectgarbage()

    local socketState = { 0, 0, 0 };
    local SOCKET_PINS = { 5, 7, 6 };

    gpio.mode(5, gpio.OUTPUT);
    gpio.mode(6, gpio.OUTPUT);
    gpio.mode(7, gpio.OUTPUT);

    gpio.write(5, gpio.LOW);
    gpio.write(6, gpio.LOW);
    gpio.write(7, gpio.LOW);

    urest.get('^/sockets', function()
        return socketState;
    end);

    urest.post('^/sockets', function(req, params, body)
        local data = cjson.decode(body);

        if not data.socket then
            return urest.error(400, 'NO_SOCKET', 'missing socket')
        end

        if not data.state then
            return urest.error(400, 'NO_STATE', 'missing state')
        end

        print("set " .. data.socket .. "(" .. SOCKET_PINS[data.socket] .. ")" .. " to " .. data.state)

        if data.state == 1 then
            socketState[data.socket] = 1
            gpio.write(SOCKET_PINS[data.socket], gpio.HIGH);
        else
            socketState[data.socket] = 0
            gpio.write(SOCKET_PINS[data.socket], gpio.LOW);
        end

        return { success = 1 };
    end)

    collectgarbage();

    local srv = net.createServer(net.TCP);
    srv:listen(config.HTTP_PORT, function(client)
        client:on('receive', function(_, request)
            local method, url = request:match('^(%a+)%s+(%S+)%s+HTTP')

            if (url == '/') then
                print('index requested');
                file.open("index.html", "r");
                local content = file.read();
                file.close();
                collectgarbage();

                client:send("HTTP/1.1 200 OK\r\n" ..
                        "Content-Type: text/html\r\n" ..
                        "Content-Length: " .. #content .. "\r\n\r\n" ..
                        content);
                client:close();
                collectgarbage();
            else
                client:send(urest.handle(request))
                client:close()
            end

            print('heap', node.heap())
        end)

        client:on('disconnection', function()
            collectgarbage()
        end)
    end)
end

return restServer;