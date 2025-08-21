--npc=210759/布莱恩·铜须
local function Set_BrannBronzebeard(tooltip, unit, npcID, size)
    if npcID~='210759' then
        return
    end

    local role= UnitGroupRolesAssigned(unit)
    local left= role~='NONE' and WoWTools_DataMixin.Icon[role] or nil
    local right

    local companionFactionID = C_DelvesUI.GetFactionForCompanion()
    if not companionFactionID then
        return
    end

    local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(companionFactionID)
    if rankInfo and rankInfo.currentLevel and rankInfo.maxLevel then
--等级
        if rankInfo.currentLevel == rankInfo.maxLevel then
            left= (left or '')..format(WoWTools_DataMixin.onlyChinese and '等级 %d' or UNIT_LEVEL_TEMPLATE, rankInfo.currentLevel)
        else
            left= (left or '')..'|cnGREEN_FONT_COLOR:'..format(WoWTools_DataMixin.onlyChinese and '等级 %d/%d' or TOOLTIP_TALENT_RANK, rankInfo.currentLevel, rankInfo.maxLevel)..'|r'

            local repInfo = C_GossipInfo.GetFriendshipReputation(companionFactionID)
            if repInfo and repInfo.nextThreshold and repInfo.standing and repInfo.nextThreshold>0 then
--经验
                left= (left or '')..format('|A:GarrMission_CurrencyIcon-Xp:0:0|a|cnGREEN_FONT_COLOR:%i%%|r', repInfo.standing/repInfo.nextThreshold*100)
--图标
                if repInfo.texture and repInfo.texture>0 then
                    right= '|T'..repInfo.texture..':'..size..'|t'..repInfo.texture
                end
            end
        end
    end

    if left then
        tooltip:AddLine(left)
    end

    tooltip:AddDoubleLine(
        right or ' ',
        'companionFactionID'..WoWTools_DataMixin.Icon.icon2..companionFactionID
    )
end









--设置单位, NPC
function WoWTools_TooltipMixin:Set_Unit_NPC(tooltip, name, unit, guid)
    if WoWTools_FrameMixin:IsLocked(tooltip) or not UnitExists(unit) then
        return
    end

    local textLeft, text2Left, textRight, text2Right=' ', '', '', ''

    --怪物, 图标
    if UnitIsQuestBoss(unit) then--任务
        tooltip.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest')
        tooltip.Portrait:SetShown(true)

    elseif UnitIsBossMob(unit) then--世界BOSS
        text2Left= WoWTools_DataMixin.onlyChinese and '首领' or BOSS
        tooltip.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
        tooltip.Portrait:SetShown(true)
    else
        local classification = UnitClassification(unit)--TargetFrame.lua
        if classification == "rareelite" then--稀有, 精英
            text2Left= WoWTools_DataMixin.onlyChinese and '稀有' or GARRISON_MISSION_RARE
            tooltip.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
            tooltip.Portrait:SetShown(true)

        elseif classification == "rare" then--稀有
            text2Left= WoWTools_DataMixin.onlyChinese and '稀有' or GARRISON_MISSION_RARE
            tooltip.Portrait:SetAtlas('UnitFrame-Target-PortraitOn-Boss-Rare-Star')
            tooltip.Portrait:SetShown(true)
        else
            SetPortraitTexture(tooltip.Portrait, unit)
            tooltip.Portrait:SetShown(true)
        end
    end

    local creatureName=UnitCreatureType(unit)--生物类型
    if creatureName and not creatureName:find(COMBAT_ALLY_START_MISSION) then
        textRight=creatureName--WoWTools_TextMixin:CN(type)翻译出错
    end

    local uiWidgetSet= UnitWidgetSet(unit)
    if uiWidgetSet and uiWidgetSet>0 then
        tooltip:AddLine(WoWTools_DataMixin.Icon.icon2..'uiWidgetSetID '..uiWidgetSet)
    end

    local zone, npc
    if guid then
--位面,NPCID
        npc, zone =  WoWTools_UnitMixin:GetNpcID(unit, guid)
--布莱恩·铜须
        Set_BrannBronzebeard(tooltip, unit, npc, self.iconSize)
        if zone or npc then
            tooltip:AddDoubleLine(
                zone and WoWTools_DataMixin.Player.Language.layer..WoWTools_DataMixin.Icon.icon2..zone,
                npc and 'npcID'..WoWTools_DataMixin.Icon.icon2..npc
            )

            WoWTools_DataMixin.Player.Layer=zone
        end
        self:Set_Web_Link(tooltip, {type='npc', id=npc, name=name, isPetUI=false})--取得网页，数据链接 
    end

    --NPC 中文名称
    local data= WoWTools_TextMixin:CN(nil, {unit=unit, npcID=npc})
    if data then
        textLeft= data[1]
        text2Right= data[2]
    end

    tooltip.textLeft:SetText(textLeft)
    tooltip.text2Left:SetText(text2Left)
    tooltip.textRight:SetText(textRight)
    tooltip.text2Right:SetText(text2Right)

    if not WoWToolsSave['Plus_Tootips'].disabledNPCcolor then
        local r, g, b = select(2, WoWTools_UnitMixin:GetColor(unit, nil))--颜色
        local lineLeft, lineRight
        local tooltipName=tooltip:GetName() or 'GameTooltip'
        for i=1, tooltip:NumLines() do
            lineLeft= _G[tooltipName.."TextLeft"..i]
            if lineLeft then
                lineLeft:SetTextColor(r, g, b)
            end
            lineRight= _G[tooltipName.."TextRight"..i]
            if lineRight and lineRight:IsShown() then
                lineRight:SetTextColor(r, g, b)
            end
        end
        tooltip.textLeft:SetTextColor(r, g, b)
        tooltip.text2Left:SetTextColor(r, g, b)
        tooltip.textRight:SetTextColor(r, g, b)
        tooltip.text2Right:SetTextColor(r, g, b)

        if tooltip.StatusBar then
            tooltip.StatusBar:SetStatusBarColor(r,g,b)
        end
        --self:Set_HealthBar_Unit(GameTooltipStatusBar, unit)--生命条提示
    end

    self:Set_Item_Model(tooltip, {unit=unit, guid=guid})--设置, 3D模型

    self:Set_Width(tooltip)--设置，宽度
    WoWTools_Mixin:Call(GameTooltip_CalculatePadding, tooltip)
end


