--社区 Plus



local function Set_Sctipt(object)
    object:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    object:SetScript('OnEnter', function(self)
        self:SetAlpha(0.3)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(WoWTools_DataMixin.Icon.icon2..self.tooltip)
        GameTooltip:Show()
    end)
end



local function Create_Texture(btn)
    if btn.allText then
        return
    end

--总人数
    btn.allText= WoWTools_LabelMixin:Create(btn)--, {color=true})
    btn.allText:SetPoint('TOPLEFT', btn.Icon, 'BOTTOMLEFT')
    btn.allText.tooltip= (WoWTools_DataMixin.onlyChinese and '成员数量' or CLUB_FINDER_SORT_BY_MOST_MEMBERS)
                ..'|n'..(WoWTools_DataMixin.onlyChinese and '在线成员' or GUILD_MEMBERS_ONLINE)
                ..'|n'..(WoWTools_DataMixin.onlyChinese and '公会会阶' or GUILDCONTROL_GUILDRANKS)
    Set_Sctipt(btn.allText)

--[[在线人数
    btn.onlineText=WoWTools_LabelMixin:Create(btn, {color=true})
    btn.onlineText:SetPoint('BOTTOM', 0, 2)
    btn.onlineText.tooltip= WoWTools_DataMixin.onlyChinese and '在线成员' or GUILD_MEMBERS_ONLINE
    Set_Sctipt(btn.onlineText)]]

--是否有申请人
    btn.inviteTexture= btn:CreateTexture(nil, 'BORDER',nil, 2)
    btn.inviteTexture:SetPoint('RIGHT',-6,0)
    btn.inviteTexture:SetSize(20,20)
    btn.inviteTexture:SetAtlas('communities-icon-invitemail')
    btn.inviteTexture.tooltip= WoWTools_DataMixin.onlyChinese and '申请人' or CLUB_FINDER_APPLICANTS
    Set_Sctipt(btn.inviteTexture)

--是否有未读信息
    btn.msgTexture= btn:CreateTexture(nil, 'BORDER', nil, 2)
    btn.msgTexture:SetPoint('RIGHT',-6,-20)
    btn.msgTexture:SetSize(20,20)
    btn.msgTexture:SetAtlas('communities-icon-notification')
    btn.msgTexture.tooltip= WoWTools_DataMixin.onlyChinese and '未读信息' or COMMUNITIES_CHAT_FRAME_UNREAD_MESSAGES_NOTIFICATION
    Set_Sctipt(btn.msgTexture)

--是否跨派系
    btn.factionTexture= btn:CreateTexture(nil, 'BORDER', nil, 2)
    btn.factionTexture:SetPoint('RIGHT',-6,20)
    btn.factionTexture:SetSize(20,20)
    btn.factionTexture:SetAtlas('CrossedFlags')
    btn.factionTexture.tooltip= WoWTools_DataMixin.onlyChinese and '跨阵营' or COMMUNITIES_EDIT_DIALOG_CROSS_FACTION
    Set_Sctipt(btn.factionTexture)

    --[[btn.rankText= WoWTools_LabelMixin:Create(btn, {color=true, layer='BORDER'})
    btn.rankText:SetPoint('BOTTOMRIGHT', -6, 2)]]
end



local COMMUNITIES_DELETE_CONFIRM_STRING= COMMUNITIES_DELETE_CONFIRM_STRING
--公会，社区，在线人数
local function Init()
    WoWTools_DataMixin:Hook(CommunitiesListEntryMixin, 'Init', function(btn, elementData)
        local clubID= btn.clubId

        local hasInvite, hasMessage, faction, text

        if clubID and elementData and elementData.clubInfo then
            Create_Texture(btn)

            local online, all= WoWTools_GuildMixin:GetNumOnline(clubID)
            if online and all then
                text= online..'/'..all
            end
            local info = C_Club.GetMemberInfoForSelf(clubID)
            if info and info.guildRank then
                text= (text and text..' ' or '')..info.guildRank
            end

            hasInvite=  WoWTools_GuildMixin:GetApplicantList(clubID) and true or false
            hasMessage= CommunitiesUtil.DoesCommunityHaveUnreadMessages(clubID)
            faction= elementData.clubInfo.crossFaction and 'CrossedFlags'

            btn.allText:SetTextColor(btn.Name:GetTextColor())
        end
        if btn.allText then
            btn.allText:SetText(text or '' )
            btn.inviteTexture:SetShown(hasInvite)
            btn.msgTexture:SetShown(hasMessage)
            btn.factionTexture:SetShown(faction)
        end
    end)



    Init=function()end
end




function WoWTools_GuildMixin:Plus_CommunitiesFrame()
    Init()
end