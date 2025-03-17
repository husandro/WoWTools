local e= select(2, ...)
--地图ID，信息

local function Save()
    return WoWTools_WorldMapMixin.Save
end
local Frame





local function Set_Text()
    local m=''
    local story, achievementID

    local uiMapID = WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")
    m= uiMapID or m
    if uiMapID then
        local uiMapGroupID=C_Map.GetMapGroupID(uiMapID)
        if uiMapGroupID then
            m='g'..uiMapGroupID..'  '..m
        end
        local areaPoiIDs=C_AreaPoiInfo.GetAreaPOIForMap(uiMapID)
        if areaPoiIDs then
            for _,areaPoiID in pairs(areaPoiIDs) do
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
                if poiInfo and (poiInfo.areaPoiID or poiInfo.tooltipWidgetSet) and poiInfo.atlasName then
                    m='|A:'..poiInfo.atlasName..':0:0|a'..m
                end
            end
        end
        if IsInInstance() then
            local instanceID, _, LfgDungeonID =select(8, GetInstanceInfo())
            if instanceID then
                m=INSTANCE..instanceID..'  '..m
                if LfgDungeonID then
                    m=(e.onlyChinese and '随机' or 'Random')..LfgDungeonID..'  '..m
                end
            end
        end
    end

    if e.Player.Layer then
        m = e.Player.Layer..' '..m
    end

    achievementID = C_QuestLog.GetZoneStoryInfo(uiMapID)--当前地图，故事任务
    if achievementID then
        local completed, _, icon
        story, _, completed, _, _, _, _, _, icon= select(2, GetAchievementInfo(achievementID))
        story= e.cn(story) or achievementID
        if completed then
            story= '|cff9e9e9e'..story..'|r'
        end
        if icon then
            story= '|T'..icon..':0|t'..story
        end
    end

    Frame.Text:SetText(m)


    Frame.storyText:SetText(story or '')
    Frame.storyText.achievementID= achievementID or nil
end








local function Init()
    Frame= CreateFrame('Frame', nil, _G['WoWTools_PlusWorldMap_MenuButton'])
    Frame:SetPoint('LEFT')
    Frame:SetSize(1,1)

    Frame.Text=WoWTools_LabelMixin:Create(Frame, {copyFont=WorldMapFrameTitleText})
    Frame.Text:SetPoint('RIGHT', Frame, 'LEFT', -2, 0)

    Frame.storyText=WoWTools_LabelMixin:Create(Frame)--, {copyFont=WorldMapFrameTitleText})
    Frame.storyText:SetPoint('RIGHT', Frame.Text, 'LEFT', -2, 0)
    --Frame.storyText:SetPoint('BOTTOM', WoWTools_PlusWorldMap_MenuButton, 'TOP', 0, 2)
    Frame.storyText:EnableMouse(true)
    Frame.storyText:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    Frame.storyText:SetScript('OnEnter', function(self)
        if not self.achievementID then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:SetAchievementByID(self.achievementID)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(e.onlyChinese and '查看' or VIEW, e.Icon.left)
        GameTooltip:AddDoubleLine(
            e.onlyChinese and '发送链接' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SEND_LABEL, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK),
            e.Icon.right
        )
        GameTooltip:Show()
        self:SetAlpha(0.7)
    end)
    Frame.storyText:SetScript("OnMouseUp", function(self) self:SetAlpha(0.7) end)
    Frame.storyText:SetScript('OnMouseDown', function(self, b)
        if not self.achievementID then
            return
        end
        if b=='RightButton' then
            print(GetAchievementLink(self.achievementID) or self.achievementID)
        else
            WoWTools_LoadUIMixin:Achievement(self.achievementID)--打开成就
        end
        self:SetAlpha(0.3)
    end)


    --hooksecurefunc(WorldMapFrame.ScrollContainer, 'SetMapID', function(self, mapID)--MapCanvasScrollControllerMixin
    hooksecurefunc(WorldMapFrame, 'OnMapChanged', Set_Text)--Blizzard_WorldMap.lua    
    --hooksecurefunc('QuestMapLogTitleButton_OnClick',function(self, button)--任务日志 展开所有, 收起所有--QuestMapFrame.lua


    Frame:SetScript('OnShow', Set_Text)
    Frame:SetScript('OnHide', function(self)
        self.Text:SetText('')
        self.storyText:SetText('')
    end)

    function Frame:Settings()
        Frame:SetShown(Save().ShowMapID)
        Frame:SetScale(Save().MapIDScale or 1)
    end

    Frame:Settings()

    if Frame:IsVisible() then
        Set_Text()
    end
end




function WoWTools_WorldMapMixin:Init_MpaID()
    if Frame then
        Frame:Settings()

    elseif self.Save.ShowMapID then
        Init()
    end
end