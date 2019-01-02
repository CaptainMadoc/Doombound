ui = {
	elements = {}
}

function ui:lateInit()
	for i,v in pairs(self.elements) do
		if self.elements[i].init then
			self.elements[i]:init()
		end
	end
end

--[[
	element:draw() must be returned like this:
	
	return
	{
		func = "function name in localAnimator",
		args = {1,2,3,4,5}
	}

]]


function ui:update()
	local SetElements = {}
	for i,v in pairs(self.elements) do
		if v.remove then --in ui elements you can use self.remove = true
			self.elements[i] = nil
		elseif self.elements[i].draw then
			local pulled = self.elements[i]:draw() -- asking all binded elements what to draw
			for i,v in pairs(pulled) do
				table.insert(SetElements, v)
			end
		end
	end
	activeItem.setScriptedAnimationParameter("elements", SetElements)
end

function ui:newElement(table)
	local newUUID = sb.makeUuid()..sb.makeUuid()
	self.elements[newUUID] = table
	return newUUID
end

addClass("ui")