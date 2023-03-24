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