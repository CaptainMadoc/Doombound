module = {
	
}

function module:create(attachmentConfig)
	local attachment = {} 
	
	if attachmentConfig.stats.fireSounds then
		animator.setSoundPool("fireSounds", attachmentConfig.stats.fireSounds)
	end
	
	function attachment:refreshStats()
		attachmentSystem:setStats(attachmentConfig.stats)
	end

	function attachment:update(dt)
	
	end
	
	function attachment:uninit()
	
	end
	
	return attachment
end
