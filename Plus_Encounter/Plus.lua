
local function Init()
    if WoWToolsSave['Adventure_Journal'].hideEncounterJournal then
        return
    end

    EncounterJournal.encounter.instance.mapButton:SetScript('OnLeave', GameTooltip_Hide)
    EncounterJournal.encounter.instance.mapButton:SetScript('OnEnter', function(self)--综述,小地图提示
        local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, _, mapID= EJ_GetInstanceInfo()
        if not name then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(
            link or name,

            (dungeonAreaMapID and 'uiMapID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..dungeonAreaMapID..'|r' or '')
            ..(mapID and ' instanceID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..mapID..'|r' or '')
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(description, nil,nil,nil, true)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(bgImage and '|T'..bgImage..':26|t'..bgImage, loreImage and '|T'..loreImage..':26|t'..loreImage)
        GameTooltip:AddDoubleLine(buttonImage1 and '|T'..buttonImage1..':26|t'..buttonImage1, buttonImage2 and '|T'..buttonImage2..':26|t'..buttonImage2)
        --GameTooltip:AddLine(' ')
        --GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_EncounterMixin.addName)
        GameTooltip:Show()
    end)








    local function Create_Button_Label(btn)
--索引
        btn.indexLabel= btn:CreateFontString(nil, 'OVERLAY', 'GameFontNormalMed3')
        btn.indexLabel:SetPoint('TOPRIGHT', -8, -7)
        btn.indexLabel:SetTextColor(0.827, 0.659, 0.463)
        btn.indexLabel:SetScript('OnLeave', function(self)
            GameTooltip:Hide()
            self:SetAlpha(1)
        end)
        btn.indexLabel:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            GameTooltip:SetText(
                WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_DataMixin.onlyChinese and '索引' or 'index')
                ..' |cffffffff'..(self:GetText() or '')
            )
            GameTooltip:Show()
            self:SetAlpha(0.5)
        end)

        btn.killedLabel= btn:CreateFontString(nil, 'OVERLAY', 'GameFontNormalMed3')
        btn.killedLabel:SetTextColor(0.827, 0.659, 0.463)
        btn.killedLabel:SetPoint('RIGHT', btn.indexLabel, 'LEFT', -5, 0)
        btn.killedLabel:EnableMouse(true)
        btn.killedLabel:SetScript('OnLeave', function(self)
            GameTooltip:Hide()
            self:SetAlpha(1)
        end)
        btn.killedLabel:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            GameTooltip:SetText(
                WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_DataMixin.onlyChinese and '已击败' or DUNGEON_ENCOUNTER_DEFEATED)
                ..' |cffffffff'..(self:GetText() or '')
            )
            GameTooltip:Show()
            self:SetAlpha(0.5)
        end)
--全部清除
        btn.killedLabel:SetScript('OnMouseDown', function(self)
            MenuUtil.CreateContextMenu(self:GetParent(), function(_, root)
                local num= 0
                for _ in pairs(WoWToolsPlayerDate['BossKilled']) do
                    num= num+1
                end
                root:CreateButton(
                    WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
                function()
                    StaticPopup_Show('WoWTools_OK',
                        '|A:bags-button-autosort-up:0:0|a|cnWARNING_FONT_COLOR:'
                        ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
                        ..'|r|n|n'
                        ..(WoWTools_DataMixin.onlyChinese and '击败首领：记录' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LFG_LIST_BOSSES_DEFEATED, EVENTTRACE_LOG_HEADER)),
                        nil,
                        {SetValue=function()
                        WoWToolsPlayerDate['BossKilled']={}
                            WoWTools_DataMixin:Call('EncounterJournal_Refresh')
                        end}
                    )
                    return MenuResponse.Open
                end)
            end)
        end)

--增加 OnEnter
        btn:SetScript('OnLeave', GameTooltip_Hide)
        btn:SetScript('OnEnter', function(self)
            if not self.encounterID then
                return
            end

            local bossName, _, journalEncounterID, rootSectionID, _, journalInstanceID, dungeonEncounterID, instanceID= EJ_GetEncounterInfo(self.encounterID)--button.index= button.GetOrderIndex()
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")

            local cn= WoWTools_TextMixin:CN(bossName) or bossName
            bossName= cn~=bossName and cn..' '..bossName or bossName or self.encounterID
            GameTooltip:SetText(WoWTools_DataMixin.Icon.icon2..bossName)
--journalEncounterID journalInstanceID
            journalEncounterID= journalEncounterID or self.encounterID
            GameTooltip:AddDoubleLine('journalEncounterID |cffffffff'..journalEncounterID, journalInstanceID  and 'journalInstanceID |cffffffff'..journalInstanceID)
--instanceID sectionID
            GameTooltip:AddDoubleLine(instanceID and 'instanceID |cffffffff'..instanceID or ' ', rootSectionID  and 'sectionID |cffffffff'..rootSectionID)

            if dungeonEncounterID then
                GameTooltip:AddDoubleLine('encounterID |cffffffff'..dungeonEncounterID)
                local numKill=WoWToolsPlayerDate['BossKilled'][dungeonEncounterID] or 0
--已击败
                GameTooltip:AddLine(
                    format(WoWTools_DataMixin.onlyChinese and '%s（|cffffffff%d|r次）' or REAGENT_COST_CONSUME_CHARGES,
                    WoWTools_DataMixin.onlyChinese and '已击败' or DUNGEON_ENCOUNTER_DEFEATED,
                    numKill)
                )
            end
            GameTooltip:Show()
        end)
    end





--BOSS 列表 按钮
    WoWTools_DataMixin:Hook(EncounterBossButtonMixin, 'Init', function(self, data)
        if not data.bossID then
            return
        end

        if not self.indexLabel then
            Create_Button_Label(self)
        end

        self.indexLabel:SetText(data.index or '')
        local encounterID= select(7, EJ_GetEncounterInfo(data.bossID))
        local numKill=WoWToolsPlayerDate['BossKilled'][encounterID] or 0
        if numKill>0 then
            self.killedLabel:SetFormattedText(WoWTools_DataMixin.onlyChinese and '%d次' or ITEM_SPELL_CHARGES, numKill)
        else
            self.killedLabel:SetText('')
        end
    end)








--贸易站 任务，提示
    WoWTools_DataMixin:Hook(MonthlyActivitiesButtonMixin, 'ShowTooltip', function(self)
        local data = self:GetData()
        local id= data and data.ID
        if not id then
            return
        end
        GameTooltip:AddLine(
            '|cnGREEN_FONT_COLOR:<'
            ..(WoWTools_DataMixin.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK)..WoWTools_DataMixin.Icon.right
            ..'>'
        )
        GameTooltip:AddLine(
            'perksActivityID|cffffffff'
            ..WoWTools_DataMixin.Icon.icon2
            ..id
        )
        GameTooltip:Show()
    end)
    WoWTools_DataMixin:Hook(MonthlyActivitiesButtonMixin, 'OnClick', function(self, d)
        local data = self:GetData()
        local id= data and data.ID
        if id and d=='RightButton' then
            local link=C_PerksActivities.GetPerksActivityChatLink(id)
            WoWTools_ChatMixin:Chat(link, nil, true)
        end
    end)
    WoWTools_DataMixin:Hook(MonthlyActivitiesButtonMixin, 'Init', function(self)
        self:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    end)


    Init=function()end
end






function WoWTools_EncounterMixin:Init_Plus()
    Init()
end