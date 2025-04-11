local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UPDATE_INSTANCE_INFO")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

-- 延迟初始化函数
local function DelayedInitialization()
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
    
    Utils.CheckAndPrintInstanceDifficulty()
end

f:SetScript("OnEvent", function(self, event, ...)
    -- 延迟0.5秒执行（确保游戏环境完全加载）
    C_Timer.After(0.5, DelayedInitialization)
    
    -- 如果是特定事件可以立即执行部分操作
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        UpdateCharacterItemLevel() -- 装备变化立即更新
    end
end)

-- 登出处理（不需要延迟）
local logoutFrame = CreateFrame("Frame")
logoutFrame:RegisterEvent("PLAYER_LOGOUT")
logoutFrame:SetScript("OnEvent", function()
    OwlSavedInstancesDB._lastLogout = time()
end)