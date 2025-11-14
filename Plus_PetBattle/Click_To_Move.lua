--点击移动
local function Save()
    return WoWToolsSave['Plus_PetBattle2']
end




local ClickToMoveButton--, Frame
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

local function Is_Lock_CVar(name)
    if Save().ClickMoveButton['lock_'..name] then
        return '|A:AdventureMapIcon-Lock:0:0|a'
    end
end


local function Lock_CVar(name)
    local value= Save().ClickMoveButton['lock_'..name]
    if UnitAffectingCombat('player') then
        if value then
            ClickToMoveButton:RegisterEvent('PLAYER_REGEN_ENABLED')
        end

    elseif value and C_CVar.GetCVar(name)~=value then
        if C_CVar.SetCVar(name, value) then
            print(WoWTools_DataMixin.addName, CVarNameTabs[name],
                '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK)..'|r',
                name=='autoInteract' and '' or CameraTabs[value][1]
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



local function Lock_ClickToMove_CVar()
    local value=  Get_Lock_ClickToMove_Value()
    if UnitAffectingCombat('player') then
        if value then
            ClickToMoveButton:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
        return
    end

    if value and C_CVar.GetCVar('autoInteract')~=value then
        if C_CVar.SetCVar('autoInteract', value) then
            print(WoWTools_DataMixin.addName,
            CVarNameTabs['autoInteract'],
                '|A:AdventureMapIcon-Lock:0:0|a|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK)
            )
        end
    end
end



local function Set_ClickToMove_CVar()
    if not UnitAffectingCombat('player') then
        C_CVar.SetCVar("autoInteract", C_CVar.GetCVarBool("autoInteract") and '0' or '1')
    end
end



















local function Init_ClickToMove_Menu(self, root, col)
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
            Lock_ClickToMove_CVar()
            return MenuResponse.CloseAll
        end, {value=tab[1]})
        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddDoubleLine('autoInteract', desc.data.value)
            tooltip:AddLine(' ')
            tooltip:AddLine(CVarNameTabs['autoInteract'])
        end)
    end

    sub=root:CreateRadio(
        '|A:AdventureMapIcon-Lock:0:0|a'..(WoWTools_DataMixin.onlyChinese and '自动锁定' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, LOCK)),
    function()
        return Save().ClickMoveButton.AutoClickToMove
    end, function()
        Save().ClickMoveButton.AutoClickToMove= not Save().ClickMoveButton.AutoClickToMove and true or nil
        Save().ClickMoveButton['lock_autoInteract']= nil
        Lock_ClickToMove_CVar()
        return MenuResponse.CloseAll
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '等级' or LEVEL)..' < '..GetMaxLevelForLatestExpansion(), WoWTools_TextMixin:GetEnabeleDisable(false))
        tooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '等级' or LEVEL)..' = '..GetMaxLevelForLatestExpansion(), WoWTools_TextMixin:GetEnabeleDisable(true))
    end)
end









local function Init_CVar_Menu(root, name, col)
    local sub
    for _, value in pairs({'1', '4', '2', '0'}) do
        sub= root:CreateRadio(
            (Save().ClickMoveButton['lock_'..name]==value and '|A:AdventureMapIcon-Lock:0:0|a' or '')
            ..(Is_Lock_CVar(name) and '|cff828282' or col)
            ..CameraTabs[value][1],

        function(data)
            return C_CVar.GetCVar(data.name)==data.value

        end, function(data)
            if not UnitAffectingCombat('player') and not Is_Lock_CVar(name) then
                if C_CVar.GetCVar(data.name)~=data.value then
                    C_CVar.SetCVar(data.name, data.value)
                end
            end
            return MenuResponse.Refresh
        end, {value=value, name=name})

        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddDoubleLine(desc.data.name, desc.data.value)
            tooltip:AddLine(' ')
            tooltip:AddLine(CameraTabs[desc.data.value][2], nil, nil, nil, true)
        end)


        sub:CreateCheckbox(
            '|A:AdventureMapIcon-Lock:0:0|a'
            ..col
            ..(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK),

        function(data)
            return Save().ClickMoveButton['lock_'..data.name]==data.value

        end, function(data)
            Save().ClickMoveButton['lock_'..data.name]= Save().ClickMoveButton['lock_'..data.name]~=data.value and data.value or nil
            Lock_CVar(data.name, Save().ClickMoveButton['lock_'..data.name])
            --return MenuResponse.Refresh
            return MenuResponse.CloseAll
        end, {value=value, name=name})
    end
end


















local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2
    local col= UnitAffectingCombat('player') and '|cff828282' or ''

--点击移动
    sub=root:CreateCheckbox(
        (Get_Lock_ClickToMove_Value() and '|A:AdventureMapIcon-Lock:0:0|a|cff828282' or col)
        ..CVarNameTabs['autoInteract'],
    function()
        return C_CVar.GetCVarBool("autoInteract")
    end, function()
        if Get_Lock_ClickToMove_Value() then--锁定
            Lock_ClickToMove_CVar()
        else
            Set_ClickToMove_CVar()
        end
    end)

    sub:SetTooltip(function(tooltip)
        if UnitAffectingCombat('player') then
            tooltip:AddLine('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
        end
    end)
    root:CreateSpacer()

    Init_ClickToMove_Menu(self, sub, col)

    sub:CreateDivider()
--点击移动, 镜头跟随模式
    Init_CVar_Menu(sub, 'cameraSmoothTrackingStyle', col)
    sub:CreateDivider()
    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '点击移动' or CLICK_TO_MOVE)



--移动，镜头跟随模式
    sub=root:CreateButton(
        (Is_Lock_CVar('cameraSmoothStyle') or '')
        ..col
        ..(WoWTools_DataMixin.onlyChinese and '镜头跟随模式' or CAMERA_FOLLOWING_STYLE),
    function()
        return MenuResponse.Open
    end)
    Init_CVar_Menu(sub, 'cameraSmoothStyle', col)

    sub:CreateDivider()
    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '镜头跟随模式' or CAMERA_FOLLOWING_STYLE)

--打开选项界面
    root:CreateSpacer()
    sub= WoWTools_PetBattleMixin:OpenOptions(root, WoWTools_PetBattleMixin.addName3)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().ClickMoveButton.Scale or 1
    end, function(value)
        Save().ClickMoveButton.Scale= value
        self:set_scale()
    end)

--FrameStrata      
    sub2=WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        self:SetFrameStrata(data or 'MEDIUM')
        Save().ClickMoveButton.Strata= data
    end)
    sub2:SetEnabled(Save().ClickMoveButton.PlayerFrame)

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

    ClickToMoveButton= WoWTools_ButtonMixin:Menu(PlayerFrame,
        {
            atlas= 'transmog-nav-slot-feet',
            size= 23,
            isType2= true,
            name='WoWToolsClickToMoveButton',
        }
    )


    function ClickToMoveButton:set_scale()
        self:SetScale(Save().ClickMoveButton.Scale or 1)
    end


    function ClickToMoveButton:Settings()
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




    function ClickToMoveButton:set_State()
        --local icon= self:GetNormalTexture()
        if C_CVar.GetCVarBool("autoInteract") then
          --  self:UnlockHighlight()
            self.texture:SetVertexColor(1,1,1)
        else
            --self:LockHighlight()
            self.texture:SetVertexColor(1,0,0)
        end
    end

    ClickToMoveButton:SetScript('OnEvent', function(self, event, arg1)
        if event=='CVAR_UPDATE' then
            if arg1=='autoInteract' then
                self:set_State()
                Lock_ClickToMove_CVar()
            elseif arg1=='cameraSmoothStyle' or arg1=='cameraSmoothTrackingStyle' then
                Lock_CVar(arg1)
            end
        elseif event=='PLAYER_REGEN_ENABLED' then
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
            Lock_ClickToMove_CVar()
            Lock_CVar('cameraSmoothStyle')
            Lock_CVar('cameraSmoothTrackingStyle')
        end
    end)

    function ClickToMoveButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_PetBattleMixin.addName, WoWTools_PetBattleMixin.addName3)
        GameTooltip:AddLine(' ')
        local col= UnitAffectingCombat('player') and '|cff626262' or ''
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
    ClickToMoveButton:SetScript('OnLeave', function(self) ResetCursor() GameTooltip:Hide() self:set_State() end)
    ClickToMoveButton:SetScript('OnEnter', ClickToMoveButton.set_tooltip)

    ClickToMoveButton:RegisterForDrag("RightButton")
    ClickToMoveButton:SetMovable(true)
    ClickToMoveButton:SetClampedToScreen(true)
    ClickToMoveButton:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() and not Save().ClickMoveButton.PlayerFrame then
            self:StartMoving()
        end
    end)
    ClickToMoveButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().ClickMoveButton.Point={self:GetPoint(1)}
            Save().ClickMoveButton.Point[2]=nil
        else
            print(
                WoWTools_DataMixin.addName,
                '|cnWARNING_FONT_COLOR:',
                WoWTools_DataMixin.onlyChinese and '保存失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, FAILED)
            )
        end
    end)

    ClickToMoveButton:SetScript("OnMouseUp", ResetCursor)
    ClickToMoveButton:SetScript("OnMouseDown", function(self, d)
        if d=='LeftButton' then
            Set_ClickToMove_CVar()
            self:CloseMenu()
        elseif d=='RightButton' and IsAltKeyDown() and not Save().ClickMoveButton.PlayerFrame then
            SetCursor('UI_MOVE_CURSOR')
        end
        self:set_tooltip()
    end)

    ClickToMoveButton:SetupMenu(Init_Menu)

    ClickToMoveButton:Settings()

    Lock_CVar('cameraSmoothTrackingStyle')
    Lock_CVar('cameraSmoothStyle')
    Lock_ClickToMove_CVar()


    Init_Button=function()
        ClickToMoveButton:Settings()
    end
end











function WoWTools_PetBattleMixin:ClickToMove_Button()
    Init_Button()
end
