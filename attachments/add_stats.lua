module = {
	
}

function module:create(attachmentConfig)
	local attachment = {} 
	
	if attachmentConfig.stats.fireSounds then
		attachmentSystem:setFireSounds(attachmentConfig.stats.fireSounds)
	end

	function attachment:refreshStats()
		attachmentSystem:addStats(attachmentConfig.stats)
	end
	
	function attachment:update(dt)
	
	end
	
	function attachment:uninit()
	
	end
	
	return attachment
end
