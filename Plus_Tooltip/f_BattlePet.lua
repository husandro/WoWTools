local e= select(2, ...)


--宠物面板提示
function WoWTools_TooltipMixin:Set_Battle_Pet(frame, speciesID, level, breedQuality, maxHealth, power, speed, customName)
    if not speciesID or speciesID < 1 then
        return
    end
    WoWTools_TooltipMixin:Set_Init_Item(frame)

    local speciesName, speciesIcon, _, companionID, tooltipSource, tooltipDescription, _, _, _, _, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    WoWTools_TooltipMixin:Set_Item_Model(frame, {creatureDisplayID=creatureDisplayID})--设置, 3D模型
    --frame.itemModel:SetDisplayInfo(creatureDisplayID)
    if obtainable then
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        if numCollected==0 then
            BattlePetTooltipTemplate_AddTextLine(frame, format(e.onlyChinese and '已收集（%d/%d）' or ITEM_PET_KNOWN, 0, limit), 1,0,0)
        end
    end
    BattlePetTooltipTemplate_AddTextLine(frame, (e.onlyChinese and '宠物' or PET)..' '..speciesID..'                  |T'..speciesIcon..':0|t'..speciesIcon)
    BattlePetTooltipTemplate_AddTextLine(frame, 'NPC '..companionID..'                  '..(e.onlyChinese and '模型' or MODEL)..' '..creatureDisplayID)

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
    BattlePetTooltipTemplate_AddTextLine(frame, abilityIcon)

    local npcName= e.cn(nil, {npcID=companionID, isName=true})--中文名称
    if npcName then
        BattlePetTooltipTemplate_AddTextLine(frame, npcName)
    end

    local sourceInfo= e.cn(nil, {speciesID=speciesID}) or {}
    tooltipDescription= sourceInfo[1] or tooltipDescription
    if tooltipDescription then
        BattlePetTooltipTemplate_AddTextLine(frame, tooltipDescription, nil, nil, nil, true)--来源提示
    end
    tooltipSource= sourceInfo[2] or tooltipSource
    if tooltipSource then
        BattlePetTooltipTemplate_AddTextLine(frame, tooltipSource, nil, nil, nil, true)--来源提示--来源
    end

    --[[if PetJournalSearchBox and PetJournalSearchBox:IsVisible() and IsAltKeyDown() then--设置搜索
        PetJournalSearchBox:SetText(speciesName)
    end]]
    if obtainable then
        if IsAltKeyDown() then--宠物手册，设置名称
            WoWTools_LoadUIMixin:Journal(2, {petSpeciesID=speciesID})
        end
        BattlePetTooltipTemplate_AddTextLine(frame, ' ')
        BattlePetTooltipTemplate_AddTextLine(frame,
            '|TInterface\\Icons\\PetJournalPortrait:0|t'
            ..(e.onlyChinese and '搜索' or SEARCH)..' |A:NPE_Icon:0:0|aAlt'
        )
    end

    if not frame.backgroundColor then--背景颜色
        frame.backgroundColor=frame:CreateTexture(nil,'BACKGROUND')
        frame.backgroundColor:SetAllPoints(frame)
        frame.backgroundColor:SetAlpha(0.15)
    end
    if (breedQuality ~= -1) then--设置背影颜色
        frame.backgroundColor:SetColorTexture(ITEM_QUALITY_COLORS[breedQuality].r, ITEM_QUALITY_COLORS[breedQuality].g, ITEM_QUALITY_COLORS[breedQuality].b, 0.15)
    end
    frame.backgroundColor:SetShown(breedQuality~=-1)

    local AllCollected, CollectedNum, CollectedText= WoWTools_PetBattleMixin:Collected(speciesID)--收集数量
    frame.textLeft:SetText(CollectedNum or '')
    frame.text2Left:SetText(CollectedText or '')
    frame.textRight:SetText(not CollectedNum and AllCollected or '')

    WoWTools_TooltipMixin:Set_Web_Link(frame, {type='npc', id=companionID, name=speciesName, col=nil, isPetUI=true})--取得网页，数据链接
    frame:Show()
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