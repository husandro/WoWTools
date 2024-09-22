local id, e = ...
WoWTools_MarkerMixin={
Save={
    autoSet=true,
    tank= 2,
    tank2= 6,
    healer= 1,

    countdown=7,
    groupReadyTips=true,
    tipsTextSacle=1,

    markersScale=1,
    markersFrame= e.Player.husandro,
    FrameStrata='MEDIUM',
    pingTime= e.Player.husandro,--显示ping冷却时间
    autoReady=0,
},
Color={
    [1]={r=1, g=1, b=0, col='|cffffff00'},--星星, 黄色
    [2]={r=1, g=0.45, b=0.04, col='|cffff7f3f'},--圆形, 橙色
    [3]={r=1, g=0, b=1, col='|cffa335ee'},--菱形, 紫色
    [4]={r=0, g=1, b=0, col='|cff1eff00'},--三角, 绿色
    [5]={r=0.6, g=0.6, b=0.6, col='|cffffffff'},--月亮, 白色
    [6]={r=0.1, g=0.2, b=1, col='|cff0070dd'},--方块, 蓝色
    [7]={r=1, g=0, b=0, col='|cffff2020'},--十字, 红色
    [8]={r=1, g=1, b=1, col='|cffffffff'},--骷髅,白色
},
AutoReadyFrame=nil,--自动就绪
TankHealerFrame=nil,
}


local function Save()
    return WoWTools_MarkerMixin.Save
end
local MarkerButton





function WoWTools_MarkerMixin:Set_Taget(unit, index)--设置,目标,标记
    if CanBeRaidTarget(unit) and GetRaidTargetIndex(unit)~=index then
        SetRaidTarget(unit, index)
    end
end













































































local function Init_Menu(_, root)
    local sub, tre, tab

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
            WoWTools_MarkerMixin.TankHealerFrame:set_TankHealer(true)--设置队伍标记
        end
    end)
    sub:SetGridMode(MenuConstants.VerticalGridDirection, 3)

    tab={
        {text= e.Icon.TANK..(e.onlyChinese and '坦克' or TANK), type='tank'},
        {text= e.Icon.HEALER..(e.onlyChinese and '治疗' or HEALER), type='healer', tip=e.onlyChinese and '仅限小队' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GROUP)},
        {text= e.Icon.TANK..(e.onlyChinese and '坦克' or TANK)..'2', type='tank2', tip=e.onlyChinese and '仅限团队' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RAID)},
    }

    for _, info in pairs(tab) do
        tre=sub:CreateButton(info.text, function()
            Save().tank= 2
            Save().tank2= 6
            Save().healer= 1
        end)
        tre:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '重置' or RESET)
        end)
        sub:CreateDivider()

        for i=1, NUM_RAID_ICONS do
            tre=sub:CreateCheckbox(
                WoWTools_MarkerMixin.Color[i].col..'|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..i..':0|t'..e.cn(_G['RAID_TARGET_'..i]),
            function(data)
                return Save()[data.type]==data.index
            end, function(data)
                if Save().tank==data.index or Save().healer==data.index or Save().tank2==data.index then
                    return
                end
                Save()[data.type]=data.index
                MarkerButton:set_Texture()--图标

            end, {index=i, type=info.type, tip=info.tip})
            tre:SetTooltip(function(tooltip, data)
                tooltip:AddLine(data.data.tip)
            end)
        end
    end


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
            print(e.addName, WoWTools_MarkerMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end
    end)

    tab={
        [1]= format('|cff00ff00%s|r|A:common-icon-checkmark:0:0|a', e.onlyChinese and '就绪' or READY),
        [2]= format('|cffff0000%s|r|A:auctionhouse-ui-filter-redx:0:0|a', e.onlyChinese and '未就绪' or NOT_READY_FEMALE),
        [0]= e.onlyChinese and '无' or NONE
    }

    root:CreateDivider()
    for value, text in pairs(tab) do
        sub=root:CreateCheckbox(text, function(data)
                return (data==0 and (Save().autoReady==0 or not Save().autoReady))
                        or Save().autoReady==data
            end, function(data)
                Save().autoReady=data
                MarkerButton.ReadyTextrueTips:settings()--自动就绪, 主图标, 提示
            end, value)
        sub:SetTooltip(function(tooltip, data)
            if data.data==1 or data.data==2 then
                tooltip:AddLine(e.onlyChinese and '自动' or SELF_CAST_AUTO)
            end
        end)
    end

end






















































--####
--初始
--####
local function Init()
    WoWTools_MarkerMixin.MarkerButton= MarkerButton

    --自动就绪, 主图标, 提示
    MarkerButton.ReadyTextrueTips=MarkerButton:CreateTexture(nil,'OVERLAY')
    MarkerButton.ReadyTextrueTips:SetPoint('TOP')
    local size=MarkerButton:GetWidth()/2
    MarkerButton.ReadyTextrueTips:SetSize(size, size)
    function MarkerButton.ReadyTextrueTips:settings()
        if Save().autoReady==1 then
            MarkerButton.ReadyTextrueTips:SetAtlas(e.Icon.select)
        elseif Save().autoReady==2 then
            MarkerButton.ReadyTextrueTips:SetAtlas('auctionhouse-ui-filter-redx')
        else
            MarkerButton.ReadyTextrueTips:SetTexture(0)
        end
    end
    MarkerButton.ReadyTextrueTips:settings()





    function MarkerButton:set_Texture()--图标
        self.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..Save().tank)
    end
    MarkerButton:set_Texture()--图标

    function MarkerButton:set_Desaturated_Textrue()--主图标,是否有权限
        local raid= IsInRaid()
        local enabled= not WoWTools_MapMixin:IsInPvPArea()
                and (
                        (raid and WoWTools_GroupMixin:isLeader())--队长(团长)或助理
                    or (GetNumGroupMembers()>1 and not raid)
                )
        self.texture:SetDesaturated(not enabled)
    end

    MarkerButton:set_Desaturated_Textrue()--主图标,是否有权限

    MarkerButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    MarkerButton:RegisterEvent('GROUP_ROSTER_UPDATE')
    MarkerButton:RegisterEvent('GROUP_LEFT')
    MarkerButton:RegisterEvent('GROUP_JOINED')
    MarkerButton:SetScript("OnEvent", MarkerButton.set_Desaturated_Textrue)





    MarkerButton:SetScript("OnClick", function(self, d)
        if d=='LeftButton' then
            WoWTools_MarkerMixin.TankHealerFrame:on_click()
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
            e.tips:Hide()
        end
    end)

    function MarkerButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_MarkerMixin.addName, (e.onlyChinese and '标记' or EVENTTRACE_MARKER), e.Icon.left)
        e.tips:AddLine(e.Icon.TANK..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save().tank))
        if not IsInRaid() then
            e.tips:AddLine(e.Icon.HEALER..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save().healer))
        else
            e.tips:AddLine(e.Icon.TANK..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save().tank2))
        end
        e.tips:Show()
    end



    MarkerButton:SetScript('OnLeave', function(self)
        if self.groupReadyTips then
            self.groupReadyTips:SetButtonState('NORMAL')
        end
        e.tips:Hide()
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_Alpha(false)
        end
        self:state_leave()
    end)
    MarkerButton:SetScript('OnEnter', function(self)
        if self.groupReadyTips and self.groupReadyTips:IsShown() then
            self.groupReadyTips:SetButtonState('PUSHED')
        end
        self:set_tooltip()
        self:state_enter(Init_Menu)
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_Alpha(true)
        end
    end)







    WoWTools_MarkerMixin:Init_Markers_Frame()--设置标记, 框架
    WoWTools_MarkerMixin:Init_Ready_Tips_Button()--队员,就绪,提示信息
    WoWTools_MarkerMixin:Init_Tank_Healer()--设置队伍标记
    WoWTools_MarkerMixin:Init_AutoReady()
end
















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            WoWTools_MarkerMixin.Save= WoWToolsSave['ChatButton_Markers'] or WoWTools_MarkerMixin.Save

            WoWTools_MarkerMixin.addName= '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t|cffffff00'..(e.onlyChinese and '队伍标记' or BINDING_HEADER_RAID_TARGET)..'|r'

            MarkerButton= WoWTools_ChatButtonMixin:CreateButton('Markers', WoWTools_MarkerMixin.addName)

            if MarkerButton then

                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_Markers']=WoWTools_MarkerMixin.Save
        end
    end
end)

