local id, e = ...
local addName= HUD_EDIT_MODE_MINIMAP_LABEL
local Save={scale=0.85}

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
        print(id, addName, UI_SCALE, scale)
    end)
    frame.ScaleIn:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(ZOOM_IN, UI_SCALE..(Save.scale or 1))
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
        print(id, addName, UI_SCALE, scale)
    end)
    frame.ScaleOut:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(ZOOM_OUT, UI_SCALE..(Save.scale or 1))
        e.tips:Show()
    end)
    frame.ScaleOut:SetScript('OnLeave', function() e.tips:Hide() end)

    if ExpansionLandingPageMinimapButton then
        ExpansionLandingPageMinimapButton:SetScale(0.6)--透明度
        ExpansionLandingPageMinimapButton:SetAlpha(0.3)
        ExpansionLandingPageMinimapButton:SetScript('OnEnter', function(self)
            self:SetAlpha(1)
        end)
        ExpansionLandingPageMinimapButton:SetScript('OnLeave', function(self)
            self:SetAlpha(0.3)
        end)
        C_Timer.After(10, function()--盟约图标停止闪烁
            ExpansionLandingPageMinimapButton.MinimapLoopPulseAnim:Stop()
        end)

        ExpansionLandingPageMinimapButton:SetMovable(true)--移动
        ExpansionLandingPageMinimapButton:RegisterForDrag("RightButton")
        ExpansionLandingPageMinimapButton:SetClampedToScreen(true)
        ExpansionLandingPageMinimapButton:SetScript("OnDragStart", ExpansionLandingPageMinimapButton.StartMoving)        
        ExpansionLandingPageMinimapButton:SetScript("OnDragStop", ExpansionLandingPageMinimapButton.StopMovingOrSizing)
    end
end

--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

             --添加控制面板        
             local sel=e.CPanel(addName, not Save.disabled)
             sel:SetScript('OnClick', function()
                 if Save.disabled then
                     Save.disabled=nil
                 else
                     Save.disabled=true
                 end
                 print(id, addName, e.GetEnabeleDisable(not Save.disabled), 	REQUIRES_RELOAD)
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
    end
end)