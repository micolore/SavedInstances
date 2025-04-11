Utils = Utils or {}

-- 林培风-白银之手
function Utils.GetCharacterKey()
    local name, realm = UnitFullName("player")
    return name .. "-" .. realm
end

-- 判断字符串是否存在于表中
function Utils.isStringInTable(table, str)
    for key, _ in pairs(table) do
        if key == str then
            return true -- 找到了，返回 true
        end
    end
    return false -- 没找到，返回 false
end

function Utils.GetFormattedMoney(money)
    -- 计算金币、银币和铜币
    local gold = floor(money / 1e4) -- 1金币 = 10000铜币
    local silver = floor(money / 100 % 100) -- 1银币 = 100铜币
    local copper = money % 100 -- 剩余的铜币

    -- 返回格式化的字符串
    return ("%dg %ds %dc"):format(gold, silver, copper)
end

-- 定义一个函数来获取指定物品在所有背包中的总数量
function Utils.GetTotalItemQuantity(itemID)
    local totalQuantity = 0
    for bagID = 0, 4 do -- 0 表示主背包，1-4 表示副背包
        local numSlots = GetContainerNumSlots(bagID)
        if numSlots then
            for slot = 1, numSlots do
                local _, itemCount = GetContainerItemInfo(bagID, slot)
                local _, _, _, _, _, _, itemLink = GetContainerItemInfo(bagID, slot)
                local itemIDFromLink = itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
                if itemIDFromLink == itemID and itemCount then
                    totalQuantity = totalQuantity + itemCount
                end
            end
        end
    end
    return totalQuantity
end
-- 获取按 ilevel 排序后的角色列表
function Utils.GetCharactersSortedByIlevel()
    local sorted = {}
    
    for charKey, charData in pairs(OwlSavedInstancesDB.characters) do
        table.insert(sorted, {
            key = charKey,
            name = charData.name,
            ilevel = charData.ilevel or 0,
            data = charData
        })
    end
    
    table.sort(sorted, function(a, b)
        return a.ilevel > b.ilevel  -- 大于号表示降序
    end)
    
    return sorted
end

function Utils.GetCurrencyAmount(currencyID)
    local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if info then
        return info.quantity or 0
    end
    return 0
end

function Utils.GetCurrentWeekStart()
    -- 获取当前时间（服务器时间）
    local currentTime = GetServerTime()  -- 使用魔兽API获取服务器时间，避免本地时区问题
    local serverDate = date("*t", currentTime)  -- 转换为日期表
    
    -- 计算到本周四的天数差（周四=5）
    local daysToThursday = (5 - serverDate.wday) % 7  -- wday范围：1（周日）到7（周六）
    
    -- 计算本周四7:00的时间戳
    local thursdayTime = currentTime - 
                        (serverDate.hour * 3600 + serverDate.min * 60 + serverDate.sec) -  -- 减去当天已过时间
                        daysToThursday * 86400 +                                           -- 减去到周四的天数
                        7 * 3600  -- 加上7小时（7:00 AM）
    
    -- 如果当前时间已过本周四7:00，则返回本周四；否则返回上周四
    if currentTime >= thursdayTime then
        return thursdayTime
    else
        return thursdayTime - 604800  -- 减去7天
    end
end

function Utils.GetLevel8DelvesDoneCount()
    local worldActivities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
    local count = #worldActivities
    for i = 1,count do
        local activity = worldActivities[i]
        -- DEFAULT_CHAT_FRAME:AddMessage("1 exec... threshold: " .. tostring(activity.threshold) .." level: ".. tostring(activity.level) .." progress: ".. tostring(activity.progress))
        if activity and activity.level >= 8 then
            return activity.progress
        end
    end
    return "?"
end

-- 世界任务（地下城）
function Utils.GetLevelDelvesDoneCount()
    local worldActivities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
    local count = #worldActivities
    for i = 1,count do
        local activity = worldActivities[i]
        -- EFAULT_CHAT_FRAME:AddMessage("GetLevelDelvesDoneCount: " .. tostring(activity.progress))
        return activity.progress
    end
    return 0
end

-- 地下城
function Utils.GetLevelActivitiesDoneCount()
    local worldActivities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Activities)
    local count = #worldActivities
    for i = 1,count do
        local activity = worldActivities[i]
        return activity.progress
    end
    return 0
end

function Utils.GetLevelRaidDoneCount()
    local worldActivities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Raid)
    local count = #worldActivities
    for i = 1,count do
        local activity = worldActivities[i]
        return activity.progress
    end
    return 0
end

function Utils:IsWeeklyRewardForDelvesFull()
    local worldActivitiesRewards = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
    local bestReward = worldActivitiesRewards[3]
    return bestReward and bestReward.level == 8 or false
end

-- 是否新的一周第一次登陆（任意角色）
function Utils.IsNewWeekFirstLogin()
    local currentWeekStart = Utils.GetCurrentWeekStart()

    if not OwlSavedInstancesDB.weeklyStart then
        OwlSavedInstancesDB.weekFirstLogin = currentWeekStart;
    end

    local SECONDS_PER_WEEK = 7 * 24 * 60 * 60 
    local currentTime = time()

    -- 记录的首次登录时间加一周时间如果大于当前时间，说明是当前周登录过了，否则就是没登录过。
    if currentTime < OwlSavedInstancesDB.weekFirstLogin + SECONDS_PER_WEEK then
        return false
    else
        OwlSavedInstancesDB.weekFirstLogin = currentWeekStart
        return true
    end
end

-- 当前角色是否首次登录
function Utils.IsUserNewWeekFirstLogin()
    local character = GetCharacterData()
    
    local currentWeekStart = Utils.GetCurrentWeekStart()

    if not character.weekFirstLogin then
        character.weekFirstLogin = currentWeekStart;
        return true
    end
    local SECONDS_PER_WEEK = 7 * 24 * 60 * 60 
    local currentTime = time()

    if currentTime < character.weekFirstLogin + SECONDS_PER_WEEK then
        return false
    else
        character.weekFirstLogin = currentWeekStart
        return true
    end
end