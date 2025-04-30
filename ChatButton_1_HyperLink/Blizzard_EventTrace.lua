local function Save()
    return WoWToolsSave['ChatButton_HyperLink']
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
local EditBox








--Plus
local function Init_Plus()
    if not C_AddOns.IsAddOnLoaded('Blizzard_EventTrace') or Save().hideEventTracePlus then
        return
    end
    EditBox= WoWTools_EditBoxMixin:Create(EventTrace, {
        name='WoWToolsChatButtonEventTraceEditBox',
        isSearch=true,
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



    local function GetDisplayEvent(elementData)
        if elementData then
            return elementData.displayEvent or elementData.event
        end
    end


--点击，事件
    local function Button_OnClick(self)

    end


--隐藏事件按钮，提示 OnEnter
    local function Button_OnEnter(self)
        if not EventTrace:IsLoggingPaused() then--移过时，暂停
            EventTrace:TogglePause()
        end
        local p= self:GetParent()
        local elementData = p:GetElementData();
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '过滤' or CALENDAR_FILTERS)
        GameTooltip_AddColoredLine(GameTooltip, GetDisplayEvent(elementData), HIGHLIGHT_FONT_COLOR)
        GameTooltip:Show()
        p.MouseoverOverlay:SetShown(true)
    end





    hooksecurefunc(EventTraceLogEventButtonMixin, 'OnLoad', function(self)
--隐藏事件按钮
        self.HideButton:SetScript('OnLeave', function(s)
            GameTooltip:Hide()
            s:GetParent().MouseoverOverlay:SetShown(false)
        end)
        self.HideButton:SetScript('OnEnter', function(s)
            Button_OnEnter(s)
        end)
--点击，事件
        hooksecurefunc(self, 'SetScript', function(frame, text)
            if text=='OnClick' then
                frame:HookScript('OnClick', function(s)
                    Button_OnClick(s)
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
