module = {}

function module:init()
	
end

function module:update()
	local elements = animationConfig.animationParameter("elements")
	for i,v in pairs(elements or {}) do
		if localAnimator[v.func or "nil"] then
			localAnimator[v.func](table.unpack(v.args or {}))
		end
	end
end

function module:uninit()

end

