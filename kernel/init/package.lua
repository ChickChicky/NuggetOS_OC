local _path = {
    '/kernel/',
    '/bin/',
    '/lib/'
}

local _loaded = {}

function require(name)


    if _loaded[name] ~= nil then
        return _loaded[name]
    end

    for _,p in pairs(_path) do
        local path = p..name
        if fs.exists(path) then
            _loaded[name] = dofile(path)
            return _loaded[name]
        end
    end

end