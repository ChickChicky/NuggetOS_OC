local _beep = computer.beep

function computer.beep(freq,dur)
    
    if type(freq) == 'string' then
        for c in freq:gmatch('.') do

            local l = 0
            if c == '.' then
                l = 0.2
            elseif c == '_' then
                l = 0.6
            end

            if c == ' ' then
                --sleep(0.1)
                _beep(20,0.1)
            else
                _beep(1000,l)
            end

        end
    else
        _beep(freq,dur)
    end

end