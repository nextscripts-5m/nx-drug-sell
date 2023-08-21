local nextCommand   = 0
local findZone      = false

RegisterNetEvent('esx:playerLoaded', function ()
    ESX.RegisterServerCallback('doc_spaccio:getConfig', function(source, cb)
        cb(Config)
    end)
end)

ESX.RegisterServerCallback('doc_spaccio:getConfig', function(source, cb)
    cb(Config)
end)


--- Check if a player can sell drugs
RegisterNetEvent('doc:checkZona', function()

    local xPlayer = ESX.GetPlayerFromId(source)
    local plrPos = xPlayer.getCoords(true)


    for job, phrase in pairs(Config.notAllowedJob) do
    
        if(xPlayer.getJob().name == job) then
            
            xPlayer.showNotification(Config.notAllowedJob[job])
            -- we put it true, for avoiding double notification from the client
            TriggerClientEvent('doc:setZone', source, true, false)
            return
        end
    end
      
    for j,zona in pairs(Config.Zone) do
        
        -- controlliamo di essere in almeno un raggio di una zona
        local distance = #(plrPos - zona.posizione)
        if(distance <= zona.raggio) then


            MySQL.Async.fetchScalar('SELECT nextcm FROM users where identifier = ?', {xPlayer.getIdentifier()}, function (result)
                
                nextCommand = result or 0
            end)
            
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
                
                TriggerClientEvent('doc:nextCommand', source, minutes)
                
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
    
    local xPlayer = ESX.GetPlayerFromId(source)
    local dirtyItem = Config.blackMoney
    local dirtyQuantity = Config.BlackMoneyQuantities[item]
    xPlayer.removeInventoryItem(item, count)
    xPlayer.addInventoryItem(dirtyItem, dirtyQuantity * count)

end)


RegisterNetEvent('doc:updatePlayers', function (zona)
    Config.Zone[zona].limitPlayer = math.max(Config.Zone[zona].limitPlayer - 1, 0)
    print('Limit ' .. Config.Zone[zona].limitPlayer)
end)



