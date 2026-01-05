
local function Save()
    return WoWToolsSave['ChatButton_Markers'] or {}
end




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

local function Get_selfModeIconValue()
    local iconOn = GetCVarBool("findYourselfModeIcon")--CombatOverrides.lua
    if iconOn then
        local circleOn = GetCVarBool("findYourselfModeCircle")
        local outlineOn = GetCVarBool("findYourselfModeOutline")
        local value = (circleOn and 1 or 0) + (outlineOn and 2 or 0) + (iconOn and 4 or 0)
        if value>=4 and value<=7 then
            return value
        end
    end
end

















local function Init_RaidTarget_Menu(self, root)
    local sub

    local Tab={
        {
            text= WoWTools_DataMixin.Icon.TANK..(WoWTools_DataMixin.onlyChinese and '坦克' or TANK),
            type='tank',
            tip= WoWTools_DataMixin.onlyChinese and '小队或团队' or  (GROUP..' '..OR_CAPS ..' '..RAID),
            rest=restGroup,
            check=checkGroup
        },
        {
            text= WoWTools_DataMixin.Icon.HEALER..(WoWTools_DataMixin.onlyChinese and '治疗' or HEALER),
            type='healer',
            tip=WoWTools_DataMixin.onlyChinese and '仅限小队' or format(LFG_LIST_CROSS_FACTION, GROUP),
            rest=restGroup,
            check=checkGroup
        },
        {
            text= WoWTools_DataMixin.Icon.TANK..(WoWTools_DataMixin.onlyChinese and '坦克' or TANK)..'2',
            type='tank2',
            tip=WoWTools_DataMixin.onlyChinese and '仅限团队' or format(LFG_LIST_CROSS_FACTION, RAID),
            rest=restGroup,
            check=checkGroup
        },
        {
            text='|A:auctionhouse-icon-favorite:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                ..(Get_selfModeIconValue() and '|A:QuestLegendary:0:0|a' or ''),
            type='isSelf',
            tip= function(tooltip)
                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '不在队伍' or PARTY_LEAVE)
                local value= Get_selfModeIconValue()
                if not value then
                    return
                end
                local valueTab={
                    [4]=WoWTools_DataMixin.onlyChinese and '图标' or SELF_HIGHLIGHT_MODE_ICON,
                    [5]=WoWTools_DataMixin.onlyChinese and '圆环和图标' or SELF_HIGHLIGHT_MODE_CIRCLE_AND_ICON,
                    [6]=WoWTools_DataMixin.onlyChinese and '轮廓线和图标' or SELF_HIGHLIGHT_MODE_OUTLINE_AND_ICON,
                    [7]=WoWTools_DataMixin.onlyChinese and '圆环、轮廓线和图标' or SELF_HIGHLIGHT_MODE_CIRCLE_OUTLINE_AND_ICON,
                }
                tooltip:AddLine(' ')
                GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '综合' or GENERAL)
                GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '开启自身高亮' or SELF_HIGHLIGHT_ON)
                GameTooltip_AddErrorLine(tooltip, valueTab[value])
            end,
            rest=restSelf,
            check=checkSelf
        },
        {
            text='|A:Target:0:0|a'..(WoWTools_DataMixin.onlyChinese and '目标' or TARGET),
            type='target',
            tip=WoWTools_DataMixin.onlyChinese and '不在队伍' or PARTY_LEAVE,
            rest= restSelf,
            check=checkSelf
        }
    }
    for _, info in pairs(Tab) do
        sub=root:CreateButton(
            info.text,
        function(data)
            data.rest()
            self:settings()
            WoWTools_MarkerMixin:Init_Tank_Healer(true)
            return MenuResponse.Refresh
        end, {
            text= info.text,
            type=info.type,
            rest=info.rest,
            tip=info.tip,
        })

        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重置' or RESET)
             if type(desc.data.tip)=='function' then
                desc.data.tip(tooltip)
            else
                tooltip:AddLine(desc.data.tip)
            end
        end)
        sub:AddInitializer(function(button, desc)
            local index=Save()[desc.data.type]
            button.fontString:SetText(
                (index and WoWTools_MarkerMixin:GetColor(index).col or '')
                ..desc.data.text
                ..(index and '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..index..':0|t' or '')
            )
        end)

        root:CreateDivider()

        for i=1, NUM_RAID_ICONS do
            sub=root:CreateRadio(
                '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..i..':0|t'
                ..WoWTools_MarkerMixin:GetColor(i).col
                ..WoWTools_TextMixin:CN(_G['RAID_TARGET_'..i]),
            function(data)
                return Save()[data.type]==data.index
            end, function(data)
                if Save()[data.type]==data.index then
                    Save()[data.type]=nil

                elseif data.check(data.index) then
                    Save()[data.type]=data.index
                end
                self:settings()
                WoWTools_MarkerMixin:Init_Tank_Healer(true)
                return MenuResponse.Refresh

            end, {
                text=info.text,
                index=i,
                type=info.type,
                tip=info.tip,
                check=info.check
            })

            sub:SetTooltip(function(tooltip, desc)
                tooltip:AddDoubleLine(desc.data.text, desc.data.index)
                if type(desc.data.tip)=='function' then
                    desc.data.tip(tooltip)
                else
                    tooltip:AddLine(desc.data.tip)
                end
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
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2
    sub=root:CreateCheckbox(
        (Save().tank==0 and Save().healer==0 and '|cff626262' or '')
        ..'|A:mechagon-projects:0:0|a'
        ..((WoWTools_DataMixin.onlyChinese and '自动标记' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, EVENTTRACE_MARKER))
        ..WoWTools_DataMixin.Icon.TANK..WoWTools_DataMixin.Icon.HEALER
    ), function ()
        return Save().autoSet
    end, function ()
        Save().autoSet= not Save().autoSet and true or false
        WoWTools_MarkerMixin.TankHealerFrame:set_Enabel_Event()
        WoWTools_MarkerMixin:Init_Tank_Healer()
    end)




    Init_RaidTarget_Menu(self, sub)





    root:CreateDivider()
    sub=root:CreateCheckbox(
        (WoWTools_MapMixin:IsInPvPArea()
        or (InCombatLockdown()) and '|cff626262' or '')
        ..(WoWTools_DataMixin.onlyChinese and '队伍标记工具' or format(PROFESSION_TOOL_TOOLTIP_LINE, BINDING_HEADER_RAID_TARGET)
    ), function()
        return  _G['WoWToolsMarkerFrame'] and  _G['WoWToolsMarkerFrame']:IsShown()
    end, function()
        if not InCombatLockdown() then
            Save().markersFrame= not Save().markersFrame and true or nil
            WoWTools_MarkerMixin:Init_Markers_Frame()--设置标记, 框架
        end
    end)
    sub:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, WoWTools_DataMixin.onlyChinese and '世界标记' or SLASH_WORLD_MARKER3:gsub('/',''))
        GameTooltip_AddNormalLine(tooltip, WoWTools_DataMixin.onlyChinese and '需求：队伍和权限' or (NEED..": "..format(COVENANT_RENOWN_TOAST_REWARD_COMBINER, HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS, CALENDAR_INVITELIST_SETMODERATOR)))
        if InCombatLockdown() then
            GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and "当前禁用操作" or (REFORGE_CURRENT..': '..DISABLE))
        end
    end)


    --重置位置
    WoWTools_MenuMixin:RestPoint(self, sub, Save().markersFramePoint, function()
        Save().markersFramePoint=nil
        if _G['WoWToolsMarkerFrame'] then
            _G['WoWToolsMarkerFrame']:set_point()
        end
        print(
            WoWTools_MarkerMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
        )
    end)



    sub=root:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '队员就绪信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, READY, INFO)), function()
        return Save().groupReadyTips
    end, function()
        Save().groupReadyTips= not Save().groupReadyTips and true or false
        WoWTools_MarkerMixin:Init_Ready_Tips_Button()--注册事件, 就绪,队员提示信息
        if Save().groupReadyTips then--测试
            local btn= _G['WoWToolsChatMarkersReadyInfoButton']
            if btn then
                btn.text:SetText('Test')
                btn:set_Shown()
            end
        end
    end)
    sub:CreateButton(
        (_G['WoWToolsChatMarkersReadyInfoButton'] and _G['WoWToolsChatMarkersReadyInfoButton']:IsShown() and '' or '|cff626262')
        ..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2
    ), function()
        local btn= _G['WoWToolsChatMarkersReadyInfoButton']
        if btn then
            btn:set_Hide()
        end
    end)
    sub:CreateButton((Save().groupReadyTipsPoint and '' or '|cff626262')..(WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION), function()
        Save().groupReadyTipsPoint=nil
        local btn= _G['WoWToolsChatMarkersReadyInfoButton']
        if btn then
            btn:ClearAllPoints()
            btn:set_Point()--位置
            print(
                WoWTools_MarkerMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
            )
        end
    end)

    root:CreateDivider()


    sub= root:CreateButton(
        WoWTools_MarkerMixin:Get_ReadyTextAtlas(Save().autoReady)
        or (WoWTools_DataMixin.onlyChinese and '无就绪' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NONE, READY)),
    function()
        local show= ReadyCheckFrame:IsShown()
        ReadyCheckFrame:SetShown(not show)
        ReadyCheckListenerFrame:SetShown(not show)
        return MenuResponse.Refresh
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示就绪框' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, READY))
        tooltip:AddLine('ReadyCheckFrame')
    end)


 --自动, 就绪  
    for value= 0, 2 do

        sub2= sub:CreateRadio(
            WoWTools_MarkerMixin:Get_ReadyTextAtlas(value)
            or (WoWTools_DataMixin.onlyChinese and '无' or NONE),
        function(data)
            return data==Save().autoReady
        end, function(data)
            Save().autoReady=data
            self:settings()
            return MenuResponse.Refresh
        end, value>0 and value or nil)

        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO)
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
        name=WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS ,
        minValue=1,
        maxValue=25,
        step=1,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO)
        end

    })
    sub:CreateSpacer()
end















function WoWTools_MarkerMixin:Setup_Menu(btn)
    btn:SetupMenu(Init_Menu)
end