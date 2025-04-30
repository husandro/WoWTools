local function Save()
    return WoWToolsSave['ChatButtonWorldChannel']
end








































local function Channel_Opetion_Menu(self, sub, name)

   
end






--添加菜单
local function Add_Menu(self, root, name, channelNumber)
    local text, sub, communityName, communityTexture, online
    local clubId=name:match('Community:(%d+)')

    if clubId then
        WoWTools_Mixin:Load({id=clubId, type='club'})
    end

    local clubInfo= clubId and C_Club.GetClubInfo(clubId)--社区名称

    if clubInfo and (clubInfo.shortName or clubInfo.name) then
        online= WoWTools_GuildMixin:GetNumOnline(clubInfo.clubId)--在线成员
        text= (clubInfo.avatarId==1
                and '|A:plunderstorm-glues-queueselector-trio-selected:0:0|a'
                or ('|T'..(clubInfo.avatarId or 0)..':0|t')
            )
            ..(clubInfo.clubType == Enum.ClubType.BattleNet and '|cff00ccff' or '|cffff8000')
            ..(clubInfo.shortName or clubInfo.name)
            ..'|r'
            ..(clubInfo.favoriteTimeStamp and '|A:recipetoast-icon-star:0:0|a' or ' ')
            ..((online==0 and '|cff828282' or '|cffffffff')..online)
        communityName=clubInfo.shortName or clubInfo.name
        communityTexture=clubInfo.avatarId
    end



    sub=root:CreateCheckbox(
        ((channelNumber and channelNumber>0) and channelNumber..' ' or '')..(text or name),--频道数字
    function(data)
        return self.channelNumber == GetChannelName(data.communityName or data.name)

    end, function(data)
        self:Send_Say(data.name, data.channelNumber)
        self:Set_LeftClick_Tooltip(--设置点击提示,频道字符
            data.communityName or data.name,
            data.channelNumber,
            data.texture,
            data.clubInfo
        )

    end, {
        texture=communityTexture,
        name=name,
        communityName=communityName,
        channelNumber= channelNumber,
        clubId= clubId,
        clubInfo= clubInfo,
    })
    --self.Description.EditBox.Instructions:SetText(self.clubType == Enum.ClubType.BattleNet and COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS_BATTLE_NET or COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS);

    sub:SetTooltip(function(tooltip, desc)
        local value= self:Check_Channel(desc.data.name)
        local t
        if value==0 then--不存在
            t= self:Get_Channel_Color(nil, 0)..(WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)
        elseif value==1 then
            t= WoWTools_DataMixin.onlyChinese and '已加入' or CLUB_FINDER_JOINED
        elseif value==2 then--屏蔽
            t= self:Get_Channel_Color(name, 2)..(WoWTools_DataMixin.onlyChinese and '已屏蔽' or IGNORED)
        end

        local club= desc.data.clubInfo

        if club and club.clubId then
            local isNet=  club.clubType == Enum.ClubType.BattleNet
            tooltip:AddLine(club.name, club.shortName)
            local col= isNet and '|cff00ccff' or '|cffff8000'
            tooltip:AddDoubleLine(
                t and col..t,
                col
                ..(
                    isNet
                    and (WoWTools_DataMixin.onlyChinese and '暴雪群组' or COMMUNITIES_INVITATION_FRAME_TYPE)
                    or (WoWTools_DataMixin.onlyChinese and '社区' or CLUB_FINDER_COMMUNITY_TYPE)
                )
            )
            tooltip:AddLine(club.description, nil, nil, nil, true)
            tooltip:AddDoubleLine('clubId', club.clubId)
        elseif t then
            tooltip:AddLine(t)
        end
    end)

    sub:AddInitializer(function(button, description)
        button:SetScript("OnUpdate", function(frame, elapsed)
            frame.elapsed= (frame.elapsed or 0.3) +elapsed
            if frame.elapsed<=0.3 then
                return
            end
            frame.elapsed=0
            local value= self:Check_Channel(description.data.name)
            if value==0 then--不存在
                frame.fontString:SetTextColor(0.62, 0.62, 0.62)
            elseif value==2 then----屏蔽
                frame.fontString:SetTextColor(1,0,0)
            else
                frame.fontString:SetTextColor(1,1,1)
            end
        end)

        if button.leftTexture1 then
            button.leftTexture1:SetShown(false)
        end
        if button.leftTexture2 then
            button.leftTexture2:SetAtlas('newplayertutorial-icon-mouse-leftbutton')
        end

        button:SetScript('OnHide', function(frame)
            frame:SetScript('OnUpdate', nil)
            frame.elapsed=nil
            if frame.fontString then
                frame.fontString:SetTextColor(1,1,1)
            end
        end)
    end)

--世界，修改
     if name== Save().world then
        sub:CreateButton(WoWTools_DataMixin.onlyChinese and '修改名称' or EQUIPMENT_SET_EDIT:gsub('/.+',''), function()
            StaticPopup_Show('WoWToolsChatButtonWorldChangeNamme')
        end)
        sub:CreateDivider()
    end

--屏蔽
    local value= self:Check_Channel(name)
    local col= value==1 and '' or '|cff9e9e9e'
    sub:CreateButton(col..(WoWTools_DataMixin.onlyChinese and '屏蔽' or IGNORE), function(data)
        self:Set_Join(data, nil, nil, true)--加入,移除,屏蔽
        return MenuResponse.Close
    end, name)

--加入
    col= value==1 and '|cff9e9e9e' or ''
    sub:CreateButton(col..(WoWTools_DataMixin.onlyChinese and '加入' or CHAT_JOIN), function(data)
        self:Set_Join(data, true)
        return MenuResponse.Close
    end, name)
end














local function Init_Menu(self, root)

    --世界频道
    local world = GetChannelName(Save().world)
    Add_Menu(self, root, Save().world, world)

--频道，列表
    root:CreateDivider()
    local find
    local channels = {GetChannelList()}
    for i = 1, #channels, 3 do
        local channelNumber, name, disabled = channels[i], channels[i+1], channels[i+2]
        if not disabled and channelNumber and name~=Save().world then
            Add_Menu(self, root, name, channelNumber)
            find=true
        end
    end
    if find then
        root:CreateDivider()
    end



    WoWTools_WorldMixin:Init_Filter_Menu(root)--屏蔽刷屏, 菜单
end















local function Init(btn)

    btn:SetupMenu(Init_Menu)
end

function WoWTools_WorldMixin:Init_Menu()
    Init(self.Button)
end