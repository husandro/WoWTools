local id, e = ...

WoWTools_ObjectiveTrackerMixin={
Save={
    --disabled=not e.Player.husandro,
    scale= e.Player.husandro and 0.85 or 1,
    autoHide= e.Player.husandro and true or nil
},
}

local addName
local function Save()
    return WoWTools_ObjectiveTrackerMixin.Save
end








--清除，全部，按钮
function WoWTools_ObjectiveTrackerMixin:Add_ClearAll_Button(frame, tooltip, func)
    local btn= WoWTools_ButtonMixin:Cbtn(frame, {size=22, atlas='bags-button-autosort-up', alpha=0.3})
    btn:SetPoint('RIGHT', frame.Header.MinimizeButton, 'LEFT', -2, 0)
    btn:SetScript('OnLeave', function(f) f:SetAlpha(0.3) e.tips:Hide() end)
    btn:SetScript('OnEnter', function(f)
        e.tips:SetOwner(f, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName,addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '双击' or 'Double-Click')..e.Icon.left, (e.onlyChinese and '全部清除' or CLEAR_ALL)..'|A:bags-button-autosort-up:0:0|a|cffff00ff'..(f.tooltip or ''))
        e.tips:Show()
        f:SetAlpha(1)
    end)
    btn:SetScript('OnDoubleClick', func)
    function btn:print_text(num)
        print(WoWTools_Mixin.addName,addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, '|A:bags-button-autosort-up:0:0|a', '|cffff00ff'..(num or 0)..'|r', btn.tooltip)
    end
    btn.tooltip= tooltip
end





function WoWTools_ObjectiveTrackerMixin:Set_Block_Icon(block, icon, type)
    if icon and not block.Icon2 then
        block.Icon2= block:CreateTexture(nil, 'OVERLAY')
        if block.poiButton then
            block.Icon2:SetPoint('RIGHT',block.poiButton.Display.Icon, 'LEFT', -2, 0)
        else
            block.Icon2:SetPoint('TOPRIGHT', block.HeaderText, 'TOPLEFT', -4,-1)
        end
        block.Icon2:SetSize(26,26)
        block.Icon2:EnableMouse()
        block.Icon2:SetScript('OnLeave', function(f) e.tips:Hide() f:GetParent():SetAlpha(1) end)
        block.Icon2:SetScript('OnEnter', function(f)
            local parent= f:GetParent()
            parent:SetAlpha(0.5)
            local typeID= parent.id
            if not typeID then
                return
            end
            e.tips:SetOwner(f, "ANCHOR_LEFT")
            if f.type=='isAchievement' then
                e.tips:SetAchievementByID(typeID)
            --elseif f.type=='isItem' then
                --e.tips:SetItemByID(typeID)
            elseif f.type=='isRecipe' then
                e.tips:SetRecipeResultItem(typeID)
            end
            e.tips:Show()
        end)
    end
    if block.Icon2 then
        block.Icon2.type= type
        block.Icon2:SetTexture(icon or 0)
    end
end


function WoWTools_ObjectiveTrackerMixin:Set_Line_Icon(line, icon)
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


function WoWTools_ObjectiveTrackerMixin:Get_Block(f, index)
    if f.usedBlocks[f.blockTemplate] then
        return f.usedBlocks[f.blockTemplate][index]
    end
end






local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_ObjectiveTrackerMixin.Save= WoWToolsSave['ObjectiveTracker'] or WoWTools_ObjectiveTrackerMixin.Save

           addName= '|A:Objective-Nub:0:0|a'..(e.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL)
           WoWTools_ObjectiveTrackerMixin.addName= addName

            --添加控制面板
            e.AddPanel_Check({
                name=addName,
                tooltip=addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save().disabled then
                WoWTools_ObjectiveTrackerMixin:Init_Quest()
                WoWTools_ObjectiveTrackerMixin:Init_Campaign_Quest()
                WoWTools_ObjectiveTrackerMixin:Init_World_Quest()
                WoWTools_ObjectiveTrackerMixin:Init_Achievement()
                WoWTools_ObjectiveTrackerMixin:Init_Professions()
                WoWTools_ObjectiveTrackerMixin:Init_MonthlyActivities()
                WoWTools_ObjectiveTrackerMixin:Init_ScenarioObjective()
                WoWTools_ObjectiveTrackerMixin:Init_ObjectiveTrackerFrame()
                WoWTools_ObjectiveTrackerMixin:Init_ObjectiveTrackerShared()
            end

            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ObjectiveTracker']= Save()
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

