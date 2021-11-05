CheckCallback = function(found, cb)
    if found then
        if cb then
            return cb(true)
        else
            return true
        end
    else
        if cb then
            return cb(false)
        else
            return false
        end
    end
end

CheckNegativeNumber = function(number)
    if number < 0 then
        return 0
    else
        return number
    end
end

CreateHouse = function(data)
    local self = {}
    self.pendingInvites = {}
    self.id = json.decode(data.id)
    self.data = json.decode(data.data)
    self.storage = json.decode(data.storage) or {}
    self.keys = json.decode(data.keys) or {}
    self.owner = json.decode(data.owner) or ''
    self.doorpos = vector3(self.data.door.x, self.data.door.y, self.data.door.z-1)

    self.updateDB = false
    self.extradata = json.decode(data.extra_data) or {}

    if not self.extradata.instancedMembers then
        self.extradata.instancedMembers = {}
    end
    self.isInstanced = function(license)
        if self.extradata.instancedMembers[license] then
            return true
        else
            return false
        end
    end

    self.hasKeys = function(identifier)
        for k,v in pairs(self.keys) do
            if v == identifier then
                return true
            end
        end
    end

    self.addKeys = function(identifier)
        if not self.hasKeys(identifier) then
            -- print("Giving keys to " .. identifier .. ' on house ' .. self.id)    
            table.insert(self.keys, identifier)
            CheckCallback(true, cb)
            self.updateDB = true
        end
    end

    self.removeItem = function(cb, type, name, count, item)
        data = {
            type = type,
            name = name,
            count = count,
            item = item
        }
        if type == 'weapon' then
            for k,v in pairs(self.storage[type]) do
                if v.name == name and v.count == count then
                    table.remove(self.storage[type], k)
                    -- print('removing weapon ' .. name .. ' x' .. count .. ' bullets')
                    return cb(true)

                end
            end
        else
            if self.storage[type][name] and self.storage[type][name].count >= count then
                self.storage[type][name].count = self.storage[type][name].count - count
                -- print(name .. ' removing  ' .. count)
                return cb(true)
            end
        end
        self.updateDB = true
    end

    self.addItem = function(cb, type, name, count, item)
        data = {
            type = type,
            name = name,
            count = count,
            item = item
        }

        if self.storage[type] == nil then
            self.storage[type] = {}
        end
        
        if type == 'weapon' then
            table.insert(self.storage[type], data)
            -- print('inserting weapon')
            return cb(true)
        else
            if self.storage[type][name] then
                self.storage[type][name].count = self.storage[type][name].count + count
                -- print(name .. ' Already exists, adding to it')
            else
                -- print(name .. ' Does not exist, creating it')
                self.storage[type][name] = data
            end
            return cb(true)
        end
        self.updateDB = true
    end

    self.addInstancedMember = function(license, cb)
        local xPlayer = ESX.GetPlayerFromIdentifier(license)
        if xPlayer then
            self.extradata.instancedMembers[license] = {
                license = xPlayer.getIdentifier(),
            }
            self.updateDB = true
            -- print('Player ' .. src .. ' joined house #'.. self.id .. ' Total players inside: ' .. tostring(#self.instancedMembers))
        end
    end
    
    self.removeInstancedMember = function(license, cb)
        local xPlayer = ESX.GetPlayerFromIdentifier(license)
        self.extradata.instancedMembers[license] = nil
        self.updateDB = true
        -- print('Player ' .. src .. ' leave house #'.. self.id .. ' Total players inside: ' .. tostring(#self.instancedMembers))
    end

    self.getInstancedMembers = function(cb, type)
        if type == 'license' then
            for _, _member in pairs(self.extradata.instancedMembers) do
                cb(_member.license)
            end
        end
    end
    
    self.addInvite = function(src, cb) 
        if not self.pendingInvites[src] then
            local xPlayer = ESX.GetPlayerFromId(src)
            -- print('Added new invite for id: ' .. src)
            self.pendingInvites[src] = {
                src = src,
                name = xPlayer.name
            }
        end
    end

    self.acceptInvite = function(src, cb)
        if self.pendingInvites[src] then
            if GetPlayerPing(src) > 0 then
                TriggerClientEvent('esx_housing:enterHouse', src, self.id)
            end
            self.pendingInvites[src] = nil
        end
    end

    self.getPendingInvites = function(src, cb)
        return self.pendingInvites
    end

    self.reset = function()
        houses[house].storage = {}
        houses[house].keys = {}
        houses[house].owner = ''
        houses[house].money = 0
        houses[house].black_money = 0
        houses[house].extradata.lastTimestamp = {}
        houses[house].extradata.instancedMembers = {}        
        houses[house].updateDB = true
    end
    
    return self
end