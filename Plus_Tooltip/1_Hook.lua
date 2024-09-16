local e= select(2, ...)
local function Save()
    return WoWTools_TooltipMixin.Save
end



local function Init()
    --战斗宠物，技能 SharedPetBattleTemplates.lua
    hooksecurefunc('SharedPetBattleAbilityTooltip_SetAbility', function(self, abilityInfo, additionalText)
        local abilityID = abilityInfo:GetAbilityID()
        if abilityID then
            local _, name, icon, _, unparsedDescription, _, petType = C_PetBattles.GetAbilityInfoByID(abilityID)
            local description = SharedPetAbilityTooltip_ParseText(abilityInfo, unparsedDescription)
            self.Description:SetText(description
                                    ..'|n|n|cffffffff'..(e.onlyChinese and '技能' or ABILITIES)
                                    ..' '..abilityID
                                    ..(icon and '  |T'..icon..':0|t'..icon or '')..'|r'
                                    ..(Save().ctrl and not UnitAffectingCombat('player') and '|nWoWHead Ctrl+Shift' or '')
                                )
            WoWTools_TooltipMixin:Set_Web_Link(self, {type='pet-ability', id=abilityID, name=name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency
            local btn= _G['WoWTools_PetBattle_Type_TrackButton']--PetBattle.lua 联动
            if btn then
                btn:set_type_tips(petType)
            end
        end
    end)


    hooksecurefunc(GameTooltip, 'SetSpellBookItem', function(self, slot, unit)--宠物，技能书，提示        
        if unit==Enum.SpellBookSpellBank.Pet and slot then
            local data= C_SpellBook.GetSpellBookItemInfo(slot, Enum.SpellBookSpellBank.Pet)
            if data then
                self:AddLine(' ')
                self:AddDoubleLine(data.spellID and (e.onlyChinese and '法术' or SPELLS)..' '..data.spellID or ' ', data.iconID and '|T'..data.iconID..':0|t'..data.iconID)
                if data.actionID or data.itemType then
                    self:AddDoubleLine(data.itemType and 'itemType '..data.itemType or ' ', 'actionID '..data.actionID)
                end
                --self:Show()
            end
        end
    end)


    --####
    --声望
    --####
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
                self.factionIDText=WoWTools_LabelMixin:CreateLabel(self)
                self.factionIDText:SetPoint('BOTTOM', self, 'TOP', 0,-4)
            end
            self.factionIDText:SetText(frame.elementData.factionID or '')
        end)
        ReputationFrame.ReputationDetailFrame:HookScript('OnShow', function(self)
            local selectedFactionIndex = C_Reputation.GetSelectedFaction();
            local factionData = C_Reputation.GetFactionDataByIndex(selectedFactionIndex);
            if factionData and factionData.factionID> 0 then
                if not self.factionIDText then
                    self.factionIDText=WoWTools_LabelMixin:CreateLabel(self)
                    self.factionIDText:SetPoint('BOTTOM', self, 'TOP', 0,-4)
                end
                self.factionIDText:SetText(factionData.factionID)
            end
        end)



    hooksecurefunc(AreaPOIPinMixin,'TryShowTooltip', function(self)--POI提示 AreaPOIDataProvider.lua
        e.tips:AddLine(' ')
        local uiMapID = self:GetMap() and self:GetMap():GetMapID()
        if self.areaPoiID then
            e.tips:AddDoubleLine('areaPoiID', self.areaPoiID)
        end
        if self.widgetSetID then
            e.tips:AddDoubleLine('widgetSetID', self.widgetSetID)
            for _,widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(self.widgetSetID) or {}) do
                if widget and widget.widgetID and widget.shownState==1 then
                    e.tips:AddDoubleLine('|A:characterupdate_arrow-bullet-point:0:0|awidgetID', widget.widgetID)
                end
            end
        end
        if uiMapID then
            e.tips:AddDoubleLine('uiMapID', uiMapID)
        end
        if self.factionID then
            WoWTools_TooltipMixin:Set_Faction(e.tips, self.factionID)
        end
        if self.areaPoiID and uiMapID then
            local poiInfo= C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, self.areaPoiID)
            if poiInfo and poiInfo.atlasName  then
                e.tips:AddDoubleLine('atlasName', '|A:'..poiInfo.atlasName..':0:0|a'..poiInfo.atlasName)
            end
        end
        e.tips:Show()
    end)

    --#############
    --挑战, AffixID
    --Blizzard_ScenarioObjectiveTracker.lua
    hooksecurefunc(ScenarioChallengeModeAffixMixin, 'OnEnter', function(self)
        if self.affixID then
            local name, description, filedataid = C_ChallengeMode.GetAffixInfo(self.affixID)
            GameTooltip:SetText(e.cn(name), 1, 1, 1, 1, true)
            GameTooltip:AddLine(e.cn(description), nil, nil, nil, true)
            GameTooltip:AddDoubleLine('affixID '..self.affixID, filedataid and '|T'..filedataid..':0|t'..filedataid or ' ')
            WoWTools_TooltipMixin:Set_Web_Link(GameTooltip, {type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
            GameTooltip:Show()
        end
    end)
    if ScenarioChallengeModeBlock and ScenarioChallengeModeBlock.Affixes and ScenarioChallengeModeBlock.Affixes[1] then
        ScenarioChallengeModeBlock.Affixes[1]:HookScript('OnEnter', function(self)
            if self.affixID then
                local name, description, filedataid = C_ChallengeMode.GetAffixInfo(self.affixID)
                GameTooltip:SetText(e.cn(name), 1, 1, 1, 1, true)
                GameTooltip:AddLine(e.cn(description), nil, nil, nil, true)
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
            e.tips:AddDoubleLine('transmogID', self.transmogID)
        end
    end)




    --添加任务ID
    local function create_Quest_Label(frame)
        frame.questIDLabel= WoWTools_LabelMixin:CreateLabel(frame, {mouse=true, justifyH='RIGHT'})
        frame.questIDLabel:SetAlpha(0.3)
        frame.questIDLabel:SetScript('OnLeave', function(self) GameTooltip_Hide() self:SetAlpha(0.3) end)
        frame.questIDLabel:SetScript('OnEnter', function(self)
            if self.questID then
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                --GameTooltip_AddQuest(self, self.questID)
                --e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.addName, addName..e.Icon.left)
                e.tips:AddDoubleLine((e.onlyChinese and '任务' or QUESTS_LABEL)..' ID', self.questID)
                e.tips:Show()
                self:SetAlpha(1)
            end
        end)
        frame.questIDLabel:SetScript('OnMouseDown', function(self)
            if self.questID then
                local info = C_QuestLog.GetQuestTagInfo(self.questID) or {}
                WoWTools_TooltipMixin:Show_URL(true, 'quest', self.questID, info.tagName)
            end
        end)
        function frame.questIDLabel:settings(questID)
            local num= (questID and questID>0) and questID
            self:SetText(num or '')
            self.questID= num
        end
        return frame.questIDLabel
    end

    local label= create_Quest_Label(QuestMapDetailsScrollFrame)
    label:SetPoint('BOTTOMRIGHT', QuestMapDetailsScrollFrame, 'TOPRIGHT', 0, 4)
    hooksecurefunc('QuestMapFrame_ShowQuestDetails', function(questID)
        QuestMapDetailsScrollFrame.questIDLabel:settings(questID)
    end)

    label= create_Quest_Label(QuestFrame)
    if _G['WoWeuCN_Tooltips_BlizzardOptions'] then
        label:SetPoint('BOTTOMRIGHT',QuestMapFrame.DetailsFrame.BackFrame, 'TOPRIGHT', 25, 28)
    else
        label:SetPoint('TOPRIGHT', -30, -35)
    end
    QuestFrame:HookScript('OnShow', function(self)
        local questID= WoWTools_QuestMixin:GetID()
        self.questIDLabel:settings(questID)
    end)



    --任务日志 显示ID
    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
        local info= self.questLogIndex and C_QuestLog.GetInfo(self.questLogIndex)
        if not info or not info.questID or not HaveQuestData(info.questID) then
            return
        end

        WoWTools_TooltipMixin:Set_Quest(e.tips, info.questID, info)--任务

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
                    if C_QuestLog.IsUnitOnQuest(u2, info.questID) then
                        acceto=acceto+1
                    end
                end
                e.tips:AddDoubleLine((e.onlyChinese and '共享' or SHARE_QUEST)..' '..(acceto..'/'..(n-1)), e.GetYesNo(C_QuestLog.IsPushableQuest(info.questID)))
            end
        end

        e.tips:Show()
    end)

    --添加 WidgetSetID
    hooksecurefunc('GameTooltip_AddWidgetSet', function(self, uiWidgetSetID)
        if uiWidgetSetID then
            self:AddDoubleLine('WidgetSetID', uiWidgetSetID)
            self:Show()
        end
    end)


    for i= 1, NUM_OVERRIDE_BUTTONS do-- ActionButton.lua
        if _G['OverrideActionBarButton'..i] then
            hooksecurefunc(_G['OverrideActionBarButton'..i], 'SetTooltip', function(self)
                if self.action then
                    local actionType, ID, subType = GetActionInfo(self.action)
                    if actionType and ID then
                        if actionType=='spell' or actionType =="companion" then
                            WoWTools_TooltipMixin:Set_Spell(e.tips, ID)--法术
                            e.tips:AddDoubleLine('action '..self.action, subType and 'subType '..subType)
                        elseif actionType=='item' and ID then
                            WoWTools_TooltipMixin:Set_Item(e.tips, nil, ID)
                            e.tips:AddDoubleLine('action '..self.action, subType and 'subType '..subType)
                        else
                            e.tips:AddDoubleLine('action '..self.action, 'ID '..ID)
                            e.tips:AddDoubleLine(actionType and 'actionType '..actionType, subType and 'subType '..subType)
                        end
                        e.tips:Show()
                    end
                end
            end)
        end
    end
end










function WoWTools_TooltipMixin:Init_Hook()
    Init()
end