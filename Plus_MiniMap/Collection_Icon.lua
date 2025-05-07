local function Save()
    return  WoWToolsSave['Minimap_Plus']
end
local Button
local libDBIcon
local Objects={}


local function Get_Button(name)
    return Objects[name] or libDBIcon:GetMinimapButton(name)
end

--锁定按钮
local function Lock_Button(btn, name)--lib:Lock(name)
    btn= btn or Get_Button(name)
    if not btn or btn.WoWToolsIsLocked then
        return
    end

    libDBIcon.objects[name]= nil

    btn:SetFixedFrameStrata(false)
    btn:SetParent(Button.frame)
    btn.WoWToolsIsLocked=true

    if not btn:GetScript('OnDragStart') then
        return
    end

    --btn:SetMovable(false)
    btn:SetScript("OnDragStart", nil)
    btn:SetScript("OnDragStop", nil)
end



--还原按钮
local function Unlock_Button(btn, name)
    btn= btn or Get_Button(name)
    if not btn or not btn.WoWToolsIsLocked then
        return
    end
    btn:ClearAllPoints()
    btn:SetFrameStrata('MEDIUM')
    btn:SetFixedFrameStrata(true)
    btn:SetParent(Minimap)

    libDBIcon.objects[name]= btn
    libDBIcon:Unlock(name)

    local db= btn.db

    libDBIcon:SetButtonToPosition(btn, db and db.minimapPos or nil)

    if not db or not db.hide then
        libDBIcon:Show(name)
    else
        libDBIcon:Hide(name)
    end

    --btn:SetMovable(false)



    btn.WoWToolsIsLocked=nil
end








local function Init_Buttons()
    local level= Button.frame:GetFrameLevel()+1
    local strata= Save().Icons.strata or 'HIGH'
    local isSortUp= Save().Icons.isSortUp
    local noAdd= Save().Icons.noAdd
    local hideAdd= Save().Icons.hideAdd

    local tab={}

    for name, btn in pairs(libDBIcon.objects) do
        Objects[name]= btn
    end


    for name, btn in pairs(Objects) do
        if noAdd[name] then
            Unlock_Button(btn, name)

        elseif hideAdd[name] then
            Lock_Button(btn, name)
            btn:SetShown(false)

        elseif btn:IsShown() then
            table.insert(tab, {
                btn=btn,
                name=name
            })
        end
    end


    table.sort(tab, function(a, b)
        if isSortUp then
            return a.name>b.name
        else
            return a.name<b.name
        end
    end)


    local btn
    for index, data in pairs(tab) do
        btn= data.btn

        Lock_Button(btn, strata, level)

        btn:ClearAllPoints()

        btn:SetPoint('BOTTOM', index==1 and Button or tab[index-1].btn, 'TOP')


        Button.Background:SetPoint('LEFT', btn)
        Button.Background:SetPoint('TOP', btn)
    end

    local numLine= Save().Icons.numLine or 1

    for i= numLine+1, #tab, numLine do

        tab[i].btn:ClearAllPoints()
        tab[i].btn:SetPoint('RIGHT', tab[i-numLine] and tab[i-numLine].btn or Button, 'LEFT')

        Button.Background:SetPoint('LEFT', btn)
        Button.Background:SetPoint('TOP', tab[i-1].btn)
    end
end













local function Init_Menu(self, root)
    local sub, num

--过滤
    num=0
    for _ in pairs(Save().Icons.noAdd) do
        num=num+1
    end
    sub= root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '过滤' or AUCTION_HOUSE_SEARCH_BAR_FILTERS_LABEL)..' #'..num,
    function()
        return MenuResponse.Open
    end)

--过滤，列表
    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '过滤' or AUCTION_HOUSE_SEARCH_BAR_FILTERS_LABEL)
    sub:CreateDivider()
    num=0
    for name in pairs(Objects) do
        num= num+1
        sub:CreateCheckbox(
            num..') '..name,
        function(data)
            return Save().Icons.noAdd[data.name]
        end, function(data)
            Save().Icons.noAdd[data.name]= not Save().Icons.noAdd[data.name] and true or nil
            Save().Icons.hideAdd[data.name]=nil
            Unlock_Button(nil, name)
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
        (WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)..' #'..num,
    function()
        return MenuResponse.Open
    end)

--隐藏，列表
    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
    sub:CreateDivider()
    num=0
    for name in pairs(Objects) do
        num= num+1
        sub:CreateCheckbox(
            num..')'..name,
        function(data)
            return Save().Icons.hideAdd[data.name]
        end, function(data)
            Save().Icons.hideAdd[data.name]= not Save().Icons.hideAdd[data.name] and true or nil
            Save().Icons.noAdd[data.name]=nil
            Unlock_Button(nil, name)
            self:settings()
        end, {name=name})
    end
    WoWTools_MenuMixin:SetScrollMode(sub, nil)--SetScrollMod

--升序
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '升序' or PERKS_PROGRAM_ASCENDING,
    function()
        return Save().Icons.isSortUp
    end, function()
        Save().Icons.isSortUp= not Save().Icons.isSortUp and true or nil
        self:settings()
    end)

--显示背景
    WoWTools_MenuMixin:ShowBackground(root,
    function()
        return not Save().Icons.hideBackground
    end, function()
        local hide= Save().Icons.hideBackground
        Save().Icons.hideBackground= not hide and true or nil
        self:settings()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(root, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().Icons.strata= data
        self:settings()
    end)

    root:CreateDivider()
--重置位置
    WoWTools_MenuMixin:RestPoint(self, root, Save().Icons.point, function()
        Save().Icons.point=nil
        self:set_point()
        return MenuResponse.Open
    end)

--打开，选项
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MinimapMixin.addName})
end


















local function Init()
    if Save().Icons.disabled then
        return
    end

    libDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if not libDBIcon then
        return
    end

    Button= WoWTools_ButtonMixin:Cbtn(nil, {
        name='WoWToolsMinimapCollectionIcons',
        size=23,
        isType2=true,
        notBorder=true,
    })
    Button.texture:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')

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
        self:rest_bg_postion()
        Init_Buttons()
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


    hooksecurefunc(LibStub("LibDBIcon-1.0", true), 'Register', function()
        if not Save().Icons.disabled then
            Init_Buttons()
        end
    end)

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
