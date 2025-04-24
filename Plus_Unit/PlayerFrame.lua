



--####
--玩家 PlayerFrame.lua
--####
local function Init()--
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
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '所有团队成员都获得团队助理权限' or ALL_ASSIST_DESCRIPTION, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(' ', WoWTools_TextMixin:GetEnabeleDisable(IsEveryoneAssistant()))
        GameTooltip:Show()
    end
    playerFrameTargetContextual.assisterButton:SetScript('OnEnter', playerFrameTargetContextual.assisterButton.set_tooltips)
    playerFrameTargetContextual.assisterButton:SetScript('OnClick', function(self)
        SetEveryoneIsAssistant(not IsEveryoneAssistant())
        C_Timer.After(0.7, function()
            self:set_tooltips()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName, WoWTools_DataMixin.onlyChinese and '所有团队成员都获得团队助理权限' or ALL_ASSIST_DESCRIPTION, WoWTools_TextMixin:GetEnabeleDisable(IsEveryoneAssistant()))
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

    PlayerFrame.lootButton:RegisterEvent('LOADING_SCREEN_DISABLED')
    PlayerFrame.lootButton:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    PlayerFrame.lootButton:RegisterUnitEvent('UNIT_ENTERED_VEHICLE','player')
    PlayerFrame.lootButton:RegisterUnitEvent('UNIT_EXITED_VEHICLE','player')
    PlayerFrame.lootButton:SetScript('OnEvent', PlayerFrame.lootButton.set_shown)

    PlayerFrame.lootButton:SetScript('OnClick', function()
        SetLootSpecialization(0)
        local currentSpec = GetSpecialization()
        local specID= currentSpec and GetSpecializationInfo(currentSpec)
        local name, _, texture= select(2, GetSpecializationInfoByID(specID or 0))
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName,  WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION, texture and '|T'..texture..':0|t' or '', name)
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

    PlayerFrame.instanceFrame.dungeonDifficultyStr= ERR_DUNGEON_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"地下城难度已设置为%s。"
    PlayerFrame.instanceFrame.raidDifficultyStr= ERR_RAID_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"团队副本难度设置为%s。"
    PlayerFrame.instanceFrame.legacyRaidDifficultyStr= ERR_LEGACY_RAID_DIFFICULTY_CHANGED_S:gsub('%%s', '(.+)')--"已将经典团队副本难度设置为%s。"
    PlayerFrame.instanceFrame:RegisterEvent('LOADING_SCREEN_DISABLED')
    PlayerFrame.instanceFrame:SetScript('OnEvent', function(self, event, arg1)
        if event=='LOADING_SCREEN_DISABLED' then
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
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        if WoWTools_WoWDate[WoWTools_DataMixin.Player.guid].Keystone.link then
            GameTooltip:AddLine('|T4352494:0|t'..WoWTools_WoWDate[WoWTools_DataMixin.Player.guid].Keystone.link)
            GameTooltip:AddLine(' ')
        end
        WoWTools_ChallengeMixin:ActivitiesTooltip()
        GameTooltip:AddLine(' ')
        WoWTools_LabelMixin:ItemCurrencyTips({showTooltip=true, showName=true, showAll=true})
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    function PlayerFrame.keystoneFrame:set_settings()
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
        self:SetShown(not IsInInstance() and text~=nil)
    end

    PlayerFrame.keystoneFrame:RegisterEvent('LOADING_SCREEN_DISABLED')
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
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_UnitMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE, WoWTools_TextMixin:GetEnabeleDisable(C_PvP.IsWarModeDesired())..WoWTools_DataMixin.Icon.left)
        if not C_PvP.CanToggleWarMode(false)  then
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '当前不能操作' or SPELL_FAILED_NOT_HERE, 1,0,0)
        end
        GameTooltip:Show()
    end
    PlayerFrame.warModeButton:SetScript('OnEnter', PlayerFrame.warModeButton.set_tooltips)
    PlayerFrame.warModeButton:RegisterEvent('LOADING_SCREEN_DISABLED')
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
        C_Timer.After(1, function() self:set_settings() end)
    end)



    --修改, 宠物, 名称)
    hooksecurefunc('UnitFrame_OnEvent', function(self, event)
        if self.unit=='pet' and event == "UNIT_NAME_UPDATE" then
            self.name:SetText('|A:auctionhouse-icon-favorite:0:0|a')
        end
    end)

    Init=function()end
end













function WoWTools_UnitMixin:Init_PlayerFrame()--玩家
    Init()
end