local ox_inventory = exports.ox_inventory

if Config.Framework == "esx" then
    Framework = "ESX"
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qb" then
    Framework = "QB"
    QBCore = exports['qb-core']:GetCoreObject()
else
    print("Unsopported Framework")
    return
end

local nextCommand   = 0
local findZone      = false

-- RegisterNetEvent('esx:playerLoaded', function ()
--     ESX.RegisterServerCallback('doc_spaccio:getConfig', function(source, cb)
--         cb(Config)
--     end)
-- end)

-- ESX.RegisterServerCallback('doc_spaccio:getConfig', function(source, cb)
--     cb(Config)
-- end)


--- Check if a player can sell drugs
RegisterNetEvent('doc:checkZona', function()
    local source    = source
    local xPlayer   = GetXPlayer(source)
    local plrPos    = GetPlayerCoords(xPlayer)


    for job, phrase in pairs(Config.notAllowedJob) do
    
        if(GetPlayerJob(xPlayer).name == job) then
            ShowNotification(source, Config.notAllowedJob[job], xPlayer)
            -- we put it true, for avoiding double notification from the client
            TriggerClientEvent('doc:setZone', source, true, false)
            return
        end
    end

    for j,zona in pairs(Config.Zone) do

        -- controlliamo di essere in almeno un raggio di una zona
        local distance = #(plrPos - zona.posizione)
        if(distance <= zona.raggio) then

            local response = MySQL.query.await("SELECT nextcm FROM users WHERE identifier = ?", {GetIdentifier(xPlayer)})

            if response then
                nextCommand = response[1].nextcm or 0
            end

            print('nextcm: ' .. nextCommand)

            if(GetGameTimer() > nextCommand) then
                -- possiamo ripetere il comando

                Config.Zone[j].limitPlayer = Config.Zone[j].limitPlayer + 1
                print('Limit: ' .. Config.Zone[j].limitPlayer)

                if(Config.Zone[j].limitPlayer > Config.PlayerLimit) then
                    TriggerClientEvent('doc:reachedLimitPlayer', source)
                    findZone = true
                    break
                end

                TriggerClientEvent('doc:setZone', source, j, true)

                -- aggiorniamo il nuovo tempo in cui puoi ripetere il comando
                setNextCommandTime(xPlayer)
            else
                --non possiamo ripetere il comando
                local timeToWait = nextCommand - GetGameTimer()
                local minutes = ESX.Math.Round((timeToWait / Config.MINUTE))

                TriggerClientEvent('doc:nextCommand', source, tonumber(minutes))

            end

            findZone = true

        end

    end
    
    -- inviamo una zona nil solo dopo averle confrontate tutte
    if not findZone then 
        TriggerClientEvent('doc:setZone', source, nil, false)
    end
    findZone = false


end)

---Set how often you can repeat the command
function setNextCommandTime(player)    
    local minutes = 4 * Config.MINUTE
    nextCommand = GetGameTimer() + minutes

    MySQL.Async.execute('UPDATE users SET nextcm = (?) WHERE identifier = ?', {
        nextCommand,
        player.getIdentifier(),
    })
end


RegisterNetEvent('doc:removeItem', function (item, count)
    local source    = source
    local xPlayer   = GetXPlayer(source)
    local dirtyItem = Config.blackMoney
    local dirtyQuantity = Config.BlackMoneyQuantities[item]

    if not dirtyQuantity then
        print(("[%s] Item '%s' not setup in config. Player '%s' may be a modder and triggered this event."):format(GetCurrentResourceName(), item, GetIdentifier(xPlayer)))
        return
    end

    local inventoryItem = ox_inventory:GetItem(source, item, nil, false)
    if(not inventoryItem or inventoryItem.count < count) then
        ShowNotification(source, Config.Lang["not-enough"], xPlayer)
        return
    end

    if count > 0 then
        ox_inventory:AddItem(source, dirtyItem, dirtyQuantity * count)
        ox_inventory:RemoveItem(source, item, count)
    end

end)


RegisterNetEvent('doc:updatePlayers', function (zona)
    Config.Zone[zona].limitPlayer = math.max(Config.Zone[zona].limitPlayer - 1, 0)
    print('Limit ' .. Config.Zone[zona].limitPlayer)
end)
