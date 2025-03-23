--玩具界面, 菜单


local function Save()
    return  WoWToolsSave['Tools_UseItems']
end











local function Init_Opetions_ToyBox(btn)--标记, 是否已选取
    if btn.useItem then
        btn.useItem:set_alpha()
        return
    end

    btn.useItem= WoWTools_ButtonMixin:Cbtn(btn,{size=16, atlas='soulbinds_tree_conduit_icon_utility'})
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
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_ToolsMixin.addName, WoWTools_UseItemsMixin.addName)
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        GameTooltip:AddLine(' ')

        local icon= C_Item.GetItemIconByID(itemID)
        local find=WoWTools_UseItemsMixin:Find_Type('item', itemID)
        GameTooltip:AddDoubleLine(
            (icon and '|T'..icon..':0|t' or '')..(C_ToyBox.GetToyLink(itemID) or itemID)..' '..WoWTools_TextMixin:GetEnabeleDisable(find),
            WoWTools_DataMixin.Icon.left
        )
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
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
                table.remove(Save().item, find)
            else
                table.insert(Save().item, itemID)
            end
            self:set_tooltips()
            self:set_alpha()
        else
            WoWTools_UseItemsMixin:Init_Menu(self)
        end
    end)
    btn.useItem:SetScript('OnLeave', function(self) GameTooltip:Hide() self:set_alpha() end)
    btn.useItem:SetScript('OnEnter', btn.useItem.set_tooltips)
    btn.useItem:set_alpha()

end












function WoWTools_UseItemsMixin:Init_UI_Toy()
    hooksecurefunc('ToySpellButton_UpdateButton', Init_Opetions_ToyBox)--玩具界面, 菜单
end