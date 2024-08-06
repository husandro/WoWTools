local id, e = ...
local addName= SCRAPPING_MACHINE_TITLE
local Save={
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
local Initializer
local MaxNumeri= 9









local function get_num_items()
    local n= 0
    for btn in ScrappingMachineFrame.ItemSlots.scrapButtons:EnumerateActive() do
        if btn and btn.itemLink then
            n=n +1
        end
    end
    return n
end

local function can_scrap_item(bag, slot, onlyEquip, classID)
    local itemLocation= ItemLocation:CreateFromBagAndSlot(bag, slot)
    if itemLocation and itemLocation:IsValid() and C_Item.CanScrapItem(itemLocation) then
        local itemID= C_Item.GetItemID(itemLocation)
        if Save.items[itemID] then--禁用，自动添加，物品
            return
        end

        if not onlyEquip and not classID then
            return itemLocation
        end

        local itemLink= C_Item.GetItemLink(itemLocation)
        if itemLink then
            local itemEquipLoc, _, classID2 = select(4, C_Item.GetItemInfoInstant(itemLink))
            if onlyEquip then--装备
                local invSlot= e.GetItemSlotID(itemEquipLoc)
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







--[[local function Init_Currency()
    if not e.Is_Timerunning then
        return
    end

    local frame=CreateFrame('Frame')
end]]








function Init_Menu(self, level, menuList)
    if menuList=='DISABLE' then
        local n=0
        for itemID in pairs(Save.items) do
            e.LoadDate({id=itemID, type='item'})
            e.LibDD:UIDropDownMenu_AddButton({
                text= select(2, C_Item.GetItemInfo(itemID)) or itemID,
                icon= C_Item.GetItemIconByID(itemID),
                tooltipOnButton=true,
                tooltipTitle= itemID,
                tooltipText= e.cn(C_Spell.GetSpellDescription(itemID)),
                checked=true,
                arg1= itemID,
                keepShownOnClick=true,
                func= function(_, arg1)
                    Save.items[arg1]=nil
                    print(id, Initializer:GetName(), e.onlyChinese and '移除' or REMOVE, select(2, C_Item.GetItemInfo(itemID)) or itemID)
                end
            }, level)
            n=n+1
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        e.LibDD:UIDropDownMenu_AddButton({
            text= (e.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..n,
            colorCode= n==0 and '|cff606060',
            notCheckable=true,
            func=function()
                Save.items={}
                self:GetParent():settings()
            end
        }, level)
        return
    end

    local tab={}
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do--背包数量
            local itemLocation= can_scrap_item(bag, slot, nil, nil)
            local itemLink= itemLocation and C_Item.GetItemLink(itemLocation)
            if itemLink then
                local itemID, _, _, _, icon, classID= C_Item.GetItemInfoInstant(itemLink)
                if itemID then
                    tab[classID]=tab[classID] or {}
                    tab[classID][itemID]= {icon=icon, itemLink=itemLink}
                end
            end
        end
    end

    if menuList then
        for itemID, info in pairs(tab[menuList] or {}) do
            e.LibDD:UIDropDownMenu_AddButton({
                text= info.itemLink or itemID,
                icon= info.icon,
                checked= Save.items[itemID],
                arg1= itemID,
                tooltipOnButton=true,
                tooltipTitle=itemID,
                tooltipText= e.cn(C_Spell.GetSpellDescription(itemID)),
                keepShownOnClick=true,
                func= function(_, arg1)
                    Save.items[arg1]= not Save.items[arg1] and true or nil
                    self:GetParent():settings()
                end
            }, level)
        end
        return
    end

    for classID in pairs(tab) do
        e.LibDD:UIDropDownMenu_AddButton({
            text= classID..' '..(e.cn(C_Item.GetItemClassInfo(classID)) or ''),
            menuList= classID,
            hasArrow=true,
            keepShownOnClick=true,
            notCheckable=true,
        }, level)
    end
    
    e.LibDD:UIDropDownMenu_AddSeparator(level)
    e.LibDD:UIDropDownMenu_AddButton({
        text= (e.onlyChinese and '禁用添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, ADD))..' |cnGREEN_FONT_COLOR:#'..get_num_items()..'|r',
        keepShownOnClick=true,
        hasArrow=true,
        menuList='DISABLE',
        notCheckable=true,
    }, level)
end




















local function Init_Disabled_Button()
    local btn= e.Cbtn(ScrappingMachineFrame, {size=28, icon='hide'})
    btn.Text= e.Cstr(btn)
    btn.Text:SetPoint('CENTER')
    btn:SetPoint('RIGHT', -10,0)
    function btn:get_num()
        local n=0
        for _ in pairs(Save.items) do
            n=n+1
        end
        return n
    end
    function btn:settings()
        self.Text:SetText(self:get_num())
        self:SetNormalAtlas(e.Icon.disabled)
    end
    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()

        local infoType, _, itemLink= GetCursorInfo()
        if infoType == "item" and itemLink then
            local texture= C_Item.GetItemIconByID(itemLink)
            if texture then
                self:SetNormalTexture(texture)
                e.tips:SetHyperlink(itemLink)
                e.tips:Show()
                return
            end
        end

        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(
            (e.onlyChinese and '禁用物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, ITEMS))..' |cnGREEN_FONT_COLOR:#'..self.Text:GetText(),
            e.onlyChinese and '自动添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ADD)
        )
        e.tips:AddDoubleLine(
            e.Icon.left..(e.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS)),
            (e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..e.Icon.right
        )        
        e.tips:Show()
    end
    btn:SetScript('OnLeave', function(self) e.tips:Hide() self:settings() end)
    btn:SetScript('OnEnter', btn.set_tooltips)
    btn:SetScript('OnClick', function(self, d)
        if d=='RightButton' then
            if not self.Menu then
                self.Menu= CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)--主菜单
        
        end
    end)
    btn:SetScript("OnMouseUp", function(self, d)
        if d~='LeftButton' then return end
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID then
            Save.items[itemID]= not Save.items[itemID] and true or nil
            print(id, Initializer:GetName(),
                Save.items[itemID] and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r'
                    or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r'),
                itemLink or itemID
            )
            ClearCursor()
            self:settings()
            self:set_tooltips()
        end
    end)

    btn:settings()
end





























local function Init()
    --拆解法术，提示
    ScrappingMachineFrame.ScrapButton:HookScript('OnLeave', GameTooltip_Hide)
    ScrappingMachineFrame.ScrapButton:HookScript('OnEnter', function(self)
        local spellID= C_ScrappingMachineUI.GetScrapSpellID()
        if not spellID or GameTooltip:IsOwned(self) then
            return
        end
        e.tips:SetOwner(self:GetParent(), "ANCHOR_BOTTOMRIGHT")
        e.tips:ClearLines()
        e.tips:SetSpellByID(spellID)
        e.tips:Show()
    end)

    --物品，提示
    for btn in ScrappingMachineFrame.ItemSlots.scrapButtons:EnumerateActive() do
        if (btn) then
            hooksecurefunc(btn, 'RefreshIcon', function(self)
                e.Set_Item_Info(self, {itemLink=self.itemLink})-- itemLocation= self.itemLocation})
            end)
        end
    end

    --清除，所有，物品
    ScrappingMachineFrame.celarAllItem= e.Cbtn(ScrappingMachineFrame, {size=28, atlas='bags-button-autosort-up'})
    ScrappingMachineFrame.celarAllItem:SetPoint('BOTTOMRIGHT', -8, 28)
    ScrappingMachineFrame.celarAllItem:SetScript('OnClick', C_ScrappingMachineUI.RemoveAllScrapItems)
    ScrappingMachineFrame.celarAllItem:SetScript('OnLeave', GameTooltip_Hide)
    ScrappingMachineFrame.celarAllItem:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(' ', '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL))
        e.tips:Show()
    end)
    


    --添加，所有，物品
    ScrappingMachineFrame.addAllItem= e.Cbtn(ScrappingMachineFrame, {size={23,23}, atlas='communities-chat-icon-plus'})
    ScrappingMachineFrame.addAllItem:SetPoint('LEFT', ScrappingMachineFrame.ScrapButton, 'RIGHT', 2,0)
    ScrappingMachineFrame.addAllItem:SetScript('OnLeave', GameTooltip_Hide)
    ScrappingMachineFrame.addAllItem:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddLine((e.onlyChinese and '添加' or ADD)..'|A:communities-chat-icon-plus:0:0|a'..(e.onlyChinese and '所有' or ALL))
        e.tips:Show()
    end)
    ScrappingMachineFrame.addAllItem:SetScript('OnClick', function()
        local free= MaxNumeri-get_num_items()
        if free==0 then
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
    end)

    --添加，所有，宝石
    ScrappingMachineFrame.addAllGem= e.Cbtn(ScrappingMachineFrame.addAllItem, {size=23, texture=135998})
    ScrappingMachineFrame.addAllGem:SetPoint('LEFT', ScrappingMachineFrame.addAllItem, 'RIGHT', 4,0)
    ScrappingMachineFrame.addAllGem:SetScript('OnLeave', GameTooltip_Hide)
    ScrappingMachineFrame.addAllGem:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddLine((e.onlyChinese and '添加' or ADD)..'|T135998:0|t'..(e.onlyChinese and '宝石' or AUCTION_CATEGORY_GEMS))
        e.tips:Show()
    end)
    ScrappingMachineFrame.addAllGem:SetScript('OnClick', function()
        local free= MaxNumeri- get_num_items()
        if free==0 then
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
    end)


    --添加，所有，装备
    ScrappingMachineFrame.addAllEquip= e.Cbtn(ScrappingMachineFrame.addAllItem, {size={23,23}, texture=135995})
    ScrappingMachineFrame.addAllEquip:SetPoint('LEFT', ScrappingMachineFrame.addAllGem, 'RIGHT', 4, 0)
    ScrappingMachineFrame.addAllEquip:SetScript('OnLeave', GameTooltip_Hide)
    ScrappingMachineFrame.addAllEquip:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddLine((e.onlyChinese and '添加' or ADD)..'|T135995:0|t'..(e.onlyChinese and '装备' or BAG_FILTER_EQUIPMENT))
        e.tips:Show()
    end)

    ScrappingMachineFrame.addAllEquip:SetScript('OnClick', function()
        local free= MaxNumeri-get_num_items()
        if free==0 then
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
    end)

    


    hooksecurefunc(ScrappingMachineFrame, 'UpdateScrapButtonState', function(self)
        self.celarAllItem:SetAlpha(C_ScrappingMachineUI.HasScrappableItems() and 1 or 0.3)
        self.addAllItem:SetAlpha(MaxNumeri> get_num_items() and 1 or 0.3)
    end)
end














--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|TInterface\\Icons\\inv_gizmo_03:0|t'..(e.onlyChinese and '拆解大师Mk1型' or addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(Save.disabled), ScrappingMachineFrame and (e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD) or '')
                end
            })

            if Save.disabled then
                self:UnregisterEvent('ADDON_LOADED')
            end

        elseif arg1=='Blizzard_ScrappingMachineUI' then--分解 ScrappingMachineFrame
            Init()
            Init_Disabled_Button()
            --Init_Currency()
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)