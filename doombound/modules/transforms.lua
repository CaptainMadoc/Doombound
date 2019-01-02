

transforms = {
	updateChild = {},
	lateUpdateChild = {},

	original = {}, --this should NEVER be changed by other functions
	current = {},
}

--some api adding
function vec2.lerpR(a,b,r)
	return {
		a[1] + (b[1] - a[1]) * r[1],
		a[2] + (b[2] - a[2]) * r[2]	
	}
end


--do not use this

function transforms.calculateTransform(tab)
		local new = {
			scale = tab.scale or {1,1},
			scalePoint = tab.scalePoint or {0,0},
			position = vec2.mul(tab.position or {0,0}, tab.scale or {1,1}),
			rotation = tab.rotation or 0,
			rotationPoint = vec2.lerpR(tab.scalePoint, tab.rotationPoint, tab.scale)
		}
		return new
end

function transforms:loadTransforms()
		local configanimation = config.getParameter("animation")
		local animations = {}
		
		if configanimation then
			animations = root.assetJson(itemDir(configanimation), {})
		end
		local animationCustom = config.getParameter("animationCustom", {})
		local animationTranformationGroup = sb.jsonMerge(animationCustom, animations).transformationGroups or {} 
		
		for i,v in pairs(animationTranformationGroup) do
			if not v.ignore then
				local newtrans = {position = {0,0}, scale = {1,1}, scalePoint = {0,0}, rotation = 0, rotationPoint = {0,0}}
				if v.transform then
					newtrans = sb.jsonMerge(newtrans, v.transform)
				end
				self:add(i, newtrans,
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
		end
end

function transforms:init()
	transforms:loadTransforms()
	message.setHandler("getTransforms", function(_, loc, ...) if loc then return self.original end end)
	self:update(1/62)
end

function transforms:update(dt)
	for i,v in pairs(self.current) do
		if type(self.updateChild[i]) == "function" then
			self.updateChild[i](i, v, dt)
		end
	end
end

function transforms:lateUpdate(dt)
	for i,v in pairs(self.current) do
		if type(self.lateUpdateChild[i]) == "function" then
			self.lateUpdateChild[i](i, v, dt)
		end
	end
end

--creates a new transform with a function that updates it.
function transforms:add(name,tr,updatefunc)
	self.original[name] = copycat(tr)
	self.updateChild[name] = updatefunc
end

function transforms:lateAdd(name,tr,updatefunc)
	self.original[name] = copycat(tr)
	self.lateUpdateChild[name] = updatefunc
end
--this apply the transforms in the list. the ones that are not in the apply list will be filled with the original.
function transforms:apply(name, tr)
	if self.original[name] then
		self.current[name] = sb.jsonMerge(copycat(self.original[name]), tr)
	end
end


addClass("transforms")