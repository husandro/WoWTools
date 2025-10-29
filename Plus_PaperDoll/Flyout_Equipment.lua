--装备弹出
--EquipmentFlyout.lua
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end


local itemLevelStr= ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')--"物品等级：%d"
local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"
local pvpItemStr= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"



local function set_item_Set(self, link)--套装
    local set
    if link and not Save().hide then
        set=select(16 , C_Item.GetItemInfo(link))
        if set then
            if set and not self.set then
                self.set=self:CreateTexture()
                self.set:SetAllPoints(self)
                self.set:SetAtlas('UI-HUD-MicroMenu-Highlightalert')
            end
        end
    end
    if self.set then
        self.set:SetShown(set and true or false)
    end
end












local function setFlyout(button, itemLink, slot)
    local text, level, dateInfo
    if not Save().hide then
        if not button.level then
            button.level= WoWTools_LabelMixin:Create(button)
            button.level:SetPoint('BOTTOM')
        end
        
        dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=itemLink, itemID=itemLink and C_Item.GetItemInfoInstant(itemLink) , text={upgradeStr, pvpItemStr, itemLevelStr}, onlyText=true})--物品提示，信息

        if dateInfo and dateInfo.text[itemLevelStr] then
            level= tonumber(dateInfo.text[itemLevelStr])
        end
        level= level or itemLink and C_Item.GetDetailedItemLevelInfo(itemLink)
        text= level
        if text then
            local itemQuality = C_Item.GetItemQualityByID(itemLink)
            if itemQuality then
                local hex = select(4, C_Item.GetItemQualityColor(itemQuality))
                if hex then
                    text= '|c'..hex..text..'|r'
                end
            end
        end
    end
    if button.level then
        button.level:SetText(text or '')
    end

    local upgrade, pvpItem, upLevel, upText
    local updown--UpgradeFrame等级，比较
    if dateInfo then
        upgrade, pvpItem=dateInfo.text[upgradeStr], dateInfo.text[pvpItemStr]
        if upgrade then
            upLevel= upgrade and upgrade:match('(%d+/%d+)')
            upText= dateInfo.text[upgradeStr]:match('(.-)%d+/%d+')
            upText=upText and strlower(WoWTools_TextMixin:sub(upText, 1,3, true))
        end
        if upgrade and not button.upgrade then
            button.upgrade= WoWTools_LabelMixin:Create(button, {color={r=0,g=1,b=0}})
            button.upgrade:SetPoint('LEFT')
            button.itemType=WoWTools_LabelMixin:Create(button)
            button.itemType:SetPoint('TOPRIGHT')
        end
        if button.upgrade then
            button.upgrade:SetText(upLevel or '')
            button.itemType:SetText(upText or '')
        end
        if level then
            if not slot or slot==0 then
                local itemEquipLoc= itemLink and select(4, C_Item.GetItemInfoInstant(itemLink))
                slot= WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
            end
            if slot then
                local itemLink2 = GetInventoryItemLink('player', slot)
                if itemLink2 then
                    updown = C_Item.GetDetailedItemLevelInfo(itemLink2)
                    if updown then
                        updown=level-updown
                        if updown>0 then
                            updown= '|cnGREEN_FONT_COLOR:+'..updown..'|r'
                        elseif updown<0 then
                            updown= '|cnWARNING_FONT_COLOR:'..updown..'|r'
                        elseif updown==0 then
                            updown= nil
                        end
                    else
                        updown= '|A:bags-greenarrow:0:0|a'
                    end
                else
                    updown= '|A:bags-greenarrow:0:0|a'
                end
            end
        end
    end
    if updown and not button.updown then
        button.updown=WoWTools_LabelMixin:Create(button)
        button.updown:SetPoint('TOPLEFT')
    end
    if button.updown then
        button.updown:SetText(updown or '')
    end

    set_item_Set(button, itemLink)--套装

    if pvpItem and not button.pvpItem and not Save().hide then--提示PvP装备
        local h=button:GetHeight()/3
        button.pvpItem=button:CreateTexture(nil,'OVERLAY',nil,7)
        button.pvpItem:SetSize(h,h)
        button.pvpItem:SetPoint('RIGHT')
        button.pvpItem:SetAtlas('Warfronts-BaseMapIcons-Horde-Barracks-Minimap')
    end
    if button.pvpItem then
        button.pvpItem:SetShown(pvpItem and true or false)
    end

    if not button.isEquippedTexture then--提示，已装备
        button.isEquippedTexture= button:CreateTexture(nil, 'OVERLAY')
        button.isEquippedTexture:SetPoint('CENTER')
        local w,h= button:GetSize()
        button.isEquippedTexture:SetSize(w+12, h+12)
        button.isEquippedTexture:SetAtlas('Forge-ColorSwatchHighlight')--'Forge-ColorSwatchSelection')
        button.isEquippedTexture:SetVertexColor(1,0,0)

        button:HookScript('OnEnter', function(self)--查询
            if self.itemLink then
                WoWTools_BagMixin:Find(true, {itemLink=self.itemLink})
            end
        end)
        button:HookScript('OnLeave', function()
           WoWTools_BagMixin:Find(false)
        end)
    end
    local show=false
    if not Save().hide and button.itemLink then
        show= C_Item.IsEquippedItem(button.itemLink)
    end
    button.isEquippedTexture:SetShown(show)
end













local function Settings(itemButton)
    for _, button in ipairs(EquipmentFlyoutFrame.buttons) do
        if button and button:IsShown()  then
            local itemLink, slot
            if button.location and type(button.location)=='number' then--角色, 界面
                local location = button.location
                slot= itemButton:GetID()
                if location < EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
                    local _, _, bags, _, slot2, bag = EquipmentManager_UnpackLocation(location)
                    --[[if ( voidStorage and voidSlot ) then
                        itemLink = GetVoidItemHyperlinkString(voidSlot)
                    else]]if ( not bags and slot2) then
                        itemLink =GetInventoryItemLink("player",slot2)
                    elseif bag and slot2 then
                        itemLink = C_Container.GetContainerItemLink(bag, slot2)
                    end
                end
            else--其它
                local location = button:GetItemLocation()
                if location and type(location)=='table' then
                    itemLink= C_Item.GetItemLink(location)
                    slot=C_Item.GetItemInventoryType(location)
                end
            end
            setFlyout(button, itemLink, slot)
            button.itemLink= itemLink
        end
    end
end






local function Init()
    WoWTools_DataMixin:Hook('EquipmentFlyout_UpdateItems', function()
        local itemButton = EquipmentFlyoutFrame.button
        Settings(itemButton)
    end)

    WoWTools_DataMixin:Hook('EquipmentFlyout_Show', function(...)
            Settings(...)
    end)

   Init=function()end
end





function WoWTools_PaperDollMixin:Init_EquipmentFlyout()
    Init()
end




