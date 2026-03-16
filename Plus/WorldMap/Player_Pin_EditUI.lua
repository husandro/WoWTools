local function Save()
    return WoWToolsSave['Plus_WorldMap'].PlayerPin
end
local function SaveWoW()
    return WoWToolsPlayerDate.PlayerMapPin
end

local Frame
local PinHeight= 42--默认大小













local function GetMapName(mapID)
    local mapInfo= mapID and C_Map.GetMapInfo(mapID)
    local count= 0
    local name
    if mapInfo then
        if SaveWoW()[mapID] then
            count= CountTable(SaveWoW()[mapID])-1
        end
        name= mapID
            ..' '..(WoWTools_TextMixin:CN(mapInfo.name) or '')
            ..' ('..(count==0 and DISABLED_FONT_COLOR:WrapTextInColorCode(count) or count)..')'
    end
    return name, count
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

local function GetProfessionIcon(profession)
    if profession then
        local text
        for skillLineID in pairs(profession) do
            local icon, name= WoWTools_ProfessionMixin:GetName(skillLineID)
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








local function Set_UpdataAddButton_Stat()
    local isUpdate, isAdd= false, false

    local mapID= Frame.mapID
    local name= Frame.nameEdit.name
    local icon= Frame.iconEdit.icon

    local xy= Frame.xyEdit.xy

    if mapID and (name or icon) and xy then
        local data= SaveWoW()[mapID] or {}

        isUpdate= data[Frame.selectXY] and true or false
        isAdd= not data[xy] and true or false
    end

    Frame.addButton:SetEnabled(isAdd)
    Frame.updateButton:SetEnabled(isUpdate)
end








local function Set_FrameSelect(data)
    Frame.selectXY= data.xy

    Frame.xyEdit:SetText(data.xy or '')
    Frame.iconEdit:SetText(data.pin.icon or '')
    Frame.nameEdit:SetText(data.pin.name or '')

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
end









local function Search_Text(findText, xy, pin)
    if not findText then
        return true

    elseif xy==findText then
        return true
    elseif pin.name and pin.name:find(findText) then

        return true
    elseif pin.note and pin.note:find(findText) then
        return true
    end
    if pin.profession then
        for skillLineID in pairs(pin.profession) do
            if format('%d', skillLineID)==findText then
                return true
            end
            local info= C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
            if info and info.professionName then
                 local name= WoWTools_TextMixin:CN(info.professionName)
                if name:find(findText) then
                    return true
                end
            end
        end
    end
    if pin.class then
        for classID in pairs(pin.class) do
            if format('%d', classID)==findText then
                return true
            end
            local info= C_CreatureInfo.GetClassInfo(classID)
            if info and info.className then
                local name= WoWTools_TextMixin:CN(info.className)
                if name:find(findText) then
                    return true
                end
            end
        end
    end
end








local function Refresh_All(pinData)
    local dataProvider = CreateDataProvider()

    pinData = pinData or {}

    local mapID= pinData.mapID or Frame.mapID or WoWTools_WorldMapMixin:GetMapID()
    Frame.mapID= mapID

--新建
    if pinData.isNew then
        if SaveWoW()[pinData.mapID] and SaveWoW()[pinData.mapID][pinData.xy] then
            Set_FrameSelect({
                xy= pinData.xy,
                pin= SaveWoW()[pinData.mapID][pinData.xy],
            })
        else
            Frame.newButton:Click()
            if pinData.xy then
                Frame.xyEdit:SetText(pinData.xy)
            end
        end
        if pinData.name then
            Frame.nameEdit:SetText(pinData.name)
        end
    end

    local findText
    if pinData.xy then
        Frame.search:SetText(pinData.xy)
    end
    findText= Frame.search:GetText()
    findText= findText:gsub(' ', '')~='' and findText or nil

    if SaveWoW()[mapID] then
        SaveWoW()[mapID].options= SaveWoW()[mapID].options or {}
        if SaveWoW()[mapID].options.iconS then
            Frame.iconS:SetValue(SaveWoW()[mapID].options.iconS)
        end
        if SaveWoW()[mapID].options.fontH then
            Frame.fontH:SetValue(SaveWoW()[mapID].options.fontH)
        end

        for xy, pin in pairs(SaveWoW()[mapID] or {}) do
            if xy~='options' and Search_Text(findText, xy, pin) then

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
            if a and a.x and b and b.x then
                if a.x==b.x then
                    return a.y< b.y
                else
                    return a.x< b.x
                end
            else
                return false
            end
        end)
    end
    Frame.view:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)

    Frame.mapMenu:SetText(GetMapName(Frame.mapID) or Frame.mapMenu:GetDefaultText())

    Frame.numLabel:SetText(dataProvider:GetSize())

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
        WoWTools_WorldMapMixin:PlayerPin_RefreshPins()
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
        self:SetButtonState('NORMAL')
        WoWTools_WorldMapMixin:PlayerPin_SetPinState(Frame.mapID)
    end)

    btn:SetScript('OnEnter', function(self)
        self.Delete:Show()
        WoWTools_WorldMapMixin:PlayerPin_SetPinState(Frame.mapID, self.data.xy)
    end)

    function btn:set_event()
        self:set_select()
        EventRegistry:RegisterCallback("WoWToolsPlayrPin.UpateSelect", self.set_select, self)
    end

    btn:SetScript('OnHide', function(self)
        EventRegistry:UnregisterCallback("WoWToolsPlayrPin.UpateSelect", self)
        self.data= nil
        self:SetButtonState('NORMAL')
    end)
    btn:SetScript('OnClick', function(self)
        Set_FrameSelect(self.data)
    end)

end











local function Initializer(self, data)
    if not self.Delete then
        Add_ListButton(self)
    end

    WoWTools_ButtonMixin:AddMask(self, true, self.Icon)

    self.data= data

--图标
    WoWTools_TextureMixin:SetTexture(self.Icon, data.pin.icon)
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
    local xy= Frame.xyEdit.xy

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

    SaveWoW()[mapID].options= {
        iconS= Frame.iconS.value or PinHeight,
        fontH= Frame.fontH.value or PinHeight
    }

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
    WoWTools_WorldMapMixin:PlayerPin_RefreshPins()
end































local function Init()
    Frame= WoWTools_FrameMixin:Create(nil, {
        name= 'WoWToolsPlayerPinEditUIFrame',
        size={580, 370},
        strata='HIGH',
        header= WoWTools_WorldMapMixin.addName2,
        notEsc=true,
        minW=330,
        minH=330
    })


--列表
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




    Frame.search= WoWTools_EditBoxMixin:Create(Frame, {isSearch=true})
    --Frame.search:SetPoint('LEFT', Frame.worldButton, 'RIGHT', 8, 0)
    Frame.search:SetPoint('BOTTOMLEFT', Frame.ScrollBox, 'TOPLEFT', 23, 2)
    Frame.search:SetPoint('BOTTOMRIGHT', Frame.ScrollBox, 'TOPRIGHT', -23, 2)
    Frame.search:SetScript('OnTextChanged', function(self, userInput)
        if userInput then
            Refresh_All()
        end
        local show=self:GetText()~=''
        self.clearButton:SetShown(show)
        self.Instructions:SetShown(not show)
    end)
    Frame.search.clearButton:SetScript('OnMouseUp', function(self)
        self:GetParent():SetText('')
        self:Hide()
        Refresh_All()
    end)


--数量
    Frame.numLabel= Frame:CreateFontString(nil, "BORDER", 'WoWToolsFonts')
    Frame.numLabel:SetPoint('RIGHT', Frame.search, 'LEFT', -4, 0)
    Frame.numLabel:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
    Frame.numLabel:SetJustifyH('RIGHT')







    Frame.newButton= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    Frame.newButton:SetPoint('LEFT', Frame.search, 'RIGHT', 2, 0)
    Frame.newButton:SetNormalAtlas('communities-chat-icon-plus')
    Frame.newButton.owner= 'ANCHOR_RIGHT'
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
        --WoWTools_WorldMapMixin:ShowWorldFrame(Frame.mapID)
    end)





    Frame.mapMenu = CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    --Frame.mapMenu:SetPoint('LEFT',Frame.newButton, 'RIGHT', 6, 0)
    Frame.mapMenu:SetPoint('BOTTOMLEFT', Frame.ScrollBox, 'TOPRIGHT', 52, -2)
    Frame.mapMenu:SetPoint('RIGHT', -50, 0)
    Frame.mapMenu.Text:SetJustifyH('CENTER')
    Frame.mapMenu:SetDefaultText(DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '地区' or ZONE))
    Frame.mapMenu:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end

        local sub
        local allCount= 0


        local mapTab= {}
        for mapID, info in pairs(SaveWoW()) do
            table.insert(mapTab, {
                info= info,
                mapID= mapID,
            })
        end
        table.sort(mapTab, function(a,b)
            if a and b then
                return a.mapID> b.mapID
            else
               return false
            end
        end)

        --for mapID, info in pairs(SaveWoW()) do
        for index, newTab in pairs(mapTab) do
            local mapID= newTab.mapID
            local info= newTab.info

            local name, num= GetMapName(mapID)
            name= name or (DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '无效的地图' or ERR_HOUSING_RESULT_INVALID_MAP)..' '..mapID)
            allCount= num+ allCount

            local size= info.options or {}


            sub=root:CreateRadio(
                name,
            function(data)
                return data.mapID==Frame.mapID
            end, function(data)
                Frame.mapID= data.mapID
                WoWTools_WorldMapMixin:ShowWorldFrame(Frame.mapID)
                Refresh_All()
                return MenuResponse.Refresh
            end, {mapID= mapID, data=info,
                rightText=((size.iconS or PinHeight)..' '..(size.fontH or PinHeight))..' '.. DISABLED_FONT_COLOR:WrapTextInColorCode(index)})
            WoWTools_MenuMixin:SetRightText(sub)

            sub:CreateButton(
                WoWTools_DataMixin.onlyChinese and '删除' or DELETE,
            function(data)
                StaticPopup_Show('WoWTools_OK',
                    data.name..'|n|n'
                    ..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE)..' #'..data.num
                    ..'|n',
                nil,
                {SetValue=function()
                    SaveWoW()[data.mapID]= nil
                    WoWTools_WorldMapMixin:PlayerPin_RefreshPins()
                    Refresh_All()
                end})
                return MenuResponse.Open
            end, {num=num, name=name, mapID=mapID})
        end
        root:CreateDivider()


        local name='#'..#mapTab..' '..(WoWTools_DataMixin.onlyChinese and '全部删除' or CLEAR_ALL)..' ('..allCount..')'
        sub= root:CreateButton(
            name,
        function()
            StaticPopup_Show('WoWTools_OK',
                name,
            nil,
            {SetValue=function()
                WoWToolsPlayerDate.PlayerMapPin= {}
                WoWTools_WorldMapMixin:PlayerPin_RefreshPins()
                Refresh_All()
            end})
            return MenuResponse.Open
        end)

        WoWTools_MenuMixin:SetScrollMode(root)
    end)





    local worldButton= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    worldButton:SetPoint('RIGHT', Frame.mapMenu, 'LEFT', -2, 0)
    worldButton:SetNormalAtlas('poi-islands-table')
    function worldButton:tooltip(tooltip)
        local mapID= WoWTools_WorldMapMixin:GetMapID()
        tooltip:AddDoubleLine(
            (WorldMapFrame:IsShown() and WorldMapFrame.mapID==Frame.mapID and '|cff626262' or '')
            ..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS),
            (GetMapName(mapID))
        )
        local canvas= WorldMapFrame:GetCanvas()
        if WorldMapFrame.mapID and canvas then
            local w, h= canvas:GetSize()
            tooltip:AddDoubleLine(
                'Canvas '..(mapID~=Frame.mapID and mapID or ''),
                '|cffffffff'..math.modf(w)..'|r x |cffffffff'..math.modf(h)
            )
        end
    end
    worldButton:SetScript('OnClick', function(self)
        local mapID= WoWTools_WorldMapMixin:GetMapID()
        if mapID then
            Frame.mapID= mapID
            Refresh_All()
            WoWTools_WorldMapMixin:ShowWorldFrame(Frame.mapID)
        end
        WoWToolsButton_OnEnter(self)
    end)


    local goMapButton=  CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    goMapButton:SetPoint('LEFT', Frame.mapMenu, 'RIGHT', 2, 0)
    goMapButton:SetNormalAtlas('wowlabs-spectatecycling-arrowleft_hover')
    goMapButton.owner= 'ANCHOR_RIGHT'
    function goMapButton:tooltip(tooltip)
        tooltip:AddDoubleLine(
            GetMapName(Frame.mapID),
            (WorldMapFrame:IsShown() and WorldMapFrame.mapID==Frame.mapID and '|cff626262' or '')
            ..(WoWTools_DataMixin.onlyChinese and '返回' or HOUSEFINDER_BACK_BUTTON)
        )
    end
    goMapButton:SetScript('OnClick', function()
        WoWTools_WorldMapMixin:ShowWorldFrame(Frame.mapID)
    end)














--图标 大小
    Frame.iconS= CreateFrame("Slider", nil, Frame, 'MinimalSliderTemplate')
    Frame.iconS:SetPoint('TOPLEFT', Frame.mapMenu, 'BOTTOMLEFT', 0, -2)
    Frame.iconS:SetPoint('TOPRIGHT', Frame.mapMenu, 'BOTTOM', -6, -2)
    Frame.iconS:SetMinMaxValues(2, 200)
    Frame.iconS:EnableMouseWheel(true)
    Frame.iconS:SetValueStep(1)
    Frame.iconS.leftLabel= Frame.iconS:CreateFontString(nil, "ARTWORK", 'WoWToolsFont2')
    Frame.iconS.leftLabel:SetPoint('LEFT')
    Frame.iconS.rightLabel= Frame.iconS:CreateFontString(nil, "ARTWORK", 'WoWToolsFont2')
    Frame.iconS.rightLabel:SetPoint('RIGHT')
    Frame.iconS.rightLabel:SetText(WoWTools_DataMixin.onlyChinese and '图标' or SELF_HIGHLIGHT_ICON)
    Frame.iconS.Save_Value= function(self)
        if Frame.mapID and self.value then
            SaveWoW()[Frame.mapID]= SaveWoW()[Frame.mapID] or {}
            SaveWoW()[Frame.mapID].options= SaveWoW()[Frame.mapID].options or {}
            SaveWoW()[Frame.mapID].options[self.type]= self.value
            WoWTools_WorldMapMixin:PlayerPin_RefreshPins()
        end
    end
    Frame.iconS.On_MouseWheel= function(self, d)
        local value= self:GetValue()
        value= d==1 and value-1 or (value+1)
        self:SetValue(value)
    end
    Frame.iconS.On_ValueChanged= function(self)
        local value= self:GetValue() or PinHeight
        value= math.modf(value)
        self.value= value
        self.leftLabel:SetText(self.value)
        self.value= value
        if self:IsMouseOver() then
           Frame.iconS.Save_Value(self)
        end
    end
    Frame.iconS.type='iconS'
    Frame.iconS:SetScript('OnMouseWheel', Frame.iconS.On_MouseWheel)
    Frame.iconS:SetScript('OnValueChanged', Frame.iconS.On_ValueChanged)
    Frame.iconS:SetValue(PinHeight)
    WoWTools_TextureMixin:SetSlider(Frame.iconS)

--名称 大小
    Frame.fontH= CreateFrame("Slider", nil, Frame, 'MinimalSliderTemplate')
    Frame.fontH:SetPoint('LEFT', Frame.iconS, 'RIGHT', 6, 0)
    Frame.fontH:SetPoint('TOPRIGHT', Frame.mapMenu, 'BOTTOMRIGHT', 0, -2)
    Frame.fontH:SetMinMaxValues(Frame.iconS:GetMinMaxValues())
    Frame.fontH:EnableMouseWheel(true)
    Frame.fontH:SetValueStep(Frame.iconS:GetValueStep())
    Frame.fontH.leftLabel= Frame.fontH:CreateFontString(nil, "ARTWORK", 'WoWToolsFont2')
    Frame.fontH.leftLabel:SetPoint('LEFT')
    Frame.fontH.rightLabel= Frame.fontH:CreateFontString(nil, "ARTWORK", 'WoWToolsFont2')
    Frame.fontH.rightLabel:SetPoint('RIGHT')
    Frame.fontH.rightLabel:SetText(WoWTools_DataMixin.onlyChinese and '字体' or FONT_SIZE)
    Frame.fontH.type='fontH'
    Frame.fontH:SetScript('OnMouseWheel', Frame.iconS.On_MouseWheel)
    Frame.fontH:SetScript('OnValueChanged', Frame.iconS.On_ValueChanged)
    Frame.fontH:SetValue(PinHeight)
    WoWTools_TextureMixin:SetSlider(Frame.fontH)


--同时设置，图标和名称 大小
    local fontIconMenu= CreateFrame('DropdownButton', nil, Frame, 'WoWToolsMenu3Template')
    fontIconMenu:SetPoint('LEFT', Frame.fontH, 'RIGHT', 3, 0)
    fontIconMenu:SetNormalAtlas('Professions-Crafting-Orders-Icon')
    fontIconMenu:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end
        for i= 18, 72, 2 do
            root:CreateButton(
                i,
            function(data)
                local value= data
                Frame.iconS:SetValue(value)
                Frame.iconS.Save_Value(Frame.iconS)
                Frame.fontH:SetValue(value)
                Frame.iconS.Save_Value(Frame.fontH)
                return MenuResponse.Open
            end, i)
        end
        WoWTools_MenuMixin:SetScrollMode(root)
    end)














--捕捉，名称
    Frame.getNameButton= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    Frame.getNameButton:SetPoint('TOPLEFT', worldButton, 'BOTTOMLEFT', 0, -52)
    Frame.getNameButton.tooltip= WoWTools_DataMixin.onlyChinese and '捕捉名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNIT_CAPTURABLE, NAME)
    Frame.getNameButton:SetNormalAtlas('Cursor_unablecast_32')
    function Frame.getNameButton:set_event()
        if self.isSatrt then
            self:RegisterEvent('GLOBAL_MOUSE_DOWN')
        else
            self:UnregisterEvent('GLOBAL_MOUSE_DOWN')
        end
    end
    function Frame.getNameButton:clear()
        self:SetScript('OnUpdate', nil)
        self.isSatrt= nil
        self.esp= nil
        self:set_event()
        self:SetNormalAtlas('Cursor_unablecast_32')
        Frame.Header:Setup(WoWTools_WorldMapMixin.addName2)
        ResetCursor()
    end
    function Frame.getNameButton:get_name()
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
    Frame.getNameButton:SetScript("OnHide", Frame.getNameButton.clear)
    Frame.getNameButton:SetScript('OnEvent', function(self, _, d)
        if d=='RightButton' then
            self:clear()
        elseif d=='LeftButton' then
            local text= self:get_name()
            if text then
                Frame.nameEdit:SetText(text)
                self:clear()
            end
        end
    end)
    Frame.getNameButton:SetScript('OnClick', function(self)
        if self.isSatrt then
            self:clear()
            return
        end
        self.isSatrt= true
        self:set_event()
        if WorldMapFrame:IsShown() then
            ToggleWorldMap()
        end
        self.esp= 3
        self:SetScript('OnUpdate', function(_, esp)
            self.esp= self.esp+ esp
            if self.esp>0.1 then
                self.esp= 0
                SetCursor('Interface\\CURSOR\\Crosshairs.blp')
                local text= self:get_name()
                self:SetNormalAtlas(text and 'Cursor_cast_32' or 'Cursor_unablecast_32')
                Frame.Header:Setup(text and GREEN_FONT_COLOR:WrapTextInColorCode(text) or self.tooltip)
                return
            end
        end)
    end)




    Frame.nameEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 1)
    Frame.nameEdit:SetPoint('LEFT', Frame.getNameButton, 'RIGHT', 6, 0)
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
        icon= select(2, WoWTools_TextureMixin:SetTexture(self.iconButton.icon, icon))
        if not icon then
            self.iconButton.icon:SetTexture(WoWTools_DataMixin.Icon.icon)
        end
        self.iconButton.icon:SetAlpha(icon and 1 or 0.5)
        self.icon= icon
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

        --插件
        local tavFrame= _G['TAV_InfoPanel']
        if tavFrame and tavFrame.Name and tavFrame.Name.GetText then
            local btn= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')--  WoWTools_ButtonMixin:Cbtn(Frame, {atlas='Gear'})
            btn:SetNormalAtlas('Gear')
            btn:SetFrameStrata('HIGH')
            btn:SetPoint('RIGHT', tavFrame.Name, 'LEFT', -14, 0)
            btn:SetScript('OnClick', function()
                local text= _G['TAV_InfoPanel'].Name:GetText()
                if text and text~='' then
                    Frame.iconEdit:SetText(text)
                    _G['TAV_InfoPanel']:Hide()
                end
            end)
            btn.tooltip= WoWTools_WorldMapMixin.addName2..(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
        end
    end
















    Frame.getMapXYButton= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    Frame.getMapXYButton:SetPoint('TOPLEFT', Frame.getNameButton, 'BOTTOMLEFT', 0, -4)
    Frame.getMapXYButton.tooltip= WoWTools_DataMixin.onlyChinese and '捕捉XY' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNIT_CAPTURABLE, 'XY')
    Frame.getMapXYButton:SetNormalAtlas('Cursor_unablecast_32')
    function Frame.getMapXYButton:set_event()
        self:SetNormalAtlas(self.isSatrt and 'cursor_crosshairs_32' or 'Cursor_unablecast_32')
        if self.isSatrt then
            self:RegisterEvent('GLOBAL_MOUSE_DOWN')
        else
            self:UnregisterEvent('GLOBAL_MOUSE_DOWN')
        end
    end
    function Frame.getMapXYButton:clear()
        self:SetScript('OnUpdate', nil)
        self.isSatrt= nil
        self.esp= nil
        self:SetNormalAtlas('Cursor_unablecast_32')
        self:set_event()
        Frame.Header:Setup(WoWTools_WorldMapMixin.addName2)
        ResetCursor()
    end
    Frame.getMapXYButton:SetScript("OnHide", Frame.getMapXYButton.clear)
    Frame.getMapXYButton:SetScript('OnEvent', function(self, _, d)
        if d=='RightButton' then
            self:clear()
        elseif d=='LeftButton' then
            if not WorldMapFrame:IsShown() then
                self:clear()
            else
                local xy= WoWTools_WorldMapMixin:GetTextForXY(nil, nil, true, false)
                if xy then
                    Frame.xyEdit:SetText(xy)
                    self:clear()
                end
            end
        end
    end)
    Frame.getMapXYButton:SetScript('OnClick', function(self)
        if self.isSatrt then
            self:clear()
            return
        end
        WoWTools_WorldMapMixin:ShowWorldFrame(Frame.mapID)
        self.isSatrt= true
        self:set_event()
        self.esp= 3
        self:SetScript('OnUpdate', function(_, esp)
            self.esp= self.esp+ esp
            if self.esp>0.3 then
                self.esp= 0
                SetCursor('Interface\\CURSOR\\Crosshairs.blp')
                self:SetNormalAtlas(WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition() and 'Cursor_cast_32' or 'Cursor_unablecast_32')
                local xy= WoWTools_WorldMapMixin:GetTextForXY(nil, nil, true, false)
                Frame.Header:Setup(xy and GREEN_FONT_COLOR:WrapTextInColorCode(xy) or self.tooltip)
                return
            end
        end)
    end)



    Frame.xyEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 2)
    Frame.xyEdit:SetPoint('LEFT', Frame.getMapXYButton, 'RIGHT', 6, 0)
    --Frame.xyEdit:SetPoint('TOPLEFT',  Frame.nameEdit, 'BOTTOMLEFT', 0, -4)
    Frame.xyEdit:SetPoint('RIGHT', -54, 0)
    Frame.xyEdit:SetHeight(23)
    Frame.xyEdit.Instructions:SetText('xy 12.34 12.34')
    Frame.xyEdit.searchIcon:SetAtlas('UI-WorldMapArrow')

    Frame.xyEdit:HookScript('OnTextChanged', function(self)
        local text= self:GetText() or ''
        text= text:gsub('  ', '')
        text= text:gsub(' $', '')
        text= text:gsub('^ ', '')
        local x, y
        if text~='' and text~=' ' then
            x, y= text:match('(%d%d%.%d%d) (%d%d%.%d%d)')
            if x and y then
                self.xy= WoWTools_WorldMapMixin:GetTextForXY(x, y)
            else
                x, y= WoWTools_WorldMapMixin:GetXYForText(self:GetText())
                self.xy= WoWTools_WorldMapMixin:GetTextForXY(x, y)
            end
            x, y= tonumber(x), tonumber(y)
        end
        if not x or not y then
            self:SetTextColor(WARNING_FONT_COLOR:GetRGB())
        else
            self:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
        end
        Frame.sliderX:SetValue(x or 0)
        Frame.sliderY:SetValue(y or 0)
        Set_UpdataAddButton_Stat()
    end)

    function Frame.xyEdit:Get_TextForSiliderXY()
        return WoWTools_WorldMapMixin:GetTextForXY(
            format('%.2f', Frame.sliderX:GetValue()),
            format('%.2f', Frame.sliderY:GetValue())
        )
    end



    local playerXY= CreateFrame('Button', nil, Frame, 'WoWToolsButton2Template')
    playerXY:SetPoint('LEFT', Frame.xyEdit, 'RIGHT', 2, 0)
    playerXY:SetNormalTexture(0)
    playerXY.owner= 'ANCHOR_RIGHT'
    SetPortraitTexture(playerXY:GetNormalTexture(), 'player')
    function playerXY:tooltip(tooltip)
        local xy= WoWTools_WorldMapMixin:GetTextForXY(nil, nil, false, true)
        if xy then
            tooltip:AddLine(xy)
        else
            GameTooltip_AddErrorLine(tooltip,
                (WoWTools_DataMixin.onlyChinese and '无效的地图' or ERR_HOUSING_RESULT_INVALID_MAP)..' xy'
            )
        end
    end
    playerXY:SetScript('OnClick', function()
        Frame.xyEdit:SetText(WoWTools_WorldMapMixin:GetTextForXY(nil, nil, false, true) or '')
        WoWTools_WorldMapMixin:ShowWorldFrame(C_Map.GetBestMapForUnit("player"))
    end)
















--划条，X，如果OnMouseWheel 会自动更新
    Frame.sliderX= CreateFrame("Slider", nil, Frame, 'MinimalSliderTemplate')
    Frame.sliderX:SetPoint('TOPLEFT', Frame.xyEdit, 'BOTTOMLEFT',6, -3)
    Frame.sliderX:SetPoint('TOPRIGHT', Frame.xyEdit, 'BOTTOM', -6, -3)
    Frame.sliderX:SetMinMaxValues(0, 100)
    Frame.sliderX:EnableMouseWheel(true)
    Frame.sliderX:SetValueStep(0.05)
    Frame.sliderX:SetValue(0)
    Frame.sliderX.tooltip= function(self)
        if not WorldMapFrame:IsShown() or not Frame.updateButton:IsEnabled() then
            return
        end
        GameTooltip:SetOwner(self, self.anchor or "ANCHOR_LEFT")
        GameTooltip_SetTitle(GameTooltip,
            (Frame.updateButton:IsEnabled() and '' or DISABLED_FONT_COLOR:GenerateHexColorMarkup())
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_DataMixin.onlyChinese and '更新' or UPDATE),
            GREEN_FONT_COLOR
        )
        GameTooltip:Show()
    end
    Frame.sliderX.set_valuechanged= function(self)
        if self:IsMouseOver() then
            Frame.xyEdit:SetText(Frame.xyEdit:Get_TextForSiliderXY())
            if WorldMapFrame:IsShown() and Frame.updateButton:IsEnabled() then
                Frame.updateButton:Click()
            end

        end
    end
    Frame.sliderX.set_wheel= function(self, d)
        local value= self:GetValue()
        value= d==1 and value-0.05 or (value+0.05)
        self:SetValue(value)
        Frame.xyEdit:SetText(Frame.xyEdit:Get_TextForSiliderXY())
    end

    Frame.sliderX:SetScript('OnMouseWheel', Frame.sliderX.set_wheel)
    Frame.sliderX:SetScript('OnValueChanged', Frame.sliderX.set_valuechanged)
    Frame.sliderX:SetScript('OnLeave', GameTooltip_Hide)
    Frame.sliderX:SetScript('OnEnter', Frame.sliderX.tooltip)
    WoWTools_TextureMixin:SetSlider(Frame.sliderX)


    Frame.sliderY= CreateFrame("Slider", nil, Frame, 'MinimalSliderTemplate')
    Frame.sliderY:SetPoint('LEFT', Frame.sliderX, 'RIGHT', 6, 0)
    Frame.sliderY:SetPoint('TOPRIGHT', Frame.xyEdit, 'BOTTOMRIGHT', -6, -3)
    Frame.sliderY:SetMinMaxValues(Frame.sliderX:GetMinMaxValues())
    Frame.sliderY:EnableMouseWheel(true)
    Frame.sliderY:SetValueStep(Frame.sliderX:GetValueStep())
    Frame.sliderY:SetScript('OnMouseWheel', Frame.sliderX.set_wheel)
    Frame.sliderY:SetScript('OnValueChanged', Frame.sliderX.set_valuechanged)
    Frame.sliderY:SetScript('OnLeave', GameTooltip_Hide)
    Frame.sliderY:SetScript('OnEnter', Frame.sliderX.tooltip)
    Frame.sliderY:SetValue(0)
    Frame.sliderY.anchor= "ANCHOR_RIGHT"
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
            local icon, name, textureID, info= WoWTools_ProfessionMixin:GetName(skillLineID)
            if name then
                local color
                if C_SpellBook.GetSkillLineIndexByID(skillLineID) then
                    color= info.isPrimaryProfession and GREEN_FONT_COLOR or EPIC_PURPLE_COLOR
                else
                    color= info.isPrimaryProfession and HIGHLIGHT_FONT_COLOR or NORMAL_FONT_COLOR
                end
                local sub=root:CreateCheckbox(
                    (icon or '')
                    ..color:WrapTextInColorCode(name),
                function(data)
                    return self.profession[data.rightText] and true or false
                end, function(data)
                    self.profession[data.rightText]= not self.profession[data.rightText] and true or nil
                    if self.profession[data.rightText] then
                        if not Frame.iconEdit.icon and data.textureID then
                            Frame.iconEdit:SetText(data.textureID)
                        end
                        if not Frame.nameEdit.name and data.name then
                            Frame.nameEdit:SetText(data.name)
                        end
                    end
                end, {info=info, rightText=skillLineID, name=name, textureID=textureID})
                WoWTools_MenuMixin:SetRightText(sub)
                sub:SetTooltip(function(tooltip, desc)
                    if desc.data.info.expansionName~=UNKNOWN then
                        tooltip:AddLine(WoWTools_TextMixin:CN(desc.data.info.expansionName))
                    end
                end)
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
    Frame.updateButton:SetPoint('TOPLEFT', Frame.professionMenu, 'BOTTOMLEFT', 3, -12)
    Frame.updateButton:SetPoint('TOPRIGHT', Frame.professionMenu, 'TOPRIGHT', -3, -12)
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
  
    
















    --导入数据
    Frame.dataFrame=WoWTools_EditBoxMixin:CreateFrame(Frame,{
        name='WoWToolsPlayerPinEditUIOutInScrollFrame'
    })
    --Frame.dataFrame:Hide()
    Frame.dataFrame:SetPoint('TOPLEFT', Frame, 'TOPRIGHT', 0, -10)
    Frame.dataFrame:SetPoint('BOTTOMRIGHT', 310, 8)



    Frame.dataFrame.CloseButton= CreateFrame('Button', 'WoWToolsPlayerPinEditUIOutInScrollFrameCloseButton', Frame.dataFrame, 'UIPanelCloseButtonNoScripts')
    Frame.dataFrame.CloseButton:SetPoint('TOPRIGHT',0, 13)
    Frame.dataFrame.CloseButton:SetScript('OnClick', function(self)
        local frame=self:GetParent()
        frame:Hide()
        frame:SetText("")
    end)
    WoWTools_TextureMixin:SetButton(Frame.dataFrame.CloseButton)

    Frame.dataFrame.enter= WoWTools_ButtonMixin:Cbtn(Frame.dataFrame, {
        name= 'WoWToolsPlayerPinEditUIOutInScrollFrameEnterButton',
        size={100, 23},
        isUI=true
    })
    Frame.dataFrame.enter:SetPoint('BOTTOM', Frame.dataFrame, 'TOP', 0, 5)
    Frame.dataFrame.enter:SetFormattedText('|A:Professions_Specialization_arrowhead:0:0|a%s', WoWTools_DataMixin.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
   -- Frame.dataFrame.enter:Hide()


   

    function Frame.dataFrame.enter:set_date(isTip)--导入数据，和提示
        local lines = { 'WoWToolsWorldMapPlayerPin'}

        for mapID, data in pairs(SaveWoW()) do
            local line= format(
                '[%d]={options={iconS=%d,fontH=%d}',
                mapID,
                data.options.iconS or 0,
                data.options.fontH or 0
            )

            for optionOrXY, info in pairs(data) do
                line= optionOrXY..'|n'
                for name, set in pairs(info) do
                    
                end
            end
            line= line..'}|n'
        end

        return WoWTools_ZipMixin:base64Encode(table.concat(lines, "\n"))
    end

    
    Frame.dataFrame.enter:SetScript('OnClick', function(self)--导入
        Frame.dataFrame.enter:set_date()
        
    end)

    Frame.dataUscita= WoWTools_ButtonMixin:Cbtn(Frame, {size=22, atlas='bags-greenarrow'})
    Frame.dataUscita:SetPoint('TOPLEFT', 6, -6)
    Frame.dataUscita:SetScript('OnLeave', GameTooltip_Hide)
    Frame.dataUscita:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '导出' or SOCIAL_SHARE_TEXT or  HUD_EDIT_MODE_SHARE_LAYOUT)
        GameTooltip:Show()
    end)
    Frame.dataUscita:SetScript('OnClick', function(self)
        local text= WoWTools_ZipMixin:base64Encode(SaveWoW())
        Frame.dataFrame:SetText(text or '')
        Frame.dataFrame:SetInstructions(WoWTools_DataMixin.onlyChinese and '导出' or SOCIAL_SHARE_TEXT or  HUD_EDIT_MODE_SHARE_LAYOUT)
    end)

    Frame.dataEnter= WoWTools_ButtonMixin:Cbtn(Frame, {size=22, atlas='Professions_Specialization_arrowhead'})
    Frame.dataEnter:SetPoint('LEFT', Frame.dataUscita, 'RIGHT')
    Frame.dataEnter:SetScript('OnLeave', GameTooltip_Hide)
    Frame.dataEnter:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
        GameTooltip:Show()
    end)
    Frame.dataEnter:SetScript('OnClick', function()
        info= WoWTools_ZipMixin:base64Decode(Frame.dataFrame:GetText())
print(type(info), info)

        
    end)





















    function Frame:settings()
        self:SetFrameStrata(Save().UIStrata or 'HIGH')
    end
    Frame:settings()

    Init=function()

    end
end










function WoWTools_WorldMapMixin:PlayerPin_ShowUI(data)
    if not Frame then
        Init()
    else
        Frame:SetShown(data and true or not Frame:IsShown())
    end
    if Frame:IsShown() then
        Refresh_All(data)
    end

end

function WoWTools_WorldMapMixin:PlayerPin_SetUIButtonState(xy)
    if Frame and Frame:IsShown() and Frame.mapID==WorldMapFrame.mapID then
        if xy then
            Frame.ScrollBox:ScrollToElementDataByPredicate(function(elementData)
                return elementData.xy==xy
            end)
        end
        for _, btn in pairs(Frame.ScrollBox:GetFrames() or {}) do
            btn:SetButtonState(btn.data.xy==xy and 'PUSHED' or 'NORMAL')
        end
    end
end

function WoWTools_WorldMapMixin:PlayerPin_RefreshUI(data)
    if Frame then
        if Frame:IsShown() then
            Refresh_All(data)
        end
    end
end

function WoWTools_WorldMapMixin:PlayerPin_GetUIFrame()
    return Frame, 'WoWToolsPlayerPinEditUIFrame'
end