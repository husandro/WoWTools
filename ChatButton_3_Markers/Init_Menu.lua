local e= select(2, ...)
local function Save()
    return WoWTools_MarkerMixin.Save
end


















local function Init_Menu(_, root)
    local sub, sub2

    sub=root:CreateCheckbox(
        (Save().tank==0 and Save().healer==0 and '|cff9e9e9e' or '')
        ..'|A:mechagon-projects:0:0|a'
        ..((e.onlyChinese and '自动标记' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, EVENTTRACE_MARKER))
        ..e.Icon.TANK..e.Icon.HEALER
    ), function ()
        return Save().autoSet
    end, function ()
        Save().autoSet= not Save().autoSet and true or nil
        WoWTools_MarkerMixin.TankHealerFrame:set_Enabel_Event()
        if Save().autoSet then
            WoWTools_MarkerMixin.TankHealerFrame:on_click()
        end
    end)



    for _, info in pairs({
        {text= e.Icon.TANK..(e.onlyChinese and '坦克' or TANK), type='tank'},
        {text= e.Icon.HEALER..(e.onlyChinese and '治疗' or HEALER), type='healer', tip=e.onlyChinese and '仅限小队' or format(LFG_LIST_CROSS_FACTION, GROUP)},
        {text= e.Icon.TANK..(e.onlyChinese and '坦克' or TANK)..'2', type='tank2', tip=e.onlyChinese and '仅限团队' or format(LFG_LIST_CROSS_FACTION, RAID)},
    }) do
        sub2=sub:CreateButton(info.text, function()
            Save().tank= 2
            Save().tank2= 6
            Save().healer= 1
            WoWTools_MarkerMixin.MarkerButton:settings()
            WoWTools_MarkerMixin.TankHealerFrame:on_click()
            return MenuResponse.Refresh
        end, {text= info.text, type=info.type})
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)
        end)
        sub2:AddInitializer(function(button, description)
            local index=Save()[description.data.type]
            button.fontString:SetText(
                description.data.text..(index and '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..index..':0|t' or '')
            )
        end)

        sub:CreateDivider()

        for i=1, NUM_RAID_ICONS do
            sub2=sub:CreateRadio(
                '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..i..':0|t'..e.cn(_G['RAID_TARGET_'..i]),
            function(data)
                return Save()[data.type]==data.index
            end, function(data)
                if Save().tank~=data.index and Save().healer~=data.index and Save().tank2~=data.index then
                    Save()[data.type]=data.index
                    WoWTools_MarkerMixin.MarkerButton:settings()
                    WoWTools_MarkerMixin.TankHealerFrame:on_click()
                end
                return MenuResponse.Refresh
            end, {index=i, type=info.type, tip=info.tip})

            sub2:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.tip)
                tooltip:AddLine(description.data.index)
            end)

            sub2:AddInitializer(function(button, description)
                if Save().tank==description.data.index or Save().healer==description.data.index or Save().tank2==description.data.index then
                    button.fontString:SetTextColor(WoWTools_MarkerMixin.Color[i].r, WoWTools_MarkerMixin.Color[i].g, WoWTools_MarkerMixin.Color[i].b)
                else
                    button.fontString:SetTextColor(0.62, 0.62, 0.62)
                end
            end)
        end
    end












--我
    sub2=sub:CreateButton('|A:auctionhouse-icon-favorite:0:0|a'..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME), function()
        Save().isSelf= 4
        WoWTools_MarkerMixin.TankHealerFrame:on_click()
        WoWTools_MarkerMixin.MarkerButton:settings()
        return MenuResponse.Refresh
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '重置' or RESET)
        tooltip:AddLine(e.onlyChinese and '不在队伍' or PARTY_LEAVE)
    end)
    sub:CreateDivider()
    for i=1, NUM_RAID_ICONS do
        sub2=sub:CreateCheckbox(
            WoWTools_MarkerMixin.Color[i].col
            ..'|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..i..':0|t'..e.cn(_G['RAID_TARGET_'..i]),
        function(data)
            return Save().isSelf==data.index
        end, function(data)
            Save().isSelf= Save().isSelf~= data.index and data.index or nil
            if not Save().isSelf then
                WoWTools_MarkerMixin:Set_Taget('player', 0)
            else
                WoWTools_MarkerMixin.TankHealerFrame:on_click()
            end
            WoWTools_MarkerMixin.MarkerButton:settings()
            return MenuResponse.Refresh
        end, {index=i})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(e.onlyChinese and '不在队伍' or PARTY_LEAVE)
            tooltip:AddLine(description.data.index)
        end)
    end





    sub:SetGridMode(MenuConstants.VerticalGridDirection, 4)










    root:CreateDivider()
    sub=root:CreateCheckbox(
        (WoWTools_MapMixin:IsInPvPArea() or (WoWTools_MarkerMixin.MakerFrame and not WoWTools_MarkerMixin.MakerFrame:CanChangeAttribute()) and '|cff9e9e9e' or '')
        ..(e.onlyChinese and '队伍标记工具' or format(PROFESSION_TOOL_TOOLTIP_LINE, BINDING_HEADER_RAID_TARGET)
    ), function()
        return WoWTools_MarkerMixin.MakerFrame and WoWTools_MarkerMixin.MakerFrame:IsShown()
    end, function()
        Save().markersFrame= not Save().markersFrame and true or nil
        WoWTools_MarkerMixin:Init_Markers_Frame()--设置标记, 框架
    end)
    sub:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '世界标记' or SLASH_WORLD_MARKER3:gsub('/',''))
        GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '需求：队伍和权限' or (NEED..": "..format(COVENANT_RENOWN_TOAST_REWARD_COMBINER, HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS, CALENDAR_INVITELIST_SETMODERATOR)))
        if WoWTools_MarkerMixin.MakerFrame and not WoWTools_MarkerMixin.MakerFrame:CanChangeAttribute() then
            GameTooltip_AddErrorLine(tooltip, e.onlyChinese and "当前禁用操作" or (REFORGE_CURRENT..': '..DISABLE))
        end
    end)
    WoWTools_MarkerMixin:Init_MarkerTools_Menu(sub)--队伍标记工具, 选项，菜单


    sub=root:CreateCheckbox(e.onlyChinese and '队员就绪信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, READY, INFO)), function()
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
        ..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2
    ), function()
        if WoWTools_MarkerMixin.ReadyTipsButton then
            WoWTools_MarkerMixin.ReadyTipsButton:set_Hide()
        end
    end)
    sub:CreateButton((Save().groupReadyTipsPoint and '' or '|cff9e9e9e')..(e.onlyChinese and '重置位置' or RESET_POSITION), function()
        Save().groupReadyTipsPoint=nil
        if WoWTools_MarkerMixin.ReadyTipsButton then
            WoWTools_MarkerMixin.ReadyTipsButton:ClearAllPoints()
            WoWTools_MarkerMixin.ReadyTipsButton:set_Point()--位置
            print(WoWTools_Mixin.addName, WoWTools_MarkerMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end
    end)


    root:CreateDivider()
    for value, text in pairs({
        [1]= format('|cff00ff00%s|r|A:common-icon-checkmark:0:0|a', e.onlyChinese and '就绪' or READY),
        [2]= format('|cffff0000%s|r|A:auctionhouse-ui-filter-redx:0:0|a', e.onlyChinese and '未就绪' or NOT_READY_FEMALE),
        [0]= e.onlyChinese and '无' or NONE
    }) do
        sub=root:CreateCheckbox(text, function(data)
                return (data==0 and (Save().autoReady==0 or not Save().autoReady))
                        or Save().autoReady==data
            end, function(data)
                Save().autoReady=data
                WoWTools_MarkerMixin.MarkerButton.ReadyTextrueTips:settings()--自动就绪, 主图标, 提示
            end, value)
        sub:SetTooltip(function(tooltip, data)
            if data.data==1 or data.data==2 then
                tooltip:AddLine(e.onlyChinese and '自动' or SELF_CAST_AUTO)
            end
        end)
    end

end







function WoWTools_MarkerMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end

function WoWTools_MarkerMixin:Set_Menu(...)
    Init_Menu(...)
end