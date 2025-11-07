local P_Save= {
    items={--禁用，自动添加，物品
        --+精通
        [210715]=true,--缺口精湛紫晶 
        [216640]=true,--瑕疵精湛紫晶
        [211106]=true,--精湛紫晶
        [211108]=true,--完美精湛紫晶

        --+爆击
        [210714]=true,--缺口致命蓝玉
        [216644]=true,--瑕疵致命蓝玉
        [211123]=true,--致命蓝玉
        [211102]=true,--完美致命蓝玉

        --+急速
        [210681]=true,--缺口迅捷黄晶
        [216643]=true,--瑕疵迅捷黄晶
        [211107]=true,--迅捷黄晶
        [211110]=true,--完美迅捷黄晶

        --+全能
        [220371]=true,--缺口万能钻石
        [220372]=true,--瑕疵万能钻石
        [220374]=true,--万能钻石
        [220373]=true,--完美万能钻石
    },
}

local MaxNumeri= 9
local addName

local function Save()
    return WoWToolsSave['Other_ScrappingMachine']
end












local function get_num_items()
    local n= 0
    if ScrappingMachineFrame then
        for btn in ScrappingMachineFrame.ItemSlots.scrapButtons:EnumerateActive() do
            if btn and btn.itemLink then
                n=n +1
            end
        end
    end
    return n
end















local function can_scrap_item(bag, slot, onlyEquip, classID)
    if not ScrappingMachineFrame:IsShown() then
        return
    end

    local itemLocation= ItemLocation:CreateFromBagAndSlot(bag, slot)

    if itemLocation and itemLocation:IsValid() and C_Item.CanScrapItem(itemLocation) then
        local itemID= C_Item.GetItemID(itemLocation)
        if Save().items[itemID] then--禁用，自动添加，物品
            return
        end

        if not onlyEquip and not classID then
            return itemLocation
        end

        local itemLink= C_Item.GetItemLink(itemLocation)
        if itemLink then
            local itemEquipLoc, _, classID2 = select(4, C_Item.GetItemInfoInstant(itemLink))
            if onlyEquip then--装备
                local invSlot= WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
                if invSlot then
                    return itemLocation
                end
            elseif classID then--类型
                if classID== classID2 then
                    return itemLocation
                end
            end
        end
    end
end















local ButtonList={
    {
        name='AddGem',
        texture=135998,
        classID=3,
        tooltip=WoWTools_DataMixin.onlyChinese and '添加宝石' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, AUCTION_CATEGORY_GEMS),
        click=function()
            local free= MaxNumeri- get_num_items()
            if free==0 or InCombatLockdown() then
                return
            end
            for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do
                for slot=1, C_Container.GetContainerNumSlots(bag) do--背包数量
                    if can_scrap_item(bag, slot, nil, 3) then
                        C_Container.UseContainerItem(bag, slot)
                        free= free-1
                        if free==0 then
                            return
                        end
                    end
                end
            end
        end
    },{

        name='AddItem',
        texture=135995,
        tooltip=WoWTools_DataMixin.onlyChinese and '添加装备' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, BAG_FILTER_EQUIPMENT),
        click=function()
            local free= MaxNumeri-get_num_items()
            if free==0 or InCombatLockdown() then
                return
            end
            for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do
                for slot=1, C_Container.GetContainerNumSlots(bag) do--背包数量
                    if can_scrap_item(bag, slot, true, nil) then
                        C_Container.UseContainerItem(bag, slot)
                        free= free-1
                        if free<=0 then
                            return
                        end
                    end
                end
            end
        end
    --[[},{
        name='ItemBag',
        atlas='bag-main',
        tooltip=WoWTools_DataMixin.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL,
        click=function(self)
            MenuUtil.CreateContextMenu(self, Init_BagList_Menu)
        end]]
    },{
        name='AddAll',
        atlas='communities-chat-icon-plus',
        tooltip=WoWTools_DataMixin.onlyChinese and '全部添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, ALL),
        click=function()
            local free= MaxNumeri-get_num_items()
            if free==0 or InCombatLockdown() then
                return
            end
            for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do
                for slot=1, C_Container.GetContainerNumSlots(bag) do--背包数量
                    if can_scrap_item(bag, slot, nil, nil) then
                        C_Container.UseContainerItem(bag, slot)
                        free= free-1
                        if free==0 then
                            return
                        end
                    end
                end
            end
        end
    },


    {name='-'},

    {
        name='ClearItem',
        atlas='bags-button-autosort-up',
        tooltip=(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        click=function() C_ScrappingMachineUI.RemoveAllScrapItems() end
    }
}

















local function Init_SubItem_Menu(self, sub, items)
    local sub2
    for itemID in pairs(items) do
        sub2=sub:CreateCheckbox(
            WoWTools_ItemMixin:GetName(itemID),
        function(data)
            return Save().items[data.itemID]
        end, function(data)
            Save().items[data.itemID]= not Save().items[data.itemID] and true or nil
            self:settings()
        end, {itemID=itemID})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)
end
















local function Init_Menu(self, root)
    local sub
    local tab={}

    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do--背包数量
            local itemLocation= can_scrap_item(bag, slot, nil, nil)
            local itemLink= itemLocation and C_Item.GetItemLink(itemLocation)
            if itemLink then
                local itemID, _, _, _, _, classID= C_Item.GetItemInfoInstant(itemLink)
                if itemID then
                    tab[classID]=tab[classID] or {}
                    tab[classID][itemID]=true-- '|T'..(icon or 0)..':0|t'--{icon=icon, itemLink=itemLink}
                end
            end
        end
    end

    for classID, info in pairs(tab) do
        sub=root:CreateButton(
            '|cff606060'..classID..'|r '..(WoWTools_TextMixin:CN(C_Item.GetItemClassInfo(classID)) or ''),
        function()
            return MenuResponse.Open
        end)

        Init_SubItem_Menu(self, sub, info)
    end

    root:CreateDivider()
    sub=root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)
        ..'|cnGREEN_FONT_COLOR:#'..self.Text:GetText(),
    function()
        return MenuResponse.Open
    end)

    Init_SubItem_Menu(self, sub, Save().items)
    sub:CreateDivider()
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
    function()
        StaticPopup_Show('WoWTools_OK',
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
        nil,
        {SetValue=function()
            Save().items={}
        end})
        return MenuResponse.Open
    end)


--打开选项界面
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {
    name=addName,
    category=WoWTools_OtherMixin.Category
    })
end














--[[背包，所有物品，列表
local function Init_BagList_Menu(self, root)
    local sub
    local tab={}
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do--背包数量
            local itemLocation= can_scrap_item(bag, slot, nil, nil)
            local itemLink= itemLocation and C_Item.GetItemLink(itemLocation)
            if itemLink then
                local itemID, _, _, _, _, classID= C_Item.GetItemInfoInstant(itemLink)
                if itemID then
                    tab[classID]=tab[classID] or {}
                    tab[classID][itemID]={bagID=bag, slotID=slot}
                end
            end
        end
    end

    for classID, info in pairs(tab) do
        sub=root:CreateButton(
            '|cff606060'..classID..'|r '..(WoWTools_TextMixin:CN(C_Item.GetItemClassInfo(classID)) or ''),
        function()
            return MenuResponse.Open
        end)

        Init_SubItem_Menu(self, sub, info)
    end
end]]

















local function Init_Button()
    local ItemsButton= CreateFrame('Button', 'WoWToolsScrappingItemButton', ScrappingMachineFrame, 'WoWToolsButtonTemplate')--  WoWTools_ButtonMixin:Cbtn(ScrappingMachineFrame, {size=23})

    ItemsButton.Text= WoWTools_LabelMixin:Create(ItemsButton)
    ItemsButton.Text:SetPoint('CENTER')
    ItemsButton:SetPoint('TOPLEFT', ScrappingMachineFrame.ItemSlots, 'TOPRIGHT', 12, 0)

    function ItemsButton:get_num()
        local n=0
        for _ in pairs(Save().items) do
            n=n+1
        end
        return n
    end
    function ItemsButton:settings()
        local num= self:get_num()
        self.Text:SetText(num)
        if num==0 then
            self.Text:SetTextColor(0.62, 0.62, 0.62)
        else
            self.Text:SetTextColor(1,0,0)
        end
        self:SetNormalAtlas('talents-node-choiceflyout-circle-red')
    end
    function ItemsButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()

        local infoType, _, itemLink= GetCursorInfo()
        if infoType == "item" and itemLink then
            local texture= select(5, C_Item.GetItemInfoInstant(itemLink))
            if texture then
                self:SetNormalTexture(texture)
                GameTooltip:SetHyperlink(itemLink)
                GameTooltip:Show()
                return
            end
        end

        GameTooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)
            ..'|A:talents-button-reset:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '自动添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ADD)),
            '|cnGREEN_FONT_COLOR:#'..self.Text:GetText()
        )
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS)),
            (WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:Show()
    end
    ItemsButton:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:settings()
    end)
    ItemsButton:SetScript('OnEnter', function(self)
        self:set_tooltips()
    end)
    ItemsButton:SetScript('OnMouseDown', function(self)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID then
            Save().items[itemID]= not Save().items[itemID] and true or nil
            print(WoWTools_DataMixin.Icon.icon2..addName,
                Save().items[itemID] and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..'|r'
                    or ('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|r'),
                itemLink or itemID
            )
            ClearCursor()
            self:settings()
            self:set_tooltips()
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    ItemsButton:settings()




for index, info in pairs(ButtonList) do
    if info.name~='-' then
        --[[local btn=WoWTools_ButtonMixin:Cbtn(ScrappingMachineFrame, {
            name= 'WoWToolsScrapping'..info.name..'Button',
            size=23,
            atlas=info.atlas,
            texture=info.texture,
        })]]
        local btn= CreateFrame('Button', 'WoWToolsScrapping'..info.name..'Button', ScrappingMachineFrame, 'WoWToolsButtonTemplate')

        if info.atlas then
            btn:SetNormalAtlas(info.atlas)
        elseif info.texture then
            btn:SetNormalTexture(info.texture)
        end


        btn.tooltip= (info.texture and format('|T%d:0|t', info.texture) or format('|A:%s:0:0|a', info.atlas))..info.tooltip
        btn.click= info.click

        btn:SetPoint('TOP', ItemsButton, 'BOTTOM', 0, -(index*23))
        btn:SetScript('OnLeave', function()
            GameTooltip:Hide()
        end)
        btn:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.tooltip..WoWTools_DataMixin.Icon.icon2)
            GameTooltip:Show()
        end)

        btn:SetScript('OnClick', function(self)
            local spellID= C_ScrappingMachineUI.GetScrapSpellID()
            if spellID and C_Spell.IsCurrentSpell(spellID) then
                return
            end
            self:click()
        end)
    end
end

ButtonList={}

WoWTools_DataMixin:Hook(ScrappingMachineFrame, 'UpdateScrapButtonState', function()
    _G['WoWToolsScrappingClearItemButton']:SetAlpha(C_ScrappingMachineUI.HasScrappableItems() and 1 or 0.5)
    _G['WoWToolsScrappingAddAllButton']:SetAlpha(MaxNumeri> get_num_items() and 1 or 0.5)
end)

    Init_Button=function()end
end


















local function Init()
    --拆解法术，提示
    ScrappingMachineFrame.ScrapButton:HookScript('OnLeave', GameTooltip_Hide)
    ScrappingMachineFrame.ScrapButton:HookScript('OnEnter', function(self)
        local spellID= C_ScrappingMachineUI.GetScrapSpellID()
        if not spellID or GameTooltip:IsOwned(self) then
            return
        end
        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(spellID)
        GameTooltip:Show()
    end)

    --物品，提示
    for btn in ScrappingMachineFrame.ItemSlots.scrapButtons:EnumerateActive() do
        if (btn) then
            WoWTools_DataMixin:Hook(btn, 'RefreshIcon', function(self)
                local tab= (self.itemLink or self.itemLocation) and {itemLink=self.itemLink, itemLocation= self.itemLocation} or nil
                WoWTools_ItemMixin:SetupInfo(self, tab)
            end)
        end
    end



    Init_Button()

    Init=function()end
end













local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1== 'WoWTools' then

        WoWToolsSave['Other_ScrappingMachine']= WoWToolsSave['Other_ScrappingMachine'] or CopyTable(P_Save)
        P_Save= nil

        addName= '|TInterface\\Icons\\inv_gizmo_03:0|t'..(WoWTools_DataMixin.onlyChinese and '拆解大师Mk1型' or SCRAPPING_MACHINE_TITLE)

        --添加控制面板
        WoWTools_PanelMixin:OnlyCheck({
            name= addName,
            Value= not Save().disabled,
            GetValue=function() return not Save().disabled end,
            SetValue= function()
                Save().disabled= not Save().disabled and true or nil
                print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_TextMixin:GetEnabeleDisable(Save().disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end,
            layout= WoWTools_OtherMixin.Layout,
            category= WoWTools_OtherMixin.Category,
        })

        if Save().disabled then
            self:UnregisterEvent(event)
        else
            if C_AddOns.IsAddOnLoaded('Blizzard_ScrappingMachineUI') then
                Init()
                self:UnregisterEvent(event)
            end
        end

    elseif arg1=='Blizzard_ScrappingMachineUI' and WoWToolsSave then--分解 ScrappingMachineFrame
        Init()
        self:UnregisterEvent(event)
    end
end)