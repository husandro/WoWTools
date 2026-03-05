--[[
description 离弦之箭既出，射手的利刃便如黑暗中的月光般划破阴影。
purchased false
price 80
transmogSetID 0
doesNotExpire false
isItemInfo true
timeRemaining 2357816
mountTypeName 
perksVendorItemID 1324
quality 3
perksVendorCategoryID 1
invType INVTYPE_WEAPON
mountID 0
subItemsLoaded true
itemModifiedAppearanceID 304084
speciesID 0
iconTexture 
name 射手的夜色军刀
refundable false
itemID 266122
showSaleBanner false
isPurchasePending false
]]

--vendorItemInfo = C_PerksProgram.GetVendorItemInfo(vendorItemID)
local function Set_ItemType(btn, itemInfo)
    if not btn.leftItemTypeLabe then
        btn.leftItemTypeLabe= btn:CreateFontString(nil, 'BORDER', 'WoWToolsFont')
        btn.leftItemTypeLabe:SetPoint('RIGHT', btn, 'LEFT')
        btn.leftItemTypeLabe:SetJustifyH('RIGHT')
    end

    if itemInfo.speciesID and itemInfo.speciesID>0 then
        btn.leftItemTypeLabe:SetText(WoWTools_DataMixin.onlyChinese and '宠物' or PET)

    elseif itemInfo.mountID and itemInfo.mountID>0 then
        btn.leftItemTypeLabe:SetText(WoWTools_DataMixin.onlyChinese and '坐骑' or MOUNT)

    elseif itemInfo.transmogSetID and itemInfo.transmogSetID>0 then
        btn.leftItemTypeLabe:SetText(WoWTools_DataMixin.onlyChinese and '套装' or PERKS_PROGRAM_CART_COLLECTION_HEADER)

    elseif itemInfo.itemID and itemInfo.itemID>0 then
        if C_ToyBox.GetToyInfo(itemInfo.itemID) then
            btn.leftItemTypeLabe:SetText(WoWTools_DataMixin.onlyChinese and '玩具' or TOY)
        end
        
    else
        btn.leftItemTypeLabe:SetText("")
    end
end


--商站
function WoWTools_ItemMixin.Events:Blizzard_PerksProgram()

--右边，列表
    WoWTools_DataMixin:Hook(PerksProgramScrollItemDetailsMixin, 'InitItem', function(frame, data)
         WoWTools_ItemMixin:SetupInfo(frame, {itemID=data.itemID, point=frame.Icon})
    end)

    WoWTools_DataMixin:Hook(HeaderSortButtonMixin, 'OnLoad', function()
        print('OnLoad')
    end)
    WoWTools_DataMixin:Hook(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox, 'Update', function(frame)
         if not frame:HasView() then
            return
        end
        for _, btn in pairs(frame:GetFrames()) do
           
            --[[if btn.itemID then
                local itemLink= WoWTools_ItemMixin:GetLink(btn.itemID)
                WoWTools_ItemMixin:SetupInfo(btn.ContentsContainer, itemLink and {itemLink=itemLink, point=btn.ContentsContainer.Icon, size=12} or nil)

                print(btn.itemID, btn.itemLink, btn.product, btn.name, btn.texture )
            else]]if btn.GetItemInfo then--
                local itemInfo=btn:GetItemInfo()
                local itemLink= WoWTools_ItemMixin:GetLink(itemInfo.itemID)
                WoWTools_ItemMixin:SetupInfo(btn.ContentsContainer, itemLink and {itemLink=itemLink, point=btn.ContentsContainer.Icon, size=12} or nil)

                info= itemInfo
                --for k, v in pairs(info or {}) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR|r') for k2,v2 in pairs(v) do print('|cffffff00',k2,v2, '|r') end print('|cffff0000---',k, '---END|r') else print(k,v) end end print('|cffff00ff——————————|r')
                Set_ItemType(btn, itemInfo)
            end

    --双击， 移队/加入购物车
            if btn:IsObjectType('Button') and not btn:GetScript('OnDoubleClick') then
                btn:SetScript('OnDoubleClick', function(b)
                    b.ContentsContainer.CartToggleButton:Click()
                end)
            end
        end

        if PerksProgramFrame.GetFrozenItemFrame then
            local f= PerksProgramFrame:GetFrozenItemFrame()
            if f then
                WoWTools_ItemMixin:SetupInfo(f.FrozenButton, f.FrozenButton.itemID and {itemLink=WoWTools_ItemMixin:GetLink(f.FrozenButton.itemID), size=12} or nil)
            end
        end
    end)

    --C_Timer.After(0.3, function()
       -- set_uptate(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.ScrollBox)
    --end)
end
