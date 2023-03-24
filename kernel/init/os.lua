function sleep( s )

    local start = os.time()
    repeat
        coroutine.yield()
    until os.difftime(os.time(),start) >= s

end

function os.execute()

end