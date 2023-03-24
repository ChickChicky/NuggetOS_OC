function table.includes(tabl,item)
    for _,v in pairs(tabl) do
        if v == item then
            return true
        end
    end
    return false
end

function table.flat(t)
    local nt = {}
    for _,tab in pairs(t) do
        for _,v in pairs(tab) do
            table.insert(nt,v)
        end
    end
    return nt
end

function table.find(t,match)
    local omatch = match;
    if type(match) ~= 'function' then
        match = function(v) return omatch == v end;
    end

    for k,v in pairs(t) do
        if match(v,k) then return v end;
    end
end

function table.indexof(t,match)
    local omatch = match;
    if type(match) ~= 'function' then
        match = function(v) return omatch == v end;
    end

    for k,v in pairs(t) do
        if match(v,k) then return k end;
    end
end

function table.includes(t,match)
    return table.indexof(t,match) ~= nil;
end

function table.filter(t,match)
    local omatch = match;
    if type(match) ~= 'function' then
        match = function(v) return omatch ~= v end;
    end
    local nt = {};
    for k,v in pairs(t) do
        if match(v,k) then nt[k] = v end;
    end
    return nt;
end

function table.ifilter(t,match)
    local omatch = match;
    if type(match) ~= 'function' then
        match = function(v) return omatch ~= v end;
    end
    local nt = {};
    for k,v in pairs(t) do
        if match(v,k) then table.insert(nt, v) end;
    end
    return nt;
end

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

function table.map(t,fn)
    local nt = {};
    for k,v in pairs(t) do
        nt[k] = fn(v,k,t);
    end
    return nt;
end

function table.imap(t,fn)
    local nt = {};
    for i,v in ipairs(t) do
        table.insert(nt, fn(v,i,t));
    end
    return nt;
end

function table.keys(t)
    local keys = {};
    for k in pairs(t) do
        table.insert(keys,k);
    end
    return keys;
end

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

function table.fromstring(str) 
    local tabl = {};
    for c in str:gmatch('.') do
        table.insert(tabl,c);
    end
    return tabl;
end

function table.slice(t,s,e)
    s = s or 1
    e = e or #t
    local nt = {}
    for i = s,e do
        table.insert(nt,t[i])
    end
    return nt
end

function table.from(iterable)
    local t = {}
    for i in iterable do
        table.insert(t,i)
    end
    return t
end