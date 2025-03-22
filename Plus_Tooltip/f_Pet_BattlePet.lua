local e= select(2, ...)


--宠物面板提示
function WoWTools_TooltipMixin:Set_Battle_Pet(tooltip, speciesID, level, breedQuality, maxHealth, power, speed, customName)
    if not speciesID or speciesID < 1 then
        return
    end
    WoWTools_TooltipMixin:Set_Init_Item(tooltip)

    BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')

    local speciesName, speciesIcon, _, companionID, tooltipSource, tooltipDescription, _, _, _, _, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    WoWTools_TooltipMixin:Set_Item_Model(tooltip, {creatureDisplayID=creatureDisplayID})--设置, 3D模型
    --tooltip.itemModel:SetDisplayInfo(creatureDisplayID)
    if obtainable then
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        if numCollected==0 then
            BattlePetTooltipTemplate_AddTextLine(tooltip, format(WoWTools_Mixin.onlyChinese and '已收集（%d/%d）' or ITEM_PET_KNOWN, 0, limit), 1,0,0)
        end
    end
    BattlePetTooltipTemplate_AddTextLine(tooltip, 'speciesID '..speciesID..'    |T'..speciesIcon..':0|t'..speciesIcon)
    BattlePetTooltipTemplate_AddTextLine(tooltip, 'companionID '..companionID..'    displayID '..creatureDisplayID)

    BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')

    local tab = C_PetJournal.GetPetAbilityListTable(speciesID)--技能图标
    table.sort(tab, function(a,b) return a.level< b.level end)
    local abilityIcon=''
    for k, info in pairs(tab) do
        local icon, type = select(2, C_PetJournal.GetPetAbilityInfo(info.abilityID))
        if abilityIcon~='' then
            if k==4 then
                abilityIcon=abilityIcon..'   '
            end
            abilityIcon=abilityIcon..' '
        end
        abilityIcon=abilityIcon..'|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[type]..':0|t|T'..icon..':0|t'..info.level
    end
    BattlePetTooltipTemplate_AddTextLine(tooltip, abilityIcon)

    BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')
    local npcName= WoWTools_TextMixin:CN(nil, {npcID=companionID, isName=true})--中文名称
    if npcName then
        BattlePetTooltipTemplate_AddTextLine(tooltip, npcName)
    end

    local sourceInfo= WoWTools_TextMixin:CN(nil, {speciesID=speciesID}) or {}
    tooltipDescription= sourceInfo[1] or tooltipDescription
    if tooltipDescription then
        BattlePetTooltipTemplate_AddTextLine(tooltip, tooltipDescription, nil, nil, nil, true)--来源提示
    end
    tooltipSource= sourceInfo[2] or tooltipSource
    if tooltipSource then
        BattlePetTooltipTemplate_AddTextLine(tooltip, tooltipSource, nil, nil, nil, true)--来源提示--来源
    end

    --[[if PetJournalSearchBox and PetJournalSearchBox:IsVisible() and IsAltKeyDown() then--设置搜索
        PetJournalSearchBox:SetText(speciesName)
    end]]
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
            ..(WoWTools_Mixin.onlyChinese and '搜索' or SEARCH)..' |A:NPE_Icon:0:0|aAlt'
        )
    end

    if not tooltip.backgroundColor then--背景颜色
        tooltip.backgroundColor=tooltip:CreateTexture(nil,'BACKGROUND')
        tooltip.backgroundColor:SetAllPoints(tooltip)
        tooltip.backgroundColor:SetAlpha(0.15)
    end
    if (breedQuality ~= -1) then--设置背影颜色
        tooltip.backgroundColor:SetColorTexture(ITEM_QUALITY_COLORS[breedQuality].r, ITEM_QUALITY_COLORS[breedQuality].g, ITEM_QUALITY_COLORS[breedQuality].b, 0.15)
    end
    tooltip.backgroundColor:SetShown(breedQuality~=-1)

    local AllCollected, CollectedNum, CollectedText= WoWTools_PetBattleMixin:Collected(speciesID)--收集数量
    tooltip.textLeft:SetText(CollectedNum or '')
    tooltip.text2Left:SetText(CollectedText or '')
    tooltip.textRight:SetText(not CollectedNum and AllCollected or '')

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='npc', id=companionID, name=speciesName, col=nil, isPetUI=true})--取得网页，数据链接
    BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')
    --tooltip:Show()
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

    hooksecurefunc('GameTooltip_AddQuestRewardsToTooltip', function(self)--世界任务ID GameTooltip_AddQuest
        WoWTools_TooltipMixin:Set_Quest(self)
    end)
end







function WoWTools_TooltipMixin:Init_BattlePet()
    Init_BattlePet()
end