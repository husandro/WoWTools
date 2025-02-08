--点击移动
local e= select(2, ...)
local function Save()
    return WoWTools_PetBattleMixin.Save
end




local ClickToMoveButton, Frame


local function Set_ClickToMove_Cvar(value, printText)
    if UnitAffectingCombat('player') then
        return
    end
    local set
    if value then
        set= C_CVar.SetCVar("autoInteract", value)
    else
        set= C_CVar.SetCVar("autoInteract", C_CVar.GetCVarBool("autoInteract") and '0' or '1')
    end
    if printText and set then
        print(e.addName, WoWTools_PetBattleMixin.addName,
            e.onlyChinese and '点击移动' or CLICK_TO_MOVE,
            e.GetEnabeleDisable(C_CVar.GetCVarBool("autoInteract"))
        )
    end
end

local function Init_CVar()
    if not Save().clickToMove or Frame then
        if Frame then
            Frame:Settings()
        end
        return
    end

    Frame= CreateFrame('Frame')

    function Frame:Settings()
        self:UnregisterEvent('PLAYER_LEVEL_UP')
        if Save().clickToMove then
            if not e.Player.levelMax then
                self:RegisterEvent('PLAYER_LEVEL_UP')
            end
            self:set_cvar()
        end
    end

    function Frame:set_cvar()
        local value= C_CVar.GetCVarBool("autoInteract")
        if e.Player.levelMax then
            if not value then
                if not UnitAffectingCombat('player') then
                     Set_ClickToMove_Cvar('1', true)
                else
                    self:RegisterEvent('PLAYER_REGEN_ENABLED')
                end
            end
        elseif value then
            if not UnitAffectingCombat('player') then
                Set_ClickToMove_Cvar('0', true)
            else
                self:RegisterEvent('PLAYER_REGEN_ENABLED')
            end
        end
    end

    Frame:SetScript('OnEvent', function(self)
        self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        self:set_cvar()
    end)
end


















local function Init_Menu(self, root)
    local sub
--点击移动
    sub=root:CreateCheckbox(
        WoWTools_PetBattleMixin.addName2,
    function()
        return C_CVar.GetCVarBool("autoInteract")
    end, function()
        if not UnitAffectingCombat('player') then
            Set_ClickToMove_Cvar(nil, true)
        end
    end)
    sub:SetTooltip(function(tooltip)
        if UnitAffectingCombat('player') then
            tooltip:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
        end
    end)

    root:CreateDivider()
--缩放
    WoWTools_MenuMixin:Scale(root, function()
        return Save().ClickMoveButton.Scale or 1
    end, function(value)
        Save().ClickMoveButton.Scale= value
        self:Settings()
    end)


    if not Save().ClickMoveButton.PlayerFrame then
--FrameStrata      
        WoWTools_MenuMixin:FrameStrata(root, function(data)
            return self:GetFrameStrata()==data
        end, function(data)
            self:SetFrameStrata(data or 'MEDIUM')
            Save().ClickMoveButton.Strata= data
        end)

        
    sub:CreateDivider()
    --重置
        sub:CreateButton(
            e.onlyChinese and '重置' or RESET,
        function()
            Save().ClickMoveButton= {disabled= Save().ClickMoveButton.disabled}
            self:settings()
            return MenuResponse.Open
        end)
    end

--打开选项界面
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {
        category= WoWTools_PetBattleMixin.Category,
        name= WoWTools_PetBattleMixin.addName3
    })
end




















local function Init_Button()

    if Save().ClickMoveButton.disabled or ClickToMoveButton then
        if ClickToMoveButton then
            ClickToMoveButton:Settings()
        end
        return
    end


    ClickToMoveButton= WoWTools_ButtonMixin:CreateMenu(PlayerFrame,
        {
            atlas= 'transmog-nav-slot-feet',
            size= 19,
            isType2= true,
            hideIcon= true,
            name='WoWToolsClickToMoveButton',
        }
    )


    function ClickToMoveButton:Settings()
        self:UnregisterEvent('CVAR_UPDATE')
        if Save().ClickMoveButton.disabled then
            self:SetShown(false)
            return
        end

        self:ClearAllPoints()

        if Save().ClickMoveButton.PlayerFrame then
            local frameLevel= PlayerFrame:GetFrameLevel() +1
            local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual()
            self:SetParent(PlayerFrame)
            self:SetFrameStrata(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain:GetFrameStrata())
            self:SetFrameLevel( PlayerFrame:GetFrameLevel() +1)
            self:SetPoint('RIGHT', PlayerFrame.portrait, 'LEFT', 2, -8)
        else
            self:SetParent(UIParent)
            self:SetFrameStrata(Save().ClickMoveButton.Strata or 'MEDIUM')
            local p= Save().ClickMoveButton.Point
            if p then
                self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
            else
                self:SetPoint('CENTER', UIParent, 100, 100)
            end
        end

        self:RegisterEvent('CVAR_UPDATE')
        self:set_State()
        self:SetScale(Save().ClickMoveButton.Scale or 1)
        self:SetShown(true)
    end




    function ClickToMoveButton:set_State()
        if C_CVar.GetCVarBool("autoInteract") then
            self:UnlockHighlight()
            self:SetAlpha(0.3)
        else
            self:LockHighlight()
            self:SetAlpha(1)
        end
    end

    ClickToMoveButton:SetScript('OnEvent', function(self, _, arg1)
        if arg1=='autoInteract' then
            self:set_State()
        end
    end)

    function ClickToMoveButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_PetBattleMixin.addName, WoWTools_PetBattleMixin.addName3)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(
            (UnitAffectingCombat('player') and '|cff9e9e9e' or '')
            ..WoWTools_PetBattleMixin.addName2
            ..': '
            ..e.GetEnabeleDisable(C_CVar.GetCVarBool("autoInteract")),

            e.Icon.left
        )

        e.tips:AddDoubleLine(
            e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL,

            e.Icon.right
        )

        if not Save().ClickMoveButton.PlayerFrame then
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(
                e.onlyChinese and '移动' or NPE_MOVE,
                'Alt+'..e.Icon.right
            )
        end

        e.tips:AddLine(' ')
        e.tips:AddLine(e.Get_CVar_Tooltips({name='autoInteract'}))
        e.tips:Show()
        self:SetAlpha(1)
    end
    ClickToMoveButton:SetScript('OnLeave', function(self) ResetCursor() e.tips:Hide() self:set_State() end)
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
        Save().ClickMoveButton.Point={self:GetPoint(1)}
        Save().ClickMoveButton.Point[2]=nil
    end)

    ClickToMoveButton:SetScript("OnMouseUp", ResetCursor)
    ClickToMoveButton:SetScript("OnMouseDown", function(self, d)
        if d=='LeftButton' then
            Set_ClickToMove_Cvar(nil, nil)
            self:CloseMenu()
        elseif d=='RightButton' and IsAltKeyDown() and not Save().ClickMoveButton.PlayerFrame then
            SetCursor('UI_MOVE_CURSOR')
        end
        self:set_tooltip()
    end)

    ClickToMoveButton:SetupMenu(Init_Menu)

    ClickToMoveButton:Settings()
end










function WoWTools_PetBattleMixin:ClickToMove_Button()
    Init_Button()
end

function WoWTools_PetBattleMixin:ClickToMove_CVar()
    Init_CVar()
end