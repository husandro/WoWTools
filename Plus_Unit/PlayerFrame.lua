--玩家 PlayerFrame.lua








--全部有权限，助手，提示
local function Craete_assisterButton()
    local frame= PlayerFrame_GetPlayerFrameContentContextual()
    frame.assisterButton= WoWTools_ButtonMixin:Cbtn(frame,{size=18})--点击，设置全员，权限
    frame.assisterButton:SetFrameLevel(5)
    frame.assisterButton:SetPoint(frame.LeaderIcon:GetPoint())
    frame.assisterButton:Hide()


    function frame.assisterButton:set_tooltip()
        GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '所有团队成员都获得团队助理权限' or ALL_ASSIST_DESCRIPTION, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(' ', WoWTools_TextMixin:GetEnabeleDisable(IsEveryoneAssistant()))
        GameTooltip:Show()
    end


    frame.assisterButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    frame.assisterButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)


    frame.assisterButton:SetScript('OnClick', function(self)
        SetEveryoneIsAssistant(not IsEveryoneAssistant())
        C_Timer.After(1, function()
            if GameTooltip:IsOwned(self) then
                self:set_tooltip()
            end
        end)
        print(
            WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName,
            WoWTools_DataMixin.onlyChinese and '所有团队成员都获得团队助理权限' or ALL_ASSIST_DESCRIPTION,
            WoWTools_TextMixin:GetEnabeleDisable(IsEveryoneAssistant())
        )
    end)
    frame.assisterIcon= frame:CreateTexture(nil, 'OVERLAY', nil, 1)--助手，提示 PlayerFrame.xml
    frame.assisterIcon:SetAllPoints(frame.assisterButton)
    frame.assisterIcon:SetTexture('Interface\\GroupFrame\\UI-Group-AssistantIcon')
    frame.assisterIcon:Hide()
    frame.isEveryoneAssistantIcon= frame:CreateTexture(nil, 'OVERLAY', nil, 6)--所有限员，有权限，提示
    frame.isEveryoneAssistantIcon:SetPoint('CENTER', frame.assisterButton)
    frame.isEveryoneAssistantIcon:SetAtlas('runecarving-menu-reagent-selected')
    frame.isEveryoneAssistantIcon:SetSize(16,16)
    frame.isEveryoneAssistantIcon:Hide()

    WoWTools_DataMixin:Hook('PlayerFrame_UpdatePartyLeader', function()
        local contextual = PlayerFrame_GetPlayerFrameContentContextual()
        local isLeader= UnitIsGroupLeader("player")
        local isAssist= UnitIsGroupAssistant('player')
        contextual.assisterButton:SetShown(isLeader or WoWTools_DataMixin.Player.husandro)
        contextual.assisterIcon:SetShown(not isLeader and isAssist or WoWTools_DataMixin.Player.husandro)
        contextual.isEveryoneAssistantIcon:SetShown(IsEveryoneAssistant() )
    end)


--移动zzZZ, 睡着
     frame.PlayerRestLoop.RestTexture:SetPoint('TOPRIGHT', PlayerFrame.portrait, 14, 38)
end



















--拾取专精
local function Create_lootButton(frame)
    frame.lootButton= WoWTools_ButtonMixin:Cbtn(frame, {
        name='WoWToolsPlayerFrameLootButton',
        size=20,
        isType2=true,
        notBorder=true
    })
    frame.lootButton:SetPoint('TOP', frame.portrait, 6,10)
    frame.lootButton:SetFrameLevel(frame:GetFrameLevel() +1)


    --[[local portrait= frame.lootButton:CreateTexture(nil, 'ARTWORK', nil, 7)--外框
    portrait:SetAtlas('UI-HUD-UnitFrame-TotemFrame')
    portrait:SetPoint('CENTER',1,-1)
    portrait:SetSize(21,21)
    WoWTools_ColorMixin:Setup(portrait, {type='Texture'})--设置颜色]]

    local lootTipsTexture= frame.lootButton:CreateTexture(nil, "OVERLAY")
    lootTipsTexture:SetSize(8,8)
    lootTipsTexture:SetPoint('TOP', 0, 4)
    lootTipsTexture:SetAtlas('Banker')

    frame.lootButton:SetScript('OnLeave', GameTooltip_Hide)
    frame.lootButton:SetScript('OnEnter', function()
        GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        local text
        local lootSpecID = GetLootSpecialization()
        if lootSpecID then
            local name, _, texture= select(2, GetSpecializationInfoByID(lootSpecID))
            if texture and name then
                text= '|T'..texture..':0|t'..name
            end
        end
        GameTooltip:AddDoubleLine('|A:Banker:0:0|a'..(WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION), text)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '当前专精' or TRANSMOG_CURRENT_SPECIALIZATION, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)

    function frame.lootButton:set_shown()
        local find=false
        if UnitIsUnit(PlayerFrame.unit, 'player') then
            local currentSpec = GetSpecialization()
            local specID= currentSpec and GetSpecializationInfo(currentSpec)
            if specID then
                local lootSpecID = GetLootSpecialization()
                if lootSpecID and lootSpecID>0 and lootSpecID~=specID then
                    local name, _, texture= select(2, GetSpecializationInfoByID(lootSpecID))
                    if texture and name then
                        self.texture:SetTexture(texture)--SetNormalTexture(texture)
                        find=true
                    end
                end
            end
        end
        self:SetShown(find)
    end

    frame.lootButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame.lootButton:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    frame.lootButton:RegisterUnitEvent('UNIT_ENTERED_VEHICLE','player')
    frame.lootButton:RegisterUnitEvent('UNIT_EXITED_VEHICLE','player')

    frame.lootButton:SetScript('OnEvent', function (self)
        self:set_shown()
    end)

    frame.lootButton:SetScript('OnClick', function()
        SetLootSpecialization(0)
        local currentSpec = GetSpecialization()
        local specID= currentSpec and GetSpecializationInfo(currentSpec)
        local name, _, texture= select(2, GetSpecializationInfoByID(specID or 0))

        print(WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName,
            WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION,
            texture and '|T'..texture..':0|t' or '',
            WoWTools_TextMixin:CN(name)
        )
    end)

    frame.lootButton:set_shown()
end

















--Riad 副本, 地下城，指示, 
local function Create_instanceFrame(frame)

    PlayerFrame.instanceFrame= CreateFrame("Frame", nil, PlayerFrame)
    PlayerFrame.instanceFrame:SetFrameLevel(PlayerFrame:GetFrameLevel() +1)
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
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
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
                text= ID==dungeonID and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight)..text..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft) or text
                GameTooltip:AddLine((text==self.name and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight) or '')..text..(text==self.name and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft) or ''))
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
    local portrait= frame.instanceFrame:CreateTexture(nil, 'OVERLAY')
    portrait:SetAtlas('UI-HUD-UnitFrame-TotemFrame')
    portrait:SetPoint('CENTER', frame.instanceFrame.dungeon,1,0)
    portrait:SetSize(20,20)
    WoWTools_ColorMixin:Setup(portrait, {type='Texture'})--设置颜色


--提示
    frame.instanceFrame.dungeon:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)

    function frame.instanceFrame.dungeon:set_tooltip()
        GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        local dungeonID= GetDungeonDifficultyID()
        local text=WoWTools_MapMixin:GetDifficultyColor(nil, dungeonID)
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY), '|A:DungeonSkull:0:0|a'..text)
        GameTooltip:AddLine(' ')
        local tab={
            DifficultyUtil.ID.DungeonNormal,
            DifficultyUtil.ID.DungeonHeroic,
            DifficultyUtil.ID.DungeonMythic
        }
        for index, ID in pairs(tab) do
            text= WoWTools_MapMixin:GetDifficultyColor(nil, ID)
            text= ID==dungeonID and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight)..text..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft) or text
            local set
            if index==3 then
                set= ((UnitIsGroupLeader("player") or not IsInGroup()) and dungeonID~=ID and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e')
                    ..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
                    ..WoWTools_DataMixin.Icon.left
            end
            GameTooltip:AddDoubleLine(text,set)
        end
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end

    frame.instanceFrame.dungeon:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)

    frame.instanceFrame.dungeon:SetScript('OnMouseUp', function(self) self:SetAlpha(0.5) end)
    frame.instanceFrame.dungeon:SetScript('OnMouseDown', function(self)
        if (UnitIsGroupLeader("player") or not IsInGroup()) and GetDungeonDifficultyID()~=DifficultyUtil.ID.DungeonMythic then
            SetDungeonDifficultyID(DifficultyUtil.ID.DungeonMythic)
            C_Timer.After(0.5, function()
                if GameTooltip:IsShown() then
                    self:set_tooltip()
                end
            end)
        end
        self:SetAlpha(0.1)
    end)


    function frame.instanceFrame:set_settings()
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

            local text3= (WoWTools_DataMixin.onlyChinese and '团队副本难度' or RAID_DIFFICULTY)..': '..name3..'|r'

            local otherDifficulty = GetLegacyRaidDifficultyID()
            local size3= otherDifficulty and DifficultyUtil.GetMaxPlayers(otherDifficulty)--UnitPopup.lua
            if size3 and not displayMythic3 then
                text3= text3..'|n'..(WoWTools_DataMixin.onlyChinese and '经典团队副本难度' or LEGACY_RAID_DIFFICULTY)..': '..(size3==10 and (WoWTools_DataMixin.onlyChinese and '10人' or RAID_DIFFICULTY1) or size3==25 and (WoWTools_DataMixin.onlyChinese and '25人' or RAID_DIFFICULTY2) or '')
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
                local text2= (WoWTools_DataMixin.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY)..': '..color2.hex..name2..'|r'

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

    frame.instanceFrame.dungeonDifficultyStr= ERR_DUNGEON_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"地下城难度已设置为%s。"
    frame.instanceFrame.raidDifficultyStr= ERR_RAID_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"团队副本难度设置为%s。"
    frame.instanceFrame.legacyRaidDifficultyStr= ERR_LEGACY_RAID_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"已将经典团队副本难度设置为%s。"

    frame.instanceFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

    frame.instanceFrame:SetScript('OnEvent', function(self, event, arg1)
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

    frame.instanceFrame:set_settings()
end
















--挑战，数据
local function Create_keystoneFrame(frame)
    frame.keystoneFrame= CreateFrame("Frame", nil, frame)
    frame.keystoneFrame:SetSize(18, 18)

    frame.keystoneFrame:SetPoint('LEFT', PlayerFrame_GetPlayerFrameContentContextual().LeaderIcon, 'RIGHT',0,-2)
    frame.keystoneFrame.texture=frame.keystoneFrame:CreateTexture()
    frame.keystoneFrame.texture:SetAllPoints(frame.keystoneFrame)
    frame.keystoneFrame.texture:SetTexture(4352494)
    WoWTools_ButtonMixin:AddMask(frame.keystoneFrame)

    frame.keystoneFrame.Text= WoWTools_LabelMixin:Create(frame.keystoneFrame, {color=true})
    frame.keystoneFrame.Text:SetPoint('LEFT', frame.keystoneFrame, 'RIGHT')
    frame.keystoneFrame:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip:Hide() end)
    frame.keystoneFrame:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        if WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link then
            GameTooltip:AddLine('|T4352494:0|t'..WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link)
            GameTooltip:AddLine(' ')
        end
        WoWTools_ChallengeMixin:ActivitiesTooltip()
        GameTooltip:AddLine(' ')
        WoWTools_LabelMixin:ItemCurrencyTips({showTooltip=true, showName=true, showAll=true})
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    function frame.keystoneFrame:set_settings()
        local text
        local score= C_ChallengeMode.GetOverallDungeonScore()
        if score and score>0 then
            local activeText= WoWTools_ChallengeMixin:GetRewardText(1)--得到，周奖励，信息
            activeText= activeText and ' ('..activeText..') '
            text= WoWTools_ChallengeMixin:KeystoneScorsoColor(score)..(activeText or '')--分数
            local info = C_MythicPlus.GetRunHistory(false, true) or {}--次数
            local num= #info
            if num>0 then
                text= text..num
            end
        end
        self.Text:SetText(text or '')
        self:SetShown(
            (WoWTools_DataMixin.Player.IsMaxLevel and not PlayerGetTimerunningSeasonID())
            or WoWTools_DataMixin.Player.husandro
        )
    end

    frame.keystoneFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame.keystoneFrame:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')--地下城挑战
    frame.keystoneFrame:RegisterEvent('WEEKLY_REWARDS_UPDATE')--地下城挑战
    frame.keystoneFrame:RegisterEvent('CHALLENGE_MODE_COMPLETED')

    frame.keystoneFrame:SetScript('OnEvent', function(self)
        C_Timer.After(2, function() self:set_settings() end)
    end)

    frame.keystoneFrame:set_settings()
end















--设置, 战争模式 Blizzard_WarmodeButtonTemplate.lua
local function Create_warModeButton(frame)
    frame.warModeButton= WoWTools_ButtonMixin:Cbtn(frame, {size=20, isType2=true})
    frame.warModeButton:SetPoint('LEFT', frame, 5, 12)
    frame.warModeButton:SetScript('OnClick',  function(self)
        --C_PvP.ToggleWarMode()
        WoWTools_LoadUIMixin:SpellBook(2)
        --C_Timer.After(1, function() if GameTooltip:IsShown() then self:set_tooltip() end end)
    end)
    function frame.warModeButton:GetWarModeDesired()
        return UnitPopupSharedUtil.IsInWarModeState()
    end
    function frame.warModeButton:set_tooltip()
        if WarmodeButtonMixin then
            WarmodeButtonMixin.OnEnter(self)
            return
        end

        GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE, WoWTools_TextMixin:GetEnabeleDisable(C_PvP.IsWarModeDesired())..WoWTools_DataMixin.Icon.left)

        if not C_PvP.ArePvpTalentsUnlocked() then
			GameTooltip_AddErrorLine(
                GameTooltip,
                format(
                    WoWTools_DataMixin.onlyChinese and '在%d级解锁' or PVP_TALENT_SLOT_LOCKED,
                    C_PvP.GetPvpTalentsUnlockedLevel()
                ),
            true)

        elseif not C_PvP.CanToggleWarMode(true) or not C_PvP.CanToggleWarMode(false) or InCombatLockdown() then
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '当前不能操作' or SPELL_FAILED_NOT_HERE, 1,0,0)
		end

        GameTooltip:Show()
    end

    frame.warModeButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    frame.warModeButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)

    frame.warModeButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame.warModeButton:RegisterEvent('PLAYER_FLAGS_CHANGED')
    frame.warModeButton:RegisterEvent('PLAYER_UPDATE_RESTING')
    function frame.warModeButton:set_settings()
        local isCan= C_PvP.CanToggleWarModeInArea()
        if isCan then
            self:SetNormalAtlas(C_PvP.IsWarModeDesired() and 'pvptalents-warmode-swords' or 'pvptalents-warmode-swords-disabled')
        end
        self:SetShown(isCan)
    end
    frame.warModeButton:SetScript('OnEvent', function(self, event)
        C_Timer.After(1, function() self:set_settings() end)
    end)

    frame.warModeButton:set_settings()
end






local function Init()
    if WoWToolsSave['Plus_UnitFrame'].hidePlayerFrame then
        return
    end
do
    Craete_assisterButton()--全部有权限，助手，提示
end
do
    Create_lootButton(PlayerFrame)--拾取专精
end
do
    Create_instanceFrame(PlayerFrame)--Riad 副本, 地下城，指示
end
do
    Create_keystoneFrame(PlayerFrame)--挑战，数据
end
do
    Create_warModeButton(PlayerFrame)--设置, 战争模式
end

--移动，小队，号
    PlayerFrameGroupIndicatorText:ClearAllPoints()
    PlayerFrameGroupIndicatorText:SetPoint('TOPRIGHT', PlayerFrame, -35, -24)

--处理,小队, 号码
    WoWTools_DataMixin:Hook('PlayerFrame_UpdateGroupIndicator', function()
        if IsInRaid() then
            local text= PlayerFrameGroupIndicatorText:GetText()
            local num= text and text:match('(%d)')
            if num then
                PlayerFrameGroupIndicatorText:SetFormattedText('|A:services-number-%s:22:22|a', num)
            end
        end
    end)
    if IsInRaid() then
        WoWTools_DataMixin:Call(PlayerFrame_UpdateGroupIndicator)
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
    WoWTools_DataMixin:Hook('PlayerFrame_UpdateLevel', function()
        if UnitExists("player") then
            local effectiveLevel = UnitEffectiveLevel(PlayerFrame.unit)
            if effectiveLevel== GetMaxLevelForLatestExpansion() then
                PlayerLevelText:SetText('')
            --[[else
                --PlayerLevelText:SetText(effectiveLevel)
                local r,g,b= select(2, WoWTools_UnitMixin:GetColor(unit))
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
    PlayerFrame.PlayerFrameContainer.FrameTexture:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)--设置颜色


--移动，缩小，开启战争模式时，PVP图标
    WoWTools_DataMixin:Hook('PlayerFrame_UpdatePvPStatus', function()--开启战争模式时，PVP图标
        local contextual = PlayerFrame_GetPlayerFrameContentContextual();
        local icon= contextual and contextual.PVPIcon
        if icon then
            icon:SetSize(25,25)
            icon:ClearAllPoints()
            icon:SetPoint('RIGHT', PlayerFrame.PlayerFrameContainer.PlayerPortrait, 'LEFT', 13, -24)
        end
    end)


--修改, 宠物, 名称)
    WoWTools_DataMixin:Hook('UnitFrame_OnEvent', function(self, event)
        if self.unit=='pet' and event == "UNIT_NAME_UPDATE" then
            self.name:SetText('|A:auctionhouse-icon-favorite:0:0|a')
        end
    end)

    Init=function()end
end













function WoWTools_UnitMixin:Init_PlayerFrame()--玩家
    Init()
end