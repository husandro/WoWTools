local id, e = ...
local addName= ADVENTURE_JOURNAL
local Save={wowBossKill={}}
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

    local tab=e.WoWSave[e.Player.guid].Instance.ins
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
    tab=e.WoWSave[e.Player.guid].Worldboss.boss
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

    tab=e.WoWSave[e.Player.guid].Rare.boss--稀有怪
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
            if he==MYTHIC_DUNGEONS then
                local weekLevel=e.WoWSave[e.Player.guid].Keystones.weekLevel--本周最高
                if weekLevel then
                    text=text..' |cnGREEN_FONT_COLOR:'..weekLevel..'|r'
                end
            end
            for x,r in pairs(v) do
                text = text~='' and text..'\n' or text
                text = text..'     '
                if r.unlocked then
                    text = text..'|cnGREEN_FONT_COLOR:'..x..')'..r.difficulty.. ' '..'|cnGREEN_FONT_COLOR:'..COMPLETE..'|r'
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
            local max=info.maxQuantity
            local totalEarned=info.totalEarned
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
    for guid, info in pairs(e.WoWSave) do
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
            e.tips:AddDoubleLine(e.GetPlayerInfo(nil, guid,true), guid==e.Player.guid and e.Icon.star2)
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
    self:SetScript('OnLeave', function() e.tips:Hide() end)
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
        e.Cstr(nil, size, nil, self2.Text)
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
        panel.WorldBoss=e.Cbtn(UIParent, nil, not Save.hideWorldBossText, nil,nil,true)
        if Save.WorldBossPoint then
            panel.WorldBoss:SetPoint(Save.WorldBossPoint[1], UIParent, Save.WorldBossPoint[3], Save.WorldBossPoint[4], Save.WorldBossPoint[5])
        else
            if IsAddOnLoaded('Blizzard_EncounterJournal') then
                panel.WorldBoss:SetPoint('BOTTOMRIGHT',EncounterJournal, 'TOPRIGHT', -65,5)
            else
                panel.WorldBoss:SetPoint('CENTER')
            end
        end

        panel.WorldBoss:SetSize(14,14)
        panel.WorldBoss:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT");
            e.tips:ClearLines();
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddDoubleLine(e.onlyChinse and '冒险指南' or ADVENTURE_JOURNAL, e.onlyChinse and '世界BOSS和稀有怪' or (CHANNEL_CATEGORY_WORLD..'BOSS/'..GARRISON_MISSION_RARE))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.GetShowHide(not Save.hideWorldBossText), e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinse and '移动' or  NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine(e.onlyChinse and '大小' or FONT_SIZE, (Save.EncounterJournalFontSize or 12)..e.Icon.mid)
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

        panel.WorldBoss.Text=e.Cstr(panel.WorldBoss, Save.EncounterJournalFontSize, nil,nil,true)
        panel.WorldBoss.Text:SetPoint('TOPLEFT')

        panel.WorldBoss.texture=panel.WorldBoss:CreateTexture()
        panel.WorldBoss.texture:SetAllPoints(panel.WorldBoss)
        panel.WorldBoss.texture:SetAtlas(e.Icon.disabled)
        panel.WorldBoss.texture:SetShown(Save.hideWorldBossText)
    end

    local msg
    if not Save.hideWorldBossText then
        for guid, info in pairs(e.WoWSave) do
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
                msg= msg..'\n'..e.GetPlayerInfo(nil, guid, true)..(guid==e.Player.guid and e.Icon.star2 or '')
            end
        end
        msg= msg or '...'
    end
    panel.WorldBoss.Text:SetText(msg or '')
    panel.WorldBoss:SetShown(true)
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
        panel.instanceBoss=e.Cbtn(UIParent, nil, not Save.hideInstanceBossText, nil,nil,true)
        if Save.instanceBossPoint then
            panel.instanceBoss:SetPoint(Save.instanceBossPoint[1], UIParent, Save.instanceBossPoint[3], Save.instanceBossPoint[4], Save.instanceBossPoint[5])
        else
            if EncounterJournal then
                panel.instanceBoss:SetPoint('BOTTOMRIGHT',EncounterJournal, 'TOPRIGHT', -45,20)
            else
                panel.instanceBoss:SetPoint('CENTER')
            end
        end
        panel.instanceBoss:SetSize(14,14)
        panel.instanceBoss:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT");
            e.tips:ClearLines();
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddDoubleLine(e.onlyChinse and '冒险指南' or ADVENTURE_JOURNAL, e.onlyChinse and '副本' or INSTANCE)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.GetShowHide(not Save.hideInstanceBossText), e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine(e.onlyChinse and '大小' or FONT_SIZE, (Save.EncounterJournalFontSize or 12)..e.Icon.mid)
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
        panel.instanceBoss.Text=e.Cstr(panel.instanceBoss, Save.EncounterJournalFontSize, nil, nil, true)
        panel.instanceBoss.Text:SetPoint('TOPLEFT')

        panel.instanceBoss.texture=panel.instanceBoss:CreateTexture()
        panel.instanceBoss.texture:SetAllPoints(panel.instanceBoss)
        panel.instanceBoss.texture:SetAtlas(e.Icon.disabled)
        panel.instanceBoss.texture:SetShown(Save.hideInstanceBossText)
    end

    local msg
    if not Save.hideInstanceBossText then
        for guid, info in pairs(e.WoWSave) do
            local text
            for bossName, tab in pairs(info.Instance.ins) do--ins={[名字]={[难度]=已击杀数}}
                text= text and text..'\n   '..bossName or '   '..bossName
                for difficultyName, killed in pairs(tab) do
                    text= text..' '..difficultyName..' '..killed
                end
            end
            if text then
                msg=msg and msg..'\n' or ''
                msg= msg ..e.GetPlayerInfo(nil, guid, true)..(guid==e.Player.guid and e.Icon.star2 or '')..'\n'
                msg= msg.. text
            end
        end
        msg=msg or '...'
    end
    panel.instanceBoss.Text:SetText(msg or '')
    panel.instanceBoss:SetShown(true)
end

local function set_EncounterJournal_Keystones_Tips(self)--险指南界面, 挑战
    e.tips:SetOwner(self, "ANCHOR_LEFT");
    e.tips:ClearLines();
    e.tips:AddDoubleLine(e.onlyChinse and '史诗钥石地下城' or CHALLENGES, e.Icon.left)
    for guid, info in pairs(e.WoWSave) do
        local find
        for itemLink, _ in pairs(info.Keystone.itemLink) do
            e.tips:AddLine(itemLink)
            find=true
        end
        if find then
            e.tips:AddDoubleLine(e.GetPlayerInfo(nil, guid, true), guid==e.Player.guid and e.Icon.star2)
        end
    end
    e.tips:Show()
end

local function set_EncounterJournal_Money_Tips(self)--险指南界面, 钱
    e.tips:SetOwner(self, "ANCHOR_LEFT");
    e.tips:ClearLines();
    local numPlayer, allMoney  = 0, 0
    for guid, info in pairs(e.WoWSave) do
        if info.Money then
            e.tips:AddDoubleLine(e.GetPlayerInfo(nil, guid, true)..(guid==e.Player.guid and e.Icon.star2 or ''), GetCoinTextureString(info.Money))
            numPlayer=numPlayer+1
            allMoney= allMoney + info.Money
        end
    end
    if allMoney==0 then
        e.tips:AddDoubleLine(e.onlyChinse and '钱' or MONEY, e.onlyChinse and '无' or NONE)
    else
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinse and '角色' or CHARACTER)..' '..numPlayer..' '..(e.onlyChinse and '总计：' or FROM_TOTAL)..e.MK(allMoney/10000, 3), GetCoinTextureString(allMoney))
    end
    e.tips:Show()
end

--######
--初始化
--######
local function Init()--冒险指南界面
    EncounterJournal.btn= e.Cbtn(EncounterJournal.TitleContainer, nil, not Save.hideEncounterJournal)--按钮, 总开关
    EncounterJournal.btn:SetPoint('RIGHT',-22, -2)
    EncounterJournal.btn:SetSize(22, 22)
    EncounterJournal.btn:SetScript('OnEnter',function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.onlyChinse and '冒险指南' or ADVENTURE_JOURNAL, e.GetEnabeleDisable(not Save.hideEncounterJournal))
        e.tips:AddDoubleLine(e.onlyChinse and '奖励' or QUEST_REWARDS, e.GetShowHide(not Save.hideEncounterJournal_All_Info_Text))
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
            print(id, addName, e.GetShowHide(not Save.hideEncounterJournal), e.onlyChinse and '需要刷新' or NEED..REFRESH)
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

    EncounterJournal.instance =e.Cbtn(EncounterJournal.TitleContainer, nil ,true)--所有角色副本
    EncounterJournal.instance:SetPoint('RIGHT', EncounterJournal.btn, 'LEFT')
    EncounterJournal.instance:SetNormalAtlas('animachannel-icon-kyrian-map')
    EncounterJournal.instance:SetSize(22,22)
    EncounterJournal.instance:SetScript('OnEnter',function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine((e.onlyChinse and '副本' or INSTANCE)..e.Icon.left..e.GetShowHide(Save.showInstanceBoss), e.onlyChinse and '已击杀' or DUNGEON_ENCOUNTER_DEFEATED)
        e.tips:AddLine(' ')
        for guid, info in pairs(e.WoWSave) do
            local find
            for bossName, tab in pairs(info.Instance.ins) do----ins={[名字]={[难度]=已击杀数}}
                local text
                for difficultyName, killed in pairs(tab) do
                    text= (text and text..' ' or '')..difficultyName..killed
                end
                e.tips:AddDoubleLine(bossName,text)
                find= true
            end
            if find then
                e.tips:AddDoubleLine(e.GetPlayerInfo(nil, guid, true), guid==e.Player.guid and e.Icon.star2)
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
    end)
    EncounterJournal.instance:SetScript("OnLeave",function() e.tips:Hide() end)

    EncounterJournal.Worldboss =e.Cbtn(EncounterJournal.TitleContainer, nil ,true)--所有角色已击杀世界BOSS
    EncounterJournal.Worldboss:SetPoint('RIGHT', EncounterJournal.instance, 'LEFT')
    EncounterJournal.Worldboss:SetNormalAtlas('poi-soulspiritghost')
    EncounterJournal.Worldboss:SetSize(22,22)
    EncounterJournal.Worldboss:SetScript('OnEnter',set_EncounterJournal_World_Tips)--提示
    EncounterJournal.Worldboss:SetScript('OnMouseDown', function(self2, d)
        if  Save.showWorldBoss then
            Save.showWorldBoss=nil
        else
            Save.showWorldBoss=true
            Save.hideWorldBossText=nil
        end
        setWorldbossText()
    end)
    EncounterJournal.Worldboss:SetScript("OnLeave",function() e.tips:Hide() end)

    if e.Player.levelMax then--UnitLevel("player") >= GetMaxLevelForPlayerExpansion()
        EncounterJournal.keystones =e.Cbtn(EncounterJournal.TitleContainer, nil ,true)--所有角色,挑战
        EncounterJournal.keystones:SetPoint('RIGHT', EncounterJournal.Worldboss, 'LEFT')
        EncounterJournal.keystones:SetNormalTexture(4352494)
        EncounterJournal.keystones:SetSize(22,22)
        EncounterJournal.keystones:SetScript('OnEnter',set_EncounterJournal_Keystones_Tips)
        EncounterJournal.keystones:SetScript("OnLeave",function() e.tips:Hide() end)
        EncounterJournal.keystones:SetScript('OnMouseDown', function()
            PVEFrame_ToggleFrame('ChallengesFrame',3)
        end)
    end
    EncounterJournal.money =e.Cbtn(EncounterJournal.TitleContainer, nil ,true)--钱
    EncounterJournal.money:SetPoint('RIGHT', EncounterJournal.keystones or EncounterJournal.Worldboss, 'LEFT')
    EncounterJournal.money:SetNormalAtlas('Front-Gold-Icon')
    EncounterJournal.money:SetSize(22,22)
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
    local function EncounterJournal_ListInstances_set_Instance(button,showTips)--界面,
        local text,find
        if button.instanceID==1205 or button.instanceID==1192 or button.instanceID==1028 or button.instanceID==822 or button.instanceID==557 or button.instanceID==322 then--世界BOSS
            if showTips then
                set_EncounterJournal_World_Tips(button)--角色世界BOSS提示
                find=true
            else
                for guid, info in pairs(e.WoWSave) do--世界BOSS
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
                local text=EncounterJournal_ListInstances_set_Instance(button)
                if not button.tipsText and text then
                    button.tipsText=e.Cstr(button,14, button.name)
                    button.tipsText:SetPoint('BOTTOMRIGHT', -8, 8)
                    button.tipsText:SetWidth(174)
                    button.tipsText:SetJustifyH('RIGHT')
                    button.tipsText:SetWordWrap(true)
                end
                if button.tipsText then
                    button.tipsText:SetText(text or '')
                end

                button:SetScript('OnEnter', function (self3)
                    if Save.hideEncounterJournal then
                        return
                    end
                    e.tips:SetOwner(self3, "ANCHOR_LEFT");
                    e.tips:ClearLines();
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:AddLine(' ')
                    if EncounterJournal_ListInstances_set_Instance(button,true) then
                        e.tips:AddLine(' ')
                    end
                    local texture=button.bgImage:GetTexture()
                    e.tips:AddDoubleLine('journalInstanceID: '..button.instanceID, texture and '|T'..texture..':0|t'..texture)
                    e.tips:Show()
                end)
                button:SetScript('OnLeave', function() e.tips:Hide() end)
            end
       end
    end)

    --Boss, 战利品, 信息
    hooksecurefunc(EncounterJournalItemMixin,'Init',function(self2, elementData)--Blizzard_EncounterJournal.lua
        if Save.hideEncounterJournal or not self2.link or not self2.itemID then
            return
        end
        if self2.name then--幻化
            local text, collected = e.GetItemCollected(self2.link, nil, true)--物品是否收集, 返回图标
            if text then
                if not collected then
                    self2.name:SetText(self2.name:GetText()..text)
                end
            else
                local mountID = C_MountJournal.GetMountFromItem(self2.itemID)--坐骑物品
                local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(self2.itemID))--宠物物品
                text=speciesID and e.GetPetCollected(speciesID) or mountID and e.GetMountCollected(mountID)--宠物, 收集数量
                if text then
                    self2.name:SetText(self2.name:GetText()..text)
                end
            end
        end
        if self2.slot then--专精图标
            local specTable = GetItemSpecInfo(self2.link) or {}
            local specTableNum=#specTable
            if specTableNum>0 then
                local specA=''
                local class
                table.sort(specTable, function (a2, b2) return a2<b2 end)
                for k,  specID in pairs(specTable) do
                    local icon2, _, classFile=select(4, GetSpecializationInfoByID(specID))
                    if icon2 and classFile then
                        icon2='|T'..icon2..':0|t'
                        specA = specA..((class and class~=classFile) and '  ' or '')..icon2
                        class=classFile
                    end
                end
                if specA~='' then
                    self2.slot:SetText((self2.slot:GetText() or '')..specA)
                end
            end
        end
    end)
    --boss, ID, 信息
    hooksecurefunc('EncounterJournal_DisplayInstance', function(instanceID, noButton)--Blizzard_EncounterJournal.lua
        if not EncounterJournal.encounter then
            return
        end
        local self2 = EncounterJournal.encounter;
        if Save.hideEncounterJournal or not instanceID then
            if self2.instance.Killed then
                self2.instance.Killed:SetText('')
            end
            return
        end
        local name, description, bgImage, buttonImage1, loreImage, buttonImage, dungeonAreaMapID = EJ_GetInstanceInfo(instanceID)
        if description then
            local mapName, parentMapID
            if dungeonAreaMapID and dungeonAreaMapID > 0 then
                local mapInfo= C_Map.GetMapInfo(dungeonAreaMapID)
                if mapInfo then
                    mapName= mapInfo.name
                    parentMapID= mapInfo.parentMapID
                    if parentMapID then
                        mapInfo=C_Map.GetMapInfo(parentMapID)
                        if mapInfo and mapInfo.name then
                            parentMapID=mapInfo.name..'UiMapID: '..parentMapID
                        end
                    end
                end
            end
            local text='journalInstanceID: '..instanceID
            --..((dungeonAreaMapID and dungeonAreaMapID>0) and ' UiMapID: '..dungeonAreaMapID or '')
            ..(mapName and '|n'..mapName..'UiMapID: '..dungeonAreaMapID or '')
            ..(parentMapID and '|n'.. parentMapID or '')
            ..(buttonImage and '|n|T'..buttonImage..':0|t'..buttonImage or '')
            ..((buttonImage1 and buttonImage1~=buttonImage) and '|n|T'..buttonImage1..':0|t'..buttonImage1 or '')
            ..(bgImage and '|n|T'..bgImage..':0|t'..bgImage or '')
            ..(loreImage and '|n|T'..loreImage..':0|t'..loreImage or '')
            self2.instance.LoreScrollingFont:SetText(description..'\n'..text)
        end
        if not noButton then
            for _, button in pairs(self2.info.BossesScrollBox:GetFrames()) do
                button:SetScript('OnEnter', function(self3)
                    local index=self3.GetOrderIndex()
                    if not Save.hideEncounterJournal and index then
                        local name2, _, journalEncounterID, rootSectionID, _, journalInstanceID, dungeonEncounterID, instanceID2= EJ_GetEncounterInfoByIndex(index)
                        e.tips:SetOwner(self3, "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:AddLine(' ')
                        if instanceID2 then
                            e.tips:AddDoubleLine(name2, 'instanceID: '..instanceID2)
                        end
                        if journalEncounterID then
                            e.tips:AddDoubleLine('journalEncounterID: '..'|cnGREEN_FONT_COLOR:'..journalEncounterID..'|r', (rootSectionID and rootSectionID>0) and 'JournalEncounterSectionID: '..rootSectionID or ' ')
                        end
                        if dungeonEncounterID then
                            e.tips:AddDoubleLine('dungeonEncounterID: '..dungeonEncounterID, (journalInstanceID and journalInstanceID>0) and 'journalInstanceID: '..journalInstanceID or ' ' )
                            local numKill=Save.wowBossKill[dungeonEncounterID]
                            if numKill then
                                e.tips:AddDoubleLine(e.onlyChinse and '击杀' or KILLS, '|cnGREEN_FONT_COLOR:'..numKill..' |r'..(e.onlyChinse and '次' or VOICEMACRO_LABEL_CHARGE1))
                            end
                        end

                        e.tips:Show()
                    end
                end)
                button:SetScript('OnLeave', function() e.tips:Hide() end)
            end
        end

        if self2.instance.mapButton then
            self2.instance.mapButton:SetScript('OnEnter', function(self3)--综述,小地图提示
                local instanceName, description2, _, _, _, _, dungeonAreaMapID2 = EJ_GetInstanceInfo();
                if dungeonAreaMapID2 and instanceName then
                    e.tips:SetOwner(self3, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(instanceName, 'UiMapID: '..dungeonAreaMapID2)
                    e.tips:AddLine(' ')
                    e.tips:AddLine(description2, nil,nil,nil, true)
                    e.tips:Show()
                end
            end)
            self2.instance.mapButton:SetScript('OnLeave', function() e.tips:Hide() end)
        end

        if not self2.instance.Killed then--综述, 添加副本击杀情况
            self2.instance.Killed=e.Cstr(self2.instance, nil, nil,nil,nil,nil,'RIGHT')
            self2.instance.Killed:SetPoint('BOTTOMRIGHT', -33, 126)
        end
        self2.instance.Killed.instanceID=instanceID
        self2.instance.Killed.tooltipTitle=name
        local text= EncounterJournal_ListInstances_set_Instance(self2.instance.Killed)
        self2.instance.Killed:SetText(text or '')
    end)

    --战利品, 套装, 收集数
    hooksecurefunc(EncounterJournal.LootJournalItems.ItemSetsFrame,'ConfigureItemButton', function(self2, button)--Blizzard_LootJournalItems.lua
        local has = C_TransmogCollection.PlayerHasTransmogByItemInfo(button.itemID)
        if has==false and not button.tex and not Save.hideEncounterJournal then
            button.tex=button:CreateTexture()
            button.tex:SetSize(16,16)
            button.tex:SetPoint('BOTTOMRIGHT',2,-2)
            button.tex:SetAtlas(e.Icon.transmogHide)
        end
        if button.tex then
            button.tex:SetShown(has==false and not Save.hideEncounterJournal)
        end
    end)

    --战利品, 套装 , 收集数量
    local function lootSet(self2)
        if Save.hideEncounterJournal then
            return
        end
        local buttons = self2.buttons;
        local offset = HybridScrollFrame_GetOffset(self2)
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
    hooksecurefunc(EncounterJournal.LootJournalItems.ItemSetsFrame, 'UpdateList', lootSet);
    hooksecurefunc('HybridScrollFrame_Update', function(self2)
            if EncounterJournal and self2==EncounterJournal.LootJournalItems.ItemSetsFrame then
                lootSet(self2)
            end
    end)

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
    hooksecurefunc('EncounterJournal_OnClick', function(self2, d)--右击发送超链接
        if d=='RightButton' and self2.link and not Save.hideEncounterJournal then
            if not ChatEdit_GetActiveWindow() then
                ChatFrame_OpenChat(self2.link, SELECTED_DOCK_FRAME)
            else
                ChatEdit_InsertLink(self2.link)
            end
            return
        end
    end)
    hooksecurefunc('EncounterJournal_UpdateButtonState', function(self2)--技能提示
        self2:EnableMouse(true)
        self2:RegisterForClicks("LeftButtonDown","RightButtonDown")
        self2:SetScript("OnEnter", function(self3)
            local frame2=self3:GetParent()
            local spellID= frame2 and frame2.spellID
            if spellID and not Save.hideEncounterJournal then
                e.tips:SetOwner(self3, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(spellID)
                e.tips:Show()
            end
        end)
        self2:SetScript('OnLeave', function() e.tips:Hide() end)
    end)
    --BOSS模型
    hooksecurefunc('EncounterJournal_DisplayCreature', function(self2, forceUpdate)
        if not Save.hideEncounterJournal and EncounterJournal.creatureDisplayID and not EncounterJournal.creatureDisplayIDText then
            local modelScene = EncounterJournal.encounter.info.model;
            EncounterJournal.creatureDisplayIDText=e.Cstr(modelScene,14, modelScene.imageTitle)
            EncounterJournal.creatureDisplayIDText:SetPoint('BOTTOMLEFT', 5, 2)
        end
        if EncounterJournal.creatureDisplayIDText then
            EncounterJournal.creatureDisplayIDText:SetText((EncounterJournal.creatureDisplayID and not Save.hideEncounterJournal) and MODEL..'ID: '..EncounterJournal.creatureDisplayID or '')
        end
    end)

    --记录上次选择版本
    hooksecurefunc('EncounterJournal_TierDropDown_Select', function(_, tier)
        Save.EncounterJournalTier=tier
    end)

    --记录上次选择TAB
    hooksecurefunc('EJ_ContentTab_Select', function(id2)
        Save.EncounterJournalSelectTabID=id2
    end)
    if not Save.hideEncounterJournal then
        local numTier=EJ_GetNumTiers()
        if numTier and Save.EncounterJournalTier and Save.EncounterJournalTier<=numTier then
            EJ_SelectTier(Save.EncounterJournalTier)
        end
        if Save.EncounterJournalSelectTabID then
            EJ_ContentTab_Select(Save.EncounterJournalSelectTabID)
        end
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent('BOSS_KILL')
panel:RegisterEvent('UPDATE_INSTANCE_INFO')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')
panel:RegisterEvent('WEEKLY_REWARDS_UPDATE')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(e.onlyChinse and '冒险指南' or addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_EncounterJournal' and not Save.disabled then---冒险指南
            Init()--冒险指南界面
            EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
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
    end
end)