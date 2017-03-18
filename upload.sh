#!/bin/sh
sleep 1
nodemcu-uploader --baud 115200 file remove init.lua
nodemcu-uploader --baud 115200 node restart
sleep 8
#nodemcu-uploader --baud 115200 exec 'for k,v in pairs(file.list()) do print(k); file.remove(k) end'
nodemcu-uploader --baud 115200 upload server.lua init.lua config.lua connection.lua ada_pwm.lua
nodemcu-uploader --baud 115200 node restart
