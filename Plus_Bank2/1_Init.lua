if BankFrameTab2 then
    return
end


local P_Save={

}


local function Save()
    return WoWToolsSave['Plus_Bank2'] or {}
end


local function Init()
    if Save().disabled then
        return
    end

    WoWTools_BankMixin:Init_UI2()
    Init=function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("BANKFRAME_OPENED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Bank2']= Save() or P_Save

            WoWTools_BankMixin.addName= '|A:Banker:0:0|a'..(WoWTools_DataMixin.onlyChinese and '银行' or BANK)

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_BankMixin.addName,
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    
                    Init()

                    if Save().disabled  then
                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_BankMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
                    end
                end
            })

            if Save().disabled then
                self:UnregisterAllEvents()
            else
                self:UnregisterEvent(event)
            end
        end

    elseif event=='BANKFRAME_OPENED' then
        Init()
        self:UnregisterEvent(event)
    end
end)


