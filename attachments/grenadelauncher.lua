module = {
	
}

function module:create(c, name, itm)
	local attachment = {special = true, config = c, type = name, attachmentItemConfig = copycat(itm.parameters), canFire = os.clock() + 1, itemDirectory = root.itemConfig(itm).directory} 
	
	function attachment:update(dt) end
	
	function attachment:getAmmo()
		local listComp = root.assetJson(self.config.compatibleAmmo, {})
		for i,v in pairs(listComp) do
			if player.hasItem({name = v, count = 1}) then
				local taken = player.consumeItem({name = v, count = 1})
				local item = root.itemConfig(taken)
				local fitem = sb.jsonMerge(item.config, item.parameters)
				return fitem
			end
		end
	end
	
	function attachment:fireSpecial(a)

		--we check if anything is playing 
		if animation:isAnyPlaying() then
			return
		end

		--a timer
		if self.canFire < os.clock() then

			local ammo = self:getAmmo() -- get ammo from the inv

			if ammo then

				--valid ammo
				customSounds:play(vDir(config.firingSound or "/sfx/gun/grenade2.ogg", self.itemDirectory))
				world.spawnProjectile(
					ammo.projectile or "grenadeimpact", 
					vec2.add(mcontroller.position(),activeItem.handPosition(animator.partPoint(attachmentSystem.config[self.type].attachPart, attachmentSystem.config[self.type].gunTag))),
					activeItem.ownerEntityId(),
					vec2.sub(activeItem.handPosition(animator.partPoint(attachmentSystem.config[self.type].attachPart, attachmentSystem.config[self.type].gunTagEnd)), activeItem.handPosition(animator.partPoint(attachmentSystem.config[self.type].attachPart, attachmentSystem.config[self.type].gunTag))),
					false,
					ammo.projectileConfig or {}
				)

			else
				--no valid ammo
				animator.playSound("dry")
			end
			--cooldown
			self.canFire = os.clock() + 1
		end
	end
	
	function attachment:uninit()
	
	end
	
	return attachment
end
