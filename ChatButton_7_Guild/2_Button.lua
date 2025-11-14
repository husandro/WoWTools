
local function Save()
    return WoWToolsSave['ChatButtonGuild'] or {}
end

local G_GUILD_INFO_TEMPLATE= GUILD_INFO_TEMPLATE:gsub('(%%.+)', '')--公会创立





local function Set_Text(self)
    local isInGuild= IsInGuild()

    --设置背景
    if isInGuild then
        self.texture2:SetAtlas(
            isInGuild and 'UI-HUD-MicroMenu-GuildCommunities-Up'
            or (WoWTools_DataMixin.Player.Faction=='Alliance' and 'honorsystem-prestige-laurel-bg-alliance')
            or (WoWTools_DataMixin.Player.Faction=='Horde' and 'honorsystem-prestige-laurel-bg-horde')
            or 'UI-HUD-MicroMenu-GuildCommunities-Up'
    )
    else
        self.texture2:SetAtlas('honorsystem-prestige-laurel-bg-alliance')
    end

--图标
    if isInGuild then--GuildUtil.lua
        SetLargeGuildTabardTextures(-- SetSmallGuildTabardTextures(
            'player',
            self.texture,
            self.texture2,--self.background2,
            nil, --self.border,
            C_GuildInfo.GetGuildTabardInfo('player')
        )
    end
    self.texture:SetShown(isInGuild)

--在线人数
    local online=1
    if isInGuild then
        online = select(2, GetNumGuildMembers()) or 1
    end
    online= online-1
    self.membersText:SetText(online==0 and '|cff8282820' or online)
    self.membersText:SetAlpha(online==0 and 0.3 or 1)

    local bottomText
    if isInGuild then
--弹劾
        if CanReplaceGuildMaster() then--弹劾
            bottomText= WoWTools_DataMixin.onlyChinese and '弹' or  WoWTools_TextMixin:sub(GUILD_IMPEACH_POPUP_CONFIRM, 2, 5,true)
        elseif WoWTools_GuildMixin:IsLeaderOrOfficer() and CanGuildInvite() then
            bottomText= WoWTools_GuildMixin:GetClubFindDay(nil)--Club,列出查找，过期时间
        end
    end
    self.bottomText:SetText(bottomText or (WoWTools_DataMixin.onlyChinese and '会' or 'g'))
end










local function Init(btn)
    btn.texture:ClearAllPoints()
    btn.texture:SetPoint('CENTER', -1.5, 1)
    btn.texture:SetSize(18,18)

    btn.texture2= btn:CreateTexture(nil, 'BACKGROUND', nil, 2)
    btn.texture2:SetPoint("TOPLEFT", btn, "TOPLEFT", -14, 14)
    btn.texture2:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 14, -14)

    btn.IconMask:SetPoint("TOPLEFT", btn, "TOPLEFT", 5.5, -5.5)
    btn.IconMask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -8, 8)
    btn.texture2:AddMaskTexture(btn.IconMask)

    btn.inviteTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.inviteTexture:SetPoint('TOPLEFT',1,-1)
    btn.inviteTexture:SetAtlas('communities-icon-invitemail')
    btn.inviteTexture:SetSize(12,12)
    --btn.inviteTexture:Hide()

    --[[GuildMicroButton.inviteTexture= btn:CreateTexture(nil, 'OVERLAY')
    GuildMicroButton.inviteTexture:SetPoint('TOPLEFT',1,-1)
    GuildMicroButton.inviteTexture:SetAtlas('communities-icon-invitemail')
    GuildMicroButton.inviteTexture:SetSize(12,12)]]
    
    
    btn.msgTexture= btn:CreateTexture(nil, 'BORDER', nil, 2)
    btn.msgTexture:SetPoint('LEFT',-3,0)
    btn.msgTexture:SetSize(12,12)
    btn.msgTexture:SetAtlas('communities-icon-notification')

    btn.membersText=WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})-- 10, nil, nil, true, nil, 'CENTER')
    btn.membersText:SetPoint('TOPRIGHT', -3, 0)

    btn.bottomText= WoWTools_LabelMixin:Create(btn, {size=10, color=true, justifyH='CENTER'})
    btn.bottomText:SetPoint('BOTTOM', 0, 2)


    function btn:set_guildinfo_event()
        self:UnregisterEvent('CHAT_MSG_SYSTEM')
        if IsInGuild() and (Save().guildInfo or not WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild.text) then
            self:RegisterEvent('CHAT_MSG_SYSTEM')
            GuildInfo()
        end
    end

--申请者
    function btn:set_new_application(isInit)
        local isInviete, isMessage= false, false
        local clubs= C_ClubFinder.IsEnabled() and C_Club.GetSubscribedClubs()
        if clubs then
            for _, data in pairs(clubs or {}) do
                if not isInviete and WoWTools_GuildMixin:GetApplicantList(data.clubId) then
                    isInviete=true

                    if isInit then
                        print(
                            WoWTools_GuildMixin.addName..WoWTools_DataMixin.Icon.icon2,
                            '|cffff00ff'
                            ..(WoWTools_DataMixin.onlyChinese and '新' or NEW)..'|r|A:communities-icon-invitemail:0:0|a|cnGREEN_FONT_COLOR:'
                            ..(WoWTools_DataMixin.onlyChinese and '申请人' or CLUB_FINDER_APPLICANTS)
                        )
                    end
                end

                if not isMessage and CommunitiesUtil.DoesCommunityHaveUnreadMessages(data.clubId) then
                    isMessage= true
                end

                if isMessage and isInviete then
                    break
                end
            end
        end
        self.inviteTexture:SetShown(isInviete)
        --GuildMicroButton.inviteTexture:SetShown(isInviete)
        self.msgTexture:SetShown(isMessage)
    end

    function btn:set_tooltip()
        self:set_owner()
        if not IsInGuild() then
            GameTooltip:AddLine('|cff626262'..(WoWTools_DataMixin.onlyChinese and '无公会' or ITEM_REQ_PURCHASE_GUILD)..WoWTools_DataMixin.Icon.left)
        else
            WoWTools_GuildMixin:Load_Club(nil)--加载，Club,数据
        end
        WoWTools_GuildMixin:OnEnter_GuildInfo()--公会，社区，信息
        GameTooltip:Show()
    end


    function btn:set_OnMouseDown()
        WoWTools_ChatMixin:Say('/g')
    end

    --[[btn:SetScript('OnMouseDown',function(self, d)
        if d=='LeftButton' then
            if not IsInGuild() then-- and not InCombatLockdown() then
                ToggleGuildFrame()
                self:CloseMenu()
                self:set_tooltip()
            else
                WoWTools_ChatMixin:Say('/g')
                self:set_tooltip()
            end
        end
    end)]]




--菜单
    WoWTools_GuildMixin:Init_Menu()

--事件

    btn:RegisterEvent('GUILD_ROSTER_UPDATE')
    btn:RegisterEvent('PLAYER_GUILD_UPDATE')

    btn:RegisterEvent('CLUB_FINDER_RECRUITMENT_POST_RETURNED')
    btn:RegisterEvent('CLUB_FINDER_RECRUITS_UPDATED')
    btn:RegisterEvent('CLUB_FINDER_APPLICATIONS_UPDATED')
    btn:RegisterEvent('CLUB_FINDER_POST_UPDATED')--C_ClubFinder.RequestPostingInformationFromClubId
    btn:RegisterEvent('CLUB_MESSAGE_UPDATED')


    btn:SetScript('OnEvent', function(self, event, arg1)
        if
--更新，数据
            event=='PLAYER_GUILD_UPDATE'
            or event=='GUILD_ROSTER_UPDATE'
            or event=='CLUB_FINDER_RECRUITMENT_POST_RETURNED'

        then
            Set_Text(self)

--公会创立，信息
        elseif event=='CHAT_MSG_SYSTEM' then
            if arg1 and arg1:find(G_GUILD_INFO_TEMPLATE) then
                WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild.text= arg1
                self:UnregisterEvent(event)
            end

        else
            self:set_new_application()
        end
    end)



    Set_Text(btn)

    btn:set_guildinfo_event()
    btn:set_new_application(WoWTools_GuildMixin:IsLeaderOrOfficer())--申请者

    Init=function()end
end











function WoWTools_GuildMixin:Init_Button()
    Init(WoWTools_ChatMixin:GetButtonForName('Guild'))
end