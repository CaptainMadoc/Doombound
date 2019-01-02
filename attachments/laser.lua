module = {
	
}

function module:create(config, name)
	local attachment = {}
	
	laser:add(attachmentSystem.config[name].attachPart, attachmentSystem.config[name].gunTag, attachmentSystem.config[name].gunTagEnd, config.laserColor)

	function attachment:refreshStats()
		local gottenStats = attachmentSystem:getStats()

		gottenStats.movingInaccuracy = gottenStats.movingInaccuracy / 2
		gottenStats.standingInaccuracy = gottenStats.standingInaccuracy / 2
		gottenStats.crouchInaccuracyMultiplier = gottenStats.crouchInaccuracyMultiplier / 2
		
		attachmentSystem:setStats(gottenStats)
	end

	function attachment:uninit()
	
	end
	
	return attachment
end
