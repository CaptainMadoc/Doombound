flashlight = {
	out = {}
}


function flashlight:add(part, tag, tagEnd, lc)
	self.out[part] = {tag = tag, tagEnd = tagEnd, lightColor = lc or {255,255,255,128}}
	activeItem.setScriptedAnimationParameter("flashlight",  self.out)
end

function flashlight:init()
	activeItem.setScriptedAnimationParameter("flashlight",  {})
end

function flashlight:update(dt)
end

function flashlight:uninit()
end

addClass("flashlight")