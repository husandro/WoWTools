local e= select(2, ...)
local function Save()
    return WoWTools_EncounterMixin.Save
end
local Button









local function set_EncounterJournal_Keystones_Tips(self)--险指南界面, 挑战
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(e.onlyChinese and '史诗钥石地下城' or CHALLENGES, e.Icon.left)
    for guid, info in pairs(e.WoWDate or {}) do
        if guid and  info.Keystone.link then
            e.tips:AddDoubleLine(
                (info.Keystone.weekNum or 0)
                .. (info.Keystone.weekMythicPlus and ' |cnGREEN_FONT_COLOR:('..info.Keystone.weekMythicPlus..') ' or '')
                ..WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true})
                ..(info.Keystone.score and ' ' or '')..(WoWTools_WeekMixin:KeystoneScorsoColor(info.Keystone.score)),
                info.Keystone.link)
        end
    end
    e.tips:Show()
end

local function Set_Money(self, isTooltip)--险指南界面, 钱
    local numPlayer, allMoney  = 0, 0
    if isTooltip then
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
    end
    for guid, info in pairs(e.WoWDate or {}) do
        if info.Money then
            if isTooltip then
                e.tips:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo({ guid=guid, faction=info.faction, reName=true, reRealm=true}), C_CurrencyInfo.GetCoinTextureString(info.Money))
            end
            numPlayer=numPlayer+1
            allMoney= allMoney + info.Money
        end
    end
    if isTooltip then
        if allMoney==0 then
            e.tips:AddDoubleLine(e.onlyChinese and '钱' or MONEY, e.onlyChinese and '无' or NONE)
        else
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine((e.onlyChinese and '角色' or CHARACTER)..' '..numPlayer..' '..(e.onlyChinese and '总计：' or FROM_TOTAL)..WoWTools_Mixin:MK(allMoney/10000, 3), C_CurrencyInfo.GetCoinTextureString(allMoney))
        end
        e.tips:Show()
    end
    return numPlayer, allMoney
end

















local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {icon=not Save().hideEncounterJournal, size={22,22}})--按钮, 总开关
    Button:SetPoint('RIGHT',-22, -2)
    function Button:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
        e.tips:AddDoubleLine(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, e.GetEnabeleDisable(not Save().hideEncounterJournal).. e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '奖励' or QUEST_REWARDS, e.GetShowHide(not Save().hideEncounterJournal_All_Info_Text)..e.Icon.right)
        e.tips:Show()
    end
    Button:SetScript('OnEnter', Button.set_Tooltips)
    Button:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            Save().hideEncounterJournal= not Save().hideEncounterJournal and true or nil
            self:set_Shown()
            self:SetNormalAtlas(Save().hideEncounterJournal and e.Icon.disabled or e.Icon.icon )
            WoWTools_EncounterMixin:Specialization_Loot_SetEvent()--BOSS战时, 指定拾取, 专精, 事件
            e.call(EncounterJournal_ListInstances)

        elseif d=='RightButton' then
            Save().hideEncounterJournal_All_Info_Text= not Save().hideEncounterJournal_All_Info_Text and true or nil
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
        end
        self:set_Tooltips()
    end)
    Button:SetScript("OnLeave",GameTooltip_Hide)
    Button.btn={}

    Button.btn.instance =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--所有角色副本
    Button.btn.instance:SetPoint('RIGHT', Button, 'LEFT')
    Button.btn.instance:SetNormalAtlas('animachannel-icon-kyrian-map')
    Button.btn.instance:SetScript('OnEnter',function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine((e.onlyChinese and '副本' or INSTANCE)..e.Icon.left..e.GetShowHide(Save().showInstanceBoss), e.onlyChinese and '已击杀' or DUNGEON_ENCOUNTER_DEFEATED)
        e.tips:AddLine(' ')
        for guid, info in pairs(e.WoWDate or {}) do
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
                    e.tips:AddLine(WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}))
                end
            end
        end
        e.tips:Show()
    end)
    Button.btn.instance:SetScript("OnLeave", function ()
       e.tips:Hide()
       if WoWTools_EncounterMixin.InstanceBossButton then
            WoWTools_EncounterMixin.InstanceBossButton:SetButtonState('NORMAL')
        end
    end)
    Button.btn.instance:SetScript('OnClick', function()
        if  Save().showInstanceBoss then
            Save().showInstanceBoss=nil
        else
            Save().showInstanceBoss=true
            Save().hideInstanceBossText=nil
        end
        WoWTools_EncounterMixin:InstanceBoss_Settings()
        if WoWTools_EncounterMixin.InstanceBossButton then
            WoWTools_EncounterMixin.InstanceBossButton:SetButtonState('PUSHED')
        end
    end)


    Button.btn.Worldboss =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--所有角色已击杀世界BOSS
    Button.btn.Worldboss:SetPoint('RIGHT', Button.btn.instance, 'LEFT')
    Button.btn.Worldboss:SetNormalAtlas('poi-soulspiritghost')

    Button.btn.Worldboss:SetScript("OnLeave", function()
        e.tips:Hide()
        if WoWTools_EncounterMixin.WorldBossButton then
            WoWTools_EncounterMixin.WorldBossButton:SetButtonState('NORMAL')
        end
    end)
    Button.btn.Worldboss:SetScript('OnEnter',function(self)--提示
        WoWTools_EncounterMixin:GetWorldData(self)
        if WoWTools_EncounterMixin.WorldBossButton then
            WoWTools_EncounterMixin.WorldBossButton:SetButtonState('PUSHED')
        end
    end)

    Button.btn.Worldboss:SetScript('OnMouseDown', function(self2, d)
        if  Save().showWorldBoss then
            Save().showWorldBoss=nil
        else
            Save().showWorldBoss=true
            Save().hideWorldBossText=nil
        end
        WoWTools_EncounterMixin:WorldBoss_Settings()
    end)


    if e.Player.levelMax then
        Button.btn.keystones =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--所有角色,挑战
        Button.btn.keystones:SetPoint('RIGHT', Button.btn.Worldboss, 'LEFT')
        Button.btn.keystones:SetNormalTexture(4352494)
        Button.btn.keystones:SetScript('OnEnter', set_EncounterJournal_Keystones_Tips)
        Button.btn.keystones:SetScript("OnLeave",GameTooltip_Hide)
        Button.btn.keystones:SetScript('OnMouseDown', function()
            PVEFrame_ToggleFrame('ChallengesFrame', 3)
        end)
    end


    Button.btn.money =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--钱
    Button.btn.money:SetPoint('RIGHT', Button.btn.keystones or Button.btn.Worldboss, 'LEFT')
    Button.btn.money:SetNormalAtlas('Front-Gold-Icon')
    Button.btn.money:SetScript('OnEnter', function(self)
        Set_Money(self, true)
    end)
    Button.btn.money:SetScript("OnLeave", GameTooltip_Hide)
        
    Button.btn.money.label= WoWTools_LabelMixin:Create(Button.btn.money, {size=14})
    Button.btn.money.label:SetPoint('RIGHT', Button.btn.money, 'LEFT')
    function Button.btn.money.label:settings()
        local numPlayer, allMoney= Set_Money(self, false)
        local text
        if allMoney>0 then
            text= '#'..numPlayer..' |cffffffff'..WoWTools_Mixin:MK(allMoney/10000, 3)
        end
        self:SetText(text or '')
    end
    Button.btn.money.label:SetScript('OnShow', Button.btn.money.label.settings)
    Button.btn.money.label:SetScript('OnHide', function(self) self:SetText('') end)
    Button.btn.money.label:settings()

    function Button:set_Shown()
        for _, btn in pairs(self.btn) do
            btn:SetShown(not Save().hideEncounterJournal)
        end
    end

    Button:set_Shown()
end









function WoWTools_EncounterMixin:Button_Init()
    Init()
end