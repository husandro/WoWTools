
local function Save()
    return  WoWToolsSave['Plus_WorldMap']
end

local function Init()
    if Save().notPlus then
        return
    end

 --缩放, 声望追踪，圆形图标
    for _, frame in ipairs(WorldMapFrame.overlayFrames or {}) do
        if frame.BountyDropdown then

            function frame:set_scale()
                if not WoWTools_FrameMixin:IsLocked(self) then
                    self:SetScale(Save().activityTrackerScale or 1)
                end
            end

            Menu.ModifyMenu("MENU_WORLD_MAP_ACTIVITY_TRACKER", function(self, root)
                root:CreateDivider()
                local sub= WoWTools_MenuMixin:Scale(self, root, function()
                    return Save().activityTrackerScale or 1
                end, function(value)
                    if not WoWTools_FrameMixin:IsLocked(frame) then
                        Save().activityTrackerScale= value
                        frame:set_scale()
                    end
                end)
                sub:SetTooltip(function(tooltip)
                    tooltip:AddLine(WoWTools_WorldMapMixin.addName..WoWTools_DataMixin.Icon.icon2)
                end)
            end)

            if Save().activityTrackerScale then
                frame:set_scale()
            end

            break
        end
    end






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



--战役 ID 提示 CampaignOverviewMixin
    local function Set_Campaign_OnEnter(self)
        local campaign= self.campaign or self:GetParent().campaign
        local campaignID= campaign and campaign:GetID()
        if not campaignID  then
            return
        end
        if not GameTooltip:IsOwned(self) then
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
            GameTooltip:AddLine(' ')
            local curIndex= (campaign:GetCompletedChapterCount() or 0)+1
            GameTooltip:AddDoubleLine(
                (campaign.isWarCampaign and '阵营战役' or WAR_CAMPAIGN)
                or (WoWTools_DataMixin.onlyChinese and '战役' or CONTAINER_CAMPAIGN_PROGRESS),
                '|cffffffff'..format(
                    WoWTools_DataMixin.onlyChinese and '%d/%d 章' or STORY_CHAPTERS,
                    curIndex,
                    count
                )
            )

            
--章节
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(WoWTools_DataMixin and '章节' or 'ChapterIDs')
            for index, chapterID in pairs(campaign.chapterIDs or {}) do
                local col= index< curIndex and '|cff626262' or (select(2, math.modf(index/2))==0 and '|cff00ccff' or '|cffffffff')
                GameTooltip:AddDoubleLine(
                    col..index..')', col..chapterID
                )
            end
        end
        GameTooltip:Show()
        info= campaign
        for k, v in pairs(info or {}) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR|r') for k2,v2 in pairs(v) do print('|cffffff00',k2,v2, '|r') end print('|cffff0000---',k, '---END|r') else print(k,v) end end print('|cffff00ff——————————|r')
    end
--列表中，标题
    WoWTools_DataMixin:Hook(CampaignHeaderDisplayMixin, 'SetCampaign', function(self, campaignID)
        if not self.isSetOonenter then
            self:SetScript('OnLeave', GameTooltip_Hide)
            self:HookScript('OnEnter', Set_Campaign_OnEnter)
            self.isSetOonenter= true
        end
    end)

    WoWTools_DataMixin:Hook(CampaignLoreButtonMixin, 'SetMode', function(self)
        local campaign= self:GetParent().campaign
        local campaignID= campaign and campaign:GetID()
        if not self.IDLabel then
            self.IDLabel= self:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
            self.IDLabel:SetPoint('LEFT', self, 'RIGHT', 4, 0)
        end
        self.IDLabel:SetText(campaignID or '')
    end)
    WoWTools_DataMixin:Hook(CampaignLoreButtonMixin, 'OnLeave', GameTooltip_Hide)
    WoWTools_DataMixin:Hook(CampaignLoreButtonMixin, 'OnEnter', Set_Campaign_OnEnter)

    Init=function()end
end





function WoWTools_WorldMapMixin:Init_Plus()
    Init()
end