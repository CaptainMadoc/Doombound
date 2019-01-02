module = {
	tRefresh = 0.1,
}

function module:init()
    
end

function module:update(dt)
	self.tRefresh = math.max(self.tRefresh - dt, 0)
	if self.tRefresh then
		self.f = animationConfig.animationParameter("flashlight")
		self.tRefresh = 5
	end

    if self.f then
		for i,v in pairs(self.f) do
			local start = animationConfig.partPoint(i, v.tag)
			local e = animationConfig.partPoint(i, v.tagEnd)
			localAnimator.addLightSource(
				{
					position = vec2.add(activeItemAnimation.ownerPosition(), activeItemAnimation.handPosition(start)),
					color = v.lightColor,
					pointLight = true,
					pointBeam = 6,
					beamAngle = vec2.angle(vec2.sub(activeItemAnimation.handPosition(e), activeItemAnimation.handPosition(start)))
				}
			)
		end
    end
end

function module:uninit()

end