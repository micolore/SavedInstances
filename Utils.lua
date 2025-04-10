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
    -- 获取当前时间
    local currentTime = time()
    
    -- 计算当前是周几（1=周日, 2=周一...7=周六）
    local weekday = tonumber(date("%w", currentTime))  -- %w 返回0-6（0=周日）
    weekday = (weekday == 0) and 7 or weekday  -- 转换为1-7格式
    
    -- 计算本周四00:00的时间戳（魔兽世界每周重置时间是周四）
    local secondsSinceThursday = (weekday >= 5) and (weekday - 5) * 86400 
                               or (weekday + 2) * 86400
    return currentTime - secondsSinceThursday - (currentTime % 86400)
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
