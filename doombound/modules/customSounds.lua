customSounds = {
    soundInt = 1,
    noWarn = false
}

--[[
    var = {
        sound = "path",
        volume = 1,
        pitch = 1,
        position = {0,0}
    }
]]

--plays queued sounds onto the animator. returns the queued sound name
function customSounds:play(var)
    local varType = type(var)

    if varType == "table" then

        --if you've gotten this. its probably reseting.
        if not animator.hasSound("customSound_"..self.soundInt) then

            -- if you've gotten this. this is probably a bad queue setup
            if self.soundInt == 1 and not self.noWarn then
                sb.logWarn("self.soundInt = 1 -- this means customSound_1 is not set properly")
                self.noWarn = true
                return
            end

            self.soundInt = 1
        end


        local soundTarget = "customSound_"..self.soundInt
        
        local ft = type(var.sound)
        if ft == "table" then
            animator.setSoundPool(soundTarget, var.sound)
        else
            animator.setSoundPool(soundTarget, {var.sound or "/assetmissing.wav"})
        end

        animator.setSoundVolume(soundTarget, var.volume or 1, var.volumeRampTime or 0.0)
        animator.setSoundPitch(soundTarget, var.pitch or 1, var.pitchRampTime or 0.0)
        animator.setSoundPosition(soundTarget, var.position or {0,0})

        self.soundInt = self.soundInt + 1

        animator.playSound(soundTarget)

        return soundTarget
    elseif varType == "string" then
        self:play({sound = var})
    end

end