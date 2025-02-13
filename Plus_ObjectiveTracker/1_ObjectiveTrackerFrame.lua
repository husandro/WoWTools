local e= select(2, ...)
--ObjectiveTrackerFrame

local function Save()
    return WoWTools_ObjectiveTrackerMixin.Save
end

local function set_scale(isInit)
    if (isInit and Save().scale==1) or not Save().scale or not ObjectiveTrackerFrame:CanChangeAttribute() then
        return
    end
    ObjectiveTrackerFrame:SetScale(Save().scale)
end

local function set_frames_show(collapse)
    for _, frame in pairs({
        'QuestObjectiveTracker',
        'CampaignQuestObjectiveTracker',
        'WorldQuestObjectiveTracker',
        'AchievementObjectiveTracker',
        'ProfessionsRecipeTracker',
        'MonthlyActivitiesObjectiveTracker',
    }) do
        frame= _G[frame]
        if frame then
            if frame:IsCollapsed()~=collapse then
                frame:SetCollapsed(collapse)
            end
        end
    end
end





local function menu_tooltip(root)
    root:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '友情提示: 可能会出现错误' or 'note: errors may occur')
        tooltip:AddLine(e.onlyChinese and '当有可点击物品按钮时会错误' or 'Wrong when there is an item button')
    end)
end

local function Init_Menu(_, root)
    local sub
    sub=root:CreateButton((e.onlyChinese and '收起选项 |A:NPE_ArrowUp:0:0|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS), function()
        set_frames_show(true)
    end)
    menu_tooltip(sub)

    sub=root:CreateButton((e.onlyChinese and '展开选项 |A:NPE_ArrowDown:0:0|a' or HUD_EDIT_MODE_EXPAND_OPTIONS), function()
        set_frames_show(false)
    end)
    menu_tooltip(sub)

    root:CreateDivider()
    WoWTools_MenuMixin:Scale(root, function()
        return Save().scale
    end, function(value)
        Save().scale= value
        set_scale()
    end)

    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ObjectiveTrackerMixin.addName})
end





local function Init()
    set_scale(true)

    ObjectiveTrackerFrame.Header.MinimizeButton:HookScript('OnLeave', GameTooltip_Hide)
    ObjectiveTrackerFrame.Header.MinimizeButton:HookScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine((e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..e.Icon.right)
        e.tips:Show()
    end)

    ObjectiveTrackerFrame.Header.MinimizeButton:HookScript('OnMouseDown', function(frame, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(frame, Init_Menu)
        end
    end)

    hooksecurefunc(ObjectiveTrackerManager, 'ReleaseFrame', function(_, line)
        if line.Icon2 then
            line.Icon2:SetTexture(0)
        end
    end)
end





function WoWTools_ObjectiveTrackerMixin:Init_ObjectiveTrackerFrame()
    Init()
end



 --[[local sub, col

    col= set_frames_show(true, true) and '' or '|cff9e9e9e'
    root:CreateButton(col..(e.onlyChinese and '收起选项 |A:NPE_ArrowUp:0:0|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS), function()
        set_frames_show(true, false)
    end)

    col= set_frames_show(false, true) and '' or '|cff9e9e9e'
    root:CreateButton(col..(e.onlyChinese and '展开选项 |A:NPE_ArrowDown:0:0|a' or HUD_EDIT_MODE_EXPAND_OPTIONS), function()
        set_frames_show(false, false)
    end)

    sub= root:CreateCheckbox(e.onlyChinese and '自动' or SELF_CAST_AUTO, function()
        return Save().autoHide
    end, function()
        Save().autoHide = not Save().autoHide and true or nil
        self.eventFrame:set_event()
    end)
    sub:SetTooltip(function(tooltip, elementDescription)
        GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
        GameTooltip_AddInstructionLine(tooltip, e.onlyChinese and e.onlyChinese and '收起选项 |A:NPE_ArrowUp:0:0|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
        GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '仅限在副本中' or format(LFG_LIST_CROSS_FACTION, AGGRO_WARNING_IN_INSTANCE))
    end)

缩放
    btn:HookScript('OnMouseWheel', function(self, d)
        Save().scale= WoWTools_FrameMixin:ScaleFrame(ObjectiveTrackerFrame, d, Save().scale, function()
            print(WoWTools_Mixin.addName, WoWTools_ObjectiveTrackerMixin.addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            print('|cnRED_FONT_COLOR:', e.onlyChinese and '友情提示: 可能会出现错误' or 'note: errors may occur')
        end)
        self:set_tooltip()
    end)


  sub=root:CreateButton('BUG', function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '当有可点击物品按钮时会错误' or 'Wrong when there is an item button')
    end)
    
    btn.eventFrame= CreateFrame('Frame', nil, btn)
    function btn.eventFrame:set_event()
        if Save().autoHide then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent("CHALLENGE_MODE_START")
            self:set_collapse()
        else
            self:UnregisterAllEvents()
        end
    end
    function btn.eventFrame:set_collapse()
        if IsInInstance() then
            set_frames_show(true, false)
        end
    end
    btn.eventFrame:SetScript('OnEvent', btn.eventFrame.set_collapse)
    btn.eventFrame:set_event()

    


    
local HUD_EDIT_MODE_COLLAPSE_OPTIONS= HUD_EDIT_MODE_COLLAPSE_OPTIONS:gsub('|A:.-|a', '|A:NPE_ArrowUp:0:0|a')
local HUD_EDIT_MODE_EXPAND_OPTIONS= HUD_EDIT_MODE_EXPAND_OPTIONS:gsub('|A:.-|a', '|A:NPE_ArrowDown:0:0|a')
local tabs={
    'QuestObjectiveTracker',
    'CampaignQuestObjectiveTracker',
    'WorldQuestObjectiveTracker',
    'AchievementObjectiveTracker',
    'ProfessionsRecipeTracker',
    'MonthlyActivitiesObjectiveTracker',
}
--右击
local function set_frames_show(collapse, isFind)
    for _, frame in pairs(tabs) do
        frame= _G[frame]
        if frame then
            local isCollapsed = frame:IsCollapsed()
            if (collapse and not isCollapsed) or (not collapse and isCollapsed) then
                if isFind then
                    return true
                else
                    local find= false
                    for _, block in pairs(frame.usedBlocks and frame.usedBlocks[frame.blockTemplate] or {}) do
                        if block.ItemButton then
                            --find=true
                            --break
                        end
                    end
                    if not find then
                        --e.call(frame.ToggleCollapsed, frame)
                    end
                end
            end
        end
    end
end

--for _, block in pairs(frame.usedBlocks and frame.usedBlocks[frame.blockTemplate] or {}) do
--if block.ItemButton then
]]
