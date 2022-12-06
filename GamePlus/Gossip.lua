local id, e = ...
local addName=ENABLE_DIALOG..QUESTS_LABEL
local Save={
        gossip=true, quest=true, unique=true, autoSortQuest=true, autoSelectReward=true,
        Option={}, NPC={},
        QuestOption={}, QuestNPC={},
}
--[[
    Save.Option[self2.info.gossipOptionID]={
        name=self2.name,
        npcID=self2.npc,
        gossipText=self2.info.name
    }
]]

local panel=e.Cbtn(UIParent, nil,nil,nil,nil, true, {20,20});--闲话图标
local questFrame=e.Cbtn(UIParent, nil,nil,nil,nil, true, {20,20});--任务图标

local function setTexture()--设置图标
    questFrame:SetNormalAtlas(Save.quest and 'campaignavailablequesticon' or e.Icon.icon)
    panel:SetNormalAtlas(Save.gossip and 'transmog-icon-chat' or e.Icon.icon)
end

local function setPoint()--设置位置
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('TOPRIGHT', ObjectiveTrackerBlocksFrame, 'TOPRIGHT', -45, -2)
    end
end

local isQuestTrivialTracking
local function get_set_IsQuestTrivialTracking(setting)--其它任务,低等任务,追踪
    for trackingID=1, C_Minimap.GetNumTrackingTypes() do
        local name, texture, active, category, nested = C_Minimap.GetTrackingInfo(trackingID)
        if name==MINIMAP_TRACKING_TRIVIAL_QUESTS then
            if setting then
                active= not active and true or false
                C_Minimap.SetTracking(trackingID, active)
            end
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


--###########
--对话，主菜单
--###########
local function InitMenu_Gossip(self, level, type)
    local info
    if type=='CUSTOM' then
        for gossipOptionID, tab in pairs(Save.Option) do
            info={
                text= tab.name,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= tab.gossipText,
                tooltipText='\ngossipOptionID '..gossipOptionID..'\n\n'..e.Icon.left..REMOVE,
                func=function()
                    Save.Option[gossipOptionID]=nil
                    print(id, ENABLE_DIALOG, REMOVE, tab.gossipText, tab.name, 'gossipOptionID:', gossipOptionID)
                end
            }
            UIDropDownMenu_AddButton(info, level)
        end

        UIDropDownMenu_AddSeparator(level)
        info={
            text=CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.Option={}
                print(id, ENABLE_DIALOG,CUSTOM,CLEAR_ALL)
            end
        }
        UIDropDownMenu_AddButton(info, level)
    elseif type=='NPC' then
        for npcID, name in pairs(Save.NPC) do--禁用NPC
            info={
                text=name,
                tooltipOnButton=true,
                tooltipTitle= 'NPC '..npcID,
                tooltipTEXT= e.Icon.left..REMOVE,
                notCheckable= true,
                func= function()
                    Save.NPC[npcID]=nil
                end
            }
            UIDropDownMenu_AddButton(info, level)
        end
        UIDropDownMenu_AddSeparator(level)
        info={
            text=CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.NPC={}
                print(id, ENABLE_DIALOG,CUSTOM,CLEAR_ALL)
            end
        }
        UIDropDownMenu_AddButton(info, level)
    else
        info={--启用,禁用
            text=e.Icon.left..AUTO_JOIN:gsub(JOIN, ENABLE_DIALOG),
            checked=Save.gossip,
            func= function()
                Save.gossip= not Save.gossip and true or nil
                setTexture()--设置图标
            end
        }
        UIDropDownMenu_AddButton(info, level)
        info={--唯一
            text= ITEM_UNIQUE..ENABLE_DIALOG,
            checked= Save.unique,
            func= function()
                Save.unique= not Save.unique and true or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={--自定义,闲话,选项
            text=CUSTOM,
            menuList='CUSTOM',
            notCheckable=true,
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

        info={--禁用NPC, 闲话, 选项
            text=DISABLE,
            menuList='NPC',
            notCheckable=true,
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={
            text=e.Icon.right..NPE_MOVE,
            notCheckable=true,
            isTitle=true,
        }
        UIDropDownMenu_AddButton(info, level)
        info={
            text=RESET_POSITION,
            notCheckable=true,
            colorCode=not Save.point and '|cff606060',
            func= function()
                Save.point=nil
                panel:ClearAllPoints()
                setPoint()
            end
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={
            text=id..' '..ENABLE_DIALOG,
            isTitle=true,
            notCheckable=true,
        }
        UIDropDownMenu_AddButton(info, level)
    end
end


--###########
--对话，初始化
--###########
local function Init_Gossip()
    panel.MenuGossip=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.MenuGossip, InitMenu_Gossip, 'MENU')

    panel:SetMovable(true)--移动
    panel:SetClampedToScreen(true)
    panel:RegisterForDrag('RightButton')
    panel:SetScript('OnDragStart',function(self)
        if not IsModifierKeyDown() then
            self:StartMoving()
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    panel:SetScript('OnDragStop', function(self)
        self:StopMovingOrSizing()
        ResetCursor()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
        CloseDropDownMenus()
    end)
    panel:SetScript('OnMouseDown', function(self, d)
        local key=IsModifierKeyDown()
        if d=='LeftButton' and not key then
            Save.gossip= not Save.gossip and true or nil
            setTexture()
        elseif d=='RightButton' and not key then
            ToggleDropDownMenu(1, nil, self.MenuGossip, self, 15,0)
        end
    end)
    panel:SetScript('OnMouseUp', function()
        ResetCursor()
    end)

    --禁用此npc闲话选项
    GossipFrame.sel=CreateFrame("CheckButton", nil, GossipFrame, 'InterfaceOptionsCheckButtonTemplate')
    GossipFrame.sel:SetPoint("BOTTOMLEFT",5,2)
    GossipFrame.sel.Text:SetText(DISABLE)
    GossipFrame.sel:SetScript("OnClick", function (self, d)
        if not self.npc and self.name then
            return
        end
        Save.NPC[self.npc]= not Save.NPC[self.npc] and self.name or nil
        print(id, ENABLE_DIALOG, self.name, self.npc, e.GetEnabeleDisable(Save.NPC[self.npc]))
    end)
    GossipFrame.sel:SetScript('OnEnter',function (self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, ENABLE_DIALOG)
        if self.npc and self.name then
            e.tips:AddDoubleLine(self.name, 'NPC '..self.npc)
            e.tips:AddDoubleLine(DISABLE..' NPC', e.GetEnabeleDisable(not Save.NPC[self.npc]))
        else
            e.tips:AddDoubleLine(NONE, 'NPC ID')
        end
        e.tips:Show()
    end)
    GossipFrame.sel:SetScript("OnLeave", function()
        e.tips:Hide()
    end)

    local selectGissipIDTab= {}
    GossipFrame:SetScript('OnShow', function (self)
        selectGissipIDTab={}
        local npc=e.GetNpcID('npc')
        self.sel.npc=npc
        self.sel.name=UnitName("npc")
        self.sel:SetChecked(Save.NPC[npc])
    end)

    --自定义闲话选项, 按钮 GossipFrameShared.lua
    hooksecurefunc(GossipOptionButtonMixin, 'Setup', function(self, info)--GossipFrameShared.lua
        if not info or not info.gossipOptionID then
            return
        end

        if not self.sel then
            self.sel=CreateFrame("CheckButton", nil, self, 'InterfaceOptionsCheckButtonTemplate')
            self.sel:SetPoint("RIGHT", -2, 0)
            self.sel:SetSize(18, 18)
            self.sel:SetScript("OnEnter", function(self2)
                if self2.info and self2.info.gossipOptionID then
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(' ')
                    e.tips:AddDoubleLine(id, GOSSIP_OPTIONS)
                    e.tips:AddDoubleLine(self2.name, self2.npc and 'NPC: '..self2.npc or '')
                    e.tips:AddDoubleLine(self2.info.name, 'gossipOption: '..self2.info.gossipOptionID)
                    e.tips:Show()
                end
            end)
            self.sel:SetScript("OnLeave", function ()
                e.tips:Hide()
            end)
            self.sel:SetScript("OnClick", function (self2)
                if self2.info and self2.info.gossipOptionID then
                    if Save.Option[self2.info.gossipOptionID] then
                        Save.Option[self2.info.gossipOptionID]=nil
                    else
                        Save.Option[self2.info.gossipOptionID]={
                            name=self2.name,
                            --npcID=self2.npc,
                            gossipText=self2.info.name
                        }
                        C_GossipInfo.SelectOption(self:GetID())
                    end
                end
            end)
        end

        local npc=e.GetNpcID('npc')
        self.sel.name=UnitName("npc")
        self.sel.info=info
        self.sel:SetChecked(Save.Option[info.gossipOptionID])

        local index=self:GetID()
        local gossip= C_GossipInfo.GetOptions()
        local name=info.name
        
        local find
        if IsModifierKeyDown() then
            return

        elseif Save.Option[info.gossipOptionID] then--自定义
            C_GossipInfo.SelectOption(index)
            find=true
        
        elseif (npc and Save.NPC[npc]) or not Save.gossip then
            return

        elseif (info.flags == Enum.GossipOptionRecFlags.QuestLabelPrepend or name:find(QUESTS_LABEL)) and Save.quest then--任务
            if info.flags == Enum.GossipOptionRecFlags.QuestLabelPrepend then
                name=GOSSIP_QUEST_OPTION_PREPEND:format(info.name)
            end
            C_GossipInfo.SelectOption(index)
            find=true

        elseif #gossip==1 and Save.unique then--仅一个
            if not getMaxQuest() then
                local tab= C_GossipInfo.GetActiveQuests() or {}
                for _, questInfo in pairs(tab) do
                    if questInfo.questID and questInfo.isComplete and (Save.quest or Save.QuestOption[questInfo.questID]) then
                        return
                    end
                end

                tab= C_GossipInfo.GetAvailableQuests() or {}
                for _, questInfo in pairs(tab) do
                    if questInfo.questID and (Save.quest or Save.QuestOption[questInfo.questID]) and (isQuestTrivialTracking and questInfo.isTrivial or not questInfo.isTrivial) then
                        return
                    end
                end
            end

            C_GossipInfo.SelectOption(index)
            find=true
        end

        if find and not selectGissipIDTab[info.gossipOptionID] then
            selectGissipIDTab[info.gossipOptionID]=true
            print(id, ENABLE_DIALOG, '|T'..(info.overrideIconID or info.icon or '')..':0|t', '|cffff00ff'..name)
        end
    end)

    local selectQeust
    --自动接取任务,多个任务GossipFrameShared.lua questInfo.questID, questInfo.title, questInfo.isIgnored, questInfo.isTrivial
    hooksecurefunc(GossipSharedAvailableQuestButtonMixin, 'Setup', function(self, info)
        local questID=info and info.questID or self:GetID()
        if not questID then
            return
        end

        if not self.sel then
            self.sel=CreateFrame("CheckButton", nil, self, 'InterfaceOptionsCheckButtonTemplate')
            self.sel:SetPoint("RIGHT", -2, 0)
            self.sel:SetSize(18, 18)
            self.sel:SetScript("OnEnter", function(self2)
                if self2.questID then
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(id, QUESTS_LABEL)
                    e.tips:AddDoubleLine(self2.info.title, 'ID '..self2.questID)
                    e.tips:Show()
                end
            end)
            self.sel:SetScript("OnLeave", function ()
                e.tips:Hide()
            end)
            self.sel:SetScript("OnClick", function (self2)
                if Save.QuestOption[self2.questID] then
                    Save.QuestOption[self2.questID]=nil
                else
                    Save.QuestOption[self2.questID]={
                        name= self2.name,
                        title= self2.title,
                    }
                    C_GossipInfo.SelectAvailableQuest(self2.questID);
                    if self2.title then
                        print(id, QUESTS_LABEL, '|cnGREEN_FONT_COLOR:'..self2.title)
                    end
                end
            end)
        end
        local npc=e.GetNpcID('npc')
        self.sel.name= UnitName("npc")
        self.sel.questID= questID
        self.sel.title= info.title
        local find
        
        if IsModifierKeyDown() then
            return

        elseif Save.QuestOption[questID] then--or  C_QuestLog.IsComplete(questID) then
           C_GossipInfo.SelectAvailableQuest(questID);--or self:GetID()
            find=true

        elseif not Save.quest or not getQuestTrivial(questID) or getMaxQuest() or (npc and Save.NPC[npc]) then
            return

        else
            C_GossipInfo.SelectAvailableQuest(questID)
            find=true
        end

        if info.title and find and (not selectQeust or selectQeust~=info.title) then
            selectQeust=info.title
            print(id, QUESTS_LABEL, '|cnGREEN_FONT_COLOR:'..info.title, questID)
        end
    end)

    --完成已激活任务,多个任务GossipFrameShared.lua
    hooksecurefunc(GossipSharedActiveQuestButtonMixin, 'Setup', function(self, info)
        local questID=info.questID or self:GetID()
        if not questID or (not Save.quest and not Save.QuestOption[questID]) or IsModifierKeyDown() or not C_QuestLog.IsComplete(questID) or (Save.NPC[GossipFrame.sel.npc]) then
            return
        end
        C_GossipInfo.SelectActiveQuest(questID)
        if info.title then            
            print(id, QUESTS_LABEL,'|T'..(info.overrideIconID or info.icon or '')..':0|t', '|cnGREEN_FONT_COLOR:'..info.title)
        end
    end)
end


--###########
--任务，主菜单
--###########
local function set_Only_Show_Zone_Quest()--显示本区域任务
    if Save.autoSortQuest then
        for index=1, select(2,C_QuestLog.GetNumQuestLogEntries()) do
            local info = C_QuestLog.GetInfo(index)
            if info and info.questID and not info.isHeader then
                if info.isOnMap then
                    C_QuestLog.AddQuestWatch(info.questID)
                else
                    C_QuestLog.RemoveQuestWatch(info.questID)
                end
            end
        end
        C_QuestLog.SortQuestWatches()
    end
end

local function set_PushableQuest()--共享,任务
    if Save.pushable and IsInGroup() then
        for index=1, select(2,C_QuestLog.GetNumQuestLogEntries()) do
            local info = C_QuestLog.GetInfo(index)
            if info and info.questID and not info.isHeader then
                C_QuestLog.SetSelectedQuest(info.questID)
                QuestLogPushQuest()
            end
        end
        C_QuestLog.SortQuestWatches()
    end
end

local function set_Auto_QuestWatch_Event()--设置事件, 仅显示本地图任务, 共享任务, 
    if Save.autoSortQuest then
        questFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
        questFrame:RegisterEvent('ZONE_CHANGED')
        questFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
    else
        questFrame:UnregisterEvent('PLAYER_ENTERING_WORLD')
        questFrame:UnregisterEvent('ZONE_CHANGED')
        questFrame:UnregisterEvent('ZONE_CHANGED_NEW_AREA')
    end
    if Save.pushable then
        questFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
    else
        questFrame:UnregisterEvent('GROUP_ROSTER_UPDATE')
    end
end

local function InitMenu_Quest(self, level, type)
    local info
    if type=='TRACKING' then--追踪
        info={--自动任务追踪
            text=AUTO_QUEST_WATCH_TEXT,
            checked=C_CVar.GetCVarBool("autoQuestWatch"),
            tooltipOnButton=true,
            tooltipTitle=ERR_QUEST_ACCEPTED_S:format('Cvar autoQuestWatch'),
            func=function()
                C_CVar.SetCVar("autoQuestWatch", C_CVar.GetCVarBool("autoQuestWatch") and '0' or '1')
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={--当前地图
            text=REFORGE_CURRENT..WORLD_MAP,
            checked=Save.autoSortQuest,
            tooltipOnButton=true,
            tooltipTitle=	GROUP_FINDER_CROSS_FACTION_LISTING_WITH_PLAYSTLE:format(SHOW,FLOOR..QUESTS_LABEL),--仅限-本区域任务
            tooltipText=EVENTS_LABEL..':' ..UPDATE..FLOOR,
            func=function()
                Save.autoSortQuest= not Save.autoSortQuest and true or nil
                set_Auto_QuestWatch_Event()--仅显示本地图任务,事件
            end
        }
        UIDropDownMenu_AddButton(info, level)

    elseif type=='CUSTOM' then
        for questID, tab in pairs(Save.QuestOption) do
            info={
                text= tab.title,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= tab.name,
                tooltipText='questID  '..questID..'\n\n'..e.Icon.left..REMOVE,
                func=function()
                    Save.QuestOption[questID]=nil
                    print(id, QUESTS_LABEL, REMOVE, tab.title, tab.name, 'ID', tab.questID)
                end
            }
            UIDropDownMenu_AddButton(info, level)
        end

        UIDropDownMenu_AddSeparator(level)
        info={
            text=CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.QuestOption={}
                print(id, ENABLE_DIALOG,CUSTOM,CLEAR_ALL)
            end
        }
        UIDropDownMenu_AddButton(info, level)

    elseif type=='DISABLE' then--禁用, NPC, 任务
        for npcID, name in pairs(Save.QuestNPC) do
            info={
                text=name,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= 'NPC '..npcID,
                tooltipText= e.Icon.left..REMOVE,
                func= function()
                    Save.QuestNPC[npcID]=nil
                    print(id, QUESTS_LABEL, REMOVE, name, 'NPC '..npcID)
                end
            }
            UIDropDownMenu_AddButton(info, level)
        end
        UIDropDownMenu_AddSeparator(level)
        info={
            text=CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.QuestNPC={}
                print(id, QUESTS_LABEL, DISABLE, CLEAR_ALL)
            end
        }
        UIDropDownMenu_AddButton(info, level)

    else
        info={
            text=e.Icon.left..QUICK_JOIN_IS_AUTO_ACCEPT_TOOLTIP,--自动接受
            checked=Save.quest,
            func= function()
                Save.quest= not Save.quest and true or nil
                setTexture()--设置图标
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text='|A:TrivialQuests:0:0|a'..MINIMAP_TRACKING_TRIVIAL_QUESTS,--低等任务
            checked= isQuestTrivialTracking,
            tooltipOnButton= true,
            tooltipTitle= TRACKING,
            tooltipText= LOW..LEVEL..QUESTS_LABEL,
            func= function ()
                get_set_IsQuestTrivialTracking(true)--其它任务,低等任务,追踪
            end,
        }
        UIDropDownMenu_AddButton(info, level)

        info={--自动:选择奖励
            text= TITLE_REWARD:format(AUTO_JOIN:gsub(JOIN, CHOOSE)),
            checked= Save.autoSelectReward,
            tooltipOnButton=true,
            tooltipTitle= PROFESSIONS_CRAFTING_QUALITY:format(VIDEO_OPTIONS_ULTRA_HIGH),
            tooltipText= '|cff0000ff'..GARRISON_MISSION_RARE..'|r',
            func= function()
                Save.autoSelectReward= not Save.autoSelectReward and true or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={--共享任务
            text=SHARE_QUEST,
            checked=Save.pushable,
            colorCode= not IsInGroup() and '|cff606060',
            tooltipOnButton=true,
            tooltipTitle=LFG_LIST_CROSS_FACTION:format(AGGRO_WARNING_IN_PARTY),
            func= function()
                Save.pushable= not Save.pushable and true or nil
                set_PushableQuest()--共享,任务
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text=TRACKING,
            notCheckable=true,
            hasArrow=true,
            menuList='TRACKING'
        }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)

        info={--自定义,任务,选项
            text=CUSTOM,
            menuList='CUSTOM',
            notCheckable=true,
            hasArrow=true,
        }
        info={--禁用, NPC, 任务
            text=DISABLE,
            notCheckable=true,
            menuList='DISABLE',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={
            text=id..' '..QUESTS_LABEL,
            notCheckable=true,
            isTitle=true,
        }
        UIDropDownMenu_AddButton(info, level)
    end
end

--###########
--任务，初始化
--###########
local function Init_Quest()
    questFrame.MenuQest=CreateFrame("Frame",nil, questFrame, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(questFrame.MenuQest, InitMenu_Quest, 'MENU')

    questFrame:SetPoint('RIGHT', panel, 'LEFT')

    if Save.autoSortQuest then--仅显示本地图任务,事件
        set_Auto_QuestWatch_Event()
    end

    questFrame.Text=e.Cstr(questFrame, nil, nil,nil, true,nil, 'RIGHT')--任务数量
    questFrame.Text:SetPoint('RIGHT', questFrame, 'LEFT')
    questFrame:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Save.quest= not Save.quest and true or nil
            setTexture()--设置图标
        elseif d=='RightButton' then
            ToggleDropDownMenu(1, nil, self.MenuQest, self, 15,0)
        end
    end)
    questFrame:SetScript('OnEnter', set_Only_Show_Zone_Quest)

    questFrame:RegisterEvent("QUEST_LOG_UPDATE")
    questFrame:RegisterEvent('MINIMAP_UPDATE_TRACKING')
    questFrame:SetScript("OnEvent", function(self, event)
        if event=='MINIMAP_UPDATE_TRACKING' then
            get_set_IsQuestTrivialTracking()--其它任务,低等任务,追踪

        elseif event=='QUEST_LOG_UPDATE' then--更新数量
            local n = select(2,C_QuestLog.GetNumQuestLogEntries()) or 0;
            local max = C_QuestLog.GetMaxNumQuestsCanAccept() or 25;
            if max == n then
                self.Text:SetText(RED_FONT_COLOR_CODE..n..'/'..max..'|r')
            else
                self.Text:SetText(n..'/'..max)
            end
        elseif event=='GROUP_ROSTER_UPDATE' then
            set_PushableQuest()--共享,任务
        else
            set_Auto_QuestWatch_Event()--仅显示本地图任务,事件
        end
    end)

    QuestFrame.sel=CreateFrame("CheckButton", nil, QuestFrame, 'InterfaceOptionsCheckButtonTemplate')--禁用此npc,任务,选项
    QuestFrame.sel:SetPoint("TOPLEFT", QuestFrame, 40, 20)
    QuestFrame.sel.Text:SetText(DISABLE)
    QuestFrame.sel:SetScript("OnClick", function (self, d)
        if not self.npc and self.name then
            return
        end
        Save.QuestNPC[self.npc]= not Save.QuestNPC[self.npc] and self.name or nil
        print(id, QUESTS_LABEL, self.name, self.npc, DISABLE..QUESTS_LABEL..':',  e.GetEnabeleDisable(Save.QuestNPC[self.npc]))
    end)
    QuestFrame.sel:SetScript('OnEnter',function (self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        if self.npc and self.name then
            e.tips:AddDoubleLine(id, QUESTS_LABEL)
            e.tips:AddDoubleLine(self.name, 'NPC '..self.npc)
            e.tips:AddDoubleLine(DISABLE..' NPC', e.GetEnabeleDisable(not Save.QuestNPC[self.npc]))
        else
            e.tips:AddDoubleLine(NONE, 'NPC ID')
        end
        e.tips:Show()
    end)
    QuestFrame.sel:SetScript("OnLeave", function()
        e.tips:Hide()
    end)

    QuestFrame:SetScript('OnShow', function (self)
        local npc=e.GetNpcID('npc')
        self.sel.npc=npc
        self.sel.name=UnitName("npc")
        self.sel:SetChecked(Save.NPC[npc])
    end)

    local function select_Reward()--自动:选择奖励
        if Save.autoSelectReward then
            local firstItem = QuestInfoRewardsFrameQuestInfoItem1
            
            if firstItem then
                local numQuests = GetNumQuestChoices()
                if numQuests and numQuests >1 then
                    local bestValue, bestItem = 0, nil
                    local bestLevel, bestLevelItem= 0,nil
                    local selectItemLink
                    for i = 1, numQuests do
                        local  itemLink = GetQuestItemLink('choice', i)
                        if itemLink then
                            local amount = select(3, GetQuestItemInfo('choice', i))--钱
                            local _, _, itemQuality, itemLevel, _, _,_,_, itemEquipLoc, _, sellPrice= GetItemInfo(itemLink)
                            if itemQuality and itemQuality<4 then--最高 稀有的 3
                                
                                if amount and sellPrice then
                                    local totalValue = (sellPrice and sellPrice * amount) or 0
                                    if totalValue > bestValue then
                                        bestValue = totalValue
                                        bestItem = i
                                    
                                    end
                                end
                                
                                local invSlot = itemEquipLoc and  e.itemSlotTable[itemEquipLoc]
                                if invSlot and itemLevel and itemLevel>1 then--装等
                                    local itemLinkPlayer = GetInventoryItemLink('player', invSlot)
                                    if itemLinkPlayer then
                                        local lv=GetDetailedItemLevelInfo(itemLinkPlayer)
                                        if lv and lv>0 and itemLevel-lv>0 then
                                            if bestLevel and bestLevel<lv or not bestLevel then
                                                bestLevel=lv
                                                bestLevelItem=i
                                                selectItemLink=itemLink
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    bestItem= bestLevelItem or bestItem
                    if bestItem then
                        _G['QuestInfoRewardsFrameQuestInfoItem'..bestItem]:Click()
                        if selectItemLink then
                            print(id, QUESTS_LABEL, CHOOSE, selectItemLink)
                        end
                    end
                end
            end
        end
    end

    --任务框, 自动选任务    
    QuestFrameGreetingPanel:HookScript('OnShow', function(self)--QuestFrame.lua QuestFrameGreetingPanel_OnShow
        if not Save.quest or IsModifierKeyDown() or Save.QuestNPC[QuestFrame.sel.npc] then--getMaxQuest()
            return
        end

        local numActiveQuests = GetNumActiveQuests();
        local numAvailableQuests = GetNumAvailableQuests();
        if numActiveQuests > 0 then
            for index=1, numActiveQuests do
                if select(2,GetActiveTitle(index)) then
                    
                    SelectActiveQuest(index)
                    return
                end
            end
        end
        if numAvailableQuests > 0 and not getMaxQuest() then
            for i=(numActiveQuests + 1), (numActiveQuests + numAvailableQuests) do
                local index = i - numActiveQuests
                local isTrivial= GetAvailableQuestInfo(index);
                if (isTrivial and isQuestTrivialTracking) or not isTrivial then
                    SelectAvailableQuest(index)
                    return
                end
            end
       end
    end)

    --任务进度, 继续, 完成 QuestFrame.lua
    hooksecurefunc('QuestFrameProgressItems_Update', function(self)
        if not Save.quest or IsModifierKeyDown() or  Save.QuestNPC[QuestFrame.sel.npc] then
            return
        end

       
        local b=QuestFrameCompleteQuestButton;
        if b and b:IsEnabled() then
            QuestProgressCompleteButton_OnClick()
        end
    end)
    --自动接取任务, 仅一个任务
    hooksecurefunc('QuestInfo_Display', function(template, parentFrame, acceptButton, material, mapView)--QuestInfo.lua
        local questID;
        if ( template.questLog ) then
            questID = questFrame.questID;
        else
            questID = GetQuestID();
        end

        local complete= questID and C_QuestLog.IsComplete(questID)
        if not Save.quest
            or IsModifierKeyDown()
            or (not complete and  (not getQuestTrivial() or getMaxQuest()))
            or  Save.QuestNPC[QuestFrame.sel.npc]
        then
            return
        end
        if acceptButton and acceptButton:IsEnabled() then
            if complete then
                select_Reward()--自动:选择奖励
            end
            acceptButton:Click()
        end
    end)

  
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('QUEST_ACCEPTED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED"  then
        if arg1 == id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            Save.QuestOption = not Save.QuestOption or {}

             --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(addName, e.GetEnabeleDisable(not Save.disabled), '|cnRED_FONT_COLOR:'..REQUIRES_RELOAD)
            end)
            
            if not Save.disabled then
                setPoint()--设置位置
                setTexture()
                get_set_IsQuestTrivialTracking()--其它任务,低等任务,追踪

                Init_Gossip()--对话，初始化
                Init_Quest()--任务，初始化

                Save.QuestNPC= Save.QuestNPC or {}
            else
                panel:UnregisterAllEvents()
                questFrame:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
            set_Only_Show_Zone_Quest()

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
        if IsInGroup() and arg1 and Save.pushable then
            if C_QuestLog.IsPushableQuest(arg1) then
                C_QuestLog.SetSelectedQuest(arg1)
                QuestLogPushQuest()
            end
        end

    end
end)
