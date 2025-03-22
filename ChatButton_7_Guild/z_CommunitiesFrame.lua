--社区 Plus
local e= select(2, ...)


local function Set_Sctipt(object)
    object:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    object:SetScript('OnEnter', function(self)
        self:SetAlpha(0.3)
        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_GuildMixin.addName, WoWTools_DataMixin.Icon.icon2..self.tooltip)
        if self.isCrossFaction then
            GameTooltip:AddDoubleLine(' ', WoWTools_TextMixin:GetYesNo(self.crossFaction))
        end
        GameTooltip:Show()
    end)
end



local function Create_Texture(btn)
    if btn.allText then
        return
    end
--总人数
    btn.allText= WoWTools_LabelMixin:Create(btn, {color={r=0.62,g=0.62,b=0.62}})
    btn.allText:SetPoint('TOP', btn.Icon, 'BOTTOM')
    btn.allText.tooltip= WoWTools_Mixin.onlyChinese and '成员数量' or CLUB_FINDER_SORT_BY_MOST_MEMBERS
    Set_Sctipt(btn.allText)

--在线人数
    btn.onlineText=WoWTools_LabelMixin:Create(btn, {color=true})
    btn.onlineText:SetPoint('BOTTOM', 0, 2)
    btn.onlineText.tooltip= WoWTools_Mixin.onlyChinese and '在线成员' or GUILD_MEMBERS_ONLINE
    Set_Sctipt(btn.onlineText)

--是否有申请人
    btn.inviteTexture= btn:CreateTexture(nil, 'BORDER',nil, 2)
    btn.inviteTexture:SetPoint('RIGHT',-6,0)
    btn.inviteTexture:SetSize(20,20)
    btn.inviteTexture:SetAtlas('communities-icon-invitemail')
    btn.inviteTexture.tooltip= WoWTools_Mixin.onlyChinese and '申请人' or CLUB_FINDER_APPLICANTS
    Set_Sctipt(btn.inviteTexture)

--是否有未读信息
    btn.msgTexture= btn:CreateTexture(nil, 'BORDER', nil, 2)
    btn.msgTexture:SetPoint('RIGHT',-6,-20)
    btn.msgTexture:SetSize(20,20)
    btn.msgTexture:SetAtlas('communities-icon-notification')
    btn.msgTexture.tooltip= WoWTools_Mixin.onlyChinese and '未读信息' or COMMUNITIES_CHAT_FRAME_UNREAD_MESSAGES_NOTIFICATION
    Set_Sctipt(btn.msgTexture)

--是否跨派系
    btn.factionTexture= btn:CreateTexture(nil, 'BORDER', nil, 2)
    btn.factionTexture:SetPoint('RIGHT',-6,20)
    btn.factionTexture:SetSize(20,20)
    btn.factionTexture.tooltip= WoWTools_Mixin.onlyChinese and '跨阵营' or COMMUNITIES_EDIT_DIALOG_CROSS_FACTION
    btn.factionTexture.isCrossFaction= true
    Set_Sctipt(btn.factionTexture)

    function btn:settings(online, all, hasInvite, hasMessage, faction)
        self.allText:SetText(all and all>0 and all or '')
        self.onlineText:SetText(online or '')
        self.inviteTexture:SetShown(hasInvite)
        self.msgTexture:SetShown(hasMessage)
        local crossFaction= faction and true or false
        self.factionTexture:SetShown(crossFaction)
        if self.isCrossFaction then
            self.crossFaction= crossFaction
        end
    end
end




--公会，社区，在线人数

local function CommunitiesList_ScrollBox(self)
    if not self:GetView() then
        return
    end
    for _, btn in pairs(self:GetFrames() or {}) do

        local clubID= btn.clubId

        local online, all, hasInvite, hasMessage, faction
        if clubID then
            online, all= WoWTools_GuildMixin:GetNumOnline(clubID)

            hasInvite=  WoWTools_GuildMixin:GetApplicantList(clubID) and true or false
            hasMessage= CommunitiesUtil.DoesCommunityHaveUnreadMessages(clubID)

            local elementData = clubID and btn:GetElementData()
            local clubInfo= elementData.clubInfo or {}

            faction= clubInfo.crossFaction and 'CrossedFlags' or WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction]

            Create_Texture(btn)

            btn.factionTexture:SetAtlas(faction)
        end
        if btn.settings then
            btn:settings(online, all, hasInvite, hasMessage, faction)
        end
    end
end




local function Init()
    hooksecurefunc(CommunitiesFrameCommunitiesList.ScrollBox, 'SetScrollTargetOffset', CommunitiesList_ScrollBox)--公会，社区，在线人数
    return true
end



function WoWTools_GuildMixin:Plus_CommunitiesFrame()
    if Init() then
        Init=function()end
        return true
    end
end