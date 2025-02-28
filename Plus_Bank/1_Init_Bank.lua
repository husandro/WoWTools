local id, e = ...
WoWTools_BankMixin.Save={
    --disabled=true,--禁用

    line=2,
    num=15,

    --showIndex=true,--显示，索引
    showBackground= true,--设置，背景


    left_List= true,
    showLeftList=true,--大包时，显示，存取，分类，按钮
    --leftListScale=1,
    --hideLeftListTooltip=true,

    openBagInBank=e.Player.husandro,

    --disabledBankBag=true,--银行背包
    disabledReagentFrame= not e.Player.husandro,--材料银行
    disabledAccountBag= not e.Player.husandro,--战团银行

    allAccountBag=e.Player.husandro,--战团银行,整合
}



local function Save()
    return WoWTools_BankMixin.Save
end

















--银行
--BankFrame.lua
local function Init()
    WoWTools_BankMixin:Init_Menu()
    WoWTools_BankMixin:Init_MoveFrame()

    WoWTools_BankMixin:Init_Plus()--整合，一起
    WoWTools_BankMixin:Init_UI()--存放，取出，所有
    WoWTools_BankMixin:Init_Left_List()

    return true
end















EventRegistry:RegisterFrameEventAndCallback('BANKFRAME_OPENED', function(owner)
    if not Save().disabled and Init() then
        Init=function() end
        EventRegistry:UnregisterCallback('BANKFRAME_OPENED', owner)
    end
end)





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_BankMixin.Save= WoWToolsSave['Plus_Bank'] or WoWTools_BankMixin.Save

            local addName= '|A:Banker:0:0|a'..(e.onlyChinese and '银行' or BANK)
            WoWTools_BankMixin.addName= addName

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if  Save().disabled then
                self:UnregisterEvent(event)
            else
                self:RegisterEvent('BANKFRAME_OPENED')
            end
        end

    elseif event=='BANKFRAME_OPENED' then
        Init()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Bank']=Save()
        end
    end
end)


