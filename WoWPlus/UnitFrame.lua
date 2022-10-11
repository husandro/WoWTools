local id, e = ...
local addName=UNITFRAME_LABEL
local Save={}

PlayerCastingBarFrame:HookScript('OnShow', function()--CastingBarFrame.lua
    PlayerCastingBarFrame:SetFrameStrata('TOOLTIP')--设置施法条层
end)


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

--TextStatusBar.lua
--[[hooksecurefunc('TextStatusBar_UpdateTextStringWithValues', function(statusFrame, textString, value, valueMin, valueMax)
    if statusFrame.unit then
        local r, g, b=GetClassColor(UnitClassBase(statusFrame.unit))
        textString:SetTextColor(r, g, b);
        if statusFrame.LeftText and statusFrame.RightText then
            statusFrame.LeftText:SetTextColor(r, g, b);
            statusFrame.RightText:SetTextColor(r, g, b);
        end
    end
end)]]
--[[hooksecurefunc('HealthBar_OnValueChanged', function(self, value, smooth)
    if not value or not self.lockColor then
		return;
	end
    if self.unit then
        local r, g, b, hex=GetClassColor(UnitClassBase(self.unit))
        if r and g and b then
            self:SetStatusBarColor(r, g, b);
            return
        end
    end
end)]]
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