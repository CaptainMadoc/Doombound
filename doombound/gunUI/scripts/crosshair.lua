module = {
	inAccuracy = 0,
	muzzleDistance = {0,0}
}

function circle(d,steps)
	local pos = {d,0}
	local pol = {}
	for i=1,steps do
		table.insert(pol,pos)
		pos = vec2.rotate(pos, math.rad(360 / steps))
	end
	return pol
end


function module:refreshData()
    self.inAccuracy = animationConfig.animationParameter("inAccuracy") or 0
    self.muzzleDistance = animationConfig.animationParameter("muzzleDistance") or {0,0}
end

function module:init() if true then return end
    self:refreshData()
end

function module:update(dt) if true then return end
	self:refreshData()

	local distance = (math.abs(self["muzzleDistance"][2]) + math.abs(self["muzzleDistance"][1])) / 2
	local cir = circle((0.125 + (self["inAccuracy"] / 45) * distance) ,16)

	local position = vec2.add(activeItemAnimation.ownerAimPosition(), {0.03125,-0.03125})

	for i=2,#cir do
		localAnimator.addDrawable({line = {cir[i - 1], cir[i]},width = 2, color = {0,0,0,72},fullbright = true, position = position}, "overlay")
		localAnimator.addDrawable({line = {cir[i - 1], cir[i]},width = 1, color = {255,255,255,72},fullbright = true, position = position}, "overlay")
	end
	localAnimator.addDrawable({line = {cir[1], cir[#cir]},width = 2, color = {0,0,0,72},fullbright = true, position = position}, "overlay")
	localAnimator.addDrawable({line = {cir[1], cir[#cir]},width = 1, color = {255,255,255,72},fullbright = true, position = position}, "overlay")
end

function module:uninit()

end