local ada_pwm = require("ada_pwm")

local fade_list = {}
local current_value = {[0] = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

function fader()
    print("Fading")
    for key, entry in pairs(fade_list) do
        local port = entry["port"]
        local final_dim = entry["dim"]
        local speed = entry["speed"]
        local dim = 0
        if math.abs(current_value[port] - final_dim) <= math.abs(speed) then
            dim = final_dim
            table.remove(fade_list, key)
            print("Done with fading for port " .. port)
        else
            dim = current_value[port] + speed
        end
        if dim < 0 then
            dim = 0
        end
        if dim > 100 then
            dim = 100
        end
        print("Setting port " .. port .. " to " .. dim)
        current_value[port] = dim
        ada_pwm.led_dim(port, dim)
    end
end

function calc_fade_speed(port, dim, fade)
    local speed = 0
    if fade == 0 then
        speed = dim - current_value[port]
    else
        speed = (dim - current_value[port]) / fade 

        if speed >= -1 and speed <= 1 then
            speed = current_value[port] - dim
        end
    end
    return speed
end

function init()
    local config = require("config")

    wifi.setmode(wifi.STATION)
    wifi.sta.config(config.SSID, config.PASS)

    tmr.alarm(1, 10*60*1000, tmr.ALARM_SINGLE, function()
        print("light sleep serial unstable ...")
        wifi.sleeptype(wifi.LIGHT_SLEEP)
    end)
    ada_pwm.init_i2c()
    ada_pwm.init_pca()

    local FADER_MS = 500

    tmr.alarm(2, FADER_MS, tmr.ALARM_AUTO, fader)

    tmr.alarm(3, 10*1000, tmr.ALARM_SINGLE, function()
        print(wifi.sta.getip())
    end)
end

function server()
    srv=net.createServer(net.TCP)
    srv:listen(80, function(conn)
        conn:on("receive", function(sck, payload)
            local code, method, port, dim, fade = require("connection").handle(sck, payload)
            if code == 200 and method == "GET" and port and dim and fade then
                print("dimming port " .. port .. " to " .. dim .. " in " .. fade .. " cs")
                local speed = calc_fade_speed(port, dim, fade)
                print("dim speed is " .. speed)
                local entry = { port = port, dim = dim, speed = speed }
                table.insert(fade_list, entry)
            end
        end)
        conn:on("sent", function(sck) sck:close() end)
    end)
end

init()
server()

