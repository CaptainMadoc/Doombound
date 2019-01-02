--this is a thing for a ui to test our current apis so, do not use this

_GBDEBUG = {
    enabled = false,
    units = {}, -- _GBDEBUG:newTestUnit("unitname", function() end)
    point = {}, -- _GBDEBUG.point[sb.makeUuid] = {0,0}
    lines = {}, -- _GBDEBUG.lines[sb.makeUuid] = {a = BeginPos, b = EndPos}
    texts = {}, -- _GBDEBUG.texts[sb.makeUuid] = {text = "str", position = {0,0}}
}


-- API: creates a test unit
function _GBDEBUG:newTestUnit(name, func)
    self.units[name] = func
end

-- get all test units
function _GBDEBUG:getTestUnits() -- gets a list of strings to be available
    local list = {}
    for i,v in pairs(self.units) do
        table.insert(list, i)
    end
    return list
end

-- test a unit test
function _GBDEBUG:callTestUnit(name)
    if type(self.units[name]) == "function" then
        return self.units[name]()
    end
    return
end

-- local client msg handler
function _GBDEBUG:createLocMsg(name, func)
    message.setHandler(name, 
        function(_, loc, ...)
            if not loc then return end
            return func(...)
        end
    )
end

function _GBDEBUG:init()
    self:createLocMsg("gbDebugCall", function(name) return self:callTestUnit(name) end)
    self:createLocMsg("gbDebugGetUnits", function() return self:getTestUnits()  end)
end

addClass("_GBDEBUG")