function ShowCharacterRoster()
    local sortedChars = Utils.GetCharactersSortedByIlevel()

    local frame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplate")
    frame:SetSize(700, 500)
    frame:SetPoint("CENTER")

    -- 允许拖动（关键设置）
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
      
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  
    local dragRegion = CreateFrame("Frame", nil, frame)
    dragRegion:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    dragRegion:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
    dragRegion:SetHeight(20)
    dragRegion:EnableMouse(true)
    dragRegion:RegisterForDrag("LeftButton")
    dragRegion:SetScript("OnDragStart", function() frame:StartMoving() end)
    dragRegion:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", frame, "TOP", 0, -2) -- 标题位置
    title:SetText("角色装备与副本状态") -- 标题文本

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -30)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)

    -- 内容容器
    local content = CreateFrame("Frame")
    content:SetSize(550, 0)
    scroll:SetScrollChild(content)
    
    -- 表头
    local headers = {
        { text = "角色", width = 200, align = "CENTER", padding = 5 },
        { text = "装等", width = 60, align = "CENTER", padding = 0 },
        { text = "宝匣钥匙", width = 80, align = "CENTER", padding = 0 },
        { text = "宏伟宝库", width = 80, align = "CENTER", padding = 0 },
        { text = "阿梅达希尔", width = 200, align = "CENTER", padding = 0 }
    }
    
    -- 绘制表
    local headerX = 10
    for i, header in ipairs(headers) do
        local h = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        h:SetPoint("TOPLEFT", content, "TOPLEFT", headerX, -10)
        h:SetText(header.text)
        h:SetWidth(header.width)
        h:SetJustifyH(header.align)
        headerX = headerX + header.width + 5
    end
    
    local offsetY = -40
    for _, charInfo in ipairs(sortedChars) do
        
        local charData = charInfo.data
        --DEFAULT_CHAT_FRAME:AddMessage("ResetWeeklyData exec..." .. charData.class)

        local classColor = RAID_CLASS_COLORS[charData.class]
        local nameText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nameText:SetPoint("TOPLEFT", content, "TOPLEFT", 10, offsetY)
        nameText:SetSize(headers[1].width, 20)
        nameText:SetText(format("|cff%.2x%.2x%.2x%s|r-%s", 
            classColor.r*255, classColor.g*255, classColor.b*255,
            charData.name, charData.realm))
        
        local ilvlText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        ilvlText:SetPoint("LEFT", nameText, "RIGHT", 5, 0)
        ilvlText:SetText(string.format("%d", charData.ilevel or 0))
        ilvlText:SetSize(headers[2].width, 20)

        local bunkerKeyCountText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        bunkerKeyCountText:SetPoint("LEFT", ilvlText, "RIGHT", 5, 0)
        local bunkerKeyCount = charData.bunkerKeyCount or 0
        local keyColor = bunkerKeyCount > 5 and "|cffff0000" or "|cffffffff"  -- 大于5=红色，否则白色
        bunkerKeyCountText:SetText(format("%s%d|r", keyColor, bunkerKeyCount))
        bunkerKeyCountText:SetSize(headers[3].width, 20)

        local weekWorldActivitieText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        weekWorldActivitieText:SetPoint("LEFT", bunkerKeyCountText, "RIGHT", 5, 0)
        local weekRaidProgress = charData.weekRaidProgress or 0
        local weekActivitiesProgress = charData.weekActivitiesProgress or 0
        local weekWorldProgress = charData.weekWorldProgress or 0
        local progressString = string.format("%d/%d/%d", weekRaidProgress, weekActivitiesProgress, weekWorldProgress)
        weekWorldActivitieText:SetText(progressString)
        weekWorldActivitieText:SetSize(headers[4].width, 20)
        
        local instanceCol = headers[1].width + headers[2].width + headers[3].width +headers[4].width

        for i, instanceName in ipairs(InstanceList) do
            local status = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            status:SetPoint("LEFT", nameText, "LEFT", instanceCol + (i-1)*(headers[4].width + 5), 0)
            status:SetSize(headers[5].width, 20)
            status:SetJustifyH("CENTER")
            if charData and charData.instances and charData.instances[instanceName] then
                local inst = charData.instances[instanceName]
                -- DEFAULT_CHAT_FRAME:AddMessage("ResetWeeklyData exec..." .. tostring(inst.locked) .. charData.name)
                local color = inst.locked and "|cffff0000已打|r" or "|cff00ff00可打|r"
                --local reset = date("%Y-%m-%d", inst.resetTime or 0)  -- 处理 resetTime 为 nil 的情况
                status:SetText(format("%s", color))
            else
                status:SetText("|cffaaaaaa未知|r")
            end
        end
        
        offsetY = offsetY - 20
    end
    
    content:SetHeight(math.abs(offsetY) + 20)
end

-- 快捷命令（插件的触发条件）
SLASH_ROSTER1 = "/roster"
SlashCmdList["ROSTER"] = ShowCharacterRoster

-- 创建小地图按钮
local minimapButton = CreateFrame("Button", "MyAddonMinimapButton", Minimap, "UIPanelButtonTemplate")
minimapButton:SetSize(25, 25)
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

local icon = minimapButton:CreateTexture(nil, "ARTWORK")
icon:SetTexture("Interface\\AddOns\\Owl\\owl3.tga")
icon:SetSize(20, 20)
icon:SetPoint("CENTER")
icon:SetBlendMode("BLEND")  -- 启用透明
icon:SetVertexColor(1, 1, 1)  -- 确保不偏色


-- 设置按钮的正常、高亮和按下纹理
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
-- 设置按钮的点击事件
minimapButton:SetScript("OnClick", function()
    ShowCharacterRoster()
end)
