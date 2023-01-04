local id, e = ...
local addName= HUD_EDIT_MODE_MINIMAP_LABEL
local Save={scale=0.85, ZoomOut=true}
local panel=CreateFrame("Frame")

local function set_ZoomOut_Event()--更新地区时,缩小化地图, 事件
    if Save.ZoomOut then
        panel:RegisterEvent('PLAYER_ENTERING_WORLD')
        panel:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        panel:RegisterEvent('ZONE_CHANGED')
    else
        panel:UnregisterEvent('PLAYER_ENTERING_WORLD')
        panel:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        panel:UnregisterEvent('ZONE_CHANGED')
    end
end
local function set_ZoomOut()--更新地区时,缩小化地图
    local value= Minimap:GetZoomLevels()
    if value~=0 then
        Minimap:SetZoom(0)
    end
end
--####
--初始
--####
local function Init()
    local frame=MinimapCluster
    if Save.scale and Save.scale~=1 then
        frame:SetScale(Save.scale)
    end
    frame.ScaleIn=e.Cbtn(Minimap, nil, nil, nil, nil, true, {20,20})
    frame.ScaleIn:SetPoint('TOP',-2, 13)
    frame.ScaleIn:SetScript('OnMouseDown', function(self, d)
        local scale = Save.scale or 1
        scale= scale+0.05
        scale= scale>2 and 2 or scale<0.4 and 0.4 or scale
        frame:SetScale(scale)
        Save.scale=scale
        print(id, addName, e.onlyChinse and '缩放' or UI_SCALE, scale)
    end)
    frame.ScaleIn:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.onlyChinse and '放大' or ZOOM_IN, (e.onlyChinse and '缩放' or UI_SCALE)..(Save.scale or 1))
        e.tips:Show()
    end)
    frame.ScaleIn:SetScript('OnLeave', function() e.tips:Hide() end)

    frame.ScaleOut=e.Cbtn(Minimap, nil, nil, nil, nil, true, {20,20})
    frame.ScaleOut:SetPoint('BOTTOM', -1, -13)
    frame.ScaleOut:SetScript('OnMouseDown', function(self, d)
        local scale = Save.scale or 1
        scale= scale-0.05
        scale= scale>2 and 2 or scale<0.4 and 0.4 or scale
        frame:SetScale(scale)
        Save.scale=scale
        print(id, addName, e.onlyChinse and '缩放' or UI_SCALE, scale)
    end)
    frame.ScaleOut:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.onlyChinse and '缩小' or ZOOM_OUT, (e.onlyChinse and '缩放' or UI_SCALE)..(Save.scale or 1))
        e.tips:Show()
    end)
    frame.ScaleOut:SetScript('OnLeave', function() e.tips:Hide() end)

    if ExpansionLandingPageMinimapButton then
        local OpenWR=function()
            if not WeeklyRewardsFrame then
                return
            end
            if WeeklyRewardsFrame:IsShown() then
                HideUIPanel(WeeklyRewardsFrame);
            else
                WeeklyRewardsFrame:Show()
                tinsert(UISpecialFrames, WeeklyRewardsFrame:GetName())
            end
        end
        ExpansionLandingPageMinimapButton:SetScale(0.6)--透明度
        ExpansionLandingPageMinimapButton:SetFrameStrata('TOOLTIP')
        ExpansionLandingPageMinimapButton:SetMovable(true)--移动
        ExpansionLandingPageMinimapButton:RegisterForDrag("RightButton")
        ExpansionLandingPageMinimapButton:SetClampedToScreen(true)
        ExpansionLandingPageMinimapButton:SetScript("OnDragStart", function(self, d)
            if d=='RightButton' and IsAltKeyDown() then
                self:StartMoving()
            end
        end)
        ExpansionLandingPageMinimapButton:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
        end)
        ExpansionLandingPageMinimapButton:SetScript('OnMouseDown', function(self, d)
           if d=='RightButton' and not IsModifierKeyDown() then--周奖励面板
                if not WeeklyRewardsFrame then
                    LoadAddOn("Blizzard_WeeklyRewards")
                end
                OpenWR()
           end
        end)
        ExpansionLandingPageMinimapButton:SetScript('OnEnter',function(self)
            self:SetAlpha(1)
            e.tips:SetOwner(self, "ANCHOR_LEFT");
            e.tips:ClearLines();
            e.tips:AddDoubleLine(e.onlyChinse and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , e.Icon.right)
            e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
        ExpansionLandingPageMinimapButton:SetScript('OnLeave', function(self)
            e.tips:Hide()
            self:SetAlpha(0.3)
        end)

        C_Timer.After(8, function()--盟约图标停止闪烁
            ExpansionLandingPageMinimapButton.MinimapLoopPulseAnim:Stop()
            ExpansionLandingPageMinimapButton:SetAlpha(0.3)
        end)
    end

    local function set_minimapTrackingShowAll()--追踪,镇民
        if Save.minimapTrackingShowAll~=nil then
            C_CVar.SetCVar('minimapTrackingShowAll', not Save.minimapTrackingShowAll and '0' or '1' )
        end
    end

    if MinimapCluster and MinimapCluster.Tracking and MinimapCluster.Tracking.Button then
        MinimapCluster.Tracking.Button:HookScript( 'OnMouseDown', function()
            UIDropDownMenu_AddSeparator(1)
            local info={
                text=e.onlyChinse and '镇民' or TOWNSFOLK_TRACKING_TEXT,
                checked= C_CVar.GetCVarBool("minimapTrackingShowAll"),
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinse and '显示: 追踪' or SHOW..': '..TRACKING,
                tooltipText= id..' '..addName,
                func= function()
                    Save.minimapTrackingShowAll= not C_CVar.GetCVarBool("minimapTrackingShowAll") and true or false
                    set_minimapTrackingShowAll()--追踪,镇民
                end
            }
            UIDropDownMenu_AddButton(info, 1)

            info={
                text= e.onlyChinse and '缩小地图' or BINDING_NAME_MINIMAPZOOMOUT,
                checked= Save.ZoomOut,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinse and '更新地区时' or UPDATE..ZONE,
                tooltipText= id..' '..addName,
                func= function()
                    Save.ZoomOut= not Save.ZoomOut and true or nil
                    set_ZoomOut_Event()--更新地区时,缩小化地图
                    set_ZoomOut()--更新地区时,缩小化地图
                end
            }
            UIDropDownMenu_AddButton(info, 1)
        end)
    end

    if Save.ZoomOut then
        set_ZoomOut_Event()--更新地区时,缩小化地图
    end

    if Save.minimapTrackingShowAll~=nil then
        set_minimapTrackingShowAll()--追踪,镇民
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

             --添加控制面板        
             local sel=e.CPanel(e.onlyChinse and '小地图' or addName, not Save.disabled)
             sel:SetScript('OnClick', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需求重新加载' or REQUIRES_RELOAD)
             end)
             sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, addName)
                e.tips:AddDoubleLine(UI_SCALE, Save.scale or 1)
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            if not Save.disabled then
                Init()
            end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    else
        set_ZoomOut()--更新地区时,缩小化地图
    end
end)