local function SaveWoW()
    return WoWToolsPlayerDate.WorldMapPin
end

local Frame

local function GetMapName(mapID)
    local mapInfo= mapID and C_Map.GetMapInfo(mapID)
    if mapInfo then
        return WoWTools_TextMixin:CN(mapInfo.name)
    end
end









local function Find_Pool(name)
    local btn= _G['WoWToolsWorldFramePlayerPinButton']
    if not btn or not WorldMapFrame:IsVisible() or WorldMapFrame.mapID~=Frame.mapID then
        return
    end
    for b in btn.pool:EnumerateActive() do
        b:SetButtonState(name and b.data.name==name and 'PUSHED' or 'NORMAL')
    end
end






local function Save_Edit()
    local mapName
    mapName= Frame.nameEdit:GetText() or ''
    mapName= mapName:gsub(' ', '')~='' and mapName or nil
    local x, y= Frame.xyEdit:GetXY()

    if not mapName or not x or not y then
        return
    end
end






local function Add_ListButton(btn)
    btn.Delete= CreateFrame('Button', nil, btn, 'WoWToolsButtonTemplate')
    btn.Delete:SetNormalAtlas('common-icon-redx')
    btn.Delete:SetPoint('TOPRIGHT', -2, -2)
    btn.Delete:SetSize(20,20)
    btn.Delete:Hide()
    btn.Delete:SetScript('OnClick', function(self)
        local mapID= Frame.mapID
        local data= self:GetParent().data
        local name= data.name
        if name then
            SaveWoW()[mapID][name]= nil
            print(WoWTools_DataMixin.Icon,
            WoWTools_DataMixin.onlyChinese and '删除' or DELETE,
            data.name,
            data.data.icon,
            data.data.x,
            data.data.y,
            data.data.note
        )
        end

        Frame:Init()
    end)

    btn.Delete:SetScript('OnLeave', function(self)
        self:Hide()
        self:GetParent():SetButtonState('NORMAL')
    end)
    btn.Delete:SetScript('OnEnter', function(self)
        self:Show()
        self:GetParent():SetButtonState('PUSHED')
    end)

    function btn:set_select()
        self.Select:SetShown(Frame.selectName== self.data.name)
    end

    btn:SetScript('OnLeave', function(self)
        self.Delete:Hide()
        Find_Pool()
    end)

    btn:SetScript('OnEnter', function(self)
        self.Delete:Show()
        Find_Pool(self.data.name)
    end)
    btn:SetScript('OnHide', function(self)
        self.data= nil
    end)
    btn:SetScript('OnClick', function(self)
        Frame.selectName= self.data.name
        Frame:Init()
        Frame.nameEdit:SetText(self.data.name)
        Frame.xyEdit:SetText(self.data.data.x..' '..self.data.data.y)
        Frame.iconEdit:SetText(self.data.data.icon)
        Frame.noteEdit:SetText(self.data.data.note)
        Frame.nameEdit:SetFocus()
    end)
end











local function Initializer(self, data)
    if not self.Delete then
         Add_ListButton(self)
    end

    self.data= data

    self.Name:SetText(data.name or '')
    local isAtlas, textureID= WoWTools_TextureMixin:IsAtlas(data.data.icon)
    if isAtlas then
        self.Icon:SetAtlas(textureID)
    else
        self.Icon:SetTexture(textureID or 0)
    end
    self.Sub:SetText(data.data.x..'  '..data.data.y)
    self.Sub2:SetText(data.data.note or '')

    local color= data.color or CreateColor(1.0, 0.9294, 0.7607)
    self.Name:SetTextColor(color:GetRGB())

    self.Index:SetText(data.index)

    self:set_select()
end


























local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub
    for mapID, info in pairs(SaveWoW()) do

        sub=root:CreateRadio(
            mapID,
        function(data)
            return data.mapID==Frame.mapID
        end, function(data)
            Frame:Init({mapID=data.mapID})
            return MenuResponse.Refresh
        end, {
            rightText= CountTable(info)..' '..(GetMapName(mapID) or ''),
            mapID= mapID,
            data= info,
        })

        WoWTools_MenuMixin:SetRightText(sub)
    end
end





















local function Init(tab)
    Frame= WoWTools_FrameMixin:Create(UIParent, {
        name= 'WoWToolsPlayerPinEditUIFrame',
        size={580, 370},
        strata='HIGH',
        header= '|A:Ping_Wheel_Icon_Assist:0:0|a'..(WoWTools_DataMixin.onlyChinese and '地图标记' or MAP_PIN),
    })

    --Frame:Hide()

    Frame.list = CreateFrame("Frame", nil, Frame, "WowScrollBoxList")
    Frame.list:SetPoint("TOPLEFT", 12, -55)
    Frame.list:SetPoint("BOTTOMRIGHT", Frame, 'BOTTOM', 0, 6)


    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPLEFT", Frame.list, "TOPRIGHT", 8,-20)
    Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame.list, "BOTTOMRIGHT",8,20)
    WoWTools_TextureMixin:SetScrollBar(Frame)

    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.list, Frame.ScrollBar, Frame.view)

    --[[Frame.view:SetElementFactory(function(factory, elementData)
		if elementData.category then
			factory("JourneysListCategoryNameTemplate", CategoryNameInitializer);
		elseif elementData.divider then
			factory("JourneysListCategoryDividerTemplate", nop);
		elseif elementData.isRenownJourney then
			factory("RenownCardButtonTemplate", RenownCardInitializer);
		else
			factory("JourneyCardButtonTemplate", JourneyCardInitializer);
		end
	end);]]

    Frame.view:SetElementInitializer("WoWToolsPlayerPinButtonTemplate", Initializer)

    --[[
        icon= data.icon,
        x= data.x,
        y= data.y,
        note= data.note,
    ]]

    function Frame:Init(pinData)
        pinData = pinData or {}

        self.mapID= pinData.mapID or self.mapID or WoWTools_WorldMapMixin:GetMapID()

        local dataProvider = CreateDataProvider()

        local index= 0
        for name, pin in pairs(SaveWoW()[self.mapID] or {}) do

            for i=1, 22 do
                index= index +1
                dataProvider:Insert({
                    name= name,
                    data= pin,
                    index= index,
                })
            end
        end
        --[[dataProvider:SetSortComparator(function(a, b)
            if a and b then
                return #a.name> #b.name
            else
                return false
            end
        end)]]

        self.view:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
        self.num:SetText(index)

        local name= GetMapName(self.mapID)
        self.mapMenu:SetDefaultText(self.mapID..(name and ' '..name or ''))
    end


    Frame.worldButton= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    Frame.worldButton:SetPoint('BOTTOMLEFT', Frame.list, 'TOPLEFT', 0, 2)
    Frame.worldButton:SetNormalAtlas('poi-islands-table')
    function Frame.worldButton:tooltip(tooltip)

        local mapID= WoWTools_WorldMapMixin:GetMapID()
        local color= not mapID and WARNING_FONT_COLOR
                or (mapID==Frame.mapID and DISABLED_FONT_COLOR)
                or GREEN_FONT_COLOR

        tooltip:AddDoubleLine(color:WrapTextInColorCode(
            (WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
            ..' '..(mapID or (WoWTools_DataMixin.onlyChinese and '无' or NONE))),
            GetMapName(mapID)
        )
    end
    Frame.worldButton:SetScript('OnClick', function()
        local mapID= WoWTools_WorldMapMixin:GetMapID()
        if mapID then
            Frame:Init({mapID= mapID})
        end
    end)


    Frame.search= WoWTools_EditBoxMixin:Create(Frame, {isSearch=true})
    Frame.search:SetPoint('LEFT', Frame.worldButton, 'RIGHT', 8, 0)
    Frame.search:SetPoint('BOTTOMRIGHT', Frame.list, 'TOPRIGHT', 0, 2)

    

    Frame.newButton= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    Frame.newButton:SetPoint('BOTTOMLEFT', Frame.list, 'TOPRIGHT', 23, 0)
    Frame.newButton:SetNormalAtlas('common-icon-plus')

    Frame.mapMenu = CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    Frame.mapMenu:SetPoint('LEFT',Frame.newButton, 'RIGHT', 6, 0)
    Frame.mapMenu:SetPoint('RIGHT', -50, 0)
    Frame.mapMenu.Text:SetJustifyH('CENTER')
    Frame.mapMenu:SetupMenu(Init_Menu)

    Frame.num= Frame.mapMenu:CreateFontString(nil, 'BORDER', 'WoWToolsFont', -1)
    Frame.num:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
    Frame.num:SetPoint('LEFT', 4, 0)

    --[[local nameLabel= Frame:CreateFontString(nil, 'BORDER', 'WoWToolsFont')
    nameLabel:SetPoint('TOPLEFT', Frame.list, 'TOPRIGHT', 20, -20)
    nameLabel:SetText(WoWTools_DataMixin.onlyChinese and '名称' or NAME)

    
    local xyLabel= Frame:CreateFontString(nil, 'BORDER', 'WoWToolsFont')
    xyLabel:SetPoint('TOPLEFT', nameLabel, 'BOTTOMLEFT', 0, -20)
    xyLabel:SetText('XY')

    local iconLabel= Frame:CreateFontString(nil, 'BORDER', 'WoWToolsFont')
    iconLabel:SetPoint('TOPLEFT', xyLabel, 'BOTTOMLEFT', 0, -20)
    iconLabel:SetText(WoWTools_DataMixin.onlyChinese and '图标' or SELF_HIGHLIGHT_MODE_ICON)

    local notLabel= Frame:CreateFontString(nil, 'BORDER', 'WoWToolsFont')
    notLabel:SetPoint('TOPLEFT', iconLabel, 'BOTTOMLEFT', 0, -20)
    notLabel:SetText(WoWTools_DataMixin.onlyChinese and '备注' or LABEL_NOTE)]]

    

    Frame.nameEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 1)
    Frame.nameEdit:SetPoint('TOPLEFT', Frame.list, 'TOPRIGHT', 20, -20)
    Frame.nameEdit:SetPoint('RIGHT', -54, 0)
    Frame.nameEdit:SetHeight(23)
    Frame.nameEdit.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '名称' or NAME)
    Frame.nameEdit.searchIcon:SetAtlas('Gear')
    Frame.nameEdit:HookScript('OnTextChanged', function(self, userInput)
        if userInput and self:HasFocus() then
            Save_Edit(self)
        end
    end)
    

    Frame.xyEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 2)
    Frame.xyEdit:SetPoint('TOPLEFT',  Frame.nameEdit, 'BOTTOMLEFT', 0, -4)
    Frame.xyEdit:SetPoint('RIGHT', -54, 0)
    Frame.xyEdit:SetHeight(23)
    Frame.xyEdit.Instructions:SetText('XY')
    Frame.xyEdit.searchIcon:SetAtlas('UI-WorldMapArrow')
    function Frame.xyEdit:GetXY()
        local xy= Frame.xyEdit:GetText() or ''
        xy= xy:gsub('  ', ' ')
        local x, y= xy:match('(.-) (.+)')
        if x and y then
            x, y= tonumber(x), tonumber(y)
            if x and y and x>=0 and x<=100 and y>=0 and y<=100 then
                return x, y
            end
        end
    end
    Frame.xyEdit:HookScript('OnTextChanged', function(self, userInput)
        local x= self:GetXY()
        if x and userInput and self:HasFocus() then
            Save_Edit()
        end
        if not x then
            self:SetTextColor(WARNING_FONT_COLOR:GetRGB())
        else
            self:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
        end
    end)
    Frame.xyEdit:SetScript('OnLeave', GameTooltip_Hide)
    Frame.xyEdit:SetScript('OnEnter', function(self)
        local x, y= self:GetXY()
        if x and y then
            GameTooltip_ShowSimpleTooltip(GameTooltip,
                x..' '..y,
                SimpleTooltipConstants.NoOverrideColor,
                SimpleTooltipConstants.DoNotWrapText,
                self,
                "ANCHOR_RIGHT"
            )
        else
            GameTooltip_ShowSimpleTooltip(GameTooltip,
                WARNING_FONT_COLOR:GenerateHexColorMarkup()
                ..(WoWTools_DataMixin.onlyChinese and '坐标' or 'XY')
                ..' 50.00 60.00',
                SimpleTooltipConstants.NoOverrideColor,
                SimpleTooltipConstants.DoNotWrapText,
                self,
                "ANCHOR_RIGHT"
            )
        end
    end)

    Frame.iconEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 3)
    Frame.iconEdit:SetPoint('TOPLEFT', Frame.xyEdit, 'BOTTOMLEFT', 0, -4)
    Frame.iconEdit:SetPoint('RIGHT', -54, 0)
    Frame.iconEdit:SetHeight(23)
    Frame.iconEdit.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '图标' or SELF_HIGHLIGHT_MODE_ICON)
    Frame.iconEdit.searchIcon:SetTexture(0)
    Frame.iconEdit:HookScript('OnTextChanged', function(self, userInput)
        local icon= self:GetText() or ''
        if icon=='' then
            self.icon.icon:SetTexture(WoWTools_DataMixin.Icon.icon)
        else
            if C_Texture.GetAtlasID(icon)>0 then
                self.icon.icon:SetAtlas(icon)--:SetNormalAtlas(icon)
            else
                self.icon.icon:SetTexture(icon)--:SetNormalTexture(icon or WoWTools_DataMixin.Icon.icon)
            end
        end
        if userInput and self:HasFocus() then
            Save_Edit()
        end
    end)
    Frame.iconEdit.clearButton:HookScript('OnMouseUp', function()
        Save_Edit()
    end)

    Frame.iconEdit.icon= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    Frame.iconEdit.icon:SetPoint('LEFT', Frame.iconEdit, 'RIGHT')
    Frame.iconEdit.icon.icon= Frame.iconEdit.icon:CreateTexture(nil, 'BACKGROUND')
    Frame.iconEdit.icon.icon:SetAllPoints()
    function Frame.iconEdit.icon:tooltip()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '选择图标' or COMMUNITIES_CREATE_DIALOG_AVATAR_PICKER_INSTRUCTIONS)
        if not _G['TAV_CoreFrame'] then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('|cnWARNING_FONT_COLOR:Texture Atlas Viewer', WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)
        end
    end
    Frame.iconEdit.icon:SetScript('OnClick', function()
        WoWTools_TextureMixin:GetNewIcon(Frame, {
            --text= Frame.nameEdit:GetText(),
            texture= Frame.iconEdit:GetText(),
            SetValue=function(newIcon, newText)
                Frame.iconEdit:SetText(newIcon)
                Frame.nameEdit:SetText(newText)
                Save_Edit()
            end
        })
    end)


    Frame.noteEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 4)
    Frame.noteEdit:SetPoint('TOPLEFT',  Frame.iconEdit, 'BOTTOMLEFT', 0, -4)
    Frame.noteEdit:SetPoint('RIGHT', -54, 0)
    Frame.noteEdit:SetHeight(23)
    Frame.noteEdit.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '备注' or LABEL_NOTE)
    Frame.noteEdit.searchIcon:SetTexture(0)
    Frame.noteEdit:HookScript('OnTextChanged', function(self, userInput)
        if userInput and self:HasFocus() then
            Save_Edit()
        end
    end)
    Frame.noteEdit.clearButton:HookScript('OnMouseUp', function()
        Save_Edit()
    end)


--设置，TAB键
    Frame.tabGroup= CreateTabGroup(Frame.nameEdit, Frame.xyEdit, Frame.iconEdit, Frame.noteEdit)
    Frame.nameEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)
    Frame.xyEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)
    Frame.iconEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)
    Frame.noteEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)



    Frame:SetScript('OnHide', function(self)
        self.view:SetDataProvider(CreateDataProvider(), ScrollBoxConstants.RetainScrollPosition)
    end)



    Frame:Init(tab)

    Init=function()end
end










function WoWTools_WorldMapMixin:Init_PlayerPin_EditUI(data)
    if Frame then
        Frame:SetShown(data and true or not Frame:IsShown())
        if Frame:IsShown() then
            Frame:Init(data)
        end
    else
        Init(data)
    end
end