data = {} -- needed
dataManager = {
    savelist = {

    }
}

function dataManager:load(name, autosave, tabdef)
    data[name] = config.getParameter(name)
    if type(tabdef) == "table" and type(data[name]) == "table" then
        data[name] = sb.jsonMerge(tabdef, data[name])
    elseif not data[name] then -- fail safe
        data[name] = tabdef
        autosave = false
    end
    
    if autosave then
        table.insert(self.savelist, name)
    end
end

function dataManager:save(name)
    activeItem.setInstanceValue(name, data[name])
end

function dataManager:uninit()
    for i,v in pairs(self.savelist) do
        self:save(v)
    end
end

addClass("dataManager")