local blips = {}
local streakPlayers = {}
local playerCoords = nil

-- Notification handler
local function sendNotification(message, type, duration)
    type = type or Config.Notification.Type
    duration = duration or Config.Notification.Duration

    if Config.Notification.System == "mythic_notify" then
        exports['mythic_notify']:SendAlert(type, message, duration)
    elseif Config.Notification.System == "okokNotify" then
        exports['okokNotify']:Alert("Bounty System", message, duration, type)
    elseif Config.Notification.System == "qb-core" then
        QBCore.Functions.Notify(message, type, duration)
    elseif Config.Notification.System == "esx" then
        ESX.ShowNotification(message)
    else
        TriggerEvent('chat:addMessage', { args = {"Bounty System", message} })
    end
end

-- Create a blip for a streak player
local function createBlip(playerId, coords)
    if not Config.Blip.Enabled then return end
    if blips[playerId] then RemoveBlip(blips[playerId]) end

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.Blip.Sprite)
    SetBlipColour(blip, Config.Blip.Color)
    SetBlipScale(blip, Config.Blip.Scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Bounty Target")
    EndTextCommandSetBlipName(blip)
    blips[playerId] = blip
end

-- Remove a player's blip
local function removeBlip(playerId)
    if blips[playerId] then
        RemoveBlip(blips[playerId])
        blips[playerId] = nil
    end
end

-- Update blips based on proximity
local function updateBlips()
    if not Config.Blip.Enabled then return end
    playerCoords = GetEntityCoords(PlayerPedId())

    for playerId, data in pairs(streakPlayers) do
        local targetCoords = data.coords
        local distance = #(playerCoords - vector3(targetCoords.x, targetCoords.y, targetCoords.z))

        if distance <= Config.Blip.Distance then
            if not blips[playerId] then
                createBlip(playerId, targetCoords)
            end
        else
            removeBlip(playerId)
        end
    end
end

-- Streak-related events
RegisterNetEvent('bounty:markPlayer', function(playerId, coords)
    streakPlayers[playerId] = { coords = coords }
end)

RegisterNetEvent('bounty:updatePlayerCoords', function(playerId, coords)
    if streakPlayers[playerId] then
        streakPlayers[playerId].coords = coords
    end
end)

RegisterNetEvent('bounty:endStreak', function(playerId)
    removeBlip(playerId)
    streakPlayers[playerId] = nil
end)

-- Periodically update blips
CreateThread(function()
    while true do
        Wait(1000)
        updateBlips()
    end
end)
