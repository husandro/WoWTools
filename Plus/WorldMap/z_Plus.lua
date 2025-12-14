
local function Save()
    return  WoWToolsSave['Plus_WorldMap']
end





local function Bounty_Setting(self)
    if not WoWTools_FrameMixin:IsLocked(self) then
        self:SetScale(Save().activityTrackerScale or 1)
    end
    local alpha= Save().activityTrackerAlpha or 1
    self.IconBorder:SetAlpha(alpha)
    local maxAlpha= math.max(0.3, alpha)
    self.Icon:SetAlpha(maxAlpha)
    WoWTools_TextureMixin:SetButton(self.BountyDropdown, maxAlpha)

    local fontScale= Save().activityTrackerFontScale or 0.5
    if fontScale>0 then
        self.factionText:SetScale(Save().activityTrackerFontScale or 0.5)
    end
    self.factionText:SetShown(fontScale>0)
end





local function Set_FactionText(self, bountyInfo)
    local factionID= bountyInfo and bountyInfo.factionID or nil
    local data= WoWTools_FactionMixin:GetInfo(factionID)
    if not data.name or Save().activityTrackerFontScale==0 then
        self.factionText:SetText('')
    end

    local t

    if data.factionStandingtext and not data.isCapped then
        t= data.factionStandingtext
    end

    if data.valueText then
        t= (t and t..' ' or '')..data.valueText
    end

    self.factionText:SetText(
        (t or '')
        ..(data.hasRep and '|cnGREEN_FONT_COLOR:*|r' or '')
        ..(data.hasRewardPending or '')
    )

    self.factionText.factionID= factionID
end






--战役 ID 提示 CampaignOverviewMixin
local function Set_Campaign_OnEnter(self)
    local campaign= self.campaign or self:GetParent().campaign
    local campaignID= campaign and campaign:GetID()
    if not campaignID  then
        return
    end
    --QuestScrollFrame.CampaignTooltip
    if not self:IsMouseOver() then
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:ClearLines()
    end
--名称
    local name= WoWTools_TextMixin:CN(campaign.name, {campaignID=campaignID, isName=true})
    if name then
        GameTooltip:AddLine(WoWTools_DataMixin.Icon.icon2..name)
    end
--中文 Description
    local cnData= WoWTools_TextMixin:CN(nil, {campaignID=campaignID})
    if cnData and cnData.D then
        GameTooltip:AddLine(cnData.D, nil, nil, nil, true)
    end
--ID
    GameTooltip:AddDoubleLine('campaignID', '|cffffffff'..campaignID)
--章节数量
    local count= campaign:GetChapterCount() or 0
    if count>0 then
        local chapterIDs={}
        local chapterIndex=0
        local currentChapterID= campaign:GetCurrentChapterID()
        for index, chapterID in pairs(campaign.chapterIDs or {}) do
            if chapterID==currentChapterID then
                chapterIndex= index
            end
            table.insert(chapterIDs, chapterID)
        end

        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            (WoWTools_DataMixin and '章节' or 'ChapterIDs')
            ..' '
            ..format('%d/%d', chapterIndex, count),

            (campaign.isWarCampaign and '阵营战役' or WAR_CAMPAIGN)
            or (WoWTools_DataMixin.onlyChinese and '战役' or CONTAINER_CAMPAIGN_PROGRESS)
        )
--章节
        for index, chapterID in pairs(chapterIDs) do
            local col= index==chapterIndex and '|cnGREEN_FONT_COLOR:' or (index>chapterIndex and '|cffffffff') or '|cff626262'
            GameTooltip:AddDoubleLine(
                col..index..')',
                col..chapterID
            )
        end
    end
    GameTooltip:Show()
end


















local function Init_BountyDropdown(frame)
--声望，字体
    frame.factionText= frame:CreateFontString(nil, 'OVERLAY', 'WorldMapTextFont')
    frame.factionText:SetPoint('TOPLEFT', frame.Icon, 'BOTTOMLEFT', 0, 10)
    frame.factionText:EnableMouse(true)
    frame.factionText:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        WoWTools_SetTooltipMixin:Hide()
    end)
    frame.factionText:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Faction(self)
        self:SetAlpha(0.5)
    end)

--Mask
    frame.BackgroundMask:ClearAllPoints()
    frame.BackgroundMask:SetPoint('TOPLEFT', frame.Icon, 4, -4)
    frame.BackgroundMask:SetPoint('BOTTOMRIGHT', frame.Icon, -3, 3)
    frame.BackgroundMask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask', "CLAMPTOBLACKADDITIVE" , "CLAMPTOBLACKADDITIVE")
    frame.Icon:AddMaskTexture(frame.BackgroundMask)
    WoWTools_TextureMixin:HideTexture(frame.IconBorder)
    WoWTools_TextureMixin:HideTexture(frame.Background)

--菜单
    Menu.ModifyMenu("MENU_WORLD_MAP_ACTIVITY_TRACKER", function(self, root)
        if not self:IsMouseOver() then
            return
        end
        root:CreateDivider()
        local sub= WoWTools_MenuMixin:OpenOptions(root, {name= WoWTools_WorldMapMixin.addName})--root:CreateButton(WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)

--声望，字体，缩放
        sub:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return Save().activityTrackerFontScale or 0.5
            end, setValue=function(value)
                Save().activityTrackerFontScale=value
                Bounty_Setting(frame)
            end,
            name=WoWTools_DataMixin.onlyChinese and '声望' or REPUTATION,
            minValue=0,
            maxValue=2,
            step=0.1,
            bit='%.1f',
        })

--缩放
        WoWTools_MenuMixin:ScaleRoot(self, sub, function()
            return Save().activityTrackerScale or 1
        end, function(value)
            if not WoWTools_FrameMixin:IsLocked(frame) then
                Save().activityTrackerScale= value
                Bounty_Setting(frame)
            end
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_WorldMapMixin.addName..WoWTools_DataMixin.Icon.icon2)
        end)
--Alpha
        WoWTools_MenuMixin:BgAplha(sub, function()
            return Save().activityTrackerAlpha or 1
        end, function(value)
            Save().activityTrackerAlpha= value
            Bounty_Setting(frame)
        end, function()
            Save().activityTrackerScale= nil
            Save().activityTrackerAlpha= nil
            Save().activityTrackerFontScale= nil
            Bounty_Setting(frame)
        end, true)
    end)

    Bounty_Setting(frame)


--保存上次，操作 WorldMapActivityTrackerMixin
    local _bountyInfo= Save().bountyInfo
    if _bountyInfo then
        frame:SetSelectedBounty(_bountyInfo)
        Set_FactionText(frame, _bountyInfo)
    end

    WoWTools_DataMixin:Hook(frame, 'SetSelectedBounty', function(self, bountyInfo)
        Save().bountyInfo= bountyInfo
        Set_FactionText(self, bountyInfo)
    end)

    _bountyInfo= nil

    Init_BountyDropdown=function()end
end

















local function Init()
    if Save().notPlus then
        return
    end




 --缩放, 声望追踪，圆形图标
    for _, frame in ipairs(WorldMapFrame.overlayFrames or {}) do
        if frame.BountyDropdown then--frame BountyFrameMixin
            Init_BountyDropdown(frame)
            break
        end
    end





--战役 ID 提示 CampaignOverviewMixin
--列表中，标题
    WoWTools_DataMixin:Hook(CampaignHeaderDisplayMixin, 'SetCampaign', function(self)
        if not self.chapterLabel then
            self:HookScript('OnLeave', function()
                if QuestScrollFrame.CampaignTooltip then
                    QuestScrollFrame.CampaignTooltip:SetShown(false)
                end
                GameTooltip:Hide()
            end)
            self:HookScript('OnEnter', function(...) Set_Campaign_OnEnter(...) end)
            self.chapterLabel= self:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
            self.chapterLabel:SetPoint('RIGHT', self.CollapseButton, 'LEFT', -2, 0)
        end
        local text
        local num= self.campaign and self.campaign:GetChapterCount() or 0
        if num>0 then
            local currentChapterID= self.campaign:GetCurrentChapterID()
            for index, chapterID in pairs(self.campaign.chapterIDs or {}) do
                if chapterID==currentChapterID then
                    text= index..'/'..num
                    break
                end
            end
        end
        self.chapterLabel:SetText(text or '')
    end)
--列表中，战役，进入 详细 按钮
    WoWTools_DataMixin:Hook(CampaignLoreButtonMixin, 'OnLeave', function()
        if QuestScrollFrame.CampaignTooltip then
            QuestScrollFrame.CampaignTooltip:SetShown(false)
        end
        GameTooltip:Hide()
    end)
    WoWTools_DataMixin:Hook(CampaignLoreButtonMixin, 'OnEnter', function(...) Set_Campaign_OnEnter(...) end)

--战役，详细中，返回按钮
    QuestMapFrame.QuestsFrame.CampaignOverview.Header.BackButton:HookScript('OnLeave', GameTooltip_Hide)
    QuestMapFrame.QuestsFrame.CampaignOverview.Header.BackButton:HookScript('OnEnter', function(...) Set_Campaign_OnEnter(...) end)












--SearchBox，添加按钮
    QuestScrollFrame.SearchBox:SetWidth(301- 20*2)

    local btnCollapse= WoWTools_ButtonMixin:Cbtn(QuestScrollFrame.SearchBox, {size=22, atlas='NPE_ArrowUp'})--campaign_headericon_closed
    btnCollapse:SetPoint('LEFT', QuestScrollFrame.SearchBox, 'RIGHT')
    btnCollapse:SetScript('OnLeave', GameTooltip_Hide)
    btnCollapse:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(not WoWTools_DataMixin.onlyChinese and HUD_EDIT_MODE_COLLAPSE_OPTIONS or "收起选项 |A:editmode-up-arrow:16:11:0:3|a")
        GameTooltip:AddLine(WoWTools_WorldMapMixin.addName)
        GameTooltip:Show()
    end)
    btnCollapse:SetScript("OnMouseDown", function()
        for i=1, C_QuestLog.GetNumQuestLogEntries() do
            CollapseQuestHeader(i)
        end
    end)

    local btnExpand= WoWTools_ButtonMixin:Cbtn(QuestScrollFrame.SearchBox, {size=22, atlas='NPE_ArrowDown'})
    btnExpand:SetPoint('LEFT', btnCollapse, 'RIGHT')
    btnExpand:SetScript('OnLeave', GameTooltip_Hide)
    btnExpand:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(not WoWTools_DataMixin.onlyChinese and HUD_EDIT_MODE_EXPAND_OPTIONS or "展开选项 |A:editmode-down-arrow:16:11:0:-7|a")
        GameTooltip:AddLine(WoWTools_WorldMapMixin.addName)
        GameTooltip:Show()
    end)
    btnExpand:SetScript("OnMouseDown", function()
        for i=1, C_QuestLog.GetNumQuestLogEntries() do
            ExpandQuestHeader(i)
        end
    end)





    Init=function()end
end











function WoWTools_WorldMapMixin:Init_Plus()
    Init()
    --C_Timer.After(0.3, Init)
end