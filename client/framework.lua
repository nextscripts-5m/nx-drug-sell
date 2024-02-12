TriggerServerCallback = function (name, callback, ...)

    if Framework == "ESX" then
        ESX.TriggerServerCallback(name, callback, ...)

    elseif Framework == "QB" then
        QBCore.Functions.TriggerCallback(name, callback, ...)
    end
end

ShowNotification = function (message, type)
    type = type and type or "info"
    if Framework == "ESX" then
        ESX.ShowNotification(message, type)

    elseif Framework == "QB" then
        QBCore.Functions.Notify(message, type, 5000)
    end
end

GetJobFramework = function ()
    if Framework == "ESX" then
        return ESX.PlayerData.job.name
    elseif Framework == "QB" then
        return QBCore.Functions.GetPlayerData().job.name
    end
end