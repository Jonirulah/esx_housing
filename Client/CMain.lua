ESX = nil
Houses = {}
loaded = promise.new()

-- Load Core
CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Wait(0)
	end

    Wait(1000)

    ESX.TriggerServerCallback('esx_housing:ReceiveData', function(houses)
        for k,v in pairs(houses) do
            Houses[k] = CreateHouse(houses[k])
        end
    loaded:resolve()
    end)
end)

-- Draw Markers (HOUSE External)
Citizen.CreateThread(function()
    Citizen.Await(loaded)
    while true do
        local coords = GetEntityCoords(PlayerPedId())
        Citizen.Wait(0)

        if house_active then
            if house_active.getdistance(coords) < Config.DrawDistance then

                if house_active.owned or house_active.owner ~= '' then
                    DrawMarker(Config.Marker.Type, house_active.doorpos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Marker.Size.x, Config.Marker.Size.y, Config.Marker.Size.z, Config.Marker.Color.r, 255, Config.Marker.Color.b, 100, false, true, 2, false, false, false, false)
                end

                if Config.Debug then
                    print("House near to " .. house_active.id .. " price " .. house_active.data.price .. "$" .. " owner " .. house_active.owner)
                end

                local distance = house_active.getdistance(coords)
                if distance < 1.5 then
                    if house_active.owned then
                        ESX.ShowHelpNotification(Locales[Config.Locale]["enter_house"])
                        
                    elseif house_active.owner ~= '' then
                        ESX.ShowHelpNotification(Locales[Config.Locale]["buy_house"])
                    end
                end
            else
                house_active = nil
                close = false
            end
        end
        
        if not house_active then
            for k,v in pairs(Houses) do
                if Houses[k].getdistance(coords) <= 15 then
                    house_active = Houses[k]
                    close = true
                end
            end
        end

        if not house_active then
            Wait(1000)
        end
    end
end)