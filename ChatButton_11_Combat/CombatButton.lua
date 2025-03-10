local e= select(2, ...)
local function Save()
    return WoWTools_CombatMixin.Save
end







local function Init(btn)
    
    btn.texture2=btn:CreateTexture(nil, 'OVERLAY')
    btn.texture2:SetAllPoints(btn)
    btn.texture2:AddMaskTexture(btn.mask)
    btn.texture2:SetColorTexture(1,0,0)
    btn.texture2:SetShown(false)

    function btn:set_texture()
        self.texture:SetAtlas(e.Icon[e.Player.faction] or e.Icon['Neutral'])
        self.texture:SetDesaturated(Save().disabledText and true or false)--禁用/启用 TrackButton, 提示
    end

   

    function btn:set_Sacle_InCombat(bat)--提示，战斗中
        self.texture2:SetShown(bat)
        if Save().combatScale then
            self:SetScale(bat and Save().inCombatScale or 1)
        end
    end

    function btn:set_Click()
        Save().disabledText = not Save().disabledText and true or nil
        self:set_texture()
        WoWTools_CombatMixin:Init_TrackButton()
    end

    function btn:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        WoWTools_CombatMixin:Set_Combat_Tooltip(e.tips)
        e.tips:Show()
    end

    WoWTools_CombatMixin:Init_SetupMenu()

    function btn:HandlesGlobalMouseEvent(_, event)
        return event == "GLOBAL_MOUSE_DOWN"-- and buttonName == "RightButton";
    end


    function btn:set_OnLeave()
        WoWTools_CombatMixin:Set_Button_State()
    end

    function btn:set_OnEnter()
        WoWTools_CombatMixin:Set_Button_State()
    end




    btn:RegisterEvent('PLAYER_REGEN_DISABLED')
    btn:RegisterEvent('PLAYER_REGEN_ENABLED')
    btn:RegisterEvent('PLAYER_ENTERING_WORLD')
    btn:RegisterEvent('NEUTRAL_FACTION_SELECT_RESULT')

    btn:SetScript("OnEvent", function(self, event)--提示，战斗中, 是否在战场
        if event=='PLAYER_REGEN_ENABLED' then
            self:set_Sacle_InCombat(false)--提示，战斗中
        elseif event=='PLAYER_REGEN_DISABLED' then
            self:set_Sacle_InCombat(true)
        elseif event=='NEUTRAL_FACTION_SELECT_RESULT' then
            self:set_texture()
        end
    end)

    btn:set_Sacle_InCombat(UnitAffectingCombat('player'))--提示，战斗中  
    btn:set_texture()
end








function WoWTools_CombatMixin:Init_Button()
    Init(self.CombatButton)
end


function WoWTools_CombatMixin:Set_Button_State()
    if GameTooltip:IsOwned(self.TrackButton) or GameTooltip:IsOwned(self.CombatButton) then
        self.TrackButton:SetButtonState('PUSHED')
        self.CombatButton:SetButtonState('PUSHED')
    else
        self.TrackButton:SetButtonState('NORMAL')
        self.CombatButton:SetButtonState('NORMAL')
    end
end