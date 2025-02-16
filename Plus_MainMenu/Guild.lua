
--公会 GuildMicroButton
local e= select(2, ...)









local function Init()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(GuildMicroButton,  {size=WoWTools_MainMenuMixin.Save.size, color=true})
    frame.Text:SetPoint('TOP', GuildMicroButton, 0,  -3)

    frame.Text2= WoWTools_LabelMixin:Create(GuildMicroButton,  {size=WoWTools_MainMenuMixin.Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', GuildMicroButton, 0, 3)

    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)
    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text2)

    GuildMicroButton.Text2= frame.Text2

    function frame:settings()
        local online = select(2, GetNumGuildMembers())
        self.Text:SetText((online and online>1) and online-1 or '')

        online=0
        local guildClubId= C_Club.GetGuildClubId()
        for _, tab in pairs(C_Club.GetSubscribedClubs() or {}) do
            local members= C_Club.GetClubMembers(tab.clubId) or {}
            if tab.clubId~=guildClubId then
                for _, memberID in pairs(members) do--CommunitiesUtil.GetOnlineMembers
                    local info = C_Club.GetMemberInfo(tab.clubId, memberID) or {}
                    if not info.isSelf and info.presence~=Enum.ClubMemberPresence.Offline and info.presence~=Enum.ClubMemberPresence.Unknown then--CommunitiesUtil.GetOnlineMembers()
                        online= online+1
                    end
                end
            end
        end
        self.Text2:SetText(online>0 and online or '')
    end
    local COMMUNITIES_LIST_EVENTS = {
        "CLUB_ADDED",
        "CLUB_REMOVED",
        "CLUB_UPDATED",
        "CLUB_INVITATION_ADDED_FOR_SELF",
        "CLUB_INVITATION_REMOVED_FOR_SELF",
        "GUILD_ROSTER_UPDATE",
        "CLUB_STREAMS_LOADED",
        "PLAYER_GUILD_UPDATE",
    }
    FrameUtil.RegisterFrameForEvents(frame, COMMUNITIES_LIST_EVENTS)
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    GuildMicroButton:HookScript('OnEnter', function(self)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        if IsInGuild() then
            e.tips:AddLine(' ')
        end
        e.Get_Guild_Enter_Info()
        e.tips:Show()
        local all= GetNumGuildMembers() or 0
        self.Text2:SetText(all>0 and all or '')
    end)
end









function WoWTools_MainMenuMixin:Init_Guild()--公会
    Init()
end