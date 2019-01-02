--requires ui.lua

crosshair_ui = {
	elementID = "",
	disable = false
}

function crosshair_ui:init()
	self.elementID = ui:newElement(self:createElement())
end

function crosshair_ui:createElement()
	local element = {}

	function element:init()

	end

	function element:circle(d, steps)
		local pos = {d,0}
		local pol = {}
		for i=1,steps do
			table.insert(pol,pos)
			pos = vec2.rotate(pos, math.rad(360 / steps))
		end
		return pol
	end

	function element:draw()
		local todraw = {}
		if crosshair_ui.disable then return todraw end
		local inAccuracy = gun:inaccuracy()
		local muzzleDistance = world.distance(activeItem.ownerAimPosition(),gun:rel(animator.partPoint("gun", "muzzle_begin"))) or {0,0}
		
		local distance = (math.abs(muzzleDistance[2]) + math.abs(muzzleDistance[1])) / 2

		local cir = self:circle((0.125 + (inAccuracy / 45) * distance) ,16)
		local position = vec2.add(activeItem.ownerAimPosition(), {0.03125,-0.03125})
		
		for i=2,#cir do
			table.insert( 
				todraw,
				{
					func = "addDrawable",
					args = {{line = {cir[i - 1], cir[i]},width = 2, color = {0,0,0,72},fullbright = true, position = position}, "overlay"}
				}
			)
			table.insert(todraw,
				{
					func = "addDrawable",
					args = {{line = {cir[i - 1], cir[i]},width = 1, color = {255,255,255,72},fullbright = true, position = position}, "overlay"}
				}
			)
		end
		
		table.insert(todraw,
			{
				func = "addDrawable",
				args = {{line = {cir[1], cir[#cir]},width = 2, color = {0,0,0,72},fullbright = true, position = position}, "overlay"}
			}
		)
		table.insert(todraw,
			{
				func = "addDrawable",
				args = {{line = {cir[1], cir[#cir]},width = 1, color = {255,255,255,72},fullbright = true, position = position}, "overlay"}
			}
		)

		return todraw
	end

	return element
end

addClass("crosshair_ui")