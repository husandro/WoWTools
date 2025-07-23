local function Save()
    return WoWToolsSave['Plus_GuildBank']
end
local MAX_GUILDBANK_SLOTS_PER_TAB= 98
















local StopRun, IsInRun

local function Init_Sort()
    if IsInRun then--禁用，按钮移动事件
        StopRun=true--停止，已运行
        return
    else
        local atlas= WoWTools_GuildBankMixin:Get_Access()
        if atlas then
            return
        end
    end

    IsInRun= true

    local saveItemSeconds= (Save().saveItemSeconds or 0.8)+0.2
    local currentIndex = GetCurrentGuildBankTab() -- 当前 Tab

    local find, itemLink, itemQuality, itemTexture, classID, subclassID, _
    local isRightToLeft= Save().sortRightToLeft

    local items = {}

    for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
        itemLink = GetGuildBankItemLink(currentIndex, slot)
        if itemLink then
            _, _, itemQuality, _, _, _, _, _, _, itemTexture, _, classID, subclassID= C_Item.GetItemInfo(itemLink)
            table.insert(items, {
                slot = slot,
                link = itemLink,
                icon= itemTexture,
                rarity = itemQuality,
                type = classID,
                subType = subclassID,
            })
        end
    end

    if #items==0 then
        StopRun= nil
        IsInRun= nil
        return
    end

    table.sort(items, function(a, b)
        if a.type == b.type then
            if a.subType == b.subType then
                if a.rarity == b.rarity then
                    return a.icon < b.icon
                else
                    return a.rarity > b.rarity
                end
            else
                return a.subType < b.subType
            end
        else
            return a.type < b.type
        end
    end)

    for indexSlot, item in pairs(items) do
        item.indexSlot= isRightToLeft and MAX_GUILDBANK_SLOTS_PER_TAB-indexSlot+1 or indexSlot
    end


    local function sortItems()
        if
            IsModifierKeyDown()
            or not GuildBankFrame:IsShown()
            or GuildBankFrame.mode ~= "bank"
            or StopRun
            or GetCurrentGuildBankTab()~= currentIndex
        then
            StopRun= nil
            IsInRun= nil
            print(
                WoWTools_GuildBankMixin.addName,
                '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '排序' or STABLE_FILTER_BUTTON_LABEL)..'|r',
                    WoWTools_DataMixin.onlyChinese and '中断' or INTERRUPT
                )
            return
        end

        find=false
        for _, item in pairs(items) do
            if item.slot ~= item.indexSlot and GetGuildBankItemLink(currentIndex, item.indexSlot)~=item.link then
                PickupGuildBankItem(currentIndex, item.slot)
                PickupGuildBankItem(currentIndex, item.indexSlot)
                item.slot= item.indexSlot
                find=true
                --print(item.indexSlot, item.link)
                break
            end
        end

        if not find then
            IsInRun= nil
            print(
                WoWTools_GuildBankMixin.addName,
                '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '排序' or STABLE_FILTER_BUTTON_LABEL)..'|r',
                WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE
            )
            return
        end

        C_Timer.After(saveItemSeconds, function()
            sortItems()
        end)
    end

    sortItems()
end






local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local atlas, access= WoWTools_GuildBankMixin:Get_Access()
    if atlas then
        root:CreateTitle(atlas..access)
        return
    end


    root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '整理银行' or BAG_CLEANUP_BANK),
    function()
        Init_Sort()
        return MenuResponse.Open
    end)

    root:CreateDivider()

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '反向整理银行' or REVERSE_CLEAN_UP_BAGS_TEXT:gsub(HUD_EDIT_MODE_BAGS_LABEL, BANK),
    function()
        return Save().sortRightToLeft
    end, function()
        Save().sortRightToLeft= not Save().sortRightToLeft and true or nil
         if IsInRun then--禁用，按钮移动事件
            StopRun=true--停止，已运行
        end
    end)

    --[[root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().saveItemSeconds or 0.8
        end, setValue=function(value)
            Save().saveItemSeconds=value

            if IsInRun then--禁用，按钮移动事件
                StopRun=true--停止，已运行
            end

        end,
        name=WoWTools_DataMixin.onlyChinese and '延迟' or LAG_TOLERANCE,
        minValue=0.5,
        maxValue=1.5,
        step=0.1,
        bit='%.1f',
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '延迟' or LAG_TOLERANCE)
        end
    })
    root:CreateSpacer()]]
end




--REVERSE_CLEAN_UP_BAGS_TEXT = "反向整理背包";
--G_CLEANUP_BANK = "整理银行";
--..(WoWTools_DataMixin.onlyChinese and '整理银行' or BAG_CLEANUP_BANK)
local function Init()
    local btn= WoWTools_ButtonMixin:Cbtn(GuildBankFrame, {atlas='bags-button-autosort-up'})
    btn:SetPoint('TOPRIGHT', -15, -28)-- -15 -36
    btn:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        
        GameTooltip:SetText(
            '|A:bags-button-autosort-up:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '整理银行' or BAG_CLEANUP_BANK)
            ..WoWTools_DataMixin.Icon.left
            ..'|cnGREEN_FONT_COLOR:'
            ..(Save().saveItemSeconds or 0.8)
        )
        GameTooltip:AddLine(
            '|A:dressingroom-button-appearancelist-up:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:Show()
    end)
    --btn:SetupMenu(Init_Menu)
    btn:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            Init_Sort()
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    


    GuildItemSearchBox:ClearAllPoints()
    GuildItemSearchBox:SetPoint('RIGHT', btn, 'LEFT', -8, 0)


    Init=function()end
end


function WoWTools_GuildBankMixin:Init_Sort()
    Init()
end