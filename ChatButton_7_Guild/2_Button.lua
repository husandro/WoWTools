local e= select(2, ...)
local function Save()
    return WoWTools_GuildMixin.Save
end
local GuildButton
local G_GUILD_INFO_TEMPLATE= GUILD_INFO_TEMPLATE:gsub('(%%.+)', '')--公会创立





local function Set_Text(self)
    local isInGuild= IsInGuild()

    --设置背景
    if isInGuild then
        self.texture2:SetAtlas(
            isInGuild and 'UI-HUD-MicroMenu-GuildCommunities-Up'
            or (e.Player.faction=='Alliance' and 'honorsystem-prestige-laurel-bg-alliance')
            or (e.Player.faction=='Horde' and 'honorsystem-prestige-laurel-bg-horde')
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
    self.membersText:SetText(online>1 and online-1 or '')


    if isInGuild then
--弹劾
        if CanReplaceGuildMaster() then--弹劾
            self.bottomText:SetText(e.onlyChinese and '弹' or  WoWTools_TextMixin:sub(GUILD_IMPEACH_POPUP_CONFIRM, 2, 5,true))
        elseif WoWTools_GuildMixin:IsLeaderOrOfficer() and CanGuildInvite() then
            self.bottomText:SetText(WoWTools_GuildMixin:GetClubFindDay(nil) or '')--Club,列出查找，过期时间
        end
    else
        self.bottomText:SetText('')
    end
end










local function Init()
    GuildButton= WoWTools_ChatButtonMixin:CreateButton('Guild', WoWTools_GuildMixin.addName)

    if not GuildButton then
        return
    end


    GuildButton.texture:ClearAllPoints()
    GuildButton.texture:SetPoint('CENTER', -1.5, 1)
    GuildButton.texture:SetSize(18,18)

    GuildButton.texture2= GuildButton:CreateTexture(nil, 'BACKGROUND', nil, 2)
    GuildButton.texture2:SetPoint("TOPLEFT", GuildButton, "TOPLEFT", -14, 14)
    GuildButton.texture2:SetPoint("BOTTOMRIGHT", GuildButton, "BOTTOMRIGHT", 14, -14)



    GuildButton.mask:SetPoint("TOPLEFT", GuildButton, "TOPLEFT", 5.5, -5.5)
    GuildButton.mask:SetPoint("BOTTOMRIGHT", GuildButton, "BOTTOMRIGHT", -8, 8)
    GuildButton.texture2:AddMaskTexture(GuildButton.mask)

    GuildButton.messageTexture= GuildButton:CreateTexture(nil, 'OVERLAY')
    GuildButton.messageTexture:SetPoint('TOPLEFT',-2,2)
    GuildButton.messageTexture:SetAtlas('communities-icon-notification')
    GuildButton.messageTexture:SetSize(16,16)

    GuildButton.membersText=WoWTools_LabelMixin:Create(GuildButton, {color={r=1,g=1,b=1}})-- 10, nil, nil, true, nil, 'CENTER')
    GuildButton.membersText:SetPoint('TOPRIGHT', -3, 0)

    GuildButton.bottomText= WoWTools_LabelMixin:Create(GuildButton, {size=10, color=true, justifyH='CENTER'})
    GuildButton.bottomText:SetPoint('BOTTOM', 0, 2)


    function GuildButton:set_guildinfo_event()
        self:UnregisterEvent('CHAT_MSG_SYSTEM')
        if IsInGuild() and (Save().guildInfo or not e.WoWDate[e.Player.guid].Guild.text) then
            self:RegisterEvent('CHAT_MSG_SYSTEM')
            GuildInfo()
        end
    end

--申请者
    function GuildButton:set_new_application(isInit)
        local clubs= C_Club.GetSubscribedClubs()
        for _, data in pairs(clubs or {}) do
            if WoWTools_GuildMixin:GetApplicantList(data.clubId) then
                self.messageTexture:SetShown(true)
                if isInit then
                    print(e.Icon.icon2..WoWTools_GuildMixin.addName,
                        '|cnGREEN_FONT_COLOR:'
                        ..(e.onlyChinese and '新' or NEW)..'|A:communities-icon-notification:0:0|a'
                        ..(e.onlyChinese and '申请人' or CLUB_FINDER_APPLICANTS)
                    )
                end
                return
            end
        end
        self.messageTexture:SetShown(false)
    end

    function GuildButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        if not IsInGuild() then
            GameTooltip:AddLine('|cff9e9e9e'..(e.onlyChinese and '无公会' or ITEM_REQ_PURCHASE_GUILD)..e.Icon.left)
        else
            WoWTools_GuildMixin:Load_Club(nil)--加载，Club,数据
        end
        WoWTools_GuildMixin:OnEnter_GuildInfo()--公会，社区，信息
        GameTooltip:Show()
    end




    GuildButton:SetScript('OnMouseDown',function(self, d)
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
    end)




--菜单
    WoWTools_GuildMixin:Init_Menu(GuildButton)

--事件
    GuildButton:RegisterEvent('GUILD_ROSTER_UPDATE')
    GuildButton:RegisterEvent('PLAYER_GUILD_UPDATE')

    --GuildButton:RegisterEvent('CLUB_FINDER_RECRUITMENT_POST_RETURNED')
    GuildButton:RegisterEvent('CLUB_FINDER_RECRUITS_UPDATED')
    GuildButton:RegisterEvent('CLUB_FINDER_APPLICATIONS_UPDATED')
    GuildButton:RegisterEvent('CLUB_FINDER_POST_UPDATED')--C_ClubFinder.RequestPostingInformationFromClubId

    GuildButton:RegisterEvent('PLAYER_ENTERING_WORLD')

    GuildButton:SetScript('OnEvent', function(self, event, arg1)
--初始
        if event=='PLAYER_ENTERING_WORLD' then
            C_ClubFinder.RequestSubscribedClubPostingIDs()
            self:set_guildinfo_event()
            Set_Text(self)
            self:set_new_application(Save().guildInfo)--申请者
            self:UnregisterEvent(event)

        elseif
--更新，数据
            event=='PLAYER_GUILD_UPDATE'
            or event=='GUILD_ROSTER_UPDATE'
            or (event=='CLUB_FINDER_RECRUITMENT_POST_RETURNED' and arg1==Enum.ClubFinderRequestType.Guild)

        then
            Set_Text(self)

--公会创立，信息
        elseif event=='CHAT_MSG_SYSTEM' then
            if arg1 and arg1:find(G_GUILD_INFO_TEMPLATE) then
                e.WoWDate[e.Player.guid].Guild.text= arg1
                self:UnregisterEvent(event)
            end

        elseif--申请者
            event == 'CLUB_FINDER_RECRUITS_UPDATED'
            or event == 'CLUB_FINDER_APPLICATIONS_UPDATED'
            or event=='CLUB_FINDER_POST_UPDATED'
        then

            GuildButton:set_new_application()

        end
    end)
    return true
end











function WoWTools_GuildMixin:Init_Button()
    if Init() then
        Init=function()end
        return true
    end
end