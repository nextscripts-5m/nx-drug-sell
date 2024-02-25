GetNumberOfPlayers = function (zoneName)
    return Config.Zone[zoneName].limitPlayer
end

GetCops = function ()
    if Framework == "ESX" then
        local xPlayers = ESX.GetExtendedPlayers('job', 'police')
        return #xPlayers
    elseif Framework == "QB" then
        local players   = QBCore.Functions.GetQBPlayers()
        local count     = 0
        for k, v in pairs(players) do
            if v.PlayerData.job.name == "police" then
                count += 1
            end
        end
        return count
    end
end