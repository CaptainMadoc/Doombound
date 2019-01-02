remaining = 10

function init()
    remaining = config.getParameter("ammoRemaining", 10)
    object.setInteractive(true)
    if remaining <= 0 then
        object.smash(true)
    end
end

function save()
    if remaining <= 0 then
        object.smash(true)
    end
    object.setConfigParameter("ammoRemaining", remaining)
    object.setConfigParameter("description", "Remaining dispenses: ^green;"..remaining)
end

function procdir(str,dir)
if str:sub(1,1) == "/" then return str end
return dir..str
end

--{1: {source: {1: -2.49744, 2: 2.5}, sourceId: -65536} }
function onInteraction(entity)
    hands = {world.entityHandItem(entity.sourceId, "primary"), world.entityHandItem(entity.sourceId, "alt")}
    PosSpawn = world.entityPosition(entity.sourceId)
    candispense = {}
    for i,v in pairs(hands) do
        local itemInfo = root.itemConfig(v)
        local itemInfo2 = sb.jsonMerge(itemInfo.config, itemInfo.parameters)
        if itemInfo2.compatibleAmmo then
            if type(itemInfo2.compatibleAmmo) == "string" then
                itemInfo2.compatibleAmmo = root.assetJson(procdir(itemInfo2.compatibleAmmo,itemInfo.directory), jarray())
            end
            if itemInfo2.compatibleAmmo[1] then
                table.insert(candispense, itemInfo2.compatibleAmmo[1])
            end
        end
    end
    if #candispense == 0 then
       return 
    end
    local rand = candispense[math.random(1,#candispense)]
    local give = {name = rand, count = 60}
    remaining = remaining - 1
    world.spawnItem(give, PosSpawn)
    save()
end