local M, module = {}, ...

local dev_addr = 0x40

local id = 0
local sda = 2 --GPIO4
local scl = 1 --GPIO5

local mode1=0x00     --location for Mode1 register address
local mode2=0x01     --location for Mode2 reigster address
local led0=0x06      --location for start of LED0 registers
local rst=0x01       --reset device

function M.handle(client, request)
    package.loaded[module]=nil
end

function M.init_i2c()
	i2c.setup(id, sda, scl, i2c.SLOW)
end

function read_reg(reg)
	i2c.start(id)
	i2c.address(id, dev_addr ,i2c.TRANSMITTER)
	i2c.write(id,reg)
	i2c.stop(id)
	i2c.start(0x0)
	i2c.address(0x0, dev_addr,i2c.RECEIVER)
	c = i2c.read(0x0,1)
	i2c.stop(0x0)
	rval = string.byte(c, 1)
	--print(rval)
	return rval
end

function write_reg(reg, data)
	i2c.start(id)
	i2c.address(id, dev_addr ,i2c.TRANSMITTER)
	i2c.write(id,reg)
	i2c.write(id,data)
	i2c.stop(id)
end

function write_12_bit(a)
	ah=bit.rshift(a,8)
	al=bit.band(a,0xff)
	return ah, al
end  

function M.init_pca()
    write_reg(mode1, rst)           --reset device

    if (read_reg(mode1)==0x01) then --check status
        status = true 
        print("PCA9685 Init OK")
    else 
        status = false
        print("PCA9685 Init Failure!")
    end
    --print(status)

    write_reg(mode1, 0xA0) --10100000 - set for auto-increment 

    --Direct LED connection 
    write_reg(mode2, 0x10) --set to output mode INVRT = 1 OUTDRV = 0

    --External N-type driver
    --write_reg(mode2, 0x04)   -- set to output mode INVRT = 0 OUTDRV = 1

    --External P-type driver
    --write_reg(mode2, 0x14) --set to output mode INVRT = 1 OUTDRV = 1
    
    return status
end


function write_led(ledN, LED_ON, LED_OFF)
	i2c.start(id)
	i2c.address(id, dev_addr ,i2c.TRANSMITTER)
	i2c.write(id,led0+4*ledN)
	write_12_bit(LED_ON)
	i2c.write(id,al)
	i2c.write(id,ah)
	write_12_bit(LED_OFF)
	i2c.write(id,al)
	i2c.write(id,ah)
	i2c.stop(id)
end


function M.set_on(ledN)
    write_led(ledN,0x1000,0)
end


function M.set_off(ledN)
	write_led(ledN,0,0x1000)
end


function M.led_dim(ledN, dimm)
   if (dimm==0) then M.set_off(ledN)
   else if (dimm==100) then M.set_on(ledN)
        else write_led(ledN, dim, 0)
   end
   end
end


return M

