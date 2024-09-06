local e= select(2, ...)
local Frame=CreateFrame('Frame')
local Save= function()
    return  WoWTools_MinimapMixin.Save
end





local function Create_Label()
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
    local value= Minimap:GetZoomLevels()
    if value~=0 then
        Minimap:SetZoom(0)
    end
end





function Frame:MINIMAP_UPDATE_ZOOM()--当前缩放，显示数值
    local zoom = Minimap:GetZoom()
    local level= Minimap:GetZoomLevels()
    Minimap.zoomText:SetText(zoom and level and (level-zoom)..'/'..level or '')
    Minimap.viewRadius:SetFormattedText('%i', C_Minimap.GetViewRadius() or 100)
end




Frame:RegisterEvent("ADDON_LOADED")
Frame:SetScript("OnEvent", function(self, event)
    if event=='PLAYER_ENTERING_WORLD' or event=='ZONE_CHANGED_NEW_AREA' or event=='ZONE_CHANGED' then

    elseif event=='MINIMAP_UPDATE_ZOOM' then
        self:MINIMAP_UPDATE_ZOOM()
    end
end)





--Minimap.lua
--更新地区时,缩小化地图
--当前缩放，显示数值
function WoWTools_MinimapMixin:Init_Minimap_Zoom()
    if not Minimap.viewRadius then
        Create_Label()
    end
    Frame:set_event()
end