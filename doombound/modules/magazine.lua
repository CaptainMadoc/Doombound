magazine = {
	type = "normal",
	size = 30,
	elementID = false,
	disableUI = false,
	storage = {
	}
}

		--CALLBACKS

function magazine:init()
	dataManager:load("compatibleAmmo", false, jarray())
	self.storage = config.getParameter("magazine", jarray())
	self.elementID = ui:newElement(self:createElement())
end

function magazine:lateinit()
	animation:addEvent("insert_mag", function() self:insert() end)
	animation:addEvent("insert_bullet", function() self:insert(1) end)
	animation:addEvent("remove_mag", function() self:remove() end)
	if self:count() > self.size then
		self:remove()
	end
end

function magazine:update(dt)
	activeItem.setScriptedAnimationParameter("magazine", self.storage)
	activeItem.setScriptedAnimationParameter("magazineType", self.type)
	activeItem.setScriptedAnimationParameter("maxMagazine", self.size or 30)
end

function magazine:uninit()
	activeItem.setInstanceValue("magazine", self.storage)
end

--ui.lua needed
function magazine:createElement()
	
	local element = {
		lerpingVar1 = 0
	}

	function element:init()
		
	end

	function element:draw()
		local todraw = {}
		if magazine.disableUI then return todraw end
		local load = data.gunLoad
		local direction = -1
		if activeItem.hand() == "alt" then direction = 1 end

		local countedAmmo = 0

		for i,v in pairs(magazine.storage or {}) do
			countedAmmo = countedAmmo + v.count
		end
	
		self.lerpingVar1 = lerpr(self.lerpingVar1, countedAmmo, 0.125)

		table.insert(
			todraw, {
				func = "addDrawable",
				args = {
					{
						poly = {
							{0.5  * direction, -4.75},
							{10.375 * direction, -4.75},
							{10.625 * direction, -5.25},
							{0.875  * direction , -5.25},
						},
						position = mcontroller.position(),
						color = {0,0,0,128},
						fullbright = true
					},
					"overlay"
				}
			}
		)
	
		table.insert(
			todraw, {
				func = "addDrawable",
				args = {
					{
						line = {
							{(2.25)  * direction , -5},
							{(2.25 + (8 * (self.lerpingVar1 / magazine.size))) * direction, -5}
						},
						position = mcontroller.position(),
						width = 2,
						color = {255,255,255,255},
						fullbright = true
					},
					"overlay"
				}
			}
		)
	
		if type(load) == "table" then
			local chambercolor = {255,255,255}
			if load.parameters and load.parameters.fired then chambercolor = {255,0,0} end
	
			table.insert(todraw,{
					func = "addDrawable",
					args = {
						{
							line = {
								{(1)  * direction , -5},
								{(2) * direction, -5}
							},
							position = mcontroller.position(),
							width = 2,
							color = chambercolor,
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

		--API-

--counts how much bullets in the magazine
function magazine:count()
	local c = 0
	for i,v in pairs(self.storage) do
		c = c + v.count
	end
	return c
end

--get a list of compatible ammo for this mag
function magazine:getCompatibleAmmo()
	local compat = config.getParameter("compatibleAmmo", jarray())
	if type(compat) == "string" then
		compat = root.assetJson(processDirectory(compat))
	end
	if not compat or #compat == 0 then
		return {"gbtestammo"}
	end
	return compat
end

--Check if player has ammo for it
function magazine:playerHasAmmo()
	for i,v in pairs(self:getCompatibleAmmo()) do
		local finditem = {name = v, count = 1}
		if type(v) == "table" then finditem = v end
		if player.hasItem(finditem, true) then
			return true
		end
	end
	return false
end

function magazine:insert(co)
	if not co then --variable 'co' is how much bullet we take from player inventory
		co = self.size - self:count()
	end
	for i,v in pairs(self:getCompatibleAmmo()) do
		if co > 0 then
			local finditem = {name = v, count = 1}
			if type(v) == "table" then
				finditem = v
				finditem.count = co
			end

			if player.hasItem(finditem) then
				finditem.count = co
				local con = player.consumeItem(finditem, true, true)
				if con then
					table.insert(self.storage, con)
					co = co - con.count
				end
			end
		else
			break
		end
	end
	activeItem.setInstanceValue("magazine", self.storage)
end

--remove bullets from the mags
function magazine:remove(specific)
	local togive = jarray()
	local toremove = specific or self:count() -- todo
	for i,v in pairs(self.storage) do
		if #togive == 0 then
			table.insert(togive,v)
		else
			local matched = false
			for i2,v2 in pairs(togive) do
				if sb.printJson(v.parameters) == sb.printJson(v2.parameters) and v.name == v2.name then
					matched = true
					togive[i2].count = togive[i2].count + v.count
				end
			end
			if not matched then
				table.insert(togive, v)
			end
		end
	end
	for i,v in pairs(togive) do
		player.giveItem(v)
	end
	self.storage = jarray();
	activeItem.setInstanceValue("magazine", self.storage)
end

--takes a bullet from the magazine
function magazine:take()
	if self:count() > 0 then
		local ammoPull = copycat(self.storage[#self.storage])
		if ammoPull.count <= 1 then
			table.remove(self.storage,#self.storage)
		else
			self.storage[#self.storage].count = self.storage[#self.storage].count - 1
		end
		activeItem.setInstanceValue("magazine", self.storage)
		ammoPull.count = 1
		return ammoPull
	end
	return nil
end

addClass("magazine")