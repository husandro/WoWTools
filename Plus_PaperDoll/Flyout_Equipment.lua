--装备弹出
--EquipmentFlyout.lua
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end


local ITEM_LEVEL= ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')--"物品等级：%d"
local ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"
local PVP_ITEM_LEVEL_TOOLTIP= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"



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






local function Create_ButtonLabel(btn)
    local w, h= btn:GetSize()

    btn.level= WoWTools_LabelMixin:Create(btn)
    btn.level:SetPoint('BOTTOM')

    btn.upgrade= WoWTools_LabelMixin:Create(btn, {color={r=0,g=1,b=0}})
    btn.upgrade:SetPoint('LEFT')
    btn.itemType=WoWTools_LabelMixin:Create(btn)
    btn.itemType:SetPoint('TOPRIGHT')
--等级，比较
    btn.updown=WoWTools_LabelMixin:Create(btn)
    btn.updown:SetPoint('TOPLEFT')

    btn.pvpItem=btn:CreateTexture(nil,'OVERLAY',nil,7)
    btn.pvpItem:SetSize(h/3, h/3)
    btn.pvpItem:SetPoint('RIGHT')
    btn.pvpItem:SetAtlas('Warfronts-BaseMapIcons-Horde-Barracks-Minimap')
--提示，已装备
    btn.isEquippedTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.isEquippedTexture:SetPoint('CENTER')
    btn.isEquippedTexture:SetSize(w+12, h+12)
    btn.isEquippedTexture:SetAtlas('Forge-ColorSwatchHighlight')--'Forge-ColorSwatchSelection')
    btn.isEquippedTexture:SetVertexColor(1,0,0)

    btn.setTexture=btn:CreateTexture()
    btn.setTexture:SetAllPoints(btn)
    btn.setTexture:SetAtlas('UI-HUD-MicroMenu-Highlightalert')

    btn:HookScript('OnEnter', function(self)--查询
        WoWTools_BagMixin:Find(true, {itemLink=self:GetItemLink()})
    end)
    btn:HookScript('OnLeave', function()
        WoWTools_BagMixin:Find(false)
    end)
    btn:HookScript('OnHide', function(self)
        set_item_Set(self)--套装
        self.level:SetText('')
        self.upgrade:SetText('')
        self.itemType:SetText('')
        self.updown:SetText('')
        self.pvpItem:SetShown(false)
        self.isEquippedTexture:SetShown(false)
        self.setTexture:SetShown(false)
    end)
end










local function setFlyout(self)--, itemLink, slot)
	local locationData, itemLink
    if not Save().hide and self.location then
        locationData= EquipmentManager_GetLocationData(self.location)
    end

    if locationData then
        local bag, slot = locationData.bag, locationData.slot
        if not locationData.isBags then
            itemLink= GetInventoryItemLink('player', slot)
        else
            itemLink= C_Container.GetContainerItemLink(bag, slot)
        end
    end

    local upgrade, upLevel, upText, updown, text, level
    local isSet, isEquipped, isPvP= false, false, false
    if itemLink then
        if not self.isEquippedTexture then
            Create_ButtonLabel(self)
        end

        local dateInfo= WoWTools_ItemMixin:GetTooltip({itemLInk=itemLink, text={ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT, PVP_ITEM_LEVEL_TOOLTIP, ITEM_LEVEL}, onlyText=true})--物品提示，信息

        level= dateInfo.text[ITEM_LEVEL]
        level= level and tonumber(level) or C_Item.GetDetailedItemLevelInfo(itemLink)

        local slotID
        if level then
            text= WoWTools_ItemMixin:GetColor(nil, {itemLink=itemLink, text=level})
            local itemButton = EquipmentFlyoutFrame.button
            slotID = itemButton.id or itemButton:GetID()
        end

        upgrade=dateInfo.text[ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT]
        isPvP= dateInfo.text[PVP_ITEM_LEVEL_TOOLTIP] and true or false

        if upgrade then
            upLevel= upgrade and upgrade:match('(%d+/%d+)')
            upText= dateInfo.text[ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT]:match('(.-)%d+/%d+')
            upText= upText and strlower(WoWTools_TextMixin:sub(upText, 1,3, true)) or nil
        end

        if level and slotID then
            local link = GetInventoryItemLink('player', slotID)
            if link then
                updown = C_Item.GetDetailedItemLevelInfo(link)
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

        isEquipped= C_Item.IsEquippedItem(itemLink)
        isSet= select(16 , C_Item.GetItemInfo(itemLink)) and true or false

    end

    if self.isEquippedTexture then
        set_item_Set(self, itemLink)--套装

        self.level:SetText(text or '')
        self.upgrade:SetText(upLevel or '')
        self.itemType:SetText(upText or '')
        self.updown:SetText(updown or '')
        self.pvpItem:SetShown(isPvP)
        self.isEquippedTexture:SetShown(isEquipped)
        self.setTexture:SetShown(isSet)
    end
end















local function Init()
    WoWTools_DataMixin:Hook('EquipmentFlyout_UpdateItems', function()
        for _, btn in ipairs(EquipmentFlyoutFrame.buttons) do
            if btn and btn:IsShown()  then
                setFlyout(btn)
            end
        end
    end)

    --[[WoWTools_DataMixin:Hook('EquipmentFlyout_Show', function()
        print('aaa')
       for _, btn in ipairs(EquipmentFlyoutFrame.buttons) do
            if btn and btn:IsShown()  then
                setFlyout(btn)
            end
        end
    end)]]

   Init=function()end
end





function WoWTools_PaperDollMixin:Init_EquipmentFlyout()
    Init()
end




