if GameLimitedMode_IsActive() then
    return
end



local function Save()
    return WoWToolsSave['Plus_Mail']
end





local function Init_Menu(_, root)
    local sub

    local function set_tooltip(tooltip)
        tooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
    end

    sub=root:CreateCheckbox(
        'UI Plus',
    function()
        return not Save().hideUIPlus
    end, function()
        Save().hideUIPlus= not Save().hideUIPlus and true or nil
    end)
    sub:SetTooltip(set_tooltip)

--重新加载UI
    WoWTools_MenuMixin:Reload(sub)

    root:CreateTitle(WoWTools_Mixin.onlyChinese and '收件箱' or INBOX)
    root:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '收件箱' or INBOX)..' Plus',
    function()
        return not Save().hide
    end, function()
        Save().hide= not Save().hide and true or nil
        WoWTools_MailMixin:Init_InBox()--收信箱，物品，提示
    end)


    root:CreateTitle(WoWTools_Mixin.onlyChinese and '发件箱' or SENDMAIL)

    sub=root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '名单列表' or WHO_LIST,
    function()
        return not Save().hideSendNameList
    end, function()
        Save().hideSendNameList= not Save().hideSendNameList and true or nil
        WoWTools_MailMixin:Init_Send_Name_List()--收件人，列表
    end)


    sub=root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '历史收件人' or format(CRAFTING_ORDER_MAIL_FULFILLED_TO, HISTORY),
    function()
        return not Save().hideHistoryList
    end, function()
        Save().hideHistoryList= not Save().hideHistoryList and true or nil
        WoWTools_MailMixin:Init_Send_History_Name()--收件人，历史记录
    end)


    sub=root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '物品快捷键' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, SETTINGS_KEYBINDINGS_LABEL),
    function()
        return not Save().hideItemButtonList
    end, function()
        Save().hideItemButtonList= not Save().hideItemButtonList and true or nil
        WoWTools_MailMixin:Init_Fast_Button()
    end)

    sub=root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '自动转到发件箱' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NPE_TURN, SENDMAIL)),
    function()
        return not Save().notAutoToSendFrame
    end, function()
        Save().notAutoToSendFrame= not Save().notAutoToSendFrame and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '尚未发现信件' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TAXI_PATH_UNREACHABLE, MAIL_LABEL))
    end)


    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().autoToSendFrameSecond or 1
        end, setValue=function(value)
            Save().autoToSendFrameSecond=value
        end,
        name=WoWTools_Mixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS ,
        minValue=0.5,
        maxValue=5,
        step=0.1,
        bit='%.1f',
    })
    sub:CreateSpacer()

    root:CreateDivider()


--打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MailMixin.addName})
end










local function Init()
    local btn=WoWTools_ButtonMixin:Menu(MailFrameCloseButton, {name='WoWToolsMailMenuButton'})
    btn:SetPoint('RIGHT', MailFrameCloseButton, 'LEFT')

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_MailMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)


    btn:SetupMenu(Init_Menu)
end




function WoWTools_MailMixin:Init_Menu_Button()
    Init()
end