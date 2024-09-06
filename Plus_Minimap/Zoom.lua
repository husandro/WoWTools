local e= select(2, ...)


local Frame=CreateFrame('Frame')
Frame:RegisterEvent("ADDON_LOADED")
Frame:SetScript("OnEvent", function(self, event)
    if event=='PLAYER_ENTERING_WORLD' or event=='ZONE_CHANGED_NEW_AREA' or event=='ZONE_CHANGED' then
        self:set_ZoomOut()--更新地区时,缩小化地图

    elseif event=='MINIMAP_UPDATE_ZOOM' then--当前缩放，显示数值 Minimap.lua
        self:set_MINIMAP_UPDATE_ZOOM()
    end
end)








local Save= function()
    return  WoWTools_MinimapMixin.Save
end



--###################
--更新地区时,缩小化地图
--###################
function Frame:set_ZoomOut()
    if Save().ZoomOut then
        local value= Minimap:GetZoomLevels()
        if value~=0 then
            Minimap:SetZoom(0)
        end
    end
end




--################
--当前缩放，显示数值
--Minimap.lua
function Frame:set_Event_MINIMAP_UPDATE_ZOOM()
    if Save().ZoomOutInfo then
        Frame:RegisterEvent('MINIMAP_UPDATE_ZOOM')
    else
        Frame:UnregisterEvent('MINIMAP_UPDATE_ZOOM')
        if Minimap.zoomText then
            Minimap.zoomText:SetText('')
        end
        if Minimap.viewRadius then
            Minimap.viewRadius:SetText('')
        end
    end
end

function Frame:set_MINIMAP_UPDATE_ZOOM()
    local zoom = Minimap:GetZoom()
    local level= Minimap:GetZoomLevels()
    if not Minimap.zoomText then
        Minimap.zoomText= e.Cstr(Minimap, {color=true, mouse=true})
        Minimap.zoomText:SetPoint('BOTTOM', Minimap.ZoomOut, 'TOP', 3, 0)
        Minimap.zoomText:SetAlpha(0.5)
        Minimap.zoomText:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
        Minimap.zoomText:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE, self:GetText())
            e.tips:AddDoubleLine(e.addName, Initializer:GetName())
            e.tips:Show()
            self:SetAlpha(1)
        end)
    end
    Minimap.zoomText:SetText(zoom and level and (level-zoom)..'/'..level or '')

    if not Minimap.viewRadius then
        Minimap.viewRadius=e.Cstr(Minimap, {color=true, justifyH='CENTER', mouse=true})
        Minimap.viewRadius:SetPoint('BOTTOMLEFT', Minimap, 'BOTTOM', 8, -8)
        Minimap.viewRadius:SetAlpha(0.5)
        Minimap.viewRadius:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
        Minimap.viewRadius:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '镜头视野范围' or CAMERA_FOV, format(e.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100)))
            e.tips:AddDoubleLine(e.addName, Initializer:GetName())
            e.tips:Show()
            self:SetAlpha(1)
        end)

    end
    Minimap.viewRadius:SetFormattedText('%i', C_Minimap.GetViewRadius() or 100)
end



