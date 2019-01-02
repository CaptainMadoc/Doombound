

require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/doombound/scripts/util.lua"
require "/doombound/scripts/itemBugLog.lua"

debugMode = true
_Delta = os.clock()
_profiling = {}

function processDirectory(str)
	if strStarts(str, "/") then
		return str
	end
	if selfItem or selfItem.rootDirectory then
		return selfItem.rootDirectory..str
	end
	local itemConfig = root.itemConfig({name = item.name()})
	return itemConfig.directory..str
end

pD = processDirectory

--

updateInfo = {dt = 1/62, fireMode = "none", shiftHeld = false, moves = {up = false, left = false, right = false, down = false}}
updateLast = {dt = 1/62, fireMode = "none", shiftHeld = false, moves = {up = false, left = false, right = false, down = false}}
selfItem = {
	classes = {},
	toCondense = false,
	condensedClasses = {},
	rootDirectory = "/",
	hasLateInited = false,
	suspend = false
}

--[[
	INFO:
	Base Item Parameter Needed are
	"rootDirectory" for items custom root directory like lua near recipe files (optional)
	"scriptClass"   for modules with addClass() to load (can be a table of strings or a string as a file path)

	A module class will able to sync with the item runtime like:

	CustomClass:init()
	CustomClass:lateInit()
	CustomClass:update(dt, fireMode, shiftHeld, moves)
	CustomClass:lateUpdate(dt, fireMode, shiftHeld, moves)
	CustomClass:uninit()
	CustomClass:activate(fireMode, shiftHeld)

	The Concept of communicating with other modules will need a variable verification

	if type(OtherModules) == "table" and OtherModules.CallingPizza then

	end
]]

function init()	
	
	message.setHandler("isLocal", function(_, loc) return loc end )
	activeItem.setScriptedAnimationParameter("entityID", activeItem.ownerEntityId())

	local ownitem = root.itemConfig({name = item.name(), count = 1})
	selfItem.rootDirectory = config.getParameter("rootDirectory", ownitem.directory)
	
	
	local scriptList = config.getParameter("scriptClass")
	if type(scriptList) == "string" then
		scriptList = root.assetJson(processDirectory(scriptList))
	end
	
	if type(scriptList) == "table" then
		for i,v in ipairs(scriptList) do
			require(processDirectory(v))
		end
	else
		log("Invalid scriptClass type", 2)
	end
	
	updateClass()
	for i,v in ipairs(selfItem.condensedClasses) do
		if _ENV[v] and _ENV[v].init then
			local ret, status = IBL:run(function() _ENV[v]:init() end)
			if not status then
				selfItem.suspend = true
				return
			end
		end
	end
end

function updateClass()
	if selfItem.toCondense then
		selfItem.condensedClasses = table.condense(selfItem.classes,false)
		selfItem.toCondense = false
		return
	end
end

function addClass(name, prioity) --add for the class system to update
	if prioity then
		prioity = math.max(prioity, -9999)
		selfItem.classes[10000 + prioity] = name
		selfItem.toCondense = true
		return
	else
		selfItem.toCondense = true
		table.insert(selfItem.classes, name)
		return
	end
end

function update(dt, fireMode, shiftHeld, moves) 
	if selfItem.suspend then return end
	updateInfo = {dt = os.clock() - _Delta, fireMode = fireMode, shiftHeld = shiftHeld, moves = moves}
	updateClass()

	--LATEINIT
	if not selfItem.hasLateInited then
		for i,v in ipairs(selfItem.condensedClasses) do --the reason behind of this, is because i use this when all the modules are properly inited. also cannot be recalled after loading another script in runtime.
			if _ENV[v] and _ENV[v].lateinit then

				local clocked = os.clock()
				local ret, status = IBL:run(function(dt, fireMode, shiftHeld, moves) _ENV[v]:lateinit(dt, fireMode, shiftHeld, moves) end, dt, fireMode, shiftHeld, moves)
				_profiling[v] = lerp(_profiling[v] or 0, os.clock() - clocked, 2)

				if not status then
					selfItem.suspend = true
					return
				end
			elseif _ENV[v] and _ENV[v].lateInit then
				local clocked = os.clock()
				local ret, status = IBL:run(function(dt, fireMode, shiftHeld, moves) _ENV[v]:lateInit(dt, fireMode, shiftHeld, moves) end, dt, fireMode, shiftHeld, moves)
				_profiling[v] = lerp(_profiling[v] or 0, os.clock() - clocked, 2)
				
				if not status then
					selfItem.suspend = true
					return
				end
			end
		end
		selfItem.hasLateInited = true
	end
		
	for i,v in ipairs(selfItem.condensedClasses) do
		if _ENV[v] and _ENV[v].update then
			
			local clocked = os.clock()
			local ret, status = IBL:run(function(dt, fireMode, shiftHeld, moves) _ENV[v]:update(dt, fireMode, shiftHeld, moves) end, dt, fireMode, shiftHeld, moves)
			_profiling[v] = lerp(_profiling[v] or 0, os.clock() - clocked, 2)

			if not status then
				selfItem.suspend = true
				return
			end
		end
	end

	for i,v in ipairs(selfItem.condensedClasses) do
		if _ENV[v] and _ENV[v].lateUpdate then
			local clocked = os.clock()
			local ret, status = IBL:run(function(dt, fireMode, shiftHeld, moves) _ENV[v]:lateUpdate(dt, fireMode, shiftHeld, moves) end, dt, fireMode, shiftHeld, moves)
			_profiling[v] = lerp(_profiling[v] or 0, os.clock() - clocked, 2)
			if not status then
				selfItem.suspend = true
				return
			end
		end
	end
	
	updateLast = {dt = updateInfo.dt, fireMode = updateInfo.fireMode, shiftHeld = shiftHeld, moves = moves}
	_Delta = os.clock()
end

function uninit()
	if selfItem.suspend then return end

	updateClass()
	for i,v in ipairs(selfItem.condensedClasses) do
		if _ENV[v] and _ENV[v].uninit then
			local ret, status = IBL:run(function() _ENV[v]:uninit() end)
			if not status then
				selfItem.suspend = true
				return
			end
		end
	end

	--	sb.logInfo(sb.printJson(_profiling, 1))
end

function activate(fireMode, shiftHeld)
	if selfItem.suspend then return end

	updateClass()
	for i,v in ipairs(selfItem.condensedClasses) do
		if _ENV[v] and _ENV[v].activate then
			local ret, status = IBL:run(function(fireMode, shiftHeld) _ENV[v]:activate(fireMode, shiftHeld) end, fireMode, shiftHeld)
			if not status then
				selfItem.suspend = true
				return
			end
		end
	end
end
