
--移动 ETRACE
WoWTools_MoveMixin.Events['Blizzard_EventTrace']= function()
    EventTrace.Log.Bar.SearchBox:SetPoint('LEFT', EventTrace.Log.Bar.Label, 'RIGHT')
    EventTrace.Log.Bar.SearchBox:SetScript('OnEditFocusGained', function(self)
        self:HighlightText()
    end)
    WoWTools_MoveMixin:Setup(EventTrace)
end












local function Init()
    EventTraceCloseButton:SetFrameLevel(EventTrace.TitleContainer:GetFrameLevel()+1)

    hooksecurefunc(EventTraceLogEventButtonMixin, 'OnEnter', function()
        EventTraceTooltip:AddLine(' ')
        EventTraceTooltip:AddLine(
            (WoWTools_Mixin.onlyChinese and '双击' or BUFFER_DOUBLE)
            ..WoWTools_DataMixin.Icon.left
            ..'|cnGREEN_FONT_COLOR:'
            ..(WoWTools_Mixin.onlyChinese and '搜索' or SEARCH)
            --WoWTools_DataMixin.Icon.right..(WoWTools_Mixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
        )
        EventTraceTooltip:Show()
    end)

    --[[hooksecurefunc(EventTraceLogEventButtonMixin, 'Init', function(self, elementData, showArguments, showTimestamp)
       -- info= elementData
       -- for k, v in pairs(info or {}) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR') for k2,v2 in pairs(v) do print(k2,v2) end print('|cffff0000---',k, '---END') else print(k,v) end end print('|cffff00ff——————————')
    end)

    hooksecurefunc(EventTraceLogEventButtonMixin, 'OnLoad', function(self)
        self:HookScript('OnMouseDown', Set_OnMouseDown)
    end)]]
    
    return true
end


function WoWTools_HyperLink:Blizzard_EventTrace()
    if C_AddOns.IsAddOnLoaded('Blizzard_EventTrace') and Init() then
        Init=function()end
    end
end