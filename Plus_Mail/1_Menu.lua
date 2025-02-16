if GameLimitedMode_IsActive() then
    return
end


local e= select(2, ...)
local function Save()
    return WoWTools_MailMixin.Save
end





local function Init_Menu(self, root)
    local sub

    local function set_tooltip(tooltip)
        tooltip:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
    end

    sub=root:CreateCheckbox(
        'UI Plus',
    function()
        return not Save().hideUIPlus
    end, function()
        Save().hideUIPlus= not Save().hideUIPlus and true or nil
    end)
    sub:SetTooltip(set_tooltip)

    root:CreateTitle(e.onlyChinese and '收件箱' or INBOX)
    root:CreateCheckbox(
        (e.onlyChinese and '收件箱' or INBOX)..' Plus',
    function()
        return not Save().hide
    end, function()
        Save().hide= not Save().hide and true or nil
        WoWTools_MailMixin:RefreshAll()
    end)


    root:CreateTitle(e.onlyChinese and '发件箱' or SENDMAIL)

    sub=root:CreateCheckbox(
        e.onlyChinese and '名单列表' or WHO_LIST,
    function()
        return not Save().hideSendNameList
    end, function()
        Save().hideSendNameList= not Save().hideSendNameList and true or nil
    end)
    sub:SetTooltip(set_tooltip)


    sub=root:CreateCheckbox(
        e.onlyChinese and '历史收件人' or format(CRAFTING_ORDER_MAIL_FULFILLED_TO, HISTORY),
    function()
        return not Save().hideHistoryList
    end, function()
        Save().hideHistoryList= not Save().hideHistoryList and true or nil
    end)
    sub:SetTooltip(set_tooltip)


    sub=root:CreateCheckbox(
        e.onlyChinese and '物品快捷键' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, SETTINGS_KEYBINDINGS_LABEL),
    function()
        return not Save().hideItemButtonList
    end, function()
        Save().hideItemButtonList= not Save().hideItemButtonList and true or nil
    end)
    sub:SetTooltip(set_tooltip)

    sub=root:CreateCheckbox(
        e.onlyChinese and '自动转到收件箱' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NPE_TURN, SENDMAIL)),
    function()
        return not Save().notAutoToSendFrame
    end, function()
        Save().notAutoToSendFrame= not Save().notAutoToSendFrame and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '尚未发现信件' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TAXI_PATH_UNREACHABLE, MAIL_LABEL))
    end)


    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().autoToSendFrameSecond or 1
        end, setValue=function(value)
            Save().autoToSendFrameSecond=value
        end,
        name=e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS ,
        minValue=0.5,
        maxValue=5,
        step=1,
        bit='%.1f',
    })
    sub:CreateSpacer()

    root:CreateDivider()

--重新加载UI
    WoWTools_MenuMixin:Reload(root)
--打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MailMixin.addName})
end










local function Init()
    local btn=WoWTools_ButtonMixin:CreateMenu(MailFrameCloseButton, {name='WoWToolsMailMenuButton'})
    btn:SetPoint('RIGHT', MailFrameCloseButton, 'LEFT')

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_MailMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine((e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), e.Icon.left)
        GameTooltip:Show()
    end)


    btn:SetupMenu(Init_Menu)
end




function WoWTools_MailMixin:Init_Menu_Button()
    Init()
end