arms = {
	curdirection = 2,
	inited = false,
	twohand_current = false,
	twohand_target = false,
	cropA1 = "?crop=0;0;24;43",
	cropA2 = "?crop=23;0;27;43",
	cropA3 = "?crop=26;0;43;43",
}

function arms:init()
	activeItem.setFrontArmFrame("rotation?scale=0")
	activeItem.setBackArmFrame("rotation?scale=0")
	
	self.current = config.getParameter("twoHanded", true)
	self.target = config.getParameter("twoHanded", true)
	self.twohand = config.getParameter("twoHanded", false)
	
	self.specie = world.entitySpecies(activeItem.ownerEntityId())
	if not self.specie then	return end
	
	--get portraits parts 
	local port = portrait:auto(activeItem.ownerEntityId())
	--get skin directives
	self.directives = portrait:skinDirectives(port)
	
	-- it has front armor
	if port.FrontArmArmor then 
		-- we get the directory of the armor and the directives
		self.directory = portrait:getDirectory(port, "FrontArmArmor")
		self.armordirectives = portrait:getDirectives(port, "FrontArmArmor")
	end
	
	--back armor too
	if port.BackArmArmor then
		self.Bdirectory = portrait:getDirectory(port, "BackArmArmor")
		self.Barmordirectives = portrait:getDirectives(port, "BackArmArmor")
	end
	
	--humanoid config for offsets
	local humanoidConfig = root.assetJson("/humanoid.config")

	--if we have found the species config then we could use his humanoid config
	local speciesConfig = root.assetJson("/species/"..self.specie..".species")
	if speciesConfig.humanoidConfig then
		humanoidConfig = root.assetJson(speciesConfig.humanoidConfig)
	end


	local armSize = vec2.div({43,43}, 8)
	local armCenter = vec2.div(armSize, -2)
	
	--bunch of calculation offset from the humanoid
	local frontArmRotationCenter = vec2.div(humanoidConfig.frontArmRotationCenter, 8)
	local frontArmHandPosition = vec2.div(humanoidConfig.frontHandPosition, -8)
	
	local backArmHandPosition = vec2.div(humanoidConfig.backArmOffset, 8)
	local backArmRotationCenter = vec2.div(humanoidConfig.backArmRotationCenter, 8)
	

	local transformsArm = {
		R_hand = {position = {26 * 0.125, 0}},
		R_arm1 = {},
		R_arm2 = {position = {23 * 0.125, 0}}
	}
	
	--current item animation config
	local configanimation = config.getParameter("animation")
	local animations = {}
	
	if configanimation then
		animations = root.assetJson(itemDir(configanimation), {})
	end
	local animationCustom = config.getParameter("animationCustom", {})
	local animationTranformationGroup = sb.jsonMerge(animations, animationCustom).transformationGroups or {} 
	--

	--fold this if its long
	local createTransform = function ()
		--creating custom transforms for arms 
		transforms:add("R_arm1", sb.jsonMerge({rotation = 0}, animationTranformationGroup.R_arm1.transform or {}),
			function(name,thisTransform, dt) 
				if animator.hasTransformationGroup(name) then --Check to prevent crashing
					local setting  = {
						position = frontArmHandPosition,
						rotationPoint = vec2.add(vec2.sub(frontArmRotationCenter, armCenter), frontArmHandPosition),

						rotation = thisTransform.rotation or 0,

						scale = {1,1},
						scalePoint = {0,0},
					}

					animator.resetTransformationGroup(name) 
					animator.scaleTransformationGroup(name, setting.scale, setting.scalePoint)
					animator.rotateTransformationGroup(name, util.toRadians(setting.rotation), vec2.sub(setting.rotationPoint, setting.position))
					animator.translateTransformationGroup(name, setting.position)
				end
			end
		)

		transforms:add("R_arm2", sb.jsonMerge({rotation = 0}, animationTranformationGroup.R_arm2.transform or {}),
			function(name,thisTransform, dt) 
				if animator.hasTransformationGroup(name) then --Check to prevent crashing
					local setting  = transforms.calculateTransform({
						position = {23 * 0.125,0},
						rotationPoint = {0,17 * 0.125 + 0.0625},

						rotation = thisTransform.rotation or 0,

						scale = {1,1},
						scalePoint = {0,0},
					})

					animator.resetTransformationGroup(name) 
					animator.scaleTransformationGroup(name, setting.scale, setting.scalePoint)
					animator.rotateTransformationGroup(name, util.toRadians(setting.rotation), setting.rotationPoint)
					animator.translateTransformationGroup(name, setting.position)
				end
			end
		)

		transforms:add("R_hand", sb.jsonMerge({rotation = 0}, animationTranformationGroup.R_hand.transform or {}),
			function(name,thisTransform, dt) 
				if animator.hasTransformationGroup(name) then --Check to prevent crashing
					local setting  = transforms.calculateTransform({
						position = {0.375,0},
						rotationPoint = {0.125,18 * 0.125},

						rotation = thisTransform.rotation or 0,

						scale = {1,1},
						scalePoint = {0,0},
					})

					animator.resetTransformationGroup(name) 
					animator.scaleTransformationGroup(name, setting.scale, setting.scalePoint)
					animator.rotateTransformationGroup(name, util.toRadians(setting.rotation), setting.rotationPoint)
					animator.translateTransformationGroup(name, setting.position)
				end
			end
		)

		transforms:add("L_arm1", sb.jsonMerge({rotation = 0}, animationTranformationGroup.L_arm1.transform or {}),
			function(name,thisTransform, dt) 
				if animator.hasTransformationGroup(name) then --Check to prevent crashing
					local setting  = {
						position = frontArmHandPosition,
						rotationPoint = vec2.add(vec2.sub(frontArmRotationCenter, armCenter), frontArmHandPosition),

						rotation = thisTransform.rotation or 0,

						scale = {1,1},
						scalePoint = {0,0},
					}

					animator.resetTransformationGroup(name) 
					animator.scaleTransformationGroup(name, setting.scale, setting.scalePoint)
					animator.rotateTransformationGroup(name, util.toRadians(setting.rotation), vec2.sub(setting.rotationPoint, setting.position))
					animator.translateTransformationGroup(name, setting.position)
				end
			end
		)

		transforms:add("L_arm2", sb.jsonMerge({rotation = 0}, animationTranformationGroup.L_arm2.transform or {}),
			function(name,thisTransform, dt) 
				if animator.hasTransformationGroup(name) then --Check to prevent crashing
					local setting  = transforms.calculateTransform({
						position = {23 * 0.125,0},
						rotationPoint = {0,17 * 0.125 + 0.0625},

						rotation = thisTransform.rotation or 0,

						scale = {1,1},
						scalePoint = {0,0},
					})

					animator.resetTransformationGroup(name) 
					animator.scaleTransformationGroup(name, setting.scale, setting.scalePoint)
					animator.rotateTransformationGroup(name, util.toRadians(setting.rotation), setting.rotationPoint)
					animator.translateTransformationGroup(name, setting.position)
				end
			end
		)

		transforms:add("L_hand", sb.jsonMerge({rotation = 0}, animationTranformationGroup.L_hand.transform or {}),
			function(name,thisTransform, dt) 
				if animator.hasTransformationGroup(name) then --Check to prevent crashing
					local setting  = transforms.calculateTransform({
						position = {0.375,0},
						rotationPoint = {0.125,18 * 0.125},

						rotation = thisTransform.rotation or 0,

						scale = {1,1},
						scalePoint = {0,0},
					})

					animator.resetTransformationGroup(name) 
					animator.scaleTransformationGroup(name, setting.scale, setting.scalePoint)
					animator.rotateTransformationGroup(name, util.toRadians(setting.rotation), setting.rotationPoint)
					animator.translateTransformationGroup(name, setting.position)
				end
			end
		)

		transforms:add("L_offset", sb.jsonMerge({position = {0,0}}, animationTranformationGroup.L_offset.transform or {}),
			function(name,tt, dt) 
				if animator.hasTransformationGroup(name) then --Check to prevent crashing
					animator.resetTransformationGroup(name) 
					animator.translateTransformationGroup(name, tt.position)
				end
			end
		)

		transforms:add("R_offset", sb.jsonMerge({position = {0,0}}, animationTranformationGroup.R_offset.transform or {}),
			function(name,tt, dt) 
				if animator.hasTransformationGroup(name) then --Check to prevent crashing
					animator.resetTransformationGroup(name) 
					animator.translateTransformationGroup(name, tt.position)
				end
			end
		)

		transforms:add("global",sb.jsonMerge({position = armCenter, rotation = 0, rotationPoint = {0,0}}, animationTranformationGroup.global.transform or {}),
			function(name,thisTransform, dt) 
				if animator.hasTransformationGroup(name) then --Check to prevent crashing
					local setting  = transforms.calculateTransform({
						position = thisTransform.position or {0,0},
						scale = thisTransform.scale or {1,1},
						scalePoint = thisTransform.scalePoint or {0,0},
						rotation = thisTransform.rotation or 0,
						rotationPoint = thisTransform.rotationPoint or {0,0}
					})
					
					animator.resetTransformationGroup(name) 
					animator.scaleTransformationGroup(name, setting.scale, setting.scalePoint)
					animator.rotateTransformationGroup(name, util.toRadians(setting.rotation), setting.rotationPoint)
					animator.translateTransformationGroup(name, setting.position)
				end
			end
		)
	end	

	createTransform()
	self.inited = true
end

function arms:lateinit(dt)
end

function arms:update(dt)
	if not self.inited then --failed getting humanoid config retrying
		self:init()
		return
	end
	
	if self.twohand_current ~= self.twohand_target then
		self:setTwoHandedGrip(self.twohand_target)
		self.twohand_current = self.twohand_target
	end
	
	local aim, direction = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())

	--knows to auto switch layers using animation zlevels
	if self.curdirection ~= direction then

		self.curdirection = direction

		local handhold = activeItem.hand()

		if not self.twohand then --non two hand here
			animator.setAnimationState("left", self:whatlayer(direction, handhold))
			animator.setAnimationState("right", self:whatlayer(-direction, handhold))
			self:setFullArm("L", false) -- it will hide it
			self:setFullArm("R", true)
		else
			animator.setAnimationState("left", "back")
			animator.setAnimationState("right", "front")
			self:setFullArm("L", true)
			self:setFullArm("R", true)
		end
	end
end

--util for this module
function arms:flipped(arm, dir)
	if dir > 0 then
		return arm
	end
	if arm == "alt" then
		return "primary"
	else
		return "alt"
	end
end

--util
function arms:whatlayer(dir, arm)
	if arm == "alt" then dir = -dir end

	if dir > 0 then
		return "front"
	else
		return "back"
	end
end


--util dont use
function arms:setArm(side, img, crop)
	if crop then
		animator.setGlobalTag(side.."_a1", img..self.cropA1)
		animator.setGlobalTag(side.."_a2", img..self.cropA2)
		animator.setGlobalTag(side.."_hand", img..self.cropA3)
	else
		animator.setGlobalTag(side.."_a1", img)
		animator.setGlobalTag(side.."_a2", img)
		animator.setGlobalTag(side.."_hand", img)
	end
end

--util
function arms:setArmorArm(side, img, crop)
	if crop then
		animator.setGlobalTag(side.."_af1", img..self.cropA1)
		animator.setGlobalTag(side.."_af2", img..self.cropA2)
		animator.setGlobalTag(side.."_handf", img..self.cropA3)
	else
		animator.setGlobalTag(side.."_af1", img)
		animator.setGlobalTag(side.."_af2", img)
		animator.setGlobalTag(side.."_handf", img)
	end
end

--API--
function arms:setTwoHandedGrip(bool)
	self.twohand = bool
	self.curdirection = -self.curdirection
	activeItem.setTwoHandedGrip(bool)
end

-- side = "back", show = true
function arms:setFullArm(side, show)
	if show then
		self:setArm(side, "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives,true)
		if self.directory and self.armordirectives then
			self:setArmorArm(side, self.directory..":rotation"..self.armordirectives,true)
		else
			self:setArmorArm(side, "",false)
		end
	else
		self:setArm(side, "",false)
		self:setArmorArm(side, "",false)
	end
end

addClass("arms")