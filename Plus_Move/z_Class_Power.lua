--职业，能量条
local e= select(2, ...)
local function Save()
    return WoWTools_MoveMixin.Save
end







local function Set_Class_Frame(frame, click)
    if not frame then
        return
    end
    do
        WoWTools_MoveMixin:Setup(frame, {notFuori=true,
            save=true,
            notMoveAlpha=true,
            alpha=0,
            click=click,
        restPointFunc=function(btn)
            Save().scale[btn.name]=nil
            if not UnitAffectingCombat('player') then
                btn.target:SetScale(1)
                e.call(PlayerFrame_UpdateArt, PlayerFrame)
            end
        end})
    end
    if frame.setMoveFrame then
        if Save().point[frame:GetName()] then
            frame:SetParent(UIParent)
        end
        hooksecurefunc('PlayerFrame_ToPlayerArt', function()
            C_Timer.After(0.8, function() WoWTools_MoveMixin:SetPoint(frame) end)
        end)
        if frame.Setup then
            hooksecurefunc(frame, 'Setup', function(self)
                if self:IsShown() then
                    WoWTools_MoveMixin:SetPoint(self)
                end
            end)
        end

        local f= CreateFrame('Frame')
        f:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
        f:RegisterUnitEvent('UNIT_DISPLAYPOWER', "player")
        f.frame= frame
        f:SetScript('OnEvent', function(self)
            if self.frame:IsShown() then
                WoWTools_MoveMixin:SetPoint(self.frame)
            end
        end)
    end
end









local function Init()--职业，能量条
    local frame--PlayerFrame.classPowerBar
    local click
    if e.Player.class=='MAGE' then--法师
        frame= MageArcaneChargesFrame

    elseif e.Player.class=='MONK' then--MonkHarmonyBarFrame
        frame= MonkHarmonyBarFrame

    elseif e.Player.class=='DEATHKNIGHT' then--RuneFrame        
        frame= RuneFrame

    elseif e.Player.class=='EVOKER' then
        frame= EssencePlayerFrame

    elseif e.Player.class=='PALADIN' then--QS 
        frame= PaladinPowerBarFrame

    elseif e.Player.class=='DRUID' then--XD
        frame= DruidComboPointBarFrame

    elseif e.Player.class=='ROGUE' then--DZ
        frame= RogueComboPointBarFrame

    elseif e.Player.class=='WARLOCK' then--SS
        frame= WarlockPowerFrame

    elseif e.Player.class=='SHAMAN' then--SM
        frame= TotemFrame
        click= 'LeftButton'

        --Blizzard_UnitFrame/TotemFrame.lua
        hooksecurefunc(TotemFrame, 'Update', function(self)
            WoWTools_MoveMixin:SetPoint(self)
        end)
        --[[hooksecurefunc('PlayerFrame_AdjustAttachments', function(self)
            WoWTools_MoveMixin:SetPoint(TotemFrame)
        end)]]
        for btn in TotemFrame.totemPool:EnumerateActive() do
            WoWTools_MoveMixin:Setup(btn, {frame=TotemFrame, click='LeftButton'})
        end
        hooksecurefunc(TotemButtonMixin, 'OnLoad', function(self)
            WoWTools_MoveMixin:Setup(self, {frame=TotemFrame, click='LeftButton'})
        end)
        --[[local texture= WoWTools_TextureMixin:CreateBackground(frame, {isAllPoint=true, alpha=0})
        if texture then
            frame:HookScript('OnEnter', function(self)
                self.Background:SetAlpha(0.5)
            end)
            frame:HookScript('OnLeave', function(self)
                self.Background:SetAlpha(0)
            end)
        end]]
    end
    Set_Class_Frame(frame, click)
end




function WoWTools_MoveMixin:Init_Class_Power()
    Init()
end
