


--宠物面板提示
function WoWTools_TooltipMixin:Set_Battle_Pet(tooltip, speciesID, level, breedQuality, maxHealth, power, speed, customName)
    if not speciesID or speciesID < 1 then
        return
    end
    WoWTools_TooltipMixin:Set_Init_Item(tooltip)

    --BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')

    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, _, _, _, _, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    local size= self.iconSize--20

    WoWTools_TooltipMixin:Set_Item_Model(tooltip, {creatureDisplayID=creatureDisplayID})--设置, 3D模型
    --tooltip.itemModel:SetDisplayInfo(creatureDisplayID)
    if obtainable then
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        if numCollected==0 then
            BattlePetTooltipTemplate_AddTextLine(tooltip, format(WoWTools_DataMixin.onlyChinese and '已收集（%d/%d）' or ITEM_PET_KNOWN, 0, limit), 1,0,0)
        end
    end
    BattlePetTooltipTemplate_AddTextLine(tooltip, 'speciesID '..speciesID..'    |T'..speciesIcon..':'..size..'|t'..speciesIcon)
    BattlePetTooltipTemplate_AddTextLine(tooltip, 'companionID '..companionID..'    displayID '..creatureDisplayID)

    BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')

--技能图标
    local abilityIconA, abilityIconB= WoWTools_PetBattleMixin:GetAbilityIcon(speciesID, nil, nil, false, size)
    if abilityIconA and abilityIconB then
        BattlePetTooltipTemplate_AddTextLine(tooltip, abilityIconA)
        BattlePetTooltipTemplate_AddTextLine(tooltip, abilityIconB)
    end

    BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')

    local npcName= WoWTools_TextMixin:CN(nil, {npcID=companionID, isName=true})--中文名称
    if npcName then
        BattlePetTooltipTemplate_AddTextLine(tooltip, npcName)
    end

--Description
    local sourceInfo= WoWTools_TextMixin:CN(nil, {speciesID=speciesID}) or {}
    tooltipDescription= sourceInfo[1] or tooltipDescription
    if tooltipDescription then
        BattlePetTooltipTemplate_AddTextLine(tooltip, tooltipDescription, nil, nil, nil, true)--来源提示
    end

--来源
    tooltipSource= sourceInfo[2] or tooltipSource
    if tooltipSource then
        BattlePetTooltipTemplate_AddTextLine(tooltip, tooltipSource, nil, nil, nil, true)--来源提示--来源
    end

    if obtainable
        and not UnitAffectingCombat('player')
        and (not tooltip.JournalClick or not tooltip.JournalClick:IsShown())
    then
        if IsAltKeyDown() then--宠物手册，设置名称
            WoWTools_LoadUIMixin:Journal(2, {petSpeciesID=speciesID})
        end
        BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')
        BattlePetTooltipTemplate_AddTextLine(tooltip,
            '|TInterface\\Icons\\PetJournalPortrait:0|t'
            ..(WoWTools_DataMixin.onlyChinese and '搜索' or SEARCH)..' |A:NPE_Icon:0:0|aAlt'
        )
    end

--设置背影颜色
    local r,g,b,a
    if (breedQuality ~= -1) then
        r,g,b,a= ITEM_QUALITY_COLORS[breedQuality].r, ITEM_QUALITY_COLORS[breedQuality].g, ITEM_QUALITY_COLORS[breedQuality].b, 0.15
    end
    tooltip:Set_BG_Color(r,g,b,a)


--收集数量
    local AllCollected, CollectedNum, CollectedText= WoWTools_PetBattleMixin:Collected(speciesID)--收集数量
    local text2Right
--强弱
     if petType and PET_TYPE_SUFFIX[petType] then
        local typeTexture= "Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType]
        local strongTexture, weakHintsTexture= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)
        text2Right= '|T'..strongTexture..':'..size..'|t|cnGREEN_FONT_COLOR:<|r|T'..typeTexture..':'..size..':|t|cnRED_FONT_COLOR:>|r|T'..weakHintsTexture..':'..size..'|t'
    end

    tooltip.textLeft:SetText(CollectedNum or '')
    tooltip.text2Left:SetText(CollectedText or '')
    tooltip.textRight:SetText(AllCollected or '')
--强弱
    tooltip.text2Right:SetText(text2Right or '')


    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='npc', id=companionID, name=speciesName, col=nil, isPetUI=true})--取得网页，数据链接

    GameTooltip_CalculatePadding(tooltip)
end





--###########
--宠物面板提示
--###########
local function Init_BattlePet()
    hooksecurefunc("BattlePetToolTip_Show", function(...)--BattlePetTooltip.lua 
        WoWTools_TooltipMixin:Set_Battle_Pet(BattlePetTooltip, ...)
    end)

    hooksecurefunc('FloatingBattlePet_Show', function(...)--FloatingPetBattleTooltip.lua
        WoWTools_TooltipMixin:Set_Battle_Pet(FloatingBattlePetTooltip, ...)
    end)

    hooksecurefunc(GameTooltip, "SetCompanionPet", function(self, petGUID)--设置宠物信息
        local speciesID= petGUID and C_PetJournal.GetPetInfoByPetID(petGUID)
        WoWTools_TooltipMixin:Set_Pet(self, speciesID)--宠物
    end)

    --[[hooksecurefunc('GameTooltip_AddQuestRewardsToTooltip', function(self, questID)--世界任务ID GameTooltip_AddQuest
        WoWTools_TooltipMixin:Set_Quest(self, questID)
    end)]]

    Init_BattlePet=function()end
end







function WoWTools_TooltipMixin:Init_BattlePet()
    Init_BattlePet()
end