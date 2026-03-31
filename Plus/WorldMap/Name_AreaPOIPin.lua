--地图POI提示 AreaPOIDataProvider.lua
local function Save()
    return WoWToolsSave['Plus_WorldMap']
end
local function SaveWoW()
    return WoWToolsPlayerDate.WorldMapUserAreaPoiName
end


local function Set_Update(self, elapsed)
    self.elapsed= (self.elapsed or 1) + elapsed
    if self.elapsed>1 then
        self.elapsed= 0

        if self.areaPoiID then
            local time= C_AreaPoiInfo.GetAreaPOISecondsLeft(self.areaPoiID)

            if time and time>0 then
                if time<86400 then
                 self.Text:SetText(WoWTools_TimeMixin:SecondsToClock(time))
                else
                    self.Text:SetText(SecondsToTime(time, true))
                end
            end


        elseif self.widgetID then
            local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(self.widgetID)
            if widgetInfo and widgetInfo.shownState== 1 and widgetInfo.text and widgetInfo.hasTimer then--剩余时间：
                local cn= WoWTools_TextMixin:CN(widgetInfo.text)
                self.Text:SetText(cn:gsub(HEADER_COLON, '|n'))
            end
        end
    end
end






--地图POI提示 AreaPOIDataProvider.lua
local function Init()
    if not Save().ShowAreaPOI_Name then
        return
    end

    WoWTools_DataMixin:Hook(AreaPOIPinMixin, 'OnAcquired', function(self, poiInfo)
        if not self.WoWToolsFrame then
            self.WoWToolsFrame= CreateFrame('Frame', nil, self)
            self.WoWToolsFrame:SetAllPoints()
            self.WoWToolsFrame.Text= self.WoWToolsFrame:CreateFontString(nil, 'ARTWORK', 'WoWToolsWorldFont')
            self.WoWToolsFrame.Text:SetPoint('TOP', self.Texture or self, 'BOTTOM')
            self.WoWToolsFrame:SetScript('OnHide', function(frame)
                frame:SetScript('OnUpdate', nil)
                frame.elapsed= nil
                frame.areaPoiID= nil-- poiInfo.areaPoiID
                frame.widgetID= nil
            end)
        end

        local text
        if poiInfo and Save().ShowAreaPOI_Name and not SaveWoW().noShow[poiInfo.areaPoiID] then

            text= SaveWoW().pinName[poiInfo.areaPoiID]--自定义名称

            if not text then--取得默认名称

                if poiInfo.areaPoiID and C_AreaPoiInfo.IsAreaPOITimed(poiInfo.areaPoiID) then
                    self.WoWToolsFrame.areaPoiID= poiInfo.areaPoiID
                    self.WoWToolsFrame:SetScript('OnUpdate', Set_Update)

                elseif poiInfo.widgetSetID then
                    for _, widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(poiInfo.widgetSetID) or {}) do
                        if widget and widget.widgetID and  widget.widgetType==Enum.UIWidgetVisualizationType.TextWithState then
                            local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widget.widgetID)
                            if widgetInfo and widgetInfo.shownState==Enum.WidgetShownState.Shown then

                                if widgetInfo.hasTimer then--剩余时间：
                                    self.WoWToolsFrame.widgetID= widget.widgetID
                                    self.WoWToolsFrame:SetScript('OnUpdate', Set_Update)
                                    break

                                elseif widgetInfo.text and widgetInfo.text~='' then
                                    local icon, num= widgetInfo.text:match('(|T.-|t).-]|r.-(%d+)')
                                    local text2= widgetInfo.text:match('(%d+/%d+)')--次数

                                    if icon and num then
                                        text= icon..'|cff00ff00'..num..'|r'
                                    end
                                    if text2 then
                                        text= (text or '')..'|cffff00ff'..text2..'|r'
                                    end
                                    break
                                end
                            end
                        end
                    end
                end

                text= text or WoWTools_TextMixin:CN(poiInfo.name)
                if text then
                    text= text:match('%((.+)%)') or text:match('（(.+)）')  or text
                end
            end
        end

        self.WoWToolsFrame.Text:SetText(text or '')
        self.WoWToolsFrame.Text:SetFontHeight(Save().areaPoinFontSize or 10)
    end)











    --POI提示 AreaPOIDataProvider.lua
    --AreaPOIPinMixin:TryShowTooltip
    --[[可能会有性能问题，暂时只给husandro用
    if WoWTools_DataMixin.Player.husandro then
        WoWTools_DataMixin:Hook(AreaPoiUtil, 'TryShowTooltip', function(_, _, poiInfo)
            local tooltip = Save().ShowAreaPOI_Name
                    and poiInfo
                    and (poiInfo.areaPoiID or poiInfo.widgetSetID)
                    and GetAppropriateTooltip()

            if not tooltip or not tooltip:IsVisible() or not poiInfo then
                return
            end

            if poiInfo.areaPoiID then
                tooltip:AddLine('areaPoiID|cffffffff'..WoWTools_DataMixin.Icon.icon2..poiInfo.areaPoiID)
            end
            if poiInfo.widgetSetID then
                tooltip:AddLine('widgetSetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..poiInfo.widgetSetID)
                for _,widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(poiInfo.widgetSetID) or {}) do
                    if widget and widget.widgetID and widget.shownState==1 then
                        tooltip:AddLine('widgetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..widget.widgetID)
                    end
                end
            end
            if poiInfo.factionID then
                WoWTools_TooltipMixin:Set_Faction(tooltip, poiInfo.factionID)
            end

            WoWTools_TooltipMixin:Show(tooltip)
        end)
    end]]

    if WorldMapFrame:IsShown() then
        WoWTools_WorldMapMixin:Refresh()
    end


    Init=function()
        WoWTools_WorldMapMixin:Refresh()
    end
end


--BaseMapPoiPinMixin
function WoWTools_WorldMapMixin:Init_AreaPOI_Name()
    Init()
end


















function WoWTools_WorldMapMixin:AreaPOINameMenu(_, root)
    local sub, sub2
--AreaPOI名称
    sub=root:CreateCheckbox(
        '|A:minimap-genericevent-hornicon:0:0|aAreaPOI',
    function()
        return Save().ShowAreaPOI_Name
    end, function()
        Save().ShowAreaPOI_Name= not Save().ShowAreaPOI_Name and true or false
        WoWTools_WorldMapMixin:Init_AreaPOI_Name()
    end,sub)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示名称' or PROFESSIONS_FLYOUT_SHOW_NAME)
        --tooltip:AddLine('|cnWARNING_FONT_COLOR:BUG')
    end)

--字体大小
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        name= WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE,
        getValue=function()
            return Save().areaPoinFontSize or 10
        end, setValue=function(value)
            Save().areaPoinFontSize=value
            WoWTools_WorldMapMixin:Init_AreaPOI_Name()
        end,
        minValue=4,
        maxValue=24,
        step=1,
        --tooltip=WoWTools_DataMixin.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH)
    })
    sub:CreateSpacer()
    --sub:CreateDivider()

    for pin in WorldMapFrame:EnumeratePinsByTemplate("AreaPOIPinTemplate") do
        local poiInfo= pin.poiInfo
        if poiInfo and poiInfo.areaPoiID and poiInfo.name then
            local user= SaveWoW().pinName[poiInfo.areaPoiID]
            sub2= sub:CreateCheckbox(
                (user and '|cnGREEN_FONT_COLOR:' or '')
                ..(user or WoWTools_TextMixin:CN(poiInfo.name)),
            function()
                return not SaveWoW().noShow[poiInfo.areaPoiID]
            end, function(data)
                SaveWoW().noShow[data.areaPoiID]= not SaveWoW().noShow[data.areaPoiID] and true or nil
                WoWTools_WorldMapMixin:Init_AreaPOI_Name()
            end, {areaPoiID=poiInfo.areaPoiID, name=poiInfo.name, rightText='|cff626262'..poiInfo.areaPoiID, user=user})

            WoWTools_MenuMixin:SetRightText(sub2)
            sub2:SetTooltip(function(tooltip, desc)
                tooltip:AddLine(desc.data.user2)
            end)

            sub2:CreateButton(
                WoWTools_DataMixin.onlyChinese and '编辑' or EDIT,
            function(data)
                local user2= SaveWoW().pinName[data.areaPoiID]
                local name2= WoWTools_TextMixin:CN(data.name)
                StaticPopup_Show('WoWTools_EditText',
                    name2
                    ..'|n|nareaPoiID '..data.areaPoiID..'\n',
                nil,
                {
                    text= user2 or name2,
                    SetValue= function(s)
                        SaveWoW().pinName[data.areaPoiID]= s:GetEditBox():GetText()
                        WoWTools_WorldMapMixin:Init_AreaPOI_Name()
                    end,
                    OnAlt= user2 and function()
                        SaveWoW().pinName[data.areaPoiID]= nil
                        WoWTools_WorldMapMixin:Init_AreaPOI_Name()
                    end or nil,
                })
                return MenuResponse.Open
            end, {areaPoiID=poiInfo.areaPoiID, name=poiInfo.name})
        end
    end
    WoWTools_MenuMixin:SetScrollMode(sub)

    sub:CreateDivider()

    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
    function()
        StaticPopup_Show('WoWTools_OK',
            '|A:minimap-genericevent-hornicon:0:0|aAreaPOI|n|n'..
            (WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
            ..'|n',
        nil,
        {SetValue=function()
            WoWToolsPlayerDate.WorldMapUserAreaPoiName= {noShow={},pinName={}}
            WoWTools_WorldMapMixin:Init_AreaPOI_Name()
        end})
        return MenuResponse.Open
    end)
end