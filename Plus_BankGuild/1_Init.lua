--WoWTools_GuildBankMixin={}
local P_Save={
    showIndex=true,
    plusItem=true,
    plusTab=true,

    autoOpenBags=WoWTools_DataMixin.Player.husandro,--自动，打开背包
    --autoOutMoney=0,--自动取钱，0：全部提取 数值：指定数量 nil:禁用
    onlyMemberOutMoney=true,--仅限成员

    saveItemSeconds=0.8,--保存，提取物品，延迟
    sortRightToLeft=true,--排序，从后到前
}

--[[--旧数据
    line=0,
    num=20,
    BgAplha=1,--背景ALPHA
    showIndex=true,
    autoOpenBags=WoWTools_DataMixin.Player.husandro,--自动，打开背包
    plusOnlyOfficerAndLeader=true,

    saveItemSeconds=0.8,--保存，提取物品，延迟
    sortRightToLeft=true,--排序，从后到前
]]




local function Save()
    return WoWToolsSave['Plus_GuildBank']
end





local function Init()
    WoWTools_GuildBankMixin:Init_Plus()
    WoWTools_GuildBankMixin:Init_Menu()
    WoWTools_GuildBankMixin:Init_Sort()
    WoWTools_GuildBankMixin:Init_InOut_Item()
    WoWTools_GuildBankMixin:Init_Out_Money()

--自动，打开背包 
    GuildBankFrame:HookScript('OnShow', function(self)
        if WoWToolsSave['Plus_GuildBank'].autoOpenBags and not InCombatLockdown() then
            do
                WoWTools_BagMixin:OpenBag(nil, false)
            end
            if not InCombatLockdown() then
                self:Raise()
            end
        end
    end)

    Init=function()end
end













local panel= CreateFrame("Frame")

panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Plus_GuildBank']= WoWToolsSave['Plus_GuildBank'] or CopyTable(P_Save)
            P_Save=nil

            WoWTools_GuildBankMixin.addName= '|A:VignetteLoot:0:0|a'..(WoWTools_DataMixin.onlyChinese and '公会银行' or GUILD_BANK)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_GuildBankMixin.addName,
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_GuildBankMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI
                    )
                end
            })

            if Save().disabled then
                self:UnregisterEvent(event)

            elseif C_AddOns.IsAddOnLoaded('Blizzard_GuildBankUI') then
                if Init() then
                    Init=function()end
                end
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_GuildBankUI' and WoWToolsSave then
            Init()
            self:UnregisterEvent(event)
        end
    end
end)