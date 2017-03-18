local ada_pwm = require("ada_pwm")

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

    ada_pwm.set_on(0)
    ada_pwm.set_off(0)
    
    print(wifi.sta.getip())
end

init()

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(sck, payload)
        local code, method, port, dim = require("connection").handle(sck, payload)
        if code == 200 and method == "GET" and port and dim then
            print("dimming port " .. port .. " to " .. dim)
            ada_pwm.led_dim(port, dim)
        end
    end)
    conn:on("sent", function(sck) sck:close() end)
end)

