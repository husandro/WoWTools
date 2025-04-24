--施法条 CastingBarFrame.lua









local function Create_CastTimeTexte(frame)
    if frame.CastTimeText then
        return
    end

    frame.CastTimeText= WoWTools_LabelMixin:Create(frame, {size=14, color={r=1, g=1, b=1}, justifyH='RIGHT'})
    frame.CastTimeText:SetPoint('RIGHT', frame)

    if frame.UpdateCastTimeText then
        return
    end

    frame:HookScript('OnUpdate', function(self, elapsed)--玩家, 施法, 时间
        self.elapsed= (self.elapsed or 0.1) + elapsed
        if self.elapsed>=0.1 and self.value and self.maxValue then
            self.elapsed=0
            local value= self.channeling and self.value or (self.maxValue-self.value)
            if value<=0 then
                self.CastTimeText:SetText(0)
            elseif value>=3 then
                self.CastTimeText:SetFormattedText('%i', value)
            else
                self.CastTimeText:SetFormattedText('%.01f', value)
            end
        end
    end)
end













local function Settings(frame)
    frame.Icon:EnableMouse(true)
    frame.Icon:SetScript('OnEnter', function(self)
        local unit= self:GetParent().unit or 'player'
        local spellID= select(9, UnitCastingInfo(unit)) or select(8, UnitChannelInfo(unit)) or 0
        if spellID==0 then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(spellID)
        GameTooltip:Show()
    end)
    frame:HookScript('OnShow', function(self)--图标
        self.Icon:SetShown(true)
    end)

    --WoWTools_ColorMixin:Setup(frame.CastTimeText, {type='FontString'})--设置颜色    
    if not frame.CastTimeText then
        Create_CastTimeTexte(frame)
    else
        frame.CastTimeText:SetShadowOffset(1, -1)
        if frame.ChargeFlash then
            frame.CastTimeText:ClearAllPoints()
            frame.CastTimeText:SetPoint('RIGHT', frame.ChargeFlash, 'RIGHT')
        end
    end
    --WoWTools_ColorMixin:Setup(frame.Text, {type='FontString'})--设置颜色
    frame.Text:SetTextColor(1, 0.82, 0, 1)
    frame.Text:SetShadowOffset(1, -1)

    if frame==PlayerCastingBarFrame then
        frame:HookScript('OnShow', function(self)
            self:SetFrameStrata('TOOLTIP')
            self:SetFrameLevel('10000')
        end)
    end
    if frame.UpdateCastTimeText then
        hooksecurefunc(frame, 'UpdateCastTimeText', function(self)--去掉 秒
            local text= self.CastTimeText:GetText()
            text= text:match('(%d+.%d)') or text
            text= text=='0.0' and '' or text
            self.CastTimeText:SetText(text)
            if self~=PlayerCastingBarFrame then
                self.CastTimeText:SetShown(true)
            end
        end)
    end
end











--MirrorTimer.lua
local function SetupTimer(frame)
    for _, activeTimer in pairs(frame.activeTimers) do
        if not activeTimer.valueText then
            activeTimer.valueText=WoWTools_LabelMixin:Create(activeTimer, {justifyH='RIGHT'})
            activeTimer.valueText:SetPoint('BOTTOMRIGHT',-7, 4)

            WoWTools_ColorMixin:Setup(activeTimer.valueText, {type='FontString'})--设置颜色
            WoWTools_ColorMixin:Setup(activeTimer.Text, {type='FontString'})--设置颜色

            hooksecurefunc(activeTimer, 'UpdateStatusBarValue', function(self)
                self.valueText:SetText(format('%i', self.StatusBar:GetValue()))
            end)
        end
    end
end








local function Init()
    if WoWToolsSave['Plus_UnitFrame'].hideCastingFrame then
        return
    end

    Settings(PlayerCastingBarFrame)
    Settings(PetCastingBarFrame)
    Settings(OverlayPlayerCastingBarFrame)
    Settings(TargetFrameSpellBar)

    hooksecurefunc(MirrorTimerContainer, 'SetupTimer', SetupTimer)

    Init=function()end
end


function WoWTools_UnitMixin:Init_CastingBar()
   Init()
end