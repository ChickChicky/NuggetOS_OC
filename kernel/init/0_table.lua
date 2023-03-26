---Flattens a table
---@param t table
---@return table
function table.flat(t)
    local nt = {}
    for _,tab in pairs(t) do
        for _,v in pairs(tab) do
            table.insert(nt,v)
        end
    end
    return nt
end

---Finds an item in a table
---@param t table
---@param match any|function
---@return any?
function table.find(t,match)
    local omatch = match;
    if type(match) ~= 'function' then
        match = function(v) return omatch == v end;
    end

    for k,v in pairs(t) do
        if match(v,k,t) then return v end;
    end
end

---Returns the key of the first item satisfying the provided `match` value
---@param t table
---@param match any|function
---@return any?
function table.keyof(t,match)
    local omatch = match;
    if type(match) ~= 'function' then
        match = function(v) return omatch == v end;
    end

    for k,v in pairs(t) do
        if match(v,k,t) then return k end;
    end
end

---Returns whether a table contains en element corresponding to the provided `match` value
---@param t table
---@param match any|function
---@return boolean
function table.includes(t,match)
    return table.keyof(t,match) ~= nil;
end

---Returns a table containing only the elements satisfying the `match` value
---@param t table
---@param match any|function
---@return table
function table.filter(t,match)
    local omatch = match;
    if type(match) ~= 'function' then
        match = function(v) return omatch ~= v end;
    end
    local nt = {};
    for k,v in pairs(t) do
        if match(v,k,t) then nt[k] = v end;
    end
    return nt;
end

---Returns a table containing only the elements satisfying the `match` value
---@param t table
---@param match any|function
---@return table
function table.ifilter(t,match)
    local omatch = match;
    if type(match) ~= 'function' then
        match = function(v) return omatch ~= v end;
    end
    local nt = {};
    for k,v in pairs(t) do
        if match(v,k,t) then table.insert(nt, v) end;
    end
    return nt;
end

---...
---@param t table
---@return table
function table.ishift(t)
    local m = t[1] or 1;
    for k,_ in pairs(t) do
        m = math.min(m,k);
    end
    local nt = {};
    for k,v in pairs(t) do
        nt[k-m+1] = v;
    end
    return nt;
end

---Maps a function to all items in a table
---@param t table
---@param fn function
---@return table
function table.map(t,fn)
    local nt = {};
    for k,v in pairs(t) do
        nt[k] = fn(v,k,t);
    end
    return nt;
end

---Maps a function to all items in a table
---@param t table
---@param fn function
---@return table
function table.imap(t,fn)
    local nt = {};
    for i,v in ipairs(t) do
        table.insert(nt, fn(v,i,t));
    end
    return nt;
end

---Returns a table containing only the keys of the provided table
---@param t table
---@return table
function table.keys(t)
    local keys = {};
    for k in pairs(t) do
        table.insert(keys,k);
    end
    return keys;
end

---Returns a table that has been split in to chunks of equal size
---@param t table
---@param size number
---@return table
function table.chunks(t,size)
    local chunks = {};
    local chunk = {};
    for _,item in ipairs(t) do
        table.insert(chunk, item);
        if #chunk == size then
            table.insert(chunks,chunk);
            chunk = {};
        end
    end
    return chunks;
end

---Creates a table from the characters in a string
---@param str string
---@return table
function table.fromstring(str)
    local tabl = {};
    for c in str:gmatch('.') do
        table.insert(tabl,c);
    end
    return tabl;
end

---Creates a table containing only items from `s` to `e`
---@param t table
---@param s? number
---@param e? number
---@return table
function table.slice(t,s,e)
    s = s or 1
    e = e or #t
    local nt = {}
    for i = s,e do
        table.insert(nt,t[i])
    end
    return nt
end

---Creates a table from an iterable
---@param iterable function
---@return table
function table.from(iterable)
    local t = {}
    for i in iterable do
        table.insert(t,i)
    end
    return t
end

---Creates a nex table containing all the items of both table combined
---@param t table
---@param u table
---@return table
function table.imerge(t,u)
    local nt = {}
    for k,v in ipairs(t) do
        table.insert(nt,v)
    end
    for k,v in ipairs(u) do
        table.insert(nt,v)
    end
    return nt
end

function table.merge(t,u)
    local nt = {}
    for k,v in pairs(t) do
        nt[k] = v
    end
    for k,v in pairs(u) do
        nt[k] = v
    end
    return nt
end

function table.shallowclone(t)
    local nt = {}
    for k,v in pairs(t) do
        nt[k] = v
    end
    return nt
end

function table.nn(t)
    local nt = {}
    for k,v in pairs(t) do
        if k ~= 'n' then
            nt[k] = v
        end
    end
    return nt
end