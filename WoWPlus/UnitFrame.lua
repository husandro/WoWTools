local id, e = ...
local addName= UNITFRAME_LABEL
local Save={raidFrameScale=0.85}--{SetShadowOffset= 1}
local panel=CreateFrame("Frame")
local R,G,B= GetClassColor(UnitClassBase('player'))

local function set_SetShadowOffset(self)--设置, 阴影
    if self then
        self:SetShadowOffset(1, -1)
    end
end
local function set_SetTextColor(self, r, g, b)--设置, 字体
    if self and self:IsShown() and r and g and b then
        self:SetTextColor(r, g, b)
    end
end
local function set_SetRaidTarget(texture, unit)--设置, 标记 TargetFrame.lua
    if texture and unit then
        local index = GetRaidTargetIndex(unit)
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
    set_SetShadowOffset(PlayerLevelText)

    --施法条
    PlayerCastingBarFrame:HookScript('OnShow', function(self)--图标
        self.Icon:SetShown(true)
    end)
    set_SetTextColor(PlayerCastingBarFrame.Text, R,G,B)--颜色
    PlayerCastingBarFrame.castingText=e.Cstr(PlayerCastingBarFrame, nil, nil, nil, {R,G,B}, nil, 'RIGHT')
    PlayerCastingBarFrame.castingText:SetDrawLayer('OVERLAY', 2)
    PlayerCastingBarFrame.castingText:SetPoint('RIGHT', PlayerCastingBarFrame.ChargeFlash, 'RIGHT')
    PlayerCastingBarFrame:HookScript('OnUpdate', function(self, elapsed)--玩家, 施法, 时间
        if self.maxValue and self.value then
            local value=self.maxValue-self.value
            if value>=3 then
                self.castingText:SetFormattedText('%i', value)
            else
                self.castingText:SetFormattedText('%.01f', value)
            end
        else
            self.castingText:SetText('')
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
                levelText:SetTextColor(r,g,b)
            end
        end
    end)
end

--####
--宠物
--####
local function set_PetFrame()
    if PetHitIndicator then
        PetHitIndicator:ClearAllPoints()
        PetHitIndicator:SetPoint('TOPLEFT', PetPortrait or PetHitIndicator:GetParent(), 'BOTTOMLEFT')
    end
    if PlayerHitIndicator then
        PlayerHitIndicator:ClearAllPoints()
        PlayerHitIndicator:SetPoint('BOTTOMLEFT', (PlayerFrame.PlayerFrameContainer and PlayerFrame and PlayerFrame.PlayerFrameContainer.PlayerPortrait) or  PlayerHitIndicator:GetParent(), 'TOPLEFT')
    end
end

--####
--小队
--####
local function set_PartyFrame()--PartyFrame.lua
    hooksecurefunc(PartyFrame, 'UpdatePartyFrames', function(self)
        if not ShouldShowPartyFrames() then
            return
        end
        for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
            local exists= UnitExists(memberFrame.unit)
            memberFrame.PartyMemberOverlay.unit= memberFrame.unit or memberFrame:GetUnit()
            memberFrame.PartyMemberOverlay.exists= exists
            if not memberFrame.PartyMemberOverlay.RaidTargetIcon and exists then
                memberFrame.PartyMemberOverlay.RaidTargetIcon= memberFrame:CreateTexture(nil,'OVERLAY', nil, 7)--队伍, 标记
                memberFrame.PartyMemberOverlay.RaidTargetIcon:SetPoint('RIGHT', memberFrame.PartyMemberOverlay.RoleIcon, 'LEFT')
                memberFrame.PartyMemberOverlay.RaidTargetIcon:SetSize(14,14)
                memberFrame.PartyMemberOverlay.RaidTargetIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
                set_SetRaidTarget(memberFrame.PartyMemberOverlay.RaidTargetIcon, memberFrame.unit)--设置,标记

                memberFrame.PartyMemberOverlay.portrait= CreateFrame("Frame")--目标的目标
                memberFrame.PartyMemberOverlay.portrait:SetPoint('LEFT', memberFrame, 'RIGHT')
                memberFrame.PartyMemberOverlay.portrait:SetSize(38,38)

                memberFrame.PartyMemberOverlay:RegisterEvent('RAID_TARGET_UPDATE')--更新,标记
                memberFrame.PartyMemberOverlay:HookScript('OnEvent', function (self2, event)
                    if event=='RAID_TARGET_UPDATE' and self2.exists then
                        set_SetRaidTarget(self2.RaidTargetIcon, self2.unit);
                    end
                end)
                hooksecurefunc(memberFrame, 'UpdateAssignedRoles', function(self2)--隐藏, DPS 图标
                    local icon = self2.PartyMemberOverlay.RoleIcon;
                    local role = UnitGroupRolesAssigned(self2.unit or self2.PartyMemberOverlay.unit or self2:GetUnit())
                    if role== 'DAMAGER' then
                        icon:SetShown(false)
                    end
                end)
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
            self.classTexture=self:CreateTexture(nil,'OVERLAY', nil, 7)
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

            if self.healthbar then
                set_SetShadowOffset(self.healthbar.LeftText)--字本, 阴影
                set_SetShadowOffset(self.healthbar.TextString)
                set_SetShadowOffset(self.healthbar.RightText)
            end
            if self.manabar then
                set_SetShadowOffset(self.manabar.LeftText)
                set_SetShadowOffset(self.manabar.TextString)
                set_SetShadowOffset(self.manabar.RightText)
            end
            set_SetShadowOffset(self.name)
        end
        self.classTexture:SetAtlas(class or 0)

        if self.name then
            set_SetTextColor(self.name, r,g,b)--名称, 颜色
            if unit=='pet' or UnitIsUnit('pet',unit) then
                self.name:SetText('')
            elseif isParty then
                self.name:SetText(UnitName(unit))
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
    --去掉生命条 %
    --############
    --extStatusBar.lua
    hooksecurefunc('TextStatusBar_UpdateTextStringWithValues', function(statusFrame, textString, value, valueMin, valueMax)
        if value and value>0 then
            if textString and textString:IsShown() then
                local text= textString:GetText()
                text= text:gsub('%%', '')
                textString:SetText(text)
            elseif statusFrame.LeftText and statusFrame.LeftText:IsShown() then
                local text= statusFrame.LeftText:GetText()
                text= text:gsub('%%', '')
                statusFrame.LeftText:SetText(text)
            end
        end
    end)
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
end

--####
--团队
--####
local function set_RaidFrame()--设置,团队 CompactUnitFrame.lua

    hooksecurefunc('CompactUnitFrame_SetUnit', function(frame, unit)--队伍, 标记
        if unit and not frame.RaidTargetIcon and frame.name then
            frame.RaidTargetIcon= frame:CreateTexture(nil,'OVERLAY', nil, 7)
            frame.RaidTargetIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
            frame.RaidTargetIcon:SetPoint('TOPRIGHT')
            frame.RaidTargetIcon:SetSize(13,13)
            frame:RegisterEvent("RAID_TARGET_UPDATE")
            set_SetRaidTarget(frame.RaidTargetIcon, unit)
        end
    end)
    hooksecurefunc('CompactUnitFrame_UpdateUnitEvents', function(frame)
        frame:RegisterEvent("RAID_TARGET_UPDATE")
    end)
    hooksecurefunc('CompactUnitFrame_UnregisterEvents', function(frame)
        frame:UnregisterEvent("RAID_TARGET_UPDATE")
    end)
    hooksecurefunc('CompactUnitFrame_OnEvent', function(self, event, ...)
        if event=='RAID_TARGET_UPDATE' and self.RaidTargetIcon and self.unit then
            set_SetRaidTarget(self.RaidTargetIcon, self.unit);
        end
    end)

    hooksecurefunc('CompactUnitFrame_UpdateRoleIcon', function(frame)--隐藏, DPS，图标 
        if not frame.roleIcon or not frame.optionTable.displayRaidRoleIcon or UnitInVehicle(frame.unit) or UnitHasVehicleUI(frame.unit) then
            return;
        end
        local raidID = UnitInRaid(frame.unit);
        if raidID then
            if select(12, GetRaidRosterInfo(raidID))=='DAMAGER' then
                frame.roleIcon:SetShown(false);
            end
        else
            if UnitGroupRolesAssigned(frame.unit) == "DAMAGER"then
                frame.roleIcon:SetShown(false);
            end
        end
    end)

    hooksecurefunc('CompactUnitFrame_UpdateName', function(frame)--修改, 名字
        if not frame.name or (frame.UpdateNameOverride and frame:UpdateNameOverride()) or not ShouldShowName(frame) then
            return;
        end
        if UnitIsUnit('player',frame.unit) then
            frame.name:SetText(e.Icon.player)
        else
            local name= frame.name:GetText()
            if name then
                name= name:match('(.-)%-') or name
                name= e.WA_Utf8Sub(name, 4, 8)
                frame.name:SetText(name)
            end
        end
    end)

    hooksecurefunc('CompactUnitFrame_UpdateStatusText', function(frame)--去掉,生命条, %
        if not frame.statusText or not frame.statusText:IsShown() or frame.optionTable.healthText ~= "perc" then
            return
        end
            local text= frame.statusText:GetText()
            if text then
                text= text:gsub('%%', '')
                frame.statusText:SetText(text)
            end
    end)
    hooksecurefunc('CompactRaidGroup_InitializeForGroup', function(frame, groupIndex)--处理, 队伍号
        frame.title:SetText('|A:'..e.Icon.number..groupIndex..':0:0|a')
    end)

    --新建, 移动, 按钮
    CompactRaidFrameContainer.moveFrame= e.Cbtn(CompactRaidFrameContainer, nil, true, nil, nil, nil, {20,20})
    CompactRaidFrameContainer.moveFrame:SetAlpha(0.3)
    CompactRaidFrameContainer.moveFrame:SetPoint('TOPRIGHT', CompactRaidFrameContainer, 'TOPLEFT',-2, -13)
    CompactRaidFrameContainer.moveFrame:SetClampedToScreen(true)
    CompactRaidFrameContainer.moveFrame:SetMovable(true)
    CompactRaidFrameContainer.moveFrame:RegisterForDrag('RightButton')
    CompactRaidFrameContainer.moveFrame:SetScript("OnDragStart", function(self,d)
        if d=='RightButton' and not IsMetaKeyDown() then
            CompactRaidFrameContainer:StartMoving()
        end
    end)
    CompactRaidFrameContainer.moveFrame:SetScript("OnDragStop", function(self)
        CompactRaidFrameContainer:StopMovingOrSizing()
    end)
    CompactRaidFrameContainer.moveFrame:SetScript("OnMouseDown", function(self, d)
        print(id, addName, (e.onlyChinse and '移动' or NPE_MOVE)..e.Icon.right, 'Alt+'..e.Icon.mid..(e.onlyChinse and '缩放' or UI_SCALE), Save.raidFrameScale or 1)
        if d=='RightButton' and not IsMetaKeyDown() then
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
                CompactRaidFrameContainer:SetScale(sacle)
                Save.raidFrameScale=sacle
            end
        end
    end)
    if Save.raidFrameScale and Save.raidFrameScale~=1 then
        CompactRaidFrameContainer:SetScale(Save.raidFrameScale)
    end
    CompactRaidFrameContainer:SetClampedToScreen(true)
    CompactRaidFrameContainer:SetMovable(true)

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
end

--###############
--小队, 使用团框架
--###############
local function set_CompactPartyFrame()--CompactPartyFrame.lua
    if not CompactPartyFrame or CompactPartyFrame.moveFrame then
        return
    end
    CompactPartyFrame.title:SetText('')

    --新建, 移动, 按钮
    CompactPartyFrame.moveFrame= e.Cbtn(CompactPartyFrame, nil, true, nil, nil, nil, {15,15})
    CompactPartyFrame.moveFrame:SetAlpha(0.3)
    CompactPartyFrame.moveFrame:SetPoint('TOPLEFT', CompactPartyFrame, 'TOPLEFT',0,2)
    CompactPartyFrame.moveFrame:SetClampedToScreen(true)
    CompactPartyFrame.moveFrame:SetMovable(true)
    CompactPartyFrame.moveFrame:RegisterForDrag('RightButton')
    CompactPartyFrame.moveFrame:SetScript("OnDragStart", function(self,d)
        if d=='RightButton' and not IsMetaKeyDown() then
            CompactPartyFrame:StartMoving()
        end
    end)
    CompactPartyFrame.moveFrame:SetScript("OnDragStop", function(self)
        CompactPartyFrame:StopMovingOrSizing()
    end)
    CompactPartyFrame.moveFrame:SetScript("OnMouseDown", function(self, d)
        print(id, addName, (e.onlyChinse and '移动' or NPE_MOVE)..e.Icon.right, 'Alt+'..e.Icon.mid..(e.onlyChinse and '缩放' or UI_SCALE), Save.compactPartyFrameScale or 1)
        if d=='RightButton' and not IsMetaKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
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

--######
--初始化
--######
local function Init()
    set_RaidFrame()--团队

    set_CompactPartyFrame()--小队, 使用团框架
    hooksecurefunc('CompactPartyFrame_UpdateVisibility', set_CompactPartyFrame)

    set_PlayerFrame()--玩家
    set_TargetFrame()--目标
    set_PetFrame()--宠物
    set_PartyFrame()--小队
    set_UnitFrame_Update()--职业, 图标， 颜色
    C_Timer.After(2, function()
        set_LootSpecialization()--拾取专精
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

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

            if not Save.disabled then
                --Save.SetShadowOffset= Save.SetShadowOffset or 1
                Init()
            end
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