local id, e= ...

if e.Player.level< 58 then
    return
end

local addName= MOUNT_JOURNAL_FILTER_DRAGONRIDING..SPEED
local Save= {sacleBool= e.Player.husandro}
local panel= CreateFrame("Frame", nil, UIWidgetPowerBarContainerFrame)
panel:SetShown(false)

local lastX, lastY, lastT = 0, 0, 0
local function get_Speed()
    local time = GetTime()
    local dt = time - lastT
    local uiMapID = C_Map.GetBestMapForUnit('player')
    if uiMapID then
        local cur= GetUnitSpeed("player")
        if cur and cur>0 then
            lastX, lastY, lastT = 0, 0, 0
            return cur
        else
            local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
            if position then
                local x, y = position.x, position.y
                local w, h = C_Map.GetMapWorldSize(uiMapID)
                x = x * w
                y = y * h
                local dx = x - lastX
                local dy = y - lastY

                local groundSpeed = math.sqrt(dx * dx + dy * dy) / dt
                if groundSpeed >= 0 then
                    local cosTheta = math.cos(math.abs(0))
                    if cosTheta >= 0 then
                        lastX = x
                        lastY = y
                        lastT = time
                        return groundSpeed / cosTheta
                    end
                end
            end
        end
    end
    lastX, lastY, lastT = 0, 0, 0
end

--####
--初始
--####
local function Init()
    panel.text= e.Cstr(panel, {size=16})--16)
    panel.text:SetPoint('BOTTOM', UIWidgetPowerBarContainerFrame, 'TOP',0, 12)

    panel.statusBar= CreateFrame('StatusBar', nil, panel)
    panel.statusBar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
    panel.statusBar:SetStatusBarColor(0.8, 0.8, 0)
    panel.statusBar:SetPoint('BOTTOM', UIWidgetPowerBarContainerFrame, 'TOP')
    panel.statusBar:SetMinMaxValues(0, 1000)
    panel.statusBar:SetSize(200, 4)
    panel.statusBar:SetValue(0)

    panel:SetScript('OnHide', function(self)
        lastX, lastY, lastT = 0, 0, 0
        self.text:SetText('')
        self.statusBar:SetValue(0)
        self.statusBar:SetShown(false)
    end)
    panel:SetScript('OnShow', function(self)
        self.statusBar:SetShown(true)
    end)

    local timeElapsed = 0
    local speedTextFactor = 100 / BASE_MOVEMENT_SPEED
    panel:SetScript('OnUpdate', function(self, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 0.3 then
            local speed= get_Speed()
            if speed and speed>0 then
                speed= speed * speedTextFactor
                if speed>=1000 then
                    self.text:SetFormattedText('|cffff0000%.0f', speed)
                    self.statusBar:SetStatusBarColor(1, 0, 0)
                elseif speed>=800 then
                    self.text:SetFormattedText('|cff00ff00%.0f', speed)
                    self.statusBar:SetStatusBarColor(0, 1, 0)
                elseif speed>=600 then
                    self.text:SetFormattedText('|cffff00ff%.0f', speed)
                    self.statusBar:SetStatusBarColor(1, 0, 1)
                else
                    self.text:SetFormattedText('%.0f', speed)
                    self.statusBar:SetStatusBarColor(0.8, 0.8, 0)
                end
                self.statusBar:SetValue(speed>1000 and 1000 or speed)
            else
                self.text:SetText('')
                self.statusBar:SetValue(0)
            end
            timeElapsed = 0
        end
    end)

    hooksecurefunc(UIWidgetPowerBarContainerFrame, 'CreateWidget', function(self, widgetID)
        if widgetID==4460 and not IsInInstance() then
            panel:SetShown(true)
        end
    end)
    hooksecurefunc(UIWidgetPowerBarContainerFrame, 'RemoveWidget', function(self, widgetID)
        if widgetID==4460 then
            panel:SetShown(false)
        end
    end)
    if not IsInsane() then
        local widgetInfo = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460)
        if widgetInfo and widgetInfo.shownState==1 then
            panel:SetShown(true)
        end
    end
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel('|A:dragonriding_vigor_decor:0:0|a'..(e.onlyChinese and '驭龙术速度' or addName), not Save.disabled, true)
            sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
            end)
            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                if e.onlyChinese then
                    e.tips:AddDoubleLine('仅限: 不在副本', '等级: '..70)
                    e.tips:AddDoubleLine('仅限: 水平', '速度')
                else
                    e.tips:AddDoubleLine(format(LFG_LIST_CROSS_FACTION, BUG_CATEGORY2), LEVEL..': '..70)
                    e.tips:AddDoubleLine(format(LFG_LIST_CROSS_FACTION, HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL), SPEED)
                end
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
--https://wago.io/KIIAJSKl1