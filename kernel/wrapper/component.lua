local _types = {}

for addr,ctype in component.list() do
    if not table.includes(_types,ctype) then
        table.insert(_types,ctype)
        component[ctype] = component.proxy(addr);
    end
end