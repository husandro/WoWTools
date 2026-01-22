
local function Save()
    return WoWToolsSave['Adventure_Journal']
end





local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub, sub2

    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '旅程' or JOURNEYS_LABEL,
    function()
        return not Save().hideJourneys
    end, function()
        Save().hideJourneys= not Save().hideJourneys and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
    
    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '列表' or WHO_LIST:gsub(GUILD_TAB_ROSTER , ''),
    function()
        return not Save().hideJourneysList
    end, function()
        Save().hideJourneysList= not Save().hideJourneysList and true or nil
        WoWTools_EncounterMixin:Init_JourneysList()
    end)
    
--Plus
    sub=root:CreateCheckbox(
        'Plus',
    function()
        return not Save().hideEncounterJournal
    end, function()
        Save().hideEncounterJournal= not Save().hideEncounterJournal and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
--副本列表
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '副本列表' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INSTANCE, 'List'),
    function()
        return not Save().hideInsList
    end, function()
        Save().hideInsList= not Save().hideInsList and true or nil
        WoWTools_EncounterMixin:Init_ListInstances()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--副本列表，缩放
    sub:CreateSpacer()
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().insListScale or 1
    end, function(value)
        Save().insListScale= value
        WoWTools_DataMixin:Call('EncounterJournal_ListInstances')
    end, function()
        Save().insListScale= nil
        WoWTools_DataMixin:Call('EncounterJournal_ListInstances')
    end)


--专精拾取
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION,
    function()
        return not Save().hideLootSpec
    end, function()
        Save().hideLootSpec= not Save().hideLootSpec and true or nil
        WoWTools_EncounterMixin:Init_LootSpec()
        WoWTools_DataMixin:Call('EncounterJournal_Refresh')
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('ENCOUNTER_START')
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)


    sub2=sub:CreateCheckbox(
        format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION,
            (WoWTools_UnitMixin:GetClassIcon(nil, nil, self.classFile) or '')
            ..WoWTools_ColorMixin:SetStringColor(
                WoWTools_DataMixin.onlyChinese and WoWTools_DataMixin.ClassName_CN[WoWTools_DataMixin.Player.Class] or UnitClass('player')
            )
        ),
    function()
        return Save().lootOnlyClass
    end, function()
        Save().lootOnlyClass= not Save().lootOnlyClass and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--按钮，缩放
    sub:CreateSpacer()
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().lootScale or 1
    end, function(value)
        Save().lootScale= value
        WoWTools_DataMixin:Call('EncounterJournal_Refresh')
    end, function()
        Save().lootScale= nil
        WoWTools_DataMixin:Call('EncounterJournal_Refresh')
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

--记录上次选择版本
    root:CreateDivider()
    local tier= Save().EncounterJournalTier or EJ_GetCurrentTier() or 1
    local tierName= EJ_GetTierInfo(tier)
    sub=root:CreateCheckbox(
        WoWTools_TextMixin:CN(tierName) or 'EJ Tier',
    function()
        return Save().isSaveTier
    end, function()
        Save().isSaveTier= not Save().isSaveTier and true or false
        Save().EncounterJournalTier= Save().isSaveTier and EJ_GetCurrentTier() or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '保存改动' or EDIT_TICKET)
        tooltip:AddLine(' ')
        tooltip:AddLine('EJ Tier|cffffffff '..tier)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '仅限：重载时' or format(LFG_LIST_CROSS_FACTION, RELOADUI))
    end)


--打开选项界面
    root:CreateDivider()
    sub= WoWTools_MenuMixin:Reload(root)
    WoWTools_MenuMixin:OpenOptions(sub, {name=WoWTools_EncounterMixin.addName})
--重新加载UI

end



--[[

Menu.ModifyMenu("MENU_EJ_EXPANSION", function(_, root)
    root:CreateDivider()
    local sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '保存' or SAVE),
    function()
        return Save().isSaveTier
    end, function()
        Save().isSaveTier= not Save().isSaveTier and true or false
        Save().EncounterJournalTier= Save().isSaveTier and EJ_GetCurrentTier() or nil
    end)
    sub:SetTooltip(function(tooltip)
        local tier= Save().EncounterJournalTier or EJ_GetCurrentTier() or 1
        local name= EJ_GetTierInfo(tier)
        tooltip:AddLine(WoWTools_DataMixin.Icon.icon2..WoWTools_TextMixin:CN(name)..' tier|cffffffff '..tier)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '仅限：重载时' or format(LFG_LIST_CROSS_FACTION, RELOADUI))
    end)
end)
]]

















local function Init()
    local menu= CreateFrame('DropdownButton', 'WoWToolsAdventureJournalMenuButton', EncounterJournalCloseButton, 'WoWToolsMenuTemplate')
    menu:SetPoint('RIGHT', EncounterJournalCloseButton, 'LEFT')
    menu:SetupMenu(Init_Menu)


    local great= EncounterJournalInstanceSelect.GreatVaultButton
    great:ClearAllPoints()
    great:SetPoint('RIGHT', menu, 'LEFT', -4, 0)
    great:SetFrameStrata(menu:GetFrameStrata())
    great:SetFrameLevel(menu:GetFrameLevel())
    great:SetSize(23,23)
    local icon= great:GetNormalTexture()
    if icon then
        icon:ClearAllPoints()
        icon:SetPoint('TOPLEFT', -2, 2)
        icon:SetPoint('BOTTOMRIGHT', 2, -2)
    end

    local wow= WoWTools_DataMixin:CreateWoWItemListButton(menu, {
        name='WoWToolsEncounterJournalWoWButton',
        type='Instance',
        alpha=1,
    })
    wow:SetPoint('RIGHT', great, 'LEFT', -4, 0)


    local key =WoWTools_ButtonMixin:Cbtn(menu, {size=22})--所有角色,挑战
    key:SetPoint('RIGHT', wow, 'LEFT', -4, 0)
    key.texture= key:CreateTexture(nil,'BORDER')
    key.texture:SetPoint('TOPLEFT', 2, -2)
    key.texture:SetPoint('BOTTOMRIGHT', -2, 2)
    key.texture:SetTexture('Interface\\EncounterJournal\\UI-EJ-PortraitIcon')--4352494)
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
    --WoWTools_TextureMixin:SetButton(key)





    local com= CreateFrame('Button', 'WoWToolsEJPlayerCompanionMenuButton', menu, 'WoWToolsButtonTemplate')
    com.texture= com:CreateTexture()
    com.texture:SetAllPoints()
    com:SetPoint('RIGHT', key, 'LEFT', -4, 0)
    function com:tooltip(tooltip)
        local find
        for companionID=1, 20 do
            local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(companionID)
            if traitTreeID and traitTreeID>0 then
                if WoWTools_FactionMixin:GetCompanionInfo(companionID, tooltip) then
                    find=true
                end

            else
                break
            end
        end
        if find then
            GameTooltip:AddLine(' ')
        end
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
    end

    function com:Get_CompanionID()
        local factionID= C_DelvesUI.GetDelvesFactionForSeason()-- or 2272
        if factionID then
            local major= C_MajorFactions.GetMajorFactionData(factionID)
            if major then
                return major.playerCompanionID
            end
        end
    end

    function com:setting()
        local companionID= self:Get_CompanionID() or 1
        local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(companionID)
        local configID= traitTreeID and C_Traits.GetConfigIDByTreeID(traitTreeID)
        SetPortraitTextureFromCreatureDisplayID(self.texture, C_DelvesUI.GetCreatureDisplayInfoForCompanion(companionID))
        self.texture:SetDesaturated(InCombatLockdown() or not configID)
    end

    com:SetScript('OnClick', function(self, d)
        self:setting()
        if d=='LeftButton' then
            WoWTools_LoadUIMixin:OpenCompanion()
            return
        end
        MenuUtil.CreateContextMenu(self, function(_, root)
            local enabled= not InCombatLockdown()
            for companionID=1, 20 do
                local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(companionID)
                if traitTreeID and traitTreeID>0 then
                    local info= WoWTools_FactionMixin:GetCompanionInfo(companionID)
                    if info then
                        local sub=root:CreateButton(
    --可修该
                            (info.configID and enabled  and '' or DISABLED_FONT_COLOR:GenerateHexColorMarkup())
                            ..info.compaionName
                            ..(info.compaionLevel and ' '..info.compaionLevel or ''),
                        function(data)
                            WoWTools_LoadUIMixin:OpenCompanion(data.companionID)
                            return MenuResponse.Open
                        end, {
                            companionID=companionID,
                            factionID= info.factionID,
                        })
                        sub:AddInitializer(function(button, desc)
                            local icon = button:AttachTexture()
                            icon:SetSize(23, 23)
                            icon:SetPoint("RIGHT")
                            SetPortraitTextureFromCreatureDisplayID(icon, C_DelvesUI.GetCreatureDisplayInfoForCompanion(desc.data.companionID))
                        end)
                        WoWTools_SetTooltipMixin:FactionMenu(sub)
                    end

                else
                    break
                end
            end
        end)
    end)

    com:HookScript('OnShow', function(self)
        self:setting()
    end)
    

    Init=function()end
end

function WoWTools_EncounterMixin:Init_Menu()
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









