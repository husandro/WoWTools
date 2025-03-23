




local function Init()

    hooksecurefunc(EventTraceLogEventButtonMixin, 'OnEnter', function()
        EventTraceTooltip:AddLine(' ')
        EventTraceTooltip:AddDoubleLine(
            (WoWTools_Mixin.onlyChinese and '双倍' or BUFFER_DOUBLE)..WoWTools_DataMixin.Icon.left..'|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '搜索' or SEARCH),
            WoWTools_DataMixin.Icon.right..(WoWTools_Mixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
        )
        EventTraceTooltip:Show()
    end)

    WoWTools_TooltipMixin.AddOn.Blizzard_EventTrace=nil
end





function WoWTools_TooltipMixin.AddOn.Blizzard_EventTrace()
    Init()
end