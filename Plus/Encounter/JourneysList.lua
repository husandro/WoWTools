--旅程 12.0才有
local function Save()
    return WoWToolsSave['Adventure_Journal']
end


local Buttons={}




local function Create_Button(frame, index)
    local btn= CreateFrame('Button', nil, frame, 'WoWToolsButtonTemplate')

    btn.text= btn:CreateFontString(nil, 'BORDER', 'GameFontNormal')
    btn.text:SetFontHeight(18)
    btn.text:SetPoint('LEFT', btn, 'RIGHT')

    btn:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 0, -(index-1)*23)

    function btn:Init()
        local data= WoWTools_FactionMixin:GetInfo(self.factionID)
        if data.atlas then
            self:SetNormalAtlas(data.atlas)
        else
            self:SetNormalTexture(data.texture or 0)
        end
        
        local name= (WoWTools_TextMixin:CN(data.name))
        local factionStandingtext= not data.isCapped and data.factionStandingtext
        local valueText= data.valueText
        self.text:SetText(
            (name or '')
            ..(name and ' ' or '')
            ..(factionStandingtext and HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(factionStandingtext) or '')
            ..(factionStandingtext and ' ' or '')
            ..(valueText or '')
        )
    end

    btn:SetScript('OnHide', function(self)
        self.text:SetText('')
        self:SetNormalTexture(0)
    end)
    btn:SetScript('OnShow', btn.Init)
    btn:SetScript('OnLeave', function(self)
        WoWTools_SetTooltipMixin:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Faction(self)
    end)
    btn:SetScript('OnClick', function(self)
        WoWTools_LoadUIMixin:MajorFaction(self.factionID)
    end)
    Buttons[index]= btn
    return btn
end


local function Init_Button()
    local menu= CreateFrame('DropdownButton', 'WoWToolsEJFactionMenuButton', EncounterJournalJourneysFrame, 'WoWToolsMenuTemplate')
    menu:SetPoint('LEFT', EncounterJournalInstanceSelect.ExpansionDropdown, 'RIGHT', 8, 0)
    menu:SetNormalTexture(WoWTools_DataMixin.Icon.icon)

    menu.frame= CreateFrame('Frame', nil, menu)
    menu.frame:SetPoint('TOPLEFT', EncounterJournalCloseButton, 'BOTTOMRIGHT', 8, 0)
    menu.frame:SetSize(1,1)

    function menu:Init()
        local major= C_MajorFactions.GetMajorFactionIDs()
        table.sort(major, function(a, b) return b<a end)

        local height, num= EncounterJournal:GetHeight()-46, 0

        for index, factionID in pairs(major) do
            local y= num*23
            if y > height then
                break
            end
            num= num+1
            local btn= Buttons[index] or Create_Button(self.frame, index)
            btn.factionID= factionID
            btn:Init()
        end

        for index=num+1, #Buttons do
            Buttons[index]:Hide()
        end
    end

    menu:Init()
end

    --[[menu.ScrollBox= CreateFrame('Frame', nil, menu.frame, 'WowScrollBoxList')
    
    menu.ScrollBox:SetPoint('TOPLEFT', EncounterJournal, 'TOPRIGHT', 8, -23)
    menu.ScrollBox:SetPoint('BOTTOMLEFT', EncounterJournal, 'BOTTOMRIGHT', 8, 0)
    menu.ScrollBox:SetWidth(200)

    menu.ScrollBar= CreateFrame("EventFrame", nil, menu, "MinimalScrollBar")
    menu.ScrollBar:SetPoint("TOPRIGHT", menu.ScrollBox, "TOPLEFT", 0, -12)
    menu.ScrollBar:SetPoint("BOTTOMRIGHT", menu.ScrollBox, "BOTTOMLEFT", 0, 12)
    WoWTools_TextureMixin:SetScrollBar(menu.ScrollBar)



    menu.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(menu.ScrollBox, menu.ScrollBar, menu.view)
    menu.view:SetElementInitializer('WoWToolsButtonTemplate', Set_Button)

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
    end)]]




















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
                                
                if data.isUnlocked and not data.isCapped and data.factionStandingtext then
                    btn.RenownCardFactionLevel:SetText(data.factionStandingtext)
                end
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



    Init_Button()

    Init=function()
        _G['WoWToolsEJFactionMenuButton']:SetShown(not Save().hideJourneys)
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