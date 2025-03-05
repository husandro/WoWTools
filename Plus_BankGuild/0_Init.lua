local id, e = ...
WoWTools_GuildBankMixin={
    Save={
        line=2,
        num=20,
    }
}




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_GuildBankMixin.Save= WoWToolsSave['Plus_GuildBank'] or WoWTools_GuildBankMixin.Save

            local addName= '|A:ChallengeMode-Chest:0:0|a'..(e.onlyChinese and '公会银行' or GUILD_BANK)
            WoWTools_GuildBankMixin.addName= addName

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                GetValue=function() return not WoWTools_GuildBankMixin.Save.disabled end,
                SetValue= function()
                    WoWTools_GuildBankMixin.Save.disabled= not WoWTools_GuildBankMixin.Save.disabled and true or nil
                    print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not WoWTools_GuildBankMixin.Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if WoWTools_GuildBankMixin.Save.disabled then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_GuildBankUI' then
            WoWTools_GuildBankMixin:Init_Plus()
            WoWTools_GuildBankMixin:Init_Guild_Texture()
            WoWTools_GuildBankMixin:Init_GuildMenu()
            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_GuildBank']= WoWTools_GuildBankMixin.Save
        end
    end
end)