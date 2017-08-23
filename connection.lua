local M, module = {}, ...

function validate(port, dim, fade)
    return port and dim and port >= 0 and port < 16 and dim >= 0 and dim <= 100 and fade >= 0 and fade <= 600
end

function M.handle(client, request)
    package.loaded[module]=nil

    local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
    if(method == nil)then
        _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
    end
    local _GET = {}
    if (vars ~= nil)then
        for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
            _GET[k] = v
        end
    end

    local port, dim, fade = string.match(path,"/P(%d+)/(%d+)/F(%d+)")
    port = tonumber(port)
    dim = tonumber(dim)
    fade = tonumber(fade)

    if method == "GET" and validate(port, dim, fade) then
        local buf = "HTTP/1.1 200 OK\n\n"
        buf = buf .. "Setting port " .. port .. " to value " .. dim .. "\n"

        client:send(buf)
        return 200, method, port, dim, fade
    elseif method == "GET" and path == "/" then
        local buf = "HTTP/1.1 200 OK\n\n"
        buf = buf .. "nodemcu ok\n" 

        client:send(buf)
        return 200, method, nil, nil, nil
    else
        local buf = "HTTP/1.1 400 Bad Request\n\n"
        buf = buf .. "cannot process request: " .. method .. " " .. path .. "\n"

        client:send(buf)
        return 400, method, nil, nil, nil
    end
end

return M
