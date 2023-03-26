local env = ...

local flags = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)=='-')end)
local args  = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)~='-')end)

local src = path.absolute(args[1] or '',env.cwd,env.usr)
local dest = path.absolute(args[2] or '',env.cwd,env.usr)

kernel.disk.rename(src,dest)