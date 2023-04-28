local id, e = ...
if not e.Player.levelMax then
    return
end
local addName= CHALLENGES
local Save= {}
local panel=CreateFrame("Frame")

local affixSchedule = {-- AngryKeystones Schedule Dragonflight Season 1,史诗钥石地下城, 界面
	[1]  = { [1]=6,   [2]=14,  [3]=10, }, -- Fortified | Raging | Quaking
	[2]  = { [1]=11,  [2]=12,  [3]=9,  }, -- Tyrannical | Bursting | Grievous
	[3]  = { [1]=8,   [2]=3,   [3]=10, }, -- Fortified | Sanguine | Volcanic
	[4]  = { [1]=6,   [2]=124, [3]=9,  }, -- Tyrannical | Raging | Storming
	[5]  = { [1]=123, [2]=12,  [3]=10, }, -- Fortified | Spiteful | Grievous
	[6]  = { [1]=8,   [2]=13,  [3]=9,  }, -- Tyrannical | Sanguine | Explosive
	[7]  = { [1]=7,   [2]=124, [3]=10, }, -- Fortified | Bolstering | Storming
	[8]  = { [1]=123, [2]=14,  [3]=9,  }, -- Tyrannical | Spiteful | Quaking
	[9]  = { [1]=11,  [2]=13,  [3]=10, }, -- Fortified | Bursting | Explosive
	[10] = { [1]=7,   [2]=3,   [3]=9,  }, -- Tyrannical | Bolstering | Volcanica
}
local EncounterJournal_Maps={--[mapChallengeModelID]= journalInstanceID
    [2]= 313,--青龙寺
    [400]= 1198,--诺库德阻击战
    [200]= 721,--[英灵殿]
    [402]= 1201,--[艾杰斯亚学院]
    [210]= 800,--[群星庭院]
    [399]= 1202,--[红玉新生法池]
    [401]= 1203;--[碧蓝魔馆]
    [165]= 537,--[影月墓地]
}
    --[[[166]= 536,--暗轨之路(车站)
    [391]= 1194,--街头商贩之路(天街)
    [392]= 1194,--街头商贩之路(天街)
    [370]= 1178,--机械王子之路(麦卡贡)
    [369]= 1178,--机械王子之路(麦卡贡)
    [169]= 558,--铁船之路(码头)
    [227]= 860,--堕落守护者之路(卡拉赞)
    [234]= 860,--堕落守护者之路(卡拉赞)]]

    --[]= 68,--旋云之巅
    --[]= 1197,--奥达曼：提尔的遗产
    --[]= 1199,--奈萨鲁斯
    --[]= 1196,--蕨皮山谷

    --[]=1204,--注能大厅
    --[]=1022,--地渊孢林
    --[]=1001,--自由镇
    --[]=767,--奈萨里奥的巢穴

--[[
local spellIDs={--法术, 传送门, {mapChallengeModeID = 法术 SPELL ID}, BUG, 战斗中关闭, 会出现错误
    [166]=159900,--暗轨之路(车站)
    [391]=367416,--街头商贩之路(天街)
    [370]=373274,--机械王子之路(麦卡贡)
    [169]=159896,--铁船之路(码头)
    [227]=373262,--堕落守护者之路(卡拉赞)
}
]]


local function getBagKey(self, point, x, y) --KEY链接
    local find=point:find('LEFT')
    local i=1
    for bagID=0, NUM_BAG_SLOTS do
        for slotID=1,C_Container.GetContainerNumSlots(bagID) do
            local icon, itemLink, itemID
            local info= C_Container.GetContainerItemInfo(bagID, slotID)
            if info then
                icon=info.iconFileID
                itemLink=info.hyperlink
                itemID= info.itemID
            end
            if itemID and itemLink and C_Item.IsItemKeystoneByID(itemID) then
                if not self['key'..i] then
                    self['key'..i] = CreateFrame("Button", nil, self)
                    self['key'..i]:SetHighlightAtlas('Forge-ColorSwatchSelection')
                    self['key'..i]:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress')
                    self['key'..i]:SetSize(16, 16)
                    self['key'..i]:SetNormalTexture(icon)
                    self['key'..i].item=itemLink
                    if i==1 then
                        self['key'..i]:SetPoint(point,x, y)
                    else
                        if find then
                            self['key'..i]:SetPoint(point, self['key'..(i-1)], 'TOPLEFT', 0, 0)
                        else
                            self['key'..i]:SetPoint(point, self['key'..(i-1)], 'TOPRIGHT', 0, 0)
                        end
                    end
                    self['key'..i]:SetScript("OnMouseDown",function(self2, d2)--发送链接
                            if d2=='LeftButton' then
                                e.Chat(self2.item)
                            else
                                if not ChatEdit_InsertLink(self2.item) then
                                    ChatFrame_OpenChat(self2.item)
                                end
                            end
                    end)
                    self['key'..i]:SetScript("OnEnter",function(self2)
                            e.tips:SetOwner(self2, "ANCHOR_LEFT")
                            e.tips:ClearLines()
                            e.tips:SetHyperlink(self2.item)
                            e.tips:AddDoubleLine(e.onlyChinese and '发送信息' or SEND_MESSAGE, e.Icon.left)
                            e.tips:AddDoubleLine(e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, e.Icon.right)
                            e.tips:Show()
                    end)
                    self['key'..i]:SetScript("OnLeave",function()
                            e.tips:Hide()
                    end)
                    self['key'..i].bag=e.Cstr(self)
                    if point:find('LEFT') then
                        self['key'..i].bag:SetPoint('LEFT', self['key'..i], 'RIGHT', 0, 0)
                    else
                        self['key'..i].bag:SetPoint('RIGHT', self['key'..i], 'LEFT', 0, 0)
                    end
                    self['key'..i].bag:SetText(itemLink)
                end
                if self['key'..i] and self==ChallengesFrame then
                    self['key'..i]:SetShown(not Save.hide)
                end
                i=i+1
            end
        end
    end
end

--##################
--挑战,钥石,插入,界面
--##################
local function UI_Party_Info(frame)--队友位置
    if IsInRaid() or not IsInGroup(LE_PARTY_CATEGORY_HOME) then
        frame.party:SetText('')
        return
    end

    local UnitTab={}
    local name, uiMapID=e.GetUnitMapName('player')
    local text
    for i=1, GetNumGroupMembers() do
        local unit='party'..i
        if i==GetNumGroupMembers() then
            unit='player'
        end
        local guid=UnitGUID(unit)
        if guid then
            text= text and text..'\n' or ''

            local stat=GetReadyCheckStatus(unit)
            if stat=='ready' then
                text= text..e.Icon.select2
            elseif stat=='waiting' then
                text= text..'  '
            elseif stat=='notready' then
                text= text ..e.Icon.O2
            end

            local tab= e.UnitItemLevel[guid]--装等
            if tab then
                if tab.itemLevel then
                    text= text..'|A:charactercreate-icon-customize-body-selected:0:0|a'..tab.itemLevel
                else
                    table.insert(UnitTab, unit)
                end
            end

            local info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)--挑战, 分数
            if info and info.currentSeasonScore and info.currentSeasonScore>0 then
                text= text..e.GetKeystoneScorsoColor(info.currentSeasonScore, true)
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

            text= text..e.GetPlayerInfo({unit=nil, guid=guid, name=name,  reName=true, reRealm=true, reLink=false})--信息

            local name2, uiMapID2=e.GetUnitMapName(unit)
            if (name and name==name2) or (uiMapID and uiMapID==uiMapID2) then--地图名字
                text=text..e.Icon.select2
            elseif name2 then
                text=text ..e.Icon.map2..name2
            else
                text= text.. e.Icon.info2
            end

            local reason=UnitPhaseReason(unit)--位面
            if reason then
                if reason==0 then--不同了阶段
                    text= text ..'|cnRED_FONT_COLOR:'..ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', e.onlyChinese and '阶段' or MAP_BAR_THUNDER_ISLE_TITLE0:gsub('1',''))..'|r'
                elseif reason==1 then--不在同位面
                    text= text ..'|cnRED_FONT_COLOR:'..ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', e.Player.LayerText)..'|r'
                elseif reason==2 then--战争模式
                    text= text ..(C_PvP.IsWarModeDesired() and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '开启战争模式' or ERR_PVP_WARMODE_TOGGLE_ON)..'|r')
                elseif reason==3 then
                    text= text..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)..'|r'
                end
            end


        end
    end
    frame.party:SetText(text or '')
    e.GetNotifyInspect(UnitTab)--取得装等
end

local function set_Key_Blizzard_ChallengesUI()--挑战,钥石,插入界面
    local frame=ChallengesKeystoneFrame
    frame.ready = CreateFrame("Button",nil, frame, 'UIPanelButtonTemplate')--就绪
    frame.ready:SetText((e.onlyChinese and '就绪' or READY)..e.Icon.select2)
    frame.ready:SetPoint('LEFT', frame.StartButton, 'RIGHT',2, 0)
    frame.ready:SetSize(100,24)
    frame.ready:SetScript("OnMouseDown",function()
            DoReadyCheck()
    end)

    frame.mark = CreateFrame("Button",nil, frame, 'UIPanelButtonTemplate')--标记
    frame.mark:SetText(e.Icon['TANK']..(e.onlyChinese and '标记' or EVENTTRACE_MARKER)..e.Icon['HEALER'])
    frame.mark:SetPoint('RIGHT', frame.StartButton, 'LEFT',-2, 0)
    frame.mark:SetSize(100,24)
    frame.mark:SetScript("OnMouseDown",function()
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

    frame.clear = CreateFrame("Button",nil, frame, 'UIPanelButtonTemplate')--清除KEY
    frame.clear:SetPoint('RIGHT', -15, -50)
    frame.clear:SetSize(70,24)
    frame.clear:SetText(e.onlyChinese and '清除' or  SLASH_STOPWATCH_PARAM_STOP2)
    frame.clear:SetScript("OnMouseDown",function()
            C_ChallengeMode.RemoveKeystone()
            frame:Reset()
            ItemButtonUtil.CloseFilteredBags(frame)
            ClearCursor()
    end)

    frame.ins = CreateFrame("Button",nil, frame, 'UIPanelButtonTemplate')--插入
    frame.ins:SetPoint('BOTTOMRIGHT', frame.clear, 'TOPRIGHT', 0, 2)
    frame.ins:SetSize(70,24)
    frame.ins:SetText(e.onlyChinese and '插入' or  COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN)
    frame.ins:SetScript("OnMouseDown",function()
            ItemButtonUtil.OpenAndFilterBags(frame)
            if ItemButtonUtil.GetItemContext() == nil then return end
            for bagID=0, NUM_BAG_FRAMES do--ContainerFrame.lua
                local itemLocation = ItemLocation:CreateEmpty()
                for slotIndex = 1, ContainerFrame_GetContainerNumSlots(bagID) do
                    itemLocation:SetBagAndSlot(bagID, slotIndex)
                    if ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation) == ItemButtonUtil.ItemContextMatchResult.Match then
                        C_Container.UseContainerItem(bagID, slotIndex)
                        return
                    end
                end
            end
            print(id, CHALLENGE_MODE_KEYSTONE_NAME:format('|cnRED_FONT_COLOR:'..(e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..'|r'))
    end)

    frame.party=e.Cstr(frame)--队伍信息
    frame.party:SetPoint('LEFT', 15, -50)

    frame:HookScript('OnShow', function()
            getBagKey(frame, 'BOTTOMRIGHT', -15, 170)--KEY链接
            UI_Party_Info(frame)
    end)

    if frame.DungeonName then
        frame.DungeonName:ClearAllPoints()
        frame.DungeonName:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 15, 110)
        frame.DungeonName:SetJustifyH('LEFT')
    end
    if frame.TimeLimit then
        frame.TimeLimit:ClearAllPoints()
        frame.TimeLimit:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -15, 120)
        frame.TimeLimit:SetJustifyH('RIGHT')
    end

    local sel2=CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")--插入, KEY时, 说
    if not frame.DungeonName and not e.onlyChinese then
        e.Cstr(nil,nil,frame.DungeonName, sel2.text)
    end
    sel2.text:SetText(e.onlyChinese and '说' or SAY)
    sel2:SetPoint('TOPLEFT',22,-12)
    sel2:SetChecked(Save.slotKeystoneSay)
    sel2:SetScript('OnMouseDown', function()
        Save.slotKeystoneSay= not Save.slotKeystoneSay and true or nil
    end)
    sel2:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '插入' or  COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN)
        e.tips:Show()
    end)
    sel2:SetScript('OnLeave', function() e.tips:Hide() end)
    hooksecurefunc(frame,'OnKeystoneSlotted',function()--插入, KEY时, 说
        if not Save.slotKeystoneSay then
            return
        end
        local mapID, affixes, powerLevel = C_ChallengeMode.GetSlottedKeystoneInfo()
        local name,_, timeLimit= C_ChallengeMode.GetMapUIInfo(mapID)
        local m=name..'('.. powerLevel..'): '
        for _,v in pairs(affixes) do
            local name2=C_ChallengeMode.GetAffixInfo(v)
            if name2 then
                m=m..name2..', '
            end
        end
        m=m..SecondsToClock(timeLimit)
        e.Chat(m)
    end)

    local timeElapsed = 0
    frame:HookScript("OnUpdate", function (self, elapsed)--更新队伍数据
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 0.8 then
            UI_Party_Info(frame)
            timeElapsed=0
        end
    end)


    frame.countdown = CreateFrame("Button",nil, frame, 'UIPanelButtonTemplate')--倒计时7秒
    frame.countdown:SetText((e.onlyChinese and '倒计时' or PLAYER_COUNTDOWN_BUTTON)..' 7')
    frame.countdown:SetPoint('TOP', frame, 'BOTTOM',100, 5)
    frame.countdown:SetSize(150,24)
    frame.countdown:SetScript("OnMouseDown",function()
        C_PartyInfo.DoCountdown(7)
    end)
    frame.countdown2 = CreateFrame("Button",nil, frame, 'UIPanelButtonTemplate')--倒计时7秒
    frame.countdown2:SetText((e.onlyChinese and '取消' or CANCEL)..' 0')
    frame.countdown2:SetPoint('TOP', frame, 'BOTTOM',-100, 5)
    frame.countdown2:SetSize(100,24)
    frame.countdown2:SetScript("OnMouseDown",function()
        C_PartyInfo.DoCountdown(0)
        e.Chat(CANCEL)
    end)
end

local function set_CHALLENGE_MODE_START()--赏金, 说 Bounty
    local tab = select(2, C_ChallengeMode.GetActiveKeystoneInfo()) or {}
    for _, info  in pairs(tab) do
        local activeAffixID=select(3, C_ChallengeMode.GetAffixInfo(info))
        if activeAffixID==136177 then
            C_Timer.After(6, function()
                local chat={}

                local n=GetNumGroupMembers()
                local IDs2={373113, 373108, 373116, 373121}
                for i=1, n do
                    local u= i==n and 'player' or 'party'..i
                    local name2=i==n and COMBATLOG_FILTER_STRING_M or UnitName(u)
                    if UnitExists(u) and name2 then
                        local buff
                        for _, v in pairs(IDs2) do
                            local name=e.WA_GetUnitBuff(u, v)
                            if  name then
                                local link=GetSpellLink(v)
                                if link or name then
                                    buff=i..')'..name2..': '..(link or name)
                                    break
                                end
                            end
                        end
                        buff=buff or (i..')'..name2..': '..NONE)
                        table.insert(chat, buff)
                    end
                end

                for _, v in pairs(chat) do
                    if not Save.slotKeystoneSay then
                        print(v)
                    else
                        e.Chat(v)
                    end
                end
            end)
            break
        end
    end
end


--##################
--史诗钥石地下城, 界面
--##################
local function makeAffix(parent, id2)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(20, 20)

    local border = frame:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints()
    border:SetAtlas("ChallengeMode-AffixRing-Sm")
    frame.Border = border

    local portrait = frame:CreateTexture(nil, "ARTWORK")
    portrait:SetSize(18, 18)
    portrait:SetPoint("CENTER", border)
    frame.Portrait = portrait

    frame.SetUp = ScenarioChallengeModeAffixMixin.SetUp
    frame:SetScript("OnEnter", ScenarioChallengeModeAffixMixin.OnEnter)
    frame:SetScript("OnLeave", e.tips_Hide)
    frame:SetUp(id2)--Blizzard_ScenarioObjectiveTracker.lua
    return frame
end
local currentWeek--词缀日程表AngryKeystones Schedule.lua
local function Affix()
    if IsAddOnLoaded("AngryKeystones") then
        return
    end

    local currentAffixes = C_MythicPlus.GetCurrentAffixes()
    if currentAffixes then
        for index, affixes in ipairs(affixSchedule) do
            local matches = 0
            for _, affix in ipairs(currentAffixes) do
                if affix.id == affixes[1] or affix.id == affixes[2] or affix.id == affixes[3] then
                    matches = matches + 1
                end
            end
            if matches >= 3 then
                currentWeek = index
            end
        end
    end
    if currentWeek then
        local one= currentWeek ==12 and  1 or currentWeek
        local due=one+1 due=due==12 and 1 or due
        local tre=due+1 tre=tre==12 and 1 or tre
        local affixs={affixSchedule[one], affixSchedule[due], affixSchedule[tre]}
        local last
        for k,v in pairs(affixs) do
            for i=3 ,1, -1 do
                if not ChallengesFrame['AffixOne'..k..i] then
                    ChallengesFrame['AffixOne'..k..i]= makeAffix(ChallengesFrame, v[i])
                    if not last then
                        ChallengesFrame['AffixOne'..k..i]:SetPoint('RIGHT', -10, -((k-1)*(22)))
                    else
                        ChallengesFrame['AffixOne'..k..i]:SetPoint('RIGHT', last, 'LEFT', 0, 0)
                    end
                    if i==1 then
                        last=nil
                    else
                        last=ChallengesFrame['AffixOne'..k..i]
                    end
                end
                ChallengesFrame['AffixOne'..k..i]:SetShown(not Save.hide)
            end
        end
    end
end


local function GetNum(mapID, all)--取得完成次数,如 1/10
    local nu, to=0,0
    local info
    if all then
        info=C_MythicPlus.GetRunHistory(true, true) or {}--全部
    else
        info=C_MythicPlus.GetRunHistory(false, true) or {}--本周
    end
    for _,v in pairs(info) do
        if v.mapChallengeModeID==mapID then
            if v.completed then
                nu=nu+1
            end
            to=to+1
        end
    end
    if to>0 then
        return '|cff00ff00'..nu..'|r/'..to
    end
end


--[[local function set_Spell_Port(self)--传送门
    local spellID=spellIDs[self.mapID]
    if spellID then
        if not self.spell then
            self.spell=CreateFrame("Button", nil, self, 'SecureActionButtonTemplate')
            self.spell:SetHighlightAtlas('Forge-ColorSwatchSelection')
            self.spell:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress')
            self.spell:RegisterForClicks("LeftButtonDown")
            self.spell:SetAttribute("type*", "spell")
            self.spell:SetAttribute( "spell*", spellID)
            self.spell:SetPoint('RIGHT',0, 0)
            self.spell:SetSize(h+8, h+8)
            if IsSpellKnown(spellID) then--加个外框
                self.spell.tex=self.spell:CreateTexture(nil, 'OVERLAY')
                self.spell.tex:SetAllPoints(self.spell)
                self.spell.tex:SetAtlas(e.Icon.tex)
                self.spell.tex:SetAlpha(0.4)
            end
            self.spell:SetScript("OnEnter",function(self2)
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:SetSpellByID(spellID)
                    if not IsSpellKnown(spellID) then--没学会
                        e.tips:AddDoubleLine(SPELL_FAILED_NOT_KNOWN, e.Icon.X, 1,0,0)
                    else
                        local startTime, duration= GetSpellCooldown(spellID)
                        if startTime and duration and duration>0 then
                            local t=GetTime()
                            if startTime>t then t=t+86400 end
                            t=t-startTime
                            t=duration-t
                            e.tips:AddDoubleLine('CD', SecondsToTime(t), 1,0,0, 1,0,0)
                        end
                    end
                    e.tips:Show()
            end)
            self.spell:SetScript("OnLeave",function() e.tips:Hide() end)
        end
        self.spell:SetNormalTexture(IsSpellKnown(spellID) and GetSpellTexture(spellID) or e.Icon.O)
    end
end]]

local function Kill(self)--副本PVP团本
    if Save.hide then
        if self.re then
            self.re:SetText('')
        end
        return
    end
    local R = {}
    local GetRewardText=function(type,level)
        if type == Enum.WeeklyRewardChestThresholdType.Raid then
            return  DifficultyUtil.GetDifficultyName(level)
        elseif type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
            return string.format(WEEKLY_REWARDS_MYTHIC, level)
        elseif type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
            return PVPUtil.GetTierName(level)
        elseif type== Enum.WeeklyRewardChestThresholdType.AlsoReceive then
            return 'AlsoReceive'
        elseif type== Enum.WeeklyRewardChestThresholdType.Concession then
            return 'Concession'
        end
    end
    local activityInfo =  C_WeeklyRewards.GetActivities()

    for  _ ,v in pairs(activityInfo) do
        if not R[v.type] then R[v.type] = {} end
        local  text = GetRewardText(v.type,v.level) or NONE
        R[v.type][v.index] = {
            level = v.level,
            difficulty = text,
            progress = v.progress,
            threshold = v.threshold,
            unlocked = v.progress>=v.threshold,
        }
    end

    local GetRewardTypeHead=function(type)
        if type == Enum.WeeklyRewardChestThresholdType.Raid then
            return  RAIDS
        elseif type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
            return MYTHIC_DUNGEONS
        elseif type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
            return PVP
        end
    end

    local T=''
    for i,v in pairs(R) do

        T=T..'\n'..'|T450908:0|t'
        local he=GetRewardTypeHead(i)
        if he then T=T..he end

        for x,r in pairs(v) do
            if T~='' then T=T..'\n' end
            T=T..'   '
            if r.unlocked then
                T=T.. '|cff00ff00'..x..')'..r.difficulty.. ' '..COMPLETE..'|r'
            else
                T=T..x..')'..r.difficulty.. ' '..r.progress.."/"..r.threshold
            end
        end
    end
    if T~='' then
        if not self.re then
            self.re=e.Cstr(self)
            self.re:SetPoint('TOPLEFT', self, 'TOPLEFT', 10, -45)
            self.re:SetJustifyH('LEFT')
        end
    end
    if self.re then
        self.re:SetText(T)
    end
end

local function HistorySort(a,b)
    if a.mapChallengeModeID == b.mapChallengeModeID then
        return a.level > b.level
    else
        return a.mapChallengeModeID< b.mapChallengeModeID
    end
end
local function All(self)--所有记录   
    if Save.hide then-- or Save.hideAll then 
        if self.WoWKeystones then self.WoWKeystones:SetText('') end
        return
    end
    local m=""

    local currentWeekBestLevel, weeklyRewardLevel, nextDifficultyWeeklyRewardLevel, nextBestLevel = C_MythicPlus.GetWeeklyChestRewardLevel()
    if currentWeekBestLevel and weeklyRewardLevel and weeklyRewardLevel>0 and currentWeekBestLevel>0 then
        m=m..format(e.onlyChinese and '%d级的当前奖励是%d。%d级的奖励是%d。' or MYTHIC_PLUS_CURR_WEEK_REWARD, currentWeekBestLevel,weeklyRewardLevel, nextDifficultyWeeklyRewardLevel, nextBestLevel)
    end
    --[[m=m..(e.onlyChinese and '每周最佳纪录: ' or CHALLENGE_MODE_WEEKLY_BEST..': ')..currentWeekBestLevel.. ' ('..weeklyRewardLevel..')'
    if nextDifficultyWeeklyRewardLevel and nextBestLevel and nextDifficultyWeeklyRewardLevel>0 and nextBestLevel>0 and currentWeekBestLevel<nextDifficultyWeeklyRewardLevel then
        m=m..'\n'..(e.onlyChinese and '下一级：' or NEXT_RANK_COLON)..nextDifficultyWeeklyRewardLevel..' ('..nextBestLevel..')'
    end]]

    local mapChallengeModeID, level = C_MythicPlus.GetLastWeeklyBestInformation()
    if mapChallengeModeID and level and level>0 and mapChallengeModeID>0 then
        local name, _, _, texture, _ = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
        if name then
            m= (m~='' and m..'\n\n' or m)..(e.onlyChinese and '上周' or HONOR_LASTWEEK)..': '.. (texture and '|T'..texture..':0|t' or '')..name..' '..level
        end
    end

    local info= C_MythicPlus.GetRunHistory(true, true)--全部
    if info then
        local nu=#C_MythicPlus.GetRunHistory(true) or {}
        local nu2=#info
        m= (m~='' and m..'\n\n' or m)..(e.onlyChinese and '历史' or HISTORY)..': |cff00ff00'..nu.. '/'.. nu2.. ' |r(|cffffffff'..nu2-nu..'|r)'
    end

    info = C_MythicPlus.GetRunHistory(false, true)--本周记录
    if info then
        table.sort(info, HistorySort)
        local n,n2=0,0
        local IDs={}
        for _, v in pairs(info) do
            if v and v.level and v.mapChallengeModeID then
                local name, _, _, texture = C_ChallengeMode.GetMapUIInfo(v.mapChallengeModeID)
                if name then
                    IDs[name]=IDs[name] or {
                        texture=texture and '|T'..texture..':0|t' or '',
                        lv={},
                        co=0,
                        to=0,
                    }
                    if v.completed then
                        table.insert(IDs[name].lv, '|cff00ff00'..v.level..'|r')
                        n=n+1
                        IDs[name].co=IDs[name].co+1
                    else
                        table.insert(IDs[name].lv, '|cffffffff'..v.level..'|r')
                    end
                    IDs[name].to=IDs[name].to+1
                    n2=n2+1
                end
            end
        end
        local m2=''
        for k, v in pairs(IDs) do
            if m2~='' then m2=m2..'|n' end
            m2=m2..v.texture..' |cff00ff00'..v.co..'/'..v.to..'|r '..k
            for _,v2 in pairs(v.lv) do
                m2=m2..' '..v2
            end
        end
        if m2~='' then m=(m~='' and m..'|n' or '')..(e.onlyChinese and '本周' or CHALLENGE_MODE_THIS_WEEK)..': |cff00ff00'..n..'/'..n2..'|r  (|cffffffff'..(n2-n)..'|r)|n'..m2 end
    end

    local text= m..'\n'--所有角色KEY
    for guid, infoWoW in pairs(WoWDate) do
        local find
        for link, _ in pairs(infoWoW.Keystone.itemLink) do
            text=text..'\n    '..link
            find=true
        end
        if find then
            text= text..'\n'.. e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false})
        end
    end
    if  text and not self.WoWKeystones then
        self.WoWKeystones=e.Cstr(self)
        if IsAddOnLoaded('RaiderIO') and RaiderIO_ProfileTooltip then
            self.WoWKeystones:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', 2, 0)
            --self.WoWKeystones:SetPoint('TOPLEFT', RaiderIO_ProfileTooltip, 'BOTTOMLEFT')
        else
            self.WoWKeystones:SetPoint('TOPLEFT', self, 'TOPRIGHT', 2, -10)
        end
    end
    if self.WoWKeystones then
        self.WoWKeystones:SetText(text)
    end
end

local function Cur(self)--货币数量
    local IDs={1602, 1191}
    for k, v in pairs(IDs) do
        local info=C_CurrencyInfo.GetCurrencyInfo(v)
        local t=''
        if info and info.discovered and info.quantity and info.maxQuantity and not Save.hide then
            if info.maxQuantity>0  then
                if info.useTotalEarnedForMaxQty then--本周还可获取                        
                    local q
                    q= info.maxQuantity - info.totalEarned
                    if q>0 then q='|cff00ff00'..q..'|r' end
                    t=t..'('..q..'+) '
                end
                if info.quantity==info.maxQuantity then
                    t=t..'|cff00ff00'..info.quantity.. '/'..info.maxQuantity..'|r '
                else
                    t=t..info.quantity.. '/'..info.maxQuantity..' '
                end
            else
                if info.maxQuantity==0 then
                    t=t..info.quantity..'/'.. (e.onlyChinese and '无限制' or UNLIMITED)..' '
                else
                    if info.quantity==info.maxQuantity then
                        t=t..'|cff00ff00'..info.quantity.. '/'..info.maxQuantity..'|r '
                    else
                        t=t..info.quantity..'/'..info.maxQuantity..' '
                    end
                end
            end
            --t=t..info.name

            if not self['cur'..k] then
                self['cur'..k]=CreateFrame("Button", nil, self)
                self['cur'..k]:SetHighlightAtlas('Forge-ColorSwatchSelection')
                self['cur'..k]:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress')
                self['cur'..k]:SetNormalTexture(info.iconFileID)
                if k==1 then
                    self['cur'..k]:SetPoint('BOTTOMRIGHT',-10, 90)
                else
                    self['cur'..k]:SetPoint('BOTTOMRIGHT', self['cur'..(k-1)], 'TOPRIGHT', 0,0)
                end
                self['cur'..k]:SetSize(16, 16)

                self['cur'..k]:SetScript("OnEnter",function(self2)
                        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:SetCurrencyByID(v)
                        e.tips:Show()
                end)
                self['cur'..k]:SetScript("OnLeave",function()
                        e.tips:Hide()
                end)

                self['cur'..k].text=e.Cstr(self['cur'..k], {size=10})
                self['cur'..k].text:SetPoint('RIGHT', self['cur'..k], 'LEFT', 0, 0)
                self['cur'..k].text:SetJustifyH('RIGHT')
            end
        end
        if self['cur'..k] then
            self['cur'..k].text:SetText(t)
            self['cur'..k]:SetShown(not Save.hide)
        end
    end
end


local function set_Update()--Blizzard_ChallengesUI.lua
    local self=ChallengesFrame
    if not self.maps or #self.maps==0 then
        return
    end
    local currentChallengeMapID= C_MythicPlus.GetOwnedKeystoneChallengeMapID()--当前, KEY地图,ID
    for i=1, #self.maps do
        local frame = self.DungeonIcons[i]
        if frame and frame.mapID then
            if not frame.tips then
                frame:SetScript("OnMouseDown",function(self2)
                    if not IsAddOnLoaded("Blizzard_EncounterJournal.lua") then LoadAddOn("Blizzard_EncounterJournal.lua") end
                    if not EncounterJournal or not EncounterJournal:IsVisible() then
                        ToggleEncounterJournal()
                    end
                    --securecall('NavBar_Reset', EncounterJournal.navBar)
                    --securecall('EncounterJournal_DisplayInstance', EncounterJournal_Maps[self2.mapID])
                end)
                frame:HookScript('OnEnter', function(self2)--提示
                    if self2.mapID then
                        local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self2.mapID)
                        if intimeInfo then
                            e.tips:AddLine(' ')
                            for index, info in pairs(intimeInfo.members) do
                                if info.name then
                                    if index==1 then
                                        if intimeInfo.completionDate and intimeInfo.level then--完成,日期
                                            local d=intimeInfo.completionDate
                                            local time= ('%s:%s %d/%d/%d %s'):format(d.hour<10 and '0'..d.hour or d.hour, d.minute<10 and '0'..d.minute or d.minute, d.day, d.month, d.year, '|r('..intimeInfo.level..')')
                                            local time2
                                            if overtimeInfo and overtimeInfo.completionDate and overtimeInfo.level then
                                                d=overtimeInfo.completionDate
                                                time2= ('%s %s:%s %d/%d/%d'):format('('..overtimeInfo.level..')|cffff0000', d.hour<10 and '0'..d.hour or d.hour, d.minute<10 and '0'..d.minute or d.minute, d.day, d.month, d.year)
                                            end
                                            e.tips:AddDoubleLine('|cnGREEN_FONT_COLOR:'..time, time2)
                                        end
                                    end

                                    local text, text2= '', nil
                                    if info.specID then
                                        text= '|T'..select(4, GetSpecializationInfoByID(info.specID))..':0|t'
                                    end
                                    text= info.name== e.Player.name and text..info.name..e.Icon.star2 or text..info.name
                                    if info.classID then
                                        local classFile= select(2, GetClassInfo(info.classID))
                                        local argbHex = classFile and select(4, GetClassColor(classFile))
                                        if argbHex then
                                            text= '|c'..argbHex..text..'|r'
                                        end
                                    end
                                    if overtimeInfo and overtimeInfo.members and overtimeInfo.members[index] and overtimeInfo.members[index].name then
                                        local info2= overtimeInfo.members[index]
                                        text2= info2.name== e.Player.name and (e.Icon.star2..info2.name) or info2.name
                                        if info2.specID then
                                            text2= text2..'|T'..select(4, GetSpecializationInfoByID(info2.specID))..':0|t'
                                        end
                                        if info2.classID then
                                            local classFile= select(2, GetClassInfo(info2.classID))
                                            local argbHex = classFile and select(4, GetClassColor(classFile))
                                            if argbHex then
                                                text2= '|c'..argbHex..text2..'|r'
                                            end
                                        end
                                    end
                                    e.tips:AddDoubleLine(text, text2)

                                    if index==#intimeInfo.members and intimeInfo.affixIDs then
                                        local affix, affix2='', ''
                                        for index2, v in pairs(intimeInfo.affixIDs) do
                                            local filedataid = select(3, C_ChallengeMode.GetAffixInfo(v))
                                            if filedataid then
                                                affix= affix.. '|T'..filedataid..':0|t'
                                            end
                                            if overtimeInfo and overtimeInfo.affixIDs and overtimeInfo.affixIDs[index2] then
                                                filedataid = select(3, C_ChallengeMode.GetAffixInfo(overtimeInfo.affixIDs[index2]))
                                                if filedataid then
                                                    affix2= affix2.. '|T'..filedataid..':0|t'
                                                end
                                            end
                                        end
                                        if affix ~='' then
                                            e.tips:AddDoubleLine(affix, affix2)
                                        end
                                    end
                                end
                            end
                        end



                        e.tips:AddLine(' ')
                        local timeLimit, texture, backgroundTexture = select(3, C_ChallengeMode.GetMapUIInfo(self2.mapID))
                        local a=GetNum(self2.mapID, true) or RED_FONT_COLOR_CODE..(e.onlyChinese and '无' or NONE)..'|r'--所有
                        local w=GetNum(self2.mapID) or RED_FONT_COLOR_CODE..(e.onlyChinese and '无' or NONE)..'|r'--本周
                        e.tips:AddDoubleLine((e.onlyChinese and '历史' or HISTORY)..': '..a, (e.onlyChinese and '本周' or CHALLENGE_MODE_THIS_WEEK)..': '..w)
                        e.tips:AddDoubleLine('mapChallengeModeID |cnGREEN_FONT_COLOR:'.. self2.mapID..'|r', timeLimit and (e.onlyChinese and '限时' or GROUP_FINDER_PVE_PLAYSTYLE3)..' '.. SecondsToTime(timeLimit))
                        if texture and backgroundTexture then
                            e.tips:AddDoubleLine('|T'..texture..':0|t'..texture, '|T'..backgroundTexture..':0|t'..backgroundTexture)
                        end
                        --if EncounterJournal_Maps[self2.mapID] then
                            e.tips:AddLine(' ')
                            e.tips:AddDoubleLine(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, e.Icon.left)
                        --end
                        e.tips:Show()
                    end
                end)
                frame.tips=true
            end

            if Save.hide then
                if frame.nameStr then frame.nameStr:SetText('') end
                if frame.sc then frame.sc:SetText('') end
                if frame['affixInfo1'] then frame['affixInfo1']:SetText('') end
                if frame['affixInfo2'] then frame['affixInfo2']:SetText('') end
                if frame.nu then frame.nu:SetText('') end
                if frame.currentKey then frame.currentKey:SetShown(false) end
            else

                local name = C_ChallengeMode.GetMapUIInfo(frame.mapID)--名称                        
                if name then
                    if not frame.nameStr then
                        frame.nameStr=e.Cstr(frame, {size=10})
                        frame.nameStr:SetPoint('BOTTOM',frame, 'TOP', 0,0)
                    end
                    name=name:match('%((.+)%)') or name
                    name=name:match('%（(.+)%）') or name
                    name=name:match('%- (.+)') or name
                    name=name:match('%:(.+)') or name
                    name=name:match('%: (.+)') or name
                    name=name:match('：(.+)') or name
                    name=name:match('·(.+)') or name
                    name=e.WA_Utf8Sub(name, 5, 10)
                    frame.nameStr:SetText(name)
                end

                local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(frame.mapID)--分数 最佳
                local affixScores, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(frame.mapID)
                if(overAllScore and intimeInfo or overtimeInfo) then
                    local label=frame.sc
                    if not label then--分数
                        label=e.Cstr(frame, {size=10})
                        label:SetPoint('LEFT', 0, -3)
                        label:EnableMouse(true)
                        label:SetScript('OnEnter', function(self2)
                            e.tips:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                            e.tips:ClearLines()
                            e.tips:AddLine((e.onlyChinese and '史诗钥石评分：%s' or CHALLENGE_COMPLETE_DUNGEON_SCORE ):format(self2.score))
                            e.tips:Show()
                        end)
                        label:SetScript('OnLeave', function() e.tips:Hide() end)
                        frame.sc= label
                        if frame.HighestLevel then--移动层数位置
                            frame.HighestLevel:ClearAllPoints()
                            frame.HighestLevel:SetPoint('LEFT', 0, 12)
                            frame.HighestLevel:EnableMouse(true)
                            frame.HighestLevel:SetScript('OnEnter', function(self2)
                                e.tips:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                                e.tips:ClearLines()
                                e.tips:AddLine((e.onlyChinese and '最佳%s' or DUNGEON_SCORE_BEST_AFFIX):format( (e.onlyChinese and '等级' or LEVEL)..': '..self2:GetText()))
                                e.tips:Show()
                            end)
                            frame.HighestLevel:SetScript('OnLeave', function() e.tips:Hide() end)
                        end
                    end
                    local score= '|A:AdventureMapIcon-MissionCombat:16:16|a'..e.GetKeystoneScorsoColor(overAllScore,nil,true)
                    label:SetText(score)
                    label.score= score
                end

                if(affixScores and #affixScores > 0) then --最佳 
                    local nameA, _, filedataidA = C_ChallengeMode.GetAffixInfo(10)
                    local nameB, _, filedataidB = C_ChallengeMode.GetAffixInfo(9)
                    local k=1
                    for _, info in ipairs(affixScores) do
                        if info.level and info.level>0 and (info.name == nameA or info.name==nameB) then
                            local label=frame['affixInfo'..k]
                            if not label then
                                label= e.Cstr(frame, {justifyH= info.name==nameB and 'RIGHT'})
                                if info.name== nameA then
                                    label:SetPoint('BOTTOMLEFT')
                                else
                                    label:SetPoint('BOTTOMLEFT', 0, 14)
                                end
                                label:EnableMouse(true)
                                label:SetScript('OnEnter', function(self2)
                                    e.tips:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                                    e.tips:ClearLines()
                                    e.tips:AddLine((e.onlyChinese and '最佳%s' or DUNGEON_SCORE_BEST_AFFIX):format(self2.name))
                                    e.tips:Show()
                                end)
                                label:SetScript('OnLeave', function() e.tips:Hide() end)
                                frame['affixInfo'..k]= label
                            end
                            local level= info.overTime and '|cnRED_FONT_COLOR:'..info.level..'|r' or info.level
                            local icon='|T'..(info.name == nameA and filedataidA or filedataidB)..':0|t'
                            label:SetText(icon..level)
                            label.name= icon..info.name..': '..level
                            k=k+1
                        end
                    end
                end


                local all= GetNum(frame.mapID, true)--副本 完成/总次数 (全部)
                local week= GetNum(frame.mapID)--本周
                if all or week then
                    local label= frame.nu
                    if not label then
                        label=e.Cstr(frame)
                        label:SetPoint('TOPLEFT')
                        label:EnableMouse(true)
                        label:SetScript('OnEnter', function(self2)
                            e.tips:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                            e.tips:ClearLines()
                            e.tips:AddDoubleLine(e.onlyChinese and '历史' or HISTORY , self2.all or (e.onlyChinese and '无' or NONE))
                            e.tips:AddDoubleLine(e.onlyChinese and '本周' or CHALLENGE_MODE_THIS_WEEK, self2.week or (e.onlyChinese and '无' or NONE))
                            e.tips:Show()
                        end)
                        label:SetScript('OnLeave', function() e.tips:Hide() end)
                        frame.nu= label
                    end
                    label:SetText((all or '')..( week and ' |cffffffff(|r'..week..'|cffffffff)|r' or ''))
                    label.all=all or week
                    label.week= week
                end

                if currentChallengeMapID== frame.mapID and not frame.currentKey then--提示, 包里KEY地图
                    frame.currentKey= frame:CreateTexture(nil, 'OVERLAY')
                    frame.currentKey:SetPoint('BOTTOM')
                    frame.currentKey:SetAtlas('auctionhouse-icon-favorite')
                    frame.currentKey:SetSize(14,14)
                    frame.currentKey:EnableMouse(true)
                    frame.currentKey:SetScript('OnEnter', function(self2)
                        e.tips:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        for bag=0, NUM_BAG_SLOTS do
                            for slot=1, C_Container.GetContainerNumSlots(bag) do
                                local info = C_Container.GetContainerItemInfo(bag, slot)
                                if info and C_Item.IsItemKeystoneByID(info.hyperlink) then
                                    e.tips:SetBagItem(bag, slot)
                                end
                                break
                            end
                        end
                        e.tips:Show()
                    end)
                    frame.currentKey:SetScript('OnLeave', function() e.tips:Hide() end)
                end
                if frame.currentKey then
                    frame.currentKey:SetShown(currentChallengeMapID== frame.mapID)
                end
            end
            --set_Spell_Port(frame)--传送门
        end
    end

    if ChallengesFrame.WeeklyInfo.Child.WeeklyChest and ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus and ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:GetText()==MYTHIC_PLUS_COMPLETE_MYTHIC_DUNGEONS then
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetText('')--隐藏，完成史诗钥石地下城即可获得
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:Hide()
    end
    if ChallengesFrame and ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child and ChallengesFrame.WeeklyInfo.Child.Description then
        ChallengesFrame.WeeklyInfo.Child.Description:SetText('')
        ChallengesFrame.WeeklyInfo.Child.Description:Hide()
    end
end

--####
--初始
--####
local function Init()
    local self=ChallengesFrame
    self.sel= e.Cbtn(self, {size={22,22}, icon= not Save.hide})
    self.sel:SetPoint('TOPLEFT',60,-20)
    --self.sel:SetChecked(Save.hide)
    --self.sel.text:SetText(e.onlyChinese and '隐藏' or HIDE)
    self.sel:SetScript("OnClick", function (self2)
        Save.hide = not Save.hide and true or nil
        Kill(ChallengesFrame)--副本PVP团本
        ChallengesFrame:Update()
        Affix()
        All(ChallengesFrame)--所有记录   
        Cur(ChallengesFrame)--货币数量
        self2:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.icon)
    end)

    self.sel:SetScript("OnEnter",function(self2)
            local mapIDs = {}
            for _, v in pairs( (C_ChallengeMode.GetMapTable() or {})) do
                mapIDs[v]=true
            end

            local infos= C_MythicPlus.GetRunHistory(true, true)
            if not infos then return end
            local IDs={}
            local t=0
            for _, v in pairs(infos) do
                local mapChallengeModeID=v.mapChallengeModeID
                IDs[mapChallengeModeID]= IDs[mapChallengeModeID] or {c=0, t=0}
                if v.completed then
                    t=t+1
                    IDs[mapChallengeModeID].c= IDs[mapChallengeModeID].c+1
                end
                IDs[mapChallengeModeID].t= IDs[mapChallengeModeID].t+1
                if v.level and ( not IDs[mapChallengeModeID].lv or  v.level > IDs[mapChallengeModeID].lv) then--最高等级
                    IDs[mapChallengeModeID].lv=v.level
                    IDs[mapChallengeModeID].completed=v.completed
                    if v.completed then
                        if not IDs[mapChallengeModeID].lv2 or  v.level > IDs[mapChallengeModeID].lv2 then
                            IDs[mapChallengeModeID].lv2=v.level
                        end
                    end
                end
                IDs[mapChallengeModeID].mapIDs=mapIDs[mapChallengeModeID]--本赛季
            end

            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(HISTORY, t..'/'..#infos, 0,1,0 ,0,1,0)

            for k, v in pairs(IDs) do
                local name, _, _, texture= C_ChallengeMode.GetMapUIInfo(k)
                if name then
                    local col, r, g, b
                    local bestOverAllScore = select(2, C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(k))
                    if  bestOverAllScore then
                        col=C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(bestOverAllScore)
                    end
                    if col then r,g,b= col.r, col.g, col.b end
                    local m=not mapIDs[k] and e.Icon.X or ''
                    m=m..(texture and '|T'..texture..':0|t' or '').. name
                    if v.lv then
                        m=m..'('
                        if v.completed then
                            m=m..'|cff00ff00'..v.lv..'|r'
                        else
                            m=m..RED_FONT_COLOR_CODE..v.lv..'|r'
                            m=v.lv2 and m..'/|cff00ff00'..v.lv2..'|r' or m
                        end
                        m=m..') '
                    end
                    m=m.. (bestOverAllScore or '')
                    e.tips:AddDoubleLine(m, v.c..'/'..v.t, r,g,b , r,g,b)
                end
            end
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '显示/隐藏' or SHOW..'/'..HIDE, e.Icon.left)
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
    end)
    self.sel:SetScript("OnLeave",function()
            e.tips:Hide()
    end)

    if self.WeeklyInfo and self.WeeklyInfo.Child then--隐藏, 赛季最佳
        if self.WeeklyInfo.Child.SeasonBest then
            self.WeeklyInfo.Child.SeasonBest:SetText('')
        end
   end

   Kill(self)--副本PVP团本
   hooksecurefunc(self, 'Update', set_Update)
   Affix()
   All(self)--所有记录   
   Cur(self)--货币数量

    if ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child then
        if ChallengesFrame.WeeklyInfo.Child.Description and ChallengesFrame.WeeklyInfo.Child.Description:IsVisible() then
            local text= ChallengesFrame.WeeklyInfo.Child.Description:GetText()
            if text==MYTHIC_PLUS_MISSING_KEYSTONE_MESSAGE then
                ChallengesFrame.WeeklyInfo.Child.Description:SetText()
                print(id, addName)
                print('|cffff00ff',text)
            end
        end
    end
end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('CHALLENGE_MODE_START')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel('|A:UI-HUD-MicroMenu-Groupfinder-Mouseover:0:0|a'..(e.onlyChinese and '史诗钥石地下城' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_ChallengesUI' then--挑战,钥石,插入界面
            set_Key_Blizzard_ChallengesUI()--挑战,钥石,插入界面
            Init()--史诗钥石地下城, 界面
            panel:RegisterEvent('CHALLENGE_MODE_COMPLETED')
            panel:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
            panel:RegisterEvent('UPDATE_INSTANCE_INFO')
            panel:RegisterEvent('WEEKLY_REWARDS_UPDATE')

        elseif arg1=='Blizzard_WeeklyRewards' then--周奖励界面，添加一个按钮，打开挑战界面
            local btn =e.Cbtn(WeeklyRewardsFrame, {icon='hide', size={15,15}})--所有角色,挑战
            btn:SetPoint('BOTTOMLEFT', WeeklyRewardsFrame, 'TOPLEFT', 30,0)
            btn:SetNormalTexture(4352494)
            btn:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT");
                e.tips:ClearLines();
                e.tips:AddDoubleLine(e.onlyChinese and '史诗钥石地下城' or CHALLENGES, e.Icon.left)
                e.tips:Show()
            end)
            btn:SetScript("OnLeave",function() e.tips:Hide() end)
            btn:SetScript('OnMouseDown', function()
                PVEFrame_ToggleFrame('ChallengesFrame',3)
            end)
            btn:SetAlpha(0.5)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='CHALLENGE_MODE_START' then
        set_CHALLENGE_MODE_START()--赏金, 说 Bounty

    elseif event=='CHALLENGE_MODE_COMPLETED' or event=='WEEKLY_REWARDS_UPDATE' then
        C_Timer.After(2, function()
            Kill(ChallengesFrame)--副本PVP团本
            All(ChallengesFrame)--所有记录   
            Cur(ChallengesFrame)--货币数量
        end)
    elseif event=='CURRENCY_DISPLAY_UPDATE' then
        Cur(ChallengesFrame)--货币数量

    elseif event=='UPDATE_INSTANCE_INFO' then
        C_Timer.After(2, function()
            Kill(ChallengesFrame)--副本PVP团本
        end)
    end
end)
