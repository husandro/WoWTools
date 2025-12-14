
local function Save()
    return WoWToolsSave['Plus_GuildBank']
end



--GuildBankFrame:UpdateTabs()
--GuildBankFrame:Update()
local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub

--标签
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '标签' or 'Tab',
    function()
        return Save().plusTab
    end, function()
        Save().plusTab= not Save().plusTab and true or nil
        GuildBankFrame:UpdateTabs()
    end)

--索引
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '索引' or 'Index',
    function()
        return Save().showIndex
    end, function()
        Save().showIndex= not Save().showIndex and true or nil--显示，索引
        WoWTools_GuildBankMixin:Init_Plus()
    end)

--物品信息
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO),
    function()
        return Save().plusItem
    end, function()
        Save().plusItem= not Save().plusItem and true or nil
        GuildBankFrame:Update()
    end)


--打开，背包
    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL,
    function()
        return Save().autoOpenBags
    end, function()
        Save().autoOpenBags= not Save().autoOpenBags and true or nil
        if Save().autoOpenBags then
            do
                WoWTools_BagMixin:OpenBag(nil, false)
            end
            if not InCombatLockdown() then
                GuildBankFrame:Raise()
            end
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '打开公会银行时' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OPENING, GUILD_BANK))
        tooltip:AddLine(MicroButtonTooltipText(WoWTools_DataMixin.onlyChinese and '打开所有背包' or BINDING_NAME_OPENALLBAGS, "OPENALLBAGS")
    )
    end)

    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().saveItemSeconds or 0.8
        end, setValue=function(value)
            Save().saveItemSeconds=value
        end,
        name=WoWTools_DataMixin.onlyChinese and '延迟' or LAG_TOLERANCE,
        minValue=0.2,
        maxValue=3,
        step=0.1,
        bit='%.1f',
        tooltip=function(tooltip)
            tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '延迟' or LAG_TOLERANCE,
                (Save().saveItemSeconds or 0.8 )..' '..(WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
            )
            if WoWTools_DataMixin.onlyChinese then
                tooltip:AddLine('存放，提取，整理')
            else
                tooltip:AddLine(DEPOSIT..', '..WITHDRAW..', '..BAG_CLEANUP_BANK)
            end
        end
    })
    root:CreateSpacer()

    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_GuildBankMixin.addName})
    WoWTools_MenuMixin:Reload(sub)


end



local function Init()
    local btn= WoWTools_ButtonMixin:Menu(GuildBankFrame.CloseButton, {
        name='WoWToolsGuildBankMenuButton',
    })
    btn:SetPoint('RIGHT', GuildBankFrame.CloseButton, 'LEFT', -2, 0)

    btn:SetupMenu(Init_Menu)

    Init=function()end
end




function WoWTools_GuildBankMixin:Init_Menu()
   Init()
end