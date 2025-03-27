
WoWTools_ObjectiveMixin={}
local P_Save={
    disabled= not WoWTools_DataMixin.Player.husandro,
    scale= WoWTools_DataMixin.Player.husandro and 0.85 or 1,
    autoHide= WoWTools_DataMixin.Player.husandro and true or nil
}


local function Save()
    return WoWToolsSave['ObjectiveTracker']
end








--清除，全部，按钮
function WoWTools_ObjectiveMixin:Add_ClearAll_Button(frame, tooltip, func)
    if WoWTools_Mixin:IsLockFrame(frame) then
        return
    end
    local btn= WoWTools_ButtonMixin:Cbtn(frame, {size=22, atlas='bags-button-autosort-up', alpha=0.3})
    btn:SetPoint('RIGHT', frame.Header.MinimizeButton, 'LEFT', -2, 0)
    btn:SetScript('OnLeave', function(f) f:SetAlpha(0.3) GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(f)
        GameTooltip:SetOwner(f, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName,WoWTools_ObjectiveMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '双击' or 'Double-Click')..WoWTools_DataMixin.Icon.left, (WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)..'|A:bags-button-autosort-up:0:0|a|cffff00ff'..(f.tooltip or ''))
        GameTooltip:Show()
        f:SetAlpha(1)
    end)
    btn:SetScript('OnDoubleClick', func)
    function btn:print_text(num)
        print(WoWTools_DataMixin.Icon.icon2.. WoWTools_ObjectiveMixin.addName, WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, '|A:bags-button-autosort-up:0:0|a', '|cffff00ff'..(num or 0)..'|r', btn.tooltip)
    end
    btn.tooltip= tooltip
end





function WoWTools_ObjectiveMixin:Set_Block_Icon(block, icon, type)
    if WoWTools_Mixin:IsLockFrame(block) then
        return
    end
    if icon and not block.Icon2 then
        block.Icon2= block:CreateTexture(nil, 'OVERLAY')
        if block.poiButton then
            block.Icon2:SetPoint('RIGHT',block.poiButton.Display.Icon, 'LEFT', -2, 0)
        else
            block.Icon2:SetPoint('TOPRIGHT', block.HeaderText, 'TOPLEFT', -4,-1)
        end
        block.Icon2:SetSize(26,26)
        block.Icon2:EnableMouse()
        block.Icon2:SetScript('OnLeave', function(f) GameTooltip:Hide() f:GetParent():SetAlpha(1) end)
        block.Icon2:SetScript('OnEnter', function(f)
            local parent= f:GetParent()
            parent:SetAlpha(0.5)
            local typeID= parent.id
            if not typeID then
                return
            end
            GameTooltip:SetOwner(f, "ANCHOR_LEFT")
            if f.type=='isAchievement' then
                GameTooltip:SetAchievementByID(typeID)
            --elseif f.type=='isItem' then
                --GameTooltip:SetItemByID(typeID)
            elseif f.type=='isRecipe' then
                GameTooltip:SetRecipeResultItem(typeID)
            end
            GameTooltip:Show()
        end)
    end
    if block.Icon2 then
        block.Icon2.type= type
        block.Icon2:SetTexture(icon or 0)
    end
end


function WoWTools_ObjectiveMixin:Set_Line_Icon(line, icon)
    if icon and not line.Icon2 then
        line.Icon2= line:CreateTexture(nil, 'OVERLAY')
        line.Icon2:SetPoint('RIGHT', line.Text)
        line.Icon2:SetSize(16, 16)
        line.Icon2:EnableMouse()
        line.Icon2:SetScript('OnLeave', function(f) f:GetParent():SetAlpha(1) end)
        line.Icon2:SetScript('OnEnter', function(f)
            local parent= f:GetParent()
            parent:SetAlpha(0.5)
        end)
    end
    if line.Icon2 then
        line.Icon2:SetTexture(icon or 0)
    end
end


function WoWTools_ObjectiveMixin:Get_Block(f, index)
    if f.usedBlocks[f.blockTemplate] then
        return f.usedBlocks[f.blockTemplate][index]
    end
end






local function Init()
    WoWTools_ObjectiveMixin:Init_Quest()
    WoWTools_ObjectiveMixin:Init_Campaign_Quest()
    WoWTools_ObjectiveMixin:Init_World_Quest()
    WoWTools_ObjectiveMixin:Init_Achievement()
    WoWTools_ObjectiveMixin:Init_Professions()
    WoWTools_ObjectiveMixin:Init_MonthlyActivities()
    WoWTools_ObjectiveMixin:Init_ScenarioObjective()
    WoWTools_ObjectiveMixin:Init_ObjectiveTrackerFrame()
    WoWTools_ObjectiveMixin:Init_ObjectiveTrackerShared()

    Init=function()end
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['ObjectiveTracker']= WoWToolsSave['ObjectiveTracker'] or P_Save

           WoWTools_ObjectiveMixin.addName= '|A:Objective-Nub:0:0|a|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL)..'|r'

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name=WoWTools_ObjectiveMixin.addName,
                tooltip='|cnRED_FONT_COLOR:Bug',
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Init()
                    print(WoWTools_DataMixin.Icon.icon2.. WoWTools_ObjectiveMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save().disabled then
                Init()
            end

            self:UnregisterEvent(event)
        end
    end
end)


--[[
local Frames={
    'QuestObjectiveTracker',
    'CampaignQuestObjectiveTracker',
    'WorldQuestObjectiveTracker',
    'AchievementObjectiveTracker',
    'ProfessionsRecipeTracker',
    'MonthlyActivitiesObjectiveTracker',
    'BonusObjectiveTracker', --.Header
}]]

