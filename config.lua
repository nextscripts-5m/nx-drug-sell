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

--[[
    NameOfTheZone = {
        position :
        radius :
        limitPlayer : ALWAYS 0
        minimumCops :

        Drugs = {
            nameOfTheDrug = {
                blackMoney : how many black money it gives for each piece of drug
                maxQuantity : the player will sell from 1 to maxQuantity pieces of drug
            }
        }

        Blip = {
            enable : if true, all players can see the blip on map,
            name : blip name on map
            sprite : reference https://docs.fivem.net/docs/game-references/blips/
            color : reference https://docs.fivem.net/docs/game-references/blips/#blip-colors
            display : https://docs.fivem.net/natives/?_0x9029B2F3DA924928
            scale : the scale of the blip on the map
            shortRange : https://docs.fivem.net/natives/?_0xBE8BE4FE60E27B72
            circleColor : https://docs.fivem.net/docs/game-references/blips/#blip-colors
        }

        Peds = {
            "ped_model" : -- reference https://wiki.rage.mp/index.php?title=Peds
        }
    }
]]
Config.Zone = {
    Nord = {
        position        = vector3(243.3969, 2823.6755, 43.6674),
        radius          = 100.0,
        limitPlayer     = 0,
        minimumCops     = 0,

        Drugs   = {
            ['marijuana'] = {
                blackMoney  = 150,
                maxQuantity = 15
            }
        },

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