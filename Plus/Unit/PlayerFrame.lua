--玩家 PlayerFrame.lua
local function Save()
    return WoWToolsSave['Plus_UnitFrame']
end









local function Init()
    if Save().hidePlayerFrame then
        return
    end

    local contextual= PlayerFrame_GetPlayerFrameContentContextual()--PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual
    local size=20



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
    AssisterButton= CreateFrame('Button', 'WoWToolsPlayerFrameAssisterButton', contextual, 'WoWToolsButtonTemplate') -- WoWTools_ButtonMixin:Cbtn(contextual,{size=18})--点击，设置全员，权限
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
        C_Timer.After(0.5, function()
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
        AssisterButton:SetShown(isLeader and IsInRaid())
        AssisterButton.Icon:SetShown(not isLeader and isAssist)
        AssisterButton.EveryoneAssistantIcon:SetShown(IsEveryoneAssistant())
    end)

























--拾取专精
    local LootButton= CreateFrame('DropdownButton', 'WoWToolsPlayerFrameLootButton', contextual, 'WoWToolsMenu3Template')
    LootButton:SetPoint('BOTTOMLEFT', contextual.LeaderIcon, 'BOTTOMRIGHT')
    LootButton:SetSize(size, size)
    LootButton:SetNormalTexture(0)
    WoWTools_ButtonMixin:AddMask(LootButton)

    LootButton.texture= LootButton:CreateTexture(nil, 'OVERLAY')
    LootButton.texture:SetSize(10, 10)
    LootButton.texture:SetPoint('BOTTOM')
    LootButton.texture:SetAtlas('VignetteLoot')
    function LootButton:tooltip(tooltip)

        local text=''
        local lootSpecID = GetLootSpecialization()
        if lootSpecID then
            local name, _, texture= select(2, GetSpecializationInfoByID(lootSpecID))
            text= ' |T'..(texture or 0)..':0|t'..(WoWTools_TextMixin:CN(name) or '')
        end
        GameTooltip_SetTitle(tooltip,
            '|A:VignetteLoot:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)
            ..text
        )

        tooltip:AddLine(' ')
        local name, _, icon= PlayerUtil.GetSpecName()
        GameTooltip_AddInstructionLine(tooltip,
            '<'
            ..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
            ..WoWTools_DataMixin.Icon.left
            ..' |T'..(icon or 0)..':0|t'..(WoWTools_TextMixin:CN(name) or '')
            ..'>'
        )
        GameTooltip_AddInstructionLine(tooltip,
            '<'
            ..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
            ..WoWTools_DataMixin.Icon.right
            ..'>'
        )
    end

    function LootButton:settings()
        local specID = PlayerUtil.GetCurrentSpecID() or 0
        local lootSpecID = GetLootSpecialization()
        lootSpecID= lootSpecID==0 and specID or lootSpecID
        self:SetNormalTexture(select(3, PlayerUtil.GetSpecNameBySpecID(lootSpecID)) or 0)
        self.texture:SetShown(specID~=lootSpecID)
        self:SetShown(Save().showLootButton or specID~=lootSpecID)
    end

    LootButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    LootButton:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    LootButton:RegisterUnitEvent('UNIT_ENTERED_VEHICLE','player')
    LootButton:RegisterUnitEvent('UNIT_EXITED_VEHICLE','player')
    LootButton:SetScript('OnEvent', LootButton.settings)

    LootButton:SetupMenu(function(self, root)
        if self:IsMouseOver() then
            WoWTools_MenuMixin:Set_Specialization(root)
            root:CreateDivider()
            root:CreateCheckbox(
                WoWTools_DataMixin.onlyChinese and '总是显示' or BATTLEFIELD_MINIMAP_SHOW_ALWAYS,
            function()
                return Save().showLootButton
            end, function()
                Save().showLootButton= not Save().showLootButton and true or nil
                self:settings()
            end)
        end
    end)

    LootButton:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            self:CloseMenu()
            SetLootSpecialization(0)
            local currentSpec = GetSpecialization()
            local specID= currentSpec and C_SpecializationInfo.GetSpecializationInfo(currentSpec)
            local name, _, texture= select(2, GetSpecializationInfoByID(specID or 0))

            print(WoWTools_UnitMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION,
                texture and '|T'..texture..':0|t' or '',
                WoWTools_TextMixin:CN(name)
            )

            WoWToolsButton_OnEnter(self)
        end
    end)

























--图标
    local RaidButton= CreateFrame('DropdownButton', 'WoWToolsPlayerFrameRaidButton', contextual, 'WoWToolsMenu3Template')
    RaidButton:SetSize(size, size)
    RaidButton:SetPoint('BOTTOMLEFT', LootButton, 'BOTTOMRIGHT')

--10人，25人
    RaidButton.text= RaidButton:CreateFontString(nil, 'ARTWORK', 'WoWToolsFont2')-- WoWTools_LabelMixin:Create(InsFrame, {color=true})
    RaidButton.text:SetPoint('CENTER')
    RaidButton.text:SetJustifyH('CENTER')
    RaidButton.texture= RaidButton:CreateTexture(nil, 'BORDER')
    RaidButton.texture:SetAllPoints()
    RaidButton.texture:SetAtlas('UI-HUD-Minimap-GuildBanner-Mythic-Large')

    function RaidButton:tooltip(tooltip)
        if DifficultyUtil.InStoryRaid() then
            GameTooltip_AddErrorLine(tooltip,
                WoWTools_DataMixin.onlyChinese and '在剧情模式不可用' or DIFFICULTY_LOCKED_REASON_STORY_RAID
            )
            tooltip:AddLine(' ')
        end

        local difficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo())
        if isDynamicInstance and CanChangePlayerDifficulty() then
            local toggleDifficultyID = select(7, GetDifficultyInfo(difficultyID))
            if toggleDifficultyID then
                tooltip:AddDoubleLine(
                    WoWTools_DataMixin.onlyChinese and '可修改难度' or 'Difficulty can be changed',
                    WoWTools_MapMixin:GetDifficultyColor(nil, toggleDifficultyID),
                    0,1,0
                )
            end
        end

        local dungeonID= GetRaidDifficultyID() or 0
        tooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '团队副本难度' or RAID_DIFFICULTY)
            ..' '..dungeonID,
            WoWTools_MapMixin:GetDifficultyColor(nil, dungeonID),
            1,0.82,0, 1,1,1
        )

        local legacyID= GetLegacyRaidDifficultyID() or 0
        legacyID= NormalizeLegacyDifficultyID(legacyID)
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '经典团队副本难度' or LEGACY_RAID_DIFFICULTY,
            dungeonID==DifficultyUtil.ID.PrimaryRaidMythic and WoWTools_TextMixin:GetEnabeleDisable(false)
            or (legacyID==DifficultyUtil.ID.Raid10Normal and (WoWTools_DataMixin.onlyChinese and '10人' or RAID_DIFFICULTY1))
            or (legacyID==DifficultyUtil.ID.Raid25Normal and (WoWTools_DataMixin.onlyChinese and '25人' or RAID_DIFFICULTY2))
            or (WoWTools_DataMixin.onlyChinese and '无' or NONE),
            1,0.82,0, 1,1,1
        )

        tooltip:AddLine(' ')

        local isLeader= UnitIsGroupLeader("player") or not IsInGroup()
        local color= isLeader and GREEN_FONT_COLOR or DISABLED_FONT_COLOR

        tooltip:AddLine(
            '<'
            ..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
            ..WoWTools_DataMixin.Icon.left
            ..'|A:UI-HUD-Minimap-GuildBanner-Mythic-Large:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '英雄' or PLAYER_DIFFICULTY2)
            ..'>',
            color:GetRGB()
        )
        tooltip:AddLine(
            '<'
            ..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
            ..WoWTools_DataMixin.Icon.right
            ..'>',
            color:GetRGB()
        )
    end

    RaidButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    RaidButton:RegisterEvent('GROUP_LEFT')
    RaidButton:RegisterEvent('GROUP_ROSTER_UPDATE')
    RaidButton:RegisterEvent('PLAYER_DIFFICULTY_CHANGED')
    RaidButton:SetScript('OnEvent', function(self)
        if IsInInstance() and not IsInRaid()--不在团本里
            --or (IsInGroup() and not isInRaid and not UnitIsGroupLeader("player"))--队伍没有权限
        then
            self:SetShown(false)
            return
        end

        local dungeonID= GetRaidDifficultyID() or 0
        local legacyID= GetLegacyRaidDifficultyID() or 0
        local legacyText

        if dungeonID<DifficultyUtil.ID.PrimaryRaidMythic then
            legacyID= NormalizeLegacyDifficultyID(legacyID)
            if legacyID==DifficultyUtil.ID.Raid10Normal then
                legacyText= '10'
            elseif legacyID==DifficultyUtil.ID.Raid25Normal then
                legacyText= '25'
            end
        end
        self.text:SetText(legacyText or '')

        local color= select(2, WoWTools_MapMixin:GetDifficultyColor(nil, dungeonID))
        self.texture:SetVertexColor(color:GetRGB())
        self.text:SetTextColor(color:GetRGB())

        self:SetShown(true)
    end)

    RaidButton:SetupMenu(function(self, root)
        if self:IsMouseOver() then
            WoWTools_MenuMixin:DungeonDifficulty(self, root)
        end
    end)
    RaidButton:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and (UnitIsGroupLeader("player") or not IsInGroup()) then
            self:CloseMenu()
            SetRaidDifficulties(true, DifficultyUtil.ID.PrimaryRaidHeroic)
            SetRaidDifficulties(false, DifficultyUtil.ID.Raid25Normal)
            C_Timer.After(0.5, function()
            if self:IsMouseOver() then
                WoWToolsButton_OnEnter(self)
            end
        end)
        end
    end)
    RaidButton:SetScript('OnMouseWheel', function(self, d)
        local isLeader= UnitIsGroupLeader("player") or not IsInGroup()
        if not isLeader then
            return
        end

        local dungeonID= GetRaidDifficultyID() or DifficultyUtil.ID.PrimaryRaidNormal
        local toggleDifficultyID= d==1 and dungeonID-1 or dungeonID+1
        toggleDifficultyID= math.max(toggleDifficultyID, DifficultyUtil.ID.PrimaryRaidNormal)
        toggleDifficultyID= math.min(toggleDifficultyID, DifficultyUtil.ID.PrimaryRaidMythic)

        SetRaidDifficulties(true, toggleDifficultyID)

        if toggleDifficultyID<DifficultyUtil.ID.PrimaryRaidMythic then
            if NormalizeLegacyDifficultyID(GetLegacyRaidDifficultyID() or 0) ~= DifficultyUtil.ID.Raid25Normal then
                SetRaidDifficulties(false, DifficultyUtil.ID.Raid25Normal)
            end
        end

        C_Timer.After(0.5, function()
            if self:IsMouseOver() then
                WoWToolsButton_OnEnter(self)
            end
        end)
    end)




















    local DungeonButton= CreateFrame('DropdownButton', 'WoWToolsPlayerFrameDungeonButton', contextual, 'WoWToolsMenu3Template')
    DungeonButton:SetSize(size, size)
    DungeonButton:SetPoint('BOTTOMLEFT', RaidButton, 'BOTTOMRIGHT')

    DungeonButton.texture= DungeonButton:CreateTexture(nil, 'BORDER')
    DungeonButton.texture:SetAllPoints()
    DungeonButton.texture:SetAtlas('DungeonSkull')

    function DungeonButton:tooltip(tooltip)
        local dungeonID= GetDungeonDifficultyID() or 0
        tooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY)
            ..' '..dungeonID,
            WoWTools_MapMixin:GetDifficultyColor(nil, dungeonID),
            1,0.82,0, 1,1,1
        )

        local isLeader= UnitIsGroupLeader("player") or not IsInGroup()
        local color= isLeader and GREEN_FONT_COLOR or DISABLED_FONT_COLOR

        tooltip:AddLine(' ')

        tooltip:AddLine(
            '<'
            ..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
            ..WoWTools_DataMixin.Icon.left
            ..'|A:DungeonSkull:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '史诗' or PLAYER_DIFFICULTY6)
            ..'>',
            color:GetRGB()
        )

        GameTooltip_AddInstructionLine(tooltip,
            '<'
            ..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
            ..WoWTools_DataMixin.Icon.right
            ..'>'
        )
    end

    DungeonButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    DungeonButton:RegisterEvent('GROUP_LEFT')
    DungeonButton:RegisterEvent('GROUP_ROSTER_UPDATE')
    DungeonButton:RegisterEvent('PLAYER_DIFFICULTY_CHANGED')
    DungeonButton:SetScript('OnEvent', function(self)
        if IsInRaid() then
            self:SetShown(false)
            return
        end

        local color= select(2, WoWTools_MapMixin:GetDifficultyColor(nil, GetDungeonDifficultyID() or 0))
        self.texture:SetVertexColor(color:GetRGB())

        if self:IsMouseOver() then
            WoWToolsButton_OnEnter(self)
        end

        self:SetShown(true)
    end)


    DungeonButton:SetupMenu(function(self, root)
        if self:IsMouseOver() then
            WoWTools_MenuMixin:DungeonDifficulty(self, root)
        end
    end)
    DungeonButton:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and (UnitIsGroupLeader("player") or not IsInGroup()) then
            self:CloseMenu()
            SetDungeonDifficultyID(DifficultyUtil.ID.DungeonMythic)
            C_Timer.After(0.5, function()
                if self:IsMouseOver() then
                    WoWToolsButton_OnEnter(self)
                end
            end)
        end
    end)

    DungeonButton:SetScript('OnMouseWheel', function(_, d)
        if UnitIsGroupLeader("player") or not IsInGroup() then
            local dungeonID= GetDungeonDifficultyID() or DifficultyUtil.ID.DungeonMythic



            local toggleDifficultyID= d==1 and dungeonID-1 or dungeonID+1
            if toggleDifficultyID==DifficultyUtil.ID.DungeonMythic-1 then
                toggleDifficultyID= DifficultyUtil.ID.DungeonHeroic

            elseif toggleDifficultyID== DifficultyUtil.ID.DungeonHeroic+1 then
                toggleDifficultyID= DifficultyUtil.ID.DungeonMythic
            end

            toggleDifficultyID= math.max(toggleDifficultyID, DifficultyUtil.ID.DungeonNormal)
            toggleDifficultyID= math.min(toggleDifficultyID, DifficultyUtil.ID.DungeonMythic)

            SetDungeonDifficultyID(toggleDifficultyID)
        end
    end)
















--挑战，数据
    local KeyButton= CreateFrame("Button", 'WoWToolsPlayerFrameKeystoneButton', contextual, 'WoWToolsButtonTemplate')
    KeyButton:SetSize(size, size)

    KeyButton:SetPoint('BOTTOMLEFT', DungeonButton, 'BOTTOMRIGHT')

    KeyButton.Text= KeyButton:CreateFontString(nil, 'BORDER', 'WoWToolsFont') -- WoWTools_LabelMixin:Create(KeyButton, {color=true})
    WoWTools_ColorMixin:SetLabelColor(KeyButton.Text)
    KeyButton.Text:SetPoint('LEFT')

    function KeyButton:tooltip(tooltip)
        if WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link then
            tooltip:AddLine('|T4352494:0|t'..WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link)
            tooltip:AddLine(' ')
        end
        WoWTools_ChallengeMixin:ActivitiesTooltip()
        tooltip:AddLine(' ')
        WoWTools_LabelMixin:ItemCurrencyTips({showTooltip=true, showName=true, showAll=true})
    end

    function KeyButton:set_settings()
        local text
        local show= WoWTools_DataMixin.Player.IsMaxLevel
                    and not PlayerIsTimerunning()
                    and C_MythicPlus.IsMythicPlusActive()
                    or WoWTools_DataMixin.Player.husandro

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
        self.Text:SetText(text or format('|T4352494:%d|t', size-4))
        self:SetShown(show)
    end

    KeyButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    KeyButton:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')--地下城挑战
    KeyButton:RegisterEvent('WEEKLY_REWARDS_UPDATE')--地下城挑战
    KeyButton:RegisterEvent('CHALLENGE_MODE_COMPLETED')
    KeyButton:RegisterEvent('PLAYER_LEVEL_UP')

    KeyButton:SetScript('OnEvent', function(self)
        C_Timer.After(2, function() self:set_settings() end)
    end)


    KeyButton:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:OpenWoWItemListFrame()--战团，物品列表
    end)
    --KeyButton:set_settings()



    Init=function()end
end













function WoWTools_UnitMixin:Init_PlayerFrame()--玩家
    Init()
end













--[[设置, 战争模式 Blizzard_WarmodeButtonTemplate.lua
local function Create_warModeButton(frame)
    frame.warModeButton= WoWTools_ButtonMixin:Cbtn(frame, {size=20, isType2=true, name='WoWToolsPlayerFrameWarModeButton'})
    frame.warModeButton:SetPoint('LEFT', frame, 5, 12)
    frame.warModeButton:SetScript('OnClick',  function(self)
        --C_PvP.ToggleWarMode()
        WoWTools_LoadUIMixin:SpellBook(2)
        --C_Timer.After(0.5, function() if GameTooltip:IsShown() then self:set_tooltip() end end)
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
        C_Timer.After(0.5, function() self:set_settings() end)
    end)

    frame.warModeButton:set_settings()
end]]

