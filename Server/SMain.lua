houses = {}
loaded = promise.new()

-- Load ESX & DB
Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    while MySQL == nil or ESX == nil do
        Citizen.Wait(0)
    end

    LoadDatabase()
end)

-- This is made only on the start of the script
LoadDatabase = function()
    local house_data = {}
    local result = MySQL.Sync.fetchAll('SELECT * FROM housing_data')
    for k,v in pairs(result) do
        houses[k] = CreateHouse(result[k])
    end
    loaded:resolve()
end

-- This is donde on Sync Interval (only flashes changes into db)
FlashDatabase = function()
    for k,v in pairs(houses) do
        if houses[k].updateDB == true then
            -- Query
            MySQL.Sync.execute('UPDATE housing_data SET data=@data, owner=@owner, keys=@keys, storage=@storage, money=@money, black_money=@black_money WHERE id=@id', {
                ["@data"] = json.encode(houses[k].data),
                ["@owner"] = json.encode(houses[k].owner),
                ["@keys"] = json.encode(houses[k].keys),
                ["@storage"] = json.encode(houses[k].storage),
                ["@money"] = json.encode(houses[k].money),
                ["@black_money"] = json.encode(houses[k].black_money),
            })
            houses[k].updateDB = false
        end
    end
end

ESX.RegisterServerCallback('esx_housing:ReceiveData', function(source, cb)
    cb(houses)
end)

-- Thread to Sync Changes
CreateThread(function()
    Citizen.Await(loaded)
    while true do
        print("Flashing changes to database yes nigga")
        FlashDatabase()
        Wait(Config.SyncInterval * 60 * 1000)
    end
end)
