local function Save()
    return WoWToolsSave['Plus_Container'].delete
end



local function Check_ItemQuality(itemID, quality)
    quality= quality or (itemID and C_Item.GetItemQualityByID(itemID))
    if quality then
        return quality<= Enum.ItemQuality.Uncommon or quality==Enum.ItemQuality.Heirloom
    end

end

local function Delete_Item()
    if not Save().inCombat and PlayerIsInCombat()  then
        return
    end

    local infoType, itemID, itemLink= GetCursorInfo()

    if infoType ~= "item" or not Check_ItemQuality(itemID) then
        return
    end

    DeleteCursorItem()

    print(
        WoWTools_DataMixin.Icon.icon2
        ..(WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY)
        ..'|A:common-icon-delete:0:0|a',
        itemLink
    )
end


















local function Check_Bag(bag, slot, quality)
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if info
        and info.itemID
        and not info.isLocked
        and Check_ItemQuality(nil, info.quality)
    then
        if quality then
            if quality==info.quality then
                return info
            end
        elseif Save().item[info.itemID] then
            return info
        end
    end
end

local function Get_BagAllItem(quality)
    local tab, num= {}, 0
    for bag= BACKPACK_CONTAINER, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do--0-5
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info= Check_Bag(bag, slot, quality)
            if info then
                num= num+ (info.stackCount or 1)
                table.insert(tab, {bag=bag, slot=slot, info=info})
            end
        end
    end
    return tab, num
end

local function Get_BagItem(quality)
    for bag= BACKPACK_CONTAINER, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do--0-5
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info= Check_Bag(bag, slot, quality)
            if info then
                return bag, slot, info
            end
        end
    end
end











local function Delete_AllItem(quality)
    if not Save().inCombat and PlayerIsInCombat() then
        return
    end

    local bag, slot= Get_BagItem(quality)
    if not bag or not slot then
        return
    end

    C_Container.PickupContainerItem(bag, slot)

    do
        Delete_Item()
    end

    if GetCursorInfo() then
        ClearCursor()
    end
end






local function Set_Auto()
    if not Save().auto then
        return
    end

    WorldFrame:HookScript('OnMouseDown', function()
        if not Save().auto
            or GetCursorInfo()
        then
            return
        end
        Delete_AllItem()
    end)
    Set_Auto=function()end
end









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
        --(WoWTools_DataMixin.onlyChinese and '摧毁全部' or HOUSING_DECOR_STORAGE_ITEM_DESTROY_ALL)
        (WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY)
        ..WoWTools_DataMixin:MK(select(2, Get_BagAllItem()), 3),
    function()
        Delete_AllItem()
        return MenuResponse.Refresh
    end, {rightText=
        Save().auto and '|cnGREEN_FONT_COLOR:' or '|cnDISABLED_FONT_COLOR:'
        ..(WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO)
        ..'|r'..CountTable(Save().item)
    })
    WoWTools_MenuMixin:SetRightText(sub)

    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自动摧毁' or  format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, HOUSING_DECOR_STORAGE_ITEM_DESTROY),
    function()
        return Save().auto
    end, function()
        Save().auto= not Save().auto and true or false
        Set_Auto()
        self:settings()
    end, {rightText= #new})
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('WorldFrame:HookScript(\"OnMouseDown\"')
        GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0)
    end)

    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT,
    function()
        return Save().inCombat
    end, function()
        Save().inCombat= not Save().inCombat and true or nil
        self:set_count()
    end)


--勾选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '勾选所有' or EVENTTRACE_BUTTON_ENABLE_FILTERS,
    function()
        for _, itemID in pairs(new) do
            Save().item[itemID]=true
        end
        self:set_count()
        return MenuResponse.Refresh
    end)

--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
     function()
        Save().item={}
        self:set_count()
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
            self:set_count()
        end, {itemID=itemID, rightText=index, rightColor=DISABLED_FONT_COLOR})

        WoWTools_MenuMixin:LoadName(sub2)
        WoWTools_MenuMixin:SetRightText(sub2)
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)





--品质，列表
    root:CreateDivider()
    for _, quality in pairs({
        Enum.ItemQuality.Poor,
        Enum.ItemQuality.Common,
        Enum.ItemQuality.Uncommon,
        Enum.ItemQuality.Heirloom,
    }) do

        local qualityTab, num= Get_BagAllItem(quality)

        sub=root:CreateButton(
            WoWTools_ItemMixin.QualityText[quality],
        function(data)
            Delete_AllItem(data.quality)
        end, {rightText=WoWTools_DataMixin:MK(num, 3), quality=quality})
        sub:SetTooltip(function (tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY)
        end)
        WoWTools_MenuMixin:SetRightText(sub)


        --勾选所有
        sub:CreateButton(
            WoWTools_DataMixin.onlyChinese and '勾选所有' or EVENTTRACE_BUTTON_ENABLE_FILTERS,
        function(data)
            for _, info in pairs(data) do
                Save().item[info.itemID]= true
            end
            self:set_count()
            return MenuResponse.Refresh
        end, qualityTab)

    --撤选所有
        sub:CreateButton(
            WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
        function(data)
             for _, info in pairs(data) do
                Save().item[info.itemID]= nil
            end
            self:set_count()
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
                self:set_count()
            end, {itemID=bag.info.itemID, rightText=index, itemLink= bag.info.hyperlink})

            WoWTools_MenuMixin:LoadName(sub2)
            WoWTools_MenuMixin:SetRightText(sub2)
            WoWTools_SetTooltipMixin:Set_Menu(sub2)
        end

        WoWTools_MenuMixin:SetScrollMode(sub)
    end


--打开选项界面
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BagMixin.addName})
end














local function Create_Button(frame)
    if not frame then
        return
    end

    local isCombinedBag= frame==ContainerFrameCombinedBags
    local btn= CreateFrame('DropdownButton', 'WoWToolsBagDeleteItemButton'..(isCombinedBag and 1 or 2), frame.CloseButton, 'WoWToolsMenu3Template')
    btn:SetPoint('RIGHT', frame.CloseButton, 'LEFT', isCombinedBag and -46 or -23, 0)
    btn:SetNormalAtlas('common-icon-delete')

    btn.Text= btn:CreateFontString(nil, 'ARTWORK', 'WoWToolsFont2')
    btn.Text:SetPoint('BOTTOMRIGHT', -1, 1)
    btn.Text:SetFontHeight(10)

    btn.Auto= btn:CreateFontString(nil, 'ARTWORK', 'WoWToolsFont2')
    btn.Auto:SetPoint('TOPLEFT', 1, -1)
    btn.Auto:SetText('A')
    btn.Auto:SetTextColor(GREEN_FONT_COLOR:GetRGB())
    btn.Auto:SetFontHeight(10)

    function btn:tooltip()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()

        if not Save().inCombat and PlayerIsInCombat() then
            GameTooltip_AddErrorLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '战斗中', HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        end

        GameTooltip:AddDoubleLine(
            format(
                '%s%s: %s (%s)',
                WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY,
                WoWTools_ItemMixin.QualityText[2],--优秀  
                WoWTools_DataMixin.onlyChinese and '最高' or VIDEO_OPTIONS_ULTRA_HIGH
            ),
            (Save().auto and '|cnGREEN_FONT_COLOR:' or '|cff626262')
            ..(WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO)
        )

        local infoType, itemID, itmeLink= GetCursorInfo()

        local icon
        if infoType == "item" and Check_ItemQuality(itemID) then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(
                WoWTools_ItemMixin:GetName(itemID, itmeLink),
                '|A:common-icon-delete:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY),
                nil, nil, nil, 0,1,0
            )
            icon= C_Item.GetItemIconByID(itemID)
        else
            local info= select(3, Get_BagItem())
            if info then
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(
                    WoWTools_ItemMixin:GetName(info.itemID),
                    '|A:common-icon-delete:0:0|a'
                    ..(WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY)
                )
                icon= info.iconFileID
                C_Container.SetItemSearch(C_Item.GetItemNameByID(info.itemID) or '')
            end
        end
        if icon then
            self:SetNormalTexture(icon)
        else
            self:SetNormalAtlas('common-icon-delete')
        end

        GameTooltip:Show()
    end

    function btn:set_count()
        local num= select(2, Get_BagAllItem())
        num= WoWTools_DataMixin:MK(num)
        self.Text:SetText(num)
        local auto= Save().auto
        self.Auto:SetShown(auto)
        if auto then
            if Save().inCombat then
                self.Auto:SetTextColor(WARNING_FONT_COLOR:GetRGB())
            else
                self.Auto:SetTextColor(GREEN_FONT_COLOR:GetRGB())
            end
        end
    end

    function btn:settings()
        self.Auto:SetShown(Save().auto)
    end

    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        self:SetNormalAtlas('common-icon-delete')
        C_Container.SetItemSearch('')
    end)
    btn:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
        self:tooltip()
    end)

    btn:SetScript('OnEvent', btn.set_count)
    btn:SetScript('OnHide', function(self)
        self:UnregisterEvent('BAG_UPDATE_DELAYED')
    end)
    btn:SetScript('OnShow', function(self)
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        self:set_count()
    end)

    btn:SetScript('OnMouseDown', function(self, d)
        local infoType, itemID= GetCursorInfo()
        if infoType == "item" and itemID and Check_ItemQuality(itemID) then
            self:CloseMenu()
            Save().item[itemID]= true
            Delete_Item()
            self:tooltip()

        elseif d=='LeftButton' then
            self:CloseMenu()
            Delete_AllItem()
        end

        C_Timer.After(0.3, function()
            if self:IsMouseOver() then
                self:tooltip()
            end
        end)
    end)

    btn:SetupMenu(Init_Menu)
end




























local function Init()
    if (not ContainerFrameCombinedBags and not ContainerFrame1)
        or Save().disabled
    then
        return
    end

    do
        Create_Button(ContainerFrameCombinedBags)
        Create_Button(ContainerFrame1)
    end
    Create_Button=function()end

    Set_Auto()

    Init=function()end
end



















function WoWTools_BagMixin:Init_DeleteItem()
    Init()
end


function WoWTools_BagMixin:Check_DeleteItem(itemID)
    if itemID then
        return Save().item[itemID]
    end
end