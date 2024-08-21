local id, e = ...
local addName = WORLD_MAP
local addName2=RESET_POSITION:gsub(RESET, PLAYER)
local Save={
    --PlayerXY=true,--玩家实时，坐标
    --showFlightMapPinName=true,飞行地图，显示，飞行点名称
}

local panel=CreateFrame("Frame")
local Button--开关
local PostionButton--实时玩家， 当前坐标
local PlayerButton--世界地图， 当前坐标

local function create_Wolor_Font(self, size)--AreaLabelDataProvider.xml
    local font= e.Cstr(self, {size=size, justifyH='CENTER', color=false, fontName='WorldMapTextFont'})--WorldMapTextFont SubZoneTextFont
    return font
end



local function getPlayerXY()--当前世界地图位置
    local uiMapID= C_Map.GetBestMapForUnit("player")--当前地图        
    if uiMapID then
        local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
        if position then
            local x, y
            x,y=position:GetXY()
            if x and y then
                x= format('%.2f', x*100)
                y= format('%.2f', y*100)
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
            e.Chat(C_Map.GetUserWaypointHyperlink(), nil, true)
            --ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..C_Map.GetUserWaypointHyperlink())
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
                e.Chat(pointText, nil, true)
                --ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..pointText)
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
        e.Chat(name, nil, true)
        --ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..name)
    else
        print("Cannot set waypoints on this map")
    end
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

        local itemEquipLoc, _, classID = select(4, C_Item.GetItemInfoInstant(itemID))
        if classID==2 or classID==4 then
            if quality and text then--物品，颜色
                text='|c'..select(4, C_Item.GetItemQualityColor(quality))..itemLevel..'|r'
            end

            local setLevelUp
            local invSlot = e.GetItemSlotID(itemEquipLoc)
            if invSlot and itemName and itemLevel and itemLevel>1 then--装等
                local itemLinkPlayer =  GetInventoryItemLink('player', invSlot)
                if itemLinkPlayer then
                    local lv= C_Item.GetDetailedItemLevelInfo(itemLinkPlayer)
                    if lv and itemLevel-lv>0 then
                        text= (text or '')..'|A:bags-greenarrow:0:0|a'
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
        --itemName, texture, numItems, currencyID, quality =  GetQuestLogRewardCurrencyInfo(1, self.questID)--货币
        local data= C_QuestLog.GetQuestRewardCurrencyInfo(self.questID, 1, false)
        local currencyID= data and data.currencyID
        if currencyID and data and data.quantity and data.quantity>0 then
            local info, _, _, _, isMax, canWeek, canEarned, canQuantity= e.GetCurrencyMaxInfo(currencyID, nil)
            if info and data.quantity>1 then
                if isMax then
                    text= format('|cnRED_FONT_COLOR:%d|r', data.quantity)
                elseif canWeek or canEarned or canQuantity then
                    text= format('|cnGREEN_FONT_COLOR:%d|r', data.quantity)
                end
                texture=info.iconFileID
            end
        end

        if not text then
            local gold= GetQuestLogRewardMoney(self.questID)
            if gold and gold>0 then
                text= e.MK(gold/10000, 0)
                texture='interface\\moneyframe\\ui-goldicon'
            end
        end
    end


        --[[if self.Texture then
            self.Texture:SetTexture(texture)
            self.Texture:SetSize(40, 40)
        else]]
    if self.Display and texture then
        if type(texture)=='number' then
            SetPortraitToTexture(self.Display.Icon, texture)
        else
            self.Display.Icon:SetTexture(texture)
        end
        self.Display.Icon:SetSize(20, 20)
    end


    if not self.Text and text then
        self.Text= create_Wolor_Font(self, 12)
        self.Text:SetPoint('TOP', self, 'BOTTOM',0, 2)
    end
    if self.Text then
        self.Text:SetText(text or '')
    end

    --local isNormalQuest= self.worldQuestType == Enum.QuestTagType.Normal--任务，类型
    local tagInfo
    if self.worldQuestType and self.worldQuestType ~= Enum.QuestTagType.Normal  then
        tagInfo= self.tagInfo or C_QuestLog.GetQuestTagInfo(self.questID)
    end
    if tagInfo then
        local inProgress = self.dataProvider:IsMarkingActiveQuests() and C_QuestLog.IsOnQuest(self.questID)
        
        local atlas= QuestUtil.GetWorldQuestAtlasInfo(self.questID, tagInfo, inProgress)--QuestUtils.lua (questID, tagInfo, inProgress)
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
        self.worldQuestTypeTips:SetShown(tagInfo)
    end
end



































--###############
--实时玩家当前坐标
--###############
local function CursorPositionInt()
    if not Save.PlayerXY or PostionButton then
        if PostionButton then
            PostionButton:SetShown(Save.PlayerXY)
        end
        return
    end
    PostionButton= e.Cbtn(nil, {icon='hide', size={18,18}})-- CreateFrame('Button', nil, UIParent)

    function PostionButton:set_Point()
        if not Save.PlayerXYPoint then
            PostionButton:SetPoint('BOTTOMRIGHT', WorldMapFrame, 'TOPRIGHT',-50, 5)
        else
            PostionButton:SetPoint(Save.PlayerXYPoint[1], UIParent, Save.PlayerXYPoint[3], Save.PlayerXYPoint[4], Save.PlayerXYPoint[5])
        end
    end
    PostionButton:set_Point()

    PostionButton:SetFrameStrata('HIGH')
    PostionButton:SetMovable(true)
    PostionButton:RegisterForDrag("RightButton")
    PostionButton:SetClampedToScreen(true)
    PostionButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    PostionButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.PlayerXYPoint={self:GetPoint(1)}
        Save.PlayerXYPoint[2]=nil
    end)
    PostionButton:SetScript("OnMouseDown", function(_, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        end
     end)
    PostionButton:SetScript("OnMouseUp", ResetCursor)
    PostionButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' and not IsModifierKeyDown() then
            sendPlayerPoint()--发送玩家位置
        end
    end)
    PostionButton:SetScript("OnEnter",function(self)
        e.tips:ClearLines()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(id, addName2)
        e.tips:AddLine(' ')
        local can
        can= C_Map.GetBestMapForUnit("player")
        can= can and C_Map.CanSetUserWaypointOnMap(can)
        e.tips:AddDoubleLine('|A:Waypoint-MapPin-ChatIcon:0:0|a'..(e.onlyChinese and '发送位置' or RESET_POSITION:gsub(RESET, SEND_LABEL)), (not can and GetMinimapZoneText() or not can and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE)..'|r' or '') ..e.Icon.left)
        e.tips:AddDoubleLine(e.Player.L.size..' '..(Save.PlayerXYSize or 12), 'alt+'..e.Icon.mid)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'alt+'..e.Icon.right)
        e.tips:Show()
    end)
    PostionButton:SetScript("OnLeave", function()
        e.tips:Hide()
        ResetCursor()
    end)

    PostionButton:SetScript('OnMouseWheel',function(self, d)
        if not IsAltKeyDown() then
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
        e.Cstr(nil, {size=size, changeFont=self.Text, color=true})
        print(e.addName,e.cn(addName), e.Player.L.size, size)
    end)

    PostionButton.Text=e.Cstr(PostionButton, {size=Save.PlayerXYSize, color=true})
    PostionButton.Text:SetPoint('RIGHT', PostionButton, "LEFT")

    PostionButton:HookScript("OnUpdate", function (self, elapsed)
        self.elapsed = (self.elapsed or 0.3) + elapsed
        if self.elapsed > 0.3 then
            self.elapsed = 0
            local x, y= getPlayerXY()
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
local function Init_set_Map_ID()--显示地图ID
    if not Button then
        Button=e.Cbtn(WorldMapFrame.BorderFrame.TitleContainer, {icon='hide', size={22,22}})
        if C_AddOns.IsAddOnLoaded('Mapster') then
            Button:SetPoint('RIGHT', WorldMapFrame.BorderFrame.TitleContainer, 'RIGHT', -140,0)
        else
            Button:SetPoint('RIGHT', WorldMapFrame.BorderFrame.TitleContainer, 'RIGHT', -50,0)
        end
        Button:SetNormalAtlas(Save.hide and e.Icon.disabled or 'poi-islands-table')

        function Button:set_Map_ID_Text()
            local m=''
            local story, achievementID
            if not Save.hide then
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
                    if not Button.mapID then--字符
                        Button.mapID=e.Cstr(WorldMapFrame.BorderFrame.TitleContainer, {copyFont=WorldMapFrameTitleText})
                        Button.mapID:SetPoint('RIGHT', Button, 'LEFT')
                    end
                end
                if e.Player.Layer then
                    m = e.Player.Layer..' '..m
                end

                achievementID = C_QuestLog.GetZoneStoryInfo(uiMapID)--当前地图，故事任务
                if achievementID then
                    if not Button.storyText then--字符
                        Button.storyText=e.Cstr(Button, {copyFont=WorldMapFrameTitleText})
                        Button.storyText:SetPoint('BOTTOMRIGHT', Button, 'TOPRIGHT')
                        Button.storyText:EnableMouse(true)
                        Button.storyText:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
                        Button.storyText:SetScript('OnEnter', function(self2)
                            if self2.achievementID then
                                e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                                e.tips:ClearLines()
                                e.tips:SetAchievementByID(self2.achievementID)
                                e.tips:AddLine(' ')
                                e.tips:AddDoubleLine(e.onlyChinese and '发送链接' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SEND_LABEL, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK), e.Icon.left)
                                e.tips:Show()
                                self2:SetAlpha(0.7)
                            end
                        end)
                        Button.storyText:SetScript("OnMouseUp", function(self2) self2:SetAlpha(0.7) end)
                        Button.storyText:SetScript('OnMouseDown', function(self2)
                            if self2.achievementID then
                                print(GetAchievementLink(self2.achievementID) or self2.achievementID)
                            end
                            self2:SetAlpha(0.3)
                        end)
                    end
                    local completed, _
                    story, _, completed= select(2, GetAchievementInfo(achievementID))
                    story= story or achievementID
                    if completed then
                        story= '|cff9e9e9e'..story..'|r'
                    end
                end

            end
            if Button.mapID then
                Button.mapID:SetText(m)
            end
            if Button.storyText then
                Button.storyText:SetText(story or '')
                Button.storyText.achievementID= achievementID
            end
            PlayerButton:SetShown(not Save.hide)
        end

        Button:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, e.cn(addName))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.Player.L.layer, e.Player.Layer or (e.onlyChinese and '无' or NONE))--位面

            local uiMapID = WorldMapFrame.mapID or WorldMapFrame:GetMapID("current")--地图信息
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
                local x,y = getPlayerXY()
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
            e.tips:AddDoubleLine(e.cn(addName), e.GetEnabeleDisable(not Save.hide)..e.Icon.left)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(addName2, e.GetEnabeleDisable(Save.PlayerXY)..e.Icon.right)
            local col= Save.PlayerXYPoint and '' or '|cff9e9e9e'
            e.tips:AddDoubleLine(col..(e.onlyChinese and '重置位置' or RESET_POSITION), col..'Ctrl+'..e.Icon.right)
            e.tips:Show()

            if PostionButton then
                PostionButton:SetButtonState('PUSHED')
            end
        end)
        Button:SetScript('OnLeave', function()
            e.tips:Hide()
            if PostionButton then
                PostionButton:SetButtonState('NORMAL')
            end
        end)
        Button:SetScript('OnClick', function(self, d)
            if d=='RightButton' and IsControlKeyDown() then
                Save.PlayerXYPoint=nil
                if PostionButton then
                    PostionButton:ClearAllPoints()
                    PostionButton:set_Point()
                end
                print(e.addName, e.cn(addName), addName2, e.onlyChinese and '重置位置' or RESET_POSITION)

            elseif d=="LeftButton" and not IsModifierKeyDown() then
                Save.hide= not Save.hide and true or nil
                self:set_Map_ID_Text()
                print(e.addName, e.cn(addName), e.GetShowHide(not Save.hide), e.onlyChinese and ' 刷新' or REFRESH)
                self:SetNormalAtlas(Save.hide and e.Icon.disabled or 'poi-islands-table')
            elseif d=='RightButton' and not IsModifierKeyDown() then--实时玩家当前坐标
                if Save.PlayerXY then
                    Save.PlayerXY=nil
                    print(e.addName, e.cn(addName), addName2..":", e.GetEnabeleDisable(Save.PlayerXY), '|cnGREEN_FONT_COLOR:'..NEED..'/reload|r')
                else
                    Save.PlayerXY=true
                    print(e.addName, e.cn(addName), addName2..":", e.GetEnabeleDisable(Save.PlayerXY))
                end
                CursorPositionInt()
            end
        end)
    end

    if not PlayerButton then--玩家坐标
        PlayerButton=e.Cbtn(WorldMapFrame.BorderFrame.TitleContainer, {icon='hide', size={22,22}})
        if _G['MoveZoomInButtonPerWorldMapFrame'] then
            PlayerButton:SetPoint('LEFT', _G['MoveZoomInButtonPerWorldMapFrame'], 'RIGHT')
        else
            PlayerButton:SetPoint('LEFT', WorldMapFrame.BorderFrame.TitleContainer, 'LEFT', 75, -2)
        end
        PlayerButton:SetNormalAtlas(e.Icon.player:match('|A:(.-):'))
        PlayerButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        PlayerButton:SetScript('OnLeave', GameTooltip_Hide)
        PlayerButton:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, e.cn(addName))
            e.tips:AddLine(' ')
            local can
            can= C_Map.GetBestMapForUnit("player")
            can= can and C_Map.CanSetUserWaypointOnMap(can)
            e.tips:AddDoubleLine('|A:Waypoint-MapPin-ChatIcon:0:0|a'..(e.onlyChinese and '发送位置' or RESET_POSITION:gsub(RESET, SEND_LABEL)), (not can and GetMinimapZoneText() or not can and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE)..'|r' or '')..e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '返回当前地图' or (PREVIOUS..REFORGE_CURRENT..WORLD_MAP), e.Icon.right)
            e.tips:Show()
        end)
        PlayerButton:SetScript('OnMouseDown', function(self, d)
            if d=='RightButton' then--返回当前地图                
	            WorldMapFrame:SetMapID(MapUtil.GetDisplayableMapForPlayer())
            elseif d=='LeftButton' then
                sendPlayerPoint()--发送玩家位置
            end
        end)

        PlayerButton.edit= CreateFrame("EditBox", nil, PlayerButton, 'InputBoxTemplate')
        PlayerButton.edit:SetSize(90,20)
        e.Set_Label_Texture_Color(PlayerButton.edit, {type='EditBox'})
        --PlayerButton.edit:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
        PlayerButton.edit:SetAutoFocus(false)
        PlayerButton.edit:ClearFocus()
        PlayerButton.edit:SetPoint('LEFT', PlayerButton, 'RIGHT',2,0)
        PlayerButton.edit:SetScript('OnEditFocusLost', function(self)
            e.Set_Label_Texture_Color(self, {type='EditBox'})
            --self:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
        end)
        PlayerButton.edit:SetScript('OnEditFocusGained', function(self)
            self:HighlightText()
            self:SetTextColor(1,1,1)
        end)
        PlayerButton.edit:SetScript("OnKeyUp", function(s, key)
            if IsControlKeyDown() and key == "C" then
                s:ClearFocus()
                print(e.addName,e.cn(addName), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r', s:GetText())
            end
        end)
        PlayerButton.edit.Left:SetAlpha(0.5)
        PlayerButton.edit.Middle:SetAlpha(0.5)
        PlayerButton.edit.Right:SetAlpha(0.5)

        PlayerButton.Text=e.Cstr(PlayerButton, {copyFont=WorldMapFrameTitleText})--玩家当前坐标
        PlayerButton.Text:SetPoint('LEFT',PlayerButton.edit, 'RIGHT', 2, 0)
        PlayerButton:HookScript("OnUpdate", function (self, elapsed)
            self.elapsed = (self.elapsed or 1) + elapsed
            if self.elapsed > 0.15 then
                self.elapsed = 0
                local text=''
                local x, y= getPlayerXY()--玩家当前坐标
                if x and y then
                    text=x..' '..y
                end
                if not self.edit:HasFocus() then
                    self.edit:SetText(text)
                end
                x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()--当前世界地图位置
                if x and y then
                    text = ('%.2f'):format(x*100)..' '..('%.2f'):format(y*100)
                else
                    text=''
                end
                PlayerButton.Text:SetText(text)
            end
        end)
    end
end















--##########
--地图POI提示
--AreaPOIDataProvider.lua
local function set_Widget_Text_OnUpDate(self, elapsed)
    self.elapsed= (self.elapsed or 1) + elapsed
    if self.elapsed>1 then
        self.elapsed= 0
        if self.updateAreaPoiID then
            local time= C_AreaPoiInfo.GetAreaPOISecondsLeft(self.updateAreaPoiID)
            if time and time>0 then
                if time<86400 then
                    self.Text:SetText(e.SecondsToClock(time))
                else
                    self.Text:SetText(SecondsToTime(time, true))
                end
                return
            end
        end
        if self.updateWidgetID then
            local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(self.updateWidgetID) or {}
            if widgetInfo.shownState== 1 and widgetInfo.text and widgetInfo.hasTimer then--剩余时间：
                self.Text:SetText(widgetInfo.text:gsub(HEADER_COLON, '|n'))
            end
        end
    end
end










local INSTANCE_DIFFICULTY_FORMAT='('..e.Magic(INSTANCE_DIFFICULTY_FORMAT)..')'-- "（%s）";
local function set_AreaPOIPinMixin_OnAcquired(frame)
    frame.updateWidgetID=nil
    frame.updateAreaPoiID=nil
    frame:SetScript('OnUpdate', nil)

    if not frame.Text and not Save.hide and (frame.name or frame.widgetSetID or frame.areaPoiID) then
        frame.Text= create_Wolor_Font(frame, 10)
        frame.Text:SetPoint('TOP', frame, 'BOTTOM', 0, 3)
    end

    if not frame or Save.hide or not(frame.widgetSetID and frame.areaPoiID) then
        if frame and frame.Text then
            local text--地图，地名，名称
            if not Save.hide and frame.name then
                text= e.cn(frame.name)
                text= text:match(INSTANCE_DIFFICULTY_FORMAT) or text
            end
            frame.Text:SetText(text or '')
        end
        return
    end

    local text

    if frame.areaPoiID and C_AreaPoiInfo.IsAreaPOITimed(frame.areaPoiID) then
        frame.updateAreaPoiID= frame.areaPoiID
        frame:SetScript('OnUpdate', set_Widget_Text_OnUpDate)

    elseif frame.widgetSetID then
        for _,widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(frame.widgetSetID) or {}) do
            if widget and widget.widgetID and  widget.widgetType==8 then
                local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID) or {}
                if widgetInfo.shownState== Enum.WidgetShownState.Shown and widgetInfo.text then
                    if widgetInfo.hasTimer then--剩余时间：
                        text= widgetInfo.text
                        frame.updateWidgetID= widget.widgetID
                        if not frame.setScripOK then
                            frame.setScripOK=true
                            frame:SetScript('OnUpdate', set_Widget_Text_OnUpDate)
                        end
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

    frame.Text:SetText(text or frame.name or '')
end











local function Init_Menu()
    Menu.ModifyMenu("MENU_QUEST_MAP_FRAME_SETTINGS", function(_, root)
        root:CreateDivider()
        root:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部放弃' or LOOT_HISTORY_ALL_PASSED)..' #'..(select(2, C_QuestLog.GetNumQuestLogEntries()) or 0), function()
            StaticPopupDialogs[id..addName.."ABANDON_QUEST"] =  {
                text= (e.onlyChinese and "放弃\"%s\"？" or ABANDON_QUEST_CONFIRM)..'|n|n|cnYELLOW_FONT_COLOR:'..(not e.onlyChinese and VOICEMACRO_1_Sc_0..' ' or "危险！")..(not e.onlyChinese and VOICEMACRO_1_Sc_0..' ' or "危险！")..(not e.onlyChinese and VOICEMACRO_1_Sc_0 or "危险！"),
                button1 = '|cnRED_FONT_COLOR:'..(not e.onlyChinese and ABANDON_QUEST_ABBREV or "放弃"),
                button2 = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '取消' or CANCEL),
                OnAccept = function()
                    local n=0
                    print(e.addName, e.cn(addName),  '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '放弃' or ABANDON_QUEST_ABBREV))
                    for index=1 , C_QuestLog.GetNumQuestLogEntries() do
                        do
                            local questInfo=C_QuestLog.GetInfo(index)
                            if questInfo and questInfo.questID and C_QuestLog.CanAbandonQuest(questInfo.questID) then
                                local linkQuest=GetQuestLink(questInfo.questID)
                                C_QuestLog.SetSelectedQuest(questInfo.questID)
                                C_QuestLog.SetAbandonQuest();
                                C_QuestLog.AbandonQuest()
                                n=n+1
                                print(n..') ', linkQuest or questInfo.questID)
                            end
                            if IsModifierKeyDown() then
                                return
                            end
                        end
                    end
                    PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
                end,
                whileDead=true, hideOnEscape=true, exclusive=true,
                showAlert= true,
            }
            StaticPopup_Show(id..addName.."ABANDON_QUEST", '|n|cnRED_FONT_COLOR:|n|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '所有任务' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, QUESTS_LABEL))..' |r#|cnGREEN_FONT_COLOR:'..select(2, C_QuestLog.GetNumQuestLogEntries())..'|r')
        end)
    end)

    QuestScrollFrame.SearchBox:SetWidth(301- 20*2)

    local btnCollapse= e.Cbtn(QuestScrollFrame.SearchBox, {size={20,20}, atlas='NPE_ArrowUp'})--campaign_headericon_closed
    btnCollapse:SetPoint('LEFT', QuestScrollFrame.SearchBox, 'RIGHT')
    btnCollapse:SetScript('OnLeave', GameTooltip_Hide)
    btnCollapse:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(not e.onlyChinese and HUD_EDIT_MODE_COLLAPSE_OPTIONS or "收起选项 |A:editmode-up-arrow:16:11:0:3|a")
        e.tips:Show()
    end)
    btnCollapse:SetScript("OnMouseDown", function()
        for i=1, C_QuestLog.GetNumQuestLogEntries() do
            CollapseQuestHeader(i)
        end
    end)

    local btnExpand= e.Cbtn(QuestScrollFrame.SearchBox, {size={20,20}, atlas='NPE_ArrowDown'})
    btnExpand:SetPoint('LEFT', btnCollapse, 'RIGHT')
    btnExpand:SetScript('OnLeave', GameTooltip_Hide)
    btnExpand:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(not e.onlyChinese and HUD_EDIT_MODE_EXPAND_OPTIONS or "展开选项 |A:editmode-down-arrow:16:11:0:-7|a")
        e.tips:Show()
    end)
    btnExpand:SetScript("OnMouseDown", function()
        for i=1, C_QuestLog.GetNumQuestLogEntries() do
            ExpandQuestHeader(i)
        end
    end)
end





--####
--初始
--####
local function Init()
    Init_Menu()

    hooksecurefunc(WorldQuestPinMixin, 'RefreshVisuals', set_WorldQuestPinMixin_RefreshVisuals)--世界地图任务

    CursorPositionInt()

    --BaseMapPoiPinMixin
    hooksecurefunc(AreaPOIPinMixin,'OnAcquired', set_AreaPOIPinMixin_OnAcquired)--地图POI提示 AreaPOIDataProvider.lua


    Init_set_Map_ID()--显示地图ID
    if Button then
        --hooksecurefunc(WorldMapFrame.ScrollContainer, 'SetMapID', function(self, mapID)--MapCanvasScrollControllerMixin
        hooksecurefunc(WorldMapFrame, 'OnMapChanged', Button.set_Map_ID_Text)--Blizzard_WorldMap.lua
    end
    --hooksecurefunc('QuestMapLogTitleButton_OnClick',function(self, button)--任务日志 展开所有, 收起所有--QuestMapFrame.lua

    hooksecurefunc(DungeonEntrancePinMixin, 'OnAcquired', function(self)--地下城，加名称
        local text
        if not Save.hide and self.name then
            if not self.Text then
                self.Text= create_Wolor_Font(self, 10)
                self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
            end
            text= e.cn(self.name)
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

            addName2= e.onlyChinese and '时实坐标' or addName2

            --添加控制面板
            e.AddPanel_Check({
                name= format('|A:poi-islands-table:0:0|a%s', e.onlyChinese and '地图' or addName),
                tooltip= e.cn(addName),
                GetValue= function() return not Save.disabled end,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.addName, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")



        elseif arg1=='Blizzard_FlightMap' then--飞行点，加名称
            local btn= e.Cbtn(FlightMapFrame.BorderFrame.TitleContainer, {size={20,20}, icon=Save.showFlightMapPinName})
            if _G['MoveZoomInButtonPerFlightMapFrame'] then
                btn:SetPoint('RIGHT', _G['MoveZoomInButtonPerFlightMapFrame'], 'LEFT')
            else
                btn:SetPoint('LEFT')
            end
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
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:Show()
                self:SetAlpha(1)
            end)

            hooksecurefunc(FlightMap_FlightPointPinMixin, 'SetFlightPathStyle', function(self)
                local text
                if self.taxiNodeData and Save.showFlightMapPinName then
                    if not self.Text and self.taxiNodeData.name then
                        self.Text= create_Wolor_Font(self, 10)
                        self.Text:SetPoint('TOP', self, 'BOTTOM', 0, 3)
                    end
                    text= self.taxiNodeData.name
                    if text then
                        text= text:match('(.-)'..KEY_COMMA) or text:match('(.-)'..PLAYER_LIST_DELIMITER) or text
                        text= e.cn(text)
                    end
                end
                if self.Text then
                    self.Text:SetText(text or '')
                end
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)