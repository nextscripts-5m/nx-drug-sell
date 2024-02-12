GetXPlayer = function (source)
    local source = tonumber(source)
    if Framework == "ESX" then
        return ESX.GetPlayerFromId(source)

    elseif Framework == "QB" then
        return QBCore.Functions.GetPlayer(source)
    end
end

ShowNotification = function (source, message, xPlayer)

    if Framework == "ESX" then
        xPlayer.showNotification(message)
    elseif Framework == "QB" then
        TriggerClientEvent('QBCore:Notify', source, message)
    end
end

GetIdentifier = function(xPlayer)
    if Framework == "ESX" then
       return xPlayer.getIdentifier()
    elseif Framework == "QB" then
        return xPlayer.PlayerData.license
    end
end

GetPlayerName = function (xPlayer)
    if Framework == "ESX" then
        return xPlayer.getName()
     elseif Framework == "QB" then
         return xPlayer.PlayerData.name
     end
end

GetPlayerCoords = function (xPlayer, source)
    if Framework == "ESX" then
        return xPlayer.getCoords(true)
     elseif Framework == "QB" then
        local ped = GetPlayerPed(source)
        local coords = QBCore.Functions.GetCoords(ped)
        return vec3(coords.x, coords.y, coords.z)
     end
end

GetPlayerJob = function (xPlayer)
    if Framework == "ESX" then
        return xPlayer.getJob()
     elseif Framework == "QB" then
         return xPlayer.PlayerData.job
     end
end

RegisterCallback = function(name, callback)
    if Framework == "ESX" then
        ESX.RegisterServerCallback(name, callback)

    elseif Framework == "QB" then
        QBCore.Functions.CreateCallback(name, callback)
    end
end

RoundFigures = function (value)
    if Framework == "ESX" then
        return ESX.Math.Round(value)
    elseif Framework == "QB" then
        return math.floor(value + 0.5)
    end
end