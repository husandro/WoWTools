local id, e = ...
local addName= HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL
local Save={
    scale= 0.85,
    autoHide=true,
    --inCombatHide=e.Player.husandro,--战斗中隐藏
}
local Initializer

local ModulTab={--Blizzard_ObjectiveTracker.lua
    'SCENARIO_CONTENT_TRACKER_MODULE',--1 场景战役 SCENARIOS
    'UI_WIDGET_TRACKER_MODULE',--2
    'BONUS_OBJECTIVE_TRACKER_MODULE',--3 	奖励目标 SCENARIO_BONUS_OBJECTIVES
    'WORLD_QUEST_TRACKER_MODULE',--4世界任务 TRACKER_HEADER_WORLD_QUESTS
    'CAMPAIGN_QUEST_TRACKER_MODULE',--5战役 TRACKER_HEADER_CAMPAIGN_QUESTS
    'QUEST_TRACKER_MODULE',--6 	追踪任务 TRACK_QUEST
    'ACHIEVEMENT_TRACKER_MODULE',--7 追踪成就 TRACKER_HEADER_ACHIEVEMENTS
    'PROFESSION_RECIPE_TRACKER_MODULE',--8 追踪配方 PROFESSIONS_TRACK_RECIPE
    'MONTHLY_ACTIVITIES_TRACKER_MODULE',--9 旅行者日志 TRACKER_HEADER_MONTHLY_ACTIVITIES
}


--[[local function ItemNum(btn)--增加物品数量
    local nu= btn.itemLink and C_Item.GetItemCount(btn.itemLink, true, true,true) or 0
    if nu>1 and not btn.num then
        btn.num=e.Cstr(btn)
        btn.num:SetPoint('BOTTOMLEFT', btn, 'BOTTOMLEFT', 0, 0)
    end
    if btn.num then
        btn.num:SetText(nu>1 or '')
    end
end]]

--清除, 追踪，按钮
local function create_ClearAll_Button(frame)
    if frame.clearAll then
        return
    end
    frame.clearAll= e.Cbtn(frame, {atlas='bags-button-autosort-up', size={22,22}})
    frame.clearAll:SetPoint('RIGHT', frame.MinimizeButton, 'LEFT',-2,0)
    frame.clearAll:SetAlpha(0.3)
    frame.clearAll:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.3) end)
    frame.clearAll:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if self.tooltip then
            e.tips:AddDoubleLine('|cnGREEN_FONT_COLOR:'..self.tooltip)
        end
        e.tips:AddDoubleLine('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL), e.onlyChinese and '双击'..e.Icon.left or (BUFFER_DOUBLE..e.Icon.left))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:Show()
        self:SetAlpha(1)
    end)
end



--任务颜色
local function set_Quest_Color(block, questID)
    questID=questID or block.id
    if not block or not questID or C_QuestLog.IsFailed(questID) then
        return
    end
    local r, g, b=block.r, block.g, block.b

    if (not r or not g or not b) then
        local color= e.GetQestColor(nil, questID)
        if color then
            r,g,b= color.r, color.g, color.b
        end
    end
    if r and g and b and block.HeaderText then
        block.HeaderText:SetTextColor(r,g,b)
    end
    local questLogIndex = C_QuestLog.GetLogIndexForQuestID(block.id)
    local numObjectives = GetNumQuestLeaderBoards(questLogIndex)
    for objectiveIndex = 1, numObjectives do
        local line = block.lines[objectiveIndex]
        if line and line.Text then
            if line.state == "COMPLETED" then
                line:SetAlpha(0.3)
            end
            if block.r and block.g and block.b then
                line.Text:SetTextColor(block.r, block.g, block.b)
            end
        end
    end
    block.r =r
    block.g=g
    block.b=b
end



--挑战,进入FB时, 隐藏Blizzard_ObjectiveTracker.lua
local function hide_Trecker()
    if not Save.autoHide then
        return
    end
    local ins=IsInInstance()--local sc=C_Scenario.IsInScenario();   
    if ins then
        for index, self in pairs(ModulTab) do
            self= _G[self]
            if index>2 and self and self.Header and self.Header.MinimizeButton then
                if not self.collapsed  then
                    --local module = self.Header.MinimizeButton:GetParent().module;
                    self:SetCollapsed(true);
                    --e.call('ObjectiveTracker_Update', 0, nil, self)--如果有法术按钮时，会出错
                    self.Header.MinimizeButton:SetCollapsed(true);
                    self.setColla=true;
                end
            end
        end
    else
        for index, self in pairs(ModulTab) do
            self= _G[self]
            if index>2 and self and self.Header and self.Header.MinimizeButton then
                if self.setColla then
                    if self.collapsed  then
                        self:SetCollapsed(false);
                       -- e.call('ObjectiveTracker_Update', 0, nil, self)--如果有法术按钮时，会出错
                        self.Header.MinimizeButton:SetCollapsed(false);
                    end
                    self.setColla=nil;
                end
            end
        end
    end
end








--任务
local function Init_Quest()
    hooksecurefunc(QUEST_TRACKER_MODULE, 'OnBlockHeaderLeave', function(_ ,block)
        set_Quest_Color(block, block.id)
    end)
    hooksecurefunc('QuestObjectiveTracker_DoQuestObjectives', function(_, block)--, questCompleted, questSequenced, existingBlock, useFullHeight)
        set_Quest_Color(block)
    end)
    hooksecurefunc(CAMPAIGN_QUEST_TRACKER_MODULE, 'SetBlockHeader', function(_, block, text, questLogIndex, isQuestComplete, questID)--任务颜色 图标
        local info = questLogIndex and C_QuestLog.GetInfo(questLogIndex)
        if not info then
            return
        end
        local color
        if isQuestComplete then-- C_QuestLog.IsComplete(questID) then
            color= e.GetQestColor('Complete')
        elseif C_QuestLog.IsFailed(questID) then
            color= e.GetQestColor('Failed')
        else
            color= e.GetQestColor('Legendary')
        end
        block.r, block.g, block.b= color.r, color.g, color.b
        set_Quest_Color(block, questID)
    end)
    hooksecurefunc(QUEST_TRACKER_MODULE, 'SetBlockHeader', function(_, block, text, questLogIndex, isQuestComplete, questID)--任务颜色 图标
        local info = questLogIndex and C_QuestLog.GetInfo(questLogIndex)
        if not info then
            return
        end

        local m=''
        questID= questID or info.questID
        local atlas, color =e.QuestLogQuests_GetBestTagID(questID, info, nil, isQuestComplete)
        if atlas then
            m=m..atlas
        end

        local ver=GetQuestExpansion(questID or info.questID)--版本
        if ver and ver~= e.ExpansionLevel then
            local col= ver<e.ExpansionLevel and e.GetQestColor('Trivial') or e.GetQestColor('Difficult')
            m= m..col.hex..'['..(ver+1)..']|r'
        end

        if color then
            block.r, block.g, block.b= color.r, color.g, color.b
            set_Quest_Color(block, questID)
        end
        if C_QuestInfoSystem.HasQuestRewardSpells(questID) then
            for _, spellID in pairs(C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}) do
                local texture= GetSpellTexture(spellID)
                if texture then
                    m= format('%s|T%d:0|t', m, texture)
                end
            end
        end

        if m~='' or e.strText[text] then--汉化，图标
            block.HeaderText:SetText(m..e.cn(text))
        end
    end)

    
    --任务，物品
    hooksecurefunc('QuestObjectiveSetupBlockButton_AddRightButton', function(block, btn)--物品按钮左边,放大 --Blizzard_ObjectiveTrackerShared.lua
        if not btn or not block or not btn:IsShown() or block.groupFinderButton == btn then-- or block.rightButton==btn then
            return
        end
        if not btn.set_item_num then
            function btn:set_item_num()--物品数量
                local nu=0
                if self:IsShown() then
                    local itemLink= GetQuestLogSpecialItemInfo(self:GetID() or 0)
                    nu= itemLink and C_Item.GetItemCount(itemLink, true, true,true) or 0
                    if nu>1 and not self.Text then
                        self.Text=e.Cstr(self, {color={r=1,g=1,b=1}})
                        self.Text:SetPoint('BOTTOMRIGHT', -2, 2)
                    end
                end
                if self.Text then
                    self.Text:SetText(nu>1 and nu or '')
                end
            end
            function btn:set_event()
                if self:IsShown() then
                    self:RegisterEvent("BAG_UPDATE")
                else
                    self:UnregisterEvent("BAG_UPDATE")
                end
            end
            btn:SetSize(35,35)--右击移动
            if btn.NormalTexture then btn.NormalTexture:SetSize(60,60) end
            btn:SetClampedToScreen(true)--保存
            btn:SetMovable(true)
            btn:RegisterForDrag("RightButton")
            btn:HookScript("OnDragStart", btn.StartMoving)
            btn:HookScript("OnDragStop", btn.StopMovingOrSizing)
            btn:HookScript("OnEvent", btn.set_item_num)
            btn:HookScript("OnShow", btn.set_event)
            btn:HookScript("OnHide", btn.set_event)

            btn:set_item_num()
            btn:set_event()
        end

        btn:ClearAllPoints()
        if block.HeaderText then
            btn:SetPoint('TOPRIGHT',  block.HeaderText, 'TOPLEFT',-28,0)
        elseif block.TrackedQuest then
            btn:SetPoint('TOPRIGHT',  block.TrackedQuest, 'TOPLEFT',-5,0)
        else
            btn:SetPoint('TOPRIGHT',  block, 'TOPLEFT',-20,0)
        end
    end)
end









--##################################
--8 追踪配方 PROFESSIONS_TRACK_RECIPE
--Blizzard_ProfessionsRecipeTracker.lua
local function Profession_Add_Objectives(isRecraft)--Update
    for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked(isRecraft)) do
        local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft) or {};
        local blockID = NegateIf(recipeID, isRecraft)
        local block = PROFESSION_RECIPE_TRACKER_MODULE:GetBlock(blockID);
        local blockName = isRecraft and format(e.onlyChinese and '再造：%s' or PROFESSIONS_CRAFTING_FORM_RECRAFTING_HEADER, recipeSchematic.name) or recipeSchematic.name;

        if block then
            if recipeSchematic.icon and recipeSchematic.icon>0 then
                block.HeaderText:SetText('|T'..recipeSchematic.icon..':0|t'..blockName)
            else
                local itemLink= C_TradeSkillUI.GetRecipeItemLink(recipeID)
                local icon= itemLink and C_Item.GetItemIconByID(itemLink)
                if icon and icon>0 then
                    block.HeaderText:SetText('|T'..icon..':0|t'..blockName)
                end
            end
        end

        local eligibleSlots = {};
        for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
            if ProfessionsUtil.IsReagentSlotRequired(reagentSlotSchematic) then
                if ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic) then
                    table.insert(eligibleSlots, 1, {slotIndex = slotIndex, reagentSlotSchematic = reagentSlotSchematic});
                else
                    table.insert(eligibleSlots, {slotIndex = slotIndex, reagentSlotSchematic = reagentSlotSchematic});
                end
            end
        end

        for _, tbl in ipairs(eligibleSlots) do--10.1.5, Professions 该成 ProfessionsUtil
            local slotIndex = tbl.slotIndex;
            local reagentSlotSchematic = tbl.reagentSlotSchematic;
            if ProfessionsUtil.IsReagentSlotRequired(reagentSlotSchematic) then
                local reagent = reagentSlotSchematic.reagents[1];
                local quantityRequired = reagentSlotSchematic.quantityRequired;
                local quantity = ProfessionsUtil.AccumulateReagentsInPossession(reagentSlotSchematic.reagents);
                local name, icon

                if ProfessionsUtil.IsReagentSlotBasicRequired(reagentSlotSchematic) then
                    if reagent.itemID then
                        local item = Item:CreateFromItemID(reagent.itemID);
                        name = item:GetItemName();
                        icon= item:GetItemIcon()

                    elseif reagent.currencyID then
                        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
                        if currencyInfo then
                            name = currencyInfo.name;
                            icon= currencyInfo.iconFileID
                        end
                    end
                elseif ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic) then
                    if reagentSlotSchematic.slotInfo then
                        name = reagentSlotSchematic.slotInfo.slotText;
                        icon= reagentSlotSchematic.icon
                    end
                end


                if name and icon then
                    local text = format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, '|T'..icon..':0|t'..format('%s/%d', quantity, quantityRequired), name)
                    local metQuantity = quantity >= quantityRequired;
                    local line= block.lines[slotIndex]
                    if line then
                        line.Text:SetText(text)
                        line:SetAlpha(metQuantity and 0.3 or 1)
                        if line.Dash then
                            if metQuantity then
                                line.Dash:SetVertexColor(0,1,0)
                            else
                                line.Dash:SetVertexColor(1,0,0)
                            end
                        end
                    end
                end
            end
        end
    end
end





















--清除, 追踪, 按钮
local function Init_ClearButton_ObjectiveTracker_Initialize(frame) 
    for _, module in ipairs(frame.MODULES) do
        if module== WORLD_QUEST_TRACKER_MODULE then--4世界任务 TRACKER_HEADER_WORLD_QUESTS
            create_ClearAll_Button(module.Header)
            module.Header.clearAll.tooltip= e.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS
            module.Header.clearAll:SetScript('OnDoubleClick', function(self)
                local questIDS={}
                for i= 1, C_QuestLog.GetNumWorldQuestWatches() do
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
                print(id, Initializer:GetName(), '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.tooltip, '|cffff00ff'..num)
            end)

        elseif module== QUEST_TRACKER_MODULE or module== CAMPAIGN_QUEST_TRACKER_MODULE then--6 追踪任务 TRACK_QUEST
            create_ClearAll_Button(module.Header)
            module.Header.clearAll.tooltip= e.onlyChinese and '战役|n任务' or (TRACKER_HEADER_CAMPAIGN_QUESTS..'|n'..TRACKER_HEADER_QUESTS)
            module.Header.clearAll:SetScript('OnDoubleClick', function(self)
                local questIDS, num= {}, 0
                for i= 1, C_QuestLog.GetNumQuestWatches() do
                    local questID= C_QuestLog.GetQuestIDForQuestWatchIndex(i)
                    if questID and questID>0 then
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
                print(id, Initializer:GetName(), e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, self.tooltip, '|cffff00ff'..num)
            end)

        elseif module== ACHIEVEMENT_TRACKER_MODULE then--7 追踪成就 TRACKING
            create_ClearAll_Button(module.Header)
            module.Header.clearAll.tooltip= e.onlyChinese and '成就' or TRACKER_HEADER_ACHIEVEMENTS
            module.Header.clearAll:SetScript('OnDoubleClick', function(self)
                local num=0
                for index, achievementID in pairs(C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)) do
                    C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, achievementID,  Enum.ContentTrackingStopType.Manual)
                    print(index..')', GetAchievementLink(achievementID) or achievementID)
                    num= num +1
                end
                if num>0 and AchievementFrame then
                    e.call('AchievementFrameAchievements_ForceUpdate')--Blizzard_ObjectiveTracker
                end
                print(id, Initializer:GetName(), '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.tooltip, '|cffff00ff'..num)
            end)

            
        elseif module== PROFESSION_RECIPE_TRACKER_MODULE then--8 追踪配方 PROFESSIONS_TRACK_RECIPE
            create_ClearAll_Button(module.Header)
            module.Header.clearAll.tooltip= e.onlyChinese and '追踪配方' or PROFESSIONS_TRACK_RECIPE
            module.Header.clearAll:SetScript('OnDoubleClick', function(self)
                local num= 0
                local function clear_Recipe(isRecrafting)
                    local tab= C_TradeSkillUI.GetRecipesTracked(isRecrafting) or {}
                    for index, recipeID in pairs(tab) do
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
                print(id, Initializer:GetName(), '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.tooltip, '|cffff00ff'..num)
            end)

        elseif module== MONTHLY_ACTIVITIES_TRACKER_MODULE then--9
            create_ClearAll_Button(module.Header)
            module.Header.clearAll.tooltip= e.onlyChinese and '旅行者日志' or TRACKER_HEADER_MONTHLY_ACTIVITIES
            module.Header.clearAll:SetScript('OnDoubleClick', function(self)
                local tab= C_PerksActivities.GetTrackedPerksActivities() or {}
                local num=0
                for _, perksActivityIDs in pairs(tab) do
                    for _, perksActivityID in pairs(perksActivityIDs) do
                        C_PerksActivities.RemoveTrackedPerksActivity(perksActivityID)
                        num= num+1
                    end
                end
                print(id, Initializer:GetName(), '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.tooltip, '|cffff00ff'..num)
            end)
        end
    end
end
















--操作
local function Init_MinimizeButton_Options()
    function ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:set_scale()
        ObjectiveTrackerFrame:SetScale(Save.scale or 1)
    end
    function ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:colla_module(type)
        for _, frame in pairs(ModulTab) do
            frame= _G[frame]
            if frame and frame.Header and frame.Header.MinimizeButton then
                if frame.collapsed ~=type and frame.Header.added and frame.Header:IsVisible() then
                    local module = frame.Header.MinimizeButton:GetParent().module
                    module:SetCollapsed(type)
                    --e.call('ObjectiveTracker_Update', 0, nil, module)--如果有法术按钮时，会出错
                    frame.Header.MinimizeButton:SetCollapsed(type)
                end
            end
        end
    end

    function ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '展开选项 |A:editmode-down-arrow:16:11:0:-7|a/收起选项 |A:editmode-up-arrow:16:11:0:3|a' or (HUD_EDIT_MODE_EXPAND_OPTIONS..'/'..HUD_EDIT_MODE_COLLAPSE_OPTIONS), e.Icon.mid)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..': |cnGREEN_FONT_COLOR:'..(Save.scale or 1), 'Alt+ '..e.Icon.mid)
        e.tips:AddDoubleLine('|A:mechagon-projects:0:0|a'..(e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE))..': '..e.GetEnabeleDisable(Save.autoHide), 'Alt+ '..e.Icon.right)
        e.tips:Show()
    end
    ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript("OnLeave", GameTooltip_Hide)
    ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript("OnEnter",ObjectiveTrackerFrame.HeaderMenu.MinimizeButton.set_tooltips)
    ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript('OnMouseWheel',function(self, d)
        if not IsModifierKeyDown() then
            self:colla_module( d==1 and true or false)
        elseif IsAltKeyDown() then
            local num= Save.scale or 1
            num= d==1 and num-0.05 or num
            num= d==-1 and num+ 0.05 or num
            num= num>4 and 4 or num
            num= num< 0.4 and 0.4 or num
            Save.scale=num
            self:set_scale(true)
            self:set_tooltips()
        end
    end)

    --战斗中收起
    function ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:set_evnet()
        if Save.inCombatHide then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        else
            self:UnregisterEvent('PLAYER_REGEN_DISABLED')
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end
    ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript('OnEvent', function(_, event)
        if event=='PLAYER_REGEN_DISABLED' then
            e.call('ObjectiveTracker_Collapse')

        elseif event=='PLAYER_REGEN_ENABLED' then
            e.call('ObjectiveTracker_Expand')
        end
    end)

    ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:HookScript('OnClick', function(_, d)
        if IsAltKeyDown() and d=='RightButton' then
            e.OpenPanelOpting('|A:Objective-Nub:0:0|a'..(e.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL))
        end
    end)

    ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:set_scale()
    ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:set_evnet()
end























--####
--初始
--####
local function Init()    
    Init_MinimizeButton_Options()--操作
    Init_Quest()--任务
    hooksecurefunc(PROFESSION_RECIPE_TRACKER_MODULE, 'Update', function(frame)--8 追踪配方
        Profession_Add_Objectives(true)
        Profession_Add_Objectives(false)
    end)


    hooksecurefunc('ObjectiveTracker_Initialize', Init_ClearButton_ObjectiveTracker_Initialize)--清除, 追踪, 按钮


    hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, 'Update', function()
        local self= ScenarioStageBlock
        --local scenarioName, currentStage, numStages, flags, _, _, _, xp, money, scenarioType, _, textureKit = C_Scenario.GetInfo()
        local currentStage, numStages= select(2, C_Scenario.GetInfo())
        if not self.numLabel then
            self.numLabel= e.Cstr(self, {copyFont=self.Stage})
            self.numLabel:SetPoint('LEFT', self.Stage, 'RIGHT')
        end
        local text
        if currentStage and numStages and numStages>1 then
            text= format('|cnGREEN_FONT_COLOR:%d|r%s/%d', currentStage, currentStage==numStages and '|cnGREEN_FONT_COLOR:' or '', numStages)
        end
        self.numLabel:SetText(text or '')
    end)

    hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, 'SetBlockHeader', function(self, block, text)
        text= e.strText[text]
        if text then
            local height = self:SetStringText(block.HeaderText, text, nil, OBJECTIVE_TRACKER_COLOR["Header"], block.isHighlighted)
            block.height = height
        end
    end)
end





















--添加控制面板
local function Init_Options()
    Initializer= e.AddPanel_Check({
        name= '|A:Objective-Nub:0:0|a'..(e.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL),
        tooltip= e.cn(addName),
        value= not Save.disabled,
        func= function()
            Save.disabled= not Save.disabled and true or nil
            print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })
    local initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
        tooltip= (e.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL)
            ..'|n|n'..(e.onlyChinese and '场景战役' or SCENARIOS)..' ...'
            ..'|nUI WIDGET ...'
            ..'|n|n'..(e.onlyChinese and '奖励目标' or SCENARIO_BONUS_OBJECTIVES)..' '..e.GetShowHide(false)
            ..'|n'..(e.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS)..' '..e.GetShowHide(false)
            ..'|n'..(e.onlyChinese and '战役' or TRACKER_HEADER_CAMPAIGN_QUESTS)..' '..e.GetShowHide(false)
            ..'|n'..(e.onlyChinese and '追踪任务' or TRACK_QUEST)..' '..e.GetShowHide(false)
            ..'|n'..(e.onlyChinese and '追踪成就' or TRACKER_HEADER_ACHIEVEMENTS)..' '..e.GetShowHide(false)
            ..'|n'..(e.onlyChinese and '追踪配方' or PROFESSIONS_TRACK_RECIPE)..' '..e.GetShowHide(false)
            ..'|n|n'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT )..' '..e.GetShowHide(false),
        value= Save.autoHide,
        func= function()
            Save.autoHide= not Save.autoHide and true or nil
            print(id, Initializer:GetName(), e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
                e.onlyChinese and '任务追踪栏' or QUEST_OBJECTIVES, e.GetEnabeleDisable(Save.autoHide)
            )
            if ObjectiveTrackerFrame.HeaderMenu.MinimizeButton.set_evnet then
                ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:set_evnet()
            end
        end
    })
    initializer2:SetParentInitializer(Initializer, function() if Save.disabled then return false else return true end end)
    initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '战斗中隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, HIDE),
        value= Save.inCombatHide,
        func= function()
            Save.inCombatHide= not Save.inCombatHide and true or nil
            if ObjectiveTrackerFrame.HeaderMenu.MinimizeButton.set_evnet then
                ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:set_evnet()
            end
        end
    })
    initializer2:SetParentInitializer(Initializer, function() if Save.disabled then return false else return true end end)

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
            Save= WoWToolsSave[addName] or Save

            Init_Options()--添加控制面板

            if not Save.disabled then
                Init()
                self:RegisterEvent("PLAYER_ENTERING_WORLD")
                self:RegisterEvent("CHALLENGE_MODE_START")
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_ENTERING_WORLD' or event=='CHALLENGE_MODE_START' then--隐藏
        hide_Trecker()
    end
end)