# lua-lock

    ./anybaud /dev/ttyUSB0 74880

## Flashing

    Sometimes you have to use flash mode dio for nodemcu/non adafruit

    esptool.py  --port /dev/ttyUSB0 write_flash 0x00000 nodemcu-firmware/bin/nodemcu_integer_master_20160515-0600.bin

    upload.sh

## Http api

    curl http://192.168.178.120/P12/70
