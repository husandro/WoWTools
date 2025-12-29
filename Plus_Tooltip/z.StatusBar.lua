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
        local unit, guid= select(2, TooltipUtil.GetDisplayedUnit(GameTooltip))

        if WoWTools_FrameMixin:IsLocked(frame)
            or not issecretvalue(guid)
        then
            frame.text:SetText('')
            frame.textLeft:SetText('')
            frame.textRight:SetText('')
            return
        end

        local value= UnitHealth(unit)
        local max= UnitHealthMax(unit)
        local r, g, b, left, right, col, text

        r, g, b, col = GetClassColor(select(2, UnitClass(unit)))

        local isDeath= UnitIsFeignDeath(unit)
        if canaccessvalue(isDeath) and isDeath then
            text= WoWTools_DataMixin.onlyChinese and '假死' or BOOST2_HUNTERBEAST_FEIGNDEATH:match('|cFFFFFFFF(.+)|r') or NO..DEAD
        elseif canaccessvalue(value) and value then
            if value <= 0 then
                text = '|A:poi-soulspiritghost:0:0|a'..'|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '死亡' or DEAD)..'|r'
            elseif canaccessvalue(max) and max and max>0 then
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
            right = WoWTools_DataMixin:MK(max, 2)
        else
            left= value
            right= max
        end

        frame.text:SetText(text or '')
        frame.textLeft:SetText(left)
        frame.textRight:SetText(right)

        frame:SetStatusBarColor(r, g, b)
        frame.textLeft:SetTextColor(r, g, b)
        frame.textRight:SetTextColor(r , g, b)
    end)

    WoWTools_TextureMixin:SetStatusBar(GameTooltipStatusBar)

    Init=function()end
end






function WoWTools_TooltipMixin:Init_StatusBar()
    Init()
end