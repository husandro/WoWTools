--挑战,钥石,插入界面
local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end

local KeyFrame
































--##################
--挑战,钥石,插入,界面
--##################
local function UI_Party_Info()--队友位置
    local UnitTab={}
    local name, uiMapID=WoWTools_MapMixin:GetUnit('player')
    local text
    local all= GetNumGroupMembers()
    all= all==0 and 1 or all--没有队友, 1人
    for i=1, all do
        local unit='party'..i
        if i==all then
            unit='player'
        end
        local guid=UnitGUID(unit)
        if guid then
            text= text and text..'|n' or ''

            local stat=GetReadyCheckStatus(unit)
            if stat=='ready' then
                text= text..format('|A:%s:0:0|a', 'common-icon-checkmark')
            elseif stat=='waiting' then
                text= text..'  '
            elseif stat=='notready' then
                text= format('%s|A:%s:0:0|a', text, 'talents-button-reset')
            end

            local tab= WoWTools_DataMixin.UnitItemLevel[guid]--装等
            if tab then
                if tab.itemLevel then
                    text= text..'|A:charactercreate-icon-customize-body-selected:0:0|a'..tab.itemLevel
                else
                    table.insert(UnitTab, unit)
                end
            end

            local info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)--挑战, 分数
            if info and info.currentSeasonScore and info.currentSeasonScore>0 then
                text= text..WoWTools_ChallengeMixin:KeystoneScorsoColor(info.currentSeasonScore, true)
                if info.runs and info.runs then
                    local bestRunLevel=0
                    for _, run in pairs(info.runs) do
                        if run.bestRunLevel and run.bestRunLevel>bestRunLevel then
                            bestRunLevel=run.bestRunLevel
                        end
                    end
                    if bestRunLevel>0 then
                        text= text..'('..bestRunLevel..')'
                    end
                end
            end

            text= text..WoWTools_UnitMixin:GetPlayerInfo({guid=guid, unit=unit, name=name, reName=true, reRealm=true})--信息

            local name2, uiMapID2=WoWTools_MapMixin:GetUnit(unit)
            if (name and name==name2) or (uiMapID and uiMapID==uiMapID2) then--地图名字
                text=text..format('|A:%s:0:0|a', 'common-icon-checkmark')
            elseif name2 then
                text=text ..'|A:poi-islands-table:0:0|a'..name2
            else
                text= text.. '|A:questlegendary:0:0|a'
            end

            local reason=UnitPhaseReason(unit)--位面
            if reason then
                if reason==0 then--不同了阶段
                    text= text ..'|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '不同了阶段' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('',  MAP_BAR_THUNDER_ISLE_TITLE0:gsub('1','')))..'|r'
                elseif reason==1 then--不在同位面
                    text= text ..'|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '不在同位面' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', WoWTools_DataMixin.Player.Language.layer))..'|r'
                elseif reason==2 then--战争模式
                    text= text ..(C_PvP.IsWarModeDesired() and '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF)..'|r' or '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '开启战争模式' or ERR_PVP_WARMODE_TOGGLE_ON)..'|r')
                elseif reason==3 then
                    text= text..'|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)..'|r'
                end
            end


        end
    end

    KeyFrame.PartyInfoText:SetText(text or '')
    WoWTools_UnitMixin:GetNotifyInspect(UnitTab)--取得装等
end
















--插入, KEY时, 说

local function Set_SlotKeystoneSay()
    local mapChallengeModeID, affixes, powerLevel = C_ChallengeMode.GetSlottedKeystoneInfo()
    if not Save().slotKeystoneSay
        or ChallengesKeystoneFrame:IsVisible()
        or not mapChallengeModeID
    then
        return
    end

    local name, _, timeLimit= C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)

    if not name then
        return
    end


    local journalInstanceID= WoWTools_DataMixin.ChallengesSpellTabs[mapChallengeModeID] and WoWTools_DataMixin.ChallengesSpellTabs[mapChallengeModeID].ins
    if journalInstanceID then
        name = select(8, EJ_GetInstanceInfo(journalInstanceID)) or ('|Hjournal:0:'..journalInstanceID..':23|h['..name..']|h')
    end

    local m= name..'('.. powerLevel..'): '

    for _,v in pairs(affixes or {}) do
        local name2=C_ChallengeMode.GetAffixInfo(v)
        if name2 then
            m=m..name2..', '
        end
    end
    m=m..WoWTools_TimeMixin:SecondsToClock(timeLimit)
    WoWTools_ChatMixin:Chat(m, nil, nil)
end




















local function Init_Buttons()--挑战,钥石,插入界面

--插入, KEY
    KeyFrame.InsetKeyButton = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--插入
    KeyFrame.InsetKeyButton:SetPoint('RIGHT', ChallengesKeystoneFrame, -12, 75)
    KeyFrame.InsetKeyButton:SetSize(70,24)
    KeyFrame.InsetKeyButton:SetText(WoWTools_DataMixin.onlyChinese and '插入' or  COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN)
    KeyFrame.InsetKeyButton:SetScript("OnMouseDown",function()
        if InCombatLockdown() then
            print(
                WoWTools_DataMixin.Icon.icon2.. WoWTools_ChallengeMixin.addName,
                '|cnRED_FONT_COLOR:',
                WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT
            )
            return
        end
        ItemButtonUtil.OpenAndFilterBags(ChallengesKeystoneFrame)

        if ItemButtonUtil.GetItemContext() == nil then return end

        local itemLocation = ItemLocation:CreateEmpty()
        for bagID= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do--ContainerFrame.lua
            for slotIndex = 1, ContainerFrame_GetContainerNumSlots(bagID) do
                itemLocation:SetBagAndSlot(bagID, slotIndex)
                if ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation) == ItemButtonUtil.ItemContextMatchResult.Match then
                    C_Container.UseContainerItem(bagID, slotIndex)
                    return
                end
            end
        end
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_ChallengeMixin.addName,
            '|cnRED_FONT_COLOR:',
            WoWTools_DataMixin.onlyChinese and '钥石：尚未发现' or format(CHALLENGE_MODE_KEYSTONE_NAME, TAXI_PATH_UNREACHABLE)
        )
    end)

--插入史诗钥石, 说，提示
    KeyFrame.ChatTooltipTexture= KeyFrame.InsetKeyButton:CreateTexture(nil, 'OVERLAY')
    KeyFrame.ChatTooltipTexture:SetSize(12, 12)
    KeyFrame.ChatTooltipTexture:SetPoint('LEFT')
    KeyFrame.ChatTooltipTexture:SetAtlas('transmog-icon-chat')



--清除, KEY
    KeyFrame.ClearKeyButton = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--清除KEY
    KeyFrame.ClearKeyButton:SetPoint('TOPRIGHT', KeyFrame.InsetKeyButton, 'BOTTOMRIGHT', 0, -4)
    KeyFrame.ClearKeyButton:SetSize(70,24)
    KeyFrame.ClearKeyButton:SetText(WoWTools_DataMixin.onlyChinese and '清除' or  SLASH_STOPWATCH_PARAM_STOP2)
    KeyFrame.ClearKeyButton:SetScript("OnMouseDown",function()
        C_ChallengeMode.RemoveKeystone()
        ChallengesKeystoneFrame:Reset()
        ItemButtonUtil.CloseFilteredBags(ChallengesKeystoneFrame)
        ClearCursor()
    end)








--地下城挑战，分数，超链接
    KeyFrame.ScoreButton= CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')
    KeyFrame.ScoreButton:SetPoint('TOPRIGHT', KeyFrame.ClearKeyButton, 'BOTTOMRIGHT', 0, -4)
    KeyFrame.ScoreButton:SetSize(70, 24)
    KeyFrame.ScoreButton:SetScript('OnMouseDown', function(self, d)
        local link= WoWTools_ChallengeMixin:GetDungeonScoreLink()
        if d=='LeftButton' then
            WoWTools_ChatMixin:Chat(link, nil, nil)
        else
            WoWTools_ChatMixin:Chat(link, nil, true)
        end
    end)

    KeyFrame.ScoreButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        WoWTools_SetTooltipMixin:Frame(self, nil, {dungeonScore=true})
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine('|cnGREEN_FONT_COLOR:<'..(WoWTools_DataMixin.onlyChinese and '发送信息' or SEND_MESSAGE)..'>'..WoWTools_DataMixin.Icon.left..'|A:transmog-icon-chat:0:0|a')
        GameTooltip:AddLine('|cnGREEN_FONT_COLOR:<'..(WoWTools_DataMixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT)..'>'..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        WoWTools_ChatMixin:Chat(self.dungeonScore, nil, nil)
    end)

    function KeyFrame.ScoreButton:set_text()
        local score= C_ChallengeMode.GetOverallDungeonScore() or 0
        self:SetText(
            '|A:recipetoast-icon-star:0:0|a'
            ..(score>0 and WoWTools_ChallengeMixin:KeystoneScorsoColor(score) or 0)
        )
    end





--发送链接
    KeyFrame.KeyButton= CreateFrame("ItemButton", nil, KeyFrame)-- WoWTools_ButtonMixin:Cbtn(KeyFrame)
    KeyFrame.KeyButton:SetPoint('TOP', KeyFrame.ScoreButton, 'BOTTOM', 0, -4)
    KeyFrame.KeyButton:SetScript("OnMouseDown",function(self, d)
        if d=='LeftButton' then
            WoWTools_ChatMixin:Chat(self.item, nil, nil)
        else
            --WoWTools_ChatMixin:Chat(self.item, nil, true)
            MenuUtil.CreateContextMenu(self, function(...)
                WoWTools_ChallengeMixin:Say_Menu(...)
            end)
        end
    end)

    KeyFrame.KeyButton:SetScript("OnLeave", GameTooltip_Hide)
    KeyFrame.KeyButton:SetScript("OnEnter",function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            WoWTools_SetTooltipMixin:Frame(self)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(' ', '|cnGREEN_FONT_COLOR:<'..(WoWTools_DataMixin.onlyChinese and '发送信息' or SEND_MESSAGE)..'>'..WoWTools_DataMixin.Icon.left)
            GameTooltip:AddDoubleLine(' ', (WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.right)
          --  GameTooltip:AddLine('|cnGREEN_FONT_COLOR:<'..(WoWTools_DataMixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT)..'>'..WoWTools_DataMixin.Icon.right)
            GameTooltip:Show()
    end)
    KeyFrame.KeyButton.Text=WoWTools_LabelMixin:Create(KeyFrame.KeyButton, {size=14})
    KeyFrame.KeyButton.Text:SetPoint('RIGHT', KeyFrame.KeyButton, 'LEFT')
    function KeyFrame.KeyButton:set_text()
        local info, bagID, slotID= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})
        if info then
            self:SetItemLocation(ItemLocation:CreateFromBagAndSlot(bagID, slotID))
            self.Text:SetText(WoWTools_HyperLink:CN_Link(info.hyperlink, {itemID=info.itemID}) or '')
            self:SetItemButtonCount(C_MythicPlus.GetOwnedKeystoneLevel())
        end
        self:SetShown(info and true or false)
    end


















--就绪
    local ready = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--就绪
    ready:SetText((WoWTools_DataMixin.onlyChinese and '就绪' or READY)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
    ready:SetPoint('LEFT', ChallengesKeystoneFrame.StartButton, 'RIGHT',2, 0)
    ready:SetSize(100,24)
    ready:SetScript("OnMouseDown", DoReadyCheck)






--标记
    local mark = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--标记
    mark:SetText(WoWTools_DataMixin.Icon['TANK']..(WoWTools_DataMixin.onlyChinese and '标记' or EVENTTRACE_MARKER)..WoWTools_DataMixin.Icon['HEALER'])
    mark:SetPoint('RIGHT', ChallengesKeystoneFrame.StartButton, 'LEFT',-2, 0)
    mark:SetSize(100,24)
    mark:SetScript("OnMouseDown",function()
        local n=GetNumGroupMembers()
        for i=1,n  do
            local u='party'..i
            if i==n then u='player' end
            if CanBeRaidTarget(u) then
                local r=UnitGroupRolesAssigned(u)
                local index=GetRaidTargetIndex(u)
                if r=='TANK' then
                    if index~=2 then SetRaidTarget(u, 2) end
                elseif r=='HEALER' then
                    if index~=1 then SetRaidTarget(u, 1) end
                else
                    if index and index>0 then SetRaidTarget(u, 0) end
                end
            end
        end
    end)








--倒计时7秒
    local countdown = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--倒计时7秒
    countdown:SetText((WoWTools_DataMixin.onlyChinese and '倒计时' or PLAYER_COUNTDOWN_BUTTON)..' 7')
    countdown:SetPoint('TOP', ChallengesKeystoneFrame, 'BOTTOM',100, 5)
    countdown:SetSize(150,24)
    countdown:SetScript("OnMouseDown",function()
        C_PartyInfo.DoCountdown(7)
    end)









--停止， 倒计时
    local stop = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--倒计时7秒
    stop:SetText((WoWTools_DataMixin.onlyChinese and '取消' or CANCEL)..' 0')
    stop:SetPoint('TOP', ChallengesKeystoneFrame, 'BOTTOM',-100, 5)
    stop:SetSize(100,24)
    stop:SetScript("OnMouseDown",function()
        C_PartyInfo.DoCountdown(0)
        WoWTools_ChatMixin:Chat(WoWTools_DataMixin.Player.cn and '停止! 停止! 停止!' or 'Stop! Stop! Stop!', nil, nil)
    end)
    stop:SetScript('OnLeave', GameTooltip_Hide)
    stop:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText('|A:transmog-icon-chat:0:0|a'..(WoWTools_DataMixin.Player.cn and '停止! 停止! 停止!' or 'Stop! Stop! Stop!'))
        GameTooltip:Show()
    end)









--移动
    ChallengesKeystoneFrame.DungeonName:ClearAllPoints()
    ChallengesKeystoneFrame.DungeonName:SetPoint('BOTTOMLEFT', ChallengesKeystoneFrame, 'BOTTOMLEFT', 15, 110)
    ChallengesKeystoneFrame.DungeonName:SetJustifyH('LEFT')

    ChallengesKeystoneFrame.TimeLimit:ClearAllPoints()
    ChallengesKeystoneFrame.TimeLimit:SetPoint('BOTTOMRIGHT', ChallengesKeystoneFrame, 'BOTTOMRIGHT', -15, 120)
    ChallengesKeystoneFrame.TimeLimit:SetJustifyH('RIGHT')





    Create_Buttons= function()end
end






















local function Init_Menu(self, root)
    local sub
    sub=root:CreateCheckbox(
        'Plus',
    function()
        return not Save().hideKeyUI
    end, function()
        Save().hideKeyUI= not Save().hideKeyUI and true or nil
        WoWTools_ChallengeMixin:ChallengesKeystoneFrame()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().keystoneScale or 1
    end, function(value)
        Save().keystoneScale= value
        WoWTools_ChallengeMixin:ChallengesKeystoneFrame()
    end)

--说
    root:CreateDivider()
    root:CreateTitle(
        '|A:transmog-icon-chat:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '说' or SAY)
    )

--插入史诗钥石
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '插入史诗钥石' or  CHALLENGE_MODE_INSERT_KEYSTONE,
    function()
        return Save().slotKeystoneSay
    end, function()
        Save().slotKeystoneSay= not Save().slotKeystoneSay and true or nil
        WoWTools_ChallengeMixin:ChallengesKeystoneFrame()
    end)

--挑战开始
    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '挑战开始' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYER_DIFFICULTY5, START),
    function()
        return not Save().hideAffixSay
    end, function()
        Save().hideAffixSay= not Save().hideAffixSay and true or nil
    end)
    sub:SetTooltip(function(tootip)
        tootip:AddLine('CHALLENGE_MODE_START')
    end)

--挑战结束
    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '挑战结束' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYER_DIFFICULTY5, COMPLETE),
    function()
        return not Save().hideEndKeystoneSay
    end, function()
        Save().hideEndKeystoneSay= not Save().hideEndKeystoneSay and true or nil
        WoWTools_ChallengeMixin:Say_ChallengeComplete()
    end)
    sub:SetTooltip(function(tootip)
        tootip:AddLine('CHALLENGE_MODE_START')
        tootip:AddLine(' ')
        tootip:AddLine( WoWTools_DataMixin.onlyChinese and '按钮' or SHOW_QUICK_BUTTON )
    end)

    WoWTools_ChallengeMixin:Say_ChallengeComplete_Menu(self, sub)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ChallengeMixin.addName})
end









local function Init()
    local btn= WoWTools_ButtonMixin:Menu(ChallengesKeystoneFrame.CloseButton)
    btn:SetPoint('RIGHT', ChallengesKeystoneFrame.CloseButton, 'LEFT')

    btn:SetupMenu(Init_Menu)

    KeyFrame= CreateFrame('Frame', nil, ChallengesKeystoneFrame.CloseButton)
    KeyFrame:SetFrameLevel(ChallengesKeystoneFrame.CloseButton:GetFrameLevel()+1)
    KeyFrame:SetPoint('TOPLEFT')
    KeyFrame:SetSize(1,1)
    KeyFrame:Hide()


--队伍信息
    KeyFrame.PartyInfoText=WoWTools_LabelMixin:Create(KeyFrame, {size=16})
    KeyFrame.PartyInfoText:SetPoint('TOPLEFT', ChallengesKeystoneFrame, 'TOPRIGHT', 2, 0)


    Init_Buttons()


    KeyFrame:SetScript("OnUpdate", function (self, elapsed)--更新队伍数据
        self.elapsed= (self.elapsed or 0.8) + elapsed
        if self.elapsed > 0.8 then
            self.elapsed=0
            UI_Party_Info()
        end

        local has= C_ChallengeMode.HasSlottedKeystone()
        self.InsetKeyButton:SetEnabled(not has)
        self.ClearKeyButton:SetEnabled(has)
    end)




    KeyFrame:SetScript('OnHide', function(self)
        self.elapsed=nil
        self.KeyButton:Reset()
        self.KeyButton.Text:SetText('')

        self.ScoreButton.Text:SetText('')

        self.PartyInfoText:SetText('')
        self:UnregisterAllEvents()
    end)

    KeyFrame:SetScript('OnShow', function(self)
        self.ScoreButton:set_text()--地下城挑战，分数，超链接
        self.KeyButton:set_text()--发送链接
        self:RegisterEvent('BAG_UPDATE_DELAYED')
    end)

    KeyFrame:SetScript('OnEvent', function(self)
        self.KeyButton:set_text()--发送链接
    end)

    function KeyFrame:settings()

        self.ChatTooltipTexture:SetShown(Save().slotKeystoneSay)
        self:SetShown(not Save().hideKeyUI)
        self:SetScale(Save().keystoneScale or 1)
    end

--插入, KEY时, 说
    hooksecurefunc(ChallengesKeystoneFrame, 'OnKeystoneSlotted', Set_SlotKeystoneSay)--插入, KEY时, 说


    KeyFrame:settings()

    Init=function()
        KeyFrame:settings()
    end
end



function WoWTools_ChallengeMixin:ChallengesKeystoneFrame()
    Init()
end

function WoWTools_ChallengeMixin:ChallengesKeystoneFrame_Menu(_, root)
    if KeyFrame then
        Init_Menu(KeyFrame, root)
    end
end