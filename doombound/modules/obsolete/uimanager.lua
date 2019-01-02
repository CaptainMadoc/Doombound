--obsolete

uimanager = {}

function uimanager:init()
end

function uimanager:lateinit()
	local uiShell =  config.getParameter("uiShell")
	if uiShell then
		activeItem.setScriptedAnimationParameter("uiShell", vDir(uiShell, selfItem.rootDirectory))
		
	end
end

function uimanager:update(dt)
	
	activeItem.setScriptedAnimationParameter("load", type(data.gunLoad))
	
	if data.gunLoad and data.gunLoad.parameters.fired then
		activeItem.setScriptedAnimationParameter("fired", true)
	elseif data.gunLoad then
		activeItem.setScriptedAnimationParameter("fired", false)
	end
	
	activeItem.setScriptedAnimationParameter("fireSelect",  gun:fireMode())
	activeItem.setScriptedAnimationParameter("inAccuracy",  gun:inaccuracy())
	activeItem.setScriptedAnimationParameter("althanded",  activeItem.hand() == "alt")
	activeItem.setScriptedAnimationParameter("muzzleDistance",  world.distance(activeItem.ownerAimPosition(),gun:rel(animator.partPoint("gun", "muzzle_begin"))))

end

function uimanager:uninit()
end

addClass("uimanager")