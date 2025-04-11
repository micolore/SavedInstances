# shua

## 功能点
角色、装等、副本cd（阿美达希尔）、钥匙、箱子（本周开的次数）

## 参考

* 依赖包
 https://www.wowace.com  

* api 
https://wowpedia.fandom.com/wiki/API_C_CurrencyInfo.GetCurrencyInfo  

* 中文
https://luntan.turtle-wow.org/viewtopic.php?t=663

* logo
https://www.ailogoeasy.com/zh#generate-favicon

### 一些 api
GetItemCount(itemID, "itemName", or "itemLink", [includeBank]) - 返回当前制定的物品在你背包中的数量  
GetItemInfo(itemId or "itemString") - Returns information about an item.  
https://warcraft.wiki.gg/wiki/API_GetMoney  
https://warcraft.wiki.gg/wiki/API_GetInstanceLockTimeRemaining  
https://warcraft.wiki.gg/wiki/API_GetNumSavedInstances 返回锁定的副本？？为什么需要index而不是id？？？
https://warcraft.wiki.gg/wiki/API_GetSavedInstanceInfo  
https://warcraft.wiki.gg/wiki/API_GetInstanceInfo 当前副本  
https://warcraft.wiki.gg/wiki/API_GetContainerItemInfo  
https://warcraft.wiki.gg/wiki/World_of_Warcraft:_The_War_Within 地心之战  
https://warcraft.wiki.gg/wiki/API_GetCurrencyInfo 老版本的获货币的api  
https://warcraft.wiki.gg/wiki/Category:Numeric_IDs 所有id的分类  
https://warcraft.wiki.gg/wiki/CurrencyID 老版本的货币id（有新api）   
https://warcraft.wiki.gg/wiki/InstanceID 副本id  
https://warcraft.wiki.gg/wiki/DifficultyID 副本等级id（普通）  

## 副本id
-- 在游戏中输入以下命令获取最新副本ID
/run for i=1,1000 do local n=GetRealZoneText(i) if n and strfind(n,"阿梅达希尔") then print(i,n) end end  

/run local i,n,d=GetInstanceInfo() print(format("ID:%d 名称:%s 难度:%d",i,n,d))  


## lua 

* 打印数据
 --DEFAULT_CHAT_FRAME:AddMessage("1-instanceId:" .. tostring(id) .. " name:" .. tostring(name) .. " locked:" .. locked )

## 地下堡

https://www.curseforge.com/wow/addons/zamestotv-delves-all-sturdy-chest 插件1

-- Check if weekly reward for delves is full (Level 8) 进度检查
function ZDH_GlobalScripting:IsWeeklyRewardForDelvesFull()
    local worldActivitiesRewards = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
    local bestReward = worldActivitiesRewards[3]
    return bestReward and bestReward.level == 8 or false
end

-- Delve Progress Functions 完成次数（宝库有三个等级，代码看明白了。）
local function GetLevel8DelvesDoneCount()
    local worldActivities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
    for i = 2, 1, -1 do
        local activity = worldActivities[i]
        if activity and activity.level >= 8 then
            return activity.progress
        end
    end
    return "?"
end

-- Key Tracking Functions 获取宝匣钥匙数量（跟我写的有点不一样
local function GetKeyNumber()
    local keys = "|T4622270:20|t Keys: "
    local keyInfos = C_CurrencyInfo.GetCurrencyInfo(3028) -- Delve Key Currency ID
    keys = keys .. (keyInfos.quantity == 0 and "|cFFFF0000" or "") .. keyInfos.quantity .. "|r"
    return keys
end

-- 本周获得的钥匙数量 下面id应该是世界任务完成的标识
local function GetKeyFlags()
    local keysQuestIDs = {84736, 84737, 84738, 84739}
    local keysObtained = 0
    for _, questID in ipairs(keysQuestIDs) do
        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
            keysObtained = keysObtained + 1
        end
    end
    local keyFlags = "Keys this week: " .. keysObtained .. "/4"
    return keyFlags, keysObtained
end

-- Delve List Management 所有的丰腴地下堡list
local DelvesBountifulList = {
    Zones = {
        ["Isle of Dorn"] = { uiMapID = 2248, delves = {{id = 7787, name = "Earthcrawl Mines"}, {id = 7781, name = "Kriegval's Rest"}, {id = 7779, name = "Fungal Folly"}} },
        ["Hallowfall"] = { uiMapID = 2215, delves = {{id = 7789, name = "Skittering Breach"}, {id = 7785, name = "Nightfall Sanctum"}, {id = 7783, name = "The Sinkhole"}, {id = 7780, name = "Mycomancer Cavern"}} },
        ["The Ringing Deeps"] = { uiMapID = 2214, delves = {{id = 7782, name = "The Waterworks"}, {id = 7788, name = "The Dread Pit"}, {id = 8181, name = "Excavation Site 9"}} },
        ["Azj-Kahet"] = { uiMapID = 2255, delves = {{id = 7790, name = "The Spiral Weave"}, {id = 7784, name = "Tak-Rethan Abyss"}, {id = 7786, name = "The Underkeep"}} },
        ["Undermine"] = { uiMapID = 2346, delves = {{id = 8246, name = "Sidestreet Sluice"}} },		
    }
}

function DelvesBountifulList:GetMapAtZoneLevel3(uiMapID)
    local mapInfo = C_Map.GetMapInfo(uiMapID)
    if mapInfo.mapType > 3 and mapInfo.parentMapID > 0 then
        return self:GetMapAtZoneLevel3(mapInfo.parentMapID)
    end
    return uiMapID
end

function DelvesBountifulList:GetBountifulDelves()
    local bountifulDelves, addedDelves = {}, {}
    for _, zoneData in pairs(self.Zones) do
        for _, delve in ipairs(zoneData.delves) do
            if not addedDelves[delve.id] then
                local areaPoiInfo = C_AreaPoiInfo.GetAreaPOIInfo(zoneData.uiMapID, delve.id)
                if areaPoiInfo then
                    table.insert(bountifulDelves, areaPoiInfo)
                    addedDelves[delve.id] = true
                end
            end
        end
    end
    return bountifulDelves
end

-- 应该是世界任务完成之后的钥匙数量+1了
local function UpdateKeyCount()
    local keys = 0
    if C_QuestLog.IsQuestFlaggedCompleted(84736) then keys = keys + 1 end
    if C_QuestLog.IsQuestFlaggedCompleted(84737) then keys = keys + 1 end
    if C_QuestLog.IsQuestFlaggedCompleted(84738) then keys = keys + 1 end
    if C_QuestLog.IsQuestFlaggedCompleted(84739) then keys = keys + 1 end
    frame.text:SetText(keys .. "/4")
end

local function GetCurrentWeek()
    return math.floor((time() / 86400) / 7)  -- 获取当前的"周数"
end

local function ResetWeeklyData()
    local currentWeek = GetCurrentWeek()
    if SavedItemTrackerDB.lastWeek ~= currentWeek then
        SavedItemTrackerDB.weeklyCount = 0  -- 新的一周，重置计数
        SavedItemTrackerDB.lastWeek = currentWeek
    end
end

local function OnItemLooted(self, event, ...)
    local itemID_looted = ...
    if itemID_looted == itemID then
        SavedItemTrackerDB.weeklyCount = (SavedItemTrackerDB.weeklyCount or 0) + 1
    end
end

local function GetWeeklyItemCount()
    ResetWeeklyData()
    return SavedItemTrackerDB.weeklyCount or 0
end