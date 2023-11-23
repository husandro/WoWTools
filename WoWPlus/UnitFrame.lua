local id, e = ...
local addName= UNITFRAME_LABEL
local Save={
    notRaidFrame= not e.Player.husandro,
    raidFrameScale=0.8,
    --raidFrameAlpha=1,
}
local panel=CreateFrame("Frame")

local function set_SetTextColor(self, r, g, b)--设置, 字体
    if self and r and g and b then
        self:SetTextColor(r, g, b)
    end
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














--#######
--拾取专精
--#######
local function set_LootSpecialization()--拾取专精
    local self= PlayerFrame
    if self and self.lootSpecFrame then
        local find=false
        if self.unit~='vehicle' then
            local currentSpec = GetSpecialization()
            local specID= currentSpec and GetSpecializationInfo(currentSpec)
            if specID then
                local lootSpecID = GetLootSpecialization()
                if lootSpecID and lootSpecID~=specID then
                    local name, _, texture= select(2, GetSpecializationInfoByID(lootSpecID))
                    if texture and name then
                        SetPortraitToTexture(self.lootSpecFrame.texture, texture)
                        find=true
                        self.lootSpecFrame.tips= (e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION).." "..('|T'..texture..':0|t')..name
                    end
                end
            end
        end
        self.lootSpecFrame:SetShown(find)
    end
end













--################
--副本, 地下城，指示
--################
local function set_Instance_Difficulty()
    local self= PlayerFrame
    if not self or not self.instanceFrame2 then
        return
    end
    local ins, find2, find3=  IsInInstance(), false, false
    if not ins and self.unit~= 'vehicle' then
        local difficultyID2 = GetDungeonDifficultyID()
        local difficultyID3= GetRaidDifficultyID()
        local displayMythic3 = select(6, GetDifficultyInfo(difficultyID3))

        local name2, color2= e.GetDifficultyColor(nil, difficultyID2)
        local name3, color3= e.GetDifficultyColor(nil, difficultyID3)

        local text3= (e.onlyChinese and '团队副本难度' or RAID_DIFFICULTY)..': '..name3..'|r'
        local otherDifficulty = GetLegacyRaidDifficultyID()
        local size3= otherDifficulty and DifficultyUtil.GetMaxPlayers(otherDifficulty)--UnitPopup.lua
        if size3 and not displayMythic3 then
            text3= text3..'|n'..(e.onlyChinese and '经典团队副本难度' or LEGACY_RAID_DIFFICULTY)..': '..(size3==10 and (e.onlyChinese and '10人' or RAID_DIFFICULTY1) or size3==25 and (e.onlyChinese and '25人' or RAID_DIFFICULTY2) or '')
        end

        if name3 and (name3~=name2 or not displayMythic3) then
            self.instanceFrame3.texture:SetVertexColor(color3.r, color3.g, color3.b)
            self.instanceFrame3.tips= text3
            self.instanceFrame3.name= name3
            self.instanceFrame3.text:SetText((size3 and not displayMythic3) and size3 or '')
            find3=true
        end

        if name2  then
            self.instanceFrame2.texture:SetVertexColor(color2.r, color2.g, color2.b)
            local text2= (e.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY)..': '..color2.hex..name2..'|r'

            if not find3 then
                text2= text2..'|n|n'..text3
            end
            self.instanceFrame2.tips=text2
            self.instanceFrame2.name= name2
            find2= true
        end
    end
    self.instanceFrame2:SetShown(not ins and find2)
    self.instanceFrame3:SetShown(not ins and find3)
end






















--#########
--挑战，数据
--#########
local function set_Keystones_Date()
    local self= PlayerFrame
    if not self or not self.keystoneText or IsInInstance() then
        if self and self.keystoneText then
            self.keystoneText:SetText('')
        end
        return
    end

    local text
    local score= C_ChallengeMode.GetOverallDungeonScore()
    if score and score>0 then

        local activeText= e.Get_Week_Rewards_Text(1)--得到，周奖励，信息
       --[[ for _, activities in pairs(C_WeeklyRewards.GetActivities(1) or {}) do--本周完成 Enum.WeeklyRewardChestThresholdType.MythicPlus 1
            if activities.level and activities.level>=0 and activities.threshold and activities.threshold>0 and activities.type==1 then
                activeText= (activeText and activeText..'/' or '')..activities.level
            end
        end]]
        activeText= activeText and ' ('..activeText..') '

        text= e.GetKeystoneScorsoColor(score, true)..(activeText or '')--分数
        local info = C_MythicPlus.GetRunHistory(false, true) or {}--次数
        local num= #info
        if num>0 then
            text= text..num
        end
    end
    self.keystoneText:SetText(text or '')

end















--####
--玩家
--####
local function Init_PlayerFrame()--PlayerFrame.lua
    hooksecurefunc('PlayerFrame_UpdateLevel', function()
        set_SetTextColor(PlayerLevelText, e.Player.r, e.Player.g, e.Player.b)
    end)

    --施法条
    PlayerCastingBarFrame:HookScript('OnShow', function(self)--图标
        self.Icon:SetShown(true)
    end)

    PlayerCastingBarFrame.castingText= e.Cstr(PlayerCastingBarFrame, {color={r=e.Player.r, g=e.Player.g, b=e.Player.b}, justifyH='RIGHT'})
    PlayerCastingBarFrame.castingText:SetDrawLayer('OVERLAY', 2)
    PlayerCastingBarFrame.castingText:SetPoint('RIGHT', PlayerCastingBarFrame.ChargeFlash, 'RIGHT')
    PlayerCastingBarFrame:HookScript('OnUpdate', function(self, elapsed)--玩家, 施法, 时间
        self.elapsed= (self.elapsed or 0.1) + elapsed
        if self.elapsed>=0.1 and self.value and self.maxValue then
            self.elapsed=0
            local value= self.channeling and self.value or (self.maxValue-self.value)
            if value<=0 then
                self.castingText:SetText(0)
            elseif value>=3 then
                self.castingText:SetFormattedText('%i', value)
            else
                self.castingText:SetFormattedText('%.01f', value)
            end
        end
    end)
    set_SetTextColor(PlayerCastingBarFrame.Text, e.Player.r, e.Player.g, e.Player.b)--法术名称，颜色

    hooksecurefunc('PlayerFrame_UpdateGroupIndicator', function()--处理,小队, 号码
        if IsInRaid() and PlayerFrameGroupIndicatorText then
            local text= PlayerFrameGroupIndicatorText:GetText()
            local num= text and text:match('(%d)')
            if num then
                PlayerFrameGroupIndicatorText:SetText('|A:'..e.Icon.number..num..':18:18|a')
            end
        end
    end)
    PlayerFrameGroupIndicatorLeft:SetTexture(0)
    PlayerFrameGroupIndicatorLeft:SetShown(false)
    PlayerFrameGroupIndicatorMiddle:SetTexture(0)
    PlayerFrameGroupIndicatorMiddle:SetShown(false)
    PlayerFrameGroupIndicatorRight:SetTexture(0)
    PlayerFrameGroupIndicatorRight:SetShown(false)

    if PlayerHitIndicator then--玩家, 治疗，爆击，数字
        PlayerHitIndicator:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
        PlayerHitIndicator:ClearAllPoints()
        PlayerHitIndicator:SetPoint('TOPLEFT', PlayerFrame.PlayerFrameContainer.PlayerPortrait, 'BOTTOMLEFT')
        --PlayerHitIndicator:SetPoint('BOTTOMLEFT', (PlayerFrame.PlayerFrameContainer and PlayerFrame and PlayerFrame.PlayerFrameContainer.PlayerPortrait) or  PlayerHitIndicator:GetParent(), 'TOPLEFT')
    end
    if PetHitIndicator then--宠物
        PetHitIndicator:ClearAllPoints()
        PetHitIndicator:SetPoint('TOPLEFT', PetPortrait or PetHitIndicator:GetParent(), 'BOTTOMLEFT')
    end
    hooksecurefunc('PlayerFrame_UpdateLevel', function()
        local text= PlayerLevelText:GetText()
        if text and text~='' and tonumber(text)==MAX_PLAYER_LEVEL then
            PlayerLevelText:SetText('')
        end
    end)
    if PlayerFrame.PlayerFrameContainer and PlayerFrame.PlayerFrameContainer.FrameTexture then
        PlayerFrame.PlayerFrameContainer.FrameTexture:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)--外框
    end

    if PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop.RestTexture then
        PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop.RestTexture:ClearAllPoints()
        PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop.RestTexture:SetPoint('CENTER', PlayerFrame.PlayerFrameContainer.PlayerPortrait)
    end

    hooksecurefunc('PlayerFrame_UpdatePvPStatus', function(self)--开启战争模式时，PVP图标
        local icon= PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PVPIcon
        if icon then
            icon:SetSize(25,25)
            icon:ClearAllPoints()
            icon:SetPoint('RIGHT', PlayerFrame.PlayerFrameContainer.PlayerPortrait, 'LEFT', 13, -24)
        end
    end)
end















--####
--目标
--####
local function Init_TargetFrame()
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

    TargetFrame.rangeText= e.Cstr(TargetFrame, {justifyH='RIGHT'})
    TargetFrame.rangeText:SetPoint('RIGHT', TargetFrame, 'LEFT', 22,0)
    hooksecurefunc(TargetFrame, 'OnUpdate', function(self, elapsed)--距离
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed>0.3 then
            self.elapsed=0
            local text
            if not UnitIsUnit('player', 'target') then
                local mi, ma= e.GetRange('target')
                if mi and ma then
                    text=mi..'|n'..ma
                    if mi>40 then
                        text='|cFFFF0000'..text--红色

                    elseif mi>35 then
                        text='|cFFFFD000'..text
                    elseif mi>30 then
                        text='|cFFFF00FF'..text
                    elseif mi >8 then
                        text ='|cFFFFFF00'..text
                    elseif mi>5 then
                        text='|cFFAF00FF'..text
                    elseif mi>2 then
                        text='|cFF00FF00'..text
                    else
                        text='|cFFFFFFFF'..text----白色
                    end
                end
            end
            self.rangeText:SetText(text or '')
        end
    end)
end



























--####
--小队
--####
local function set_memberFrame(memberFrame)
    local unit= memberFrame.unit or memberFrame:GetUnit()
    local exists= memberFrame:IsShown()

    local r, g, b
    local classFilename= exists and UnitClassBase(unit)
    if classFilename then
        r,g,b= GetClassColor(classFilename)
    end
    r= r or 1
    g= g or 1
    b= b or 1

    --####
    --外框
    --####
    if memberFrame.Texture and exists then
        memberFrame.Texture:SetVertexColor(r, g, b)
    end

    --#########
    --目标的目标
    --#########
    local frame= memberFrame.potFrame
    if not frame then
        frame= e.Cbtn(memberFrame, {type=true, size={35,35}, icon='hide', pushe=true})

        frame.Portrait= frame:CreateTexture(nil, 'BACKGROUND')--队友，目标，图像
        frame.Portrait:SetAllPoints(frame)

        frame.healthBar= CreateFrame('StatusBar', nil, frame)
        frame.healthBar:SetSize(55, 8)
        frame.healthBar:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT')
        frame.healthBar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
        frame.healthBar:SetMinMaxValues(0,100)
        frame.healthBar:SetFrameLevel(frame:GetFrameLevel()+7)
        frame.healthBar.unit= unit..'target'

        frame.healthBar.Text= e.Cstr(frame.healthBar)
        frame.healthBar.Text:SetPoint('RIGHT')
        frame.healthBar.Text:SetTextColor(1,1,1)

        frame.Text= e.Cstr(frame, {size=14})--队友，目标，职业
        frame.Text:SetPoint('BOTTOMRIGHT',3,-2)

        frame.playerTargetTexture= frame:CreateTexture(nil, 'BORDER')
        frame.playerTargetTexture:SetSize(52,52)
        frame.playerTargetTexture:SetPoint('CENTER')
        frame.playerTargetTexture:SetAtlas('DK-Blood-Rune-CDFill')

        local texture= frame.healthBar:CreateTexture(nil, 'BACKGROUND')--队友，目标，生命条，外框
        texture:SetAtlas('MainPet-HealthBarFrame')
        texture:SetAllPoints(frame.healthBar)
        texture:SetVertexColor(1, 0, 0)

        frame:SetPoint('LEFT', memberFrame, 'RIGHT', -3, 4)
        frame:SetAttribute('type', 'target')
        frame:SetAttribute('unit', frame.healthBar.unit)

        function frame:set_Party_Target_Changed()
            local text
            local exists2= UnitExists(self.unit)
            if exists2 then
                if UnitIsUnit(self.unit, 'player') then--我
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
                text= UnitIsPlayer(self.unit) and e.Class(self.unit)
                local r2, g2, b2= GetClassColor(UnitClassBase(self.unit))
                self.healthBar:SetStatusBarColor(r2 or 1, g2 or 1, b2 or 1, 1)
                --self.playerTargetTexture:SetVertexColor(r2 or 1, g2 or 1, b2 or 1, 1)
            end
            self.Portrait:SetShown(exists2)--队友，目标，图像
            self.Text:SetText(text or '')--队友，目标，职业
            self.healthBar:SetAlpha(exists2 and 1 or 0)
            --self.healthBar:SetShown(exists2)--队友， 目标， 生命条
            --self.healthBar.elapsed=1
            self.playerTargetTexture:SetShown(UnitIsUnit(self.unit, 'target'))
        end
        function frame:set_IsPlayerTarget()
            self.playerTargetTexture:SetShown(UnitIsUnit(self.unit, 'target'))
        end
        frame:SetScript('OnLeave', function() e.tips:Hide() end)
        frame:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            if UnitExists(self.unit) then
                e.tips:SetUnit(self.unit)
            else
                e.tips:AddDoubleLine(' ',e.Icon.left..(e.onlyChinese and '选中目标' or BINDING_HEADER_TARGETING))
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, addName)
            end
            e.tips:Show()
        end)
        frame:SetScript('OnEvent', function(self, event)
            if event=='PLAYER_TARGET_CHANGED' then
                self:set_IsPlayerTarget()
            else
                if event=='UNIT_TARGET' then
                    self:set_IsPlayerTarget()
                end
                self:set_Party_Target_Changed()
            end
        end)
        frame.unit= unit..'target'

        --队友， 目标， 生命条
        frame.healthBar:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= (self.elapsed or 0.75) +elapsed
            if self.elapsed>0.75 then
                self.elapsed=0
                local cur= UnitHealth(self.unit) or 0
                local max= UnitHealthMax(self.unit)
                if max and max>0 and cur < max then
                    local value= cur/max*100
                    self:SetValue(value)
                    self.Text:SetFormattedText('%i', value)
                else
                    self.Text:SetText('')
                end
            end
        end)

        memberFrame.potFrame= frame
    end

    frame:UnregisterAllEvents()
    if exists then
        frame:RegisterEvent('RAID_TARGET_UPDATE')
        frame:RegisterUnitEvent('UNIT_TARGET', unit)
        frame:RegisterUnitEvent('UNIT_FLAGS', unit..'target')
        frame:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', unit..'target')
        frame:RegisterEvent('PLAYER_TARGET_CHANGED')
    end
    frame:set_Party_Target_Changed()
    frame:set_IsPlayerTarget()
    --#########
    --队友，施法
    --#########
    frame= memberFrame.castFrame
    if not frame then
        frame= CreateFrame("Frame", nil, memberFrame)
        frame:SetPoint('BOTTOMLEFT', memberFrame.potFrame, 'BOTTOMRIGHT')
        frame:SetSize(20,20)
        frame.texture=  frame:CreateTexture(nil,'BACKGROUND')
        frame.texture:SetAllPoints(frame)
        function frame:set_Party_Casting()
            local texture, startTime, endTime, find, channel
            if UnitExists(self.unit) then
                texture, startTime, endTime= select(3, UnitChannelInfo(self.unit))
                if not (texture and  startTime and endTime) then
                    texture, startTime, endTime= select(3, UnitCastingInfo(self.unit))
                else
                    channel= true
                end
                if texture and startTime and endTime then
                    local duration=(endTime - startTime) / 1000
                    e.Ccool(self, nil, duration, nil, true, channel, nil,nil)
                    find=true
                end
            end
            self.texture:SetTexture(texture or 0)
            self:SetAlpha(find and 1 or 0)
        end
        frame:SetScript('OnEvent', function (self, _, _, _, spellID)
            self:set_Party_Casting()
            self.spellID= spellID
        end)
        frame:SetScript('OnLeave', function() e.tips:Hide() end)
        frame:SetScript('OnEnter', function(self)
            if self.spellID then
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(self.spellID)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end
        end)
        frame.unit= unit
        memberFrame.castFrame= frame
    end
    frame:UnregisterAllEvents()
    if exists then
        local events= {
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
        }
        FrameUtil.RegisterFrameForUnitEvents(frame, events, unit)
    end
    frame:set_Party_Casting()

    --##########
    --队伍, 标记
    --##########
    frame= memberFrame.RaidTargetFrame
    if not frame then
        frame= CreateFrame("Frame", nil, memberFrame)
        frame:SetSize(14,14)
        frame:SetPoint('RIGHT', memberFrame.PartyMemberOverlay.RoleIcon, 'LEFT')
        frame:SetScript('OnEvent', function (self)
            set_RaidTarget(self.RaidTargetIcon, self.unit)
        end)
        frame.RaidTargetIcon= frame:CreateTexture()
        frame.RaidTargetIcon:SetAllPoints(frame)
        frame.RaidTargetIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
        frame.unit= unit
        memberFrame.RaidTargetFrame= frame
    end
    frame:UnregisterAllEvents()
    if exists then
        frame:RegisterEvent('RAID_TARGET_UPDATE')
    end
    set_RaidTarget(frame.RaidTargetIcon, unit)--设置,标记

    --#######
    --战斗指示
    --#######
    frame= memberFrame.combatFrame
    if not frame then
        frame= CreateFrame('Frame', nil, memberFrame)
        --frame:SetPoint('TOPLEFT', memberFrame.potFrame, 'TOPRIGHT', 2, 2)
        frame:SetPoint('BOTTOMLEFT', memberFrame.potFrame, 'RIGHT', 2, 2)
        frame:SetSize(16,16)
        frame:SetScript('OnLeave', function() e.tips:Hide() end)
        frame:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:AddLine(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)

        frame.texture= frame:CreateTexture()
        frame.texture:SetAllPoints(frame)
        frame.texture:SetAtlas('UI-HUD-UnitFrame-Player-CombatIcon-2x')
        frame.texture:SetVertexColor(1, 0, 0)
        frame.texture:SetShown(false)

        frame.unit= unit
        frame:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= (self.elapsed or 0.3) + elapsed
            if self.elapsed>0.3 then
                self.elapsed=0
                self.texture:SetShown(UnitAffectingCombat(self.unit))
            end
        end)
        memberFrame.combatFrame= frame
    end
    frame:SetShown(exists)

    --#######
    --队友位置
    --#######
    frame= memberFrame.positionFrame
    if not frame then
        frame= CreateFrame("Frame", nil, memberFrame)
        frame:SetPoint('LEFT', memberFrame.PartyMemberOverlay.LeaderIcon, 'RIGHT')
        frame:SetSize(1,1)
        frame.Text= e.Cstr(frame)
        frame.Text:SetPoint('LEFT')
        function frame:set_Shown(isExists)
            local show= not IsInInstance() and isExists
            if isExists then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
            else
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
            end
            if show then
                self:RegisterEvent('PLAYER_REGEN_DISABLED')
                self:RegisterEvent('PLAYER_REGEN_ENABLED')
            else
                self:UnregisterEvent('PLAYER_REGEN_DISABLED')
                self:UnregisterEvent('PLAYER_REGEN_ENABLED')
            end
            self:SetShown(show and not UnitAffectingCombat('player'))
        end
        frame:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= (self.elapsed or 0.3) + elapsed
            if self.elapsed>0.3 then
                self.elapsed=0
                local mapID= C_Map.GetBestMapForUnit(self.unit)--地图ID
                local mapInfo= mapID and C_Map.GetMapInfo(mapID)
                local text
                local distanceSquared, checkedDistance = UnitDistanceSquared(self.unit)
                if distanceSquared and checkedDistance then
                    text= e.MK(distanceSquared, 0)
                end
                if mapInfo and mapInfo.name then
                    text= (text and text..' ' or '')..mapInfo.name
                    local mapID2= C_Map.GetBestMapForUnit('player')
                    if mapID2== mapID then
                        text= e.Icon.select2..text
                    end
                end
                self.Text:SetText(text or '')
            end
        end)
        frame:SetScript('OnEvent', function(self, event)
            if event == 'PLAYER_ENTERING_WORLD' then
                self:set_Shown(UnitExists(self.unit))
            elseif event=='PLAYER_REGEN_DISABLED' then
                self:SetShown(false)
            elseif event=='PLAYER_REGEN_ENABLED' then
                self.elapsed=1
                self:SetShown(true)
            end
        end)
        frame.unit= unit
        memberFrame.positionFrame= frame
    end
    if exists then
        frame.Text:SetTextColor(r, g, b)
    end
    frame:set_Shown(exists)

    --#########
    --队友，死亡
    --#########
    frame= memberFrame.deadFrame
    if not frame then
        frame= CreateFrame('Frame', nil, memberFrame)
        frame:SetPoint("CENTER", memberFrame.Portrait)
        frame:SetFrameLevel(memberFrame:GetFrameLevel()+1)
        frame:SetSize(37,37)
        frame:SetFrameStrata('HIGH')
        frame.texture= frame:CreateTexture()
        frame.texture:SetAllPoints(frame)
        function frame:set_Active()
            local find= false
            if UnitIsConnected(self.unit) and UnitIsPlayer(self.unit) then
                if UnitIsCharmed(self.unit) then--被魅惑
                    self.texture:SetAtlas('CovenantSanctum-Reservoir-Idle-NightFae-Spiral3')
                    find= true
                elseif UnitIsFeignDeath(self.unit) then--假死
                    self.texture:SetTexture(132293)
                    find= true

                elseif UnitIsDead(self.unit) then
                    self.texture:SetAtlas('xmarksthespot')
                    find= true
                    if not self.deadBool then--死亡，次数
                        self.deadBool=true
                        self.dead= self.dead +1
                    end

                elseif UnitIsGhost(self.unit) then
                    self.texture:SetAtlas('poi-soulspiritghost')
                    find= true
                else
                    self.deadBool= nil
                end
            end
            self.texture:SetShown(find)
            self.deadText:SetText(self.dead>0 and self.dead or '')
        end
        frame:SetScript('OnEvent', function(self, event)
            if event=='PLAYER_ENTERING_WORLD' or event=='CHALLENGE_MODE_START' then
                self.dead= 0
            end
            self:set_Active()
        end)

        --死亡，次数
        frame.dead=0
        frame.deadText= e.Cstr(frame, {mouse=true})
        frame.deadText:SetPoint('BOTTOMLEFT', frame)
        frame.deadText:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
        frame.deadText:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '死亡' or DEAD,
                    format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, self:GetParent().dead or 0 , e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
            )
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
            self:SetAlpha(0.3)
        end)
        memberFrame.deadFrame= frame
    end

    frame.unit= unit
    frame:UnregisterAllEvents()
    if exists then
        frame:RegisterEvent('PLAYER_ENTERING_WORLD')
        frame:RegisterEvent('CHALLENGE_MODE_START')
        frame:RegisterUnitEvent('UNIT_FLAGS', unit)
        frame:RegisterUnitEvent('UNIT_HEALTH', unit)
        frame.deadText:SetTextColor(r, g, b)
    else
        frame.dead= 0
    end
    frame:set_Active()
end





local function set_UpdatePartyFrames(unitFrame)
    for memberFrame in unitFrame.PartyMemberFramePool:EnumerateActive() do
        set_memberFrame(memberFrame)
    end
end





local function Init_PartyFrame()--PartyFrame.lua
    set_UpdatePartyFrames(PartyFrame)--先使用一次，用以Shift+点击，设置焦点功能, Invite.lua
    hooksecurefunc(PartyFrame, 'UpdatePartyFrames', set_UpdatePartyFrames)
    --##############
    --隐藏, DPS 图标
    --##############
    for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        hooksecurefunc(memberFrame, 'UpdateAssignedRoles', function(self)--隐藏, DPS 图标
            if UnitGroupRolesAssigned(self.unit)=='DAMAGER' then
                self.PartyMemberOverlay.RoleIcon:SetShown(false)
            end
        end)
    end
end



























--################
--职业, 图标， 颜色
--################
local function Init_UnitFrame_Update()--职业, 图标， 颜色
    hooksecurefunc('UnitFrame_Update', function(unitFrame, isParty)--UnitFrame.lua
        local unit= unitFrame.unit
        local r,g,b
        if unit=='player' then
            r,g,b= e.Player.r, e.Player.g, e.Player.b
        else
            local classFilename= unit and UnitClassBase(unit)
            if classFilename then
                r,g,b=GetClassColor(classFilename)
            end
        end
        if not UnitExists(unit) then
            return
        end
        r,g,b= r or 1, g or 1, b or 1

        local guid
        local unitIsPlayer=  UnitIsPlayer(unit)
        if unitIsPlayer then
            guid= UnitGUID(unitFrame.unit)--职业, 天赋, 图标
            if not unitFrame.classFrame then
                unitFrame.classFrame= CreateFrame('Frame', nil, unitFrame)
                unitFrame.classFrame:SetShown(false)
                unitFrame.classFrame:SetSize(16,16)
                unitFrame.classFrame.Portrait= unitFrame.classFrame:CreateTexture(nil, "BACKGROUND")
                unitFrame.classFrame.Portrait:SetAllPoints(unitFrame.classFrame)
                

                if unitFrame==TargetFrame then
                    unitFrame.classFrame:SetPoint('RIGHT', unitFrame.TargetFrameContent.TargetFrameContentContextual.LeaderIcon, 'LEFT')
                elseif unitFrame==PetFrame then
                    unitFrame.classFrame:SetPoint('LEFT', unitFrame.name,-10,0)
                elseif unitFrame==PlayerFrame then
                    unitFrame.classFrame:SetPoint('TOPLEFT', unitFrame.portrait, 'TOPRIGHT',-14,8)
                elseif unitFrame==FocusFrame then
                    unitFrame.classFrame:SetPoint('BOTTOMRIGHT', unitFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor, 'TOPRIGHT')
                else
                    unitFrame.classFrame:SetPoint('TOPLEFT', unitFrame.portrait, 'TOPRIGHT',-14,10)
                end

                unitFrame.classFrame.Texture= unitFrame.classFrame:CreateTexture(nil, 'OVERLAY')--加个外框
                unitFrame.classFrame.Texture:SetAtlas('UI-HUD-UnitFrame-TotemFrame')
                unitFrame.classFrame.Texture:SetPoint('CENTER', unitFrame.classFrame, 1,-1)
                unitFrame.classFrame.Texture:SetSize(20,20)

                function unitFrame.classFrame:set_Class(guid3)
                    local unit2= self:GetParent().unit
                    local isPlayer= UnitExists(unit2) and UnitIsPlayer(unit2)
                    local find2=false
                    if isPlayer then
                        if unit2=='player' then
                            local texture= select(4, GetSpecializationInfo(GetSpecialization() or 0))
                            if texture then
                                SetPortraitToTexture(self.Portrait, texture)
                                find2= true
                            end
                        else
                            local specID= GetInspectSpecialization(unit2)
                            if specID and specID>0 then
                                local texture= select(4, GetSpecializationInfoByID(specID))
                                if texture then
                                    SetPortraitToTexture(self.Portrait, texture)
                                    find2= true
                                end
                            else
                                local guid2= guid3 or UnitGUID(unit2)
                                if guid2 and e.UnitItemLevel[guid2] and e.UnitItemLevel[guid2].specID then
                                    local texture= select(4, GetSpecializationInfoByID(e.UnitItemLevel[guid2].specID))
                                    if texture then
                                        SetPortraitToTexture(self.Portrait, texture)
                                        find2= true
                                    end
                                else
                                    local class= e.Class(unit2, nil, true)--职业, 图标
                                    if class then
                                        self.Portrait:SetAtlas(class)
                                        find2=true
                                    end
                                end
                            end
                        end
                    end
                    self:SetShown(isPlayer and find2)
                end
                unitFrame.classFrame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', unit)
                unitFrame.classFrame:SetScript('OnEvent', function(self3)
                    local unit2= self3:GetParent().unit
                    if UnitIsPlayer(unit2) then
                        e.GetNotifyInspect(nil, unit2)--取得玩家信息
                        C_Timer.After(2, function()
                            self3:set_Class()
                        end)
                    end
                end)
            end
            unitFrame.classFrame:set_Class(guid)
            unitFrame.classFrame.Texture:SetVertexColor(r, g, b)

            if unit~='player' then
                if not unitFrame.itemLevel then
                    unitFrame.itemLevel= e.Cstr(unitFrame.classFrame, {size=12})--装等
                    if unit=='target' or unit=='focus' then
                        unitFrame.itemLevel:SetPoint('RIGHT', unitFrame.classFrame, 'LEFT')
                    else
                        unitFrame.itemLevel:SetPoint('TOPRIGHT', unitFrame.classFrame, 'TOPLEFT')
                    end
                end
                unitFrame.itemLevel:SetTextColor(r,g,b)
                unitFrame.itemLevel:SetText(guid and e.UnitItemLevel[guid] and e.UnitItemLevel[guid].itemLevel or '')
            end
        end
        if unitFrame.classFrame then
            unitFrame.classFrame:SetShown(unitIsPlayer)
        end

        if unitFrame==PlayerFrame and unit=='player' then
            if not unitFrame.lootSpecFrame then-- and unitFrame~= PetFrame and unitFrame.PlayerFrameContainer then
                local frameLevel= unitFrame.PlayerFrameContainer:GetFrameLevel()+1
                frameLevel= frameLevel<0 and 0 or frameLevel

                unitFrame.lootSpecFrame= CreateFrame("Frame", nil, unitFrame)
                unitFrame.lootSpecFrame:SetPoint('TOPRIGHT', unitFrame.classFrame, 'TOPLEFT', -0.5, 4)
                unitFrame.lootSpecFrame:SetSize(14,14)
                unitFrame.lootSpecFrame:EnableMouse(true)
                unitFrame.lootSpecFrame:SetFrameLevel(frameLevel)
                unitFrame.lootSpecFrame.texture=unitFrame.lootSpecFrame:CreateTexture(nil, 'BORDER')
                unitFrame.lootSpecFrame.texture:SetAllPoints(unitFrame.lootSpecFrame)

                local portrait= unitFrame.lootSpecFrame:CreateTexture(nil, 'ARTWORK', nil,7)--外框
                portrait:SetAtlas('DK-Base-Rune-CDFill')
                portrait:SetPoint('CENTER', unitFrame.lootSpecFrame)
                portrait:SetSize(20,20)
                portrait:SetVertexColor(r,g,b,1)

                local lootTipsTexture= unitFrame.lootSpecFrame:CreateTexture(nil, "OVERLAY")
                lootTipsTexture:SetSize(10,10)
                lootTipsTexture:SetPoint('TOP',0,8)
                lootTipsTexture:SetAtlas('Banker')

                unitFrame.lootSpecFrame:SetScript('OnLeave', function(self3) e.tips:Hide() self3:SetAlpha(1) end)
                unitFrame.lootSpecFrame:SetScript('OnEnter', function(self3)
                    if self3.tips then
                        e.tips:SetOwner(self3, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddLine(self3.tips)
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:Show()
                        self3:SetAlpha(0.3)
                    end
                end)

                unitFrame.instanceFrame3= CreateFrame("Frame", nil, unitFrame)--Riad 副本, 地下城，指示
                unitFrame.instanceFrame3:SetFrameLevel(frameLevel)
                unitFrame.instanceFrame3:SetPoint('RIGHT', unitFrame.lootSpecFrame, 'LEFT',-2, 1)
                unitFrame.instanceFrame3:SetSize(16,16)
                unitFrame.instanceFrame3:EnableMouse(true)
                unitFrame.instanceFrame3:SetScript('OnLeave', function(self3) e.tips:Hide() self3:SetAlpha(1) end)
                unitFrame.instanceFrame3:SetScript('OnEnter', function(self3)
                    if self3.tips then
                        e.tips:SetOwner(self3, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine(self3.tips, '|A:poi-torghast:0:0|a')
                        e.tips:AddLine(' ')
                        local tab={
                            DifficultyUtil.ID.DungeonNormal,
                            DifficultyUtil.ID.DungeonHeroic,
                            DifficultyUtil.ID.DungeonMythic
                        }
                        for _, ID in pairs(tab) do
                            local text= e.GetDifficultyColor(nil, ID)
                            e.tips:AddLine((text==self3.name and e.Icon.toRight2 or '')..text..(text==self3.name and e.Icon.toLeft2 or ''))
                        end
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:Show()
                        self3:SetAlpha(0.3)
                    end
                end)
                unitFrame.instanceFrame3.texture= unitFrame.instanceFrame3:CreateTexture(nil,'BORDER', nil, 1)
                unitFrame.instanceFrame3.texture:SetAllPoints(unitFrame.instanceFrame3)
                unitFrame.instanceFrame3.texture:SetAtlas('poi-torghast')

                unitFrame.instanceFrame3.text= e.Cstr(unitFrame.instanceFrame3, {size=8})
                unitFrame.instanceFrame3.text:SetPoint('TOP',0,5)
                unitFrame.instanceFrame3.text:SetTextColor(r,g,b)

                unitFrame.instanceFrame2= CreateFrame("Frame", nil, unitFrame)--5人 副本, 地下城，指示
                unitFrame.instanceFrame2:SetFrameLevel(frameLevel)
                unitFrame.instanceFrame2:SetPoint('RIGHT', unitFrame.instanceFrame3, 'LEFT',0, -6)
                unitFrame.instanceFrame2:SetSize(16,16)
                unitFrame.instanceFrame2:EnableMouse(true)
                unitFrame.instanceFrame2:SetScript('OnLeave', function(self3) e.tips:Hide() self3:SetAlpha(1) end)
                unitFrame.instanceFrame2:SetScript('OnEnter', function(self3)
                    if self3.tips then
                        e.tips:SetOwner(self3, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine(self3.tips, '|A:DungeonSkull:0:0|a')
                        e.tips:AddLine(' ')
                        local tab={
                            DifficultyUtil.ID.DungeonNormal,
                            DifficultyUtil.ID.DungeonHeroic,
                            DifficultyUtil.ID.DungeonMythic
                        }
                        for _, ID in pairs(tab) do
                            local text= e.GetDifficultyColor(nil, ID)
                            e.tips:AddLine((text==self3.name and e.Icon.toRight2 or '')..text..(text==self3.name and e.Icon.toLeft2 or ''))
                        end
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:Show()
                        self3:SetAlpha(0.3)
                    end
                end)
                unitFrame.instanceFrame2.texture= unitFrame.instanceFrame2:CreateTexture(nil,'BORDER', nil, 1)
                unitFrame.instanceFrame2.texture:SetAllPoints(unitFrame.instanceFrame2)
                unitFrame.instanceFrame2.texture:SetAtlas('DungeonSkull')

                portrait= unitFrame.instanceFrame2:CreateTexture(nil, 'BORDER',nil,2)--外框
                portrait:SetAtlas('DK-Base-Rune-CDFill')
                portrait:SetPoint('CENTER')
                portrait:SetSize(20,20)
                portrait:SetVertexColor(r,g,b,1)

                unitFrame.keystoneText= e.Cstr(unitFrame, {color=true})
                if unitFrame.PlayerFrameContent and unitFrame.PlayerFrameContent.PlayerFrameContentContextual and unitFrame.PlayerFrameContent.PlayerFrameContentContextual.LeaderIcon then
                    unitFrame.keystoneText:SetPoint('LEFT', unitFrame.PlayerFrameContent.PlayerFrameContentContextual.LeaderIcon, 'RIGHT')
                end
                if PlayerFrameGroupIndicatorText then--移动，小队，号
                    PlayerFrameGroupIndicatorText:ClearAllPoints()
                    PlayerFrameGroupIndicatorText:SetPoint('LEFT', unitFrame.keystoneText, 'RIGHT',12,0)
                end
            end
            set_Instance_Difficulty()--副本, 地下城，指示
            set_LootSpecialization()--拾取专精
            C_Timer.After(2, set_Keystones_Date)--挑战，数据
        end

        if unitFrame.name then
            local name
            if UnitIsUnit(unit, 'pet') then
                unitFrame.name:SetText(e.Icon.star2)
            else
                set_SetTextColor(unitFrame.name, r, g, b)--名称, 颜色
                if isParty then
                    name= UnitName(unit)
                    name= e.WA_Utf8Sub(name, 4, 8)
                    unitFrame.name:SetText(name)
                elseif unit=='target' and guid then
                    local wow= e.GetFriend(nil, guid)
                    if wow then
                        name= wow..GetUnitName(unit, false)
                    end
                end
            end
            if name then
                unitFrame.name:SetText(name)
            end
        end

        --################
        --生命条，颜色，材质
        --################
        if unitFrame.healthbar then
            unitFrame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
            unitFrame.healthbar:SetStatusBarColor(r,g,b)--颜色

            if not unitFrame.setHealthbarTexture and unitFrame.CheckClassification then
                hooksecurefunc(unitFrame, 'CheckClassification', function(self3)--外框，颜色
                    self3.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
                    local classFilename= UnitClassBase(self3.unit)
                    if classFilename then
                        local r2,g2,b2=GetClassColor(classFilename)
                        if r2 and g2 and b2 and self3.TargetFrameContainer then
                            if self3.TargetFrameContainer.FrameTexture then
                                self3.TargetFrameContainer.FrameTexture:SetVertexColor(r2, g2, b2)
                            end
                            if self3.TargetFrameContainer.BossPortraitFrameTexture:IsShown() then
                                self3.TargetFrameContainer.BossPortraitFrameTexture:SetVertexColor(r2, g2, b2)
                            end
                        end
                    end
                end)
                unitFrame.setHealthbarTexture= true
            end
        end
    end)
--[[
if e.Player.husandro then
        hooksecurefunc('UnitFrame_OnEvent', function(self, event)--修改, 宠物, 名称)
            if self.unit=='pet' and event == "UNIT_NAME_UPDATE" then
                self.name:SetText(e.Icon.star2)
            end
        end)

        --############
        --去掉生命条 % extStatusBar.lua TextStatusBar.lua
        --############会出现，错误

        local deadText= e.onlyChinese and '死亡' or DEAD
        hooksecurefunc('TextStatusBar_UpdateTextStringWithValues', function(frame, textString, value)
            if not frame:IsShown() then
                return
            end
            print(frame.displayedValue , frame.unit)
            if value then--statusFrame.unit
                if textString and textString:IsShown() then
                    local text
                    if UnitIsGhost(frame.unit) then
                        text= '|A:poi-soulspiritghost:18:18|a'..deadText
                    else
                        text= textString:GetText()
                    end
                    if text then
                        if text=='100%' then
                            text= ''
                        else
                            text= text:gsub('%%', '')
                        end
                        textString:SetText(text)
                    end

                elseif frame.LeftText and frame.LeftText:IsShown() then
                    local text
                    if UnitIsGhost(frame.unit) then
                        text= '|A:poi-soulspiritghost:18:18|a'..deadText
                    else
                        text= frame.LeftText:GetText()
                    end
                    if text then
                        if text=='100%' then
                            text= ''
                        else
                            text= text:gsub('%%', '')
                        end
                        frame.LeftText:SetText(text)
                    end
                end
            elseif frame.zeroText and frame.DeadText and frame.DeadText:IsShown() then
                local text= deadText--死亡
                if frame.unit then
                    if UnitIsGhost(frame.unit) then--灵魂
                        text= '|A:poi-soulspiritghost:18:18|a'..text
                    elseif UnitIsDead(frame.unit) then--死亡
                        text= '|A:deathrecap-icon-tombstone:18:18|a'..text
                    end
                end
                frame.DeadText:SetText(text)
            end
        end)

    --hooksecurefunc('SetTextStatusBarTextZeroText', function(self)
end
]]
    --###################
    --隐藏, 队伍, DPS 图标
    --###################
    for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        hooksecurefunc(memberFrame, 'UpdateAssignedRoles', function(self)--隐藏, DPS 图标
            local icon = self.PartyMemberOverlay.RoleIcon
            if icon and icon:IsShown() then
                --local role = UnitGroupRolesAssigned(self.unit)
                icon:SetAlpha(UnitGroupRolesAssigned(self.unit)== 'DAMAGER' and 0 or 1)
            end
        end)
    end
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
    CompactPartyFrame.moveFrame= e.Cbtn(CompactPartyFrame, {icon=true, size={20,20}})
    --CompactPartyFrame.moveFrame:SetFrameStrata('MEDIUM')
    CompactPartyFrame.moveFrame:SetAlpha(0.3)
    CompactPartyFrame.moveFrame:SetPoint('TOP', CompactPartyFrame, 'TOP',0, 10)
    CompactPartyFrame.moveFrame:SetClampedToScreen(true)
    CompactPartyFrame.moveFrame:SetMovable(true)
    CompactPartyFrame.moveFrame:RegisterForDrag('RightButton')
    CompactPartyFrame.moveFrame:SetScript("OnDragStart", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            local frame= self:GetParent()
            if not frame:IsMovable() then
                frame:SetMovable(true)
            end
            frame:StartMoving()
        end
    end)
    CompactPartyFrame.moveFrame:SetScript("OnDragStop", function(self)
        local frame=self:GetParent()
        frame:StopMovingOrSizing()
        frame:Raise()
    end)
    CompactPartyFrame.moveFrame:SetScript("OnMouseDown", function(_, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=="LeftButton" then
            print(id, addName, (e.onlyChinese and '移动' or NPE_MOVE)..e.Icon.right, 'Alt+'..e.Icon.mid..(e.onlyChinese and '缩放' or UI_SCALE), Save.compactPartyFrameScale or 1)
        end
    end)
    CompactPartyFrame.moveFrame:SetScript("OnLeave", ResetCursor)
    CompactPartyFrame.moveFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            if UnitAffectingCombat('player') then
                print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or COMBAT))
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
                print(id, addName, (e.onlyChinese and '缩放' or UI_SCALE), sacle)
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

local function set_ToggleWarMode()--设置, 战争模式
    if C_PvP.CanToggleWarModeInArea() then
        local isWar= C_PvP.IsWarModeDesired()
        if not PlayerFrame.warMode then
            PlayerFrame.warMode= e.Cbtn(PlayerFrame, {size={20,20}, icon='hide'})
            PlayerFrame.warMode:Raise()
            PlayerFrame.warMode:SetPoint('LEFT', PlayerFrame, 10, 12)
            PlayerFrame.warMode:SetScript('OnClick',  C_PvP.ToggleWarMode)
            PlayerFrame.warMode:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE, e.GetEnabeleDisable(C_PvP.IsWarModeDesired())..e.Icon.left)
                if not C_PvP.CanToggleWarMode(false)  then
                    e.tips:AddLine(e.onlyChinese and '当前不能操作' or SPELL_FAILED_NOT_HERE, 1,0,0)
                end
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end)
            PlayerFrame.warMode:SetScript('OnLeave', function() e.tips:Hide() end)
        end
        PlayerFrame.warMode:SetNormalAtlas(isWar and 'pvptalents-warmode-swords' or 'pvptalents-warmode-swords-disabled')
        PlayerFrame.warMode:SetShown(true)
    elseif PlayerFrame.warMode then
        PlayerFrame.warMode:SetShown(false)
    end
end














--#########
--BossFrame
--#########
local function Init_BossFrame()

    for i=1, MAX_BOSS_FRAMES do
        local frame= _G['Boss'..i..'TargetFrame']
        frame.BossButton= e.Cbtn(frame, {size={38,38}, type=true, icon='hide', pushe=true})--CreateFrame('Frame', nil, frame, 'SecureActionButtonTemplate')

        frame.BossButton:SetPoint('LEFT', frame.TargetFrameContent.TargetFrameContentMain.HealthBar, 'RIGHT')
        frame.BossButton:Raise()
  
        frame.BossButton:SetAttribute('type', 'target')
        frame.BossButton:SetAttribute('unit', frame.unit)
        frame.BossButton:SetScript('OnLeave', function() e.tips:Hide() end)
        frame.BossButton:SetScript('OnEnter', function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, self);
            e.tips:ClearLines()
            e.tips:SetUnit(self.unit)
            e.tips:Show()
        end)

        frame.BossButton.Portrait= frame.BossButton:CreateTexture(nil, 'BACKGROUND')
        frame.BossButton.Portrait:SetAllPoints(frame.BossButton)

        frame.BossButton.targetTexture= frame.BossButton:CreateTexture(nil, 'OVERLAY')
        frame.BossButton.targetTexture:SetSize(52,52)
        frame.BossButton.targetTexture:SetPoint('CENTER')
        frame.BossButton.targetTexture:SetAtlas('DK-Blood-Rune-CDFill')

        frame.BossButton.unit= frame.unit

        function frame.BossButton:set_settings()
            local unit= BossTargetFrameContainer.isInEditMode and 'player' or self.unit
            local exists=UnitExists(unit)
            if exists then
                SetPortraitTexture(self.Portrait, unit)
            end
            self.Portrait:SetShown(exists)
            self.targetTexture:SetShown(exists and UnitIsUnit('target', unit))
        end

        function frame.BossButton:set_event()
            if not UnitExists(self.unit) then
                self:UnregisterAllEvents()
            else
                self:RegisterEvent('PLAYER_TARGET_CHANGED')
                self:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', self.unit)
                self:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT')
            end
            C_Timer.After(0.3, function() self:set_settings() end)
        end

        frame.BossButton:SetScript('OnEvent', function(self)
            self:set_settings()
        end)
        frame.BossButton:set_event()



        --目标的目标，点击
        --##############
        frame.TotButton=e.Cbtn(frame, {size={38,38}, type=true, icon='hide', pushe=true})
        frame.TotButton:SetPoint('TOPLEFT', frame.BossButton, 'TOPRIGHT', 4,0)
        frame.TotButton:SetAttribute('type', 'target')
        frame.TotButton:SetAttribute('unit', frame.unit..'target')
        frame.TotButton:SetScript('OnLeave', function() e.tips:Hide() end)
        frame.TotButton:SetScript('OnEnter', function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, self);
            e.tips:ClearLines()
            if UnitExists(self.targetUnit) then
                e.tips:SetUnit(self.targetUnit)
            else
                e.tips:AddDoubleLine(id, addName)
                e.tips:AddDoubleLine(e.onlyChinese and '目标的目标' or SHOW_TARGET_OF_TARGET_TEXT, self.targetUnit)
            end
            e.tips:Show()
        end)
        frame.TotButton.unit= frame.unit
        frame.TotButton.targetUnit= frame.unit..'target'

        --目标的目标，信息
        frame.TotButton.frame= CreateFrame('Frame', nil, frame.TotButton)
        frame.TotButton.frame:SetFrameLevel(frame.TotButton:GetFrameLevel()-1)
        frame.TotButton.frame:SetAllPoints(frame.TotButton)
        frame.TotButton.frame:Hide()
        frame.TotButton.frame.unit= frame.unit
        frame.TotButton.frame.targetUnit= frame.unit..'target'

        --目标的目标，图像
        frame.TotButton.frame.Portrait= frame.TotButton.frame:CreateTexture(nil, 'BACKGROUND')
        frame.TotButton.frame.Portrait:SetAllPoints(frame.TotButton.frame)

        

        --目标的目标，外框
        frame.TotButton.frame.Border= frame.TotButton.frame:CreateTexture(nil, 'ARTWORK')
        frame.TotButton.frame.Border:SetSize(44,44)
        frame.TotButton.frame.Border:SetPoint('CENTER',2,-2)
        frame.TotButton.frame.Border:SetAtlas('UI-HUD-UnitFrame-TotemFrame')

        --目标的目标， 是我的目标
        --[[frame.TotButton.frame.IsTargetTexture=frame.TotButton.frame:CreateTexture(nil, 'OVERLAY')
        frame.TotButton.frame.IsTargetTexture:SetSize(32,32)
        frame.TotButton.frame.IsTargetTexture:SetPoint('CENTER')
        frame.TotButton.frame.IsTargetTexture:SetAtlas('DK-Blood-Rune-CDFill')

        目标的目标，生命条
        frame.TotButton.frame.healthBar= CreateFrame('StatusBar', nil, frame.TotButton.frame)
        frame.TotButton.frame.healthBar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
        frame.TotButton.frame.healthBar:SetSize(44, 8)
        frame.TotButton.frame.healthBar:SetMinMaxValues(0,100)
        frame.TotButton.frame.healthBar:SetPoint('TOP', frame.TotButton.frame, 'BOTTOM',4,2)]]

        --目标的目标，百份比
        frame.TotButton.frame.healthLable= e.Cstr(frame.TotButton.frame,{color={r=1,g=1,b=1}, size=14})
        frame.TotButton.frame.healthLable:SetPoint('BOTTOM')--, frame.TotButton.frame, 'RIGHT')

        frame.TotButton.frame:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= (self.elapsed or 0.3) +elapsed
            if self.elapsed>0.3 then
                local unit= BossTargetFrameContainer.isInEditMode and 'player' or self.targetUnit
                local text=''
                local value, max= UnitHealth(unit), UnitHealthMax(unit)
                value= (not value or value<=0) and 0 or value
                if value and max and max>0 then
                    local per= value/max*100
                    --self.healthBar:SetValue(per)
                    text= format('%0.f', per)
                end
                self.healthLable:SetText(text)
            end
        end)

        function frame.TotButton.frame:set_settings()
            local unit= BossTargetFrameContainer.isInEditMode and 'player' or self.targetUnit
            local exists=UnitExists(unit)
            if exists then
                --图像
                if BossTargetFrameContainer.isInEditMode then
                    SetPortraitTexture(self.Portrait, unit)
                    --frame.TargetFrameContent.TargetFrameContentMain.ManaBar:Show()
                elseif not UnitIsUnit(unit, 'player') then--自已
                    self.Portrait:SetAtlas('quest-important-available')
                elseif UnitIsUnit(unit, 'target') then
                    self.Portrait:SetAtlas('common-icon-checkmark')
                else
                    local index = GetRaidTargetIndex(unit)
                    if index and index>0 and index< 9 then
                        self.Portrait:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
                    else
                        SetPortraitTexture(self.Portrait, unit)--别人
                    end
                end
                --颜色
                local r,g,b
                local class= UnitClassBase(unit)
                if class then
                    r, g, b= GetClassColor(class)
                end
                r,g,b= r or 1, g or 1, b or 1

                --self.healthBar:SetStatusBarColor(r,g,b)
                    --self.IsTargetTexture:SetShown(UnitIsUnit(self.targetUnit, 'target'))
                    self.Border:SetVertexColor(0,1,0)
                
                    self.Border:SetVertexColor(r,g,b)
                
                self.healthLable:SetTextColor(r,g,b)
            end
            self:SetShown(exists)

        end

        function frame.TotButton.frame:set_event()
            if not UnitExists(self.unit) then
                self:UnregisterAllEvents()
            else
                self:RegisterUnitEvent('UNIT_TARGET', self.unit)
                self:RegisterEvent('RAID_TARGET_UPDATE')
                self:RegisterEvent('PLAYER_TARGET_CHANGED')
            end
            self:set_settings()
        end

        frame.TotButton.frame:SetScript('OnEvent', function(self)
            self:set_settings()
        end)

        frame.TotButton.frame:set_event()


        frame:HookScript('OnShow', function(self)
            C_Timer.After(0.5, function()
                self.BossButton:set_event()
                self.TotButton.frame:set_event()
            end)
        end)
        frame:HookScript('OnHide', function(self)
            self.BossButton:set_event()
            self.TotButton.frame:set_event()
        end)
    end

    --设置位置
    local function set_TotButton_point()
        for i=1, MAX_BOSS_FRAMES do
            local frame= _G['Boss'..i..'TargetFrame']
            if frame.TotButton then
                print( Boss1TargetFrameSpellBar.castBarOnSide , BossTargetFrameContainer.smallSize)
                frame.TotButton:ClearAllPoints()
                --Boss1TargetFrameSpellBar.castBarOnSide 施法条左边
                if Boss1TargetFrameSpellBar.castBarOnSide then
                    frame.TotButton:SetPoint('TOPLEFT', frame.TargetFrameContent.TargetFrameContentMain.ManaBar, 'BOTTOMLEFT')
                else
                    frame.TotButton:SetPoint('RIGHT', frame.TargetFrameContent.TargetFrameContentMain.HealthBar, 'LEFT',-2,0)
                end
                if Boss1TargetFrameSpellBar.castBarOnSide and not BossTargetFrameContainer.smallSize then
                   frame.TotButton:SetScale(0.75)
                else
                   frame.TotButton:SetScale(1)
                end
            end
        end
    end
    hooksecurefunc(Boss1TargetFrameSpellBar,'AdjustPosition', function()
        set_TotButton_point()
    end)
    hooksecurefunc(BossTargetFrameContainer, 'SetSmallSize', function()
        set_TotButton_point()
    end)

end



















--######
--初始化
--######
local function Init()
    set_CompactPartyFrame()--小队, 使用团框架

    hooksecurefunc(CompactPartyFrame,'UpdateVisibility', set_CompactPartyFrame)

    Init_PlayerFrame()--玩家
    Init_TargetFrame()--目标
    Init_PartyFrame()--小队
    Init_UnitFrame_Update()--职业, 图标， 颜色
    Init_BossFrame()

    --###############
    --MirrorTimer.lua
    --###############
    hooksecurefunc(MirrorTimerContainer, 'SetupTimer', function(frame)--, value)
        for _, activeTimer in pairs(frame.activeTimers) do
            if not activeTimer.valueText then
                activeTimer.valueText=e.Cstr(activeTimer, {justifyH='RIGHT'})
                activeTimer.valueText:SetPoint('BOTTOMRIGHT',-7, 4)
                activeTimer.valueText:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
                activeTimer.Text:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
                hooksecurefunc(activeTimer, 'UpdateStatusBarValue', function(self)
                    self.valueText:SetText(format('%i', self.StatusBar:GetValue()))
                end)
            end
        end
    end)

    C_Timer.After(2, set_ToggleWarMode)--设置, 战争模式
end






















--####
--团队
--CompactUnitFrame.lua
local function Init_RaidFrame()--设置,团队
    hooksecurefunc('CompactUnitFrame_SetUnit', function(frame, unit)--队伍标记
        if UnitExists(unit) and not unit:find('nameplate') and not frame.RaidTargetIcon and frame.name then
            frame.RaidTargetIcon= frame:CreateTexture(nil,'OVERLAY', nil, 7)
            frame.RaidTargetIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')
            frame.RaidTargetIcon:SetPoint('TOPRIGHT')
            frame.RaidTargetIcon:SetSize(13,13)
            set_RaidTarget(frame.RaidTargetIcon, unit)
        end
        frame.unitItemLevel=nil--取得装等
    end)
    hooksecurefunc('CompactUnitFrame_UpdateUnitEvents', function(frame)
        if frame.RaidTargetIcon then
            frame:RegisterEvent("RAID_TARGET_UPDATE")
        end
    end)
    hooksecurefunc('CompactUnitFrame_UnregisterEvents', function(frame)
        if frame.RaidTargetIcon then
            frame:UnregisterEvent("RAID_TARGET_UPDATE")
            frame:UnregisterEvent("UNIT_TARGET")
        end
    end)
    hooksecurefunc('CompactUnitFrame_OnEvent', function(self, event)
        if self.RaidTargetIcon and self.unit then
            if event=='RAID_TARGET_UPDATE'then
                set_RaidTarget(self.RaidTargetIcon, self.unit)
            end
        end
    end)

    hooksecurefunc('CompactUnitFrame_UpdateRoleIcon', function(frame)--隐藏, DPS，图标 
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

    hooksecurefunc('CompactUnitFrame_UpdateName', function(frame)--修改, 名字
        if not UnitExists(frame.unit) or frame.unit:find('nameplate') or not frame.name or (frame.UpdateNameOverride and frame:UpdateNameOverride()) or not ShouldShowName(frame) then
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

    --[[hooksecurefunc('CompactUnitFrame_UpdateHealthColor', function(frame)--颜色
        if frame.unit:find('pet') and frame.healthBar then
            local class= UnitClassBase(frame.unit)
            if class then
                local r, g, b= GetClassColor(class)
                if r and g and b then
                    frame.healthBar:SetStatusBarColor(r,g,b)
                    frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b
                end
            end
        end
    end)]]

    hooksecurefunc('CompactUnitFrame_UpdateStatusText', function(frame)--去掉,生命条, %
        if not UnitExists(frame.unit) or frame.unit:find('nameplate') or not frame.statusText or not frame.statusText:IsShown() or frame.optionTable.healthText ~= "perc" then
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
        frame.title:SetText('|A:'..e.Icon.number..groupIndex..':18:18|a')
    end)


    --新建, 移动, 按钮
    CompactRaidFrameContainer:SetClampedToScreen(true)
    CompactRaidFrameContainer:SetMovable(true)

    CompactRaidFrameContainer.moveFrame= e.Cbtn(CompactRaidFrameContainer, {icon= true, size={22,22}})--IsEveryoneAssistant() hooksecurefunc('RaidFrameAllqbCheckButton_UpdateAvailable', function()
    CompactRaidFrameContainer.moveFrame:SetPoint('TOPRIGHT', CompactRaidFrameContainer, 'TOPLEFT',-2, -13)

    CompactRaidFrameContainer.moveFrame:SetClampedToScreen(true)
    CompactRaidFrameContainer.moveFrame:SetMovable(true)
    CompactRaidFrameContainer:SetMovable(true)
    CompactRaidFrameContainer.moveFrame:RegisterForDrag('RightButton')
    CompactRaidFrameContainer.moveFrame:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            local frame= self:GetParent()
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
    CompactRaidFrameContainer.moveFrame:SetScript("OnMouseDown", function()
        if IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    function CompactRaidFrameContainer.moveFrame:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        local col= UnitAffectingCombat('player') and '|cff606060' or ''
        e.tips:AddDoubleLine(col..(e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.raidFrameScale or 1), col..'Alt+'..e.Icon.mid)
        e.tips:Show()
        self:SetAlpha(1)
    end
    function CompactRaidFrameContainer.moveFrame:set_Scale()
        self:GetParent():SetScale(Save.raidFrameScale or 1)
    end
    CompactRaidFrameContainer.moveFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() and not UnitAffectingCombat('player') then
            local num= Save.raidFrameScale or 1
            if d==1 then
                num= num+0.05
            elseif d==-1 then
                num= num-0.05
            end
            num= num>4 and 4 or num
            num= num<0.4 and 0.4 or num
            Save.raidFrameScale= num
            self:set_Scale()
            self:set_Tooltips()
            print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, num)
        end
    end)
    CompactRaidFrameContainer.moveFrame:SetScript("OnLeave", function(self)
        e.tips:Hide()
        self:SetAlpha(0.1)
    end)
    CompactRaidFrameContainer.moveFrame:SetScript('OnEnter', CompactRaidFrameContainer.moveFrame.set_Tooltips)
    CompactRaidFrameContainer.moveFrame:set_Scale()
    CompactRaidFrameContainer.moveFrame:SetAlpha(0.1)




    --团体, 管理, 缩放
    CompactRaidFrameManager.sacleFrame= e.Cbtn(CompactRaidFrameManager, {icon=true, size={15,15}})
    CompactRaidFrameManager.sacleFrame:SetPoint('RIGHT', CompactRaidFrameManagerDisplayFrameRaidMemberCountLabel, 'LEFT')
    CompactRaidFrameManager.sacleFrame:SetAlpha(0.5)
    CompactRaidFrameManager.sacleFrame:SetScript("OnMouseDown", function(self, d)
        print(id, addName, 'Alt+'..e.Icon.mid..(e.onlyChinese and '缩放' or UI_SCALE), Save.managerScale or 1)
    end)
    CompactRaidFrameManager.sacleFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            if UnitAffectingCombat('player') then
                print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or COMBAT))
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
                print(id, addName, (e.onlyChinese and '缩放' or UI_SCALE), sacle)
                CompactRaidFrameManager:SetScale(sacle)
                Save.managerScale=sacle
            end
        end
    end)
    if Save.managerScale and Save.managerScale~=1 then
        CompactRaidFrameManager:SetScale(Save.managerScale)
    end

    --[[hooksecurefunc('CompactUnitFrame_UpdateDistance', function(frame)--取得装等, 高CPU
        if not frame.unitItemLevel and UnitExists(frame.unit) and CheckInteractDistance(frame.unit, 1) and CanInspect(frame.unit) then --frame.inDistance and frame.inDistance< DISTANCE_THRESHOLD_SQUARED then
            NotifyInspect(frame.unit)--取得装等
            local guid= UnitGUID(frame.unit)
            if guid and e.UnitItemLevel[guid] then
                frame.unitItemLevel= e.UnitItemLevel[guid].itemLevel
            end
        end
    end)]]

    hooksecurefunc('CompactUnitFrame_UpdateStatusText', function(frame)
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
            frame.statusText:SetText(e.MK(UnitHealth(frame.displayedUnit), 0))
        elseif ( frame.optionTable.healthText == "losthealth" ) then
            local healthLost = UnitHealthMax(frame.displayedUnit) - UnitHealth(frame.displayedUnit)
            if ( healthLost > 0 ) then
                frame.statusText:SetText('-'..e.MK(healthLost, 0))
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
end





















--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')--拾取专精
panel:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED','player')

panel:RegisterEvent('PLAYER_ENTERING_WORLD')--副本, 地下城，指示
local dungeonDifficultyStr= ERR_DUNGEON_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"地下城难度已设置为%s。"
local raidDifficultyStr= ERR_RAID_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"团队副本难度设置为%s。"
local legacyRaidDifficultyStr= ERR_LEGACY_RAID_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"已将经典团队副本难度设置为%s。"

panel:RegisterEvent('GROUP_ROSTER_UPDATE')--挑战，数据
panel:RegisterEvent('GROUP_LEFT')

panel:RegisterEvent('PLAYER_FLAGS_CHANGED')--设置, 战争模式
panel:RegisterEvent('PLAYER_UPDATE_RESTING')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            local initializer2= e.AddPanel_Check({
                name= '|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged:0:0|a'..(e.onlyChinese and '单位框体' or addName),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            local initializer= e.AddPanel_Check({
                name= e.onlyChinese and '团队框体' or HUD_EDIT_MODE_RAID_FRAMES_LABEL,
                tooltip= addName,
                value= not Save.notRaidFrame,
                func= function()
                    Save.notRaidFrame= not Save.notRaidFrame and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })
            initializer:SetParentInitializer(initializer2, function() return true end)


            if not Save.notRaidFrame then
                Init_RaidFrame()--团队
            end

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_ChallengesUI' then--挑战,钥石,插入界面
            C_Timer.After(2, set_Keystones_Date)--挑战，数据
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_LOOT_SPEC_UPDATED' or event=='PLAYER_SPECIALIZATION_CHANGED' then
        set_LootSpecialization()--拾取专精

    elseif event=='PLAYER_ENTERING_WORLD' then--副本, 地下城，指示
        if not IsInInstance() then
            self:RegisterEvent('CHAT_MSG_SYSTEM')
        else
            self:UnregisterEvent('CHAT_MSG_SYSTEM')
        end

        C_MythicPlus.RequestMapInfo()
        C_Timer.After(2, function()
            set_Instance_Difficulty()--副本, 地下城，指示
            set_Keystones_Date()--挑战，数据
            set_ToggleWarMode()--设置, 战争模式
        end)


    elseif event=='PLAYER_FLAGS_CHANGED' or event=='PLAYER_UPDATE_RESTING' then
        C_Timer.After(1, set_ToggleWarMode)--设置, 战争模式

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        C_Timer.After(2, set_Keystones_Date)--挑战，数据

    elseif event=='CHAT_MSG_SYSTEM' then--"地下城难度已设置为%s。团队副本难度设置为%s。已将经典团队副本难度设置为%s。
        if arg1 and (arg1:find(dungeonDifficultyStr) or arg1:find(raidDifficultyStr) or arg1:find(legacyRaidDifficultyStr)) then
            set_Instance_Difficulty()--副本, 地下城，指示
        end
    end
end)


--[[
    EditModeSettingDisplayInfo.lua
    for index, tab in pairs(EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame]) do
        if tab.name==HUD_EDIT_MODE_SETTING_UNIT_FRAME_WIDTH  then-- Frame Width
            EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame][index].minValue=36
        elseif tab.name==HUD_EDIT_MODE_SETTING_UNIT_FRAME_HEIGHT then
            EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame][index].minValue=18
        end
    end
]]
