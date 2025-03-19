
local id, e = ...

WoWTools_GuildMixin.Save={
    --disabledPetitionTarget=true,新建，自动要求签名目标
    --guildInfo=true,公会信息
    --showNotOnLine=true,
    --subGuildName= number or nil,截取公会名称
}


local GuildButton





--保存公会数据，到WOW
local function Save_WoWGuild()
    if IsInGuild() then
        local clubID= C_Club.GetGuildClubId()

        if clubID then
            WoWTools_GuildMixin:Load_Club(clubID)
        end

        local club= clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or {}
        local guildName, guildRankName, guildRankIndex, realm= GetGuildInfo('player')

        e.WoWDate[e.Player.guid].Guild= {
            guid= club.clubFinderGUID,
            link= WoWTools_GuildMixin:GetClubLink(clubID, club.clubFinderGUID),
            clubID= clubID,
            data={guildName, guildRankName, guildRankIndex, realm or e.Player.realm},
            text= e.WoWDate[e.Player.guid].Guild.text
        }

    else
        e.WoWDate[e.Player.guid].Guild= {data={}}
    end
end






local function Init()
    if not GuildButton then
        return
    end

    C_ClubFinder.RequestSubscribedClubPostingIDs()

    WoWTools_GuildMixin:Init_Button()
    WoWTools_GuildMixin:Init_ClubFinder()
    WoWTools_GuildMixin:Plus_CommunitiesFrame()--社区 Plus
    WoWTools_GuildMixin:Init_PetitionFrame()--新建，公会, 签名 OfferPetition
end


local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')

panel:RegisterEvent('PLAYER_ENTERING_WORLD')--保存公会数据，到WOW
panel:RegisterEvent('PLAYER_GUILD_UPDATE')
panel:RegisterEvent('PLAYER_LOGIN')


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_GuildMixin.Save= WoWToolsSave['ChatButtonGuild'] or WoWTools_GuildMixin.Save

            local addName= '|A:UI-HUD-MicroMenu-GuildCommunities-Up:0:0|a'..(e.onlyChinese and '公会' or GUILD)
            WoWTools_GuildMixin.addName= addName

            GuildButton= WoWTools_ChatMixin:CreateButton('Guild', WoWTools_GuildMixin.addName)
            WoWTools_GuildMixin.GuildButton= GuildButton

            if not GuildButton  then
                self:UnregisterEvent('PLAYER_ENTERING_WORLD')
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_LOGIN' then
        Init()
        Save_WoWGuild()--保存公会数据，到WOW
        self:UnregisterEvent(event)

    elseif event=='PLAYER_GUILD_UPDATE' then
        Save_WoWGuild()--保存公会数据，到WOW

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButtonGuild']= WoWTools_GuildMixin.Save
        end
    end
end)