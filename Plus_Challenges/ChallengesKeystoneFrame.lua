--挑战,钥石,插入界面
local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end

local KeyFrame









local function Create_Key(btn, point, x, y, parent, i, find)
    if btn['key'..i] then
        return
    end

    btn['key'..i]= WoWTools_ButtonMixin:Cbtn(parent or btn, {size=16, icon='hide'})

    if i==1 then
        btn['key'..i]:SetPoint(point, btn, x, y)
    else
        if find then
            btn['key'..i]:SetPoint(point, btn['key'..(i-1)], 'TOPLEFT', 0, 0)
        else
            btn['key'..i]:SetPoint(point, btn['key'..(i-1)], 'TOPRIGHT', 0, 0)
        end
    end

    btn['key'..i]:SetScript("OnMouseDown",function(self, d2)--发送链接
            if d2=='LeftButton' then
                WoWTools_ChatMixin:Chat(self.item, nil, nil)
            else
                WoWTools_ChatMixin:Chat(self.item, nil, true)
            end
    end)

    btn['key'..i]:SetScript("OnEnter",function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:SetHyperlink(self.item)
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '发送信息' or SEND_MESSAGE, WoWTools_DataMixin.Icon.left)
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, WoWTools_DataMixin.Icon.right)
            GameTooltip:Show()
    end)
    btn['key'..i]:SetScript("OnLeave",function()
            GameTooltip:Hide()
    end)

    btn['key'..i].bag=WoWTools_LabelMixin:Create(btn['key'..i])

    if point:find('LEFT') then
        btn['key'..i].bag:SetPoint('LEFT', btn['key'..i], 'RIGHT', 0, 0)
    else
        btn['key'..i].bag:SetPoint('RIGHT', btn['key'..i], 'LEFT', 0, 0)
    end
end









local function getBagKey(frame, point, x, y, parent) --KEY链接
    local find=point:find('LEFT')
    local i=1
    for bagID= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do
        for slotID=1, C_Container.GetContainerNumSlots(bagID) do
            local icon, itemLink, itemID
            local info= C_Container.GetContainerItemInfo(bagID, slotID)
            if info then
                icon=info.iconFileID
                itemLink=info.hyperlink
                itemID= info.itemID
            end
            if itemID and itemLink and C_Item.IsItemKeystoneByID(itemID) then

                Create_Key(frame, point, x, y, parent, i, find)

                frame['key'..i].item=itemLink
                frame['key'..i].bag:SetText(itemLink)
                frame['key'..i]:SetNormalTexture(icon)
                if frame['key'..i] and frame==ChallengesFrame then
                    frame['key'..i]:SetShown(not Save().hideTips)
                end

                i=i+1
            end
        end
    end
end























--##################
--挑战,钥石,插入,界面
--##################
local function UI_Party_Info(self)--队友位置
    if Save().hideKeyUI then
        return
    end
    local UnitTab={}
    local name, uiMapID=WoWTools_MapMixin:GetUnit('player')
    local text
    local all= GetNumGroupMembers()
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
    if not self.partyLable then
        self.partyLable=WoWTools_LabelMixin:Create(KeyFrame)--队伍信息
        --self.party:SetPoint('BOTTOMLEFT', _G['MoveZoomInButtonPerChallengesKeystoneFrame'] or self, 'TOPLEFT')
        self.partyLable:SetPoint('TOPLEFT', self, 'TOPRIGHT')
    end
    self.partyLable:SetText(text or '')
    WoWTools_UnitMixin:GetNotifyInspect(UnitTab)--取得装等
end


























local function Create_Buttons()--挑战,钥石,插入界面
    if not Save().hideKeyUI then
        return
    end


    KeyFrame= CreateFrame('Frame', nil, ChallengesKeystoneFrame)
    KeyFrame:SetPoint('TOPLEFT')
    KeyFrame:SetSize(1,1)
    KeyFrame:SetFrameStrata('HIGH')
    KeyFrame:SetFrameLevel(7)

    local ready = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--就绪
    ready:SetText((WoWTools_DataMixin.onlyChinese and '就绪' or READY)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
    ready:SetPoint('LEFT', ChallengesKeystoneFrame.StartButton, 'RIGHT',2, 0)
    ready:SetSize(100,24)
    ready:SetScript("OnMouseDown", DoReadyCheck)

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

    local clear = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--清除KEY
    clear:SetPoint('RIGHT', ChallengesKeystoneFrame, -15, -50)
    clear:SetSize(70,24)
    clear:SetText(WoWTools_DataMixin.onlyChinese and '清除' or  SLASH_STOPWATCH_PARAM_STOP2)
    clear:SetScript("OnMouseDown",function()
        C_ChallengeMode.RemoveKeystone()
        ChallengesKeystoneFrame:Reset()
        ItemButtonUtil.CloseFilteredBags(ChallengesKeystoneFrame)
        ClearCursor()
    end)

    local ins = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--插入
    ins:SetPoint('BOTTOMRIGHT', clear, 'TOPRIGHT', 0, 2)
    ins:SetSize(70,24)
    ins:SetText(WoWTools_DataMixin.onlyChinese and '插入' or  COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN)
    ins:SetScript("OnMouseDown",function()
            if UnitAffectingCombat('player') then
                print(WoWTools_DataMixin.Icon.icon2.. WoWTools_ChallengeMixin.addName,'|cnRED_FONT_COLOR:', WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
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
            print(WoWTools_DataMixin.addName, CHALLENGE_MODE_KEYSTONE_NAME:format('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..'|r'))
    end)














    ChallengesKeystoneFrame:HookScript('OnShow', function(self)
        if Save().hideKeyUI then
            return
        end

        getBagKey(self, 'BOTTOMRIGHT', -15, 170, KeyFrame)--KEY链接

        UI_Party_Info(self)

        self.inseSayTips=true--插入, KEY时, 说

        --地下城挑战，分数，超链接
        local dungeonScore = C_ChallengeMode.GetOverallDungeonScore()--DungeonScoreInfoMixin:OnClick() Blizzard_ChallengesUI.lua
        if dungeonScore and dungeonScore>0 then
            local link = GetDungeonScoreLink(dungeonScore, UnitName("player"))
            if not self.dungeonScoreLink then
                self.dungeonScoreLink= WoWTools_LabelMixin:Create(KeyFrame, {mouse=true, size=16})
                self.dungeonScoreLink:SetPoint('BOTTOMRIGHT', ChallengesKeystoneFrame, -15, 145)
                self.dungeonScoreLink:SetScript('OnMouseDown', function(self3, d)
                    if not self3.link then
                        return
                    end
                    if d=='LeftButton' then
                       WoWTools_ChatMixin:Chat(self3.link, nil, nil)
                    elseif d=='RightButton' then
                        WoWTools_ChatMixin:Chat(self3.link, nil, true)
                        --if not ChatEdit_InsertLink(self3.link) then
                        --ChatFrame_OpenChat(self3.link)
                    end
                    self3:SetAlpha(0.5)
                end)
                self.dungeonScoreLink:SetScript('OnEnter', function(self3)
                    self3:SetAlpha(0.7)
                    GameTooltip:SetOwner(self3, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddLine(self3.link)
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '发送信息' or SEND_MESSAGE, WoWTools_DataMixin.Icon.left)
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, WoWTools_DataMixin.Icon.right)
                    GameTooltip:Show()
                end)
                self.dungeonScoreLink:SetScript('OnLeave', function(self3)
                    self3:SetAlpha(1)
                    GameTooltip:Hide()
                end)
                self.dungeonScoreLink:SetScript('OnMouseUp', function(self3)
                    self3:SetAlpha(0.7)
                end)
            end
            self.dungeonScoreLink.link= link
            self.dungeonScoreLink:SetText(WoWTools_ChallengeMixin:KeystoneScorsoColor(dungeonScore))
        end
    end)

    if ChallengesKeystoneFrame.DungeonName then
        ChallengesKeystoneFrame.DungeonName:ClearAllPoints()
        ChallengesKeystoneFrame.DungeonName:SetPoint('BOTTOMLEFT', ChallengesKeystoneFrame, 'BOTTOMLEFT', 15, 110)
        ChallengesKeystoneFrame.DungeonName:SetJustifyH('LEFT')
    end
    if ChallengesKeystoneFrame.TimeLimit then
        ChallengesKeystoneFrame.TimeLimit:ClearAllPoints()
        ChallengesKeystoneFrame.TimeLimit:SetPoint('BOTTOMRIGHT', ChallengesKeystoneFrame, 'BOTTOMRIGHT', -15, 120)
        ChallengesKeystoneFrame.TimeLimit:SetJustifyH('RIGHT')
    end




--插入, KEY时, 说
    local check= CreateFrame("CheckButton", nil, KeyFrame, "InterfaceOptionsCheckButtonTemplate")--插入, KEY时, 说
    check:SetPoint('RIGHT', ins, 'LEFT')
    check:SetChecked(Save().slotKeystoneSay)
    check:SetScript('OnMouseDown', function()
        Save().slotKeystoneSay= not Save().slotKeystoneSay and true or nil
    end)
    check:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine('|A:transmog-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '说' or SAY))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(1, WoWTools_DataMixin.onlyChinese and '插入' or  COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN)
        GameTooltip:AddDoubleLine(2, WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE)
        GameTooltip:Show()
        self:SetAlpha(1)
    end)
    check:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(0.5) end)

    hooksecurefunc(ChallengesKeystoneFrame, 'OnKeystoneSlotted',function(self)--插入, KEY时, 说

        if not Save().slotKeystoneSay or not C_ChallengeMode.HasSlottedKeystone() or not self.inseSayTips then
            return
        end

        local mapChallengeModeID, affixes, powerLevel = C_ChallengeMode.GetSlottedKeystoneInfo()
        if not mapChallengeModeID then
            return
        end

        local name,_, timeLimit= C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)

        if not name then
            return
        end

        local journalInstanceID= WoWTools_DataMixin.ChallengesSpellTabs[mapChallengeModeID] and WoWTools_DataMixin.ChallengesSpellTabs[mapChallengeModeID].ins
        if journalInstanceID then
            name = select(8, EJ_GetInstanceInfo(journalInstanceID)) or name
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
        self.inseSayTips=nil
    end)

    ChallengesKeystoneFrame:HookScript("OnUpdate", function (self, elapsed)--更新队伍数据
        self.elapsed= (self.elapsed or 0.8) + elapsed
        if self.elapsed > 0.8 then
            self.elapsed=0
            UI_Party_Info(self)
        end
        local inse= C_ChallengeMode.HasSlottedKeystone()
        self.ins:SetEnabled(not inse)
        self.clear:SetEnabled(inse)
    end)


    local countdown = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--倒计时7秒
    countdown:SetText((WoWTools_DataMixin.onlyChinese and '倒计时' or PLAYER_COUNTDOWN_BUTTON)..' 7')
    countdown:SetPoint('TOP', ChallengesKeystoneFrame, 'BOTTOM',100, 5)
    countdown:SetSize(150,24)
    countdown:SetScript("OnMouseDown",function()
        C_PartyInfo.DoCountdown(7)
    end)

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
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_ChallengeMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(' ', '|A:transmog-icon-chat:0:0|a'..(WoWTools_DataMixin.Player.cn and '停止! 停止! 停止!' or 'Stop! Stop! Stop!'))
        GameTooltip:Show()
    end)


    Create_Buttons= function()
        KeyFrame:SetShown(not Save().hideKeyUI)
    end
end























local function Init()

    local btn= WoWTools_ButtonMixin:Cbtn(ChallengesKeystoneFrame, {size={18,18}, icon='hide'})
    btn:SetFrameStrata('HIGH')
    btn:SetFrameLevel(7)
    btn:SetAlpha(0.5)
    btn:SetPoint('RIGHT', ChallengesKeystoneFrame.CloseButton, 'LEFT')

    function btn:set_texture()
        self:SetNormalAtlas(not Save().hideKeyUI and WoWTools_DataMixin.Icon.icon or 'talents-button-reset')
    end

    btn:SetScript("OnClick", function(self)
        Save().hideKeyUI = not Save().hideKeyUI and true or nil
        Create_Buttons()
        self:set_texture()
    end)
    btn:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '显示/隐藏' or SHOW..'/'..HIDE, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_ChallengeMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(1)
    end)
    btn:SetScript("OnLeave",function(self)
        GameTooltip:Hide()
        self:SetAlpha(0.5)
    end)

    btn:set_texture()

    if not Save().hideKeyUI then
        Create_Buttons()
    end
end



function WoWTools_ChallengeMixin:ChallengesKeystoneFrame()
    Init()
end