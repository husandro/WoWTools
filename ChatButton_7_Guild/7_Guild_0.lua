
local id, e = ...

WoWTools_GuildMixin.Save={
    --disabledPetitionTarget=true,新建，自动要求签名目标
    --guildInfo=true,公会信息
    --showNotOnLine=true,
}




local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')
panel:RegisterEvent('CLUB_FINDER_RECRUITMENT_POST_RETURNED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_GuildMixin.Save= WoWToolsSave['ChatButtonGuild'] or WoWTools_GuildMixin.Save

            local addName= '|A:UI-HUD-MicroMenu-GuildCommunities-Up:0:0|a'..(e.onlyChinese and '公会' or GUILD)
            WoWTools_GuildMixin.addName= addName

            C_Timer.After(3, function()
                WoWTools_GuildMixin:Load_Club(nil)--加载，Club,数据
            end)

            if WoWTools_GuildMixin:Init_Button() then--禁用Chat Button
                WoWTools_GuildMixin:Init_ClubFinder()
                WoWTools_GuildMixin:Init_PetitionFrame()--新建，公会, 签名 OfferPetition
                WoWTools_GuildMixin:Plus_CommunitiesFrame()--社区 Plus
            end

            self:UnregisterEvent(event)
        end

    elseif event == 'CLUB_FINDER_RECRUITMENT_POST_RETURNED' then--保存公会数据，到WOW
        if arg1==Enum.ClubFinderRequestType.Guild or arg1==Enum.ClubFinderRequestType.All then
            if IsInGuild() then
                local clubID= C_Club.GetGuildClubId()
                local club= clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or {}
                local guildName, guildRankName, guildRankIndex, realm= GetGuildInfo('player')
                local text= e.WoWDate[e.Player.guid].Guild.text

                e.WoWDate[e.Player.guid].Guild= {
                   guid= club.clubFinderGUID,
                    link= GetClubFinderLink(club.clubFinderGUID, club.name),
                    clubID= clubID,
                    data={guildName, guildRankName, guildRankIndex, realm or e.Player.realm},
                    text= text
                }
            else
                e.WoWDate[e.Player.guid].Guild= {
                    data={},
                }
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButtonGuild']= WoWTools_GuildMixin.Save
        end
    end
end)