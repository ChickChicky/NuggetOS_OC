function sleep( s )

    local start = os.time()
    repeat
        coroutine.yield()
    until os.difftime(os.time(),start) >= s

end

---Executes a program
---@param program string the name/path of the program
---@param env? table the environment in which the command is ran
---@param ... any arguments
---@return nil,...|true
function os.execute(program,env,...)
    env = env or {}
    local variants = {
        program,
        program..'.lua',
        path.join('/bin/',program),
        path.join('/bin/',program..'.lua'),
    }
    for k,v in pairs(variants) do
        if fs.exists(v) then
            return nil,dofile(v,env,...)
        end
    end
    return true
end