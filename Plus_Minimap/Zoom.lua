local e= select(2, ...)
local Frame=CreateFrame('Frame')
local Save= function()
    return  WoWTools_MinimapMixin.Save
end














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
    local level = Minimap:GetZoom()
    local max= Minimap:GetZoomLevels()

    local select= value=='min' and 0 or (value=='max' and max) or (value-1)
    max= select>max and max or select

    if select~=level then
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
    for _, value in pairs({'min', 2, 3, 4, 5, 'max'}) do
        root:CreateRadio(
            value=='min' and (e.onlyChinese and '缩小' or ZOOM_OUT)
            or (value=='max' and (e.onlyChinese and '放大' or ZOOM_IN))
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
    end
    root:CreateDivider()
    root:CreateTitle(e.onlyChinese and '锁定' or LOCK)
end




local function Init()
    Minimap.ZoomIn:HookScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    Minimap.ZoomOut:HookScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    Minimap.viewRadius=e.Cstr(Minimap, {color=true, justifyH='CENTER', mouse=true})
    Minimap.viewRadius:SetPoint('BOTTOMLEFT', Minimap, 'BOTTOM', 8, -8)
    Minimap.viewRadius:SetAlpha(0.5)
    Minimap.viewRadius:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
    Minimap.viewRadius:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '镜头视野范围' or CAMERA_FOV, format(e.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100)))
        e.tips:AddDoubleLine(e.addName, WoWTools_MinimapMixin.addName)
        e.tips:Show()
        self:SetAlpha(1)
    end)

    Minimap.zoomText= e.Cstr(Minimap, {color=true, mouse=true})
    Minimap.zoomText:SetPoint('BOTTOM', Minimap.ZoomOut, 'TOP', 3, 0)
    Minimap.zoomText:SetAlpha(0.5)
    Minimap.zoomText:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
    Minimap.zoomText:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE, self:GetText())
        e.tips:AddDoubleLine(e.addName, WoWTools_MinimapMixin.addName)
        e.tips:Show()
        self:SetAlpha(1)
    end)
end



--Minimap.lua
--更新地区时,缩小化地图
--当前缩放，显示数值
function WoWTools_MinimapMixin:Init_Minimap_Zoom()
    if self.Save.ZoomOut==true then
        self.Save.ZoomOut='min'
    end
    if not Minimap.viewRadius then
        Init()
    end
    Frame:set_event()
end

function WoWTools_MinimapMixin:Zoom_Menu(frame, root)
    Init_Menu(frame, root)
end
