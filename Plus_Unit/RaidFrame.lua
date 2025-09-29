--团队 CompactUnitFrame.lua
local function Save()
    return WoWToolsSave['Plus_UnitFrame'] or {}
end





local function set_RaidTarget(texture, unit)--设置, 标记 TargetFrame.lua
    if texture then
        local index = UnitExists(unit) and GetRaidTargetIndex(unit)
        if index and index>0 and index< 9 then
            SetRaidTargetIconTexture(texture, index)
            texture:SetShown(true)
        else
            texture:SetShown(false)
        end
    end
end










local function Init()--设置,团队
    if Save().hideRaidFrame then
        return
    end

    WoWTools_DataMixin:Hook('CompactUnitFrame_SetUnit', function(frame, unit)--队伍标记
        if UnitExists(unit) and not unit:find('nameplate') and not frame.RaidTargetIcon and frame.name then
            frame.RaidTargetIcon= frame:CreateTexture(nil,'OVERLAY', nil, 7)
            frame.RaidTargetIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
            frame.RaidTargetIcon:SetPoint('TOPRIGHT')
            frame.RaidTargetIcon:SetSize(13,13)
            set_RaidTarget(frame.RaidTargetIcon, unit)
        end
        frame.unitItemLevel=nil--取得装等
    end)
    WoWTools_DataMixin:Hook('CompactUnitFrame_UpdateUnitEvents', function(frame)
        if frame.RaidTargetIcon then
            frame:RegisterEvent("RAID_TARGET_UPDATE")
        end
    end)
    WoWTools_DataMixin:Hook('CompactUnitFrame_UnregisterEvents', function(frame)
        if frame.RaidTargetIcon then
            frame:UnregisterEvent("RAID_TARGET_UPDATE")
            frame:UnregisterEvent("UNIT_TARGET")
        end
    end)
    WoWTools_DataMixin:Hook('CompactUnitFrame_OnEvent', function(self, event)
        if self.RaidTargetIcon and self.unit then
            if event=='RAID_TARGET_UPDATE'then
                set_RaidTarget(self.RaidTargetIcon, self.unit)
            end
        end
    end)

    WoWTools_DataMixin:Hook('CompactUnitFrame_UpdateRoleIcon', function(frame)--隐藏, DPS，图标 
        if not UnitExists(frame.unit) or frame.unit:find('nameplate') then
            return
        end
        local bool=true
        if not UnitInVehicle(frame.unit) and not UnitHasVehicleUI(frame.unit) and frame.roleIcon and frame.optionTable.displayRaidRoleIcon then
            local raidID = UnitInRaid(frame.unit)
            if raidID then
                if select(12, GetRaidRosterInfo(raidID))=='DAMAGER' then
                    bool=false
                end
            else
                if UnitGroupRolesAssigned(frame.unit) == "DAMAGER" then
                    bool= false
                end
            end
            frame.roleIcon:SetShown(bool)
        end
        if frame.powerBar then
            frame.powerBar:SetAlpha(bool and 1 or 0)
        end
        if frame.background then
            frame.background:ClearAllPoints()--背景
            if bool then
                frame.background:SetAllPoints(frame)
            else
                frame.background:SetAllPoints(frame.healthBar)
            end
        end
    end)

    WoWTools_DataMixin:Hook('CompactUnitFrame_UpdateName', function(frame)--修改, 名字
        if not UnitExists(frame.unit) or frame.unit:find('nameplate') or not frame.name or (frame.UpdateNameOverride and frame:UpdateNameOverride()) or not ShouldShowName(frame) then
            return
        end
        if UnitIsUnit('player', frame.unit) then
            frame.name:SetText(WoWTools_DataMixin.Icon.Player)
        elseif frame.unit:find('pet') then
            frame.name:SetText('')
        else
            local name= frame.name:GetText()
            if name then
                name= name:match('(.-)%-') or name
                name= WoWTools_TextMixin:sub(name, 4, 8)
                frame.name:SetText(name)
            end
        end
    end)

    WoWTools_DataMixin:Hook('CompactUnitFrame_UpdateStatusText', function(frame)--去掉,生命条, %
        if not UnitExists(frame.unit) or frame.unit:find('nameplate') or not frame.statusText or not frame.statusText:IsShown() or frame.optionTable.healthText ~= "perc" then
            return
        end
        local text= frame.statusText:GetText()
        if text then
            if text== '100%' or text=='0%' then
                text= ''
            else
                text= text:gsub('%%', '')
            end
            frame.statusText:SetText(text)
        end
    end)
    WoWTools_DataMixin:Hook('CompactRaidGroup_InitializeForGroup', function(frame, groupIndex)--处理, 队伍号
        frame.title:SetText('|A:services-number-'..groupIndex..':18:18|a')
    end)


    --新建, 移动, 按钮
    CompactRaidFrameContainer:SetClampedToScreen(true)
    CompactRaidFrameContainer:SetMovable(true)

    CompactRaidFrameContainer.moveFrame= WoWTools_ButtonMixin:Cbtn(CompactRaidFrameContainer, {texture='Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools', size=22})
    CompactRaidFrameContainer.moveFrame:SetPoint('TOPRIGHT', CompactRaidFrameContainer, 'TOPLEFT',-2, -13)

    CompactRaidFrameContainer.moveFrame:SetClampedToScreen(true)
    CompactRaidFrameContainer.moveFrame:SetMovable(true)
    CompactRaidFrameContainer:SetMovable(true)
    CompactRaidFrameContainer.moveFrame:RegisterForDrag('RightButton')
    CompactRaidFrameContainer.moveFrame:SetScript("OnDragStart", function(self)
        local frame= self:GetParent()
        if IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(frame) then
            if not frame:IsMovable()  then
                frame:SetMovable(true)
            end
            frame:StartMoving()
        end
    end)
    CompactRaidFrameContainer.moveFrame:SetScript("OnDragStop", function(self)
        self:GetParent():StopMovingOrSizing()
    end)
    CompactRaidFrameContainer.moveFrame:SetScript('OnMouseUp', ResetCursor)
    CompactRaidFrameContainer.moveFrame:SetScript("OnMouseDown", function(self)
        if IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(self:GetParent()) then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    function CompactRaidFrameContainer.moveFrame:set_Tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        local col= UnitAffectingCombat('player') and '|cff9e9e9e' or ''
        GameTooltip:AddDoubleLine(col..(WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..' '..(Save().raidFrameScale or 1), col..'Alt+'..WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
        self:SetAlpha(1)
    end
    function CompactRaidFrameContainer.moveFrame:set_Scale()
        self:GetParent():SetScale(Save().raidFrameScale or 1)
    end
    CompactRaidFrameContainer.moveFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if not IsAltKeyDown() then
            return
        end
        if not self:CanChangeAttribute() then
            print(WoWTools_DataMixin.addName, '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            return
        end
        local num= Save().raidFrameScale or 1
        if d==1 then
            num= num+0.05
        elseif d==-1 then
            num= num-0.05
        end
        num= num>4 and 4 or num
        num= num<0.4 and 0.4 or num
        Save().raidFrameScale= num
        self:set_Scale()
        self:set_Tooltips()
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName, WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE, num)
    end)
    CompactRaidFrameContainer.moveFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self:SetAlpha(0.1)
    end)
    CompactRaidFrameContainer.moveFrame:SetScript('OnEnter', CompactRaidFrameContainer.moveFrame.set_Tooltips)
    CompactRaidFrameContainer.moveFrame:set_Scale()
    CompactRaidFrameContainer.moveFrame:SetAlpha(0.1)




    --团体, 管理, 缩放

    CompactRaidFrameManager.ScaleButton= WoWTools_ButtonMixin:Menu(CompactRaidFrameManagerDisplayFrameOptionsButton, {
        size=18,
        name='CompactRaidFrameManagerScaleMenuButton'
    })
    CompactRaidFrameManager.ScaleButton:SetPoint('RIGHT', CompactRaidFrameManagerDisplayFrameRaidMemberCountLabel, 'LEFT')
    CompactRaidFrameManager.ScaleButton:SetAlpha(0.3)
    function CompactRaidFrameManager.ScaleButton:settings()
        CompactRaidFrameManager:SetScale(Save().managerScale or 1)
    end
    CompactRaidFrameManager.ScaleButton:SetScript('OnLeave', function(self)
        self:SetAlpha(0.3)
    end)
    CompactRaidFrameManager.ScaleButton:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
    end)
    CompactRaidFrameManager.ScaleButton:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end

--缩放
        WoWTools_MenuMixin:Scale(self, root, function()
            return Save().managerScale or 1
        end, function(value)
            Save().managerScale= value
            self:settings()
        end)

        root:CreateDivider()
--打开选项界面
        WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_UnitMixin.addName})
    end)
    CompactRaidFrameManager.ScaleButton:settings()







    WoWTools_DataMixin:Hook('CompactUnitFrame_UpdateStatusText', function(frame)
        if frame.unit:find('nameplate') then
            return
        end
        local connected= UnitIsConnected(frame.displayedUnit)
        local dead= UnitIsDead(frame.displayedUnit)
        local ghost= UnitIsGhost(frame.displayedUnit)
        if frame.background then
            frame.background:SetShown(connected and not ghost and not dead)
        end

        if not frame.statusText or not frame.optionTable.displayStatusText or not frame.statusText:IsShown() then--not frame.optionTable.displayStatusText then
            return
        end

        if ( not connected ) then--没连接
            frame.statusText:SetFormattedText("\124T%s.tga:0\124t", FRIENDS_TEXTURE_DND)
        elseif ghost then--灵魂
            frame.statusText:SetText('|A:poi-soulspiritghost:0:0|a')
        elseif dead then--死亡
            frame.statusText:SetText('|A:deathrecap-icon-tombstone:0:0|a')
        elseif ( frame.optionTable.healthText == "health" ) then
            frame.statusText:SetText(WoWTools_DataMixin:MK(UnitHealth(frame.displayedUnit), 0))
        elseif ( frame.optionTable.healthText == "losthealth" ) then
            local healthLost = UnitHealthMax(frame.displayedUnit) - UnitHealth(frame.displayedUnit)
            if ( healthLost > 0 ) then
                frame.statusText:SetText('-'..WoWTools_DataMixin:MK(healthLost, 0))
            end
        elseif (frame.optionTable.healthText == "perc") then
            if UnitHealth(frame.displayedUnit)== UnitHealthMax(frame.displayedUnit) then
                frame.statusText:SetText('')
            else
                local text= frame.statusText:GetText()
                if text then
                    text= text:gsub('%%','')
                    frame.statusText:SetText(text)
                end
            end
        end
    end)


    Init=function()end
end










function WoWTools_UnitMixin:Init_RaidFrame()--团队
    Init()
end