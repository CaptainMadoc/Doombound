gun = {
	--------------------------
	features = {
		recoilRecovery = true,
		cameraAim = true,
		aim = true --disable this if you want to override things
	},
	--------------------------

	camera = {0,0}, -- camera position
    fireModeInt = 1, -- firemode index  use gun:fireMode()
	recoil = 0,	-- use gun:addRecoil(float addangle)

	cooldown = 0, -- delay for rpm
	aimPos = nil, --
}		


--CALLBACKS----------------------------------------------

function gun:gbDebug()
	if _GBDEBUG then
		_GBDEBUG:newTestUnit("gun:fire()", function() return self:fire() end)
		_GBDEBUG:newTestUnit("gun:load_chamber()", function() return self:load_chamber() end)
	end
end


function gun:init()

	--DATA ITEM LOADS
    dataManager:load("gunLoad", true)
    dataManager:load("gunScript", false, "/doombound/base/default.lua")
	dataManager:load("gunStats", false
	)

	--old gun settings 
	    --dataManager:load("fireTypes", false, {"auto"})
	    --dataManager:load("casingFX", false, true)
	    --dataManager:load("bypassShellEject", false, false)
	    --dataManager:load("muzzlePosition", false, {part = "gun", tag = "muzzle_begin", tag_end = "muzzle_end"})
	    --dataManager:load("casing", false, {part = "gun", tag  = "casing_pos"})

	--dataManager:load("gunSettings", false, 
	--	{ -- default settings
	--	{ -- default settings
	--		fireSounds = jarray(),
	--		fireTypes = data.fireTypes or {"semi"},
	--		chamberEjection = not data.bypassShellEject or true,
	--		muzzlePosition = data.muzzlePosition or {part = "gun", tag = "muzzle_begin", tag_end = "muzzle_end"},
	--		showCasings = data.casingFX or true,
	--		casingPosition = data.casing or {part = "gun", tag  = "casing_pos"}
	--	}
	--)

	local defaultStats = { -- default stats 
		damageMultiplier = 1,
		bulletSpeedMultiplier = 1,
		maxMagazine = 30,
		aimLookRatio = 0,
		burst = 3,
		recoil = 4,
		recoilRecovery = 2,
		movingInaccuracy = 5,
		standingInaccuracy = 1,
		crouchInaccuracyMultiplier = 0.25,
		muzzleFlash = 1,
		rpm = 600
	}


	local defaultSettings = {
		fireSounds = jarray(),
		fireTypes = {"semi"},
		chamberEjection = true,
		muzzlePosition = {part = "gun", tag = "muzzle_begin", tag_end = "muzzle_end"},
		showCasings = true,
		casingPosition = {part = "gun", tag  = "casing_pos"},
		cursor = "/doombound/crosshair/crosshair2.cursor",
	}

	self.stats = default(config.getParameter("gunStats"), defaultStats)
	self.settings = default(config.getParameter("gunSettings"), defaultSettings)
	self.animations = config.getParameter("gunAnimations")
	
	--real init
	activeItem.setCursor(self.settings.cursor)

    self.fireSounds = config.getParameter("fireSounds", self.settings.fireSounds or jarray())
	for i,v in pairs(self.fireSounds) do
		self.fireSounds[i] = processDirectory(v)
	end
	
	self:setFireSound( self.fireSounds )

	animation:addEvent("eject_chamber", function() self:eject_chamber() end)
	animation:addEvent("load_ammo", function() self:load_chamber() end)

	if magazine then 
		magazine.size = self.stats.maxMagazine 
	else
		error("magazine module does not exist!")
		return
	end

	self:gbDebug()

	--main gun script
	require(processDirectory(data.gunScript))
end

function gun:lateinit(...)
	if main and main.init then
		main:init(...)
	end
end

function gun:uninit(...)
	if main and main.uninit then
		main:uninit(...)
	end
	dataManager:save("gunLoad")
end

function gun:activate(...)
	if main and main.activate then
		main:activate(...)
	end
end

function gun:update(dt, fireMode, shiftHeld, moves)

	--camerasystem
	if self.features.cameraAim then
		local distance = world.distance(activeItem.ownerAimPosition(), mcontroller.position())
		camera.target = vec2.add({distance[1] * util.clamp(self.stats.aimLookRatio, 0, 0.5),distance[2] * util.clamp(self.stats.aimLookRatio, 0, 0.5)}, self.camera)
		camera.smooth = 8
		self.camera = {lerp(self.camera[1],0,self.stats.recoilRecovery),lerp(self.camera[2],0,self.stats.recoilRecovery)}
	end
	
	--recoil recovery
	if self.features.recoilRecovery then
	self.recoil = lerp(self.recoil, 0, self.stats.recoilRecovery)	
	end

	--aiming. gun.features.aim = false allows for compatibility like aim assisters
	if self.features.aim then
		local angle, dir = activeItem.aimAngleAndDirection(0, vec2.add(self.aimPos or activeItem.ownerAimPosition(), vec2.div(mcontroller.velocity(), 28)))
		aim.target = math.deg(angle) + self.recoil
		aim.direction = dir
	end

	--rpm system
	if self.hasToLoad and gun:ready() then
		self.hasToLoad = false
		self:load_chamber()
		self.cooldown = 0.016
    end

	--main gun script update
	if main and main.update then
		main:update(dt, fireMode, shiftHeld, moves)
	end

	--timer rpm lol
	self.cooldown = math.max(self.cooldown - updateInfo.dt, 0)
end

		--API--

--Use for calculation RPM to shots timer
function gun:rpm()
    return math.max((60/(self.stats.rpm or 666)) - 0.016, 0.016)
end

--i think its for the angle RNG -/+
function gun:inaccuracy()
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = self.stats.crouchInaccuracyMultiplier
	end
	local velocity = whichhigh(math.abs(mcontroller.xVelocity()), math.abs(mcontroller.yVelocity() + 1.28))
	local percent = math.min(velocity / 14, 1)
	return lerpr(self.stats.standingInaccuracy, self.stats.movingInaccuracy, percent) * crouchMult
end

--RNG
function gun:calculateInAccuracy(pos)
	local angle = (math.random(0,2000) - 1000) / 1000
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = self.stats.crouchInaccuracyMultiplier
	end
	if not pos then
		return math.rad((angle * self:inaccuracy()))
	end
	return vec2.rotate(pos, math.rad((angle * self:inaccuracy())))
end

--Quick relativepos from hand + pos
function gun:rel(pos)	
	return vec2.add(mcontroller.position(), activeItem.handPosition(pos))
end

--vec2 angle from muzzlePosition
function gun:angle()
	return vec2.sub(self:rel(animator.partPoint(self.settings.muzzlePosition.part, self.settings.muzzlePosition.tag_end)),self:rel(animator.partPoint(self.settings.muzzlePosition.part, self.settings.muzzlePosition.tag)))
end

--vec2 angle from casing
function gun:casingPosition()
	local offset = {0,0}
	if self.settings.casingPosition then
		offset = animator.partPoint(self.settings.casingPosition.part, self.settings.casingPosition.tag)
	end
	return vec2.add(mcontroller.position(), activeItem.handPosition(offset))
end

--overrides from cursor aim if you want to make aimbot attachments
function gun:aimAt(pos)
	if not pos then self.aimPos = nil return end self.aimPos = pos
end

function gun:canFire()
	if data.gunLoad and not data.gunLoad.parameters.fired then
		return true
	else
		return false
	end
end

--base damage of the current bullet
function gun:rawDamage(projectilename)
	local dmg = 0
	if data.gunLoad then
		return root.projectileConfig(projectilename or (data.gunLoad.parameters or {}).projectile or "bullet-4").power or 5.0
	end
	return dmg
end


--You know
function gun:fire(overrideStats)
	if not overrideStats then overrideStats = {} end

	if data.gunLoad and not data.gunLoad.parameters.fired then -- data.gunLoad must be a valid bullet without a parameter fired as true
		
		local newConfig = root.itemConfig({name = data.gunLoad.name, count = 1, parameters = data.gunLoad.parameters})		
		if not newConfig then self:eject_chamber() return end

		data.gunLoad.parameters = sb.jsonMerge(newConfig.config, newConfig.parameters)
		
		local ownerDmgMultiplier = 1

		-- apply bullet stat projectile stuff
		local finalProjectileConfig = data.gunLoad.parameters.projectileConfig or {}
		if not finalProjectileConfig.power then -- we calculate the gun x bullet power
			finalProjectileConfig.power = (self:rawDamage(data.gunLoad.parameters.projectile or "bullet-4") * (overrideStats.damageMultiplier or self.stats.damageMultiplier or 1.0)) * ownerDmgMultiplier
		elseif finalProjectileConfig.power then
			finalProjectileConfig.power = (finalProjectileConfig.power * (overrideStats.damageMultiplier or self.stats.damageMultiplier or 1.0)) * ownerDmgMultiplier
		end

		finalProjectileConfig.speed = (finalProjectileConfig.speed or 5.0) * (overrideStats.bulletSpeedMultiplier or self.stats.bulletSpeedMultiplier or 1.0)
		--

		--spawns bullet HERE
		for i=1,data.gunLoad.parameters.projectileCount or 1 do
			world.spawnProjectile(
				data.gunLoad.parameters.projectile or "bullet-4", 
				self:rel(animator.partPoint(self.settings.muzzlePosition.part, self.settings.muzzlePosition.tag)), 
				activeItem.ownerEntityId(), 
				self:calculateInAccuracy(self:angle()), 
				false,
				finalProjectileConfig
			)
		end

		--marks ammo as a fired bullet
		data.gunLoad.parameters.fired = true
		
		--used by action lever style
		if self.settings.chamberEjection then
			self:eject_chamber()
			if magazine:count() > 0 then
				self.hasToLoad = true
			end
		end
		--
		
		--emits FX muzzle flash sometimes changed by a silencer/flash hider
		if (overrideStats.muzzleFlash or self.stats.muzzleFlash) == 1 then
			animator.setAnimationState("firing", "on")
		end

		--firesounds
		animator.playSound("fireSounds")
		
		--local status
		self.cooldown = self:rpm()
		self:addRecoil()
		
		self.recoilCamera = {math.sin(math.rad(self.recoil * 80)) * ((self.recoil / 8) ^ 1.25), self.recoil / 8}
		dataManager:save("gunLoad") --Save as we changed something in gunLoad 
		
		return true
	else --else plays a dry sound
		animator.playSound("dry")
		self.cooldown = self:rpm()
		return false
	end
end

--Gets bullet out from the internal gun
function gun:eject_chamber()
	if data.gunLoad then

		local itemConfig = root.itemConfig(data.gunLoad)
		local finalItemParameters = sb.jsonMerge(itemConfig.config, data.gunLoad.parameters or {})

		local projectileParam = finalItemParameters.casingProjectileConfig or {speed = 10, timeToLive = 0.5}


		if not itemConfig.parameters.fired then
			projectileParam.actionOnReap = projectileParam.actionOnReap or {}
			table.insert(projectileParam.actionOnReap, {action = "item", name = data.gunLoad.name,count = data.gunLoad.count, data = itemConfig.parameters})
			--player.giveItem(data.gunLoad)
		end

		world.spawnProjectile(
			finalItemParameters.casingProjectile or "invisibleprojectile", 
			self:casingPosition(), 
			activeItem.ownerEntityId(), 
			vec2.rotate({0,1}, math.rad(math.random(90) - 45)), 
			false,
			projectileParam
		)

		data.gunLoad = nil

		dataManager:save("gunLoad")
	end
end

--Gets bullet in from the internal gun; can be manual loaded with 'bullet'
function gun:load_chamber(bullet)
	if data.gunLoad then 
		self:eject_chamber()
	end
	data.gunLoad = bullet or magazine:take()
	dataManager:save("gunLoad")
end

--See if nothing is loaded
function gun:chamberDry()
	if type(data.gunLoad) ~= "table" then
		return true
	elseif data.gunLoad.parameters and data.gunLoad.parameters.fired then
		return true
	end
	return false
end

function gun:dry()
	return self:chamberDry() and magazine:count() == 0
end

--Gun full ready
function gun:ready()
	if self.cooldown == 0 then
		return true
	end
	return false
end


--Adding armOffsets
function gun:addRecoil(custom)
	local a = custom
	if not custom then
		a = self.stats.recoil
	end
	self.recoil = self.recoil + a * 2
end


--Gets Current Firemode
function gun:fireMode()
	return (self.settings.fireTypes or self.settings.fireTypes)[self.fireModeInt] or "null"
end

function gun:switchFireModes(custom)
	if not self.settings.fireTypes then self.settings.fireTypes = {"semi"} end --verify
	animator.playSound("dry")
	if self.fireModeInt == #self.settings.fireTypes then
		self.fireModeInt = 1
	else
		self.fireModeInt = math.max(math.min((custom or self.fireModeInt + 1),#self.settings.fireTypes),1)
	end
end


--sets our gun firesounds
function gun:setFireSound(soundpool)
	animator.setSoundPool("fireSounds", soundpool or self.fireSound)
end

addClass("gun")