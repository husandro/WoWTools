--旅程 12.0才有
local function Save()
    return WoWToolsSave['Adventure_Journal'].JourneysList
end


--local Buttons={}
local Button

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

    if Save().name and data.name and (not Save().onlyCurVerName or self.isCurVer) then
        local name= WoWTools_TextMixin:CN(data.name)
        if not data.isUnlocked then
            name= DISABLED_FONT_COLOR:WrapTextInColorCode(name)
        end
        text= name..(text and ' '..text or '')
    end

    self.text:SetText(text or '')
end
















local function Create_Button(btn)
    btn.canClickForOptions= true
    btn.text=btn:CreateFontString(nil, 'BORDER', 'ChatFontSmall')
    btn.text:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
    btn.text:SetShadowOffset(1,-1)
    btn.text:SetPoint('LEFT', btn, 'RIGHT')


    btn:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
    end)
    btn:SetScript('OnShow', function(self)
        self:RegisterEvent('MAJOR_FACTION_RENOWN_LEVEL_CHANGED')
        self:RegisterEvent('MAJOR_FACTION_UNLOCKED')
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
    --Buttons[index]= btn
    --return btn
end








local function Init_Button()
    Button.pool:ReleaseAll()
    local tab= {}
    for _, factionID in pairs(C_MajorFactions.GetMajorFactionIDs() or {}) do
        --if not C_MajorFactions.IsMajorFactionHiddenFromExpansionPage(factionID) then
            local major= C_MajorFactions.GetMajorFactionData(factionID)
            if major and major.factionID and major.name then
                table.insert(tab, major)
            end
        --end
    end

    if #tab==0 then
        return
    end

    table.sort(tab, function(a, b)
        if a.expansionID==b.expansionID then
            return a.factionID> b.factionID
        else
            return a.expansionID> b.expansionID
        end
    end)

    local height= EncounterJournal:GetHeight()
    local scale= Button.frame:GetScale()
    local w= 0
    local last= Button.frame

    for index, major in pairs(tab) do
        local y= index*23*scale
        if y > height then
            break
        end

        local btn= Button.pool:Acquire()
        if not btn.text then
            Create_Button(btn)
        end

        btn.factionID= major.factionID
        btn.isCurVer= major.expansionID== WoWTools_DataMixin.ExpansionLevel
        Set_Text(btn)
        btn:SetPoint('TOPLEFT', last, 'BOTTOMLEFT')
        btn:SetShown(true)

        w= math.max(w, btn.text:GetWidth()+27)

        last= btn
    end


    Button.Bg:SetPoint('BOTTOMLEFT', last or Button.frame, 1, -1)
    Button.Bg:SetWidth(w)
end










local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub
--显示名称
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '显示名称' or PROFESSIONS_FLYOUT_SHOW_NAME,
    function ()
        return Save().name
    end, function ()
        Save().name= not Save().name and true or nil
        self:settings()
    end)
    sub=sub:CreateCheckbox(
        WoWTools_DataMixin:GetExpansionText(WoWTools_DataMixin.ExpansionLevel),
    function()
        return Save().onlyCurVerName
    end, function()
        Save().onlyCurVerName= not Save().onlyCurVerName and true or nil
        self:settings()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '仅显示' or format(LFG_LIST_CROSS_FACTION, SHOW))
    end)

    root:CreateDivider()
    --背景, 透明度
    WoWTools_MenuMixin:BgAplha(root,
    function()
        return Save().bgAlpha or 0.5
    end, function(value)
        Save().bgAlpha= value
        self:settings()
    end, function()
        Save().bgAlpha= nil
        self:settings()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, root,
    function()--GetValue
        return Save().scale or 1
    end, function(value)--SetValue
        Save().scale= value
        self:settings()
    end, function()--SetValue
        Save().scale= nil
        self:settings()
    end)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_EncounterMixin.addName})
end













local function Init()
    if Save().disabled then
        return
    end

    Button= CreateFrame('DropdownButton', 'WoWToolsEJFactionMenuButton', EncounterJournalJourneysFrame, 'WoWToolsMenuTemplate')
    Button:SetPoint('LEFT', EncounterJournalInstanceSelect.ExpansionDropdown, 'RIGHT', 8, 0)
    Button:SetNormalTexture(0)
    Button.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '名望列表' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, JOURNEYS_RENOWN_LABEL, 'List'))
    Button:SetupMenu(Init_Menu)

    Button.text= Button:CreateFontString(nil, 'BORDER', 'ChatFontSmall')
    Button.text:SetPoint('CENTER')
    Button.text:SetShadowOffset(1,-1)
    Button.text:SetTextColor(NORMAL_FONT_COLOR:GetRGB())

    Button.frame= CreateFrame('Frame', nil, Button)
    Button.frame:SetPoint('TOPLEFT', EncounterJournal, 'TOPRIGHT', 0, 1)
    Button.frame:SetSize(1,1)
    Button.Bg= Button.frame:CreateTexture(nil, "BACKGROUND")
    Button.Bg:SetColorTexture(0,0,0)
    Button.Bg:SetPoint('TOPLEFT', -3, 0)

    Button.pool= CreateFramePool('Button', Button.frame, 'WoWToolsButtonTemplate')

    Button:SetScript('OnShow', function(self)
        self.text:SetFormattedText('%d', #C_MajorFactions.GetMajorFactionIDs())
        self:SetWidth(math.max(self.text:GetStringWidth()+8, 23))
    end)





    Button.frame:SetScript('OnHide', function(self)
        --self:UnregisterAllEvents()
        self:GetParent().pool:ReleaseAll()
    end)
    Button.frame:SetScript('OnShow', function(self)
        --self:RegisterEvent('MAJOR_FACTION_UNLOCKED')
        Button:settings()
    end)
    --Button.frame:SetScript('OnEvent', Init_Button)

    function Button:settings()
        self.Bg:SetAlpha(Save().bgAlpha or 0.5)
        self.frame:SetScale(Save().scale or 1)
        Init_Button()
    end

    EncounterJournalJourneysFrame:HookScript('OnSizeChanged', function()
        if not Save().disabled then
            Init_Button()
        end
    end)

    Button:settings()

    Init= function()
       Button:SetShown(not Save().disabled)
    end
end








function WoWTools_EncounterMixin:Init_JourneysList()
    Init()
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
    end)
    
    
    
    
    
    
    
    提示factionID, 显示CheckBox
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