local env = ...

local flags = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)=='-')end)
local args  = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)~='-')end)

local used = kernel.disk.spaceUsed()
local free = kernel.disk.spaceTotal()-used

local function formatSize(s)
    if s >= 1000000 then
        return string.format("%.2fM",s/1000000)
    elseif s >= 1000 then
        return string.format("%.2fK",s/1000)
    else
        return string.format("%d",s)
    end
end

print(formatSize(used),formatSize(free),formatSize(used+free),string.format('%.2f%%',used/(used+free)),string.format('%.2f%%',free/(used+free)))