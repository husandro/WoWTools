local id, e = ...
local addName= ENABLE_DIALOG..QUESTS_LABEL
local Save={
        NPC={},

        gossip= true,
        unique= true,--唯一对话
        gossipOption={},
        choice={},--PlayerChoiceFrame

        quest= true,
        questOption={},
        questRewardCheck={},--{任务ID= index}
        autoSortQuest= e.Player.husandro,--仅显示当前地图任务
        autoSelectReward= e.Player.husandro,--自动选择奖励
}

local panel=e.Cbtn(nil, {icon='hide', size={15,15}})--闲话图标
local questPanel=e.Cbtn(panel, {icon='hide', size={15,15}})--任务图标
local questSelect={}--已选任务, 提示用

local function setTexture()--设置图标
    questPanel:SetNormalAtlas(Save.quest and 'campaignavailablequesticon' or e.Icon.icon)
    panel:SetNormalAtlas(Save.gossip and 'transmog-icon-chat' or e.Icon.icon)
end

local function setPoint()--设置位置
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('BOTTOMLEFT', _G['!KalielsTrackerFrame'] or ObjectiveTrackerBlocksFrame, 'TOPLEFT',30,0)
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
--[[local function getMaxQuest()--任务，是否已满
    return C_QuestLog.GetMaxNumQuests()==C_QuestLog.GetMaxNumQuestsCanAccept()
    --return select(2,C_QuestLog.GetNumQuestLogEntries())==C_QuestLog.GetMaxNumQuestsCanAccept()
end]]

--取得， 任务ID
local function questInfo_GetQuestID()--QuestInfo.lua
    if ( QuestInfoFrame.questLog ) then
		return C_QuestLog.GetSelectedQuest();
	else
		return GetQuestID();
	end
end

local function select_Reward(questID)--自动:选择奖励
    local numQuests = GetNumQuestChoices() or 0
    if numQuests <2 then
        local frame=_G['QuestInfoRewardsFrameQuestInfoItem1']
        if frame and frame.check then
            frame.check:SetShown(false)
        end
        return
    end

    local bestValue, bestLevel= 0, 0
    local notColleced, upItem, selectItemLink, bestItem

    for i = 1, numQuests do
        local frame= _G['QuestInfoRewardsFrameQuestInfoItem'..i]
        if frame and questID then
            if not frame.check then
                frame.check=CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
                frame.check:SetPoint("TOPRIGHT")
                frame.check:SetScript('OnClick', function(self)
                    if self.questID and self.index then
                        if Save.questRewardCheck[self.questID] and Save.questRewardCheck[self.questID]==self.index then
                            Save.questRewardCheck[self.questID]=nil
                        else
                            Save.questRewardCheck[self.questID]=self.index
                        end
                        for index=1, numQuests do
                            local frame2=  _G['QuestInfoRewardsFrameQuestInfoItem'..index]
                            if frame2 and frame2.check then
                                if index==self.index then
                                    if Save.questRewardCheck[self.questID] then
                                        frame2:Click()
                                        CompleteQuest()
                                    end
                                else
                                    frame2.check:SetChecked(false)
                                end
                            end
                        end
                    end
                end)
                frame.check:SetScript('OnEnter', function(self)
                    if self.questID then
                        e.tips:SetOwner(self, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine('questID: |cnGREEN_FONT_COLOR:'..self.questID..'|r', self.index)
                        e.tips:AddDoubleLine(id, QUESTS_LABEL)
                        e.tips:Show()
                    end
                end)
                frame.check:SetScript('OnLeave', function() e.tips:Hide() end)
            end
            frame.check:SetChecked(Save.questRewardCheck[questID] and Save.questRewardCheck[questID]==i)
            frame.check.index= i
            frame.check.questID= questID
            frame.check.numQuests= numQuests
            frame.check:SetShown(true)
        end
    end

    if Save.questRewardCheck[questID] and Save.questRewardCheck[questID]<=numQuests then
        bestItem= Save.questRewardCheck[questID]
        selectItemLink= GetQuestItemLink('choice', Save.questRewardCheck[questID])
        e.LoadDate({id=selectItemLink, type='item'})
    else
        for i = 1, numQuests do
            local  itemLink = GetQuestItemLink('choice', i)
            e.LoadDate({id=itemLink, type='item'})
            if itemLink then
                local amount = select(3, GetQuestItemInfo('choice', i))--钱
                local _, _, itemQuality, itemLevel, _, _,_,_, itemEquipLoc, _, sellPrice,classID, subclassID = GetItemInfo(itemLink)
                if Save.autoSelectReward and not(classID==19 or (classID==4 and subclassID==5) or itemLevel==1) and itemQuality and itemQuality<4 and IsEquippableItem(itemLink) then--最高 稀有的 3                                
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

                    if not (notColleced and upItem) and amount and sellPrice then
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
    if bestItem and not IsModifierKeyDown() then
        _G['QuestInfoRewardsFrameQuestInfoItem'..bestItem]:Click()--QuestFrame.lua
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
                tooltipTitle='gossipOptionID '..gossipOptionID..'|n|n'..e.Icon.left..(e.onlyChinese and '移除' or REMOVE),
                arg1= gossipOptionID,
                func=function(_, arg1)
                    Save.gossipOption[arg1]=nil
                    print(id, ENABLE_DIALOG, e.onlyChinese and '移除' or REMOVE, text, 'gossipOptionID:', arg1)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.gossipOption={}
                print(id, addName, e.onlyChinese and '自定义' or CUSTOM, e.onlyChinese and '清除全部' or CLEAR_ALL)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    elseif type=='DISABLE' then--禁用NPC, 闲话,任务, 选项
        for npcID, name in pairs(Save.NPC) do
            info={
                text=name,
                tooltipOnButton=true,
                tooltipTitle= 'NPC '..npcID,
                tooltipText= e.Icon.left.. (e.onlyChinese and '移除' or REMOVE),
                notCheckable= true,
                arg1= npcID,
                func= function(_, arg1)
                    Save.NPC[arg1]=nil
                    print(id, addName, e.onlyChinese and '移除' or REMOVE, 'NPC:', arg1)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            func= function()
                Save.NPC={}
                print(id, addName, e.onlyChinese and '自定义' or CUSTOM, e.onlyChinese and '清除全部' or CLEAR_ALL)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='PlayerChoiceFrame' then
        for spellID, rarity in pairs(Save.choice) do
            e.LoadDate({id=spellID, type='spell'})
            local icon= GetSpellTexture(spellID)
            local name= GetSpellLink(spellID) or ('spellID '..spellID)
            rarity= rarity+1
            local hex= select(4, GetItemQualityColor(rarity))
            local quality=(hex and '|c'..hex or '')..(_G['ITEM_QUALITY'..rarity..'_DESC'] or rarity)
            info={
                text=(icon and '|T'..icon..':0|t' or '').. name..' '.. quality,
                tooltipOnButton=true,
                tooltipTitle= e.Icon.left.. (e.onlyChinese and '移除' or REMOVE),
                tooltipText= 'spellID '..spellID,                
                notCheckable= true,

                arg1=spellID,
                func= function(_, arg1)
                    Save.choice[arg1]=nil
                    print(id, addName, e.onlyChinese and '选择' or CHOOSE, e.onlyChinese and '移除' or REMOVE, GetSpellLink(arg1) or ('spellID '..arg1))
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.choice={}
                print(id, addName, e.onlyChinese and '选择' or CHOOSE, e.onlyChinese and '清除全部' or CLEAR_ALL)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    info={--启用,禁用
        text=e.Icon.left..(e.onlyChinese and '自动对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ENABLE_DIALOG)),
        checked=Save.gossip,
        keepShownOnClick=true,
        func= function()
            Save.gossip= not Save.gossip and true or nil
            setTexture()--设置图标
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    info={--唯一
        text= e.onlyChinese and '唯一对话' or ITEM_UNIQUE..ENABLE_DIALOG,
        checked= Save.unique,
        keepShownOnClick=true,
        func= function()
            Save.unique= not Save.unique and true or nil
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={--自定义,闲话,选项
        text= e.onlyChinese and '自定义对话' or (CUSTOM..ENABLE_DIALOG),
        menuList='CUSTOM',
        notCheckable=true,
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={--禁用NPC, 闲话,任务, 选项
        text= e.onlyChinese and '禁用 NPC' or (DISABLE..' NPC'),
        menuList='DISABLE',
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '对话' or ENABLE_DIALOG,
        tooltipText= e.onlyChinese and '任务' or QUESTS_LABEL,
        notCheckable=true,
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={--PlayerChoiceFrame
        text= e.onlyChinese and '选择' or CHOOSE,
        menuList='PlayerChoiceFrame',
        tooltipOnButton=true,
        tooltipTitle='PlayerChoiceFrame',
        tooltipText= 'Blizzard_PlayerChoice',
        notCheckable=true,
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text=e.Icon.right..(e.onlyChinese and '移动' or NPE_MOVE),
        notCheckable=true,
        isTitle=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    info={
        text= e.onlyChinese and '重置位置' or RESET_POSITION,
        notCheckable=true,
        colorCode=not Save.point and '|cff606060',
        keepShownOnClick=true,
        func= function()
            Save.point=nil
            panel:ClearAllPoints()
            setPoint()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text=id..' '..(e.onlyChinese and '对话' or ENABLE_DIALOG),
        isTitle=true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end


--###########
--对话，初始化
--###########
local function Init_Gossip()

    --panel:SetFrameStrata('HIGH')
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
        e.LibDD:CloseDropDownMenus()
        self:Raise()
    end)
    panel:SetScript('OnMouseDown', function(self, d)
        local key=IsModifierKeyDown()
        if d=='LeftButton' and not key then
            Save.gossip= not Save.gossip and true or nil
            setTexture()
        elseif d=='RightButton' and not key then
            if not self.MenuGossip then
                self.MenuGossip=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.MenuGossip, InitMenu_Gossip, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.MenuGossip, self, 15, 0)
        end
    end)
    panel:SetScript('OnMouseUp', function()
        ResetCursor()
    end)

    --禁用此npc闲话选项
    GossipFrame.sel=CreateFrame("CheckButton", nil, GossipFrame, 'InterfaceOptionsCheckButtonTemplate')
    GossipFrame.sel:SetPoint("BOTTOMLEFT",5,2)
    GossipFrame.sel.Text:SetText(DISABLE)
    GossipFrame.sel:SetScript("OnMouseDown", function (self, d)
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
            e.tips:AddDoubleLine(self.name, 'NPC |cnGREEN_FONT_COLOR:'..self.npc..'|r')
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
                if self2.spellID then
                    e.tips:SetSpellByID(self2.spellID)
                    e.tips:AddLine(' ')
                end
                if self2.id and self2.text then
                    e.tips:AddDoubleLine((self2.icon and '|T'..self2.icon..':0|t' or '')..self2.text, 'gossipOption: |cnGREEN_FONT_COLOR:'..self2.id..'|r')
                else
                    e.tips:AddDoubleLine(NONE, 'gossipOptionID',1,0,0)
                end
                e.tips:Show()
            end)
            self.sel:SetScript("OnLeave", function ()
                e.tips:Hide()
            end)
            self.sel:SetScript("OnMouseDown", function (self2)
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

        local index= info.gossipOptionID or self:GetID()
        local gossip= C_GossipInfo.GetOptions() or {}
        local allGossip= #gossip
        local name=info.name
        local npc=e.GetNpcID('npc')
        self.sel.id=index
        self.sel.text=info.name
        self.sel.spellID= info.spellID
        self.sel.icon= info.overrideIconID or info.icon

        if IsModifierKeyDown() or not index or selectGissipIDTab[index] then
            return
        end

        local find
        local quest= FlagsUtil.IsSet(info.flags, Enum.GossipOptionRecFlags.QuestLabelPrepend)
        if Save.gossipOption[index] then--自定义
            C_GossipInfo.SelectOption(index)
            find=true

        elseif (npc and Save.NPC[npc]) or not Save.gossip then--禁用NPC
            return

        elseif Save.quest and  (quest or name:find('0000FF') or  name:find(QUESTS_LABEL) or name:find(LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST)) then--任务
            if quest then
                name=GOSSIP_QUEST_OPTION_PREPEND:format(info.name)
            end
            C_GossipInfo.SelectOption(index)
            find=true

        elseif allGossip==1 and Save.unique  then--仅一个
           -- if not getMaxQuest() then
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
           -- end

            C_GossipInfo.SelectOption(index)
            find=true

        elseif IsInInstance() then
            if index==107571--挑战，模式，去 SX buff
                --and C_ChallengeMode.IsChallengeModeActive()
                and e.WA_GetUnitDebuff('player', nil, 'HARMFUL', {
                           [57723]= true,
                           [57724]= true,
                           [264689]= true,
                           [80354]= true,
                           [390435]= true,
                        })
            then
                C_GossipInfo.SelectOption(index)
                find=true

            elseif index==107572 then--挑战，模式, 修理
                local value= select(2, e.GetDurabiliy())
                if value<85 then
                    C_GossipInfo.SelectOption(index)
                    find=true
                end

            elseif index==56363 then--奥达曼， 传送门3
                C_GossipInfo.SelectOption(index)
                find=true
            elseif index==56364 and allGossip==2 then--奥达曼， 传送门2
                C_GossipInfo.SelectOption(index)
                find=true
            elseif index==56365 and allGossip==1 then--奥达曼， 传送门1
                C_GossipInfo.SelectOption(index)
                find=true
            end

        end

        if find then
            selectGissipIDTab[index]=true
            print(id, ENABLE_DIALOG, '|T'..(info.overrideIconID or info.icon or '')..':0|t', '|cffff00ff'..name..'|r', index)
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
                    e.tips:AddDoubleLine(self2.text, 'ID |cnGREEN_FONT_COLOR:'..self2.id..'|r')
                else
                    e.tips:AddDoubleLine(NONE, QUESTS_LABEL..' ID',1,0,0)
                end
                e.tips:Show()
            end)
            self.sel:SetScript("OnLeave", function ()
                e.tips:Hide()
            end)
            self.sel:SetScript("OnMouseDown", function (self2)
                if self2.id and self2.text then
                    Save.questOption[self2.id]= not Save.questOption[self2.id] and self2.text or nil
                    if Save.questOption[self2.id] then
                        C_GossipInfo.SelectAvailableQuest(self2.id)
                    end
                else
                    print(id, addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE)..'|r', e.onlyChinese and '任务' or QUESTS_LABEL,'ID')
                end
            end)
        end

        local npc=e.GetNpcID('npc')
        self.sel.id= questID
        self.sel.text= info.title

        if IsModifierKeyDown() then
            return

        elseif Save.questOption[questID] then--自定义
           C_GossipInfo.SelectAvailableQuest(questID)--or self:GetID()

        elseif not Save.quest or not_Ace_QuestTrivial(questID) or Save.NPC[npc] then--or getMaxQuest()
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
local setQuestWatchTime
local function set_Only_Show_Zone_Quest()--显示本区域任务
    if not Save.autoSortQuest or IsInInstance() or setQuestWatchTime then
        return
    end
    setQuestWatchTime= true
    C_Timer.After(0.8, function()
        local uiMapID= C_Map.GetBestMapForUnit('player')
        if not uiMapID or uiMapID==0 then
            return
        end
        for index=1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(index)
            if info and info.questID and not info.isHeader and not info.campaignID and not info.isHidden and not C_QuestLog.IsQuestCalling(info.questID) then
                if info.isOnMap and GetQuestUiMapID(info.questID)==uiMapID and not C_QuestLog.IsComplete(info.questID) then
                    C_QuestLog.AddQuestWatch(info.questID)
                else
                    C_QuestLog.RemoveQuestWatch(info.questID)
                end
            end
        end
        C_QuestLog.SortQuestWatches()
        setQuestWatchTime=nil
    end)
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
        --questPanel:RegisterEvent('QUEST_LOG_UPDATE')
        questPanel:RegisterEvent('SCENARIO_UPDATE')
    else
        questPanel:UnregisterEvent('PLAYER_ENTERING_WORLD')
        questPanel:UnregisterEvent('ZONE_CHANGED')
        questPanel:UnregisterEvent('ZONE_CHANGED_NEW_AREA')
        --questPanel:UnregisterEvent('SCENARIO_UPDATE')
        --questPanel:UnregisterEvent('QUEST_LOG_UPDATE')
    end
    if Save.pushable then
        questPanel:RegisterEvent('GROUP_ROSTER_UPDATE')
    else
        questPanel:UnregisterEvent('GROUP_ROSTER_UPDATE')
    end
end

local function InitMenu_Quest(self, level, type)
    local info
    if type=='REWARDSCHECK' then--三级菜单 ->自动:选择奖励
        local num=0
        for questID, index in pairs(Save.questRewardCheck) do
            e.LoadDate({id=questID, type='quest'})
            info={
                text= (C_QuestLog.GetTitleForQuestID(questID) or ('questID: '..questID))..': |cnGREEN_FONT_COLOR:'..index,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='questID: '..questID,
                func= function()
                    Save.questRewardCheck[questID]=nil
                end,
            }
            num=num+1
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.questRewardCheck={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='CUSTOM' then
        for questID, text in pairs(Save.questOption) do
            info={
                text= text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='questID  '..questID..'|n|n'..e.Icon.left..REMOVE,
                func=function()
                    Save.questOption[questID]=nil
                    print(id, QUESTS_LABEL, e.onlyChinese and '移除' or REMOVE, text, 'ID', questID)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func= function()
                Save.questOption={}
                print(id, QUESTS_LABEL, e.onlyChinese and '自定义' or CUSTOM, e.onlyChinese and '清除全部' or CLEAR_ALL)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='QUEST' then
        info={
            text='|A:TrivialQuests:0:0|a'..(e.onlyChinese and '其他任务' or MINIMAP_TRACKING_TRIVIAL_QUESTS),--低等任务
            checked= isQuestTrivialTracking,
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinese and '追踪' or TRACKING,
            tooltipText= e.onlyChinese and '低等任务' or (LOW..LEVEL..QUESTS_LABEL),
            func= function ()
                get_set_IsQuestTrivialTracking(true)--其它任务,低等任务,追踪
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    info={
        text=e.Icon.left..(e.onlyChinese and '自动接受' or QUICK_JOIN_IS_AUTO_ACCEPT_TOOLTIP),
        checked= Save.quest,
        menuList= 'QUEST',
        hasArrow= true,
        func= function()
            Save.quest= not Save.quest and true or nil
            setTexture()--设置图标
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={--自动:选择奖励
        text= e.onlyChinese and '自动选择奖励' or format(TITLE_REWARD, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, CHOOSE)),
        checked= Save.autoSelectReward,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '最高品质' or format(PROFESSIONS_CRAFTING_QUALITY, VIDEO_OPTIONS_ULTRA_HIGH),
        tooltipText= '|cff0000ff'..(e.onlyChinese and '稀有' or GARRISON_MISSION_RARE)..'|r',
        menuList='REWARDSCHECK',
        hasArrow=true,
        func= function()
            Save.autoSelectReward= not Save.autoSelectReward and true or nil
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '共享任务' or SHARE_QUEST,
        checked=Save.pushable,
        colorCode= not IsInGroup() and '|cff606060',
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '仅限在队伍中' or format(LFG_LIST_CROSS_FACTION, AGGRO_WARNING_IN_PARTY),
        func= function()
            Save.pushable= not Save.pushable and true or nil
            set_PushableQuest()--共享,任务
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '追踪' or TRACKING,
        isTitle= true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '自动任务追踪' or AUTO_QUEST_WATCH_TEXT,
        checked=C_CVar.GetCVarBool("autoQuestWatch"),
        tooltipOnButton=true,
        tooltipTitle= format(e.onlyChinese and '接受任务：%s' or ERR_QUEST_ACCEPTED_S, 'Cvar autoQuestWatch'),
        func=function()
            C_CVar.SetCVar("autoQuestWatch", C_CVar.GetCVarBool("autoQuestWatch") and '0' or '1')
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '当前地图' or (REFORGE_CURRENT..WORLD_MAP),
        checked= Save.autoSortQuest,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '仅显示当前地图任务' or format(GROUP_FINDER_CROSS_FACTION_LISTING_WITH_PLAYSTLE, SHOW,FLOOR..QUESTS_LABEL),--仅限-本区域任务
        tooltipText= e.onlyChinese and '触发事件: 更新区域' or (EVENTS_LABEL..':' ..UPDATE..FLOOR),
        func=function()
            Save.autoSortQuest= not Save.autoSortQuest and true or nil
            set_Auto_QuestWatch_Event()--仅显示本地图任务,事件
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)

    info={--自定义,任务,选项
        text= e.onlyChinese and '自定义任务' or CUSTOM..QUESTS_LABEL,
        menuList='CUSTOM',
        notCheckable=true,
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end

--###########
--任务，初始化
--###########
local function Init_Quest()
    questPanel:SetPoint('RIGHT', panel, 'LEFT')

    questPanel.Text=e.Cstr(questPanel, {justifyH='RIGHT'})--nil, nil,nil, nil,nil, 'RIGHT')--任务数量
    questPanel.Text:SetPoint('RIGHT', questPanel, 'LEFT')
    questPanel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Save.quest= not Save.quest and true or nil
            setTexture()--设置图标
        elseif d=='RightButton' then
            if not self.MenuQest then
                self.MenuQest=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.MenuQest, InitMenu_Quest, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.MenuQest, self, 15, 0)
        end
    end)
    questPanel:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local all=C_QuestLog.GetAllCompletedQuestIDs() or {}--完成次数
        e.tips:AddDoubleLine((e.onlyChinese and '日常' or DAILY)..': |cnGREEN_FONT_COLOR:'..GetDailyQuestsCompleted()..'|r'..e.Icon.select2, (e.onlyChinese and '已完成' or  CRITERIA_COMPLETED)..' '..e.MK(#all, 3))
        e.tips:AddLine(' ')

        e.tips:AddDoubleLine((e.onlyChinese and '上限' or CAPPED)..': '..select(2,  C_QuestLog.GetNumQuestLogEntries())..'/'..C_QuestLog.GetMaxNumQuestsCanAccept(), (e.onlyChinese and '追踪' or TRACK_QUEST_ABBREV)..': '..C_QuestLog.GetNumQuestWatches())
        e.tips:AddLine(' ')

        local numQuest,dayNum,weekNum, companionNum, numAll = 0, 0, 0, 0, 0
        for index=1, select(2,C_QuestLog.GetNumQuestLogEntries()) do
            local info = C_QuestLog.GetInfo(index)
            if info and  not info.isHeader then
                if info.frequency== 0 then
                    numQuest= numQuest+ 1
                elseif info.frequency== 1 then
                    dayNum= dayNum+ 1
               elseif info.frequency== 2 then
                    weekNum= weekNum+ 1
               end
               if info.campaignID then
                    companionNum= companionNum+ 1
               end
               if not info.isHidden then
                    numAll= numAll+ 1
               end
            end
        end

        --[[Day={0.10, 0.72, 1},--日常 |cff19b7ff
        Week={0.02, 1, 0.66},--周长 |cff05ffa8
        Legendary={1, 0.49, 0},--传说 |cffff7c00
        Calling={1, 0, 0.9},--使命 |cffff00e5
        ]]
        e.tips:AddLine('|cff19b7ff'..(e.onlyChinese and '日常' or DAILY)..': '..dayNum)
        e.tips:AddLine('|cff05ffa8'..(e.onlyChinese and '周长' or WEEKLY)..': '..weekNum)
        e.tips:AddLine('|cffff7c00'..(e.onlyChinese and '战役' or TRACKER_HEADER_CAMPAIGN_QUESTS)..': '..companionNum)

        e.tips:AddLine('|cffffffff'..(e.onlyChinese and '一般' or RESISTANCE_FAIR)..': '..numQuest..'/25')
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetEnabeleDisable(Save.quest)..e.Icon.left, (e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..e.Icon.right)
        e.tips:AddDoubleLine(id, e.onlyChinese and '任务' or QUESTS_LABEL)
        e.tips:Show()

        set_Only_Show_Zone_Quest()
    end)
    questPanel:SetScript('OnLeave', function() e.tips:Hide() end)

    questPanel:RegisterEvent("QUEST_LOG_UPDATE")
    questPanel:RegisterEvent('MINIMAP_UPDATE_TRACKING')
    questPanel:SetScript("OnEvent", function(self, event)
        if event=='MINIMAP_UPDATE_TRACKING' then
            get_set_IsQuestTrivialTracking()--其它任务,低等任务,追踪

        elseif event=='QUEST_LOG_UPDATE' then--更新数量
            --local n = select(2,C_QuestLog.GetNumQuestLogEntries())
            --local max = C_QuestLog.GetMaxNumQuestsCanAccept()
            self.Text:SetText((select(2,C_QuestLog.GetNumQuestLogEntries()) or ''))-- and n..'/'..max or '')
        elseif event=='GROUP_ROSTER_UPDATE' then
            set_PushableQuest()--共享,任务
        else
            set_Auto_QuestWatch_Event()--仅显示本地图任务,事件
        end
    end)

    QuestFrame.sel=CreateFrame("CheckButton", nil, QuestFrame, 'InterfaceOptionsCheckButtonTemplate')--禁用此npc,任务,选项
    QuestFrame.sel:SetPoint("TOPLEFT", QuestFrame, 40, 20)
    QuestFrame.sel.Text:SetText(e.onlyChinese and '禁用' or DISABLE)
    QuestFrame.sel:SetScript("OnMouseDown", function (self, d)
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
        local questID=questInfo_GetQuestID()
        if questID then
            e.tips:AddDoubleLine('questID', questID)
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

        local numActiveQuests = GetNumActiveQuests()
        local numAvailableQuests = GetNumAvailableQuests()
        if numActiveQuests > 0 then
            for index=1, numActiveQuests do
                if select(2,GetActiveTitle(index)) then
                    SelectActiveQuest(index)
                    return
                end
            end
        end
        if numAvailableQuests > 0 then-- and not getMaxQuest() 
            for i=(numActiveQuests + 1), (numActiveQuests + numAvailableQuests) do
                local index = i - numActiveQuests
                local isTrivial= GetAvailableQuestInfo(index)
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

        local questID= questInfo_GetQuestID()

        if not questID or not Save.quest or IsModifierKeyDown() or (Save.NPC[npc] and not Save.questOption[questID]) then
            return
        end

        if not IsQuestCompletable() then--or not C_QuestOffer.GetHideRequiredItemsOnTurnIn() then
            if questID then--and not questSelect[questID] then
                local link--C_QuestLog.RequestLoadQuestByID(questID)
                local buttonIndex = 1--物品数量
                for i=1, GetNumQuestItems() do
                    local hidden = IsQuestItemHidden(i)
                    if (hidden == 0) then
                        local requiredItem = _G["QuestProgressItem"..buttonIndex]
                        if requiredItem and requiredItem.type then
                            local itemLink = GetQuestItemLink(requiredItem.type, i)
                            local name,_ , numItems = GetQuestItemInfo(requiredItem.type, i)
                            if itemLink or name then
                                link=(link or '')..(numItems and '|cnRED_FONT_COLOR:'..numItems..'x|r' or '')..(itemLink or name)
                            end
                        end
                        buttonIndex = buttonIndex+1
                    end
                end
                local text=GetProgressText()
                C_Timer.After(0.5, function()
                    local questLink=GetQuestLink(questID)
                    if not questLink then
                        local index= C_QuestLog.GetLogIndexForQuestID(questID)
                        local info2= index and C_QuestLog.GetInfo(index)
                        if info2 and info2.title and info2.level then
                            questLink= '|Hquest:'..questID..':'..info2.level..'|h['..info2.title..']|h'
                        end
                        questLink=questLink or ('|cnGREEN_FONT_COLOR:'..questID..'|r')
                    end
                    print(id, QUESTS_LABEL, questLink, text and '|cffff00ff'..text..'|r', link, QuestFrameGoodbyeButton and '|cnRED_FONT_COLOR:'..QuestFrameGoodbyeButton:GetText())
                end)
               -- questSelect[questID]=true
            end
            QuestGoodbyeButton_OnClick()
        else
            if not questSelect[questID] then
                C_Timer.After(0.5, function()
                    print(id, addName, GetQuestLink(questID) or questID)
                end)
                questSelect[questID]=true
            end
            QuestProgressCompleteButton_OnClick()--local b=QuestFrameCompleteQuestButton
        end
    end)

    --自动接取任务, 仅一个任务
    hooksecurefunc('QuestInfo_Display', function(template, parentFrame, acceptButton, material, mapView)--QuestInfo.lua
        local npc=e.GetNpcID('npc')
        QuestFrame.sel.npc=npc
        QuestFrame.sel.name=UnitName("npc")
        QuestFrame.sel:SetChecked(Save.NPC[npc])

        local questID= questInfo_GetQuestID()
        if not questID and template.canHaveSealMaterial and not QuestUtil.QuestTextContrastEnabled() and template.questLog then
            local frame = parentFrame:GetParent():GetParent()
            questID = frame.questID
        end

        if not questID
            or not Save.quest
            or (Save.NPC[npc] and not Save.questOption[questID])
            or IsModifierKeyDown()
            or not_Ace_QuestTrivial(questID)
            or not acceptButton
            or not acceptButton:IsEnabled()
        then return end

        local complete=IsQuestCompletable() or  C_QuestLog.IsComplete(questID)--QuestFrame.lua QuestFrameProgressPanel_OnShow(self) C_QuestLog.IsComplete(questID)
        if complete then
            select_Reward(questID)--自动:选择奖励
        end

        local itemLink=''--QuestInfo.lua QuestInfo_ShowRewards()
        for index=1, GetNumQuestChoices() do--物品
            local questItem = QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame, index)
            if questItem then
                local link=GetQuestItemLink(questItem.type, index)
                if link then
                    itemLink= itemLink..link
                end
            end
        end

        local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}--QuestInfo.lua QuestInfo_ShowRewards()
        for _, spellID in pairs(spellRewards) do
            e.LoadDate({id=spellID, type='spell'})
            local spellLink= GetSpellLink(spellID)
            itemLink= itemLink.. (spellLink or (' spellID'..spellID))
        end

        local skillName, skillIcon, skillPoints = GetRewardSkillPoints()--专业
        if skillName then
            itemLink= itemLink..(GetSpellLink(skillName) or ((skillIcon and '|T'..skillIcon..':0|t' or '')..skillName))..(skillPoints and '|cnGREEN_FONT_COLOR:+'..skillPoints..'|r' or '')
        end

        local majorFactionRepRewards = C_QuestOffer.GetQuestOfferMajorFactionReputationRewards()--名望
        if majorFactionRepRewards then
			for _, rewardInfo in ipairs(majorFactionRepRewards) do
                if rewardInfo.factionID and rewardInfo.rewardAmount then
                    local data = C_MajorFactions.GetMajorFactionData(rewardInfo.factionID)
                    if data and data.name then
                        itemLink= itemLink..(data.textureKit and '|A:MajorFactions_Icons_'..data.textureKit..'512:0:0|a' or '')..(not data.textureKit and data.name or '')..'|cnGREEN_FONT_COLOR:+'..rewardInfo.rewardAmount..'|r'
                    end
                end
            end
        end

        if not questSelect[questID] then
            C_Timer.After(0.5, function()
                print(id, QUESTS_LABEL, GetQuestLink(questID) or questID, (complete and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')..acceptButton:GetText()..'|r', itemLink)
            end)
            questSelect[questID]=true
        end

        acceptButton:Click()
    end)

    

    if Save.autoSortQuest then--仅显示本地图任务,事件
        set_Auto_QuestWatch_Event()
    end
    C_Timer.After(2, set_Only_Show_Zone_Quest)--显示本区域任务
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
            Save= WoWToolsSave[addName] or Save
            Save.questOption = Save.questOption or {}
            Save.gossipOption= Save.gossipOption or {}
            Save.questRewardCheck= Save.questRewardCheck or {}
            Save.choice= Save.choice or {}
             --添加控制面板        
            local sel=e.CPanel('|A:CampaignAvailableQuestIcon:0:0|a'..(e.onlyChinese and '对话和任务' or addName), not Save.disabled, true)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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
                panel:SetShown(false)
                questPanel:SetShown(false)
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_PlayerChoice' then--命运, 字符
            hooksecurefunc(StaticPopupDialogs["CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING"],"OnShow",function(s)
                if Save.gossip and s.editBox then
                    s.editBox:SetText(SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING)
                end
            end)


            --自动选择奖励
            --Blizzard_PlayerChoice.lua
            panel.Send_Player_Choice_Response= function(optionInfo)
                if not optionInfo then
                    return
                end
                C_PlayerChoice.SendPlayerChoiceResponse(optionInfo.buttons[1].id)
                print(id, addName, (optionInfo.spellID and GetSpellLink(optionInfo.spellID) or ''), '|n',
                        '|T'..(optionInfo.choiceArtID or 0)..':0|t'..optionInfo.rarityColor:WrapTextInColorCode(optionInfo.description or '')
                    )
                PlayerChoiceFrame:OnSelectionMade();
                C_PlayerChoice.OnUIClosed()
                for optionFrame in PlayerChoiceFrame.optionPools:EnumerateActiveByTemplate(PlayerChoiceFrame.optionFrameTemplate) do
                    optionFrame:SetShown(false)
                end
            end
            hooksecurefunc(PlayerChoiceFrame, 'SetupOptions', function(self2)
                if IsModifierKeyDown() or not Save.gossip
                then
                    return
                end
                local tab={}
                local soloOption = (#self2.choiceInfo.options == 1)
                for optionFrame in self2.optionPools:EnumerateActiveByTemplate(self2.optionFrameTemplate) do
                    local enabled= not optionFrame.optionInfo.disabledOption and optionFrame.optionInfo.spellID and optionFrame.optionInfo.spellID>0
                    if not optionFrame.check and enabled then
                        optionFrame.check= CreateFrame("CheckButton", nil, optionFrame, "InterfaceOptionsCheckButtonTemplate")
                        optionFrame.check:SetPoint('BOTTOM' ,0, -40)
                        optionFrame.check:SetScript('OnClick', function(self3)
                            local optionInfo= self3:GetParent().optionInfo
                            if optionInfo and optionInfo.spellID then
                                Save.choice[optionInfo.spellID]= not Save.choice[optionInfo.spellID] and (optionInfo.rarity or 0) or nil
                                if Save.choice[optionInfo.spellID] then
                                    panel.Send_Player_Choice_Response(optionInfo)
                                end
                            else
                                print(id, addName,'|cnRED_FONT_COLOR:', not e.onlyChinese and ERRORS..' ('..UNKNOWN..')' or '未知错误')
                            end
                        end)
                        optionFrame.check:SetScript('OnLeave', function() e.tips:Hide() end)
                        optionFrame.check:SetScript('OnEnter', function(self3)
                            local optionInfo= self3:GetParent().optionInfo
                            e.tips:SetOwner(self3:GetParent(), "ANCHOR_BOTTOMRIGHT")
                            e.tips:ClearLines()
                            if optionInfo and optionInfo.spellID then
                                e.tips:SetSpellByID(optionInfo.spellID)
                            end
                            e.tips:AddLine(' ')
                            e.tips:AddDoubleLine(id, addName)
                            e.tips:Show()
                        end)
                        optionFrame.check.elapsed=0
                        optionFrame.check.Text2=e.Cstr(optionFrame.check)
                        optionFrame.check.Text2:SetPoint('RIGHT', optionFrame.check, 'LEFT')
                        optionFrame.check.Text2:SetTextColor(0,1,0)
                        optionFrame.check:SetScript('OnUpdate', function(self3, elapsed)
                            self3.elapsed = self3.elapsed + elapsed
                            if self3.elapsed>=1 then
                                local text, count
                                local aura= self3.spellID and C_UnitAuras.GetPlayerAuraBySpellID(self3.spellID)
                                if aura then
                                    local value= aura.expirationTime-aura.duration
                                    local time= GetTime()
                                    time= time < value and time + 86400 or time
                                    time= time - value
                                    text= e.SecondsToClock(aura.duration- time)
                                    count= select(3, e.WA_GetUnitBuff('player', self3.spellID, 'HELPFUL'))
                                    count= count and count>1 and count or nil
                                end
                                self3.Text:SetText(text or '')
                                self3.Text2:SetText(count or '')
                                self3.elapsed=0
                            end
                        end)
                    end

                    
                    if optionFrame.check then
                        optionFrame.check.elapsed=1.1
                        optionFrame.check.spellID= optionFrame.optionInfo.spellID
                        optionFrame.check:SetShown(enabled)
                        if enabled then
                            local saveChecked= Save.choice[optionFrame.optionInfo.spellID]
                            optionFrame.check:SetChecked(saveChecked)
                            if saveChecked or (soloOption and Save.unique) then
                                optionFrame.optionInfo.rarity = optionFrame.optionInfo.rarity or 0
                                table.insert(tab, optionFrame.optionInfo)
                            end
                        end
                    end
                end
                if #tab>0 then
                    table.sort(tab, function(a,b)
                        if a.rarity== b.rarity then
                            return a.spellID> b.spellID
                        else
                            return a.rarity> b.rarity
                        end
                    end)
                    panel.Send_Player_Choice_Response(tab[1])
                end
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then

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
