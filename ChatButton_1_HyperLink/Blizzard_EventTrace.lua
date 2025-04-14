local function Save()
    return WoWToolsSave['ChatButton_HyperLink']
end







--移动 ETRACE
WoWTools_MoveMixin.Events['Blizzard_EventTrace']= function()
    EventTrace.Log.Bar.SearchBox:SetPoint('LEFT', EventTrace.Log.Bar.Label, 'RIGHT')
    EventTrace.Log.Bar.SearchBox:SetScript('OnEditFocusGained', function(self)
        self:HighlightText()
    end)
    WoWTools_MoveMixin:Setup(EventTrace)
end











--Plus
local function Init()
    if not C_AddOns.IsAddOnLoaded('Blizzard_EventTrace') then
        return
    end

    EventTraceCloseButton:SetFrameLevel(EventTrace.TitleContainer:GetFrameLevel()+1)

    hooksecurefunc(EventTraceLogEventButtonMixin, 'OnEnter', function()
        EventTraceTooltip:AddLine(' ')
        EventTraceTooltip:AddLine(
            (WoWTools_DataMixin.onlyChinese and '双击' or BUFFER_DOUBLE)
            ..WoWTools_DataMixin.Icon.left
            ..'|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '搜索' or SEARCH)
            --WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
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
    Init=function()end
end










local Frame
local EventTabs={}
local index=1

local function Init_EventTrace_Print()
    if not Save().eventTracePrint then
        return
    end


    Frame= CreateFrame('Frame')
    function Frame:set_event()
        if Save().eventTracePrint then
            self:RegisterAllEvents()
        else
            self:UnregisterAllEvents()
        end
        EventTabs={}
        index=1
    end

    Frame:SetScript('OnEvent', function(_, event, arg1, ...)
        if not EventTabs[event] then
            arg= arg1 and {[arg1]=1} or {}
            index= index+1

            EventTabs[event]={
                index=index,
                num=1,
                arg= arg1 and {[arg1]=1} or {},
            }

            print(
                (select(2, math.modf((index-1)/2))==0 and '|cff10d3c8' or '|cffd3a21b')..index..')',
                event..'|r',
                arg1 or '',
                ...
            )
        else
            if arg1 then
                EventTabs[event].arg[arg1]= (EventTabs[event].arg[arg1] or 0)+1
                EventTabs[event].num= EventTabs[event].num+1
            end
        end
    end)

    Frame:set_event()

    Init_EventTrace_Print= function()
        Frame:set_event()
    end
end











function WoWTools_HyperLink:Blizzard_EventTrace()
    Init()
end

function WoWTools_HyperLink:Init_EventTrace_Print()
    Init_EventTrace_Print()
end

function WoWTools_HyperLink:Get_EventTrace_Print_Tab()
    return EventTabs
end
