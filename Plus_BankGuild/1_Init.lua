local id, e = ...
WoWTools_GuildBankMixin.Save={
    line=0,
    num=20,
    BgAplha=1,--背景ALPHA
    showIndex=true,
    autoOpenBags=e.Player.husandro,--自动，打开背包
    plusOnlyOfficerAndLeader=true,

    saveItemSeconds=0.8,--保存，提取物品，延迟
    sortRightToLeft=true,--排序，从后到前
}







local function Init()
    if WoWTools_TextureMixin.Events.Blizzard_GuildBankUI then
        WoWTools_TextureMixin.Events:Blizzard_GuildBankUI(WoWTools_TextureMixin)
        WoWTools_TextureMixin.Events.Blizzard_GuildBankUI=nil
    end

    WoWTools_GuildBankMixin:Init_Plus()
    WoWTools_GuildBankMixin:Init_GuildMenu()
    WoWTools_GuildBankMixin:Init_Plus_Sort()

--自动，打开背包 
    GuildBankFrame:HookScript('OnShow', function(self)
        if WoWTools_GuildBankMixin.Save.autoOpenBags then
            do
                WoWTools_BagMixin:OpenBag(nil, false)
            end
            self:Raise()
        end
    end)
end













local panel= CreateFrame("Frame")

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWTools_GuildBankMixin.Save= WoWToolsSave['Plus_GuildBank'] or WoWTools_GuildBankMixin.Save

            local addName= '|A:VignetteLoot:0:0|a'..(WoWTools_Mixin.onlyChinese and '公会银行' or GUILD_BANK)
            WoWTools_GuildBankMixin.addName= addName

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                GetValue=function() return not WoWTools_GuildBankMixin.Save.disabled end,
                SetValue= function()
                    WoWTools_GuildBankMixin.Save.disabled= not WoWTools_GuildBankMixin.Save.disabled and true or nil
                    print(e.Icon.icon2.. addName, e.GetEnabeleDisable(not WoWTools_GuildBankMixin.Save.disabled), WoWTools_Mixin.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if WoWTools_GuildBankMixin.Save.disabled then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_GuildBankUI' then
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_GuildBank']= WoWTools_GuildBankMixin.Save
        end
    end
end)