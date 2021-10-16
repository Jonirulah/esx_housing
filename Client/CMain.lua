ESX = nil
Houses = {}
loaded = promise.new()
local blips = {}
local view_blips = {}

NewBlip = function(coords, id, owned)
    if owned then
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, 40)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(_U('house_marker') .. " #" .. id)
        EndTextCommandSetBlipName(blip)
        table.insert(blips, blip)
    else
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, 375)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(_U('house_marker') .. " #" .. id)
        EndTextCommandSetBlipName(blip)
        table.insert(view_blips, blip) 
    end       
end

-- Load Core
CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Wait(0)
	end

    Wait(1000)

    ESX.TriggerServerCallback('esx_housing:ReceiveData', function(houses)
        houses_owned = 0
        for k,v in pairs(houses) do
            Houses[k] = CreateHouse(houses[k])
            if Houses[k].owned then
                NewBlip(Houses[k].doorpos, Houses[k].id, true)
                houses_owned = houses_owned + 1
            end
        end

    loaded:resolve()
    end)
end)

RegisterCommand("viewhouses", function()
    if not viewing then
        for k,v in pairs(Houses) do
            Houses[k] = CreateHouse(Houses[k])
            if not Houses[k].owned or Houses[k].owner == '""' then
                NewBlip(Houses[k].doorpos, Houses[k].id)
            end
        end
        viewing = true
    else
        for k,v in pairs(view_blips) do
            RemoveBlip(v)
        end
        viewing = false
    end
end)

-- Draw Markers
Citizen.CreateThread(function()
    Citizen.Await(loaded)
    while true do
        local coords = GetEntityCoords(PlayerPedId())
        Citizen.Wait(0)

        if house_active then
            if house_active.getdistance(coords) < Config.DrawDistance then
                DrawMarker(Config.Marker.Type, house_active.doorpos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Marker.Size.x, Config.Marker.Size.y, Config.Marker.Size.z, Config.Marker.Color.r, 255, Config.Marker.Color.b, 100, false, true, 2, false, false, false, false)
                if Config.Debug then
                    print("House near to " .. house_active.id .. " price " .. house_active.data.price .. "$" .. " owner " .. house_active.owner)
                end

                local distance = house_active.getdistance(coords)
                if distance < 1.5 then
                    if house_active.owned then
                        ESX.ShowHelpNotification(Locales[Config.Locale]["enter_house"])
                        -- Enter to the house
                        if IsControlJustPressed(0,38) then
                            last_coords = coords
                            house_inside = house_active
                            -- While inside house thread
                            CreateThread(function()
                                while house_inside do
                                    local coords = GetEntityCoords(PlayerPedId())
                                    Citizen.Wait(0)
                                    for k,v in pairs(Config.Points[house_inside.data.prop]) do
                                        if #(coords - v) < 5 then
                                            DrawMarker(Config.Marker.Type, v, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Marker.Size.x, Config.Marker.Size.y, Config.Marker.Size.z, Config.Marker.Color.r, 255, Config.Marker.Color.b, 100, false, true, 2, false, false, false, false) 
                                            if #(coords - v) < 1.5 then   
                                                if k == "exit" then
                                                    ESX.ShowHelpNotification(Locales[Config.Locale]["exit_house"])
                                                    if IsControlJustPressed(0, 38) then
                                                        ESX.Game.Teleport(PlayerPedId(), last_coords)
                                                        DoScreenFadeOut(0)
                                                        Wait(300)
                                                        DoScreenFadeIn(200)

                                                    end
                                                elseif k == "storage" then
                                                    ESX.ShowHelpNotification(Locales[Config.Locale]["open_storage"])
                                                    if IsControlJustPressed(0, 38) then
                                                        -- Open Storage Menu
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end)
                            DoScreenFadeOut(0)
                            ESX.Game.Teleport(PlayerPedId(), Config.Points[house_inside.data.prop].exit)
                            Wait(300)
                            DoScreenFadeIn(200)
                        end                        
                    elseif house_active.owner == '""' then
                        -- Check Houses
                        if houses_owned >= Config.MaxHousesperUser then
                            ESX.ShowHelpNotification(Locales[Config.Locale]["exceeded_house"])
                        else
                            ESX.ShowHelpNotification(Locales[Config.Locale]["buy_house"])
                        end
                    else
                        ESX.ShowHelpNotification(Locales[Config.Locale]["already_bought"])
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