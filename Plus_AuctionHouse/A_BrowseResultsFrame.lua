
if WoWTools_AuctionHouseMixin.disabled then
    return
end







local function Set_BrowseResultsFrame(frame)
    if not frame:HasView() then
        return
    end
    for _, btn in pairs(frame:GetFrames() or {}) do
        local text
        local itemKey= btn.rowData and btn.rowData.itemKey
        local itemKeyInfo = itemKey and C_AuctionHouse.GetItemKeyInfo(itemKey)--itemID battlePetSpeciesID itemName battlePetLink appearanceLink quality iconFileID isPet isCommodity isEquipment
        if itemKeyInfo then

            --if itemKeyInfo.isPet then
                local isCollectedAll--宠物
                text, isCollectedAll= select(3, WoWTools_PetBattleMixin:Collected(itemKeyInfo.battlePetSpeciesID, itemKeyInfo.itemID, true))
                if isCollectedAll then
                    text= '|A:common-icon-checkmark-yellow:0:0|a'
                end

            --elseif itemKeyInfo.isEquipment then
            if not text then
                text= WoWTools_CollectedMixin:Item(itemKeyInfo.itemID, nil, true)--物品是否收集
            end
            --else

                if not text then--坐骑
                    local isMountCollected= select(2, WoWTools_CollectedMixin:Mount(nil, itemKeyInfo.itemID))
                    if isMountCollected==true then
                        text= '|A:common-icon-checkmark-yellow:0:0|a'
                    elseif isMountCollected==false then
                        text= '|A:QuestNormal:0:0|a'
                    end
                end
                if not text then--玩具,是否收集
                    local isToy= select(2, WoWTools_CollectedMixin:Toy(itemKeyInfo.itemID))
                    if isToy==true then
                        text= '|A:common-icon-checkmark-yellow:0:0|a'
                    elseif isToy==false then
                        text= '|A:QuestNormal:0:0|a'
                    end
                end
                if not text and select(6, C_Item.GetItemInfoInstant(itemKeyInfo.itemID))==3 then--显示, 宝石, 属性
                    local t1, t2= WoWTools_ItemMixin:SetGemStats(nil, WoWTools_AuctionHouseMixin:GetItemLink(btn.rowData))
                    if t1 then
                        text= t1..(t2 and ' '..t2 or '')
                    end
                end
                if not text then
                    local redInfo= WoWTools_ItemMixin:GetTooltip({
                        itemKey=itemKey,
                        red=true,
                        text={ITEM_SPELL_KNOWN},
                    })
                    if redInfo.text[ITEM_SPELL_KNOWN] then
                        text= '|A:common-icon-checkmark:0:0|a'
                    elseif redInfo.red then
                        text= '|A:worldquest-icon-firstaid:0:0|a'
                    else
                        text= '|A:Recurringavailablequesticon:0:0|a'
                    end
                end
        end
        if text and not btn.lable then
            btn.lable= WoWTools_LabelMixin:Create(btn)
        end
        if btn.lable then
            btn.lable:SetPoint('RIGHT', btn.cells[2].Icon, 'LEFT')
            btn.lable:SetText(text or '')
        end
    end
end











--浏览拍卖行
--Blizzard_AuctionHouseUI.lua
--local ITEM_SPELL_KNOWN = ITEM_SPELL_KNOWN--"已学习
local function Init()
    WoWTools_DataMixin:Hook(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, 'Update', Set_BrowseResultsFrame)

    --双击，一口价
    WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemBuyFrame.ItemList.ScrollBox, 'Update', function(frame)
        if not frame:HasView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            if not btn.setOnDoubleClick then
                btn:SetScript('OnDoubleClick', function()
                    if AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton and AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton:IsEnabled() then
                        if StaticPopup1:IsShown() then
                            StaticPopup1:Hide()
                        else
                            AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton:Click()
                        end
                    end
                end)
                btn.setOnDoubleClick=true
            end
        end
    end)

    --购买，数量
    AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.InputBox:HookScript('OnShow', function(self)
        if not self:HasText() then
            self:SetText(1)
        end
    end)
end


function WoWTools_AuctionHouseMixin:Init_BrowseResultsFrame()
    if not WoWToolsSave['Plus_AuctionHouse'].disabledBuyPlus then
        Init()
    end
end