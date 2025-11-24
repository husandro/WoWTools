local function Save()
    return WoWToolsSave['ChatButton_HyperLink']
end

local EventTabs={}



























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
    if t == "nil" then
        return color:WrapTextInColorCode(t)

    elseif t == "string" then
        return color:WrapTextInColorCode(string.format('"%s"', arg))

    elseif t== 'table' then
        local a='{'
        for k, v in pairs(arg) do
            if type(v)=='table' then
                a= (a and a..'|n' or '')..'    '..tostring(k)..'|cffffffff=|r|cffff00ff{'
                for k2,v2 in pairs(v) do
                    a= a..'|n        '.. tostring(k2)..'|cffffffff=|r'..tostring(v2)
                end
                a=a..'|n    }|r'
            else
                a= (a and a..'\n' or '')..'    '..tostring(k)..'|cff0070dd=|r'..tostring(v)
            end
        end
        a=a..'|n}'
        return color:WrapTextInColorCode(a)
    end

    return color:WrapTextInColorCode(tostring(arg))
end

local function AddTooltipArguments(args)
    local text
    if args then
        for index, arg in pairs({SafeUnpack(args)}) do
            text= (text and text..'\n\n' or '')..'|cff00ccffarg'..index..'='..FormatArgument(arg)..'|r'
        end
    end
    return text
end

























--左边列表
local function Init_LeftList()
    local Pause, Clear, Refresh, Menu
    local size=28
    local IsLogging= not Save().eventTraceIsPased--暂停，事件


--ScrollBox
    local ScrollBox= CreateFrame('Frame', 'WoWToolsEventTraceScrollBox', EventTrace.Log, 'WowScrollBoxList')
    ScrollBox:SetPoint('TOPRIGHT', EventTrace, 'TOPLEFT', 5, 0)
    ScrollBox:SetPoint('BOTTOMLEFT', EventTrace, 'BOTTOMLEFT', 5, 0)
    ScrollBox.events={}
    ScrollBox.num=0
    ScrollBox.width=100--宽度

--ScrollBar
    local ScrollBar= CreateFrame("EventFrame", 'WoWToolsEventTraceScrollBar', EventTrace.Log, "MinimalScrollBar")
    ScrollBar:SetPoint("TOPRIGHT", ScrollBox, "TOPLEFT", -4, -6)
    ScrollBar:SetPoint("BOTTOMRIGHT", ScrollBox, "BOTTOMLEFT", -4, 6)
    WoWTools_TextureMixin:SetScrollBar(ScrollBar)

    ScrollBox.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, ScrollBox.view)

--重置
    Refresh= WoWTools_ButtonMixin:Cbtn(EventTrace.Log, {
        name='WoWToolsEventTraceRefresh',
        size=size,
        atlas='128-RedButton-Refresh-Disabled',
        notLocked=true
    })
    Refresh:SetPoint('BOTTOMRIGHT', EventTrace, 'TOPLEFT', 6, 0)
    Refresh:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetNormalAtlas('128-RedButton-Refresh-Disabled')
    end)
    Refresh:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '重置' or RESET))
        GameTooltip:Show()
        self:SetNormalAtlas('128-RedButton-Refresh')
    end)
    Refresh:SetScript('OnClick', function()
        ScrollBox.events={}
        for _, data in pairs(EventTrace.logDataProvider:GetCollection() or {}) do
            if data.event then
                ScrollBox.events[data.event]= (ScrollBox.events[data.event] or 0)+1
            end
        end
        ScrollBox:settings()
    end)

--暂停
    Pause= WoWTools_ButtonMixin:Cbtn(Refresh, {
        name='WoWToolsEventTracePause',
        size=size,
        icon='hide',
        notLocked=true}
    )
    Pause:SetPoint('RIGHT', Refresh, 'LEFT')
    Pause:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_texture()
    end)
    Pause:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:set_texture()
    end)
    Pause:SetScript('OnClick', function(self)
        self:settings()
        self:set_tooltip()
    end)
    function Pause:settings()
        Save().eventTraceIsPased= not Save().eventTraceIsPased and true or nil
        IsLogging= not Save().eventTraceIsPased
        self:set_texture()
    end
    function Pause:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2
            ..(Save().eventTraceIsPased and (WoWTools_DataMixin.onlyChinese and '暂停' or EVENTTRACE_BUTTON_PAUSE)
            or (WoWTools_DataMixin.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER))
        )
        GameTooltip:Show()
    end
    function Pause:set_texture()
        local atlas
        local isOwner= self:IsMouseOver()
        if Save().eventTraceIsPased then
            atlas= isOwner and '128-RedButton-VisibilityOff' or '128-RedButton-VisibilityOff-Disabled'
        else
            atlas= isOwner and '128-RedButton-VisibilityOn' or '128-RedButton-VisibilityOn-Disabled'
        end
        self:SetNormalAtlas(atlas)
    end
    Pause:set_texture()

--清除
    Clear= WoWTools_ButtonMixin:Cbtn(Refresh, {
        name='WoWToolsEventTraceClear',
        size=size,
        atlas='128-RedButton-Delete-Disabled',
        notLocked=true})
    Clear:SetPoint('RIGHT', Pause, 'LEFT')
    Clear:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetNormalAtlas('128-RedButton-Delete-Disabled')
    end)
    Clear:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2))
        GameTooltip:Show()
        self:SetNormalAtlas('128-RedButton-Delete')
    end)
    Clear:SetScript('OnClick', function()
        ScrollBox:settings(true)
    end)

--[[菜单
    Menu= WoWTools_ButtonMixin:Cbtn(Refresh, {
        name= 'WoWToolsEventTraceMenu',
        atlas='GM-icon-settings-pressed',
        size=size,
        isType2=true,
        notBorder=true,
        notLocked=true
    })
    Menu:SetPoint('RIGHT', Clear, 'LEFT')
    Menu.texture:SetVertexColor(0.5, 0.5, 0.5)
    Menu:SetScript('OnLeave', function(self)
        self.texture:SetVertexColor(0.5,0.5,0.5)
    end)
    Menu:SetScript('OnEnter', function(self)
        self.texture:SetVertexColor(1,1,1)
    end)
    Menu:SetScript('OnClick', function()
        WoWTools_ChatMixin:GetButtonForName('HyperLink'):OpenMenu()
    end)]]

--数量
    ScrollBox.Text= WoWTools_LabelMixin:Create(Refresh, {color={r=0.5,g=0.5,b=0.5}})
    ScrollBox.Text:SetPoint('RIGHT', Clear, 'LEFT', 0, 1)













--初始
    ScrollBox.view:SetElementInitializer('EventSchedulerHeaderTemplate', function(frame, data)
        if frame.Init then
            frame.Background:SetVertexColor(0.1, 0.1, 0.1, 0.7)
            frame.Background:SetPoint('LEFT')
            frame.Background:SetPoint('RIGHT')
            frame.Label:SetPoint('LEFT', frame,2,0)
            frame:SetScript("OnMouseDown", function(s)
                --[[if not EventTrace:IsLoggingPaused() then--移过时，暂停
                    EventTrace:TogglePause()
                end]]
                EventTrace.Log.Bar.SearchBox:SetText(s.event)
            end)
            frame:SetScript('OnLeave', function(s)
                s.Label:SetTextColor(0.5, 0.5, 0.5)
            end)
            frame:SetScript('OnEnter', function(s)
                s.Label:SetTextColor(1, 1, 1)
            end)
            frame.Init=nil
        end

        frame.event= data.event
    --内容
        frame.Label:SetText(data.num..' '..data.event)
    --宽度
        ScrollBox.width= math.max(frame.Label:GetStringWidth(), ScrollBox.width)
    end)

    --设置，列表
    function ScrollBox:settings(isClear)
        local data = CreateDataProvider()--DataProviderMixin
        local all=0
        if not isClear then
            for event, num in pairs(self.events) do
                data:Insert({event=event, num=num})
                all=all+1
            end
            data:SetSortComparator(function(a,b) return a.num> b.num end)
        else
            self.events={}
            self.width=50--宽度
        end
        self.view:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
        self.Text:SetText(all)
    --设置，宽度
        self:SetPoint('LEFT', EventTrace, 'LEFT', -(self.width)-2, 0)
    end

    --添加，事件
    WoWTools_DataMixin:Hook(EventTrace, 'LogLine', function(_, data)
        if not data.displayEvent and data.event then
            local find= ScrollBox.events[data.event] or 0

            ScrollBox.events[data.event]= find+1

            if find==0 and IsLogging then
                ScrollBox:settings()
            end
        end
    end)

    --全部清除
    EventTrace.Log.Bar.DiscardAllButton:HookScript('OnClick', function()
        ScrollBox:settings(true)
    end)

    --刷新，事件
    WoWTools_DataMixin:Hook(EventTrace, 'TogglePause', function(self)
        if not self.isLoggingPaused then
            ScrollBox:settings()
        end
    end)

    --过滤，事件
    WoWTools_DataMixin:Hook(EventTrace, 'RemoveEventFromDataProvider', function(_, _, event)
        if ScrollBox.events[event] then
            ScrollBox.events[event]= nil
            ScrollBox:settings()
        end
    end)

    Init_LeftList= function()end
end























--上面 EditBox
local function Init_EditBox()
    local Frame= WoWTools_EditBoxMixin:CreateFrame(EventTrace, {
        text= WoWTools_DataMixin.onlyChinese and '查看' or VIEW,
        name= 'WoWToolsEventTraceViewEditBox',
    })
    --Frame:Hide()
    Frame.ScrollBar:ClearAllPoints()
    Frame:SetPoint('BOTTOMLEFT', EventTrace, 'TOPLEFT', 12, 0)
    Frame:SetPoint('BOTTOMRIGHT', EventTrace, 'TOPRIGHT',-23 ,0)
    Frame:SetHeight(23)

--查看，按钮
    Frame.View= WoWTools_ButtonMixin:Cbtn(Frame, {atlas='Perks-PreviewOn', isType2=true, notBorder=true, notLocked=true})
    Frame.View.texture:SetDesaturated(true)
    Frame.View:SetPoint('LEFT', Frame, 'RIGHT', 0, 6)
    Frame.View:SetScript('OnLeave', function(self)
        self.texture:SetDesaturated(true)
        GameTooltip:Hide()
    end)
    Frame.View:SetScript('OnEnter', function(self)
        self.texture:SetDesaturated(false)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '查看' or VIEW))
        GameTooltip:Show()
    end)
    Frame.View:SetScript('OnMouseDown', function(self)
        WoWTools_TextMixin:ShowText(
            self:GetParent():GetText(),
            WoWTools_DataMixin.onlyChinese and '事件' or EVENTS_LABEL,
            nil
        )
    end)
    --Frame.View:Hide()

--清除，按钮
    Frame.clearButton= CreateFrame('Button', nil, Frame)
    Frame.clearButton:SetSize(14,14)
    Frame.clearButton:SetPoint('TOPRIGHT', -2, 4)
    Frame.clearButton:SetFrameLevel(Frame.editBox:GetFrameLevel()+1)
    Frame.clearButton:SetNormalAtlas('common-search-clearbutton')
    Frame.clearButton:SetAlpha(0.5)
    Frame.clearButton:Hide()
    Frame.clearButton:SetScript('OnLeave', function(s) s:SetAlpha(0.5) end)
    Frame.clearButton:SetScript('OnEnter', function(s) s:SetAlpha(1) end)
    Frame.clearButton:SetScript('OnMouseDown', function(s) s:GetParent().editBox:SetText('') s:SetAlpha(0.5) end)

--设置 OnTextChanged
    Frame.editBox:SetScript('OnTextChanged', function(self)
        local isText= self:GetText()~= ""
        local numLine= self:GetNumLines() or 0
        local p= self:GetParent()
        self.Instructions2:SetText(isText and numLine or '')
        self.Instructions2:SetShown(isText)
        self.Instructions:SetShown(not isText)
        p.clearButton:SetShown(isText)
        --p.View:SetShown(numLine>1)
    end)



    WoWTools_DataMixin:Hook(EventTraceLogEventButtonMixin, 'OnLoad', function(self)
--隐藏事件按钮，提示 OnEnter
        self.HideButton:SetScript('OnLeave', function(s)
            GameTooltip:Hide()
            s:GetParent().MouseoverOverlay:SetShown(false)
        end)
        self.HideButton:SetScript('OnEnter', function(s)

            local p= s:GetParent()
            local elementData = p:GetElementData()
            GameTooltip:SetOwner(s, 'ANCHOR_LEFT')
            GameTooltip:SetText(WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '过滤' or CALENDAR_FILTERS))
            GameTooltip_AddColoredLine(GameTooltip, GetDisplayEvent(elementData), HIGHLIGHT_FONT_COLOR)
            GameTooltip:Show()
            p.MouseoverOverlay:SetShown(true)
        end)


--点击，事件
        local function set_script(s)
            local data = s:GetElementData()
            local t=''
            if data then
                t=(GetDisplayEvent(data) or '')
                    ..' '
                    ..(AddTooltipArguments(data.args) or '')
                    ..' '
                    ..(data.formattedTimestamp and GRAY_FONT_COLOR:WrapTextInColorCode(data.formattedTimestamp) or '')
            end
            Frame:SetText(t)
            Frame.editBox:SetCursorPosition(1)
        end

        WoWTools_DataMixin:Hook(self, 'SetScript', function(frame, text)
            if text=='OnClick' then
                frame:HookScript('OnClick', function(s)
                    set_script(s)
                end)
            end
        end)
    end)


    Init_Plus=function()end
end


















--Plus
local function Init_Plus()
    if Save().hideEventTracePlus then
        return
    end

    if not C_AddOns.IsAddOnLoaded('Blizzard_EventTrace') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_EventTrace' then
                Init_Plus()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end

--上面 EditBox
    Init_EditBox()
--左边列表
    Init_LeftList()


--关闭按钮
    EventTraceCloseButton:SetFrameLevel(EventTrace.TitleContainer:GetFrameLevel()+1)

--OnEnter 提示
    WoWTools_DataMixin:Hook(EventTraceLogEventButtonMixin, 'OnEnter', function()
        EventTraceTooltip:AddLine(' ')
        EventTraceTooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '查看' or VIEW)
            ..WoWTools_DataMixin.Icon.left
            ..' '..(WoWTools_DataMixin.onlyChinese and '双击' or BUFFER_DOUBLE)
            ..WoWTools_DataMixin.Icon.left
            ..'|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '搜索' or SEARCH),

            WoWTools_DataMixin.Icon.right
            ..'|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
        )
        EventTraceTooltip:Show()
    end)


--暂停/开始按钮，颜色
    EventTrace.Log.Bar.PlaybackButton.Label:SetTextColor(0,1,0)
    WoWTools_DataMixin:Hook(EventTrace, 'UpdatePlaybackButton', function(self)
        if self:IsLoggingPaused() then
            self.Log.Bar.PlaybackButton.Label:SetTextColor(1,0,0)
        else
            self.Log.Bar.PlaybackButton.Label:SetTextColor(0,1,0)
        end
    end)




    Init_Plus=function()end
end





















local function Init()
    if not Save().eventTracePrint then
        return
    end

    local Frame= CreateFrame('Frame')
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



    Frame.events={
        LOADING_SCREEN_DISABLED=1,
        PLAYER_ENTERING_WORLD=1,
        PLAYER_LOGIN=1,
        ADDON_LOADED=1,
    }

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
                (
                    self.events[event] and '|cnGREEN_FONT_COLOR:'
                    or (select(2, math.modf((self.index-1)/2))==0 and '|cff10d3c8' or '|cffd3a21b')
                )
                ..self.index
                ..')',
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

    Init= function()
        Frame:set_event()
    end
end





                


function WoWTools_HyperLink:Init_EventTrace()
    Init()
    Init_Plus()
end

function WoWTools_HyperLink:Get_EventTrace_Print_Tab()
    return EventTabs
end
