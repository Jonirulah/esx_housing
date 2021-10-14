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
    self.id = json.decode(data.id)
    self.data = json.decode(data.data)
    self.storage = json.decode(data.storage)
    self.money = json.decode(data.money)
    self.black_money = json.decode(data.black_money)
    self.keys = json.decode(data.key)
    self.owner = json.decode(data.owner)
    self.updateDB = false

    -- Add house keys to users
    self.addkey = function(identifier, cb)
        table.insert(self.keys, identifier)
        CheckCallback(true, cb)
        self.updateDB = true
    end

    -- Remove house keys to users
    self.removekey = function(identifier, cb)
        local found = false
        for k,v in pairs(self.keys) do
            if v == identifier then
                table.remove(self.keys, k)
                found = true
            end
        end
        CheckCallback(found, cb)
        self.updateDB = true

    end

    -- Add Money to house storage
    self.addmoney = function(type, money, cb)
        if type == "black_money" then
            self.black_money = self.black_money + tonumber(money)
            self.black_money = CheckNegativeNumber(self.black_money)

        else
            self.money = self.money + tonumber(money)
            self.money = CheckNegativeNumber(self.money)
        end
        CheckCallback(true, cb)
        self.updateDB = true

    end

    -- Remove Money to house storage
    self.removemoney = function(type, money, cb)
        if type == "black_money" then
            self.black_money = self.black_money - tonumber(money)
            self.black_money = CheckNegativeNumber(self.black_money)
        else
            self.money = self.money - tonumber(money)
            self.money = CheckNegativeNumber(self.money)
        end
        CheckCallback(true, cb)
        self.updateDB = true
    end



    return self
end