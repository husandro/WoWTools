--点击移动
local function Save()
    return WoWToolsSave['Plus_PetBattle2']
end





local CameraTabs={}
local CVarNameTabs={}


local function Init_Camera_Tabs()
    CameraTabs={
        ['1']={WoWTools_DataMixin.onlyChinese and '移动时只调整水平角度' or CAMERA_SMART, WoWTools_DataMixin.onlyChinese and '将视角固定在你所设置的角度，但你的角色移动时则恢复到跟踪视角。（只调整水平角度）' or OPTION_TOOLTIP_CAMERA_SMART},
        ['4']={WoWTools_DataMixin.onlyChinese and '仅在移动时' or CAMERA_SMARTER, WoWTools_DataMixin.onlyChinese and '将视角固定在你所设置的角度，但你的角色移动时则恢复到跟踪视角。' or OPTION_TOOLTIP_CAMERA_SMARTER},
        ['2']={WoWTools_DataMixin.onlyChinese and '总是调整视角' or CAMERA_ALWAYS, WoWTools_DataMixin.onlyChinese and '设定视角，使视角总是处于你的角色后方。' or OPTION_TOOLTIP_CAMERA_ALWAYS},
        ['0']={WoWTools_DataMixin.onlyChinese and '从不调整镜头' or CAMERA_NEVER, WoWTools_DataMixin.onlyChinese and '设定视角，使其固定在一点，永远不自动调节。' or OPTION_TOOLTIP_CAMERA_NEVER},
    }
    CVarNameTabs={
        ['autoInteract']= WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '点击移动' or CLICK_TO_MOVE),
        ['cameraSmoothStyle']= WoWTools_DataMixin.onlyChinese and '镜头跟随模式' or CAMERA_FOLLOWING_STYLE,
        ['cameraSmoothTrackingStyle']= WoWTools_DataMixin.onlyChinese and '点击移动镜头' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLICK_TO_MOVE, CAMERA_LABEL)
    }
end

local function Lock_Is_CVar(name)
    if Save().ClickMoveButton['lock_'..name] then
        return '|A:AdventureMapIcon-Lock:0:0|a'
    end
end


local function Lock_CVar(self, name)
    local value= Save().ClickMoveButton['lock_'..name]
    if PlayerIsInCombat() then
        if value then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end

    elseif value and C_CVar.GetCVar(name)~=value then
        if C_CVar.SetCVar(name, value) then
            print(
                CVarNameTabs[name]..WoWTools_DataMixin.Icon.icon2,
                '|A:AdventureMapIcon-Lock:0:0|a|cnWARNING_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK)..'|r',

                name=='autoInteract' and WoWTools_TextMixin:GetEnabeleDisable(value=='1')
                    or CameraTabs[value][1]
            )
        end
    end
end


local function Get_Lock_ClickToMove_Value()
    if Save().ClickMoveButton.AutoClickToMove then
        return WoWTools_DataMixin.Player.IsMaxLevel and '1' or '0'
    else
        return Save().ClickMoveButton['lock_autoInteract']
    end
end



local function Lock_ClickToMove_CVar(self)
    local value=  Get_Lock_ClickToMove_Value()
    if PlayerIsInCombat() then
        if value then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
        return
    end

    if value and C_CVar.GetCVar('autoInteract')~=value then
        if C_CVar.SetCVar('autoInteract', value) then
            print(
            CVarNameTabs['autoInteract']..WoWTools_DataMixin.Icon.icon2,
                '|A:AdventureMapIcon-Lock:0:0|a|cnWARNING_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK)
                ..'|cnGREEN_FONT_COLOR:'..WoWTools_TextMixin:GetEnabeleDisable(value=='1')
            )
        end
    end
end



















local function Init_ClickToMove_Menu(self, root)
    local sub
    for _, tab in pairs({
        {'0', WoWTools_DataMixin.onlyChinese and '锁定禁用' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOCK, DISABLE)},
        {'1', WoWTools_DataMixin.onlyChinese and '锁定启用' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOCK, ENABLE)},
    }) do
        sub=root:CreateRadio(
            '|A:AdventureMapIcon-Lock:0:0|a'..tab[2],
        function(data)
            return Save().ClickMoveButton['lock_autoInteract']==data.value
        end, function(data)
            Save().ClickMoveButton['lock_autoInteract']= Save().ClickMoveButton['lock_autoInteract']~=data.value and data.value or nil
            Save().ClickMoveButton.AutoClickToMove=nil
            Lock_ClickToMove_CVar(self)
            self:set_State()
            return MenuResponse.Refresh
        end, {value=tab[1]})
        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddDoubleLine('CVar autoInteract', desc.data.value)
            tooltip:AddLine(' ')
            tooltip:AddLine(CVarNameTabs['autoInteract'])
        end)
    end

    sub=root:CreateRadio(
        '|A:AdventureMapIcon-Lock:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '自动锁定' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, LOCK)),
    function()
        return Save().ClickMoveButton.AutoClickToMove
    end, function()
        Save().ClickMoveButton.AutoClickToMove= not Save().ClickMoveButton.AutoClickToMove and true or nil
        Save().ClickMoveButton['lock_autoInteract']= nil
        Lock_ClickToMove_CVar(self)
        self:set_State()
        return MenuResponse.Refresh
    end)
    sub:SetTooltip(function(tooltip)
        local maxLevel= GetMaxLevelForLatestExpansion()
        tooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '等级' or LEVEL)
            ..' < '..maxLevel,
            WoWTools_TextMixin:GetEnabeleDisable(false)
        )
        tooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '等级' or LEVEL)
            ..' = '..maxLevel,
            WoWTools_TextMixin:GetEnabeleDisable(true)
        )
    end)
end









local function Init_CVar_Menu(self, root, name, col)
    local sub
    for _, value in pairs({'1', '4', '2', '0'}) do
        sub= root:CreateRadio(
            (Save().ClickMoveButton['lock_'..name]==value and '|A:AdventureMapIcon-Lock:0:0|a' or '')
            ..(Lock_Is_CVar(name) and '|cff828282' or col)
            ..CameraTabs[value][1],

        function(data)
            return C_CVar.GetCVar(data.name)==data.value

        end, function(data)
            if not PlayerIsInCombat() and not Lock_Is_CVar(name) then
                if C_CVar.GetCVar(data.name)~=data.value then
                    C_CVar.SetCVar(data.name, data.value)
                end
            end
            return MenuResponse.Refresh
        end, {value=value, name=name})

        sub:SetTooltip(function(tooltip, desc)
            if Save().ClickMoveButton['lock_'..name] then
                GameTooltip_AddErrorLine(tooltip,
                    '|A:AdventureMapIcon-Lock:0:0|a'
                    ..(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK)
                )
            end
            tooltip:AddDoubleLine(desc.data.name, desc.data.value)
            tooltip:AddLine(' ')
            tooltip:AddLine(CameraTabs[desc.data.value][2], nil, nil, nil, true)
        end)
        sub:AddInitializer(function(btn, desc)
            btn:RegisterEvent('CVAR_UPDATE')
            btn:SetScript('OnEvent', function(b, _, cvarName)
                if cvarName==desc.data.name and b.leftTexture2 then
                    b.leftTexture2:SetShown(
                        C_CVar.GetCVar(cvarName)==desc.data.value
                    )
                end
            end)
            btn:SetScript('OnHide', function(b)
                b:UnregisterEvent('CVAR_UPDATE')
            end)
        end)



        sub:CreateCheckbox(
            '|A:AdventureMapIcon-Lock:0:0|a'
            ..col
            ..(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK),

        function(data)
            return Save().ClickMoveButton['lock_'..data.name]==data.value

        end, function(data)
            Save().ClickMoveButton['lock_'..data.name]= Save().ClickMoveButton['lock_'..data.name]~=data.value and data.value or nil
            Lock_CVar(self, data.name)
            return MenuResponse.Refresh
        end, {value=value, name=name})
    end
end


















local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2
    local col= PlayerIsInCombat() and '|cff828282' or ''

--点击移动
    sub=root:CreateCheckbox(
        (Get_Lock_ClickToMove_Value() and '|A:AdventureMapIcon-Lock:0:0|a|cff828282' or col)
        ..CVarNameTabs['autoInteract'],
    function()
        return C_CVar.GetCVarBool("autoInteract")
    end, function()
        if Get_Lock_ClickToMove_Value() then--锁定
            Lock_ClickToMove_CVar(self)
        else
            self:set_clickmove()
        end
    end)

    sub:SetTooltip(function(tooltip)
        if Get_Lock_ClickToMove_Value() then
            GameTooltip_AddErrorLine(tooltip,
                '|A:AdventureMapIcon-Lock:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK)
            )
        end

        if PlayerIsInCombat() then
            GameTooltip_AddErrorLine(tooltip,
                (WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
            )
        end
    end)









    Init_ClickToMove_Menu(self, sub)





--点击移动, 镜头跟随模式
    root:CreateTitle(WoWTools_DataMixin.onlyChinese and '鼠标' or MOUSE_LABEL)
    Init_CVar_Menu(self, root, 'cameraSmoothTrackingStyle', col)

--移动，镜头跟随模式
    root:CreateTitle(WoWTools_DataMixin.onlyChinese and '镜头' or CAMERA_LABEL)
    Init_CVar_Menu(self, root, 'cameraSmoothStyle', col)

    --[[sub=root:CreateButton(
        (Lock_Is_CVar('cameraSmoothStyle') or '')
        ..col
        ..(WoWTools_DataMixin.onlyChinese and '镜头跟随模式' or CAMERA_FOLLOWING_STYLE),
    function()
        return MenuResponse.Open
    end)
   


    sub:CreateDivider()
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '镜头跟随模式' or CAMERA_FOLLOWING_STYLE,
    function()
         if not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID, CLICK_TO_MOVE)--ItemRef.lua
        end
        return MenuResponse.Open
    end)
 ]]
--打开选项界面
    root:CreateDivider()
    sub=  WoWTools_MenuMixin:OpenOptions(root, {
            category=WoWTools_PetBattleMixin.Category,
            name= WoWTools_PetBattleMixin.addName,
            name2= WoWTools_PetBattleMixin.addName3
        })

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().ClickMoveButton.Scale or 1
    end, function(value)
        Save().ClickMoveButton.Scale= value
        self:set_scale()
    end)

--FrameStrata      
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        self:SetFrameStrata(data or 'MEDIUM')
        Save().ClickMoveButton.Strata= data
    end)


    sub2= sub:CreateCheckbox(
        'UIParent',
    function()
        return not Save().ClickMoveButton.PlayerFrame
    end, function()
        Save().ClickMoveButton.PlayerFrame= not Save().ClickMoveButton.PlayerFrame and true or false
        self:Settings()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('SetParent(\"UIParent\")')
    end)

    sub:CreateDivider()
--重置
    sub:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '重置' or RESET),
    function()
        Save().ClickMoveButton={
            PlayerFrame=true,
            lock_autoInteract=WoWTools_DataMixin.Player.husandro and '1' or nil,
            lock_cameraSmoothStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
            lock_cameraSmoothTrackingStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
        }
        self:Settings()
        return MenuResponse.Open
    end)
end




















local function Init_Button()
    if Save().ClickMoveButton.disabled then
        return
    end

    Init_Camera_Tabs()

    local btn= CreateFrame('DropdownButton', 'WoWToolsClickToMoveButton', PlayerFrame, 'WoWToolsMenu2Template')
    btn.texture:SetAtlas('transmog-gearSlot-unassigned-feet')
    btn.border:SetAlpha(0.3)
    btn.lockedTexture= btn:CreateTexture(nil, 'ARTWORK')
    btn.lockedTexture:SetSize(10,10)
    btn.lockedTexture:SetPoint('BOTTOM')
    btn.lockedTexture:SetAtlas('AdventureMapIcon-Lock')
    WoWTools_TextureMixin:SetAlphaColor(btn.lockedTexture, true)


    function btn:set_scale()
        self:SetScale(Save().ClickMoveButton.Scale or 1)
    end


    function btn:Settings()
        self:UnregisterAllEvents()

        if Save().ClickMoveButton.disabled then
            self:SetShown(false)
            return
        end

        self:ClearAllPoints()
        if Save().ClickMoveButton.PlayerFrame then
            --[[local frameLevel= PlayerFrame:GetFrameLevel() +1
            local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual()
            self:SetFrameLevel( PlayerFrame:GetFrameLevel() +1)]]
            self:SetParent(PlayerFrame)
            self:SetPoint('RIGHT', PlayerFrame.portrait, 'LEFT', 2, -8)
        else
            self:SetParent(UIParent)
            local p= Save().ClickMoveButton.Point
            if p and p[1] then
                self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
            else
                self:SetPoint('CENTER', UIParent, 100, 100)
            end
        end

        self:SetFrameStrata(Save().ClickMoveButton.Strata or 'MEDIUM')
        self:RegisterEvent('CVAR_UPDATE')
        self:set_State()
        self:set_scale()
        self:SetShown(true)
    end




    function btn:set_State()
        if C_CVar.GetCVarBool("autoInteract") then
            self.texture:SetVertexColor(1,1,1)
        else
            self.texture:SetVertexColor(1,0,0)
        end
        self.lockedTexture:SetShown(Get_Lock_ClickToMove_Value())
    end

    btn:SetScript('OnEvent', function(self, event, arg1)
        if event=='CVAR_UPDATE' then
            if arg1=='autoInteract' then
                self:set_State()
                Lock_ClickToMove_CVar(self)
            elseif arg1=='cameraSmoothStyle' or arg1=='cameraSmoothTrackingStyle' then
                Lock_CVar(self, arg1)
            end
        elseif event=='PLAYER_REGEN_ENABLED' then
            Lock_ClickToMove_CVar(self)
            Lock_CVar(self, 'cameraSmoothStyle')
            Lock_CVar(self, 'cameraSmoothTrackingStyle')
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end)

    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_PetBattleMixin.addName, WoWTools_PetBattleMixin.addName3)
        GameTooltip:AddLine(' ')
        local col= PlayerIsInCombat() and '|cff626262' or ''
        GameTooltip:AddDoubleLine(
            (Get_Lock_ClickToMove_Value() and '|cff828282' or col)
            ..CVarNameTabs['autoInteract']
            ..': |r'
            ..WoWTools_TextMixin:GetEnabeleDisable(C_CVar.GetCVarBool("autoInteract")),

            WoWTools_DataMixin.Icon.left
        )

        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL,

            WoWTools_DataMixin.Icon.right
        )

        if not Save().ClickMoveButton.PlayerFrame then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(
                WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE,
                'Alt+'..WoWTools_DataMixin.Icon.right
            )
        end
        GameTooltip:Show()
        self:SetAlpha(1)
    end
    btn:SetScript('OnLeave', function(self) ResetCursor() GameTooltip:Hide() self:set_State() end)
    btn:SetScript('OnEnter', btn.set_tooltip)

    btn:RegisterForDrag("RightButton")
    btn:SetMovable(true)
    btn:SetClampedToScreen(true)
    btn:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() and not Save().ClickMoveButton.PlayerFrame then
            self:CloseMenu()
            self:StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().ClickMoveButton.Point={self:GetPoint(1)}
            Save().ClickMoveButton.Point[2]=nil
        end
    end)

    function btn:set_clickmove()
        if not PlayerIsInCombat() then
            C_CVar.SetCVar("autoInteract",
                C_CVar.GetCVarBool("autoInteract") and '0' or '1'
            )
        end

    end

    btn:SetScript("OnMouseUp", ResetCursor)
    btn:SetScript("OnMouseDown", function(self, d)
        if d=='LeftButton' then
            self:set_clickmove()
            self:CloseMenu()
        elseif d=='RightButton' and IsAltKeyDown() and not Save().ClickMoveButton.PlayerFrame then
            SetCursor('UI_MOVE_CURSOR')
        end
        self:set_tooltip()
    end)

    btn:SetupMenu(Init_Menu)

    btn:Settings()

    Lock_CVar(btn, 'cameraSmoothTrackingStyle')
    Lock_CVar(btn, 'cameraSmoothStyle')
    Lock_ClickToMove_CVar(btn)


    Init_Button=function()
        _G['WoWToolsClickToMoveButton']:Settings()
    end
end











function WoWTools_PetBattleMixin:ClickToMove_Button()
    Init_Button()
end
