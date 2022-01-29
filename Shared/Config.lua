Config = {} or Config

Config.Locale = 'es'
Config.Debug = true
-- Debug Level 0 enables debug sv-side
-- Debug level 1 enables debug cl-side
-- Debug level 2 enables debug cl-side & sv-side
Config.DebugLevel = 0

Config.Marker = {
    Type = 1,
    Size = {x = 1.1, y = 1.1, z = 0.35},
    Color = {r = 255, g = 0, b = 0},
}

-- Housing Config
Config.OpenMenuKey = "F5" -- Key
Config.DrawDistance = 10 -- Distance to start drawing markers
Config.ResellPrice = 0.6 -- 60% of price paid
Config.DBSyncInterval = 1 -- In minutes, when changes should be flashed to the database.
Config.Points = {
    lowcost = {
        storage = vector3(265.88, -999.44, -100.0),
        exit = vector3(266.2, -1007.52, -102.0),
    },

    mansion = {
        storage = vector3(-174.8, 493.84, 129.04),
        exit = vector3(-174.4, 497.92, 136.64),
    },

    apartment_lowend = {
        storage = vector3(350.64, -993.6, -100.2),
        exit = vector3(346.52, -1013.24, -100.2),
    },

    apartment_midend = {
        storage = vector3(-766.0, 330.96, 195.08),
        exit = vector3(-773.88, 342.12, 195.68),
    },

    small_mansion = {
        storage = vector3(118.92, 566.0, 175.68),
        exit = vector3(117.12, 560.12, 183.32),
    },

    motel = {
        storage = vector3(151.32, -1003.32, -100.0),
        exit = vector3(151.4, -1007.28, -100.0),
    },
}

-- House Pricing
Config.MaxHousesperUser = 2 -- Limit of houses able to buy from a single user
Config.MaxKeysperHouse = 5 -- Limit of keys per house

-- Key Pricing
Config.KeyResetPrice = 1000 -- Price to change the lock and reset
Config.KeyCreationPrice = 500 -- Price for keys to be made

-- Sleep Config
Config.SleepEnabled = true -- Player will respawn in his house on login if he disconnected inside
Config.KickPlayersWithNoKeys = true -- Players that no longer has keys and disconnects in house will be kicked out of the house on login to avoid robbery

-- Automatic House Removal
Config.HouseRemoval = true
Config.HouseRemovalTypes = { -- hours
    lowcost = {
        maxTime = 240 -- 10d
    },

    mansion = {
        maxTime = 360 -- 15d
    },

    apartment_lowend = {
        maxTime = 240 -- 10d
    },

    apartment_midend = {
        maxTime = 360 -- 15d
    },

    small_mansion = {
        maxTime = 360 -- 15d
    },

    motel = {
        maxTime = 168 -- 7d
    },
}
