local id, e = ...
local addName=	TRACK_QUEST
local Save={
        scale= 0.85,
        autoHide=true
    }


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

local Color={
    Day={0.10, 0.72, 1},--日常
    Week={0.02, 1, 0.66},--周长
    Legendary={1, 0.49, 0},--传说
    Calling={1, 0, 0.9},--使命

    Trivial={0.53, 0.53, 0.53},--0 难度 Difficulty
    Easy={0.63, 1, 0.61},--1
    Difficult={1, 0.43, 0.42},--3
    Impossible={1, 0, 0.08},--4
}

local function ItemNum(button)--增加物品数量
    if button.itemLink then
        local nu=GetItemCount(button.itemLink, true, true,true)
        if nu>1 then
            if not button.num then
                button.num=e.Cstr(button)
                button.num:SetPoint('BOTTOMLEFT', button, 'BOTTOMLEFT', 0, 0)
            end
            button.num:SetText(nu)
            return
        end
    end
    if button.num then
        button.num:SetText('')
    end
end


local colla_Module=function(type)
    for _, self in pairs(ModulTab) do
        self= _G[self]
        if self and self.Header and self.Header.MinimizeButton then
            if self.collapsed ~=type and self.Header.added and self.Header:IsVisible() then
                local module = self.Header.MinimizeButton:GetParent().module
                module:SetCollapsed(type)
                ObjectiveTracker_Update(0, nil, module)
                self.Header.MinimizeButton:SetCollapsed(type)
            end
        end
    end
end

local function Scale(setPrint)
    if Save.scale<0.5 then
        Save.scale=0.5
    elseif Save.scale>1.5 then
        Save.scale=1.5
    end
    ObjectiveTrackerFrame:SetScale(Save.scale)
    if setPrint then
        print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:',Save.scale)
    end
end



--任务颜色
local function setColor(block, questID)
    questID=questID or block.id
    if not block or not questID or C_QuestLog.IsFailed(questID) then
        return
    end
    local r, g, b=block.r, block.g, block.b

    if (not r or not g or not b)  and UnitEffectiveLevel('player')== e.Player.level then
        local lv= C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID)
        if lv then
            if lv== 0 then--Trivial    
                r,g,b= Color.Trivial[1], Color.Trivial[2], Color.Trivial[3]
            elseif lv== 1 then--Easy    
                r,g,b= Color.Easy[1], Color.Easy[2], Color.Easy[3]
            elseif lv==3 then--Difficult    
                r,g,b= Color.Difficult[1], Color.Difficult[2], Color.Difficult[3]
            elseif lv==4 then--Impossible    
                r,g,b= Color.Impossible[1], Color.Impossible[2], Color.Impossible[3]
            end
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

local function hideTrecker()--挑战,进入FB时, 隐藏Blizzard_ObjectiveTracker.lua
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
                    securecallfunction(ObjectiveTracker_Update, 0, nil, self)
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
                        securecallfunction(ObjectiveTracker_Update, 0, nil, self)
                        self.Header.MinimizeButton:SetCollapsed(false);
                    end
                    self.setColla=nil;
                end
            end
        end
    end
end

--####
--初始
--####
local function Init()
    if Save.scale and Save.scale~=1 then
        Scale()
    end--缩放

    local btn=ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
    btn:SetScript("OnLeave", function(self) e.tips:Hide() end)
    btn:SetScript("OnEnter",function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')

        e.tips:AddDoubleLine(e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE), e.Icon.mid)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..': '..(Save.scale or 1), 'Ctrl + '..e.Icon.mid)
        e.tips:Show()
    end)
    btn:SetScript('OnMouseWheel',function(self,d)
        if d == 1 and not IsModifierKeyDown() then
            colla_Module(true)
            print(id, addName,'|cnRED_FONT_COLOR:', e.onlyChinese and '全部隐藏' or (HIDE..ALL))
        elseif d == -1 and not IsModifierKeyDown() then
            colla_Module()
            print(id, addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '显示全部' or (SHOW..ALL))
        elseif d==1 and IsControlKeyDown() then
            Save.scale=Save.scale+0.05
            Scale(true)
        elseif d==-1 and IsControlKeyDown() then
            Save.scale=Save.scale-0.05
            Scale(true)
        end
    end)

    hooksecurefunc(QUEST_TRACKER_MODULE, 'OnBlockHeaderLeave', function(self ,block)
        setColor(block, block.id)
    end)
    hooksecurefunc('QuestObjectiveTracker_DoQuestObjectives', function(self, block, questCompleted, questSequenced, existingBlock, useFullHeight)
        setColor(block)
    end)

    hooksecurefunc(QUEST_TRACKER_MODULE,'SetBlockHeader', function(self, block, text, questLogIndex, isQuestComplete, questID)--任务颜色 图标
        local m=''
        block.r, block.g, block.b=nil, nil, nil
        if questID then
            if C_QuestLog.IsComplete(questID) then m=m..e.Icon.select2 elseif C_QuestLog.IsFailed(questID) then m=m.e.Icon.X2 end
            local factionGroup = GetQuestFactionGroup(questID)
            if factionGroup == LE_QUEST_FACTION_HORDE then
                m=m..e.Icon.horde2
                if factionGroup == LE_QUEST_FACTION_ALLIANCE then
                    m=m..e.Icon.alliance2
                end
            end
            if  C_QuestLog.IsQuestCalling(questID) then--使命
                m=m..'|A:campaignavailabledailyquesticon:10:10|a'
                block.r, block.g, block.b=Color.Calling[1],Color.Calling[2],Color.Calling[3]
            end
            if C_QuestLog.IsAccountQuest(questID) then m=m..e.Icon.wow2 end--帐户
            if C_QuestLog.IsLegendaryQuest(questID) then
                m=m..'|A:questlegendary:10:10|a'
                block.r, block.g, block.b=Color.Legendary[1],Color.Legendary[2],Color.Legendary[3]
            end--传奇                            
        end
        if questLogIndex then
            local info = C_QuestLog.GetInfo(questLogIndex)
            if info then
                if info.startEvent then--事件开始
                    m=m..'|A:vignetteevent:10:10|a'
                end
                if info.frequency then
                    if info.frequency==Enum.QuestFrequency.Daily then--日常
                        m=m..'|A:UI-DailyQuestPoiCampaign-QuestBang:10:10|a'
                        block.r, block.g, block.b=Color.Day[1],Color.Day[2],Color.Day[3]
                    elseif info.frequency==Enum.QuestFrequency.Weekly then--周常
                        m=m..'|A:weeklyrewards-orb-unlocked:10:10|a'
                        block.r, block.g, block.b= Color.Week[1], Color.Week[2], Color.Week[3]
                    end
                end
                local ver=GetQuestExpansion(questID or info.questID)--版本
                if ver and ver~= e.ExpansionLevel then
                    m=m..(ver<e.ExpansionLevel and  '|cff606060' or '|cnRED_FONT_COLOR:')..'['..(ver+1)..']|r'
                end
                if info.campaignID then
                    block.r, block.g, block.b=Color.Legendary[1],Color.Legendary[2],Color.Legendary[3]
                elseif info.isStory then
                    block.r, block.g, block.b=Color.Legendary[1],Color.Legendary[2],Color.Legendary[3]
                    m= '|A:StoryHeader-CheevoIcon:0:0|a'..m
                end
            end
        end
        setColor(block, questID)
        if m~='' then block.HeaderText:SetText(m..text) end
    end)

    --##################################
    --8 追踪配方 PROFESSIONS_TRACK_RECIPE
    --Blizzard_ProfessionsRecipeTracker.lua
    hooksecurefunc(PROFESSION_RECIPE_TRACKER_MODULE, 'Update', function(self)
        local function AddObjectives(isRecraft)
			for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked(isRecraft)) do
				local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft);
				local blockID = NegateIf(recipeID, isRecraft);
				local block = self:GetBlock(blockID);
				local blockName = isRecraft and format(e.onlyChinese and '再造：%s' or PROFESSIONS_CRAFTING_FORM_RECRAFTING_HEADER, recipeSchematic.name)
                                            --or recipeSchematic.name;
                                
                if recipeSchematic.icon and recipeSchematic.icon>0 then
                    block.HeaderText:SetText('|T'..recipeSchematic.icon..':0|t'..blockName)
                end
				--self:SetBlockHeader(block, blockName);
                
				local eligibleSlots = {};
				for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
					if Professions.IsReagentSlotRequired(reagentSlotSchematic) then
						if Professions.IsReagentSlotModifyingRequired(reagentSlotSchematic) then
							table.insert(eligibleSlots, 1, {slotIndex = slotIndex, reagentSlotSchematic = reagentSlotSchematic});
						else
							table.insert(eligibleSlots, {slotIndex = slotIndex, reagentSlotSchematic = reagentSlotSchematic});
						end
					end
				end

				for _, tbl in ipairs(eligibleSlots) do
					local slotIndex = tbl.slotIndex;
					local reagentSlotSchematic = tbl.reagentSlotSchematic;
					if Professions.IsReagentSlotRequired(reagentSlotSchematic) then
						local reagent = reagentSlotSchematic.reagents[1];
						local quantityRequired = reagentSlotSchematic.quantityRequired;
						local quantity = Professions.AccumulateReagentsInPossession(reagentSlotSchematic.reagents);
						local name, icon

						if Professions.IsReagentSlotBasicRequired(reagentSlotSchematic) then
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
						elseif Professions.IsReagentSlotModifyingRequired(reagentSlotSchematic) then
							if reagentSlotSchematic.slotInfo then
								name = reagentSlotSchematic.slotInfo.slotText;
                                icon= reagentSlotSchematic.icon
							end
						end
						

						if name and icon then
                            local text = format('%s %s', '|T'..icon..':0|t'..format('%s/%d', quantity, quantityRequired), name)
							local metQuantity = quantity >= quantityRequired;

                            local line= block.lines[slotIndex]
                            if line then
                                line.Text:SetText(text)
                                line:SetAlpha(metQuantity and 0.5 or 1)
                            end
						end
					end
				end

				--block:SetHeight(block.height);

				--[[if ( ObjectiveTracker_AddBlock(block) ) then
					block:Show();
					self:FreeUnusedLines(block);
				else
					block.used = false;
					break;
				end]]
			end
		end

		AddObjectives(true);
		AddObjectives(false);
    end)

    --[[hooksecurefunc(PROFESSION_RECIPE_TRACKER_MODULE, 'SetStringText', function(self, fontString, text, useFullHeight, colorStyle, useHighlight)
        local te=text:gsub('%d+/%d+ ','')
        if te then
            local icon = C_Item.GetItemIconByID(te)
            if icon and icon~=134400 then
                local str='|T'..icon..':0|t'..te

                local count, totale=text:match('(%d+)/(%d+)')
                count, totale=count and tonumber(count), totale and tonumber(totale)
                local ok
                if count and totale and count>=totale then
                    str=str..e.Icon.select2
                    ok=true
                end

                str=text:gsub(te, str)
                if ok then
                    str='|cnGREEN_FONT_COLOR:'..str..'|r'
                end
                fontString:SetText(str)
            end
        end
    end)]]

    hooksecurefunc('QuestObjectiveSetupBlockButton_AddRightButton', function(block, button)--物品按钮左边,放大 --Blizzard_ObjectiveTrackerShared.lua
        if not button or not block or not button:IsShown() or block.groupFinderButton == button then
            return
        end

        button.itemLink=GetQuestLogSpecialItemInfo(button:GetID())--物品数量
        if not button.setMove then
            button:SetSize(35,35)--右击移动
            if  button.NormalTexture then button.NormalTexture:SetSize(60,60) end
            button:SetClampedToScreen(true)--保存
            button:SetMovable(true)
            button:RegisterForDrag("RightButton")
            button:SetScript("OnDragStart", function(self)
                self:StartMoving()
            end)
            button:SetScript("OnDragStop", function(self)
                    self:StopMovingOrSizing()
            end)
            button:RegisterEvent('BAG_UPDATE')
            button:SetScript("OnEvent", function(self2)
                ItemNum(self2)
            end)
            button:SetScript("OnShow", function()
                button:RegisterEvent("BAG_UPDATE")
            end)
            button:SetScript("OnHide", function()
                button.itemLink=nil
                button:UnregisterEvent("BAG_UPDATE")
            end)
            ItemNum(button)
            button.setMove=true
        end

        button:ClearAllPoints()
        if block.HeaderText then
            button:SetPoint('TOPRIGHT',  block.HeaderText, 'TOPLEFT',-28,0)
        elseif block.TrackedQuest then
            button:SetPoint('TOPRIGHT',  block.TrackedQuest, 'TOPLEFT',-5,0)
        else
            button:SetPoint('TOPRIGHT',  block, 'TOPLEFT',-20,0)
        end
    end)

    --##########
    --清除, 追踪
    --##########
    local function create_ClearAll_Button(self)
        self.clearAll= e.Cbtn(self, {atlas='bags-button-autosort-up', size={22,22}})
        self.clearAll:SetPoint('RIGHT', self.MinimizeButton, 'LEFT',-2,0)
        self.clearAll:SetAlpha(0.3)
        self.clearAll:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.3) end)
        self.clearAll:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            if self2.tooltip then
                e.tips:AddDoubleLine('|cnGREEN_FONT_COLOR:'..self2.tooltip)
            end
            e.tips:AddDoubleLine('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL), e.onlyChinese and '双击'..e.Icon.left or (BUFFER_DOUBLE..e.Icon.left))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
            self2:SetAlpha(1)
        end)
    end
    hooksecurefunc('ObjectiveTracker_Initialize', function(self)
        for _, module in ipairs(self.MODULES) do
            if module== WORLD_QUEST_TRACKER_MODULE then--4世界任务 TRACKER_HEADER_WORLD_QUESTS
                create_ClearAll_Button(module.Header)
                module.Header.clearAll.tooltip= e.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS
                module.Header.clearAll:SetScript('OnDoubleClick', function(self2)
                    local questIDS={}
                    for i= 1, C_QuestLog.GetNumWorldQuestWatches() do
                        local questID= C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
                        if questID and questID>0 then
                            table.insert(questIDS, questID)
                        end
                    end
                    local num=0
                    for _, questID in pairs(questIDS) do
                        local wasRemoved= C_QuestLog.RemoveWorldQuestWatch(questID)
                        if wasRemoved then
                            num=num+1
                        end
                    end
                    print(id, addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, self2.tooltip, '|cffff00ff'..num)
                end)

            elseif module== QUEST_TRACKER_MODULE or module== CAMPAIGN_QUEST_TRACKER_MODULE then--6 追踪任务 TRACK_QUEST
                create_ClearAll_Button(module.Header)
                module.Header.clearAll.tooltip= e.onlyChinese and '战役|n任务' or (TRACKER_HEADER_CAMPAIGN_QUESTS..'|n'..TRACKER_HEADER_QUESTS)
                module.Header.clearAll:SetScript('OnDoubleClick', function(self2)
                    local questIDS, num= {}, 0
                    for i= 1, C_QuestLog.GetNumQuestWatches() do
                        local questID= C_QuestLog.GetQuestIDForQuestWatchIndex(i)
                        if questID and questID>0 then
                            table.insert(questIDS, questID)
                        end
                    end
                    for _, questID in pairs(questIDS) do
                       local wasRemoved= C_QuestLog.RemoveQuestWatch(questID)
                       if wasRemoved then
                            num=num+1
                        end
                    end
                    print(id, addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, self2.tooltip, '|cffff00ff'..num)
                end)

            elseif module== ACHIEVEMENT_TRACKER_MODULE then--7 追踪成就 TRACKING
                create_ClearAll_Button(module.Header)
                module.Header.clearAll.tooltip= e.onlyChinese and '成就' or TRACKER_HEADER_ACHIEVEMENTS
                module.Header.clearAll:SetScript('OnDoubleClick', function(self2)
                    local num=0
                    for _, achievementID in pairs({GetTrackedAchievements()}) do
                        RemoveTrackedAchievement(achievementID)
                    end
                    print(id, addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, self2.tooltip, '|cffff00ff'..num)
                end)

            elseif module== PROFESSION_RECIPE_TRACKER_MODULE then--8 追踪配方 PROFESSIONS_TRACK_RECIPE
                create_ClearAll_Button(module.Header)
                module.Header.clearAll.tooltip= e.onlyChinese and '追踪配方' or PROFESSIONS_TRACK_RECIPE 
                module.Header.clearAll:SetScript('OnDoubleClick', function(self2)
                    local tab= C_TradeSkillUI.GetRecipesTracked(false) or {}
                    local num= 0
                    for _, recipeID in pairs(tab) do
                        C_TradeSkillUI.SetRecipeTracked(recipeID, false, false)
                        num=num+1
                    end

                    local tab2= C_TradeSkillUI.GetRecipesTracked(true) or {}
                    for _, recipeID in pairs(tab2) do
                        C_TradeSkillUI.SetRecipeTracked(recipeID, false, true)
                        num=num+1
                    end
                    print(id, addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, self2.tooltip, '|cffff00ff'..num)
                end)

            elseif module== MONTHLY_ACTIVITIES_TRACKER_MODULE then--9
                create_ClearAll_Button(module.Header)
                module.Header.clearAll.tooltip= e.onlyChinese and '旅行者日志' or TRACKER_HEADER_MONTHLY_ACTIVITIES
                module.Header.clearAll:SetScript('OnDoubleClick', function(self2)
                    local tab= C_PerksActivities.GetTrackedPerksActivities() or {}
                    local num=0
                    for _, perksActivityIDs in pairs(tab) do
                        for _, perksActivityID in pairs(perksActivityIDs) do
                            C_PerksActivities.RemoveTrackedPerksActivity(perksActivityID)
                            num= num+1
                        end
                    end
                    print(id, addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, self2.tooltip, '|cffff00ff'..num)
                end)
            end
        end
    end)
end

--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("PLAYER_ENTERING_WORLD")
panel:RegisterEvent("CHALLENGE_MODE_START")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel('|A:Objective-Nub:0:0|a'..(e.onlyChinese and '目标追踪栏' or HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end)

            if not Save.disabled then
                local sel2=CreateFrame("CheckButton", nil, sel, "InterfaceOptionsCheckButtonTemplate")
                sel2.text:SetText(e.onlyChinese and '自动隐藏' or (AUTO_JOIN:gsub(JOIN, HIDE)))
                sel2:SetPoint('LEFT', sel.Text, 'RIGHT')
                sel2:SetChecked(Save.autoHide)
                sel2:SetScript('OnEnter', function(self2)
                    local text=e.GetShowHide(false)
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(e.onlyChinese and '场景战役' or SCENARIOS, '...')
                    e.tips:AddDoubleLine('UI WIDGET', '...')
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.onlyChinese and '奖励目标' or SCENARIO_BONUS_OBJECTIVES, text)
                    e.tips:AddDoubleLine(e.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS, text)
                    e.tips:AddDoubleLine(e.onlyChinese and '战役' or TRACKER_HEADER_CAMPAIGN_QUESTS, text)
                    e.tips:AddDoubleLine(e.onlyChinese and '追踪任务' or TRACK_QUEST, text)
                    e.tips:AddDoubleLine(e.onlyChinese and '追踪成就' or (TRACKER_HEADER_ACHIEVEMENTS), text)
                    e.tips:AddDoubleLine(e.onlyChinese and '追踪配方' or PROFESSIONS_TRACK_RECIPE, text)
                    e.tips:Show()
                end)
                sel2:SetScript('OnLeave', function() e.tips:Hide() end)

                sel2:SetScript('OnMouseDown', function ()
                    Save.autoHide= not Save.autoHide and true or nil
                    print(id, addName, e.onlyChinese and '自动隐藏' or (AUTO_JOIN:gsub(JOIN, '')..HIDE), e.onlyChinese and '任务追踪栏' or QUEST_OBJECTIVES, e.GetEnabeleDisable(Save.autoHide))
                end)

                Init()
                panel:UnregisterEvent('ADDON_LOADED')
            else
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    elseif event=='PLAYER_ENTERING_WORLD' or event=='CHALLENGE_MODE_START' then--隐藏
        hideTrecker()

    end
end)