--选项，操作，按钮
local e= select(2, ...)
local button



local function Init_Dia()

    StaticPopupDialogs['WoWToolsUseItemsADD']={--添加, 移除
        text= WoWTools_UseItemsMixin.addName..'|n|n%s: %s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= e.onlyChinese and '添加' or ADD,
        button2= e.onlyChinese and '取消' or CANCEL,
        button3= e.onlyChinese and '移除' or REMOVE,
        OnShow = function(self, data)
            local find=WoWTools_UseItemsMixin:Find_Type(data.type, data.ID)
            data.index=find
            self.button3:SetEnabled(find)
            self.button1:SetEnabled(not find)
        end,
        OnAccept = function(_, data)
            table.insert(WoWTools_UseItemsMixin.Save[data.type], data.ID)
            print(WoWTools_ToolsButtonMixin:GetName(), WoWTools_UseItemsMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r', e.onlyChinese and '完成' or COMPLETE, data.name, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        OnAlt = function(_, data)
            table.remove(Save[data.type], data.index)
            print(WoWTools_ToolsButtonMixin:GetName(), WoWTools_UseItemsMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', e.onlyChinese and '完成' or COMPLETE, data.name, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
    }

end




local function Init()
    Init_Dia()

    --button.Menu=CreateFrame("Frame", nil, button, "UIDropDownMenuTemplate")
    --e.LibDD:UIDropDownMenu_Initialize(button.Menu, Init_Menu_List, 'MENU')--主菜单
    local btn= WoWTools_ToolsButtonMixin:GetButton()

    button=WoWTools_ButtonMixin:Cbtn(btn.Frame, {atlas='Soulbinds_Tree_Conduit_Icon_Utility', size={22,22}})
    button:SetPoint('TOPLEFT', btn, 'TOPRIGHT')

    button:SetScript('OnMouseDown',function(self, d)--添加, 移除
        local infoType, itemID, itemLink ,spellID= GetCursorInfo()
        if infoType == "item" and itemID and itemLink then
            local itemEquipLoc= select(4, C_Item.GetItemInfoInstant(itemLink))
            local slot= WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
            local type = slot and 'equip' or 'item'
            local text = slot and (e.onlyChinese and '装备' or EQUIPSET_EQUIP) or (e.onlyChinese and '物品' or ITEMS)
            local icon = C_Item.GetItemIconByID(itemLink)
            StaticPopup_Show('WoWToolsUseItemsADD', text , (icon and '|T'..icon..':0|t' or '')..itemLink, {type=type, name=itemLink, ID=itemID})
            ClearCursor()

        elseif infoType =='spell' and spellID then
            local spellLink=C_Spell.GetSpellLink(spellID) or ((e.onlyChinese and '法术' or SPELLS)..' ID: '..spellID)
            local icon=C_Spell.GetSpellTexture(spellID)
            StaticPopup_Show('WoWToolsUseItemsADD',  e.onlyChinese and '法术' or SPELLS , (icon and '|T'..icon..':0|t' or '')..spellLink, {type='spell', name=spellLink, ID=spellID})
            ClearCursor()

        else
            WoWTools_UseItemsMixin:Init_Menu(self)
            --MenuUtil.CreateContextMenu(self, Init_Menu)
            --e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)
    button:SetScript('OnEnter',function (self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_ToolsButtonMixin:GetName(), WoWTools_UseItemsMixin.addName)
        e.tips:AddDoubleLine(e.onlyChinese and '拖曳' or DRAG_MODEL, e.onlyChinese and '添加' or ADD)
        e.tips:AddDoubleLine(e.onlyChinese and '法术' or SPELLS, e.onlyChinese and '物品，装备' or (ITEMS..', '..EQUIPSET_EQUIP), 0,1,0, 0,1,0)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:Show()
        self:SetAlpha(1.0)
    end)
    button:SetScript('OnLeave', function (self)
        self:SetAlpha(0.1)
        e.tips:Hide()
    end)
end







function WoWTools_UseItemsMixin:Init_Button()
    Init_Dia()
    Init()
end