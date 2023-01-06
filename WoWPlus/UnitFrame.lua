local id, e = ...
local addName= UNITFRAME_LABEL
local Save={}



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

--######
--初始化
--######
local function Init()
    local R,G,B= GetClassColor(UnitClassBase('player'))

    --######
    --施法条
    --######
    local frame=PlayerCastingBarFrame
    if frame then
        frame:SetFrameStrata('TOOLTIP')--层

        frame.Portrait= frame:CreateTexture()--图标 SetPortraitTexture(self.Portrait, texture)
        local h= frame:GetHeight() * 2
        frame.Portrait:SetSize(h, h)
        frame.Portrait:SetPoint('TOPLEFT',frame.ChargeFlash,'TOPLEFT')
        frame.Portrait:SetDrawLayer('OVERLAY', 2)
        frame:HookScript('OnShow', function(self)
            local texture= select(3, UnitCastingInfo('player')) or select(3, UnitChannelInfo('player'))
            SetPortraitToTexture(self.Portrait, texture or 0)
        end)

        if frame.Text then--法术名称, 颜色
            frame.Text:SetTextColor(R,G,B)
        end

        frame.castingText=e.Cstr(frame, nil, nil, nil, {R,G,B}, nil, 'RIGHT')
        frame.castingText:SetDrawLayer('OVERLAY', 2)
        frame.castingText:SetPoint('RIGHT', frame.ChargeFlash, 'RIGHT')
        frame:HookScript('OnUpdate', function(self, elapsed)--玩家, 施法, 时间
            if self.maxValue and self.value then
                local value=self.maxValue-self.value
                if value>=3 then
                    self.castingText:SetFormattedText('%i', value)
                else
                    self.castingText:SetFormattedText('%.01f', value)
                end
            else
                self.castingText:SetText('')
            end
        end)
    end

    --#########
    --职业, 图标
    --#########
    --hooksecurefunc('UnitFrame_SetUnit', function(self, unit, healthbar, manabar)
    hooksecurefunc('UnitFrame_Update', function(self, isParty)
        local unit=self.overrideName or self.unit

        local r,g,b=GetClassColor(UnitClassBase(unit))

        self.name:SetTextColor(r,g,b)
        --self.healthbar:SetStatusBarColor(r, g, b)

        local class=e.Class(unit, nil, true)--职业, 图标
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

   --[[ hooksecurefunc('UnitFrameHealthBar_Update', function(statusbar, unit)
        if unit and statusbar then
            local r,g ,b = GetClassColor(UnitClassBase(unit))
            print(r,g,b, unit)
            if r and g and b then
                statusbar:SetStatusBarColor(r, g, b)
            end
        end
    end)]]
end

--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(e.onlyChinse and '单位框体' or addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if not Save.disabled then
                Init()
            end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
