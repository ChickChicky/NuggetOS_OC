io.clear()

do
    local img = image.load('/msc/img/os.img')
    local x = math.floor(kernel.width/2-img.width/2)
    img:printAt(x,2)
    io._sp(1,img.height+3)
end

print('Loading Nugget OS \x1b[33m0.0.1\x1b[m')

--[[while true do

    local evt,comp,chr,code,usr = computer.pullSignal()
    if evt == 'key_down' then
        print(chr,code,usr)
    end

end]]

kernel.loadfiles('/nuggetos/init')