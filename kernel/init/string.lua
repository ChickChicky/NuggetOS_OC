function string:chunks(size)
    local chunks = {};
    local chunk = "";
    for c in self:gmatch('.') do
        chunk = chunk..c;
        if #chunk == size then
            table.insert(chunks,chunk);
            chunk = "";
        end
    end
    return chunks;
end

function string:split(sep)
    local split = {}
    local s = ''
    for c in self:gmatch('.') do
        if c == sep then
            table.insert(split,s)
            s = ''
        else
            s = s..c
        end
    end
    table.insert(split,s)
    return split
end

---@class string
---@operator mod(any|any[]):string
---@operator add(any):string

-- No operator overloading, I guess...

--local stringmt = getmetatable("")

--[[function stringmt.__add(s,other)
    return s..tostring(other)
end

--- String formatting
--- ```
--- print("Hello, {} !" % "world")
--- --> "Hello, world !"
---  
--- print("Hello, {name} !" % {name="world"})
--- --> "Hello, world !"
--- ```
--- @param s string
--- @param other any|any[]
--- function stringmt.__mod(s,other)
function string.format(s,other)
    if type(other) ~= 'table' then
        other = {other}
    end
    local matches = {}
    local org = 0
    while true do
        local ms,me = s:find('{%a*}',org)
        if not ms then break end
        table.insert(matches,{ms,me})
        org = me
    end
    local shift = 0
    local k = 0
    local function n() k = k+1 return k end
    for i,match in pairs(matches) do
        local pl = #s
        local p0 = match[1] + shift
        local p1 = match[2] + shift
        local key = s:sub(p0+1,p1-1)
        s = s:sub(1,p0-1) .. tostring(#key and (key:match('^%d+$') and other[tonumber(key)] or other[key]) or other[n()]) .. s:sub(p1+1)
        shift = shift + #s-pl
    end
    return s
end]]