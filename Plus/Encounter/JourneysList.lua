--旅程 12.0才有

local function Init()
    if not EncounterJournalJourneysFrame then
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

                btn.infoLabe:SetText(data.valueText or '')

                btn.NormalTexture:SetShown(btn.majorFactionData.isUnlocked)
            end
        end
    end)


--查看进度 JourneyProgressFrameMixin
    WoWTools_DataMixin:Hook(EncounterJournalJourneysFrame.JourneyProgress, 'SetupProgressDetails', function(frame)
        if not frame.infoLabel then
            frame.infoLabel= frame:CreateFontString(nil, nil,'GameFontNormal')
            frame.infoLabel:SetPoint('TOP', frame.ProgressDetailsFrame.JourneyLevelProgress, 'BOTTOM', 0,2)
        end
        local factionID= frame.majorFactionData.factionID
        local data= WoWTools_FactionMixin:GetInfo(factionID)
        frame.infoLabel:SetText(data.valueText or '')
    end)


--[[提示factionID, 显示CheckBox
	view:SetElementFactory(function(factory, elementData)
		if elementData.category then
			factory("JourneysListCategoryNameTemplate", CategoryNameInitializer);
		elseif elementData.divider then
			factory("JourneysListCategoryDividerTemplate", nop);
		elseif elementData.isRenownJourney then
			factory("RenownCardButtonTemplate", RenownCardInitializer);
		else
			factory("JourneyCardButtonTemplate", JourneyCardInitializer);
		end
	end);
]]

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
		if data and data.isRenownJourney then
            frame:HookScript('OnEnter', set_enter)
            frame:HookScript('OnLeave', set_leave)
            set_leave(frame)
        end
	end
    WoWTools_DataMixin:Hook(RenownCardButtonMixin, 'OnEnter', set_enter)
    WoWTools_DataMixin:Hook(RenownCardButtonMixin, 'OnLeave', set_leave)

    Init=function()end
end

function WoWTools_EncounterMixin:Init_JourneysList()
    Init()
end