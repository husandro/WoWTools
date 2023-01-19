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
local function set_minimapTrackingShowAll()--追踪,镇民
    if Save.minimapTrackingShowAll~=nil then
        C_CVar.SetCVar('minimapTrackingShowAll', not Save.minimapTrackingShowAll and '0' or '1' )
    end
end


--####
--缩放
--####
local function set_MinimapCluster()--缩放
    local frame=MinimapCluster
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
    if Save.scale and Save.scale~=1 then
        frame:SetScale(Save.scale)
    end
end


--#######
--盟约图标
--#######
local function set_ExpansionLandingPageMinimapButton()
    if not ExpansionLandingPageMinimapButton then
        return
    end
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

--#################
--小地图, 标记, 文本
--#################
local function set_vigentteButton_Event()
    if Save.vigentteButton then
        panel:RegisterEvent('VIGNETTE_MINIMAP_UPDATED')
        panel:RegisterEvent('VIGNETTES_UPDATED')
    else
        panel:UnregisterEvent('VIGNETTE_MINIMAP_UPDATED')
        panel:UnregisterEvent('VIGNETTES_UPDATED')
    end
end
local function set_vigentteButton_Text()
    if not Save.vigentteButtonShowText then
        panel.vigentteButton.text:SetText('')
        return
    end
    local text
    local vignetteGUIDs=C_VignetteInfo.GetVignettes();
    for _, guid in pairs(vignetteGUIDs) do
        if guid then
            local info= C_VignetteInfo.GetVignetteInfo(guid)
            if info and (info.onWorldMap or info.onMinimap) and info.name and info.atlasName then--and  info.zoneInfiniteAOI then
                text= text and text..'\n' or ''
                text= text.. info.name..'|A:'..info.atlasName..':0:0|a'
            end
        end
    end
    panel.vigentteButton.text:SetText(text or '..')
end
local function set_VIGNETTE_MINIMAP_UPDATED()--小地图, 标记, 文本
    set_vigentteButton_Event()
    if not Save.vigentteButton then
        if panel.vigentteButton then
            panel.vigentteButton.text:SetText('')
            panel.vigentteButton:SetShown(false)
        end
        return
    end
    if not panel.vigentteButton then
        --e.Cbtn= function(self, Template, value, SecureAction, name, notTexture, size)
        panel.vigentteButton= e.Cbtn(nil, nil, nil, nil, nil, true,{15, 15})
        if Save.pointVigentteButton then
            panel.vigentteButton:SetPoint(Save.pointVigentteButton[1], UIParent, Save.pointVigentteButton[3], Save.pointVigentteButton[4], Save.pointVigentteButton[5])
        else
            panel.vigentteButton:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMLEFT', -10,5)
        end
        if not Save.vigentteButtonShowText then
            panel.vigentteButton:SetNormalAtlas(e.Icon.disabled)
        end
        panel.vigentteButton:RegisterForDrag("RightButton")
        panel.vigentteButton:SetMovable(true)
        panel.vigentteButton:SetClampedToScreen(true)
        panel.vigentteButton:SetScript("OnDragStart", function(self,d)
            if d=='RightButton' and not IsModifierKeyDown() then
                self:StartMoving()
            end
        end)
        panel.vigentteButton:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            Save.pointVigentteButton={self:GetPoint(1)}
            Save.pointVigentteButton=nil
            print(id, addName, 'Alt+'..e.Icon.right, e.onlyChinse and '还原位置' or RESET_POSITION)
        end)
        panel.vigentteButton:SetScript('OnMouseDown', function(self, d)
            local key= IsModifierKeyDown()
            if d=='LeftButton' and not key then
                Save.vigentteButtonShowText= not Save.vigentteButtonShowText and true or nil
                if Save.vigentteButtonShowText then
                    self:SetNormalTexture(0)
                else
                    self:SetNormalAtlas(e.Icon.disabled)
                end
                set_vigentteButton_Text()
            elseif d=='RightButton' and key then
                self:ClearAllPoints()
                self:SetPoint('BOTTOMRIGHT', Minimap, 'BOTTOMLEFT', -10,5)
                Save.pointVigentteButton=nil
            elseif d=='RightButton' and not key then
                SetCursor('UI_MOVE_CURSOR')
            end
        end)
        panel.vigentteButton:SetScript('OnMouseWheel', function(self, d)--缩放
            if IsAltKeyDown() then
                local size=Save.vigentteButtonSize or 12
                if d==1 then
                    size=size+1
                elseif d==-1 then
                    size=size-1
                end
                if size>36 then
                    size=36
                elseif size<8 then
                    size=8
                end
                print(id, addName, e.onlyChinse and '字体大小' or FONT_SIZE, size)
                Save.vigentteButtonSize= size
                e.Cstr(nil, size, nil, panel.vigentteButton.text, true ,nil,'RIGHT')
            end
        end)
        panel.vigentteButton:SetScript('OnEnter',function(self)
            set_vigentteButton_Text()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddDoubleLine(e.onlyChinse and '文本' or LOCALE_TEXT_LABEL, e.GetShowHide(Save.vigentteButtonShowText)..e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine((e.onlyChinse and '字体大小' or FONT_SIZE)..': '..(Save.vigentteButtonSize or 12), 'Alt+'..e.Icon.mid)
            e.tips:Show()
        end)
        panel.vigentteButton:SetScript('OnLeave',function(self)
            e.tips:Hide()
            ResetCursor()
        end)

        --e.Cstr=function(self, size, fontType, ChangeFont, color, layer, justifyH)
        panel.vigentteButton.text= e.Cstr(panel.vigentteButton, Save.vigentteButtonSize, nil, nil, true,nil,'RIGHT')
        panel.vigentteButton.text:SetPoint('BOTTOMRIGHT')
    end
    panel.vigentteButton:SetShown(true)
    set_vigentteButton_Text()
end

--###############
--小地图, 添加菜单
--###############
local function set_MinimapMenu()--小地图, 添加菜单
    if not MinimapCluster or not MinimapCluster.Tracking or not MinimapCluster.Tracking.Button then
        return
    end
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

        info={
            text= e.onlyChinse and '文本' or LOCALE_TEXT_LABEL,
            checked= Save.vigentteButton,
            func= function ()
                Save.vigentteButton= not Save.vigentteButton and true or nil
                set_VIGNETTE_MINIMAP_UPDATED()--小地图, 标记, 文本
            end
        }
        UIDropDownMenu_AddButton(info, 1)
    end)
end




--####
--初始
--####
local function Init()
    set_MinimapCluster()--缩放
    set_ExpansionLandingPageMinimapButton()--盟约图标
    set_MinimapMenu()--小地图, 添加菜单

    if Save.ZoomOut then
        set_ZoomOut_Event()--更新地区时, 缩小化地图
    end
    if Save.minimapTrackingShowAll~=nil then
        set_minimapTrackingShowAll()--追踪,镇民
    end

    set_VIGNETTE_MINIMAP_UPDATED()--小地图, 标记, 文本
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

             --添加控制面板        
             local sel=e.CPanel(e.onlyChinse and '小地图' or addName, not Save.disabled)
             sel:SetScript('OnMouseDown', function()
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

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_ENTERING_WORLD' or event=='ZONE_CHANGED_NEW_AREA' or event=='ZONE_CHANGED' then
        set_ZoomOut()--更新地区时,缩小化地图

    elseif event=='VIGNETTE_MINIMAP_UPDATED' or event=='VIGNETTES_UPDATED' then
        set_vigentteButton_Event()--小地图, 标记, 文本        
    end
end)