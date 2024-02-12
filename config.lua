Config = {}

-- Supports "esx" and "qb"
Config.Framework = "esx"

-- "en" or "it" are now available
Config.Locales = "en"
Language = Lang[Config.Locales]

-- Limit of players that can sell together. Put 0 if you want no limit
Config.PlayerLimit = 5

Config.BlackMoneyItem = "black_money"

Config.NotAllowedJob = {
    "police",
    "ambulance"
}

-- How many seconds between the spawn of each ped
Config.SecondsBetweenSpawns = 15

Config.Zone = {
    Nord = {
        position        = vector3(243.3969, 2823.6755, 43.6674),
        radius          = 100.0,
        limitPlayer     = 0,
        minimumCops     = 2,

        Drugs   = {
            ['marijuana'] = {
                blackMoney  = 150,
                maxQuantity = 15
            }
        },

        -- reference https://docs.fivem.net/docs/game-references/blips/
        Blip = {
            enable      = true,
            name        = "Nord Zone",
            sprite      = 496,
            color       = 2,
            display     = 4,
            scale       = 0.9,
            shortRange  = false,
            circleColor = 1
        },

        ---reference https://wiki.rage.mp/index.php?title=Peds
        Peds = {
            "u_m_y_paparazzi",
            "csb_ramp_gang",
            "a_m_m_farmer_01",
            "ig_g",
            "ig_jay_norris",
            "a_m_y_ktown_01",
        },

    },
}