aim = {
	current = 0,
	target = 0, --to lerp
	direction = 1, --facing
	disabled = false,
	anglesmooth = 1,
	armoffset = 0
}

function aim:lerp(value, to, speed)
	return value + ((to - value ) / speed ) 
end

function aim:gbDebug()
	if _GBDEBUG then
		_GBDEBUG:newTestUnit("aim:disable()", function() self.disabled = true end)
		_GBDEBUG:newTestUnit("aim:enable()", function() self.disabled = false end)
	end
end

function aim:init()
	message.setHandler("disableAim", function(_, loc) if loc then self.disabled = true end end)
	message.setHandler("enableAim", function(_, loc) if loc then self.disabled = false end end)
	self:gbDebug()
end

function aim:update(dt)
	if self.disabled then
		activeItem.setArmAngle(0)
		self.current = 0
		return
	end
	
	self.current = lerp(self.current, self.target, math.max(self.anglesmooth / (dt * 60), 1)) --smoothing aim
	activeItem.setArmAngle(math.rad(self.current + self.armoffset)) --applies aiming
	activeItem.setFacingDirection(self.direction)
end

addClass("aim")