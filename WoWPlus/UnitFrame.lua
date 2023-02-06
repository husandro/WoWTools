local id, e = ...
local addName= UNITFRAME_LABEL
local Save={raidFrameScale=0.8, notRaidFrame=not e.Player.husandro }--{SetShadowOffset= 1}
local panel=CreateFrame("Frame")
local R,G,B= GetClassColor(UnitClassBase('player'))

--[[local function set_SetShadowOffset(self)--设置, 阴影
    if self then
        self:SetShadowOffset(1, -1)
    end
end]]
local function set_SetTextColor(self, r, g, b)--设置, 字体
    if self and self:IsShown() and r and g and b then
        self:SetTextColor(r, g, b)
    end
end

local function set_SetRaidTarget(texture, unit)--设置, 标记 TargetFrame.lua
    if texture and unit then
        local index = UnitExists(unit) and GetRaidTargetIndex(unit)
        if index and index>0 and index< 9 then
            SetRaidTargetIconTexture(texture, index)
            texture:SetShown(true)
        else
            texture:SetShown(false)
        end
    end
end

--####
--玩家
--####
local function set_PlayerFrame()--PlayerFrame.lua
    hooksecurefunc('PlayerFrame_UpdateLevel', function()
        set_SetTextColor(PlayerLevelText, R,G,B)
    end)
    --set_SetShadowOffset(PlayerLevelText)

    --施法条
    PlayerCastingBarFrame:HookScript('OnShow', function(self)--图标
        self.Icon:SetShown(true)
    end)
    PlayerCastingBarFrame:SetFrameStrata('TOOLTIP')--设置为， 最上层
    set_SetTextColor(PlayerCastingBarFrame.Text, R,G,B)--颜色
    PlayerCastingBarFrame.castingText=e.Cstr(PlayerCastingBarFrame, nil, nil, nil, {R,G,B}, nil, 'RIGHT')
    PlayerCastingBarFrame.castingText:SetDrawLayer('OVERLAY', 2)
    PlayerCastingBarFrame.castingText:SetPoint('RIGHT', PlayerCastingBarFrame.ChargeFlash, 'RIGHT')
    PlayerCastingBarFrame:HookScript('OnUpdate', function(self, elapsed)--玩家, 施法, 时间
        if self.value and self.maxValue then
            local value= self.channeling and self.value or (self.maxValue-self.value)
            if value>=3 then
                self.castingText:SetFormattedText('%i', value)
            else
                self.castingText:SetFormattedText('%.01f', value)
            end
        end
    end)
    hooksecurefunc('PlayerFrame_UpdateGroupIndicator', function()--处理,小队, 号码
        if IsInRaid() then
            local text= PlayerFrameGroupIndicatorText:GetText()
            local num= text:match('(%d)')
            if num then
                PlayerFrameGroupIndicatorText:SetText('|A:'..e.Icon.number..num..':0:0|a')
            end
        end
    end)
    PlayerFrameGroupIndicatorLeft:SetTexture(0)
    PlayerFrameGroupIndicatorMiddle:SetTexture(0)
    PlayerFrameGroupIndicatorRight:SetTexture(0)

    if PlayerHitIndicator then
        PlayerHitIndicator:ClearAllPoints()
        PlayerHitIndicator:SetPoint('BOTTOMLEFT', (PlayerFrame.PlayerFrameContainer and PlayerFrame and PlayerFrame.PlayerFrameContainer.PlayerPortrait) or  PlayerHitIndicator:GetParent(), 'TOPLEFT')
    end
end

--####
--目标
--####
local function set_TargetFrame()
    hooksecurefunc(TargetFrame,'CheckLevel', function(self)--目标, 等级, 颜色
        local levelText = self.TargetFrameContent.TargetFrameContentMain.LevelText
        if levelText and levelText:IsShown() and self.unit then
            local classFilename= UnitClassBase(self.unit)
            if classFilename then
                local r,g,b=GetClassColor(classFilename)
                if r and g and b then
                    levelText:SetTextColor(r,g,b)
                end
            end
        end
    end)
end


--####
--小队
--####
local function set_Party_Target_Changed(portrait, unit)
    if unit and UnitExists(unit) and portrait then
        unit= unit..'target'
        if UnitExists(unit) then
            local index = GetRaidTargetIndex(unit)
            if index and index>0 and index< 9 then
                portrait:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
            else
                SetPortraitTexture(portrait, unit, true)
            end
            portrait:SetShown(true)
        else
            portrait:SetShown(false)
        end
    end
end
local function set_Paerty_Casting(frame, unit, start)
    if not (frame or unit) then
        return
    end
    if start then
        local texture, startTime, endTime = select(3, UnitChannelInfo(unit))
        if not (texture and  startTime and endTime) then
            texture, startTime, endTime= select(3, UnitCastingInfo(unit))
        end
        if texture and startTime and endTime then
            local duration=(endTime - startTime) / 1000
            e.Ccool(frame, nil, duration, nil, true, nil, nil,nil)
        end
        frame.texture:SetTexture(texture or 0)
    else
        frame.texture:SetTexture(0)
        if frame.cooldown then
            frame.cooldown:Clear()
        end
    end
end
local function set_PartyFrame()--PartyFrame.lua
    hooksecurefunc(PartyFrame, 'UpdatePartyFrames', function(self)
        for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
            local unit= memberFrame.unit or memberFrame:GetUnit()
            local frame= memberFrame.PartyMemberOverlay
            if frame and unit then
                local exists= memberFrame:IsShown()
                frame.unit= unit
                if not frame.RaidTargetIcon and exists then
                    frame.RaidTargetIcon= self:CreateTexture(nil,'OVERLAY', nil, 7)--队伍, 标记
                    frame.RaidTargetIcon:SetPoint('RIGHT', frame.RoleIcon, 'LEFT')
                    frame.RaidTargetIcon:SetSize(14,14)
                    frame.RaidTargetIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')

                    frame.TotPortrait= self:CreateTexture(nil,'OVERLAY', nil, 7)--目标的目标
                    frame.TotPortrait:SetPoint('TOPLEFT', memberFrame, 'TOPRIGHT',-3 ,-4)
                    frame.TotPortrait:SetSize(20,20)

                    frame.frame= CreateFrame("Frame", nil, self)
                    frame.frame:SetPoint('TOP', frame.TotPortrait, 'BOTTOM')
                    frame.frame:SetSize(20,20)
                    frame.frame.texture= self:CreateTexture(nil,'BACKGROUND')
                    frame.frame.texture:SetAllPoints(frame.frame)
                    frame.frame:HookScript('OnEvent', function (self2, event, arg1)
                        if  event == "UNIT_SPELLCAST_START" or  event == "UNIT_SPELLCAST_CHANNEL_START" or event=='UNIT_SPELLCAST_EMPOWER_START'  then
                            set_Paerty_Casting(self2, unit, true)
                        else
                            set_Paerty_Casting(self2, unit)
                        end
                    end)
                    frame:HookScript('OnEvent', function (self2, event, arg1)
                        if event=='RAID_TARGET_UPDATE' then
                            set_SetRaidTarget(self2.RaidTargetIcon, self2.unit)
                        elseif event=='UNIT_TARGET' and arg1==self2.unit then
                            set_Party_Target_Changed(self2.TotPortrait, self2.unit)
                        end
                    end)

                    hooksecurefunc(memberFrame, 'UpdateAssignedRoles', function(self2)--隐藏, DPS 图标
                        if self2.unit then
                            local role = UnitGroupRolesAssigned(self2.unit)
                            local icon = self2.PartyMemberOverlay.RoleIcon
                            if icon and role== 'DAMAGER' then
                                icon:SetShown(false)
                            end
                        end
                    end)
                end

                if frame.RaidTargetIcon then
                    if exists then
                        frame:RegisterEvent('RAID_TARGET_UPDATE')--更新,标记
                        frame:RegisterUnitEvent('UNIT_TARGET', unit)

                        frame.frame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)--开始
                        frame.frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
                        frame.frame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit)
                        frame.frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)--结束
                        frame.frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
                        frame.frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
                        frame.frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
                        frame.frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
                        frame.frame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit)

                        set_SetRaidTarget(frame.RaidTargetIcon, unit)--设置,标记
                        set_Party_Target_Changed(frame.TotPortrait, unit)
                        set_Paerty_Casting(frame.frame, unit, true)
                    else
                        frame:UnregisterAllEvents()
                        frame.RaidTargetIcon:SetShown(false)
                        frame.TotPortrait:SetShown(false)
                        frame.frame:UnregisterAllEvents()
                        frame.frame.texture:SetTexture(0)
                    end
                end
            end
        end
    end)
end

--################
--职业, 图标， 颜色
--################
local function set_UnitFrame_Update()--职业, 图标， 颜色
    hooksecurefunc('UnitFrame_Update', function(self, isParty)--UnitFrame.lua
        local unit= self.overrideName or self.unit
        local r,g,b
        if unit=='player' then
            r,g,b= R,G,B
        else
            local classFilename= unit and UnitClassBase(unit)
            if classFilename then
                r,g,b=GetClassColor(classFilename)
            end
        end
        if not UnitExists(unit) or not (r and g and b) then
            return
        end
        local class=e.Class(unit, nil, true)--职业, 图标
        if not self.classTexture then
            self.classTexture= self:CreateTexture(nil,'OVERLAY', nil, 7)
            if unit=='target' or unit=='focus' then
                self.classTexture:SetPoint('TOPRIGHT', self.portrait, 'TOPLEFT',0,10)
                if unit=='target' then--移动, 队长图标，TargetFrame.lua
                    local targetFrameContentContextual = TargetFrame.TargetFrameContent.TargetFrameContentContextual
                    if targetFrameContentContextual then
                        targetFrameContentContextual.LeaderIcon:ClearAllPoints()
                        targetFrameContentContextual.LeaderIcon:SetPoint('RIGHT', self.classTexture,'LEFT')
                        targetFrameContentContextual.GuideIcon:ClearAllPoints()
                        targetFrameContentContextual.GuideIcon:SetPoint('RIGHT', self.classTexture,'LEFT')
                    end
                end
            else
                self.classTexture:SetPoint('TOPLEFT', self.portrait, 'TOPRIGHT',-14,10)
            end
            self.classTexture:SetSize(20,20)

--[[            if self.healthbar then
                set_SetShadowOffset(self.healthbar.LeftText)--字本, 阴影
                set_SetShadowOffset(self.healthbar.TextString)
                set_SetShadowOffset(self.healthbar.RightText)
            end
            if self.manabar then
                set_SetShadowOffset(self.manabar.LeftText)
                set_SetShadowOffset(self.manabar.TextString)
                set_SetShadowOffset(self.manabar.RightText)
            end
            set_SetShadowOffset(self.name)]]
        end
        self.classTexture:SetAtlas(class or 0)

        if self.name then
            set_SetTextColor(self.name, r,g,b)--名称, 颜色
            if unit:find('pet') or UnitIsUnit(unit, 'pet') then
                self.name:SetText('')
            elseif isParty then
                local name= UnitName(unit)
                name= e.WA_Utf8Sub(name, 4, 8)
                self.name:SetText(name)
            end
        end
        if self.healthbar then
            self.healthbar:SetStatusBarColor(r,g,b)--颜色
            self.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
        end
    end)

    hooksecurefunc(TargetFrame, 'CheckClassification', function ()--目标，颜色
        TargetFrame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
    end)
    hooksecurefunc('UnitFrame_OnEvent', function(self, event, unit)--修改, 宠物, 名称
        if unit== 'pet' and unit == self.unit and event == "UNIT_NAME_UPDATE" then
            self.name:SetText('')
        end
    end)

    --############
    --去掉生命条 % extStatusBar.lua
    --############
    hooksecurefunc('TextStatusBar_UpdateTextStringWithValues', function(statusFrame, textString, value, valueMin, valueMax)
        if value and value>0 then
            if textString and textString:IsShown() then
                local text= textString:GetText()
                if text then
                    if text=='100%' then
                        text= ''
                    else
                        text= text:gsub('%%', '')
                    end
                    textString:SetText(text)
                end
            elseif statusFrame.LeftText and statusFrame.LeftText:IsShown() then
                local text= statusFrame.LeftText:GetText()
                if text then
                    if text=='100%' then
                        text= ''
                    else
                        text= text:gsub('%%', '')
                    end
                    statusFrame.LeftText:SetText(text)
                end
            end
        end
    end)

    --###################
    --隐藏, 队伍, DPS 图标
    --###################
    for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        hooksecurefunc(memberFrame, 'UpdateAssignedRoles', function(self)--隐藏, DPS 图标
            local icon = self.PartyMemberOverlay.RoleIcon
            if icon and icon:IsShown() then
                local role = UnitGroupRolesAssigned(self.unit)
                if role== 'DAMAGER' then
                    icon:SetAlpha(0)
                else
                    icon:SetAlpha(1)
                end
            end
        end)
    end

end

--#######
--拾取专精
--#######
local function set_LootSpecialization()--拾取专精
    local currentSpec = GetSpecialization()
    local specID= currentSpec and GetSpecializationInfo(currentSpec)
    local find=false
    if specID then
        local lootSpecID = GetLootSpecialization()
        if lootSpecID and lootSpecID~=specID then
            local texture= select(4, GetSpecializationInfoByID(lootSpecID))
            if texture then
                if not PlayerFrame.lootSpecTexture then
                    PlayerFrame.lootSpecTexture= PlayerFrame:CreateTexture(nil,'OVERLAY', nil, 7)
                    PlayerFrame.lootSpecTexture:SetSize(20,20)
                    if PlayerFrame.classTexture then
                        PlayerFrame.lootSpecTexture:SetPoint('RIGHT', PlayerFrame.classTexture, 'LEFT')
                    else
                        PlayerFrame.lootSpecTexture:SetPoint('TOPLEFT', PlayerFrame.portrait, 'TOPRIGHT',-34,10)
                    end
                end
                SetPortraitToTexture(PlayerFrame.lootSpecTexture, texture)
                find=true
            end
        end
    end
    if PlayerFrame.lootSpecTexture then
        PlayerFrame.lootSpecTexture:SetShown(find)
    end

    if PetHitIndicator then
        PetHitIndicator:ClearAllPoints()
        PetHitIndicator:SetPoint('TOPLEFT', PetPortrait or PetHitIndicator:GetParent(), 'BOTTOMLEFT')
    end
end

--####
--团队
--CompactUnitFrame.lua
local function set_RaidFrame()--设置,团队
    if Save.notRaidFrame then
        return
    end
    hooksecurefunc('CompactUnitFrame_SetUnit', function(frame, unit)--队伍标记
        if unit and not frame.RaidTargetIcon and frame.name then
            frame.RaidTargetIcon= frame:CreateTexture(nil,'OVERLAY', nil, 7)
            frame.RaidTargetIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
            frame.RaidTargetIcon:SetPoint('TOPRIGHT')
            frame.RaidTargetIcon:SetSize(13,13)
            --frame:RegisterEvent("RAID_TARGET_UPDATE")
            set_SetRaidTarget(frame.RaidTargetIcon, unit)
        --[[系统, 自带
            frame.ToTargetIcon=  frame:CreateTexture(nil,'OVERLAY', nil, 6)--BOSS, 目标
            frame.ToTargetIcon:SetAtlas('worldstate-capturebar-leftglow-safedangerous-embercourt')
            frame.ToTargetIcon:SetAllPoints(frame)
            frame.ToTargetIcon:SetShown(false)
            ]]
        end
    end)
    hooksecurefunc('CompactUnitFrame_UpdateUnitEvents', function(frame)
        frame:RegisterEvent("RAID_TARGET_UPDATE")
        --frame:RegisterUnitEvent("UNIT_TARGET", 'boss1', 'boss2', 'boss3', 'boss4', 'boss5', 'boss6', 'boss7', 'boss8')
    end)
    hooksecurefunc('CompactUnitFrame_UnregisterEvents', function(frame)
        frame:UnregisterEvent("RAID_TARGET_UPDATE")
        frame:UnregisterEvent("UNIT_TARGET")
    end)
    hooksecurefunc('CompactUnitFrame_OnEvent', function(self, event, arg1)
        if self.RaidTargetIcon and self.unit then
            if event=='RAID_TARGET_UPDATE'then
                set_SetRaidTarget(self.RaidTargetIcon, self.unit)
            --elseif event=='UNIT_TARGET' and arg1 then
                --self.ToTargetIcon:SetShown(UnitIsUnit(self.unit, arg1..'target'))
            end
        end
    end)

    hooksecurefunc('CompactUnitFrame_UpdateRoleIcon', function(frame)--隐藏, DPS，图标 
        if not UnitExists(frame.unit) then
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
            frame.powerBar:SetShown(bool)
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

    hooksecurefunc('CompactUnitFrame_UpdateName', function(frame)--修改, 名字
        if not frame.unit or not frame.name or (frame.UpdateNameOverride and frame:UpdateNameOverride()) or not ShouldShowName(frame) then
            return
        end
        if UnitIsUnit('player', frame.unit) then
            frame.name:SetText(e.Icon.player)
        elseif frame.unit:find('pet') then
            frame.name:SetText('')
        else
            local name= frame.name:GetText()
            if name then
                name= name:match('(.-)%-') or name
                name= e.WA_Utf8Sub(name, 4, 8)
                frame.name:SetText(name)
            end
        end
    end)

    hooksecurefunc('CompactUnitFrame_UpdateHealthColor', function(frame)--颜色
        if frame.healthBar and frame.unit and frame.unit:find('pet') then
            local class= UnitClassBase(frame.unit)
            if class then
                local r, g, b= GetClassColor(class)
                if r and g and b then
                    frame.healthBar:SetStatusBarColor(r,g,b)
                    frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b
                end
            end
        end
    end)

    hooksecurefunc('CompactUnitFrame_UpdateStatusText', function(frame)--去掉,生命条, %
        if not frame.statusText or not frame.statusText:IsShown() or frame.optionTable.healthText ~= "perc" then
            return
        end
        local text= frame.statusText:GetText()
        if text then
            if text== '100%' then
                text= ''
            else
                text= text:gsub('%%', '')
            end
            frame.statusText:SetText(text)
        end
    end)

    hooksecurefunc('CompactRaidGroup_InitializeForGroup', function(frame, groupIndex)--处理, 队伍号
        frame.title:SetText('|A:'..e.Icon.number..groupIndex..':0:0|a')
    end)


    --新建, 移动, 按钮
    CompactRaidFrameContainer:SetClampedToScreen(true)
    CompactRaidFrameContainer:SetMovable(true)

    CompactRaidFrameContainer.moveFrame= e.Cbtn(CompactRaidFrameContainer, nil, true, nil, nil, nil, {20,20})
    CompactRaidFrameContainer.moveFrame:SetAlpha(0.3)
    CompactRaidFrameContainer.moveFrame:SetPoint('TOPRIGHT', CompactRaidFrameContainer, 'TOPLEFT',-2, -13)
    CompactRaidFrameContainer.moveFrame:SetClampedToScreen(true)
    CompactRaidFrameContainer.moveFrame:SetMovable(true)
    CompactRaidFrameContainer.moveFrame:RegisterForDrag('RightButton')
    CompactRaidFrameContainer.moveFrame:SetScript("OnDragStart", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            CompactRaidFrameContainer:StartMoving()
        end
    end)
    CompactRaidFrameContainer.moveFrame:SetScript("OnDragStop", function(self)
        CompactRaidFrameContainer:StopMovingOrSizing()
    end)
    CompactRaidFrameContainer.moveFrame:SetScript("OnMouseDown", function(self, d)
        print(id, addName, (e.onlyChinse and '移动' or NPE_MOVE)..e.Icon.right, 'Alt+'..e.Icon.mid..(e.onlyChinse and '缩放' or UI_SCALE), Save.raidFrameScale or 1)
        if d=='RightButton' and not IsModifierKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    CompactRaidFrameContainer.moveFrame:SetScript("OnLeave", function(self, d)
        ResetCursor()
    end)
    CompactRaidFrameContainer.moveFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            if UnitAffectingCombat('player') then
                print(id, addName, e.onlyChinse and '缩放' or UI_SCALE, '|cnRED_FONT_COLOR:'..(e.onlyChinse and '战斗中' or COMBAT))
            else
                local sacle= Save.raidFrameScale or 1
                if d==1 then
                    sacle=sacle+0.1
                elseif d==-1 then
                    sacle=sacle-0.1
                end
                if sacle>2 then
                    sacle=2
                elseif sacle<0.5 then
                    sacle=0.5
                end
                print(id, addName, (e.onlyChinse and '缩放' or UI_SCALE), sacle)
                CompactRaidFrameContainer:SetScale(sacle)
                Save.raidFrameScale=sacle
            end
        end
    end)
    if Save.raidFrameScale and Save.raidFrameScale~=1 then
        CompactRaidFrameContainer:SetScale(Save.raidFrameScale)
    end


    --团体, 管理, 缩放
    CompactRaidFrameManager.sacleFrame= e.Cbtn(CompactRaidFrameManager, nil, true, nil, nil, nil, {15,15})
    CompactRaidFrameManager.sacleFrame:SetPoint('RIGHT', CompactRaidFrameManagerDisplayFrameRaidMemberCountLabel, 'LEFT')
    CompactRaidFrameManager.sacleFrame:SetAlpha(0.5)
    CompactRaidFrameManager.sacleFrame:SetScript("OnMouseDown", function(self, d)
        print(id, addName, 'Alt+'..e.Icon.mid..(e.onlyChinse and '缩放' or UI_SCALE), Save.managerScale or 1)
    end)
    CompactRaidFrameManager.sacleFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            if UnitAffectingCombat('player') then
                print(id, addName, e.onlyChinse and '缩放' or UI_SCALE, '|cnRED_FONT_COLOR:'..(e.onlyChinse and '战斗中' or COMBAT))
            else
                local sacle= Save.managerScale or 1
                if d==1 then
                    sacle=sacle+0.05
                elseif d==-1 then
                    sacle=sacle-0.05
                end
                if sacle>1.5 then
                    sacle=1.5
                elseif sacle<0.5 then
                    sacle=0.5
                end
                print(id, addName, (e.onlyChinse and '缩放' or UI_SCALE), sacle)
                CompactRaidFrameManager:SetScale(sacle)
                Save.managerScale=sacle
            end
        end
    end)
    if Save.managerScale and Save.managerScale~=1 then
        CompactRaidFrameManager:SetScale(Save.managerScale)
    end

    hooksecurefunc('CompactUnitFrame_UpdateDistance', function(frame)--取得装等, 高CPU
        if not frame.unitItemLevel and frame.unit and CheckInteractDistance(frame.unit, 1) and CanInspect(frame.unit) then --frame.inDistance and frame.inDistance< DISTANCE_THRESHOLD_SQUARED then
            if not frame.getItemTime then
                NotifyInspect(frame.unit)--取得装等
                local guid= UnitGUID(frame.unit)
                if guid and e.UnitItemLevel[guid] then
                    if not e.UnitItemLevel[guid].itemLevel then
                        NotifyInspect(frame.unit)--取得装等
                        print(frame.unit, '取得装等')
                    end
                    frame.unitItemLevel= e.UnitItemLevel[guid].itemLevel
                end
            end
        end
    end)
        --[[
        if not frame.statusText or not frame.optionTable.displayStatusText then
            return
        end
	    local distance, checkedDistance = UnitDistanceSquared(frame.displayedUnit)
        if ( checkedDistance ) then

           
            local inDistance = distance < DISTANCE_THRESHOLD_SQUARED
            if ( inDistance ~= frame.inDistance ) then
                local text= e.GetUnitMapName(frame.displayedUnit)--单位, 地图名称
                if text then
                    text= '|cnGREEN_FONT_COLOR:'..text..'|r'
                    frame.statusText:SetText(text)
                end
            end
        end]]

    hooksecurefunc('CompactUnitFrame_UpdateStatusText', function(frame)
        local connected= UnitIsConnected(frame.displayedUnit)
        if frame.background then
            frame.background:SetShown(connected)
        end

        if not frame.statusText or not frame.optionTable.displayStatusText or not frame.statusText:IsShown() then--not frame.optionTable.displayStatusText then
            return
        end

        if ( not connected ) then
            frame.statusText:SetFormattedText("\124T%s.tga:0\124t", FRIENDS_TEXTURE_DND)
        elseif UnitIsGhost(frame.displayedUnit) then
            frame.statusText:SetText('|A:poi-soulspiritghost:0:0|a')
        elseif UnitIsDead(frame.displayedUnit) then
            frame.statusText:SetText('|A:deathrecap-icon-tombstone:0:0|a')
        elseif ( frame.optionTable.healthText == "health" ) then
            frame.statusText:SetText(e.MK(UnitHealth(frame.displayedUnit),1))
        elseif ( frame.optionTable.healthText == "losthealth" ) then
            local healthLost = UnitHealthMax(frame.displayedUnit) - UnitHealth(frame.displayedUnit)
            if ( healthLost > 0 ) then
                frame.statusText:SetFormattedText('%-%s', e.MK(healthLost,1))
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
--[[
    for index, tab in pairs(EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame]) do
        if tab.name==HUD_EDIT_MODE_SETTING_UNIT_FRAME_WIDTH  then-- Frame Width
            EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame][index].minValue=36
        elseif tab.name==HUD_EDIT_MODE_SETTING_UNIT_FRAME_HEIGHT then
            EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame][index].minValue=18
        end
    end]]
end

--###############
--小队, 使用团框架
--###############

local function set_CompactPartyFrame()--CompactPartyFrame.lua
    if not CompactPartyFrame or CompactPartyFrame.moveFrame or not CompactPartyFrame:IsShown() then
        return
    end
    CompactPartyFrame.title:SetText('')
    CompactPartyFrame.title:Hide()
    --新建, 移动, 按钮
    CompactPartyFrame.moveFrame= e.Cbtn(CompactPartyFrame, nil, true, nil, nil, nil, {20,20})
    --CompactPartyFrame.moveFrame:SetFrameStrata('MEDIUM')
    CompactPartyFrame.moveFrame:SetAlpha(0.3)
    CompactPartyFrame.moveFrame:SetPoint('TOP', CompactPartyFrame, 'TOP',0, 10)
    CompactPartyFrame.moveFrame:SetClampedToScreen(true)
    CompactPartyFrame.moveFrame:SetMovable(true)
    CompactPartyFrame.moveFrame:RegisterForDrag('RightButton')
    CompactPartyFrame.moveFrame:SetScript("OnDragStart", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            CompactPartyFrame:StartMoving()
        end
    end)
    CompactPartyFrame.moveFrame:SetScript("OnDragStop", function(self)
        CompactPartyFrame:StopMovingOrSizing()
    end)
    CompactPartyFrame.moveFrame:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=="LeftButton" then
            print(id, addName, (e.onlyChinse and '移动' or NPE_MOVE)..e.Icon.right, 'Alt+'..e.Icon.mid..(e.onlyChinse and '缩放' or UI_SCALE), Save.compactPartyFrameScale or 1)
        end
    end)
    CompactPartyFrame.moveFrame:SetScript("OnLeave", function(self, d)
        ResetCursor()
    end)
    CompactPartyFrame.moveFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            if UnitAffectingCombat('player') then
                print(id, addName, e.onlyChinse and '缩放' or UI_SCALE, '|cnRED_FONT_COLOR:'..(e.onlyChinse and '战斗中' or COMBAT))
            else
                local sacle= Save.compactPartyFrameScale or 1
                if d==1 then
                    sacle=sacle+0.05
                elseif d==-1 then
                    sacle=sacle-0.05
                end
                if sacle>1.5 then
                    sacle=1.5
                elseif sacle<0.5 then
                    sacle=0.5
                end
                print(id, addName, (e.onlyChinse and '缩放' or UI_SCALE), sacle)
                CompactPartyFrame:SetScale(sacle)
                Save.compactPartyFrameScale=sacle
            end
        end
    end)
    if Save.compactPartyFrameScale and Save.compactPartyFrameScale~=1 then
        CompactPartyFrame:SetScale(Save.compactPartyFrameScale)
    end
    CompactPartyFrame:SetClampedToScreen(true)
    CompactPartyFrame:SetMovable(true)
end

--#########
--MirrorTimer
--#########
local elapsedValue=0
local function set_MirrorTimerMixin(self, elapsed)
    if elapsedValue>0.5 then
        if self.value then
            if not self.valueText then
                self.valueText=e.Cstr(self,nil,nil,nil,nil,nil,'RIGHT')
                self.valueText:SetPoint('BOTTOMRIGHT',-7, 4)
            end
            self.valueText:SetText(format('%i', self.value))
        end
        elapsedValue= 0
    else
        elapsedValue= elapsedValue+elapsed
    end
end

--######
--初始化
--######
local function Init()
    set_RaidFrame()--团队

    set_CompactPartyFrame()--小队, 使用团框架
    hooksecurefunc('CompactPartyFrame_UpdateVisibility', set_CompactPartyFrame)

    set_PlayerFrame()--玩家
    set_TargetFrame()--目标
    set_PartyFrame()--小队

    set_UnitFrame_Update()--职业, 图标， 颜色

    if MirrorTimer1 then
        MirrorTimer1:HookScript('OnUpdate', set_MirrorTimerMixin)--MirrorTimer.lua
    end

    C_Timer.After(2, set_LootSpecialization)--拾取专精
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')--拾取专精
panel:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED','player')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(e.onlyChinse and '单位框体' or addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            local sel2=CreateFrame("CheckButton", nil, sel, "InterfaceOptionsCheckButtonTemplate")
            sel2.text:SetText(e.onlyChinse and '团队框体' or HUD_EDIT_MODE_RAID_FRAMES_LABEL)
            --sel2.text:SetTextColor(1,0,0)
            sel2:SetPoint('LEFT', sel.text, 'RIGHT')
            sel2:SetChecked(not Save.notRaidFrame)
            sel2:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinse and '如果出现错误' or ENABLE_ERROR_SPEECH, e.onlyChinse and '请取消' or CANCEL)
                --e.tips:AddDoubleLine(e.onlyChinse and '战斗中, 增加队员' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..' ('..ADD..') '..PLAYERS_IN_GROUP, e.onlyChinse and '错误' or ENABLE_ERROR_SPEECH)
                e.tips:Show()
            end)
            sel2:SetScript('OnLeave', function() e.tips:Hide() end)
            sel2:SetScript('OnMouseDown', function ()
                Save.notRaidFrame= not Save.notRaidFrame and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)


            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                --Save.SetShadowOffset= Save.SetShadowOffset or 1
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_LOOT_SPEC_UPDATED' or event=='PLAYER_SPECIALIZATION_CHANGED' then
        set_LootSpecialization()--拾取专精
    end
end)