--requires ui.lua

gun_ui = {
	disable = false,
	elementID = ""
}

function gun_ui:init()
	self.elementID = ui:newElement(self:createElement_FireMode())
end

function gun_ui:createElement_FireMode()
	local element = {
		althand = activeItem.hand() == "alt"
	}

	function element:init()
		self.althand = activeItem.hand() == "alt"
	end

	function element:draw()
		local todraw = {}
		if gun_ui.disable then return todraw end
		local fireSelected = gun:fireMode()

		if fireSelected then
			self.althand = activeItem.hand() == "alt"
			
    	    local offset = {-1.5,-6}
			local directive = ""
			
			if self.althand then
    	        offset[1] = 1.5
    	        directive = "?flip"
			end

			local direction = -1
			if activeItem.hand() == "alt" then direction = 1 end
			table.insert(
				todraw, {
					func = "addDrawable",
					args = {
						{
							poly = {
								{0.875  * direction, -6.75},
								{2.125 * direction, -6.75},
								{2.125 * direction, -5.375},
								{0.875 * direction , -5.375},
							},
							position = mcontroller.position(),
							color = {0,0,0,128},
							fullbright = true
						},
						"overlay"
					}
				}
			)

			table.insert(todraw, 
				{
					func = "addDrawable",
					args = {
						{
							image = "/doombound/gunUI/"..fireSelected..".png"..directive,
							position = vec2.add( mcontroller.position(), offset ),
							fullbright = true
						},
						"overlay"
					}
				}
			)
		end

		return todraw
	end

	return element
end



addClass("gun_ui")