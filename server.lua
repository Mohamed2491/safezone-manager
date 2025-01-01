-- Fetch safe zones from the database
lib.callback.register('safezone:getZones', function()
    local result = exports.oxmysql:executeSync("SELECT * FROM safe_zones", {})
    return result
end)

-- Add a new safe zone
RegisterNetEvent('safezone:addZone', function(data)
    exports.oxmysql:insert(
        "INSERT INTO safe_zones (name, x, y, z, radius, show_on_map) VALUES (?, ?, ?, ?, ?, ?)", 
        {data.name, data.x, data.y, data.z, data.radius, data.show_on_map}, 
        function()
            TriggerClientEvent('safezone:refreshZones', -1) -- Notify all clients to refresh zones
        end
    )
end)

-- Update a safe zone
RegisterServerEvent('safezone:updateZone')
AddEventHandler('safezone:updateZone', function(zoneId, data)
    exports.oxmysql:execute('UPDATE safe_zones SET name = @name, x = @x, y = @y, z = @z, radius = @radius, show_on_map = @show_on_map WHERE id = @id', {
        ['@name'] = data.name,
        ['@x'] = data.x,
        ['@y'] = data.y,
        ['@z'] = data.z,
        ['@radius'] = data.radius,
        ['@show_on_map'] = data.show_on_map,
        ['@id'] = zoneId
    }, function(affectedRows)
        TriggerClientEvent('safezone:refreshZones', -1)
    end)
end)

-- Remove a safe zone
RegisterNetEvent('safezone:removeZone', function(id)
    exports.oxmysql:execute(
        "DELETE FROM safe_zones WHERE id = ?", 
        {id}, 
        function()
            TriggerClientEvent('safezone:refreshZones', -1) -- Notify all clients to refresh zones
        end
    )
end)


lib.addCommand(Config.Command, {
    help = 'Open Safezone panel',
    restricted = Config.Permission
}, function(source, raw)
    TriggerClientEvent('safezone:openpanel',source)
end)