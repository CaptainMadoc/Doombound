module = {
	
}

function module:create(config)
	local attachment = {} 

	function attachment:refreshStats()
		local gottenStats = attachmentSystem:getStats()

		for i,v in pairs(config.stats) do
			if i == "fireSounds" then
				animator.setSoundPool("fireSounds", v)
			elseif gottenStats[i] then
				gottenStats[i] = math.max(gottenStats[i] * v, 0)
			end
		end	
		
		attachmentSystem:setStats(gottenStats)
	end

	function attachment:update(dt)
	
	end
	
	function attachment:uninit()
	
	end
	
	return attachment
end
