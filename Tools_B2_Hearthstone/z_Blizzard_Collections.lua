--玩具界面, 按钮
local e= select(2, ...)
local function Save()
    return WoWTools_HearthstoneMixin.Save
end







local function Remove_Toy(itemID)--移除
    local ToyButton= WoWTools_HearthstoneMixin.ToyButton

    Save().items[itemID]=nil
    local isSelect, isLock= ToyButton:Check_Random_Value(itemID)
    if isLock or isSelect then
        if isSelect then
            ToyButton:Set_SelectValue_Random(nil)
        end
        if isLock then
            Save().lockedToy=nil
            ToyButton:Set_LockedValue_Random(nil)
        end
    elseif ToyButton.itemID==itemID then
        ToyButton:Init_Random(Save().lockedToy)
    end

    print(e.Icon.icon2..WoWTools_HearthstoneMixin.addName, e.onlyChinese and '移除' or REMOVE, WoWTools_ItemMixin:GetLink(itemID))
end

local function Add_Toy(itemID)--添加
    Save().items[itemID]= true
    WoWTools_HearthstoneMixin.ToyButtonToyButton:Init_Random(Save().lockedToy)--初始
end

local function Add_Remove_Toy(itemID)--移除/添加
    if itemID then
        if Save().items[itemID] then
            Remove_Toy(itemID)--移除
        else
            Add_Toy(itemID)--添加
        end
    end
end









local function ToySpellButton_UpdateButton(btn)--标记, 是否已选取
    if not btn.hearthstone then
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
            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_HearthstoneMixin.addName)
            GameTooltip:AddLine(' ')
            local itemID=self:get_itemID()
            local icon= C_Item.GetItemIconByID(itemID)
            GameTooltip:AddDoubleLine(
                (icon and '|T'..icon..':0|t' or '')..(itemID and C_ToyBox.GetToyLink(itemID) or itemID),
                e.GetEnabeleDisable(Save().items[itemID])..e.Icon.left
            )
            GameTooltip:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            GameTooltip:Show()
            self:SetAlpha(1)
        end
        btn.hearthstone:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                Add_Remove_Toy(self:get_itemID())--移除/添加
                self:set_tooltips()
                self:set_alpha()
            else
                MenuUtil.CreateContextMenu(self, WoWTools_HearthstoneMixin.Init_Menu_Toy)
            end
        end)
        btn.hearthstone:SetScript('OnLeave', function(self) GameTooltip:Hide() self:set_alpha() end)
        btn.hearthstone:SetScript('OnEnter', btn.hearthstone.set_tooltips)
    end
    btn.hearthstone:set_alpha()
end










function WoWTools_HearthstoneMixin:Init_Blizzard_Collections()
    hooksecurefunc('ToySpellButton_UpdateButton', ToySpellButton_UpdateButton)
end


function WoWTools_HearthstoneMixin:Remove_Toy(itemID)
    Remove_Toy(itemID)
end