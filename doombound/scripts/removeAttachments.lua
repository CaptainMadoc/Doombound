function apply(input)
	if input.parameters and input.parameters.attachments then
		for i,v in pairs(input.parameters.attachments) do
			if input.parameters.attachments[i].item ~= nil then
				input.parameters.giveback = input.parameters.giveback or {}
				table.insert(input.parameters.giveback, input.parameters.attachments[i].item)
			end
			input.parameters.attachments[i].item = nil
		end
		
		input.parameters.giveback = input.parameters.giveback or {}
		table.insert(input.parameters.giveback, item.descriptor())
		return input
	end
end