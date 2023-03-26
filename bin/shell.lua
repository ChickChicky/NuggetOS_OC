local env = ...

---@type string
local cwd = env.cwd

while true do

    io.write('/'..path.correct(cwd)..' > ')
    local cmd = io.read()

    local parts = string.split(cmd,' ')

    if parts[1] == 'exit' then

        break

    elseif parts[1] == 'cd' then

        local p = path.absolute(parts[2] or '', cwd, '')

        if fs.exists(p) then
            cwd = p
        else
            print('No such file or directory: ',tostring(p))
        end

    else

        xpcall(

            function ()

                local failed = os.execute(
                    parts[1],
                    table.merge(table.pack(env),{cwd=path.correct(cwd)}), -- environment data
                    table.unpack(table.slice(parts,2))
                )
                if failed then
                    eprint('No such command: ' .. parts[1])
                end

            end,

            function (e)
                eprint('Error: '..tostring(e))
            end

        )


    end

    print()

end