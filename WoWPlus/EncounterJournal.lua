local id, e = ...
local addName= ADVENTURE_JOURNAL
local Save={
    wowBossKill={},
    loot= {[e.Player.class]= {}},
}
local panel=CreateFrame("Frame")


local function getBossNameSort(name)--取得怪物名称, 短名称
    name=name:gsub('(,.+)','')
    name=name:gsub('(，.+)','')
    name=name:gsub('·.+','')
    name=name:gsub('%-.+','')
    name=name:gsub('<.+>', '')
    return name
end

local function EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据
    local self=EncounterJournal
    if not self or Save.hideEncounterJournal_All_Info_Text then
        if self and self.AllText then
            self.AllText:SetText('')
        end
        return
    end
    if not self.AllText then
        self.AllText=e.Cstr(self)
        self.AllText:SetPoint('TOPLEFT', self, 'TOPRIGHT',40,0)
    end
    local m=''

    local tab=WoWDate[e.Player.guid].Instance.ins
    local text=''
    for insName, info in pairs(tab) do
        text= text~='' and text..'\n' or text
        text= text..'|T450908:0|t'..insName
        for difficultyName, index in pairs(info) do
            text=text..'\n     '..index..' '..difficultyName
        end
    end
    if text~='' then
        m= m~='' and m..'\n\n'..text or text
    end

    text=''--世界BOSS
    tab=WoWDate[e.Player.guid].Worldboss.boss
    local num=0
    for bossName, _ in pairs(tab) do
        num=num+1
        text= text~='' and text..' ' or text
        text=text.. getBossNameSort(bossName)
    end
    if text~='' then
        m= m~='' and m..'\n\n' or m
        m=m..num..' |cnGREEN_FONT_COLOR:'..text..'|r'
    end

    tab=WoWDate[e.Player.guid].Rare.boss--稀有怪
    text, num='',0
    for name, _ in pairs(tab) do
        text=text~='' and text..' ' or text
        text=text..getBossNameSort(name)
        num=num+1
    end
    if text~='' then
        m= m~='' and m..'\n\n' or m
        m= m..num..' '..'|cnGREEN_FONT_COLOR:'..text..'|r'
    end

    --周奖励,副本,PVP,团本
    tab = {}
    local activityInfo =  C_WeeklyRewards.GetActivities()--Blizzard_WeeklyRewards.lua
    for  _ , info in pairs(activityInfo) do
        local difficulty
        if info.type == Enum.WeeklyRewardChestThresholdType.Raid then
            difficulty = DifficultyUtil.GetDifficultyName(info.level);
        elseif info.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
            difficulty =  string.format(WEEKLY_REWARDS_MYTHIC, info.level);
        elseif info.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
            difficulty =  PVPUtil.GetTierName(info.level);
        elseif info.type== Enum.WeeklyRewardChestThresholdType.AlsoReceive then
            difficulty =  WEEKLY_REWARDS_ALSO_RECEIVE;
        elseif info.type== Enum.WeeklyRewardChestThresholdType.Concession then
            difficulty =  WEEKLY_REWARDS_GET_CONCESSION;
        end
        tab[info.type]=tab[info.type] or {}
        tab[info.type][info.index] = {
            level = info.level,
            difficulty = difficulty or NONE,
            progress = info.progress,
            threshold = info.threshold,
            unlocked = info.progress >= info.threshold,
            rewards = info.rewards,
        }
    end
    text=''
    for type,v in pairs(tab) do
        local head
        if type == Enum.WeeklyRewardChestThresholdType.Raid then
            head = RAIDS
        elseif type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
            head = MYTHIC_DUNGEONS
        elseif type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
            head = PVP
        end
        if head then
            text = text~='' and text..'\n' or text
            text = text..'|T450908:0|t'..head
            if head==MYTHIC_DUNGEONS and WoWDate[e.Player.guid].Keystone then
                local weekLevel= WoWDate[e.Player.guid].Keystone.weekLevel--本周最高
                if weekLevel then
                    text=text..' |cnGREEN_FONT_COLOR:'..weekLevel..'|r'
                end
            end
            for x,r in pairs(v) do
                text = text~='' and text..'\n' or text
                text = text..'     '
                if r.unlocked then
                    text = text..'|cnGREEN_FONT_COLOR:'..x..')'..r.difficulty.. ' '..COMPLETE..'|r'
                else
                    text = text..x..')'..r.difficulty.. ' '..r.progress.."/"..r.threshold
                end
                if r.level and r.level>0 then
                    text=text..' '..r.level
                end
                if r.rewards then
                    if r.rewards.type==1 then
                        text=text..' '..ITEMS
                    elseif r.rewards.type==2 then
                        text=text..' '..CURRENCY
                    elseif r.rewards==3 then
                        text=text..' '..QUESTS_LABEL
                    end
                end
            end
        end
    end
    m= m~='' and m..'\n\n'..text or text

    --征服点数 Conquest 1602 1191/勇气点数
    tab={1191, 1602, 1792}
    text=''
    for _,v in pairs(tab) do
        local info=C_CurrencyInfo.GetCurrencyInfo(v)
        if info and info.quantity and info.quantity>=0 and info.name then
            local t=(info.iconFileID and '|T'..info.iconFileID..':0|t' or '')..info.name..': '
            t=t..e.MK(info.quantity,3)..((info.maxQuantity and info.maxQuantity>0) and '/'..e.MK(info.maxQuantity,3) or '')
            if info.maxQuantity and info.maxQuantity>0 and info.maxQuantity==info.quantity then
                t='|cnRED_FONT_COLOR:'..t..'|r'
            end
            text= text~='' and text..'\n'..t or t
        end
    end
    if text~='' then
        m= m~='' and m..'\n\n'..text or text
    end
    --本周还可获取奖励
    if C_WeeklyRewards.CanClaimRewards() then
        m=m..'\n\n|cFF00FF00'.. string.format(LFD_REWARD_DESCRIPTION_WEEKLY,1)..'|r|T134140:0|t'
    end
    self.AllText:SetText(m)
end

local function set_EncounterJournal_World_Tips(self2)--所有角色已击杀世界BOSS提示
    e.tips:SetOwner(self2, "ANCHOR_LEFT");
    e.tips:ClearLines();
    e.tips:AddDoubleLine(ADVENTURE_JOURNAL, CHANNEL_CATEGORY_WORLD..'BOSS/'..GARRISON_MISSION_RARE..e.Icon.left..e.GetShowHide(Save.showWorldBoss))
    e.tips:AddLine(' ')
    for guid, info in pairs(WoWDate) do
        local find
        local text, num= nil, 0
        for bossName, _ in pairs(info.Worldboss.boss) do--世界BOSS
            num=num+1
            text= text and text..' ' or '   '
            text= text..'|cnGREEN_FONT_COLOR:'..num..')|r'..getBossNameSort(bossName)
        end
        if text then
            e.tips:AddLine(text, nil,nil,nil, true)
            find=true
        end

        text, num= nil, 0
        for bossName, _ in pairs(info.Rare.boss) do--稀有怪
            num= num+1
            text= text and text..' ' or ''
            text= text..'(|cnGREEN_FONT_COLOR:'..num..'|r)'..getBossNameSort(bossName)
        end
        if text then
            e.tips:AddLine(text, nil,nil,nil, true)
            find=true
        end
        if find then
            e.tips:AddDoubleLine(e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=false, reRealm=false, reLink=false}), guid==e.Player.guid and e.Icon.star2)
        end
    end
    e.tips:Show()
end

local function MoveFrame(self, savePointName)
    self:RegisterForDrag("RightButton")
    self:SetClampedToScreen(true)
    self:SetMovable(true)
    self:SetScript("OnDragStart", function(self2) self2:StartMoving() end);
    self:SetScript("OnDragStop", function(self2)
            ResetCursor()
            self2:StopMovingOrSizing()
            Save[savePointName]={self2:GetPoint(1)}
    end);
    self:SetScript('OnLeave', function()
        self:SetButtonState("NORMAL")
        e.tips:Hide()
    end)
    self:EnableMouseWheel(true)
    self:SetScript('OnMouseWheel', function(self2, d)
        local size=Save.EncounterJournalFontSize or 12
        if d==1 then
            size=size+1
        else
            size=size-1
        end
        size= size<6 and 6 or size
        size= size>72 and 72 or size
        Save.EncounterJournalFontSize=size
        e.Cstr(nil, {size=size, changeFont=self2.Text})--size, nil, self2.Text)
        print(id, addName, 	FONT_SIZE, size)
    end)
end

local function setWorldbossText()--显示世界BOSS击杀数据Text
    if not Save.showWorldBoss then
        if panel.WorldBoss then
            panel.WorldBoss.Text:SetText('')
            panel.WorldBoss:SetShown(false)
        end
        return
    end
    if not panel.WorldBoss then
        panel.WorldBoss=e.Cbtn(nil, {icon='hide', size={14,14}})
        if Save.WorldBossPoint then
            panel.WorldBoss:SetPoint(Save.WorldBossPoint[1], UIParent, Save.WorldBossPoint[3], Save.WorldBossPoint[4], Save.WorldBossPoint[5])
        else
            if IsAddOnLoaded('Blizzard_EncounterJournal') then
                panel.WorldBoss:SetPoint('BOTTOMRIGHT',EncounterJournal, 'TOPRIGHT', -65,5)
            else
                panel.WorldBoss:SetPoint('CENTER')
            end
        end
        panel.WorldBoss:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT");
            e.tips:ClearLines();
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddDoubleLine(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, e.onlyChinese and '世界BOSS和稀有怪' or (CHANNEL_CATEGORY_WORLD..'BOSS/'..GARRISON_MISSION_RARE))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.GetShowHide(not Save.hideWorldBossText), e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or  NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine(e.onlyChinese and '大小' or FONT_SIZE, (Save.EncounterJournalFontSize or 12)..e.Icon.mid)
            e.tips:Show()
        end)
        panel.WorldBoss:SetScript('OnMouseDown', function(self2, d)
            if d=='LeftButton' then
                Save.hideWorldBossText= not Save.hideWorldBossText and true or nil
                panel.WorldBoss.texture:SetShown(Save.hideWorldBossText)
                panel.WorldBoss.Text:SetShown(not Save.hideWorldBossText)
            end
        end)
        MoveFrame(panel.WorldBoss, 'WorldBossPoint')

        panel.WorldBoss.Text=e.Cstr(panel.WorldBoss, {size=Save.EncounterJournalFontSize})--, nil,nil,nil)
        panel.WorldBoss.Text:SetPoint('TOPLEFT')

        panel.WorldBoss.texture=panel.WorldBoss:CreateTexture()
        panel.WorldBoss.texture:SetAllPoints(panel.WorldBoss)
        panel.WorldBoss.texture:SetAtlas(e.Icon.disabled)
        --panel.WorldBoss.texture:SetShown(Save.hideWorldBossText)
    end

    local msg
    if not Save.hideWorldBossText then
        for guid, info in pairs(WoWDate) do
            local text, numAll, find= nil, 0, nil
            for bossName, _ in pairs(info.Worldboss.boss) do--世界BOSS
                numAll=numAll+1
                text= text and text ..' ' or '   '
                text= text..'|cnGREEN_FONT_COLOR:'..numAll..')|r'..getBossNameSort(bossName)
            end
            if text then
                msg= msg and msg..'\n' or ''
                msg= msg..text
                find= true
            end

            text, numAll= nil, 0
            for bossName, _ in pairs(info.Rare.boss) do--稀有怪
                numAll=numAll+1
                text= text and text ..' ' or '   '
                text= text..'|cnGREEN_FONT_COLOR:'..numAll..')|r'..getBossNameSort(bossName)
            end
            if text then
                msg= msg and msg..'\n' or ''
                msg= msg..text
                find= true
            end
            if find then
                msg= msg..'\n'..e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false})
            end
        end
        msg= msg or '...'
    end
    panel.WorldBoss.Text:SetText(msg or '')
    panel.WorldBoss:SetShown(true)
    panel.WorldBoss.texture:SetShown(Save.hideWorldBossText)
    panel.WorldBoss.Text:SetShown(not Save.hideWorldBossText)
end

local function setInstanceBossText()--显示副本击杀数据
    if not Save.showInstanceBoss then
        if panel.instanceBoss then
            panel.instanceBoss.Text:SetText('')
            panel.instanceBoss:SetShown(false)
        end
        return
    end
    if not panel.instanceBoss then
        panel.instanceBoss=e.Cbtn(nil, {icon='hide', size={14,14}})
        if Save.instanceBossPoint then
            panel.instanceBoss:SetPoint(Save.instanceBossPoint[1], UIParent, Save.instanceBossPoint[3], Save.instanceBossPoint[4], Save.instanceBossPoint[5])
        else
            if EncounterJournal then
                panel.instanceBoss:SetPoint('BOTTOMRIGHT',EncounterJournal, 'TOPRIGHT', -45,20)
            else
                panel.instanceBoss:SetPoint('CENTER')
            end
        end
        panel.instanceBoss:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT");
            e.tips:ClearLines();
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddDoubleLine(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, e.onlyChinese and '副本' or INSTANCE)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.GetShowHide(not Save.hideInstanceBossText), e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine(e.onlyChinese and '大小' or FONT_SIZE, (Save.EncounterJournalFontSize or 12)..e.Icon.mid)
            e.tips:Show()
        end)
        panel.instanceBoss:SetScript('OnMouseDown', function(self2, d)
            if d=='LeftButton' then
                Save.hideInstanceBossText= not Save.hideInstanceBossText and true or nil
                panel.instanceBoss.texture:SetShown(Save.hideInstanceBossText)
                panel.instanceBoss.Text:SetShown(not Save.hideInstanceBossText)
            end
        end)
        MoveFrame(panel.instanceBoss, 'instanceBossPoint')
        panel.instanceBoss.Text=e.Cstr(panel.instanceBoss, {size=Save.EncounterJournalFontSize})
        panel.instanceBoss.Text:SetPoint('TOPLEFT')

        panel.instanceBoss.texture=panel.instanceBoss:CreateTexture()
        panel.instanceBoss.texture:SetAllPoints(panel.instanceBoss)
        panel.instanceBoss.texture:SetAtlas(e.Icon.disabled)
        panel.instanceBoss.texture:SetShown(Save.hideInstanceBossText)
    end

    local msg
    if not Save.hideInstanceBossText then
        for guid, info in pairs(WoWDate) do
            local text
            for bossName, tab in pairs(info.Instance.ins) do--ins={[名字]={[难度]=已击杀数}}
                text= text and text..'\n   '..bossName or '   '..bossName
                for difficultyName, killed in pairs(tab) do
                    text= text..' '..difficultyName..' '..killed
                end
            end
            if text then
                msg=msg and msg..'\n' or ''
                msg= msg ..e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false})..'\n'
                msg= msg.. text
            end
        end
        msg=msg or '...'
    end
    panel.instanceBoss.Text:SetText(msg or '')
    panel.instanceBoss:SetShown(true)
    panel.instanceBoss.texture:SetShown(Save.hideInstanceBossText)
    panel.instanceBoss.Text:SetShown(not Save.hideInstanceBossText)
end

local function set_EncounterJournal_Keystones_Tips(self)--险指南界面, 挑战
    e.tips:SetOwner(self, "ANCHOR_LEFT");
    e.tips:ClearLines();
    e.tips:AddDoubleLine(e.onlyChinese and '史诗钥石地下城' or CHALLENGES, e.Icon.left)
    for guid, info in pairs(WoWDate) do
        if guid and info then
            local find
            for itemLink, _ in pairs(info.Keystone.itemLink) do
                e.tips:AddLine(itemLink)
                find=true
            end
            if find then
                e.tips:AddLine(e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false}))
            end
        end
    end
    e.tips:Show()
end

local function set_EncounterJournal_Money_Tips(self)--险指南界面, 钱
    e.tips:SetOwner(self, "ANCHOR_LEFT");
    e.tips:ClearLines();
    local numPlayer, allMoney  = 0, 0
    for guid, info in pairs(WoWDate) do
        if info.Money then
            e.tips:AddDoubleLine(e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false}), GetCoinTextureString(info.Money))
            numPlayer=numPlayer+1
            allMoney= allMoney + info.Money
        end
    end
    if allMoney==0 then
        e.tips:AddDoubleLine(e.onlyChinese and '钱' or MONEY, e.onlyChinese and '无' or NONE)
    else
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '角色' or CHARACTER)..' '..numPlayer..' '..(e.onlyChinese and '总计：' or FROM_TOTAL)..e.MK(allMoney/10000, 3), GetCoinTextureString(allMoney))
    end
    e.tips:Show()
end












--############################
--BOSS战时, 指定拾取, 专精, 事件
--############################
local function set_Loot_Spec_Event()
    if Save.hideEncounterJournal then
        panel:UnregisterEvent('ENCOUNTER_START')
        panel:UnregisterEvent('ENCOUNTER_END')
    else
        panel:RegisterEvent('ENCOUNTER_START')
        panel:RegisterEvent('ENCOUNTER_END')
    end
end
--######
--初始化
--######
local function Init()--冒险指南界面
    EncounterJournal.btn= e.Cbtn(EncounterJournal.TitleContainer, {icn=not Save.hideEncounterJournal, size={22,22}})--按钮, 总开关
    EncounterJournal.btn:SetPoint('RIGHT',-22, -2)
    EncounterJournal.btn:SetScript('OnEnter',function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, e.GetEnabeleDisable(not Save.hideEncounterJournal))
        e.tips:AddDoubleLine(e.onlyChinese and '奖励' or QUEST_REWARDS, e.GetShowHide(not Save.hideEncounterJournal_All_Info_Text))
        e.tips:Show()
    end)
    EncounterJournal.btn:SetScript('OnMouseDown', function(self2, d)
        if d=='LeftButton' then
            Save.hideEncounterJournal= not Save.hideEncounterJournal and true or nil
            EncounterJournal.instance:SetShown(not Save.hideEncounterJournal)
            EncounterJournal.Worldboss:SetShown(not Save.hideEncounterJournal)
            if EncounterJournal.keystones then
                EncounterJournal.keystones:SetShown(not Save.hideEncounterJournal)
            end
            EncounterJournal.money:SetShown(not Save.hideEncounterJournal)
            EncounterJournal.btn:SetNormalAtlas(Save.hideEncounterJournal and e.Icon.disabled or e.Icon.icon )
            print(id, addName, e.GetShowHide(not Save.hideEncounterJournal), e.onlyChinese and '需要刷新' or NEED..REFRESH)
            set_Loot_Spec_Event()--BOSS战时, 指定拾取, 专精, 事件

        elseif d=='RightButton' then
            if Save.hideEncounterJournal_All_Info_Text then
                Save.hideEncounterJournal_All_Info_Text=nil
            else
                Save.hideEncounterJournal_All_Info_Text=true
            end
            EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据
        end
    end)
    EncounterJournal.btn:SetScript("OnLeave",function() e.tips:Hide() end)

    EncounterJournal.instance =e.Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--所有角色副本
    EncounterJournal.instance:SetPoint('RIGHT', EncounterJournal.btn, 'LEFT')
    EncounterJournal.instance:SetNormalAtlas('animachannel-icon-kyrian-map')
    EncounterJournal.instance:SetScript('OnEnter',function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine((e.onlyChinese and '副本' or INSTANCE)..e.Icon.left..e.GetShowHide(Save.showInstanceBoss), e.onlyChinese and '已击杀' or DUNGEON_ENCOUNTER_DEFEATED)
        e.tips:AddLine(' ')
        for guid, info in pairs(WoWDate) do
            if guid and info then
                local find
                for bossName, tab in pairs(info.Instance.ins) do----ins={[名字]={[难度]=已击杀数}}
                    local text
                    for difficultyName, killed in pairs(tab) do
                        text= (text and text..' ' or '')..difficultyName..killed
                    end
                    e.tips:AddDoubleLine(bossName, text)
                    find= true
                end
                if find then
                    e.tips:AddLine(e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false}))
                end
            end
        end
        e.tips:Show()
    end)--提示
    EncounterJournal.instance:SetScript('OnMouseDown', function()
            if  Save.showInstanceBoss then
                Save.showInstanceBoss=nil
            else
                Save.showInstanceBoss=true
                Save.hideInstanceBossText=nil
            end
            setInstanceBossText()
            if panel.instanceBoss then
                panel.instanceBoss:SetButtonState('PUSHED')
            end
    end)
    EncounterJournal.instance:SetScript("OnLeave",function() e.tips:Hide() end)

    EncounterJournal.Worldboss =e.Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--所有角色已击杀世界BOSS
    EncounterJournal.Worldboss:SetPoint('RIGHT', EncounterJournal.instance, 'LEFT')
    EncounterJournal.Worldboss:SetNormalAtlas('poi-soulspiritghost')
    EncounterJournal.Worldboss:SetScript('OnEnter',set_EncounterJournal_World_Tips)--提示
    EncounterJournal.Worldboss:SetScript('OnMouseDown', function(self2, d)
        if  Save.showWorldBoss then
            Save.showWorldBoss=nil
        else
            Save.showWorldBoss=true
            Save.hideWorldBossText=nil
        end
        setWorldbossText()
        if panel.WorldBoss then
            panel.WorldBoss:SetButtonState('PUSHED')
        end
    end)
    EncounterJournal.Worldboss:SetScript("OnLeave",function() e.tips:Hide() end)

    if e.Player.levelMax then
        EncounterJournal.keystones =e.Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--所有角色,挑战
        EncounterJournal.keystones:SetPoint('RIGHT', EncounterJournal.Worldboss, 'LEFT')
        EncounterJournal.keystones:SetNormalTexture(4352494)
        EncounterJournal.keystones:SetScript('OnEnter',set_EncounterJournal_Keystones_Tips)
        EncounterJournal.keystones:SetScript("OnLeave",function() e.tips:Hide() end)
        EncounterJournal.keystones:SetScript('OnMouseDown', function()
            PVEFrame_ToggleFrame('ChallengesFrame',3)
        end)
    end
    EncounterJournal.money =e.Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--钱
    EncounterJournal.money:SetPoint('RIGHT', EncounterJournal.keystones or EncounterJournal.Worldboss, 'LEFT')
    EncounterJournal.money:SetNormalAtlas('Front-Gold-Icon')
    EncounterJournal.money:SetScript('OnEnter',set_EncounterJournal_Money_Tips)
    EncounterJournal.money:SetScript("OnLeave",function() e.tips:Hide() end)

    EncounterJournal.money:SetShown(not Save.hideEncounterJournal)
    EncounterJournal.instance:SetShown(not Save.hideEncounterJournal)
    EncounterJournal.Worldboss:SetShown(not Save.hideEncounterJournal)
    if EncounterJournal.keystones then
        EncounterJournal.keystones:SetShown(not Save.hideEncounterJournal)
    end
    setWorldbossText()
    setInstanceBossText()

    --Blizzard_EncounterJournal.lua
    local function EncounterJournal_ListInstances_set_Instance(button,showTips)--界面,击杀,数据
        local text,find
        if button.instanceID==1205 or button.instanceID==1192 or button.instanceID==1028 or button.instanceID==822 or button.instanceID==557 or button.instanceID==322 then--世界BOSS
            if showTips then
                set_EncounterJournal_World_Tips(button)--角色世界BOSS提示
                find=true
            else
                for guid, info in pairs(WoWDate) do--世界BOSS
                    if guid==e.Player.guid then
                        local num=0
                        for bossName, _ in pairs(info.Worldboss.boss) do
                            text= text and text..' ' or ''
                            if num>0 and math.modf(num/3)==0 then
                                text=text..'\n'
                            end
                            text= text..'|cnGREEN_FONT_COLOR:'..num..')'..getBossNameSort(bossName)
                        end
                        break
                    end
                end
            end
        else
            local n=GetNumSavedInstances()
            for i=1, n do
                local name, _, reset, _, _, _, _, _, _, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i);
                if button.tooltipTitle==name and (not reset or reset>0) and numEncounters and encounterProgress and numEncounters>0 and encounterProgress>0 then
                    local num=encounterProgress..'/'..numEncounters..'|r'
                    num= encounterProgress==numEncounters and '|cnGREEN_FONT_COLOR:'..num..'|r' or num
                    if showTips then
                        if find then
                            e.tips:AddLine(' ')
                        end

                        e.tips:AddDoubleLine(name..'(|cnGREEN_FONT_COLOR:'..difficultyName..'|r): ',num);
                        local t;
                        for j=1,numEncounters do
                            local bossName,_,isKilled = GetSavedInstanceEncounterInfo(i,j);
                            local t2
                            t2= bossName;
                            if t then
                                t2=t2..' ('..j else t2=j..') '..t2
                            end;
                            if isKilled then t2='|cFFFF0000'..t2..'|r' end;
                            if j==numEncounters or t then
                                if not t then
                                    t=t2
                                    t2=nil
                                end;
                                e.tips:AddDoubleLine(t,t2);
                                t=nil;
                            else
                                t=t2;
                            end;
                        end;
                        find=true
                    else
                        text= text and text..'\n' or ''
                        difficultyName=difficultyName:gsub('%(', '')
                        difficultyName=difficultyName:gsub('%)', '')
                        difficultyName=difficultyName:gsub('（', ' ')
                        difficultyName=difficultyName:gsub('）', '')
                        text=text..difficultyName..' '..num
                    end
                end;
            end;
        end
        if not showTips then
            return text
        else
            return find
        end
    end
    hooksecurefunc('EncounterJournal_ListInstances', function()--界面, 副本击杀
        if Save.hideEncounterJournal then
            for _, button in pairs(EncounterJournal.instanceSelect.ScrollBox:GetFrames()) do
                if button and button.tipsText then
                    button.tipsText:SetText('')
                end
            end
            return
        end

        for _, button in pairs(EncounterJournal.instanceSelect.ScrollBox:GetFrames()) do--ScrollBox.lua
            if button and button.tooltipTitle and button.instanceID then--button.bgImage:GetTexture() button.name:GetText()
                local text=EncounterJournal_ListInstances_set_Instance(button)--界面,击杀,数据
                if not button.tipsText and text then
                    button.tipsText=e.Cstr(button, {size=e.onlyChinese and 12 or 10, copyFont=button.name})--10, button.name)
                    button.tipsText:SetPoint('BOTTOMRIGHT', -8, 8)
                    button.tipsText:SetJustifyH('RIGHT')
                end
                if button.tipsText then
                    button.tipsText:SetText(text or '')
                end

                local info= C_ChallengeMode.GetMapTable() or {}--挑战地图 mapChallengeModeID
                local currentChallengeMapID= C_MythicPlus.GetOwnedKeystoneChallengeMapID()--当前, KEY地图,ID
                local instanceName=button.name:GetText()
                button.mapChallengeModeID=nil
                local challengeText
                for _, mapChallengeModeID in pairs(info) do
                    local name=C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
                    if name==instanceName then
                        button.mapChallengeModeID= mapChallengeModeID--挑战,地图ID

                        local nu, all, leavel, runScore= 0, 0, 0, 0
                        local infoChalleng=C_MythicPlus.GetRunHistory(true, true) or {}--挑战,全部, 次数
                        for _,v in pairs(infoChalleng) do
                            if v.mapChallengeModeID==mapChallengeModeID then
                                if v.completed then
                                    nu=nu+1
                                end
                                all=all+1
                            end
                        end

                        local affix
                        local affixScores, overAllScore= C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapChallengeModeID)--最佳, 词缀
                        if(affixScores and #affixScores > 0) then
                            local nameA, _, filedataidA = C_ChallengeMode.GetAffixInfo(10)
                            local nameB, _, filedataidB = C_ChallengeMode.GetAffixInfo(9)
                            for _, tab in ipairs(affixScores) do
                                if tab.level and tab.level>0 and (tab.name == nameA or tab.name==nameB) then
                                    local level= tab.overTime and '|cnRED_FONT_COLOR:'..tab.level..'|r' or tab.level
                                    local icon='|T'..(tab.name == nameA and filedataidA or filedataidB)..':0|t'
                                    affix= (affix and affix..'\n' or '').. icon..level
                                end
                            end
                        end

                        runScore= overAllScore or 0--最佳, 分数
                        local intimeInfo= C_MythicPlus.GetSeasonBestForMap(mapChallengeModeID)--最佳, 等级
                        if intimeInfo then
                            leavel= intimeInfo.level
                        end
                        if all>0 then
                            challengeText= '|cff00ff00'..nu..'|r/'..all
                            ..'\n'..'|T4352494:0|t'..leavel
                            ..'\n'..'|A:AdventureMapIcon-MissionCombat:0:0|a'..runScore
                            ..(affix and '\n'..affix or '')
                            ..(currentChallengeMapID== mapChallengeModeID and '|A:auctionhouse-icon-favorite:0:0|a' or '')--当前, KEY地图,ID
                            local color= C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(runScore)
                            if color then
                                challengeText= color:WrapTextInColorCode(challengeText)
                            end
                        end
                        break
                    end
                end
                if challengeText and not button.challengeText then
                    button.challengeText= e.Cstr(button, {size=e.onlyChinese and 12 or 10})
                    button.challengeText:SetPoint('LEFT',4,0)
                end
                if button.challengeText then
                    button.challengeText:SetText(challengeText or '')
                end

                button:SetScript('OnEnter', function (self3)
                    if Save.hideEncounterJournal then
                        return
                    end
                    e.tips:SetOwner(self3, "ANCHOR_RIGHT");
                    e.tips:ClearLines();
                    local texture=self3.bgImage:GetTexture()
                    e.tips:AddLine(self3.name:GetText())
                    e.tips:AddDoubleLine('journalInstanceID: |cnGREEN_FONT_COLOR:'..self3.instanceID, texture and '|T'..texture..':0|t'..texture)
                    if self3.mapChallengeModeID then
                        e.tips:AddLine('mapChallengeModeID: |cnGREEN_FONT_COLOR:'.. self3.mapChallengeModeID)
                    end
                    e.tips:AddLine(' ')
                    if EncounterJournal_ListInstances_set_Instance(self3, true) then--界面,击杀,数据
                        e.tips:AddLine(' ')
                    end
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:Show()
                end)
                button:SetScript('OnLeave', function() e.tips:Hide() end)
            end
       end
    end)

    --Boss, 战利品, 信息
    hooksecurefunc(EncounterJournalItemMixin,'Init',function(self, elementData)--Blizzard_EncounterJournal.lua
        local text, collectText='', nil
        if not Save.hideEncounterJournal and self.link and self.itemID and self.slot then
            local specTable = GetItemSpecInfo(self.link) or {}--专精图标
            local specTableNum=#specTable
            if specTableNum>0 then
                local specA=''
                local class
                table.sort(specTable, function (a2, b2) return a2<b2 end)
                collectText= e.onlyChinese and '拾取专精' or format(PROFESSIONS_SPECIALIZATION_TITLE, UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LOOT )
                for _,  specID in pairs(specTable) do
                    local _, name,_, icon2, _, classFile= GetSpecializationInfoByID(specID)
                    if icon2 and classFile then
                        icon2='|T'..icon2..':0|t'
                        specA = specA..((class and class~=classFile) and '  ' or '')..icon2
                        class=classFile
                        collectText= collectText..'\n'..icon2..name
                    end
                end
                if specA~='' then
                    text= text..specA
                end
            end

            local item, collected = e.GetItemCollected(self.link, nil, true)--物品是否收集, 返回图标, 幻化
            if item and not collected then
                text= text..item
                collectText= collectText and collectText..'\n\n' or ''
                collectText= collectText..item..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
            else
                local mountID = C_MountJournal.GetMountFromItem(self.itemID)--坐骑物品
                local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(self.itemID))--宠物物品
                local str= speciesID and select(3, e.GetPetCollectedNum(speciesID)) or mountID and e.GetMountCollected(mountID)--宠物, 收集数量
                if str then
                    text= text and '' or '   '
                    text= text..str
                end
            end
        end
        if text and not self.collectedText and self.slot then
            self.collectedText= e.Cstr(self)--nil,nil,nil,nil,nil,'CENTER')
            self.collectedText:SetPoint('LEFT', self.slot, 'CENTER', 5, 0)
            self.collectedText:EnableMouse(true)
            self.collectedText:SetScript('OnEnter', function(self2)
                if self2.collectText then
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddLine(self2.collectText)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:Show()
                end
            end)
            self.collectedText:SetScript('OnLeave', function() e.tips:Hide() end)
        end
        if self.collectedText then
            self.collectedText:SetText(text)
            self.collectedText.collectText= collectText
            --self.collectedText:SetShown(text and true or false)
        end

        e.Set_Item_Stats(self, self.link, {point= self.icon, itemID= self.itemID})--显示, 物品, 属性
    end)

    --#######################
    --BOSS战时, 指定拾取, 专精
    --#######################
    local function set_Loot_Spec_Texture(self)
        local specID=self.dungeonEncounterID and Save.loot[e.Player.class][self.dungeonEncounterID]
        local icon= specID and select(4, GetSpecializationInfoByID(specID))
        if icon then
            self:SetNormalTexture(icon)
        else
            self:SetNormalAtlas(e.Icon.icon)
        end
        self:SetAlpha(icon and 1 or 0.3)
    end
    local function set_Loot_Spec_Menu_Init(self, level, type)
        local info
        if type=='CLEAR' then
            for class= 1, GetNumClasses() do
                local classInfo = C_CreatureInfo.GetClassInfo(class)
                if classInfo and classInfo.classFile then
                    Save.loot[classInfo.classFile]= Save.loot[classInfo.classFile] or {}
                    local n=0
                    for _, _ in pairs(Save.loot[classInfo.classFile]) do
                        n= n+1
                    end
                    local col= select(4, GetClassColor(classInfo.classFile))
                    col= col and '|c'..col or col
                    info={
                        text= (e.Class(nil, classInfo.classFile) or '')..classInfo.className..(e.Player.class==classInfo.classFile and e.Icon.star2 or '')..(n>0 and ' |cnGREEN_FONT_COLOR:#'..n..'|r' or ''),
                        colorCode= col,
                        notCheckable=true,
                        arg1= classInfo.classFile,
                        arg2= classInfo.className,
                        hasArrow= n>0,
                        menuList= classInfo.classFile,
                        func= function(_, arg1, arg2)
                            Save.loot[arg1]={}
                            print(id, addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.Class(nil, arg1), arg2, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要刷新' or NEED..REFRESH))
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end
            end
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            info={
                text= e.onlyChinese and '全部清除' or CLEAR_ALL,
                icon='bags-button-autosort-up',
                notCheckable=true,
                func= function()
                    Save.loot={[e.Player.class]={}}
                    print(id, addName, e.onlyChinese and '全部清除' or CLEAR_ALL, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要刷新' or NEED..REFRESH))
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            return
        elseif type then
            local col= select(4, GetClassColor(type))
            col= col and '|c'..col or col
            for dungeonEncounterID, specID in pairs(Save.loot[type]) do
                info={
                    text='dungeonEncounterID |cnGREEN_FONT_COLOR:'..dungeonEncounterID..'|r',
                    icon= select(4,  GetSpecializationInfoByID(specID)),
                    colorCode= col,
                    notCheckable= true,
                    arg1=type,
                    arg2=dungeonEncounterID,
                    func= function(_, arg1, arg2)
                        Save.loot[arg1][arg2]=nil
                        print(id, addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.Class(nil, arg1), arg2, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要刷新' or NEED..REFRESH))
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
            return
        end

        local curSpec= GetSpecialization()
        local find
        for specIndex= 1, GetNumSpecializations() do
            local specID, name, _ , icon= GetSpecializationInfo(specIndex)
            if icon and specID and name then
                info= {
                    text=name..(curSpec==specIndex and e.Icon.star2 or ''),
                    colorCode= e.Player.col,
                    icon=icon,
                    checked= Save.loot[e.Player.class][self.dungeonEncounterID]== specID,
                    tooltipOnButton=true,
                    tooltipTitle= self.encounterID and EJ_GetEncounterInfo(self.encounterID) or '',
                    tooltipText= 'specID '..specID..'\n'..(self.dungeonEncounterID and 'dungeonEncounterID '..self.dungeonEncounterID or ''),
                    arg1= {
                        dungeonEncounterID=self.dungeonEncounterID,
                        specID= specID,
                        button=self.button},
                    func=function(_,arg1)
                        if not Save.loot[e.Player.class][arg1.dungeonEncounterID] or Save.loot[e.Player.class][arg1.dungeonEncounterID]~= arg1.specID then
                            Save.loot[e.Player.class][arg1.dungeonEncounterID]=arg1.specID
                        else
                            Save.loot[e.Player.class][arg1.dungeonEncounterID]=nil
                        end
                        set_Loot_Spec_Texture(arg1.button)
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                find=true
            end
        end
        if find then
            info= {
                text= e.onlyChinese and '无' or NONE,
                icon= 'xmarksthespot',
                checked= not Save.loot[e.Player.class][self.dungeonEncounterID],
                arg1= self.dungeonEncounterID,
                arg2= self.button,
                func=function(_,arg1, arg2)
                    Save.loot[e.Player.class][arg1]=nil
                    set_Loot_Spec_Texture(arg2)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        local name=self.encounterID and EJ_GetEncounterInfo(self.encounterID)
        if name and self.dungeonEncounterID then
            info= {
                text= name..' '..self.dungeonEncounterID,
                notCheckable=true,
                isTitle=true,
            }
        end
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
            notCheckable=true,
            hasArrow=true,
            menuList='CLEAR',
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        --e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION,
            icon= e.Class('player', e.Player.class, true) or  'Banker',
            isTitle=true,
            notCheckable=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text=id..' '..addName,
            isTitle=true,
            notCheckable=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    local function set_Loot_Spec(button)
        if not button.LootButton then
            button.LootButton= e.Cbtn(button, {size={20,20}, icon='hide'})
            button.LootButton:SetPoint('LEFT', button, 'RIGHT')
            button.LootButton:SetNormalAtlas(e.Icon.icon)
            button.LootButton:SetScript('OnClick', function(self)
                local menu= EncounterJournal.encounter.LootSpecMenu
                if not menu then
                    menu=CreateFrame("Frame", id..addName..'Menu', EncounterJournal.encounter, "UIDropDownMenuTemplate")
                    e.LibDD:UIDropDownMenu_Initialize(menu, set_Loot_Spec_Menu_Init, 'MENU')
                end
                menu.dungeonEncounterID=self.dungeonEncounterID
                menu.button=self
                menu.encounterID= self.encounterID
                e.LibDD:ToggleDropDownMenu(1, nil, menu, self, 15,0)
            end)
        end
        local dungeonEncounterID= button.encounterID and select(7, EJ_GetEncounterInfo(button.encounterID))
        button.LootButton.dungeonEncounterID= dungeonEncounterID
        button.LootButton.encounterID= button.encounterID
        set_Loot_Spec_Texture(button.LootButton)
        button.LootButton:SetShown(not Save.hideEncounterJournal)
    end


    EncounterJournal.encounter.instance.mapButton:SetScript('OnEnter', function(self3)--综述,小地图提示
        local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, _, mapID= EJ_GetInstanceInfo()
        if not name then return end
        e.tips:SetOwner(self3, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(link or name, (dungeonAreaMapID and 'UiMapID|cnGREEN_FONT_COLOR:'..dungeonAreaMapID..'|r' or '')..(mapID and ' mapID|cnGREEN_FONT_COLOR:'..mapID..'|r' or ''))
        e.tips:AddLine(' ')
        e.tips:AddLine(description, nil,nil,nil, true)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(bgImage and '|T'..bgImage..':26|t'..bgImage, loreImage and '|T'..loreImage..':26|t'..loreImage)
        e.tips:AddDoubleLine(buttonImage1 and '|T'..buttonImage1..':26|t'..buttonImage1, buttonImage2 and '|T'..buttonImage2..':26|t'..buttonImage2)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
    EncounterJournal.encounter.instance.mapButton:SetScript('OnLeave', function() e.tips:Hide() end)


    hooksecurefunc(EncounterJournal.encounter.info.BossesScrollBox, 'SetScrollTargetOffset', function(self2)
        for _, button in pairs(self2:GetFrames()) do
            if not button.OnEnter then
                button:SetScript('OnEnter', function(self3)
                    if not Save.hideEncounterJournal and self3.encounterID then
                        local name2, _, journalEncounterID, rootSectionID, _, journalInstanceID, dungeonEncounterID, instanceID2= EJ_GetEncounterInfo(self3.encounterID)--button.index= button.GetOrderIndex()
                        e.tips:SetOwner(self3, "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine(name2,  'journalEncounterID: '..'|cnGREEN_FONT_COLOR:'..(journalEncounterID or self3.encounterID)..'|r')
                        e.tips:AddDoubleLine(instanceID2 and 'instanceID: '..instanceID2, (rootSectionID and rootSectionID>0) and 'JournalEncounterSectionID: '..rootSectionID or ' ')
                        if dungeonEncounterID then
                            e.tips:AddDoubleLine('dungeonEncounterID: |cffff00ff'..dungeonEncounterID, (journalInstanceID and journalInstanceID>0) and 'journalInstanceID: '..journalInstanceID or ' ' )
                            local numKill=Save.wowBossKill[dungeonEncounterID]
                            if numKill then
                                e.tips:AddDoubleLine(e.onlyChinese and '击杀' or KILLS, '|cnGREEN_FONT_COLOR:'..numKill..' |r'..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
                            end
                        end
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:Show()
                    end
                end)
                button:SetScript('OnLeave', function() e.tips:Hide() end)
            end
            set_Loot_Spec(button)--BOSS战时, 指定拾取, 专精
        end
    end)


    --战利品, 套装, 收集数 Blizzard_LootJournalItems.lua
    if EncounterJournal.LootJournalItems.ItemSetsFrame and EncounterJournal.LootJournalItems.ItemSetsFrame.ScrollBox and EncounterJournal.LootJournalItems.ItemSetsFrame.ScrollBox.Update then
        hooksecurefunc(EncounterJournal.LootJournalItems.ItemSetsFrame.ScrollBox, 'Update', function(self)
            for _, frame in pairs(self:GetFrames()) do
                local ItemButtons=frame.ItemButtons or {}
                for _, itemButton in pairs(ItemButtons) do
                    local itemID= not Save.hideEncounterJournal and itemButton and itemButton.itemID
                    local has =itemID and C_TransmogCollection.PlayerHasTransmogByItemInfo(itemID)
                    if has and not itemButton.collection then
                        itemButton.collection= itemButton:CreateTexture()
                        itemButton.collection:SetSize(16,16)
                        itemButton.collection:SetPoint('BOTTOMRIGHT', 2, -2)
                        itemButton.collection:SetAtlas(e.Icon.select)
                    end
                    if itemButton.collection then
                        itemButton.collection:SetShown(has)
                    end
                end
            end
        end)
    end

    --[[hooksecurefunc(EncounterJournal.LootJournalItems.ItemSetsFrame,'ConfigureItemButton', function(self2, button)--Blizzard_LootJournalItems.lua
        local has = C_TransmogCollection.PlayerHasTransmogByItemInfo(button.itemID)
        print(has, id, addName)
        if has==false and not button.tex and not Save.hideEncounterJournal then
            button.tex=button:CreateTexture()
            button.tex:SetSize(16,16)
            button.tex:SetPoint('BOTTOMRIGHT',2,-2)
            button.tex:SetAtlas(e.Icon.transmogHide)
        end
        if button.tex then
            button.tex:SetShown(has==false and not Save.hideEncounterJournal)
        end
    end)]]

    --[[战利品, 套装 , 收集数量
    local function lootSet(self2)
        if Save.hideEncounterJournal then
            return
        end
        local buttons = self2.buttons;
        local offset = HybridScrollFrame_GetOffset(self2)
        if self2.buttons then
            for i = 1, #buttons do
                local button= buttons[i];
                local index = offset + i;
                if ( index <= #self2.itemSets ) then
                    local setID=self2.itemSets[index].setID
                    local collected= e.GetSetsCollectedNum(setID)--收集数量
                    if collected and self2.itemSets[index].name then
                        button.SetName:SetText(self2.itemSets[index].name..collected)
                    end
                end
            end
        end
    end
    hooksecurefunc(EncounterJournal.LootJournalItems.ItemSetsFrame, 'UpdateList', lootSet);
    hooksecurefunc('HybridScrollFrame_Update', function(self2)
        if EncounterJournal and self2==EncounterJournal.LootJournalItems.ItemSetsFrame then
            lootSet(self2)
        end
    end)
]]
    --BOSS技能 Blizzard_EncounterJournal.lua
    local function EncounterJournal_SetBullets_setLink(text)--技能加图标
        local find
        text=text:gsub('|Hspell:.-]|h',function(link)
            local t=link
            local icon= select(3, GetSpellInfo(link)) or GetSpellTexture(link:match('Hspell:(%d+)'))
            if icon then
                find=true
                return '|T'..icon..':0|t'..link
            end
        end)
        if find then
            return text
        end
    end
    hooksecurefunc('EncounterJournal_SetBullets', function(object, description, hideBullets)
        if Save.hideEncounterJournal then
            return
        end
        if not string.find(description, "%$bullet;") then
            local text=EncounterJournal_SetBullets_setLink(description)
            if text then
                object.Text:SetText(text)
                object:SetHeight(object.Text:GetContentHeight());
            end
            return
        end
        local desc = strtrim(string.match(description, "(.-)%$bullet;"))
        if (desc) then
            local text=EncounterJournal_SetBullets_setLink(desc)
            if text then
                object.Text:SetText(text)
                object:SetHeight(object.Text:GetContentHeight());
            end
        end

        local bullets = {}
        local k = 1;
        local parent = object:GetParent();
        for v in string.gmatch(description,"%$bullet;([^$]+)") do
            tinsert(bullets, v);
        end
        for j = 1,#bullets do
            local text = strtrim(bullets[j]).."|n|n";
            if (text and text ~= "") then
                text=EncounterJournal_SetBullets_setLink(text)
			    local bullet = parent.Bullets and parent.Bullets[k];
                if text and bullet then
                    bullet.Text:SetText(text);
                    if (bullet.Text:GetContentHeight() ~= 0) then
                        bullet:SetHeight(bullet.Text:GetContentHeight());
                    end
                end
                k = k + 1;
            end
        end
    end)

    hooksecurefunc('EncounterJournal_UpdateButtonState', function(self2)--技能提示
        if not self2.OnEnter then
            self2:SetScript("OnEnter", function(self3)
                local spellID= self3:GetParent().spellID--self3.link
                if Save.hideEncounterJournal or not spellID or spellID==0 then
                    return
                end
                e.tips:SetOwner(self3, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(spellID)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end)
            self2:SetScript('OnLeave', function() e.tips:Hide() end)
        end
    end)

    --BOSS模型 Blizzard_EncounterJournal.lua
    hooksecurefunc('EncounterJournal_DisplayCreature', function(self, forceUpdate)
        local text
        if not Save.hideEncounterJournal and self.displayInfo and EncounterJournal.encounter and EncounterJournal.encounter.info and EncounterJournal.encounter.info.model and EncounterJournal.encounter.info.model.imageTitle then
            if not EncounterJournal.creatureDisplayIDText then
                EncounterJournal.creatureDisplayIDText=e.Cstr(self,{size=10, fontType=EncounterJournal.encounter.info.model.imageTitle})--10, EncounterJournal.encounter.info.model.imageTitle)
                EncounterJournal.creatureDisplayIDText:SetPoint('BOTTOM', EncounterJournal.encounter.info.model.imageTitle, 'TOP', 0 , 10)
            end
            if EncounterJournal.iconImage  then
                text= (text or '')..'|T'..EncounterJournal.iconImage..':0|t'..EncounterJournal.iconImage..'\n'
            end
            if self.id then
                text= (text or '')..'JournalEncounterCreatureID '.. self.id..'\n'
            end
            if self.uiModelSceneID  then
                text= (text or '')..'uiModelSceneID '..self.uiModelSceneID..'\n'
            end
            text= (text or '')..'CreatureDisplayID ' .. self.displayInfo
        end
        if EncounterJournal.creatureDisplayIDText then
            EncounterJournal.creatureDisplayIDText:SetText(text or '')
        end
    end)
end

--###########
--加载保存数据
--###########
local lootSpceLog--BOSS战时, 指定拾取, 专精, 还原, 专精拾取
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.loot= Save.loot or {}
            Save.loot[e.Player.class]= Save.loot[e.Player.class] or {}
            --添加控制面板        
            local sel=e.CPanel('|A:UI-HUD-MicroMenu-AdventureGuide-Mouseover:0:0|a'..(e.onlyChinese and '冒险指南' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                if not Save.hideEncounterJournal then
                    set_Loot_Spec_Event()--BOSS战时, 指定拾取, 专精, 事件
                end
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_EncounterJournal' then---冒险指南
            if not Save.disabled then
                Init()--冒险指南界面
                EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据
                panel:RegisterEvent('BOSS_KILL')
                panel:RegisterEvent('UPDATE_INSTANCE_INFO')
                panel:RegisterEvent('PLAYER_ENTERING_WORLD')
                panel:RegisterEvent('WEEKLY_REWARDS_UPDATE')
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='UPDATE_INSTANCE_INFO' then
        C_Timer.After(2, function()
            setInstanceBossText()--显示副本击杀数据
            setWorldbossText()--显示世界BOSS击杀数据Text
            EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据
        end)

    elseif event=='BOSS_KILL' and arg1 then
        Save.wowBossKill[arg1]= Save.wowBossKill[arg1] and Save.wowBossKill[arg1] +1 or 1--Boss击杀数量

    elseif event=='WEEKLY_REWARDS_UPDATE' then
        C_Timer.After(2, function()
            EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据
        end)

    elseif event=='ENCOUNTER_START' and arg1 then--BOSS战时, 指定拾取, 专精
        local indicatoSpec=Save.loot[e.Player.class][arg1]
        if indicatoSpec then
            local loot = GetLootSpecialization()
            local spec = GetSpecialization()
            spec= spec and GetSpecializationInfo(spec)
            local loot2= loot==0 and spec or loot
            if loot2~= indicatoSpec then
                lootSpceLog= loot
                SetLootSpecialization(indicatoSpec)
                local _, name, _, icon, role = GetSpecializationInfoByID(indicatoSpec)
                print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)..'|r', e.Icon[role], icon and '|T'..icon..':0|t', name and '|cffff00ff'..name)
            end
        end

    elseif event=='ENCOUNTER_END' then--BOSS战时, 指定拾取, 专精, 还原, 专精拾取
        if lootSpceLog  then
            SetLootSpecialization(lootSpceLog)
            if lootSpceLog==0 then
                local spec = GetSpecialization()
                lootSpceLog= spec and GetSpecializationInfo(spec) or lootSpceLog
            end
            local _, name, _, icon, role = GetSpecializationInfoByID(lootSpceLog)
            print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)..'|r', e.Icon[role], icon and '|T'..icon..':0|t', name and '|cffff00ff'..name)
            lootSpceLog=nil
        end
    end
end)