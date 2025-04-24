--小队
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








--目标的目标
local function Create_potFrame(frame)
    local unit= frame.unit or frame:GetUnit()


    local btn= WoWTools_ButtonMixin:Cbtn(frame, {isSecure=true, size=35, isType2=true})
    btn:SetPoint('LEFT', frame, 'RIGHT', -3, 4)
    btn:SetAttribute('type', 'target')
    btn:SetAttribute('unit', unit..'target')
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        if UnitExists(self.unit) then
            GameTooltip:SetUnit(self.unit)
        else
            GameTooltip:AddDoubleLine(self.unit, WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '选中目标' or BINDING_HEADER_TARGETING))
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        end
        GameTooltip:Show()
    end)
    btn.unit= unit..'target'

    btn.frame=CreateFrame('Frame', nil, btn)
    btn.frame:SetFrameLevel(btn.frame:GetFrameLevel()-1)
    btn.frame:SetAllPoints()
    btn.frame:Hide()

    --[[btn.frame.isPlayerTargetTexture= btn.frame:CreateTexture(nil, 'BORDER')
    btn.frame.isPlayerTargetTexture:SetSize(42,42)
    btn.frame.isPlayerTargetTexture:SetPoint('CENTER',2,-2)
    btn.frame.isPlayerTargetTexture:SetAtlas('UI-HUD-UnitFrame-TotemFrame')]]
    btn.frame.isPlayerTargetTexture= btn.border
    btn.frame.isPlayerTargetTexture:SetVertexColor(1,0,0)

    --[[btn.frame.Portrait= btn.frame:CreateTexture(nil, 'BACKGROUND')--队友，目标，图像
    btn.frame.Portrait:SetAllPoints()]]
    btn.frame.Portrait= btn.texture


    btn.frame.healthLable= WoWTools_LabelMixin:Create(btn.frame, {size=14})
    btn.frame.healthLable:SetPoint('BOTTOMRIGHT')
    btn.frame.healthLable:SetTextColor(1,1,1)

    btn.frame.class= btn.frame:CreateTexture(nil, "ARTWORK")
    btn.frame.class:SetSize(14,14)
    btn.frame.class:SetPoint('TOPRIGHT')

    function btn.frame:set_settings()
        local exists2= UnitExists(self.unit)
        --if self.unit then
            if self.isPlayer then
                SetPortraitTexture(self.Portrait, self.unit, true)--图像
            elseif UnitIsUnit(self.isSelfUnit, self.unit) then--队员，选中他自已
                self.Portrait:SetAtlas(WoWTools_DataMixin.Icon.toLeft)
            elseif UnitIsUnit(self.unit, 'player') then--我
                self.Portrait:SetAtlas('auctionhouse-icon-favorite')
            elseif UnitIsDeadOrGhost(self.unit) then--死亡
                self.Portrait:SetAtlas('xmarksthespot')
            else
                local index = GetRaidTargetIndex(self.unit)
                if index and index>0 and index< 9 then--标记
                    self.Portrait:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
                else
                    SetPortraitTexture(self.Portrait, self.unit, true)--图像
                end
            end

            if UnitIsPlayer(self.unit) then
                self.class:SetAtlas(WoWTools_UnitMixin:GetClassIcon(nil, self.unit, nil, true))
            elseif UnitIsBossMob(self.unit) then
                self.class:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
            else
                self.class:SetTexture(0)
            end

            local r2,g2,b2= select(2, WoWTools_UnitMixin:GetColor(self.unit))
            self.healthLable:SetTextColor(r2, g2, b2)
        --end
        self.isPlayerTargetTexture:SetShown(exists2 and UnitIsUnit(self.unit, 'target'))
        self:SetShown(exists2)
    end

    function btn.frame:set_event()
        self:RegisterEvent('RAID_TARGET_UPDATE')
        self:RegisterUnitEvent('UNIT_TARGET', self.unit)
        self:RegisterUnitEvent('UNIT_FLAGS', self.unit..'target')
        self:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', self.unit..'target')
        self:RegisterEvent('PLAYER_TARGET_CHANGED')
    end
    btn.frame:SetScript('OnEvent', function (self)
        self:set_event()
    end)


    --队友， 目标， 生命条
    btn.frame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) +elapsed
        if self.elapsed>0.5 then
            self.elapsed=0
            local cur= UnitHealth(self.unit) or 0
            local max= UnitHealthMax(self.unit)
            cur= cur<0 and 0 or cur
            if max and max>0 then
                local value= cur/max*100
                self.healthLable:SetFormattedText('%i', value)
            end
        end
    end)

    btn.frame:SetScript('OnHide', function(self)
        self.elapsed=nil
        self.healthLable:SetText('')
        self.class:SetTexture(0)
        self.Portrait:SetTexture(0)
    end)

    frame.potFrame= btn
end
















--队友，施法
local function Create_castFrame(frame)
    local castFrame= CreateFrame("Frame", nil, frame)
    castFrame:SetPoint('BOTTOMLEFT', frame.potFrame, 'BOTTOMRIGHT')
    castFrame:SetSize(20,20)

    castFrame.texture= castFrame:CreateTexture(nil,'BACKGROUND')
    castFrame.texture:SetAllPoints()

    castFrame:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    castFrame:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        local spellID= select(8, UnitChannelInfo(self.unit)) or select(9, UnitCastingInfo(self.unit))
        if spellID then
            GameTooltip:SetSpellByID(spellID)
        else
            GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '队员' or PLAYERS_IN_GROUP)..' '..(self.unit or ''), WoWTools_DataMixin.onlyChinese and '施法条' or HUD_EDIT_MODE_CAST_BAR_LABEL)
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    function castFrame:set_settings()
        local texture= WoWTools_CooldownMixin:SetFrame(self, {unit=self.unit})
        self.texture:SetTexture(texture or 0)
    end
    castFrame:SetScript('OnEvent', function(self, event, arg1)
        if event=='UNIT_SPELLCAST_SENT' and not UnitIsUnit(self.unit, arg1) then
            return
        end
        self:set_settings()
    end)
    castFrame:SetScript('OnHide', function(self)
        self.texture:SetTexture(0)
        WoWTools_CooldownMixin:SetFrame(self)
    end)

    frame.castFrame= castFrame
end














--队伍, 标记, 成员派系
local function Create_raidTargetFrame(frame)
    local raidTargetFrame= CreateFrame("Frame", nil, frame)
    raidTargetFrame:SetSize(14,14)
    raidTargetFrame:SetPoint('RIGHT', frame.PartyMemberOverlay.RoleIcon, 'LEFT')
    raidTargetFrame.texture= raidTargetFrame:CreateTexture()
    raidTargetFrame.texture:SetAllPoints(raidTargetFrame)
    raidTargetFrame.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')

    --成员派系
    raidTargetFrame.faction=raidTargetFrame:CreateTexture(nil, 'ARTWORK')
    raidTargetFrame.faction:SetSize(14,14)
    raidTargetFrame.faction:SetPoint('TOPLEFT', frame.Portrait)

    function raidTargetFrame:set_faction()
        local faction= UnitFactionGroup(self.unit)
        local atlas
        if faction~= WoWTools_DataMixin.Player.Faction or self.isPlayer then
            atlas= WoWTools_DataMixin.Icon[faction]
        end
        if atlas then
            self.faction:SetAtlas(atlas)
        else
            self.faction:SetTexture(0)
        end
    end

    raidTargetFrame:SetScript('OnEvent', function(self, event)
        if event=='RAID_TARGET_UPDATE' then
            set_RaidTarget(self.texture, self.unit)--队伍, 标记
        elseif event=='UNIT_FACTION' then
            self:set_faction()--成员派系
        end
    end)


    frame.raidTargetFrame= raidTargetFrame
end





















--战斗指示
local function Create_combatFrame(frame)
    local combatFrame= CreateFrame('Frame', nil, frame)
    combatFrame:SetPoint('BOTTOMLEFT', frame.potFrame, 'RIGHT', 2, 2)
    combatFrame:SetSize(16,16)
    combatFrame:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    combatFrame:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(self.unit, WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    combatFrame.texture= combatFrame:CreateTexture()
    combatFrame.texture:SetAllPoints(combatFrame)
    combatFrame.texture:SetAtlas('UI-HUD-UnitFrame-Player-CombatIcon')
    combatFrame.texture:SetVertexColor(1, 0, 0)
    combatFrame.texture:SetShown(false)
    combatFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed>0.3 then
            self.elapsed=0
            self.texture:SetShown(UnitAffectingCombat(self.unit) or self.isPlayer)
        end
    end)

    combatFrame:SetScript('OnHide', function(self)
        self.elapsed=nil
    end)

    frame.combatFrame= combatFrame
end










--队友位置
local function Create_positionFrame(frame)
    local positionFrame= CreateFrame("Frame", nil, frame)
    positionFrame:Hide()
    positionFrame:SetPoint('LEFT', frame.PartyMemberOverlay.LeaderIcon, 'RIGHT')
    positionFrame:SetSize(1,1)
    positionFrame.Text= WoWTools_LabelMixin:Create(positionFrame)
    positionFrame.Text:SetPoint('LEFT')

    function positionFrame:set_shown()
        self:SetShown(not IsInInstance() and not UnitAffectingCombat('player') or self.isPlayer)
    end

    positionFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed>0.3 then
            self.elapsed=0
            local mapID= C_Map.GetBestMapForUnit(self.unit)--地图ID
            local mapInfo= mapID and C_Map.GetMapInfo(mapID)
            local text
            local distanceSquared, checkedDistance = UnitDistanceSquared(self.unit)
            if distanceSquared and checkedDistance then
                text= WoWTools_Mixin:MK(distanceSquared, 0)
            end
            if mapInfo and mapInfo.name then
                text= (text and text..' ' or '')..WoWTools_TextMixin:CN(mapInfo.name)
                local mapID2= C_Map.GetBestMapForUnit('player')
                if mapID2== mapID then
                    text= format('|A:%s:0:0|a', 'common-icon-checkmark')..text
                end
            end
            self.Text:SetText(text or '')
        end
    end)



    function positionFrame:set_event()
        if not IsInInstance() and UnitExists(self.unit) or self.isPlayer then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        else
            self:UnregisterEvent('PLAYER_REGEN_DISABLED')
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end

    positionFrame:RegisterEvent('LOADING_SCREEN_DISABLED')
    positionFrame:SetScript('OnEvent',  positionFrame.set_shown)
    positionFrame:SetScript('OnHide', function(self)
        self:set_event()
        self.elapsed=nil
        self.Text:SetText('')
    end)
    positionFrame:SetScript('OnShow', positionFrame.set_event)

    frame.positionFrame= positionFrame
end














--队友，死亡
local function Create_deadFrame(frame)
    --local unit= frame.unit or frame:GetUnit()

    local deadFrame= CreateFrame('Frame', nil, frame)
    deadFrame:SetPoint("CENTER", frame.Portrait)
    deadFrame:SetFrameLevel(frame:GetFrameLevel()+1)
    deadFrame:SetSize(37,37)
    deadFrame:SetFrameStrata('HIGH')

    deadFrame.texture= deadFrame:CreateTexture()
    deadFrame.texture:SetAllPoints(deadFrame)

    --死亡，次数
    deadFrame.dead=0
    deadFrame.Text= WoWTools_LabelMixin:Create(deadFrame, {mouse=true, color={r=1,g=1,b=1}})
    deadFrame.Text:SetPoint('BOTTOMRIGHT', deadFrame, -2,0)
    deadFrame.Text:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    deadFrame.Text:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '死亡' or DEAD)..' '..(self.unit or ''),
                format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, self:GetParent().dead or 0 , WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
        )
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)


    function deadFrame:set_settings()
        local atlas,texture
        if UnitIsConnected(self.unit) then
            local isDead= UnitIsDead(self.unit)
            local isGhost= UnitIsGhost(self.unit)
            if isDead or isGhost then--死亡，次数
                if not self.deadBool then
                    self.deadBool=true
                    self.dead= self.dead +1
                end
            else
                self.deadBool= nil
            end
            if UnitHasIncomingResurrection(self.unit) then--正在复活
                atlas='poi-traveldirections-arrow2'
            elseif UnitIsUnconscious(self.unit) then--失控
                atlas='cursor_legendaryquest_128'
            elseif UnitIsCharmed(self.unit) or UnitIsPossessed(self.unit)  then--被魅惑
                atlas= 'CovenantSanctum-Reservoir-Idle-NightFae-Spiral3'
            elseif UnitIsFeignDeath(self.unit) then--假死
                texture= 132293
            elseif isDead then
                atlas= 'xmarksthespot'
            elseif isGhost then
                atlas='poi-soulspiritghost'
            end
        end
        if atlas then
            self.texture:SetAtlas(atlas)
        else
            self.texture:SetTexture(texture or 0)
        end
        if self.isPlayer then
            self.Text:SetText(10)
        else
            self.Text:SetText(self.dead>0 and self.dead or '')
        end
    end
    function deadFrame:set_event()
        self:RegisterEvent('LOADING_SCREEN_DISABLED')
        self:RegisterEvent('CHALLENGE_MODE_START')
        self:RegisterUnitEvent('UNIT_FLAGS', self.unit)
        self:RegisterUnitEvent('UNIT_HEALTH', self.unit)
    end
    deadFrame:SetScript('OnEvent', function(self, event)
        if event=='LOADING_SCREEN_DISABLED' or event=='CHALLENGE_MODE_START' then
            self.dead= 0
        end
        self:set_settings()
    end)
    deadFrame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.dead= 0
        self.Text:SetText('')
    end)
    deadFrame:SetScript('OnShow', function(self)
        self:set_event()
    end)



    frame.deadFrame= deadFrame
end


















local function set_memberFrame(frame)
    if not PartyFrame:ShouldShow() then
        return
    end

    local unit= frame.unit or frame:GetUnit()
    local isPlayer= unit=='player'
    local exists= UnitExists(unit)
    local r,g,b= select(2, WoWTools_UnitMixin:GetColor(unit))

--外框
    frame.Texture:SetVertexColor(r, g, b)
    frame.PortraitMask:SetVertexColor(r, g, b)

--目标的目标
    frame.potFrame.frame.unit= unit..'target'
    frame.potFrame.frame.isSelfUnit= unit
    frame.potFrame.frame.isPlayer= isPlayer
    frame.potFrame.frame:UnregisterAllEvents()
    if exists then
        frame.potFrame.frame:set_event()
    end
    frame.potFrame.frame:set_settings()


--队友，施法
    frame.castFrame:UnregisterAllEvents()
    if exists then
        local events= {--ActionButton.lua
            'UNIT_SPELLCAST_CHANNEL_START',
            'UNIT_SPELLCAST_CHANNEL_STOP',
            'UNIT_SPELLCAST_CHANNEL_UPDATE',
            'UNIT_SPELLCAST_START',
            'UNIT_SPELLCAST_DELAYED',
            'UNIT_SPELLCAST_FAILED',
            'UNIT_SPELLCAST_FAILED_QUIET',
            'UNIT_SPELLCAST_INTERRUPTED',
            'UNIT_SPELLCAST_SUCCEEDED',
            'UNIT_SPELLCAST_STOP',
            'UNIT_SPELLCAST_RETICLE_TARGET',
            'UNIT_SPELLCAST_RETICLE_CLEAR',
            'UNIT_SPELLCAST_EMPOWER_START',
            'UNIT_SPELLCAST_EMPOWER_STOP',
        }
        FrameUtil.RegisterFrameForUnitEvents(frame.castFrame, events, unit)
        frame.castFrame:RegisterEvent('UNIT_SPELLCAST_SENT')
    end
    frame.castFrame.unit= unit
    if isPlayer then
        frame.castFrame.texture:SetAtlas('Relic-Life-TraitGlow')
    else
        frame.castFrame.texture:SetTexture(0)
    end


--队伍, 标记, 成员派系
    frame.raidTargetFrame.unit= unit
    frame.raidTargetFrame.isPlayer= isPlayer
    frame.raidTargetFrame:UnregisterAllEvents()
    if exists then
        frame.raidTargetFrame:RegisterUnitEvent('UNIT_FACTION', unit)
        frame.raidTargetFrame:RegisterEvent('RAID_TARGET_UPDATE')
    end
    if isPlayer then
        SetRaidTargetIconTexture(frame.raidTargetFrame.texture, 1)
    else
        set_RaidTarget(frame.raidTargetFrame.texture, frame.raidTargetFrame.unit)--队伍, 标记
    end
    frame.raidTargetFrame:set_faction()--成员派系


--战斗指示
    frame.combatFrame.unit= unit
    frame.combatFrame.isPlayer= isPlayer
    frame.combatFrame:SetShown(exists)

--队友位置
    frame.positionFrame.isPlayer= isPlayer
    frame.positionFrame.Text:SetTextColor(r, g, b)
    frame.positionFrame.unit= unit
    frame.positionFrame:set_event()
    frame.positionFrame:set_shown()


--队友，死亡
    frame.deadFrame.isPlayer= isPlayer
    frame.deadFrame.unit= unit
    if exists then
        frame.deadFrame:set_event()
    end
    frame.deadFrame:set_settings()
    
end


















--先使用一次，用以Shift+点击，设置焦点功能, Invite.lua
local function Init()--PartyFrame.lua
    PartyFrame.Background:SetWidth(122)--144

    for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        frame.Texture:SetAtlas('UI-HUD-UnitFrame-Party-PortraitOn-Status')--PartyFrameTemplates.xml

        Create_potFrame(frame)--目标的目标
        Create_castFrame(frame)--队友，施法
        Create_raidTargetFrame(frame)--队伍, 标记, 成员派系
        Create_combatFrame(frame)--战斗指示
        Create_positionFrame(frame)--队友位置
        Create_deadFrame(frame)--队友，死亡

        hooksecurefunc(frame, 'UpdateAssignedRoles', function(self)--隐藏, DPS 图标
            self.PartyMemberOverlay.RoleIcon:SetShown(UnitGroupRolesAssigned(self.unit)~= 'DAMAGER')
        end)

        set_memberFrame(frame)

        hooksecurefunc(frame, 'UpdateMember', set_memberFrame)
    end


    Init=function()end
end



function WoWTools_UnitMixin:Init_PartyFrame()--小队
    Init()
end