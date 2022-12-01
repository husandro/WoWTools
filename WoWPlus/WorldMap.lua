local id, e = ...
local addName =WORLD_MAP
local addName2=RESET_POSITION:gsub(RESET, PLAYER)
local Save={}
local QuestTagTypeIcon = {
    --Tag = 0,
    --Profession = 1,
    --Normal = 2,
    [3]='worldquest-icon-pvp-ffa',--PvP = 3,
    [4]='worldquest-icon-petbattle',--PetBattle = 4,
    --Bounty = 5,
    --Dungeon = 6,
    --Invasion = 7,
    --Raid = 8,
    --Contribution = 9,
    --RatedReward = 10,
    --InvasionWrapper = 11,
    --FactionAssault = 12,
    --Islands = 13,
    --Threat = 14,
    [15]='Callings-Available',--CovenantCalling = 15,
}
--世界地图任务--WorldQuestDataProvider.lua
hooksecurefunc(WorldQuestPinMixin, 'RefreshVisuals', function(self)--self.tagInfo
    if Save.disabled then
        if self.str then
            self.str:SetShown(false)
        end
        if self.worldQuestTypeTips then
            self.worldQuestTypeTips:SetShown(false)
        end
        return
    end
    local tagInfo=self.tagInfo
    local itemName, itemTexture, numItems, quality, _, itemID, itemLevel    
    itemName, itemTexture, numItems, quality, _, itemID, itemLevel = GetQuestLogRewardInfo(1, self.questID)
    if not itemName then
        itemName, itemTexture, numItems, _, quality = GetQuestLogRewardCurrencyInfo(1, self.questID)
    end
    if not itemName then
        itemLevel=GetQuestLogRewardMoney(self.questID)
        if itemLevel then
            itemLevel=e.MK(itemLevel/10000,1)
            itemTexture='interface\\moneyframe\\ui-goldicon'
        end
    end
    self.Texture:SetTexture(itemTexture)
    self.Texture:SetSize(45, 45)
    if not self.str then
        self.str=e.Cstr(self,26)
        self.str:SetPoint('TOP', self, 'BOTTOM', 0, 0)
    end
    local str= itemLevel or numItems
    if str then
        if quality and quality~=1 then
            str='|c'..select(4, GetItemQualityColor(quality))..str..'|r'
        elseif tagInfo.quality==1 then
            str='|cffa335ee'..str..'|r'
        elseif tagInfo.quality==2 then
            str='|cffe6cc80'..str..'|r'
        end
    end
    local sourceID =itemID and select(2, C_TransmogCollection.GetItemInfo(itemID))--幻化
    local sourceInfo = sourceID and C_TransmogCollection.GetSourceInfo(sourceID)
    if sourceInfo then
        str=(str or '')..(sourceInfo.isCollected and e.Icon.okTransmog2 or e.Icon.transmogHide2)
    end
    self.str:SetText(str or '')
    self.str:SetShown(str and true or false)

    if self.worldQuestType ~= Enum.QuestTagType.Normal then
        
        local inProgress = self.dataProvider:IsMarkingActiveQuests() and C_QuestLog.IsOnQuest(self.questID);
        local atlas= QuestUtil.GetWorldQuestAtlasInfo(self.worldQuestType, inProgress, tagInfo.tradeskillLineID, self.questID);
        if not self.worldQuestTypeTips then
            self.worldQuestTypeTips=self:CreateTexture(nil, 'OVERLAY')
            self.worldQuestTypeTips:SetPoint('TOPRIGHT', self.Texture, 'TOPRIGHT', 5, 5)
            self.worldQuestTypeTips:SetSize(30, 30)
        end
        self.worldQuestTypeTips:SetAtlas(atlas)
    end
    if self.worldQuestTypeTips then
        self.worldQuestTypeTips:SetShown(self.worldQuestType ~= Enum.QuestTagType.Normal)
    end
end)

--任务日志
local Code=IN_GAME_NAVIGATION_RANGE:gsub('d','s')--%s码    
local function Quest(self, questID)--任务
    if not HaveQuestData(questID) then return end
    local t=''
    local lv=C_QuestLog.GetQuestDifficultyLevel(questID)--ID
    if lv then t=t..'['..lv..']' else t=t..' 'end
    if C_QuestLog.IsComplete(questID) then t=t..'|cFF00FF00'..COMPLETE..'|r' else t=t..INCOMPLETE end
    if t=='' then t=t..QUESTS_LABEL end    
    t=t..' ID:'
    self:AddDoubleLine(t, questID)

    local distanceSq= C_QuestLog.GetDistanceSqToQuest(questID)--距离
    if distanceSq then
        t= TRACK_QUEST_PROXIMITY_SORTING..': '
        local _, x, y = QuestPOIGetIconInfo(questID)
        if x and y then
            x=math.modf(x*100) y=math.modf(y*100)
            if x and y then t=t..x..', '..y end
        end
        self:AddDoubleLine(t,  Code:format(e.MK(distanceSq)))
    end
    if IsInGroup() then
        if C_QuestLog.IsPushableQuest(questID) then t='|cFF00FF00'..YES..'|r' else t=NO end--共享
        local t2=SHARE_QUEST..': '
        local u if IsInRaid() then u='raid' else u='party' end
        local n,acceto=GetNumGroupMembers(), 0
        for i=1, n do
            local u2
            if u=='party' and i==n then u2='player' else u2=u..i end
            if C_QuestLog.IsUnitOnQuest(u2, questID) then acceto=acceto+1 end            
        end
        t2=t2..acceto..'/'..n
        self:AddDoubleLine(t2, t)
    end
    local all=C_QuestLog.GetAllCompletedQuestIDs()--完成次数
    if all and #all>0 then
        t= GetDailyQuestsCompleted() or '0'
        t=t..DAILY..' '..#all..QUESTS_LABEL
        self:AddDoubleLine(TRACKER_FILTER_COMPLETED_QUESTS..': ', t)
    end
    --local info=C_QuestLog.GetQuestDetailsTheme(questID)--POI图标
    --if info and info.poiIcon then e.playerTexSet(info.poiIcon, nil) end--设置图,像
    self:Show()
end
hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)--任务日志 显示ID
        if Save.disabled or not self.questLogIndex then
            return
        end
        local info = C_QuestLog.GetInfo(self.questLogIndex)
        if not info or not info.questID then return end
        Quest(e.tips, info.questID)
end)
local function Coll()
    for i=1, C_QuestLog.GetNumQuestLogEntries() do
        CollapseQuestHeader(i)
    end
end
local function Exp()
    for i=1, C_QuestLog.GetNumQuestLogEntries() do
        ExpandQuestHeader(i)
    end
end
hooksecurefunc('QuestMapLogTitleButton_OnClick',function(self, button)--任务日志 展开所有, 收起所有
        if Save.disabled or ChatEdit_TryInsertQuestLinkForQuestID(self.questID) then
            return
        end
        if not C_QuestLog.IsQuestDisabledForSession(self.questID) and button == "RightButton" then
            UIDropDownMenu_AddSeparator()
            local info= UIDropDownMenu_CreateInfo()
            info.notCheckable=true
            info.text=SHOW..'|A:campaign_headericon_open:0:0|a'..ALL
            info.func=function()
                Exp()
            end
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info = UIDropDownMenu_CreateInfo()
            info.notCheckable=true
            info.text=HIDE..'|A:campaign_headericon_closed:0:0|a'..ALL
            info.func=function()
                Coll()
            end
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)            
        end
end)--QuestMapFrame.lua
local function setMapQuestList()--世界地图,任务, 加 - + 按钮
    local f=QuestScrollFrame
    if not Save.disabled and not f.btn then
        f.btn= CreateFrame("Button", nil, f)
        f.btn:SetPoint('BOTTOM')
        f.btn:SetSize(20,20)
        f.btn:SetNormalAtlas('campaign_headericon_open')
        f.btn:SetPushedAtlas('campaign_headericon_openpressed')
        f.btn:SetHighlightAtlas('Forge-ColorSwatchSelection')
        f.btn:SetScript("OnMouseDown", function()
                Exp()
        end)
        f.btn:SetFrameStrata('DIALOG')

        f.btn2= CreateFrame("Button", nil, f.btn)
        f.btn2:SetPoint('BOTTOMRIGHT', f.btn, 'BOTTOMLEFT', 2, 0)
        f.btn2:SetSize(20,20)
        f.btn2:SetNormalAtlas('campaign_headericon_closed')
        f.btn2:SetPushedAtlas('campaign_headericon_closedpressed')
        f.btn2:SetHighlightAtlas('Forge-ColorSwatchSelection')
        f.btn2:SetScript("OnMouseDown", function()
                Coll()
        end)
    end
    if f.btn then
        f.btn:SetShown(not Save.disabled)
        f.btn2:SetShown(not Save.disabled)
    end
end

local function getPlayerXY()--当前世界地图位置
    local uiMapID= C_Map.GetBestMapForUnit("player")--当前地图        
    if uiMapID then
        local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
        if position then
            local x,y=position:GetXY()
            if x and y then
                x=('%.1f'):format(x*100)
                y=('%.1f'):format(y*100)
                return x, y
            end
        end
    end
end
local function sendPlayerPoint()--发送玩家位置
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID then
        if  C_Map.CanSetUserWaypointOnMap(mapID) then
            local point=C_Map.GetUserWaypoint()
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)
            C_Map.SetUserWaypoint(mapPoint)
            ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..C_Map.GetUserWaypointHyperlink())
            if point then
                C_Map.SetUserWaypoint(point)
            else
                C_Map.ClearUserWaypoint()
            end
            return
        else
            local x, y=getPlayerXY()
            if x and y then
                local pointText=x..' '..y
                local info=C_Map.GetMapInfo(mapID)
                if info and info.name then
                    pointText=pointText..' '..info.name
                end
                ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..pointText)
                return
            end
        end
    end
    local name=GetMinimapZoneText()
    local name2
    if mapID then
        local info=C_Map.GetMapInfo(mapID)
        name2=info and info.name
    end
    if name  or name2 then
        if name2 and name~=name2 then
            name=name2..'('..name..')'
        end
        name =name or name2
        ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..name)
    else
        print("Cannot set waypoints on this map")
    end
end

local function CursorPositionInt()
    local frame=WorldMapFrame
    if not Save.PlayerXY or frame.playerPostionBtn then
        if frame.playerPostionBtn then
            frame.playerPostionBtn:SetShown(Save.PlayerXY)
        end
        return
    end
    frame.playerPostionBtn=CreateFrame('Button', nil, UIParent)--实时玩家当前坐标
    frame.playerPostionBtn:SetHighlightAtlas(e.Icon.highlight)
    frame.playerPostionBtn:SetPushedAtlas(e.Icon.pushed)
    if not Save.PlayerXYPoint then
        frame.playerPostionBtn:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT',-50, 5)
    else
        frame.playerPostionBtn:SetPoint(Save.PlayerXYPoint[1], UIParent, Save.PlayerXYPoint[3], Save.PlayerXYPoint[4], Save.PlayerXYPoint[5])
    end
    frame.playerPostionBtn:SetSize(12,12)
    frame.playerPostionBtn:RegisterForClicks("LeftButtonDown","RightButtonDown")
    frame.playerPostionBtn:EnableMouseWheel(true)
    frame.playerPostionBtn:SetMovable(true)
    frame.playerPostionBtn:RegisterForDrag("RightButton");
    frame.playerPostionBtn:SetClampedToScreen(true);
    frame.playerPostionBtn:SetScript("OnDragStart", function(self2, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
            self2:StartMoving()
        end
    end)
    frame.playerPostionBtn:SetScript("OnDragStop", function(self2, d)
        self2:StopMovingOrSizing()
        Save.PlayerXYPoint={self2:GetPoint(1)}
        print(id, addName, addName2, '|cFF00FF00Alt+'..e.Icon.right..KEY_BUTTON2..'|r: '.. TRANSMOGRIFY_TOOLTIP_REVERT)
        ResetCursor()
    end)
    frame.playerPostionBtn:SetScript("OnMouseUp", function(self2,d)
        if d=='RightButton' and IsAltKeyDown() then
            self2.PlayerXYPoint=nil
            self2:ClearAllPoints();
            self2:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT',-50, 5)
        elseif d=='LeftButton' and not IsModifierKeyDown() then
            sendPlayerPoint()--发送玩家位置
        end
        ResetCursor();
    end);
    frame.playerPostionBtn:SetScript("OnEnter",function(self2)
        if UnitAffectingCombat('player') then
            return
        end
        e.tips:ClearLines()
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(id, addName2)
        e.tips:AddLine(' ')
        local can = C_Map.GetBestMapForUnit("player")
        can= can and C_Map.CanSetUserWaypointOnMap(can)
        e.tips:AddDoubleLine('|A:Waypoint-MapPin-ChatIcon:0:0|a'..RESET_POSITION:gsub(RESET, SEND_LABEL), (not can and GetMinimapZoneText() or not can and '|cnRED_FONT_COLOR:'..NONE..'|r' or '') ..e.Icon.left)
        e.tips:AddDoubleLine(FONT_SIZE..': '..(Save.PlayerXYSize or 12), e.Icon.mid)
        e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
        e.tips:Show()
    end)
    frame.playerPostionBtn:SetScript("OnLeave", function()
        e.tips:Hide()
        ResetCursor()
    end)

    frame.playerPostionBtn:SetScript('OnMouseWheel',function(self, d)
        if IsModifierKeyDown() then
            return
        end
        local size=Save.PlayerXYSize or 12
        if d==1 then
            size=size+1
            size = size>72 and 72 or size
        elseif d==-1 then
            size=size-1
            size= size<8 and 8 or size
        end
        Save.PlayerXYSize=size
        e.Cstr(nil, size, nil, self.Text)
        print(id,FONT_SIZE..': '..size)
    end)

    frame.playerPostionBtn.Text=e.Cstr(frame.playerPostionBtn, Save.PlayerXYSize)
    frame.playerPostionBtn.Text:SetPoint('RIGHT')

    local timeElapsed = 0
    frame.playerPostionBtn:HookScript("OnUpdate", function (self, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 0.3 then
            timeElapsed = 0
            local x, y =getPlayerXY()
            if x and y then
                self.Text:SetText(x.. ' '..y)
            else
                self.Text:SetText('..')
            end
        end
    end)
end

local function setOnEnter(self)--地图ID提示
    local frame=WorldMapFrame
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(id, addName)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(e.L['LAYER']..':', e.Layer and e.Layer or NONE)
    local uiMapID = frame.mapID or frame:GetMapID("current")
    if uiMapID then
        local info = C_Map.GetMapInfo(uiMapID)
        if info then
            e.tips:AddDoubleLine(info.name, 'mapID: '..info.mapID or uiMapID)--地图ID
            local uiMapGroupID = C_Map.GetMapGroupID(uiMapID)
            if uiMapGroupID then
                e.tips:AddDoubleLine(FLOOR, 'uiMapGroupID: '..uiMapGroupID)
            end
        end
        local areaPoiIDs=C_AreaPoiInfo.GetAreaPOIForMap(uiMapID)
        if areaPoiIDs then
            for _,areaPoiID in pairs(areaPoiIDs) do
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
                if poiInfo and (poiInfo.areaPoiID or poiInfo.widgetSetID) then
                    e.tips:AddDoubleLine((poiInfo.atlasName and '|A:'..poiInfo.atlasName..':0:0|a' or '')
                    .. poiInfo.name
                    ..(poiInfo.widgetSetID and 'widgetSetID: '..poiInfo.widgetSetID or ''),
                    'areaPoiID: '..(poiInfo.areaPoiID or NONE))
                end
            end
        end
        if IsInInstance() then--副本数据
            local instanceID, _, LfgDungeonID =select(8, GetInstanceInfo())
            if instanceID then
                e.tips:AddDoubleLine(INSTANCE..'ID:', instanceID)
                if LfgDungeonID then
                    e.tips:AddDoubleLine(SLASH_RANDOM3:gsub('/','')..INSTANCE..'ID:', LfgDungeonID)
                end
            end
        end
        local x,y =getPlayerXY()
        if x and y then
            local playerCursorMapName
            local uiMapIDPlayer= C_Map.GetBestMapForUnit("player")
            if uiMapIDPlayer and uiMapIDPlayer~=uiMapID then
                local info2 = C_Map.GetMapInfo(uiMapIDPlayer)
                playerCursorMapName=info2 and info2.name
            end
            e.tips:AddLine(' ')
            if playerCursorMapName then
                e.tips:AddDoubleLine(e.Icon.player..playerCursorMapName, 'XY: '..x..' '..y)
            else
                e.tips:AddDoubleLine(RESET_POSITION:gsub(RESET, e.Icon.player), 'XY: '..x..' '..y)
            end
        end
    end
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(addName..": "..e.GetEnabeleDisable(not Save.disabled), e.Icon.left)
    e.tips:AddDoubleLine(addName2..': '..e.GetEnabeleDisable(Save.PlayerXY), e.Icon.right)
    e.tips:Show()
end

local function setMapIDText(self)
    local m=''
    if not Save.disabled then
        local uiMapID = self.mapID or self:GetMapID("current")
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
                    if poiInfo and (poiInfo.areaPoiID or poiInfo.widgetSetID) and poiInfo.atlasName then
                        m='|A:'..poiInfo.atlasName..':0:0|a'..m
                    end
                end
            end
            if IsInInstance() then
                local instanceID, _, LfgDungeonID =select(8, GetInstanceInfo())
                if instanceID then
                    m=INSTANCE..instanceID..'  '..m
                    if LfgDungeonID then
                        m=SLASH_RANDOM3:gsub('/','')..LfgDungeonID..'  '..m
                    end
                end
            end
            if not self.mapInfoBtn.mapID then--字符
                self.mapInfoBtn.mapID=e.Cstr(self.BorderFrame.TitleContainer, nil, WorldMapFrameTitleText)
                self.mapInfoBtn.mapID:SetPoint('RIGHT', self.mapInfoBtn, 'LEFT')
            end
        end
        if e.Layer then
            m = e.Layer..' '..m
        end
    end
    if self.mapInfoBtn.mapID then
        self.mapInfoBtn.mapID:SetText(m)
    end
    self.playerPosition:SetShown(not Save.disabled)
end

local function setMapID(self)--显示地图ID
    if not self.mapInfoBtn then
        self.mapInfoBtn=e.Cbtn(self.BorderFrame.TitleContainer)
        if IsAddOnLoaded('Mapster') then
            self.mapInfoBtn:SetPoint('RIGHT', self.BorderFrame.TitleContainer, 'RIGHT', -140,0)
        else
            self.mapInfoBtn:SetPoint('RIGHT', self.BorderFrame.TitleContainer, 'RIGHT', -50,0)
        end
        
        self.mapInfoBtn:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.map)
        self.mapInfoBtn:SetSize(22,22)
        self.mapInfoBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        self.mapInfoBtn:SetScript('OnEnter', setOnEnter)
        self.mapInfoBtn:SetScript('OnLeave', function() e.tips:Hide() end)
        self.mapInfoBtn:SetScript('OnClick', function(self2, d)
            if d=="LeftButton" then
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                setMapIDText(self)
                setMapQuestList()--世界地图,任务, 加 - + 按钮
                print(id, addName, e.GetShowHide(not Save.disabled))
                self.mapInfoBtn:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.map)
            elseif d=='RightButton' then--实时玩家当前坐标
                if Save.PlayerXY then
                    Save.PlayerXY=nil
                    print(id, addName, addName2..":", e.GetEnabeleDisable(Save.PlayerXY), '|cnGREEN_FONT_COLOR:'..NEED..'/reload|r')
                else
                    Save.PlayerXY=true
                    print(id, addName, addName2..":", e.GetEnabeleDisable(Save.PlayerXY))                   
                end
                CursorPositionInt()
            end
        end)
    end

    if not self.playerPosition then--玩家坐标
        self.playerPosition=e.Cbtn(self.BorderFrame.TitleContainer)
        self.playerPosition:SetPoint('LEFT', self.BorderFrame.TitleContainer, 'LEFT', 95, -2)
        self.playerPosition:SetSize(22, 22)
        self.playerPosition:SetNormalAtlas(e.Icon.player:match('|A:(.-):'))
        self.playerPosition:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        self.playerPosition:SetScript('OnLeave', function() e.tips:Hide() end)
        self.playerPosition:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddLine(' ')
            local can = C_Map.GetBestMapForUnit("player")
            can= can and C_Map.CanSetUserWaypointOnMap(can)
            e.tips:AddDoubleLine('|A:Waypoint-MapPin-ChatIcon:0:0|a'..RESET_POSITION:gsub(RESET, SEND_LABEL), (not can and GetMinimapZoneText() or not can and '|cnRED_FONT_COLOR:'..NONE..'|r' or '')..e.Icon.left)
            e.tips:AddDoubleLine(PREVIOUS..REFORGE_CURRENT..WORLD_MAP, e.Icon.right)
            e.tips:Show()
        end)
        self.playerPosition:SetScript('OnClick', function(self2, d)
            if d=='RightButton' then--返回当前地图                
	            self:SetMapID(MapUtil.GetDisplayableMapForPlayer())
            elseif d=='LeftButton' then
                sendPlayerPoint()--发送玩家位置
            end
        end)
        self.playerPosition.Text=e.Cstr(self.playerPosition, nil ,WorldMapFrameTitleText)--玩家当前坐标
        self.playerPosition.Text:SetPoint('LEFT',self.playerPosition, 'RIGHT', 2, 0)
        local timeElapsed2=0
        self.playerPosition:HookScript("OnUpdate", function (self2, elapsed)
            timeElapsed2 = timeElapsed2 + elapsed
            if timeElapsed2 > 0.15 then
                timeElapsed2 = 0
                local text=''
                local x, y= getPlayerXY()--玩家当前坐标
                if x and y then
                    text=x..' '..y
                end
                x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()--当前世界地图位置            
                if x and y then
                    text = text~='' and text..'    ' or text
                    text = text..('%.1f'):format(x*100)..' '..('%.1f'):format(y*100)
                end
                self.playerPosition.Text:SetText(text)
            end
        end)
    end
    setMapIDText(self)
end
hooksecurefunc(WorldMapFrame, 'OnMapChanged', setMapID)--Blizzard_WorldMap.lua


--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            CursorPositionInt()
            setMapQuestList()--世界地图,任务, 加 - + 按钮
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)