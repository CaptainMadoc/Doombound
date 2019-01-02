laser = {
	out = {}
}

function laser:init()
	activeItem.setScriptedAnimationParameter("laser",  {})
end

function laser:update(dt)
end

function laser:uninit()
end

function laser:add(part, tag, tagEnd, lc)
	self.out[part] = {tag = tag, tagEnd = tagEnd, laserColor = lc or {255,255,255,127}}
	activeItem.setScriptedAnimationParameter("laser",  self.out)
end

addClass("laser")