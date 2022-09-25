local id, e = ...
local addName=QUEST_OBJECTIVES
local Save={scale= 1, alpha=1, autoHide=true}
local F=ObjectiveTrackerFrame--移动任务框
local btn=ObjectiveTrackerFrame.HeaderMenu.MinimizeButton

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
hooksecurefunc(PROFESSION_RECIPE_TRACKER_MODULE, 'OnBlockHeaderClick', function(self, block, mouseButton)--清除所有专业追踪
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
end)


local mo={
    SCENARIO_CONTENT_TRACKER_MODULE,
    UI_WIDGET_TRACKER_MODULE,
    BONUS_OBJECTIVE_TRACKER_MODULE,
    WORLD_QUEST_TRACKER_MODULE,--世界任务
    CAMPAIGN_QUEST_TRACKER_MODULE,--战役
    QUEST_TRACKER_MODULE,
    ACHIEVEMENT_TRACKER_MODULE,
    PROFESSION_RECIPE_TRACKER_MODULE,
}
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

local function Scale()
    if Save.disabled then
        return
    end
    if Save.scale<0.5 then Save.scale=0.5 elseif Save.scale>1.5 then Save.scale=1.5 end
    F:SetScale(Save.scale)
    print(addName..': '..UI_SCALE..' |cff00ff00'..Save.scale..'|r')
end

local function Alpha()
    if Save.disabled then
        return
    end
    if Save.alpha<0.3 then Save.alpha=0.3 elseif Save.alpha>1 then Save.alpha=1 end
    F:SetAlpha(Save.alpha)
    print(addName..' ('..CHANGE_OPACITY..'0.1 - 1): |cff00ff00'..Save.alpha..'|r')
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

--任务日志
local Code=IN_GAME_NAVIGATION_RANGE:gsub('d','s')--%s码    
local Quest=function(self, questID)--任务
    if not HaveQuestData(questID) then return end
    local t=''
    local lv=C_QuestLog.GetQuestDifficultyLevel(questID)--ID
    if lv then t=t..'['..lv..']' else t=t..' 'end
    if C_QuestLog.IsComplete(questID) then t=t..'|cFF00FF00'..COMPLETE..'|r' else t=t..INCOMPLETE end
    if t=='' then t=t..QUESTS_LABEL end    
    t=t..' ID:'
    self:AddDoubleLine(t, questID)

    local distanceSq= C_QuestLog.GetDistanceSqToQuest(questID)--距离
    if distanceSq then
        t= TRACK_QUEST_PROXIMITY_SORTING..': '
        local _, x, y = QuestPOIGetIconInfo(questID)
        if x and y then
            x=math.modf(x*100) y=math.modf(y*100)
            if x and y then t=t..x..', '..y end
        end
        self:AddDoubleLine(t,  Code:format(e.MK(distanceSq)))
    end

    if IsInGroup() then
        if C_QuestLog.IsPushableQuest(questID) then t='|cFF00FF00'..YES..'|r' else t=NO end--共享
        local t2=SHARE_QUEST..': '
        local u if IsInRaid() then u='raid' else u='party' end
        local n,acceto=GetNumGroupMembers(), 0
        for i=1, n do
            local u2
            if u=='party' and i==n then u2='player' else u2=u..i end
            if C_QuestLog.IsUnitOnQuest(u2, questID) then acceto=acceto+1 end            
        end
        t2=t2..acceto..'/'..n
        self:AddDoubleLine(t2, t)
    end

    local all=C_QuestLog.GetAllCompletedQuestIDs()--完成次数
    if all and #all>0 then
        t= GetDailyQuestsCompleted() or '0'
        t=t..DAILY..' '..#all..QUESTS_LABEL
        self:AddDoubleLine(TRACKER_FILTER_COMPLETED_QUESTS..': ', t)
    end
    --local info=C_QuestLog.GetQuestDetailsTheme(questID)--POI图标
    --if info and info.poiIcon then e.playerTexSet(info.poiIcon, nil) end--设置图,像

    self:Show()
end

hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)--任务日志 显示ID
        if Save.disabled or not self.questLogIndex then
            return
        end
        local info = C_QuestLog.GetInfo(self.questLogIndex)
        if not info or not info.questID then return end
        Quest(e.tips, info.questID)
end)

local function Coll()
    for i=1, C_QuestLog.GetNumQuestLogEntries() do
        CollapseQuestHeader(i)
    end
end
local function Exp()
    for i=1, C_QuestLog.GetNumQuestLogEntries() do
        ExpandQuestHeader(i)
    end
end

hooksecurefunc('QuestMapLogTitleButton_OnClick',function(self, button)--任务日志 展开所有, 收起所有
        if Save.disabled or ChatEdit_TryInsertQuestLinkForQuestID(self.questID) then
            return
        end
        if not C_QuestLog.IsQuestDisabledForSession(self.questID) and button == "RightButton" then
            UIDropDownMenu_AddSeparator()
            local info= UIDropDownMenu_CreateInfo()
            info.notCheckable=true
            info.text=SHOW..'|A:campaign_headericon_open:0:0|a'..ALL
            info.func=function()
                Exp()
            end
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info = UIDropDownMenu_CreateInfo()
            info.notCheckable=true
            info.text=HIDE..'|A:campaign_headericon_closed:0:0|a'..ALL
            info.func=function()
                Coll()
            end
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)            
        end
end)--QuestMapFrame.lua

--世界地图任务
hooksecurefunc(WorldQuestPinMixin, 'RefreshVisuals', function(S)
    local questID =S and S.questID
    local self=S and S.Texture
    if Save.disabled or not questID or not self then
        return
    end
    local mago=nil--幻化
    local lv = GetQuestLogRewardMoney(questID)
    if lv ==0 then
        lv=nil
    elseif lv and lv>10000 then
        lv=e.Player.col..('%i'):format(lv/10000)..'|r'
        self:SetAtlas('Front-Gold-Icon')
        self:SetSize(40, 40)
    else
        local _, icon, num, quality, _, itemID, lv2 = GetQuestLogRewardInfo(1, questID)
        if not icon then
            _, icon, num, quality, _, _, lv2=GetQuestLogRewardCurrencyInfo(1, questID)
        elseif itemID then--物品
            local classID = select(6, GetItemInfoInstant(itemID))--幻化                    
            if (classID==2 or classID==4 ) then
                if not  C_TransmogCollection.PlayerHasTransmog(itemID) then                                
                    local sourceID=select(2,C_TransmogCollection.GetItemInfo(itemID))
                    if sourceID then 
                        local hasItemData, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID)
                        if hasItemData and canCollect then
                            local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
                            if sourceInfo and not sourceInfo.isCollected then
                                mago=true
                            end
                        end
                    end
                end
            end
        end
        if icon then
            self:SetTexture(icon)
            self:SetSize(40, 40)
        end
        lv=lv2
        if lv and lv<=1 then lv=num end
        if lv and lv <=1 then lv=nil end
        if lv then
            if quality then
                local hex=select(4, GetItemQualityColor(quality))
                if hex then lv='|c'..hex..lv..'|r' end
            end
        end
    end
    if lv then
        if not S.Str then
            S.Str=e.Cstr(S)
            S.Str:SetPoint('TOP', self, 'BOTTOM', 0, 0)
        end
        S.Str:SetText(lv)
    elseif S.Str then
        S.Str:SetText('')
    end
    local t2=C_TaskQuest.GetQuestTimeLeftSeconds(questID)
    if t2 and t2 >0 then
        local s,t=SecondsToTimeAbbrev(t2)
        t=s:format(t)
        if not S.Tim then
            S.Tim= e.Cstr(S)
            S.Tim:SetPoint('BOTTOM', self, 'TOP', 0, -2)
        end
        S.Tim:SetText(t)
    elseif S.Tim then
        S.Tim:SetText('')
    end
    if mago then--幻化
        if not self.mago then
            self.mago=S:CreateTexture()
            self.mago:SetSize(40, 40)
            self.mago:SetPoint('RIGHT', self, 'LEFT', 20,0)
            self.mago:SetAtlas(e.Icon.transmog)
        end
    end
    if self.mago then
        self.mago:SetShown(mago)
    end
end)--WorldQuestDataProvider.lua

local function hideTrecker()--挑战,进入FB时, 隐藏Blizzard_ObjectiveTracker.lua
    if not Save.autoHide then
        return
    end
    local ins=IsInInstance()--local sc=C_Scenario.IsInScenario();   
    if ins then
        for _, self in pairs(mo) do
            if self and self.Header and self.Header.MinimizeButton then 
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
        for _, self in pairs(mo) do
            if self and self.Header and self.Header.MinimizeButton then 
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

local function Ini()
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
            Scale()
        elseif d==-1 and IsControlKeyDown() then
            Save.scale=Save.scale-0.05
            Scale()
        elseif d==1 and IsShiftKeyDown() then
            Save.alpha=Save.alpha+0.1
            Alpha()
        elseif d==-1 and IsShiftKeyDown() then
            Save.alpha=Save.alpha-0.1
            Alpha()
        end
    end)

    local f=QuestScrollFrame--世界地图,任务, 加 - + 按钮
    f.btn= CreateFrame("Button", nil, f)
    f.btn:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
    f.btn:SetSize(20,20)
    f.btn:SetNormalAtlas('campaign_headericon_open')
    f.btn:SetPushedAtlas('campaign_headericon_openpressed')
    f.btn:SetHighlightAtlas('Forge-ColorSwatchSelection')
    f.btn:SetScript("OnMouseDown", function()
            Exp()
    end)
    f.btn:SetFrameStrata('DIALOG')

    f.btn2= CreateFrame("Button", nil, f.btn)
    f.btn2:SetPoint('BOTTOMRIGHT', f.btn, 'BOTTOMLEFT', 2, 0)
    f.btn2:SetSize(20,20)
    f.btn2:SetNormalAtlas('campaign_headericon_closed')
    f.btn2:SetPushedAtlas('campaign_headericon_closedpressed')
    f.btn2:SetHighlightAtlas('Forge-ColorSwatchSelection')
    f.btn2:SetScript("OnMouseDown", function()
            Coll()
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
        Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
        --添加控制面板        
        local sel=e.CPanel(addName, not Save.disabled)
        sel:SetScript('OnClick', function()
            if Save.disabled then
                Save.disabled=nil
            else
                Save.disabled=true
            end
            print(addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
        end)
        local sel2=CreateFrame("CheckButton", nil, sel, "InterfaceOptionsCheckButtonTemplate")
        sel2.Text:SetText(GX_ADAPTER_AUTO_DETECT..HIDE)
        sel2:SetPoint('LEFT', sel.Text, 'RIGHT')
        sel2:SetChecked(Save.autoHide)

        Ini()
sel2:SetScript('OnClick', function ()
    if Save.autoHide then
        Save.autoHide=nil
    else
        Save.autoHide=true
    end
    print(GX_ADAPTER_AUTO_DETECT,HIDE, QUEST_OBJECTIVES,e.GetEnabeleDisable(Save.autoHide))
end)

        if Save.scale~=1 then Scale() end--缩放
        if Save.alpha~=1 then Alpha() end--透明度
    elseif event == "PLAYER_LOGOUT" then
        if not WoWToolsSave then WoWToolsSave={} end
		WoWToolsSave[addName]=Save

    elseif event=='PLAYER_ENTERING_WORLD' or event=='CHALLENGE_MODE_START' then--隐藏
        hideTrecker()
    end
end)