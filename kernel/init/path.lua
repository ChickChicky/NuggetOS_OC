---@class path
path = {}

---Joins multiple paths together to make one
---@param ... string
---@return string
function path.join(...)
    return table.concat(table.filter(table.flat(table.map(table.filter({...},function(v)return(v and #v)end),path.parts)),function(v)return(v and #v)end),'/')
end

---Returns the parts of a path
---@param p string
---@return table
function path.parts(p)
    local parts = {''}
    for c in p:gmatch('.') do
        if c == '/' then
            table.insert(parts,'')
        else
            parts[#parts] = parts[#parts]..c
        end
    end
    return table.ifilter(parts,function(v)return(#v>0)end)
end

---Turns any path into an absolute one given the CWD and the username
---@param pth string
---@param cwd string
---@param usr string
---@return string
function path.absolute(pth,cwd,usr)
    local parts = path.parts(pth)
    local p = path.parts(cwd)
    local function relovePath()
        for k, part in ipairs(parts) do
            if part == '..' then
                table.remove(p,#p)
            else
                table.insert(p,part)
            end
        end
    end
    if pth:sub(1,1) == '/' then
        p = {}
        relovePath()
        return '/'..path.join(table.unpack(p))
    elseif parts[1] == '~' then
        p = path.parts(path.join('home',usr))
        parts = table.slice(parts,2)
        relovePath()
        return '/'..path.join(table.unpack(p))
    else
        if parts[1] == '.' then
            parts = table.slice(parts,2)
        end
        relovePath()
        return '/'..path.join(table.unpack(p))
    end
end

function path.correct(p)
   return path.join(table.unpack(path.parts(p)))
end