local id, e = ...
local addName=HUD_EDIT_MODE_OBJECTIVE_TRACKER_LABEL
local Save={scale= 0.85, alpha=1, autoHide=true}
local F=ObjectiveTrackerFrame--移动任务框
local btn=ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
local mo={
    SCENARIO_CONTENT_TRACKER_MODULE,--1 场景战役 SCENARIOS
    UI_WIDGET_TRACKER_MODULE,--2
    BONUS_OBJECTIVE_TRACKER_MODULE,--3 	奖励目标 SCENARIO_BONUS_OBJECTIVES
    WORLD_QUEST_TRACKER_MODULE,--4世界任务 TRACKER_HEADER_WORLD_QUESTS
    CAMPAIGN_QUEST_TRACKER_MODULE,--5战役 TRACKER_HEADER_CAMPAIGN_QUESTS
    QUEST_TRACKER_MODULE,--6 	追踪任务 TRACK_QUEST
    ACHIEVEMENT_TRACKER_MODULE,--7 追踪成就 TRACKING..
    PROFESSION_RECIPE_TRACKER_MODULE,--追踪配方 PROFESSIONS_TRACK_RECIPE
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
local Icon={
    day='|A:UI-DailyQuestPoiCampaign-QuestBang:0:0|a',
    legend='|A:questlegendary:0:0|a',
    week='|A:weeklyrewards-orb-unlocked:0:0|a',
    start='|A:vignetteevent:0:0|a',
    campa='|A:campaignavailabledailyquesticon:0:0|a',
    x2='Interface\\AddOns\\WeakAuras\\Media\\Textures\\cancel-icon.tga',
    clear='bags-button-autosort-up'
}

hooksecurefunc('QuestObjectiveItem_OnEnter', function(self)
        if not Save.disabled and self.setMove and e.tips:IsShown() then
            e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
            e.tips:Show()
        end
end)

local function ItemNum(button)--增加物品数量
    if button.itemLink then
        local nu=GetItemCount(button.itemLink)

        if nu>1 then
            if not button.num then
                button.num=e.Cstr(button)
                button.num:SetPoint('BOTTOMLEFT', button, 'BOTTOMLEFT', 0, 0)                
            end
            button.num:SetText(nu)
            return
        end
    end
    if button.num then button.num:SetText('') end
end
hooksecurefunc('QuestObjectiveSetupBlockButton_AddRightButton', function(block, button)--物品按钮左边,放大
        if Save.disabled or not button or not block or not button:IsShown()  or block.groupFinderButton == button then
            return
        end
        button:ClearAllPoints()
        if not button.point then
            button:SetPoint('TOPRIGHT',block,'TOPLEFT',-25, 0)
        else
            button:SetPoint(button.point[1], button.point[2], button.point[3], button.point[4], button.point[5])
        end

        if not button.setMove then                                
            button:SetSize(35,35)--右击移动
            if  button.NormalTexture then button.NormalTexture:SetSize(60,60) end
            button:SetClampedToScreen(true)--保存
            button:SetMovable(true)
            button:RegisterForDrag("RightButton")
            button:SetScript("OnDragStart", function(self)
                    if not IsModifierKeyDown()  then  self:StartMoving() end
            end)
            button:SetScript("OnDragStop", function(self)
                    self:StopMovingOrSizing()
                    self.point={self:GetPoint(1)}
                    print(addName..'|cFF00FF00Alt+'..e.Icon.right..KEY_BUTTON2..'|r: '.. TRANSMOGRIFY_TOOLTIP_REVERT)
            end)
            button:SetScript("OnMouseDown", function(self, d)
                    if d=='RightButton' and IsAltKeyDown() and not self.Moving then
                        self:ClearAllPoints()
                        self:SetPoint('TOPRIGHT',block,'TOPLEFT',-25, 0)
                        self.point=nil
                    end
            end)

            button.itemLink=GetQuestLogSpecialItemInfo(button:GetID())--物品数量
            if button.itemLink then
                button:RegisterEvent("BAG_UPDATE")
                ItemNum(button)
                button:SetScript("OnEvent", function(_, event)
                        if event == "BAG_UPDATE" then
                            ItemNum(button)
                        end
                end)
                button:SetScript("OnShow", function()
                        button.itemLink=GetQuestLogSpecialItemInfo(button:GetID())
                        button:RegisterEvent("BAG_UPDATE")
                end)
                button:SetScript("OnHide", function()
                        button.itemLink=nil
                        button:UnregisterEvent("BAG_UPDATE")
                end)
            end
            button.setMove=true
        end
end)--Blizzard_ObjectiveTrackerShared.lua

local ObjectiveTrackerRemoveAll =function(self, tip)
    local block = self.activeFrame
    if Save.disabled or not block then
        return
    end

    local questID
    if tip=='W' then
        if block.TrackedQuest then questID=block.TrackedQuest.questID end
    else
        questID=block.id
        local info = UIDropDownMenu_CreateInfo()--放弃任务
        info.text = ABANDON_QUEST
        info.notCheckable = 1
        info.checked = false
        info.icon=Icon.x2
        if not C_QuestLog.CanAbandonQuest(questID) then info.disabled=true end--不可放弃
        info.arg1 = questID
        info.func = function(_, questID) QuestMapQuestOptions_AbandonQuest(questID) end
        UIDropDownMenu_AddButton(info)
    end
    UIDropDownMenu_AddSeparator()
    if questID then
        local info = UIDropDownMenu_CreateInfo()
        info.text = QUESTS_LABEL..' ID '..questID
        info.isTitle = 1
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info)
    end

    local info = UIDropDownMenu_CreateInfo()
    local to=C_QuestLog.GetNumQuestWatches()+C_QuestLog.GetNumWorldQuestWatches()
    info.text = REMOVE_WORLD_MARKERS..' '..to
    info.notCheckable = 1
    info.checked = false
    info.icon=Icon.clear
    if to<2 then info.disabled=true end
    info.func = function()
        local nu=C_QuestLog.GetNumQuestWatches()
        while nu>0 do
            local questID=C_QuestLog.GetQuestIDForQuestWatchIndex(1)
            if not questID then questID= C_SuperTrack.GetSuperTrackedQuestID() end
            if questID then C_QuestLog.RemoveQuestWatch(questID) end
            nu=C_QuestLog.GetNumQuestWatches()
        end
        nu=C_QuestLog.GetNumWorldQuestWatches()
        while nu>0 do
            local questID= C_QuestLog.GetQuestIDForWorldQuestWatchIndex(1)
            if questID then C_QuestLog.RemoveWorldQuestWatch(questID) end
            nu=C_QuestLog.GetNumWorldQuestWatches()
        end
    end
    UIDropDownMenu_AddButton(info)
end

hooksecurefunc('BonusObjectiveTracker_OnOpenDropDown', function(self)--ID,清除世界任务追踪
        ObjectiveTrackerRemoveAll(self,'W')
end)--Blizzard_BonusObjectiveTracker.lua

hooksecurefunc('QuestObjectiveTracker_OnOpenDropDown', function(self)--ID,清除任务追踪
        ObjectiveTrackerRemoveAll(self,'Q')
end)--Blizzard_QuestObjectiveTracker.lua

hooksecurefunc('AchievementObjectiveTracker_OnOpenDropDown', function(self)--清除所有成就追踪
        if Save.disabled then
            return
        end
        local block = self.activeFrame
        if block and block.id then
            local info = UIDropDownMenu_CreateInfo()
            info.text = ACHIEVEMENTS..' ID '..block.id
            info.icon=select(10,GetAchievementInfo(block.id))
            info.isTitle = 1
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info)
        end
        local info = UIDropDownMenu_CreateInfo()
        local trackedAchievements = { GetTrackedAchievements() }
        info.text = REMOVE_WORLD_MARKERS..' '..#trackedAchievements
        info.notCheckable = 1
        info.checked = false
        info.icon=Icon.clear
        if #trackedAchievements<2 then info.disabled=true end
        info.func = function ()
            for i = 1, #trackedAchievements do
                RemoveTrackedAchievement(trackedAchievements[i])
            end
        end
        UIDropDownMenu_AddButton(info)
end)
hooksecurefunc(mo[8], 'OnBlockHeaderClick', function(self, block, mouseButton)--清除所有专业追踪
    if mouseButton=='RightButton' then
        local recipeInfo =C_TradeSkillUI.GetRecipeInfo(block.id)
        local info = UIDropDownMenu_CreateInfo()
        info.text =((recipeInfo and recipeInfo.icon) and '|T'..recipeInfo.icon..':0|t' or '')..TRADE_SKILLS..' ID '..block.id
        info.isTitle = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info)

        info = UIDropDownMenu_CreateInfo()
        local tracked=C_TradeSkillUI.GetRecipesTracked() or {}
        info.text ='|A:'..Icon.clear..':0:0|a'..REMOVE_WORLD_MARKERS..' '..#tracked
        info.notCheckable = true
        info.checked = false
        --info.icon=Icon.clear
        if #tracked<2 then
            info.disabled=true
        end
        info.func = function ()
            for _, recipeID in pairs(tracked) do
                C_TradeSkillUI.SetRecipeTracked(recipeID, false);
            end
        end
        UIDropDownMenu_AddButton(info)
    end
end)
hooksecurefunc(mo[8], 'SetStringText', function(self, fontString, text, useFullHeight, colorStyle, useHighlight)
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
end)

local Colla=function(type)
    for _, self in pairs(mo) do
        if self and self.Header and self.Header.MinimizeButton then            
            if self.collapsed ~=type  then
                local module = self.Header.MinimizeButton:GetParent().module
                module:SetCollapsed(type)
                ObjectiveTracker_Update(0, nil, module)
                self.Header.MinimizeButton:SetCollapsed(type)
            end
        end
    end
end

local function Scale(setPrint)
    if Save.disabled then
        return
    end
    if Save.scale<0.5 then Save.scale=0.5 elseif Save.scale>1.5 then Save.scale=1.5 end
    F:SetScale(Save.scale)
    if setPrint then
        print(addName..': '..UI_SCALE..' |cff00ff00'..Save.scale..'|r')
    end
end

local function Alpha(setPrint)
    if Save.disabled then
        return
    end
    if Save.alpha<0.3 then Save.alpha=0.3 elseif Save.alpha>1 then Save.alpha=1 end
    F:SetAlpha(Save.alpha)
    if setPrint then
        print(addName..' ('..CHANGE_OPACITY..'0.1 - 1): |cff00ff00'..Save.alpha..'|r')
    end
end

--任务颜色
local function setColor(block, questID)
    questID=questID or block.id
    if Save.disabled or not block or not questID or C_QuestLog.IsFailed(questID) then
        return
    end
    local r, g, b=block.r, block.g, block.b
    if not r or not g or not b then
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
                --    line.Text.colorStyle = {r=block.r, g=block.g, b=block.b}
                line.Text:SetTextColor(block.r, block.g, block.b)
            end
        end
    end
    block.r =r
    block.g=g
    block.b=b
end

hooksecurefunc(QUEST_TRACKER_MODULE,'SetBlockHeader', function(self, block, text, questLogIndex, isQuestComplete, questID)--任务颜色 图标
    if Save.disabled then
        return
    end
    local m=''
    block.r, block.g, block.b=nil, nil, nil
    if questID then
        if C_QuestLog.IsComplete(questID) then m=m..e.Icon.select2 elseif C_QuestLog.IsFailed(questID) then m=m.e.Icon.X2 end
        local factionGroup = GetQuestFactionGroup(questID)
        if factionGroup == LE_QUEST_FACTION_HORDE then
            m=m..e.Icon.horde2
            if factionGroup == LE_QUEST_FACTION_ALLIANCE then
                m=m.e.Icon.alliance2
            end
        end
        if  C_QuestLog.IsQuestCalling(questID) then--使命
            m=m..Icon.campa
            block.r, block.g, block.b=Color.Calling[1],Color.Calling[2],Color.Calling[3]
        end
        if C_QuestLog.IsAccountQuest(questID) then m=m..e.Icon.wow2 end--帐户
        if C_QuestLog.IsLegendaryQuest(questID) then
            m=m..Icon.legend
            block.r, block.g, block.b=Color.Legendary[1],Color.Legendary[2],Color.Legendary[3]
        end--传奇                            
    end
    if questLogIndex then
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info then
            if info.startEvent then--事件开始
                m=m..Icon.start
            end
            if info.frequency then
                if info.frequency==Enum.QuestFrequency.Daily then--日常
                    m=m..Icon.day
                    block.r, block.g, block.b=Color.Day[1],Color.Day[2],Color.Day[3]
                elseif info.frequency==Enum.QuestFrequency.Weekly then--周常
                    m=m..Icon.week
                    block.r, block.g, block.b= Color.Week[1], Color.Week[2], Color.Week[3]
                end
            end
            if info.isOnMap then
                m=m..e.Icon.map2
            end
            if info.level and info.level ~= MAX_PLAYER_LEVEL then
                m=m..'['..info.level..']'
            end
        end
    end
    setColor(block, questID)
    if m~='' then block.HeaderText:SetText(m..text) end
end)
hooksecurefunc(QUEST_TRACKER_MODULE, 'OnBlockHeaderLeave', function(self ,block)
        setColor(block, block.id)
end)
hooksecurefunc('QuestObjectiveTracker_DoQuestObjectives', function(self, block, questCompleted, questSequenced, existingBlock, useFullHeight)
        setColor(block)
end)


local function hideTrecker()--挑战,进入FB时, 隐藏Blizzard_ObjectiveTracker.lua
    if not Save.autoHide then
        return
    end
    local ins=IsInInstance()--local sc=C_Scenario.IsInScenario();   
    if ins then
        for index, self in pairs(mo) do
            if index>2 and self and self.Header and self.Header.MinimizeButton then
                if not self.collapsed  then
                    --local module = self.Header.MinimizeButton:GetParent().module;
                    self:SetCollapsed(true);
                    ObjectiveTracker_Update(0, nil, self);
                    self.Header.MinimizeButton:SetCollapsed(true);
                    self.setColla=true;
                end
            end
        end
    else
        for index, self in pairs(mo) do
            if index>2 and self and self.Header and self.Header.MinimizeButton then 
                if self.setColla then
                    if self.collapsed  then
                        self:SetCollapsed(false);
                        ObjectiveTracker_Update(0, nil, self);
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
    if Save.disabled then
        return
    end
    F:SetMovable(true)
    F:EnableMouse(true)
    btn:RegisterForDrag("RightButton")
    btn:SetScript("OnDragStart", function() F:StartMoving() end)    
    btn:SetScript("OnDragStop", function() 
            ResetCursor()
            F:StopMovingOrSizing()
    end)
    btn:SetScript("OnMouseUp", function(self,D) ResetCursor() end)        
    btn:SetScript("OnMouseDown", function(self,d) if d=='RightButton' and not IsAltKeyDown() then SetCursor('UI_MOVE_CURSOR') end end)
    btn:SetScript("OnLeave", function(self) ResetCursor() e.tips:Hide() end)
    btn:SetScript("OnEnter",function(self)
            if UnitAffectingCombat('player') then return end
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine(SHOW..'/'..HIDE, e.Icon.mid)
            e.tips:AddDoubleLine(UI_SCALE..': '..Save.scale, 'Ctrl + '..e.Icon.mid)
            e.tips:AddDoubleLine(CHANGE_OPACITY..': '..Save.alpha, 'Shift + '..e.Icon.mid)
            e.tips:Show()
    end)
    btn:SetScript('OnMouseWheel',function(self,d)
        if d == 1 and not IsModifierKeyDown() then
            Colla(true)
            print(addName..': '..RED_FONT_COLOR_CODE..HIDE..'|r'..ALL)
        elseif d == -1 and not IsModifierKeyDown() then
            Colla()
            print(addName..': |cff00ff00'..SHOW..'|r'..ALL)
        elseif d==1 and IsControlKeyDown() then
            Save.scale=Save.scale+0.05
            Scale(true)
        elseif d==-1 and IsControlKeyDown() then
            Save.scale=Save.scale-0.05
            Scale(true)
        elseif d==1 and IsShiftKeyDown() then
            Save.alpha=Save.alpha+0.1
            Alpha(true)
        elseif d==-1 and IsShiftKeyDown() then
            Save.alpha=Save.alpha-0.1
            Alpha(true)
        end
    end)
end
--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("PLAYER_ENTERING_WORLD")
panel:RegisterEvent("CHALLENGE_MODE_START")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

        --添加控制面板        
        local sel=e.CPanel(addName, not Save.disabled)
        sel:SetScript('OnClick', function()
            if Save.disabled then
                Save.disabled=nil
            else
                Save.disabled=true
            end
            print(id, addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
        end)
        local sel2=CreateFrame("CheckButton", nil, sel, "InterfaceOptionsCheckButtonTemplate")
        sel2.Text:SetText(AUTO_JOIN:gsub(JOIN, '')..HIDE)
        sel2:SetPoint('LEFT', sel.Text, 'RIGHT')
        sel2:SetChecked(Save.autoHide)
        sel2:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(SCENARIOS, '...')
            e.tips:AddDoubleLine('UI WIDGET', '...')
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(SCENARIO_BONUS_OBJECTIVES, e.GetShowHide(false))
            e.tips:AddDoubleLine(TRACKER_HEADER_WORLD_QUESTS, e.GetShowHide(false))
            e.tips:AddDoubleLine(TRACKER_HEADER_CAMPAIGN_QUESTS, e.GetShowHide(false))
            e.tips:AddDoubleLine(TRACK_QUEST, e.GetShowHide(false))
            e.tips:AddDoubleLine(TRACKING..ACHIEVEMENTS, e.GetShowHide(false))
            e.tips:AddDoubleLine(PROFESSIONS_TRACK_RECIPE, e.GetShowHide(false))
            e.tips:Show()
        end)
        sel2:SetScript('OnLeave', function() e.tips:Hide() end)
        Init()
        sel2:SetScript('OnClick', function ()
            if Save.autoHide then
                Save.autoHide=nil
            else
                Save.autoHide=true
            end
            print(id, addName, AUTO_JOIN:gsub(JOIN, '')..HIDE, QUEST_OBJECTIVES,e.GetEnabeleDisable(Save.autoHide))
        end)

        if Save.scale~=1 then Scale() end--缩放
        if Save.alpha~=1 then Alpha() end--透明度
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='PLAYER_ENTERING_WORLD' or event=='CHALLENGE_MODE_START' then--隐藏
        hideTrecker()
    end
end)