module = {
    configPath = nil,
    config = {},
    modules = {}
}

function module:init()
    self.config = root.assetJson(lp(self.configPath), {})
    for i,v in pairs(self.config.scripts or {}) do
        self.modules[i] = loadModule(lp(v))
    end
    for i,v in pairs(self.modules) do
        if v.init then
            self.modules[i]:init()
        end
    end
end

function module:update(dt)
    for i,v in pairs(self.modules) do
        if v.update then
            self.modules[i]:update(dt)
        end
    end
end

function module:uninit()
    for i,v in pairs(self.modules) do
        if v.uninit then
            self.modules[i]:uninit(dt)
        end
    end
end