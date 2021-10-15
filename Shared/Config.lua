Config = {} or Config

Config.Locale = 'es'
Config.Debug = true

Config.Marker = {
    Type = 1,
    Size = {x = 1.1, y = 1.1, z = 0.35},
    Color = {r = 255, g = 0, b = 0},
}

-- Housing Config
Config.DrawDistance = 15 -- Distance to start drawing markers
Config.ResellPrice = 60 -- 60% of price paid
Config.SyncInterval = 5 -- In minutes
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
        exit = vector3(151.4, -1007.28, -99.8), 
    },

    camper = {
        storage = vector3(90.76, 3752.36, 39.76),
        exit = vector3(93.4, 3750.72, 39.76), 
    }

}

-- patera -> low cost
-- mediumapart -> apartment_lowend
-- eclipserojo -> apartment_midend
-- eclipse -> apartment_midend
-- motel_casa -> motel
-- caravana -> camper

-- House Pricing   
Config.MaxHousesperUser = 2 -- Limit of houses able to buy from a single user

-- Key Pricing
Config.MaxKeysperHouse = 5 -- Maximum keys allowed to be created
Config.KeySwappingPrice = 1000 -- Price to change the lock and reset 
Config.KeyCreationPrice = 500 -- Price for keys to be made
