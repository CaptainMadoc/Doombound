module = {
    magazine = {},
    maxMagazine = 1,
    load = false,
    altHanded = false,
    fired = false,
    selected = 1,
    rotatingMagazine = false,
    fireSelect = "semi",
    position = {1,-1},
    direction = -1,
    ownerPosition = {0,0},
    mag1 = 0,
}

function module:refreshData()
    self.magazine = animationConfig.animationParameter("magazine")
    self.maxMagazine = animationConfig.animationParameter("maxMagazine")
    self.load = animationConfig.animationParameter("load")
    self.althanded = animationConfig.animationParameter("althanded")
    self.fired = animationConfig.animationParameter("fired")
    self.selected = animationConfig.animationParameter("selected")
    self.rotatingMagazine = animationConfig.animationParameter("rotatingMagazine")
    self.fireSelect = animationConfig.animationParameter("fireSelect")
    self.uiShell = "/doombound/ui/ammo.png"
    self.ownerPosition = activeItemAnimation.ownerPosition()
end

function module:init()
    self:refreshData()
end

function module:update(dt)
    self:refreshData()

    if self["fireSelect"] and false then
        local offset = {-1.5,-6}
        local directive = ""
		if self["althanded"] then
            offset = {1.5,-6}
            directive = "?flipx"
            self.direction = 1
		end
		localAnimator.addDrawable(
            {
                image = lp(self["fireSelect"]..".png"..directive),
                position = vec2.add( self.ownerPosition, offset ),
                fullbright = true
            },
            "overlay"
        )	
    end
    
    if self.selected then
        self:drawMagR()
    else
        self:drawMag()
    end


end

function module:drawMag()
    local countedAmmo = 0
	for i,v in pairs(self["magazine"] or {}) do
		for i=1,v.count do
			countedAmmo = countedAmmo + 1
		end
    end

    self.mag1 = lerp(self.mag1, countedAmmo, 0.125)
    localAnimator.addDrawable(
        {
            line = {
                {(2.25)  * self.direction , -5},
                {(2.25 + (8 * (self.mag1 / self.maxMagazine))) * self.direction, -5}
            },
            position = self.ownerPosition,
            width = 2,
            color = {255,255,255,255},
            fullbright = true
        },
        "overlay"
    )

    if self["load"] == "table" then
        local chambercolor = {255,255,255}
        if  self["fired"] then chambercolor = {255,0,0} end

        localAnimator.addDrawable(
            {
                line = {
                    {(1)  * self.direction , -5},
                    {(2) * self.direction, -5}
                },
                position = self.ownerPosition,
                width = 2,
                color = chambercolor,
                fullbright = true
            },
            "overlay"
        )
    end

end

function module:drawMagR()

    local lines = {}
    local angleperammo = 360/self.maxMagazine
    if self.mag1 > (self.maxMagazine - 1) * angleperammo and self.selected == 1 then
        self.mag1 = self.mag1 - 360
    end
    self.mag1 = lerp(self.mag1, self.selected * angleperammo, 0.125)
    for i=1,self.maxMagazine do
        local a = {0,0.5}
        local b = {0,1}
        
        local ang =  math.rad((angleperammo * i) - self.mag1)


        local color = {255,255,255}
        if not self.magazine[i] and i ~= self.selected or i == self.selected and self["load"] ~= "table" then
            color = {0,0,0}
        elseif  self.magazine[i] and self.magazine[i].parameters and self.magazine[i].parameters.fired or i == self.selected and self["fired"] then
            color = {255,0,0}
        end

        table.insert(
            lines,
            {
                line = {
                    vec2.add( vec2.rotate(a,ang), {3 *self.direction, -5}),
                    vec2.add( vec2.rotate(b,ang), {3 *self.direction, -5})
                },
                position = self.ownerPosition,
                width = 2,
                color = color,
                fullbright = true
            }
        )
    end

    for i,v in pairs(lines) do
        localAnimator.addDrawable(
        v,
        "overlay"
    )
    end
    
end

function module:uninit()

end