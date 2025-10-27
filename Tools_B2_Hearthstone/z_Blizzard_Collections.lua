--玩具界面, 按钮

local function Save()
    return WoWToolsSave['Tools_Hearthstone']
end







local function Remove_Toy(itemID)--移除
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('Hearthstone')
    if not btn then
        return
    end

    Save().items[itemID]=nil
    local isSelect, isLock= btn:Check_Random_Value(itemID)
    if isLock or isSelect then
        if isSelect then
            btn:Set_SelectValue_Random(nil)
        end
        if isLock then
            Save().lockedToy=nil
            btn:Set_LockedValue_Random(nil)
        end
    elseif btn.itemID==itemID then
        btn:Init_Random(Save().lockedToy)
    end

    print(
        WoWTools_HearthstoneMixin.addName..WoWTools_DataMixin.Icon.icon2,
        WoWTools_DataMixin.onlyChinese and '移除' or REMOVE,
        WoWTools_ItemMixin:GetLink(itemID)
    )
end



local function Add_Remove_Toy(itemID)--移除/添加
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('Hearthstone')
    if itemID and btn then
        if Save().items[itemID] then
            Remove_Toy(itemID)--移除
        else--添加
            Save().items[itemID]= true
            if btn then
                btn:Init_Random(Save().lockedToy)--初始
            end
        end
    end
end









local function Create_Button(btn)--标记, 是否已选取
    btn.hearthstone= WoWTools_ButtonMixin:Cbtn(btn,{size=16, texture=134414})
    btn.hearthstone:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT')

    function btn.hearthstone:get_itemID()
        return self:GetParent().itemID
    end
    function btn.hearthstone:set_alpha()
        self:SetAlpha(Save().items[self:get_itemID()] and 1 or 0.1)
    end
    function btn.hearthstone:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HearthstoneMixin.addName)
        GameTooltip:AddLine(' ')
        local itemID=self:get_itemID()
        local icon= C_Item.GetItemIconByID(itemID)
        GameTooltip:AddDoubleLine(
            (icon and '|T'..icon..':0|t' or '')..(itemID and C_ToyBox.GetToyLink(itemID) or itemID),
            WoWTools_TextMixin:GetEnabeleDisable(Save().items[itemID])..WoWTools_DataMixin.Icon.left
        )
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        self:SetAlpha(1)
    end
    btn.hearthstone:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Add_Remove_Toy(self:get_itemID())--移除/添加
            self:set_tooltips()
            self:set_alpha()
        else
            MenuUtil.CreateContextMenu(self, function(...)
                WoWTools_HearthstoneMixin:Init_Menu_Toy(...)
            end)
        end
    end)
    btn.hearthstone:SetScript('OnLeave', function(self) GameTooltip:Hide() self:set_alpha() end)
    btn.hearthstone:SetScript('OnEnter', function(self) self:set_tooltips() end)
end







local function Init()
    WoWTools_DataMixin:Hook('ToySpellButton_UpdateButton', function(btn)--标记, 是否已选取
        if not btn.hearthstone then
            Create_Button(btn)
        end
        btn.hearthstone:set_alpha()
    end)
    Init=function()end
end





function WoWTools_HearthstoneMixin:Blizzard_Collections()
    Init()
end

function WoWTools_HearthstoneMixin:Remove_Toy(itemID)
    Remove_Toy(itemID)
end