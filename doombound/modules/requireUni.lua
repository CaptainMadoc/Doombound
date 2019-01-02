--this is a enhanced version of starbound require function
requireUni = {
    loaded = {}
}

function requireUni:load(str, name) --str [script path], name [variables [module by default]]
    if self.loaded[str] then
        return self.loaded[str]
    end
    local temp
    if _ENV[name or "module"] then
        temp = _ENV[name or "module"]
    end
    require(str)
    if _ENV[name or "module"] then
        self.loaded[str] = _ENV[name or module]
        _ENV[name or "module"] = nil
    end
    if temp then
        _ENV[name or "module"] = temp
    end
    return self.loaded[str]
end
