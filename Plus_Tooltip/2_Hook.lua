
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
    hooksecurefunc('SharedPetBattleAbilityTooltip_SetAbility', function(self, abilityInfo, additionalText)
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
                self:AddLine(' ')
                self:AddDoubleLine(data.spellID and (WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)..' '..data.spellID or ' ', data.iconID and '|T'..data.iconID..':0|t'..data.iconID)
                if data.actionID or data.itemType then
                    self:AddDoubleLine(data.itemType and 'itemType '..data.itemType or ' ', 'actionID '..data.actionID)
                    GameTooltip_CalculatePadding(self)
                end
            end
        end
    end)



--声望
    hooksecurefunc(ReputationEntryMixin, 'ShowStandardTooltip', function(self)
        WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
    end)
    hooksecurefunc(ReputationEntryMixin, 'ShowMajorFactionRenownTooltip', function(self)
        WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
    end)
    hooksecurefunc(ReputationEntryMixin, 'ShowFriendshipReputationTooltip', function(self)
        WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
    end)
    hooksecurefunc(ReputationEntryMixin, 'ShowParagonRewardsTooltip', function(self)
        WoWTools_TooltipMixin:Set_Faction(EmbeddedItemTooltip, self.elementData.factionID)
    end)
    hooksecurefunc(ReputationEntryMixin, 'OnClick', function(frame)
        local self= ReputationFrame.ReputationDetailFrame
        if not self.factionIDText then
            self.factionIDText=WoWTools_LabelMixin:Create(self)
            self.factionIDText:SetPoint('BOTTOM', self, 'TOP', 0,-4)
        end
        self.factionIDText:SetText(frame.elementData.factionID or '')
    end)
    ReputationFrame.ReputationDetailFrame:HookScript('OnShow', function(self)
        local selectedFactionIndex = C_Reputation.GetSelectedFaction();
        local factionData = C_Reputation.GetFactionDataByIndex(selectedFactionIndex);
        if factionData and factionData.factionID> 0 then
            if not self.factionIDText then
                self.factionIDText=WoWTools_LabelMixin:Create(self)
                self.factionIDText:SetPoint('BOTTOM', self, 'TOP', 0,-4)
            end
            self.factionIDText:SetText(factionData.factionID)
        end
    end)









--POI提示 AreaPOIDataProvider.lua
    hooksecurefunc(AreaPOIPinMixin,'TryShowTooltip', function(self)
        GameTooltip:AddLine(' ')
        local uiMapID = self:GetMap() and self:GetMap():GetMapID()
        if self.areaPoiID then
            GameTooltip:AddDoubleLine('areaPoiID', self.areaPoiID)
        end
        if self.widgetSetID then
            GameTooltip:AddDoubleLine('widgetSetID', self.widgetSetID)
            for _,widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(self.widgetSetID) or {}) do
                if widget and widget.widgetID and widget.shownState==1 then
                    GameTooltip:AddDoubleLine('|A:characterupdate_arrow-bullet-point:0:0|awidgetID', widget.widgetID)
                end
            end
        end
        if uiMapID then
            GameTooltip:AddDoubleLine('uiMapID', uiMapID)
        end
        if self.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.factionID)
        end
        if self.areaPoiID and uiMapID then
            local poiInfo= C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, self.areaPoiID)
            if poiInfo and poiInfo.atlasName  then
                GameTooltip:AddDoubleLine('atlasName', '|A:'..poiInfo.atlasName..':0:0|a'..poiInfo.atlasName)
            end
        end
        GameTooltip_CalculatePadding(GameTooltip)
        --GameTooltip:Show()
    end)











--挑战, AffixID
--Blizzard_ScenarioObjectiveTracker.lua
    hooksecurefunc(ScenarioChallengeModeAffixMixin, 'OnEnter', function(self)
        if self.affixID then
            local name, description, filedataid = C_ChallengeMode.GetAffixInfo(self.affixID)
            GameTooltip:SetText(WoWTools_TextMixin:CN(name), 1, 1, 1, 1, true)
            GameTooltip:AddLine(WoWTools_TextMixin:CN(description), nil, nil, nil, true)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('affixID '..self.affixID, filedataid and '|T'..filedataid..':0|t'..filedataid or ' ')
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
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine('affixID '..self.affixID, filedataid and '|T'..filedataid..':0|t'..filedataid or ' ')
                WoWTools_TooltipMixin:Set_Web_Link(GameTooltip, {type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
                GameTooltip:Show()
            end
        end)
    end









--试衣间
--DressUpFrames.lua
    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'OnEnter', function(self)
        if self.transmogID then
            GameTooltip:AddDoubleLine('transmogID', self.transmogID)
        end
    end)











--添加任务ID
    local label= create_Quest_Label(QuestMapDetailsScrollFrame)
    label:SetPoint('BOTTOMRIGHT', QuestMapDetailsScrollFrame, 'TOPRIGHT', 0, 4)
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
                GameTooltip_CalculatePadding(GameTooltip)
            end
        end

        --GameTooltip:Show()
    end)










--添加 WidgetSetID
    hooksecurefunc('GameTooltip_AddWidgetSet', function(tooltip, uiWidgetSetID)
        if uiWidgetSetID then
            tooltip:AddLine(' ')
            tooltip:AddDoubleLine('WidgetSetID', uiWidgetSetID)
            GameTooltip_CalculatePadding(tooltip)
            --tooltip:Show()
        end
    end)






--ActionButton.lua
    for i= 1, NUM_OVERRIDE_BUTTONS do
        if _G['OverrideActionBarButton'..i] then
            hooksecurefunc(_G['OverrideActionBarButton'..i], 'SetTooltip', function(self)
                if self.action then
                    local actionType, ID, subType = GetActionInfo(self.action)
                    if actionType and ID then
                        if actionType=='spell' or actionType =="companion" then
                            WoWTools_TooltipMixin:Set_Spell(GameTooltip, ID)--法术
                            GameTooltip:AddDoubleLine('action '..self.action, subType and 'subType '..subType)
                        elseif actionType=='item' and ID then
                            WoWTools_TooltipMixin:Set_Item(GameTooltip, nil, ID)
                            GameTooltip:AddDoubleLine('action '..self.action, subType and 'subType '..subType)
                        else
                            GameTooltip:AddDoubleLine('action '..self.action, 'ID '..ID)
                            GameTooltip:AddDoubleLine(actionType and 'actionType '..actionType, subType and 'subType '..subType)
                        end
                        GameTooltip_CalculatePadding(GameTooltip)
                    end
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

        tooltip:AddLine(' ')

        tooltip:AddDoubleLine(
            'warbandSceneID |cffffffff'..warbandSceneID,
            'sourceType |cffffffff'..(self.warbandSceneInfo.sourceType or '')
        )

        local quality= self.warbandSceneInfo.quality or 1
        local atlas= self.warbandSceneInfo.textureKit or ''

        tooltip:AddDoubleLine(
            '|A:'..atlas..':32:32|a'..atlas,
            '|c'..select(4,  C_Item.GetItemQualityColor(quality)) ..
            WoWTools_TextMixin:CN(_G['ITEM_QUALITY'..quality..'_DESC'] or '')
        )

        GameTooltip_CalculatePadding(tooltip)
    end)

--商店
    if _G['AccountStoreFrame'] then
        hooksecurefunc(AccountStoreBaseCardMixin, 'OnEnter', function(self)
            local info= self.itemInfo
            if not info or not info.id then
                return
            end
            local tooltip = GetAppropriateTooltip()
            tooltip:AddLine(' ')
            tooltip:AddDoubleLine(
                'ID '..info.id,
                info.creatureDisplayID and 'creatureDisplayID '..info.creatureDisplayID
                or (info.displayIcon and '|T'..info.displayIcon..':0|t'..info.displayIcon)
                or (info.transmogSetID and 'transmogSetID '..info.transmogSetID)
            )
            tooltip:Show()
        end)
    end

    --FloatingPetBattleAbilityTooltip
    Init=function()end
end














function WoWTools_TooltipMixin:Init_Hook()
    Init()
end