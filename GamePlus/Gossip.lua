local id, e = ...
local addName=GOSSIP_OPTIONS:gsub(SETTINGS_TITLE,'')

local Save={gossip=true, qest=true, Option={}, NPC={},}

local Icon={
    TrivialQuests='|A:TrivialQuests:0:0|a',
}

--[[local function Cbtn(self)
    local b=CreateFrame("Button",nil, self)
    b:SetSize(20, 20)
    b:SetHighlightAtlas(Icon.setHighlightAtlas)
    b:SetPushedAtlas(Icon.setPushedAtlas)
    return b
end]]

local q=e.Cbtn(ObjectiveTrackerBlocksFrame, nil,nil,nil,nil, true);--任务图标
local g=e.Cbtn(ObjectiveTrackerBlocksFrame, nil,nil,nil,nil, true);--闲话图标
q:SetSize(20,20)
g:SetSize(20,20)
g:SetPoint('RIGHT', q, 'LEFT', -2, 0)

--设置图标
local function setTexture()
    if Save.qest then
        q:SetNormalAtlas('campaignavailablequesticon')
    else
        q:SetNormalAtlas(e.Icon.icon)
    end
    if Save.gossip then
       g:SetNormalAtlas('transmog-icon-chat')
    else
        g:SetNormalAtlas(e.Icon.icon)
    end
end
local function setParent()--设置父级
    if not Save.point and ObjectiveTrackerBlocksFrame then
        q:SetParent(ObjectiveTrackerBlocksFrame)
        g:SetParent(ObjectiveTrackerBlocksFrame)
    else
        q:SetParent(UIParent)
        g:SetParent(UIParent)
    end
end

--################
--闲话选项
--################

--禁用此npc闲话选项
GossipFrame:SetScript('OnShow', function (self)
    if not self.sel then
        self.sel=CreateFrame("CheckButton", nil, GossipFrame, 'InterfaceOptionsCheckButtonTemplate')
        self.sel:SetPoint("BOTTOMLEFT",5,2)
        self.sel.Text:SetText(DISABLE)
        self.sel:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        self.sel:SetScript("OnClick", function (self2, d)
            if not self2.npc then
                return
            end
            if d=='LeftButton' then

                    if Save.NPC[self2.npc] then
                        Save.NPC[self2.npc]=nil
                    else
                        Save.NPC[self2.npc]=self2.name or true
                    end
                    print(GOSSIP_OPTIONS..(self2.name and '|cffff00ff'..self2.name..'|r' or '')..': '..(Save.NPC[self2.npc] and RED_FONT_COLOR_CODE..DISABLE..'|r' or GREEN_FONT_COLOR_CODE..ENABLE..'|r'))

            elseif d=='RightButton' then
                StaticPopupDialogs['husandro']={
                    text =CLEAR_ALL..'|n|n|cffff00ff'..(self2.name or self2.npc)..'|r|n|n'..GOSSIP_OPTIONS..': '..CUSTOM,
                    button1 =CLEAR or KEY_NUMLOCK_MAC,
                    button2 = CANCEL,
                    OnAccept=function()
                        local n=0
                        for k,v in pairs(Save.Option) do
                            if v and v.npcid==self2.npc then
                                Save.Option[k]=nil
                                n=n+1
                            end
                       end
                       print(CLEAR_ALL..' (|cffff00ff'..(self2.name or self2.npc)..'|r)'..CUSTOM..': '..GREEN_FONT_COLOR_CODE..n..' |r'..GOSSIP_OPTIONS)
                    end,
                    whileDead=true,timeout=10,hideOnEscape = true,}
                StaticPopup_Show('husandro');
                self2:SetChecked(Save.NPC[self2.npc]);
            end
        end)
        self.sel:SetScript('OnEnter',function (self2)
            if self2.npc then
                e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                e.tips:ClearLines()

                e.tips:AddDoubleLine((self2.name and self2.name..' ' or ''), 'npc ID: '..self2.npc)
                e.tips:AddDoubleLine(DISABLE..' NPC', e.GetEnabeleDisable(not Save.NPC[self2.npc])..e.Icon.left)
                e.tips:AddDoubleLine(CLEAR_ALL, e.Icon.right)
                e.tips:AddDoubleLine(' ')
                e.tips:AddDoubleLine(GOSSIP_OPTIONS, e.GetEnabeleDisable(Save.gossip))
                e.tips:Show()
            end
        end)
        self.sel:SetScript("OnLeave", function() e.tips:Hide() end)
    end
    local npc=e.GetNpcID('npc')
    self.sel.npc=npc
    self.sel.name=UnitName("npc")
    self.sel:SetChecked(Save.NPC[npc])
    GossipFrame.sel:SetShown(npc)
end)

--自定义闲话选项
hooksecurefunc(GossipOptionButtonMixin, 'Setup', function(self, info)--GossipFrameShared.lua
    if not info.gossipOptionID then
        if self.sel then self.sel:Hide() end
        return
    end
    if not self.sel then
        self.sel=CreateFrame("CheckButton", nil, self, 'InterfaceOptionsCheckButtonTemplate')
        self.sel:SetPoint("RIGHT", -2, 0)
        self.sel:SetSize(18, 18)
        self.sel:SetScript("OnEnter", function(self2)
            if self2.info.gossipOptionID then
                e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(self2.name, self2.npc and 'npc ID: '..self2.npc or '')
                e.tips:AddDoubleLine(self2.info.name, 'gossipOptionID: '..self2.info.gossipOptionID)
                e.tips:AddDoubleLine(' ')
                e.tips:AddDoubleLine(CUSTOM, e.GetEnabeleDisable(Save.Option[self2.info.gossipOptionID]))
                e.tips:AddDoubleLine(self2.name, e.GetEnabeleDisable(not Save.NPC[self2.npc]))
                e.tips:AddDoubleLine(GOSSIP_OPTIONS, e.GetEnabeleDisable(Save.gossip))
                e.tips:Show()
            end
        end)
        self.sel:SetScript("OnLeave", function ()
            e.tips:Hide()
        end)
        self.sel:SetScript("OnClick", function (self2)
            if Save.Option[self2.info.gossipOptionID] then
                Save.Option[self2.info.gossipOptionID]=nil
            else
                Save.Option[self2.info.gossipOptionID]={
                    name=self2.name,
                    npcid=self2.npc,
                    --gossip=self2.info.name
                }
                C_GossipInfo.SelectOption(self:GetID())
            end
        end)
    end

    local npc=e.GetNpcID('npc')
    self.sel.npc=npc
    self.sel.name=UnitName("npc")
    self.sel.info=info
    self.sel:SetChecked(Save.Option[info.gossipOptionID])
    self.sel:SetShown(true)
    if IsModifierKeyDown() or not Save.gossip or (npc and Save.NPC[npc]) then
        return
    end
    if Save.Option[info.gossipOptionID]  then
        print(GREEN_FONT_COLOR_CODE..GOSSIP_OPTIONS..' |r(Alt '..RED_FONT_COLOR_CODE..DISABLE..'|r): |cffff00ff'..(self.sel.name or '')..'|r')
        local text=C_GossipInfo.GetText()--内容
        if text then print(YELLOW_FONT_COLOR_CODE..text..'|r') end
        local icon=self.Icon:GetTexture()--图标
        local spell=self.spellID and GetSpellLink(self.spellID) or ''
        print((icon and '|T'..icon..':0|t' or '')..'|cnBRIGHTBLUE_FONT_COLOR:'..info.name..'|r'..spell)--选项信息
        C_GossipInfo.SelectOption(self:GetID())
    end
end)

--hooksecurefunc(GossipFrame, 'Update', function()
--对话图标

g:SetScript('OnClick', function(self, d)
    if d=='LeftButton' and not IsModifierKeyDown() then
        if Save.gossip then
            Save.gossip=nil
        else
            Save.gossip=true
        end
        print(GOSSIP_OPTIONS..': '..e.GetEnabeleDisable(Save.gossip))
        setTexture()
    elseif d=='LeftButton' and IsAltKeyDown() then--清除自定义闲话选       
        StaticPopupDialogs['husandro']={
            text =CLEAR_ALL..'|n|n'..GOSSIP_OPTIONS,
            button1 =CLEAR or KEY_NUMLOCK_MAC,
            button2 = CANCEL,
            OnAccept=function(s)
                Save.Option={}
                Save.NPC={}
                print('('..GOSSIP_OPTIONS..') '..CLEAR_ALL..": "..GREEN_FONT_COLOR_CODE..COMPLETE..'|r|n/reload: '..GREEN_FONT_COLOR_CODE..SAVE..'|r')
            end,
            whileDead=true,timeout=10,hideOnEscape = true,}
        StaticPopup_Show('husandro');
    end
end)
g:SetScript('OnEnter', function(self2)
    local n=0
    for k,_ in pairs(Save.Option) do
        if k then
            n=n+1
        end
    end
    for k,_ in pairs(Save.NPC) do
        if k then
            n=n+1
        end
    end
    e.tips:SetOwner(self2, "ANCHOR_LEFT")    
    e.tips:ClearLines()
    e.tips:AddDoubleLine(id, addName)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(GOSSIP_OPTIONS, e.GetEnabeleDisable(Save.gossip)..e.Icon.left)
    e.tips:AddDoubleLine(CLEAR_ALL, n..' Alt+'..e.Icon.left)
    e.tips:Show()
end)
g:SetScript('OnLeave', function ()
    e.tips:Hide()
end)

--#######
--任务图标
--#######
local isQuestTrivialTracking--其它任务,低等任务,追踪
local function GetIsQuestTrivialTracking()
    for trackingID=1, C_Minimap.GetNumTrackingTypes() do
        name, texture, active, category, nested = C_Minimap.GetTrackingInfo(trackingID)
        if name==MINIMAP_TRACKING_TRIVIAL_QUESTS then
            isQuestTrivialTracking = active
            break
        end
    end
end

local function getQuestTrivial(questID)--其它任务,低等任务
    questID=questID or QuestInfoFrame.questLog and C_QuestLog.GetSelectedQuest() or GetQuestID()--取得任务ID
    if questID then
        local trivial=C_QuestLog.IsQuestTrivial(questID)
        return (trivial and isQuestTrivialTracking) or not trivial
    end
end

local function getMaxQuest()--任务，是否已满
    return select(2,C_QuestLog.GetNumQuestLogEntries())==C_QuestLog.GetMaxNumQuestsCanAccept()
end

QuestFrameGreetingPanel:HookScript('OnShow', function()--QuestFrame.lua QuestFrameGreetingPanel_OnShow
    if not Save.qest or IsModifierKeyDown() or getMaxQuest() then
        return
    end
    local numActiveQuests = GetNumActiveQuests();
	local numAvailableQuests = GetNumAvailableQuests();
    if numActiveQuests > 0 then
        for i=1, numActiveQuests do
			local title, isComplete = GetActiveTitle(i);
            if isComplete then
                SelectActiveQuest(i)
                return
            end
        end
    end
    if numAvailableQuests > 0 then
        for i=(numActiveQuests + 1), (numActiveQuests + numAvailableQuests) do
            local index = i - numActiveQuests
            local isTrivial, frequency, isRepeatable, isLegendary, questID = GetAvailableQuestInfo(index);
            if (isTrivial and isQuestTrivialTracking) or not isTrivial then
                SelectAvailableQuest(index)
                return
            end
        end
   end
end)

--可选闲话(任务)GossipFrameShared.lua
hooksecurefunc(GossipOptionButtonMixin, 'Setup', function(self, optionInfo)
    if not optionInfo.gossipOptionID or not Save.qest or IsModifierKeyDown() or optionInfo.flags ~= Enum.GossipOptionRecFlags.QuestLabelPrepend then
        return
    end
    
    local spell=optionInfo.spellID and GetSpellLink(optionInfo.spellID) or ''
    local icon=self.Icon:GetTexture()
    icon = icon and '|T'..icon..':0|t' or ''
    local text=GOSSIP_QUEST_OPTION_PREPEND:format(optionInfo.name)
    print(GREEN_FONT_COLOR_CODE..QUESTS_LABEL..' |r(Alt '..RED_FONT_COLOR_CODE..DISABLE..'|r): |cffff00ff'..icon..text..'|r'..spell)

    C_GossipInfo.SelectOption(optionInfo.gossipOptionID)
end)

--任务进度, 继续, 完成QuestFrame.lua
hooksecurefunc('QuestFrameProgressItems_Update', function(self)
    if not Save.qest or IsModifierKeyDown() then
        return
    end
    local b=QuestFrameCompleteQuestButton;
    if b and b:IsEnabled() then
        
        QuestProgressCompleteButton_OnClick()
    end
end)

--完成已激活任务,多个任务GossipFrameShared.lua
hooksecurefunc(GossipSharedActiveQuestButtonMixin, 'Setup', function(self, info)
    local questID=info.questID or self:GetID()
    if not questID or not Save.qest or IsModifierKeyDown() or not C_QuestLog.IsComplete(questID) then
        return
    end
    C_GossipInfo.SelectActiveQuest(questID)
end)
--自动接取任务,多个任务GossipFrameShared.lua
hooksecurefunc(GossipSharedAvailableQuestButtonMixin, 'Setup', function(self, info)
   -- print(not info.questID , not Save.qest , IsModifierKeyDown() , not getQuestTrivial(info.questID) , getMaxQuest())
    if not info.questID or not Save.qest or IsModifierKeyDown() or not getQuestTrivial(info.questID) or getMaxQuest() then
        return
    end
    
    C_GossipInfo.SelectAvailableQuest(info.questID);--or self:GetID()
end)
--自动接取任务, 仅一个任务
hooksecurefunc('QuestInfo_Display', function(self, template, parentFrame, acceptButton, material, mapView)--QuestInfo.lua
    local frame=QuestInfoFrame
    if not Save.qest or IsModifierKeyDown() or not frame or not getQuestTrivial() or getMaxQuest() then
        return
    end
    
    if frame.acceptButton and frame.acceptButton:IsEnabled() then
        frame.acceptButton:Click()
    end
end)


q:SetScript('OnMouseDown', function(self, d)
    local key=IsModifierKeyDown()
    if d=='LeftButton' and not key then
        if Save.qest then
            Save.qest=nil
        else
            Save.qest=true
        end
        setTexture()
        print(QUICK_JOIN_IS_AUTO_ACCEPT_TOOLTIP..' ('..QUESTS_LABEL..'): '..e.GetEnabeleDisable(Save.qest))
    elseif d=='RightButton' and not key then
        SetCursor('UI_MOVE_CURSOR')
    elseif d=='RightButton' and IsAltKeyDown() then
        self:ClearAllPoints()
        Save.point=nil
        setParent()--设置父级
        self:SetPoint('TOPRIGHT', ObjectiveTrackerBlocksFrame, 'TOPRIGHT', -45, -2)--设置位置
    end
end)
q:SetScript('OnEnter', function (self2)
    e.tips:SetOwner(self2, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(id, 	QUESTS_LABEL)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(QUICK_JOIN_IS_AUTO_ACCEPT_TOOLTIP..': '..QUESTS_LABEL, e.GetEnabeleDisable(Save.qest)..e.Icon.left)
    e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(MINIMAP_TRACKING_TRIVIAL_QUESTS..'|A:TrivialQuests:0:0|a', Save.qest and e.GetEnabeleDisable(isQuestTrivialTracking))--低等任务
    e.tips:AddDoubleLine(QUESTS_LABEL..' '..#C_QuestLog.GetAllCompletedQuestIDs()..' '..COMPLETE, GetDailyQuestsCompleted()..' '..DAILY)--已完成任务
    e.tips:Show()
end)
q:SetScript('OnLeave', function ()
    e.tips:Hide()
end)

q:SetMovable(true)
q:SetClampedToScreen(true)
q:RegisterForDrag('RightButton')
q:SetScript('OnDragStart',function(self)
    if not IsModifierKeyDown() then
        self:StartMoving()
        SetCursor('UI_MOVE_CURSOR')
    end
end)
q:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
    ResetCursor()
    setParent()--设置父级
    Save.point={self:GetPoint(1)}
    Save.point[2]=nil
    print(id, addName, '|cFF00FF00Alt+'.. e.Icon.right..KEY_BUTTON2..'|r', TRANSMOGRIFY_TOOLTIP_REVERT)
end)
q:SetScript('OnMouseUp', function()
    ResetCursor()
end)

q:RegisterEvent("PLAYER_LOGOUT")
q:RegisterEvent("QUEST_LOG_UPDATE")
q:RegisterEvent('MINIMAP_UPDATE_TRACKING')
q:SetScript("OnEvent", function(self, event, arg1)
    if event=='MINIMAP_UPDATE_TRACKING' then
        GetIsQuestTrivialTracking()--其它任务,低等任务,追踪
        
    else
        if not self.str then
            self.str=e.Cstr(self)
            self.str:SetPoint('RIGHT', g, 'LEFT', 0, 0)
        end
        local n = select(2,C_QuestLog.GetNumQuestLogEntries()) or 0;
        local max = C_QuestLog.GetMaxNumQuestsCanAccept() or 25;
        if max == n then
            self.str:SetText(RED_FONT_COLOR_CODE..n..'/'..max..'|r')
        else
            self.str:SetText(n..'/'..max..'|r')
        end
    end
end)

--加载保存数据

g:RegisterEvent("ADDON_LOADED")
g:RegisterEvent("PLAYER_LOGOUT")

g:RegisterEvent('QUEST_ACCEPTED')

g:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED"  then
        if arg1 == id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            setTexture()
            if Save.point then
                setParent()--设置父级
                q:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
            else
                q:SetPoint('TOPRIGHT', ObjectiveTrackerBlocksFrame, 'TOPRIGHT', -45, -2)--设置位置
            end

            GetIsQuestTrivialTracking()--其它任务,低等任务,追踪

        elseif arg1=='Blizzard_PlayerChoice' then--命运, 字符
            hooksecurefunc(StaticPopupDialogs["CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING"],"OnShow",function(s)
                if Save.gossip and s.editBox then
                    s.editBox:SetText(SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING);
                end
            end)
        end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='QUEST_ACCEPTED' then--共享任务
        if IsInGroup() and arg1 and Save.qest then
            if C_QuestLog.IsPushableQuest(arg1) then
                C_QuestLog.SetSelectedQuest(arg1)
                QuestLogPushQuest()
            end
        end
    end
end)