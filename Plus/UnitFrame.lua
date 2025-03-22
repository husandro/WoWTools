local id, e = ...
local addName
local Save={
    --notRaidFrame= not e.Player.husandro,
    raidFrameScale= e.Player.husandro and 0.8 or 1,
    --raidFrameAlpha=1,
    --healthbar='UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status'
}



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














--####
--玩家
--####
local function Init_PlayerFrame()--PlayerFrame.lua
    local playerFrameTargetContextual = PlayerFrame_GetPlayerFrameContentContextual()
    local frameLevel= PlayerFrame:GetFrameLevel() +1

    --全部有权限，助手，提示
    --####################
    playerFrameTargetContextual.assisterButton= WoWTools_ButtonMixin:Cbtn(playerFrameTargetContextual,{size=16})--点击，设置全员，权限
    playerFrameTargetContextual.assisterButton:SetFrameLevel(5)
    playerFrameTargetContextual.assisterButton:SetPoint(playerFrameTargetContextual.LeaderIcon:GetPoint())
    playerFrameTargetContextual.assisterButton:Hide()
    playerFrameTargetContextual.assisterButton:SetScript('OnLeave', GameTooltip_Hide)
    function playerFrameTargetContextual.assisterButton:set_tooltips()
        GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(e.onlyChinese and '所有团队成员都获得团队助理权限' or ALL_ASSIST_DESCRIPTION, e.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(' ', e.GetEnabeleDisable(IsEveryoneAssistant()))
        GameTooltip:Show()
    end
    playerFrameTargetContextual.assisterButton:SetScript('OnEnter', playerFrameTargetContextual.assisterButton.set_tooltips)
    playerFrameTargetContextual.assisterButton:SetScript('OnClick', function(self)
        SetEveryoneIsAssistant(not IsEveryoneAssistant())
        C_Timer.After(0.7, function()
            self:set_tooltips()
            print(e.Icon.icon2.. addName, e.onlyChinese and '所有团队成员都获得团队助理权限' or ALL_ASSIST_DESCRIPTION, e.GetEnabeleDisable(IsEveryoneAssistant()))
        end)
    end)
    playerFrameTargetContextual.assisterIcon= playerFrameTargetContextual:CreateTexture(nil, 'OVERLAY', nil, 1)--助手，提示 PlayerFrame.xml
    playerFrameTargetContextual.assisterIcon:SetAllPoints(playerFrameTargetContextual.assisterButton)
    playerFrameTargetContextual.assisterIcon:SetTexture('Interface\\GroupFrame\\UI-Group-AssistantIcon')
    playerFrameTargetContextual.assisterIcon:Hide()
    playerFrameTargetContextual.isEveryoneAssistantIcon= playerFrameTargetContextual:CreateTexture(nil, 'OVERLAY', nil, 6)--所有限员，有权限，提示
    playerFrameTargetContextual.isEveryoneAssistantIcon:SetPoint('CENTER', playerFrameTargetContextual.assisterButton)
    playerFrameTargetContextual.isEveryoneAssistantIcon:SetAtlas('runecarving-menu-reagent-selected')
    playerFrameTargetContextual.isEveryoneAssistantIcon:SetSize(16,16)
    playerFrameTargetContextual.isEveryoneAssistantIcon:Hide()

    hooksecurefunc('PlayerFrame_UpdatePartyLeader', function()
        local contextual = PlayerFrame_GetPlayerFrameContentContextual()
        local isLeader= UnitIsGroupLeader("player")
        local isAssist= UnitIsGroupAssistant('player')
        contextual.assisterButton:SetShown(isLeader)
        contextual.assisterIcon:SetShown(not isLeader and isAssist)
        contextual.isEveryoneAssistantIcon:SetShown(IsEveryoneAssistant())
    end)

    --移动，小队，号
    --############
    PlayerFrameGroupIndicatorText:ClearAllPoints()
    PlayerFrameGroupIndicatorText:SetPoint('TOPRIGHT', PlayerFrame, -35, -24)

    --处理,小队, 号码
    hooksecurefunc('PlayerFrame_UpdateGroupIndicator', function()
        if IsInRaid() then
            local text= PlayerFrameGroupIndicatorText:GetText()
            local num= text and text:match('(%d)')
            if num then
                PlayerFrameGroupIndicatorText:SetFormattedText('|A:services-number-%s:22:22|a', num)
            end
        end
    end)
    if IsInRaid() then
        WoWTools_Mixin:Call(PlayerFrame_UpdateGroupIndicator)
    end

    if PlayerFrameGroupIndicatorLeft then
        PlayerFrameGroupIndicatorLeft:SetTexture(0)
        PlayerFrameGroupIndicatorLeft:SetShown(false)
        PlayerFrameGroupIndicatorMiddle:SetTexture(0)
        PlayerFrameGroupIndicatorMiddle:SetShown(false)
        PlayerFrameGroupIndicatorRight:SetTexture(0)
        PlayerFrameGroupIndicatorRight:SetShown(false)
    end

    --等级，颜色
    hooksecurefunc('PlayerFrame_UpdateLevel', function()
        if UnitExists("player") then
            local effectiveLevel = UnitEffectiveLevel(PlayerFrame.unit)
            if effectiveLevel== GetMaxLevelForLatestExpansion() then
                PlayerLevelText:SetText('')
            --[[else
                --PlayerLevelText:SetText(effectiveLevel)
                local r,g,b= select(2, WoWTools_UnitMixin:Get_Unit_Color(unit))
                PlayerLevelText:SetTextColor(r,g,b)--设置颜色]]
            end
        end
    end)

    --玩家, 治疗，爆击，数字
    if PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator then
        local label= PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator.HitText
        if label then
            WoWTools_ColorMixin:Setup(label, {type='FontString'})--设置颜色
            label:ClearAllPoints()
            label:SetPoint('TOPLEFT', PlayerFrame.PlayerFrameContainer.PlayerPortrait, 'BOTTOMLEFT')
        end
    end
    --宠物
    if PetHitIndicator then
        PetHitIndicator:ClearAllPoints()
        PetHitIndicator:SetPoint('TOPLEFT', PetPortrait or PetHitIndicator:GetParent(), 'BOTTOMLEFT')
    end

    --外框
    PlayerFrame.PlayerFrameContainer.FrameTexture:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)--设置颜色

    --移动zzZZ, 睡着
    playerFrameTargetContextual.PlayerRestLoop.RestTexture:SetPoint('TOPRIGHT', PlayerFrame.portrait, 14, 38)

    C_Timer.After(4, function()
    local t= PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator
    t:Show()
    t.HitText:SetText('aaaaa')
end)







    --拾取专精
    --#######
    PlayerFrame.lootButton= WoWTools_ButtonMixin:Cbtn(PlayerFrame, {size=14, isType2=true})
    PlayerFrame.lootButton:SetPoint('TOPLEFT', PlayerFrame.portrait, 'TOPRIGHT',-32,16)
    PlayerFrame.lootButton:SetFrameLevel(frameLevel)


    local portrait= PlayerFrame.lootButton:CreateTexture(nil, 'ARTWORK', nil, 7)--外框
    portrait:SetAtlas('UI-HUD-UnitFrame-TotemFrame')
    portrait:SetPoint('CENTER',1,-1)
    portrait:SetSize(21,21)
    WoWTools_ColorMixin:Setup(portrait, {type='Texture'})--设置颜色

    local lootTipsTexture= PlayerFrame.lootButton:CreateTexture(nil, "OVERLAY")
    lootTipsTexture:SetSize(10,10)
    lootTipsTexture:SetPoint('TOP',0,8)
    lootTipsTexture:SetAtlas('Banker')

    PlayerFrame.lootButton:SetScript('OnLeave', GameTooltip_Hide)
    PlayerFrame.lootButton:SetScript('OnEnter', function()
        GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
        GameTooltip:AddLine(' ')
        local text
        local lootSpecID = GetLootSpecialization()
        if lootSpecID then
            local name, _, texture= select(2, GetSpecializationInfoByID(lootSpecID))
            if texture and name then
                text= '|T'..texture..':0|t'..name
            end
        end
        GameTooltip:AddDoubleLine('|A:Banker:0:0|a'..(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION), text)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(e.onlyChinese and '当前专精' or TRANSMOG_CURRENT_SPECIALIZATION, e.Icon.left)
        GameTooltip:Show()
    end)

    function PlayerFrame.lootButton:set_shown()
        local find=false
        if UnitIsUnit(PlayerFrame.unit, 'player') then
            local currentSpec = GetSpecialization()
            local specID= currentSpec and GetSpecializationInfo(currentSpec)
            if specID then
                local lootSpecID = GetLootSpecialization()
                if lootSpecID and lootSpecID>0 and lootSpecID~=specID then
                    local name, _, texture= select(2, GetSpecializationInfoByID(lootSpecID))
                    if texture and name then
                        self:SetNormalTexture(texture)
                        find=true
                    end
                end
            end
        end
        self:SetShown(find)
    end

    PlayerFrame.lootButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    PlayerFrame.lootButton:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    PlayerFrame.lootButton:RegisterUnitEvent('UNIT_ENTERED_VEHICLE','player')
    PlayerFrame.lootButton:RegisterUnitEvent('UNIT_EXITED_VEHICLE','player')
    PlayerFrame.lootButton:SetScript('OnEvent', PlayerFrame.lootButton.set_shown)

    PlayerFrame.lootButton:SetScript('OnClick', function()
        SetLootSpecialization(0)
        local currentSpec = GetSpecialization()
        local specID= currentSpec and GetSpecializationInfo(currentSpec)
        local name, _, texture= select(2, GetSpecializationInfoByID(specID or 0))
        print(e.Icon.icon2.. addName,  e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION, texture and '|T'..texture..':0|t' or '', name)
    end)




    --Riad 副本, 地下城，指示,  
    --######################
    PlayerFrame.instanceFrame= CreateFrame("Frame", nil, PlayerFrame)
    PlayerFrame.instanceFrame:SetFrameLevel(frameLevel)
    PlayerFrame.instanceFrame:SetPoint('RIGHT', PlayerFrame.lootButton, 'LEFT',-2,-2)
    PlayerFrame.instanceFrame:SetSize(16,16)
    --图标
    PlayerFrame.instanceFrame.raid= PlayerFrame.instanceFrame:CreateTexture(nil,'BORDER', nil, 1)
    PlayerFrame.instanceFrame.raid:SetAllPoints(PlayerFrame.instanceFrame)
    PlayerFrame.instanceFrame.raid:SetAtlas('poi-torghast')
    --10人，25人
    PlayerFrame.instanceFrame.raid.text= WoWTools_LabelMixin:Create(PlayerFrame.instanceFrame, {color=true})
    PlayerFrame.instanceFrame.raid.text:SetPoint('TOP',0,8)
    --提示
    PlayerFrame.instanceFrame.raid:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) self.text:SetAlpha(1) end)
    PlayerFrame.instanceFrame.raid:SetScript('OnEnter', function(self)
        if self.tips then
            GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
            GameTooltip:AddLine(' ')
            local dungeonID= GetRaidDifficultyID()
            local text=WoWTools_MapMixin:GetDifficultyColor(nil, dungeonID)
            GameTooltip:AddDoubleLine(self.tips, '|A:poi-torghast:0:0|a')
            GameTooltip:AddLine(' ')
            local tab={
                DifficultyUtil.ID.DungeonNormal,
                DifficultyUtil.ID.DungeonHeroic,
                DifficultyUtil.ID.DungeonMythic
            }
            for _, ID in pairs(tab) do
                text= WoWTools_MapMixin:GetDifficultyColor(nil, ID)
                text= ID==dungeonID and format('|A:%s:0:0|a', e.Icon.toRight)..text..format('|A:%s:0:0|a', e.Icon.toLeft) or text
                GameTooltip:AddLine((text==self.name and format('|A:%s:0:0|a', e.Icon.toRight) or '')..text..(text==self.name and format('|A:%s:0:0|a', e.Icon.toLeft) or ''))
            end

            GameTooltip:Show()
            self:SetAlpha(0.3)
            self.text:SetAlpha(0.3)
        end
    end)
    --5人 副本, 地下城，指示
    PlayerFrame.instanceFrame.dungeon= PlayerFrame.instanceFrame:CreateTexture(nil,'BORDER', nil, 1)
    PlayerFrame.instanceFrame.dungeon:SetPoint('RIGHT', PlayerFrame.instanceFrame, 'LEFT', 2, -8)
    PlayerFrame.instanceFrame.dungeon:SetSize(16,16)
    PlayerFrame.instanceFrame.dungeon:SetAtlas('DungeonSkull')
     --外框
    portrait= PlayerFrame.instanceFrame:CreateTexture(nil, 'OVERLAY')
    portrait:SetAtlas('UI-HUD-UnitFrame-TotemFrame')
    portrait:SetPoint('CENTER', PlayerFrame.instanceFrame.dungeon,1,0)
    portrait:SetSize(20,20)
    WoWTools_ColorMixin:Setup(portrait, {type='Texture'})--设置颜色
    --提示
    PlayerFrame.instanceFrame.dungeon:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    function PlayerFrame.instanceFrame.dungeon:set_tooltips()
        GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
        GameTooltip:AddLine(' ')
        local dungeonID= GetDungeonDifficultyID()
        local text=WoWTools_MapMixin:GetDifficultyColor(nil, dungeonID)
        GameTooltip:AddDoubleLine((e.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY), '|A:DungeonSkull:0:0|a'..text)
        GameTooltip:AddLine(' ')
        local tab={
            DifficultyUtil.ID.DungeonNormal,
            DifficultyUtil.ID.DungeonHeroic,
            DifficultyUtil.ID.DungeonMythic
        }
        for index, ID in pairs(tab) do
            text= WoWTools_MapMixin:GetDifficultyColor(nil, ID)
            text= ID==dungeonID and format('|A:%s:0:0|a', e.Icon.toRight)..text..format('|A:%s:0:0|a', e.Icon.toLeft) or text
            local set
            if index==3 then
                set= ((UnitIsGroupLeader("player") or not IsInGroup()) and dungeonID~=ID and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e')
                    ..(e.onlyChinese and '设置' or SETTINGS)
                    ..e.Icon.left
            end
            GameTooltip:AddDoubleLine(text,set)
        end
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end
    PlayerFrame.instanceFrame.dungeon:SetScript('OnEnter', PlayerFrame.instanceFrame.dungeon.set_tooltips)
    PlayerFrame.instanceFrame.dungeon:SetScript('OnMouseUp', function(self) self:SetAlpha(0.5) end)
    PlayerFrame.instanceFrame.dungeon:SetScript('OnMouseDown', function(self)
        if (UnitIsGroupLeader("player") or not IsInGroup()) and GetDungeonDifficultyID()~=DifficultyUtil.ID.DungeonMythic then
            SetDungeonDifficultyID(DifficultyUtil.ID.DungeonMythic)
            C_Timer.After(0.5, function()
                if GameTooltip:IsShown() then
                    self:set_tooltips()
                end
            end)
        end
        self:SetAlpha(0.1)
    end)
    function PlayerFrame.instanceFrame:set_settings()
        local ins, findRiad, findDungeon=  IsInInstance(), false, false
        if not ins and UnitIsUnit(PlayerFrame.unit, 'player') then
            local difficultyID2 = GetDungeonDifficultyID() or 0
            local difficultyID3= GetRaidDifficultyID() or 0
            local displayMythic3 = select(6, GetDifficultyInfo(difficultyID3))

            local name2, color2= WoWTools_MapMixin:GetDifficultyColor(nil, difficultyID2)
            local name3, color3= WoWTools_MapMixin:GetDifficultyColor(nil, difficultyID3)
            if not name3 and difficultyID3 then
                name3= GetDifficultyInfo(difficultyID3) or difficultyID3
                color3= {r=1,g=1,b=1}
            end

            local text3= (e.onlyChinese and '团队副本难度' or RAID_DIFFICULTY)..': '..name3..'|r'

            local otherDifficulty = GetLegacyRaidDifficultyID()
            local size3= otherDifficulty and DifficultyUtil.GetMaxPlayers(otherDifficulty)--UnitPopup.lua
            if size3 and not displayMythic3 then
                text3= text3..'|n'..(e.onlyChinese and '经典团队副本难度' or LEGACY_RAID_DIFFICULTY)..': '..(size3==10 and (e.onlyChinese and '10人' or RAID_DIFFICULTY1) or size3==25 and (e.onlyChinese and '25人' or RAID_DIFFICULTY2) or '')
            end

            if name3 and (name3~=name2 or not displayMythic3) then
                self.raid:SetVertexColor(color3.r, color3.g, color3.b)
                self.raid.tips= text3
                self.raid.name= name3
                self.raid.text:SetText((size3 and not displayMythic3) and size3 or '')
                self.raid.text:SetTextColor(color3.r, color3.g, color3.b)
                findRiad=true
            else
                self.raid.text:SetText('')
            end

            if name2  then
                self.dungeon:SetVertexColor(color2.r, color2.g, color2.b)
                local text2= (e.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY)..': '..color2.hex..name2..'|r'

                if not findRiad then
                    text2= text2..(text3 and '|n|n'..text3 or '')
                end
                self.dungeon.tips=text2
                self.dungeon.name= name2
                findDungeon= true
            end
            self.raid:SetShown(findRiad)
            self.dungeon:SetShown(findDungeon)
        end
        self:SetShown(not ins)
    end

    PlayerFrame.instanceFrame.dungeonDifficultyStr= ERR_DUNGEON_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"地下城难度已设置为%s。"
    PlayerFrame.instanceFrame.raidDifficultyStr= ERR_RAID_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"团队副本难度设置为%s。"
    PlayerFrame.instanceFrame.legacyRaidDifficultyStr= ERR_LEGACY_RAID_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"已将经典团队副本难度设置为%s。"
    PlayerFrame.instanceFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    PlayerFrame.instanceFrame:SetScript('OnEvent', function(self, event, arg1)
        if event=='PLAYER_ENTERING_WORLD' then
            if IsInInstance() then
                self:UnregisterEvent('CHAT_MSG_SYSTEM')--会出错误，冒险指南，打开世界BOSS
            else
                self:RegisterEvent('CHAT_MSG_SYSTEM')
            end
            self:set_settings()--副本, 地下城，指示
        elseif arg1 and (arg1:find(self.dungeonDifficultyStr) or arg1:find(self.raidDifficultyStr) or arg1:find(self.legacyRaidDifficultyStr)) then
            self:set_settings()--副本, 地下城，指示
        end
    end)













    --挑战，数据
    --#########
    PlayerFrame.keystoneFrame= CreateFrame("Frame", nil, PlayerFrame)
    PlayerFrame.keystoneFrame:SetSize(12, 12)
    PlayerFrame.keystoneFrame:SetPoint('LEFT', playerFrameTargetContextual.LeaderIcon, 'RIGHT',0,-2)
    PlayerFrame.keystoneFrame.texture=PlayerFrame.keystoneFrame:CreateTexture()
    PlayerFrame.keystoneFrame.texture:SetAllPoints(PlayerFrame.keystoneFrame)
    PlayerFrame.keystoneFrame.texture:SetTexture(4352494)
    PlayerFrame.keystoneFrame.Text= WoWTools_LabelMixin:Create(PlayerFrame.keystoneFrame, {color=true})
    PlayerFrame.keystoneFrame.Text:SetPoint('LEFT', PlayerFrame.keystoneFrame, 'RIGHT')
    PlayerFrame.keystoneFrame:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip:Hide() end)
    PlayerFrame.keystoneFrame:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
        GameTooltip:AddLine(' ')
        if e.WoWDate[e.Player.guid].Keystone.link then
            GameTooltip:AddLine('|T4352494:0|t'..e.WoWDate[e.Player.guid].Keystone.link)
            GameTooltip:AddLine(' ')
        end
        WoWTools_WeekMixin:Activities({showTooltip=true})
        GameTooltip:AddLine(' ')
        WoWTools_LabelMixin:ItemCurrencyTips({showTooltip=true, showName=true, showAll=true})
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    function PlayerFrame.keystoneFrame:set_settings()
        local text
        local score= C_ChallengeMode.GetOverallDungeonScore()
        if score and score>0 then
            local activeText= WoWTools_WeekMixin:GetRewardText(1)--得到，周奖励，信息
            activeText= activeText and ' ('..activeText..') '
            text= WoWTools_WeekMixin:KeystoneScorsoColor(score)..(activeText or '')--分数
            local info = C_MythicPlus.GetRunHistory(false, true) or {}--次数
            local num= #info
            if num>0 then
                text= text..num
            end
        end
        self.Text:SetText(text or '')
        self:SetShown(not IsInInstance() and text~=nil)
    end

    PlayerFrame.keystoneFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    PlayerFrame.keystoneFrame:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')--地下城挑战
    PlayerFrame.keystoneFrame:RegisterEvent('WEEKLY_REWARDS_UPDATE')--地下城挑战
    PlayerFrame.keystoneFrame:RegisterEvent('CHALLENGE_MODE_COMPLETED')
    PlayerFrame.keystoneFrame:SetScript('OnEvent', function(self)
        C_Timer.After(2, function() self:set_settings() end)
    end)




    --移动，缩小，开启战争模式时，PVP图标
    hooksecurefunc('PlayerFrame_UpdatePvPStatus', function()--开启战争模式时，PVP图标
        local contextual = PlayerFrame_GetPlayerFrameContentContextual();
        local icon= contextual and contextual.PVPIcon
        if icon then
            icon:SetSize(25,25)
            icon:ClearAllPoints()
            icon:SetPoint('RIGHT', PlayerFrame.PlayerFrameContainer.PlayerPortrait, 'LEFT', 13, -24)
        end
    end)

    --设置, 战争模式
    PlayerFrame.warModeButton= WoWTools_ButtonMixin:Cbtn(PlayerFrame, {size=20, isType2=true})
    PlayerFrame.warModeButton:SetPoint('LEFT', PlayerFrame, 5, 12)
    PlayerFrame.warModeButton:SetScript('OnClick',  function(self)
        C_PvP.ToggleWarMode()
        C_Timer.After(1, function() if GameTooltip:IsShown() then self:set_tooltips() end end)
    end)
    PlayerFrame.warModeButton:SetScript('OnLeave', GameTooltip_Hide)
    function PlayerFrame.warModeButton:set_tooltips()
        GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(e.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE, e.GetEnabeleDisable(C_PvP.IsWarModeDesired())..e.Icon.left)
        if not C_PvP.CanToggleWarMode(false)  then
            GameTooltip:AddLine(e.onlyChinese and '当前不能操作' or SPELL_FAILED_NOT_HERE, 1,0,0)
        end
        GameTooltip:Show()
    end
    PlayerFrame.warModeButton:SetScript('OnEnter', PlayerFrame.warModeButton.set_tooltips)
    PlayerFrame.warModeButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    PlayerFrame.warModeButton:RegisterEvent('PLAYER_FLAGS_CHANGED')
    PlayerFrame.warModeButton:RegisterEvent('PLAYER_UPDATE_RESTING')
    function PlayerFrame.warModeButton:set_settings()
        local isCan= C_PvP.CanToggleWarModeInArea()
        if isCan then
            self:SetNormalAtlas(C_PvP.IsWarModeDesired() and 'pvptalents-warmode-swords' or 'pvptalents-warmode-swords-disabled')
        end
        self:SetShown(isCan)
    end
    PlayerFrame.warModeButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            C_Timer.After(2, function() self:set_settings() end)
        else
            C_Timer.After(1, function() self:set_settings() end)
        end
    end)



end


































--####
--目标
--####
local function Init_TargetFrame()
    --目标，生命条，颜色，材质
    hooksecurefunc(TargetFrame, 'CheckClassification', function(frame)--外框，颜色
        local r,g,b= select(2, WoWTools_UnitMixin:Get_Unit_Color(frame.unit))
        frame.TargetFrameContainer.FrameTexture:SetVertexColor(r, g, b)
        frame.TargetFrameContainer.BossPortraitFrameTexture:SetVertexColor(r, g, b)
        frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')--生命条，材质
        frame.healthbar:SetStatusBarColor(r,g,b)--生命条，颜色
    end)

    hooksecurefunc(TargetFrame,'CheckLevel', function(self)--目标, 等级, 颜色
        local levelText = self.TargetFrameContent.TargetFrameContentMain.LevelText
        if levelText then
            local r,g,b= select(2, WoWTools_UnitMixin:Get_Unit_Color(self.unit))
            levelText:SetTextColor(r,g,b)
        end
    end)

    TargetFrame.rangeText= WoWTools_LabelMixin:Create(TargetFrame, {justifyH='RIGHT'})
    TargetFrame.rangeText:SetPoint('RIGHT', TargetFrame, 'LEFT', 22, 6)
    TargetFrame.speedText= WoWTools_LabelMixin:Create(TargetFrame, {justifyH='RIGHT', color={r=1,g=1,b=1}})
    TargetFrame.speedText:SetPoint('TOPRIGHT', TargetFrame.rangeText, 'BOTTOMRIGHT', 0, -2)

    TargetFrame:HookScript('OnHide', function(self)
        self.elapsed= nil
    end)
    hooksecurefunc(TargetFrame, 'OnUpdate', function(self, elapsed)--距离
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed<0.3 then
            return
        end

        self.elapsed=0
        local text, speed

        if not UnitIsUnit('player', 'target') then
            local mi, ma= WoWTools_UnitMixin:GetRange('target')
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

            local value= GetUnitSpeed('target') or 0
            if value==0 then
                speed= '|cff8282820%'
            else
                speed= format( '%.0f%%', (value)*100/BASE_MOVEMENT_SPEED)
            end

        end
        self.rangeText:SetText(text or '')
        self.speedText:SetText(speed or '')
    end)
end



























--####
--小队
--####
local function set_memberFrame(memberFrame)
    if not PartyFrame:ShouldShow() then
        return
    end
    local unit= memberFrame.unit or memberFrame:GetUnit()
    local isPlayer= unit=='player'
    local exists= UnitExists(unit)

    local r,g,b= select(2, WoWTools_UnitMixin:Get_Unit_Color(unit))

    --外框
    memberFrame.Texture:SetVertexColor(r, g, b)
    memberFrame.PortraitMask:SetVertexColor(r, g, b)
    --目标的目标
    local btn= memberFrame.potFrame
    if not btn then
        btn= WoWTools_ButtonMixin:Cbtn(memberFrame, {isSecure=true, size=35, isType2=true})
        btn:SetPoint('LEFT', memberFrame, 'RIGHT', -3, 4)
        btn:SetAttribute('type', 'target')
        btn:SetAttribute('unit', unit..'target')
        btn:SetScript('OnLeave', GameTooltip_Hide)
        btn:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            if UnitExists(self.unit) then
                GameTooltip:SetUnit(self.unit)
            else
                GameTooltip:AddDoubleLine(self.unit, e.Icon.left..(e.onlyChinese and '选中目标' or BINDING_HEADER_TARGETING))
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
            end
            GameTooltip:Show()
        end)
        btn.unit= unit..'target'

        btn.frame=CreateFrame('Frame', nil, btn)
        btn.frame:SetFrameLevel(btn.frame:GetFrameLevel()-1)
        btn.frame:SetAllPoints()
        btn.frame:Hide()

        btn.frame.isPlayerTargetTexture= btn.frame:CreateTexture(nil, 'BORDER')
        btn.frame.isPlayerTargetTexture:SetSize(42,42)
        btn.frame.isPlayerTargetTexture:SetPoint('CENTER',2,-2)
        btn.frame.isPlayerTargetTexture:SetAtlas('UI-HUD-UnitFrame-TotemFrame')
        btn.frame.isPlayerTargetTexture:SetVertexColor(1,0,0)

        btn.frame.Portrait= btn.frame:CreateTexture(nil, 'BACKGROUND')--队友，目标，图像
        btn.frame.Portrait:SetAllPoints(btn.frame)


        btn.frame.healthLable= WoWTools_LabelMixin:Create(btn.frame, {size=14})
        btn.frame.healthLable:SetPoint('BOTTOMRIGHT')
        btn.frame.healthLable:SetTextColor(1,1,1)

        btn.frame.class= btn.frame:CreateTexture(nil, "ARTWORK")
        btn.frame.class:SetSize(14,14)
        btn.frame.class:SetPoint('TOPRIGHT')

        function btn.frame:set_settings()
            local exists2= UnitExists(self.unit)
            if self.unit then
                if self.isPlayer then
                    SetPortraitTexture(self.Portrait, self.unit, true)--图像
                elseif UnitIsUnit(self.isSelfUnit, self.unit) then--队员，选中他自已
                    self.Portrait:SetAtlas(e.Icon.toLeft)
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
                    self.class:SetAtlas(WoWTools_UnitMixin:GetClassIcon(self.unit, nil, true))
                elseif UnitIsBossMob(self.unit) then
                    self.class:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
                else
                    self.class:SetTexture(0)
                end

                local r2,g2,b2= select(2, WoWTools_UnitMixin:Get_Unit_Color(self.unit))
                self.healthLable:SetTextColor(r2, g2, b2)
            end
            self.isPlayerTargetTexture:SetShown(exists2 and UnitIsUnit(self.unit, 'target'))
            self:SetShown(exists2)
        end

        function btn.frame:set_evnet()
            self:RegisterEvent('RAID_TARGET_UPDATE')
            self:RegisterUnitEvent('UNIT_TARGET', self.unit)
            self:RegisterUnitEvent('UNIT_FLAGS', self.unit..'target')
            self:RegisterUnitEvent('UNIT_PORTRAIT_UPDATE', self.unit..'target')
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
        end
        btn.frame:SetScript('OnEvent', btn.frame.set_settings)


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

        memberFrame.potFrame= btn
    end
    btn.frame.unit= unit..'target'
    btn.frame.isSelfUnit= unit
    btn.frame.isPlayer= isPlayer
    btn.frame:UnregisterAllEvents()
    if exists then
        btn.frame:set_evnet()
    end
    btn.frame:set_settings()



    --#########
    --队友，施法
    --#########
    local castFrame= memberFrame.castFrame
    if not castFrame then
        castFrame= CreateFrame("Frame", nil, memberFrame)
        castFrame:SetPoint('BOTTOMLEFT', memberFrame.potFrame, 'BOTTOMRIGHT')
        castFrame:SetSize(20,20)
        castFrame.texture=  castFrame:CreateTexture(nil,'BACKGROUND')
        castFrame.texture:SetAllPoints(castFrame)
        castFrame:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
        castFrame:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            local spellID= select(8, UnitChannelInfo(self.unit)) or select(9, UnitCastingInfo(self.unit))
            if spellID then
                GameTooltip:SetSpellByID(spellID)
            else
                GameTooltip:AddDoubleLine((e.onlyChinese and '队员' or PLAYERS_IN_GROUP)..' '..(self.unit or ''), e.onlyChinese and '施法条' or HUD_EDIT_MODE_CAST_BAR_LABEL)
            end
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
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
        memberFrame.castFrame= castFrame
    end
    castFrame:UnregisterAllEvents()
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
        FrameUtil.RegisterFrameForUnitEvents(castFrame, events, unit)
        castFrame:RegisterEvent('UNIT_SPELLCAST_SENT')
    end
    castFrame.unit= unit
    if isPlayer then
        castFrame.texture:SetAtlas('Relic-Life-TraitGlow')
    else
        castFrame.texture:SetTexture(0)
    end

    --##########
    --队伍, 标记, 成员派系
    --##########
    local raidTargetFrame= memberFrame.raidTargetFrame
    if not raidTargetFrame then
        raidTargetFrame= CreateFrame("Frame", nil, memberFrame)
        raidTargetFrame:SetSize(14,14)
        raidTargetFrame:SetPoint('RIGHT', memberFrame.PartyMemberOverlay.RoleIcon, 'LEFT')
        raidTargetFrame.texture= raidTargetFrame:CreateTexture()
        raidTargetFrame.texture:SetAllPoints(raidTargetFrame)
        raidTargetFrame.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')

        --成员派系
        raidTargetFrame.faction=raidTargetFrame:CreateTexture(nil, 'ARTWORK')
        raidTargetFrame.faction:SetSize(14,14)
        raidTargetFrame.faction:SetPoint('TOPLEFT', memberFrame.Portrait)
        function raidTargetFrame:set_faction()
            local faction= UnitFactionGroup(self.unit)
            local atlas
            if faction~= e.Player.faction or self.isPlayer then
                atlas= e.Icon[faction]
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
        memberFrame.raidTargetFrame= raidTargetFrame
    end
    raidTargetFrame.unit= unit
    raidTargetFrame.isPlayer= isPlayer
    raidTargetFrame:UnregisterAllEvents()
    if exists then
        raidTargetFrame:RegisterUnitEvent('UNIT_FACTION', unit)
        raidTargetFrame:RegisterEvent('RAID_TARGET_UPDATE')
    end
    if isPlayer then
        SetRaidTargetIconTexture(raidTargetFrame.texture, 1)
    else
        set_RaidTarget(raidTargetFrame.texture, raidTargetFrame.unit)--队伍, 标记
    end
    raidTargetFrame:set_faction()--成员派系


    --#######
    --战斗指示
    --#######
    local combatFrame= memberFrame.combatFrame
    if not combatFrame then
        combatFrame= CreateFrame('Frame', nil, memberFrame)
        combatFrame:SetPoint('BOTTOMLEFT', memberFrame.potFrame, 'RIGHT', 2, 2)
        combatFrame:SetSize(16,16)
        combatFrame:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
        combatFrame:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(self.unit, e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
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
        memberFrame.combatFrame= combatFrame
    end
    combatFrame.unit= unit
    combatFrame.isPlayer= isPlayer
    combatFrame:SetShown(exists)

    --#######
    --队友位置
    --#######
    local positionFrame= memberFrame.positionFrame
    if not positionFrame then
        positionFrame= CreateFrame("Frame", nil, memberFrame)
        positionFrame:Hide()
        positionFrame:SetPoint('LEFT', memberFrame.PartyMemberOverlay.LeaderIcon, 'RIGHT')
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
                    text= (text and text..' ' or '')..e.cn(mapInfo.name)
                    local mapID2= C_Map.GetBestMapForUnit('player')
                    if mapID2== mapID then
                        text= format('|A:%s:0:0|a', e.Icon.select)..text
                    end
                end
                self.Text:SetText(text or '')
            end
        end)
        function positionFrame:set_evnet()
            if not IsInInstance() and UnitExists(self.unit) or self.isPlayer then
                self:RegisterEvent('PLAYER_REGEN_DISABLED')
                self:RegisterEvent('PLAYER_REGEN_ENABLED')
            else
                self:UnregisterEvent('PLAYER_REGEN_DISABLED')
                self:UnregisterEvent('PLAYER_REGEN_ENABLED')
            end
        end
        positionFrame:SetScript('OnEvent',  positionFrame.set_shown)

        positionFrame:SetScript('OnHide', positionFrame.set_evnet)
        positionFrame:SetScript('OnShow', positionFrame.set_evnet)
        memberFrame.positionFrame= positionFrame
    end
    positionFrame.isPlayer= isPlayer
    positionFrame.Text:SetTextColor(r, g, b)
    positionFrame.unit= unit
    positionFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    positionFrame:set_evnet()
    positionFrame:set_shown()

    --#########
    --队友，死亡
    --#########
    local deadFrame= memberFrame.deadFrame
    if not deadFrame then
        deadFrame= CreateFrame('Frame', nil, memberFrame)
        deadFrame:SetPoint("CENTER", memberFrame.Portrait)
        deadFrame:SetFrameLevel(memberFrame:GetFrameLevel()+1)
        deadFrame:SetSize(37,37)
        deadFrame:SetFrameStrata('HIGH')
        deadFrame.texture= deadFrame:CreateTexture()
        deadFrame.texture:SetAllPoints(deadFrame)
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
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('CHALLENGE_MODE_START')
            self:RegisterUnitEvent('UNIT_FLAGS', unit)
            self:RegisterUnitEvent('UNIT_HEALTH', unit)
        end
        deadFrame:SetScript('OnEvent', function(self, event)
            if event=='PLAYER_ENTERING_WORLD' or event=='CHALLENGE_MODE_START' then
                self.dead= 0
            end
            self:set_settings()
        end)
        deadFrame:SetScript('OnHide', function(self)
            self:UnregisterAllEvents()
            deadFrame.dead= 0
        end)
        deadFrame:SetScript('OnShow', deadFrame.set_event)
        if exists then
            deadFrame:set_event()
        end

        --死亡，次数
        deadFrame.dead=0
        deadFrame.Text= WoWTools_LabelMixin:Create(deadFrame, {mouse=true, color={r=1,g=1,b=1}})
        deadFrame.Text:SetPoint('BOTTOMRIGHT', deadFrame, -2,0)
        deadFrame.Text:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
        deadFrame.Text:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine((e.onlyChinese and '死亡' or DEAD)..' '..(self.unit or ''),
                    format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, self:GetParent().dead or 0 , e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
            )
            GameTooltip:Show()
            self:SetAlpha(0.3)
        end)
        memberFrame.deadFrame= deadFrame
    end

    --deadFrame.Text:SetTextColor(r, g, b)
    deadFrame.isPlayer= isPlayer
    deadFrame.unit= unit
    deadFrame:set_settings()
end




local function Init_PartyFrame()--PartyFrame.lua
    PartyFrame.Background:SetWidth(122)--144
    for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do--先使用一次，用以Shift+点击，设置焦点功能, Invite.lua
        set_memberFrame(memberFrame)
        memberFrame.Texture:SetAtlas('UI-HUD-UnitFrame-Party-PortraitOn-Status')--PartyFrameTemplates.xml
    end
    hooksecurefunc(PartyFrame, 'UpdatePartyFrames', function(unitFrame)
        for memberFrame in unitFrame.PartyMemberFramePool:EnumerateActive() do
            set_memberFrame(memberFrame)
        end
    end)

    --##############
    --隐藏, DPS 图标
    --##############
    for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        hooksecurefunc(memberFrame, 'UpdateAssignedRoles', function(self)--隐藏, DPS 图标
            self.PartyMemberOverlay.RoleIcon:SetShown(UnitGroupRolesAssigned(self.unit)~='DAMAGER')
        end)
    end

    --###################
    --隐藏, 队伍, DPS 图标
    --###################
    for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
        hooksecurefunc(memberFrame, 'UpdateAssignedRoles', function(self)--隐藏, DPS 图标
            self.PartyMemberOverlay.RoleIcon:SetShown(UnitGroupRolesAssigned(self.unit)~= 'DAMAGER')
        end)
    end
end



























--################
--职业, 图标， 颜色
--################
local function Init_UnitFrame_Update(frame, isParty)--UnitFrame.lua--职业, 图标， 颜色
    local unit= frame.unit
    if not UnitExists(unit) or unit:find('nameplate') then
        return
    end
    local r,g,b= select(2, WoWTools_UnitMixin:Get_Unit_Color(unit))

    local guid
    local unitIsPlayer=  UnitIsPlayer(unit)
    if unitIsPlayer then
        guid= UnitGUID(frame.unit)--职业, 天赋, 图标
        if not frame.classFrame then
            frame.classFrame= CreateFrame('Frame', nil, frame)
            frame.classFrame:SetShown(false)
            frame.classFrame:SetSize(16,16)
            frame.classFrame.Portrait= frame.classFrame:CreateTexture(nil, "BACKGROUND")
            frame.classFrame.Portrait:SetAllPoints(frame.classFrame)


            if frame==TargetFrame then
                frame.classFrame:SetPoint('RIGHT', frame.TargetFrameContent.TargetFrameContentContextual.LeaderIcon, 'LEFT')
            elseif frame==PetFrame then
                frame.classFrame:SetPoint('LEFT', frame.name,-10,0)
            elseif frame==PlayerFrame then
                frame.classFrame:SetPoint('TOPLEFT', frame.portrait, 'TOPRIGHT',-14,8)
            elseif frame==FocusFrame then
                frame.classFrame:SetPoint('BOTTOMRIGHT', frame.TargetFrameContent.TargetFrameContentMain.ReputationColor, 'TOPRIGHT')
            else
                frame.classFrame:SetPoint('TOPLEFT', frame.portrait, 'TOPRIGHT',-14,10)
            end

            frame.classFrame.Texture= frame.classFrame:CreateTexture(nil, 'OVERLAY')--加个外框
            frame.classFrame.Texture:SetAtlas('UI-HUD-UnitFrame-TotemFrame')
            frame.classFrame.Texture:SetPoint('CENTER', frame.classFrame, 1,-1)
            frame.classFrame.Texture:SetSize(20,20)

            frame.classFrame.itemLevel= WoWTools_LabelMixin:Create(frame.classFrame, {size=12})--装等
            if unit=='target' or unit=='focus' then
                frame.classFrame.itemLevel:SetPoint('RIGHT', frame.classFrame, 'LEFT')
            else
                frame.classFrame.itemLevel:SetPoint('TOPRIGHT', frame.classFrame, 'TOPLEFT')
            end

            function frame.classFrame:set_settings(guid3)
                local unit2= self:GetParent().unit
                local isPlayer= UnitExists(unit2) and UnitIsPlayer(unit2)
                local find2=false
                if isPlayer then
                    if UnitIsUnit(unit2, 'player') then
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
                                local class= WoWTools_UnitMixin:GetClassIcon(unit2, nil, true)--职业, 图标
                                if class then
                                    self.Portrait:SetAtlas(class)
                                    find2=true
                                end
                            end
                        end
                    end

                    self.itemLevel:SetText(guid3 and e.UnitItemLevel[guid3] and e.UnitItemLevel[guid3].itemLevel or '')
                end
                self:SetShown(isPlayer and find2)
            end
            frame.classFrame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', unit)
            frame.classFrame:SetScript('OnEvent', function(self3)
                local unit2= self3:GetParent().unit
                if UnitIsPlayer(unit2) then
                    e.GetNotifyInspect(nil, unit2)--取得玩家信息
                    C_Timer.After(2, function()
                        self3:set_settings()
                    end)
                end
            end)
        end
    end
    if frame.classFrame then
        frame.classFrame:set_settings(guid)
        frame.classFrame.Texture:SetVertexColor(r or 1, g or 1, b or 1)
        frame.classFrame.itemLevel:SetTextColor(r or 1, g or 1, b or 1)
        --frame.classFrame:SetShown(unitIsPlayer)
    end

    if frame.name then
        local name
        if UnitIsUnit(unit, 'pet') then
            frame.name:SetText('|A:auctionhouse-icon-favorite:0:0|a')
        else
            frame.name:SetTextColor(r,g,b)
            if isParty then
                name= UnitName(unit)
                name= WoWTools_TextMixin:sub(name, 4, 8)
                frame.name:SetText(name)
            elseif unit=='target' and guid then
                local wow= WoWTools_UnitMixin:GetIsFriendIcon(nil, guid)
                if wow then
                    name= wow..GetUnitName(unit, false)
                end
            end
        end
        if name then
            frame.name:SetText(name)
        end
    end

    --################
    --生命条，颜色，材质
    --################
    if frame.healthbar then
        frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
        frame.healthbar:SetStatusBarColor(r,g,b)--颜色
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
    CompactPartyFrame.moveFrame= WoWTools_ButtonMixin:Cbtn(CompactPartyFrame, {icon=true, size=20})
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
    end)
    CompactPartyFrame.moveFrame:SetScript("OnMouseDown", function(_, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=="LeftButton" then
            print(e.Icon.icon2.. addName, (e.onlyChinese and '移动' or NPE_MOVE)..e.Icon.right, 'Alt+'..e.Icon.mid..(e.onlyChinese and '缩放' or UI_SCALE), Save.compactPartyFrameScale or 1)
        end
    end)
    CompactPartyFrame.moveFrame:SetScript("OnLeave", ResetCursor)
    CompactPartyFrame.moveFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if not IsAltKeyDown() then
            return
        end
        if not self:CanChangeAttribute() then
            print(e.Icon.icon2.. addName, e.onlyChinese and '缩放' or UI_SCALE, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or COMBAT))
            return
        end
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
        print(e.Icon.icon2.. addName, (e.onlyChinese and '缩放' or UI_SCALE), sacle)
        CompactPartyFrame:SetScale(sacle)
        Save.compactPartyFrameScale=sacle
    end)
    if Save.compactPartyFrameScale and Save.compactPartyFrameScale~=1 then
        CompactPartyFrame:SetScale(Save.compactPartyFrameScale)
    end
    CompactPartyFrame:SetClampedToScreen(true)
    CompactPartyFrame:SetMovable(true)
end





























--#########
--BossFrame
--#########
local function Init_BossFrame()
    for i=1, MAX_BOSS_FRAMES do
        local frame= _G['Boss'..i..'TargetFrame']
        frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')--生命条，颜色，材质

        frame.BossButton= WoWTools_ButtonMixin:Cbtn(frame, {size=38, isSecure=true, isType2=true})--CreateFrame('Frame', nil, frame, 'SecureActionButtonTemplate')

        frame.BossButton:SetPoint('LEFT', frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer, 'RIGHT')

        frame.BossButton:SetAttribute('type', 'target')
        frame.BossButton:SetAttribute('unit', frame.unit)
        frame.BossButton:SetScript('OnLeave', GameTooltip_Hide)
        frame.BossButton:SetScript('OnEnter', function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, self);
            GameTooltip:ClearLines()
            GameTooltip:SetUnit(self.unit)
            GameTooltip:Show()
        end)

        frame.BossButton.Portrait= frame.BossButton:CreateTexture(nil, 'BACKGROUND')
        frame.BossButton.Portrait:SetAllPoints()

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
            --颜色
            local r,g,b= select(2, WoWTools_UnitMixin:Get_Unit_Color(unit))
            self:GetParent().healthbar:SetStatusBarColor(r,g,b)--颜色
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


        --队友，选中BOSS，数量
        --##############
        frame.numSelectFrame= CreateFrame('Frame', frame)
        frame.numSelectFrame.unit= frame.unit
        frame.numSelectFrame.Text= WoWTools_LabelMixin:Create(frame.BossButton, {color={r=1,g=1,b=1}, size=20})
        frame.numSelectFrame.Text:SetPoint('BOTTOM', 0, -16)
        function frame.numSelectFrame:set_event(f)
            if f:IsVisible() then
                self:RegisterEvent('UNIT_TARGET')
                if BossTargetFrameContainer.isInEditMode then
                    self.Text:SetText('40')
                else
                    self:settings()
                end
            else
                self:UnregisterEvent('UNIT_TARGET')
                self.Text:SetText('')
                self.isRun=nil
            end
        end
        function frame.numSelectFrame:settings()
            if self.isRun then
                return
            end
            self.isRun=true
            local n=0
            if IsInRaid() then
                for index=1, MAX_RAID_MEMBERS do
                    local unit= 'raid'..index
                    if UnitIsUnit(unit..'target', self.unit) and not UnitIsUnit(unit, 'player') then
                        n= n+1
                    end
                end
            elseif IsInGroup() then
                for index=1, GetNumGroupMembers()-1, 1 do
                    local unit= 'party'..index
                    if UnitIsUnit(unit..'target', self.unit) then
                        n= n+1
                    end
                end
            end
            self.Text:SetText(n>0 and n or '')
            self.isRun=nil
        end
        frame.numSelectFrame:SetScript('OnEvent', function(self, _, unit)
            if UnitIsPlayer(unit) and not UnitIsUnit(unit, 'player') then
                self:settings()
            end
        end)
        frame:HookScript('OnShow', function(self)
            self.numSelectFrame:set_event(self)
        end)
        frame:HookScript('OnHide', function(self)
            self.numSelectFrame:set_event(self)
        end)
        if frame:IsShown() then
            frame.numSelectFrame:set_event(frame)
        end

        --目标的目标，点击
        --##############
        frame.TotButton=WoWTools_ButtonMixin:Cbtn(frame, {size=38, isSecure=true, isType2=true})
        function frame.TotButton:set_point()
            if Boss1TargetFrameSpellBar.castBarOnSide then
                self:SetPoint('TOPLEFT', frame.TargetFrameContent.TargetFrameContentMain.ManaBar, 'BOTTOMLEFT')
            else
                self:SetPoint('RIGHT', frame.TargetFrameContent.TargetFrameContentMain.HealthBar, 'LEFT',-2,0)
            end
        end
        frame.TotButton:set_point()
        --frame.TotButton:SetPoint('TOPLEFT', frame.BossButton, 'TOPRIGHT', 4,0)
        frame.TotButton:SetAttribute('type', 'target')
        frame.TotButton:SetAttribute('unit', frame.unit..'target')
        frame.TotButton:SetScript('OnLeave', GameTooltip_Hide)
        frame.TotButton:SetScript('OnEnter', function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, self);
            GameTooltip:ClearLines()
            if UnitExists(self.targetUnit) then
                GameTooltip:SetUnit(self.targetUnit)
            else
                GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
                GameTooltip:AddDoubleLine(e.onlyChinese and '目标的目标' or SHOW_TARGET_OF_TARGET_TEXT, self.targetUnit)
            end
            GameTooltip:Show()
        end)
        frame.TotButton.unit= frame.unit
        frame.TotButton.targetUnit= frame.unit..'target'

        --目标的目标，信息
        frame.TotButton.frame= CreateFrame('Frame', nil, frame.TotButton)
        frame.TotButton.frame:SetFrameLevel(frame.TotButton:GetFrameLevel()-1)
        frame.TotButton.frame:SetAllPoints()
        frame.TotButton.frame:Hide()
        frame.TotButton.frame.unit= frame.unit
        frame.TotButton.frame.targetUnit= frame.unit..'target'

        --目标的目标，图像
        frame.TotButton.frame.Portrait= frame.TotButton.frame:CreateTexture(nil, 'BACKGROUND')
        frame.TotButton.frame.Portrait:SetAllPoints()



        --目标的目标，外框
        frame.TotButton.frame.Border= frame.TotButton.frame:CreateTexture(nil, 'ARTWORK')
        frame.TotButton.frame.Border:SetSize(44,44)
        frame.TotButton.frame.Border:SetPoint('CENTER',2,-2)
        frame.TotButton.frame.Border:SetAtlas('UI-HUD-UnitFrame-TotemFrame')

        --目标的目标，百份比
        frame.TotButton.frame.healthLable= WoWTools_LabelMixin:Create(frame.TotButton.frame,{color={r=1,g=1,b=1}, size=14})
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
                local isSelf= UnitIsUnit(unit, 'player')
                if BossTargetFrameContainer.isInEditMode then
                    SetPortraitTexture(self.Portrait, unit)
                elseif isSelf then--自已
                    self.Portrait:SetAtlas('auctionhouse-icon-favorite')
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
                local r,g,b= select(2, WoWTools_UnitMixin:Get_Unit_Color(unit))
                --self.healthBar:SetStatusBarColor(r,g,b)
                --self.IsTargetTexture:SetShown(UnitIsUnit(self.targetUnit, 'target'))
                self.Border:SetVertexColor(r or 1, g or 1, b or 1)
                self.healthLable:SetTextColor(r or 1, g or 1, b or 1)
                WoWTools_FrameMixin:HelpFrame({frame=self, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, show=isSelf, y=-2})
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
            if frame.TotButton and frame.TotButton:CanChangeAttribute() then
                frame.TotButton:ClearAllPoints()
                frame.TotButton:set_point()
            end
        end
    end
    hooksecurefunc(Boss1TargetFrameSpellBar,'AdjustPosition', set_TotButton_point)
    hooksecurefunc(BossTargetFrameContainer, 'SetSmallSize', set_TotButton_point)
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
                name= WoWTools_TextMixin:sub(name, 4, 8)
                frame.name:SetText(name)
            end
        end
    end)

    hooksecurefunc('CompactUnitFrame_UpdateStatusText', function(frame)--去掉,生命条, %
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
    hooksecurefunc('CompactRaidGroup_InitializeForGroup', function(frame, groupIndex)--处理, 队伍号
        frame.title:SetText('|A:services-number-'..groupIndex..':18:18|a')
    end)


    --新建, 移动, 按钮
    CompactRaidFrameContainer:SetClampedToScreen(true)
    CompactRaidFrameContainer:SetMovable(true)

    CompactRaidFrameContainer.moveFrame= WoWTools_ButtonMixin:Cbtn(CompactRaidFrameContainer, {atlas=e.Icon.icon, size=22})
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
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        local col= UnitAffectingCombat('player') and '|cff9e9e9e' or ''
        GameTooltip:AddDoubleLine(col..(e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.raidFrameScale or 1), col..'Alt+'..e.Icon.mid)
        GameTooltip:Show()
        self:SetAlpha(1)
    end
    function CompactRaidFrameContainer.moveFrame:set_Scale()
        self:GetParent():SetScale(Save.raidFrameScale or 1)
    end
    CompactRaidFrameContainer.moveFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if not IsAltKeyDown() then
            return
        end
        if not self:CanChangeAttribute() then
            print(WoWTools_Mixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            return
        end
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
        print(e.Icon.icon2.. addName, e.onlyChinese and '缩放' or UI_SCALE, num)
    end)
    CompactRaidFrameContainer.moveFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self:SetAlpha(0.1)
    end)
    CompactRaidFrameContainer.moveFrame:SetScript('OnEnter', CompactRaidFrameContainer.moveFrame.set_Tooltips)
    CompactRaidFrameContainer.moveFrame:set_Scale()
    CompactRaidFrameContainer.moveFrame:SetAlpha(0.1)




    --团体, 管理, 缩放

    CompactRaidFrameManager.ScaleButton= WoWTools_ButtonMixin:Menu(CompactRaidFrameManagerDisplayFrameOptionsButton, {size=18})
    CompactRaidFrameManager.ScaleButton:SetPoint('RIGHT', CompactRaidFrameManagerDisplayFrameRaidMemberCountLabel, 'LEFT')
    CompactRaidFrameManager.ScaleButton:SetAlpha(0.3)
    function CompactRaidFrameManager.ScaleButton:settings()
        CompactRaidFrameManager:SetScale(Save.managerScale or 1)
    end
    CompactRaidFrameManager.ScaleButton:SetScript('OnLeave', function(self)
        self:SetAlpha(0.3)
    end)
    CompactRaidFrameManager.ScaleButton:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
    end)
    CompactRaidFrameManager.ScaleButton:SetupMenu(function(self, root)
--缩放
        WoWTools_MenuMixin:Scale(self, root, function()
            return Save.managerScale or 1
        end, function(value)
            Save.managerScale= value
            self:settings()
        end)

        root:CreateDivider()
--打开选项界面
        WoWTools_MenuMixin:OpenOptions(root, {name=addName})
    end)
    CompactRaidFrameManager.ScaleButton:settings()







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
            frame.statusText:SetText(WoWTools_Mixin:MK(UnitHealth(frame.displayedUnit), 0))
        elseif ( frame.optionTable.healthText == "losthealth" ) then
            local healthLost = UnitHealthMax(frame.displayedUnit) - UnitHealth(frame.displayedUnit)
            if ( healthLost > 0 ) then
                frame.statusText:SetText('-'..WoWTools_Mixin:MK(healthLost, 0))
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








local function Create_CastTimeTexte(frame)
    if frame.CastTimeText then
        return
    end

    frame.CastTimeText= WoWTools_LabelMixin:Create(frame, {size=14, color={r=1, g=1, b=1}, justifyH='RIGHT'})
    frame.CastTimeText:SetPoint('RIGHT', frame)

    if frame.UpdateCastTimeText then
        return
    end

    frame:HookScript('OnUpdate', function(self, elapsed)--玩家, 施法, 时间
        self.elapsed= (self.elapsed or 0.1) + elapsed
        if self.elapsed>=0.1 and self.value and self.maxValue then
            self.elapsed=0
            local value= self.channeling and self.value or (self.maxValue-self.value)
            if value<=0 then
                self.CastTimeText:SetText(0)
            elseif value>=3 then
                self.CastTimeText:SetFormattedText('%i', value)
            else
                self.CastTimeText:SetFormattedText('%.01f', value)
            end
        end
    end)
end






--施法条 CastingBarFrame.lua
local function Init_CastingBar(frame)
    frame.Icon:EnableMouse(true)
    frame.Icon:SetScript('OnEnter', function(self)
        local unit= self:GetParent().unit or 'player'
        local spellID= select(9, UnitCastingInfo(unit)) or select(8, UnitChannelInfo(unit)) or 0
        if spellID==0 then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(spellID)
        GameTooltip:Show()
    end)
    frame:HookScript('OnShow', function(self)--图标
        self.Icon:SetShown(true)
    end)

    --WoWTools_ColorMixin:Setup(frame.CastTimeText, {type='FontString'})--设置颜色    
    if not frame.CastTimeText then
        Create_CastTimeTexte(frame)
    else
        frame.CastTimeText:SetShadowOffset(1, -1)
        if frame.ChargeFlash then
            frame.CastTimeText:ClearAllPoints()
            frame.CastTimeText:SetPoint('RIGHT', frame.ChargeFlash, 'RIGHT')
        end
    end
    --WoWTools_ColorMixin:Setup(frame.Text, {type='FontString'})--设置颜色
    frame.Text:SetTextColor(1, 0.82, 0, 1)
    frame.Text:SetShadowOffset(1, -1)

    if frame==PlayerCastingBarFrame then
        frame:HookScript('OnShow', function(self)
            self:SetFrameStrata('TOOLTIP')
            self:SetFrameLevel('10000')
        end)
    end
    if frame.UpdateCastTimeText then
        hooksecurefunc(frame, 'UpdateCastTimeText', function(self)--去掉 秒
            local text= self.CastTimeText:GetText()
            text= text:match('(%d+.%d)') or text
            text= text=='0.0' and '' or text
            self.CastTimeText:SetText(text)
            if self~=PlayerCastingBarFrame then
                self.CastTimeText:SetShown(true)
            end
        end)
    end
end















--######
--初始化
--######
local function Init()
    Init_PlayerFrame()--玩家
    Init_TargetFrame()--目标
    Init_PartyFrame()--小队
    Init_BossFrame()--BOSS
    Init_RaidFrame()--团队
    Init_CastingBar(PlayerCastingBarFrame)
    Init_CastingBar(PetCastingBarFrame)
    Init_CastingBar(OverlayPlayerCastingBarFrame)

    Init_CastingBar(TargetFrameSpellBar)

    hooksecurefunc('UnitFrame_Update', Init_UnitFrame_Update)--职业, 图标， 颜色

    set_CompactPartyFrame()--小队, 使用团框架
    hooksecurefunc(CompactPartyFrame,'UpdateVisibility', set_CompactPartyFrame)

    --###############
    --MirrorTimer.lua
    --###############
    hooksecurefunc(MirrorTimerContainer, 'SetupTimer', function(frame)--, value)
        for _, activeTimer in pairs(frame.activeTimers) do
            if not activeTimer.valueText then
                activeTimer.valueText=WoWTools_LabelMixin:Create(activeTimer, {justifyH='RIGHT'})
                activeTimer.valueText:SetPoint('BOTTOMRIGHT',-7, 4)

                WoWTools_ColorMixin:Setup(activeTimer.valueText, {type='FontString'})--设置颜色
                WoWTools_ColorMixin:Setup(activeTimer.Text, {type='FontString'})--设置颜色

                hooksecurefunc(activeTimer, 'UpdateStatusBarValue', function(self)
                    self.valueText:SetText(format('%i', self.StatusBar:GetValue()))
                end)
            end
        end
    end)

    --修改, 宠物, 名称)
    hooksecurefunc('UnitFrame_OnEvent', function(self, event)
        if self.unit=='pet' and event == "UNIT_NAME_UPDATE" then
            self.name:SetText('|A:auctionhouse-icon-favorite:0:0|a')
        end
    end)
end



































local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            if WoWToolsSave[UNITFRAME_LABEL] then
                Save= WoWToolsSave[UNITFRAME_LABEL]
                WoWToolsSave[UNITFRAME_LABEL]= nil
            else
                Save= WoWToolsSave['Plus_UnitFrame'] or Save
            end

            addName= '|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged:0:0|a'..(e.onlyChinese and '单位框体' or UNITFRAME_LABEL)

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                GetValue= function() return not Save.disabled end,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.Icon.icon2.. addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save.disabled then
                Init()
            end

            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_UnitFrame']=Save
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
