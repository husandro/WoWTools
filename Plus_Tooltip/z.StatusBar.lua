--生命条提示









--生命条提示
local function Init()--WoWTools_DataMixin:Hook(GameTooltipStatusBar, 'UpdateUnitHealth', function(tooltip)
    if WoWToolsSave['Plus_Tootips'].hideHealth then
        return
    end

    GameTooltipStatusBar.text= WoWTools_LabelMixin:Create(GameTooltipStatusBar, {justifyH='CENTER'})
    GameTooltipStatusBar.text:SetPoint('TOP', GameTooltipStatusBar, 'BOTTOM')--生命条
    GameTooltipStatusBar.textLeft = WoWTools_LabelMixin:Create(GameTooltipStatusBar, {justifyH='LEFT'})
    GameTooltipStatusBar.textLeft:SetPoint('TOPLEFT', GameTooltipStatusBar, 'BOTTOMLEFT')--生命条
    GameTooltipStatusBar.textRight = WoWTools_LabelMixin:Create(GameTooltipStatusBar, {size=18, justifyH='RIGHT'})
    GameTooltipStatusBar.textRight:SetPoint('TOPRIGHT',0, -2)--生命条
    GameTooltipStatusBar:HookScript("OnValueChanged", function(self)
        local unit= select(2, TooltipUtil.GetDisplayedUnit(GameTooltip))
        if WoWTools_FrameMixin:IsLocked(self)
            or not canaccessvalue(unit)
            or not unit
        then
            self.text:SetText('')
            self.textLeft:SetText('')
            self.textRight:SetText('')
            return
        end

        local color= WoWTools_UnitMixin:GetColor(unit)


        local left, right, text
        local value= UnitHealth(unit)
        local max= UnitHealthMax(unit)
        local isDeath= UnitIsFeignDeath(unit)

        if canaccessvalue(isDeath) and isDeath then
            if WoWTools_DataMixin.onlyChinese then
                text= '假死'
            else
                WoWTools_DataMixin:Load(5384, 'spell')
                text= C_Spell.GetSpellName(5384) or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NO, DEAD)
            end
        else
            text= format('%i%%', UnitHealthPercent(unit, true, CurveConstants.ScaleTo100))
        end

        self.text:SetText(text)
        self.textLeft:SetText(left or value)
        self.textRight:SetText(right or max)

        self.text:SetTextColor(color:GetRGB())
        self.textLeft:SetTextColor(color:GetRGB())
        self.textRight:SetTextColor(color:GetRGB())
        self:SetStatusBarColor(color:GetRGB())
    end)



    Init=function()end
end






function WoWTools_TooltipMixin:Init_StatusBar()
    Init()
end