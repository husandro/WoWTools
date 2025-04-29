--BossFrame
--EditModeManagerFrame:IsEditModeActive()





--Boss图标，按钮
local function Create_BossButton(frame)
    frame.BossButton= WoWTools_ButtonMixin:Cbtn(frame,{
        size=38,
        isSecure=true,
        isType2=true,
        notBorder=true,
        notTexture=true,
    })
    frame.BossButton.unit= frame.unit
    frame.BossButton:SetPoint('LEFT', frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer, 'RIGHT')

    frame.BossButton:SetAttribute('type', 'target')
    frame.BossButton:SetAttribute('unit', frame.unit)

    frame.BossButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    frame.BossButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
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


    function frame.BossButton:settings()
        local unit= BossTargetFrameContainer.isInEditMode and 'player' or self.unit
        SetPortraitTexture(self.Portrait, unit)
        self.targetTexture:SetShown(UnitIsUnit('target', unit))
    end


    frame.BossButton:SetScript('OnEvent', function(self)
        self:settings()
    end)

    frame.BossButton:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.Portrait:SetTexture(0)
    end)

    frame.BossButton:SetScript('OnShow', function(self)
        self:RegisterEvent('PLAYER_TARGET_CHANGED')
        self:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', self.unit)
        self:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT')
--颜色
        local r,g,b= select(2, WoWTools_UnitMixin:GetColor(UnitExists(self.unit) and self.unit or 'player'))
        local p= self:GetParent()
        p.healthbar:SetStatusBarColor(r,g,b)--颜色
        p.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetVertexColor(r,g,b)

        self:settings()
    end)

end




















--队友，选中BOSS，数量
local function Create_numSelectFrame(frame)

    local Frame= CreateFrame('Frame', frame)
    Frame:SetPoint('BOTTOMRIGHT', frame.BossButton, 2, -2)
    Frame:SetSize(1,1)
    Frame:SetFrameStrata('HIGH')

    Frame.unit= frame.unit

    Frame.Text= WoWTools_LabelMixin:Create(Frame, {
        color={r=1,g=1,b=1},
        size=12
    })
    Frame.Text:SetPoint('BOTTOM')

    Frame.Text:EnableMouse(true)
    Frame.Text:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    Frame.Text:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(
            WoWTools_DataMixin.onlyChinese and '队友选中目标数量'
            or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, TARGET)
        )
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)

    Frame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) +elapsed
        if self.elapsed<=0.3 then
            return
        end
        self.elapsed= 0

        local n=0
        local unit
        if IsInRaid() then
            for index=1, MAX_RAID_MEMBERS do
                unit= 'raid'..index
                if UnitIsUnit(unit..'target', self.unit)  then
                    n= n+1
                end
            end
        elseif IsInGroup() then
            for index=1, GetNumGroupMembers()-1, 1 do
                if UnitIsUnit('party'..index..'target', self.unit) then
                    n= n+1
                end
            end
            if UnitIsUnit('target', self.unit) then
                n=n+1
            end
        end
        self.Text:SetText(n)
    end)

    Frame:SetScript('OnHide', function(self)
        self.elapsed=nil
        self.Text:SetText("")
    end)
end




















--目标的目标，点击
local function Create_TotButton(frame)

    frame.TotButton=WoWTools_ButtonMixin:Cbtn(frame, {
        size=38,
        isSecure=true,
        isType2=true,
        notBorder=true,
        notTexture=true,
    })

    function frame.TotButton:set_point()
        if Boss1TargetFrameSpellBar.castBarOnSide then
            self:SetPoint('TOPLEFT', frame.TargetFrameContent.TargetFrameContentMain.ManaBar, 'BOTTOMLEFT')
        else
            self:SetPoint('RIGHT', frame.TargetFrameContent.TargetFrameContentMain.HealthBar, 'LEFT',-2,0)
        end
    end
    frame.TotButton:SetScript('OnEvent', function(self, event)
        self:set_point()
        self:UnregisterEvent(event)
    end)
    frame.TotButton:set_point()

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
        if self.elapsed<=0.3 then
            return
        end
        self.elapsed= 0

        local unit= BossTargetFrameContainer.isInEditMode and 'player' or self.targetUnit
        local text=''
        local value, max= UnitHealth(unit), UnitHealthMax(unit)
        value= (not value or value<=0) and 0 or value
        if value and max and max>0 then
            local per= value/max*100
            text= format('%0.f', per)
        end
        self.healthLable:SetText(text)
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
            self.Border:SetVertexColor(r or 1, g or 1, b or 1)
            self.healthLable:SetTextColor(r or 1, g or 1, b or 1)
            WoWTools_FrameMixin:HelpFrame({frame=self, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, show=isSelf, y=-2})
        else
            self.Portrait:SetTexture(0)
            self.elapsed=nil
        end
        self:SetShown(exists)
    end



    frame.TotButton.frame:SetScript('OnEvent', function(self)
        self:set_settings()
    end)

    frame.TotButton.frame:HookScript('OnShow', function(self)
        self:RegisterUnitEvent('UNIT_TARGET', self.unit)
        self:RegisterEvent('RAID_TARGET_UPDATE')
        self:RegisterEvent('PLAYER_TARGET_CHANGED')
        self:set_settings()
    end)
    frame.TotButton.frame:HookScript('OnHide', function(self)
       self:UnregisterAllEvents()
    end)
end






















local function Init()
    if WoWToolsSave['Plus_UnitFrame'].hideBossFrame then
        return
    end


    for i=1, MAX_BOSS_FRAMES do
        local frame= _G['Boss'..i..'TargetFrame']
        if frame then
            frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')--生命条，颜色，材质
            do
                Create_BossButton(frame)--Boss图标，按钮
            end
            Create_numSelectFrame(frame)--队友，选中BOSS，数量
            Create_TotButton(frame)--目标的目标，点击
        end
    end









--设置位置
    local function set_TotButton_point()
        for i=1, MAX_BOSS_FRAMES do
            local frame= _G['Boss'..i..'TargetFrame']
            if frame and frame.TotButton then
                if InCombatLockdown() then
                    frame.TotButton:UnregisterEvent('PLAYER_REGEN_ENABLED')
                else
                    frame.TotButton:ClearAllPoints()
                    frame.TotButton:set_point()
                end
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