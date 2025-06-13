
local function Save()
    return WoWToolsSave['Plus_Move']
end
--职业，能量条
--Blizzard_UnitFrame



local Frames={
    'MageArcaneChargesFrame',--MAGE FS
    'MonkHarmonyBarFrame',--MONK WS
    'RuneFrame',--DEATHKNIGHT DK
    'EssencePlayerFrame',--EVOKER
    'PaladinPowerBarFrame',--PALADIN QS
    'DruidComboPointBarFrame',--DRUID XD
    'RogueComboPointBarFrame',--ROGUE DZ
    'WarlockPowerFrame',--WARLOCK SS
    'TotemFrame',--SHAMAN SM
}



local function Set_Func_Point(self)
    if self and self:IsShown() and self.moveFrameData then
        WoWTools_MoveMixin:SetPoint(self)
    end
end



local function Setup_Frame(name)
    local frame= _G[name]
    if not frame then
        return
    end

    WoWTools_MoveMixin:Setup(frame, {
        notFuori=true,
        save=true,
        notMoveAlpha=true,
        alpha=0,
        click='LeftButton',
        restPointFunc=function(btn)
            Save().scale[btn.name]=nil
            if frame:CanChangeAttribute() then
                frame:SetScale(1)
                WoWTools_Mixin:Call(PlayerFrame_UpdateArt, PlayerFrame)
            end
        end
    })

    if frame.moveFrameData then
        if frame.Update then--TotemFrame.lua
            hooksecurefunc(frame, 'Update', function(...)
                Set_Func_Point(...)
            end)
        end
        if frame.Setup then
            hooksecurefunc(frame, 'Setup', function(...)
                Set_Func_Point(...)
            end)
        end
    end
end


local function Init()--职业，能量条
    for _, name in pairs(Frames) do
        Setup_Frame(name)
    end


    hooksecurefunc('PlayerFrame_AdjustAttachments', function()
        for _, name in pairs(Frames) do
            Set_Func_Point(_G[name])
        end
    end)
    hooksecurefunc('PlayerFrame_UpdateArt', function()
        C_Timer.After(0.5, function()
            for _, name in pairs(Frames) do
                Set_Func_Point(_G[name])
            end
        end)
    end)


    if TotemFrame and TotemFrame.moveFrameData then--SM
        for btn in TotemFrame.totemPool:EnumerateActive() do
            WoWTools_MoveMixin:Setup(btn, {frame=TotemFrame, click='LeftButton'})
        end
        hooksecurefunc(TotemButtonMixin, 'OnLoad', function(self)
            WoWTools_MoveMixin:Setup(self, {frame=TotemFrame, click='LeftButton'})
        end)
    end

    Init=function()end
end






function WoWTools_MoveMixin:Init_Class_Power()
    Init()
end



