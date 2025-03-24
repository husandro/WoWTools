local P_Save={
    --disabled=true,--禁用

    line=2,
    num=15,
    scale=0.85,

    --showIndex=true,--显示，索引
    showBackground= true,--设置，背景


    left_List= true,
    showLeftList=true,--大包时，显示，存取，分类，按钮
    --leftListScale=1,
    --hideLeftListTooltip=true,

    openBagInBank=WoWTools_DataMixin.Player.husandro,

    --disabledBankBag=true,--银行背包
    --disabledReagentFrame= true,--材料银行
    --disabledAccountBag= true,--战团银行

    allAccountBag=true,--战团银行,整合

    guild={
        line=2,
        num=20,
    }
}


local function Save()
    return WoWToolsSave['Plus_Bank'] or {}
end


local function Init()
    WoWTools_BankMixin:Init_Menu()
    WoWTools_BankMixin:Init_MoveFrame()
    WoWTools_BankMixin:Init_Plus()--整合，一起
    WoWTools_BankMixin:Init_UI()--存放，取出，所有
    WoWTools_BankMixin:Init_Left_List()
    WoWTools_BankMixin:Set_PortraitButton()
    return true
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("BANKFRAME_OPENED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Bank']= WoWToolsSave['Plus_Bank'] or P_Save

            WoWTools_BankMixin.addName= '|A:Banker:0:0|a'..(WoWTools_Mixin.onlyChinese and '银行' or BANK)

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_BankMixin.addName,
                GetValue=function() return not WoWToolsSave['Plus_Bank'].disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    if not Save().disabled and Init() then
                        Init=function()end
                    else
                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_BankMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_Mixin.onlyChinese and '重新加载UI' or RELOADUI)
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
        if Init() then
            Init=function()end
        end
        self:UnregisterEvent(event)
    end
end)


