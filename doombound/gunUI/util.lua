function lerp(a,b,r)
	if type(a) == "table" then
		if type(b) == "number" then
			b = {b, b}
		end
		return {a[1] + (b[1] - a[1]) * r, a[2] + (b[2] - a[2]) * r}
	end
	return a + (b - a) * r
end

function copycat(var)
	if type(var) == "table" then
		local newtab = {}
		for i,v in pairs(var) do
			newtab[i] = copycat(v)
		end
		return newtab
	else
		return var
	end
end