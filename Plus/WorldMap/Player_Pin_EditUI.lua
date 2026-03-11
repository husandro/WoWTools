local function SaveWoW()
    return WoWToolsPlayerDate.PlayerMapPin
end

local Frame
local function GetMapName(mapID)
    local mapInfo= mapID and C_Map.GetMapInfo(mapID)
    if mapInfo then
        local count= 0
        if SaveWoW()[mapID] then
            count= CountTable(SaveWoW()[mapID])
        end
        return mapID
                ..' '..WoWTools_TextMixin:CN(mapInfo.name)
                ..' ('..(count==0 and DISABLED_FONT_COLOR:WrapTextInColorCode(count) or count)..')'
    end
end
local function GetClassName(classID)
    local classInfo = classID and C_CreatureInfo.GetClassInfo(classID)
    if classInfo and classInfo.className and classInfo.classFile then
        local color= RAID_CLASS_COLORS[classInfo.classFile] or HIGHLIGHT_FONT_COLOR
        local icon= WoWTools_UnitMixin:GetClassIcon(nil, nil, classInfo.classFile)
        return (icon or '')--职业图标
            ..color:WrapTextInColorCode(WoWTools_TextMixin:CN(classInfo.className))
            ..(classID== PlayerUtil.GetClassID() and '|A:recipetoast-icon-star:0:0|a' or ''),
            color,--2
            icon--3
    end
end
local function GetProfessionName(skillLineID)
    local info= skillLineID and C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
    if info and info.professionName and info.professionName~='' then
        local textureID, icon= select(2, WoWTools_TextureMixin:IsAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[skillLineID]))

        return (C_SpellBook.GetSkillLineIndexByID(skillLineID) and '|cnGREEN_FONT_COLOR:' or '')
                ..(icon or '')
                .. WoWTools_TextMixin:CN(info.professionName),
                info.professionName,--2
                textureID,--3
                icon--4
    end
end
local function GetProfessionIcon(profession)
    if profession then
        local text
        for skillLineID in pairs(profession) do
            local name, _, icon= select(2, GetProfessionName(skillLineID))
            if icon then
                text= (text or '')..icon
            elseif name then
                text= (text and text..',' or '')..WoWTools_TextMixin:CN(name)
            else
                text= (text and text..',' or '')..skillLineID
            end
        end
        return text
    end
end
local function GetClassIcon(class)
    if class then
        local text
        for classID in pairs(class) do
            local icon= select(3, GetClassName(classID))
            text= (text or '')..(icon or ((text and text..',' or '')..classID))
        end
        return text
    end
end






--[[local function Find_Pool(xy)
    local btn= _G['WoWToolsWorldFramePlayerPinButton']
    if not btn or not WorldMapFrame:IsVisible() or WorldMapFrame.mapID~=Frame.mapID then
        return
    end
    for b in btn.pool:EnumerateActive() do
        b:SetButtonState(xy and b.data and b.data.xy==xy and 'PUSHED' or 'NORMAL')
    end
end]]





local function Set_UpdataAddButton_Stat()
    local isUpdate, isAdd= false, false

    local mapID= Frame.mapID
    local name= Frame.nameEdit.name
    local icon= Frame.iconEdit.icon

    local xy= Frame.xyEdit.xy
    local xy2= Frame.selectXY

    if mapID and (name or icon) and xy then
        local data= SaveWoW()[mapID] or {}

        isUpdate= xy2 and data[xy2] and true or false
        isAdd= not data[xy] and true or false
    end

    Frame.addButton:SetEnabled(isAdd)
    Frame.updateButton:SetEnabled(isUpdate)
end






local function Refresh_All(pinData)
    local dataProvider = CreateDataProvider()

    pinData = pinData or {}

    local mapID= pinData.mapID or Frame.mapID or WoWTools_WorldMapMixin:GetMapID()
    Frame.mapID= mapID

    local findText
    if pinData.xy then
        Frame.search:SetText(pinData.xy)
        findText= pinData.xy
    else
        findText= Frame.search:GetText()
    end
    findText= findText:gsub(' ', '')~='' and findText or nil

    for xy, pin in pairs(SaveWoW()[mapID] or {}) do
        if not findText  or (
            pin:find(findText)
            or (pin.name and pin.name:find(findText))
            or (pin.note and pin.note:find(findText))
        )
        then
            local x, y= WoWTools_WorldMapMixin:GetXYForText(xy)
            dataProvider:Insert({
                x= x,
                y= y,
                xy= xy,
                pin= pin
            })
        end

    end
    dataProvider:SetSortComparator(function(a, b)
        if a and b then
            if a.x==b.x then
                return a.y< b.y
            else
                return a.x< b.x
            end
        else
            return false
        end
    end)

    Frame.view:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)

    Frame.mapMenu:SetText(GetMapName(Frame.mapID) or Frame.mapMenu:GetDefaultText())

    Set_UpdataAddButton_Stat()
end




















local function Add_ListButton(btn)
    btn.Delete= CreateFrame('Button', nil, btn, 'WoWToolsButtonTemplate')
    btn.Delete:SetNormalAtlas('common-icon-redx')
    local icon= btn.Delete:GetNormalTexture()
    icon:ClearAllPoints()
    icon:SetPoint('TOPLEFT', 3, -3)
    icon:SetPoint('BOTTOMRIGHT', -3, 3)
    btn.Delete:SetPoint('TOPRIGHT', -2, -2)
    btn.Delete:SetSize(20,20)
    btn.Delete:Hide()
    btn.Delete.owner= 'ANCHOR_RIGHT'
    btn.Delete.tooltip= WoWTools_DataMixin.onlyChinese and '删除' or DELETE

    btn.Delete:SetScript('OnClick', function(self)
        local data= self:GetParent().data
        SaveWoW()[Frame.mapID][data.xy]= nil
        print(
            WoWTools_DataMixin.Icon.icon2..self.tooltip,
            data.pin.name,
            data.pin.icon,
            data.xy,
            data.pin.note
        )
        Refresh_All()
    end)

    btn.Delete:SetScript('OnLeave', function(self)
        self:Hide()
        self:GetParent():SetButtonState('NORMAL')
        GameTooltip:Hide()
    end)
    btn.Delete:SetScript('OnEnter', function(self)
        self:Show()
        self:GetParent():SetButtonState('PUSHED')
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip_SetTitle(GameTooltip, self.tooltip)
        GameTooltip:Show()
    end)

    function btn:set_select()
        self.Select:SetShown(Frame.selectXY== self.data.xy)
    end

    btn:SetScript('OnLeave', function(self)
        self.Delete:Hide()
        WoWTools_WorldMapMixin:PlayerPin_ScrollToPin(Frame.mapID)
    end)

    btn:SetScript('OnEnter', function(self)
        self.Delete:Show()
        WoWTools_WorldMapMixin:PlayerPin_ScrollToPin(Frame.mapID, self.data.xy)
    end)

    function btn:set_event()
        self:set_select()
        EventRegistry:RegisterCallback("WoWToolsPlayrPin.UpateSelect", self.set_select, self)
    end

    btn:SetScript('OnHide', function(self)
        EventRegistry:UnregisterCallback("WoWToolsPlayrPin.UpateSelect", self)
        self.data= nil
    end)
    btn:SetScript('OnClick', function(self)
        local data= self.data

        Frame.selectXY= data.xy

        Frame.nameEdit:SetText(data.pin.name or '')
        Frame.xyEdit:SetText(data.xy)
        Frame.iconEdit:SetText(data.pin.icon or '')
        Frame.noteEdit:SetText(data.pin.note or '')

        Frame.professionMenu.profession= data.pin.profession or {}
        Frame.professionMenu:SetText(GetProfessionIcon(data.pin.profession) or Frame.professionMenu:GetDefaultText())

        Frame.classMenu.class= data.pin.class or {}
        Frame.classMenu:SetText(GetClassIcon(data.pin.class) or Frame.classMenu:GetDefaultText())

        local color
        if data.pin.color then
            color= CreateColor(data.pin.color.r or 1, data.pin.color.g or 1, data.pin.color.b or 1)
        end
        Frame.colorButton.color= color
        Frame.colorButton:set_color()

        Frame.nameEdit:SetFocus()
        EventRegistry:TriggerEvent("WoWToolsPlayrPin.UpateSelect")
    end)

end











local function Initializer(self, data)
    if not self.Delete then
        Add_ListButton(self)
    end

    self.data= data

--图标
    local icon= data.pin.icon
    if icon then
        if C_Texture.GetAtlasID(icon)>0 then
            self.Icon:SetAtlas(icon)
        else
            self.Icon:SetTexture(icon or 0)
        end
    else
        self.Icon:SetTexture(0)
    end
--名称
    self.Name:SetText(data.pin.name or '')
--颜色
    if data.pin.name then
        local color= data.pin.color
        if color then
            self.Name:SetTextColor(color.r, color.g, color.b)
        else
            self.Name:SetTextColor(Frame.colorButton.valueColor:GetRGB())
        end
    end
--xy
    self.Sub:SetText(data.xy)

--备注，设置
    local note= (GetProfessionIcon(data.pin.profession) or '')--仅限专业
    note= note..(GetClassIcon(data.pin.class) or '')--仅限职业
    self.Sub2:SetText(note..(data.pin.note or ''))
--索引
    self.Index:SetText(self:GetElementDataIndex())

    self:set_event()
end























local function Add_Updata_Data(isUpdate)
    local mapID= Frame.mapID
--名称
    local name= Frame.nameEdit:GetText()
    name= name:gsub(' ', '')~='' and name or nil
--图标
    local icon= Frame.iconEdit:GetText()
    icon= icon:gsub(' ', '')~='' and icon or nil
--xy 50.00 50.00 这个是字符
    local x, y= WoWTools_WorldMapMixin:GetXYForText(Frame.xyEdit:GetText())
    local xy= WoWTools_WorldMapMixin:GetTextForXY(x, y)

    if not mapID or not xy or not (name or icon) then
        return
    end
--备注
    local note= Frame.noteEdit:GetText()
    note= note:gsub(' ', '')~='' and note or nil
--仅限专业
    local profession= Frame.professionMenu.profession
    if profession and CountTable(profession)==0 then
        profession = nil
    end
--仅限职业
    local class= Frame.classMenu.class
    if class and CountTable(class)==0 then
        class = nil
    end
--颜色 {r=r, g=g, b=b}
    local color
    if name and Frame.colorButton.color and not tCompare(Frame.colorButton.color, Frame.colorButton.valueColor) then
        local r,g,b= Frame.colorButton.color:GetRGB()
        if r and g and b then
            color= {r=r, g=g, b=b}
        end
    end

    SaveWoW()[mapID]= SaveWoW()[mapID] or {}

--如果是更新，先删除原来
    if isUpdate and SaveWoW()[mapID][Frame.selectXY] then
        SaveWoW()[mapID][Frame.selectXY]= nil
    end

    Frame.selectXY= xy

    SaveWoW()[mapID][xy]= {
        name= name,
        icon= icon,
        note= note,
        color= color,
        class= class,
        profession= profession,
    }

    Refresh_All()

    Frame.ScrollBox:ScrollToElementDataByPredicate(function(data)
        return data.xy==xy
    end)
    WoWTools_WorldMapMixin:Init_PlayerPin_RefreshMapMarkers()
end





















local function Init()
    Frame= WoWTools_FrameMixin:Create(UIParent, {
        name= 'WoWToolsPlayerPinEditUIFrame',
        size={580, 370},
        strata='HIGH',
        header= WoWTools_WorldMapMixin.addName2,
        notEsc=true,
    })

    --Frame:Hide()

    Frame.ScrollBox = CreateFrame("Frame", nil, Frame, "WowScrollBoxList")
    Frame.ScrollBox:SetPoint("TOPLEFT", 12, -55)
    Frame.ScrollBox:SetPoint("BOTTOMRIGHT", Frame, 'BOTTOM', -100, 6)
    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPLEFT", Frame.ScrollBox, "TOPRIGHT", 8,-20)
    Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame.ScrollBox, "BOTTOMRIGHT",8,20)
    WoWTools_TextureMixin:SetScrollBar(Frame)
    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollBox, Frame.ScrollBar, Frame.view)
    Frame.view:SetElementInitializer("WoWToolsPlayerPinButtonTemplate", Initializer)


    Frame.worldButton= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    Frame.worldButton:SetPoint('BOTTOMLEFT', Frame.ScrollBox, 'TOPLEFT', 0, 2)
    Frame.worldButton:SetNormalAtlas('poi-islands-table')
    function Frame.worldButton:tooltip(tooltip)
        local mapID= WoWTools_WorldMapMixin:GetMapID()
        local color= not mapID and WARNING_FONT_COLOR
                or (mapID==Frame.mapID and GREEN_FONT_COLOR)
                or HIGHLIGHT_FONT_COLOR

        tooltip:AddDoubleLine(
            color:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS),
            GetMapName(mapID)
        )
    end
    Frame.worldButton:SetScript('OnClick', function()
        local mapID= WoWTools_WorldMapMixin:GetMapID()
        if mapID then
            Frame.mapID= mapID
            Refresh_All()
        end
    end)


    Frame.search= WoWTools_EditBoxMixin:Create(Frame, {isSearch=true})
    Frame.search:SetPoint('LEFT', Frame.worldButton, 'RIGHT', 8, 0)
    Frame.search:SetPoint('BOTTOMRIGHT', Frame.ScrollBox, 'TOPRIGHT', 0, 2)
    Frame.search:SetScript('OnTextChanged', function(_, userInput)
        if userInput then
            Refresh_All()
        end
    end)
    Frame.search.clearButton:HookScript('OnMouseUp', function()
        Refresh_All()
    end)



    Frame.newButton= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    Frame.newButton:SetPoint('BOTTOMLEFT', Frame.ScrollBox, 'TOPRIGHT', 23, -5)
    Frame.newButton:SetNormalAtlas('common-icon-plus')
    Frame.newButton:GetNormalTexture():ClearAllPoints()
    Frame.newButton:GetNormalTexture():SetPoint('TOPLEFT', 4, -4)
    Frame.newButton:GetNormalTexture():SetPoint('BOTTOMRIGHT', -4, 4)
    Frame.newButton.tooltip= WoWTools_DataMixin.onlyChinese and '新建' or NEW
    Frame.newButton:SetScript('OnClick', function()
        Frame.nameEdit:SetText('')
        Frame.colorButton.color= nil
        Frame.colorButton:set_color()
        Frame.iconEdit:SetText('')
        Frame.xyEdit:SetText('')
        Frame.noteEdit:SetText('')
        Frame.professionMenu.profession= {}
        Frame.professionMenu:SetText(Frame.professionMenu:GetDefaultText())
        Frame.classMenu.class= {}
        Frame.classMenu:SetText(Frame.classMenu:GetDefaultText())
    end)


    Frame.mapMenu = CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    Frame.mapMenu:SetPoint('LEFT',Frame.newButton, 'RIGHT', 6, 0)
    Frame.mapMenu:SetPoint('RIGHT', -50, 0)
    Frame.mapMenu.Text:SetJustifyH('CENTER')
    Frame.mapMenu:SetDefaultText(DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '地区' or ZONE))
    Frame.mapMenu:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end
        for mapID, info in pairs(SaveWoW()) do
            root:CreateRadio(
                GetMapName(mapID) or mapID,
            function(data)
                return data.mapID==Frame.mapID
            end, function(data)
                Frame.mapID= data.mapID
                Refresh_All()
                return MenuResponse.Refresh
            end, {mapID= mapID, data= info})
        end
    end)


 --Cursor_cast_32

    local worldName= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    worldName:SetPoint('TOPLEFT', Frame.newButton, 'BOTTOMLEFT', 0, -20)
    worldName.tooltip= WoWTools_DataMixin.onlyChinese and '捕捉' or UNIT_CAPTURABLE
    worldName:SetNormalAtlas('Cursor_unablecast_32')
    function worldName:set_event()
        if self.isSatrt then
            self:RegisterEvent('GLOBAL_MOUSE_DOWN')
        else
            self:UnregisterEvent('GLOBAL_MOUSE_DOWN')
        end
    end
    function worldName:clear()
        self:SetScript('OnUpdate', nil)
        self.isSatrt= nil
        self.esp= nil
        self:set_event()
        self:SetNormalAtlas('Cursor_unablecast_32')
        ResetCursor()
    end
    function worldName:get()
        local text
        local data= C_TooltipInfo.GetWorldCursor() or {}
        if data.lines and data.lines[1] and data.lines[1].leftText then
            text= data.lines[1].leftText
        elseif _G['GameTooltipTextLeft1'] and _G['GameTooltipTextLeft1']:IsVisible() then
            text=_G['GameTooltipTextLeft1']:GetText()
        end
        if text~='' then
            return text
        end
    end
    worldName:SetScript("OnHide", worldName.clear)
    worldName:SetScript('OnEvent', function(self, _, d)
        if d=='RightButton' then
            self:clear()
        elseif d=='LeftButton' then
            local text= self:get()
            if text then
                Frame.nameEdit:SetText(text)
                self:clear()
            end
        end
    end)
    worldName:SetScript('OnClick', function(self)
        if self.isSatrt then
            self:clear()
            return
        end
        self.isSatrt= true
        self:set_event()
        self.esp= 3
        self:SetScript('OnUpdate', function(_, esp)
            self.esp= self.esp+ esp
            if self.esp>0.3 then
                self.esp= 0
                SetCursor('Interface\\CURSOR\\Crosshairs.blp')
                self:SetNormalAtlas(self:get() and 'Cursor_cast_32' or 'Cursor_unablecast_32')
                return
            end
        end)
    end)

    Frame.nameEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 1)
    Frame.nameEdit:SetPoint('LEFT', worldName, 'RIGHT', 6, 0)
    --Frame.nameEdit:SetPoint('TOPLEFT', Frame.ScrollBox, 'TOPRIGHT', 40, -20)
    Frame.nameEdit:SetPoint('RIGHT', Frame.mapMenu, 'BOTTOM')
    Frame.nameEdit:SetHeight(23)
    Frame.nameEdit.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '名称' or NAME)
    Frame.nameEdit.searchIcon:SetAtlas('Gear')
    function Frame.nameEdit:get_name()
        local name= self:GetText()
        self.name= name:gsub(' ', '')~='' and name or nil
    end
    Frame.nameEdit:SetScript('OnTextChanged', function(self)
        self:get_name()
        self.Instructions:SetShown(not self.name)
        self.searchIcon:SetShown(self.name)
        Set_UpdataAddButton_Stat()
    end)

 --颜色
    Frame.colorButton= CreateFrame('DropdownButton', nil, Frame, 'WoWToolsMenu3Template ColorSwatchTemplate')--ColorSwatchMixin
    Frame.colorButton:SetPoint('LEFT', Frame.nameEdit, 'RIGHT', 2, 0)
    Frame.colorButton.valueColor= CreateColor(1.0, 0.9294, 0.7607)
    --Frame.colorButton:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    Frame.colorButton:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end
        root:CreateRadio(
            WoWTools_DataMixin.onlyChinese and '无' or NONE,
        function()
            return tCompare(self.valueColor, self.color)
        end, function()
            self.color= self.valueColor
            self:set_color()
            return MenuResponse.Refresh
        end)
        root:CreateDivider()
        local code = WoWTools_ColorMixin:GetCODE()
        table.sort(code)
        local index=0
        for _, name in pairs(code) do
            local color= _G[name]
            if color and color.GetRGB then
                index= index+1
                local sub=root:CreateRadio(
                    color:WrapTextInColorCode(name),
                function(data)
                    return tCompare(_G[data.name], self.color)
                end, function(data)
                    self.color= _G[data.name]
                    self:set_color()
                    return MenuResponse.Refresh
                end, {name=name, rightText=index})
                WoWTools_MenuMixin:SetRightText(sub)
            end
        end
        WoWTools_MenuMixin:SetScrollMode(root)
    end)
    Frame.colorButton:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            self:CloseMenu()
            local color= self.color or self.valueColor
            local r,g,b= color:GetRGB()

            WoWTools_ColorMixin:ShowColorFrame(r,g,b, nil, function()--swatchFunc
                r,g,b = WoWTools_ColorMixin:Get_ColorFrameRGBA()
                self.color= CreateColor(r or 1, g or 1, b or 1)
                self:set_color()
            end, function()--cancelFunc
                self.color= color
                self:set_color()
            end)
        end
    end)
    function Frame.colorButton:set_color()
        self.color= self.color or self.valueColor
        Frame.nameEdit:SetTextColor(self.color:GetRGB())
        self:SetColorRGB(self.color:GetRGB())
    end
    Frame.colorButton:set_color()





    Frame.iconEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 3)
    Frame.iconEdit:SetPoint('LEFT', Frame.colorButton, 'RIGHT', 17, 0)
    Frame.iconEdit:SetPoint('RIGHT', -57, 0)
    Frame.iconEdit:SetHeight(23)
    Frame.iconEdit.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '图标' or SELF_HIGHLIGHT_MODE_ICON)
    Frame.iconEdit.searchIcon:SetTexture(0)
    Frame.iconEdit:HookScript('OnTextChanged', function(self)
        local icon= self:GetText()
        icon= icon:gsub(' ', '')
        if icon=='' then
            self.icon= nil
            self.iconButton.icon:SetTexture(WoWTools_DataMixin.Icon.icon)
        else
            local num= tonumber(icon)
            if num and format('%d', num)==icon then
                icon= num
            end
            if C_Texture.GetAtlasID(icon)>0 then
                self.iconButton.icon:SetAtlas(icon)--:SetNormalAtlas(icon)
            else
                self.iconButton.icon:SetTexture(icon or 0)--:SetNormalTexture(icon or WoWTools_DataMixin.Icon.icon)
            end
            self.icon= icon
        end
        Set_UpdataAddButton_Stat()
    end)



    Frame.iconEdit.iconButton= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    Frame.iconEdit.iconButton:SetPoint('LEFT', Frame.iconEdit, 'RIGHT', 2, 0)
    Frame.iconEdit.iconButton.icon= Frame.iconEdit.iconButton:CreateTexture(nil, 'BACKGROUND')
    Frame.iconEdit.iconButton.icon:SetAllPoints()
    --WoWTools_ButtonMixin:AddMask(Frame.iconEdit.iconButton, false, Frame.iconEdit.iconButton.icon)
    Frame.iconEdit.iconButton.owner= 'ANCHOR_RIGHT'
    function Frame.iconEdit.iconButton:tooltip()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '选择图标' or COMMUNITIES_CREATE_DIALOG_AVATAR_PICKER_INSTRUCTIONS)
        if not _G['TAV_CoreFrame'] then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('|cnWARNING_FONT_COLOR:Texture Atlas Viewer', WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)
        end
    end
    Frame.iconEdit.iconButton:SetScript('OnClick', function()
        WoWTools_TextureMixin:GetNewIcon(Frame, {
            texture= Frame.iconEdit:GetText(),
            SetValue=function(newIcon)
                Frame.iconEdit:SetText(newIcon)
                --Frame.nameEdit:SetText(newText)
            end
        })
    end)


    if _G['TAV_CoreFrame'] then--查找，图标，按钮， Texture Atlas Viewer， 插件
        local tav= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')-- WoWTools_ButtonMixin:Cbtn(Frame, {size=22, atlas='communities-icon-searchmagnifyingglass'})
        tav:SetNormalAtlas("communities-icon-searchmagnifyingglass")
        tav:SetPoint('LEFT', Frame.iconEdit.iconButton, 'RIGHT')
        tav:SetScript('OnClick', function()
            local frame= _G['TAV_CoreFrame']
            frame:SetShown(not frame:IsShown())
            if frame:IsShown() and frame.LeftInset and frame.LeftInset.SearchBox and frame.LeftInset.SearchBox:GetText()=='' then
                frame.LeftInset.SearchBox:SetText('objec')
            end
        end)
        tav.owner= 'ANCHOR_RIGHT'
        tav.tooltip= 'Texture Atlas Viewer'
    end




    local playerPoint= CreateFrame('Button', nil, Frame, 'WoWToolsButton2Template')
    playerPoint:SetPoint('TOPLEFT', worldName, 'BOTTOMLEFT', 0, -4)
    --playerPoint:SetPoint('LEFT',  Frame.xyEdit, 'RIGHT',2, 0)
    playerPoint:SetNormalTexture(0)
    SetPortraitTexture(playerPoint:GetNormalTexture(), 'player')
    function playerPoint:tooltip(tooltip)
        local x,y= WoWTools_WorldMapMixin:GetPlayerXY()
        if x and y then
            tooltip:AddLine(x..' '..y)
        else
            GameTooltip_AddErrorLine(tooltip,
                WoWTools_DataMixin.onlyChinese and '无效的地图' or ERR_HOUSING_RESULT_INVALID_MAP
            )
        end
    end
    playerPoint:SetScript('OnClick', function()
        local x,y= WoWTools_WorldMapMixin:GetPlayerXY()
        local xy= WoWTools_WorldMapMixin:GetTextForXY(x, y)
        if xy then
            Frame.xyEdit:SetText(xy)
        end
    end)


    Frame.xyEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 2)
    Frame.xyEdit:SetPoint('LEFT', playerPoint, 'RIGHT', 6, 0)
    --Frame.xyEdit:SetPoint('TOPLEFT',  Frame.nameEdit, 'BOTTOMLEFT', 0, -4)
    Frame.xyEdit:SetPoint('RIGHT', -54, 0)
    Frame.xyEdit:SetHeight(23)
    Frame.xyEdit.Instructions:SetText('xy 12.34 12.34')
    Frame.xyEdit.searchIcon:SetAtlas('UI-WorldMapArrow')

    Frame.xyEdit:HookScript('OnTextChanged', function(self)
        local x, y= WoWTools_WorldMapMixin:GetXYForText(self:GetText())
        if not x then
            self:SetTextColor(WARNING_FONT_COLOR:GetRGB())
        else
            self:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
        end
        Frame.sliderX:SetValue(x or 0)
        Frame.sliderY:SetValue(y or 0)
        self.xy= WoWTools_WorldMapMixin:GetTextForXY(x, y)
        Set_UpdataAddButton_Stat()
    end)

    function Frame.xyEdit:get_xyForslider()
        local x=  tonumber(format('%.2f', Frame.sliderX:GetValue()))
        local y= tonumber(format('%.2f', Frame.sliderY:GetValue()))
        self:SetText(WoWTools_WorldMapMixin:GetTextForXY(x, y))
    end







    local worldPoint= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    worldPoint:SetPoint('LEFT', Frame.xyEdit, 'RIGHT', 2, 0)
    worldPoint.tooltip= WoWTools_DataMixin.onlyChinese and '捕捉' or UNIT_CAPTURABLE
    worldPoint.owner= 'ANCHOR_RIGHT'
    worldPoint:SetNormalAtlas('Cursor_unablecast_32')
    function worldPoint:settings()
        self:SetNormalAtlas(self.isSatrt and 'cursor_crosshairs_32' or 'Cursor_unablecast_32')
        if self.isSatrt then
            self:RegisterEvent('GLOBAL_MOUSE_DOWN')
        else
            self:UnregisterEvent('GLOBAL_MOUSE_DOWN')
        end
    end
    function worldPoint:clear()
        self:SetScript('OnUpdate', nil)
        self.isSatrt= nil
        self.esp= nil
        self:SetNormalAtlas('Cursor_unablecast_32')
        self:settings()
        ResetCursor()
    end
    function worldPoint:get()
        local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()--当前世界地图位置
        if x and y then
            return x, y
        end
    end
    worldPoint:SetScript("OnHide", worldPoint.clear)
    worldPoint:SetScript('OnEvent', function(self, _, d)
        if d=='RightButton' then
            self:clear()
        elseif d=='LeftButton' then
            if not _G['WoWToolsWorldMapMenuButton']:IsVisible() then
                self:clear()
            else
                local x, y = self:get()
                if x and y then
                    Frame.xyEdit:SetText(format('%.2f %.2f', x*100, y*100))
                    self:clear()
                end
            end
        end
    end)

    worldPoint:SetScript('OnClick', function(self)
        if self.isSatrt then
            self:clear()
            return
        end
        if not _G['WoWToolsWorldMapMenuButton']:IsVisible() then
            ToggleWorldMap()
        end
        self.isSatrt= true
        self:settings()
        self.esp= 3
        self:SetScript('OnUpdate', function(_, esp)
            self.esp= self.esp+ esp
            if self.esp>0.3 then
                self.esp= 0
                SetCursor('Interface\\CURSOR\\Crosshairs.blp')
                self:SetNormalAtlas(self:get() and 'Cursor_cast_32' or 'Cursor_unablecast_32')
                return
            end
        end)
    end)





    Frame.sliderX= CreateFrame("Slider", nil, Frame, 'MinimalSliderTemplate')
    Frame.sliderX:SetMinMaxValues(0, 100)
    Frame.sliderX:SetScript('OnValueChanged', function(self)
        if self:IsMouseOver() then
            Frame.xyEdit:get_xyForslider()
        end
    end)
    Frame.sliderX:SetPoint('TOPLEFT', Frame.xyEdit, 'BOTTOMLEFT',6, -3)
    Frame.sliderX:SetPoint('TOPRIGHT', Frame.xyEdit, 'BOTTOM', -6, -3)
    WoWTools_TextureMixin:SetSlider(Frame.sliderX)

    Frame.sliderY= CreateFrame("Slider", nil, Frame, 'MinimalSliderTemplate')
    Frame.sliderY:SetMinMaxValues(0, 100)
    Frame.sliderY:SetScript('OnValueChanged', function(self)
        if self:IsMouseOver() then
            Frame.xyEdit:get_xyForslider()
        end
    end)
    Frame.sliderY:SetPoint('LEFT', Frame.sliderX, 'RIGHT', 6, 0)
    Frame.sliderY:SetPoint('TOPRIGHT', Frame.xyEdit, 'BOTTOMRIGHT', -6, -3)
    WoWTools_TextureMixin:SetSlider(Frame.sliderY)



    Frame.noteEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 4)
    Frame.noteEdit:SetPoint('TOPLEFT',  Frame.xyEdit, 'BOTTOMLEFT', -25, -55)
    Frame.noteEdit:SetPoint('RIGHT', -13, 0)
    Frame.noteEdit:SetHeight(23)
    Frame.noteEdit.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '备注' or LABEL_NOTE)
    Frame.noteEdit.searchIcon:SetTexture(0)


    Frame.professionMenu= CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    Frame.professionMenu:SetPoint('TOPLEFT', Frame.noteEdit, 'BOTTOMLEFT', -6, -12)
    Frame.professionMenu:SetPoint('TOPRIGHT', Frame.noteEdit, 'BOTTOM', -6, -20)
    Frame.professionMenu:SetDefaultText(DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '仅限专业' or format(LFG_LIST_CROSS_FACTION, PROFESSIONS_BUTTON)))
    Frame.professionMenu.Text:SetJustifyH('CENTER')
    Frame.professionMenu.profession={}

    Frame.professionMenu:SetSelectionText(function()
       return GetProfessionIcon(Frame.professionMenu.profession) or Frame.professionMenu:GetDefaultText()
    end)
    Frame.professionMenu:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end
        root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '无' or NONE,
        function()
            self.profession={}
            return MenuResponse.Refresh
        end)
        root:CreateDivider()
        for _, i in pairs(Enum.Profession) do --WORLD_QUEST_ICONS_BY_PROFESSION 
            local skillLineID= C_TradeSkillUI.GetProfessionSkillLineID(i)
            local name, professionName, textureID= GetProfessionName(skillLineID)
            if name then
                local sub=root:CreateCheckbox(
                    name,
                function(data)
                    return self.profession[data.rightText] and true or false
                end, function(data)
                    self.profession[data.rightText]= not self.profession[data.rightText] and true or nil
                    if self.profession[data.rightText] then
                        if not Frame.iconEdit.icon and data.textureID then
                            Frame.iconEdit:SetText(data.textureID)
                        end
                        if not Frame.nameEdit.name and data.professionName then
                            Frame.nameEdit:SetText(data.professionName)
                        end
                    end
                end, {rightText=skillLineID, professionName=professionName, textureID=textureID})
                WoWTools_MenuMixin:SetRightText(sub)
            end
        end
    end)

    Frame.classMenu= CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    Frame.classMenu:SetPoint('LEFT', Frame.professionMenu, 'RIGHT', 6, 0)
    Frame.classMenu:SetPoint('RIGHT', -13, 0)
    Frame.classMenu:SetDefaultText(DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '仅限职业' or format(LFG_LIST_CROSS_FACTION, CLASS)))
    Frame.classMenu.Text:SetJustifyH('CENTER')
    Frame.classMenu.class={}
    Frame.classMenu:SetSelectionText(function()
       return GetClassIcon(Frame.classMenu.class) or Frame.classMenu:GetDefaultText()
    end)
    Frame.classMenu:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end
        root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '无' or NONE,
        function()
            self.class={}
            return MenuResponse.Refresh
        end)
        root:CreateDivider()
        for classID=1, GetNumClasses() do
            local name= GetClassName(classID)
            if name then
                local sub=root:CreateCheckbox(
                    name,
                function(data)
                    return self.class[data.rightText] and true or false
                end, function(data)
                    self.class[data.rightText]= not self.class[data.rightText] and true or nil
                end, {rightText=classID})
                WoWTools_MenuMixin:SetRightText(sub)
            end
        end
    end)

    Frame.updateButton= CreateFrame('Button', nil, Frame, 'UIPanelButtonTemplate')
    Frame.updateButton:SetPoint('TOPLEFT', Frame.professionMenu, 'BOTTOMLEFT', 3, -40)
    Frame.updateButton:SetPoint('TOPRIGHT', Frame.professionMenu, 'TOPRIGHT', -3, -40)
    Frame.updateButton:SetHeight(32)
    Frame.updateButton:SetText(WoWTools_DataMixin.onlyChinese and '更新' or UPDATE)
    Frame.updateButton:SetScript('OnClick', function()
        Add_Updata_Data(true)
    end)


    Frame.addButton= CreateFrame('Button', nil, Frame, 'UIPanelButtonTemplate')
    Frame.addButton:SetPoint('LEFT', Frame.updateButton, 'RIGHT', 6, 0)
    Frame.addButton:SetPoint('RIGHT', -19, 0)
    Frame.addButton:SetHeight(32)
    Frame.addButton:SetText(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
    Frame.addButton:SetScript('OnClick', function()
        Add_Updata_Data(false)
    end)











--设置，TAB键
    Frame.tabGroup= CreateTabGroup(Frame.nameEdit, Frame.xyEdit)--, Frame.iconEdit, Frame.noteEdit)
    Frame.nameEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)
    Frame.xyEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)
    --Frame.iconEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)
    --Frame.noteEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)





    --[[Frame:SetScript('OnHide', function(self)
        self.view:SetDataProvider(CreateDataProvider(), ScrollBoxConstants.RetainScrollPosition)
    end)]]




    Init=function()end
end










function WoWTools_WorldMapMixin:Init_PlayerPin_EditUI(data)
    if not Frame then
        Init()
    else
        Frame:SetShown(data and true or not Frame:IsShown())
    end
    if Frame:IsShown() then
        Refresh_All(data)
    end
end

function WoWTools_WorldMapMixin:PlayerPin_ScrollToXY(xy)
    if Frame and Frame:IsShown() then
        Frame.ScrollBox:ScrollToElementDataByPredicate(function(data)
            return data.xy==xy
        end)
    end
end