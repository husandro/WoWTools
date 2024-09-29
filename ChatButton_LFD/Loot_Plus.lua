--历史, 拾取框 LootHistory.lua
local e= select(2, ...)
local function Save()
    return WoWTools_LFDMixin.Save
end









local function Init()
    local function set_LootFrame_btn(btn)
        if not btn then
            return
        elseif not btn.dropInfo or Save().disabledLootPlus then
            if btn.chatTexure then
                btn.chatTexure:SetShown(false)
            end
            if btn.itemSubTypeLabel then
                btn.itemSubTypeLabel:SetText("")
            end
            btn:SetAlpha(1)
            WoWTools_ItemStatsMixin:SetItem(btn.Item)
            return
        end



        if not btn.chatTexure then
            btn.chatTexure= WoWTools_ButtonMixin:Cbtn(btn, {size={18,18}, atlas='transmog-icon-chat'})
            btn.chatTexure:SetPoint('BOTTOMRIGHT', btn, 6, 4)
            btn.chatTexure:SetScript('OnLeave', GameTooltip_Hide)
            function btn.chatTexure:get_playerinfo()
                local p=self:GetParent().dropInfo or {}
                return p.winner or p.currentLeader or {}
            end

            function btn.chatTexure:get_text()
                local p= self:GetParent().dropInfo
                local nu=''
                if IsInRaid() then
                    for i=1, MAX_RAID_MEMBERS do
                        local name, _, subgroup= GetRaidRosterInfo(i)
                        if name==e.Player.name then
                            if subgroup then
                                nu= ' '..subgroup..GROUP
                            end
                            break
                        end
                    end
                end
                return (not p or p.playerRollState==Enum.EncounterLootDropRollState.Greed) and ''
                        or ((e.Player.region==1 or e.Player.region==3) and ' need, pls{rt1}'..nu)
                        or (e.Player.region==5 and ' 您好，我很需求这个，能让让吗？谢谢{rt1}'..nu)
                        or (' '..NEED..', '..VOICEMACRO_LABEL_THANKYOU3..'{rt1}'..nu)
            end
            function btn.chatTexure:get_playername()
                local info= self:get_playerinfo()
                local playerName= info.playerName
                if playerName and info.playerGUID and not playerName:find('%-') then
                    local realm= select(7,GetPlayerInfoByGUID(info.playerGUID))
                    if realm and realm~='' and realm~=e.Player.realm then
                        playerName= playerName..'-'..realm
                    end
                end
                return playerName
            end
            btn.chatTexure:SetScript('OnEnter', function(self)
                local p= self:GetParent()
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                if p.dropInfo.startTime then
                    local startTime= '|cnRED_FONT_COLOR:'..(WoWTools_TimeMixin:Info(p.dropInfo.startTime/1000, false, nil) or '')
                    local duration= p.dropInfo.duration and '|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '持续时间：%s' or PROFESSIONS_CRAFTING_FORM_CRAFTER_DURATION_REMAINING, SecondsToTime(p.dropInfo.duration/100))
                    e.tips:AddDoubleLine(startTime, duration)
                    e.tips:AddLine(' ')
                end
                e.tips:AddDoubleLine(SLASH_SMART_WHISPER2..' '..(self:get_playername() or ''), (p.dropInfo.itemHyperlink or '')..(self:get_text() or ''))
                e.tips:AddLine(' ')
                if GroupLootHistoryFrame.selectedEncounterID then
                    e.tips:AddDoubleLine('EncounterID', GroupLootHistoryFrame.selectedEncounterID)
                end
                e.tips:AddDoubleLine(e.addName, WoWTools_LFDMixin.addName)
                e.tips:Show()
            end)
            btn.chatTexure:SetScript('OnClick', function(self)
                local p=self:GetParent().dropInfo or {}
                WoWTools_ChatMixin:Say(nil, self:get_playername(), nil, (p.itemHyperlink or '').. (self:get_text() or ''))

            end)

            if btn.WinningRollInfo and btn.WinningRollInfo.Check and not btn.WinningRollInfo.Check.move then--移动, √图标
                btn.WinningRollInfo.Check:ClearAllPoints()
                btn.WinningRollInfo.Check:SetPoint('BOTTOMRIGHT', btn, 8, -2)
                btn.WinningRollInfo.Check.move=true
            end
        end

        local notGreed= btn.dropInfo.playerRollState ~= Enum.EncounterLootDropRollState.Greed
        local winInfo= btn.chatTexure:get_playerinfo()
        btn.chatTexure:SetShown(not winInfo.isSelf and winInfo.isSelf~=nil)
        --btn.chatTexure:SetAlpha(notGreed and 1 or 0.3)
        --btn.WinningRollInfo.Check:SetAlpha(notGreed and 1 or 0.3)
        btn:SetAlpha(winInfo.isSelf and 0.3 or (not notGreed and 0.5) or 1)


        if winInfo and notGreed then--修改，名字
            if winInfo.isSelf then
                btn.WinningRollInfo.WinningRoll:SetText(e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r')
            elseif winInfo.playerGUID then
                local name= WoWTools_UnitMixin:GetPlayerInfo(nil, winInfo.playerGUID, nil, {reName=true})
                if name and name~='' then
                    btn.WinningRollInfo.WinningRoll:SetText(name)
                end
            end
        end

        WoWTools_ItemStatsMixin:SetItem(btn.Item, notGreed and btn.dropInfo.itemHyperlink, {point= btn.Item and btn.Item.IconBorder})--设置，物品，4个次属性，套装，装等

        local text
        if not btn.itemSubTypeLabel then
            btn.itemSubTypeLabel= WoWTools_LabelMixin:CreateLabel(btn, {color=true})
            btn.itemSubTypeLabel:SetPoint('BOTTOMLEFT', btn.Item.IconBorder, 'BOTTOMRIGHT',4,-8)
        end
        if btn.dropInfo.itemHyperlink and notGreed then
            local _, _, itemSubType2, itemEquipLoc, _, _, subclassID = C_Item.GetItemInfoInstant(btn.dropInfo.itemHyperlink)--提示,装备,子类型
            local collected, _, isSelfCollected= WoWTools_CollectedMixin:Item(btn.dropInfo.itemHyperlink, nil, false)--物品是否收集
            text= subclassID==0 and itemEquipLoc and e.cn(_G[itemEquipLoc]) or e.cn(itemSubType2)
            if isSelfCollected and collected then
                text= text..' '..collected
            end

            if btn.dropInfo.startTime and notGreed then
                text= text..' |cnRED_FONT_COLOR:'..WoWTools_TimeMixin:Info(btn.dropInfo.startTime/1000, true, nil)..'|r'
            end
        end
        if btn.itemSubTypeLabel then
            btn.itemSubTypeLabel:SetText(text or '')
        end
    end
    hooksecurefunc(LootHistoryElementMixin, 'Init', set_LootFrame_btn)
    hooksecurefunc(GroupLootHistoryFrame.ScrollBox, 'SetScrollTargetOffset', function(self)
        if not self:GetView() then
            return
        end
        for _, btn in pairs(self:GetFrames()) do
            set_LootFrame_btn(btn)
        end
    end)


    local btn= WoWTools_ButtonMixin:Cbtn(GroupLootHistoryFrame.TitleContainer, {size={18,18}, icon='hide'})
    if _G['MoveZoomInButtonPerGroupLootHistoryFrame'] then
        btn:SetPoint('RIGHT', _G['MoveZoomInButtonPerGroupLootHistoryFrame'], 'LEFT')
    else
        btn:SetPoint('LEFT')
    end
    function btn:Set_Atlas()
        if Save().disabledLootPlus then
            self:SetNormalAtlas(e.Icon.disabled)
        else
            self:SetNormalAtlas('communities-icon-notification')
        end
    end
    btn:Set_Atlas()
    btn:SetScript('OnClick', function(self2)
        Save().disabledLootPlus= not Save().disabledLootPlus and true or nil
        self2:Set_Atlas()
        if GroupLootHistoryFrame.selectedEncounterID then
            GroupLootHistoryFrame:DoFullRefresh()
        end
    end)
    btn:SetAlpha(0.5)
    btn:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
    btn:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '战利品 Plus' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOOT, 'Plus'), e.GetEnabeleDisable(not Save().disabledLootPlus))
        e.tips:AddLine(' ')
        local  encounterID= GroupLootHistoryFrame.selectedEncounterID
        local info= encounterID and C_LootHistory.GetInfoForEncounter(encounterID)
        if info then
            e.tips:AddDoubleLine('encounterName', info.encounterName)
            e.tips:AddDoubleLine('encounterID', info.encounterID)
            e.tips:AddDoubleLine('startTime', WoWTools_TimeMixin:SecondsToClock(info.startTime))
            e.tips:AddDoubleLine('duration', info.duration and SecondsToTime(info.duration/100))
        else
            e.tips:AddDoubleLine('encounterID', e.onlyChinese and '无' or NONE)
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.addName, WoWTools_LFDMixin.addName)
        e.tips:Show()
        self2:SetAlpha(1)
    end)
end










function WoWTools_LFDMixin:Init_Loot_Plus()
    Init()
end