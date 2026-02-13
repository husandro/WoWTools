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
    GameTooltipStatusBar:HookScript("OnValueChanged", function(frame)
        local unit= select(2, TooltipUtil.GetDisplayedUnit(GameTooltip))

        if WoWTools_FrameMixin:IsLocked(frame)
            or not canaccessvalue(unit)
            or not unit
        then
            frame.text:SetText('')
            frame.textLeft:SetText('')
            frame.textRight:SetText('')
            return
        end

        local color= WoWTools_UnitMixin:GetColor(unit)
        local r, g, b = color:GetRGB()

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
        elseif canaccessvalue(value) and value then
            if value <= 0 then
                text = WARNING_FONT_COLOR:WrapTextInColorCode('|A:poi-soulspiritghost:0:0|a'..(WoWTools_DataMixin.onlyChinese and '死亡' or DEAD))

            elseif max and max>0 then
                local hp = value / max * 100
                text = format('%i%% ', hp)
                if hp<30 then
                    text=  WARNING_FONT_COLOR:WrapTextInColorCode('|A:GarrisonTroops-Health-Consume:0:0|a'..text)
                elseif hp<60 then
                    text= GREEN_FONT_COLOR:WrapTextInColorCode(text)
                elseif hp<90 then
                    text=YELLOW_FONT_COLOR:WrapTextInColorCode(text)
                else
                    text= HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(text)
                end
            end

            left= WoWTools_DataMixin:MK(value, 2)
            right= WoWTools_DataMixin:MK(max, 2)
        else
            left= value
            right= max
        end

        frame.text:SetText(text or '')
        frame.textLeft:SetText(left)
        frame.textRight:SetText(right)

        frame.textLeft:SetTextColor(r or 1, g or 1, b or 1)
        frame.textRight:SetTextColor(r or 1, g or 1, b or 1)
    end)



    Init=function()end
end






function WoWTools_TooltipMixin:Init_StatusBar()
    Init()
end