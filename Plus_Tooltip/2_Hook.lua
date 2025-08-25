
local function Save()
    return WoWToolsSave['Plus_Tootips']
end









--添加任务ID
local function create_Quest_Label(frame)
    frame.questIDLabel= WoWTools_LabelMixin:Create(frame, {mouse=true, justifyH='RIGHT'})
    frame.questIDLabel:SetAlpha(0.3)
    frame.questIDLabel:SetScript('OnLeave', function(self)
        GameTooltip_Hide() self:SetAlpha(0.3)
    end)
    frame.questIDLabel:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Frame(self)
        self:SetAlpha(1)
    end)

    function frame.questIDLabel:settings(questID)
        questID= questID or WoWTools_QuestMixin:GetID()
        local num= (questID and questID>0) and questID
        self:SetText(num or '')
        self.questID= num
    end
    return frame.questIDLabel
end












local function Init()


--战斗宠物，技能 SharedPetBattleTemplates.lua  SharedPetBattleAbilityTooltipTemplate
    hooksecurefunc('SharedPetBattleAbilityTooltip_SetAbility', function(self, abilityInfo)
        local abilityID = abilityInfo:GetAbilityID()
        if not abilityID then
            if self.WoWToolsLabel then
                self.WoWToolsLabel:SetText('')
            end
            return
        end

        local _, name, icon = C_PetBattles.GetAbilityInfoByID(abilityID)
        if not self.WoWToolsLabel then
            self.WoWToolsLabel= WoWTools_LabelMixin:Create(self)
            self.WoWToolsLabel:SetPoint('TOP', self, 'BOTTOM')
        end

        self.WoWToolsLabel:SetText(
            'abilityID '..abilityID
            ..(icon and '  |T'..icon..':'..WoWTools_TooltipMixin.iconSize..'|t'..icon or '')
            ..(Save().ctrl and not UnitAffectingCombat('player') and '  |A:NPE_Icon:0:0|aCtrl+Shift|TInterface\\AddOns\\WoWTools\\Source\\Texture\\Wowhead.tga:0|t' or '')
        )

        WoWTools_TooltipMixin:Set_Web_Link(self, {type='pet-ability', id=abilityID, name=name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency
    end)


--宠物，技能书，提示
    hooksecurefunc(GameTooltip, 'SetSpellBookItem', function(self, slot, unit)
        if unit==Enum.SpellBookSpellBank.Pet and slot then
            local data= C_SpellBook.GetSpellBookItemInfo(slot, Enum.SpellBookSpellBank.Pet)
            if data then
                self:AddDoubleLine(
                    data.iconID and '|T'..data.iconID..':'..WoWTools_TooltipMixin.iconSize..'|t|cffffffff'..data.iconID or ' ',
                    data.spellID and (WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..data.spellID
                )
                if data.actionID or data.itemType then
                    self:AddDoubleLine(
                        data.itemType and 'itemType|cffffffff'..WoWTools_DataMixin.Icon.icon2..data.itemType,
                        data.actionID and 'actionID|cffffffff'..WoWTools_DataMixin.Icon.icon2..data.actionID
                    )
                    WoWTools_Mixin:Call(GameTooltip_CalculatePadding, self)
                end
            end
        end
    end)



--声望
    hooksecurefunc(ReputationEntryMixin, 'ShowStandardTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    hooksecurefunc(ReputationEntryMixin, 'ShowMajorFactionRenownTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    hooksecurefunc(ReputationEntryMixin, 'ShowFriendshipReputationTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    hooksecurefunc(ReputationEntryMixin, 'ShowParagonRewardsTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(EmbeddedItemTooltip, self.elementData.factionID)
        end
    end)

    hooksecurefunc(ReputationSubHeaderMixin, 'ShowStandardTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    hooksecurefunc(ReputationSubHeaderMixin, 'ShowMajorFactionRenownTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    hooksecurefunc(ReputationSubHeaderMixin, 'ShowFriendshipReputationTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    hooksecurefunc(ReputationSubHeaderMixin, 'ShowParagonRewardsTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(EmbeddedItemTooltip, self.elementData.factionID)
        end
    end)




    local factionIDText=WoWTools_LabelMixin:Create(ReputationFrame.ReputationDetailFrame,{
            name= 'ReputationDetailFramFactionIDText',
            mouse=true,
    })
    factionIDText:SetPoint('BOTTOM', ReputationFrame.ReputationDetailFrame, 'TOP')
    factionIDText:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    factionIDText:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Faction(self)
        self:SetAlpha(0.5)
    end)
    function factionIDText:settings()
        local selectedFactionIndex = C_Reputation.GetSelectedFaction();
	    local factionData = C_Reputation.GetFactionDataByIndex(selectedFactionIndex);
	    local factionID= factionData and factionData.factionID > 0 and factionData.factionID or nil
        self:SetText(factionID or '')
        self.factionID= factionID
    end
    EventRegistry:RegisterCallback('ReputationFrame.NewFactionSelected', function()
        factionIDText:settings()
    end)
--第一次，需要刷新
    hooksecurefunc(ReputationFrame.ReputationDetailFrame, 'Refresh', function()
        factionIDText:settings()
    end)
--hooksecurefunc(ReputationEntryMixin, 'OnClick', function(frame)



--POI提示 AreaPOIDataProvider.lua
    hooksecurefunc(AreaPOIPinMixin,'TryShowTooltip', function(self)
        local uiMapID = self:GetMap() and self:GetMap():GetMapID()
        if self.areaPoiID or self.widgetSetID then
            GameTooltip:AddDoubleLine(
                self.areaPoiID and 'areaPoiID|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.areaPoiID,
                self.widgetSetID and 'widgetSetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.widgetSetID
            )
        end
        if self.widgetSetID then
            for _,widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(self.widgetSetID) or {}) do
                if widget and widget.widgetID and widget.shownState==1 then
                    GameTooltip:AddLine('widgetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..widget.widgetID)
                end
            end
        end
        if uiMapID then
            GameTooltip:AddLine('uiMapID|cffffffff'..WoWTools_DataMixin.Icon.icon2..uiMapID)
        end
        if self.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.factionID)
        end
        --[[if self.areaPoiID and uiMapID then
            local poiInfo= C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, self.areaPoiID)
            if poiInfo and poiInfo.atlasName  then
                GameTooltip:AddDoubleLine('atlasName', '|A:'..poiInfo.atlasName..':0:0|a'..poiInfo.atlasName)
            end
        end]]
        WoWTools_Mixin:Call(GameTooltip_CalculatePadding, GameTooltip)
        --GameTooltip:Show()
    end)











--挑战, AffixID
--Blizzard_ScenarioObjectiveTracker.lua
    hooksecurefunc(ScenarioChallengeModeAffixMixin, 'OnEnter', function(self)
        if self.affixID then
            local name, description, filedataid = C_ChallengeMode.GetAffixInfo(self.affixID)
            GameTooltip:SetText(WoWTools_TextMixin:CN(name), 1, 1, 1, 1, true)
            GameTooltip:AddLine(WoWTools_TextMixin:CN(description), nil, nil, nil, true)
            GameTooltip:AddDoubleLine(
                filedataid and '|T'..filedataid..':'..WoWTools_TooltipMixin.iconSize..'|t|cffffffff'..filedataid,
                'affixID|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.affixID
            )
            WoWTools_TooltipMixin:Set_Web_Link(GameTooltip, {type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
            GameTooltip:Show()
        end
    end)
    if ScenarioChallengeModeBlock and ScenarioChallengeModeBlock.Affixes and ScenarioChallengeModeBlock.Affixes[1] then
        ScenarioChallengeModeBlock.Affixes[1]:HookScript('OnEnter', function(self)
            if self.affixID then
                local name, description, filedataid = C_ChallengeMode.GetAffixInfo(self.affixID)
                GameTooltip:SetText(WoWTools_TextMixin:CN(name), 1, 1, 1, 1, true)
                GameTooltip:AddLine(WoWTools_TextMixin:CN(description), nil, nil, nil, true)
                GameTooltip:AddDoubleLine(
                    filedataid and '|T'..filedataid..':'..WoWTools_TooltipMixin.iconSize..'|t|cffffffff'..filedataid,
                    'affixID|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.affixID
                )
                WoWTools_TooltipMixin:Set_Web_Link(GameTooltip, {type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
                GameTooltip:Show()
            end
        end)
    end









--试衣间
--DressUpFrames.lua
    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'OnEnter', function(self)
        if self.transmogID then
            GameTooltip:AddLine('transmogID|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.transmogID)
            GameTooltip:Show()
        end
    end)











--添加任务ID
    local label= create_Quest_Label(QuestMapDetailsScrollFrame)
    --label:SetPoint('BOTTOMRIGHT', QuestMapDetailsScrollFrame, 'TOPRIGHT', 0, 4)
    label:SetPoint('LEFT', QuestMapFrame.QuestsFrame.DetailsFrame.BackFrame.BackButton, 'RIGHT', 2, 0)    

    hooksecurefunc('QuestMapFrame_ShowQuestDetails', function(questID)
        QuestMapDetailsScrollFrame.questIDLabel:settings(questID)
    end)

    label= create_Quest_Label(QuestFrameCloseButton)
    label:SetPoint('TOPRIGHT', QuestFrameCloseButton, 'BOTTOMRIGHT')

    QuestFrame:HookScript('OnShow', function()
        QuestFrameCloseButton.questIDLabel:settings()
    end)


--任务日志 显示ID
    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
        local info= self.questLogIndex and C_QuestLog.GetInfo(self.questLogIndex)
        local questID= info and info.questID or self.questID
        if not questID  or not HaveQuestData(questID) then
            return
        end

        WoWTools_TooltipMixin:Set_Quest(GameTooltip, questID, info)--任务

        if IsInGroup() then
            local n=GetNumGroupMembers()
            if n >1 then
                local acceto=0
                local u= IsInRaid() and 'raid' or 'party'
                for i=1, n do
                    local u2
                    if u=='party' and i==n then
                        u2='player'
                    else
                        u2=u..i
                    end
                    if C_QuestLog.IsUnitOnQuest(u2, questID) then
                        acceto=acceto+1
                    end
                end
                GameTooltip:AddDoubleLine(
                    (WoWTools_DataMixin.onlyChinese and '共享' or SHARE_QUEST)..' '..(acceto..'/'..(n-1)),
                    WoWTools_TextMixin:GetYesNo(C_QuestLog.IsPushableQuest(info.questID))
                )
                WoWTools_Mixin:Call(GameTooltip_CalculatePadding, GameTooltip)
            end
        end

        --GameTooltip:Show()
    end)










--添加 WidgetSetID
    hooksecurefunc('GameTooltip_AddWidgetSet', function(tooltip, uiWidgetSetID)
        if uiWidgetSetID then
            tooltip:AddLine('widgetSetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..uiWidgetSetID)
            WoWTools_Mixin:Call(GameTooltip_CalculatePadding, tooltip)
        end
    end)






--ActionButton.lua
    for i= 1, NUM_OVERRIDE_BUTTONS do
        if _G['OverrideActionBarButton'..i] then
            hooksecurefunc(_G['OverrideActionBarButton'..i], 'SetTooltip', function(self)
                if not self.action then
                    return
                end
                local actionType, ID, subType = GetActionInfo(self.action)
                if actionType and ID then
                    if actionType=='spell' or actionType =="companion" then
                        WoWTools_TooltipMixin:Set_Spell(GameTooltip, ID)--法术
                        GameTooltip:AddDoubleLine(
                            'action|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.action,
                            subType and 'subType|cffffffff'..WoWTools_DataMixin.Icon.icon2..subType
                        )
                    elseif actionType=='item' and ID then
                        WoWTools_TooltipMixin:Set_Item(GameTooltip, nil, ID)
                        GameTooltip:AddDoubleLine(
                            'action|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.action,
                            subType and 'subType|cffffffff'..WoWTools_DataMixin.Icon.icon2..subType
                        )
                    else
                        GameTooltip:AddDoubleLine(
                            'action|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.action,
                            'ID|cffffffff'..WoWTools_DataMixin.Icon.icon2..ID
                        )
                        GameTooltip:AddDoubleLine(
                            actionType and 'actionType|cffffffff'..WoWTools_DataMixin.Icon.icon2..actionType,
                            subType and 'subType|cffffffff'..WoWTools_DataMixin.Icon.icon2..subType
                        )
                    end
                    WoWTools_Mixin:Call(GameTooltip_CalculatePadding, GameTooltip)
                end
            end)
        end
    end




--GameTooltip_AddQuest    
    hooksecurefunc('GameTooltip_AddQuest', function(self, questIDArg)
        local questID = self.questID or questIDArg
        if questID and HaveQuestData(questID) then
            WoWTools_TooltipMixin:Set_Quest(GameTooltip, questID)
        end
    end)







    --霸业商店
    if AccountStoreFrame and AccountStoreFrame.StoreDisplay.Footer.CurrencyAvailable then
        AccountStoreFrame.StoreDisplay.Footer.CurrencyAvailable:HookScript('OnEnter', function(self)
            local accountStoreCurrencyID = C_AccountStore.GetCurrencyIDForStore(Constants.AccountStoreConsts.PlunderstormStoreFrontID);
		    if accountStoreCurrencyID then
                WoWTools_TooltipMixin:Set_Currency(GetAppropriateTooltip(), accountStoreCurrencyID)
            end
        end)
    end






--SharedCollectionTemplates.lua
    hooksecurefunc(WarbandSceneEntryMixin, 'OnEnter', function(self)
        local warbandSceneID= self.warbandSceneInfo and self.warbandSceneInfo.warbandSceneID
        if not warbandSceneID then
            return
        end
        local tooltip = GetAppropriateTooltip()

        tooltip:AddDoubleLine(
            'warbandSceneID |cffffffff'..WoWTools_DataMixin.Icon.icon2..warbandSceneID,
            self.warbandSceneInfo.sourceType and 'sourceType|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.warbandSceneInfo.sourceType
        )

        local quality= self.warbandSceneInfo.quality or 1
        local atlas= self.warbandSceneInfo.textureKit or ''

        tooltip:AddDoubleLine(
            '|A:'..atlas..':'..WoWTools_TooltipMixin.iconSize..':'..WoWTools_TooltipMixin.iconSize..'|a'..atlas,
            '|c'..select(4,  C_Item.GetItemQualityColor(quality))..WoWTools_TextMixin:CN(_G['ITEM_QUALITY'..quality..'_DESC'] or '')
        )

        WoWTools_Mixin:Call(GameTooltip_CalculatePadding, tooltip)
    end)

--商店
    if _G['AccountStoreFrame'] then
        hooksecurefunc(AccountStoreBaseCardMixin, 'OnEnter', function(self)
            local info= self.itemInfo
            if not info or not info.id then
                return
            end
            local tooltip = GetAppropriateTooltip()
            tooltip:AddDoubleLine(
                'ID|cffffffff'..WoWTools_DataMixin.Icon.icon2..info.id,

                info.creatureDisplayID and 'creatureDisplayID|cffffffff'..WoWTools_DataMixin.Icon.icon2..info.creatureDisplayID
            )
            tooltip:AddDoubleLine(
                info.displayIcon and '|T'..info.displayIcon..':'..WoWTools_TooltipMixin.iconSize..'|t|cffffffff'..info.displayIcon,
                info.transmogSetID and 'transmogSetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..info.transmogSetID
            )
            tooltip:Show()
        end)
    end

    --FloatingPetBattleAbilityTooltip
    --StoryHeaderMixin:ShowTooltip() QuestScrollFrame.StoryTooltip
    Init=function()end
end














function WoWTools_TooltipMixin:Init_Hook()
    Init()
end