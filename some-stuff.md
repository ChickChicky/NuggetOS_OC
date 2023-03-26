# Lua additions

## Tables
```lua
-- flat
for k,v in pairs( table.flat( {{'a','b'},{'c','d'}} ) ) do
    print(k,v)
end
--> 1   a
--> 2   b
--> 3   c
--> 4   d

-- find
print( 
    table.find( 
        {1,30,5,34,21}, 
        function (v,k,t)
            -- v : the current value
            -- k : the current value's key
            -- t : the table
            return v > 30
        end
    ) 
)
--> 34

-- keyof
print( 
    table.keyof( 
        {1,30,5,34,21},
        function (v)
            return v > 30
        end
    )
)
--> 4
```