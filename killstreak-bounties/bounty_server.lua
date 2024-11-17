ESX = nil
QBCore = nil

-- Framework initialization
CreateThread(function()
    if Config.Framework == "esx" and GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
    elseif Config.Framework == "qb-core" and GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    else
        print("^1ERROR: No valid framework found! Check config.lua.^0")
    end
end)

local killStreaks = {}
local killTimes = {}
local cooldowns = {}
local activeRewards = {}

-- Reward a player with money and notify them
local function rewardPlayer(source, amount)
    local success = false
    if Config.Framework == "esx" and ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addMoney(amount)
            success = true
        end
    elseif Config.Framework == "qb-core" and QBCore then
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            player.Functions.AddMoney('cash', amount)
            success = true
        end
    end

    -- Send notification if reward was successfully added
    if success then
        local message = "You received $" .. amount .. "!"
        local notifyType = Config.Notification.Type or "success"
        local notifyDuration = Config.Notification.Duration or 5000

        if Config.Notification.System == "mythic_notify" then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = notifyType, text = message, length = notifyDuration })
        elseif Config.Notification.System == "okokNotify" then
            TriggerClientEvent('okokNotify:Alert', source, "Bounty System", message, notifyDuration, notifyType)
        elseif Config.Notification.System == "qb-core" then
            TriggerClientEvent('QBCore:Notify', source, message, notifyType, notifyDuration)
        elseif Config.Notification.System == "esx" then
            TriggerClientEvent('esx:showNotification', source, message)
        else
            TriggerClientEvent('chat:addMessage', source, { args = {"Bounty System", message} })
        end
    end
end

-- Handle player kills and streaks
RegisterNetEvent('bounty:playerDied', function(victimId)
    local victim = tonumber(victimId)
    local killer = source
    if not killer or not victim or killer == victim then return end

    killStreaks[killer] = (killStreaks[killer] or 0) + 1

    if killStreaks[killer] == Config.Streak.MinKills then
        TriggerClientEvent('bounty:startStreak', killer)
        local coords = GetEntityCoords(GetPlayerPed(killer))
        TriggerClientEvent('bounty:markPlayer', -1, killer, coords)

        CreateThread(function()
            while killStreaks[killer] do
                Wait(5000)
                local updatedCoords = GetEntityCoords(GetPlayerPed(killer))
                TriggerClientEvent('bounty:updatePlayerCoords', -1, killer, updatedCoords)
            end
        end)

        activeRewards[killer] = 'survivor'
        SetTimeout(Config.Streak.Timeout * 1000, function()
            if killStreaks[killer] then
                rewardPlayer(killer, Config.Streak.SurvivorReward)
                killStreaks[killer] = nil
            end
        end)
    end

    if killStreaks[victim] then
        TriggerClientEvent('bounty:endStreak', -1, victim)
        rewardPlayer(killer, Config.Streak.BountyReward)
        killStreaks[victim] = nil
    end
end)
