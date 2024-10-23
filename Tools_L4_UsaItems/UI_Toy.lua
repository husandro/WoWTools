--玩具界面, 菜单
local e= select(2, ...)



local function Init_Opetions_ToyBox(btn)--标记, 是否已选取
    if btn.useItem then
        btn.useItem:set_alpha()
        return
    end

    btn.useItem= WoWTools_ButtonMixin:Cbtn(btn,{size={16,16}, atlas='soulbinds_tree_conduit_icon_utility'})
    btn.useItem:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT', 32, 0)
    function btn.useItem:get_itemID()
        return self:GetParent().itemID
    end
    function btn.useItem:set_alpha()
        local find=WoWTools_UseItemsMixin:Find_Type('item', self:get_itemID())
        self:SetAlpha(find and 1 or 0.1)
    end
    function btn.useItem:set_tooltips()
        local itemID=self:get_itemID()
        if not itemID then
            return
        end
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_ToolsButtonMixin:GetName(), WoWTools_UseItemsMixin.addName)
        e.tips:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        e.tips:AddLine(' ')

        local icon= C_Item.GetItemIconByID(itemID)
        local find=WoWTools_UseItemsMixin:Find_Type('item', itemID)
        e.tips:AddDoubleLine(
            (icon and '|T'..icon..':0|t' or '')..(C_ToyBox.GetToyLink(itemID) or itemID)..' '..e.GetEnabeleDisable(find),
            e.Icon.left
        )
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
    end

    btn.useItem:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            local itemID= self:GetParent().itemID
            if not itemID then
                return
            end
            local find=WoWTools_UseItemsMixin:Find_Type('item', itemID)
            if find then
                table.remove(WoWTools_UseItemsMixin.Save.item, find)
            else
                table.insert(WoWTools_UseItemsMixin.Save.item, itemID)
            end
            self:set_tooltips()
            self:set_alpha()
        else
            WoWTools_UseItemsMixin:Init_Menu(self)
            --MenuUtil.CreateContextMenu(self, Init_Menu)
            --e.LibDD:ToggleDropDownMenu(1, nil, button.Menu, self, 15, 0)
        end
    end)
    btn.useItem:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha() end)
    btn.useItem:SetScript('OnEnter', btn.useItem.set_tooltips)
    btn.useItem:set_alpha()

end












function WoWTools_UseItemsMixin:Init_UI_Toy()
    hooksecurefunc('ToySpellButton_UpdateButton', Init_Opetions_ToyBox)--玩具界面, 菜单
end