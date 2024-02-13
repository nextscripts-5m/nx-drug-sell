local loaded        = false
local currentZone   = nil
Peds                = {}
InZone              = false

AddEventHandler('onClientResourceStart', function (resource)
    if GetCurrentResourceName() == resource then
        if Framework == "ESX" then
            if not ESX.IsPlayerLoaded() then return end
        elseif Framework == "QB" then
            if not LocalPlayer.state['isLoggedIn'] then return end
        end
        loaded = true
        LoadZones()
        LoadBlips()
    end
end)

PlayerLoaded = function(xPlayer)
    if loaded then return end
    if Framework == "ESX" then
        ESX.PlayerData = xPlayer
    end
    loaded = true
    LoadZones()
    LoadBlips()
end

if Config.Framework == "esx" then
    Framework = "ESX"
    ESX = exports["es_extended"]:getSharedObject()
    RegisterNetEvent("esx:playerLoaded", PlayerLoaded)

    RegisterNetEvent("esx:setJob", function (newJob, lastJob)
        ESX.PlayerData.job = newJob
    end)

elseif Config.Framework == "qb" then
    Framework = "QB"
    QBCore = exports['qb-core']:GetCoreObject()
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded", PlayerLoaded)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
        PlayerData = val
        -- print(QBCore.Debug(PlayerData))
    end)
else
    print("Unsopported Framework")
    return
end


LoadZones = function ()
    CreateThread(function ()

        if not CheckJob(GetJobFramework()) then return end

        for zoneName, zone in pairs(Config.Zone) do

            local coords    = zone.position
            local radius    = zone.radius
            local peds      = zone.Peds
            local cops      = zone.minimumCops

            local point = lib.points.new({
                coords      = coords,
                distance    = radius,
                zoneName    = zoneName,
                peds        = peds,
                cops        = cops
            })

            function point:onEnter()
                currentZone = self.zoneName
                IncreasePlayers(self.zoneName)

                if Config.PlayerLimit > 0 and GetNumberOfPlayers(self.zoneName) > Config.PlayerLimit then
                    ShowNotification(Language["too-players"], "info")
                    return
                end

                if GetCops() < cops then
                    ShowNotification(Language["no-cops"], "info")
                    return
                end

                InZone = true
                SpawnPeds(self.zoneName)
                CheckDrugs(self.zoneName)
            end

            function point:onExit()
                DecreasePlayers(self.zoneName)
                -- print(GetNumberOfPlayers(self.zoneName))
                InZone = false
            end
        end
    end)
end

CheckJob = function (jobName)
    for k, v in pairs(Config.NotAllowedJob) do
        if v == jobName then
            return false
        end
    end
    return true
end

SpawnPeds = function (zoneName)
    CreateThread(function ()
        local zone          = Config.Zone[zoneName]
        local peds          = zone.Peds
        local zoneCenter    = zone.position
        local zoneRadius    = zone.radius

        while true do

            if not InZone then
                break
            end

            if #Peds > 10 then
                Wait(1100)
                goto continue
            end

            local ped           = peds[math.random(#peds)]

            local coords    = GetRandomCoords(zoneCenter, zoneRadius)

            if coords.z == 0 then
                Wait(500)
                goto continue
            end

            local npcEntity = CreatePed(4, joaat(ped),
                coords.x, coords.y, coords.z, 0.0,
                false, -- isNetwork
                true
            )
            local blip      = CreateBlipForEntity(npcEntity)

            if blip == 0 then
                Wait(500)
                goto continue
            end

            table.insert(Peds, {
                zoneName    = zoneName,
                ped         = npcEntity,
                blip        = blip
            })

            AddTargetToEntity(npcEntity, zoneName)
            TaskWanderInArea(npcEntity, coords.x, coords.y, coords.z, zoneRadius + 0.0, 2.0, 4.0)
            SetBlockingOfNonTemporaryEvents(npcEntity, true)

            Wait(Config.SecondsBetweenSpawns * 1000)
            ::continue::
        end
        RemovePeds(zoneName)
        -- print("Ending the spawn")
    end)
    CreateThread(function ()
        while true do

            if not InZone then
                break
            end

            if #Peds >= 3 then
                PickRandomNpc()
                break
            end
            Wait(1000)
        end
    end)
end

PickRandomNpc = function ()
    local npc = Peds[math.random(#Peds)]
    TaskGoToEntity(npc.ped, PlayerPedId(), -1, 1.6, 1.28, 0, 0)
    SetPedKeepTask(npc.ped, true)
end

CheckDrugs = function (zoneName)
    CreateThread(function ()
        local zone          = Config.Zone[zoneName]
        local drugs         = zone.Drugs

        while true do

            if not InZone then
                break
            end

            local quantities    = 0
            for drug, v in pairs(drugs) do
                quantities = quantities + exports.ox_inventory:GetItemCount(drug)
            end

            if quantities == 0 then
                print("Ended Drugs")
                InZone = false
                break
            end

            Wait(1000)
        end
    end)
end

LoadBlips = function ()
    CreateThread(function ()
        for zoneName, zone in pairs(Config.Zone) do
            if zone.Blip.enable then

                local position      = zone.position
                local radius        = zone.radius
                local circleColor   = zone.Blip.circleColor
                local blipSprite    = zone.Blip.sprite
                local blipDisplay   = zone.Blip.display
                local blipScale     = zone.Blip.scale
                local blipColor     = zone.Blip.color
                local blipRange     = zone.Blip.shortRange
                local blipName      = zone.Blip.name

                local blip = AddBlipForRadius(position.x, position.y, position.z, radius)

                SetBlipColour(blip, circleColor)
                SetBlipAlpha (blip, 128)

                blip = AddBlipForCoord(position.x, position.y, position.z)

                SetBlipSprite(blip, blipSprite)
                SetBlipDisplay(blip, blipDisplay)
                SetBlipScale  (blip, blipScale)
                SetBlipColour (blip, blipColor)
                SetBlipAsShortRange(blip, blipRange)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(blipName)
                EndTextCommandSetBlipName(blip)
            end
        end
    end)
end


CreateThread(function ()
    for k, v in pairs(Config.Zone) do
        local peds = v.Peds
        for _, ped in pairs(peds) do
            lib.requestModel(tostring(ped))
        end
    end
end)

CreateThread(function ()
    while true do

        if not InZone then
            break
        end

        for k, v in pairs(Peds) do
            if v.zoneName == currentZone then
                local coords    = GetEntityCoords(v.ped)
                local zone      = Config.Zone[currentZone]

                if #(coords - zone.position) > zone.radius then
                    RemovePed(v.ped)
                end
            end
        end
        -- print("ped:", #Peds, json.encode(Peds))
        Wait(3000)
    end
end)