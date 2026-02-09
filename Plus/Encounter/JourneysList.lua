--旅程 12.0才有
local function Save()
    return WoWToolsSave['Adventure_Journal']
end


local Buttons={}

local function Set_Text(self)
    local data= WoWTools_FactionMixin:GetInfo(self.factionID)
    if data.atlas then
        self:SetNormalAtlas(data.atlas)
    else
        self:SetNormalTexture(data.texture or 0)
    end

    local text
    if not data.isCapped then
        text= data.factionStandingtext
    end
    if data.valueText then
        text= (text and text..' ' or '')..data.valueText
    end

    if text and data.barColor then
        text= data.barColor:WrapTextInColorCode(text)
    end

    if data.name and self.isCurVer then
        local name= WoWTools_TextMixin:CN(data.name)
        if not data.isUnlocked then
            name= DISABLED_FONT_COLOR:WrapTextInColorCode(name)
        end
        text= name..(text and ' '..text or '')
    end

    self.text:SetText(text or '')
end
















local function Create_Button(frame, index)
    local btn= CreateFrame('Button', nil, frame, 'WoWToolsButtonTemplate')

    btn.canClickForOptions= true

    --btn.text= btn:CreateFontString(nil, 'BORDER', 'GameFontNormal')
    btn.text=btn:CreateFontString(nil, 'BORDER', 'ChatFontNormal')
    btn.text:SetFontHeight(12)
    btn.text:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
    btn.text:SetShadowOffset(1,-1)
    btn.text:SetPoint('LEFT', btn, 'RIGHT')

    btn:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 0, -(index-1)*23)

    btn:SetScript('OnHide', function(self)
        self.text:SetText('')
        self:SetNormalTexture(0)
        self:UnregisterAllEvents()
    end)
    btn:SetScript('OnShow', function(self)
        Set_Text(self)
        self:RegisterEvent('MAJOR_FACTION_RENOWN_LEVEL_CHANGED')
    end)
    btn:SetScript('OnEvent', function(self, _, factionID)
        if factionID== self.factionID then
            Set_Text(self)
        end
    end)
    btn:SetScript('OnLeave', function()
        WoWTools_SetTooltipMixin:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Faction(self)
    end)
    btn:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            WoWTools_LoadUIMixin:OpenFaction(self.factionID)
        elseif EncounterJournalJourneysFrame then
            EncounterJournalJourneysFrame:ResetView(nil, self.factionID)
        end
    end)
    Buttons[index]= btn
    return btn
end











local function Init_Button()
    if Save().hideJourneys or Save().hideJourneysList then
        return
    end

    local menu= CreateFrame('DropdownButton', 'WoWToolsEJFactionMenuButton', EncounterJournalJourneysFrame, 'WoWToolsMenuTemplate')
    --menu:SetPoint('LEFT', EncounterJournalInstanceSelect.ExpansionDropdown, 'RIGHT', 8, 0)
    menu:SetNormalTexture(WoWTools_DataMixin.Icon.icon)

    menu.frame= CreateFrame('Frame', nil, menu)
    menu.frame:SetPoint('TOPLEFT', EncounterJournalCloseButton, 'TOPRIGHT', 8, 0)
    menu.frame:SetSize(1,1)
    menu.frame.Bg= menu.frame:CreateTexture(nil, "BACKGROUND")
    menu.frame.Bg:SetColorTexture(0,0,0,0.5)
    menu.frame.Bg:SetPoint('TOPLEFT')




    function menu:Init()

        local tab= {}
        local w= 0
        local num= 0


            for _, factionID in pairs(C_MajorFactions.GetMajorFactionIDs()) do
                if not C_MajorFactions.IsMajorFactionHiddenFromExpansionPage(factionID) then
                    local major= C_MajorFactions.GetMajorFactionData(factionID)
                    if major and major.factionID and major.name then
                        table.insert(tab, major)
                    end
                end
            end

            table.sort(tab, function(a, b)
                if a.expansionID==b.expansionID then
                    return a.factionID> b.factionID
                else
                    return a.expansionID> b.expansionID
                end
            end)

            local height= EncounterJournal:GetHeight()



            for index, major in pairs(tab) do
                local y= index*23
                if y > height then
                    break
                end
                num= index

                local btn= Buttons[index] or Create_Button(self.frame, index)
                btn.factionID= major.factionID
                btn.isCurVer= major.expansionID== WoWTools_DataMixin.ExpansionLevel
                Set_Text(btn)
                btn:SetShown(true)

                w= math.max(w, btn.text:GetWidth()+23)
            end


        self.frame.Bg:SetPoint('BOTTOMLEFT', Buttons[num] or self.frame)
        self.frame.Bg:SetWidth(w)

        for index=num+1, #Buttons do
            Buttons[index]:SetShown(false)
        end
    end



    menu:Init()

    menu.frame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
    end)
    menu.frame:SetScript('OnShow', function(self)
        self:RegisterEvent('MAJOR_FACTION_UNLOCKED')
    end)
    menu.frame:SetScript('OnEvent', function(self)
        self:GetParent():Init()
    end)

    EncounterJournalJourneysFrame:HookScript('OnSizeChanged', function()
        _G['WoWToolsEJFactionMenuButton']:Init()
    end)

    Init_Button= function()
        _G['WoWToolsEJFactionMenuButton']:SetShown(
            not (Save().hideJourneys or  Save().hideJourneysList)
        )
        _G['WoWToolsEJFactionMenuButton']:Init()
    end
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














function WoWTools_EncounterMixin:Init_JourneysList()
    Init()
    Init_Button()
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