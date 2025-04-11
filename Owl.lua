local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UPDATE_INSTANCE_INFO")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

f:SetScript("OnEvent", function(self, event, ...)
     
        -- 清理默认的数据
        CleanDefaultData()
        
        -- 初始化当前角色数据
        GetCharacterData()
        
        -- 更新登陆时间
        UpdateLastSeen()

        -- 清理所有的角色数据（宝库数据）
        ResetAllCharacters()

        -- 重置阿梅达希尔(所有角色)
        ResetOwlInstance()

        -- 更新宝匣钥匙数量
        UpdateCharacterBunkerKeyCount()

        -- 更新角色装等数据
        UpdateCharacterItemLevel()

        -- 更新宝库数据（周长）
        UpdateWeekActivitie()
    
        -- 更新副本状态（阿梅达希尔）
        UpdateInstanceStatus()
    
end)


local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function()
    OwlSavedInstancesDB._lastLogout = time()
end)
