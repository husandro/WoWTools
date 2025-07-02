local Save= function()
    return  WoWToolsSave['Minimap_Plus']
end

local Frame=CreateFrame('Frame')












function Frame:set_event()
    self:UnregisterAllEvents()
    if Save().ZoomOutInfo then
        self:RegisterEvent('MINIMAP_UPDATE_ZOOM')
        self:MINIMAP_UPDATE_ZOOM()
    else
        Minimap.zoomText:SetText('')
        Minimap.viewRadius:SetText('')
    end

    if Save().ZoomOut then
        self:RegisterEvent('ZONE_CHANGED')
        self:RegisterEvent('ZONE_CHANGED_INDOORS')
        self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
        self:ZONE_CHANGED()
    end
end





function Frame:ZONE_CHANGED()--更新地区时,缩小化地图
    local value= Save().ZoomOut
    if value==nil then
        return
    end
    local max= Minimap:GetZoomLevels()
    local select=  (type(value)=='number' and value-1)
                    or (value=='max' and max)
                    or 0
    select= math.min(select, max)
    select= math.max(select, 0)

    if select~=Minimap:GetZoom() then
        Minimap:SetZoom(select)
    end
end





function Frame:MINIMAP_UPDATE_ZOOM()--当前缩放，显示数值
    local level = Minimap:GetZoom()
    local max= Minimap:GetZoomLevels()
    Minimap.zoomText:SetText(
        max and max>0 and level
        and (max-(level or 0))..'/'..max
        or ''
    )
    Minimap.viewRadius:SetFormattedText('%i', C_Minimap.GetViewRadius() or 100)
end









Frame:RegisterEvent("ADDON_LOADED")
Frame:SetScript("OnEvent", function(self, event)
    if event=='MINIMAP_UPDATE_ZOOM' then
        self:MINIMAP_UPDATE_ZOOM()
    else
        self:ZONE_CHANGED()
    end
end)









local function Init_Menu(_, root)
    local sub
    for _, value in pairs({'min', 2, 3, 4, 5, 'max'}) do
        sub=root:CreateRadio(
            value=='min' and (WoWTools_DataMixin.onlyChinese and '缩小' or ZOOM_OUT)
            or (value=='max' and (WoWTools_DataMixin.onlyChinese and '放大' or ZOOM_IN))
            or value,
        function(data)
            return data.value==Save().ZoomOut
        end, function(data)
            if Save().ZoomOut== data.value then
                Save().ZoomOut= nil
            else
                Save().ZoomOut= data.value
            end
            Frame:set_event()
            return MenuResponse.Refresh
        end, {value=value})
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK)
        end)
    end
end




local function Init()
    Minimap.ZoomIn:HookScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
        end
    end)
    Minimap.ZoomOut:HookScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
        end
    end)

    Minimap.viewRadius=WoWTools_LabelMixin:Create(Minimap, {color=true, justifyH='CENTER', mouse=true})
    Minimap.viewRadius:SetPoint('BOTTOMLEFT', Minimap, 'BOTTOM', 8, -8)
    Minimap.viewRadius:SetAlpha(0.5)
    Minimap.viewRadius:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(0.5) end)
    Minimap.viewRadius:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '镜头视野范围' or CAMERA_FOV, format(WoWTools_DataMixin.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100)))
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MinimapMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(1)
    end)

    Minimap.zoomText= WoWTools_LabelMixin:Create(Minimap, {color=true, mouse=true})
    Minimap.zoomText:SetPoint('BOTTOM', Minimap.ZoomOut, 'TOP', 3, 0)
    Minimap.zoomText:SetAlpha(0.5)
    Minimap.zoomText:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(0.5) end)
    Minimap.zoomText:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE, self:GetText())
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MinimapMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(1)
    end)
end



--Minimap.lua
--更新地区时,缩小化地图
--当前缩放，显示数值
function WoWTools_MinimapMixin:Init_Minimap_Zoom()
    if Save().ZoomOut==true then
        Save().ZoomOut='min'
    end
    if not Minimap.viewRadius then
        Init()
    end
    Frame:set_event()
end

function WoWTools_MinimapMixin:Zoom_Menu(frame, root)
    Init_Menu(frame, root)
end
