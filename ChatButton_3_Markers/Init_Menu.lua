local e= select(2, ...)
local function Save()
    return WoWTools_MarkerMixin.Save
end











local function Init_RaidTarget_Menu(_, root)
    local sub

    local function restGroup()
        Save().tank= 2
        Save().tank2= 6
        Save().healer= 1
    end
    local function checkGroup(index)
        if Save().tank~=index and Save().healer~=index and Save().tank2~=index then
            return true
        end
    end
    local function restSelf()
        Save().isSelf= 4
        Save().target=7
    end
    local function checkSelf(index)
        if Save().isSelf~=index and Save().target~=index then
            return true
        end
    end

    local Tab={
        {
            text= e.Icon.TANK..(WoWTools_Mixin.onlyChinese and '坦克' or TANK),
            type='tank',
            tip= WoWTools_Mixin.onlyChinese and '小队或团队' or  (GROUP..' '..OR_CAPS ..' '..RAID),
            rest=restGroup,
            check=checkGroup
        },
        {
            text= e.Icon.HEALER..(WoWTools_Mixin.onlyChinese and '治疗' or HEALER),
            type='healer',
            tip=WoWTools_Mixin.onlyChinese and '仅限小队' or format(LFG_LIST_CROSS_FACTION, GROUP),
            rest=restGroup,
            check=checkGroup
        },
        {
            text= e.Icon.TANK..(WoWTools_Mixin.onlyChinese and '坦克' or TANK)..'2',
            type='tank2',
            tip=WoWTools_Mixin.onlyChinese and '仅限团队' or format(LFG_LIST_CROSS_FACTION, RAID),
            rest=restGroup,
            check=checkGroup
        },
        {
            text='|A:auctionhouse-icon-favorite:0:0|a'..(WoWTools_Mixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
            type='isSelf',
            tip=WoWTools_Mixin.onlyChinese and '不在队伍' or PARTY_LEAVE,
            rest=restSelf,
            check=checkSelf
        },
        {
            text='|A:Target:0:0|a'..(WoWTools_Mixin.onlyChinese and '目标' or TARGET),
            type='target',
            tip=WoWTools_Mixin.onlyChinese and '不在队伍' or PARTY_LEAVE,
            rest= restSelf,
            check=checkSelf
        }
    }
    for _, info in pairs(Tab) do
        sub=root:CreateButton(
            info.text,
        function(data)
            data.rest()
            WoWTools_MarkerMixin.MarkerButton:settings()
            WoWTools_MarkerMixin:Set_TankHealer(true)
            return MenuResponse.Refresh
        end, {
            text= info.text, type=info.type, rest=info.rest
        })

        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '重置' or RESET)
            tooltip:AddLine(desc.data.tip)
        end)
        sub:AddInitializer(function(button, desc)
            local index=Save()[desc.data.type]
            button.fontString:SetText(
                (index and WoWTools_MarkerMixin:SetColor(index).col or '')
                ..desc.data.text
                ..(index and '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..index..':0|t' or '')
            )
        end)

        root:CreateDivider()

        for i=1, NUM_RAID_ICONS do
            sub=root:CreateRadio(
                '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..i..':0|t'
                ..WoWTools_MarkerMixin:SetColor(i).col
                ..e.cn(_G['RAID_TARGET_'..i]),
            function(data)
                return Save()[data.type]==data.index
            end, function(data)
                if Save()[data.type]==data.index then
                    Save()[data.type]=nil

                elseif data.check(data.index) then
                    Save()[data.type]=data.index
                end
                WoWTools_MarkerMixin.MarkerButton:settings()
                WoWTools_MarkerMixin:Set_TankHealer(true)
                return MenuResponse.Refresh

            end, {text=info.text, index=i, type=info.type, tip=info.tip, check=info.check})

            sub:SetTooltip(function(tooltip, desc)
                tooltip:AddDoubleLine(desc.data.text, desc.data.index)
                tooltip:AddLine(desc.data.tip)
            end)

            sub:AddInitializer(function(button, desc)
                local index= desc.data.index
                button.fontString:SetAlpha(desc.data.check(index) and 1 or 0.3)
            end)
        end
    end

    root:SetGridMode(MenuConstants.VerticalGridDirection, #Tab)
end
















local function Init_Menu(self, root)
    local sub, sub2

    sub=root:CreateCheckbox(
        (Save().tank==0 and Save().healer==0 and '|cff9e9e9e' or '')
        ..'|A:mechagon-projects:0:0|a'
        ..((WoWTools_Mixin.onlyChinese and '自动标记' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, EVENTTRACE_MARKER))
        ..e.Icon.TANK..e.Icon.HEALER
    ), function ()
        return Save().autoSet
    end, function ()
        Save().autoSet= not Save().autoSet and true or nil
        WoWTools_MarkerMixin.TankHealerFrame:set_Enabel_Event()
        WoWTools_MarkerMixin:Set_TankHealer()
    end)




    Init_RaidTarget_Menu(self, sub)





    root:CreateDivider()
    sub=root:CreateCheckbox(
        (WoWTools_MapMixin:IsInPvPArea() or (WoWTools_MarkerMixin.MakerFrame and not WoWTools_MarkerMixin.MakerFrame:CanChangeAttribute()) and '|cff9e9e9e' or '')
        ..(WoWTools_Mixin.onlyChinese and '队伍标记工具' or format(PROFESSION_TOOL_TOOLTIP_LINE, BINDING_HEADER_RAID_TARGET)
    ), function()
        return WoWTools_MarkerMixin.MakerFrame and WoWTools_MarkerMixin.MakerFrame:IsShown()
    end, function()
        Save().markersFrame= not Save().markersFrame and true or nil
        WoWTools_MarkerMixin:Init_Markers_Frame()--设置标记, 框架
    end)
    sub:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, WoWTools_Mixin.onlyChinese and '世界标记' or SLASH_WORLD_MARKER3:gsub('/',''))
        GameTooltip_AddNormalLine(tooltip, WoWTools_Mixin.onlyChinese and '需求：队伍和权限' or (NEED..": "..format(COVENANT_RENOWN_TOAST_REWARD_COMBINER, HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS, CALENDAR_INVITELIST_SETMODERATOR)))
        if WoWTools_MarkerMixin.MakerFrame and not WoWTools_MarkerMixin.MakerFrame:CanChangeAttribute() then
            GameTooltip_AddErrorLine(tooltip, WoWTools_Mixin.onlyChinese and "当前禁用操作" or (REFORGE_CURRENT..': '..DISABLE))
        end
    end)


    WoWTools_MarkerMixin:Init_MarkerTools_Menu(self, sub)--队伍标记工具, 选项，菜单


    sub=root:CreateCheckbox(WoWTools_Mixin.onlyChinese and '队员就绪信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, READY, INFO)), function()
        return Save().groupReadyTips
    end, function()
        Save().groupReadyTips= not Save().groupReadyTips and true or nil
        WoWTools_MarkerMixin:Init_Ready_Tips_Button()--注册事件, 就绪,队员提示信息
        if Save().groupReadyTips then--测试
            WoWTools_MarkerMixin.ReadyTipsButton.text:SetText('Test')
            WoWTools_MarkerMixin.ReadyTipsButton:set_Shown()
        end
    end)
    sub:CreateButton(
        (WoWTools_MarkerMixin.ReadyTipsButton and WoWTools_MarkerMixin.ReadyTipsButton:IsShown() and '' or '|cff9e9e9e')
        ..(WoWTools_Mixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2
    ), function()
        if WoWTools_MarkerMixin.ReadyTipsButton then
            WoWTools_MarkerMixin.ReadyTipsButton:set_Hide()
        end
    end)
    sub:CreateButton((Save().groupReadyTipsPoint and '' or '|cff9e9e9e')..(WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION), function()
        Save().groupReadyTipsPoint=nil
        if WoWTools_MarkerMixin.ReadyTipsButton then
            WoWTools_MarkerMixin.ReadyTipsButton:ClearAllPoints()
            WoWTools_MarkerMixin.ReadyTipsButton:set_Point()--位置
            print(e.Icon.icon2..WoWTools_MarkerMixin.addName, WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION)
        end
    end)

    root:CreateDivider()


    sub= root:CreateButton(
        WoWTools_MarkerMixin:Get_ReadyTextIcon()
        or (WoWTools_Mixin.onlyChinese and '无就绪' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NONE, READY)),
    function()
        local show= ReadyCheckFrame:IsShown()
        ReadyCheckFrame:SetShown(not show)
        ReadyCheckListenerFrame:SetShown(not show)
        return MenuResponse.Refresh
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '显示就绪框' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, READY))
        tooltip:AddLine('ReadyCheckFrame')
    end)


 --自动, 就绪  
    for value= 0, 2 do

        sub2= sub:CreateRadio(
            WoWTools_MarkerMixin:Get_ReadyTextIcon(value)
            or (WoWTools_Mixin.onlyChinese and '无' or NONE),
        function(data)
            return data==Save().autoReady
        end, function(data)
            Save().autoReady=data
            WoWTools_MarkerMixin.MarkerButton:settings()
            return MenuResponse.Refresh
        end, value>0 and value or nil)

        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '自动' or SELF_CAST_AUTO)
        end)
    end

    sub:CreateSpacer()
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().autoReadySeconds or 3
        end, setValue=function(value)
            Save().autoReadySeconds=value
        end,
        name=WoWTools_Mixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS ,
        minValue=1,
        maxValue=25,
        step=1,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '自动' or SELF_CAST_AUTO)
        end

    })
    sub:CreateSpacer()
end






function WoWTools_MarkerMixin:Setup_Menu()
    self.MarkerButton:SetupMenu(Init_Menu)
end