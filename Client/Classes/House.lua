Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    while ESX == nil do
        Citizen.Wait(0)
    end
    
    local xPlayer = ESX.GetPlayerData()
    identifier = xPlayer.identifier
end)

CheckNegativeNumber = function(number)
    if number < 0 then
        return 0
    else
        return number
    end
end

CreateHouse = function(data)
    local self = {}
    self.id = data.id
    self.data = data.data
    self.storage = data.storage
    self.money = data.money
    self.black_money = data.black_money
    self.keys = data.keys
    self.owner = data.owner 
    self.owned = false
    self.doorpos = vector3(self.data.door.x, self.data.door.y, self.data.door.z-1)

    if self.owner == identifier then
        self.owned = true
    end

    self.getdistance = function(coords)
        local coords = vector3(coords.x, coords.y, coords.z)
        return #(coords - self.doorpos)
    end

    return self
end