local P_Save={
    --disabledPetitionTarget=true,新建，自动要求签名目标
    --guildInfo=true,公会信息
    --showNotOnLine=true,
    --subGuildName= number or nil,截取公会名称
}









local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

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

    elseif event=='PLAYER_ENTERING_WORLD' and WoWToolsSave then
        WoWTools_GuildMixin:Init_Button()
        WoWTools_GuildMixin:Init_ClubFinder()
        WoWTools_GuildMixin:Plus_CommunitiesFrame()--社区 Plus
        WoWTools_GuildMixin:Init_PetitionFrame()--新建，公会, 签名 OfferPetition

        self:UnregisterEvent(event)
    end
end)