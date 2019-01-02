magazine = {
	type = "rotating",
	storage = {
	},
	disableUI = false,
	selected = 1
}

		--CallBacks

function magazine:init()
	
	dataManager:load("compatibleAmmo")
	
	self.storage = config.getParameter("magazine", jarray())
	self.selected = config.getParameter("selected", 1)
	self.elementID = ui:newElement(self:createElement())
end

function magazine:lateinit()
	animation:addEvent("insert_mag", function() self:insert() end)
	animation:addEvent("insert_bullet", function() self:insert(1) end)
	animation:addEvent("remove_mag", function() self:remove() end)
	animation:addEvent("rotate_mag", function() self:rotate() end)
	animation:addEvent("resetSelect_mag", function() self.selected = 1 self:saveData() end)
	self:verify()
end

function magazine:update(dt)
	activeItem.setScriptedAnimationParameter("magazine", self.storage)
	activeItem.setScriptedAnimationParameter("magazineType", self.type)
	activeItem.setScriptedAnimationParameter("selected", self.selected)
	activeItem.setScriptedAnimationParameter("maxMagazine", data.gunStats.maxMagazine or 30)
end

function magazine:uninit()
	self:saveData()
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
		local direction = -1
		if activeItem.hand() == "alt" then direction = 1 end


		local lines = {}
		local angleperammo = 360/magazine.size

		if self.lerpingVar1 > (magazine.size - 1) * angleperammo and magazine.selected == 1 then
			self.lerpingVar1 = self.lerpingVar1 - 360
		end

		self.lerpingVar1 = lerpr(self.lerpingVar1, magazine.selected * angleperammo, 0.125)

		for i=1,magazine.size do
			local a = {0,0.5}
			local b = {0,1}
			
			local ang =  math.rad((angleperammo * i) - self.lerpingVar1)
	
			local color = {255,255,255}
			if not magazine.storage[i] and i ~= magazine.selected or i == magazine.selected and type(data.gunLoad) ~= "table" then
				color = {0,0,0}
			elseif  magazine.storage[i] and magazine.storage[i].parameters and magazine.storage[i].parameters.fired or i == magazine.selected and (data.gunLoad and data.gunLoad.parameters.fired) then
				color = {255,0,0}
			end
	
			table.insert(
				lines,
				{
					line = {
						vec2.add( vec2.rotate(a,ang), {3 * direction, -5}),
						vec2.add( vec2.rotate(b,ang), {3 * direction, -5})
					},
					position = mcontroller.position(),
					width = 2,
					color = color,
					fullbright = true
				}
			)
		end
	
		for i,v in pairs(lines) do
			table.insert(todraw, {
				func = "addDrawable",
				args = {v, "overlay"}
			}
		)
		end
		

		return todraw
	end

	return element
end


		--API

function magazine:processCompatible(a)
	if type(a) == "string" then
		return root.assetJson(a)
	end
	return a
end

function magazine:saveData()
	activeItem.setInstanceValue("magazine", self.storage)
	activeItem.setInstanceValue("selected", self.selected)
	activeItem.setInstanceValue("gunLoad", data.gunLoad)
end

function magazine:rotate()
	if data.gunLoad then
		self.storage[self.selected] = data.gunLoad
		data.gunLoad = nil
	end
	self.selected = self.selected + 1
	if self.selected > data.gunStats.maxMagazine then
		self.selected = 1
	end
	if self.storage[self.selected] then
		data.gunLoad = self.storage[self.selected]
		self.storage[self.selected] = nil
	end
	magazine:saveData()
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

function magazine:insert(co)
	if not co then
		co = data.gunStats.maxMagazine - #self.storage
	end
	for i,v in pairs(self:getCompatibleAmmo()) do
		if co > 0 then
			local finditem = {name = v, count = 1}
			if type(v) == "table" then
				finditem = v
				finditem.count = 1
			end

			if player.hasItem(finditem) then
				finditem.count = co
				local con = player.consumeItem(finditem, true, true)
				if con then
					for i = 1,con.count do
						table.insert(self.storage, {name = con.name,count = 1, parameters = con.parameters})
						co = co - 1
					end
				end
			end
		else
			break
		end
	end
	
	if self.storage[self.selected] then
		data.gunLoad = self.storage[self.selected]
		self.storage[self.selected] = nil
	end
	
	self:saveData()
end

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

function magazine:remove()
	local togive = jarray()
	
	if data.gunLoad then
		self.storage[self.selected] = data.gunLoad
		data.gunLoad = nil
	end
	
	for i,v in pairs(self.storage) do
		if v.parameters and v.parameters.fired then
			if v.parameters.casingProjectile then
				world.spawnProjectile(
					v.parameters.casingProjectile, 
					gun:casingPosition(), 
					activeItem.ownerEntityId(), 
					vec2.rotate({0,1}, math.rad(math.random(90) - 45)), 
					false,
					v.parameters.casingProjectileConfig or {}
				)
			end
		else
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
	end
	for i,v in pairs(togive) do
		player.giveItem(v)
	end
	self.storage = jarray();
	self:saveData()
end


function magazine:verify()
	for i,v in pairs(self.storage) do
		if i > data.gunStats.maxMagazine then
			self.storage[i] = nil
		end
	end
end

function magazine:take()
	if #self.storage > 0 then
		local ammoPull = self.storage[#self.storage]
		table.remove(self.storage,#self.storage)
		activeItem.setInstanceValue("magazine", self.storage)
		return ammoPull
	end
	return nil
end

function magazine:count()
	local c = 0
	for i,v in pairs(self.storage) do
		if not v.parameters or (v.parameters and not v.parameters.fired) then
			c = c + v.count
		end
	end
	return c
end

function magazine:rawcount()
	local c = 0
	for i,v in pairs(self.storage) do
		c = c + v.count
	end
	return c
end


addClass("magazine")