io.clear()

do
    local img = image.load('/msc/img/os.img')
    local x = math.floor(kernel.width/2-img.width/2)
    img:printAt(x,2)
    io._sp(1,img.height+3)
end

print('Loading Nugget OS \x1b[33m0.0.1\x1b[m')

kernel.loadfiles('/nuggetos/init')

print()
os.execute('/bin/shell.lua',{cwd='/home/',usr=''})

print('Nugget OS shell has been terminated')