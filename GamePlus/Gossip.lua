local id, e = ...
local Save
local Frame = GossipFrame
local Frame2=ObjectiveTrackerBlocksFrame
local tips= GameTooltip
local q=e.Cbtn(Frame2, 20);
local g=e.Cbtn(Frame2, 20);



local function QuestInfo_GetQuestID()--取得任务ID
	if ( QuestInfoFrame.questLog ) then
		return C_QuestLog.GetSelectedQuest();
	else
		return GetQuestID();
	end
end
local function QuestTrivial(questID)--其它任务,低等任务
    questID=questID or QuestInfo_GetQuestID()
    local trivial=C_QuestLog.IsQuestTrivial(questID)
    local tracking = select(3, C_Minimap.GetTrackingInfo(25))
    return (trivial and tracking) or not trivial
end

--设置图标
local function setTexture()
    if Save.qest then
        q:SetNormalAtlas(e.Icon.qest)
    else
        q:SetNormalAtlas(e.Icon.normal)
    end
    if Save.gossip then
       g:SetNormalAtlas(e.Icon.gossip)
    else
        g:SetNormalAtlas(e.Icon.normal)
    end
end

--取得NPC id
local function NPC()
    return UnitExists("npc") and select(6, strsplit("-", UnitGUID("npc"))) or nil--npc id            
end

--加载保存数据
q:RegisterEvent("ADDON_LOADED")
q:RegisterEvent("PLAYER_LOGOUT")
q:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == id then
        Save=GossipSave or {gossip=true}
        Save.Option=Save.Option or {}
        Save.NPC =Save.NPC or {}
        setTexture()
    elseif event == "PLAYER_LOGOUT" then
        GossipSave=Save
    end
end)

hooksecurefunc(GossipSharedAvailableQuestButtonMixin, 'Setup', function(self, info)--自动接取任务GossipFrameShared.lua
    if not Save.qest or not QuestTrivial(info.questID) then
        return
    end
    C_GossipInfo.SelectAvailableQuest(info.questID or self:GetID());
end)

hooksecurefunc('QuestInfo_Display', function(self, template, parentFrame, acceptButton, material, mapView)--QuestInfo.lua
    local frame=QuestInfoFrame
    if Save.qest and IsModifierKeyDown() or not frame or not QuestTrivial() then
        return
    end
    if frame.acceptButton then        
        if frame.acceptButton:IsEnabled() then
            local questDescription;
	        if ( frame.questLog ) then
		        questDescription = GetQuestLogQuestText();
	        else
		        questDescription = GetQuestText();
	        end
            print(questDescription)
            frame.acceptButton:Click()
        end
    end
end)
--禁用此np闲话c选项
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
                tips:AddDoubleLine(DISABLE..' NPC', (not Save.NPC[self2.npc] and GREEN_FONT_COLOR_CODE..NO..'|r ' or RED_FONT_COLOR_CODE..YES..'|r ')..e.Icon.left)
                tips:AddDoubleLine(CLEAR_ALL, e.Icon.right)
                tips:AddDoubleLine(' ')
                tips:AddDoubleLine(GOSSIP_OPTIONS, Save.gossip and GREEN_FONT_COLOR_CODE..ENABLE..'|r' or RED_FONT_COLOR_CODE..DISABLE..'|r')
                tips:Show()
            end
        end)
        self.sel:SetScript("OnLeave", function() tips:Hide() end)
    end
    local npc=NPC()
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
        self.sel:SetPoint("RIGHT", -5, 0)
        local h=self:GetHeight();
        self.sel:SetSize(h, h)
        self.sel:SetScript("OnEnter", function(self2)
            if self2.info.gossipOptionID then
                tips:SetOwner(self2, "ANCHOR_RIGHT")
                tips:ClearLines()
                tips:AddDoubleLine(self2.name, self2.npc and 'npc ID: '..self2.npc or '')
                tips:AddDoubleLine(self2.info.name, 'gossipOptionID: '..self2.info.gossipOptionID)
                tips:AddDoubleLine(' ')
                tips:AddDoubleLine(CUSTOM, Save.Option[self2.info.gossipOptionID] and GREEN_FONT_COLOR_CODE..ENABLE..'|r' or RED_FONT_COLOR_CODE..DISABLE..'|r')
                tips:AddDoubleLine(self2.name, not Save.NPC[self2.npc] and GREEN_FONT_COLOR_CODE..ENABLE..'|r' or RED_FONT_COLOR_CODE..DISABLE..'|r')
                tips:AddDoubleLine(GOSSIP_OPTIONS, Save.gossip and GREEN_FONT_COLOR_CODE..ENABLE..'|r' or RED_FONT_COLOR_CODE..DISABLE..'|r')
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

    local npc=NPC()
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
        print((icon and '|T'..icon..':0|t' or '')..e.col..info.name..'|r')--选项信息
        C_GossipInfo.SelectOption(self:GetID())
    end
end)

--hooksecurefunc(Frame, 'Update', function()




--任务图标
q:SetPoint('TOPRIGHT', Frame2, 'TOPRIGHT', -45, -2)
q:SetScript('OnClick', function ()
    if Save.qest then
        Save.qest=nil
    else
        Save.qest=true
    end
    setTexture()
end)

--对话图标
g:SetPoint('RIGHT', q, 'LEFT', -2, 0)
g:SetScript('OnClick', function(self, d)
    if d=='LeftButton' and not IsModifierKeyDown() then
        if Save.gossip then
            Save.gossip=nil
        else
            Save.gossip=true
        end
        print(GOSSIP_OPTIONS..': '..(Save.gossip and GREEN_FONT_COLOR_CODE..ENABLE..'|r' or RED_FONT_COLOR_CODE..DISABLE..'|r'))
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
    tips:AddDoubleLine(GOSSIP_OPTIONS..e.Icon.left, Save.gossip and GREEN_FONT_COLOR_CODE..ENABLE..'|r' or RED_FONT_COLOR_CODE..DISABLE..'|r')
    tips:AddDoubleLine(CLEAR_ALL..' Alt+'..e.Icon.left, GREEN_FONT_COLOR_CODE..n..'|r')
    tips:Show()
end)
g:SetScript('OnLeave', function ()
    tips:Hide()
end)
