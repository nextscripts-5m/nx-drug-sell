GetNumberOfPlayers = function (zoneName)
    return tonumber(lib.callback.await("drugSell:getNumberOfPlayers", false, zoneName))
end

IncreasePlayers = function (zoneName)
    lib.callback.await("drugSell:handleNumberOfPlayers", false, zoneName, 1)
end

DecreasePlayers = function (zoneName)
    lib.callback.await("drugSell:handleNumberOfPlayers", false, zoneName, -1)
end

GetCops = function ()
    return tonumber(lib.callback.await("drugSell:getNumberOfCops", false))
end

AddTargetToEntity = function (npc, zoneName)
    exports.ox_target:addLocalEntity(npc, {
        label       = 'Sell',
        name        = ("drugSell-%s"):format(npc),
        icon        = 'fa-solid fa-eye',
        distance    = 1.6,
        canInteract = CanInteractWithNpc,
        onSelect    = OnSelectEntity,
        zoneName    = zoneName
    })
end

CanInteractWithNpc = function (entity, distance, coords, name, bone)
    if IsEntityDead(entity) then
        RemovePed(entity)
    end
    return not IsEntityDead(entity)
end

OnSelectEntity = function (data)
    local entity    = data.entity
    local zoneName  = data.zoneName

    RemovePed(entity)
    PickRandomNpc()

    local drugs         = Config.Zone[zoneName].Drugs
    local drug          = nil
    local drugsQuantity = 0

    for k, v in pairs(drugs) do
        local items = exports.ox_inventory:GetItemCount(k)
        if items > drugsQuantity then
            drugsQuantity   = items
            drug            = k
        end
    end

    if drugsQuantity > 0 then

        local maxQuantity   = drugs[drug].maxQuantity
        local asked         = math.random(1, math.min(maxQuantity, exports.ox_inventory:GetItemCount(drug)))
        PedHandshake(entity)
        TriggerServerEvent("drugSell:removeItem", drug, asked, zoneName)
    end
end

RemovePed = function (entity)
    for k, ped in pairs(Peds) do
        if ped.ped == entity then
            RemoveBlip(ped.blip)
            exports.ox_target:removeLocalEntity(ped.ped, ("drugSell-%s"):format(ped.ped))
            RemoveFromTable(k)
        end
    end
end

RemovePeds = function (zoneName)
    for k = #Peds, 1, -1 do
        local ped = Peds[k]
        if ped.zoneName == zoneName then
            exports.ox_target:removeLocalEntity(ped.ped, ("drugSell-%s"):format(ped.ped))
            RemoveBlip(ped.blip)
            RemoveFromTable(k)
        end
    end
end

RemoveFromTable = function (k)
    table.remove(Peds, k)
end

GetRandomCoords = function (center, radius)
    local reducedRadius = radius - (radius * 0.25)
    reducedRadius       = math.min(radius, reducedRadius)

    local radius        = math.random(math.floor(reducedRadius * 0.35), reducedRadius)
    local coords        = center

    local x     = coords.x + math.random(-radius, radius)
    local y     = coords.y + math.random(-radius, radius)
    local _, safeZ, safePosition

    _, safeZ = GetGroundZFor_3dCoord(x, y, coords.z, true)

    safePosition = vector3(x, y, safeZ)

   return safePosition
end

CreateBlipForEntity = function (npc)
    local blip = AddBlipForEntity(npc)
    SetBlipScale(blip, .65)

    SetEntityHeading(npc, 0)
    SetPedCombatAttributes(npc, 0, true)
    SetPedCombatAttributes(npc, 5, true)
    SetPedCombatAttributes(npc, 46, true)
    SetPedFleeAttributes(npc, 0, true)
    SetPedArmour(npc, 100)
    SetPedMaxHealth(npc, 100)
    return blip
end

PedHandshake = function (npcPed)
    local dict = "mp_ped_interaction"
    local flag = "handshake_guy_a"
    lib.requestAnimDict(dict)

    TaskGoToEntity(npcPed, PlayerPedId(), -1, 0.0, 1.49, 0, 0)
    Wait(1000)

    local playerCoords = GetEntityCoords(PlayerPedId(), false)
    local pedCoords = GetEntityCoords(npcPed, false)

    local xDifference = playerCoords.x - pedCoords.x
    local yDifference = playerCoords.y - pedCoords.y

    local newHeading = math.atan(yDifference, xDifference) * (180.0 / math.pi) - 90.0

    SetEntityHeading(PlayerPedId(), newHeading +  180)
    SetEntityHeading(npcPed, newHeading)

    TaskPlayAnim(PlayerPedId(), dict, flag, 8.0, 8.0 , -1, 0, 1, false, false, false )
    TaskPlayAnim(npcPed, dict, flag, 8.0, 8.0 , -1, 0, 1, false, false, false )
    CreateThread(function ()
        while true do
            Wait(2000)
            if not IsEntityPlayingAnim(npcPed, dict, flag, 3) then
                TaskWanderStandard(npcPed, 10.0, 10.0)
            end
        end
    end)
end