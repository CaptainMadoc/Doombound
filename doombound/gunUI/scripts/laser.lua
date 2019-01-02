module = {
	tRefresh = 0.1
}

function module:init()
    
end

function module:partOffset(s, e, off)
	local angle = vec2.angle(vec2.sub(e, s))
	local e2 = vec2.add(vec2.rotate(e, -angle), off)
	return vec2.rotate(e2, angle)
end

function module:cb(s, e)
	local c = world.lineCollision(vec2.add(activeItemAnimation.ownerPosition(), activeItemAnimation.handPosition(s)), vec2.add(activeItemAnimation.ownerPosition(), activeItemAnimation.handPosition(e)))
	
	if not c then
		return activeItemAnimation.handPosition(e)
	end
	return vec2.sub(c,activeItemAnimation.ownerPosition())
end

function module:update(dt)
	self.tRefresh = math.max(self.tRefresh - dt, 0)
	if self.tRefresh then
		self.l = animationConfig.animationParameter("laser")
		self.tRefresh = 5
	end


    if self.l then
	    for i,v in pairs(self.l) do
	    	local start = animationConfig.partPoint(i, v.tag)
			local e = animationConfig.partPoint(i, v.tagEnd)

			local laserColor2 = copycat(v.laserColor)
			laserColor2[1] = math.floor(laserColor2[1] * 0.5)
			laserColor2[2] = math.floor(laserColor2[2] * 0.5)
			laserColor2[3] = math.floor(laserColor2[3] * 0.5)
			laserColor2[4] = math.floor((laserColor2[4] or 255) * 0.5)

	    	localAnimator.addDrawable(
	    		{
	    			width = 1, 
	    			position = activeItemAnimation.ownerPosition(),
	    			line = {activeItemAnimation.handPosition(start), self:cb(start, self:partOffset(start, e, {50,0}))},
	    			color = laserColor2,
	    			fullbright = true
	    		}
			)
			
	    	localAnimator.addDrawable(
	    		{
	    			width = 0.25, 
	    			position = activeItemAnimation.ownerPosition(),
	    			line = {activeItemAnimation.handPosition(start), self:cb(start, self:partOffset(start, e, {50,0}))},
	    			color = v.laserColor,
	    			fullbright = true
	    		}
	    	)
        end
    end
end

function module:uninit()

end