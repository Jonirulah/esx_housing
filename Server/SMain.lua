
Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    while MySQL == nil or ESX == nil do
        Citizen.Wait(0)
    end

    LoadDatabase()
    
end)

houses = {}

LoadDatabase = function()
    local house_data = {}
    local result = MySQL.Sync.fetchAll('SELECT * FROM housing_data')
    for k,v in pairs(result) do
        houses[k] = CreateHouse(result[k])
    end
    houses[500].removekey("licensenegrata")
end

 