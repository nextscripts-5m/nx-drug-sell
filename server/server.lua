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


lib.callback.register("drugSell:handleNumberOfPlayers", function (source, zone, amount)
    local players                   = Config.Zone[zone].limitPlayer
    players                         = math.max(players + amount, 0)
    Config.Zone[zone].limitPlayer   = players

    if Config.PlayerLimit > 0 and players > Config.PlayerLimit then
        return false
    end

    return true
end)


lib.callback.register("drugSell:getNumberOfPlayers", function (source, zone)
    return Config.Zone[zone].limitPlayer
end)

lib.callback.register("drugSell:getNumberOfCops", function (source, zone)
    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    return #xPlayers
end)


RegisterNetEvent("drugSell:removeItem", function (item, count, zoneName)
    local source    = source
    local success   = false
    local drugs     = Config.Zone[zoneName].Drugs

    if CheckLoot(drugs, item) then
        success = true
        if count > 0 then
            exports.ox_inventory:RemoveItem(source, item, count)
            local dirtyQuantity = drugs[item].blackMoney
            exports.ox_inventory:AddItem(source, Config.BlackMoneyItem, dirtyQuantity * count)
        end
    end

    if not success then
        print(("%s it's probably a cheater"):format(GetPlayerName(source)))
    end
end)

CheckLoot = function (t, e)
    for k, v in pairs(t) do
        if k == e then
            return true
        end
    end
    return false
end