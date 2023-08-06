local id, e = ...
local addName = WORLD_MAP
local addName2=RESET_POSITION:gsub(RESET, PLAYER)
local Save={
    --PlayerXY=true,--玩家实时，坐标
    --showFlightMapPinName=true,飞行地图，显示，飞行点名称
}
local panel=CreateFrame("Frame")

local function create_Wolor_Font(self, size)
    local font= e.Cstr(self, {size=size, justifyH='CENTER', color=false, fontName='WorldMapTextFont'})
    return font
end










--###########
--世界地图任务
--###########
local function set_WorldQuestPinMixin_RefreshVisuals(self)--WorldQuestDataProvider.lua self.tagInfo
    if Save.hide or not self.questID then
        if self.Text then self.Text:SetText('') end
        if self.worldQuestTypeTips then self.worldQuestTypeTips:SetShown(false) end
        return
    end
    local itemName, texture, numItems, quality, _, itemID, itemLevel
    itemName, texture, numItems, quality, _, itemID, itemLevel = GetQuestLogRewardInfo(1, self.questID)--物品

    local text
    if itemName then
        if itemLevel and itemLevel>1 then
            text= itemLevel
        end

        local itemEquipLoc, _, classID = select(4, GetItemInfoInstant(itemID))
        if classID==2 or classID==4 then
            if quality and text then--物品，颜色
                text='|c'..select(4, GetItemQualityColor(quality))..itemLevel..'|r'
            end

            local setLevelUp
            local invSlot = itemEquipLoc and e.itemSlotTable[itemEquipLoc]
            if invSlot and itemName and itemLevel and itemLevel>1 then--装等
                local itemLinkPlayer =  GetInventoryItemLink('player', invSlot)
                if itemLinkPlayer then
                    local lv= GetDetailedItemLevelInfo(itemLinkPlayer)
                    if lv and itemLevel-lv>0 then
                        text= (text or '')..e.Icon.up2
                        setLevelUp=true
                    end
                end
            end
            if not setLevelUp then
                local sourceID =itemID and select(2, C_TransmogCollection.GetItemInfo(itemID))--幻化
                if sourceID then
                    local collectedText, isCollected=e.GetItemCollected(nil, sourceID, true)--物品是否收集 
                    if collectedText and not isCollected then
                        text= (text or '')..collectedText
                    end
                end
            end
        end
    else

        itemName, texture, numItems, _, quality = GetQuestLogRewardCurrencyInfo(1, self.questID)--货币
        if itemName and numItems and numItems>1 then
            text= numItems
        end

        if not itemName then
            local gold= GetQuestLogRewardMoney(self.questID)
            if gold and gold>0 then
                text= e.MK(gold/10000, 0)
                texture='interface\\moneyframe\\ui-goldicon'
            end
        end
    end

    if texture then
        self.Texture:SetTexture(texture)
        self.Texture:SetSize(40, 40)
    end

    if not self.Text and text then
        self.Text= create_Wolor_Font(self, 22)
        self.Text:SetPoint('TOP', self, 'BOTTOM',0,2)
    end
    if self.Text then
        self.Text:SetText(text or '')
    end

    local isNormalQuest= self.worldQuestType == Enum.QuestTagType.Normal--任务，类型
    if not isNormalQuest then
        local inProgress = self.dataProvider:IsMarkingActiveQuests() and C_QuestLog.IsOnQuest(self.questID)
        local atlas= QuestUtil.GetWorldQuestAtlasInfo(self.worldQuestType, inProgress, self.tagInfo.tradeskillLineID, self.questID)
        if not self.worldQuestTypeTips and atlas then
            self.worldQuestTypeTips=self:CreateTexture(nil, 'OVERLAY')
            self.worldQuestTypeTips:SetPoint('TOPRIGHT', self.Texture, 'TOPRIGHT', 5, 5)
            self.worldQuestTypeTips:SetSize(30, 30)
        end
        if atlas then
            self.worldQuestTypeTips:SetAtlas(atlas)
        end
    end
    if self.worldQuestTypeTips then
        self.worldQuestTypeTips:SetShown(not isNormalQuest)
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
            e.tips:AddDoubleLine('|cnRED_FONT_COLOR:'..(not e.onlyChinese and VOICEMACRO_1_Sc_0 or "危险！"), '|cnRED_FONT_COLOR:'..(not e.onlyChinese and VOICEMACRO_1_Sc_0 or "危险！"))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(not e.onlyChinese and LOOT_HISTORY_ALL_PASSED or "全部放弃", (e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
            self2:SetAlpha(1)
        end)
        QuestScrollFrame.btnDeleteAllQuest:SetScript("OnDoubleClick", function()
            StaticPopupDialogs[id..addName.."ABANDON_QUEST"] = StaticPopupDialogs[id..addName.."ABANDON_QUEST"] or {
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
        self2:Raise()
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
local function set_button_OnEnter(self)
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
                    ..(poiInfo.widgetSetID and ' widgetSetID '..poiInfo.widgetSetID or ''),
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

local function set_Map_ID_Text(self)
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


local function Init_set_Map_ID()--显示地图ID
    local self= WorldMapFrame
    if not self.mapInfoBtn then
        self.mapInfoBtn=e.Cbtn(self.BorderFrame.TitleContainer, {icon='hide', size={22,22}})
        if IsAddOnLoaded('Mapster') then
            self.mapInfoBtn:SetPoint('RIGHT', self.BorderFrame.TitleContainer, 'RIGHT', -140,0)
        else
            self.mapInfoBtn:SetPoint('RIGHT', self.BorderFrame.TitleContainer, 'RIGHT', -50,0)
        end
        self.mapInfoBtn:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.map)
        self.mapInfoBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        self.mapInfoBtn:SetScript('OnEnter', set_button_OnEnter)
        self.mapInfoBtn:SetScript('OnLeave', function() e.tips:Hide() end)
        self.mapInfoBtn:SetScript('OnMouseDown', function(self2, d)
            if d=="LeftButton" then
                Save.hide= not Save.hide and true or nil
                set_Map_ID_Text(self)
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
        self.playerPosition.elapsed=1
        self.playerPosition:HookScript("OnUpdate", function (self2, elapsed)
            self2.elapsed = self2.elapsed + elapsed
            if self2.elapsed > 0.15 then
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
                self2.elapsed = 0
            end
        end)
    end
end


















local function set_Widget_Text_OnUpDate(self, elapsed)
    self.elapsed= self.elapsed + elapsed
    if self.elapsed>1 then--and self.updateWidgetID then
        if self.updateAreaPoiID then
            local time= C_AreaPoiInfo.GetAreaPOISecondsLeft(self.updateAreaPoiID)
            if time and time>0 then
                if time<86400 then
                    self.Text:SetText(e.SecondsToClock(time))
                else
                    self.Text:SetText(SecondsToTime(time, true))
                end
                self.elapsed= 0
                return
            end
        end
        if self.updateWidgetID then
            local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(self.updateWidgetID) or {}
            if widgetInfo.shownState== 1 and widgetInfo.text and widgetInfo.hasTimer then--剩余时间：
                self.Text:SetText(widgetInfo.text:gsub(HEADER_COLON, '|n'))
            end
        end
        self.elapsed= 0
    end
end

local str_INSTANCE_DIFFICULTY_FORMAT='('..e.Magic(INSTANCE_DIFFICULTY_FORMAT)..')'-- "（%s）";
local function set_AreaPOIPinMixin_OnAcquired(self)--地图POI提示 AreaPOIDataProvider.lua
    self.updateWidgetID=nil
    self.updateAreaPoiID=nil
    self:SetScript('OnUpdate', nil)
    self.elapsed=1
    if not self.Text and not Save.hide and (self.name or self.widgetSetID or self.areaPoiID) then
        self.Text= create_Wolor_Font(self, 10)
        self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
    end

    if not self or Save.hide or not(self.widgetSetID and self.areaPoiID) then
        if self and self.Text then
            local text--地图，地名，名称
            if not Save.hide and self.name then
                text= self.name:match(str_INSTANCE_DIFFICULTY_FORMAT) or self.name
            end
            self.Text:SetText(text or '')
        end
        return
    end

    local text

    if self.areaPoiID and C_AreaPoiInfo.IsAreaPOITimed(self.areaPoiID) then
        self.updateAreaPoiID= self.areaPoiID
        self:SetScript('OnUpdate', set_Widget_Text_OnUpDate)

    elseif self.widgetSetID then
        for _,widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(self.widgetSetID) or {}) do
            if widget and widget.widgetID and  widget.widgetType==8 then
                local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID) or {}
                if widgetInfo.shownState== Enum.WidgetShownState.Shown and widgetInfo.text then
                    if widgetInfo.hasTimer then--剩余时间：
                        text= widgetInfo.text
                        self.updateWidgetID= widget.widgetID
                        self:SetScript('OnUpdate', set_Widget_Text_OnUpDate)
                    else
                        local icon, num= widgetInfo.text:match('(|T.-|t).-]|r.-(%d+)')
                        local text2= widgetInfo.text:match('(%d+/%d+)')--次数
                        if icon and num then
                            text= icon..'|cff00ff00'..num..'|r'
                        end
                        if text2 then
                            text= (text or '')..'|cffff00ff'..text2..'|r'
                        end
                    end
                    if text then
                        break
                    end
                end
            end
        end
    end

    self.Text:SetText(text or self.name or '')
end





--######################
--飞行地图， 飞行点，加名称
--hooksecurefunc(FlightPointPinMixin, 'OnAcquired', set_AreaPOIPinMixin_OnAcquired)--世界地图，飞行点，加名称
local function Init_FlightMap()
    local btn= e.Cbtn(FlightMapFrame.BorderFrame.TitleContainer, {size={20,20}, icon=Save.showFlightMapPinName})
    if _G['MoveZoomInButtonPerFlightMapFrame'] then
        btn:SetPoint('RIGHT', _G['MoveZoomInButtonPerFlightMapFrame'], 'LEFT')
    else
        btn:SetPoint('LEFT')
    end
    btn:Raise()
    btn:SetAlpha(0.5)
    btn:SetScript('OnClick', function(self)
        Save.showFlightMapPinName= not Save.showFlightMapPinName and true or nil
        self:SetNormalAtlas(not Save.showFlightMapPinName and e.Icon.disabled or e.Icon.icon)
        CloseTaxiMap()
    end)
    btn:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine('taxiMapID '..(GetTaxiMapID() or ''), (e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)..' '..(NumTaxiNodes() or 0))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('|A:FlightMaster:0:0|a'..(e.onlyChinese and '飞行点名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, MOUNT_JOURNAL_FILTER_FLYING, NAME)), e.GetShowHide(Save.showFlightMapPinName))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
        self:SetAlpha(1)
    end)

    hooksecurefunc(FlightMap_FlightPointPinMixin, 'SetFlightPathStyle', function(self2)
        local text
        if self2.taxiNodeData and Save.showFlightMapPinName then
            if not self2.Text and self2.taxiNodeData.name then
                self2.Text= create_Wolor_Font(self2, 10)
                self2.Text:SetPoint('TOP', self2, 'BOTTOM', 0, 3)
            end
            text= self2.taxiNodeData.name
            if text then
                text= text:match('(.-)'..KEY_COMMA) or text:match('(.-)'..PLAYER_LIST_DELIMITER) or text
            end
        end
        if self2.Text then
            self2.Text:SetText(text or '')
        end
    end)
end




--####
--初始
--####
local function Init()
    hooksecurefunc(WorldQuestPinMixin, 'RefreshVisuals', set_WorldQuestPinMixin_RefreshVisuals)--世界地图任务

    CursorPositionInt()

    hooksecurefunc(AreaPOIPinMixin,'OnAcquired', set_AreaPOIPinMixin_OnAcquired)--地图POI提示 AreaPOIDataProvider.lua


    Init_set_Map_ID()--显示地图ID
    hooksecurefunc(WorldMapFrame, 'OnMapChanged', set_Map_ID_Text)--Blizzard_WorldMap.lua
    setMapQuestList()--世界地图,任务, 加 - + 按钮
    --hooksecurefunc('QuestMapLogTitleButton_OnClick',function(self, button)--任务日志 展开所有, 收起所有--QuestMapFrame.lua

    hooksecurefunc(DungeonEntrancePinMixin, 'OnAcquired', function(self)--地下城，加名称
        local text
        if not Save.hide and self.name then
            if not self.Text then
                self.Text= create_Wolor_Font(self, 10)
                self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
            end
            text= self.name
        end
        if self.Text then
            self.Text:SetText(text or '')
        end
    end)
end











--加载保存数据
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
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
                --panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_FlightMap' then--飞行点，加名称
            Init_FlightMap()--飞行地图， 飞行点，加名称
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)