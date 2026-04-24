--商站 Blizzard_PerksProgramElements.lua



local function Create_ItemTypeLabel(btn)
    if btn then
        btn.itemTypeLabel= btn.ContentsContainer:CreateFontString(nil, 'BORDER', 'WoWToolsFont')
        btn.itemTypeLabel:SetPoint('RIGHT', btn.ContentsContainer.Icon, 'LEFT')
        btn.itemTypeLabel:SetJustifyH('RIGHT')
    end
end


local function Set_ItemType(btn, itemInfo)
    itemInfo = itemInfo or {}

    local text
    local hex=''

    if itemInfo.speciesID and itemInfo.speciesID>0 then
        text= WoWTools_DataMixin.onlyChinese and '宠物' or PET
        hex= '|cffedd100'

    elseif itemInfo.mountID and itemInfo.mountID>0 then
        text= WoWTools_DataMixin.onlyChinese and '坐骑' or MOUNT
        hex= '|cff00ccff'

    elseif itemInfo.transmogSetID and itemInfo.transmogSetID>0 then
        text= WoWTools_DataMixin.onlyChinese and '套装' or PERKS_PROGRAM_CART_COLLECTION_HEADER
        hex= '|cff00ff12'

    elseif itemInfo.itemID and itemInfo.itemID>0 then
        local itemID= itemInfo.itemID

        if C_ToyBox.GetToyInfo(itemID) then
            text= WoWTools_DataMixin.onlyChinese and '玩具' or TOY
            hex= '|cffffffff'

        elseif C_Item.IsCosmeticItem(itemID) then
            local _, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID= C_Item.GetItemInfoInstant(itemID)
            if classID==Enum.ItemClass.Weapon then
                if itemSubType then
                    text= WoWTools_TextMixin:CN(itemSubType)
                elseif itemType then
                    text= WoWTools_TextMixin:CN(itemType)
                end
                --不可装备
                if not C_Item.IsEquippableItem(itemID) then
                    hex= '|cff808080'
                end
            end
            text= text or _G[itemEquipLoc] or (WoWTools_DataMixin.onlyChinese and '装饰品' or ITEM_COSMETIC)

--不可幻化
            if not hex and select(3, WoWTools_CollectionMixin:Item(itemID))==false then
                hex= '|cff808080'
            else
                hex= hex or '|cffffd200'
            end
            if WoWTools_DataMixin.onlyChinese then
                text= text:gsub('物品$', '')
                text= text:gsub('武器$', '')
                text= text:gsub('部$', '')
                text= text:gsub('^.手.$', function()
                end)
            else
                text= text:gsub(ICON_FILTER_ITEM..'$', '')
                text= text:gsub(WEAPON..'$', '')
                text= text:gsub(' $', '')
            end
        end
    end

    btn.itemTypeLabel:SetText(text and hex..text or "")

    local color = WoWTools_ItemMixin:GetColor(itemInfo.quality, {itemID=itemInfo.itemID})
    btn.ContentsContainer.Label:SetTextColor(color:GetRGB())
end



function WoWTools_ItemMixin.Events:Blizzard_PerksProgram()
--左边，列表
    WoWTools_DataMixin:Hook( PerksProgramProductButtonMixin, 'OnLoad', function(btn)
        if btn:HasSecretValues() then
            return
        end

        Create_ItemTypeLabel(btn)

    --双击， 移队/加入购物车
        btn:SetScript('OnDoubleClick', function(b)
            b.ContentsContainer.CartToggleButton:Click()
        end)
    end)

    WoWTools_DataMixin:Hook( PerksProgramProductButtonMixin, 'SetItemInfo', function(btn, itemInfo)
        if not btn.itemTypeLabel then
            return
        end

        Set_ItemType(btn, itemInfo)

        WoWTools_ItemMixin:SetupInfo(btn.ContentsContainer, itemInfo.itemID and {
            itemID=itemInfo.itemID,
            itemLink=WoWTools_ItemMixin:GetLink(itemInfo.itemID),
            point=btn.ContentsContainer.Icon,
            size=12
        } or nil)
    end)
    Create_ItemTypeLabel(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame.FrozenProductContainer.ProductButton)

--左边，底部
    --WoWTools_DataMixin:Hook(PerksProgramFrozenProductButtonMixin, 'SetItemInfo', function(itemInfo)



--右边，列表
    WoWTools_DataMixin:Hook(PerksProgramScrollItemDetailsMixin, 'InitItem', function(frame, data)
         WoWTools_ItemMixin:SetupInfo(frame, {itemID=data.itemID, point=frame.Icon})
    end)

end
