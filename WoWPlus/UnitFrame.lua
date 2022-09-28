local id, e = ...
PlayerCastingBarFrame:HookScript('OnShow', function()--CastingBarFrame.lua
    PlayerCastingBarFrame:SetFrameStrata('TOOLTIP')--设置施法条层
end)