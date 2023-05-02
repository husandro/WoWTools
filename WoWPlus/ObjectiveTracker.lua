local id, e = ...
local addName=	TRACK_QUEST
local Save={scale= 0.85, alpha=1, autoHide=true}
--local F=ObjectiveTrackerFrame--移动任务框
--local btn=ObjectiveTrackerFrame.HeaderMenu.MinimizeButton

local ModulTab={--Blizzard_ObjectiveTracker.lua
    'SCENARIO_CONTENT_TRACKER_MODULE',--1 场景战役 SCENARIOS
    'UI_WIDGET_TRACKER_MODULE',--2
    'BONUS_OBJECTIVE_TRACKER_MODULE',--3 	奖励目标 SCENARIO_BONUS_OBJECTIVES
    'WORLD_QUEST_TRACKER_MODULE',--4世界任务 TRACKER_HEADER_WORLD_QUESTS
    'CAMPAIGN_QUEST_TRACKER_MODULE',--5战役 TRACKER_HEADER_CAMPAIGN_QUESTS
    'QUEST_TRACKER_MODULE',--6 	追踪任务 TRACK_QUEST
    'ACHIEVEMENT_TRACKER_MODULE',--7 追踪成就 TRACKING..
    'PROFESSION_RECIPE_TRACKER_MODULE',--8 追踪配方 PROFESSIONS_TRACK_RECIPE
    'MONTHLY_ACTIVITIES_TRACKER_MODULE',--9
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
    day='|A:UI-DailyQuestPoiCampaign-QuestBang:10:10|a',
    legend='|A:questlegendary:10:10|a',
    week='|A:weeklyrewards-orb-unlocked:10:10|a',
    start='|A:vignetteevent:10:10|a',
    campa='|A:campaignavailabledailyquesticon:10:10|a',
    x2='Interface\\AddOns\\WeakAuras\\Media\\Textures\\cancel-icon.tga',
    clear='bags-button-autosort-up'
}



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

local function Alpha(setPrint)
    if Save.alpha<0.3 then
        Save.alpha=0.3
    elseif Save.alpha>1 then
         Save.alpha=1
    end
    ObjectiveTrackerFrame:SetAlpha(Save.alpha)
    if setPrint then
        print(id, addName, e.onlyChinese and '改变透明度' or CHANGE_OPACITY, '(0.1 - 1)', '|cnGREEN_FONT_COLOR:'..Save.alpha)
    end
end

--任务颜色
local function setColor(block, questID)
    questID=questID or block.id
    if not block or not questID or C_QuestLog.IsFailed(questID) then
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

    hooksecurefunc(PROFESSION_RECIPE_TRACKER_MODULE, 'SetStringText', function(self, fontString, text, useFullHeight, colorStyle, useHighlight)
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

    hooksecurefunc('QuestObjectiveSetupBlockButton_AddRightButton', function(block, button)--物品按钮左边,放大 --Blizzard_ObjectiveTrackerShared.lua
        if not button or not block or not button:IsShown()  or block.groupFinderButton == button or button.setMove then
            return
        end

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
                    e.tips:AddDoubleLine(e.onlyChinese and '追踪成就' or (TRACKING..ACHIEVEMENTS), text)
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


--[[
    local ObjectiveTrackerRemoveAll =function(self, tip)
        local block = self.activeFrame
        if not block then
            return
        end
        local questID= tip=='Q' and block.id or block.TrackedQuest and block.TrackedQuest.questID
        if not questID then
            return
        end
    
        local info
        if tip=='Q' then
            info={
                text = e.onlyChinese and '放弃任务' or ABANDON_QUEST,
                notCheckable = 1,
                icon= Icon.x2,
                disabled= not C_QuestLog.CanAbandonQuest(questID),
                arg1 = questID,
                func = function(_, arg1)
                    QuestMapQuestOptions_AbandonQuest(arg1)--QuestMapFrame.lua
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info)
        end
        e.LibDD:UIDropDownMenu_AddSeparator()
        local verText, verLevel=e.GetExpansionText(nil, questID)--任务版本
        if verLevel and verText then
            info={
                text=verText..' '..verLevel,
                isTitle=true,
                notCheckable=true,
            }
            e.LibDD:UIDropDownMenu_AddButton(info)
        end
        local text
    
        info={
            text = (e.onlyChinese and '任务' or QUESTS_LABEL)..' '..questID..'  '..(e.onlyChinese and '等级' or LEVEL)..' '.. C_QuestLog.GetQuestDifficultyLevel(questID),
            isTitle = true,
            notCheckable = true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info)
    
        info = {}
        local totaleQest= C_QuestLog.GetNumQuestWatches()+C_QuestLog.GetNumWorldQuestWatches()
        info={
            text = (e.onlyChinese and '全部清除' or REMOVE_WORLD_MARKERS)..' '..totaleQest,
            notCheckable = true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '任务 +' or (QUESTS_LABEL..' +'),
            tooltipText= e.onlyChinese and '世界任务' or TRACKER_HEADER_WORLD_QUESTS,
            icon=Icon.clear,
            colorCode= totaleQest==0 and '|cff606060',
            func = function()
                local nu=C_QuestLog.GetNumQuestWatches()
                while nu>0 do
                    questID=C_QuestLog.GetQuestIDForQuestWatchIndex(1)
                    if not questID then questID= C_SuperTrack.GetSuperTrackedQuestID() end
                    if questID then
                        C_QuestLog.RemoveQuestWatch(questID)
                    end
                    nu=C_QuestLog.GetNumQuestWatches()
                end
                nu=C_QuestLog.GetNumWorldQuestWatches()
                while nu>0 do
                    questID= C_QuestLog.GetQuestIDForWorldQuestWatchIndex(1)
                    if questID then
                        C_QuestLog.RemoveWorldQuestWatch(questID)
                    end
                    nu=C_QuestLog.GetNumWorldQuestWatches()
                end
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info)
    end
    hooksecurefunc('BonusObjectiveTracker_OnOpenDropDown', function(self)--ID,清除世界任务追踪
        ObjectiveTrackerRemoveAll(self,'W')
    end)--Blizzard_BonusObjectiveTracker.lua

    hooksecurefunc('QuestObjectiveTracker_OnOpenDropDown', function(self)--ID,清除任务追踪
        ObjectiveTrackerRemoveAll(self,'Q')
    end)--Blizzard_QuestObjectiveTracker.lua

    hooksecurefunc('AchievementObjectiveTracker_OnOpenDropDown', function(self)--清除所有成就追踪
        local block = self.activeFrame
        if block and block.id then
            local info = {}
            info.text = (e.onlyChinese and '成就 ' or ACHIEVEMENTS)..' '..block.id
            info.icon=select(10,GetAchievementInfo(block.id))
            info.isTitle = 1
            info.notCheckable = 1
            e.LibDD:UIDropDownMenu_AddButton(info)
        end
        local info = {}
        local trackedAchievements = { GetTrackedAchievements() }
        info.text = (e.onlyChinese and '全部清除' or REMOVE_WORLD_MARKERS)..' '..#trackedAchievements
        info.notCheckable = 1
        info.checked = false
        info.icon=Icon.clear
        if #trackedAchievements<2 then info.disabled=true end
        info.func = function ()
            for i = 1, #trackedAchievements do
                RemoveTrackedAchievement(trackedAchievements[i])
            end
        end
        e.LibDD:UIDropDownMenu_AddButton(info)
    end)
    hooksecurefunc(PROFESSION_RECIPE_TRACKER_MODULE, 'OnBlockHeaderClick', function(self, block, mouseButton)--清除所有专业追踪
        if mouseButton=='RightButton' then
            local recipeInfo =C_TradeSkillUI.GetRecipeInfo(block.id)
            local info = {}
            info.text =((recipeInfo and recipeInfo.icon) and '|T'..recipeInfo.icon..':0|t' or '')..(e.onlyChinese and '专业' or TRADE_SKILLS)..' '..block.id
            info.isTitle = true
            info.notCheckable = true
            e.LibDD:UIDropDownMenu_AddButton(info)

            info = {}
            local tracked=C_TradeSkillUI.GetRecipesTracked() or {}
            info.text ='|A:'..Icon.clear..':0:0|a'..(e.onlyChinese and '全部清除' or REMOVE_WORLD_MARKERS)..' '..#tracked
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
            e.LibDD:UIDropDownMenu_AddButton(info)
        end
    end)
]]