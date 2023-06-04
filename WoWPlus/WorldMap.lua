local id, e = ...
local addName = WORLD_MAP
local addName2=RESET_POSITION:gsub(RESET, PLAYER)
local Save={
    --PlayerXY=true,--玩家实时，坐标
}
local panel=CreateFrame("Frame")


--###########
--世界地图任务
--###########
local function set_WorldQuestPinMixin_RefreshVisuals(self)----WorldQuestDataProvider.lua self.tagInfo
    if Save.hide then
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
    itemLevel= (itemLevel and itemLevel>1) and itemLevel
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
        self.str=e.Cstr(self, {size=26})
        self.str:SetPoint('TOP', self, 'BOTTOM', 0, 0)
    end

    local str
    str= itemLevel or (numItems and numItems>1) and numItems--数量

    if str then
        if quality and quality~=1 then
            str='|c'..select(4, GetItemQualityColor(quality))..str..'|r'
        elseif tagInfo.quality==1 then
            str='|cffa335ee'..str..'|r'
        elseif tagInfo.quality==2 then
            str='|cffe6cc80'..str..'|r'
        end
    end

    local setLevelUp
    local itemEquipLoc= itemID and select(4, GetItemInfoInstant(itemID))
    local invSlot = itemEquipLoc and e.itemSlotTable[itemEquipLoc]
    if invSlot and itemName and itemLevel and itemLevel>1 then--装等
        local itemLinkPlayer =  GetInventoryItemLink('player', invSlot)
        if itemLinkPlayer then
            local lv=GetDetailedItemLevelInfo(itemLinkPlayer)
            if lv and itemLevel-lv>0 then
                str= (str or '')..e.Icon.up2
                setLevelUp=true
            end
        end
    end

    if not setLevelUp then
        local sourceID =itemID and select(2, C_TransmogCollection.GetItemInfo(itemID))--幻化
        if sourceID then
            local collectedText, isCollected=e.GetItemCollected(nil, sourceID, true)--物品是否收集 
            if collectedText and not isCollected then
                str=(str or '')..collectedText
            end
        end
    end


    self.str:SetText(str or '')
    self.str:SetShown(str and true or false)

    if self.worldQuestType ~= Enum.QuestTagType.Normal then
        local inProgress = self.dataProvider:IsMarkingActiveQuests() and C_QuestLog.IsOnQuest(self.questID)
        local atlas= QuestUtil.GetWorldQuestAtlasInfo(self.worldQuestType, inProgress, tagInfo.tradeskillLineID, self.questID)
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
end

--#######
--任务日志
--#######
local function setMapQuestList()--世界地图,任务, 加 - + 按钮
    if not Save.hide and not QuestScrollFrame.btnExpand then
        QuestScrollFrame.btnCollapse= e.Cbtn(QuestScrollFrame, {size={22,22}, atlas='campaign_headericon_closed'})--campaign_headericon_closed
        QuestScrollFrame.btnCollapse:SetPoint('TOPLEFT', QuestScrollFrame,'BOTTOMLEFT', 24,0)
        QuestScrollFrame.btnCollapse:SetPushedAtlas('campaign_headericon_closedpressed')
        QuestScrollFrame.btnCollapse:SetHighlightAtlas('Forge-ColorSwatchSelection')
        QuestScrollFrame.btnCollapse:SetAlpha(0.5)
        QuestScrollFrame.btnCollapse:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
        QuestScrollFrame.btnCollapse:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(not e.onlyChinese and HUD_EDIT_MODE_COLLAPSE_OPTIONS or "收起选项 |A:editmode-up-arrow:16:11:0:3|a")
            e.tips:Show()
            self2:SetAlpha(1)
        end)
        QuestScrollFrame.btnCollapse:SetScript("OnMouseDown", function()
            for i=1, C_QuestLog.GetNumQuestLogEntries() do
                CollapseQuestHeader(i)
            end
        end)

        QuestScrollFrame.btnExpand= e.Cbtn(QuestScrollFrame, {size={22,22}, atlas='campaign_headericon_open'})
        QuestScrollFrame.btnExpand:SetPoint('LEFT', QuestScrollFrame.btnCollapse, 'RIGHT', 2, 0)
        QuestScrollFrame.btnExpand:SetPushedAtlas('campaign_headericon_openpressed')
        QuestScrollFrame.btnExpand:SetHighlightAtlas('Forge-ColorSwatchSelection')
        QuestScrollFrame.btnExpand:SetAlpha(0.5)
        QuestScrollFrame.btnExpand:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
        QuestScrollFrame.btnExpand:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(not e.onlyChinese and HUD_EDIT_MODE_EXPAND_OPTIONS or "展开选项 |A:editmode-down-arrow:16:11:0:-7|a")
            e.tips:Show()
            self2:SetAlpha(1)
        end)
        QuestScrollFrame.btnExpand:SetScript("OnMouseDown", function()
            for i=1, C_QuestLog.GetNumQuestLogEntries() do
                ExpandQuestHeader(i)
            end
        end)

        QuestScrollFrame.btnDeleteAllQuest=e.Cbtn(QuestScrollFrame,{size={18,18}, atlas='xmarksthespot'})
        QuestScrollFrame.btnDeleteAllQuest:SetPoint('RIGHT', QuestScrollFrame.btnCollapse, 'LEFT', -2, 0)
        QuestScrollFrame.btnDeleteAllQuest:SetAlpha(0.5)
        QuestScrollFrame.btnDeleteAllQuest:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
        QuestScrollFrame.btnDeleteAllQuest:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(not e.onlyChinese and LOOT_HISTORY_ALL_PASSED or "全部放弃", '|cnRED_FONT_COLOR:'..(not e.onlyChinese and VOICEMACRO_1_Sc_0 or "危险！"))
            e.tips:Show()
            self2:SetAlpha(1)
        end)
        QuestScrollFrame.btnDeleteAllQuest:SetScript("OnMouseDown", function()
            StaticPopupDialogs[id..addName.."ABANDON_QUEST"] = {
                text= (e.onlyChinese and "放弃\"%s\"？" or ABANDON_QUEST_CONFIRM)..'|n|n|cnYELLOW_FONT_COLOR:'..(not e.onlyChinese and VOICEMACRO_1_Sc_0..' ' or "危险！")..(not e.onlyChinese and VOICEMACRO_1_Sc_0..' ' or "危险！")..(not e.onlyChinese and VOICEMACRO_1_Sc_0 or "危险！"),
                button1 = '|cnRED_FONT_COLOR:'..(not e.onlyChinese and ABANDON_QUEST_ABBREV or "放弃"),
                button2 = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '取消' or CANCEL),
                OnAccept = function(self2)
                    local n=0
                    for index=1 , C_QuestLog.GetNumQuestLogEntries() do
                        local questInfo=C_QuestLog.GetInfo(index)
                        if questInfo and questInfo.questID and C_QuestLog.CanAbandonQuest(questInfo.questID) then
                            local linkQuest=GetQuestLink(questInfo.questID)
                            C_QuestLog.SetSelectedQuest(questInfo.questID)
                            C_QuestLog.SetAbandonQuest();
                            C_QuestLog.AbandonQuest()
                            n=n+1
                            if linkQuest then
                                print(id, addName,  e.onlyChinese and '放弃|A:groupfinder-icon-redx:0:0|a' or (ABANDON_QUEST_ABBREV..'|A:groupfinder-icon-redx:0:0|a'), linkQuest, n..'|cnRED_FONT_COLOR:)')
                            end
                        end
                        if IsModifierKeyDown() then
                            break
                        end
                    end
                    PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
                end,
                timeout = 30,
                whileDead = true,
                exclusive = true,
                hideOnEscape = true,
                showAlert= true,
            }
            StaticPopup_Show(id..addName.."ABANDON_QUEST", '|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '|n|A:groupfinder-icon-redx:0:0|a所有任务' or ('|n|A:groupfinder-icon-redx:0:0|a'..ALL))..' |r#|cnGREEN_FONT_COLOR:'..select(2, C_QuestLog.GetNumQuestLogEntries())..'|r')
        end)

    end

    if QuestScrollFrame.btnExpand then
        QuestScrollFrame.btnExpand:SetShown(not Save.hide)
        QuestScrollFrame.btnCollapse:SetShown(not Save.hide)
        QuestScrollFrame.btnDeleteAllQuest:SetShown(not Save.hide)
    end
end




local function getPlayerXY()--当前世界地图位置
    local uiMapID= C_Map.GetBestMapForUnit("player")--当前地图        
    if uiMapID then
        local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
        if position then
            local x,y
            x,y=position:GetXY()
            if x and y then
                x=('%.2f'):format(x*100)
                y=('%.2f'):format(y*100)
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


--###############
--实时玩家当前坐标
--###############
local function CursorPositionInt()
    local frame=WorldMapFrame
    if not Save.PlayerXY or frame.playerPostionBtn then
        if frame.playerPostionBtn then
            frame.playerPostionBtn:SetShown(Save.PlayerXY)
        end
        return
    end
    frame.playerPostionBtn= e.Cbtn(nil, {icon='hide', size={12,12}})-- CreateFrame('Button', nil, UIParent)
    if not Save.PlayerXYPoint then
        frame.playerPostionBtn:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT',-50, 5)
    else
        frame.playerPostionBtn:SetPoint(Save.PlayerXYPoint[1], UIParent, Save.PlayerXYPoint[3], Save.PlayerXYPoint[4], Save.PlayerXYPoint[5])
    end

    frame.playerPostionBtn:SetFrameStrata('HIGH')
    frame.playerPostionBtn:SetMovable(true)
    frame.playerPostionBtn:RegisterForDrag("RightButton")
    frame.playerPostionBtn:SetClampedToScreen(true)
    frame.playerPostionBtn:SetScript("OnDragStart", function(self2, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
            self2:StartMoving()
        end
    end)
    frame.playerPostionBtn:SetScript("OnDragStop", function(self2, d)
        self2:StopMovingOrSizing()
        Save.PlayerXYPoint={self2:GetPoint(1)}
        Save.PlayerXYPoint[2]=nil
        ResetCursor()
    end)
    frame.playerPostionBtn:SetScript("OnMouseUp", function(self2,d)
       if d=='LeftButton' and not IsModifierKeyDown() then
            sendPlayerPoint()--发送玩家位置
        end
        ResetCursor()
    end)
    frame.playerPostionBtn:SetScript("OnEnter",function(self2)
        e.tips:ClearLines()
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(id, addName2)
        e.tips:AddLine(' ')
        local can
        can= C_Map.GetBestMapForUnit("player")
        can= can and C_Map.CanSetUserWaypointOnMap(can)
        e.tips:AddDoubleLine('|A:Waypoint-MapPin-ChatIcon:0:0|a'..(e.onlyChinese and '发送位置' or RESET_POSITION:gsub(RESET, SEND_LABEL)), (not can and GetMinimapZoneText() or not can and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE)..'|r' or '') ..e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '大小' or FONT_SIZE, (Save.PlayerXYSize or 12)..e.Icon.mid)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
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
        e.Cstr(nil, {size=size, changeFont=self.Text})
        print(id,addName, e.onlyChinese and '大小' or FONT_SIZE, size)
    end)

    frame.playerPostionBtn.Text=e.Cstr(frame.playerPostionBtn, {size=Save.PlayerXYSize, color=true})
    frame.playerPostionBtn.Text:SetPoint('BOTTOMRIGHT')

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


--#########
--地图ID提示
--#########
local function setOnEnter(self)
    local frame=WorldMapFrame
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(id, addName)
    e.tips:AddLine(' ')
    if e.Player.Layer then
        e.tips:AddDoubleLine(e.Player.LayerText, e.Player.Layer)
    end
    local uiMapID = frame.mapID or frame:GetMapID("current")
    if uiMapID then
        local info = C_Map.GetMapInfo(uiMapID)
        if info then
            e.tips:AddDoubleLine(info.name, 'mapID '..info.mapID or uiMapID)--地图ID
            local uiMapGroupID = C_Map.GetMapGroupID(uiMapID)
            if uiMapGroupID then
                e.tips:AddDoubleLine(e.onlyChinese and '区域' or FLOOR, 'uiMapGroupID g'..uiMapGroupID)
            end
        end
        local areaPoiIDs=C_AreaPoiInfo.GetAreaPOIForMap(uiMapID)
        if areaPoiIDs then
            for _,areaPoiID in pairs(areaPoiIDs) do
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
                if poiInfo and (poiInfo.areaPoiID or poiInfo.widgetSetID) then
                    e.tips:AddDoubleLine((poiInfo.atlasName and '|A:'..poiInfo.atlasName..':0:0|a' or '')
                    .. poiInfo.name
                    ..(poiInfo.widgetSetID and 'widgetSetID '..poiInfo.widgetSetID or ''),
                    'areaPoiID '..(poiInfo.areaPoiID or NONE))
                end
            end
        end
        if IsInInstance() then--副本数据
            local instanceID, _, LfgDungeonID =select(8, GetInstanceInfo())
            if instanceID then
                e.tips:AddDoubleLine(e.onlyChinese and '副本' or INSTANCE, instanceID)
                if LfgDungeonID then
                    e.tips:AddDoubleLine(e.onlyChinese and '随机副本' or LFG_TYPE_RANDOM_DUNGEON, LfgDungeonID)
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
                e.tips:AddDoubleLine(e.onlyChinese and '位置' or (RESET_POSITION:gsub(RESET, e.Icon.player)), 'XY: '..x..' '..y)
            end
        end
    end
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(addName, e.GetEnabeleDisable(not Save.hide)..e.Icon.left)
    e.tips:AddDoubleLine(addName2, e.GetEnabeleDisable(Save.PlayerXY)..e.Icon.right)
    e.tips:Show()
end

local function setMapIDText(self)
    local m=''
    if not Save.hide then
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
                        m=(e.onlyChinese and '随机' or 'Random')..LfgDungeonID..'  '..m
                    end
                end
            end
            if not self.mapInfoBtn.mapID then--字符
                self.mapInfoBtn.mapID=e.Cstr(self.BorderFrame.TitleContainer, {copyFont=WorldMapFrameTitleText})
                self.mapInfoBtn.mapID:SetPoint('RIGHT', self.mapInfoBtn, 'LEFT')
            end
        end
        if e.Player.Layer then
            m = e.Player.Layer..' '..m
        end
    end
    if self.mapInfoBtn.mapID then
        self.mapInfoBtn.mapID:SetText(m)
    end
    self.playerPosition:SetShown(not Save.hide)
end

local function set_Map_ID(self)--显示地图ID
    if not self.mapInfoBtn then
        self.mapInfoBtn=e.Cbtn(self.BorderFrame.TitleContainer, {icon='hide', size={22,22}})
        if IsAddOnLoaded('Mapster') then
            self.mapInfoBtn:SetPoint('RIGHT', self.BorderFrame.TitleContainer, 'RIGHT', -140,0)
        else
            self.mapInfoBtn:SetPoint('RIGHT', self.BorderFrame.TitleContainer, 'RIGHT', -50,0)
        end
        self.mapInfoBtn:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.map)
        self.mapInfoBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        self.mapInfoBtn:SetScript('OnEnter', setOnEnter)
        self.mapInfoBtn:SetScript('OnLeave', function() e.tips:Hide() end)
        self.mapInfoBtn:SetScript('OnMouseDown', function(self2, d)
            if d=="LeftButton" then
                Save.hide= not Save.hide and true or nil
                setMapIDText(self)
                setMapQuestList()--世界地图,任务, 加 - + 按钮
                print(id, addName, e.GetShowHide(not Save.hide), e.onlyChinese and ' 刷新' or REFRESH)
                self.mapInfoBtn:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.map)
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
        self.playerPosition=e.Cbtn(self.BorderFrame.TitleContainer, {icon='hide', size={22,22}})
        if _G['MoveZoomInButtonPerWorldMapFrame'] then
            self.playerPosition:SetPoint('LEFT', _G['MoveZoomInButtonPerWorldMapFrame'], 'RIGHT')
        else
            self.playerPosition:SetPoint('LEFT', self.BorderFrame.TitleContainer, 'LEFT', 75, -2)
        end
        self.playerPosition:SetNormalAtlas(e.Icon.player:match('|A:(.-):'))
        self.playerPosition:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        self.playerPosition:SetScript('OnLeave', function() e.tips:Hide() end)
        self.playerPosition:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddLine(' ')
            local can
            can= C_Map.GetBestMapForUnit("player")
            can= can and C_Map.CanSetUserWaypointOnMap(can)
            e.tips:AddDoubleLine('|A:Waypoint-MapPin-ChatIcon:0:0|a'..(e.onlyChinese and '发送位置' or RESET_POSITION:gsub(RESET, SEND_LABEL)), (not can and GetMinimapZoneText() or not can and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE)..'|r' or '')..e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '返回当前地图' or (PREVIOUS..REFORGE_CURRENT..WORLD_MAP), e.Icon.right)
            e.tips:Show()
        end)
        self.playerPosition:SetScript('OnMouseDown', function(self2, d)
            if d=='RightButton' then--返回当前地图                
	            self:SetMapID(MapUtil.GetDisplayableMapForPlayer())
            elseif d=='LeftButton' then
                sendPlayerPoint()--发送玩家位置
            end
        end)

        self.playerPosition.edit= CreateFrame("EditBox", nil, self.playerPosition, 'InputBoxTemplate')
        self.playerPosition.edit:SetSize(73,20)
        self.playerPosition.edit:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
        self.playerPosition.edit:SetAutoFocus(false)
        self.playerPosition.edit:ClearFocus()
        self.playerPosition.edit:SetPoint('LEFT', self.playerPosition, 'RIGHT',2,0)
        self.playerPosition.edit:SetScript('OnEditFocusLost', function(self2)
            self2:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
        end)
        self.playerPosition.edit:SetScript('OnEditFocusGained', function(self2)
            self2:HighlightText()
            self2:SetTextColor(1,1,1)
        end)
        self.playerPosition.edit:SetScript("OnKeyUp", function(s, key)
            if IsControlKeyDown() and key == "C" then
                s:ClearFocus()
                print(id,addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r', s:GetText())
            end
        end)
        self.playerPosition.edit.Left:SetAlpha(0.5)
        self.playerPosition.edit.Middle:SetAlpha(0.5)
        self.playerPosition.edit.Right:SetAlpha(0.5)

        self.playerPosition.Text=e.Cstr(self.playerPosition, {copyFont=WorldMapFrameTitleText})--玩家当前坐标
        self.playerPosition.Text:SetPoint('LEFT',self.playerPosition.edit, 'RIGHT', 2,0)
        self.playerPosition.elapsed=0
        self.playerPosition:HookScript("OnUpdate", function (self2, elapsed)
            self2.elapsed = self2.elapsed + elapsed
            if self2.elapsed > 0.15 then
                self2.elapsed = 0
                local text=''
                local x, y= getPlayerXY()--玩家当前坐标
                if x and y then
                    text=x..' '..y
                end
                if not self2.edit:HasFocus() then
                    self2.edit:SetText(text)
                end
                x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()--当前世界地图位置
                if x and y then
                    text = ('%.2f'):format(x*100)..' '..('%.2f'):format(y*100)
                else
                    text=''
                end
                self.playerPosition.Text:SetText(text)
            end
        end)
    end

    setMapIDText(self)
end

local function set_AreaPOIPinMixin_OnAcquired(poiInfo)--地图POI提示 AreaPOIDataProvider.lua
    if not poiInfo or Save.hide then
        if poiInfo and poiInfo.Str then
            poiInfo.Str:SetText('')
        end
        return
    end

    local t=''
    if poiInfo.widgetSetID==399 then --托尔加斯特
        local R={}
        local sets = C_UIWidgetManager.GetAllWidgetsBySetID(399) or {}
        for _,v in ipairs(sets) do
            local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(v.widgetID)
            if widgetInfo and widgetInfo.shownState == Enum.WidgetShownState.Shown then
                R[widgetInfo.orderIndex] = widgetInfo.text
            end
        end
        for i,v in pairs(R) do
            if i%2 ==0 then
                local name = string.gsub(v,'|n','')
                local leveltext =string.gsub(R[i+1],'|n','')
                R[i] = string.format("%s-%s",name,leveltext)
                R[i+1] = nil
            end
        end
        t=C_AreaPoiInfo.GetAreaPOIInfo(1543,6640).name
        for _,v in pairs(R) do
            t=t..'|n '..v
        end
    elseif poiInfo.name then
        t=poiInfo.name
        local ds=poiInfo.description
        if not t or #t<1 or t:find(COVENANT_UNLOCK_TRANSPORT_NETWORK) or (ds and ds:find(ANIMA_DIVERSION_ORIGIN_TOOLTIP )) then
            if poiInfo.Str then poiInfo.Str:SetText('') end
            return
        end
        t=t:match('%((.+)%)') or t
        t=t:match('（(.+)）') or t
        t=t:match(',(.+)') or t
        t=t:match(UNITNAME_SUMMON_TITLE14:gsub('%%s','%(%.%+%)')) or t
        t=t:gsub(PET_ACTION_MOVE_TO,'')
        t=t:gsub(SPLASH_BATTLEFORAZEROTH_8_1_0_FEATURE2_TITLE..':','')
        t=t:gsub(SPLASH_BATTLEFORAZEROTH_8_1_0_FEATURE2_TITLE..'：','')
    end

    if t~='' and not poiInfo.Str then
        poiInfo.Str=e.Cstr(poiInfo, {size=10, justifyH='CENTER'})
        poiInfo.Str:SetPoint('BOTTOM', poiInfo, 'TOP', 0, -3)
    end

    if poiInfo.areaPoiID and C_AreaPoiInfo.IsAreaPOITimed(poiInfo.areaPoiID) then
        local seconds= C_AreaPoiInfo.GetAreaPOISecondsLeft(poiInfo.areaPoiID)
        if seconds and seconds>0 then
            t= t~='' and t..'|n' or t
            t= t..'|cnGREEN_FONT_COLOR:'..SecondsToTime(seconds)..'|r'
        end
    end

    if poiInfo.widgetSetID then
        local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(poiInfo.widgetSetID) or {}
        for _,widget in ipairs(widgets) do
            if widget and widget.widgetID and  widget.widgetType==8 then
                local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID)
                if widgetInfo and widgetInfo.shownState== 1  and widgetInfo.text then

                    local icon, num= widgetInfo.text:match('(|T.-|t).-]|r.-(%d+)')
                    local text= widgetInfo.text:match('(%d+/%d+)')--次数
                    if icon and num then
                        t= t..icon..'|cff00ff00'..num..'|r'
                    end
                    if text then
                        t= t..'|cffff00ff'..text..'|r'
                    end
                end
            end
        end
    end

    if poiInfo.Str then
        poiInfo.Str:SetText(t)
    end
end



--####
--初始
--####
local function Init()
    hooksecurefunc(WorldQuestPinMixin, 'RefreshVisuals', set_WorldQuestPinMixin_RefreshVisuals)--世界地图任务
    hooksecurefunc(WorldMapFrame, 'OnMapChanged', set_Map_ID)--Blizzard_WorldMap.lua
    CursorPositionInt()
    hooksecurefunc(AreaPOIPinMixin,'OnAcquired', set_AreaPOIPinMixin_OnAcquired)--地图POI提示 AreaPOIDataProvider.lua
    setMapQuestList()--世界地图,任务, 加 - + 按钮
    --hooksecurefunc('QuestMapLogTitleButton_OnClick',function(self, button)--任务日志 展开所有, 收起所有--QuestMapFrame.lua
end

--加载保存数据
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(e.Icon.map2..(e.onlyChinese and '地图' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)