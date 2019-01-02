
_LOADEDMODULES = {

}

function loadModule(path)
    local someETC = false -- for cheeky script that use 'module' table name for no absolute reason

    if _LOADEDMODULES[path] then
        return copycat(_LOADEDMODULES[path])
    else
        if module then -- cheeky
            someETC = module
            module = nil
        end

        require(path)
        if module then      _LOADEDMODULES[path] = module module = nil end
        if someETC then     module = someETC end
        if _LOADEDMODULES[path] then    return copycat(_LOADEDMODULES[path]) end
        return
    end
end