local env = ...

local flags = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)=='-')end)
local args  = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)~='-')end)

local file = args[1]

local p = path.absolute(file or '',env.cwd,'')

kernel.disk.close(kernel.disk.open(p,'a'))