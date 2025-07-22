
if BankFrameTab2 then
    return
end
WoWTools_BankMixin={}
local P_Save={
    line=2,
    num=20,

    plusTab=true,
    plusIndex=true,
    plusItem=true,

    autoSaveMoney= WoWTools_DataMixin.Player.husandro and 500,--大于当前值，自动存放多余的金到银行去
    autoOutMoney= WoWTools_DataMixin.Player.husandro and 100,
    filterSaveMoney={},--[guid]=true
    allBank=WoWTools_DataMixin.Player.husandro,--整合银行
}


local function Save()
    return WoWToolsSave['Plus_Bank2']
end


local function Init()
    WoWTools_BankMixin:Init_AllBank()
    WoWTools_BankMixin:Init_BankPlus()
    WoWTools_BankMixin:Init_BankMenu()
    WoWTools_BankMixin:Init_Out_Plus()
    WoWTools_BankMixin:Init_In_Plus()
    WoWTools_BankMixin:Init_Money_Plus()
    
    Init=function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("BANKFRAME_OPENED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Bank2']= Save() or P_Save
            
            Save().filterSaveMoney=  Save().filterSaveMoney or {}
            WoWToolsSave['Plus_Bank']= nil

            WoWTools_BankMixin.addName= '|A:Banker:0:0|a'..(WoWTools_DataMixin.onlyChinese and '银行' or BANK)

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_BankMixin.addName,
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil

                    if Save().disabled  then
                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_BankMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
                    else
                        Init()
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


