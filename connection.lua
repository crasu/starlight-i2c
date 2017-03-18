local M, module = {}, ...

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

    local port, dim = string.match(path,"/P(%d+)/(%d+)")
    if method == "GET" and port and dim then
        local buf = "HTTP/1.1 200 OK\n\n"
        buf = buf .. "Setting port " .. port .. " to value " .. dim

        client:send(buf)
        return 200, method, port, dim
    end

    if method == "GET" and path == "/" then
        local buf = "HTTP/1.1 200 OK\n\n"
        buf = buf .. "proccessed" 

        client:send(buf)
        
        return 200, method, "", ""
    else
        local buf = "HTTP/1.1 400 Bad Request\n\n"
        buf = buf .. "cannot process request: " .. method .. " " .. path 

        client:send(buf)
    
        return 400, method, "", ""
    end
end

return M
