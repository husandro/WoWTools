local id, e = ...
local Save={
    scale= e.Player.husandro and 0.85 or 1,
    autoHide= e.Player.husandro and true or nil
}

local addName
local HUD_EDIT_MODE_COLLAPSE_OPTIONS= HUD_EDIT_MODE_COLLAPSE_OPTIONS:gsub('|A:.-|a', '|A:NPE_ArrowUp:0:0|a')
local HUD_EDIT_MODE_EXPAND_OPTIONS= HUD_EDIT_MODE_EXPAND_OPTIONS:gsub('|A:.-|a', '|A:NPE_ArrowDown:0:0|a')
--[[
TRACKER_HEADER_ACHIEVEMENTS = "成就" AchievementObjectiveTracker
TRACKER_HEADER_BONUS_OBJECTIVES = "奖励目标" BonusObjectiveTracker
TRACKER_HEADER_CAMPAIGN_QUESTS = "战役" CampaignQuestObjectiveTracker
TRACKER_HEADER_QUESTS = "任务" QuestObjectiveTracker
TRACKER_HEADER_SCENARIO = "场景战役" ScenarioObjectiveTracker
TRACKER_HEADER_WORLD_QUESTS = "世界任务" WorldQuestObjectiveTracker
PROFESSIONS_TRACKER_HEADER_PROFESSION = "专业技能" ProfessionsRecipeTracker
TRACKER_HEADER_MONTHLY_ACTIVITIES = "旅行者日志" MonthlyActivitiesObjectiveTracker
TRACKER_HEADER_OBJECTIVE = "目标" BonusObjectiveTracker

TRACKER_HEADER_DUNGEON = "地下城"
TRACKER_HEADER_PARTY_QUESTS = "任务"
TRACKER_HEADER_PROVINGGROUNDS = "试炼场"
AdventureObjectiveTracker
]]


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








--清除，全部，按钮
local function Add_ClearAll_Button(frame, tooltip, func)
    local btn= e.Cbtn(frame, {size=22, atlas='bags-button-autosort-up', alpha=0.3})
    btn:SetPoint('RIGHT', frame.Header.MinimizeButton, 'LEFT', -2, 0)
    btn:SetScript('OnLeave', function(self) self:SetAlpha(0.3) e.tips:Hide() end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        --e.tips:AddDoubleLine(e.Icon.right, e.onlyChinese and '选项' or SETTINGS_TITLE)
        e.tips:AddDoubleLine((e.onlyChinese and '双击' or 'Double-Click')..e.Icon.left, (e.onlyChinese and '全部清除' or CLEAR_ALL)..'|A:bags-button-autosort-up:0:0|a|cffff00ff'..(self.tooltip or ''))
        e.tips:Show()
        self:SetAlpha(1)
    end)
    btn:SetScript('OnDoubleClick', func)
    --[[btn:SetScript('OnClick', function(_, d)
        if d=='RightButton' then
            e.OpenPanelOpting(addName)
        end
    end)]]
    function btn:print_text(num)
        print(e.addName, addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, '|A:bags-button-autosort-up:0:0|a', '|cffff00ff'..(num or 0)..'|r', btn.tooltip)
    end
    btn.tooltip= tooltip
end





local function Set_Block_Icon(block, icon, type)
    if icon and not block.Icon2 then
        block.Icon2= block:CreateTexture(nil, 'OVERLAY')
        if block.poiButton then
            block.Icon2:SetPoint('RIGHT',block.poiButton.Display.Icon, 'LEFT', -2, 0)
        else
            block.Icon2:SetPoint('TOPRIGHT', block.HeaderText, 'TOPLEFT', -4,-1)
        end
        block.Icon2:SetSize(26,26)
        block.Icon2:EnableMouse()
        block.Icon2:SetScript('OnLeave', function(self) e.tips:Hide() self:GetParent():SetAlpha(1) end)
        block.Icon2:SetScript('OnEnter', function(self)
            local parent= self:GetParent()
            parent:SetAlpha(0.5)
            local typeID= parent.id
            if not typeID then
                return
            end
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            if self.type=='isAchievement' then
                e.tips:SetAchievementByID(typeID)
            --elseif self.type=='isItem' then
                --e.tips:SetItemByID(typeID)
            elseif self.type=='isRecipe' then
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


local function Set_Line_Icon(line, icon)
    if icon and not line.Icon2 then
        line.Icon2= line:CreateTexture(nil, 'OVERLAY')
        line.Icon2:SetPoint('RIGHT', line.Text)
        line.Icon2:SetSize(16, 16)
        line.Icon2:EnableMouse()
        line.Icon2:SetScript('OnLeave', function(self) self:GetParent():SetAlpha(1) end)
        line.Icon2:SetScript('OnEnter', function(self)
            local parent= self:GetParent()
            parent:SetAlpha(0.5)
        end)
    end
    if line.Icon2 then
        line.Icon2:SetTexture(icon or 0)
    end
end


local function Get_Block(self, index)
    if self.usedBlocks[self.blockTemplate] then
        return self.usedBlocks[self.blockTemplate][index]
    end
end






















--任务 QuestObjectiveTracker QuestObjectiveTrackerMixin
local function Init_Quest()
    Add_ClearAll_Button(QuestObjectiveTracker, e.onlyChinese and '任务' or TRACKER_HEADER_QUESTS, function(self)
        local questIDS, num= {}, 0
        for i= 1, C_QuestLog.GetNumQuestWatches() or 0, 1 do
            local questID= C_QuestLog.GetQuestIDForQuestWatchIndex(i)
            if questID and questID>0 and not C_CampaignInfo.IsCampaignQuest(questID) then
                table.insert(questIDS, questID)
            end
        end
        for index, questID in pairs(questIDS) do
           local wasRemoved= C_QuestLog.RemoveQuestWatch(questID)
           if wasRemoved then
                print(index..')', GetQuestLink(questID) or questID)
                num=num+1
            end
        end
        self:print_text(num)
    end)

    hooksecurefunc(QuestObjectiveTracker, 'AddBlock', function(_, block)
        local questID= block.id and tonumber(block.id)
        if questID then
            local color = select(2, e.QuestLogQuests_GetBestTagID(questID))
            if color and block.HeaderText then
                block.HeaderText:SetTextColor(color.r, color.g, color.b)
            end
        end
    end)


end




















--战役，任务 CampaignQuestObjectiveTracker
local function Init_Campaign_Quest()
    Add_ClearAll_Button(CampaignQuestObjectiveTracker, e.onlyChinese and '战役' or TRACKER_HEADER_CAMPAIGN_QUESTS, function(self)
        local questIDS, num= {}, 0
        for i= 1, C_QuestLog.GetNumQuestWatches() or 0, 1 do
            local questID= C_QuestLog.GetQuestIDForQuestWatchIndex(i)
            if questID and questID>0 and C_CampaignInfo.IsCampaignQuest(questID) then
                table.insert(questIDS, questID)
            end
        end
        for index, questID in pairs(questIDS) do
           local wasRemoved= C_QuestLog.RemoveQuestWatch(questID)
           if wasRemoved then
                print(index..')', GetQuestLink(questID) or questID)
                num=num+1
            end
        end
        self:print_text(num)
    end)
end

































--世界，任务 WorldQuestObjectiveTracker
local function Init_World_Quest()
    Add_ClearAll_Button(WorldQuestObjectiveTracker, e.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS, function(self)
        local questIDS={}
        for i= 1, C_QuestLog.GetNumWorldQuestWatches() or 0, 1 do
            local questID= C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
            if questID and questID>0 then
                table.insert(questIDS, questID)
            end
        end
        local num=0
        for index, questID in pairs(questIDS) do
            local wasRemoved= C_QuestLog.RemoveWorldQuestWatch(questID)
            if wasRemoved then
                print(index..')', GetQuestLink(questID) or questID)
                num=num+1
            end
        end
        self:print_text(num)
    end)
end






















--旅行者日志 MonthlyActivitiesObjectiveTracker
local function Init_MonthlyActivities()
    Add_ClearAll_Button(MonthlyActivitiesObjectiveTracker, e.onlyChinese and '旅行者日志' or TRACKER_HEADER_MONTHLY_ACTIVITIES, function(self)
        local num=0
        for _, perksActivityIDs in pairs(C_PerksActivities.GetTrackedPerksActivities() or {}) do
            for _, perksActivityID in pairs(perksActivityIDs) do
                C_PerksActivities.RemoveTrackedPerksActivity(perksActivityID)
                num= num+1
            end
        end
        self:print_text(num)
    end)
end





















--成就 AchievementObjectiveTracker
local function Init_Achievement()
    Add_ClearAll_Button(AchievementObjectiveTracker, e.onlyChinese and '成就' or TRACKER_HEADER_ACHIEVEMENTS, function(self)
        local num=0
        for index, achievementID in pairs(C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)) do
            C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, achievementID,  Enum.ContentTrackingStopType.Manual)
            print(index..')', GetAchievementLink(achievementID) or achievementID)
            num= num +1
        end
        if num>0 and AchievementFrame and AchievementFrame:IsVisible() and AchievementFrameAchievements_ForceUpdate then
            e.call(AchievementFrameAchievements_ForceUpdate)--Blizzard_ObjectiveTracker
        end
        self:print_text(num)
    end)



    hooksecurefunc(AchievementObjectiveTracker, 'AddAchievement', function(self, achievementID)
        local block = Get_Block(self, achievementID)
        if not block then
            return
        end

        local icon= select(10, GetAchievementInfo(achievementID))
        Set_Block_Icon(block, icon, 'isAchievement')


        for index, line in pairs(block.usedLines or {}) do
            local subIcon
            if type(index)=='number' then
                --local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementID, index);
                local assetID= select(8, GetAchievementCriteriaInfo(achievementID, index))
                subIcon = assetID and select(10, GetAchievementInfo(assetID))
            end
            Set_Line_Icon(line, subIcon)
        end
    end)


end
























--专业技能 ProfessionsRecipeTracker
local function Init_Professions()
    Add_ClearAll_Button(ProfessionsRecipeTracker, e.onlyChinese and '专业技能' or PROFESSIONS_TRACKER_HEADER_PROFESSION, function(self)
        local num= 0
        local function clear_Recipe(isRecrafting)
            for index, recipeID in pairs(C_TradeSkillUI.GetRecipesTracked(isRecrafting) or {}) do
                C_TradeSkillUI.SetRecipeTracked(recipeID, false, isRecrafting)
                local itemLink= C_TradeSkillUI.GetRecipeItemLink(recipeID)
                if itemLink then
                    print(index..')', itemLink, isRecrafting and (e.onlyChinese and '再造' or PROFESSIONS_CRAFTING_FORM_OUTPUT_RECRAFT) or '')
                end
                num=num+1
            end
        end
        clear_Recipe(true)
        clear_Recipe(false)
        self:print_text(num)
    end)


    hooksecurefunc(ProfessionsRecipeTracker, 'AddRecipe', function(self, recipeID, isRecraft)
        local blockID = NegateIf(recipeID, isRecraft);
	    local block = Get_Block(self, blockID)

        if not block then
            return
        end

        local data=  C_TradeSkillUI.GetRecipeInfo(recipeID)
        if data then
            Set_Block_Icon(block, data.icon, 'isRecipe')
        end

        local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)
        if not recipeSchematic or not recipeSchematic.reagentSlotSchematics then
            return
        end

        for index, line in pairs(block.usedLines or {}) do
            local subIcon
            if type(index)=='number' then
                local reagentSlotSchematic= recipeSchematic.reagentSlotSchematics[index]
                if reagentSlotSchematic then
                    local reagent = reagentSlotSchematic.reagents[1] or {}
                    if reagent.itemID then
                        local item = Item:CreateFromItemID(reagent.itemID);
                        subIcon = item:GetItemIcon()
                    elseif reagent.currencyID then
                        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
                        if currencyInfo then
                            subIcon = currencyInfo.iconFileID;
                        end
                    end
                end
            end

            Set_Line_Icon(line, subIcon)
        end
    end)
end



























local function Init_ScenarioObjective()
    ScenarioObjectiveTracker.StageBlock.numStagesLabel= e.Cstr(ScenarioObjectiveTracker.StageBlock, {copyFont=ScenarioObjectiveTracker.StageBlock.Name, justifyH='RIGHT'})
    ScenarioObjectiveTracker.StageBlock.numStagesLabel:SetPoint('TOPRIGHT', -20,-8)
    function ScenarioObjectiveTracker.StageBlock.numStagesLabel:settings()
        local text
        local currentStage, numStages = select(2, C_Scenario.GetInfo())
        if numStages and numStages>0 and currentStage then
            text= (numStages==currentStage and '|cnGREEN_FONT_COLOR:' or '')..currentStage..'/'..numStages
        end
        self:SetText(text or '')
    end
    hooksecurefunc(ScenarioObjectiveTracker, 'LayoutContents', function(self)
        self.StageBlock.numStagesLabel:settings()
    end)
end

























--ObjectiveTrackerFrame
local function Init_ObjectiveTrackerFrame()
    local btn= ObjectiveTrackerFrame.Header.MinimizeButton

    function btn:set_tooltip()
        local col= self:CanChangeAttribute() and '' or '|cff9e9e9e'
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        
        local text
        text= Save.scale
        if not Save.scale or Save.scale==1 then
            text=e.onlyChinese and '禁用' or DISABLE
        end
        
        e.tips:AddDoubleLine(col..(e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..text, col..'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or MAINMENU, e.Icon.right)
        e.tips:Show()
    end

    function btn:set_scale(isInit)
        if (isInit and Save.scale==1) or not Save.scale or not ObjectiveTrackerFrame:CanChangeAttribute() then
            return
        end
        ObjectiveTrackerFrame:SetScale(Save.scale)
    end
    btn:set_scale(true)

    btn:HookScript('OnLeave', GameTooltip_Hide)
    btn:HookScript('OnEnter', btn.set_tooltip)

    --缩放
    btn:HookScript('OnMouseWheel', function(self, d)
        Save.scale= WoWTools_MenuMixin:ScaleFrame(ObjectiveTrackerFrame, d, Save.scale, function()
            print(e.addName, addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            print('|cnRED_FONT_COLOR:', e.onlyChinese and '友情提示: 可能会出现错误' or 'note: errors may occur')
        end)
        self:set_tooltip()
    end)

    --右击
    function btn:set_frames_show(collapse, isFind)
        local tabs={
            QuestObjectiveTracker,
            CampaignQuestObjectiveTracker,
            WorldQuestObjectiveTracker,
            AchievementObjectiveTracker,
            ProfessionsRecipeTracker,
            MonthlyActivitiesObjectiveTracker,
        }
        for _, frame in pairs(tabs) do
            if frame then
                local isCollapsed = frame:IsCollapsed()
                if (collapse and not isCollapsed) or (not collapse and isCollapsed) then
                    if isFind then
                        return true
                    else
                        local find= false                        
                        for _, block in pairs(frame.usedBlocks and frame.usedBlocks[frame.blockTemplate] or {}) do
                            
                            if block.ItemButton then
                                find=true
                                break
                            end
                        end
                        --frame.Header.MinimizeButton:Click()
                        if not find then
                            frame:ToggleCollapsed()
                        end
                    end
                end
            end
        end
    end

    btn:HookScript('OnMouseDown', function(frame, d)
        if d~='RightButton' then
            return
        end
        MenuUtil.CreateContextMenu(frame, function(owner, root)
            local sub, col
           
            col= owner:set_frames_show(true, true) and '' or '|cff9e9e9e'
            root:CreateButton(col..(e.onlyChinese and '收起选项 |A:NPE_ArrowUp:0:0|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS), function()
                owner:set_frames_show(true, false)
            end)

            col= owner:set_frames_show(false, true) and '' or '|cff9e9e9e'
            root:CreateButton(col..(e.onlyChinese and '展开选项 |A:NPE_ArrowDown:0:0|a' or HUD_EDIT_MODE_EXPAND_OPTIONS), function()
                owner:set_frames_show(false, false)
            end)

            sub= root:CreateCheckbox(e.onlyChinese and '自动' or SELF_CAST_AUTO, function()
                return Save.autoHide
            end, function()
                Save.autoHide = not Save.autoHide and true or nil
                owner.eventFrame:set_event()
            end)
            sub:SetTooltip(function(tooltip, elementDescription)
                GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                GameTooltip_AddInstructionLine(tooltip, e.onlyChinese and e.onlyChinese and '收起选项 |A:NPE_ArrowUp:0:0|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
                GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '仅限在副本中' or format(LFG_LIST_CROSS_FACTION, AGGRO_WARNING_IN_INSTANCE))
            end)

            root:CreateDivider()
            root:CreateButton(e.onlyChinese and '选项' or SETTINGS_TITLE, function()
                e.OpenPanelOpting(nil, addName)
            end)

            sub=root:CreateButton('BUG', function()
                return MenuResponse.Open
            end)
            sub:SetTooltip(function(tooltip)
                tooltip:AddLine(e.onlyChinese and '当有可点击物品按钮时会错误' or 'Wrong when there is an item button')
            end)
        end)
    end)


    btn.eventFrame= CreateFrame('Frame', nil, btn)
    function btn.eventFrame:set_event()
        if Save.autoHide then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent("CHALLENGE_MODE_START")
            self:set_collapse()
        else
            self:UnregisterAllEvents()
        end
    end
    function btn.eventFrame:set_collapse()
        if IsInInstance() then
            self:GetParent():set_frames_show(true, false)
        end
    end
    btn.eventFrame:SetScript('OnEvent', btn.eventFrame.set_collapse)
    btn.eventFrame:set_event()



    hooksecurefunc(ObjectiveTrackerManager, 'ReleaseFrame', function(_, line)
        if line.Icon2 then
            line.Icon2:SetTexture(0)
        end
    end)
end






















local function Init_ObjectiveTrackerShared()
    --物品按钮左边,放大
    hooksecurefunc(QuestObjectiveItemButtonMixin, 'SetUp', function(self)
        --self:ClearAllPoints()
        --self:SetPoint('TOPRIGHT', self:GetParent(), 'TOPLEFT', -8,-4)
        self:SetSize(42,42)
        self.NormalTexture:SetTexture(nil)
    end)
end
















local function Init()
    Init_Quest()
    Init_Campaign_Quest()
    Init_World_Quest()
    Init_Achievement()
    Init_Professions()
    Init_MonthlyActivities()
    Init_ScenarioObjective()
    Init_ObjectiveTrackerFrame()
    Init_ObjectiveTrackerShared()
end





















--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave[HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL] then--以前版本，数据
                local data= WoWToolsSave[HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL]
                Save.scale= data.scale
                Save.autoHide= data.autoHide
                --[[
                    --inCombatHide=e.Player.husandro,--战斗中隐藏
                ]]
                WoWToolsSave[HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL]= nil
            end

            Save= WoWToolsSave['ObjectiveTracker'] or Save
            addName= '|A:Objective-Nub:0:0|a'..(e.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL)

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= addName,
                tooltip= addName,
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.addName, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save.disabled then
                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ObjectiveTracker']=Save
        end
    end
end)
