local function Save()
    return WoWToolsSave['ChatButtonWorldChannel']
end









local function Init(btn)


    function btn:Get_myChatFilter_Text()
        return (
            WoWTools_DataMixin.onlyChinese and '内容限'..Save().myChatFilterNum..'个字符以内'
            or ERR_VOICE_CHAT_CHANNEL_NAME_TOO_LONG:gsub(CHANNEL_CHANNEL_NAME,''):gsub('30', Save().myChatFilterNum)
        )
    end


    function btn:Set_LeftClick_Tooltip(name, channelNumber, texture, clubInfo)--设置点击提示,频道字符
        self.channelNumber=channelNumber
        self.channelName=name

        local text
        if name then
            text= name=='大脚世界频道' and '世' or WoWTools_TextMixin:sub(name, 1, 3)
        else
            text= WoWTools_DataMixin.onlyChinese and '无' or NONE
        end

        if name == Save().world then
            self.texture:SetAtlas('WildBattlePet')
        elseif texture then
            if clubInfo and clubInfo.clubId then
                C_Club.SetAvatarTexture(self.texture, clubInfo.avatarId, clubInfo.clubType)
            else
                self.texture:SetTexture(texture)
            end
        else
            self.texture:SetAtlas('128-Store-Main')
        end
        self.leftClickTips:SetText(text)
    end

    function btn:Set_Join(name, join, leave, remove)--加入,移除, 屏蔽
        if leave then
            LeaveChannelByName(name);
        elseif join then
            --ChatFrameUtil.CanAddChannel(
            JoinPermanentChannel(name)
            --ChatFrame_AddChannel(SELECTED_CHAT_FRAME, name);--12.01没发现
            SELECTED_CHAT_FRAME:AddChannel(name)
        elseif remove then
            ChatFrame_RemoveChannel(SELECTED_CHAT_FRAME, name)--ChatFrameMixin.RemoveChannel
        end
        C_Timer.After(1, function() self:Check_Channel(name) end)
    end


    function btn:Send_Say(name, channelNumber)--发送
        Save().lastName= name
        local check= self:Check_Channel(name)
        if check==0 or not channelNumber or channelNumber==0 then
            self:Set_Join(name, true)
            C_Timer.After(1, function()
                local channelNumber2 = GetChannelName(name)
                if channelNumber2 and channelNumber2>0 then
                    WoWTools_ChatMixin:Say('/'..channelNumber2)
                    self:Set_LeftClick_Tooltip(name, channelNumber2)--设置点击提示,频道字符
                else
                    WoWTools_ChatMixin:Say(SLASH_JOIN4..' '..name)
                end
            end)
        else
            if check==2 and SELECTED_CHAT_FRAME:GetID()~=2 then
                self:Set_Join(name, true)
            end
            if channelNumber then
                self:Set_LeftClick_Tooltip(name, channelNumber)--设置点击提示,频道字符
                WoWTools_ChatMixin:Say('/'..channelNumber);
            else
                WoWTools_ChatMixin:Say(SLASH_JOIN4..' '..name)
            end
        end
    end




    function btn:Check_Channel(name)
        if not name or not select(2,GetChannelName(name)) then
            return 0--不存存在
        else
            local tab={GetChatWindowChannels(SELECTED_CHAT_FRAME:GetID())}
            for i= 1, #tab, 2 do
                if tab[i]==name then
                    return 1--存在
                end
            end
            return 2--屏蔽
        end
    end






    function btn:Get_Channel_Color(name, value)
        value= value or self:Check_Channel(name)
        if value==0 then
            return '|cff626262'
        elseif value==2 then
            return '|cnWARNING_FONT_COLOR:'
        else
            return ''
        end
    end







    function btn:set_tooltip()
        self:set_owner()

        local find= CountTable(WoWTools_WorldMixin:Get_FilterTextTab() or {})

        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM))..' #'..find, WoWTools_TextMixin:GetEnabeleDisable(Save().myChatFilter))
        GameTooltip:AddLine(' ')

        local clubID, channelNumber, name, disabled, clubInfo, col
        local channels = {GetChannelList()}
        local value
        for i = 1, #channels, 3 do
            channelNumber, name, disabled = channels[i], channels[i+1], channels[i+2]
            if not disabled and channelNumber and name then
                value= self:Check_Channel(name)
                col= self:Get_Channel_Color(name, value)

                find= (channelNumber and self.channelNumber==channelNumber) and WoWTools_DataMixin.Icon.left or '   '

                clubID=name:match('Community:(%d+)');
                if clubID then
                   WoWTools_DataMixin:Load(clubID, 'club')

                    clubInfo= C_Club.GetClubInfo(clubID)

                    if clubInfo and clubInfo.name then
                        name= (clubInfo.avatarId==1
                                and '|A:plunderstorm-glues-queueselector-trio-selected:0:0|a'
                                or ('|T'..(clubInfo.avatarId or 0)..':0|t')
                            )
                            ..clubInfo.name
                    end
                end

                GameTooltip:AddDoubleLine(col..channelNumber..')', col..name..find)
            end
        end
        GameTooltip:Show()
    end




    function btn:set_OnMouseDown()
        if self.channelNumber and self.channelNumber>0 then
            self:Send_Say(self.channelName, self.channelNumber)
        else
            return true
        end
    end




    btn.texture:SetAtlas('128-Store-Main')

    btn.leftClickTips=WoWTools_LabelMixin:Create(btn, {size=12, color=true, justifyH='CENTER'})--10, nil, nil, true, nil, 'CENTER')
    btn.leftClickTips:SetPoint('BOTTOM',0,2)

    if Save().lastName then
        local channelNumber = GetChannelName(Save().lastName)
        if channelNumber and channelNumber>0 then
            btn.channelNumber= channelNumber
            btn:Set_LeftClick_Tooltip(Save().lastName, channelNumber)
        end
    end

    Init=function()end
end











function WoWTools_WorldMixin:Set_Button()
    Init(WoWTools_ChatMixin:GetButtonForName('World'))
end