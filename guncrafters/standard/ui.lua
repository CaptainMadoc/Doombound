function raffle() --rng
    local chance = math.random(10000) / 100
    for i=1,50 do
      chance = (chance + (math.random(10000) / 100)) / 2
    end
    return chance
end

function rafflePool() --no cheating pls
    local var1 = raffle()
    if var1 > 90 and pool.legendary and #pool.legendary > 0 then
        return pool.legendary[math.random(1,#pool.legendary)], "Legendary"
    elseif var1 > 80 and pool.rare and #pool.rare > 0 then
        return pool.rare[math.random(1,#pool.rare)], "Rare"
    elseif var1 > 60  and pool.uncommon and #pool.uncommon > 0 then
        return pool.uncommon[math.random(1,#pool.uncommon)], "Uncommon"
    elseif pool.common and #pool.common > 0 then
        return pool.common[math.random(1,#pool.common)], "Common"
    end
    return nil, "^#f00;Error pool craft" --crafting failed
end

function absoluteDir(str,dir)
    if str:sub(1,1) == "/" then
        return str
    end
    return dir..str
end

function attemptCraft() --action something
    if player.hasCountOfItem({name = "gbgunpart", count = 1}, false) >= 2 then
        local crafted, rarity = rafflePool()
        if crafted then
            
            local itemP
            if type(crafted) == "table" then
                itemP = root.itemConfig(crafted)
            elseif  type(crafted) == "string" then
                itemP = root.itemConfig({name = crafted, count = 1})
            end
            if type(itemP) == "table" then
                player.consumeItem({name = "gbgunpart", count = 5}, false, false)
                local itemConfig = itemP.config 
                player.giveItem({name = crafted, count = 1})
                if type(itemConfig.inventoryIcon) == "string" then
                    addParticles("image", {
                        image = absoluteDir(itemConfig.inventoryIcon, itemP.directory),
                        timeToLive = 4,
                        size = 1,
                        position = vec2.add(vec2.mul(canvas:size(), {0.5, 0.5}), {0,0})
                    })
                end
                return "You crafted a "..rarity.." "..(itemConfig.shortdescription or itemConfig.itemname or "Unnamed Weapon").."!"
            else
                return "Error Processing pulled item "..sb.printJson(crafted)
            end
        end
        return rarity
    end
    return "^#f00;You need 5 Guns Parts to craft a random weapon"
end

function widget_btnCraft()
    particles = {

    }
    local result = attemptCraft()
    addParticles("text", {
        text = result,
        timeToLive = 4,
        position = vec2.add(vec2.mul(canvas:size(), {0.5, 0.5}), {0,12.5    })
    })
end

function call(wid) -- universal callback
    if _ENV["widget_"..wid] then
        _ENV["widget_"..wid]()
    end
end

pool = {}

function addParticles(type, param)
    local uuid = sb.makeUuid()
    particles[uuid] = param
    particles[uuid].type = type
end

particles = {

}

require "/scripts/vec2.lua"

canvas = {}

function init()
    canvas = widget.bindCanvas("canvas")
    pool = config.getParameter("craftPools", {rare = {}, legendary = {}, uncommon = {}, common = {}})
end

function update(dt)
    for i,v in pairs(particles) do
        particles[i].timeToLive = math.max(particles[i].timeToLive - dt, 0)
        
        if v.timeToLive == 0 then
            particles[i] = nil
        end
    end

    render(dt)
end

function render(dt)
    canvas:clear()

    for i,v in pairs(particles) do
        if v.type == "image" then
            canvas:drawImage(
                v.image,
                v.position,
                math.min(v.timeToLive ^ 2, 1) * (v.size or 1),
                {255,255,255,255},
                true
            )
        elseif v.type == "text" then
            canvas:drawText(
                v.text,
                {
                    position = v.position,
                    horizontalAnchor = "mid", -- left, mid, right
                    verticalAnchor = "mid", -- top, mid, bottom
                    wrapWidth = nil -- wrap width in pixels or nil
                },
                math.min(v.timeToLive ^ 2, 1) * 8
            )
        end
    end
end