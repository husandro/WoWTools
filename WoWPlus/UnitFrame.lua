local id, e = ...
local addName=UNITFRAME_LABEL
local Save={}

PlayerCastingBarFrame:HookScript('OnShow', function()--CastingBarFrame.lua
    PlayerCastingBarFrame:SetFrameStrata('TOOLTIP')--设置施法条层
end)

local GameTooltip_UnitColor_WoW=GameTooltip_UnitColor--单位框架颜色
function GameTooltip_UnitColor(unit)--GameTooltip.lua
    local r, g ,b  = GetClassColor(UnitClassBase(unit))
    if r and g and b then
        return r, g ,b
    else
        return GameTooltip_UnitColor_WoW(unit)
    end
end
--[[
hooksecurefunc('UnitFrame_SetUnit', function(self, unit, healthbar, manabar)
end)
]]

hooksecurefunc('UnitFrame_Update', function(self, isParty)--UnitFrame.lua    
    local unit=self.overrideName or self.unit
    local r,g,b=GetClassColor(UnitClassBase(unit))
    self.name:SetTextColor(r,g,b)
    local class=e.Class(unit, nil, true)
    if not self.class then
        self.class=self:CreateTexture()
        if unit=='target' or unit=='focus' then
            self.class:SetPoint('TOPLEFT', self.portrait, 'BOTTOMLEFT',0,5)
        else
            self.class:SetPoint('TOPRIGHT', self.portrait, 'BOTTOMRIGHT',0,5)
        end
        self.class:SetSize(20,20)
    end
    self.class:SetAtlas(class)
end)
--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save


    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)