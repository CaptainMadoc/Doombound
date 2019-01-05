ammo = {

}

-- created for gunscripts probably for gun that does not have mags

function ammo:getCompatibleTypes()
	local compat = config.getParameter("compatibleAmmo", jarray())
	if type(compat) == "string" then
		compat = root.assetJson(processDirectory(compat))
	end
	if not compat or #compat == 0 then
		return {"gbtestammo"}
	end
	return compat
end

function ammo:inInventory(countneeded)
    for i,v in pairs(self:getCompatibleAmmo()) do
		local finditem = {name = v, count = countneeded or 1}
		if type(v) == "table" then finditem = v end
		if player.hasItem(finditem, true) then
			return true
		end
	end
	return false
end

function ammo:get(amount)
	local gotten = {}
	if not amount then 
		amount = 1
	end

	for i,v in pairs(self:getCompatibleTypes()) do
		if amount > 0 then
			local finditem = {name = v, count = 1}
			if type(v) == "table" then
				finditem = v
				finditem.count = amount
			end

			if player.hasItem(finditem) then
				finditem.count = amount
				local con = player.consumeItem(finditem, true, true)
				if con then
					table.insert(gotten, con)
					amount = amount - con.count
				end
			end
		else
			break
		end
	end

	return gotten
end