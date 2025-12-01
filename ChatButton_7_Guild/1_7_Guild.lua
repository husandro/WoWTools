local P_Save={
    --disabledPetitionTarget=true,新建，自动要求签名目标
    --guildInfo=true,公会信息
    --showNotOnLine=true,
    --subGuildName= number or nil,截取公会名称
}









local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['ChatButtonGuild']= WoWToolsSave['ChatButtonGuild'] or P_Save
            P_Save=nil

            WoWTools_GuildMixin.addName= '|A:UI-HUD-MicroMenu-GuildCommunities-Up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '公会' or GUILD)

            if WoWTools_ChatMixin:CreateButton('Guild', WoWTools_GuildMixin.addName) then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                C_ClubFinder.RequestSubscribedClubPostingIDs()
            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_GuildMixin:Init_Button()
        WoWTools_GuildMixin:Init_Menu()--菜单
        WoWTools_GuildMixin:Init_ClubFinder()
        WoWTools_GuildMixin:Plus_CommunitiesFrame()--社区 Plus
        WoWTools_GuildMixin:Init_PetitionFrame()--新建，公会, 签名 OfferPetition

        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)