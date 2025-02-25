local id, e = ...
WoWTools_BankMixin={
Save={
    --disabled=true,--禁用

    line=2,
    num=15,

    --showIndex=true,--显示，索引
    showBackground= true,--设置，背景


    left_List= true,
    showLeftList=true,--大包时，显示，存取，分类，按钮
    --leftListScale=1,

    openBagInBank=e.Player.husandro,

    --disabledBankBag=true,--银行背包
    disabledReagentFrame= not e.Player.husandro,--材料银行
    disabledAccountBag= not e.Player.husandro,--战团银行
},
}
--local index= BankFrame.activeTabIndex

local function Save()
    return WoWTools_BankMixin.Save
end





--银行，空位
function WoWTools_BankMixin:GetFree()
    local free= 0
    for i=1, NUM_BANKGENERIC_SLOTS do--28        
        if not self:GetItemInfo(BankSlotsFrame["Item"..i]) then
            free= free+1
        end
    end
    for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if not info or not info.itemID then
                free= free+ 1
            end
        end
    end
    return free
end


function WoWTools_BankMixin:GetItemInfo(button)
    if button then
        local info = C_Container.GetContainerItemInfo(self:GetBagAndSlot(button))
        if info and info.itemID then
            return info
        end
    end
end


function WoWTools_BankMixin:GetBagAndSlot(button)
    return button.isBag and Enum.BagIndex.Bankbag
        or button:GetParent():GetID(),

        button:GetID()
end

function WoWTools_BankMixin:OpenBag(bagID)
    if bagID then
        ToggleBag(bagID)
    else
        for i=1, 7 do
            ToggleBag(i+NUM_TOTAL_EQUIPPED_BAG_SLOTS);
        end
    end
end

function WoWTools_BankMixin:CloseBag(bagID)
    if bagID then
        CloseBag(bagID)
    else
        for i=1, 7 do
            CloseBag(i+NUM_TOTAL_EQUIPPED_BAG_SLOTS);
        end
    end
end


function WoWTools_BankMixin:Set_Background_Texture(texture)
    if texture then
        if self.Save.showBackground then
            texture:SetAtlas('bank-frame-background')
        else
            texture:SetTexture(0)
            --texture:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
        end
    end
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


