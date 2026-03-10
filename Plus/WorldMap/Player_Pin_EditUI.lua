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
        return (WoWTools_UnitMixin:GetClassIcon(nil, nil, classInfo.classFile) or '')--职业图标
            ..color:WrapTextInColorCode(WoWTools_TextMixin:CN(classInfo.className))
    end
end
local function GetProfessionName(skillLineID)
    local info= skillLineID and C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
    if info and info.professionName and info.professionName~='' then
        local textureID, icon= select(2, WoWTools_TextureMixin:IsAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[skillLineID]))
        return (C_SpellBook.GetSkillLineIndexByID(skillLineID) and '|cnGREEN_FONT_COLOR:' or '')
                    ..(icon or '')
                    .. WoWTools_TextMixin:CN(info.professionName),
                info.parentProfessionName,
                textureID
    end
end







local function Find_Pool(name)
    local btn= _G['WoWToolsWorldFramePlayerPinButton']
    if not btn or not WorldMapFrame:IsVisible() or WorldMapFrame.mapID~=Frame.mapID then
        return
    end
    for b in btn.pool:EnumerateActive() do

        b:SetButtonState(name and b.data and b.data.name==name and 'PUSHED' or 'NORMAL')
    end
end

local function Set_UpdataAddButton_Stat()
    local isUpdate, isAdd= false, false

    local mapID= Frame.mapID
    local name= Frame.nameEdit.name
    local icon= Frame.iconEdit.icon

    local xy= Frame.xyEdit.xy
    local xy2= Frame.data.xy

    if mapID and (name or icon) and xy then
        local data=SaveWoW()[mapID] or {}

        isUpdate= data[xy2]
        isAdd= not isUpdate
    end

    Frame.addButton:SetEnabled(isAdd)
    Frame.updateButton:SetEnabled(isUpdate)
end






local function Refresh_All(pinData)
    pinData = pinData or {}

    local mapID= pinData.mapID or Frame.mapID or WoWTools_WorldMapMixin:GetMapID()

    Frame.mapID= mapID

    local dataProvider = CreateDataProvider()

    local index= 0
    for xy, pin in pairs(SaveWoW()[mapID] or {}) do
        local x, y= WoWTools_WorldMapMixin:GetXYForText(xy)
        index= index +1
        dataProvider:Insert({
            x= x,
            y= y,
            xy= xy,
            index= index,
            pin= pin
        })

    end
    dataProvider:SetSortComparator(function(a, b)
        if a and b then
            if a.x==b.x then
                return a.y< b.y
            else
                return a.y< b.y
            end
        else
            return false
        end
    end)

    Frame.view:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)

    Frame.mapMenu:SetText(GetMapName(Frame.mapID) or Frame.mapMenu:GetDefaultText())
    Frame.classMenu:SetText(GetClassName(Frame.classID) or Frame.classMenu:GetDefaultText())
    Frame.professionMenu:UpdateText()

    Set_UpdataAddButton_Stat()
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
        local name= data.pin.name
        if name then

            SaveWoW()[mapID][data.xy]= nil
            print(
                WoWTools_DataMixin.Icon..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE),
                data.pin.name,
                data.pin.icon,
                data.xy,
                data.pin.note
            )
        end

        Refresh_All()
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
        self.Select:SetShown(Frame.data.xy== self.data.xy)
    end

    btn:SetScript('OnLeave', function(self)
        self.Delete:Hide()
        Find_Pool()
    end)

    btn:SetScript('OnEnter', function(self)
        self.Delete:Show()
        Find_Pool(self.data.pin.name)
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

        Frame.data= data

        Frame.nameEdit:SetText(data.pin.name or '')
        Frame.xyEdit:SetText(data.xy)
        Frame.iconEdit:SetText(data.pin.icon or '')
        Frame.noteEdit:SetText(data.pin.note or '')

        Frame.professionMenu:SetText(GetProfessionName(data.pin.skillLineID) or Frame.professionMenu:GetDefaultText())
        Frame.classMenu:SetText(GetClassName(data.pin.classID) or Frame.classMenu:GetDefaultText())

        local color= data.pin.color or {}
        Frame.colorButton.color= CreateColor(color.r or 1, color.g or 0.9294, color.b or 0.7607)
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

    self.Name:SetText(data.pin.name or '')
    local isAtlas, textureID= WoWTools_TextureMixin:IsAtlas(data.pin.icon)
    if isAtlas then
        self.Icon:SetAtlas(textureID)
    else
        self.Icon:SetTexture(textureID or 0)
    end
    self.Sub:SetText(data.xy)
    self.Sub2:SetText(data.pin.note or '')

    local color= data.color or CreateColor(1.0, 0.9294, 0.7607)
    self.Name:SetTextColor(color:GetRGB())

    self.Index:SetText(data.index)


    self:set_event()
end























local function Add_Updata_Data(isUpdate)
    local mapID= Frame.mapID

    local name= Frame.nameEdit:GetText()
    name= name:gsub(' ', '')~='' and name or nil

    local icon= Frame.iconEdit:GetText()
    icon= icon:gsub(' ', '')~='' and icon or nil

    local x, y= WoWTools_WorldMapMixin:GetXYForText(Frame.xyEdit:GetText())
    local xy= WoWTools_WorldMapMixin:GetTextForXY(x, y)

    if not mapID or not xy or not (name or icon) then
        return
    end

    local note= Frame.noteEdit:GetText()
    note= note:gsub(' ', '')~='' and note or nil

    local skillLineID= Frame.skillLineID
    local classID= Frame.classID

    local color
    if Frame.colorButton.color and Frame.colorButton.valueColor~=Frame.colorButton.color then
        local r,g,b= color:GetRGB()
        color= {r=r, g=g, b=b}
    end

    if isUpdate and SaveWoW()[mapID] and SaveWoW[mapID][Frame.data.xy] then
        SaveWoW[mapID][Frame.data.xy]= nil
    end

    SaveWoW()[mapID]= SaveWoW()[mapID] or {}
    SaveWoW()[mapID][xy]= {
        name= name,
        icon= icon,
        note= note,
        classID= classID,
        skillLineID= skillLineID,
        color= color,
    }

    Refresh_All()
end

























local function Init(tab)
    Frame= WoWTools_FrameMixin:Create(UIParent, {
        name= 'WoWToolsPlayerPinEditUIFrame',
        size={580, 370},
        strata='HIGH',
        header= WoWTools_WorldMapMixin.addName2,
    })
    Frame.data= {}

    --Frame:Hide()

    Frame.list = CreateFrame("Frame", nil, Frame, "WowScrollBoxList")
    Frame.list:SetPoint("TOPLEFT", 12, -55)
    Frame.list:SetPoint("BOTTOMRIGHT", Frame, 'BOTTOM', -80, 6)


    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPLEFT", Frame.list, "TOPRIGHT", 8,-20)
    Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame.list, "BOTTOMRIGHT",8,20)
    WoWTools_TextureMixin:SetScrollBar(Frame)

    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.list, Frame.ScrollBar, Frame.view)

    Frame.view:SetElementInitializer("WoWToolsPlayerPinButtonTemplate", Initializer)



    Frame.worldButton= CreateFrame('Button', nil, Frame, 'WoWToolsButtonTemplate')
    Frame.worldButton:SetPoint('BOTTOMLEFT', Frame.list, 'TOPLEFT', 0, 2)
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
            Refresh_All({mapID= mapID})
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
                Refresh_All({mapID=data.mapID})
                return MenuResponse.Refresh
            end, {mapID= mapID, data= info})
        end
    end)



    Frame.nameEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 1)
    Frame.nameEdit:SetPoint('TOPLEFT', Frame.list, 'TOPRIGHT', 40, -20)
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
    Frame.nameEdit:SetScript('OnHide', function(self)
        self.name= nil
    end)





    Frame.iconEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 3)
    Frame.iconEdit:SetPoint('LEFT', Frame.nameEdit, 'RIGHT', 6, 0)
    Frame.iconEdit:SetPoint('RIGHT', -2*23-6, 0)
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
            SetValue=function(newIcon, newText)
                Frame.iconEdit:SetText(newIcon)
                Frame.nameEdit:SetText(newText)
            end
        })
    end)




    Frame.xyEdit= CreateFrame('EditBox', nil, Frame, 'SearchBoxTemplate', 2)
    Frame.xyEdit:SetPoint('TOPLEFT',  Frame.nameEdit, 'BOTTOMLEFT', 0, -4)
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





 --颜色
    Frame.colorButton= CreateFrame('Button', nil, Frame, 'ColorSwatchTemplate')--ColorSwatchMixin
    Frame.colorButton:SetPoint('LEFT', Frame.xyEdit, 'RIGHT', 2, 0)
    Frame.colorButton.valueColor= CreateColor(1.0, 0.9294, 0.7607)
    --Frame.colorButton:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    Frame.colorButton:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            local color= self.color or self.valueColor
            local r,g,b= color:GetRGB()

            WoWTools_ColorMixin:ShowColorFrame(r,g,b, nil, function()--swatchFunc
                r,g,b = WoWTools_ColorMixin:Get_ColorFrameRGBA()
                self.color= CreateColor(r,g,b)
                self:set_color()
            end, function()--cancelFunc
                self.color= color
                self:set_color()
            end)
        else
            self.color= self.valueColor
            self:set_color()
        end
    end)
    function Frame.colorButton:set_color()
        local color= self.color or self.valueColor
        Frame.nameEdit:SetTextColor(color:GetRGB())
        self:SetColorRGB(color:GetRGB())
    end
    Frame.colorButton:set_color()







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
    Frame.noteEdit:SetPoint('TOPLEFT',  Frame.xyEdit, 'BOTTOMLEFT', 0, -44)
    Frame.noteEdit:SetPoint('RIGHT', -13, 0)
    Frame.noteEdit:SetHeight(23)
    Frame.noteEdit.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '备注' or LABEL_NOTE)
    Frame.noteEdit.searchIcon:SetTexture(0)


    Frame.professionMenu= CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    Frame.professionMenu:SetPoint('TOPLEFT', Frame.noteEdit, 'BOTTOMLEFT', -6, -12)
    Frame.professionMenu:SetPoint('TOPRIGHT', Frame.noteEdit, 'BOTTOM', -6, -20)
    Frame.professionMenu:SetDefaultText(DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '仅限专业' or format(LFG_LIST_CROSS_FACTION, PROFESSIONS_BUTTON)))
    Frame.professionMenu.Text:SetJustifyH('CENTER')
    Frame.professionMenu:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end
        for _, i in pairs(Enum.Profession) do --WORLD_QUEST_ICONS_BY_PROFESSION 

            local skillLineID= C_TradeSkillUI.GetProfessionSkillLineID(i)

            local name, professionName, textureID= GetProfessionName(skillLineID)
            if name then
                root:CreateCheckbox(
                    name,
                function(data)
                    return self.skillLineID ==data.skillLineID
                end, function(data)
                    if self.skillLineID==data.skillLineID then
                        self.skillLineID= nil
                    else
                        self.skillLineID= data.skillLineID
                        Frame.nameEdit:SetText(data.professionName)
                        if data.textureID then
                            Frame.iconEdit:SetText(data.textureID)
                        end
                    end
                end, {skillLineID=skillLineID, professionName=professionName, textureID=textureID})
            end
        end
    end)

    Frame.classMenu= CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    Frame.classMenu:SetPoint('LEFT', Frame.professionMenu, 'RIGHT', 6, 0)
    Frame.classMenu:SetPoint('RIGHT', -13, 0)
    Frame.classMenu:SetDefaultText(DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '仅限职业' or format(LFG_LIST_CROSS_FACTION, CLASS)))
    Frame.classMenu.Text:SetJustifyH('CENTER')
    Frame.classMenu:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end
        for classID= 1, GetNumClasses() do
            local name= GetClassName(classID)
            if name then
                root:CreateCheckbox(
                    name,
                function(data)
                    return self.classID==data.classID
                end, function(data)
                    if self.classID==data.classID then
                        self.classID= nil
                    else
                        self.classID= data.classID
                    end
                end, {classID=classID})
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
    Frame.updateButton:SetText(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
    Frame.addButton:SetScript('OnClick', function()
        Add_Updata_Data(false)
    end)











--设置，TAB键
    Frame.tabGroup= CreateTabGroup(Frame.nameEdit, Frame.xyEdit)--, Frame.iconEdit, Frame.noteEdit)
    Frame.nameEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)
    Frame.xyEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)
    --Frame.iconEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)
    --Frame.noteEdit:SetScript('OnTabPressed', function() Frame.tabGroup:OnTabPressed() end)





    Frame:SetScript('OnHide', function(self)
        self.view:SetDataProvider(CreateDataProvider(), ScrollBoxConstants.RetainScrollPosition)
    end)



    Refresh_All(tab)

    Init=function()end
end










function WoWTools_WorldMapMixin:Init_PlayerPin_EditUI(data)
    if Frame then
        Frame:SetShown(data and true or not Frame:IsShown())
        if Frame:IsShown() then
            Refresh_All(data)
        end
    else
        Init(data)
    end
end