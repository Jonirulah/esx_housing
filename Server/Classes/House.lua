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

CreateHouse = function(data)
    local self = {}
    self.id = json.decode(data.id)
    self.data = json.decode(data.data)
    self.storage = json.decode(data.storage)
    self.money = json.decode(data.money)
    self.black_money = json.decode(data.black_money)
    self.keys = json.decode(data.key)
    self.owner = json.decode(data.owner)

    self.addkey = function(identifier)
        table.insert(self.keys, identifier)
    end

    self.removekey = function(identifier, cb)
        local found = false
        for k,v in pairs(self.keys) do
            if v == identifier then
                table.remove(self.keys, k)
                found = true
            end
        end
        CheckCallback(found, cb)
    end

    return self
end