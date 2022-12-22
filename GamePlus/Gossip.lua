local id, e = ...
local addName= e.onlyChinse and '对话和任务' or ENABLE_DIALOG..QUESTS_LABEL
local Save={
        gossip=true, quest=true, unique=true, autoSortQuest=true, autoSelectReward=true,
        NPC={},
        gossipOption={},
        questOption={},
}

local panel=e.Cbtn(nil, nil,nil,nil,nil, true, {18,18});--闲话图标
local questPanel=e.Cbtn(panel, nil,nil,nil,nil, true, {18,18});--任务图标
local questSelect={}--已选任务, 提示用

local function setTexture()--设置图标
    questPanel:SetNormalAtlas(Save.quest and 'campaignavailablequesticon' or e.Icon.icon)
    panel:SetNormalAtlas(Save.gossip and 'transmog-icon-chat' or e.Icon.icon)
end

local function setPoint()--设置位置
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        if _G['!KalielsTrackerFrame'] then
            panel:SetPoint('BOTTOMRIGHT',_G['!KalielsTrackerFrame'] , 'TOPRIGHT')
        else
            panel:SetPoint('TOPRIGHT', ObjectiveTrackerBlocksFrame, 'TOPRIGHT', -45, -2)
        end
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
local function not_Ace_QuestTrivial(questID)--其它任务,低等任务
    return C_QuestLog.IsQuestTrivial(questID) and not isQuestTrivialTracking
end
local function getMaxQuest()--任务，是否已满
    return select(2,C_QuestLog.GetNumQuestLogEntries())==C_QuestLog.GetMaxNumQuestsCanAccept()
end

local function select_Reward()--自动:选择奖励
    local numQuests = GetNumQuestChoices()
    if not Save.autoSelectReward or not QuestInfoRewardsFrameQuestInfoItem1 or not numQuests or numQuests <2 then
        return
    end

    local bestValue, bestLevel= 0, 0
    local notColleced, upItem, selectItemLink, bestItem
    for i = 1, numQuests do
        local  itemLink = GetQuestItemLink('choice', i)
        if itemLink then
            local amount = select(3, GetQuestItemInfo('choice', i))--钱
            local _, _, itemQuality, itemLevel, _, _,_,_, itemEquipLoc, _, sellPrice,classID, subclassID = GetItemInfo(itemLink)
            if classID==19 or (classID==4 and subclassID==5) or itemLevel==1 or (not itemEquipLoc) then
                return
            end
            if itemQuality and itemQuality<4 and IsEquippableItem(itemLink) then--最高 稀有的 3                                
                local invSlot = itemEquipLoc and  e.itemSlotTable[itemEquipLoc]
                if invSlot and itemLevel and itemLevel>1 then--装等
                    local itemLinkPlayer = GetInventoryItemLink('player', invSlot)
                    if itemLinkPlayer then
                        local lv=GetDetailedItemLevelInfo(itemLinkPlayer)
                        if lv and lv>1 and itemLevel-lv>0 and (bestLevel and bestLevel<lv or not bestLevel) then
                            bestLevel=lv
                            bestItem = i
                            selectItemLink=itemLink
                            upItem=true
                        end
                    end
                end

                if not upItem then
                    local isCollected, isSelf= select(2, e.GetItemCollected(itemLink))--物品是否收集 
                    if isCollected==false and isSelf then
                        bestItem = i
                        selectItemLink=itemLink
                        notColleced=true
                    end
                end

                if not (notColleced and upItem) then
                    if amount and sellPrice then
                        local totalValue = (sellPrice and sellPrice * amount) or 0
                        if totalValue > bestValue then
                            bestValue = totalValue
                            bestItem = i
                            selectItemLink=itemLink
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
            print(id, QUESTS_LABEL, '|cffff00ff'..CHOOSE..'|r', selectItemLink)
        end
    end
end

--###########
--对话，主菜单
--###########
local function InitMenu_Gossip(self, level, type)
    local info
    if type=='CUSTOM' then
        for gossipOptionID, text in pairs(Save.gossipOption) do
            info={
                text= text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='gossipOptionID '..gossipOptionID..'\n\n'..e.Icon.left..REMOVE,
                func=function()
                    Save.gossipOption[gossipOptionID]=nil
                    print(id, ENABLE_DIALOG, REMOVE, text, 'gossipOptionID:', gossipOptionID)
                end
            }
            UIDropDownMenu_AddButton(info, level)
        end

        UIDropDownMenu_AddSeparator(level)
        info={
            text=CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.gossipOption={}
                print(id, ENABLE_DIALOG,CUSTOM,CLEAR_ALL)
            end
        }
        UIDropDownMenu_AddButton(info, level)

    elseif type=='DISABLE' then--禁用NPC, 闲话,任务, 选项
        for npcID, name in pairs(Save.NPC) do
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

        UIDropDownMenu_AddSeparator(level)
        info={--自定义,闲话,选项
            text=CUSTOM..ENABLE_DIALOG,
            menuList='CUSTOM',
            notCheckable=true,
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

        info={--禁用NPC, 闲话,任务, 选项
            text=DISABLE..' NPC',
            menuList='DISABLE',
            tooltipOnButton=true,
            tooltipTitle=ENABLE_DIALOG,
            tooltipText= QUESTS_LABEL,
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
        print(id, addName, self.name, self.npc, e.GetEnabeleDisable(Save.NPC[self.npc]))
    end)
    GossipFrame.sel:SetScript('OnEnter',function (self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        if self.npc and self.name then
            e.tips:AddDoubleLine(self.name, 'NPC '..self.npc)
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
        questSelect={}--已选任务, 提示用
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
                e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, ENABLE_DIALOG)
                e.tips:AddDoubleLine(' ')
                if self2.id and self2.text then
                    e.tips:AddDoubleLine(self2.text, 'gossipOption: '..self2.id)
                else
                    e.tips:AddDoubleLine(NON, 'gossipOptionID',1,0,0)
                end
                e.tips:Show()
            end)
            self.sel:SetScript("OnLeave", function ()
                e.tips:Hide()
            end)
            self.sel:SetScript("OnClick", function (self2)
                if self2.id and self2.text then
                    Save.gossipOption[self2.id]= not Save.gossipOption[self2.id] and self2.text or nil
                    if Save.gossipOption[self2.id] then
                        C_GossipInfo.SelectOption(self2.id)
                    end
                else
                    print(id, addName, '|cnRED_FONT_COLOR:'..NONE..'|r', ENABLE_DIALOG,'ID')
                end
            end)
        end

        local index=self:GetID()
        local gossip= C_GossipInfo.GetOptions()
        local name=info.name

        local npc=e.GetNpcID('npc')
        self.sel.id=info.gossipOptionID
        self.sel.text=info.name
        self.sel:SetChecked(Save.gossipOption[info.gossipOptionID])

        local find
        if IsModifierKeyDown() or selectGissipIDTab[info.gossipOptionID] then
            return

        elseif Save.gossipOption[info.gossipOptionID] then--自定义
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
                    if questInfo.questID and questInfo.isComplete and (Save.quest or Save.questOption[questInfo.questID]) then
                        return
                    end
                end

                tab= C_GossipInfo.GetAvailableQuests() or {}
                for _, questInfo in pairs(tab) do
                    if questInfo.questID and (Save.quest or Save.questOption[questInfo.questID]) and (isQuestTrivialTracking and questInfo.isTrivial or not questInfo.isTrivial) then
                        return
                    end
                end
            end

            C_GossipInfo.SelectOption(index)
            find=true
        end

        if find then
            selectGissipIDTab[info.gossipOptionID]=true
            print(id, ENABLE_DIALOG, '|T'..(info.overrideIconID or info.icon or '')..':0|t', '|cffff00ff'..name)
        end
    end)

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
                e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, QUESTS_LABEL)
                e.tips:AddDoubleLine(' ')
                if self2.id and self2.text then
                    e.tips:AddDoubleLine(self2.text, 'ID '..self2.id)
                else
                    e.tips:AddDoubleLine(NON, QUESTS_LABEL..' ID',1,0,0)
                end
                e.tips:Show()
            end)
            self.sel:SetScript("OnLeave", function ()
                e.tips:Hide()
            end)
            self.sel:SetScript("OnClick", function (self2)
                if self2.id and self2.text then
                    Save.questOption[self2.id]= not Save.questOption[self2.id] and self2.text or nil
                    if Save.questOption[self2.id] then
                        C_GossipInfo.SelectAvailableQuest(self2.id);
                    end
                else
                    print(id, addName, '|cnRED_FONT_COLOR:'..NONE..'|r',QUESTS_LABEL,'ID')
                end
            end)
        end

        local npc=e.GetNpcID('npc')
        self.sel.id= questID
        self.sel.text= info.title

        if IsModifierKeyDown() then
            return

        elseif Save.questOption[questID] then--自定义
           C_GossipInfo.SelectAvailableQuest(questID);--or self:GetID()

        elseif not Save.quest or not_Ace_QuestTrivial(questID) or getMaxQuest() or  Save.NPC[npc] then
            return

        else
            C_GossipInfo.SelectAvailableQuest(questID)
        end
    end)

    --完成已激活任务,多个任务GossipFrameShared.lua
    hooksecurefunc(GossipSharedActiveQuestButtonMixin, 'Setup', function(self, info)
        local npc=e.GetNpcID('npc')

        local questID=info.questID or self:GetID()
        if not questID or IsModifierKeyDown() then
            return

        elseif Save.questOption[questID] then--自定义
            C_GossipInfo.SelectActiveQuest(questID)
            return

        elseif not Save.quest or Save.NPC[npc] then--禁用任务, 禁用NPC
            return

        elseif C_QuestLog.IsComplete(questID) then
            C_GossipInfo.SelectActiveQuest(questID)
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
        questPanel:RegisterEvent('PLAYER_ENTERING_WORLD')
        questPanel:RegisterEvent('ZONE_CHANGED')
        questPanel:RegisterEvent('ZONE_CHANGED_NEW_AREA')
    else
        questPanel:UnregisterEvent('PLAYER_ENTERING_WORLD')
        questPanel:UnregisterEvent('ZONE_CHANGED')
        questPanel:UnregisterEvent('ZONE_CHANGED_NEW_AREA')
    end
    if Save.pushable then
        questPanel:RegisterEvent('GROUP_ROSTER_UPDATE')
    else
        questPanel:UnregisterEvent('GROUP_ROSTER_UPDATE')
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
        for questID, text in pairs(Save.questOption) do
            info={
                text= text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='questID  '..questID..'\n\n'..e.Icon.left..REMOVE,
                func=function()
                    Save.questOption[questID]=nil
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
                Save.questOption={}
                print(id, QUESTS_LABEL, CUSTOM, CLEAR_ALL)
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
       -- UIDropDownMenu_AddSeparator(level)

        info={--自定义,任务,选项
            text= e.onlyChinse and '自定义任务' or CUSTOM..QUESTS_LABEL,
            menuList='CUSTOM',
            notCheckable=true,
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

--[[
        UIDropDownMenu_AddSeparator(level)
        info={
            text=id..' '..QUESTS_LABEL,
            notCheckable=true,
            isTitle=true,
        }
        UIDropDownMenu_AddButton(info, level)

]]

    end
end

--###########
--任务，初始化
--###########
local function Init_Quest()
    questPanel.MenuQest=CreateFrame("Frame",nil, questPanel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(questPanel.MenuQest, InitMenu_Quest, 'MENU')

    questPanel:SetPoint('RIGHT', panel, 'LEFT')

    if Save.autoSortQuest then--仅显示本地图任务,事件
        set_Auto_QuestWatch_Event()
    end

    questPanel.Text=e.Cstr(questPanel, nil, nil,nil, true,nil, 'RIGHT')--任务数量
    questPanel.Text:SetPoint('RIGHT', questPanel, 'LEFT')
    questPanel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Save.quest= not Save.quest and true or nil
            setTexture()--设置图标
        elseif d=='RightButton' then
            ToggleDropDownMenu(1, nil, self.MenuQest, self, 15,0)
        end
    end)
    questPanel:SetScript('OnEnter', function(self)
        local all=C_QuestLog.GetAllCompletedQuestIDs()--完成次数
        if all and #all>0 then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine((e.onlyChinse and '今天' or GUILD_EVENT_TODAY)..' '..(GetDailyQuestsCompleted() or '0'), (e.onlyChinse and '总计: ' or  FROM_TOTAL)..#all)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinse and '任务菜单' or QUESTS_LABEL..SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end

       -- set_Only_Show_Zone_Quest()
    end)
    questPanel:SetScript('OnLeave', function() e.tips:Hide() end)

    questPanel:RegisterEvent("QUEST_LOG_UPDATE")
    questPanel:RegisterEvent('MINIMAP_UPDATE_TRACKING')
    questPanel:SetScript("OnEvent", function(self, event)
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
        Save.NPC[self.npc]= not Save.NPC[self.npc] and self.name or nil
        print(id, addName, self.name, self.npc, e.GetEnabeleDisable(Save.NPC[self.npc]))
    end)
    QuestFrame.sel:SetScript('OnEnter',function (self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        if self.npc and self.name then
            e.tips:AddDoubleLine(self.name, 'NPC '..self.npc)
        else
            e.tips:AddDoubleLine(NONE, 'NPC ID')
        end
        e.tips:Show()
    end)
    QuestFrame.sel:SetScript("OnLeave", function()
        e.tips:Hide()
    end)

    --任务框, 自动选任务    
    QuestFrameGreetingPanel:HookScript('OnShow', function(self)--QuestFrame.lua QuestFrameGreetingPanel_OnShow
        local npc=e.GetNpcID('npc')
        QuestFrame.sel.npc=npc
        QuestFrame.sel.name=UnitName("npc")
        QuestFrame.sel:SetChecked(Save.NPC[npc])

        if not npc or not Save.quest or IsModifierKeyDown() or Save.NPC[npc] then
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
        local npc=e.GetNpcID('npc')
        QuestFrame.sel.npc=npc
        QuestFrame.sel.name=UnitName("npc")
        QuestFrame.sel:SetChecked(Save.NPC[npc])

        local questID=GetQuestID()

        if not Save.quest or IsModifierKeyDown() or (Save.NPC[npc] and Save.questOption[qeustID]) then
            return
        end

        if not IsQuestCompletable() then--or not C_QuestOffer.GetHideRequiredItemsOnTurnIn() then
            if questID and not questSelect[questID] then
                local link--C_QuestLog.RequestLoadQuestByID(questID)
                local buttonIndex = 1;--物品数量
                for i=1, GetNumQuestItems() do
                    local hidden = IsQuestItemHidden(i);
                    if (hidden == 0) then
                        local requiredItem = _G["QuestProgressItem"..buttonIndex];
                        if requiredItem and requiredItem.type then
                            local itemLink = GetQuestItemLink(requiredItem.type, i)
                            local name,_ , numItems = GetQuestItemInfo(requiredItem.type, i)
                            if itemLink or name then
                                link=(link or '')..(numItems and '|cnRED_FONT_COLOR:'..numItems..'x|r' or '')..(itemLink or name)
                            end
                        end
                        buttonIndex = buttonIndex+1;
                    end
                end
                local text=GetProgressText()
                C_Timer.After(0.5, function()
                    print(id, QUESTS_LABEL, GetQuestLink(questID) or ('|cnGREEN_FONT_COLOR:'..questID..'|r'), text and '|cffff00ff'..text..'|r', link, QuestFrameGoodbyeButton and '|cnRED_FONT_COLOR:'..QuestFrameGoodbyeButton:GetText())
                end)
                questSelect[questID]=true
            end
            QuestGoodbyeButton_OnClick()
        else
            if questID and not questSelect[questID] then
                local link= GetQuestLink(questID)
                if link then
                    C_Timer.After(0.5, function()
                        print(id, addName, link)
                    end)
                end
                questSelect[questID]=true
            end
            QuestProgressCompleteButton_OnClick()--local b=QuestFrameCompleteQuestButton;
        end
    end)

    --自动接取任务, 仅一个任务
    hooksecurefunc('QuestInfo_Display', function(template, parentFrame, acceptButton, material, mapView)--QuestInfo.lua
        local npc=e.GetNpcID('npc')
        QuestFrame.sel.npc=npc
        QuestFrame.sel.name=UnitName("npc")
        QuestFrame.sel:SetChecked(Save.NPC[npc])

        local questID;
        if template.canHaveSealMaterial and not QuestUtil.QuestTextContrastEnabled() and template.questLog then
                local frame = parentFrame:GetParent():GetParent();
                questID = frame.questID;
        end
        questID= questID or GetQuestID()

        if not questID or IsModifierKeyDown() then
            return

        elseif (Save.NPC[npc] or not Save.quest) and not Save.questOption[questID] then
            return
        end

        local complete= C_QuestLog.IsComplete(questID)
        if (not_Ace_QuestTrivial(questID) and not Save.questOption[questID]) then--(not complete and getMaxQuest()) or
            return
        end

        if acceptButton and acceptButton:IsEnabled() then
            select_Reward()--自动:选择奖励

            if complete then
                if not questSelect[questID] then
                    local link=GetQuestLink(questID)
                    if link then
                        C_Timer.After(0.3, function()
                            print(id, QUESTS_LABEL, link, '|cnGREEN_FONT_COLOR:'..acceptButton:GetText()..'|r')
                        end)
                    end
                    questSelect[questID]=true
                end
            end

            acceptButton:Click()

            if not complete then
                if not questSelect[questID] then
                    C_Timer.After(0.5, function()
                        local link=GetQuestLink(questID)
                        if link then
                            print(id, QUESTS_LABEL, link, '|cnGREEN_FONT_COLOR:'..acceptButton:GetText()..'|r')
                        end
                    end)
                    questSelect[questID]=true
                end
            end
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
            Save.questOption = Save.questOption or {}
            Save.gossipOption= Save.gossipOption or {}

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

                Save.NPC= Save.NPC or {}
            else
                panel:UnregisterAllEvents()
                questPanel:UnregisterAllEvents()
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
