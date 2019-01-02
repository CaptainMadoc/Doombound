--obsolete do not use this anymore
	
weapon = {
	global = {autoReload = true},

	recoil = 0,
	recoilCamera = {0,0},
	delay = 0.5,

	burstDelay = 0.4,
	stats = {
		damageMultiplier = 2,
		maxMagazine = 30,
		aimLookRatio = 0.125,
		burst = 3,
		recoil = 4,
		recoilRecovery = 2,
		movingInaccuracy = 5,
		standingInaccuracy = 1,
		crouchInaccuracyMultiplier = 0.25,
		muzzleFlash = 1,
		rpm = 600
	},

	load = nil,
	animations = {}, --animation Names

	muzzlePosition = {part = "gun", tag = "muzzle_begin", tag_end = "muzzle_end"},
	--casing = {},

	reloadInterrupt = false,
	reloadLoop = false,
	burstCount = 0,
	fireSelect = 1,
	bypassShellEject = false,
	casingFX = true,
}

--why 2
function weapon:lerp(value, to, speed) return value + ((to - value ) / speed )  end
function weapon:lerpr(value, to, ratio) return value + ((to - value ) * ratio ) end

--eject casing
function weapon:casingPosition()
	local offset = {0,0}
	if self.casingConfig then
		offset = animator.partPoint(self.casingConfig.part, self.casingConfig.tag)
	end
	return vec2.add(mcontroller.position(), activeItem.handPosition(offset))
end

--quick calculation from arm offset
function weapon:rel(pos)
	return vec2.add(mcontroller.position(), activeItem.handPosition(pos))
end

--bug repellent
function weapon:debug(dt)
	world.debugPoint(self:rel(animator.partPoint(self.muzzlePosition.part, self.muzzlePosition.tag)), "green")
	world.debugPoint(self:rel(animator.partPoint(self.muzzlePosition.part, self.muzzlePosition.tag_end)), "red")
	world.debugPoint(self:casingPosition(), "yellow")
	world.debugLine(self:rel(animator.partPoint(self.muzzlePosition.part, self.muzzlePosition.tag)),self:rel(self:calculateInAccuracy(animator.partPoint(self.muzzlePosition.part, self.muzzlePosition.tag_end))), "red")
end

--
function weapon:calculateRPM(r)
	return 60 / r
end

--value for spread butter 
function weapon:getInAccuracy()
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = self.stats.crouchInaccuracyMultiplier
	end
	local velocity = whichhigh(math.abs(mcontroller.xVelocity()), math.abs(mcontroller.yVelocity() + 1.28))
	local percent = math.min(velocity / 14, 1)
	return self:lerpr(self.stats.standingInaccuracy, self.stats.movingInaccuracy, percent) * crouchMult
end

--Angle from muzzle parttag
function weapon:angle()
	return vec2.sub(self:rel(animator.partPoint(self.muzzlePosition.part, self.muzzlePosition.tag_end)),self:rel(animator.partPoint(self.muzzlePosition.part, self.muzzlePosition.tag)))
end

--angle calculation thingthatdoesthings
function weapon:calculateInAccuracy(pos)
	local angle = (math.random(0,2000) - 1000) / 1000
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = self.stats.crouchInaccuracyMultiplier
	end
	if not pos then
		return math.rad((angle * self:getInAccuracy()))
	end
	return vec2.rotate(pos, math.rad((angle * self:getInAccuracy())))
end

--ultimate function (requires explaining)
function weapon:fire()
	if self.load and not self.load.parameters.fired then -- self.load must be a valid bullet without a parameter fired as true

		local newConfig = root.itemConfig({name = self.load.name, count = 1, parameters = self.load.parameters})
		
		if not newConfig then self:eject_ammo() return end

		self.load.parameters = sb.jsonMerge(newConfig.config, newConfig.parameters)

		local finalProjectileConfig = self.load.parameters.projectileConfig or {}
		if not finalProjectileConfig.power then
			finalProjectileConfig.power = (root.projectileConfig(self.load.parameters.projectile or "bullet-4").power or 5.0) * (self.stats.damageMultiplier or 1.0)
		end

		for i=1,self.load.parameters.projectileCount or 1 do
			world.spawnProjectile(
				self.load.parameters.projectile or "bullet-4", 
				self:rel(animator.partPoint(self.muzzlePosition.part, self.muzzlePosition.tag)), 
				activeItem.ownerEntityId(), 
				self:calculateInAccuracy(self:angle()), 
				false,
				finalProjectileConfig
			)
		end
		self.load.parameters.fired = true
		
		--used by action lever style
		if not self.bypassShellEject then
			self:eject_ammo()
			self.hasToLoad = true
		end
		
		--
		if magazine:count() == 0 then
			animation:play(self.animations["shoot_dry"] or self.animations.shoot)
		else
			animation:play(self.animations.shoot)
		end
		
		--emits FX muzzle flash sometimes changed by a silencer/flash hider
		if self.stats.muzzleFlash == 1 then
			animator.setAnimationState("firing", "on")
		end

		animator.playSound("fireSounds")
		self.delay = self:calculateRPM(self.stats.rpm or 600)
		self.recoil = self.recoil + self.stats.recoil
		self.recoilCamera = {math.sin(math.rad(self.recoil * 80)) * ((self.recoil / 8) ^ 1.25), self.recoil / 8}

		activeItem.setInstanceValue("gunLoad", self.load)
	else --else plays a dry sound
		animator.playSound("dry")
		if not animation:isAnyPlaying() then
			animation:play(self.animations.shoot_null)
		end
		self.delay = self:calculateRPM(self.stats.rpm or 600)
	end
end

--removes ammo from chamber
function weapon:eject_ammo()
	if self.load then
		if not self.load.parameters.fired then
			player.giveItem(self.load)
		elseif self.load.parameters.casingProjectile and self.casingFX then
			world.spawnProjectile(
				self.load.parameters.casingProjectile, 
				self:casingPosition(), 
				activeItem.ownerEntityId(), 
				vec2.rotate({0,1}, math.rad(math.random(90) - 45)), 
				false,
				self.load.parameters.casingProjectileConfig or {speed = 10, timeToLive = 1}
			)
		end
		self.load = nil
		activeItem.setInstanceValue("gunLoad", self.load)
	end
	if magazine:count() == 0 then
		animation:play(self.animations.dry)
	end
end

--loads ammo into mag
function weapon:load_ammo()
	self.load = magazine:take()
	activeItem.setInstanceValue("gunLoad", self.load)
end

--check if chamber is dry
function weapon:isDry()
	return (not self.load and magazine:count() == 0)
end

--use for people who rely on auto reload
function weapon:shouldAutoReload()
	if not self.global.autoReload then
		return false
	end
	if self.load and not self.load.parameters.fired then
		return false
	end
	if magazine:count() > 0 then
		for i,v in pairs(magazine.storage) do
			if v.parameters and not v.parameters.fired then
				return false
			end
		end
	end
	return true and self.global.autoReload
end



--framework api callback--

function weapon:init()
	message.setHandler("isLocal", function(_, loc) return loc end )
	activeItem.setScriptedAnimationParameter("entityID", activeItem.ownerEntityId())
	activeItem.setCursor("/doombound/crosshair/crosshair2.cursor")

	self.fireSounds = config.getParameter("fireSounds",jarray())
	for i,v in pairs(self.fireSounds) do
		self.fireSounds[i] = processDirectory(v)
	end

	local defStats = copycat(self.stats)
	self.stats = default(config.getParameter("gunStats", self.stats), defStats)

	self.load = config.getParameter("gunLoad")
	self.burstDelay = config.getParameter("burstCooldown", self.burstDelay)
	self.fireTypes = config.getParameter("fireTypes", self.fireTypes)
	self.animations = config.getParameter("gunAnimations")
	self.bypassShellEject = config.getParameter("bypassShellEject", self.bypassShellEject)
	self.casingFX = config.getParameter("casingFX", self.casingFX)
	self.muzzlePosition = config.getParameter("muzzlePosition", self.muzzlePosition)
	self.casingConfig = config.getParameter("casing")

	animator.setSoundPool("fireSounds", self.fireSounds)
	animation:addEvent("eject_ammo", function() self:eject_ammo() end)
	animation:addEvent("load_ammo", function() self:load_ammo() end)
	animation:addEvent("reload_loop", function() self.reloadLoop = true end)
	animation:addEvent("reloadLoop", function() self.reloadLoop = true end)
end

function weapon:lateinit()
	if weapon:isDry() and self.animations["draw_dry"] then
		animation:play(self.animations["draw_dry"])
	else
		animation:play(self.animations.draw or "draw")
	end
end

function weapon:activate(fireMode, shiftHeld)
	if shiftHeld and fireMode == "alt" then
		self.fireSelect = self.fireSelect + 1
		animator.playSound("dry")
		if #self.fireTypes < self.fireSelect then
			self.fireSelect = 1
		end
	end
end


function weapon:update(dt)

	--reload when the gun chamber is dry
	if (updateInfo.shiftHeld and updateInfo.moves.up and not self.reloadLoop and not animation:isAnyPlaying() and magazine:playerHasAmmo()) or 
	   (self:shouldAutoReload() and not animation:isAnyPlaying() and not self.reloadLoop and magazine:playerHasAmmo() and self.delay == 0) then
		
		if self:isDry() and self.animations["reload_dry"] then
			animation:play(self.animations["reload_dry"])
		else
			animation:play(self.animations.reload)
		end
	end
	
	--afterfire when no bullet are present in the magazine or ammo storage
	if (not updateInfo.shiftHeld and updateInfo.moves.up and not self.reloadLoop and not animation:isAnyPlaying())
		or ((not self.load or self.load.parameters.fired) and magazine:count() > 0 and not self.reloadLoop and not animation:isAnyPlaying() and self.global.autoReload and self.delay == 0) then
		if not self.load and self.animations["cock_dry"] then
			animation:play(self.animations["cock_dry"])
		else
			animation:play(self.animations.cock)
		end
	end
	
	--Used in shotgun or single bullet loading type
	if (self.reloadLoop and not animation:isAnyPlaying() and magazine:count() < weapon.stats.maxMagazine and magazine:playerHasAmmo()) and not self.reloadInterrupt then
		if self:isDry() and self.animations["reloadLoop_dry"] then
			animation:play(self.animations["reloadLoop_dry"])
		else
			animation:play(self.animations.reloadLoop)
		end
	elseif self.reloadLoop and not animation:isAnyPlaying() then
		if self:isDry() and self.animations["reloadEnd_dry"] then
			animation:play(self.animations["reloadEnd_dry"])
		else
			animation:play(self.animations.reloadEnd)
		end
		self.reloadLoop = false
		self.reloadInterrupt = false
	end
	

	-- FIRING --

	--reloadloop interrupt
	if updateInfo.fireMode == "primary" and self.reloadLoop and not self.reloadInterrupt then
		self.reloadInterrupt = true
	end

	--auto fire
	if updateInfo.fireMode == "primary" and self.fireTypes[self.fireSelect] == "auto" and (not animation:isAnyPlaying() or animation:isPlaying({self.animations.shoot, self.animations["shoot_dry"]})) and self.delay <= 0 then
		self:fire()
	end
	--semi fire
	if updateInfo.fireMode == "primary" and self.fireTypes[self.fireSelect] == "semi" and not self.semiDebounce and (not animation:isAnyPlaying() or animation:isPlaying({self.animations.shoot, self.animations["shoot_dry"]})) and self.delay <= 0 then
		self:fire()
		self.semiDebounce = true
	elseif self.semiDebounce and updateInfo.fireMode ~= "primary" then --2018 improved semi resposiveness
		self.semiDebounce = false
	end

	--burst fire
	if updateInfo.fireMode == "primary" and self.fireTypes[self.fireSelect] == "burst" and self.burstCount <= 0 and self.delay <= 0 then
		self.burstCount = self.stats.burst or 3
	end
	if self.delay == 0 and self.burstCount > 0 then
		self:fire()
		self.burstCount = self.burstCount - 1
		if self.burstCount == 0 then
			self.delay = self.burstDelay
		end
	end

	--

	--camerasystem
	local distance = world.distance(activeItem.ownerAimPosition(), mcontroller.position())
	camera.target = vec2.add({distance[1] * util.clamp(self.stats.aimLookRatio, 0, 0.5),distance[2] * util.clamp(self.stats.aimLookRatio, 0, 0.5)}, self.recoilCamera)
	camera.smooth = 8
	self.recoilCamera = {self:lerp(self.recoilCamera[1],0,self.stats.recoilRecovery),self:lerp(self.recoilCamera[2],0,self.stats.recoilRecovery)}
	self.recoil = self:lerp(self.recoil, 0, self.stats.recoilRecovery + self.delay)
	
	--aiming system
	local angle, dir = activeItem.aimAngleAndDirection(0, vec2.add(activeItem.ownerAimPosition(), vec2.div(mcontroller.velocity(), 28)))
	aim.target = math.deg(angle) + self.recoil * 3
	aim.dir = dir
	
	--timers
	self.delay = math.max(self.delay - dt, 0)
	if self.delay == 0 and self.hasToLoad then
		self.hasToLoad = false
		self:load_ammo()
	end

	self:debug(dt)

end

function weapon:uninit()
	activeItem.setInstanceValue("gunLoad", self.load)
end

addClass("weapon", 1)