local function Save()
    return WoWToolsSave['Plus_UnitFrame'] or {}
end


local function Is_InEditMode()
    if EditModeManagerFrame then
        return EditModeManagerFrame:IsEditModeActive()-- EditModeManagerFrame:ArePartyFramesForcedShown()
    end
end

--[[local function Get_Unit_Status(unit)
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
end]]



















--目标的目标
local function Create_potFrame(frame)
    local unit= frame.unit

    frame.ToTButton= CreateFrame('Button', nil, frame, 'WoWToolsButton2Template SecureActionButtonTemplate')
    frame.ToTButton:SetSize(35,35)
    --[[WoWTools_ButtonMixin:Cbtn(frame, {
        isSecure=true,
        size=35,
        isType2=true,
        notBorder=true,
        notTexture=true,
        name= 'WoWTools'..unit..'ToTButton',
    })]]

    frame.ToTButton.unit= unit
    frame.ToTButton.target= unit..'target'


    frame.ToTButton:SetPoint('LEFT', frame, 'RIGHT', -3, 4)
    frame.ToTButton:SetAttribute('type', 'target')
    frame.ToTButton:SetAttribute('unit', frame.ToTButton.target)
    frame.ToTButton:SetScript('OnLeave', GameTooltip_Hide)

    frame.ToTButton:SetScript('OnEnter', function(self)
        --[[if not WoWTools_UnitMixin:UnitExists(self.target) then
            return
        end]]
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetUnit(self.target)
        GameTooltip:Show()
    end)


--目标，图像
    frame.ToTButton.Portrait= frame.ToTButton:CreateTexture(nil, 'BORDER')
    WoWTools_ButtonMixin:AddMask(frame.ToTButton, true, frame.ToTButton.Portrait)
    frame.ToTButton.Portrait:SetAllPoints()


    --[[frame.ToTButton.healthLable= WoWTools_LabelMixin:Create(frame.ToTButton, {size=14})
    frame.ToTButton.healthLable:SetPoint('BOTTOMRIGHT')
    frame.ToTButton.healthLable:SetTextColor(1,1,1)

    frame.ToTButton.class= frame.ToTButton:CreateTexture(nil, "ARTWORK")
    frame.ToTButton.class:SetSize(14,14)
    frame.ToTButton.class:SetPoint('TOPRIGHT')

 --目标， 生命条
    frame.ToTButton:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) +elapsed
        if self.elapsed>0.3 then
            self.elapsed=0
            self.healthLable:SetFormattedText('%i', UnitHealth(self.target)/UnitHealthMax(self.target)*100)
        end
    end)]]

    function frame.ToTButton:settings()
        SetPortraitTexture(self.Portrait, self.target)--图像
    end

    frame.ToTButton:SetScript('OnEvent', frame.ToTButton.settings)

    frame.ToTButton:RegisterUnitEvent('UNIT_TARGET', unit)
    frame.ToTButton:RegisterUnitEvent('UNIT_TARGETABLE_CHANGED', unit)
    frame.ToTButton:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', unit)
    frame.ToTButton:SetScript('OnHide', function(self)
        SetPortraitTexture(self.Portrait, self.target)--图像
    end)
end

















--[[队友，施法
local function Create_castFrame(frame)
    local unit= frame:GetUnit()
    local castFrame= CreateFrame("Frame", 'WoWTools'..unit..'ToTCastingFrame', frame)
    castFrame:SetPoint('BOTTOMLEFT', frame.ToTButton, 'BOTTOMRIGHT')
    castFrame:SetSize(20,20)

    castFrame.texture= castFrame:CreateTexture(nil, 'BACKGROUND')
    castFrame.texture:SetAllPoints()
    castFrame.texture:EnableMouse(true)
    WoWTools_ButtonMixin:AddMask(castFrame)
    castFrame.texture:Hide()

    castFrame.texture:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    castFrame.texture:SetScript('OnEnter', function(self)
        local u= self:GetParent().unit
        if not canaccessvalue(u) or not u then
            return
        end

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        local spellID= select(8, UnitChannelInfo(u)) or select(9, UnitCastingInfo(u))
        GameTooltip:SetSpellByID(spellID or 0)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    function castFrame:settings()
        local texture= WoWTools_CooldownMixin:SetFrame(self, {unit=self.unit})
        texture= texture or (Is_InEditMode() and 4622499) or 0
        self.texture:SetTexture(texture)
        self.texture:SetShown(texture>0)
    end


    castFrame:SetScript('OnEvent', function(self, event, arg1)
        if event=='UNIT_SPELLCAST_SENT' and not WoWTools_UnitMixin:UnitIsUnit(self.unit, arg1) then
            return
        else
            self:settings()
        end
    end)

    castFrame:SetScript('OnHide', function(self)
        self.texture:SetTexture(0)
        self:UnregisterAllEvents()
        WoWTools_CooldownMixin:SetFrame(self)
    end)

    function castFrame:Init()
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
    end

    if frame:IsShown() then
        castFrame:Init()
    end
    castFrame:SetScript('OnShow', function(self)
        self:Init()
    end)

end]]














--成员派系
local function Create_frame(partyFrame)
    local frame= CreateFrame("Frame", nil, partyFrame)

    frame.faction=frame:CreateTexture('WoWTools'..partyFrame.unit..'FactionTexture', 'ARTWORK')
    frame.faction:SetSize(14,14)
    frame.faction:SetPoint('TOPLEFT', partyFrame.Portrait)

    function frame:settings()
        local atlas
        if Is_InEditMode() then
            atlas= WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction]
        else
            local faction= UnitFactionGroup(self:GetParent().unit)
            if faction~= WoWTools_DataMixin.Player.Faction then
                atlas= WoWTools_DataMixin.Icon[faction]
            end
        end
        if atlas then
            self.faction:SetAtlas(atlas)
        else
            self.faction:SetTexture(0)
        end
    end

    function frame:set_event()
        self:RegisterUnitEvent('UNIT_FACTION', self:GetParent().unit)
        self:settings()
    end

    frame:SetScript('OnEvent', frame.settings)

    frame:SetScript('OnHide', function(self)
        self:UnregisterEvent('UNIT_FACTION')
        self.faction:SetTexture(0)
    end)

    frame:SetScript('OnShow', frame.set_event)

    if partyFrame:IsVisible() then
        frame:set_event()
    end
end





















--战斗指示
local function Create_combatFrame(frame)
    frame.combatFrame= CreateFrame('Frame', nil, frame)

    local combatFrame= frame.combatFrame

    if frame.PartyMemberOverlay then
        --combatFrame:SetPoint('TOPLEFT', frame, 'TOPRIGHT',-6, -4)
        combatFrame:SetPoint('LEFT', frame.PartyMemberOverlay.RoleIcon, 'RIGHT')
        combatFrame:SetSize(frame.PartyMemberOverlay.RoleIcon:GetSize())
        combatFrame:SetFrameStrata('HIGH')
    else
        --.PartyMemberOverlay.RoleIcon
        combatFrame:SetPoint('TOPLEFT', 4, -17)
        combatFrame:SetSize(12, 12)-- frame.roleIcon:GetSize() 17
    end

    combatFrame.texture= combatFrame:CreateTexture(nil, 'BORDER')
    combatFrame.texture:SetAllPoints()
    combatFrame.texture:SetAtlas('UI-HUD-UnitFrame-Player-CombatIcon')
    combatFrame.texture:SetVertexColor(1, 0, 0)
    combatFrame.texture:Hide()

  
    function combatFrame:Init()
        self.unit= self:GetParent().unit
    end

    combatFrame:SetScript('OnShow', combatFrame.Init)
    combatFrame:Init()

    combatFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed>0.3 then
            self.elapsed=0
            self.texture:SetShown(UnitAffectingCombat(self.unit) or Is_InEditMode())
        end
    end)
end










--队友位置
local function Create_positionFrame(frame)

    local Frame= CreateFrame("Frame", nil, frame)
    Frame:SetPoint('LEFT', frame.PartyMemberOverlay.LeaderIcon, 'RIGHT')
    Frame:SetSize(1,1)
--地图，位置
    Frame.map= CreateFrame('Frame', nil, Frame)
    Frame.map.Text= Frame.map:CreateFontString(nil, 'BORDER', 'WoWToolsFont')--  WoWTools_LabelMixin:Create(Frame.map)
    Frame.map.Text:SetFontHeight(10)
    Frame.map.Text:SetPoint('LEFT', Frame)
    Frame.map:Hide()
--距离
    Frame.xy= CreateFrame('Frame', nil, Frame)
    Frame.xy:SetSize(1,1)
    Frame.xy:SetPoint('RIGHT', frame.Portrait, 'LEFT')
    Frame.xy:Hide()
    Frame.xy.unit= frame.unit
    WoWTools_UnitMixin:SetRangeFrame(Frame.xy, 10)




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
            text= text..' '..WoWTools_DataMixin:MK(distanceSquared, 0)
        end

        self.Text:SetText(text)
    end)



    function Frame:set_shown()
        local isInInstance= IsInInstance()
        local isInEditMode= Is_InEditMode()

        self.map:SetShown(isInEditMode or not isInInstance)
        self.xy:SetShown(isInEditMode or isInInstance)
    end

    function Frame:Init()
        local unit= self:GetParent().unit
        self.unit= unit
        self.map.unit= unit

        local color= WoWTools_UnitMixin:GetColor(unit)
        self.map.Text:SetTextColor(color:GetRGB())

        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:set_shown()
    end

    Frame:SetScript('OnEvent',  function(self)
        self:set_shown()
    end)

    Frame:SetScript('OnHide', function(self)
        self.map.elapsed=nil
        self.map.unit=nil
        self.map.Text:SetText('')

        self.unit=nil
        self:UnregisterAllEvents()
    end)

    if frame:IsShown() then
        Frame:Init()
    end

    Frame:SetScript('OnShow', function(self)
        self:Init()
    end)

end














--队友，死亡 Save().PartyDeadData={ [GetUnitName(self.unit, true) ] = 死亡次数 0}
local function Rest_AllDeadData()
     Save().PartyDeadData={}
     for i=1, MAX_PARTY_MEMBERS+1 do
        if _G['CompactPartyFrameMember'..i] then
            local frame= _G['CompactPartyFrameMember'..i].deadFrame
            if frame and frame:IsVisible() then
                frame:UnregisterAllEvents()
                frame:Init()
            end
        end
        if PartyFrame['MemberFrame'..i] then
            local frame= PartyFrame['MemberFrame'..i].deadFrame
            if frame and frame:IsVisible() then
                frame:UnregisterAllEvents()
                frame:Init()
            end
        end
    end
end


local function Create_deadFrame(frame)
    frame.deadFrame= CreateFrame('Frame', nil, frame)
    local deadFrame= frame.deadFrame

    deadFrame:SetSize(1,1)

    deadFrame.Text= deadFrame:CreateFontString(nil, 'BORDER', 'WoWToolsFont2') --WoWTools_LabelMixin:Create(deadFrame, {mouse=true, color={r=1,g=1,b=1}})
    deadFrame.Text:EnableMouse(true)

    if frame.PartyMemberOverlay then
        deadFrame:SetPoint('TOPRIGHT', frame.Portrait, 2, -4)
        deadFrame.Text:SetPoint("RIGHT")
    else
        deadFrame:SetPoint('TOPLEFT', 16, -17)
        deadFrame.Text:SetPoint("TOPLEFT")
        deadFrame.Text:SetFontHeight(10)
    end



    deadFrame.Text:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    deadFrame.Text:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(self:GetParent().unit, 1,1,1)
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '死亡' or DEAD)
            ..': |cffffffff'..self:GetText()..'|r '
           ..(WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
        )
        GameTooltip:AddLine(
            (WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)
            ..WoWTools_DataMixin.Icon.left
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    deadFrame.Text:SetScript('OnMouseDown', function(self)
        Rest_AllDeadData()
        self:SetAlpha(0.3)
    end)
    deadFrame.Text:SetScript('OnMouseUp', function(self)
        self:SetAlpha(0.5)
    end)

    function deadFrame:GetName()
        return GetUnitName(self.unit, true)
    end

    function deadFrame:settings()
--死亡，次数
        self.Text:SetText(Save().PartyDeadData[self:GetName()] or 0)
    end

--编辑模式
        --[[if Is_InEditMode() then
            self.texture:SetTexture(WoWTools_DataMixin.Icon.icon)
            return
--没用，连线
        elseif not UnitIsConnected(unit) then
            self.texture:SetTexture(0)
            return
        end]]

        --[[local atlas, texture= Get_Unit_Status(unit)

        if atlas then
            self.texture:SetAtlas(atlas)
        else
            self.texture:SetTexture(texture or 0)
        end]]






    deadFrame:SetScript('OnEvent', function(self, event)
        if event=='CHALLENGE_MODE_START' then
            self.deadBool=nil
            Save().PartyDeadData[self:GetName()]= nil

        else
            if UnitIsDeadOrGhost(self.unit) then--死亡，次数
                if not self.deadBool then
                    self.deadBool=true

                    local name= self:GetName()
                    Save().PartyDeadData[name]= (Save().PartyDeadData[name] or 0)+1

                    self:settings()
                end
            else
                self.deadBool= nil
            end
        end
    end)

    deadFrame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
    end)

    function deadFrame:Init()
        local unit= self:GetParent().unit
        self.unit= unit
        self:RegisterEvent('CHALLENGE_MODE_START')
        self:RegisterUnitEvent('UNIT_FLAGS', unit)
        self:RegisterUnitEvent('UNIT_HEALTH', unit)
        self:RegisterUnitEvent('INCOMING_RESURRECT_CHANGED', unit)
        local color= WoWTools_UnitMixin:GetColor(unit)
        self.Text:SetTextColor(color:GetRGB())
        self:settings()
    end

    deadFrame:SetScript('OnShow', deadFrame.Init)

end


































--先使用一次，用以Shift+点击，设置焦点功能, Invite.lua
local function Init()--PartyFrame.lua
    if WoWToolsSave['Plus_UnitFrame'].hidePartyFrame then
        return
    end

    EventRegistry:RegisterFrameEventAndCallback("GROUP_LEFT", function()
        Save().PartyDeadData= {}--队友，死亡，次数
    end)

    PartyFrame.Background:SetWidth(124)--144

    --local showPartyFrames = PartyFrame:ShouldShow();
    for i=1, MAX_PARTY_MEMBERS+1 do
        local frame= PartyFrame['MemberFrame'..i]
        if frame then
            do
                Create_potFrame(frame)--目标的目标
            end

            frame.Name:SetPoint('RIGHT')
            frame.Name:SetFontObject('WoWToolsFont')

            for _, label in pairs({
                frame.ManaBar.TextString,
                frame.ManaBar.RightText,
                frame.ManaBar.LeftText,

                frame.HealthBarContainer.RightText,
                frame.HealthBarContainer.LeftText,
                frame.HealthBarContainer.CenterText,
                frame.Name,
            }) do
                if label then
                    label:SetFontHeight(10)
                end
            end
            --frame.PortraitMask:SetAlpha(0)
            --frame.Texture:SetAlpha(0)
            --Create_castFrame(frame)--队友，施法
            Create_frame(frame)--队伍, 标记, 成员派系
            Create_combatFrame(frame, false)--战斗指示

            Create_positionFrame(frame)--队友位置
            Create_deadFrame(frame)--队友，死亡

        --[[WoWTools_DataMixin:Hook(frame, 'ToPlayerArt', function(self)--PartyMemberFrame.lua
            self.Texture:SetAtlas('UI-HUD-UnitFrame-Party-PortraitOn-InCombat')--PartyFrameTemplates.xml
        end)]]


            WoWTools_DataMixin:Hook(frame, 'UpdateAssignedRoles', function(self)--隐藏, DPS 图标
                self.PartyMemberOverlay.RoleIcon:SetAlpha(UnitGroupRolesAssigned(self.unit)== 'DAMAGER' and 0 or 1)
            end)

            frame.Texture:SetAlpha(0.5)
            WoWTools_DataMixin:Hook(frame, 'UpdateMember', function(self)
                --[[local color= WoWTools_UnitMixin:GetColor(frame.unit)
            --外框
                self.Texture:SetVertexColor(color:GetRGB())
                self.PortraitMask:SetVertexColor(color:GetRGB())]]

                frame.deadFrame:UnregisterAllEvents()
                frame.deadFrame:Init()
                frame.combatFrame:Init()
            end)
        end




        frame= _G['CompactPartyFrameMember'..i]
        if frame then
            Create_combatFrame(frame)
            Create_deadFrame(frame)
        end
    end

    --hooksecurefunc(CompactPartyFrame, 'RefreshMembers', function()

    WoWTools_DataMixin:Hook(CompactPartyFrame,'UpdateVisibility', function(self)
        if not self:IsShown() then
            return
        end

        for i=1, MAX_PARTY_MEMBERS+1 do
            local frame= _G['CompactPartyFrameMember'..i]
            if frame and frame.deadFrame then
                frame.deadFrame:UnregisterAllEvents()
                frame.deadFrame:Init()
                frame.combatFrame:Init()
            end
        end
    end)

    Init=function()end
end
--[[
    WoWTools_DataMixin:Hook(PartyFrame, 'UpdatePartyFrames', function(self)
        for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
            if not frame.ToTButton then
                Init_CreateButton(frame)
            end
        end
    end)
 WoWTools_DataMixin:Hook(PartyFrame, 'UpdatePartyFrames', function(unitFrame)
    for memberFrame in unitFrame.PartyMemberFramePool:EnumerateActive() do
        set_memberFrame(memberFrame)
    end
end)
]]


function WoWTools_UnitMixin:Init_PartyFrame()--小队
    Init()
end