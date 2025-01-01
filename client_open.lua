function ShowSafeZone()
    if Config.Ui == "ui" then
    inSafeZoneui() -- you dont need to do anything here
    elseif Config.Ui == "custom" then
        -- Put your custom code here

    end
end
 
function HideSafeZone()
    if Config.Ui == "ui" then
     outsideSafeZoneui()   -- you dont need to do anything here
    elseif Config.Ui == "custom" then
        -- Put your custom code here

    end
end