local safeZones = {}
local uiVisible = false
local inSafeZone = false
local currentEditZone = nil

-- Fetch safe zones from the server
local function fetchSafeZones()
    lib.callback('safezone:getZones', false, function(zones)
        safeZones = zones
        SendNUIMessage({ action = "updateZones", zones = safeZones })
    end)
end

-- Check if the player is inside any safe zone
local function isPlayerInSafeZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in pairs(safeZones) do
        if #(playerCoords - vector3(zone.x, zone.y, zone.z)) <= zone.radius then
            return true, zone.name
        end
    end
    return false, nil
end

-- Update text UI for safe zone
local function updateSafeZoneUI()
    local isInZone, zoneName = isPlayerInSafeZone()
    local playerPed = PlayerPedId()
    if isInZone ~= inSafeZone then
        inSafeZone = isInZone
        if inSafeZone then
            ShowSafeZone()
         else
             HideSafeZone()
        end
    end
end

-- Monitor player's position
CreateThread(function()
    while true do
        fetchSafeZones()
        updateSafeZoneUI()
        Wait(500)
    end
end)

RegisterNetEvent('safezone:openpanel', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "toggleUI", state = true })
    fetchSafeZones()
end)

function inSafeZoneui()
	SendNUIMessage({
		action = 'show'
	})
end

function outsideSafeZoneui()
	SendNUIMessage({
		action = 'hide'
	})
end

-- Close UI Callback
RegisterNUICallback('closeUI', function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeUI" , state = false}) 
end)

-- Add Zone Callback
RegisterNUICallback('addZone', function(data)
    TriggerServerEvent('safezone:addZone', data)
end)

-- Edit Zone Callback
RegisterNUICallback('editZone', function(data)
    currentEditZone = data
    print("editZone callback triggered:", json.encode(data))
    SendNUIMessage({ action = "openEditPopup", zone = data })
end)

-- Save Edited Zone Callback
RegisterNUICallback('saveEditedZone', function(data)
   -- print("saveEditedZone callback triggered:", json.encode(data))
    if data.id and data.name and data.x and data.y and data.z and data.radius then
        TriggerServerEvent('safezone:updateZone', data)
    else
        print("Error: Incomplete data received for saving zone.")
    end
end)

-- Remove Zone Callback
RegisterNUICallback('removeZone', function(data)
    TriggerServerEvent('safezone:removeZone', data.id)
    --QBCore.Functions.Notify("All fields are required.", 'error', 2500)
    lib.notify({
        title = 'Safezone',
        description = 'You removed the zone',
        type = 'error'
    })
end)

-- Refresh safe zones when updated
RegisterNetEvent('safezone:refreshZones', function()
    fetchSafeZones()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    fetchSafeZones() 
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SendNUIMessage({ action = "toggleUI", state = false })
        HideSafeZone()
    end
end)

-- Initial fetch of safe zones
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        fetchSafeZones()
    end
end)

RegisterNUICallback('showAlert', function()
    -- Use the message received from the server
    lib.notify({
        title = 'Safezone',
        description = 'All fields are required.',
        type = 'error'
    })
end)

-- Server callback to get player coordinates
RegisterNUICallback('getPlayerCoords', function(_, cb)
    local playerCoords = GetEntityCoords(PlayerPedId())
    cb({
        x = playerCoords.x,
        y = playerCoords.y,
        z = playerCoords.z
    })
end)