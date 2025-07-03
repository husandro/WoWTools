

local function Is_InEditMode()
    return EditModeManagerFrame:IsEditModeActive()-- EditModeManagerFrame:ArePartyFramesForcedShown()
end

local function Get_Unit_Status(unit)
    local atlas,texture
    if UnitHasIncomingResurrection(unit) then--正在复活
        atlas='poi-traveldirections-arrow2'
    elseif UnitIsUnconscious(unit) then--失控
        atlas='cursor_legendaryquest_128'
    elseif UnitIsCharmed(unit) or UnitIsPossessed(unit)  then--被魅惑
        atlas= 'CovenantSanctum-Reservoir-Idle-NightFae-Spiral3'
    elseif UnitIsFeignDeath(unit) then--假死
        texture= 132293

    elseif UnitIsGhost(unit) then
        atlas='poi-soulspiritghost'

    elseif UnitIsDead(unit) then
        atlas= 'BattleBar-SwapPetFrame-DeadIcon'
    end
    return atlas, texture
end



















--目标的目标
local function Create_potFrame(frame)

    local btn= WoWTools_ButtonMixin:Cbtn(frame, {
        isSecure=true,
        size=35,
        isType2=true,
        notBorder=true,
        notTexture=true,
        name= 'WoWToolsParty'..frame.unit..'ToTButton',
    })

    function btn:set_unit()
        local unit=self:GetParent():GetUnit()
        self.unit= unit
        self.tt= btn.unit..'target'

        self.frame.unit= self.unit
        self.frame.tt= self.tt
    end


    btn:SetPoint('LEFT', frame, 'RIGHT', -3, 4)
    btn:SetAttribute('type', 'target')
    btn:SetAttribute('unit', frame.unit..'target')
    btn:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)

    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        if UnitExists(self.tt) then
            GameTooltip:SetUnit(self.tt)
        else
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
            GameTooltip:AddDoubleLine(self.tt, WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '选中目标' or BINDING_HEADER_TARGETING))
        end
        GameTooltip:Show()
    end)


    btn.frame= CreateFrame('Frame', nil, btn)
    btn.frame:SetFrameLevel(btn.frame:GetFrameLevel()-1)
    btn.frame:SetAllPoints()
    btn.frame:Hide()

--目标，也是我的目标
    btn.frame.isPlayerTargetTexture= btn.frame:CreateTexture(nil, 'BORDER')
    btn.frame.isPlayerTargetTexture:SetSize(42,42)
    btn.frame.isPlayerTargetTexture:SetPoint('CENTER',2,-2)
    btn.frame.isPlayerTargetTexture:SetAtlas('UI-HUD-UnitFrame-TotemFrame')
    btn.frame.isPlayerTargetTexture:SetVertexColor(1,0,0)
    btn.frame.isPlayerTargetTexture:Hide()

--目标，图像
    btn.frame.Portrait= btn.frame:CreateTexture(nil, 'BACKGROUND')
    btn.frame.Portrait:SetAllPoints()


    btn.frame.healthLable= WoWTools_LabelMixin:Create(btn.frame, {size=14})
    btn.frame.healthLable:SetPoint('BOTTOMRIGHT')
    btn.frame.healthLable:SetTextColor(1,1,1)

    btn.frame.class= btn.frame:CreateTexture(nil, "ARTWORK")
    btn.frame.class:SetSize(14,14)
    btn.frame.class:SetPoint('TOPRIGHT')



    btn:set_unit()


    function btn.frame:settings()
        local exists2= UnitExists(self.tt)
        if exists2 then

--目标，图像
            if UnitIsUnit(self.tt, self.unit) then--队员，选中他自已
                self.Portrait:SetAtlas(WoWTools_DataMixin.Icon.toLeft)

            elseif UnitIsUnit(self.tt, 'player') then--我
                self.Portrait:SetAtlas('auctionhouse-icon-favorite')
            else
                local atlas, texture=  Get_Unit_Status(self.unit)
                if atlas then
                    self.Portrait:SetAtlas(atlas)

                elseif texture then
                    self.Portrait:SetTexture(texture)

                else
                    local index = GetRaidTargetIndex(self.tt)--标记
                    if index and index>0 and index< 9 then
                        self.Portrait:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
                    else
                        SetPortraitTexture(self.Portrait, self.tt, true)--图像
                    end
                end
            end

--目标，职业
            if UnitIsPlayer(self.tt) then
                self.class:SetAtlas(WoWTools_UnitMixin:GetClassIcon(self.tt, nil, nil, {reAltlas=true}))
            elseif UnitIsBossMob(self.tt) then
                self.class:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
            else
                self.class:SetTexture(0)
            end
--目标，生命条
            local r2,g2,b2= select(2, WoWTools_UnitMixin:GetColor(self.tt))
            self.healthLable:SetTextColor(r2, g2, b2)
--目标，也是我的目标
            self.isPlayerTargetTexture:SetShown(UnitIsUnit(self.tt, 'target'))
        end
--目标是否存在
        self:SetShown(exists2)
    end

 --目标， 生命条
    btn.frame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) +elapsed
        if self.elapsed>0.3 then
            self.elapsed=0
            local cur= UnitHealth(self.tt)
            local max= UnitHealthMax(self.tt) or 0
            if cur and max>0 then
                self.healthLable:SetFormattedText('%i', math.max(cur, 0)/max*100)
            else
                self.healthLable:SetText('')
            end
        end
    end)


    btn:SetScript('OnEvent', function(self)
        self.frame:settings()
    end)

    btn:SetScript('OnShow', function(self)
        self:set_unit()
        self:RegisterEvent('RAID_TARGET_UPDATE')
        self:RegisterUnitEvent('UNIT_TARGET', self.unit)
        self:RegisterUnitEvent('UNIT_FLAGS', self.tt)
        self:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', self.tt)
        self:RegisterEvent('PLAYER_TARGET_CHANGED')
        self:RegisterUnitEvent('INCOMING_RESURRECT_CHANGED', self.tt)
        self.frame:settings()
    end)

    btn:SetScript('OnHide', function(self)
        self.frame.elapsed=nil
        self.frame.healthLable:SetText('')
        self.frame.class:SetTexture(0)
        self.frame.Portrait:SetTexture(0)
        self:UnregisterAllEvents()
    end)

    frame.ToTButton= btn
end

















--队友，施法
local function Create_castFrame(frame)
    local castFrame= CreateFrame("Frame", 'WoWTools'..frame.unit..'ToTCastingFrame', frame)
    castFrame:SetPoint('BOTTOMLEFT', frame.ToTButton, 'BOTTOMRIGHT')
    castFrame:SetSize(20,20)

    castFrame.texture= castFrame:CreateTexture(nil, 'BACKGROUND')
    castFrame.texture:SetAllPoints()
    castFrame.texture:EnableMouse(true)
    WoWTools_ButtonMixin:AddMask(castFrame)
    castFrame.texture:Hide()

    castFrame.texture:SetScript('OnLeave', function(self)
        --GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    castFrame.texture:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        local u= self:GetParent().unit
        local spellID= select(8, UnitChannelInfo(u)) or select(9, UnitCastingInfo(u))
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

    function castFrame:settings()
        local texture= WoWTools_CooldownMixin:SetFrame(self, {unit=self.unit})
        texture= texture or (Is_InEditMode(self) and 4622499) or 0
        self.texture:SetTexture(texture)
        self.texture:SetShown(texture>0)
    end


    castFrame:SetScript('OnEvent', function(self, event, arg1)
        if event=='UNIT_SPELLCAST_SENT' and not UnitIsUnit(self.unit, arg1) then
            return
        end
            self:settings()
    end)

    castFrame:SetScript('OnHide', function(self)
        self.texture:SetTexture(0)
        self:UnregisterAllEvents()
        WoWTools_CooldownMixin:SetFrame(self)
    end)

    castFrame:SetScript('OnShow', function(self)
        self.unit= self:GetParent():GetUnit()
        local events= {--ActionButton.lua
            'UNIT_SPELLCAST_CHANNEL_START',
            'UNIT_SPELLCAST_CHANNEL_UPDATE',
            'UNIT_SPELLCAST_START',
            'UNIT_SPELLCAST_DELAYED',
            'UNIT_SPELLCAST_RETICLE_TARGET',
            'UNIT_SPELLCAST_EMPOWER_START',

            'UNIT_SPELLCAST_INTERRUPTED',
            'UNIT_SPELLCAST_SUCCEEDED',
            'UNIT_SPELLCAST_RETICLE_CLEAR',
            'UNIT_SPELLCAST_FAILED',
            'UNIT_SPELLCAST_FAILED_QUIET',
            'UNIT_SPELLCAST_STOP',
            'UNIT_SPELLCAST_EMPOWER_STOP',
            'UNIT_SPELLCAST_CHANNEL_STOP',
        }
        FrameUtil.RegisterFrameForUnitEvents(self, events, self.unit)
        self:RegisterEvent('UNIT_SPELLCAST_SENT')
        self:settings()
    end)
end














--队伍, 标记, 成员派系
local function Create_raidTargetFrame(frame)
    local raidTargetFrame= CreateFrame("Frame", nil, frame)

    raidTargetFrame.texture= raidTargetFrame:CreateTexture()
    raidTargetFrame.texture:SetSize(12,12)
    raidTargetFrame.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
    raidTargetFrame.texture:SetPoint('RIGHT', frame.PartyMemberOverlay.RoleIcon, 'LEFT')

--标记 TargetFrame.lua
    function raidTargetFrame:set_mark()
        local index
        if Is_InEditMode(self) then
            index=1
        else
            index = GetRaidTargetIndex(self.unit)
            if index and (index<=0 or index>=9) then
                index= nil
            end
        end
        if index then
            SetRaidTargetIconTexture(self.texture, index)
        end
        self.texture:SetShown(index)
    end

--成员派系
    raidTargetFrame.faction=raidTargetFrame:CreateTexture(nil, 'ARTWORK')
    raidTargetFrame.faction:SetSize(14,14)
    raidTargetFrame.faction:SetPoint('TOPLEFT', frame.Portrait)
--成员派系
    function raidTargetFrame:set_faction()
        local atlas
        if Is_InEditMode(self) then
            atlas= WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction]
        else
            local faction= UnitFactionGroup(self.unit)
            if faction and faction~= WoWTools_DataMixin.Player.Faction then
                atlas= WoWTools_DataMixin.Icon[faction]
            end
        end
        if atlas then
            self.faction:SetAtlas(atlas)
        else
            self.faction:SetTexture(0)
        end
    end



    raidTargetFrame:SetScript('OnEvent', function(self, event)
        if event=='RAID_TARGET_UPDATE' then
            self:set_mark()
        elseif event=='UNIT_FACTION' then
            self:set_faction()--成员派系
        end
    end)

    raidTargetFrame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.faction:SetTexture(0)
        self.unit=nil
    end)
    raidTargetFrame:SetScript('OnShow', function(self)
        self.unit= self:GetParent():GetUnit()
        self:RegisterUnitEvent('UNIT_FACTION', self.unit)
        self:RegisterEvent('RAID_TARGET_UPDATE')
        self:set_faction()
        self:set_mark()
    end)
end





















--战斗指示
local function Create_combatFrame(frame)
    local combatFrame= CreateFrame('Frame', nil, frame)
    combatFrame:SetPoint('BOTTOMLEFT', frame.ToTButton, 'RIGHT', 2, 2)
    combatFrame:SetSize(16,16)

    combatFrame.unit= frame:GetUnit()

    combatFrame.texture= combatFrame:CreateTexture()
    combatFrame.texture:SetAllPoints(combatFrame)
    combatFrame.texture:SetAtlas('UI-HUD-UnitFrame-Player-CombatIcon')
    combatFrame.texture:SetVertexColor(1, 0, 0)
    combatFrame.texture:EnableMouse(true)
    combatFrame.texture:Hide()

    combatFrame.texture:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    combatFrame.texture:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddDoubleLine(
            self:GetParent().unit,
            WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    combatFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed>0.3 then
            self.elapsed=0
            self.texture:SetShown(
                UnitAffectingCombat(self.unit) or Is_InEditMode(self)
            )
        end
    end)

    combatFrame:SetScript('OnHide', function(self)
        self.elapsed=nil
    end)

    combatFrame:SetScript('OnShow', function(self)
        self.unit= self:GetParent():GetUnit()
    end)
end










--队友位置
local function Create_positionFrame(frame)

    local Frame= CreateFrame("Frame", nil, frame)
    Frame:SetPoint('LEFT', frame.PartyMemberOverlay.LeaderIcon, 'RIGHT')
    Frame:SetSize(1,1)

--地图，位置
    Frame.map= CreateFrame('Frame', nil, Frame)
    Frame.map.Text= WoWTools_LabelMixin:Create(Frame.map)
    Frame.map.Text:SetPoint('LEFT', Frame)
    Frame.map:Hide()
--距离
    Frame.xy= CreateFrame('Frame', nil, Frame)
    Frame.xy:SetSize(1,1)
    Frame.xy:SetPoint('RIGHT', frame.Portrait, 'LEFT')
    Frame.xy:Hide()
    WoWTools_UnitMixin:SetRangeFrame(Frame.xy)




    Frame.map:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed<=0.3 then
            return
        end
        self.elapsed=0

        local text
        text= ''

--挑战, 分数
        local info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(self.unit)
        if info and info.currentSeasonScore and info.currentSeasonScore>0 then
            text= WoWTools_ChallengeMixin:KeystoneScorsoColor(info.currentSeasonScore, true)
        end

        local mapID= C_Map.GetBestMapForUnit(self.unit)--地图ID
        local mapInfo= mapID and C_Map.GetMapInfo(mapID)
        if mapInfo and mapInfo.name then
            local mapID2= C_Map.GetBestMapForUnit('player')
--在同一地图上
            text= text.. '|A:'..(mapID2== mapID and 'common-icon-checkmark' or 'poi-islands-table')..':0:0|a'
--地图名称
            text= text..WoWTools_TextMixin:CN(mapInfo.name)
        end

--距离
        local distanceSquared, checkedDistance = UnitDistanceSquared(self.unit)
        if distanceSquared and checkedDistance then
            text= text..' '..WoWTools_Mixin:MK(distanceSquared, 0)
        end

        self.Text:SetText(text)
    end)



    function Frame:set_shown()
        local isInInstance= IsInInstance()
        local isInEditMode= Is_InEditMode(self)

        self.map:SetShown(isInEditMode or not isInInstance)
        self.xy:SetShown(isInEditMode or isInInstance)
    end

    Frame:SetScript('OnEvent',  function(self)
        self:set_shown()
    end)

    Frame:SetScript('OnHide', function(self)
        self.map.elapsed=nil
        self.map.unit=nil
        self.map.Text:SetText('')

        self.xy.elapsed= nil
        self.xy.unit=nil
        self.xy.Text:SetText('')
        self.xy.Text2:SetText('')
        self.xy.Text3:SetText('')

        self.unit=nil
        self:UnregisterAllEvents()
    end)

    Frame:SetScript('OnShow', function(self)
        local unit= self:GetParent():GetUnit()
        self.unit= unit
        self.map.unit= unit
        self.xy.unit= unit

        local r,g,b= select(2, WoWTools_UnitMixin:GetColor(unit))
        self.map.Text:SetTextColor(r,g,b)

        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:set_shown()
    end)
end














--队友，死亡
local function Create_deadFrame(frame)

    local deadFrame= CreateFrame('Frame', nil, frame)
    deadFrame:SetPoint("CENTER", frame.Portrait)
    deadFrame:SetFrameLevel(frame:GetFrameLevel()+1)
    deadFrame:SetSize(37,37)
    deadFrame:SetFrameStrata('HIGH')

    deadFrame.texture= deadFrame:CreateTexture()
    deadFrame.texture:SetAllPoints(deadFrame)


    deadFrame.Text= WoWTools_LabelMixin:Create(deadFrame, {mouse=true, color={r=1,g=1,b=1}})
    deadFrame.Text:SetPoint('BOTTOMRIGHT', deadFrame, -2,0)

    deadFrame.Text:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    deadFrame.Text:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        local p= self:GetParent()
        GameTooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '死亡' or DEAD)..' '..p.unit,
            p.dead..' '..(WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '重置' or RESET, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    deadFrame.Text:SetScript('OnMouseDown', function(self)
        self.dead=0
        self:SetAlpha(0.3)
        self:GetParent():settings()
    end)
    deadFrame.Text:SetScript('OnMouseUp', function(self)
        self:SetAlpha(0.5)
    end)


    function deadFrame:settings()
--死亡，次数
        self.Text:SetText(self.dead)
--编辑模式
        if Is_InEditMode(self) then
            self.texture:SetAtlas('QuestLegendaryTurnin')
            return
--没用，连线
        elseif not UnitIsConnected(self.unit) then
            self.texture:SetTexture(0)
            return
        end

        local atlas, texture= Get_Unit_Status(self.unit)

        if atlas then
            self.texture:SetAtlas(atlas)
        else
            self.texture:SetTexture(texture or 0)
        end
    end

    deadFrame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' or event=='CHALLENGE_MODE_START' then
            self.dead= 0
        else
            if UnitIsDeadOrGhost(self.unit) then--死亡，次数
                if not self.deadBool then
                    self.deadBool=true
                    self.dead= self.dead +1
                end
            else
                self.deadBool= nil
            end
        end
        self:settings()
    end)

    deadFrame:SetScript('OnShow', function(self)
        self.dead=0
        self.unit= self:GetParent():GetUnit()
        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:RegisterEvent('CHALLENGE_MODE_START')
        self:RegisterUnitEvent('UNIT_FLAGS', self.unit)
        self:RegisterUnitEvent('UNIT_HEALTH', self.unit)
        self:RegisterUnitEvent('INCOMING_RESURRECT_CHANGED', self.unit)
        self:settings()
    end)
    deadFrame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.Text:SetText('')
        self.dead=nil
        self.unit=nil
        self.deadBool=nil
        self.texture:SetTexture(0)
    end)
end






























--先使用一次，用以Shift+点击，设置焦点功能, Invite.lua
local function Init()--PartyFrame.lua
    if WoWToolsSave['Plus_UnitFrame'].hidePartyFrame then
        return
    end

    PartyFrame.Background:SetWidth(124)--144

    --local showPartyFrames = PartyFrame:ShouldShow();
    for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        frame.Texture:SetAtlas('UI-HUD-UnitFrame-Party-PortraitOn-Status')--PartyFrameTemplates.xml
        do
            Create_potFrame(frame)--目标的目标
        end
        Create_castFrame(frame)--队友，施法
        Create_raidTargetFrame(frame)--队伍, 标记, 成员派系
        Create_combatFrame(frame)--战斗指示
        Create_positionFrame(frame)--队友位置
        Create_deadFrame(frame)--队友，死亡

        hooksecurefunc(frame, 'UpdateAssignedRoles', function(self)--隐藏, DPS 图标
            if UnitGroupRolesAssigned(self:GetUnit())== 'DAMAGER' then
                self.PartyMemberOverlay.RoleIcon:SetShown(false)
            end
        end)

        hooksecurefunc(frame, 'UpdateMember', function(self)
            local unit= frame:GetUnit() or frame.unit
            local r,g,b= select(2, WoWTools_UnitMixin:GetColor(unit))

        --外框
            self.Texture:SetVertexColor(r, g, b)
            self.PortraitMask:SetVertexColor(r, g, b)
        end)
    end


    Init=function()end
end
--[[
 hooksecurefunc(PartyFrame, 'UpdatePartyFrames', function(unitFrame)
    for memberFrame in unitFrame.PartyMemberFramePool:EnumerateActive() do
        set_memberFrame(memberFrame)
    end
end)
]]


function WoWTools_UnitMixin:Init_PartyFrame()--小队
    Init()
end