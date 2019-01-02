function rexDump(tb, nm)
	local lines = ""
	if tb == nil or type(tb) ~= "table" then return "Not a valid table" end
	if nm == nil then nm = " " else nm = nm.." = " end
	local function addline(sti)
		lines = lines..sti.."\n"
	end
	addline(nm.."{")
	local function rextd(tab, off, name)
		if tab == nil then return nil end
		if off == nil then off = "" end
		if name == nil then name = "" end
		local nums = 0
		
		--if tab["_G"] then tab["_G"] = nil	end
		--if tab["_ENV"] then tab["_ENV"] = nil	end
			
		for ii, vv in pairs(tab) do 
			if nt ~= "_G" and nt ~= "_ENV" then
				nums = nums + 1 
			end
		end
		
		local commas = ","
		for nt, vl in pairs(tab) do
			if nt ~= "_G" and nt ~= "_ENV" and nt ~= "package" and (nt ~= "charpattern") then -- avoid loop
				if nums <= 1 then
					commas = ""
				end
				
				
				if type(nt) == "number" then
					if type(vl) == "function" then
						addline(off.."function()"..commas)
					elseif type(vl) == "table" then
						addline(off.."{")
						rextd(vl, off.."    ", "."..commas)
						addline(off.."}"..commas)
					elseif type(vl) == "string" then
						addline(off.."\""..vl.."\""..commas)
					elseif vl == nil then --does not work literally ignores it
						addline(off.."nil"..commas)
					else
						addline(off..tostring(vl)..commas)
					end
				else
					if type(vl) == "function" then
						addline(off..nt.."()"..commas)
					elseif type(vl) == "table" then
						addline(off..nt.." = {")
						rextd(vl, off.."    ", "."..nt..commas)
						addline(off.."}"..commas)
					elseif type(vl) == "string" then
						addline(off..nt.." = \""..vl.."\""..commas)
					elseif vl == nil then --does not work literally ignores it
						addline(off..nt.." = nil"..commas)
					else
						addline(off..nt.." = "..tostring(vl)..commas)
				end
			end
		end
		nums = nums - 1
		end
	end
	rextd(tb, "    ", nm) 
	addline("}")
	return lines
end