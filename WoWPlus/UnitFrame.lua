local id, e = ...
local addName= UNITFRAME_LABEL
local Save={SetShadowOffset= 1}

local R,G,B= GetClassColor(UnitClassBase('player'))

local function set_SetShadowOffset(self)--设置字本, 阴影
    if self then
        self:SetShadowOffset(Save.SetShadowOffset, -(Save.SetShadowOffset))
    end
end

local function set_SetTextColor(self, r,g,b)--设置字本, 阴影
    if self and self:IsShown() and r and g and b then
        self:SetTextColor(r,g,b)
    end
end

--####
--玩家
--####
local function set_PlayerFrame()--PlayerFrame.lua
    hooksecurefunc('PlayerFrame_UpdateLevel', function()
        set_SetTextColor(PlayerLevelText, R,G,B)
    end)

    --set_SetShadowOffset(PlayerLevelText)
    --set_SetShadowOffset(PlayerName)


    --施法条
    local frame=PlayerCastingBarFrame
    frame:HookScript('OnShow', function(self)--图标
        self.Icon:SetShown(true)
    end)
    set_SetTextColor(frame.Text, R,G,B)--颜色
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

--####
--目标
--####
local function set_TargetFrame()
    hooksecurefunc(TargetFrame,'CheckLevel', function(self)--目标, 等级, 颜色
        local levelText = self.TargetFrameContent.TargetFrameContentMain.LevelText
        if levelText and levelText:IsShown() and self.unit then
            local classFilename= UnitClassBase(self.unit)
            if classFilename then
                local r,g,b=GetClassColor(classFilename)
                levelText:SetTextColor(r,g,b)
            end
        end
    end)
end

--####
--宠物
--####
local function set_PetFrame()
    if PetHitIndicator then
        PetHitIndicator:ClearAllPoints()
        PetHitIndicator:SetPoint('TOPLEFT', PetPortrait or PetHitIndicator:GetParent(), 'BOTTOMLEFT')
    end
    if PlayerHitIndicator then
        PlayerHitIndicator:ClearAllPoints()
        PlayerHitIndicator:SetPoint('BOTTOMLEFT', (PlayerFrame.PlayerFrameContainer and PlayerFrame and PlayerFrame.PlayerFrameContainer.PlayerPortrait) or  PlayerHitIndicator:GetParent(), 'TOPLEFT')
    end
end
--######
--初始化
--######
local function Init()
    set_PlayerFrame()--玩家
    set_TargetFrame()--目标
    set_PetFrame()--宠物

    --#########
    --职业, 图标
    --#########
    hooksecurefunc('UnitFrame_Update', function(self, isParty)--UnitFrame.lua
        local unit= self.overrideName or self.unit
        if not unit or not UnitExists(unit) then
            return
        end
        local r,g,b
        if unit=='player' then
            r,g,b= R,G,B
        else
            local classFilename= UnitClassBase(unit)
            if classFilename then
                r,g,b=GetClassColor(classFilename)
            end
        end
        self.name:SetTextColor(r,g,b)--名称, 颜色
        local class=e.Class(unit, nil, true)--职业, 图标
        if not self.classTexture then
            self.classTexture=self:CreateTexture()
            if unit=='target' or unit=='focus' then
                self.classTexture:SetPoint('TOPRIGHT', self.portrait, 'TOPLEFT',-12,12)
            else
                self.classTexture:SetPoint('TOPLEFT', self.portrait, 'TOPRIGHT',-12,12)
            end
            self.classTexture:SetSize(20,20)

            if self.healthbar then
                set_SetShadowOffset(self.healthbar.LeftText)--字本, 阴影
                set_SetShadowOffset(self.healthbar.CenterText)
                set_SetShadowOffset(self.healthbar.RightText)
            end
            if self.manabar then
                set_SetShadowOffset(self.manabar.LeftText)
                set_SetShadowOffset(self.manabar.CenterText)
                set_SetShadowOffset(self.manabar.RightText)
            end
            set_SetShadowOffset(self.name)
        end

        self.classTexture:SetAtlas(class)
        self.name:SetTextColor(r,g,b)

        if self.healthbar then
            set_SetTextColor(self.healthbar.LeftText, r,g,b)--字体, 颜色
            set_SetTextColor(self.healthbar.CenterText, r,g,b)
            set_SetTextColor(self.healthbar.RightText, r,g,b)
        end
        if self.manabar then
            set_SetTextColor(self.manabar.LeftText, r,g,b)
            set_SetTextColor(self.manabar.CenterText, r,g,b)
            set_SetTextColor(self.manabar.RightText, r,g,b)
        end
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
                Save.SetShadowOffset= Save.SetShadowOffset or 1
                Init()
            end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
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
