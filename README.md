# starlight 

# baud rate for nodemcu error messages

    ./anybaud /dev/ttyUSB0 74880

## Flashing

Sometimes you have to use flash mode dio for nodemcu/non adafruit. The firmware needs the following modules bit, file, gpio, i2c, net, node, pwm, tmr, uart, wifi

    esptool.py  --port /dev/ttyUSB0 write_flash --flash_mode dio 0x00000 nodemcu-master-*-integer.bin

    ./upload.sh

## Http api

    curl http://192.168.178.120/P12/70
