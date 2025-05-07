local function Save()
    return  WoWToolsSave['Minimap_Plus']
end

local Button
local libDBIcon
local Objects={}

local function Set_Lib()
    if not libDBIcon then
        libDBIcon = LibStub("LibDBIcon-1.0", true)
    end
end



local function Get_Button(name)
    return Objects[name] or libDBIcon:GetMinimapButton(name)
end

local function Get_All_Objects()
    local objects={}
    for name, btn in pairs(libDBIcon.objects) do
        objects[name]= btn
    end
    for name, btn in pairs(Objects) do
        objects[name]= btn
    end
    return objects
end

















--锁定按钮
local function Lock_Button(btn, name)--lib:Lock(name)
    btn= btn or Get_Button(name)
    if not btn or btn.WoWToolsIsLocked then
        return
    end
    btn.WoWToolsIsLocked=true

    libDBIcon.objects[name]= nil

    btn:SetFixedFrameStrata(false)
    btn:SetParent(Button.frame)



--设置，材质
    --[[btn.icon:SetSize(26, 26)
    for _, region in pairs ({btn:GetRegions()}) do
        if region:GetObjectType()=='Texture' and region~=btn.icon then
            local text= region:GetTexture()
            if text==136430 then--OVERLAY 
                region:SetSize(62, 62)
                region:SetPoint("TOPLEFT", btn, "TOPLEFT", -4, 3)

            elseif text==136467 then--BACKGROUND
                region:SetSize(31, 31)
            end
        end
    end]]

    if not btn:GetScript('OnDragStart') then
        return
    end

    btn:SetScript("OnDragStart", nil)
    btn:SetScript("OnDragStop", nil)
end



--还原按钮
local function Unlock_Button(btn, name)
    btn= btn or Get_Button(name)
    if not btn or not btn.WoWToolsIsLocked then
        return
    end
    btn.WoWToolsIsLocked=nil
    local db= btn.db

    btn:ClearAllPoints()
    btn:SetFrameStrata('MEDIUM')
    btn:SetFixedFrameStrata(true)
    btn:SetParent(Minimap)

    libDBIcon.objects[name]= btn

    if not db or not db.lock then
        libDBIcon:Unlock(name)
    end

    libDBIcon:SetButtonToPosition(btn, db and db.minimapPos or nil)

--显示/隐藏
    if not db or not db.hide then
        libDBIcon:Show(name)
    else
        libDBIcon:Hide(name)
    end

--[[材质
    btn.icon:SetSize(18, 18)
    for _, region in pairs ({btn:GetRegions()}) do
        if region:GetObjectType()=='Texture' and region~=btn.icon then
            local text= region:GetTexture()
            if text==136430 then--OVERLAY 
                region:SetSize(50, 50)
                region:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)


            elseif text==136467 then--BACKGROUND
                region:SetSize(24, 24)
            end
        end
    end]]


end








local function Init_Buttons()
    local level= Button.frame:GetFrameLevel()+1
    local strata= Save().Icons.strata or 'HIGH'
    local isSortUp= Save().Icons.isSortUp
    local noAdd= Save().Icons.noAdd
    local hideAdd= Save().Icons.hideAdd
    local x= Save().Icons.pointX or 0
    local numLine= Save().Icons.numLine or 4

    local tab={}

    for name, btn in pairs(libDBIcon.objects) do
        if not noAdd[name] then
            Objects[name]= btn
            libDBIcon.objects[name]=nil
            Lock_Button(btn, name)
        end
    end

    for name, btn in pairs(Objects) do
        if noAdd[name] then
            Unlock_Button(btn, name)

        elseif hideAdd[name] then
            btn:SetShown(false)

        elseif btn:IsShown() then
            table.insert(tab, {
                btn=btn,
                name=name
            })
        end
    end

--排序
    table.sort(tab, function(a, b)
        if isSortUp then
            return a.name>b.name
        else
            return a.name<b.name
        end
    end)

--设置，位置
    local btn

    for index, data in pairs(tab) do
        btn= data.btn

        Lock_Button(btn, strata, level)

        btn:ClearAllPoints()

        btn:SetPoint('BOTTOMLEFT', index==1 and Button or tab[index-1].btn, 'TOPLEFT', 0, x)

        Button.Background:SetPoint('LEFT', btn)
        Button.Background:SetPoint('TOP', btn)
    end

    for i= numLine, #tab, numLine do
        tab[i].btn:ClearAllPoints()
        tab[i].btn:SetPoint('BOTTOMRIGHT', tab[i-numLine] and tab[i-numLine].btn or Button, 'BOTTOMLEFT', -x, 0)

        Button.Background:SetPoint('LEFT', btn)
        Button.Background:SetPoint('TOP', tab[i-1] and tab[i-1].btn or Button)
    end
end























--设置，按钮，材质
local function Set_Button_Texture(btn, name)
    btn= btn or Get_Button(name)

    if not btn then
        return
    end

    local bgAlpha, borderAlpha
    local icon= btn.icon

    if not Save().Icons.disabled then
        if libDBIcon.objects[name] then
            borderAlpha= Save().Icons.borderAlpha2
            bgAlpha= Save().Icons.bgAlpha2
        else
            borderAlpha= Save().Icons.borderAlpha
            bgAlpha= Save().Icons.bgAlpha
        end
    elseif not Save().disabled then
        borderAlpha= Save().Icons.borderAlpha2
        bgAlpha= Save().Icons.bgAlpha2
    end
    bgAlpha, borderAlpha= bgAlpha or 0.5, borderAlpha or 0

    for _, region in pairs ({btn:GetRegions()}) do
        if region:GetObjectType()=='Texture' and region~=icon then
            local text= region:GetTexture()
            if text==136430 then--OVERLAY 
                region:SetAlpha(borderAlpha)
                WoWTools_TextureMixin:SetAlphaColor(region, nil, nil, borderAlpha or 0)

            elseif text==136467 then--BACKGROUND
                region:SetAlpha(bgAlpha)
            end
        end
    end
end


local function Init_Lib_Register()
    hooksecurefunc(libDBIcon, 'Register', function(_, name)
        if Button and not Save().Icons.disabled then
            Init_Buttons()
        end

        Set_Button_Texture(nil, name)
    end)
    Init_Register=function()end
end

local function Init_AllButton_Texture()
    Set_Lib()

    Init_Lib_Register()

    for _, name in pairs(libDBIcon:GetButtonList()) do
        Set_Button_Texture(nil, name)
    end

    for name, btn in pairs(Objects) do
        Set_Button_Texture(btn, name)
    end

    if Button then
        Set_Button_Texture(Button, nil)
    end
end
























local function Init_Menu(self, root)
    local sub, sub2, num
    local allAddNum= 0

--过滤
    num=0
    for _ in pairs(Save().Icons.noAdd) do
        num=num+1
    end
    sub= root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '过滤' or AUCTION_HOUSE_SEARCH_BAR_FILTERS_LABEL)..' |cnRED_FONT_COLOR:#|r'..num,
    function()
        return MenuResponse.Open
    end)

--过滤
    sub2= sub:CreateButton(WoWTools_DataMixin.onlyChinese and '过滤' or AUCTION_HOUSE_SEARCH_BAR_FILTERS_LABEL, function() return MenuResponse.Open end)
    
--过滤 Border 透明度
    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save().Icons.borderAlpha2 or 0
        end, setValue=function(value)
            Save().Icons.borderAlpha2=value
            self:settings()
        end,
        name='Border Alpha',
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub2:CreateSpacer()

--过滤 Bg Alpha
    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save().Icons.bgAlpha2 or 0.5
        end, setValue=function(value)
            Save().Icons.bgAlpha2=value
            self:settings()
        end,
        name='Background Alpha',
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub2:CreateSpacer()


--过滤，列表
    sub:CreateDivider()
    num=0
    for name, btn in pairs(Get_All_Objects()) do
        num= num+1
        sub:CreateCheckbox(
            num..') '
            ..'|T'..(btn.dataObject.icon or 0)..':0|t'
            ..(btn:IsShown() and (Save().Icons.noAdd[name] and '|cnRED_FONT_COLOR:' or '') or '|cff626262')
            ..name,
        function(data)
            return Save().Icons.noAdd[data.name]
        end, function(data)
            Save().Icons.noAdd[data.name]= not Save().Icons.noAdd[data.name] and true or nil
            Save().Icons.hideAdd[data.name]=nil
            Unlock_Button(nil, data.name)
            self:settings()
        end, {name=name})
    end
    WoWTools_MenuMixin:SetScrollMode(sub, nil)--SetScrollMod

--隐藏
    num=0
    for _ in pairs(Save().Icons.hideAdd) do
        num=num+1
    end
    sub= root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)..' |cff626262#|r'..num,
    function()
        return MenuResponse.Open
    end)

--隐藏，列表
    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
    sub:CreateDivider()
    num=0
    for name, btn in pairs(Get_All_Objects()) do
        num= num+1
        sub:CreateCheckbox(
            num..') '
            ..'|T'..(btn.dataObject.icon or 0)..':0|t'
            ..(btn:IsShown() and (Save().Icons.noAdd[name] and '|cnRED_FONT_COLOR:' or '') or '|cff626262')
            ..name,
        function(data)
            return Save().Icons.hideAdd[data.name]
        end, function(data)
            Save().Icons.hideAdd[data.name]= not Save().Icons.hideAdd[data.name] and true or nil
            Save().Icons.noAdd[data.name]=nil
            Unlock_Button(nil, data.name)
            self:settings()
        end, {name=name})
    end
    WoWTools_MenuMixin:SetScrollMode(sub, nil)--SetScrollMod
    allAddNum= num

    root:CreateDivider()







--设置，按钮
    sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '按钮' or 'Button',
    function()
        return MenuResponse.Open
    end)

--Border 透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.borderAlpha or 0
        end, setValue=function(value)
            Save().Icons.borderAlpha=value
            self:settings()
        end,
        name='Border Alpha',
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub:CreateSpacer()

--Bg Alpha
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.bgAlpha or 0.5
        end, setValue=function(value)
            Save().Icons.bgAlpha=value
            self:settings()
        end,
        name='Background Alpha',
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub:CreateSpacer()

--按钮，间隔
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.pointX or 0
        end, setValue=function(value)
            Save().Icons.pointX=value
            self:settings()
        end,
        name='X',
        minValue=-15,
        maxValue=15,
        step=1,
    })
    sub:CreateSpacer()

--数量
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.numLine or 4
        end, setValue=function(value)
            Save().Icons.numLine=value
            self:settings()
        end,
        name=WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL,
        minValue=1,
        maxValue=allAddNum+1,
        step=1,
    })
    sub:CreateSpacer()

--升序
    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '升序' or PERKS_PROGRAM_ASCENDING,
    function()
        return Save().Icons.isSortUp
    end, function()
        Save().Icons.isSortUp= not Save().Icons.isSortUp and true or nil
        self:settings()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '按字母排序' or OPTION_RAID_SORT_BY_ALPHABETICAL)
    end)






    sub=root:CreateButton(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)

--显示背景
    WoWTools_MenuMixin:ShowBackground(sub,
    function()
        return not Save().Icons.hideBackground
    end, function()
        local hide= Save().Icons.hideBackground
        Save().Icons.hideBackground= not hide and true or nil
        self:settings()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().Icons.scale or 1
    end, function(value)
        Save().Icons.scale= value
        self:settings()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().Icons.strata= data
        self:settings()
    end)

    sub:CreateDivider()
--重置位置
    WoWTools_MenuMixin:RestPoint(self, sub, Save().Icons.point, function()
        Save().Icons.point=nil
        self:set_point()
        return MenuResponse.Open
    end)










    root:CreateDivider()
--打开，选项
    WoWTools_MenuMixin:OpenOptions(root, {
        name=WoWTools_MinimapMixin.addName,
        name2=WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '收集图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WEEKLY_REWARDS_GET_CONCESSION, EMBLEM_SYMBOL))
    })
end






































local function Init()
    if Save().Icons.disabled then
        return
    end
    Set_Lib()


    Button= WoWTools_ButtonMixin:Cbtn(nil, {
        name='WoWToolsMinimapCollectionIcons',
        size=31,
        isType2=true,
        notTexture=true,
        notBorder=true,
    })
    Button:SetHighlightTexture(136477)--"Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"

    Button.border = Button:CreateTexture(nil, "OVERLAY")
    Button.border:SetSize(50, 50)
    Button.border:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
    Button.border:SetPoint("TOPLEFT", Button, "TOPLEFT")

    Button.bg = Button:CreateTexture(nil, "BACKGROUND")
    Button.bg:SetSize(24, 24)
    Button.bg:SetTexture(136467) --"Interface\\Minimap\\UI-Minimap-Background"
    Button.bg:SetPoint("CENTER", Button, "CENTER")

    Button.icon=Button:CreateTexture(nil, 'BORDER')
    Button.icon:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
    Button.icon:SetPoint('CENTER')
    Button.icon:SetSize(18, 18)

    Button.frame= CreateFrame('Frame', nil, Button)
    Button.frame:SetAllPoints()



--显示背景 Background
    WoWTools_TextureMixin:CreateBackground(Button)
    Button.Background:SetPoint('BOTTOMRIGHT', Button)


    Button:SetMovable(true)
    Button:SetClampedToScreen(true)
    Button:RegisterForDrag("RightButton")
    Button:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    Button:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().Icons.point= {self:GetPoint(1)}
            Save().Icons.point[2]=nil
        end
    end)

    Button:SetScript("OnMouseUp", ResetCursor)--停止移动
    Button:SetScript("OnMouseDown", function(self, d)--设置, 光标
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='RightButton' then
             MenuUtil.CreateContextMenu(self, Init_Menu)

        elseif d=='LeftButton' then
            WoWTools_MinimapMixin:Open_Menu(self)
        end
    end)

    Button:EnableMouseWheel(true)
    Button:SetScript('OnMouseWheel', function(_, d)
        if d==1 then
            WoWTools_PanelMixin:Open(nil, '|A:talents-button-undo:0:0|a'..(WoWTools_DataMixin.onlyChinese and '设置数据' or RESET_ALL_BUTTON_TEXT))
        else
            WoWTools_PanelMixin:Open(nil, WoWTools_MinimapMixin.addName)
        end
    end)

    Button:SetScript("OnLeave", function(self)
        --self.texture:SetAlpha(0.5)
        ResetCursor()
        GameTooltip:Hide()
    end)
    Button:SetScript('OnEnter', function(self)
        --self.texture:SetAlpha(1)
        self:set_tooltip()
    end)

    function Button:set_event()
        self:UnregisterAllEvents()
--战斗
        if Save().Icons.hideInCombat then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
--移动
        if Save().Icons.hideInMove then
            self:RegisterEvent("PLAYER_STARTED_MOVING")
            self:RegisterEvent("PLAYER_STOPPED_MOVING")
        end
    end

    function Button:set_tooltip()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '收集图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WEEKLY_REWARDS_GET_CONCESSION, EMBLEM_SYMBOL))
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL,
            WoWTools_DataMixin.Icon.left..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE,
            'Alt+'..WoWTools_DataMixin.Icon.right
        )

        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '打开选项界面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS), 'UI'),
            WoWTools_DataMixin.Icon.mid
        )
        GameTooltip:Show()
    end

    function Button:rest_bg_postion()
        self.Background:SetPoint('LEFT', self)
        self.Background:SetPoint('TOP', self)
    end

    function Button:settings()
        self:SetFrameStrata(Save().Icons.strata or 'HIGH')
        self:SetScale(Save().Icons.scale or 1)
        self:rest_bg_postion()
        Init_Buttons()
        Init_AllButton_Texture()
        self.Background:SetShown(not Save().Icons.hideBackground)
        self:SetShown(true)
    end

    function Button:set_point()
        self:ClearAllPoints()
        local p= Save().Icons.point
        if p and p[1] then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint('CENTER', 100, 100)
        end
    end

    function Button:rest()
        for name, btn in pairs(Objects) do
            Unlock_Button(btn, name)
        end
        self:SetShown(false)
    end


    Button:set_point()
    Button:settings()


    Init=function()
        if Save().Icons.disabled then
            Button:rest()
            WoWTools_MinimapMixin:Init_Icon()
        else
            Button:set_point()
            Button:settings()
        end
    end
end








function WoWTools_MinimapMixin:Init_Collection_Icon()
    Init()
end

function WoWTools_MinimapMixin:Init_SetMinamp_Texture()
    Init_AllButton_Texture()
end