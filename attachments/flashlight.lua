module = {
	
}

function module:create(config, name)
	local attachment = {}
	
	flashlight:add(attachmentSystem.config[name].attachPart, attachmentSystem.config[name].gunTag, attachmentSystem.config[name].gunTagEnd, config.lightColor)
	
	function attachment:uninit()
	
	end
	
	return attachment
end
