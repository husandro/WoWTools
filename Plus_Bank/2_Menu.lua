local function Save()
    return WoWToolsSave['Plus_Bank2']
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub, sub2

--Plus 必需重新载加，因为hook Mixin
    sub= root:CreateButton(
        'Plus',
    function()
        return MenuResponse.Open
    end)

--标签
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '标签' or 'Tab',
    function()
        return Save().plusTab
    end, function()
        Save().plusTab= not Save().plusTab and true or nil
        WoWTools_BankMixin:Init_BankPlus()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--索引
    sub2=sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '索引' or 'Index', function()
        return Save().plusIndex
    end, function()
        Save().plusIndex= not Save().plusIndex and true or nil--显示，索引
        WoWTools_BankMixin:Init_BankPlus()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--索引
    sub2=sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO), function()
        return Save().plusItem
    end, function()
        Save().plusItem= not Save().plusItem and true or nil--显示，索引
        WoWTools_BankMixin:Init_BankPlus()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--重新加载UI
    sub:CreateDivider()
    WoWTools_MenuMixin:Reload(sub)







--转化为联合的大包
    root:CreateSpacer()
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '转化为联合的大包' or BAG_COMMAND_CONVERT_TO_COMBINED,
    function()
        return Save().allBank
    end, function()
        Save().allBank= not Save().allBank and true or nil
        local isInit= BankPanel.tabNames
        do
            WoWTools_BankMixin:Init_AllBank()
        end
        if not isInit then
            BankPanel:RefreshBankPanel()
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
    end)



--行数
    --root:CreateDivider()
    sub:CreateSpacer()
    sub2=WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().num
        end, setValue=function(value)
            Save().num=value
            WoWTools_BankMixin:Init_AllBank()
        end,
        name=WoWTools_DataMixin.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
        minValue=4,
        maxValue=32,
        step=1,
        bit=nil,
    })
    sub2:SetEnabled(Save().allBank)

--间隔
    sub:CreateSpacer()
    sub:CreateSpacer()
    sub2=WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().line
        end, setValue=function(value)
            Save().line=value
            WoWTools_BankMixin:Init_AllBank()
        end,
        name=WoWTools_DataMixin.onlyChinese and '间隔' or 'Interval',
        minValue=0,
        maxValue=32,
        step=1,
        bit=nil,
    })
    sub2:SetEnabled(Save().allBank)






--打开选项界面
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BankMixin.addName})
--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
end

















local function Init()
    local btn= WoWTools_ButtonMixin:Menu(BankFrameCloseButton, {name='WoWToolsPlusBankMenuButton'})
    btn:SetPoint('RIGHT', BankFrameCloseButton, 'LEFT', -2,0)

    function btn:Open_Bag()
        WoWTools_BagMixin:OpenBag(nil, true)
        C_Timer.After(0.3, function() BankFrame:Raise() end)
    end
    btn:SetupMenu(Init_Menu)


    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
        GameTooltip:Show()
    end)


    local wow= WoWTools_ItemMixin:Create_WoWButton(btn, {
        name='WoWToolsPlusBankWoWButton',
        tooltip=function(tooltip)
            --[[tooltip:AddLine(' ')
            tooltip:AddLine(
                WoWTools_DataMixin.Icon.left
                ..(WoWTools_DataMixin.onlyChinese and '保存物品' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, ITEMS))
            )]]
            tooltip:AddLine(
                '|A:BonusLoot-Chest:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '保存物品' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, ITEMS))
                ..WoWTools_DataMixin.Icon.right
                ..WoWTools_TextMixin:GetEnabeleDisable(Save().saveWoWData)
            )
        end,
        click=function(self, d, click)
            if d=='LeftButton' then
                click()
            else
                MenuUtil.CreateContextMenu(self, function(_, root)
                    local sub=root:CreateCheckbox(
                        '|A:BonusLoot-Chest:0:0|a'
                        ..(WoWTools_DataMixin.onlyChinese and '保存物品' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, ITEMS)),
                    function()
                        return Save().saveWoWData
                    end, function()
                        self:set_click()
                    end)
                    sub:SetTooltip(function(tooltip)
                        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '记录' or GUILD_BANK_LOG)
                    end)

                    root:CreateSpacer()

                    WoWTools_ItemMixin:OpenWoWItemListMenu(self, root)
                end)
            end
        end}
    )
    wow:SetPoint('RIGHT', btn, 'LEFT')
    wow:GetNormalTexture():SetVertexColor(1,1,1)
    function wow:settings()
        local saveWoWData= Save().saveWoWData
        local icon= self:GetNormalTexture()
        icon:SetDesaturated(not saveWoWData)
        icon:SetAlpha(saveWoWData and 1 or 0.3)
    end
    function wow:set_click()
        Save().saveWoWData= not Save().saveWoWData and true or nil
        self:settings()
        BankPanel:Clean()
    end
    wow:settings()


    --[[
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '保存物品' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, ITEMS),
    function()
        return Save().saveWoWData
    end, function()
        Save().saveWoWData= not Save().saveWoWData and true or nil
        BankPanel:Clean()
    end)
    WoWTools_ItemMixin:OpenWoWItemListMenu(self, sub)
    ]]
    Init=function()end
end


function WoWTools_BankMixin:Init_BankMenu()
    Init()
end