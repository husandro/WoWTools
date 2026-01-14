--旅程 12.0才有
local function Save()
    return WoWToolsSave['Adventure_Journal']
end




local function Settings_Left_Button(self)
    local data= self.data or {}
    self.Name:SetText(WoWTools_TextMixin:CN(self.data.name) or '')
    --self.Name:SetTextColor(r or 1, g or 1, b or 1)
    self.Count:SetText(data.valueText or '')
    if data.atlas then
        self.Icon:SetAtlas(data.atlas)
    else
        self.Icon:SetTexture(data.texture or 0)
    end
end


local function SetScript_Left_Button(btn)
    if btn.Count2 then
       return
    end

    btn:SetPoint('RIGHT')
    btn.NameFrame:SetPoint('RIGHT')
    btn.NameFrame:SetTexture(0)
    btn.NameFrame:SetColorTexture(0, 0, 0, 0.3)

    btn.Name:ClearAllPoints()
    btn.Name:SetHeight(0)
    btn.Name:SetPoint('BOTTOMLEFT', btn.NameFrame, 2, 2)
    btn.Name:SetPoint('RIGHT', btn.NameFrame,-2, 0)--, btn.Count, 'LEFT', -2, 0)
    btn.Name:SetWordWrap(false)

    btn.Count:ClearAllPoints()
    btn.Count:SetPoint('TOPRIGHT', btn.NameFrame, -2, -2)
    btn.Count:SetJustifyH('RIGHT')
    btn.Count:SetFontObject('ChatFontNormal')

    btn:SetScript('OnHide', function(self)
        self.data=nil
        self.factionID= nil
    end)

    btn:SetScript('OnShow', function(self)
        
    end)

    btn:SetScript('OnEvent', function(self, _, itemID, success)
        
    end)

    btn:SetScript('OnLeave', function(self)
        WoWTools_SetTooltipMixin:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Faction(self)
    end)
end







local function Init_Button()
    local menu= CreateFrame('DropdownButton', 'WoWToolsEJFactionMenuButton', EncounterJournalJourneysFrame, 'WoWToolsMenuTemplate')
    menu:SetPoint('LEFT', EncounterJournalInstanceSelect.ExpansionDropdown, 'RIGHT', 8, 0)
    menu:SetNormalTexture(WoWTools_DataMixin.Icon.icon)

    menu.frame= CreateFrame('Frame')
    menu.frame:SetPoint('TOPLEFT', EncounterJournal, 'TOPRIGHT', 2, -23)
    menu.frame:SetPoint('BOTTOMLEFT', EncounterJournal, 'BOTTOMRIGHT', 2, 0)
    menu.frame:SetWidth(200)

    menu.ScrollBox= CreateFrame('Frame', nil, menu.frame, 'WowScrollBoxList')
    
    --[[menu.ScrollBox:SetPoint('TOPLEFT')
    menu.ScrollBox:SetPoint('BOTTOMLEFT')
    menu.ScrollBox:SetWidth(200)]]
    menu.ScrollBox:SetAllPoints()

    menu.ScrollBar= CreateFrame("EventFrame", nil, menu.frame, "MinimalScrollBar")
    menu.ScrollBar:SetPoint("TOPLEFT", menu.ScrollBox, "TOPRIGHT", 6, -12)
    menu.ScrollBar:SetPoint("BOTTOMLEFT", menu.ScrollBox, "BOTTOMRIGHT", 6, 12)
    WoWTools_TextureMixin:SetScrollBar(menu.ScrollBar)



    menu.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(menu.ScrollBox, menu.ScrollBar, menu.view)
    menu.view:SetElementInitializer('RenownCardButtonTemplate', function(btn, factionID)
        btn.majorFactionData= C_MajorFactions.GetMajorFactionData(factionID)
        btn.factionID= factionID

        local data= WoWTools_FactionMixin:GetInfo(factionID)
        btn.RenownCardFactionName:SetText(data.valueText or '')

        if data.atlas then
            btn.IconFrame.Icon:SetAtlas(data.atlas)
        else
            btn.IconFrame.Icon:SetTexture(data.texture or 0)
        end
    end)

    function menu:Init()
        local data= CreateDataProvider()
        local major= C_MajorFactions.GetMajorFactionIDs()

        table.sort(major, function(a, b) return b<a end)

        for _, factionID in pairs(major) do
            data:Insert(factionID)
        end
        self.view:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
    end

    if EncounterJournalJourneysFrame:IsShown() then
        menu:Init()
    end

    menu:SetScript('OnHide', function(self)
        self.view:SetDataProvider(CreateDataProvider(), ScrollBoxConstants.RetainScrollPosition)
    end)
    menu:SetScript('OnShow', function(self)
        self:Init()
    end)
end




















local function Init()
    if not EncounterJournalJourneysFrame or Save().hideJourneys then
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


--查看进度 JourneyProgressFrameMixin SetupProgressDetails
    WoWTools_DataMixin:Hook(EncounterJournalJourneysFrame.JourneyProgress, 'SetupRewardTrack', function(frame)
        local factionID= frame.majorFactionData and frame.majorFactionData.factionID
        if not frame.infoLabel then
            frame.infoLabel= frame:CreateFontString(nil, nil,'GameFontNormal')
            frame.infoLabel:SetPoint('TOP', frame.JourneyName, 'BOTTOM')
            frame.infoLabel:EnableMouse(true)
            frame.infoLabel:SetScript('OnLeave', function(self)
                WoWTools_SetTooltipMixin:Hide()
                self:SetAlpha(1)
            end)
            frame.infoLabel:SetScript('OnEnter', function(self)
                WoWTools_SetTooltipMixin:Faction(self)
                self:SetAlpha(0.5)
            end)
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
		if data and data.isRenownJourney then
            frame:HookScript('OnEnter', set_enter)
            frame:HookScript('OnLeave', set_leave)
            set_leave(frame)
        end
	end
    WoWTools_DataMixin:Hook(RenownCardButtonMixin, 'OnEnter', set_enter)
    WoWTools_DataMixin:Hook(RenownCardButtonMixin, 'OnLeave', set_leave)



   -- Init_Button()

    Init=function()
       -- _G['WoWToolsEJFactionMenuButton']:SetShown(not Save().hideJourneys)
    end
end














function WoWTools_EncounterMixin:Init_JourneysList()
    Init()
end

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