--玩家 PlayerFrame.lua









local function Craete_assisterButton()


end












































--[[设置, 战争模式 Blizzard_WarmodeButtonTemplate.lua
local function Create_warModeButton(frame)
    frame.warModeButton= WoWTools_ButtonMixin:Cbtn(frame, {size=20, isType2=true, name='WoWToolsPlayerFrameWarModeButton'})
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
        GameTooltip:SetText(WoWTools_UnitMixin.addName..WoWTools_DataMixin.Icon.icon2)
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
    
    frame.warModeButton.bg= frame.warModeButton:CreateTexture(nil, 'ARTWORK')
    frame.warModeButton.bg:SetAllPoints()
    frame.warModeButton.bg:SetAtlas('pvptalents-talentborder-glow')

    function frame.warModeButton:set_settings()
        self:SetNormalAtlas(C_PvP.IsWarModeDesired() and 'pvptalents-warmode-swords' or 'pvptalents-warmode-swords-disabled')
    end
    frame.warModeButton:SetScript('OnEvent', function(self, event)
        C_Timer.After(1, function() self:set_settings() end)
    end)

    frame.warModeButton:set_settings()
end]]






local function Init()
    if WoWToolsSave['Plus_UnitFrame'].hidePlayerFrame then
        return
    end

    local contextual= PlayerFrame_GetPlayerFrameContentContextual()--PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual
    local size= 18



--战斗中，提示
--PlayerPlayTime "您的在线时间已经超过3小时。您的游戏收益将降为正常值的50%%，为了您的健康，请尽快下线休息，做适当身体活动，合理安排学习生活。累计下线%d小时后，您将恢复正常的游戏收益。";
--point="TOPLEFT" relativePoint="TOPRIGHT" x="-21" y="-24"/>
    contextual.PlayerPlayTime:ClearAllPoints()
    contextual.PlayerPlayTime:SetPoint('RIGHT', contextual.GuideIcon, 'LEFT')
    contextual.PlayerPlayTime:SetSize(20,20)--原29x29




--[[do
    Create_warModeButton(PlayerFrame)--设置, 战争模式
end]]

--处理,小队, 号码
    PlayerFrameGroupIndicatorText:ClearAllPoints()
    PlayerFrameGroupIndicatorText:SetPoint('RIGHT', PlayerLevelText, 'LEFT')

    local function set_grouptext()
        if PlayerFrameGroupIndicatorText:IsVisible() then
            local text= PlayerFrameGroupIndicatorText:GetText() or ''
            local num= text:match('(%d)')
            if num then
                PlayerFrameGroupIndicatorText:SetFormattedText('|A:services-number-%s:22:22|a', num)
            end
        end
    end
    WoWTools_DataMixin:Hook('PlayerFrame_UpdateGroupIndicator', set_grouptext)
    WoWTools_ColorMixin:SetLabelColor(PlayerFrameGroupIndicatorText)
    WoWTools_TextureMixin:HideFrame(contextual.GroupIndicator)
    set_grouptext()



--玩家, 治疗，爆击，数字
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator.HitText:SetScale(0.75)
    WoWTools_ColorMixin:SetLabelColor(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator.HitText)--设置颜色
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator.HitText:ClearAllPoints()
    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator.HitText:SetPoint('TOPLEFT', PlayerFrame.PlayerFrameContainer.PlayerPortrait, 'BOTTOMLEFT', 0, -5)





--战斗中，提示
--<Anchor point="TOPLEFT" x="64" y="-62"/>
    contextual.AttackIcon:ClearAllPoints()
    contextual.AttackIcon:SetPoint('TOPLEFT', 68, -43)
    contextual.AttackIcon:SetVertexColor(1,0,0)
    contextual.AttackIcon.Bg= contextual:CreateTexture(nil, 'BACKGROUND')--加个外框
    contextual.AttackIcon.Bg:SetAtlas('talents-node-choiceflyout-circle-greenglow')
    contextual.AttackIcon.Bg:SetAllPoints(contextual.AttackIcon)
    contextual.AttackIcon:HookScript('OnShow', function(self)
        self.Bg:Show()
    end)
    contextual.AttackIcon:HookScript('OnHide', function(self)
        self.Bg:Hide()
    end)
    contextual.AttackIcon.Bg:SetShown(contextual.AttackIcon:IsShown())
--PlayerFrame_UpdateStatus()
    contextual.PlayerPortraitCornerIcon:SetVertexColor(0,1,0)







--等级，颜色
    WoWTools_DataMixin:Hook('PlayerFrame_UpdateLevel', function()
        PlayerLevelText:SetAlpha(
            UnitEffectiveLevel(PlayerFrame.unit or 'player')== GetMaxLevelForLatestExpansion() and 0 or 1
        )
        WoWTools_ColorMixin:SetLabelColor(PlayerLevelText)
    end)
--宠物
    if PetHitIndicator then
        PetHitIndicator:ClearAllPoints()
        PetHitIndicator:SetPoint('TOPLEFT', PetPortrait or PetHitIndicator:GetParent(), 'BOTTOMLEFT')
    end


--外框
    PlayerFrame.PlayerFrameContainer.FrameTexture:SetVertexColor(PlayerUtil.GetClassColor():GetRGB())--设置颜色


--移动，缩小，开启战争模式时，PVP图标
    WoWTools_DataMixin:Hook('PlayerFrame_UpdatePvPStatus', function()--开启战争模式时，PVP图标
        contextual.PVPIcon:SetSize(25,25)
        contextual.PVPIcon:ClearAllPoints()
        contextual.PVPIcon:SetPoint('RIGHT', PlayerFrame.PlayerFrameContainer.PlayerPortrait, 'LEFT', 13, -24)
    end)


--修改, 宠物, 名称)
    WoWTools_DataMixin:Hook('UnitFrame_OnEvent', function(self, event)
        if self.unit=='pet' and event == "UNIT_NAME_UPDATE" then
            self.name:SetText('|A:auctionhouse-icon-favorite:0:0|a')
        end
    end)




--移动zzZZ, 睡着
     contextual.PlayerRestLoop.RestTexture:SetPoint('TOPRIGHT', PlayerFrame.portrait, 14, 38)































     --全部有权限，助手，提示
    AssisterButton= CreateFrame('Button', '', contextual, 'WoWToolsButtonTemplate') -- WoWTools_ButtonMixin:Cbtn(contextual,{size=18})--点击，设置全员，权限
    AssisterButton:SetFrameStrata('HIGH')
    AssisterButton:SetAllPoints(contextual.LeaderIcon)
    ---AssisterButton:Hide()


    function AssisterButton:tooltip(tooltip)
        GameTooltip_SetTitle(tooltip,
            WoWTools_DataMixin.Icon.left
            ..(WoWTools_DataMixin.onlyChinese and '所有团队成员都获得团队助理权限' or ALL_ASSIST_DESCRIPTION)
            ..WoWTools_DataMixin.Icon.icon2
            ..': '..WoWTools_TextMixin:GetEnabeleDisable(IsEveryoneAssistant())
        )
    end



    AssisterButton:SetScript('OnMouseDown', function(self)
        SetEveryoneIsAssistant(not IsEveryoneAssistant())
        C_Timer.After(1, function()
            if self:IsMouseOver() then
                self:tooltip(GameTooltip)
                GameTooltip:Show()
            end
        end)
        print(
            WoWTools_UnitMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_DataMixin.onlyChinese and '所有团队成员都获得团队助理权限' or ALL_ASSIST_DESCRIPTION,
            WoWTools_TextMixin:GetEnabeleDisable(IsEveryoneAssistant())
        )
    end)
    AssisterButton.Icon= AssisterButton:CreateTexture(nil, 'OVERLAY', nil, 1)--助手，提示 PlayerFrame.xml
    AssisterButton.Icon:SetAllPoints(AssisterButton)
    AssisterButton.Icon:SetTexture('Interface\\GroupFrame\\UI-Group-AssistantIcon')
    --AssisterButton.Icon:Hide()
    AssisterButton.EveryoneAssistantIcon= AssisterButton:CreateTexture(nil, 'OVERLAY', nil, 6)--所有限员，有权限，提示
    AssisterButton.EveryoneAssistantIcon:SetPoint('CENTER', AssisterButton)
    AssisterButton.EveryoneAssistantIcon:SetAtlas('runecarving-menu-reagent-selected')
    AssisterButton.EveryoneAssistantIcon:SetSize(16,16)
    AssisterButton.EveryoneAssistantIcon:Hide()

    WoWTools_DataMixin:Hook('PlayerFrame_UpdatePartyLeader', function()
        local isLeader= UnitIsGroupLeader("player")
        local isAssist= UnitIsGroupAssistant('player')
        --AssisterButton:SetShown(isLeader and IsInRaid())
        --AssisterButton.Icon:SetShown(not isLeader and isAssist)
        --AssisterButton.EveryoneAssistantIcon:SetShown(IsEveryoneAssistant())
    end)












--拾取专精
    local LootButton= CreateFrame('Button', 'WoWToolsPlayerFrameLootButton', contextual, 'WoWToolsButtonTemplate')
    --LootButton:SetPoint('TOPLEFT', contextual, 'TOPRIGHT', -21, -24)
    LootButton:SetPoint('BOTTOMLEFT', contextual.LeaderIcon, 'BOTTOMRIGHT')
    LootButton:SetSize(size, size)
    LootButton:SetNormalTexture(0)
    WoWTools_ButtonMixin:AddMask(LootButton)

    local lootTipsTexture= LootButton:CreateTexture(nil, 'OVERLAY')
    lootTipsTexture:SetSize(8,8)
    --lootTipsTexture:SetAlpha(0.7)
    lootTipsTexture:SetPoint('TOP', 0, 4)
    lootTipsTexture:SetAtlas('Banker')
    function LootButton:tooltip(tooltip)

        local text=''
        local lootSpecID = GetLootSpecialization()
        if lootSpecID then
            local name, _, texture= select(2, GetSpecializationInfoByID(lootSpecID))
            if texture and name then
                text= ' |T'..texture..':0|t'..name
            end
        end
        GameTooltip_SetTitle(tooltip,
            '|A:Banker:0:0|a'--..(WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION),
            ..format(
                WoWTools_DataMixin.onlyChinese and '专精拾取已设置为：%s' or ERR_LOOT_SPEC_CHANGED_S,
                text
            )
        )
        local name, _, icon= PlayerUtil.GetSpecName()
        tooltip:AddLine(
            WoWTools_DataMixin.Icon.left
            ..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
            ..' |T'..(icon or 0)..':0|t'..(name or '')
            ..WoWTools_DataMixin.Icon.icon2
        )
    end

    function LootButton:set_shown()
        local find=false
        if WoWTools_UnitMixin:UnitIsUnit(PlayerFrame.unit, 'player') then
            local currentSpec = GetSpecialization()
            local specID= currentSpec and C_SpecializationInfo.GetSpecializationInfo(currentSpec)
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
        C_Timer.After(0.5, function()
            if self:IsMouseOver() then
                self:tooltip(GameTooltip)
                GameTooltip:Show()
            end
        end)
    end

    LootButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    LootButton:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    LootButton:RegisterUnitEvent('UNIT_ENTERED_VEHICLE','player')
    LootButton:RegisterUnitEvent('UNIT_EXITED_VEHICLE','player')

    LootButton:SetScript('OnEvent', function (self)
        self:set_shown()
    end)

    LootButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            SetLootSpecialization(0)
            local currentSpec = GetSpecialization()
            local specID= currentSpec and C_SpecializationInfo.GetSpecializationInfo(currentSpec)
            local name, _, texture= select(2, GetSpecializationInfoByID(specID or 0))

            print(WoWTools_UnitMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION,
                texture and '|T'..texture..':0|t' or '',
                WoWTools_TextMixin:CN(name)
            )
        else
            MenuUtil.CreateContextMenu(self, function(_, root)
                WoWTools_MenuMixin:Set_Specialization(root)
            end)
        end
    end)


    LootButton:set_shown()























--Riad 副本, 地下城，指示, 
    local InsFrame= CreateFrame("Frame", 'WoWToolsPlayerFrameInstanceFrame', contextual)
    InsFrame:SetPoint('BOTTOMLEFT', LootButton, 'BOTTOMRIGHT')
    InsFrame:SetSize(size, size)

--图标
    InsFrame.raid= CreateFrame('Button', nil, InsFrame, 'WoWToolsButtonTemplate')
    InsFrame.raid:SetAllPoints(InsFrame)
    InsFrame.raid:SetNormalAtlas('UI-HUD-Minimap-GuildBanner-Mythic-Large')

--10人，25人
    InsFrame.raid.text= InsFrame.raid:CreateFontString(nil, 'ARTWORK', 'WoWToolsFont')-- WoWTools_LabelMixin:Create(InsFrame, {color=true})
    InsFrame.raid.text:SetPoint('TOP',0,8)

    InsFrame.raid:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local dungeonID= GetRaidDifficultyID()
        GameTooltip:AddLine(self.tooltip)
        GameTooltip:AddLine(' ')
        local tab={
            DifficultyUtil.ID.DungeonNormal,
            DifficultyUtil.ID.DungeonHeroic,
            DifficultyUtil.ID.DungeonMythic
        }
        for _, ID in pairs(tab) do
            local text= WoWTools_MapMixin:GetDifficultyColor(nil, ID)
            text= ID==dungeonID and '|A:common-icon-rotateright:0:0|a'..text..'|A:common-icon-rotateleft:0:0|a' or text
            GameTooltip:AddLine(
                (text==self.name and '|A:common-icon-rotateright:0:0|a' or '')
                ..text
                ..(text==self.name and '|A:common-icon-rotateleft:0:0|a' or '')
            )
        end

        GameTooltip:Show()
        self:SetAlpha(0.3)
        self.text:SetAlpha(0.3)
    end)


--5人 副本, 地下城，指示
    InsFrame.dungeon= CreateFrame('Button', nil, InsFrame, 'WoWToolsButtonTemplate')
    InsFrame.dungeon:SetPoint('BOTTOMLEFT', InsFrame, 'BOTTOMRIGHT')
    InsFrame.dungeon:SetSize(size, size)
    InsFrame.dungeon:SetNormalAtlas('DungeonSkull')


--外框
    --[[local portrait= InsFrame:CreateTexture(nil, 'OVERLAY')
    portrait:SetAtlas('UI-HUD-UnitFrame-TotemFrame')
    portrait:SetPoint('CENTER', InsFrame.dungeon,1,0)
    portrait:SetSize(20,20)
    WoWTools_TextureMixin:SetAlphaColor(portrait, nil, nil, 1)]]

--提示
    InsFrame.dungeon:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)

    function InsFrame.dungeon:tooltip()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        local dungeonID= GetDungeonDifficultyID()
        --local text=WoWTools_MapMixin:GetDifficultyColor(nil, dungeonID)
        GameTooltip_SetTitle(GameTooltip,
            '|A:DungeonSkull:0:0|a'..(WoWTools_DataMixin.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY)
            ..WoWTools_DataMixin.Icon.icon2
        )
        GameTooltip:AddLine(' ')
        for _, id in pairs({
            DifficultyUtil.ID.DungeonNormal,
            DifficultyUtil.ID.DungeonHeroic,
            DifficultyUtil.ID.DungeonMythic
        }) do
            local isCur= id==dungeonID
            local text= WoWTools_MapMixin:GetDifficultyColor(nil, id)
            if isCur then
                text= '|A:common-icon-rotateright:0:0|a'..text..'|A:common-icon-rotateleft:0:0|a'
            end

            local set
            if id==DifficultyUtil.ID.DungeonMythic then
                set= (
                        (UnitIsGroupLeader("player") or not IsInGroup() and not isCur) and '|cnGREEN_FONT_COLOR:' or '|cnDISABLED_FONT_COLOR:'
                    )
                    ..WoWTools_DataMixin.Icon.left
                    ..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
                    ..'|r'
            end

            GameTooltip:AddLine(text..(set or '')
            )
        end
        GameTooltip:Show()
    end

    InsFrame.dungeon:SetScript('OnClick', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, function(_, root)
                WoWTools_MenuMixin:DungeonDifficulty(self, root)
            end)
        elseif (UnitIsGroupLeader("player") or not IsInGroup()) and GetDungeonDifficultyID()~=DifficultyUtil.ID.DungeonMythic then
            SetDungeonDifficultyID(DifficultyUtil.ID.DungeonMythic)
            --[[C_Timer.After(0.5, function()
                if self:IsMouseOver() then
                    self:tooltip()
                end
            end)]]
        end
    end)


    function InsFrame:set_settings()
        local ins, findRiad, findDungeon=  IsInInstance(), false, false
        if not ins and WoWTools_UnitMixin:UnitIsUnit(PlayerFrame.unit, 'player') and not DifficultyUtil.InStoryRaid() then
            local difficultyID2 = GetDungeonDifficultyID() or 0
            local difficultyID3= GetRaidDifficultyID() or 0
            local displayMythic3 = select(6, GetDifficultyInfo(difficultyID3))

            local name2, color2= WoWTools_MapMixin:GetDifficultyColor(nil, difficultyID2)
            local name3, color3= WoWTools_MapMixin:GetDifficultyColor(nil, difficultyID3)
            if not name3 and difficultyID3 then
                name3= GetDifficultyInfo(difficultyID3) or difficultyID3
            end

            local text3= (WoWTools_DataMixin.onlyChinese and '团队副本难度' or RAID_DIFFICULTY)..': '..name3..'|r'

            local otherDifficulty = GetLegacyRaidDifficultyID()
            local size3= otherDifficulty and DifficultyUtil.GetMaxPlayers(otherDifficulty)--UnitPopup.lua
            if size3 and not displayMythic3 then
                text3= text3..'|n'..(WoWTools_DataMixin.onlyChinese and '经典团队副本难度' or LEGACY_RAID_DIFFICULTY)..': '..(size3==10 and (WoWTools_DataMixin.onlyChinese and '10人' or RAID_DIFFICULTY1) or size3==25 and (WoWTools_DataMixin.onlyChinese and '25人' or RAID_DIFFICULTY2) or '')
            end

            if name3 and (name3~=name2 or not displayMythic3) then
                self.raid:GetNormalTexture():SetVertexColor(color3:GetRGB())
                self.raid.tooltip= text3
                self.raid.name= name3
                self.raid.text:SetText((size3 and not displayMythic3) and size3 or '')
                self.raid.text:SetTextColor(color3:GetRGB())
                findRiad=true
            else
                self.raid.text:SetText('')
            end

            if name2  then
                self.dungeon:GetNormalTexture():SetVertexColor(color2:GetRGB())
                local text2= (WoWTools_DataMixin.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY)..': '..name2

                if not findRiad then
                    text2= text2..(text3 and '|n|n'..text3 or '')
                end
                self.dungeon.tooltip=text2
                self.dungeon.name= name2
                findDungeon= true
            end
            self.raid:SetShown(findRiad)
            self.dungeon:SetShown(findDungeon)
        end
        self:SetShown(not ins)
    end

    --InsFrame.t= WoWTools_TextMixin:Magic(ERR_DUNGEON_DIFFICULTY_CHANGED_S)--:gsub('%%s', '(.+)')--"地下城难度已设置为%s。"
    --InsFrame.t2= WoWTools_TextMixin:Magic(ERR_RAID_DIFFICULTY_CHANGED_S)--:gsub('%%s', '(.+)')--"团队副本难度设置为%s。"
    --InsFrame.t3= WoWTools_TextMixin:Magic(ERR_LEGACY_RAID_DIFFICULTY_CHANGED_S)--:gsub('%%s', '(.+)')--"已将经典团队副本难度设置为%s。"

    InsFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

    InsFrame:SetScript('OnEvent', function(self, event, arg1)
        if event=='PLAYER_ENTERING_WORLD' then
            if IsInInstance() then
                self:UnregisterEvent('PLAYER_DIFFICULTY_CHANGED')--会出错误，冒险指南，打开世界BOSS
            else
                self:RegisterEvent('PLAYER_DIFFICULTY_CHANGED')
            end
        end
        self:set_settings()--副本, 地下城，指示
        --[[if canaccessvalue(arg1)
            and arg1
            and arg1:find(self.t)
            or arg1:find(self.t2)
            or arg1:find(self.t3)
        then]]
    end)

    InsFrame:set_settings()


















--挑战，数据
    local KeyFrame= CreateFrame("Button", 'WoWToolsPlayerFrameKeystoneFrame', contextual, 'WoWToolsButtonTemplate')
    KeyFrame:SetSize(size, size)

    --KeyFrame:SetPoint('LEFT', contextual.LeaderIcon, 'RIGHT',0,-2)
    KeyFrame:SetPoint('BOTTOMLEFT', InsFrame.dungeon, 'BOTTOMRIGHT')
    --[[KeyFrame.texture=KeyFrame:CreateTexture()
    KeyFrame.texture:SetAllPoints()
    KeyFrame.texture:SetTexture(4352494)
    WoWTools_ButtonMixin:AddMask(KeyFrame, false, KeyFrame.texture)
    WoWTools_ButtonMixin:AddMask(KeyFrame)]]

    KeyFrame.Text= KeyFrame:CreateFontString(nil, 'BORDER', 'WoWToolsFont') -- WoWTools_LabelMixin:Create(KeyFrame, {color=true})
    WoWTools_ColorMixin:SetLabelColor(KeyFrame.Text)
    KeyFrame.Text:SetPoint('LEFT')
    KeyFrame:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip:Hide() end)
    KeyFrame:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip_SetTitle(GameTooltip, WoWTools_UnitMixin.addName..WoWTools_DataMixin.Icon.icon2)
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

    function KeyFrame:set_settings()
        local text
        local show= WoWTools_DataMixin.Player.IsMaxLevel
                    and not PlayerIsTimerunning()
                    and C_MythicPlus.IsMythicPlusActive()
                       -- or WoWTools_DataMixin.Player.husandro
        local score= show and C_ChallengeMode.GetOverallDungeonScore() or 0
        if score>0 then
            local activeText= WoWTools_ChallengeMixin:GetRewardText(1)--得到，周奖励，信息
            activeText= activeText and ' ('..activeText..') '
            text= WoWTools_ChallengeMixin:KeystoneScorsoColor(score)..(activeText or '')--分数
            local info = C_MythicPlus.GetRunHistory(false, true) or {}--次数
            local num= #info
            if num>0 then
                text= text..num
            end
        end
        self.Text:SetText(text or (WoWTools_DataMixin.Player.husandro and '4/8/12') or '|T4352494:0|t')
        --self:SetShown(show)
    end

    KeyFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    KeyFrame:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')--地下城挑战
    KeyFrame:RegisterEvent('WEEKLY_REWARDS_UPDATE')--地下城挑战
    KeyFrame:RegisterEvent('CHALLENGE_MODE_COMPLETED')
    KeyFrame:RegisterEvent('PLAYER_LEVEL_UP')

    KeyFrame:SetScript('OnEvent', function(self)
        C_Timer.After(2, function() self:set_settings() end)
    end)

    KeyFrame:set_settings()



    Init=function()end
end













function WoWTools_UnitMixin:Init_PlayerFrame()--玩家
    Init()
end