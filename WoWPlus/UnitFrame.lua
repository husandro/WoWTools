local id, e = ...
local addName= UNITFRAME_LABEL
local Save={
    raidFrameScale=0.8,
    notRaidFrame=not e.Player.husandro
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
    if not self or not self.keystoneText then
        return
    elseif IsInInstance() then
        self.keystoneText:SetText('')
        return
    end

    local text
    local score= C_ChallengeMode.GetOverallDungeonScore()
    if score and score>0 then
        text= e.GetKeystoneScorsoColor(score)
        local info = C_MythicPlus.GetRunHistory(false, true)--本周记录
        if info then
            local num= 0
            local level--, completed
            for _, runs  in pairs(info) do
                if runs and runs.level then
                    num= num+ 1
                    if not level or level< runs.level then
                        level= runs.level
                        --completed= runs.completed
                    end
                end
            end
            if num>0 and level then
                text= text..' ('..level..') '..num
            end
        end
    end
    self.keystoneText:SetText(text or '')
end

--####
--玩家
--####
local function set_PlayerFrame()--PlayerFrame.lua
    hooksecurefunc('PlayerFrame_UpdateLevel', function()
        set_SetTextColor(PlayerLevelText, e.Player.r, e.Player.g, e.Player.b)
    end)

    --施法条
    PlayerCastingBarFrame:HookScript('OnShow', function(self)--图标
        self.Icon:SetShown(true)
        self:Raise()--设置为， 最上层
    end)

    PlayerCastingBarFrame.castingText= e.Cstr(PlayerCastingBarFrame, {color={r=e.Player.r, g=e.Player.g, b=e.Player.b}, justifyH='RIGHT'})
    PlayerCastingBarFrame.castingText:SetDrawLayer('OVERLAY', 2)
    PlayerCastingBarFrame.castingText:SetPoint('RIGHT', PlayerCastingBarFrame.ChargeFlash, 'RIGHT')
    PlayerCastingBarFrame.elapsed=1
    PlayerCastingBarFrame:HookScript('OnUpdate', function(self, elapsed)--玩家, 施法, 时间
        self.elapsed= self.elapsed+ elapsed
        if self.elapsed>=0.1 and self.value and self.maxValue then
            local value= self.channeling and self.value or (self.maxValue-self.value)
            if value<=0 then
                self.castingText:SetText(0)
            elseif value>=3 then
                self.castingText:SetFormattedText('%i', value)
            else
                self.castingText:SetFormattedText('%.01f', value)
            end
            self.elapsed=0
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

    if PlayerHitIndicator then--玩家
        PlayerHitIndicator:ClearAllPoints()
        PlayerHitIndicator:SetPoint('BOTTOMLEFT', (PlayerFrame.PlayerFrameContainer and PlayerFrame and PlayerFrame.PlayerFrameContainer.PlayerPortrait) or  PlayerHitIndicator:GetParent(), 'TOPLEFT')
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

    



    TargetFrame.rangeText= e.Cstr(TargetFrame, {justifyH='RIGHT'})
    TargetFrame.rangeText:SetPoint('RIGHT', TargetFrame, 'LEFT', 22,0)
    TargetFrame.elapsed2= 0.4
    hooksecurefunc(TargetFrame, 'OnUpdate', function(self, elapsed)
        self.elapsed2= self.elapsed2+ elapsed
        if self.elapsed2>0.3 then
            local mi, ma= e.GetRange('target')
            local text
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
            self.rangeText:SetText(text or '')
            self.elapsed2=0
        end
    end)
end


--####
--小队
--####
local function set_PartyFrame()--PartyFrame.lua
    local function set_UpdatePartyFrames(self)
        for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
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
                frame= e.Cbtn(memberFrame, {type=true, size={35,35}, icon='hide'})
                --frame:SetFrameLevel(memberFrame:GetFrameLevel()+1)
                frame:SetPoint('LEFT', memberFrame, 'RIGHT', -3, 4)
                frame:SetAttribute('type', 'target')
                frame:SetAttribute('unit', unit..'target')

                frame.set_Party_Target_Changed= function(self2)
                    local text
                    local exists2= UnitExists(self2.unit)
                    if exists2 then
                        if UnitIsUnit(self2.unit, 'player') then--我
                            self2.Portrait:SetAtlas('auctionhouse-icon-favorite')
                        elseif UnitIsDeadOrGhost(self2.unit) then--死亡
                            self2.Portrait:SetAtlas('xmarksthespot')
                        else
                            local index = GetRaidTargetIndex(self2.unit)
                            if index and index>0 and index< 9 then--标记
                                self2.Portrait:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
                            else
                                SetPortraitTexture(self2.Portrait, self2.unit, true)--图像
                            end
                        end
                        text= UnitIsPlayer(self2.unit) and e.Class(self2.unit)
                        local r2, g2, b2= GetClassColor(UnitClassBase(self2.unit))
                        self2.healthBar:SetStatusBarColor(r2 or 1, g2 or 1, b2 or 1, 1)
                    end
                    self2.Portrait:SetShown(exists2)--队友，目标，图像
                    self2.Text:SetText(text or '')--队友，目标，职业
                    self2.healthBar:SetShown(exists2)--队友， 目标， 生命条
                    self2.healthBar.elapsed=1
                end
                frame:SetScript('OnLeave', function() e.tips:Hide() end)
                frame:SetScript('OnEnter', function(self2)
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    if  UnitExists(self2.unit) then
                        e.tips:SetUnit(self2.unit)
                    else
                        e.tips:AddDoubleLine(' ',e.Icon.left..(e.onlyChinese and '选中目标' or BINDING_HEADER_TARGETING))
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(id, addName)
                    end
                    e.tips:Show()
                end)
                frame:SetScript('OnEvent', function(self2)
                    self2.set_Party_Target_Changed(self2)
                end)
                frame.unit= unit..'target'

                frame.Portrait= frame:CreateTexture(nil, 'BACKGROUND')--队友，目标，图像
                frame.Portrait:SetAllPoints(frame)

                frame.Text= e.Cstr(frame, {size=14})--队友，目标，职业
                frame.Text:SetPoint('BOTTOMRIGHT',3,-2)

                frame.healthBar= CreateFrame('StatusBar', nil, frame)--队友， 目标， 生命条
                frame.healthBar:SetSize(55, 8)
                frame.healthBar:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT')
                frame.healthBar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
                frame.healthBar:SetMinMaxValues(0,100)
                frame.healthBar:SetFrameLevel(frame:GetFrameLevel()+7)
                frame.healthBar.elapsed=0
                frame.healthBar.unit= unit..'target'
                frame.healthBar:SetScript('OnUpdate', function(self2, elapsed)
                    self2.elapsed= self2.elapsed +elapsed
                    if self2.elapsed>0.75 then
                        local cur= UnitHealth(self2.unit)
                        local max= UnitHealthMax(self2.unit)
                        if max and max>0 then
                            local value= cur/max*100
                           self2:SetValue(value)
                           self2.Text:SetFormattedText('%i', value)
                        else
                            self2:SetShown(false)
                        end
                        self2.elapsed=0
                    end
                end)

                local texture= frame.healthBar:CreateTexture(nil, 'BACKGROUND')--队友，目标，生命条，外框
                texture:SetAtlas('MainPet-HealthBarFrame')
                texture:SetAllPoints(frame.healthBar)
                texture:SetVertexColor(1,0,0)

                frame.healthBar.Text= e.Cstr(frame.healthBar)
                frame.healthBar.Text:SetPoint('RIGHT')
                frame.healthBar.Text:SetTextColor(1,1,1)

                memberFrame.potFrame= frame
            end
            frame:UnregisterAllEvents()
            if exists then
                frame:RegisterEvent('RAID_TARGET_UPDATE')
                frame:RegisterUnitEvent('UNIT_TARGET', unit)
                frame:RegisterUnitEvent('UNIT_FLAGS', unit..'target')
                frame:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', unit..'target')
            end
            frame.set_Party_Target_Changed(frame)

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
                frame.set_Party_Casting= function(self2)
                    local texture, startTime, endTime, find, channel
                    if UnitExists(self2.unit) then
                        texture, startTime, endTime= select(3, UnitChannelInfo(self2.unit))
                        if not (texture and  startTime and endTime) then
                            texture, startTime, endTime= select(3, UnitCastingInfo(self2.unit))
                        else
                            channel= true
                        end
                        if texture and startTime and endTime then
                            local duration=(endTime - startTime) / 1000
                            e.Ccool(self2, nil, duration, nil, true, channel, nil,nil)
                            find=true
                        end
                    end
                    self2.texture:SetTexture(texture or 0)
                    if not find and self2.cooldown then
                        self2.cooldown:Clear()
                    end
                    self2:SetShown(find)
                end
                frame:SetScript('OnEvent', function (self2, _, _, _, spellID)
                    self2.set_Party_Casting(self2)
                    self2.spellID= spellID
                end)
                frame:SetScript('OnLeave', function() e.tips:Hide() end)
                frame:SetScript('OnEnter', function(self2)
                    if self2.spellID then
                        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:SetSpellByID(self2.spellID)
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
            frame.set_Party_Casting(frame)

            --##########
            --队伍, 标记
            --##########
            frame= memberFrame.RaidTargetFrame
            if not frame then
                frame= CreateFrame("Frame", nil, memberFrame)
                frame:SetSize(14,14)
                frame:SetPoint('RIGHT', memberFrame.PartyMemberOverlay.RoleIcon, 'LEFT')
                frame:SetScript('OnEvent', function (self2)
                    set_RaidTarget(self2.RaidTargetIcon, self2.unit)
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
                frame:SetPoint('TOPLEFT', memberFrame.potFrame, 'TOPRIGHT',2,2)
                frame:SetSize(16,16)
                frame:SetScript('OnLeave', function() e.tips:Hide() end)
                frame:SetScript('OnEnter', function(self2)
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
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
                frame.elapsed=0
                frame:SetScript('OnUpdate', function(self2, elapsed)
                    self2.elapsed= self2.elapsed +elapsed
                    if self2.elapsed>0.5 then
                        self2.texture:SetShown(UnitAffectingCombat(self2.unit))
                        self2.elapsed=0
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
                frame.set_Shown= function(self2)
                    self2:SetShown(not IsInInstance() and UnitExists(self2.unit))
                end
                frame:SetScript('OnEvent', function(self2)
                    self2.set_Shown(self2)
                end)
                frame.Text= e.Cstr(frame)
                frame.Text:SetPoint('LEFT')
                frame.elapsed= 0
                frame:SetScript('OnUpdate', function(self2, elapsed)
                    self2.elapsed= self2.elapsed +elapsed
                    if self2.elapsed>1 then
                        local mapID= C_Map.GetBestMapForUnit(self2.unit)--地图ID
                        local mapInfo= mapID and C_Map.GetMapInfo(mapID)
                        local text
                        local distanceSquared, checkedDistance = UnitDistanceSquared(self2.unit)
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
                        self2.Text:SetText(text or '')
                        self2.elapsed=0
                    end
                end)
                frame.unit= unit
                memberFrame.positionFrame= frame
            end
            frame:RegisterAllEvents()
            if exists then
                frame:RegisterEvent('PLAYER_ENTERING_WORLD')
                frame.Text:SetTextColor(r, g, b)
            end
            frame:set_Shown(frame)

            --#########
            --队友，死亡
            --#########
            frame= memberFrame.deadFrame
            if not frame then
                frame= CreateFrame('Frame', nil, memberFrame)
                frame:SetPoint("CENTER", memberFrame.Portrait)
                frame:SetSize(37,37)
                frame:SetFrameStrata('HIGH')
                frame.texture= frame:CreateTexture()
                frame.texture:SetAllPoints(frame)
                frame.set_Active= function(self2)
                    local find= false
                    if UnitIsConnected(self2.unit) and not UnitIsFeignDeath(self2.unit) then
                        if UnitIsDead(self2.unit) then
                            self2.texture:SetAtlas('xmarksthespot')
                            find= true
                            if not self2.deadBool then--死亡，次数
                                self2.deadBool=true
                                self2.dead= self2.dead +1
                            end
                        elseif UnitIsGhost(self2.unit) then
                            self2.texture:SetAtlas('poi-soulspiritghost')
                            find= true
                        else
                            self2.deadBool= nil
                        end
                    end
                    self2:SetShown(find)
                    self2.deadText:SetText(self2.dead>0 and self2.dead or '')
                end
                frame:SetScript('OnEvent', function(self2, event)
                    if event=='PLAYER_ENTERING_WORLD' or event=='CHALLENGE_MODE_START' then
                        self2.dead= 0
                    end
                    self2:set_Active(self2)
                end)

                --死亡，次数
                frame.dead=0
                frame.deadText= e.Cstr(frame, {mouse=true})
                frame.deadText:SetPoint('BOTTOMLEFT', frame)
                frame.deadText:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
                frame.deadText:SetScript('OnEnter', function(self2)
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(e.onlyChinese and '死亡' or DEAD, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, self2:GetParent().dead or 0 ,  e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:Show()
                    self2:SetAlpha(0.3)
                end)

                frame.unit= unit
                memberFrame.deadFrame= frame
            end
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
            frame:set_Active(frame)
        end
    end

    set_UpdatePartyFrames(PartyFrame)--先使用一次，用以Shift+点击，设置焦点功能, Invite.lua
    hooksecurefunc(PartyFrame, 'UpdatePartyFrames', set_UpdatePartyFrames)

    --##############
    --隐藏, DPS 图标
    --##############
    for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        hooksecurefunc(memberFrame, 'UpdateAssignedRoles', function(self2)--隐藏, DPS 图标
            if UnitGroupRolesAssigned(self2.unit)=='DAMAGER' then
                self2.PartyMemberOverlay.RoleIcon:SetShown(false)
            end
        end)
    end
end

--################
--职业, 图标， 颜色
--################
local function set_UnitFrame_Update()--职业, 图标， 颜色
    hooksecurefunc('UnitFrame_Update', function(self2, isParty)--UnitFrame.lua
        local unit= self2.unit
        local r,g,b
        if unit=='player' then
            r,g,b= e.Player.r, e.Player.g, e.Player.b
        else
            local classFilename= unit and UnitClassBase(unit)
            if classFilename then
                r,g,b=GetClassColor(classFilename)
            end
        end
        if not UnitExists(unit) or not (r and g and b) then
            return
        end
       
        local guid
        local unitIsPlayer=  UnitIsPlayer(unit)
        if unitIsPlayer then
            guid= UnitGUID(self2.unit)--职业, 天赋, 图标
            if not self2.classFrame then
                self2.classFrame= CreateFrame('Frame', nil, self2)
                self2.classFrame:SetShown(false)
                self2.classFrame:SetSize(16,16)
                self2.classFrame.Portrait= self2.classFrame:CreateTexture(nil, "BACKGROUND")
                self2.classFrame.Portrait:SetAllPoints(self2.classFrame)

                if self2==TargetFrame then
                    self2.classFrame:SetPoint('RIGHT', self2.TargetFrameContent.TargetFrameContentContextual.LeaderIcon, 'LEFT')
                elseif self2==PetFrame then
                    self2.classFrame:SetPoint('LEFT', self2.name,-10,0)
                elseif self2==PlayerFrame then
                    self2.classFrame:SetPoint('TOPLEFT', self2.portrait, 'TOPRIGHT',-14,8)
                elseif self2==FocusFrame then
                    self2.classFrame:SetPoint('BOTTOMRIGHT', self2.TargetFrameContent.TargetFrameContentMain.ReputationColor, 'TOPRIGHT')
                else
                    self2.classFrame:SetPoint('TOPLEFT', self2.portrait, 'TOPRIGHT',-14,10)
                end

                self2.classFrame.Texture= self2.classFrame:CreateTexture(nil, 'OVERLAY')--加个外框
                self2.classFrame.Texture:SetAtlas('UI-HUD-UnitFrame-TotemFrame-2x')

                self2.classFrame.Texture:SetPoint('CENTER', self2.classFrame, 1,-1)
                self2.classFrame.Texture:SetSize(20,20)

                function self2.classFrame:set_Class(guid3)
                    local unit2= self:GetParent().unit
                    local isPlayer= unit2 and UnitIsPlayer(unit2)
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
                self2.classFrame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', unit)
                self2.classFrame:SetScript('OnEvent', function(self3)
                    local unit2= self3:GetParent().unit
                    if UnitIsPlayer(unit2) then
                        e.GetNotifyInspect({unit2})--取得玩家信息
                        C_Timer.After(2, function()
                            self3:set_Class()
                        end)
                    end
                end)
            end
            self2.classFrame:set_Class(guid)
            self2.classFrame.Texture:SetVertexColor(r, g, b)

            if unit~='player' then
                if not self2.itemLevel then
                    self2.itemLevel= e.Cstr(self2.classFrame, {size=12})--装等
                    if unit=='target' or unit=='focus' then
                        self2.itemLevel:SetPoint('RIGHT', self2.classFrame, 'LEFT')
                    else
                        self2.itemLevel:SetPoint('TOPRIGHT', self2.classFrame, 'TOPLEFT')
                    end
                end
                self2.itemLevel:SetTextColor(r,g,b)
                self2.itemLevel:SetText(guid and e.UnitItemLevel[guid] and e.UnitItemLevel[guid].itemLevel or '')
            end
        end
        if self2.classFrame then
            self2.classFrame:SetShown(unitIsPlayer)
        end
  
        if self2==PlayerFrame and unit=='player' then
            if not self2.lootSpecFrame then-- and self2~= PetFrame and self2.PlayerFrameContainer then
                local frameLevel= self2.PlayerFrameContainer:GetFrameLevel()+1
                frameLevel= frameLevel<0 and 0 or frameLevel

                self2.lootSpecFrame= CreateFrame("Frame", nil, self2)
                self2.lootSpecFrame:SetPoint('TOPRIGHT', self2.classFrame, 'TOPLEFT', -0.5,4)
                self2.lootSpecFrame:SetSize(14,14)
                self2.lootSpecFrame:EnableMouse(true)
                self2.lootSpecFrame:SetFrameLevel(frameLevel)
                self2.lootSpecFrame.texture=self2.lootSpecFrame:CreateTexture(nil, 'BORDER')
                self2.lootSpecFrame.texture:SetAllPoints(self2.lootSpecFrame)

                local portrait= self2.lootSpecFrame:CreateTexture(nil, 'ARTWORK', nil,7)--外框
                portrait:SetAtlas('DK-Base-Rune-CDFill')
                portrait:SetPoint('CENTER', self2.lootSpecFrame)
                portrait:SetSize(20,20)
                portrait:SetVertexColor(r,g,b,1)

                local lootTipsTexture= self2.lootSpecFrame:CreateTexture(nil, "OVERLAY")
                lootTipsTexture:SetSize(10,10)
                lootTipsTexture:SetPoint('TOP',0,8)
                lootTipsTexture:SetAtlas('Banker')

                self2.lootSpecFrame:SetScript('OnLeave', function(self3) e.tips:Hide() self3:SetAlpha(1) end)
                self2.lootSpecFrame:SetScript('OnEnter', function(self3)
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

                self2.instanceFrame3= CreateFrame("Frame", nil, self2)--Riad 副本, 地下城，指示
                self2.instanceFrame3:SetFrameLevel(frameLevel)
                self2.instanceFrame3:SetPoint('RIGHT', self2.lootSpecFrame, 'LEFT',-2, 1)
                self2.instanceFrame3:SetSize(16,16)
                self2.instanceFrame3:EnableMouse(true)
                self2.instanceFrame3:SetScript('OnLeave', function(self3) e.tips:Hide() self3:SetAlpha(1) end)
                self2.instanceFrame3:SetScript('OnEnter', function(self3)
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
                self2.instanceFrame3.texture= self2.instanceFrame3:CreateTexture(nil,'BORDER', nil, 1)
                self2.instanceFrame3.texture:SetAllPoints(self2.instanceFrame3)
                self2.instanceFrame3.texture:SetAtlas('poi-torghast')

                self2.instanceFrame3.text= e.Cstr(self2.instanceFrame3, {size=8})
                self2.instanceFrame3.text:SetPoint('TOP',0,5)
                self2.instanceFrame3.text:SetTextColor(r,g,b)

                self2.instanceFrame2= CreateFrame("Frame", nil, self2)--5人 副本, 地下城，指示
                self2.instanceFrame2:SetFrameLevel(frameLevel)
                self2.instanceFrame2:SetPoint('RIGHT', self2.instanceFrame3, 'LEFT',0, -6)
                self2.instanceFrame2:SetSize(16,16)
                self2.instanceFrame2:EnableMouse(true)
                self2.instanceFrame2:SetScript('OnLeave', function(self3) e.tips:Hide() self3:SetAlpha(1) end)
                self2.instanceFrame2:SetScript('OnEnter', function(self3)
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
                self2.instanceFrame2.texture= self2.instanceFrame2:CreateTexture(nil,'BORDER', nil, 1)
                self2.instanceFrame2.texture:SetAllPoints(self2.instanceFrame2)
                self2.instanceFrame2.texture:SetAtlas('DungeonSkull')

                portrait= self2.instanceFrame2:CreateTexture(nil, 'BORDER',nil,2)--外框
                portrait:SetAtlas('DK-Base-Rune-CDFill')
                portrait:SetPoint('CENTER')
                portrait:SetSize(20,20)
                portrait:SetVertexColor(r,g,b,1)

                self2.keystoneText= e.Cstr(self2, {color=true})
                if self2.PlayerFrameContent and self2.PlayerFrameContent.PlayerFrameContentContextual and self2.PlayerFrameContent.PlayerFrameContentContextual.LeaderIcon then
                    self2.keystoneText:SetPoint('LEFT', self2.PlayerFrameContent.PlayerFrameContentContextual.LeaderIcon, 'RIGHT')
                end
                if PlayerFrameGroupIndicatorText then--移动，小队，号
                    PlayerFrameGroupIndicatorText:ClearAllPoints()
                    PlayerFrameGroupIndicatorText:SetPoint('LEFT', self2.keystoneText, 'RIGHT',12,0)
                end
            end
            set_Instance_Difficulty()--副本, 地下城，指示
            set_LootSpecialization()--拾取专精
            C_Timer.After(2, set_Keystones_Date)--挑战，数据
        end

        if self2.name then
            local name
            if UnitIsUnit(unit, 'pet') then
                self2.name:SetText(e.Icon.star2)
            else
                set_SetTextColor(self2.name, r, g, b)--名称, 颜色
                if isParty then
                    name= UnitName(unit)
                    name= e.WA_Utf8Sub(name, 4, 8)
                    self2.name:SetText(name)
                elseif unit=='target' and guid then
                    local wow= e.GetFriend(nil, guid)
                    if wow then
                        name= wow..GetUnitName(unit, false)
                    end
                end
            end
            if name then
                self2.name:SetText(name)
            end
        end

        --################
        --生命条，颜色，材质
        --################
        if self2.healthbar then
            self2.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
            self2.healthbar:SetStatusBarColor(r,g,b)--颜色
            if self2.CheckClassification and not self2.setHealthbarTexture then
                hooksecurefunc(self2, 'CheckClassification', function(self3)--外框，颜色
                    self3.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
                    local classFilename= UnitClassBase(self3.unit)
                    if classFilename then
                        local r2,g2,b2=GetClassColor(classFilename)
                        if r2 and g2 and b2 and self3.TargetFrameContainer then
                            if self3.TargetFrameContainer.FrameTexture then
                                self3.TargetFrameContainer.FrameTexture:SetVertexColor(r2,g2,b2)
                            end
                            if self3.TargetFrameContainer.BossPortraitFrameTexture:IsShown() then
                                self3.TargetFrameContainer.BossPortraitFrameTexture:SetVertexColor(r2,g2,b2)
                            end
                        end
                    end
                end)
                self2.setHealthbarTexture =true
            end
        end
    end)


    hooksecurefunc('UnitFrame_OnEvent', function(self, event, unit)--修改, 宠物, 名称
        if unit== 'pet' and unit == self.unit and event == "UNIT_NAME_UPDATE" then
            self.name:SetText('')
        end
    end)

    --############
    --去掉生命条 % extStatusBar.lua
    --############
    local deadText= e.onlyChinese and '死亡' or DEAD
    hooksecurefunc('TextStatusBar_UpdateTextStringWithValues', function(statusFrame, textString, value, valueMin, valueMax)
        if value>0 then--statusFrame.unit
            if textString:IsShown() then
                    local text
                    if value==1 and statusFrame.unit and  UnitIsGhost(statusFrame.unit) then
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

            elseif statusFrame.LeftText and statusFrame.LeftText:IsShown() then
                local text
                if value==1 and statusFrame.unit and  UnitIsGhost(statusFrame.unit) then
                    text= '|A:poi-soulspiritghost:18:18|a'..deadText
                else
                    text= statusFrame.LeftText:GetText()
                end
                if text then
                    if text=='100%' then
                        text= ''
                    else
                        text= text:gsub('%%', '')
                    end
                    statusFrame.LeftText:SetText(text)
                end
            end
        elseif statusFrame.zeroText and statusFrame.DeadText and statusFrame.DeadText:IsShown() then
            local text= deadText--死亡
            if statusFrame.unit then
                if UnitIsGhost(statusFrame.unit) then--灵魂
                    text= '|A:poi-soulspiritghost:18:18|a'..text
                elseif UnitIsDead(statusFrame.unit) then--死亡
                    text= '|A:deathrecap-icon-tombstone:18:18|a'..text
                end
            end
            statusFrame.DeadText:SetText(text)
        end
    end)
    --hooksecurefunc('SetTextStatusBarTextZeroText', function(self)
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
            print(id, addName, (e.onlyChinese and '移动' or NPE_MOVE)..e.Icon.right, 'Alt+'..e.Icon.mid..(e.onlyChinese and '缩放' or UI_SCALE), Save.compactPartyFrameScale or 1)
        end
    end)
    CompactPartyFrame.moveFrame:SetScript("OnLeave", function(self, d)
        ResetCursor()
    end)
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


--####
--团队
--CompactUnitFrame.lua
local function set_RaidFrame()--设置,团队
    if Save.notRaidFrame then
        return
    end
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

    CompactRaidFrameContainer.moveFrame= e.Cbtn(CompactRaidFrameContainer, {icon= true, size={20,20}})--IsEveryoneAssistant() hooksecurefunc('RaidFrameAllqbCheckButton_UpdateAvailable', function()
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
        print(id, addName, (e.onlyChinese and '移动' or NPE_MOVE)..e.Icon.right, 'Alt+'..e.Icon.mid..(e.onlyChinese and '缩放' or UI_SCALE), Save.raidFrameScale or 1)
        if d=='RightButton' and not IsModifierKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    CompactRaidFrameContainer.moveFrame:SetScript("OnLeave", function(self, d)
        ResetCursor()
        self:SetAlpha(0.3)
    end)
    CompactRaidFrameContainer.moveFrame:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
    end)
    CompactRaidFrameContainer.moveFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            if UnitAffectingCombat('player') then
                print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or COMBAT))
            else
                local sacle= Save.raidFrameScale or 1
                if d==1 then
                    sacle=sacle+0.05
                elseif d==-1 then
                    sacle=sacle-0.05
                end
                if sacle>2 then
                    sacle=2
                elseif sacle<0.5 then
                    sacle=0.5
                end
                print(id, addName, (e.onlyChinese and '缩放' or UI_SCALE), sacle)
                CompactRaidFrameContainer:SetScale(sacle)
                Save.raidFrameScale=sacle
            end
        end
    end)
    if Save.raidFrameScale and Save.raidFrameScale~=1 then
        CompactRaidFrameContainer:SetScale(Save.raidFrameScale)
    end

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


local function set_ToggleWarMode()--设置, 战争模式
    if C_PvP.CanToggleWarModeInArea() then
        local isWar= C_PvP.IsWarModeDesired()
        if not PlayerFrame.warMode then
            local w= PlayerFrame.healthbar:GetHeight() or 20
            PlayerFrame.warMode= e.Cbtn(PlayerFrame, {size={w,w}, icon='hide'})
            PlayerFrame.warMode:SetPoint('TOPRIGHT', PlayerFrame, -20, -8)
            PlayerFrame.warMode:SetScript('OnClick',  C_PvP.ToggleWarMode)
            PlayerFrame.warMode:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE, e.GetEnabeleDisable(not C_PvP.IsWarModeDesired()))
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
local function set_BossFrame()
    for i=1, MAX_BOSS_FRAMES do
        local frame= _G['Boss'..i..'TargetFrame']
        frame.PortraitFrame=CreateFrame('Frame', nil, frame)
        frame.PortraitFrame:SetFrameStrata('MEDIUM')
        frame.PortraitFrame:SetPoint('LEFT', frame.TargetFrameContent.TargetFrameContentMain.HealthBar, 'RIGHT')
        frame.PortraitFrame:SetSize(38, 38)
        frame.PortraitFrame.Portrait= frame.PortraitFrame:CreateTexture(nil, 'BACKGROUND')
        frame.PortraitFrame.Portrait:SetAllPoints(frame.PortraitFrame)
        function frame.PortraitFrame:set_Portrait()
            local parentFrame= self:GetParent()
            local unit= parentFrame.unit
            local isExists= UnitExists(unit)
            if isExists then
                SetPortraitTexture(self.Portrait, unit)
                self:Raise()
            end
            self:SetShown(isExists)
        end
        frame.PortraitFrame:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', frame.unit)
        frame.PortraitFrame:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT')
        frame.PortraitFrame:SetScript('OnEvent', frame.PortraitFrame.set_Portrait)
        frame.PortraitFrame:set_Portrait()
    end
end

--######
--初始化
--######
local function Init()
    set_RaidFrame()--团队

    set_CompactPartyFrame()--小队, 使用团框架

    hooksecurefunc(CompactPartyFrame,'UpdateVisibility', set_CompactPartyFrame)

    set_PlayerFrame()--玩家
    set_TargetFrame()--目标
    set_PartyFrame()--小队
    set_UnitFrame_Update()--职业, 图标， 颜色
    set_BossFrame()

    --###############
    --MirrorTimer.lua
    --###############
    hooksecurefunc(MirrorTimerContainer, 'SetupTimer', function(self, value)
        for _, activeTimer in pairs(self.activeTimers) do
            if not activeTimer.valueText then
                activeTimer.valueText=e.Cstr(activeTimer, {justifyH='RIGHT'})
                activeTimer.valueText:SetPoint('BOTTOMRIGHT',-7, 4)
                activeTimer.valueText:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
                activeTimer.Text:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
                hooksecurefunc(activeTimer, 'UpdateStatusBarValue', function(self2)
                    self2.valueText:SetText(format('%i', self2.StatusBar:GetValue()))
                end)
                --[[activeTimer.elapsed= 0.5
                activeTimer:HookScript('OnUpdate', function(self2, elapsed)
                    self2.elapsed= self2.elapsed + elapsed
                    if self2.elapsed>0.5 then
                        self2.valueText:SetText(format('%i', self2.StatusBar:GetValue()))
                        self2.elapsed= 0
                    end
                end)]]

            end
        end
    end)
        
    --#########
    --移动，速度
    --#########
    local leaveElapsed=0
    local function get_UnitSpeed(self, elapsed)
        if leaveElapsed>0.3 then
            local unit, speed
            if UnitExists('vehicle') then
                unit= 'vehicle'
            elseif UnitExists(PlayerFrame.unit) then
                unit= PlayerFrame.unit
            end
            if unit then
                speed= GetUnitSpeed(unit)--PlayerFrame.unit
                if speed and not self.speedText then
                    self.speedText= e.Cstr(self, {mouse=true})
                    self.speedText:SetPoint('TOP')
                    self.speedText:SetScript('OnLeave', function() e.tips:Hide() end)
                    self.speedText:SetScript('OnEnter', function(self2)
                        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine(e.onlyChinese and '当前' or REFORGE_CURRENT, e.onlyChinese and '移动速度' or STAT_MOVEMENT_SPEED)
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:Show()
                    end)
                    self.speedText:SetScript('OnMouseDown', function(self2)
                        local frame= self2:GetParent()
                        if frame.OnClicked then
                            frame.OnClicked(frame)
                        end
                    end)
                end
            end
            if self.speedText then
                if not speed or speed==0 then
                    self.speedText:SetText('')
                else
                    self.speedText:SetFormattedText('%.0f', speed * 100 / BASE_MOVEMENT_SPEED)
                end
            end
             leaveElapsed=0
        else
            leaveElapsed= leaveElapsed+ elapsed
        end
    end
    local function hide_SpeedText(self)
        if self.speedText then
            self.speedText:SetText('')
        end
    end
    if MainMenuBarVehicleLeaveButton then--没有车辆，界面
        MainMenuBarVehicleLeaveButton:SetScript('OnUpdate', get_UnitSpeed)
        MainMenuBarVehicleLeaveButton:SetScript('OnHide', hide_SpeedText)
    end
    if OverrideActionBarLeaveFrameLeaveButton then--有车辆，界面
        OverrideActionBarLeaveFrameLeaveButton:SetScript('OnUpdate', get_UnitSpeed)
        OverrideActionBarLeaveFrameLeaveButton:SetScript('OnHide', hide_SpeedText)
    end
    if MainMenuBarVehicleLeaveButton then--Taxi, 移动, 速度
        MainMenuBarVehicleLeaveButton:SetScript('OnUpdate', get_UnitSpeed)
        MainMenuBarVehicleLeaveButton:SetScript('OnHide', hide_SpeedText)
    end

    C_Timer.After(2, set_ToggleWarMode)--设置, 战争模式
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
--panel:RegisterEvent('CHALLENGE_MODE_COMPLETED')

panel:RegisterEvent('PLAYER_FLAGS_CHANGED')--设置, 战争模式
panel:RegisterEvent('PLAYER_UPDATE_RESTING')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel('|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged:0:0|a'..(e.onlyChinese and '单位框体' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            local sel2=CreateFrame("CheckButton", nil, sel, "InterfaceOptionsCheckButtonTemplate")
            sel2.text:SetText(e.onlyChinese and '团队框体' or HUD_EDIT_MODE_RAID_FRAMES_LABEL)
            sel2:SetPoint('LEFT', sel.text, 'RIGHT')
            sel2:SetChecked(not Save.notRaidFrame)
            sel2:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '提示：如果出现错误' or ('note: '..ENABLE_ERROR_SPEECH), e.onlyChinese and '请取消' or CANCEL)
                --e.tips:AddDoubleLine(e.onlyChinese and '登出游戏' or LOG_OUT..GAME, e.onlyChinese and '请取消' or CANCEL)
                e.tips:Show()
            end)
            sel2:SetScript('OnLeave', function() e.tips:Hide() end)
            sel2:SetScript('OnMouseDown', function ()
                Save.notRaidFrame= not Save.notRaidFrame and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)


            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
                --panel:UnregisterEvent('ADDON_LOADED')
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
    for index, tab in pairs(EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame]) do
        if tab.name==HUD_EDIT_MODE_SETTING_UNIT_FRAME_WIDTH  then-- Frame Width
            EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame][index].minValue=36
        elseif tab.name==HUD_EDIT_MODE_SETTING_UNIT_FRAME_HEIGHT then
            EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.UnitFrame][index].minValue=18
        end
    end]]
