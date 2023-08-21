Config = {}

Config.MINUTE = 60 * 1000

-- Limit of players that can sell together
Config.PlayerLimit = 5

-- Drugs item name, you can change it in ox_inventory/data/items.lua
Config.Drugs = {
    'marijuana',
}

-- What receive as money for each piece
Config.BlackMoneyQuantities = {
    ["marijuana"] = 100,
}

-- Maximum quantity to sell for each drug
Config.MaxQuantities = {
    ["marijuana"] = 15
}

-- Command Name
Config.commandName = 'sell'

-- Name of the black money that you receive, you can change it in ox_inventory/data/items.lua
Config.blackMoney = 'black_money'

-- Ox Options
Config.ox_options = {
    label = 'Sell',
    name = 'vendita',
    icon = 'fa-solid fa-eye',
    distance = 1.6,
    event = 'doc:handleSelling',
}

--- ['job_name'] = 'sentence'
Config.notAllowedJob = {
    ['police'] = 'You\'re a cop, you\'re not allowed to deal!',
    ['ambulance'] = 'You are a doctor, you are not authorized to deal!',

}
--- Language configuration
Config.Lang = {
    ['start'] = 'You\'re starting the deal',
    ['denied'] = 'You can\'t deal in this area!',
    ['run_away'] = 'Walk away or they\'ll find you!',
    ['no_drugs'] = 'You have no more drugs to sell!',
    ['terminated'] = 'You are out of the zone!',
    ['w8_minutes'] = 'You have to wait % minutes to repeat the command',
    ['w8_minute']  = 'You have to wait % minute to repeat the command',
    ['w8_seconds'] = 'You have to wait a few more seconds to repeat the command',
    ['reached_limit'] = 'There are too many people who are dealing!',
    ['help_command'] = 'The dealing begins',
    ['not_allowed'] = 'You are not authorized to deal!',
    ['zone'] = ' - Sell Zone'
}

-- Zones
Config.Zone = {
    -- Nord
    Nord = {
        posizione = vector3(243.3969, 2823.6755, 43.6674),
        raggio = 100.0,
        limitPlayer = 0,

        Blip = {
            sprite = 303,
            color = 1,
        },
        
        ---reference https://wiki.rage.mp/index.php?title=Peds
        Peds = {
            {
                model = "u_m_y_paparazzi",
                position = {
                    vector3(214.2264, 2799.7104, 45.6552),
                    vector3(291.6712, 2806.4036, 43.4682),
                },<
            },
            {
                model = "csb_ramp_gang",
                position = {
                    vector3(293.6774, 2838.5105, 43.5037),
                    vector3(261.2799, 2850.8413, 43.5692),
                },
            },
            {
                model = "a_m_m_farmer_01",
                position = {
                    vector3(177.2785, 2801.3123, 45.6552),
                    vector3(222.5159, 2822.5332, 43.7602)
                },
            },
            {
                model = "ig_g",
                position = {
                    vector3(208.8121, 2762.9973, 43.4263),
                    vector3(234.5273, 2742.7603, 43.1947)
                },
            },
            {
                model = "ig_jay_norris",
                position = {
                    vector3(293.5995, 2884.7285, 43.6152),
                },
            },
            {
                model = "a_m_y_ktown_01",
                position = {
                    vector3(239.7126, 2781.5801, 43.7658),
                },
            },
        },

    },

    -- Venezia
    Venezia = {
        posizione = vector3(-1036.1312, -1067.6548, 3.8062),
        raggio = 130.0,
        limitPlayer = 0,

        Blip = {
            sprite = 303,
            color = 1,
        },
        
        ---reference https://wiki.rage.mp/index.php?title=Peds
        Peds = {
            {
                model = "g_m_y_ballaorig_01",
                position = {
                    vector3(-983.1586, -1111.3585, 2.1503),
                    vector3(-1027.3468, -1136.4659, 2.1721),
                },
            },
            {
                model = "csb_ramp_gang",
                position = {
                    vector3(-1049.0049, -1030.0751, 2.0747),
                    vector3(-1096.0999, -1052.7220, 2.1201),
                },
            },
            {
                model = "a_m_m_farmer_01",
                position = {
                    vector3(-1070.0369, -1077.2322, 2.1502),
                    vector3(-1015.3550, -1006.4764, 2.1261)
                },
            },
            {
                model = "ig_g",
                position = {
                    vector3(-958.2629, -1045.8723, 2.1501),
                    vector3(-997.2228, -997.3133, 2.1503)
                },
            },
            {
                model = "ig_jay_norris",
                position = {
                    vector3(-995.8336, -1068.5361, 2.1501),
                },
            },
            {
                model = "a_m_y_ktown_01",
                position = {
                    vector3(-1064.7096, -1107.1256, 2.1496),
                },
            },

        },
    },


}