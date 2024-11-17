Config = {
    Framework = "esx", -- Options: "esx", "qb-core"

    Notification = {
        System = "mythic_notify", -- Options: "mythic_notify", "okokNotify", "qb-core", "esx", "chat"
        Type = "success", -- Default notification type for rewards
        Duration = 5000 -- Default notification duration for rewards
    },

    Streak = {
        MinKills = 4,
        Timeout = 600, -- In seconds
        Cooldown = 2400, -- In seconds
        SurvivorReward = 500, -- Reward for surviving streak
        BountyReward = 1000 -- Reward for killing streak player
    },

    Blip = {
        Enabled = true, -- Enable/Disable blip system
        Distance = 500.0, -- Distance in meters to show blips
        Sprite = 500, -- Red money bag icon
        Color = 1, -- Red
        Scale = 1.2 -- Blip size
    }
}
