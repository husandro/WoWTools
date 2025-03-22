local e= select(2, ...)
local function Save()
    return WoWTools_MoveMixin.Save
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
    if self and self:IsShown() and self.setMoveFrame then
        WoWTools_MoveMixin:SetPoint(self)
    end
end






local function Init()--职业，能量条
    for _, name in pairs(Frames) do
        local frame= _G[name]
        if frame then
            WoWTools_MoveMixin:Setup(frame, {
                notFuori=true,
                save=true,
                notMoveAlpha=true,
                alpha=0,
                click='LeftButton',
                restPointFunc=function(btn)
                    Save().scale[btn.name]=nil
                    if btn.targetFrame:CanChangeAttribute() then
                        btn.targetFrame:SetScale(1)
                        WoWTools_Mixin:Call(PlayerFrame_UpdateArt, PlayerFrame)
                    end
                end
            })

            if frame.setMoveFrame then
                if frame.Update then--TotemFrame.lua
                    hooksecurefunc(frame, 'Update', Set_Func_Point)
                end
                if frame.Setup then
                    hooksecurefunc(frame, 'Setup', Set_Func_Point)
                end
            end
        end
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


    if TotemFrame and TotemFrame.setMoveFrame then--SM
        for btn in TotemFrame.totemPool:EnumerateActive() do
            WoWTools_MoveMixin:Setup(btn, {frame=TotemFrame, click='LeftButton'})
        end
        hooksecurefunc(TotemButtonMixin, 'OnLoad', function(self)
            WoWTools_MoveMixin:Setup(self, {frame=TotemFrame, click='LeftButton'})
        end)
    end
end






function WoWTools_MoveMixin:Init_Class_Power()
    Init()
end



