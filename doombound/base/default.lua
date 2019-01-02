--This is a script used by default.
--You can use this as reference if you want to make a custom type weapon.

main = {
    fireQueued = 0,
    reloadLoop = false,
    semifired = false
}

--Callbacks 

--this should be his initial startup
function main:init()
    
	animation:addEvent("reload_loop", function() self.reloadLoop = true end)
	animation:addEvent("reloadLoop", function() self.reloadLoop = true end)
    --initial weapon animation
    self:animate("draw")

end

--this is called when a firemode is fired
function main:activate(fireMode, shiftHeld)
    if fireMode == "alt" and not shiftHeld then --this is for special binded attachments
        attachmentSystem:triggerSpecial()
    elseif fireMode == "alt" and shiftHeld then --this is for switching firemodes
        gun:switchFireModes()
    end
end

--every ticks (frames)
function main:update(dt, fireMode, shiftHeld, moves)
    if not self.reloadLoop then --makes sure that our frontend script is not busy reloading shells
        self:updateAutoReload()
        self:updateFire(fireMode) 
        self:updateQueuedFire(fireMode) 
        self:updateSpecial(shiftHeld, moves.up)
    else
        if not animation:isAnyPlaying() then
            if not magazine:playerHasAmmo() or magazine:count() == magazine.size then
                self.reloadLoop = false
                self:animate(gun.animations["reloadEnd"])
            else
                self:animate(gun.animations["reloadLoop"])
            end
        end
    end
    
end

--this is after init (next frame)
function main:lateinit()
end

--this is called when the lua state is being destroyed
function main:uninit()
end


--OTHER FUNCTIONS

--We made this so we dont deal with manually shoot + _dry animations
function main:animate(type,noprefix)
    if not noprefix and 
        (gun:chamberDry() and (not gun.hasToLoad and not data.bypassShellEject))
        then
		animation:play(gun.animations[type.."_dry"] or gun.animations[type] or type.."_dry")
	else
		animation:play(gun.animations[type] or type)
    end
end

--Fire implementation
function main:fire()
    if not animation:isAnyPlaying() or animation:isPlaying({gun.animations["shoot"], gun.animations["shoot_dry"]}) then
        local status = gun:fire()
        if status then
            self:animate("shoot")
        else
            self:animate("shoot_null", true)
        end
    end
end

--Specials like reload or lever switches stuff and things
function main:updateSpecial(shift, up)
    if shift and up and not animation:isAnyPlaying() then
        self:animate("reload")
    end
    if not shift and up and not animation:isAnyPlaying() then
        self:animate("cock")
    end
end

--we use this for deal with gun common firemodes.
function main:updateFire(firemode)

    
    if firemode == "primary" and gun:ready() and not self.semifired then-- primary mouse click event for firemodes
        local gunFireMode = gun:fireMode() -- we get his firemode
        if gunFireMode == "burst" and self.fireQueued == 0 then --if burst we get to queue shots
            self.fireQueued = gun.stats.burst or 3
        elseif gunFireMode == "semi" then --if semi we fire and lock this part of the function so we dont go full auto
            self:fire()
            self.semifired = true
        elseif gunFireMode == "auto" then --if auto we fire and keep on
            self:fire()
        end
    elseif firemode ~= "primary" and self.semifired then --unlocks the semi lock when mouse fire is not pressed
        self.semifired = false
    end

end

-- our queued burst fires
function main:updateQueuedFire()

    if self.fireQueued > 0 and gun:ready() and not gun:chamberDry() then
        local fireStatus = self:fire()
        if magazine:count() == 0 then
            self.fireQueued = 0
        else
            self.fireQueued = self.fireQueued - 1
        end
        if self.fireQueued == 0 then
            gun.cooldown = gun:rpm() * 4
        end
    end

end

--do not use this i think we have the auto chamber load from the internal
--function main:updateChamber()
--    if gun:ready() and gun:chamberDry() and magazine:count() > 0 and (not animation:isAnyPlaying() or animation:isPlaying({gun.animations["shoot_dry"], gun.animations["shoot"]}) ) then
--        gun:load_chamber()
--    end
--end

--smart automatic reload 
function main:updateAutoReload()
    if gun:ready() then
        if (gun:chamberDry() or (data.gunLoad and data.gunLoad.parameters.fired)) and magazine:count() == 0 and magazine:playerHasAmmo() and  not animation:isAnyPlaying() then
            self:animate("reload")
        elseif gun:chamberDry() and magazine:count() > 0 and not animation:isAnyPlaying() then
            self:animate("cock")
        end
    end
end