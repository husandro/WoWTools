local P_Save={
    --disabledPetitionTarget=true,新建，自动要求签名目标
    --guildInfo=true,公会信息
    --showNotOnLine=true,
    --subGuildName= number or nil,截取公会名称
}







--保存公会数据，到WOW
local function Save_WoWGuild()
    if IsInGuild() then
        local clubID= C_Club.GetGuildClubId()

        if clubID then
            WoWTools_GuildMixin:Load_Club(clubID)
        end

        local club= clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or {}
        local guildName, guildRankName, guildRankIndex, realm= GetGuildInfo('player')

        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild= {
            guid= club.clubFinderGUID,
            link= WoWTools_GuildMixin:GetClubLink(clubID, club.clubFinderGUID),
            clubID= clubID,
            data={guildName, guildRankName, guildRankIndex, realm or WoWTools_DataMixin.Player.realm},
            text= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild.text
        }

    else
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Guild= {data={}}
    end
end











local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_GUILD_UPDATE')
panel:RegisterEvent('LOADING_SCREEN_DISABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['ChatButtonGuild']= WoWToolsSave['ChatButtonGuild'] or P_Save

            WoWTools_GuildMixin.addName= '|A:UI-HUD-MicroMenu-GuildCommunities-Up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '公会' or GUILD)

            WoWTools_GuildMixin.GuildButton= WoWTools_ChatMixin:CreateButton('Guild', WoWTools_GuildMixin.addName)

            if WoWTools_GuildMixin.GuildButton then
                self:UnregisterEvent(event)
                C_ClubFinder.RequestSubscribedClubPostingIDs()
            else
                self:UnregisterAllEvents()
            end
        end

    elseif event=='LOADING_SCREEN_DISABLED' and WoWToolsSave then
        WoWTools_GuildMixin:Init_Button()
        WoWTools_GuildMixin:Init_ClubFinder()
        WoWTools_GuildMixin:Plus_CommunitiesFrame()--社区 Plus
        WoWTools_GuildMixin:Init_PetitionFrame()--新建，公会, 签名 OfferPetition

        Save_WoWGuild()--保存公会数据，到WOW

        self:UnregisterEvent(event)

    elseif event=='PLAYER_GUILD_UPDATE' then
        Save_WoWGuild()--保存公会数据，到WOW
    end
end)