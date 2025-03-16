
local id, e = ...

WoWTools_GuildMixin.Save={
    --disabledPetitionTarget=true,新建，自动要求签名目标
    --guildInfo=true,公会信息
    --showNotOnLine=true,
}




local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_GuildMixin.Save= WoWToolsSave['ChatButtonGuild'] or WoWTools_GuildMixin.Save

            local addName= '|A:UI-HUD-MicroMenu-GuildCommunities-Up:0:0|a'..(e.onlyChinese and '公会' or GUILD)
            WoWTools_GuildMixin.addName= addName
           
            if WoWTools_GuildMixin:Init_Button() then--禁用Chat Button
                WoWTools_GuildMixin:Init_ClubFinder()
                WoWTools_GuildMixin:Init_PetitionFrame()--新建，公会, 签名 OfferPetition
                WoWTools_GuildMixin:Plus_CommunitiesFrame()--社区 Plus
            end
            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButtonGuild']= WoWTools_GuildMixin.Save
        end
    end
end)