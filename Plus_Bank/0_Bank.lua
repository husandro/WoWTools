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

    --disabledReagentFrame=true,材料银行
},
}


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
    if Save().disabled then
        return
    end

    WoWTools_BankMixin:Init_Menu()
    WoWTools_BankMixin:Init_MoveFrame()

    WoWTools_BankMixin:Init_Plus()--整合，一起
    WoWTools_BankMixin:Init_UI()--存放，取出，所有
    WoWTools_BankMixin:Init_Left_List()

    return true
end















EventRegistry:RegisterFrameEventAndCallback('BANKFRAME_OPENED', function()
    if Init() then Init=function() end end
end)








EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(_, arg1)
    if arg1~=id then
        return
    end

    WoWTools_BankMixin.Save= WoWToolsSave['Plus_Bank'] or WoWTools_BankMixin.Save
    WoWTools_BankMixin.addName= '|A:Banker:0:0|a'..(e.onlyChinese and '银行' or BANK)

    --添加控制面板
    e.AddPanel_Check({
        name= WoWTools_BankMixin.addName,
        GetValue=function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            if Init() then
                Init=function()end
            else
                print(WoWTools_Mixin.addName, WoWTools_BankMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '重新加载UI' or RELOADUI)        
            end
        end
    })
end)



EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
    if not e.ClearAllSave then
        WoWToolsSave['Plus_Bank']= WoWTools_BankMixin.Save
    end
end)




