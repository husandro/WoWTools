--生命条提示









--生命条提示
local function Init()--WoWTools_DataMixin:Hook(GameTooltipStatusBar, 'UpdateUnitHealth', function(tooltip)
    if WoWToolsSave['Plus_Tootips'].hideHealth then--12.0没有了
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
            or not unit
            or frame:GetWidth()<100
            or WoWTools_FrameMixin:IsLocked(frame)
        then
            frame.text:SetText('')
            frame.textLeft:SetText('')
            frame.textRight:SetText('')
            return
        end

        local value=UnitHealth(unit)
        local max= UnitHealthMax(unit)
        local r, g, b, left, right, col, text

        if value and max then
            r, g, b, col = GetClassColor(select(2, UnitClass(unit)))
            if UnitIsFeignDeath(unit) then
                text= WoWTools_DataMixin.onlyChinese and '假死' or BOOST2_HUNTERBEAST_FEIGNDEATH:match('|cFFFFFFFF(.+)|r') or NO..DEAD
            elseif not issecretvalue(value) then
                if value <= 0 then
                    text = '|A:poi-soulspiritghost:0:0|a'..'|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '死亡' or DEAD)..'|r'
                else
                    local hp = value / max * 100
                    text = ('%i%%'):format(hp)..'  '
                    if hp<30 then
                        text = '|A:GarrisonTroops-Health-Consume:0:0|a'..'|cnWARNING_FONT_COLOR:' .. text..'|r'
                    elseif hp<60 then
                        text='|cnGREEN_FONT_COLOR:'..text..'|r'
                    elseif hp<90 then
                        text='|cnYELLOW_FONT_COLOR:'..text..'|r'
                    else
                        text= '|c'..col..text..'|r'
                    end
                    left =WoWTools_DataMixin:MK(value, 2)
                end
            end
            right = WoWTools_DataMixin:MK(max, 2)
            frame:SetStatusBarColor(r or 1, g or 1, b or 1)
        end
        frame.text:SetText(text or '')
        frame.textLeft:SetText(left or value or '')
        frame.textRight:SetText(right or '')
        frame.textLeft:SetTextColor(r or 1, g or 1, b or 1)
        frame.textRight:SetTextColor(r or 1, g or 1, b or 1)
    end)

    WoWTools_TextureMixin:SetStatusBar(GameTooltipStatusBar)

    Init=function()end
end






function WoWTools_TooltipMixin:Init_StatusBar()
    Init()
end