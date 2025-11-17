
local function Save()
    return WoWToolsSave['Adventure_Journal']
end





local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub

--Plus
    root:CreateCheckbox(
        'Plus',
    function()
        return not Save().hideEncounterJournal
    end, function()
        Save().hideEncounterJournal= not Save().hideEncounterJournal and true or nil
        --WoWTools_EncounterMixin:Init_Specialization_Loot()--BOSS战时, 指定拾取, 专精, 事件
        WoWTools_DataMixin:Call('EncounterJournal_ListInstances')
        self:set_icon()
    end)

--信息
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '信息' or INFO,
    function()
        return not Save().hideEncounterJournal_All_Info_Text
    end, function()
        Save().hideEncounterJournal_All_Info_Text= not Save().hideEncounterJournal_All_Info_Text and true or nil
        WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
    end)

--专精拾取
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION,
    function()
        return not Save().hideLootSpec
    end, function()
        Save().hideLootSpec= not Save().hideLootSpec and true or nil
        WoWTools_EncounterMixin:Init_LootSpec()
    end)

--打开选项界面
    root:CreateDivider()
    WoWTools_MenuMixin:Reload(root)
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_EncounterMixin.addName,})
--重新加载UI
    
end





















local function Init()
    local btn= WoWTools_ButtonMixin:Menu(EncounterJournalCloseButton, {--按钮, 总开关
        name='WoWToolsAdventureJournalMenuButton',
        size=23,
        icon='hide',

    })

    btn:SetPoint('RIGHT', EncounterJournalCloseButton, 'LEFT')

    --[[function btn:set_Tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_EncounterMixin.addName)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, WoWTools_TextMixin:GetEnabeleDisable(not Save().hideEncounterJournal).. WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '奖励' or QUEST_REWARDS, WoWTools_TextMixin:GetShowHide(not Save().hideEncounterJournal_All_Info_Text)..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end]]
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(WoWTools_EncounterMixin.addName)
        GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)
    btn:SetupMenu(Init_Menu)


    function btn:set_icon()
        if Save().hideEncounterJournal then
            self:SetNormalAtlas('talents-button-reset')
        else
            self:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        end
        WoWTools_TextureMixin:SetButton(btn)
    end
    btn:set_icon()


    local wow= WoWTools_DataMixin:CreateWoWItemListButton(btn, {
        name='WoWToolsEncounterJournalWoWButton',
        type='Instance',
    })
    wow:SetPoint('RIGHT', btn, 'LEFT')

    if WoWTools_DataMixin.Player.IsMaxLevel then
        local key =WoWTools_ButtonMixin:Cbtn(btn, {size=22})--所有角色,挑战
        key:SetPoint('RIGHT', wow, 'LEFT')
        key:SetNormalTexture(4352494)
        key:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            local find= WoWTools_ChallengeMixin:ActivitiesTooltip()--周奖励，提示
            local link= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link
            if link then
                GameTooltip:AddLine(WoWTools_HyperLink:CN_Link(link, {isName=true}))
            end

            if find or link then
                GameTooltip:AddLine(' ')
            end

            GameTooltip:AddLine(
                (WoWTools_DataMixin.onlyChinese and '史诗地下城' or MYTHIC_DUNGEONS)
                ..WoWTools_DataMixin.Icon.left
            )

            GameTooltip:Show()
        end)
        key:SetScript("OnLeave",GameTooltip_Hide)
        key:SetScript('OnMouseDown', function()
            PVEFrame_ToggleFrame('ChallengesFrame', 3)
        end)
        WoWTools_TextureMixin:SetButton(key)
    end

    Init=function()end
end

function WoWTools_EncounterMixin:Button_Init()
    Init()
end

--[[local Button









local function set_EncounterJournal_Keystones_Tips(self)--险指南界面, 挑战
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '史诗钥石地下城' or CHALLENGES, WoWTools_DataMixin.Icon.left)
    for guid, info in pairs(WoWTools_WoWDate or {}) do
        if guid and  info.Keystone.link then
            GameTooltip:AddDoubleLine(
                (info.Keystone.weekNum or 0)
                .. (info.Keystone.weekMythicPlus and ' |cnGREEN_FONT_COLOR:('..info.Keystone.weekMythicPlus..') ' or '')
                ..WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {faction=info.faction, reName=true, reRealm=true})
                ..(info.Keystone.score and ' ' or '')..(WoWTools_ChallengeMixin:KeystoneScorsoColor(info.Keystone.score)),
                info.Keystone.link)
        end
    end
    GameTooltip:Show()
end

local function Set_Money(self, isTooltip)--险指南界面, 钱
    local numPlayer, allMoney  = 0, 0
    if isTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
    end
    for guid, info in pairs(WoWTools_WoWDate or {}) do
        if info.Money then
            if isTooltip then
                GameTooltip:AddDoubleLine(
                    WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {faction=info.faction, reName=true, reRealm=true}),
                    C_CurrencyInfo.GetCoinTextureString(info.Money)
                )
            end
            numPlayer=numPlayer+1
            allMoney= allMoney + info.Money
        end
    end
    if isTooltip then
        if allMoney==0 then
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '钱' or MONEY, WoWTools_DataMixin.onlyChinese and '无' or NONE)
        else
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '角色' or CHARACTER)..' '..numPlayer..' '..(WoWTools_DataMixin.onlyChinese and '总计：' or FROM_TOTAL)..WoWTools_DataMixin:MK(allMoney/10000, 3), C_CurrencyInfo.GetCoinTextureString(allMoney))
        end
        GameTooltip:Show()
    end
    return numPlayer, allMoney
end]]
















   --[[
    Button.btn={}

 Button.btn.instance =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {size=22})--所有角色副本
    Button.btn.instance:SetPoint('RIGHT', Button, 'LEFT')
    Button.btn.instance:SetNormalAtlas('animachannel-icon-kyrian-map')
    Button.btn.instance:SetScript('OnEnter',function(self2)
        GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE)..WoWTools_DataMixin.Icon.left..WoWTools_TextMixin:GetShowHide(Save().showInstanceBoss), WoWTools_DataMixin.onlyChinese and '已击杀' or DUNGEON_ENCOUNTER_DEFEATED)
        GameTooltip:AddLine(' ')
        for guid, info in pairs(WoWTools_WoWDate or {}) do
            if guid and info then
                local find
                for bossName, tab in pairs(info.Instance.ins) do----ins={[instanceID]={[difficultyID]=已击杀数}}
                    local text
                    for difficultyName, killed in pairs(tab) do
                        text= (text and text..' ' or '')..difficultyName..killed
                    end
                    GameTooltip:AddDoubleLine(bossName, text)
                    find= true
                end
                if find then
                    GameTooltip:AddLine(WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {faction=info.faction, reName=true, reRealm=true}))
                end
            end
        end
        GameTooltip:Show()
    end)
    Button.btn.instance:SetScript("OnLeave", function ()
       GameTooltip:Hide()
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


    Button.btn.Worldboss =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {size=22})--所有角色已击杀世界BOSS
    Button.btn.Worldboss:SetPoint('RIGHT', Button.btn.instance, 'LEFT')
    Button.btn.Worldboss:SetNormalAtlas('poi-soulspiritghost')

    Button.btn.Worldboss:SetScript("OnLeave", function()
        GameTooltip:Hide()
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
    end)]]





    --[[Button.btn.money =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {size=22})--钱
    Button.btn.money:SetPoint('RIGHT', key or Button.btn.Worldboss, 'LEFT')
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
            text= '#'..numPlayer..' |cffffffff'..WoWTools_DataMixin:MK(allMoney/10000, 3)
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

    --Button:set_Shown()]]









