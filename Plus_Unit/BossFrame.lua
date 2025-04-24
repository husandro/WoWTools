


--#########
--BossFrame
--#########
local function Init()
    for i=1, MAX_BOSS_FRAMES do
        local frame= _G['Boss'..i..'TargetFrame']
        frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')--生命条，颜色，材质

        frame.BossButton= WoWTools_ButtonMixin:Cbtn(frame, {size=38, isSecure=true, isType2=true})--CreateFrame('Frame', nil, frame, 'SecureActionButtonTemplate')

        frame.BossButton:SetPoint('LEFT', frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer, 'RIGHT')

        frame.BossButton:SetAttribute('type', 'target')
        frame.BossButton:SetAttribute('unit', frame.unit)
        frame.BossButton:SetScript('OnLeave', GameTooltip_Hide)
        frame.BossButton:SetScript('OnEnter', function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, self);
            GameTooltip:ClearLines()
            GameTooltip:SetUnit(self.unit)
            GameTooltip:Show()
        end)

        frame.BossButton.Portrait= frame.BossButton:CreateTexture(nil, 'BACKGROUND')
        frame.BossButton.Portrait:SetAllPoints()

        frame.BossButton.targetTexture= frame.BossButton:CreateTexture(nil, 'OVERLAY')
        frame.BossButton.targetTexture:SetSize(52,52)
        frame.BossButton.targetTexture:SetPoint('CENTER')
        frame.BossButton.targetTexture:SetAtlas('DK-Blood-Rune-CDFill')

        frame.BossButton.unit= frame.unit

        function frame.BossButton:set_settings()
            local unit= BossTargetFrameContainer.isInEditMode and 'player' or self.unit
            local exists=UnitExists(unit)
            if exists then
                SetPortraitTexture(self.Portrait, unit)
            end
            self.Portrait:SetShown(exists)
            self.targetTexture:SetShown(exists and UnitIsUnit('target', unit))
            --颜色
            local r,g,b= select(2, WoWTools_UnitMixin:GetColor(unit))
            self:GetParent().healthbar:SetStatusBarColor(r,g,b)--颜色
        end

        function frame.BossButton:set_event()
            if not UnitExists(self.unit) then
                self:UnregisterAllEvents()
            else
                self:RegisterEvent('PLAYER_TARGET_CHANGED')
                self:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', self.unit)
                self:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT')
            end
            C_Timer.After(0.3, function() self:set_settings() end)
        end

        frame.BossButton:SetScript('OnEvent', function(self)
            self:set_settings()
        end)
        frame.BossButton:set_event()


        --队友，选中BOSS，数量
        --##############
        frame.numSelectFrame= CreateFrame('Frame', frame)
        frame.numSelectFrame.unit= frame.unit
        frame.numSelectFrame.Text= WoWTools_LabelMixin:Create(frame.BossButton, {color={r=1,g=1,b=1}, size=20})
        frame.numSelectFrame.Text:SetPoint('BOTTOM', 0, -16)
        function frame.numSelectFrame:set_event(f)
            if f:IsVisible() then
                self:RegisterEvent('UNIT_TARGET')
                if BossTargetFrameContainer.isInEditMode then
                    self.Text:SetText('40')
                else
                    self:settings()
                end
            else
                self:UnregisterEvent('UNIT_TARGET')
                self.Text:SetText('')
                self.isRun=nil
            end
        end
        function frame.numSelectFrame:settings()
            if self.isRun then
                return
            end
            self.isRun=true
            local n=0
            if IsInRaid() then
                for index=1, MAX_RAID_MEMBERS do
                    local unit= 'raid'..index
                    if UnitIsUnit(unit..'target', self.unit) and not UnitIsUnit(unit, 'player') then
                        n= n+1
                    end
                end
            elseif IsInGroup() then
                for index=1, GetNumGroupMembers()-1, 1 do
                    local unit= 'party'..index
                    if UnitIsUnit(unit..'target', self.unit) then
                        n= n+1
                    end
                end
            end
            self.Text:SetText(n>0 and n or '')
            self.isRun=nil
        end
        frame.numSelectFrame:SetScript('OnEvent', function(self, _, unit)
            if UnitIsPlayer(unit) and not UnitIsUnit(unit, 'player') then
                self:settings()
            end
        end)
        frame:HookScript('OnShow', function(self)
            self.numSelectFrame:set_event(self)
        end)
        frame:HookScript('OnHide', function(self)
            self.numSelectFrame:set_event(self)
        end)
        if frame:IsShown() then
            frame.numSelectFrame:set_event(frame)
        end

        --目标的目标，点击
        --##############
        frame.TotButton=WoWTools_ButtonMixin:Cbtn(frame, {size=38, isSecure=true, isType2=true})
        function frame.TotButton:set_point()
            if Boss1TargetFrameSpellBar.castBarOnSide then
                self:SetPoint('TOPLEFT', frame.TargetFrameContent.TargetFrameContentMain.ManaBar, 'BOTTOMLEFT')
            else
                self:SetPoint('RIGHT', frame.TargetFrameContent.TargetFrameContentMain.HealthBar, 'LEFT',-2,0)
            end
        end
        frame.TotButton:set_point()
        --frame.TotButton:SetPoint('TOPLEFT', frame.BossButton, 'TOPRIGHT', 4,0)
        frame.TotButton:SetAttribute('type', 'target')
        frame.TotButton:SetAttribute('unit', frame.unit..'target')
        frame.TotButton:SetScript('OnLeave', GameTooltip_Hide)
        frame.TotButton:SetScript('OnEnter', function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, self);
            GameTooltip:ClearLines()
            if UnitExists(self.targetUnit) then
                GameTooltip:SetUnit(self.targetUnit)
            else
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '目标的目标' or SHOW_TARGET_OF_TARGET_TEXT, self.targetUnit)
            end
            GameTooltip:Show()
        end)
        frame.TotButton.unit= frame.unit
        frame.TotButton.targetUnit= frame.unit..'target'

        --目标的目标，信息
        frame.TotButton.frame= CreateFrame('Frame', nil, frame.TotButton)
        frame.TotButton.frame:SetFrameLevel(frame.TotButton:GetFrameLevel()-1)
        frame.TotButton.frame:SetAllPoints()
        frame.TotButton.frame:Hide()
        frame.TotButton.frame.unit= frame.unit
        frame.TotButton.frame.targetUnit= frame.unit..'target'

        --目标的目标，图像
        frame.TotButton.frame.Portrait= frame.TotButton.frame:CreateTexture(nil, 'BACKGROUND')
        frame.TotButton.frame.Portrait:SetAllPoints()



        --目标的目标，外框
        frame.TotButton.frame.Border= frame.TotButton.frame:CreateTexture(nil, 'ARTWORK')
        frame.TotButton.frame.Border:SetSize(44,44)
        frame.TotButton.frame.Border:SetPoint('CENTER',2,-2)
        frame.TotButton.frame.Border:SetAtlas('UI-HUD-UnitFrame-TotemFrame')

        --目标的目标，百份比
        frame.TotButton.frame.healthLable= WoWTools_LabelMixin:Create(frame.TotButton.frame,{color={r=1,g=1,b=1}, size=14})
        frame.TotButton.frame.healthLable:SetPoint('BOTTOM')--, frame.TotButton.frame, 'RIGHT')

        frame.TotButton.frame:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= (self.elapsed or 0.3) +elapsed
            if self.elapsed>0.3 then
                local unit= BossTargetFrameContainer.isInEditMode and 'player' or self.targetUnit
                local text=''
                local value, max= UnitHealth(unit), UnitHealthMax(unit)
                value= (not value or value<=0) and 0 or value
                if value and max and max>0 then
                    local per= value/max*100
                    --self.healthBar:SetValue(per)
                    text= format('%0.f', per)
                end
                self.healthLable:SetText(text)
            end
        end)

        function frame.TotButton.frame:set_settings()
            local unit= BossTargetFrameContainer.isInEditMode and 'player' or self.targetUnit
            local exists=UnitExists(unit)
            if exists then
                --图像
                local isSelf= UnitIsUnit(unit, 'player')
                if BossTargetFrameContainer.isInEditMode then
                    SetPortraitTexture(self.Portrait, unit)
                elseif isSelf then--自已
                    self.Portrait:SetAtlas('auctionhouse-icon-favorite')
                elseif UnitIsUnit(unit, 'target') then
                    self.Portrait:SetAtlas('common-icon-checkmark')
                else
                    local index = GetRaidTargetIndex(unit)
                    if index and index>0 and index< 9 then
                        self.Portrait:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
                    else
                        SetPortraitTexture(self.Portrait, unit)--别人
                    end
                end

                --颜色
                local r,g,b= select(2, WoWTools_UnitMixin:GetColor(unit))
                --self.healthBar:SetStatusBarColor(r,g,b)
                --self.IsTargetTexture:SetShown(UnitIsUnit(self.targetUnit, 'target'))
                self.Border:SetVertexColor(r or 1, g or 1, b or 1)
                self.healthLable:SetTextColor(r or 1, g or 1, b or 1)
                WoWTools_FrameMixin:HelpFrame({frame=self, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, show=isSelf, y=-2})
            end
            self:SetShown(exists)
        end

        function frame.TotButton.frame:set_event()
            if not UnitExists(self.unit) then
                self:UnregisterAllEvents()
            else
                self:RegisterUnitEvent('UNIT_TARGET', self.unit)
                self:RegisterEvent('RAID_TARGET_UPDATE')
                self:RegisterEvent('PLAYER_TARGET_CHANGED')
            end
            self:set_settings()
        end

        frame.TotButton.frame:SetScript('OnEvent', function(self)
            self:set_settings()
        end)

        frame.TotButton.frame:set_event()


        frame:HookScript('OnShow', function(self)
            C_Timer.After(0.5, function()
                self.BossButton:set_event()
                self.TotButton.frame:set_event()
            end)
        end)
        frame:HookScript('OnHide', function(self)
            self.BossButton:set_event()
            self.TotButton.frame:set_event()
        end)

    end

    --设置位置
    local function set_TotButton_point()
        for i=1, MAX_BOSS_FRAMES do
            local frame= _G['Boss'..i..'TargetFrame']
            if frame.TotButton and frame.TotButton:CanChangeAttribute() then
                frame.TotButton:ClearAllPoints()
                frame.TotButton:set_point()
            end
        end
    end
    hooksecurefunc(Boss1TargetFrameSpellBar,'AdjustPosition', set_TotButton_point)
    hooksecurefunc(BossTargetFrameContainer, 'SetSmallSize', set_TotButton_point)








    Init=function()end
end




function WoWTools_UnitMixin:Init_BossFrame()--BOSS
    Init()
end