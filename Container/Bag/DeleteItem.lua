local function Save()
    return WoWToolsSave['Plus_Container'].delete
end
local btn







local function Delete_Item()
    --[[if InCombatLockdown() then
        return
    end]]

    local infoType, itemID, itemLink= GetCursorInfo()

    if infoType ~= "item" or not itemID then
        return
    end

    local quality= C_Item.GetItemQualityByID(itemID)

    if not quality or quality> Enum.ItemQuality.Uncommon then--优秀
        return
    end

    DeleteCursorItem()

    print(
        WoWTools_DataMixin.Icon.icon2
        ..(WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY),
        itemLink
    )

    C_Timer.After(0.3, function()
        btn:set_count()
    end)
end









local function Get_ItemList(quality)
    return WoWTools_BagMixin:GetItems(true, false, false, function(_, _, info)
        if quality then
            return quality==info.quality
        else
            return Save().item[info.itemID]
        end
    end)
end







local function Delete_AllItem(quality)
    local tab= Get_ItemList(quality)
    for _, data in pairs(tab) do
        C_Container.PickupContainerItem(data.bag, data.slot)
        do
            Delete_Item()
        end
        if GetCursorInfo() then
            ClearCursor()
        end
        break
    end
end
    --[[local tab= Get_ItemList(quality)
    local num= #tab
    if num>0 then
        local index=1
        C_Timer.NewTicker(2, function()
            local bag= tab[index].bag
            local slot= tab[index].slot
            local info= C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID and not info.isLocked then
                C_Container.PickupContainerItem(bag, slot)
                Delete_Item()
                if GetCursorInfo() then
                    ClearCursor()
                end
            end
            index= index+1
        end, num)
    end]]









local function Init_Menu(self, root)
    if not self:IsMouseOver()
       -- or WoWTools_MenuMixin:CheckInCombat(root)--战斗中
    then
        return
    end

    local new= {}
    for itemID in pairs(Save().item) do
        table.insert(new, itemID)
    end
    table.sort(new, function(a,b) return a> b end)

    local sub, sub2

--摧毁全部
    sub= root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '摧毁全部' or HOUSING_DECOR_STORAGE_ITEM_DESTROY_ALL,
    function()
        Delete_AllItem()
        return MenuResponse.Refresh
    end, {rightText=--format('%d %s%s',
                #Get_ItemList()
                --Save().auto and '|cnGREEN_FONT_COLOR:' or '|cnDISABLED_FONT_COLOR:',
                --WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO
    })

    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自动摧毁' or  format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, HOUSING_DECOR_STORAGE_ITEM_DESTROY),
    function()
        return Save().auto
    end, function()
        Save().auto= not Save().auto and true or false
        self:set_event()
        self:set_texture()
    end, {rightText= #new})
    WoWTools_MenuMixin:SetRightText(sub)

--勾选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '勾选所有' or EVENTTRACE_BUTTON_ENABLE_FILTERS,
    function()
        for _, itemID in pairs(new) do
            Save().item[itemID]=true
        end
        return MenuResponse.Refresh
    end)

--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
     function()
        Save().item={}
        return MenuResponse.Refresh
    end)
    sub:CreateDivider()

    for index, itemID in pairs(new) do
        sub2= sub:CreateCheckbox(
            itemID,
        function(data)
            return Save().item[data.itemID]
        end, function(data)
            Save().item[data.itemID]= not Save().item[data.itemID] and true or nil
        end, {itemID=itemID, rightText=index, rightColor=DISABLED_FONT_COLOR})

        WoWTools_MenuMixin:LoadName(sub2)
        WoWTools_MenuMixin:SetRightText(sub2)
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)

    root:CreateDivider()
    for quality= Enum.ItemQuality.Poor, Enum.ItemQuality.Uncommon do

        local qualityTab= Get_ItemList(quality)

        sub=root:CreateButton(
            WoWTools_ItemMixin.QualityText[quality],
        function(data)
            Delete_AllItem(data.quality)
        end, {rightText=#qualityTab, quality=quality})
        WoWTools_MenuMixin:SetRightText(sub)


        --勾选所有
        sub:CreateButton(
            WoWTools_DataMixin.onlyChinese and '勾选所有' or EVENTTRACE_BUTTON_ENABLE_FILTERS,
        function(data)
            for _, info in pairs(data) do
                Save().item[info.itemID]= true
            end
            return MenuResponse.Refresh
        end, qualityTab)

    --撤选所有
        sub:CreateButton(
            WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
        function(data)
             for _, info in pairs(data) do
                Save().item[info.itemID]= nil
            end
            return MenuResponse.Refresh
        end, qualityTab)
        sub:CreateDivider()


        for index, bag in pairs(qualityTab) do
            sub2= sub:CreateCheckbox(
                bag.info.itemID,
            function(data)
                return Save().item[data.itemID]
            end, function(data)
                Save().item[data.itemID]= not Save().item[data.itemID] and true or nil
            end, {itemID=bag.info.itemID, rightText=index, itemLink= bag.info.hyperlink})

            WoWTools_MenuMixin:LoadName(sub2)
            WoWTools_MenuMixin:SetRightText(sub2)
            WoWTools_SetTooltipMixin:Set_Menu(sub2)
        end

        WoWTools_MenuMixin:SetScrollMode(sub)
    end
end




local function Init()
    btn= CreateFrame('DropdownButton', 'WoWToolsBagDeleteItemButton', ContainerFrameCombinedBags.CloseButton, 'WoWToolsMenu3Template')
    btn:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT', -23, 0)
    btn:SetNormalAtlas('common-icon-delete')
    --btn:SetNormalTexture(WoWTools_DataMixin.Icon.icon)
   --btn:GetNormalTexture():ClearAllPoints()
    --btn:GetNormalTexture():SetPoint('CENTER')

    btn.Count= btn:CreateFontString(nil, 'ARTWORK', 'WoWToolsFont2')
    btn.Count:SetPoint('BOTTOMRIGHT', -1, 1)

    function btn:tooltip()
        if not self:IsMouseOver() then
            return
        end
        --GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        --GameTooltip:ClearLines()
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.icon2
            ..format(
                '%s: %s (%s)',
                WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY,
                WoWTools_ItemMixin.QualityText[2],--优秀  
                WoWTools_DataMixin.onlyChinese and '最高' or VIDEO_OPTIONS_ULTRA_HIGH
        )
        --(Save().auto and '|cnGREEN_FONT_COLOR:' or '|cff626262')
        --..(WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO)
    )


        local infoType, itemID= GetCursorInfo()
        if not infoType then
            local tab=Get_ItemList()
            local info= tab[1] and tab[1].info
            if info then
                GameTooltip:AddDoubleLine(
                    WoWTools_ItemMixin:GetName(info.itemID),
                    '|A:common-icon-delete:0:0|a'
                    ..(WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY)
                )
            end
            self.Count:SetText(#tab)

        elseif infoType == "item" and itemID then
            local quality= C_Item.GetItemQualityByID(itemID)
            if quality and quality<= Enum.ItemQuality.Uncommon then--优秀
                --name, col= WoWTools_ItemMixin:GetName(itemID)
                GameTooltip:AddLine(WoWTools_ItemMixin:GetName(itemID), nil)

                if Save().auto then
                    local has= Save().item[itemID] and true or false
                    if has then
                        GameTooltip:AddDoubleLine(' ',
                            '|A:common-icon-redx:0:0|a'
                            ..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)
                        )
                        self:SetNormalAtlas('common-icon-redx')
                    else
                        GameTooltip:AddDoubleLine(' ',
                            '|A:common-icon-delete:0:0|a'
                            ..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
                        )
                        self:SetNormalTexture(C_Item.GetItemIconByID(itemID))
                    end
                else
                    GameTooltip:AddDoubleLine(' ',
                            '|A:common-icon-delete:0:0|a'
                            ..(WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY)
                        )
                end
            end
            self:set_count()
        end
        --GameTooltip:Show()
        
    end

    function btn:set_count()
        self.Count:SetText(#Get_ItemList())
    end

    --[[function btn:set_texture()
        local isDisabled= Save().disabled
        --self:SetNormalAtlas(isDisabled and 'common-icon-delete-disable' or 'common-icon-delete')
        --self:SetAlpha(isDisabled and 0.5 or 1)
        if isDisabled then
            self:GetNormalTexture():SetSize(16,16)
        else
            self:GetNormalTexture():SetSize(23,23)
        end
    end]]

    --[[function btn:set_event()
        self:UnregisterAllEvents()
        if Save().auto then
            self:RegisterEvent('GLOBAL_MOUSE_DOWN')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            --self:RegisterEvent('BAG_UPDATE_DELAYED')
        end
    end]]

    --[[btn:SetScript('OnLeave', function()
        GameTooltip_Hide()
        --self:set_texture()
    end)
    btn:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
        self:tooltip()
    end)]]

    --[[btn:SetScript('OnEvent', function(self, event)
      
        if event=='GLOBAL_MOUSE_DOWN' then
              print(event)
            Delete_AllItem()
        elseif event=='PLAYER_REGEN_ENABLED' then
            self:RegisterEvent('GLOBAL_MOUSE_DOWN')
            Delete_AllItem()

        elseif event=='PLAYER_REGEN_DISABLED' then
            self:UnregisterEvent('GLOBAL_MOUSE_DOWN')
        end
    end)]]



    --[[btn:SetScript('OnHide', function(self)
        self:set_event()
        if Save().auto then
            Delete_AllItem()
        end
    end)
    ]]

    btn:SetScript('OnShow', function(self)
        self:set_count()
    end)


    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            return
        end

        self:CloseMenu()

        local infoType, itemID= GetCursorInfo()
        if not infoType then
            Delete_AllItem()
            C_Timer.After(0.3, function()
                self:tooltip()
            end)
            return
        end

        if infoType == "item" and itemID then
            local quality= C_Item.GetItemQualityByID(itemID)
            if quality and quality<= Enum.ItemQuality.Uncommon then--优秀
                --if Save().auto then
                    Save().item[itemID]= not Save().item[itemID] and true or nil

                    if Save().item[itemID] then
                        Delete_Item()
                    end
                --[[else
                    Delete_Item()
                end]]

                --self:set_texture()
                
                self:tooltip()
                
            end
        end
    end)



    btn:SetupMenu(Init_Menu)
    --btn:set_texture()
    --btn:set_event()
    Init=function()end
end

function WoWTools_BagMixin:Init_DeleteItem()
    Init()
end