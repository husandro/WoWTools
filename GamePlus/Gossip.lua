local id, e = ...
local Save
local Frame = GossipFrame
local Frame2=ObjectiveTrackerBlocksFrame
local tips= GameTooltip

local Icon={
    right='|A:newplayertutorial-icon-mouse-rightbutton:0:0|a',
    left='|A:newplayertutorial-icon-mouse-leftbutton:0:0|a',
    setHighlightAtlas='bags-newitem',
    setPushedAtlas='bags-glow-heirloom',
    normal='Lightlink-ball',
    gossip='transmog-icon-chat',--对话图标
    qest='campaignavailablequesticon',
    TrivialQuests='|A:TrivialQuests:0:0|a',
}

local function Cbtn(self)
    local b=CreateFrame("Button",nil, self)
    b:SetSize(20, 20)
    b:SetHighlightAtlas(Icon.setHighlightAtlas)
    b:SetPushedAtlas(Icon.setPushedAtlas)
    return b
end
local g=Cbtn(Frame2);--闲话图标
local q=Cbtn(Frame2);--任务图标

local function Cstr(f)
    local b=f:CreateFontString(nil, 'OVERLAY')
    b:SetFontObject('GameFontNormal')
    b:SetShadowOffset(2, -2)
    b:SetShadowColor(0, 0, 0)
    return b
end

local function GetEnabeleDisable(ed)--启用或禁用字符
    if ed then
      return '|cnGREEN_FONT_COLOR:'..ENABLE..'|r'
    else
      return '|cnRED_FONT_COLOR:'..DISABLE..'|r'
    end
end

local function GetNpcID(unit)--NPC ID
    if UnitExists(unit) then
      local guid=UnitGUID(unit)
      if guid then
        return select(6,  strsplit("-", guid));
      end
    end
end

local function QuestInfo_GetQuestID()--取得任务ID
	if ( QuestInfoFrame.questLog ) then
		return C_QuestLog.GetSelectedQuest();
	else
		return GetQuestID();
	end
end

local function GetQuestTrivialTracking()--其它任务追踪
    return select(3, C_Minimap.GetTrackingInfo(25))
end

local function QuestTrivial(questID)--其它任务,低等任务
    questID=questID or QuestInfo_GetQuestID()
    local trivial=C_QuestLog.IsQuestTrivial(questID)
    local tracking = GetQuestTrivialTracking()
    return (trivial and tracking) or not trivial
end

--设置图标
local function setTexture()
    if Save.qest then
        q:SetNormalAtlas(Icon.qest)
    else
        q:SetNormalAtlas(Icon.normal)
    end
    if Save.gossip then
       g:SetNormalAtlas(Icon.gossip)
    else
        g:SetNormalAtlas(Icon.normal)
    end
end

--加载保存数据
g:RegisterEvent("ADDON_LOADED")
g:RegisterEvent("PLAYER_LOGOUT")
g:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == id then
        Save=GossipSave or {gossip=true}
        Save.Option=Save.Option or {}
        Save.NPC =Save.NPC or {}
        setTexture()
    elseif event == "PLAYER_LOGOUT" then
        GossipSave=Save
    end
end)

--闲话选项
--禁用此npc闲话选项
Frame:SetScript('OnShow', function (self)
    if not self.sel then
        self.sel=CreateFrame("CheckButton", nil, Frame, 'InterfaceOptionsCheckButtonTemplate')
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
                                if v.gossip then
                                    print(n..')'..(CLEAR or KEY_NUMLOCK_MAC)..': '..GREEN_FONT_COLOR_CODE..v.gossip..'|r')
                                end
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
                tips:SetOwner(self2, "ANCHOR_RIGHT")
                tips:ClearLines()

                tips:AddDoubleLine((self2.name and self2.name..' ' or ''), 'npc ID: '..self2.npc)
                tips:AddDoubleLine(DISABLE..' NPC', GetEnabeleDisable(not Save.NPC[self2.npc])..Icon.left)
                tips:AddDoubleLine(CLEAR_ALL, Icon.right)
                tips:AddDoubleLine(' ')
                tips:AddDoubleLine(GOSSIP_OPTIONS, GetEnabeleDisable(Save.gossip))
                tips:Show()
            end
        end)
        self.sel:SetScript("OnLeave", function() tips:Hide() end)
    end
    local npc=GetNpcID('npc')
    self.sel.npc=npc
    self.sel.name=UnitName("npc")
    self.sel:SetChecked(Save.NPC[npc])
    Frame.sel:SetShown(npc)
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
                tips:SetOwner(self2, "ANCHOR_RIGHT")
                tips:ClearLines()
                tips:AddDoubleLine(self2.name, self2.npc and 'npc ID: '..self2.npc or '')
                tips:AddDoubleLine(self2.info.name, 'gossipOptionID: '..self2.info.gossipOptionID)
                tips:AddDoubleLine(' ')
                tips:AddDoubleLine(CUSTOM, GetEnabeleDisable(Save.Option[self2.info.gossipOptionID]))
                tips:AddDoubleLine(self2.name, GetEnabeleDisable(not Save.NPC[self2.npc]))
                tips:AddDoubleLine(GOSSIP_OPTIONS, GetEnabeleDisable(Save.gossip))
                tips:Show()
            end
        end)
        self.sel:SetScript("OnLeave", function ()
            tips:Hide()
        end)
        self.sel:SetScript("OnClick", function (self2)
            if Save.Option[self2.info.gossipOptionID] then
                Save.Option[self2.info.gossipOptionID]=nil
            else
                Save.Option[self2.info.gossipOptionID]={
                    name=self2.name,
                    npcid=self2.npc,
                    gossip=self2.info.name
                }
                C_GossipInfo.SelectOption(self:GetID())
            end
        end)
    end

    local npc=GetNpcID('npc')
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

--hooksecurefunc(Frame, 'Update', function()
--对话图标
g:SetPoint('RIGHT', q, 'LEFT', -2, 0)
g:SetScript('OnClick', function(self, d)
    if d=='LeftButton' and not IsModifierKeyDown() then
        if Save.gossip then
            Save.gossip=nil
        else
            Save.gossip=true
        end
        print(GOSSIP_OPTIONS..': '..GetEnabeleDisable(Save.gossip))
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
    tips:SetOwner(self2, "ANCHOR_LEFT")
    tips:ClearLines()
    tips:AddDoubleLine(GOSSIP_OPTIONS..Icon.left, GetEnabeleDisable(Save.gossip))
    tips:AddDoubleLine(CLEAR_ALL..' Alt+'..Icon.left, GREEN_FONT_COLOR_CODE..n..'|r')
    tips:Show()
end)
g:SetScript('OnLeave', function ()
    tips:Hide()
end)


--任务图标

QuestFrameGreetingPanel:HookScript('OnShow', function()--QuestFrame.lua QuestFrameGreetingPanel_OnShow
    if not Save.qest or IsModifierKeyDown() then
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
            if (isTrivial and GetQuestTrivialTracking()) or not isTrivial then
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
    local b=QuestFrameCompleteQuestButton;
    if b and b:IsEnabled() then
        QuestProgressCompleteButton_OnClick()
    end
end)

--完成已激活任务,多个任务GossipFrameShared.lua
hooksecurefunc(GossipSharedActiveQuestButtonMixin, 'Setup', function(self, info)
    local questID=self:GetID() or info.questID
    if not questID or not Save.qest or IsModifierKeyDown() then
        return
    end
    C_GossipInfo.SelectActiveQuest(questID)
end)
--自动接取任务,多个任务GossipFrameShared.lua
hooksecurefunc(GossipSharedAvailableQuestButtonMixin, 'Setup', function(self, info)
    if not Save.qest or IsModifierKeyDown() or not QuestTrivial(info.questID) then
        return
    end
    C_GossipInfo.SelectAvailableQuest(info.questID or self:GetID());
end)
--自动接取任务, 仅一个任务
hooksecurefunc('QuestInfo_Display', function(self, template, parentFrame, acceptButton, material, mapView)--QuestInfo.lua
    local frame=QuestInfoFrame
    if not Save.qest or IsModifierKeyDown() or not frame or not QuestTrivial() then
        return
    end
    if frame.acceptButton and frame.acceptButton:IsEnabled() then
        frame.acceptButton:Click()
    end
end)

q:SetPoint('TOPRIGHT', Frame2, 'TOPRIGHT', -45, -2)
q:SetScript('OnClick', function ()
    if Save.qest then
        Save.qest=nil
    else
        Save.qest=true
    end
    setTexture()
    print(QUICK_JOIN_IS_AUTO_ACCEPT_TOOLTIP..' ('..QUESTS_LABEL..'): '..GetEnabeleDisable(Save.qest))
end)
q:SetScript('OnEnter', function (self2)
    tips:SetOwner(self2, "ANCHOR_LEFT")
    tips:ClearLines()
    tips:AddDoubleLine(QUICK_JOIN_IS_AUTO_ACCEPT_TOOLTIP..': '..QUESTS_LABEL, GetEnabeleDisable(Save.qest)..Icon.left)
    tips:AddDoubleLine(	MINIMAP_TRACKING_TRIVIAL_QUESTS..Icon.TrivialQuests, GetEnabeleDisable(GetQuestTrivialTracking()))
    tips:AddDoubleLine(' ')
    tips:AddDoubleLine(QUESTS_LABEL..' '..#C_QuestLog.GetAllCompletedQuestIDs()..' '..COMPLETE, GetDailyQuestsCompleted()..' '..DAILY)--已完成任务
    tips:Show()
end)
q:SetScript('OnLeave', function ()
    tips:Hide()
end)

q:RegisterEvent("PLAYER_LOGOUT")
q:RegisterEvent("QUEST_LOG_UPDATE")
q:SetScript("OnEvent", function(self, event, arg1)
    if not self.str then
        self.str=Cstr(self)
        self.str:SetPoint('RIGHT', g, 'LEFT', 0, 0)
    end
    local n = select(2,C_QuestLog.GetNumQuestLogEntries()) or 0;
    local max = C_QuestLog.GetMaxNumQuestsCanAccept() or 25;
    if max == n then
        self.str(RED_FONT_COLOR_CODE..n..'/'..max..'|r')
    else
        self.str:SetText(n..'/'..max..'|r')
    end
end)