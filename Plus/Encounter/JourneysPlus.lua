

local function Init()
    if WoWToolsSave['Adventure_Journal'].hideJourneys then
        return
    end

    WoWTools_DataMixin:Hook(EncounterJournalJourneysFrame.JourneysList, 'Update', function(frame)
        if not frame:HasView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            if btn.CategoryDivider then
                WoWTools_TextureMixin:SetAlphaColor(btn.CategoryDivider, true)
            --elseif btn.CategoryName then

            elseif btn.majorFactionData then
                if not btn.infoLabe then
                    btn.infoLabe= btn:CreateFontString(nil, nil,'GameFontNormal')
                    if btn.JourneyCardName then
                        btn.infoLabe:SetPoint('TOPLEFT', btn.JourneyCardName, 'BOTTOMLEFT', 2, -4)
                    else
                        btn.infoLabe:SetPoint('BOTTOMLEFT', btn.RenownCardFactionName, 'TOPLEFT', 2, 4)
                    end
                end

                local factionID= btn.majorFactionData and btn.majorFactionData.factionID
                local data= WoWTools_FactionMixin:GetInfo(factionID)
--等级
                local levelLabel= btn.RenownCardFactionLevel or btn.JourneyCardLevel
                if levelLabel
                    and data.isUnlocked
                    and not data.isCapped
                    and data.factionStandingtext
                then
                    levelLabel:SetText(data.factionStandingtext)
                end
--经验
                btn.infoLabe:SetText(data.valueText or '')
--设置，背景
                btn.NormalTexture:SetShown(btn.majorFactionData.isUnlocked)
            end
        end
    end)


--查看进度 JourneyProgressFrameMixin SetupProgressDetails
    WoWTools_DataMixin:Hook(EncounterJournalJourneysFrame.JourneyProgress, 'SetupRewardTrack', function(frame)
        local factionID= frame.majorFactionData and frame.majorFactionData.factionID
        if not frame.infoLabel then
            frame.infoLabel= frame.ProgressDetailsFrame:CreateFontString(nil, nil,'GameFontNormal')
            --frame.infoLabel:SetPoint('TOP', frame.JourneyName, 'BOTTOM')
            frame.infoLabel:SetPoint('LEFT', frame.ProgressDetailsFrame, 'RIGHT')
            frame.infoLabel:EnableMouse(true)
            frame.infoLabel:SetScript('OnLeave', function(self)
                WoWTools_SetTooltipMixin:Hide()
                self:SetAlpha(1)
            end)
            frame.infoLabel:SetScript('OnEnter', function(self)
                WoWTools_SetTooltipMixin:Faction(self)
                self:SetAlpha(0.5)
            end)
            frame.ProgressDetailsFrame.JourneyLevelBar:SetPoint('RIGHT', frame.infoLabel, 6, 0)
        end

        local data= WoWTools_FactionMixin:GetInfo(factionID)
        frame.infoLabel:SetText(data.valueText or factionID or '')
        frame.infoLabel.factionID= factionID
    end)







    local function set_leave(self)
        if self.WatchedFactionToggleFrame and self.majorFactionData and self.majorFactionData.isUnlocked then
            local data= C_Reputation.GetWatchedFactionData()
            if data and data.factionID == self.majorFactionData.factionID then
                self.WatchedFactionToggleFrame:SetShown(true)
            end
        end
    end
    local function set_enter(self)
        local factionID= self.majorFactionData and self.majorFactionData.factionID
        if factionID then
            local tooltip= GameTooltip:IsShown() and GameTooltip or (EmbeddedItemTooltip:IsShown() and EmbeddedItemTooltip)
            if tooltip then
                WoWTools_TooltipMixin:Set_Faction(tooltip, factionID)
            end
        end
    end
    for _, frame in EncounterJournalJourneysFrame.JourneysList:EnumerateFrames() do
        local data= frame:GetElementData()
        if data then
            if data.isRenownJourney then
                frame:HookScript('OnEnter', set_enter)
                frame:HookScript('OnLeave', set_leave)
                set_leave(frame)
            end
        end
	end
    WoWTools_DataMixin:Hook(RenownCardButtonMixin, 'OnEnter', set_enter)
    WoWTools_DataMixin:Hook(RenownCardButtonMixin, 'OnLeave', set_leave)





    Init=function()end
end









function WoWTools_EncounterMixin:Init_JourneysPlus()
    Init()
end