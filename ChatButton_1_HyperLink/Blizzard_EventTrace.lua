local function Save()
    return WoWToolsSave['ChatButton_HyperLink']
end





function WoWTools_TextureMixin.Events:Blizzard_EventTrace()
    local function set_button(btn)
        if btn then
            self:SetAlphaColor(btn.NormalTexture, nil, nil, true)
            if btn.MouseoverOverlay then
                btn.MouseoverOverlay:SetTexCoord(0,1,0.8,0)
            end
        end
    end

    self:SetNineSlice(EventTrace, true)
    self:SetAlphaColor(EventTraceBg, nil, nil, true)
    self:SetAlphaColor(EventTraceInset.Bg, nil, nil, true)
    self:SetNineSlice(EventTraceInset, true)
    self:SetButton(EventTrace.ResizeButton, {all=true, alpha=0.5})
    self:SetScrollBar(EventTrace.Log.Events)
    self:SetSearchBox(EventTrace.Log.Bar.SearchBox)

    set_button(EventTrace.SubtitleBar.ViewLog)
    set_button(EventTrace.SubtitleBar.ViewFilter)

    set_button(EventTrace.Log.Bar.DiscardAllButton)
    set_button(EventTrace.Log.Bar.PlaybackButton)
    set_button(EventTrace.Log.Bar.MarkButton)

    set_button(EventTrace.Filter.Bar.DiscardAllButton)
    set_button(EventTrace.Filter.Bar.UncheckAllButton)
    set_button(EventTrace.Filter.Bar.CheckAllButton)

    self:SetFrame(EventTrace.Log.Events.ScrollBox, {index=1, isMinAlpha=true})
    self:SetFrame(EventTrace.Filter.ScrollBox, {index=1, isMinAlpha=true})

    hooksecurefunc(EventTraceLogEventButtonMixin, 'OnLoad', function(frame)
        self:SetButton(frame.HideButton, {all=true})
        local icon= frame:GetRegions()
        if icon:GetObjectType()=='Texture' then
            icon:SetTexture(0)
        end
        --frame.Alternate:SetAlpha(0.75)
    end)
    hooksecurefunc(EventTraceFilterButtonMixin, 'Init', function(frame, elementData, hideCb)
        local icon= frame:GetRegions()
        if icon:GetObjectType()=='Texture' then
            icon:SetTexture(0)
        end
    end)
end



--移动 ETRACE
function WoWTools_MoveMixin.Events:Blizzard_EventTrace()
    EventTrace.Log.Bar.SearchBox:SetPoint('LEFT', EventTrace.Log.Bar.Label, 'RIGHT')
    EventTrace.Log.Bar.SearchBox:SetScript('OnEditFocusGained', function(frame)
        frame:HighlightText()
    end)
    self:Setup(EventTrace)
end


















local Frame
local EventTabs={}
local EditBox, ReLeftList





--点击，事件
local ArgumentColors =
{
    ["string"] = GREEN_FONT_COLOR,
    ["number"] = ORANGE_FONT_COLOR,
    ["boolean"] = BRIGHTBLUE_FONT_COLOR,
    ["table"] = LIGHTYELLOW_FONT_COLOR,
    ["nil"] = GRAY_FONT_COLOR,
}
local function GetDisplayEvent(elementData)
    if elementData then
        return elementData.displayEvent or elementData.event
    end
end

local function GetArgumentColor(arg)
    return ArgumentColors[type(arg)] or HIGHLIGHT_FONT_COLOR
end
local function FormatArgument(arg)
    local color = GetArgumentColor(arg)
    local t = type(arg)
    if t == "string" then
        return color:WrapTextInColorCode(string.format('"%s"', arg))
        
    elseif t == "nil" then
        return color:WrapTextInColorCode(t)

    elseif t== 'table' then
        local a
        for k, v in pairs(arg) do
            if type(v)=='table' then
                a= (a and a..' ' or '').. tostring(k)..'={'
                for k2,v2 in pairs(v) do
                    a= (a and a..' ' or '').. tostring(k2)..'='..tostring(v2)
                end
                a=a..'}'
            else
                a= (a and a..' ' or '').. tostring(k)..'='..tostring(v)
            end
        end

        return color:WrapTextInColorCode(a or '')
    end

    return color:WrapTextInColorCode(tostring(arg))
end

local function AddTooltipArguments(...)
    local text
    local count = select("#", ...)
    for index = 1, count do
        local arg = select(index, ...)
        text= (text and text..' ' or '')..FormatArgument(arg)
    end
    return text
end

























--左边列表
local function Init_LeftList()
    ReLeftList= WoWTools_ButtonMixin:Cbtn(EditBox, {size=23, atlas='128-RedButton-Delete-Disabled'})
    ReLeftList:SetPoint('RIGHT', EditBox, 'LEFT', -2, 0)
    ReLeftList:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetNormalAtlas('128-RedButton-Delete-Disabled')
    end)
    ReLeftList:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(WoWTools_DataMixin.Icon.icon2..WoWTools_HyperLink.addName)
        GameTooltip:AddDoubleLine(' ', WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
        GameTooltip:Show()
        self:SetNormalAtlas('128-RedButton-Delete')
    end)
    ReLeftList.events={}
    ReLeftList.width=100--宽度

    ReLeftList:SetScript('OnClick', function(self)
        self:settings(true)
    end)
    function ReLeftList:settings(isClear)
        local data = CreateDataProvider()--DataProviderMixin
        if not isClear then
            for event, num in pairs(self.events) do
                data:Insert({event=event, num=num})
            end
            data:SetSortComparator(function(a,b) return a.num> b.num end)
        else
            self.events={}
            self.width=100--宽度
        end
        self.view:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
        self.ScrollBox:SetPoint('LEFT', EventTrace, 'LEFT', -(self.width)-15, 0)
    end

    ReLeftList.ScrollBox= CreateFrame('Frame', nil, EventTrace, 'WowScrollBoxList')
    ReLeftList.ScrollBox:SetPoint('TOPRIGHT', EventTrace, 'TOPLEFT', -6, 0)
    ReLeftList.ScrollBox:SetPoint('BOTTOMLEFT', EventTrace, 'BOTTOMLEFT', -6, 0)

    ReLeftList.ScrollBar= CreateFrame("EventFrame", nil, EventTrace, "MinimalScrollBar")
    ReLeftList.ScrollBar:SetPoint("TOPLEFT", ReLeftList.ScrollBox, "TOPRIGHT", 0,-6)
    ReLeftList.ScrollBar:SetPoint("BOTTOMLEFT", ReLeftList.ScrollBox, "BOTTOMRIGHT", 0,6)
    WoWTools_TextureMixin:SetScrollBar(ReLeftList.ScrollBar)

    ReLeftList.view = CreateScrollBoxListLinearView()

    ScrollUtil.InitScrollBoxListWithScrollBar(ReLeftList.ScrollBox, ReLeftList.ScrollBar, ReLeftList.view)

    ReLeftList.view:SetElementInitializer('EventSchedulerHeaderTemplate', function(frame, data)
        if not frame.event then
            frame.Background:SetAllPoints()

            frame:SetScript("OnMouseDown", function(s)
                if not EventTrace:IsLoggingPaused() then--移过时，暂停
                    EventTrace:TogglePause()
                end
                EventTrace.Log.Bar.SearchBox:SetText(s.event)
            end)
            frame:SetScript('OnLeave', function(s)
                s.Label:SetTextColor(0.5,0.5,0.5)
            end)
            frame:SetScript('OnEnter', function(s)
                s.Label:SetTextColor(1,1,1)
            end)
        end
        frame.event= data.event
--内容
        frame.Label:SetText(data.num..' '..data.event)
--宽度
        ReLeftList.width= math.max(frame.Label:GetStringWidth(), ReLeftList.width)
    end)

    hooksecurefunc(EventTraceLogEventButtonMixin, 'Init', function(_, data)
        if not data.displayEvent and data.event then
            local find= ReLeftList.events[data.event] or 0

            ReLeftList.events[data.event]= find+1

            if find==0 then
                ReLeftList:settings()
            end
        end
    end)

    EventTrace.Log.Bar.DiscardAllButton:HookScript('OnClick', function()
        ReLeftList:settings(true)
    end)

    hooksecurefunc(EventTrace, 'TogglePause', function(self)
        if not self.isLoggingPaused then
            ReLeftList:settings()
        end
    end)

    hooksecurefunc(EventTrace, 'RemoveEventFromDataProvider', function(_, _, event)
        if ReLeftList.events[event] then
            ReLeftList.events[event]= nil
            ReLeftList:settings()
        end
    end)
end





















--Plus
local function Init_Plus()
    if not C_AddOns.IsAddOnLoaded('Blizzard_EventTrace') or Save().hideEventTracePlus then
        return
    end

    EditBox= WoWTools_EditBoxMixin:Create(EventTrace, {
        name='WoWToolsChatButtonEventTraceEditBox',
        isSearch=true,
        text=WoWTools_DataMixin.onlyChinese and '事件' or EVENTS_LABEL,
    })
    EditBox:SetPoint('BOTTOMLEFT', EventTrace, 'TOPLEFT', 12, 0)
    EditBox:SetPoint('BOTTOMRIGHT', EventTrace, 'TOPRIGHT',-23 ,0)

--关闭按钮
    EventTraceCloseButton:SetFrameLevel(EventTrace.TitleContainer:GetFrameLevel()+1)

--OnEnter 提示
    hooksecurefunc(EventTraceLogEventButtonMixin, 'OnEnter', function()
        EventTraceTooltip:AddLine(' ')
        EventTraceTooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '双击' or BUFFER_DOUBLE)
            ..WoWTools_DataMixin.Icon.left
            ..'|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '搜索' or SEARCH),

            WoWTools_DataMixin.Icon.right
            ..'|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
        )
        EventTraceTooltip:Show()
    end)

    hooksecurefunc(EventTraceLogEventButtonMixin, 'OnLoad', function(self)
--隐藏事件按钮，提示 OnEnter
        self.HideButton:SetScript('OnLeave', function(s)
            GameTooltip:Hide()
            s:GetParent().MouseoverOverlay:SetShown(false)
        end)
        self.HideButton:SetScript('OnEnter', function(s)

            local p= s:GetParent()
            local elementData = p:GetElementData()
            GameTooltip:SetOwner(s, 'ANCHOR_LEFT')
            GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '过滤' or CALENDAR_FILTERS)
            GameTooltip_AddColoredLine(GameTooltip, GetDisplayEvent(elementData), HIGHLIGHT_FONT_COLOR)
            GameTooltip:Show()
            p.MouseoverOverlay:SetShown(true)
        end)

--点击，事件
        hooksecurefunc(self, 'SetScript', function(frame, text)
            if text=='OnClick' then
                frame:HookScript('OnClick', function(s)
                    local data = s:GetElementData()
                    local t=''
                    if data then
                        if not EventTrace:IsLoggingPaused() then--移过时，暂停
                            EventTrace:TogglePause()
                        end
                        t=(GetDisplayEvent(data) or '')
                            ..' '
                            ..(AddTooltipArguments(SafeUnpack(data.args) or ''))
                            ..' '
                            ..(data.formattedTimestamp and GRAY_FONT_COLOR:WrapTextInColorCode(data.formattedTimestamp) or '')
                    end
                    EditBox:SetText(t)
                end)
            end
        end)
    end)

--暂停/开始按钮，颜色
    EventTrace.Log.Bar.PlaybackButton.Label:SetTextColor(0,1,0)
    hooksecurefunc(EventTrace, 'UpdatePlaybackButton', function(self)
        if self:IsLoggingPaused() then
            self.Log.Bar.PlaybackButton.Label:SetTextColor(1,0,0)
        else
            self.Log.Bar.PlaybackButton.Label:SetTextColor(0,1,0)
        end
    end)



--左边列表
    Init_LeftList()

    Init_Plus=function()end
end





















local function Init_Print()
    if not Save().eventTracePrint then
        return
    end


    Frame= CreateFrame('Frame')
    Frame.index= 1

    function Frame:set_event()
        if Save().eventTracePrint then
            self:RegisterAllEvents()
        else
            self:UnregisterAllEvents()
        end
        EventTabs={}
        self.index=1
    end

    Frame:SetScript('OnEvent', function(self, event, arg1, ...)
        if not EventTabs[event] then
            arg= arg1 and {[arg1]=1} or {}
            self.index= self.index+1

            EventTabs[event]={
                index=self.index,
                num=1,
                arg= arg1 and {[arg1]=1} or {},
            }

            print(
                (select(2, math.modf((self.index-1)/2))==0 and '|cff10d3c8' or '|cffd3a21b')..self.index..')',
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

    Init_Print= function()
        Frame:set_event()
    end
end








function WoWTools_HyperLink:Blizzard_EventTrace()
    Init_Print()
    Init_Plus()
end

function WoWTools_HyperLink:Get_EventTrace_Print_Tab()
    return EventTabs
end
