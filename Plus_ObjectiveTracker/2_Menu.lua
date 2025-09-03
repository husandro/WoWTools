
--ObjectiveTrackerFrame



local function Save()
    return WoWToolsSave['ObjectiveTracker']
end
--[[
ScenarioObjectiveTracker,
UIWidgetObjectiveTracker,
CampaignQuestObjectiveTracker,	
QuestObjectiveTracker,
AdventureObjectiveTracker,
AchievementObjectiveTracker,
MonthlyActivitiesObjectiveTracker,
ProfessionsRecipeTracker,
BonusObjectiveTracker,
WorldQuestObjectiveTracker,
]]
local ObjectiveTabs={
    ['ScenarioObjectiveTracker']=false,

    ['QuestObjectiveTracker']=true,
    ['BonusObjectiveTracker']=true,
    ['CampaignQuestObjectiveTracker']=true,
    ['WorldQuestObjectiveTracker']=true,

    ['AchievementObjectiveTracker']=true,
    ['ProfessionsRecipeTracker']=true,
    ['MonthlyActivitiesObjectiveTracker']=true,
    ['UIWidgetObjectiveTracker']=true,
    ['AdventureObjectiveTracker']=true,
}

local function Is_Locked(frame)
    if frame then
        WoWTools_FrameMixin:IsLocked(frame)
    else
        return WoWTools_FrameMixin:IsLocked(ObjectiveTrackerFrame)
    end
end

local function Set_Collapse(collapse, isAllCollapse)
    if ObjectiveTrackerFrame:IsCollapsed() then
        return
    end

    for frame, isCheck in pairs(ObjectiveTabs) do
        frame= _G[frame]
        if frame:IsVisible()
            and not Is_Locked(frame)
            and (isCheck or isAllCollapse)
            and frame:IsCollapsed()~=collapse
        then
            frame:SetCollapsed(collapse)
        end
    end
end






local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub
    local col= Is_Locked() and '|cff828282' or ''

--收起选项
    sub=root:CreateButton(
        col
        ..(WoWTools_DataMixin.onlyChinese and '收起选项 |A:editmode-up-arrow:0:0|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS),
    function()
        Set_Collapse(true, true)
        return MenuResponse.Open
    end)

--战斗中
    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT,
    function()
        return Save().autoHideInCombat
    end, function()
        Save().autoHideInCombat = not Save().autoHideInCombat and true or nil
        self:set_event()
    end)

--展开选项
    root:CreateButton(
        col
        ..(WoWTools_DataMixin.onlyChinese and '展开选项 |A:editmode-down-arrow:0:0|a' or HUD_EDIT_MODE_EXPAND_OPTIONS),
    function()
        Set_Collapse(false, true)
        return MenuResponse.Open
    end)

--自动
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO,
    function()
        return Save().autoHide
    end, function()
        Save().autoHide = not Save().autoHide and true or nil
        self:set_event()
    end)

    root:CreateDivider()

    sub=root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '清除全部' or CLEAR_ALL),
    function()
        StaticPopup_Show('WoWTools_OK',
        (WoWTools_DataMixin.onlyChinese and '取消追踪' or OBJECTIVES_STOP_TRACKING)..'\n'
        ..'|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '清除全部' or CLEAR_ALL),
        nil,
        {SetValue=function()
            WoWTools_ObjectiveMixin:Clear_Achievement()
            WoWTools_ObjectiveMixin:Clear_CampaignQuest()
            WoWTools_ObjectiveMixin:Clear_MonthlyActivities()
            WoWTools_ObjectiveMixin:Clear_ProfessionsRecipe()
            WoWTools_ObjectiveMixin:Clear_Quest()
            WoWTools_ObjectiveMixin:Clear_WorldQuest()
        end}
)
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '取消追踪' or OBJECTIVES_STOP_TRACKING)
    end)

--缩放
    root:CreateDivider()
    WoWTools_MenuMixin:Scale(ObjectiveTrackerFrame, root, function()
        return Save().scale
    end, function(value)
        if not Is_Locked() then
            Save().scale= value
            self:set_scale()
        end
    end)

--透明度
    sub= root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '透明度' or CHANGE_OPACITY,
    function()
        return MenuResponse.Open
    end)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().alpha or 1
        end,
        setValue=function(value)
            if not Is_Locked() then
                Save().alpha= value
                self:set_scale()
            end
        end,
        name= WoWTools_DataMixin.onlyChinese and '透明度' or CHANGE_OPACITY ,
        minValue=0,
        maxValue=1,
        step=0.01,
        bit='%.2f',
    })
    sub:CreateSpacer()
    





--选项
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ObjectiveMixin.addName, tooltip=function(tooltip)
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnRED_FONT_COLOR:BUG')
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '友情提示: 可能会出现错误' or 'note: errors may occur')
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '当有可点击物品按钮时会错误' or 'Wrong when there is an item button')
    end})

    WoWTools_MenuMixin:Reload(sub)

end















local function Init()
    local MenuButton= WoWTools_ButtonMixin:Menu(ObjectiveTrackerFrame.Header, {
        size=20,
        name='WoWToolsObjectiveTrackerFrameMenuButton'
    })

    function MenuButton:set_scale()
        if not Is_Locked() then
            ObjectiveTrackerFrame:SetScale(Save().scale or 1)
            ObjectiveTrackerFrame:SetAlpha(Save().alpha or 1)
        end
    end

    function MenuButton:auto_collapse()
        Set_Collapse(IsInInstance(), false)
    end

    function MenuButton:set_event()
        self:UnregisterAllEvents()

        if Save().autoHide then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent("CHALLENGE_MODE_START")
            self:RegisterEvent('ZONE_CHANGED_NEW_AREA')

            if Save().autoHideInCombat then
                self:RegisterEvent('PLAYER_REGEN_DISABLED')
                self:RegisterEvent('PLAYER_REGEN_ENABLED')
            end

            self:auto_collapse()
        end
    end

    function MenuButton:set_shown()
        self:SetShown(not ObjectiveTrackerFrame:IsCollapsed())
    end

    MenuButton:SetScript('OnMouseWheel', function(_, d)
        Set_Collapse(d==1, true)
    end)

    MenuButton:SetPoint('RIGHT', ObjectiveTrackerFrame.Header.MinimizeButton, 'LEFT')
    MenuButton:SetScript('OnLeave', GameTooltip_Hide)
    MenuButton:HookScript('OnEnter', function()
        GameTooltip:SetOwner(ObjectiveTrackerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine('|A:Objective-Nub:0:0|a'..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')

        local col= Is_Locked() and '|cff828282' or ''
        GameTooltip:AddLine(
            col
            ..(WoWTools_DataMixin.onlyChinese and '收起选项 |A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
            ..(WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_UP)
            ..WoWTools_DataMixin.Icon.mid
        )
        GameTooltip:AddLine(
            col
            ..(WoWTools_DataMixin.onlyChinese and '展开选项 |A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
            ..(WoWTools_DataMixin.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_DOWN)
            ..WoWTools_DataMixin.Icon.mid
        )
        GameTooltip:Show()
    end)
    MenuButton:SetupMenu(Init_Menu)

    MenuButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_REGEN_DISABLED' then
            if not ObjectiveTrackerFrame:IsCollapsed() then
                ObjectiveTrackerFrame:SetCollapsed(true)
            end
        elseif event=='PLAYER_REGEN_ENABLED' then
            if ObjectiveTrackerFrame:IsCollapsed() then
                ObjectiveTrackerFrame:SetCollapsed(false)
            end
        else
            self:auto_collapse()
        end
    end)



    ObjectiveTrackerFrame.Header.MinimizeButton:HookScript('OnMouseUp', function()
        Save().initIsCollapsed= ObjectiveTrackerFrame:IsCollapsed()
    end)

    hooksecurefunc(ObjectiveTrackerFrame.Header, 'SetCollapsed', function(_, collapsed)
        Save().initIsCollapsed= collapsed--保存，上次
        MenuButton:set_shown()
    end)





--初始
    hooksecurefunc(ObjectiveTrackerManager, 'ReleaseFrame', function(_, line)
        if line.Icon2 then
            line.Icon2:SetTexture(0)
        end
    end)


    MenuButton:set_scale()
    MenuButton:set_event()
    MenuButton:set_shown()

    if Save().autoHide and Save().initIsCollapsed and not Is_Locked()  then--保存，上次
        ObjectiveTrackerFrame:SetCollapsed(true)--:ToggleCollapsed()
    end


--[[移动
    WoWTools_MoveMixin:Setup(ObjectiveTrackerFrame.Header, {
        notSave=true,
    })

    ObjectiveTrackerFrame:SetMovable(true)
    ObjectiveTrackerFrame.Header.MinimizeButton:RegisterForDrag("RightButton")

    ObjectiveTrackerFrame.Header.MinimizeButton:SetScript("OnDragStart", function(self)
        if not WoWTools_FrameMixin:IsLocked(self) then
            self:GetParent():GetParent():StartMoving()
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    ObjectiveTrackerFrame.Header.MinimizeButton:SetScript("OnDragStop", function(self, d)
        self:GetParent():GetParent():StopMovingOrSizing()
        ResetCursor()
    end)
    ObjectiveTrackerFrame.Header.MinimizeButton:HookScript('OnMouseDown', function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    ObjectiveTrackerFrame.Header.MinimizeButton:HookScript('OnMouseUp', function()
        ResetCursor()
    end)]]





    Init=function()end
end








function WoWTools_ObjectiveMixin:Init_Menu()
    Init()
end

--[[function WoWTools_ObjectiveMixin:Get_ObjectiveTab()
    return ObjectiveTabs
end]]
