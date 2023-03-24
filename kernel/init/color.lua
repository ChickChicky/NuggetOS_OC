color = {}

function color.from(...)
    local args = {...}
    local r,g,b = 0,0,0
    if
        #args == 3 and
            type(args[1]) == 'number' and
            type(args[2]) == 'number' and
            type(args[3]) == 'number'
    then
        r,g,b = table.unpack(args)
    end
    if
        #args == 1 and
            type(args[1]) == 'string'
    then
        local hexcolors = string.chunks(args[1],2)
        r,g,b = table.unpack(table.map(hexcolors,function(c)
            c = c:upper()
            local t = {
                ['0'] = 0, ['1'] = 1, ['2'] = 2,
                ['3'] = 3, ['4'] = 4, ['5'] = 5,
                ['6'] = 6, ['7'] = 7, ['8'] = 8,
                ['9'] = 9,
                A = 10, B = 11,
                C = 12, D = 13,
                E = 14, F = 15,
            }
            return t[c:sub(1,1)]*16 + t[c:sub(2,2)]
        end))
    end
    return r*65536 + g*256 + b
end