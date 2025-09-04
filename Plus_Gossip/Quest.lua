

local function Save()
    return WoWToolsSave['Plus_Gossip']
end

local IsQuestTrivialTracking

















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
                        if Save().questRewardCheck[self.questID] and Save().questRewardCheck[self.questID]==self.index then
                            Save().questRewardCheck[self.questID]=nil
                        else
                            Save().questRewardCheck[self.questID]=self.index
                        end
                        for index=1, numQuests do
                            local frame2=  _G['QuestInfoRewardsFrameQuestInfoItem'..index]
                            if frame2 and frame2.check then
                                if index==self.index then
                                    if Save().questRewardCheck[self.questID] then
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
                        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                        GameTooltip:ClearLines()
                        GameTooltip:AddDoubleLine('questID: |cnGREEN_FONT_COLOR:'..self.questID..'|r', self.index)
                        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName2)
                        GameTooltip:Show()
                    end
                end)
                frame.check:SetScript('OnLeave', GameTooltip_Hide)
            end
            frame.check:SetChecked(Save().questRewardCheck[questID] and Save().questRewardCheck[questID]==i)
            frame.check.index= i
            frame.check.questID= questID
            frame.check.numQuests= numQuests
            frame.check:SetShown(true)
        end
    end

    if Save().questRewardCheck[questID] and Save().questRewardCheck[questID]<=numQuests then
        bestItem= Save().questRewardCheck[questID]
        selectItemLink= GetQuestItemLink('choice', Save().questRewardCheck[questID])
        WoWTools_DataMixin:Load({id=selectItemLink, type='item'})
    else
        for i = 1, numQuests do
            local  itemLink = GetQuestItemLink('choice', i)
            WoWTools_DataMixin:Load({id=itemLink, type='item'})
            if itemLink then
                local amount = select(3, GetQuestItemInfo('choice', i))--钱
                local _, _, itemQuality, itemLevel, _, _,_,_, itemEquipLoc, _, sellPrice,classID, subclassID = C_Item.GetItemInfo(itemLink)
                if Save().autoSelectReward and not(classID==19 or (classID==4 and subclassID==5) or itemLevel==1) and itemQuality and itemQuality<4 and C_Item.IsEquippableItem(itemLink) then--最高 稀有的 3                                
                    local invSlot = WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
                    if invSlot and itemLevel and itemLevel>1 then--装等
                        local itemLinkPlayer = GetInventoryItemLink('player', invSlot)
                        if itemLinkPlayer then
                            local lv=C_Item.GetDetailedItemLevelInfo(itemLinkPlayer)
                            if lv and lv>1 and itemLevel-lv>0 and (bestLevel and bestLevel<lv or not bestLevel) then
                                bestLevel=lv
                                bestItem = i
                                selectItemLink=itemLink
                                upItem=true
                            end
                        end
                    end

                    if not upItem then
                        local isCollected, isSelf= select(2, WoWTools_CollectedMixin:Item(itemLink))--物品是否收集 
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
            print(WoWTools_DataMixin.Icon.icon2..'|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '选择' or CHOOSE)..'|r', selectItemLink)
        end
    end
end


























--###########
--任务，初始化
--###########
local function Init_Quest()

    local QuestButton= WoWTools_ButtonMixin:Cbtn(_G['WoWToolsGossipButton'], {
        size=22,
        name='WoWTools_GossipQuestButton',
        icon='hide',
    })
    WoWTools_GossipMixin.QuestButton= QuestButton

    QuestButton.texture= QuestButton:CreateTexture(nil, 'BORDER')
    QuestButton.texture:SetAllPoints()

    QuestButton.Text=WoWTools_LabelMixin:Create(QuestButton, {justifyH='RIGHT', color=true, size=14})--任务数量
    QuestButton.Text:SetPoint('RIGHT', QuestButton, 'LEFT', 0, 1)

--Bg
    _G['WoWToolsGossipButton'].Background:SetPoint('TOPLEFT', QuestButton.Text, -2, 4)


    QuestButton:SetPoint('RIGHT', _G['WoWToolsGossipButton'], 'LEFT')

    function QuestButton:set_Only_Show_Zone_Quest()--显示本区域任务
        if not Save().autoSortQuest or IsInInstance() or InCombatLockdown() then
            return
        end
        if self.setQuestWatchTime then
            self.setQuestWatchTime:Cancel()
            self.setQuestWatchTime=nil
        end
        self.setQuestWatchTime= C_Timer.NewTimer(1, function()
            --local uiMapID= C_Map.GetBestMapForUnit('player') or 0
            --if uiMapID and uiMapID>0 then
                for index=1, C_QuestLog.GetNumQuestLogEntries() do
                    local info = C_QuestLog.GetInfo(index)
                    if info
                        and info.questID and info.questID>0
                        and not info.isHeader
                        --and not info.campaignID
                        --and not info.isScaling
                        --and not info.isLegendarySort
                        and not info.isHidden
                        --and not C_QuestLog.IsQuestCalling(info.questID)
                        --and not C_QuestLog.IsWorldQuest(info.questID)
                    then

                        if info.isOnMap  --or GetQuestUiMapID(info.questID)==uiMapID)
                       --     and not C_QuestLog.IsComplete(info.questID)
                            --and info.hasLocalPOI 
                        then
                            C_QuestLog.AddQuestWatch(info.questID)
                        else
                            C_QuestLog.RemoveQuestWatch(info.questID)
                        end
                    end
                end
                C_QuestLog.SortQuestWatches()
            --end
        end)
    end

    function QuestButton:set_PushableQuest(questID)--共享,任务
        if IsInGroup() and Save().pushable then
            if questID then
                if IsInGroup() and C_QuestLog.IsPushableQuest(questID) then
                    C_QuestLog.SetSelectedQuest(questID)
                    QuestLogPushQuest()
                end
            else
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
    end

    function QuestButton:set_Alpha()
        self.texture:SetAlpha(Save().quest and 1 or 0.3)
    end
    function QuestButton:set_Texture()--设置，图片
        if Save().quest then
            self.texture:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest')--AutoQuest-Badge-Campaign
        else
            self.texture:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        end
        self:set_Alpha()
    end


    function QuestButton:not_Ace_QuestTrivial(questID)--其它任务,低等任务
        return C_QuestLog.IsQuestTrivial(questID) and not IsQuestTrivialTracking
    end



    function QuestButton:set_Event()--设置事件
        self:UnregisterAllEvents()

        self:RegisterEvent("QUEST_LOG_UPDATE")--更新数量
        self:RegisterEvent('MINIMAP_UPDATE_TRACKING')--其它任务,低等任务,追踪
        if Save().autoSortQuest then----显示本区域任务
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('ZONE_CHANGED')
            self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
            self:RegisterEvent('SCENARIO_UPDATE')
        end
        if Save().pushable then--共享,任务
            self:RegisterEvent('GROUP_ROSTER_UPDATE')
            self:RegisterEvent('GROUP_JOINED')
            self:RegisterEvent('QUEST_ACCEPTED')
        end
        if Save().showAllQuestNum then--显示所有任务数量, 过区域时，更新当前地图任务，数量
            self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
        end
        self:RegisterEvent('PLAYER_ENTERING_WORLD')

    end


    function QuestButton:tooltip_Show()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName2)
        GameTooltip:AddLine(' ')
        WoWTools_QuestMixin:GetQuestAll()--所有，任务，提示
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetEnabeleDisable(Save().quest),WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU),WoWTools_DataMixin.Icon.right)
        --GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS, WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
        self.texture:SetAlpha(1)
        self:set_Only_Show_Zone_Quest()
        self:set_Quest_Num_Text()
    end
    function QuestButton:set_Quest_Num_Text()
        if IsInInstance() then
            self.Text:SetText('')
        else
            if Save().showAllQuestNum then--显示所有任务数量
                local numQuest, dayNum, weekNum, campaignNum, legendaryNum, storyNum, bountyNum, inMapNum = 0, 0, 0, 0, 0, 0, 0,0
                for index=1, C_QuestLog.GetNumQuestLogEntries() do
                    local info = C_QuestLog.GetInfo(index)
                    if info and not info.isHeader and not info.isHidden then
                        if info.frequency== 0 then
                            numQuest= numQuest+ 1

                        elseif info.frequency==  Enum.QuestFrequency.Daily then--日常
                            dayNum= dayNum+ 1

                        elseif info.frequency== Enum.QuestFrequency.Weekly then--周常
                            weekNum= weekNum+ 1
                        end

                        if info.campaignID then
                            campaignNum= campaignNum+1
                        elseif info.isLegendarySort then
                            legendaryNum= legendaryNum +1
                        elseif info.isStory then
                            storyNum= storyNum +1
                        elseif info.isBounty then
                            bountyNum= bountyNum+ 1
                        end
                        if info.isOnMap then
                            inMapNum= inMapNum +1
                        end
                    end
                end

                local need= campaignNum+ legendaryNum+ storyNum +bountyNum
                self.Text:SetText(
                    (inMapNum>0 and '|cnGREEN_FONT_COLOR:'..inMapNum..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft)..'|r ' or '')
                    ..(dayNum>0 and WoWTools_QuestMixin:GetColor('Daily').hex..dayNum..'|r ' or '')
                    ..(weekNum>0 and WoWTools_QuestMixin:GetColor('Weekly').hex..weekNum..'|r ' or '')
                    ..(numQuest>0 and '|cffffffff'..numQuest..'|r ' or '')
                    ..(need>0 and WoWTools_QuestMixin:GetColor('Legendary').hex..need..'|r ' or '')
                )
            else
                local num= select(2, C_QuestLog.GetNumQuestLogEntries())
                self.Text:SetText(num>0 and num or '')
            end
        end
    end
    QuestButton:SetScript("OnEvent", function(self, event, arg1)
        if event=='MINIMAP_UPDATE_TRACKING' then
            IsQuestTrivialTracking= WoWTools_MapMixin:Get_Minimap_Tracking(MINIMAP_TRACKING_TRIVIAL_QUESTS, false)--其它任务,低等任务,追踪

        elseif event=='QUEST_LOG_UPDATE' or event=='PLAYER_ENTERING_WORLD' or event=='ZONE_CHANGED_NEW_AREA' then--更新数量
            self:set_Quest_Num_Text()

        elseif event=='GROUP_ROSTER_UPDATE' then
            self:set_PushableQuest()--共享,任务

        elseif event=='QUEST_ACCEPTED' then---共享,任务
            if arg1 then
                self:set_PushableQuest(arg1)--共享,任务
            end
        else
            self:set_Only_Show_Zone_Quest()--显示本区域任务
        end
    end)


    QuestButton:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Save().quest= not Save().quest and true or false
            self:set_Texture()--设置，图片
            self:tooltip_Show()
        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, function(...)
                WoWTools_GossipMixin:Init_Menu_Quest(...)
            end)
        end
    end)
    --[[QuestButton:SetScript('OnMouseWheel', function()
        WoWTools_PanelMixin:Open(nil, '|A:SpecDial_LastPip_BorderGlow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '对话和任务' or WoWTools_GossipMixin.addName))
    end)]]

    QuestButton:SetScript('OnLeave', function(self) GameTooltip:Hide() self:set_Alpha() end)
    QuestButton:SetScript('OnEnter', QuestButton.tooltip_Show)

    QuestButton.questSelect={}--已选任务, 提示用
    QuestButton:set_Texture()--设置，图片
    QuestButton:set_Event()--仅显示本地图任务,事件

    C_Timer.After(2, function() QuestButton:set_Only_Show_Zone_Quest() end)--显示本区域任务







    QuestFrame.sel=CreateFrame("CheckButton", nil, QuestFrame, 'InterfaceOptionsCheckButtonTemplate')--禁用此npc,任务,选项
    QuestFrame.sel:SetPoint("TOPLEFT", QuestFrame, 40, 20)
    QuestFrame.sel.Text:SetText(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)
    QuestFrame.sel.questIDLabel= WoWTools_LabelMixin:Create(QuestFrame.sel, {mouse=true})--任务ID
    QuestFrame.sel.questIDLabel:SetPoint('LEFT', QuestFrame.sel.Text, 'RIGHT', 12, 0)
    QuestFrame.sel:SetScript("OnLeave", GameTooltip_Hide)
    QuestFrame.sel:SetScript('OnEnter',function (self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName2)
        if self.npc and self.name then
            GameTooltip:AddDoubleLine(self.name, 'NPC '..self.npc)
        else
            GameTooltip:AddDoubleLine(NONE, 'NPC ID')
        end
        local questID= WoWTools_QuestMixin:GetID()
        if questID then
            GameTooltip:AddDoubleLine('questID', questID)
        end
        GameTooltip:Show()
    end)
    QuestFrame.sel:SetScript("OnMouseDown", function (self, d)
        if not self.npc and self.name then
            return
        end
        Save().NPC[self.npc]= not Save().NPC[self.npc] and self.name or nil
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName2, self.name, self.npc, WoWTools_TextMixin:GetEnabeleDisable(Save().NPC[self.npc]))
    end)

    QuestFrame.sel.questIDLabel:SetScript("OnLeave", function(self) self:SetAlpha(1) GameTooltip_Hide() end)
    QuestFrame.sel.questIDLabel:SetScript('OnEnter',function (self)
        self:SetAlpha(0.5)
        local questID= WoWTools_QuestMixin:GetID()
        if not questID then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip_AddQuest(GameTooltip, questID)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)
    QuestFrame.sel.questIDLabel:SetScript('OnMouseDown',function(self)
        local questID= WoWTools_QuestMixin:GetID()
        if questID then
            ChatEdit_TryInsertQuestLinkForQuestID(questID)
            --WoWTools_ChatMixin:Chat(GetQuestLink(questID), nil, true)
        end
    end)
















    --任务框, 自动选任务    
    QuestFrameGreetingPanel:HookScript('OnShow', function()--QuestFrame.lua QuestFrameGreetingPanel_OnShow
        local npc=WoWTools_UnitMixin:GetNpcID('npc')
        QuestFrame.sel.npc=npc
        QuestFrame.sel.name=UnitName("npc")
        QuestFrame.sel:SetChecked(Save().NPC[npc])
        QuestFrame.sel.questIDLabel:SetText(WoWTools_QuestMixin:GetID() or '')
        if npc and Save().NPC[npc] or not Save().quest or IsModifierKeyDown() then
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
                if (isTrivial and IsQuestTrivialTracking) or not isTrivial then
                    SelectAvailableQuest(index)
                    return
                end
            end
       end
    end)










    --任务进度, 继续, 完成 QuestFrame.lua
    hooksecurefunc('QuestFrameProgressItems_Update', function()
        local questID= WoWTools_QuestMixin:GetID()
        local npc=WoWTools_UnitMixin:GetNpcID('npc')
        QuestFrame.sel.npc=npc
        QuestFrame.sel.name=UnitName("npc")
        QuestFrame.sel:SetChecked(Save().NPC[npc])
        QuestFrame.sel.questIDLabel:SetText(questID or '')

        if not questID or not Save().quest or IsModifierKeyDown() or (Save().NPC[npc] and not Save().questOption[questID]) then
            return
        end

        if not IsQuestCompletable() then--or not C_QuestOffer.GetHideRequiredItemsOnTurnIn() then
            if questID then
                local link
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
                    print(WoWTools_DataMixin.Icon.icon2,
                        WoWTools_QuestMixin:GetLink(questID),
                        text and '|cnGREEN_FONT_COLOR:'..text..'|r',
                        link or '',
                        '|cffff00ff'..WoWTools_TextMixin:CN(QuestFrameGoodbyeButton and QuestFrameGoodbyeButton:GetText() or '')..WoWTools_DataMixin.Icon.left
                    )
                end)
            end
            WoWTools_DataMixin:Call(QuestGoodbyeButton_OnClick)
        else
            if not QuestButton.questSelect[questID] then--已选任务, 提示用
                C_Timer.After(0.5, function()
                    print(WoWTools_DataMixin.Icon.icon2, WoWTools_QuestMixin:GetLink(questID))
                end)
                QuestButton.questSelect[questID]=true
            end
            WoWTools_DataMixin:Call(QuestProgressCompleteButton_OnClick)
        end
    end)









    --自动接取任务, 仅一个任务
    hooksecurefunc('QuestInfo_Display', function(template, parentFrame, acceptButton)--, material, mapView)--QuestInfo.lua
        local questID= WoWTools_QuestMixin:GetID()
        local npc=WoWTools_UnitMixin:GetNpcID('npc')
        QuestFrame.sel.npc=npc
        QuestFrame.sel.name=UnitName("npc")
        QuestFrame.sel:SetChecked(Save().NPC[npc])
        QuestFrame.sel.questIDLabel:SetText(questID or '')

        if not questID and template.canHaveSealMaterial and not QuestUtil.QuestTextContrastEnabled() and template.questLog then
            local frame = parentFrame:GetParent():GetParent()
            questID = frame.questID
        end

        if not questID
            or not Save().quest
            or (Save().NPC[npc] and not Save().questOption[questID])
            or IsModifierKeyDown()
            or QuestButton:not_Ace_QuestTrivial(questID)
            or not acceptButton
            or not acceptButton:IsVisible()
            or not acceptButton:IsEnabled()
        then
            return
        end

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
            WoWTools_DataMixin:Load({id=spellID, type='spell'})
            local spellLink= C_Spell.GetSpellLink(spellID)
            itemLink= itemLink.. (spellLink or (' spellID'..spellID))
        end

        local skillName, skillIcon, skillPoints = GetRewardSkillPoints()--专业
        if skillName then
            itemLink= itemLink..(C_Spell.GetSpellLink(skillName) or ((skillIcon and '|T'..skillIcon..':0|t' or '')..skillName))..(skillPoints and '|cnGREEN_FONT_COLOR:+'..skillPoints..'|r' or '')
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

        if not QuestButton.questSelect[questID] then--已选任务, 提示用

            C_Timer.After(0.5, function()
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_QuestMixin:GetLink(questID),
                    (complete and '|cffff00ff' or '|cff00ffff')..WoWTools_TextMixin:CN(acceptButton:GetText() or '')..'|r'..WoWTools_DataMixin.Icon.left,
                    itemLink or '')
            end)
            QuestButton.questSelect[questID]=true
        end

        if acceptButton==QuestFrameCompleteQuestButton then
            WoWTools_DataMixin:Call(QuestRewardCompleteButton_OnClick)
        elseif acceptButton:IsEnabled() and acceptButton:IsVisible() then
            acceptButton:Click()
        end
    end)
end












function WoWTools_GossipMixin:Init_Quest()
    IsQuestTrivialTracking= WoWTools_MapMixin:Get_Minimap_Tracking(MINIMAP_TRACKING_TRIVIAL_QUESTS, false)
    Init_Quest()
end