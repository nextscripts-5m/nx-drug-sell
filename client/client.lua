local canSell           = false
local currentZone       = nil
local _Config              = nil
local hasSelled         = false
local isSpawned         = false
local canMove           = true
local Peds              = {}

---Drug Zone setter
---@param sell boolean tells if we are in a correct zone
RegisterNetEvent('doc:setZone',  function(zone, sell)

    canSell = sell

    -- se siamo in una zona corretta, iniziamo la vendita
    if(canSell) then

        currentZone = zone
        ESX.ShowNotification(_Config.Lang['start'])
        configuraSpaccio(currentZone)

    end

    -- facciamo in modo che questa stampa compaia solo una volta e non per ogni zona
    if zone == nil then
        ESX.ShowNotification(_Config.Lang['denied'])
    end
end)

---Remove all peds in the zone
local removeAllPeds = function()

    Citizen.CreateThread(function ()
        for k, v in ipairs(Peds) do
            removePed(k, false)
        end

    end)
end

local endSession = function ()
    removeAllPeds()
    ESX.ShowNotification(_Config.Lang['run_away'])
    TriggerServerEvent('doc:updatePlayers', currentZone)
end

---Handle peds movement in the zone
---@param zone string the zone where the player is selling
handlePedMovement = function(zone)

    local index = math.random(1, #Peds)
    local ped = Peds[index].ped
    
    -- Se il ped può muoversi, viene verso di noi
    if canMove then
        canMove = false
        TaskGoToEntity(ped, PlayerPedId(), -1, 1.0, 1.49, 0, 0)
        SetPedKeepTask(ped, true)
    end

    -- Finchè non ci arriva un ped vicino non ne facciamo partire un altro
    Citizen.CreateThread(function ()
        while true do
            Wait(500)
            if (checkDistanceBetweenPeds(PlayerPedId(), ped, zone, index)) then
                canMove = true
                break
            end
        end
    end)

    Citizen.CreateThread(function ()
        while true do
            Wait(1000)
            if hasSelled then
                -- aspettiamo qualche secondo per far avvicinare il prossimo ped
                Wait(1500)
                hasSelled = false

                if #Peds > 0 then
                    -- recursive if there are still npc
                    handlePedMovement(zone)
                end

                break
            end
        end
    end)
end

---Check if the player has still drugs to sell
---@param zone string the zone where the player is selling
local checkDrugs = function(zone)
    
    Citizen.CreateThread(function ()
        
        local quantities

        while true do
            
            Wait(1000)
            quantities = 0

            for k, v in ipairs(_Config.Drugs) do
                
                quantities = quantities + exports.ox_inventory:GetItemCount(v)

                -- if v == _Config.Drugs[1] then
                --     marijuanaQuantity = exports.ox_inventory:GetItemCount(v)
                -- end

                -- if v == _Config.Drugs[2] then
                --     eroinaQuantity = exports.ox_inventory:GetItemCount(v)
                -- end
                
            end

            if (quantities == 0) then
                
                ESX.ShowNotification(_Config.Lang['no_drugs'])
                canSell = false
                endSession()
                break
                
            else
                
                if #Peds <= 3 then
                    isSpawned = false
                    Wait(3000)
                    spawnPeds(zone)
                end
                
            end

        end

    end)

end

-- --- Verify if a ped is still alive or not
-- local checkPeds = function()
--     Citizen.CreateThread(function ()
--         while true do
--             Wait(1)
--             for k, v in ipairs(Peds) do
--                 if(IsEntityDead(v.ped)) then
--                     removePed(k, true)
--                 end
--             end
--         end
--     end)
-- end


---Sell configuration
---@param zone string the zone where the player is selling
function configuraSpaccio(zone)

    checkDistance(zone)
    spawnPeds(zone)
    handlePedMovement(zone)
    checkDrugs(zone)
    --checkPeds()

end


local canAddOptions = true
---Spawn peds in the zone
---@param zone string the zone where the player is selling
spawnPeds = function(zone)

    for _, ped in ipairs(_Config.Zone[zone].Peds) do

        for i = 1, #(ped.position), 1 do

            local haskKey = GetHashKey(ped.model)
            RequestModel(haskKey)

            while not HasModelLoaded(haskKey) do
                Citizen.Wait(1)
            end

            -- controllo se il ped è uno tra quelli spawnati, così evito di spawnare lo stesso ped
            for k, v in pairs(Peds) do

                if ped.position[i] == v.position then
                    isSpawned = true
                end
            end


            if not isSpawned then

                local npcSpawn = CreatePed(4, haskKey, ped.position[i], 0.0, false, true)

                -- controllo che un npc non mi spawni attaccato
                local _, distance = checkDistanceBetweenPeds(PlayerPedId(), npcSpawn, zone, 0)

                if distance <= 5 then
                    canAddOptions = false
                end

                local blip = AddBlipForEntity(npcSpawn)
                SetBlipScale(blip, .65)

                table.insert(Peds, { ped = npcSpawn, position = ped.position[i], blip = blip})

                SetEntityHeading(npcSpawn, ped.heading)
                SetPedCombatAttributes(npcSpawn, 0, true)
                SetPedCombatAttributes(npcSpawn, 5, true)
                SetPedCombatAttributes(npcSpawn, 46, true)
                SetPedFleeAttributes(npcSpawn, 0, true)
                SetPedArmour(npcSpawn, 100)
                SetPedMaxHealth(npcSpawn, 100)

                if canAddOptions then
                    exports.ox_target:addLocalEntity(npcSpawn, _Config.ox_options)
                    --Wait(2000)
                else
                    removePed(i, true)
                end

                canAddOptions = true

            end
        end
    end
end



---Check the distance between the player and an npc
---@param xPlayer entity the player that sells drugs
---@param npc entity the npc that buys drugs
---@param zone any the zone name
---@param index any position in the table of xPlayer, set it to 0
function checkDistanceBetweenPeds(xPlayer, npc, zone, index)
    
    Wait(500)

    local playerCoords = GetEntityCoords(xPlayer)
    local npcCoords = GetEntityCoords(npc)
    local distance = #(playerCoords - npcCoords)

    if(distance <= 2.0) then
        return true, distance
    end

    return false, distance
end


---Event Handler for ox_target event
---@param data any datas passed from the ox_options
RegisterNetEvent('doc:handleSelling', function (data)

    if IsEntityDead(data.entity) then
        for k, v in ipairs(Peds) do
            if(IsEntityDead(v.ped)) then
                removePed(k, true)
            end
        end
        ESX.ShowNotification('Non puoi vendere ad un morto!')
        return
    end

    for index, ped in ipairs(Peds) do
        if(ped.ped == data.entity) then
            removePed(index, true)
            break
        end
    end
    
    local drugsQuantity = 0
    local drug

    for k, v in ipairs(_Config.Drugs) do

        local items = exports.ox_inventory:GetItemCount(v)

        -- se ho almeno 1 pezzo di una delle due sostanze, mi salvo la quantità di una delle due ed il nome della sostanza a cui mi riferisco
        if items > drugsQuantity then
            drugsQuantity = items
            drug = v
        end

    end

    if(drugsQuantity > 0) then

        -- possiamo vendere al massimo _Config.MaxQuantity
        local askedQuantity = math.random(1, math.min(_Config.MaxQuantity, exports.ox_inventory:GetItemCount(drug)))

        TriggerServerEvent('doc:removeItem', drug, askedQuantity)

        hasSelled = true

    else
        ESX.ShowNotification(_Config.Lang['no_drugs'])
        canSell = false
        hasSelled = false
        endSession()

    end

    
end)

---Remove one ped from the sell
---@param index number the index of the ped in the Peds table
---@param canRemove boolean if true, we can remove the ped from the Peds table
function removePed(index, canRemove)

    local pedToRemove = Peds[index].ped

    RemoveBlip(Peds[index].blip)

    if canRemove then
        table.remove(Peds, index)
    end
  

    Wait(500)
    -- l'npc va via dopo la vendita
    TaskWanderStandard(pedToRemove, 10.0, 10)
    
    -- dopo lo spaccio non possiamo continuare a vendere a quel NPC
    exports.ox_target:removeLocalEntity(pedToRemove, _Config.ox_options.name)

end


-- local minutes = 2 * MINUTE
-- ---Starts the timer. Quanti <minutes> deve durare la vendita?
-- function startTimer()
--     --print('Puoi spacciare per ' .. ESX.Math.Round(minutes / MINUTE) .. ' minuti')
--     minutes = minutes - 1000
--     -- se è scaduto il tempo, interrompiamo la vendita
--     if(minutes <= 0) then
--         print('Scaduto il tempo')
--         canSell = false
--         endSession()
--     end
-- end



---Check every second if the player is in the zone
---@param zone any the sell zone name
function checkDistance(zone)

    lib.zones.sphere({
        coords = _Config.Zone[zone].posizione,
        radius = _Config.Zone[zone].raggio,
        onExit = function ()
            canSell = false
            ESX.ShowNotification(_Config.Lang['terminated'])
            endSession()
        end
    })
end


---Prints how much time a player need to wait for the next command
---@param minutes number time in minutes
RegisterNetEvent('doc:nextCommand', function (minutes)
    if(minutes > 1) then
        ESX.ShowNotification(_Config.Lang['w8_minutes'], minutes)
    elseif minutes == 1 then
        ESX.ShowNotification(_Config.Lang['w8_minute'], minutes)
    else
        ESX.ShowNotification(_Config.Lang['w8_seconds'])
    end
end)

---Triggered when we reached the max player limits
RegisterNetEvent('doc:reachedLimitPlayer', function ()
    ESX.ShowNotification(_Config.Lang['reached_limit'])
end)


---Set the blipMarker on the map
---@param Zones table config variable
local configureBlips = function(Zones)

    Citizen.CreateThread(function ()
        
        for j, zona in pairs(Zones) do

            local blip = AddBlipForRadius(zona.posizione, zona.raggio)

            SetBlipColour(blip, zona.Blip.color)
            SetBlipAlpha (blip, 128)

            local blip = AddBlipForCoord(zona.posizione)

            SetBlipSprite (blip, zona.Blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale  (blip, 0.6)
            SetBlipColour (blip, 0)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(j .. _Config.Lang['zone'])
            EndTextCommandSetBlipName(blip)

        end
    end)
end


---Get the callback from server
---@param config table config variable
ESX.TriggerServerCallback('doc_spaccio:getConfig', function(config)

    _Config  = config
    configureBlips(_Config.Zone)

    RegisterCommand(_Config.commandName, function()
        TriggerServerEvent('doc:checkZona')
    end)
    TriggerEvent('chat:addSuggestion', '/'.. _Config.commandName, _Config.Lang['help_command'], {})
end)