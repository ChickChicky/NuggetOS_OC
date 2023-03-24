image = {}

local Image = {}
function Image.new(data)
    local gpu = kernel.gpu
    local img = {
        palette = {
            fg = {},
            bg = {}
        }
    }
    function img:print()
        local fg = gpu.getForeground()
        local bg = gpu.getBackground()
        for k,line in pairs(self.lpixels) do
            for k,c in pairs(line) do
                gpu.setForeground(fg) gpu.setBackground(bg)
                if img.palette.fg[c] then
                    gpu.setForeground(img.palette.fg[c])
                end
                if img.palette.bg[c] then
                    gpu.setBackground(img.palette.bg[c])
                end
                io.write(c)
            end
            print()
        end
        gpu.setForeground(fg)
        gpu.setBackground(bg)
    end
    function img:printAt(x,y)
        local fg = gpu.getForeground()
        local bg = gpu.getBackground()
        for dy,line in pairs(self.lpixels) do
            for dx,c in ipairs(line) do
                gpu.setForeground(fg) gpu.setBackground(bg)
                if img.palette.fg[c] then
                    gpu.setForeground(img.palette.fg[c])
                end
                if img.palette.bg[c] then
                    gpu.setBackground(img.palette.bg[c])
                end
                gpu.set(x+dx-1,y+dy-1,c)
            end
            print()
        end
        gpu.setForeground(fg)
        gpu.setBackground(bg)
    end
    setmetatable(img,Image)

    local width,height = 0,0

    local dl = table.from(data:gmatch('[^\r\n]+'))
    --- @type string
    local metainf = dl[1]
    local datalines = table.slice(dl,2)

    local lines = {}
    for k,l in pairs(datalines) do
        width = math.max(width,#l)
        local line = {}
        for c in l:gmatch('.') do
            table.insert(line,c)
        end
        table.insert(lines,line)
        height = height +1
    end

    table.map(string.split(metainf,','),function(rmeta)
        local _meta = string.split(rmeta,' ')
        local chr,meta = table.remove(_meta,1),table.slice(_meta,1)
        for k,m in pairs(meta) do
            local chars = table.fromstring(m)
            local op = table.remove(chars,1)
            local dat = table.concat(chars,'')
            if op == 'f' then
                img.palette.fg[chr] = color.from(dat)
            end
            if op == 'b' then
                img.palette.bg[chr] = color.from(dat)
            end
        end
    end)

    img.width = width
    img.height = height

    img.lpixels = lines
    img.pixels = table.flat(lines)

    return img
end

function image.load(path)

    local handle = kernel.disk.open(path)
    local data = readAll(kernel.disk,handle)
    kernel.disk.close(handle)

    return Image.new(data)

end