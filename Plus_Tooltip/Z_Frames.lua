--声望
function WoWTools_TooltipMixin.Frames:ReputationFrame()

    WoWTools_DataMixin:Hook(ReputationEntryMixin, 'ShowStandardTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    WoWTools_DataMixin:Hook(ReputationEntryMixin, 'ShowMajorFactionRenownTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    WoWTools_DataMixin:Hook(ReputationEntryMixin, 'ShowFriendshipReputationTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    WoWTools_DataMixin:Hook(ReputationEntryMixin, 'ShowParagonRewardsTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(EmbeddedItemTooltip, self.elementData.factionID)
        end
    end)

    WoWTools_DataMixin:Hook(ReputationSubHeaderMixin, 'ShowStandardTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    WoWTools_DataMixin:Hook(ReputationSubHeaderMixin, 'ShowMajorFactionRenownTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    WoWTools_DataMixin:Hook(ReputationSubHeaderMixin, 'ShowFriendshipReputationTooltip', function(self)
        if self.elementData and self.elementData.factionID then
            WoWTools_TooltipMixin:Set_Faction(GameTooltip, self.elementData.factionID)
        end
    end)
    WoWTools_DataMixin:Hook(ReputationSubHeaderMixin, 'ShowParagonRewardsTooltip', function(self)
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
    WoWTools_DataMixin:Hook(ReputationFrame.ReputationDetailFrame, 'Refresh', function()
        factionIDText:settings()
    end)
--WoWTools_DataMixin:Hook(ReputationEntryMixin, 'OnClick', function(frame)
end










function WoWTools_TooltipMixin.Frames:QuestFrame()
    QuestScrollFrame.CampaignTooltip.IDLabel= QuestScrollFrame.CampaignTooltip:CreateFontString('WoWToolsCampaignIDLabel', 'ARTWORK')
    QuestScrollFrame.CampaignTooltip.IDLabel:SetFontObject('GameFontNormal')
    QuestScrollFrame.CampaignTooltip.IDLabel:SetJustifyH('LEFT')
    QuestScrollFrame.CampaignTooltip.IDLabel.layoutIndex= 5
    QuestScrollFrame.CampaignTooltip.IDLabel.expand= true
    QuestScrollFrame.CampaignTooltip.IDLabel.bottomPadding= 8
    QuestScrollFrame.CampaignTooltip.IDLabel:SetSize(250, 0)
    WoWTools_DataMixin:Hook(QuestScrollFrame.CampaignTooltip, 'SetJourneyCampaign', function(self, campaign)
        local text
        if campaign and campaign.campaignID then
            text= 'campaignID|cffffffff'..WoWTools_DataMixin.Icon.icon2..campaign.campaignID..'|r'
            if campaign.chapterIDs then
                text= text..'|nchapterIDs'
                for index, id in pairs(campaign.chapterIDs) do
                    text= text..'|n - '..index..') |cffffffff'..id..'|r'
                end
            end
        end
        self.IDLabel:SetText(text or '')
        self.IDLabel:SetShown(text)
    end)

    

--任务日志 显示ID
    WoWTools_DataMixin:Hook("QuestMapLogTitleButton_OnEnter", function(self)
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
                    WoWTools_TextMixin:GetYesNo(C_QuestLog.IsPushableQuest(questID))
                )
                WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', GameTooltip)
            end
        end
    end)
end










function WoWTools_TooltipMixin.Frames:GearManagerPopupFrame()
    --图标，修该, 提示，图标
    local function Set_SetIconTexture(btn, iconTexture)
        if not btn.Text then
            btn.Text= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1, mouse=true}})
            --btn.Text:SetPoint('TOPRIGHT', btn, 'TOPLEFT', -6, 6)
            btn.Text:SetPoint('BOTTOM', btn, 'TOP')
            --btn.Text:SetPoint('BOTTOMRIGHT', btn:GetParent().SelectedIconText.SelectedIconHeader, 'TOPRIGHT')
            --GearManagerPopupFrame.BorderBox.SelectedIconArea.SelectedIconText
              --GearManagerPopupFrame.BorderBox.SelectedIconArea.SelectedIconButton

            btn.Text:SetScript('OnLeave', function(label)
                GameTooltip:Hide()
                label:SetAlpha(1)
            end)
            btn.Text:SetScript('OnEnter', function(label)
                GameTooltip:SetOwner(label, 'ANCHOR_LEFT')
                GameTooltip:ClearLines()
                local icon= label:GetText() or ''
                GameTooltip:AddDoubleLine(
                    self.addName..WoWTools_DataMixin.Icon.icon2,
                    '|T'..icon..':0|t'..icon
                )
                GameTooltip:Show()
                label:SetAlpha(0.5)
            end)
        end
        btn.Text:SetText(iconTexture or '')
    end
--装备管理
    WoWTools_DataMixin:Hook(GearManagerPopupFrame.BorderBox.SelectedIconArea.SelectedIconButton, 'SetIconTexture', function(...)
        Set_SetIconTexture(...)
    end)
--图标，修改
    WoWTools_DataMixin:Hook(SelectedIconButtonMixin, 'SetIconTexture', function(...)
        Set_SetIconTexture(...)
    end)
end







--试衣间 DressUpFrames.lua
function WoWTools_TooltipMixin.Frames:DressUpFrame()
    WoWTools_DataMixin:Hook(DressUpOutfitDetailsSlotMixin, 'OnEnter', function(self)
        if self.transmogID then
            GameTooltip:AddLine('transmogID|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.transmogID)
            GameTooltip:Show()
        end
    end)
end



--战斗宠物，技能 SharedPetBattleTemplates.lua  SharedPetBattleAbilityTooltipTemplate
--PetBattlePrimaryAbilityTooltip
--PetJournalPrimaryAbilityTooltip
--FloatingPetBattleAbilityTooltip
function WoWTools_TooltipMixin.Frames:BattlePetTooltip()
    WoWTools_DataMixin:Hook('SharedPetBattleAbilityTooltip_SetAbility', function(self, abilityInfo)
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
            ..(self:Save().ctrl and not UnitAffectingCombat('player') and '  |A:NPE_Icon:0:0|aCtrl+Shift|TInterface\\AddOns\\WoWTools\\Source\\Texture\\Wowhead.tga:0|t' or '')
        )

        WoWTools_TooltipMixin:Set_Web_Link(self, {type='pet-ability', id=abilityID, name=name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency
    end)

--宠物面板提示
    WoWTools_DataMixin:Hook("BattlePetToolTip_Show", function(...)--BattlePetTooltip.lua 
        WoWTools_TooltipMixin:Set_Battle_Pet(BattlePetTooltip, ...)
    end)
    WoWTools_DataMixin:Hook('FloatingBattlePet_Show', function(...)--FloatingPetBattleTooltip.lua
        WoWTools_TooltipMixin:Set_Battle_Pet(FloatingBattlePetTooltip, ...)
    end)
    WoWTools_DataMixin:Hook(GameTooltip, "SetCompanionPet", function(self, petGUID)--设置宠物信息
        local speciesID= petGUID and C_PetJournal.GetPetInfoByPetID(petGUID)
        WoWTools_TooltipMixin:Set_Pet(self, speciesID)--宠物
    end)
end







function WoWTools_TooltipMixin.Frames:WarbandSceneEntryMixin()
    WoWTools_DataMixin:Hook(WarbandSceneEntryMixin, 'OnEnter', function(self)
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

        WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', tooltip)
    end)
end