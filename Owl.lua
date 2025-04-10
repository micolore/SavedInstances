local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UPDATE_INSTANCE_INFO")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

f:SetScript("OnEvent", function(self, event, ...)
        CleanDefaultData()

        ResetAllCharacters()

        ResetOwlInstance()

        GetCharacterData()

        UpdateCharacterBunkerKeyCount()

        UpdateCharacterItemLevel()

        UpdateWeekActivitie()
    
        UpdateInstanceStatus()
    
end)


local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function()
    OwlSavedInstancesDB._lastLogout = time()
end)
