local INS_AMDXE= "阿梅达希尔，梦境之愿"

InstanceList = {INS_AMDXE}

OwlSavedInstancesDB = {
    config = {
        trackedInstances = {
            [2547] = true,
        }
    },
    characters = {
        ["PlayerA-Realm1"] = {
            name = "来福",-- 角色名
            realm = "Realm1",-- 服务器
            class = "MAGE", -- 职业
            ilevel = 123.6, -- 装等
            goldCount = 0, -- 账号金币数
            bunkerKeyCount = 0, --总钥匙数
            currentWeekBunkerKeyCount = 0, -- 本周获取的钥匙数
            weekRaidProgress = 0 ,-- 本周的世界任务（地下堡）完成度
            weekActivitiesProgress = 0, -- 本周地下城完成度
            weekWorldProgress = 0, -- 本周团本完成度
            itemList = {
                [123456] = { -- 物品ID
                    count = 1, -- 本周获取该物品的数量
                    weekStart = 1631235600 -- 本周开始的时间戳
                }
            },
            lastSeen = time(),-- 最后更新时间
            instances = {
                [INS_AMDXE] = {
                    locked = false,-- 副本CD 
                    resetTime = 1631235600,-- 重置时间(下一周)
                    -- difficulty = "史诗"-- 难度
                }
            }
        }
    }
}

function CleanDefaultData()
    if OwlSavedInstancesDB and OwlSavedInstancesDB.characters then
        for fullName, charData in pairs(OwlSavedInstancesDB.characters) do
            if charData.name == "来福" and charData.realm == "Realm1" then
                OwlSavedInstancesDB.characters[fullName] = nil
            end
        end
    end
end

-- 更新角色的装等
function UpdateCharacterItemLevel()
    local _, equippedILvl = GetAverageItemLevel()
    local level = UnitLevel("player")
    if level < 80 then
        return
    end
    local characterData = GetCharacterData()
    characterData.ilevel = tonumber(string.format("%d", math.floor(equippedILvl)))
end

-- 获取修复的宝匣钥匙数量
function UpdateCharacterBunkerKeyCount()
    local characterData = GetCharacterData()
    local keyCount =  Utils.GetCurrencyAmount(3028)
    characterData.bunkerKeyCount = keyCount 
end

function UpdateInstanceStatusOld()
    local characterData = GetCharacterData()
    local trackedInstanceName = "阿梅达希尔，梦境之愿"

    for i = 1, GetNumSavedInstances() do
        local name, id, reset, locked = GetSavedInstanceInfo(i)
        --DEFAULT_CHAT_FRAME:AddMessage("UpdateInstanceStatus exec..." .. tostring(reset) .. name .. characterData.name)
        if name == trackedInstanceName then
            characterData.instances[name] = characterData.instances[name] or {}
            characterData.instances[name].locked = locked or false
            if reset and reset > 0 then
               characterData.instances[name].resetTime = GetServerTime() + reset
            end
        end
    end
end

-- 更新周活跃数据（低保）
function UpdateWeekActivitie()
    local character = GetCharacterData()
    local weekWorldProgress =  Utils:GetLevelDelvesDoneCount()
    local weekActivitiesProgress =  Utils:GetLevelActivitiesDoneCount()
    local weekRaidProgress =  Utils:GetLevelRaidDoneCount()
    character.weekRaidProgress = weekRaidProgress
    character.weekActivitiesProgress = weekActivitiesProgress
    character.weekWorldProgress = weekWorldProgress
end

-- 猫头鹰副本（只测试了史诗版本）
function UpdateInstanceStatus()
    local characterData = GetCharacterData()
    if not characterData.instances then
        characterData.instances = {}
    end

    local currentTime = GetServerTime()
    local trackedInstanceName = "阿梅达希尔，梦境之愿"

    for i = 1, GetNumSavedInstances() do
        local name, _, reset, locked = GetSavedInstanceInfo(i)
        if name and name == trackedInstanceName then
            local instanceData = characterData.instances[name]
            if reset and reset > 0 then
                local newResetTime = currentTime + reset
                if math.abs((instanceData.resetTime or 0) - newResetTime) > 60 then
                    instanceData.resetTime = newResetTime
                    instanceData.locked = locked or false
                end
            else
                instanceData.locked = false
                instanceData.resetTime = 0
            end
        end
    end
end

function GetCharacterData()
    local userKey = Utils.GetCharacterKey()
    local level = UnitLevel("player")
    if level < 80 then
        return
    end

    if not OwlSavedInstancesDB.characters[userKey] then
        OwlSavedInstancesDB.characters[userKey] = {
            name = UnitName("player"),
            realm = GetRealmName(),
            class = select(2, UnitClass("player")),
            ilevel = 0,
            itemList = {},
            lastSeen = time(),
            instances = {},
        }
    end

    return OwlSavedInstancesDB.characters[userKey]
end

-- 重置所有角色的周数据
function ResetAllCharacters()
    for charKey, charData in pairs(OwlSavedInstancesDB.characters or {}) do
        ResetWeeklyData(charData)
    end
end

function ResetWeeklyData(character)
    local currentWeekStart = Utils.GetCurrentWeekStart()

    if character.lastSeen and character.lastSeen >= currentWeekStart then
        --DEFAULT_CHAT_FRAME:AddMessage("ResetWeeklyData fail...")
        return 
    end

    for instanceID, instanceData in pairs(character.instances or {}) do
        if instanceData.resetTime and instanceData.resetTime <= time() then
            if instanceData.resetTime and instanceData.resetTime <= time() then
                instanceData.locked = false  
                instanceData.resetTime = nil
            end
        end
    end
    -- 注意！！！下面的数据重置必须要要先进行登录，否则不清理。
    local currentCharacter = GetCharacterData()
    --DEFAULT_CHAT_FRAME:AddMessage("准备清理宝库数据..."  .. currentCharacter.name )

    if not currentCharacter then
        return
    end
    -- 只能更新当前用户的
    character.lastSeen = time()

    -- 宝库-团本、五人本、世界任务、地下堡
    character.weekRaidProgress = 0
    character.weekActivitiesProgress = 0
    character.weekWorldProgress = 0
    DEFAULT_CHAT_FRAME:AddMessage("清理宝库数据完成..."  .. currentCharacter.name )
end

function ResetOwlInstance()
    
    local currentWeekStart = Utils.GetCurrentWeekStart()
    
    for _, charData in pairs(OwlSavedInstancesDB.characters or {}) do
         if not charData.lastSeen or charData.lastSeen < currentWeekStart then
            if charData.instances then
                for instanceID, instanceInfo in pairs(charData.instances) do
                    instanceInfo.locked = false
                    instanceInfo.resetTime = nil
                end
            end
        end
    end

    local currentCharacter = GetCharacterData()
    if not currentCharacter then
        return
    end
    DEFAULT_CHAT_FRAME:AddMessage("角色最后更新时间..."  .. currentCharacter.name )
    character.lastSeen = time()
end

-- 更新角色的宝匣钥匙数量 
function UpdateBunkerKeyCount(character, newBunkerKeyCount)
    if not character then return end

    local currentWeekStart = Utils.GetCurrentWeekStart()

    character.bunkerKeyCount = character.bunkerKeyCount or 0
    character.currentWeekBunkerKeyCount = character.currentWeekBunkerKeyCount or 0

    if not character.lastSeen or character.lastSeen < currentWeekStart then
        character.currentWeekBunkerKeyCount = character.currentWeekBunkerKeyCount + 1
    end

    character.bunkerKeyCount = newBunkerKeyCount

end

DifficultyMap = {
    [1] = { name = "Normal", type = "party", cn = "普通（5人）" },
    [2] = { name = "Heroic", type = "party", isHeroic = true, cn = "英雄（5人）" },
    [3] = { name = "10 Player", type = "raid", toggleDifficultyID = 5, cn = "10人团队" },
    [4] = { name = "25 Player", type = "raid", toggleDifficultyID = 6, cn = "25人团队" },
    [5] = { name = "10 Player (Heroic)", type = "raid", isHeroic = true, toggleDifficultyID = 3, cn = "10人英雄团队" },
    [6] = { name = "25 Player (Heroic)", type = "raid", isHeroic = true, toggleDifficultyID = 4, cn = "25人英雄团队" },
    [7] = { name = "Looking For Raid", type = "raid", note = "Legacy LFRs prior to SoO", cn = "随机团队（旧版）" },
    [8] = { name = "Mythic Keystone", type = "party", isHeroic = true, isChallengeMode = true, cn = "大秘境" },
    [9] = { name = "40 Player", type = "raid", cn = "40人团队" },
    [11] = { name = "Heroic Scenario", type = "scenario", isHeroic = true, cn = "英雄场景战役" },
    [12] = { name = "Normal Scenario", type = "scenario", cn = "普通场景战役" },
    [14] = { name = "Normal", type = "raid", cn = "普通团队" },
    [15] = { name = "Heroic", type = "raid", displayHeroic = true, cn = "英雄团队" },
    [16] = { name = "Mythic", type = "raid", isHeroic = true, displayMythic = true, cn = "史诗团队" },
    [17] = { name = "Looking For Raid", type = "raid", cn = "随机团队" },
    [18] = { name = "Event", type = "raid", cn = "活动团队" },
    [19] = { name = "Event", type = "party", cn = "活动小队" },
    [20] = { name = "Event Scenario", type = "scenario", cn = "活动场景战役" },
    [23] = { name = "Mythic", type = "party", isHeroic = true, displayMythic = true, cn = "史诗（5人）" },
    [24] = { name = "Timewalking", type = "party", cn = "时空漫游（5人）" },
    [25] = { name = "World PvP Scenario", type = "scenario", cn = "世界PvP场景战役" },
    [29] = { name = "PvEvP Scenario", type = "pvp", cn = "PvEvP战役" },
    [30] = { name = "Event", type = "scenario", cn = "活动场景" },
    [32] = { name = "World PvP Scenario", type = "scenario", cn = "世界PvP场景" },
    [33] = { name = "Timewalking", type = "raid", cn = "时空漫游（团队）" },
    [34] = { name = "PvP", type = "pvp", cn = "PvP战斗" },
    [38] = { name = "Normal", type = "scenario", cn = "普通场景" },
    [39] = { name = "Heroic", type = "scenario", displayHeroic = true, cn = "英雄场景" },
    [40] = { name = "Mythic", type = "scenario", displayMythic = true, cn = "史诗场景" },
    [45] = { name = "PvP", type = "scenario", displayHeroic = true, cn = "PvP英雄场景" },
    [147] = { name = "Normal", type = "scenario", note = "Warfronts", cn = "普通战争前线" },
    [149] = { name = "Heroic", type = "scenario", displayHeroic = true, note = "Warfronts", cn = "英雄战争前线" },
    [150] = { name = "Normal", type = "party", cn = "普通（5人）" },
    [151] = { name = "Looking For Raid", type = "raid", note = "Timewalking", cn = "时空漫游团队副本" },
    [152] = { name = "Visions of N'Zoth", type = "scenario", cn = "恩佐斯的幻象" },
    [153] = { name = "Teeming Island", type = "scenario", displayHeroic = true, cn = "繁盛之岛" },
    [167] = { name = "Torghast", type = "scenario", cn = "托加斯特" },
    [168] = { name = "Path of Ascension: Courage", type = "scenario", cn = "晋升之路：勇气" },
    [169] = { name = "Path of Ascension: Loyalty", type = "scenario", cn = "晋升之路：忠诚" },
    [170] = { name = "Path of Ascension: Wisdom", type = "scenario", cn = "晋升之路：智慧" },
    [171] = { name = "Path of Ascension: Humility", type = "scenario", cn = "晋升之路：谦逊" },
    [172] = { name = "World Boss", type = "none", cn = "世界首领" },
    [192] = { name = "Challenge Level 1", type = "none", cn = "挑战等级1" },
    [205] = { name = "Follower", type = "party", note = "Follower Dungeons", cn = "追随者地下城" },
    [208] = { name = "Delves", type = "scenario", cn = "深渊探索" },
    [216] = { name = "Quest", type = "party", cn = "任务（5人）" },
    [220] = { name = "Story", type = "raid", note = "Story (solo) raid", cn = "剧情（单人团队副本）" },
    [230] = { name = "Heroic", type = "none", displayHeroic = true, cn = "英雄（未分类）" }
}
