local gpuAddr = component.list('gpu', true)()
local gpu = component.proxy(gpuAddr)

local function flip(x,y)
    local chr, fg, bg = gpu.get(x,y)
    local obg,obg2 = gpu.setBackground(fg)
    local ofg,ofg2 = gpu.setForeground(bg)
    gpu.set(x,y, chr)
    gpu.setBackground(obg,obg2)
    gpu.setForeground(ofg,ofg2)
end

io = { }
term = {}

local _x,_y = 1,1

function io._sp(x,y)
    if not x or not y then
        return _x, _y
    end
    _x = x
    _y = y
end

---@class ansi
local ansi = {
    colors = {
        -- normal colors (FG/BG)
        ['30'] = 0x000000, ['40'] = 0x000000,
        ['31'] = 12914463,  ['41'] = 12914463,
        ['32'] = 1286414,   ['42'] = 1286414,
        ['33'] = 12688384,    ['43'] = 12688384,
        ['34'] = 14300928, ['44'] = 14300928,
        ['35'] = 8918936,  ['45'] = 8918936,
        ['36'] = 3839709, ['46'] = 3839709,
        ['37'] = 13421772, ['47'] = 13421772,

        -- bright colors (FG/BG)
        ['90'] = 7763574,  ['100'] = 7763574,
        ['91'] = 15157334,  ['101'] = 15157334,
        ['92'] = 1492492,   ['102'] = 1492492,
        ['93'] = 16380325, ['103'] = 16380325,
        ['94'] = 3897599, ['104'] = 3897599,
        ['95'] = 11796638, ['105'] = 11796638,
        ['96'] = 6411990, ['106'] = 6411990,
        ['97'] = 15921906, ['107'] = 15921906,
    },
    isBackground = function(color)
        if (
            (
                39 < tonumber(color) and
                48 > tonumber(color)
            ) or
            (
                99 < tonumber(color) and
                108 > tonumber(color)
            )
        ) then
            return true
        end
        return false
    end,
    isForeground = function(color)
        if (
            (
                29 < tonumber(color) and
                38 > tonumber(color)
            ) or
            (
                89 < tonumber(color) and
                98 > tonumber(color)
            )
        )  then
            return true
        end
        return false
    end
}

---@type ansi
io.ansi = ansi

--- @type number
--- 0 is soft scroll (progressive scroll)
--- 1 is hard scroll (scrolling clears and goes back to the beggining)
io.scroll = 0

--  STDOUT  --

io.stdout = { }
function io.stdout:write(...)
    local str = table.concat({...},' ' )
    local esc = false
    for ci = 1,unicode.len(str) do
        local c = unicode.sub(str,ci,ci)
        if c == '\x1b' or esc then
            if esc then
                if esc.csi == '' then
                    esc.csi = c
                else
                    if c:match('%d') then
                        esc.tmp = esc.tmp..c
                    else
                        table.insert(esc.args,esc.tmp)
                        esc.tmp = ''
                        if c:match('%a') then
                            if c == 'm' then                                                -- SGR
                                for k,style in pairs(esc.args) do
                                    local color = io.ansi.colors[style]
                                    if color then
                                        if io.ansi.isBackground(style) then
                                            gpu.setBackground(color)
                                        end
                                        if io.ansi.isForeground(style) then
                                            gpu.setForeground(color)
                                        end
                                    elseif style == '39' then
                                        gpu.setForeground(io.ansi.colors["37"])
                                    elseif style == '49' then
                                        gpu.setBackground(io.ansi.colors["40"])
                                    elseif style == '' or style == '0' then
                                        gpu.setForeground(io.ansi.colors["37"])
                                        gpu.setBackground(io.ansi.colors["40"])
                                    end
                                end
                            elseif c == 'H' then                                            -- CUP
                                io._sp(tonumber(esc.args[2]),tonumber(esc.args[1]))
                            elseif c == 'A' then io._sp(_x,_y-(tonumber(esc.args[1]) or 1)) -- CUU
                            elseif c == 'B' then io._sp(_x,_y+(tonumber(esc.args[1]) or 1)) -- CUD
                            elseif c == 'C' then io._sp(_x+(tonumber(esc.args[1]) or 1),_y) -- CUF
                            elseif c == 'D' then io._sp(_x-(tonumber(esc.args[1]) or 1),_y) -- CUB
                            elseif c == 'G' then io._sp((tonumber(esc.args[1]) or 1),_y)    -- CHA
                            elseif c == 'J' then                                            -- ED
                                local mode = tonumber(esc.args[1])
                                local w,h = gpu.getResolution()
                                if mode == 2 then
                                    gpu.fill(1,1,w,h,' ')
                                elseif mode == 0 then
                                    gpu.fill(_x,_y,w,_y,' ')
                                    gpu.fill(_x,_y+1,w,h,' ')
                                end 
                            elseif c == 'K' then                                            -- EL
                                local mode = tonumber(esc.args[1])
                                local w,h = gpu.getResolution()
                                if mode == 2 then
                                    gpu.fill(_x,_y,w,_y,' ')
                                elseif mode == 0 then
                                    gpu.fill(_x,_y,w,_y,' ')
                                end
                            end
                            esc = false
                        end
                    end
                end
            else
                esc = {
                    tmp = '',
                    args = {},
                    csi = '',
                }
            end
        elseif c == '\n' then
            _x = 1
            _y = _y +1
        elseif c == '\a' then
            computer.beep()
        elseif c == '\t' then
            io.write('    ')
        else
            gpu.set(_x,_y,c)
            _x = _x +1
        end
        if _x > gpu.w then
            io._sp( 2,_y+1 )
        end
        if _y >= gpu.h then
            if io.scroll == 0 then
                _y = _y-1
                local w,h = gpu.getResolution()
                gpu.copy(1,1,w,h,0,-1)
            elseif io.scroll == 1 then
                term.clear()
                _x = 1
                _y = 1
            else
                error( "Invalid value for io.scroll ("..tostring(io.scroll)..")" )
            end
        end
    end
end
function io.stdout:read(...) error('Cannot perform read operation on STDOUT') end

--  STDERR  --

io.stderr = {}
function io.stderr:write(...)
    local _color = gpu.setForeground( 0xff0000 )
    local str = table.concat( {...},' ' )
    for c in str:gmatch('.') do
        if c == '\n' then
            _x = 1
            _y = _y +1
        elseif c == '\a' then
            computer.beep()
        elseif c == '\t' then
            io.write('    ')
        else
            gpu.set(_x,_y,c)
            _x = _x +1
        end
    end
    gpu.setForeground( _color )
end
function io.stderr:read(...) error('Cannot perform read operation on STDERR') end

-- STDIN --

io.stdin = {}
function io.stdin:read(...)
    local v = ""
    local c = 1
    local ox,oy = _x,_y
    local mod = 0
    while true do
        local ev = {computer.pullSignal(0.1)}
        if ev[1] == 'key_down' then
            local evt,comp,chr,code,usr = table.unpack(ev)
            if code == 14 then
                local ov = #v;
                v = v:sub(1,math.max(0,c-2)) .. v:sub(c)
                c = c+#v-ov
                mod = 3
            elseif code == 211 then
                v = v:sub(1,c-1) .. v:sub(c+1)
            elseif code == 203 then
                c = math.max(1,c-1)
                mod = 3
            elseif code == 205 then
                c = math.min(#v+1,c+1)
                mod = 3
            elseif code == 199 then
                c = 1
            elseif code == 207 then
                c = #v+1
            elseif chr == 13 then
                _x = ox
                _y = oy
                io.write(v..'  \n')
                return v
            elseif chr ~= 0 then
                v = v:sub(1,c-1) .. unicode.char(chr) .. v:sub(c)
                c = c+1
                mod = 3
            end
        elseif ev[1] == 'clipboard' then
            local evt,comp,content,usr = table.unpack(ev)
            v = v:sub(1,c-1) .. content .. v:sub(c)
            c = c+#content
            mod = 3
        elseif ev[1] ~= nil then
            --computer.pushSignal(table.unpack(ev))
        end
        _x = ox
        _y = oy
        io.write(v..'  ')
        if computer.uptime()%1 >0.5 or mod>0 then
            flip(ox+c-1,oy)
        end
        mod = math.max(0,mod-1)
    end
end

-- 

function io.clear()
    io.stdout:write('\x1b[2J\x1b[1;1H')
end

function io.write(...)
    return io.stdout:write(...)
end

function io.read(...)
    return io.stdin:read(...)
end

function io.getch()
    while true do
        local evt,comp,chr,code,usr = computer.pullSignal()
        if evt == 'key_down' and chr ~= 0 then
            return utf8.char(chr)
        end
    end
end


function print(...)
    local args = table.map({...},tostring)
    io.stdout:write(table.unpack(args))
    io.stdout:write('\n')
end

function eprint(...)
    local args = table.map({...},tostring)
    local _color = gpu.setForeground(0xFF0000)
    io.stdout:write(table.unpack(args))
    io.stdout:write('\n')
    gpu.setForeground(_color)
end