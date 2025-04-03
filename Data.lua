local INS_AMDXE= "阿梅达希尔，梦境之愿"

InstanceList = {INS_AMDXE}

SavedInstancesDB = {
    config = {
        trackedInstances = {
            [2547] = true,
        }
    },
    characters = {
        ["PlayerA-Realm1"] = {
            name = "PlayerA",-- 角色名
            realm = "Realm1",-- 服务器
            class = "MAGE", -- 职业
            ilevel = 245.6, -- 装等
            goldCount = 0, -- 账号金币数
            bunkerKeyCount = 0, --总钥匙数
            currentWeekBunkerKeyCount = 0, -- 本周获取的钥匙数
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

function UpdateCharacterItemLevel()
    local _, equippedILvl = GetAverageItemLevel()
    local level = UnitLevel("player")
    if level < 80 then
        return
    end
    local characterData = GetCharacterData()
    characterData.ilevel = math.floor(equippedILvl * 100) / 100
end

function UpdateCharacterBunkerKeyCount()
    local characterData = GetCharacterData()
    local keyCount =  Utils.GetCurrencyAmount(3028)
    characterData.bunkerKeyCount = keyCount 
end

function UpdateInstanceStatus()
    local characterData = GetCharacterData()
    local trackedInstanceName = "阿梅达希尔，梦境之愿"

    for i = 1, GetNumSavedInstances() do
        local name, id, reset, locked = GetSavedInstanceInfo(i)
        if name == trackedInstanceName then
            characterData.instances[name] = characterData.instances[name] or {}
            characterData.instances[name].locked = locked or false
            characterData.instances[name].resetTime = GetServerTime() + (reset or 0)
        end
    end
end

function GetCharacterData()
    local userKey = Utils.GetCharacterKey()
    
    if not SavedInstancesDB.characters[userKey] then
        SavedInstancesDB.characters[userKey] = {
            name = UnitName("player"),
            realm = GetRealmName(),
            class = select(2, UnitClass("player")),
            ilevel = 0,
            itemList = {},
            lastSeen = time(),
            instances = {},
        }
    end

    return SavedInstancesDB.characters[userKey]
end

local function ResetAllCharacters()
    for charKey, charData in pairs(SavedInstancesDB.characters or {}) do
        ResetWeeklyData(charData)
    end
end

function ResetWeeklyData(character)
    local currentWeekStart = GetCurrentWeekStart()

    if character.lastSeen and character.lastSeen >= currentWeekStart then
        return 
    end

    character.currentWeekBunkerKeyCount = 0

    for instanceID, instanceData in pairs(character.instances or {}) do
        if instanceData.resetTime and instanceData.resetTime <= time() then
            character.instances[instanceID] = nil
        end
    end

    character.lastSeen = time()
end

function UpdateBunkerKeyCount(character, newBunkerKeyCount)
    if not character then return end

    local currentWeekStart = GetCurrentWeekStart()

    character.bunkerKeyCount = character.bunkerKeyCount or 0
    character.currentWeekBunkerKeyCount = character.currentWeekBunkerKeyCount or 0

    if not character.lastSeen or character.lastSeen < currentWeekStart then
        character.currentWeekBunkerKeyCount = character.currentWeekBunkerKeyCount + 1
    end

    character.bunkerKeyCount = newBunkerKeyCount

    character.lastSeen = time()
end