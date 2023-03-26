-- Screen
local screenAddr = component.list('screen', true)()
local screen = component.proxy(screenAddr)
-- Storage
local diskAddr = computer.getBootAddress()
local disk = component.proxy(diskAddr)
-- GPU
local gpuAddr = component.list('gpu', true)()
local gpu = component.proxy(gpuAddr)
-- EEPROM
local eepromAddr = component.list('eeprom',true)()
local eeprom = component.proxy(eepromAddr)

---------------------------------------------------------------
-- GPU setup

gpu.bind(screenAddr)
local w, h = gpu.maxResolution()
gpu.setResolution(w, h)
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
gpu.fill(1,1,w,h,' ') -- clears the screen

gpu.w,gpu.h = gpu.getResolution()

---------------------------------------------------------------
-- important functions

--[[
    Helper to get the contents of a file
]]
function readAll(disk,handle)
    local buffer = ""
    repeat
        local data = disk.read(handle,math.huge)
        buffer = buffer .. (data or "")
    until not data
    return buffer
end

--[[
    Pretty much the same as require
]]
function loadfile(path)
    local handle = disk.open(path)

    -- load the file contents
    local buffer = ""
    repeat
        local data = disk.read(handle,math.huge)
        buffer = buffer .. (data or "")
    until not data

    disk.close(handle)

    return load(buffer,path,'bt',_G)
end


function dofile(path,...)
    local fn,err = loadfile(path)
    if err then
        error(err)
    else
        if fn == nil then
            error('loadfile() returned nil')
        else
            fn(...)
        end
    end
end

-- status = setmetatable({
--     -- vars
--     lines = 0
-- },{
--     -- metamethods
--     __call = function(...)
--         gpu.set(1,status.lines+1,table.concat(table.pack(...),' '))
--         status.lines = status.lines +1
--     end
-- });

-- The very first printing functions

local lines = 0
function status(...)
    local str = table.pack(...) for k,v in pairs(str) do str[k] = tostring(v) end
    local _color = gpu.setForeground(0xFFFFFF)
    gpu.set(1,lines+1,table.concat(str,' '))
    gpu.setForeground(_color)
    lines = lines + 1
end

function estatus(...)
    local str = table.pack(...) for k,v in pairs(str) do str[k] = tostring(v) end
    local _color = gpu.setForeground(0xFF0000)
    gpu.set(1,lines+1,table.concat(str,' '))
    gpu.setForeground(_color)
    lines = lines + 1
end

function wstatus(...)
    local str = table.pack(...) for k,v in pairs(str) do str[k] = tostring(v) end
    local _color = gpu.setForeground(0xFFFF00)
    gpu.set(1,lines+1,table.concat(str,' '))
    gpu.setForeground(_color)
    lines = lines + 1
end

---------------------------------------------------------------
-- EEPROM update

-- do
--     local handle = disk.open('eeprom.lua','r')
--     local bios = readAll(disk,handle)
--     if #bios > eeprom.getSize() then
--         estatus('[INIT] eeprom.lua too large ('..tostring(#bios/1000)..'k/'..tostring(eeprom.getSize()/1000)..'k)')
--     else
--         eeprom.set(bios)
--         status('[INIT] EEPROM updated')
--     end
--     disk.close(handle)
-- end

---------------------------------------------------------------
-- Debugging things ?
--[[do
    for cAddr,cType in component.list() do
        if cType == 'gpu' then
            gpu = component.proxy(cAddr)
            break
        end
    end
    local i = 1 
    for k,v in pairs(eeprom) do
        gpu.set(1,i,tostring(k).."        "..tostring(v))
        i=i +1
    end
end]]

---------------------------------------------------------------
-- Status Report

do

    local cs = eeprom.getChecksum()
    local n = eeprom.getLabel()
    -- status(cs)

    if cs == '' or n == 'ChickOS Bios' then
        -- status('[STAT]','EEPROM',cs,'ChickOS Bios')
    elseif cs == '3941da98' then
        -- status('[STAT]','EEPROM',cs,'LUA Bios')
    else
        -- wstatus('[STAT]','EEPROM',cs,"\""..n.."\"")
    end

    if computer.energy()/computer.maxEnergy() < .1 then
        wstatus('[STAT]',tostring(math.floor(computer.energy()/computer.maxEnergy()*100))..'% energy')
    else
        status('[STAT]',tostring(math.floor(computer.energy()/computer.maxEnergy()*100))..'% energy')
    end

end

---------------------------------------------------------------
-- Loading files

do
    
    local function loadp(path)
        for i,filename in pairs(disk.list(path)) do
            if type(i) == 'number' then
                if not disk.isDirectory(path..filename) then
                    if not xpcall(
                        function()
                            dofile(path..filename)
                            status('[INIT]',path..filename)
                        end,

                        function(e)
                            estatus('[INIT]',path..filename,' ',e)
                        end
                    ) then
                        while true do coroutine.yield() end
                    end
                end
            end
        end
    end

    loadp('/kernel/init/')
    loadp('/kernel/')
    loadp('/kernel/wrapper/')
    loadp('/kernel/lib/')

end

---------------------------------------------------------------
-- Kernel

---@class okernel
local okernel = {
    screenAddr = screenAddr,
    screen = screen,
    diskAddr = diskAddr,
    disk = disk,
    gpuAddr = gpuAddr,
    gpu = gpu,
    eepromAddr = eepromAddr,
    eeprom = eeprom,

    ---@type number
    width = nil,
    ---@type number
    height = nil,
}

---loads all files from a folder globally
---@param path string
---@return number # the amount of failed loadings
function okernel.loadfiles(path)

    path = (path..'/'):gsub('//','/')

    local failed = 0

    for i,filename in pairs(disk.list(path)) do
        if type(i) == 'number' then
            if not disk.isDirectory(path..filename) then
                xpcall(
                    function()
                        dofile(path..filename)
                    end,
                    function(e)
                        estatus('LOADFILE ',path..filename,' ',e)
                        failed = failed +1
                    end
                )
            end
        end
    end

    return failed

end

local ks = 'R'

local kernelstatus = function(stat)
    local w,h = gpu.getResolution()
    local _fg = gpu.setForeground( 0xFF0000 )
    local _bg = gpu.setBackground( 0x000000 )
    gpu.set(w-#stat+1,1,stat)
    gpu.setForeground(_fg)
    gpu.setBackground(_bg)
    ks = stat
end

---@type okernel
kernel = {}
setmetatable(kernel,{
    __index = function (t,name)
        if name == 'status' then
            return ks
        elseif name == 'width' then
            return table.pack(gpu.getResolution())[1]
        elseif name == 'height' then
            return table.pack(gpu.getResolution())[2]
        else
            return okernel[name]
        end
    end,
    __newindex = function(t,name,value)
        error('Trying to overwrite ')
    end
})

---------------------------------------------------------------
-- Booting

local _coro = nil

local function setcoro(fn)
    _coro = coroutine.create(fn)
end

io._sp(1,lines+2)

image.load('/kernel/msc/img/kernel.img'):print()
print()

print('\n[BOOT] booting...')
xpcall(
    function()
        if disk.exists('boot.lua') then
            dofile('boot.lua')
        else
            eprint('[BOOT] No boot.lua file found')
        end
    end,
    function(err)
        setcoro(function()
            gpu.setBackground( 0x0000FF )
            gpu.setForeground( 0xFFFFFF )
            local w,h = gpu.getResolution()
            gpu.fill(1,1,w,h," ")
            io._sp(1,1)
            print(':(')
            print('')
            print('   An unexpected error has occured, try rebooting your device')
            local shown = false
            while true do
                coroutine.yield()
                local signal = table.pack(computer.pullSignal(0))
                local signame = signal[1]
                if signame == 'key_up' then
                    local s,kbd,char,code,player = table.unpack(signal)
                    if char == 13 and not shown then
                        print('\n\n\n\n\n')
                        print('Debug details:')
                        print('')
                        print(err)
                        shown = true
                        break
                    end
                end
            end
        end)
    end
)

while true do
    if _coro ~= nil then
        kernelstatus('A')
        local s = coroutine.status(_coro)
        if s == 'dead' then
            _coro = nil
        else
            coroutine.resume(_coro)
        end
        kernelstatus('A')
    else
        kernelstatus('Y')
        sleep(0.1)
        kernelstatus('Y')
    end
end