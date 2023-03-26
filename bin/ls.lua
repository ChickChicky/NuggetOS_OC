local env = ...

local flags = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)=='-')end)
local args  = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)~='-')end)

local dir = args[1]

local p = path.absolute(dir or '',env.cwd,'')

local function formatSize(s)
    if s >= 1000000 then
        return string.format("%.2fM",s/1000000)
    elseif s >= 1000 then
        return string.format("%.2fK",s/1000)
    else
        return string.format("%d",s)
    end
end

local function formatDate(d)
    return os.date('%b %d %Y %H:%M',d/1000+3600)
end

if fs.exists(p) then
    if table.includes(flags,'-l') then
        local list = fs.list(p)
        local sizejust = math.max(table.unpack(table.imap(table.nn(list),function(v)return(#formatSize(fs.info(path.join(p,v)).size))end)))
        for k,v in ipairs(list) do
            local info = fs.info(path.join(p,v))
            local sizestr =  formatSize(info.size)
            local d =
                ''
                .. string.rep(' ',sizejust-#sizestr) .. sizestr .. ' '
                .. formatDate(info.lastModified) .. ' '
                .. '\x1b[96m' .. (info.isDirectory and 'd' or 'f') .. '\x1b[39m '
            if info.isDirectory then
                print(d..'\x1b[94m'..v..'\x1b[39m')
            else
                print(d..v)
            end
        end
    else
        for k,v in ipairs(fs.list(p)) do
            local info = fs.info(path.join(p,v))
            if info.isDirectory then
                print('\x1b[94m'..v..'\x1b[39m')
            else
                print(v)
            end
        end
    end
else
    print('No such file or directory: ',tostring(p))
end