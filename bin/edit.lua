local env = ...

local flags = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)=='-')end)
local args  = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)~='-')end)

local dir = args[1]

local p = path.absolute(dir or '',env.cwd,env.usr)

kernel.disk.makeDirectory(p)