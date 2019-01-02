--This is a script used by default.
--You can use this as reference if you want to make a custom type weapon.

main = {
    fireQueued = 0,
    semifired = false
}

--Callbacks 

--this should be his initial startup
function main:init()
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
    self:updateLoadAmmo()
    self:updateFire(fireMode) 
    self:updateQueuedFire(fireMode) 
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

function main:updateLoadAmmo()
    if magazine:count() == 0 and magazine:playerHasAmmo() and gun:chamberDry() then
        magazine:insert(1)
    else
        if gun:chamberDry() and gun:ready() then
            gun:load_chamber(magazine:take())
        end
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
