function WoWTools_TooltipMixin.Frames:TooltipDataProcessor()
    TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, function(tooltip, data)
        if not tooltip.textLeft then
            WoWTools_TooltipMixin:Set_Init_Item(tooltip)--创建，设置，内容
        end
        if tooltip==ItemRefTooltip then
            WoWTools_TooltipMixin:Set_Init_Item(tooltip, true)--创建，设置，内容
        end
    end)

--物品 0
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
        if tooltip==ShoppingTooltip1 or ShoppingTooltip2==tooltip then
            return
        end
        local itemLink, itemID= select(2, TooltipUtil.GetDisplayedItem(tooltip))
        itemID= itemID or data.id
        WoWTools_TooltipMixin:Set_Item(tooltip, itemLink, itemID)
    end)

--法术 1
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Spell(tooltip, data.id)
    end)

--单位 Unit 2
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
        WoWTools_TooltipMixin:Set_Unit(tooltip)
    end)

--Corpse 3
--Object 4


--货币 5
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Currency(tooltip, data.id)
    end)

--BattlePet 6

--UnitAura 7
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, function(tooltip, data)
        WoWTools_TooltipMixin:Set_All_Aura(tooltip, data)
    end)
--艾泽拉斯之心 8
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.AzeriteEssence, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Azerite(tooltip, data.id)
    end)

--CompanionPet 9

--坐骑 10
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Mount(tooltip, data.id)
    end)

--PetAction 11
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.PetAction, function(tooltip, data)
        local action= tooltip:GetOwner()
        local spellID = select(7, GetPetActionInfo(action and action:GetID() or 0))
        WoWTools_TooltipMixin:Set_Spell(tooltip, spellID)
    end)
--成就 12
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Achievement, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Achievement(tooltip, data.id)
    end)



--EnhancedConduit 13
--EquipmentSet 14
--InstanceLock 15
--PvPBrawl 16
--RecipeRankInfo 17
--Totem 18

--玩具 19
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(tooltip, data)
        if tooltip==ShoppingTooltip1 or ShoppingTooltip2==tooltip then
            return
        end
        local itemLink, itemID= select(2, TooltipUtil.GetDisplayedItem(tooltip))
        itemLink= itemLink or itemID or data.id
        WoWTools_TooltipMixin:Set_Item(tooltip, itemLink, itemID)
    end)

--CorruptionCleanser 20
--MinimapMouseover 21

--法术弹出框 22
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Flyout, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Flyout(tooltip, data.id)
    end)

--任务 25
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Quest, function(tooltip, data)
        WoWTools_TooltipMixin:Set_Quest(tooltip, data.id, data)
    end)

--QuestPartyProgress 24

--宏 Macro 25
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, function(tooltip)
        local frame= tooltip:GetOwner()--宏 11版本
        if frame and frame.action then
            local type, macroID, subType= GetActionInfo(frame.action)
            if type=='macro' and macroID then
                if subType=='spell' then--and macroID or GetMacroSpell(macroID)
                    WoWTools_TooltipMixin:Set_Spell(tooltip, macroID)
                elseif not subType or subType=='' then
                    local text=GetMacroBody(macroID)
                    if text then
                        tooltip:AddLine(text,nil,nil,nil,true)
                    end
                end
            end
        end
    end)

--Debug 26
end





















function WoWTools_TooltipMixin.Frames:ShoppingTooltip1()
--装备，对比，提示
    for i=1, 2 do
        local tooltip= _G['ShoppingTooltip'..i]
        tooltip.Portrait2= tooltip:CreateTexture(nil, 'BACKGROUND',nil, 2)--右上角图标
        tooltip.Portrait2:SetPoint('TOPRIGHT',-2, -3)
        tooltip.Portrait2:SetSize(40,40)
        tooltip:HookScript('OnShow', function(t)
            local data= t:GetPrimaryTooltipData()--{dataInstanceID type isAzeriteItem guid isAzeriteEmpoweredItem isCorruptedItem, lines}
            local itemLink= data and data.guid and C_Item.GetItemLinkByGUID(data.guid)
            local atlas, isUp
            if itemLink then
                if itemLink== select(2, GameTooltip:GetItem()) then
                    atlas='QuestNormal'
                elseif itemLink==GetInventoryItemLink('player', 11) or itemLink==GetInventoryItemLink('player', 13) then
                    atlas='Adventures-Target-Indicator'
                    isUp=true
                elseif itemLink==GetInventoryItemLink('player', 12) or itemLink==GetInventoryItemLink('player', 14) then
                    atlas='Adventures-Target-Indicator'
                end
            end

            t.Portrait2:SetAtlas(atlas or WoWTools_DataMixin.Icon.Player:match('|A:(.-):') or 'QuestArtifactTurnin')

            if isUp then
                t.Portrait2:SetTexCoord(0,1,1,0)
            else
                t.Portrait2:SetTexCoord(0,1,0,1)
            end
        end)
    end
end











function WoWTools_TooltipMixin.Events:Blizzard_GameTooltip()
--宠物，技能书，提示
    WoWTools_DataMixin:Hook(GameTooltip, 'SetSpellBookItem', function(frame, slot, unit)
        if unit==Enum.SpellBookSpellBank.Pet and slot then
            local data= C_SpellBook.GetSpellBookItemInfo(slot, Enum.SpellBookSpellBank.Pet) or {}
            if data.spellID then
                self:Set_Spell(frame, data.spellID)
            elseif data.actionID then
                frame:AddDoubleLine(
                    (data.iconID and '|T'..data.iconID..':'..WoWTools_TooltipMixin.iconSize..'|t|cffffffff'..data.iconID or ' '),
                    data.actionID and 'actionID|cffffffff'..WoWTools_DataMixin.Icon.icon2..data.actionID
                )
                WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', frame)
            end
        end
    end)

--GameTooltip_AddQuest    
    WoWTools_DataMixin:Hook('GameTooltip_AddQuest', function(frame, questIDArg)
        local questID = frame.questID or questIDArg
        if questID and HaveQuestData(questID) then
            WoWTools_TooltipMixin:Set_Quest(GameTooltip, questID)
        end
    end)

--添加 WidgetSetID
    WoWTools_DataMixin:Hook('GameTooltip_AddWidgetSet', function(tooltip, uiWidgetSetID)
        if uiWidgetSetID then
            tooltip:AddLine('widgetSetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..uiWidgetSetID)
            WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', tooltip)
        end
    end)

--Buff, 来源, 数据, 不可删除，如果删除，目标buff没有数据
    WoWTools_DataMixin:Hook(GameTooltip, "SetUnitBuff", function(...)
        WoWTools_TooltipMixin:Set_Buff('Buff', ...)
    end)
    WoWTools_DataMixin:Hook(GameTooltip, "SetUnitDebuff", function(...)
        WoWTools_TooltipMixin:Set_Buff('Debuff', ...)
    end)
    WoWTools_DataMixin:Hook(GameTooltip, "SetUnitAura", function(...)
        WoWTools_TooltipMixin:Set_Buff('Aura', ...)
    end)
end















--选项 SettingsTooltip
function WoWTools_TooltipMixin.Frames:SettingsTooltip()
    SettingsTooltip:HookScript('OnShow', function(tooltip)--选项面板，值提示
        local frame= tooltip:GetOwner():GetParent()

        for i=1, 4 do
            if frame.GetSetting or frame.GetData then
                break
            else
                frame= frame:GetParent()
            end
        end

        local setting= frame.GetSetting and frame:GetSetting()
        local data= frame.GetData and frame.GetData()

        if not setting and data and data.data then
            setting= data.data.cbSetting or data.data.setitings
        end

        local variable= setting and setting.variable and tostring(setting.variable)

        if not variable then
            return
        end

        if IsAltKeyDown() then
            WoWTools_TooltipMixin:Show_URL(nil, nil, nil, variable)
            return
        end

        local variableType= setting.variableType and tostring(setting.variableType) or type(setting.variableType)

        local value= C_CVar.GetCVarInfo(variable) or ''

        tooltip:AddLine(' ')
        tooltip:AddLine(
            'variable'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..variable
        )
        tooltip:AddLine(
            'variableType'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..variableType.. '|r '..tostring(value)
        )
        tooltip:AddLine(
            '|cnGREEN_FONT_COLOR:Alt'..WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
        )
        tooltip:Show()
    end)
end















--战斗宠物，技能 SharedPetBattleTemplates.lua  SharedPetBattleAbilityTooltipTemplate
--PetBattlePrimaryAbilityTooltip
--PetJournalPrimaryAbilityTooltip
--FloatingPetBattleAbilityTooltip
function WoWTools_TooltipMixin.Frames:BattlePetTooltip()
    WoWTools_DataMixin:Hook('SharedPetBattleAbilityTooltip_SetAbility', function(frame, abilityInfo)
        local abilityID = abilityInfo:GetAbilityID()
        if not abilityID then
            if frame.WoWToolsLabel then
                frame.WoWToolsLabel:SetText('')
            end
            return
        end

        local _, name, icon = C_PetBattles.GetAbilityInfoByID(abilityID)
        if not frame.WoWToolsLabel then
            frame.WoWToolsLabel= WoWTools_LabelMixin:Create(frame)
            frame.WoWToolsLabel:SetPoint('TOP', frame, 'BOTTOM')
        end

        frame.WoWToolsLabel:SetText(
            'abilityID '..abilityID
            ..(icon and '  |T'..icon..':'..self.iconSize..'|t'..icon or '')
            ..(self:Save().ctrl and not UnitAffectingCombat('player') and '  |A:NPE_Icon:0:0|aCtrl+Shift|TInterface\\AddOns\\WoWTools\\Source\\Texture\\Wowhead.tga:0|t' or '')
        )

        self:Set_Web_Link(frame, {type='pet-ability', id=abilityID, name=name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency
    end)

--宠物面板提示
    WoWTools_DataMixin:Hook("BattlePetToolTip_Show", function(...)--BattlePetTooltip.lua 
        self:Set_Battle_Pet(BattlePetTooltip, ...)
    end)
    WoWTools_DataMixin:Hook('FloatingBattlePet_Show', function(...)--FloatingPetBattleTooltip.lua
        self:Set_Battle_Pet(FloatingBattlePetTooltip, ...)
    end)
    WoWTools_DataMixin:Hook(GameTooltip, "SetCompanionPet", function(frame, petGUID)--设置宠物信息
        local speciesID= petGUID and C_PetJournal.GetPetInfoByPetID(petGUID)
        self:Set_Pet(frame, speciesID)--宠物
    end)
end