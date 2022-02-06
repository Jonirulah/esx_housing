houses = {}
loaded = promise.new()
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Load ESX & DB
CreateThread(function()
    while MySQL == nil or ESX == nil do
        Wait(0)
    end
    LoadDatabase()
end)

LoadDatabase = function()
    local house_data = {}
    local result = MySQL.Sync.fetchAll('SELECT * FROM housing_data')
    if Config.Debug and (Config.DebugLevel == 0 or Config.DebugLevel == 2) then
        print('Loaded ' .. #result .. ' houses from the database.')
    end
    for k,v in pairs(result) do
        houses[v.id] = CreateHouse(result[k])
    end
    loaded:resolve()
end

FlashDatabase = function()
    if not restart then
        for k,v in pairs(houses) do
            if houses[v.id].updateDB == true then
                if Config.Debug and (Config.DebugLevel == 0 or Config.DebugLevel == 2) then
                    print('Flashing house ID ' .. houses[v.id].id .. ' to database.')
                end
                -- Query
                MySQL.Sync.execute('UPDATE `housing_data` SET `data`=@data, `owner`=@owner, `keys`=@keys,`storage`=@storage,`extra_data`=@extra_data WHERE id=@id', {
                    ['@id'] = json.encode(houses[v.id].id),
                    ['@data'] = json.encode(houses[v.id].data),
                    ['@owner'] = json.encode(houses[v.id].owner),
                    ['@keys'] = json.encode(houses[v.id].keys),
                    ['@storage'] = json.encode(houses[v.id].storage),
                    ['@extra_data'] = json.encode(houses[v.id].extradata),
                })
                houses[v.id].updateDB = false
            end
        end
    end
end

-- Callbacks
ESX.RegisterServerCallback('esx_housing:ReceiveData', function(source, cb)
    cb(houses)
end)

ESX.RegisterServerCallback('esx_housing:ResetKeys', function(source,cb, house)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    if xPlayer.getIdentifier() == houses[house].owner then
        if xPlayer.getAccount('bank').money >= tonumber(Config.KeyResetPrice) then
            xPlayer.removeAccountMoney('bank', tonumber(Config.KeyResetPrice))
            houses[house].keys = {}
            houses[house].updateDB = true
            TriggerClientEvent('esx_housing:Sync', -1, houses[house])
            return cb(true)
        else
            return cb(false)
        end
    end
end)

ESX.RegisterServerCallback('esx_housing:SellHouse', function(source, cb, house)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    print(houses[house].owner, xPlayer.getIdentifier())
    if houses[house].owner == xPlayer.getIdentifier() then
        -- Kick instanced players from house
        houses[house].getInstancedMembers(function(license)
            local xPlayer = ESX.GetPlayerFromIdentifier(license)
            SetPlayerRoutingBucket(xPlayer.source, 0)
            if Config.Debug and (Config.DebugLevel == 0 or Config.DebugLevel == 2) then
                print('Player ID: ' .. xSource .. ' is getting into dimension ' .. 0)

            end
            xPlayer.triggerEvent('esx_housing:leaveHouse')
        end, 'license')
        houses[house].reset()
        TriggerClientEvent('esx_housing:Sync', -1, houses[house])
        return cb(true)
    end
end)

ESX.RegisterServerCallback('esx_housing:BuyHouse', function(source, cb, house)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    if not houses[house].owner or houses[house].owner == ('' or "") then
        if xPlayer.getAccount('bank').money >= tonumber(houses[house].data.price) then
            xPlayer.removeAccountMoney('bank', tonumber(houses[house].data.price))
            houses[house].owner = xPlayer.getIdentifier()
            houses[house].extradata.lastTimestamp = os.time()
            houses[house].updateDB = true
            TriggerClientEvent('esx_housing:Sync', -1, houses[house])
            return cb(true)
        end
    end
    return cb(false)
end)

ESX.RegisterServerCallback('esx_housing:GetInvites', function(source, cb, houseId)
    cb(houses[houseId].getPendingInvites())
end)

ESX.RegisterServerCallback('esx_housing:GetUserInventory', function(source, cb)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    local inventory = xPlayer.getInventory()
    local money = xPlayer.getAccounts()
    local loadout = xPlayer.getLoadout()
    return cb(inventory, money, loadout)
end)

ESX.RegisterServerCallback('esx_housing:GetStorage', function(source, cb, houseId)
    local xSource = source
    storage = houses[houseId].storage
    elements = {}

    if storage['account'] then
        for k,v in pairs(storage['account']) do
            table.insert(elements, {item = v.name, label = v.item .. ' - '.. v.count..'$' , type = 'account', quantity = v.count, name = v.name})
        end
    end

    if storage['item'] then
        for k,v in pairs(storage['item']) do
            if v.count >= 1 then
                table.insert(elements, {item = v.name,  label = v.item .. ' - x' ..v.count, type = 'item', quantity = v.count, name = v.name})
            end
        end
    end

    if storage['weapon'] then
        for k,v in pairs(storage['weapon']) do
            table.insert(elements, {item = v.name, label = v.item .. ' - ' .. v.count .. Locales[Config.Locale]['bullets'], type = 'weapon', quantity = v.count, name = v.name})
        end
    end

    return cb(elements)
end)

ESX.RegisterServerCallback('esx_housing:createHouseMenu', function(source, cb)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    local privilege = xPlayer.getGroup()
    return cb(privilege)
end)

ESX.RegisterServerCallback('esx_housing:NewHouse', function(source, cb, data)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    local privilege = xPlayer.getGroup()
    if privilege == "mod" or privilege == "admin" or privilege == "superadmin" then
        if data["house_price"] and data["door_coords"] and data["interior_type"] then
            data = CreateNewHouse(data)
            cb(data)
        end
    end
end)

CreateNewHouse = function(data_rcv)
    data2 = {
        data = {
            door = data_rcv["door_coords"],
            price = data_rcv["house_price"],
            prop = data_rcv["interior_type"],
        },
        keys = {},
        storage = {},
        extradata = {},
        owner = '',
    }
    MySQL.Sync.execute('INSERT INTO housing_data (data) VALUES (@data)', {
        ['@data'] = json.encode(data2.data),
    })

    local result = MySQL.Sync.fetchAll("SELECT * FROM housing_data WHERE id=(SELECT max(id) FROM housing_data)")
    houses[result[1].id] = CreateHouse(result[1])
    if Config.Debug and (Config.DebugLevel == 0 or Config.DebugLevel == 2) then
        print("A new house has been created ID " .. houses[result[1].id].id)
    end
    TriggerClientEvent("esx_housing:Sync", -1, houses[result[1].id])
    return houses[result[1].id]
end

-- Register Events
RegisterNetEvent('esx_housing:addItem', function(type, name, count, item, houseId)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    local identifier = xPlayer.getIdentifier()
    if Config.Debug and (Config.DebugLevel == 0 or Config.DebugLevel == 2) then
        print('Player ID: ' .. xSource .. ' is inserting item ' .. name .. ' x' .. count .. ' into house ' .. houses[houseId].id)
    end

    if houses[houseId].isInstanced(identifier) then
        -- houses[houseId].addItem(type, name, count, item)
        houses[houseId].addItem(function(result)
            if result then
                RemovePlayerItem(xSource, type, name, item, count)
            end
        end, type, name, count, item)
        houses[houseId].updateDB = true
    end

end)

RegisterNetEvent('esx_housing:removeItem', function(type, name, count, item, houseId)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    local identifier = xPlayer.getIdentifier()
    if Config.Debug and (Config.DebugLevel == 0 or Config.DebugLevel == 2) then
        print('Player ID: ' .. xSource .. ' is removing item ' .. name .. ' x' .. count .. ' into house ' .. houses[houseId].id)
    end
    if houses[houseId].isInstanced(identifier) then
        -- Add check count if
        if type == 'weapon' then
            if xPlayer.hasWeapon(name) then
                TriggerClientEvent('esx:showNotification', xSource, Locales[Config.Locale]['already_has_weapon'])
                return
            end
        end
        houses[houseId].removeItem(function(result)
            if result then
                AddPlayerItem(xSource, type, name, item, count)
            end

        end, type, name, count, item)
        houses[houseId].updateDB = true
    end

end)

AddPlayerItem = function(source, type, name, item, count)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    if type == 'account' then
        xPlayer.addAccountMoney(name, count)
    elseif type == 'item' then
        xPlayer.addInventoryItem(name, count)
    elseif type == 'weapon' then
        xPlayer.addWeapon(name, count)
    end
    Notification(xSource, 'withdraw', item, count)

end

RemovePlayerItem = function(source, type, name, item, count)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    if type == 'account' then
        xPlayer.removeAccountMoney(name, count)
    elseif type == 'item' then
        xPlayer.removeInventoryItem(name, count)
    elseif type == 'weapon' then
        xPlayer.removeWeapon(name)
    end
    Notification(xSource, 'deposit', item, count)
end

Notification = function(source, action, name, count)
    if action == 'deposit' then
        TriggerClientEvent('esx:showNotification', source, Locales[Config.Locale]['deposit_success'] .. name .. ' x' .. count)
    else
        TriggerClientEvent('esx:showNotification', source, Locales[Config.Locale]['withdraw_success'] .. name .. ' x' .. count)
    end
end

RegisterNetEvent('esx_housing:addKeys', function(house, id)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    local identifier = xPlayer.getIdentifier()
    if houses[house].owner == identifier then
        if xPlayer.getAccount('bank').money >= tonumber(Config.KeyResetPrice) then
            xPlayer.removeAccountMoney('bank', tonumber(Config.KeyResetPrice))
            if Config.Debug and (Config.DebugLevel == 0 or Config.DebugLevel == 2) then
                print('Giving keys to player ' .. id .. ' on house ' .. house.id)
            end
            local zPlayer = ESX.GetPlayerFromId(id)
            local zIdentifier = zPlayer.getIdentifier()
            houses[house].addKeys(zIdentifier)
        end
        TriggerClientEvent('esx_housing:Sync', -1, houses[house])
    end
end)

RegisterNetEvent('esx_housing:playerEnterHouse', function(houseId)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    houses[houseId].addInstancedMember(xPlayer.getIdentifier())
    houses[houseId].extradata.lastTimestamp = os.time()
    if Config.Debug and (Config.DebugLevel == 0 or Config.DebugLevel == 2) then
        print('Player ID: ' .. xSource .. ' is getting into dimension ' .. houses[houseId].id)
    end
    SetPlayerRoutingBucket(xSource, tonumber(houses[houseId].id))
    SetRoutingBucketPopulationEnabled(tonumber(houses[houseId].id), false)
end)

RegisterNetEvent('esx_housing:playerExitHouse', function(houseId)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    houses[houseId].removeInstancedMember(xPlayer.getIdentifier())
    if Config.Debug and (Config.DebugLevel == 0 or Config.DebugLevel == 2) then
        print('Player ID: ' .. xSource .. ' is getting into dimension ' .. 0)
    end
    SetPlayerRoutingBucket(xSource, 0)
end)

RegisterNetEvent('esx_housing:AcceptInvite', function(houseId, playerId)
    local xSource = source
    local xPlayer = ESX.GetPlayerFromId(xSource)
    if houses[houseId].owner == xPlayer.getIdentifier() then
        houses[houseId].acceptInvite(playerId)
    end
end)

RegisterNetEvent('esx_housing:Ring', function(houseId)
    local xSource = source
    local house = houses[houseId]
    if house then
        house.addInvite(xSource)
        house.getInstancedMembers(function(license)
            local xPlayer = ESX.GetPlayerFromIdentifier(license)
            xPlayer.triggerEvent('esx_housing:Ring', xSource)
        end, 'license')
    else
        error('Failed to ring house with ID:' .. houseId)
    end
end)

-- Thread to Sync Changes
CreateThread(function()
    Citizen.Await(loaded)
    while true do
        FlashDatabase()
        Wait(Config.DBSyncInterval * 60 * 1000)
    end
end)

-- House removal thread on start
CreateThread(function()
    Citizen.Await(loaded)
    if Config.HouseRemoval then
        for k,v in pairs(houses) do
            maxTime = os.time() + (Config.HouseRemovalTypes[v.data.prop].maxTime * 3600)
            if type(v.extradata.lastTimestamp) == 'number' then
                if v.extradata.lastTimestamp >= maxTime then
                    houses[house].reset()
                end
            end
        end
    end
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
	if eventData.secondsRemaining == 60 then
		CreateThread(function()
			Wait(35000)
			FlashDatabase()
            restart = true
		end)
	end
end)