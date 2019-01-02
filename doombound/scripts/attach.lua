function whole(aitem)
	local a = root.itemConfig(aitem)
	return sb.jsonMerge(a.config, a.parameters)
end

function apply(input)
	local attachType = config.getParameter("attachmentType")
	local oItem = whole(input)
	if not input.parameters.attachments and oItem.attachments then
		input.parameters.attachments = {} -- oItem.attachments
	end
	for i,v in pairs(oItem.attachments) do
		if not input.parameters.attachments[i] then
			input.parameters.attachments[i] = {}
		end
		--if not input.parameters.attachments[i].item then
		--	input.parameters.attachments[i].item = v.item
		--end
	end
	
	if input.parameters.attachments[attachType] then
		if input.parameters.attachments[attachType].item ~= nil then
			input.parameters.giveback = input.parameters.giveback or {}
			table.insert(input.parameters.giveback, input.parameters.attachments[attachType].item)
		end
		input.parameters.attachments[attachType].item = item.descriptor()
		return input
	end
end