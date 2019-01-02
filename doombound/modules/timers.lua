timers = {
    list = {

    }
}

function timers:check(name, looptime) --def for timer loop time
    if not self.list[name] and looptime then
        self.list[name] = os.clock() + looptime
        return false
    end

    if self.list[name] < os.clock() then
        if looptime then 
            self.list[name] = os.clock + looptime
        end
        
        return true
    end

    return false
end

function timers:set(name, time)
    self.list[name] = os.clock() + time
end

function timers:init()

end

function timers:update(dt)
    
end

function timers:uninit()

end


addClass("timers")