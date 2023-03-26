local env = ...

local flags = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)=='-')end)
local args  = table.ifilter(table.slice({...},2),function(arg)return(arg:sub(1,1)~='-')end)

local file = args[1]

local p = path.absolute(file or '',env.cwd,'')

if fs.exists(p) then
    print(fs.readFile(p))
else
    print('\x1b[31mNo such file or directory: \x1b[91m',tostring(p),'\x1b[39m')
end