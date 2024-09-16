local id, e = ...
local addName= HUD_EDIT_MODE_MICRO_MENU_LABEL..' Plus'
local Save={
    plus=true,
    size=10,
    enabledMainMenuAlpha= true,
    mainMenuAlphaValue=0.5,

    --frameratePlus=true,--系统 fps plus
    --framerateLogIn=true,--自动，打开
}

local Frames
local Category, Layout













--角色 CharacterMicroButton 
local function Init_Character()
    local frame= CreateFrame("Frame")
    table.insert(Frames, frame)

    frame.Text= WoWTools_LabelMixin:CreateLabel(CharacterMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', CharacterMicroButton, 0,  -3)
    --frame.Text:SetPoint('BOTTOM', CharacterMicroButton, 'CENTER', 0, 1)
    frame.Text2= WoWTools_LabelMixin:CreateLabel(CharacterMicroButton,  {size=Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', CharacterMicroButton, 0, 3)
    --frame.Text2:SetPoint('TOP', CharacterMicroButton, 'CENTER', 0, -1)

    function frame:settings()
        local to, cu= GetAverageItemLevel()--装等
        local text
        if to and cu and to>0 then
            text=math.modf(cu)
            if to-cu>10 then
                text='|cnRED_FONT_COLOR:'..text..'|r'
                if IsInsane() and not WoWTools_MapMixin:IsInPvPArea() then
                    WoWTools_FrameMixin:HelpFrame({frame=self, topoint=self.Text, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, show=true})--设置，提示
                end
            end
        end
        self.Text:SetText(text or '')

        local text, value= WoWTools_DurabiliyMixin:Get(false)--耐久度
        self.Text2:SetText(text:gsub('%%', ''))
        WoWTools_FrameMixin:HelpFrame({frame=CharacterMicroButton, topoint=self.text2, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=true, show=value<30})--设置，提示
    end

    frame:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
    frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    frame:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
    frame:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame:SetScript('OnEvent', function(self) C_Timer.After(0.6, function() self:settings() end) end)
    --C_Timer.After(2, function() frame:settings() end)

    CharacterMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
        WoWTools_DurabiliyMixin:OnEnter()
        e.tips:Show()
    end)
end








--天赋
local function Init_Talent()
    local frame= CreateFrame("Frame")
    --table.insert(Frames, frame)
    PlayerSpellsMicroButton.frame= frame

    PlayerSpellsMicroButton.Portrait= PlayerSpellsMicroButton:CreateTexture(nil, 'BORDER', nil, 1)
    --PlayerSpellsMicroButton.Portrait:SetAllPoints(PlayerSpellsMicroButton)
    PlayerSpellsMicroButton.Portrait:SetPoint('CENTER')

    PlayerSpellsMicroButton.Portrait:SetSize(22, 28)




    PlayerSpellsMicroButton.Texture2= PlayerSpellsMicroButton:CreateTexture(nil, 'BORDER', nil, 2)
    PlayerSpellsMicroButton.Texture2:SetPoint('BOTTOMRIGHT', -8, 6)
    PlayerSpellsMicroButton.Texture2:SetSize(20, 24)
    PlayerSpellsMicroButton.Texture2:SetScale(0.5)

    local mask= PlayerSpellsMicroButton:CreateMaskTexture(nil, 'BORDER', nil, 3)
    mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetPoint('CENTER',0,-1)
    mask:SetSize(19, 24)
    --mask:SetAllPoints(PlayerSpellsMicroButton.Portrait)
    PlayerSpellsMicroButton.Portrait:AddMaskTexture(mask)

    mask= PlayerSpellsMicroButton:CreateMaskTexture(nil, 'BORDER', nil, 4)
    mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
    mask:SetAllPoints(PlayerSpellsMicroButton.Texture2)
    PlayerSpellsMicroButton.Texture2:AddMaskTexture(mask)

    function frame:settings()
        local lootID=  GetLootSpecialization()
        local specID=  PlayerUtil.GetCurrentSpecID()
        local icon2
        local icon = specID and select(4, GetSpecializationInfoByID(specID))
        if lootID>0 and specID and specID~= lootID then
            icon2 = select(4, GetSpecializationInfoByID(lootID))
        end
        PlayerSpellsMicroButton.Portrait:SetTexture(icon or 0)
        PlayerSpellsMicroButton.Texture2:SetTexture(icon2 or 0)
    end
    frame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'Player')
    frame:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    --frame:RegisterEvent('PLAYER_TALENT_UPDATE')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    PlayerSpellsMicroButton:SetNormalTexture(0)
    PlayerSpellsMicroButton:HookScript('OnLeave', function(self)
        self.Portrait:SetShown(true)
        self.Texture2:SetShown(true)
    end)
    PlayerSpellsMicroButton:HookScript('OnEnter', function(self)
        self.Portrait:SetShown(false)
        self.Texture2:SetShown(false)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        local a, b
        local index= GetSpecialization()--当前专精
        local specID
        if index then
            local ID, _, _, icon, role = GetSpecializationInfo(index)
            specID= ID
            if icon then
                a= (e.Icon[role] or '')..'|T'..icon..':0|t'
            end
        end
        local lootSpecID = GetLootSpecialization()
        if lootSpecID or specID then
            lootSpecID= lootSpecID==0 and specID or lootSpecID
            local icon, role = select(4, GetSpecializationInfoByID(lootSpecID))
            if icon then
                b= '|T'..icon..':0|t'..(e.Icon[role] or '')
            end
        end
        a= a or ''
        b= b or a or ''
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '当前专精' or TRANSMOG_CURRENT_SPECIALIZATION)..a, (lootSpecID==specID and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')..b..(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION))
        e.tips:Show()
    end)
end






--成就
local function Init_Achievement()
    local frame= CreateFrame('Frame')
    table.insert(Frames, frame)

    frame.Text= WoWTools_LabelMixin:CreateLabel(AchievementMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', AchievementMicroButton, 0,  -3)

    function frame:settings()
        local num
        num= GetTotalAchievementPoints() or 0
        num = num==0 and '' or WoWTools_Mixin:MK(num, 1)
        self.Text:SetText(num)
    end
    frame:RegisterEvent('ACHIEVEMENT_EARNED')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    AchievementMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
        e.tips:AddLine((GetTotalAchievementPoints() or 0)..' '..(e.onlyChinese and '成就点数' or ACHIEVEMENT_POINTS))
        if IsInGuild() then
            local guid= GetTotalAchievementPoints(true) or 0
            e.tips:AddLine(guid..' '..(e.onlyChinese and '公会成就' or GUILD_ACHIEVEMENTS_TITLE))
        end
        e.tips:Show()
    end)
end





















--任务
local function Init_Quest()
    local frame= CreateFrame('Frame')
    table.insert(Frames, frame)

    frame.Text= WoWTools_LabelMixin:CreateLabel(QuestLogMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', QuestLogMicroButton, 0,  -3)

    function frame:settings()
        local num
        num= select(2, C_QuestLog.GetNumQuestLogEntries()) or 0
        if num>=38 then
            num= '|cnRED_FONT_COLOR:'..num..'|r'
        elseif num >= MAX_QUESTS then
            num= '|cnYELLOW_FONT_COLOR:'..num..'|r'
        else
            num = num==0 and '' or num
        end
        self.Text:SetText(num)
    end
    frame:RegisterEvent('ACHIEVEMENT_EARNED')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    QuestLogMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
        WoWTools_QuestMixin:GetQuestAll()--所有，任务，提示
        e.tips:Show()
    end)
end













--公会 GuildMicroButton
local function Init_Guild()
    local frame= CreateFrame("Frame")
    table.insert(Frames, frame)

    frame.Text= WoWTools_LabelMixin:CreateLabel(GuildMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', GuildMicroButton, 0,  -3)
    frame.Text2= WoWTools_LabelMixin:CreateLabel(GuildMicroButton,  {size=Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', GuildMicroButton, 0, 3)

    GuildMicroButton.Text2= frame.Text2

    function frame:settings()
        local online = select(2, GetNumGuildMembers())
        self.Text:SetText((online and online>1) and online-1 or '')

        online=0
        local guildClubId= C_Club.GetGuildClubId()
        for _, tab in pairs(C_Club.GetSubscribedClubs() or {}) do
            local members= C_Club.GetClubMembers(tab.clubId) or {}
            if tab.clubId~=guildClubId then
                for _, memberID in pairs(members) do--CommunitiesUtil.GetOnlineMembers
                    local info = C_Club.GetMemberInfo(tab.clubId, memberID) or {}
                    if not info.isSelf and info.presence~=Enum.ClubMemberPresence.Offline and info.presence~=Enum.ClubMemberPresence.Unknown then--CommunitiesUtil.GetOnlineMembers()
                        online= online+1
                    end
                end
            end
        end
        self.Text2:SetText(online>0 and online or '')
    end
    local COMMUNITIES_LIST_EVENTS = {
        "CLUB_ADDED",
        "CLUB_REMOVED",
        "CLUB_UPDATED",
        "CLUB_INVITATION_ADDED_FOR_SELF",
        "CLUB_INVITATION_REMOVED_FOR_SELF",
        "GUILD_ROSTER_UPDATE",
        "CLUB_STREAMS_LOADED",
        "PLAYER_GUILD_UPDATE",
    };
    FrameUtil.RegisterFrameForEvents(frame, COMMUNITIES_LIST_EVENTS)
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    GuildMicroButton:HookScript('OnEnter', function(self)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        if IsInGuild() then
            e.tips:AddLine(' ')
        end
        e.Get_Guild_Enter_Info()
        e.tips:Show()
        local all= GetNumGuildMembers() or 0
        self.Text2:SetText(all>0 and all or '')
    end)
end




















--地下城查找器
local function Init_LFD()
    local frame= CreateFrame('Frame')
    table.insert(Frames, frame)

    frame.Text= WoWTools_LabelMixin:CreateLabel(LFDMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', LFDMicroButton, 0,  -3)

    function frame:settings()
        local lv= C_MythicPlus.GetOwnedKeystoneLevel() or 0
        self.Text:SetText(lv>0 and lv or '')
    end
    frame:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame:RegisterEvent('BAG_UPDATE_DELAYED')
    frame:SetScript('OnEvent', frame.settings)

    LFDMicroButton.setTextFrame= frame
    LFDMicroButton:HookScript('OnEnter', function(self)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        self.setTextFrame:settings()
        e.tips:AddLine(' ')
        WoWTools_WeekMixin:Activities({showTooltip=true})--周奖励，提示
        local link=  e.WoWDate[e.Player.guid].Keystone.link
        if link then
            e.tips:AddLine('|T4352494:0|t'..link)
        end
        e.tips:Show()
    end)
end





























 --冒险指南
 local function Init_EJ()
    local frame= CreateFrame('Frame')
    table.insert(Frames, frame)

    frame.Text= WoWTools_LabelMixin:CreateLabel(EJMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', EJMicroButton, 0,  -3)

    local function Get_Perks_Info()
        local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo()--贸易站, 点数Blizzard_MonthlyActivities.lua
        if not activitiesInfo then
            return
        end
        local thresholdMax = 0;
        for _, thresholdInfo in pairs(activitiesInfo.thresholds) do
            if thresholdInfo.requiredContributionAmount > thresholdMax then
                thresholdMax = thresholdInfo.requiredContributionAmount;
            end
        end
        thresholdMax= thresholdMax == 0 and 1000 or thresholdMax
        local earnedThresholdAmount = 0;
        for _, activity in pairs(activitiesInfo.activities) do
            if activity.completed then
                earnedThresholdAmount = earnedThresholdAmount + activity.thresholdContributionAmount;
            end
        end
        earnedThresholdAmount = math.min(earnedThresholdAmount, thresholdMax);
        return earnedThresholdAmount, thresholdMax, C_CurrencyInfo.GetCurrencyInfo(2032), activitiesInfo
    end

    function frame:settings()
        local text
        local cur, max, info= Get_Perks_Info()
        if cur then
            info =info or {}
            if cur== max then
                text= (info.quantity and WoWTools_Mixin:MK(info.quantity, 1) or format('|A:%s:0:0|a', e.Icon.select))
            else
                text= format('%i%%', cur/max*100)
            end
        end
        self.Text:SetText(text or '')
    end
    frame:RegisterEvent('CVAR_UPDATE')
    frame:RegisterEvent('PERKS_ACTIVITY_COMPLETED')
    frame:RegisterEvent('PERKS_ACTIVITIES_UPDATED')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    EJMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        local cur, max, info= Get_Perks_Info()
        if cur then
            info= info or {}
            e.tips:AddLine(' ')
            if info.quantity then
                e.tips:AddDoubleLine((info.iconFileID  and '|T'..info.iconFileID..':0|t' or '|A:activities-complete-diamond:0:0|a')..info.quantity, info.name)
            end
            e.tips:AddDoubleLine((cur==max and '|cnGREEN_FONT_COLOR:' or '|cffff00ff')..cur..'|r/'..max..format(' %i%%', cur/max*100), e.onlyChinese and '旅行者日志进度' or MONTHLY_ACTIVITIES_PROGRESSED)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.addName, e.cn(addName))
        end
        e.tips:Show()
    end)
end



























--商店
local function Init_Store()
    local frame= CreateFrame('Frame')
    table.insert(Frames, frame)

    frame.Text= WoWTools_LabelMixin:CreateLabel(StoreMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', StoreMicroButton, 0,  -3)
    frame.Text2= WoWTools_LabelMixin:CreateLabel(StoreMicroButton,  {size=Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', StoreMicroButton, 0, 3)

    StoreMicroButton.Text2= frame.Text2

    function frame:settings()
        local text
        local price= C_WowTokenPublic.GetCurrentMarketPrice() or 0
        if price>0 then
            text= WoWTools_Mixin:MK(price/10000, 0)
        end
        self.Text:SetText(text or '')
    end
    frame:RegisterEvent('TOKEN_MARKET_PRICE_UPDATED')
    frame:SetScript('OnEvent', frame.settings)
    C_WowTokenPublic.UpdateMarketPrice()
    C_Timer.After(2, function() frame:settings() end)

    StoreMicroButton:HookScript('OnEnter', function(self)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        C_WowTokenPublic.UpdateMarketPrice()
        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('|A:token-choice-wow:0:0|a'..WoWTools_Mixin:MK(price/10000,4), C_CurrencyInfo.GetCoinTextureString(price) )
            e.tips:AddLine(' ')
        end
        local bagAll,bankAll,numPlayer=0,0,0--帐号数据
        for guid, info in pairs(e.WoWDate or {}) do
            local tab=info.Item[122284]
            if tab and guid then
                e.tips:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), '|A:Banker:0:0|a'..(tab.bank==0 and '|cff9e9e9e'..tab.bank..'|r' or tab.bank)..' '..'|A:bag-main:0:0|a'..(tab.bag==0 and '|cff9e9e9e'..tab.bag..'|r' or tab.bag))
                bagAll=bagAll +tab.bag
                bankAll=bankAll +tab.bank
                numPlayer=numPlayer +1
            end
        end
        local all= bagAll+ bankAll
        e.tips:AddDoubleLine('|A:groupfinder-waitdot:0:0|a'..numPlayer, '|T1120721:0|t'..all)
        e.tips:Show()
        self.Text2:SetText(all>0 and all or '')
    end)

    local all=0
    for guid, info in pairs(e.WoWDate or {}) do
        local tab=info.Item[122284]
        if tab and guid then
            e.tips:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), '|A:Banker:0:0|a'..(tab.bank==0 and '|cff9e9e9e'..tab.bank..'|r' or tab.bank)..' '..'|A:bag-main:0:0|a'..(tab.bag==0 and '|cff9e9e9e'..tab.bag..'|r' or tab.bag))
            all= all +tab.bag +tab.bank
        end
    end
    if all>0 then
        frame.Text2:SetText(all)
    end
end




















--帮助
local function Init_Help()
    local frame= CreateFrame("Frame")
    table.insert(Frames, frame)

    frame:SetPoint('TOP')
    frame:SetSize(1,1)

    frame.Text= WoWTools_LabelMixin:CreateLabel(MainMenuMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', MainMenuMicroButton, 0,  -3)
    frame.Text2= WoWTools_LabelMixin:CreateLabel(MainMenuMicroButton,  {size=Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', MainMenuMicroButton, 0, 3)


    frame.elapsed= 1
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed > 0.4 then
            self.elapsed = 0
            local latencyHome, latencyWorld= select(3, GetNetStats())--ms
            local ms= math.max(latencyHome, latencyWorld) or 0
            local fps= math.modf(GetFramerate() or 0)
            self.Text:SetText(fps<10 and '|cnGREEN_FONT_COLOR:'..fps..'|r' or fps<20 and '|cnYELLOW_FONT_COLOR:'..fps..'|r' or fps)
            self.Text2:SetText(ms>400 and '|cnRED_FONT_COLOR:'..ms..'|r' or ms>120 and ('|cnYELLOW_FONT_COLOR:'..ms..'|r') or ms)
        end
    end)



    --添加版本号 MainMenuBar.lua
    hooksecurefunc('MainMenuBarPerformanceBarFrame_OnEnter', function()
        if not MainMenuMicroButton.hover or KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
        local version, build, date, tocversion, localizedVersion, buildType = GetBuildInfo()
        e.tips:AddLine(version..' '..build.. ' '..date.. ' '..tocversion..(buildType and ' '..buildType or ''), 1,0,1)
        if localizedVersion and localizedVersion~='' then
            e.tips:AddLine((e.onlyChinese and '本地' or REFORGE_CURRENT)..localizedVersion, 1,0,0)
        end
        e.tips:AddLine('realmID '..(GetRealmID() or '')..' '..(GetNormalizedRealmName() or ''), 1,0.82,0)
        e.tips:AddLine('regionID '..e.Player.region..' '..GetCurrentRegionName(), 1,0.82,0)

        local info=C_BattleNet.GetGameAccountInfoByGUID(e.Player.guid)
        if info and info.wowProjectID then
            local region=''
            if info.regionID and info.regionID~=e.Player.region then
                region=' regionID'..(e.onlyChinese and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')..info.regionID..'|r'
            end
            e.tips:AddLine('isInCurrentRegion '..e.GetYesNo(info.isInCurrentRegion)..region, 1,1,1)
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '选项' or SETTINGS_TITLE), e.Icon.mid)
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
        e.tips:Show()
    end)
    MainMenuMicroButton:EnableMouseWheel(true)--主菜单, 打开插件选项
    MainMenuMicroButton:HookScript('OnMouseWheel', function()
        if not Category then
            e.OpenPanelOpting()
        end
        e.OpenPanelOpting(Category, '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or addName))
    end)
end























--提示，背包，总数
local function Init_Bag()
    local frame= CreateFrame("Frame")
    table.insert(Frames, frame)

    frame.Text= WoWTools_LabelMixin:CreateLabel(MainMenuBarBackpackButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', MainMenuBarBackpackButton, 0, -6)

    function frame:settings()
        local money=0
        if Save.moneyWoW then
            for _, info in pairs(e.WoWDate or {}) do
                if info.Money then
                    money= money+ info.Money
                end
            end
        else
            money= GetMoney()
        end
        if money>=10000 then
            self.Text:SetText(WoWTools_Mixin:MK(money/1e4, 0))
        else
            self.Text:SetText(GetMoneyString(money,true))
        end
    end
    frame:RegisterEvent('PLAYER_MONEY')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)


    MainMenuBarBackpackButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')

        local numPlayer, allMoney= 0, 0
        local tab={}
        for guid, infoMoney in pairs(e.WoWDate or {}) do
            if infoMoney.Money then
                local nameText= WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=infoMoney.faction, reName=true, reRealm=true})
                local moneyText= C_CurrencyInfo.GetCoinTextureString(infoMoney.Money)
                local class= select(2, GetPlayerInfoByGUID(guid))
                local col= '|c'..select(4, GetClassColor(class))
                numPlayer=numPlayer+1
                allMoney= allMoney + infoMoney.Money
                table.insert(tab, {text=nameText, money=moneyText, col=col, index=infoMoney.Money})
            end
        end
        table.sort(tab, function(a,b) return a.index< b.index end)
        e.tips:AddDoubleLine(
            (e.onlyChinese and '总计' or TOTAL)
            ..' |cnGREEN_FONT_COLOR:'..(allMoney >=10000 and WoWTools_Mixin:MK(allMoney/10000, 3) or C_CurrencyInfo.GetCoinTextureString(allMoney))..'|r',
            '|cnGREEN_FONT_COLOR:'..numPlayer..'|r '..(e.onlyChinese and '角色' or CHARACTER)
        )

        for _, tab in pairs(tab) do
            e.tips:AddDoubleLine(tab.text, tab.col..tab.money)
        end

        e.tips:AddLine(' ')

        local num, use= 0, 0
        tab={}
        for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
            local freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i)
            local numSlots= C_Container.GetContainerNumSlots(i) or 0
            if bagFamily == 0 and numSlots>0 and freeSlots then
                num= num + numSlots
                use= use+ freeSlots
                local icon
                if i== BACKPACK_CONTAINER then
                    icon= '|A:bag-main:0:0|a'
                else
                    local inventoryID = C_Container.ContainerIDToInventoryID(i)
                    local texture = inventoryID and GetInventoryItemTexture('player', inventoryID)
                    if texture then
                        icon= '|T'..texture..':0|t'
                    end
                end
                table.insert(tab, {index='|cffff00ff'..(i+1)..'|r', icon=icon, all=numSlots, num= freeSlots>0 and '|cnGREEN_FONT_COLOR:'..num..'|r' or '|cnRED_FONT_COLOR:'..num..'|r'})
            end
        end

        e.tips:AddLine((e.onlyChinese and '总计' or TOTAL)..' '.. (use>0 and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')..use..'|r/'..num)
        for i=1, #tab, 2 do
            local a= tab[i]
            local b= tab[i+1]
            e.tips:AddDoubleLine(a.index..') '..a.all..a.icon..a.num, b and (b.num..b.icon..b.all..' ('..b.index))
        end
        e.tips:Show()
    end)


    MainMenuBarBackpackButtonCount:SetShadowOffset(1, -1)
    WoWTools_ColorMixin:SetLabelTexture(MainMenuBarBackpackButtonCount, {type='FontString'})--设置颜色

    hooksecurefunc(MainMenuBarBackpackButton, 'UpdateFreeSlots', function(self)
        local freeSlots=self.freeSlots
        if freeSlots then
            if freeSlots==0 then
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(1,0,0,1)
                freeSlots= '|cnRED_FONT_COLOR:'..freeSlots..'|r'
            elseif freeSlots<=5 then
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(0,1,0,1)
                freeSlots= '|cnGREEN_FONT_COLOR:'..freeSlots..'|r'
            else
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(0,0,0,0)
            end
            self.Count:SetText(freeSlots)
        else
            MainMenuBarBackpackButtonIconTexture:SetColorTexture(0,0,0,0)
        end
    end)

    --收起，背包小按钮
    if C_CVar.GetCVarBool("expandBagBar") and C_CVar.GetCVarBool("combinedBags") then--MainMenuBarBagButtons.lua
        C_CVar.SetCVar("expandBagBar", '0')
    end

    --if not MainMenuBarBackpackButton.OnClick then
    MainMenuBarBackpackButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() then
            ToggleAllBags()
        end
    end)
end
























--菜单，透明度
local function Init_MainMenu(init)
    if not Save.enabledMainMenuAlpha then
        return
    end
    local tab = {
        'CharacterMicroButton',--菜单
        'ProfessionMicroButton',
        'PlayerSpellsMicroButton',
        'AchievementMicroButton',
        'QuestLogMicroButton',
        'GuildMicroButton',
        'LFDMicroButton',
        'EJMicroButton',
        'CollectionsMicroButton',
        'MainMenuMicroButton',
        'HelpMicroButton',
        'StoreMicroButton',
        'MainMenuBarBackpackButton',--背包
    }
    local function set_OnLeave(self)
        local texture= self.Portrait or self:GetNormalTexture()
        if texture then
            texture:SetAlpha(Save.mainMenuAlphaValue)
        end
        if self.Background then
            self.Background:SetAlpha(Save.mainMenuAlphaValue)
        end
    end

    for _, text in pairs(tab) do
        local btn= _G[text]
        if btn then
            if init then
                btn:HookScript('OnEnter', function(self)
                    local texture= self.Portrait or self:GetNormalTexture()
                    if texture then
                        texture:SetAlpha(1)
                        texture:SetVertexColor(1,1,1,1)
                    end
                    if self.Background then
                        self.Background:SetAlpha(1)
                    end
                end)
                btn:HookScript('OnLeave', set_OnLeave)
            end
            set_OnLeave(btn)
        end
    end

    tab={
        'CharacterBag0Slot',
        'CharacterBag1Slot',
        'CharacterBag2Slot',
        'CharacterBag3Slot',
        'CharacterReagentBag0Slot',
    }
    local function set_Bag_OnLeave(self)
        local name= self:GetName()
        if name then
            local texture= _G[name..'IconTexture']
            if texture then
                texture:SetAlpha(Save.mainMenuAlphaValue)
            end
            texture=_G[name..'NormalTexture']
            if texture then
                texture:SetAlpha(Save.mainMenuAlphaValue)
            end
        end
    end
    for _, text in pairs(tab) do
        local btn= _G[text]
        if btn then
            if init then
                btn:HookScript('OnEnter', function(self)
                    local name= self:GetName()
                    if name then
                        local texture= _G[name..'IconTexture']
                        if texture then
                            texture:SetAlpha(1)
                        end
                        texture=_G[name..'NormalTexture']
                        if texture then
                            texture:SetAlpha(1)
                        end
                    end
                end)
                btn:HookScript('OnLeave', set_Bag_OnLeave)
            end
            set_Bag_OnLeave(btn)
        end
    end

    --[[CharacterReagentBag0SlotNormalTexture:SetAlpha(Save.mainMenuAlphaValue)--外框 hooksecurefunc(MainMenuBarBagManager, 'ToggleExpandBar', function()
    if init then
        CharacterReagentBag0Slot:HookScript('OnLeave', function(self)--GetCVarBool("expandBagBar")
            CharacterReagentBag0SlotIconTexture:SetAlpha(Save.mainMenuAlphaValue)
        end)
        CharacterReagentBag0Slot:HookScript('OnEnter', function(self)
            CharacterReagentBag0SlotIconTexture:SetAlpha(1)
        end)
    end]]
    --[[
        set_Reagent_Bag_Alpha(GetCVarBool("expandBagBar"))
    end)]]

    --[[if init then
        hooksecurefunc('PaperDollItemSlotButton_Update', function(self)--PaperDollFrame.lua 主菜单，包
            local bagID= self:GetID()
            if bagID>30 then
                --set_Alpha_Color(self:GetNormalTexture())
                --set_Alpha_Color(self.icon)
                self:SetAlpha(GetInventoryItemTexture("player", bagID)~=nil and 1 or 0.1)
            end
        end)
    end]]
end




























local function Init_Plus()
    if Save.disable then
        return
    end
    if not Frames then
        Frames={}
        Init_Character()--角色

        Init_Talent()--天赋 
        Init_Achievement()--成就
        Init_Quest()--任务
        Init_Guild()--公会
        Init_LFD()--地下城查找器
        Init_EJ() --冒险指南
        Init_Store()--商店
        Init_Help()--帮助
        Init_Bag()--背包
        Init_MainMenu(true)--菜单，透明度
    else
        for _, frame in pairs(Frames) do
            if frame.Text then
                WoWTools_LabelMixin:CreateLabel(nil, {size=Save.size, changeFont=frame.Text, color=true})
            end
            if frame.Text2 then
                WoWTools_LabelMixin:CreateLabel(nil, {size=Save.size, changeFont=frame.Text2, color=true})
            end
        end
    end
end




















--每秒帧数 Plus
--############
local FramerateButton
local function Init_Framerate_Plus()
    if not Save.frameratePlus or FramerateButton then
        return
    end
    FramerateButton= WoWTools_ButtonMixin:Cbtn(FramerateFrame, {size={14,14}, icon='hide'})
    FramerateButton:SetPoint('RIGHT',FramerateFrame.FramerateText)

    FramerateButton:SetMovable(true)
    FramerateButton:RegisterForDrag("RightButton");
    FramerateButton:SetClampedToScreen(true)
    FramerateButton:SetScript("OnDragStart", function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
            local frame= FramerateFrame
            if not frame:IsMovable()  then
                frame:SetMovable(true)
            end
            frame:StartMoving()
        end
    end)
    FramerateButton:SetScript("OnDragStop", function()
        FramerateFrame:StopMovingOrSizing()
        Save.frameratePoint={FramerateFrame:GetPoint(1)}
        Save.frameratePoint[2]=nil
        ResetCursor()
    end)
    FramerateButton:SetScript("OnMouseUp", ResetCursor)
    FramerateButton:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)


    function FramerateButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(MicroButtonTooltipText(FRAMERATE_LABEL, "TOGGLEFPS"))
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '字体大小' or FONT_SIZE, (Save.framerateSize or 12)..e.Icon.mid)
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
        e.tips:Show()
    end
    FramerateButton:SetScript('OnLeave', GameTooltip_Hide)
    FramerateButton:SetScript('OnEnter', FramerateButton.set_tooltips)

    FramerateButton:SetScript('OnMouseWheel',function(self, d)
        if IsModifierKeyDown() then
            return
        end
        local size=Save.framerateSize or 12
        if d==1 then
            size=size+1
            size = size>72 and 72 or size
        elseif d==-1 then
            size=size-1
            size= size<6 and 6 or size
        end
        Save.framerateSize=size
        self:set_size()
        self:set_tooltips()
    end)

    function FramerateButton:set_size()--修改大小
        WoWTools_LabelMixin:CreateLabel(nil, {size=Save.framerateSize or 12, changeFont=FramerateFrame.FramerateText, color=true})--Save.size, nil , Labels.fpsms, true)    
    end
    FramerateButton:set_size()

    FramerateFrame.Label:SetText('')--去掉FPS
    FramerateFrame.Label:SetShown(false)
    FramerateFrame:SetMovable(true)
    FramerateFrame:SetClampedToScreen(true)
    FramerateFrame:HookScript('OnShow', function(self)
        if Save.frameratePoint and FramerateFrame then
            self:ClearAllPoints()
            self:SetPoint(Save.frameratePoint[1], UIParent, Save.frameratePoint[3], Save.frameratePoint[4], Save.frameratePoint[5])
        end
    end)
    FramerateFrame:SetFrameStrata('HIGH')

    if Save.framerateLogIn and not FramerateFrame:IsShown() then--自动，打开
        FramerateFrame:Toggle()
    end
end





















--###########
--添加控制面板
--###########
local function Init_Options()--初始, 选项
    

    local initializer2= e.AddPanel_Check({
        name= 'Plus',
        tooltip= e.cn(addName),
        GetValue= function() return Save.plus end,
        category= Category,
        SetValue= function()
            Save.plus= not Save.plus and true or nil
            if Save.plus and not Frames then
                Init_Plus()
            else
                print(e.addName, e.cn(addName), e.GetEnabeleDisable(Save.plus), e.onlyChinese and '重新加载UI' or RELOADUI)
            end
        end
    })
    local initializer= e.AddPanelSider({
        name= e.onlyChinese and '字体大小' or FONT_SIZE,
        GetValue= function() return Save.size end,
        minValue= 8,
        maxValue= 18,
        setp= 1,
        tooltip= e.cn(addName),
        category= Category,
        SetValue= function(_, _, value2)
            Save.size=value2
            Init_Plus()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save.plus then return true else return false end end)

    initializer= e.AddPanel_Check_Sider({
        checkName= e.onlyChinese and '透明度' or 'Alpha',
        checkGetValue= function() return Save.enabledMainMenuAlpha end,
        checkTooltip= e.cn(addName),
        checkSetValue= function()
            Save.enabledMainMenuAlpha= not Save.enabledMainMenuAlpha and true or nil
            print(e.addName, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        sliderGetValue= function() return Save.mainMenuAlphaValue end,
        minValue= 0,
        maxValue= 0.9,
        step= 0.1,
        sliderSetValue= function(_, _, value2)
            Save.mainMenuAlphaValue= e.GetFormatter1to10(value2, 0, 1)
            Init_MainMenu()
        end,
        layout= Layout,
        category= Category,
    })
    initializer:SetParentInitializer(initializer2, function() if Save.plus then return true else return false end end)

    e.AddPanel_Header(Layout, e.onlyChinese and '系统' or SYSTEM)
    initializer2= e.AddPanel_Check({
        name= (e.onlyChinese and '每秒帧数:' or FRAMERATE_LABEL)..' Plus',
        tooltip= MicroButtonTooltipText(FRAMERATE_LABEL, "TOGGLEFPS"),
        GetValue= function() return Save.frameratePlus end,
        category= Category,
        SetValue= function()
            Save.frameratePlus= not Save.frameratePlus and true or nil
            if FramerateButton then
                print(e.addName, e.cn(addName), e.GetEnabeleDisable(Save.frameratePlus), e.onlyChinese and '重新加载UI' or RELOADUI)
            end
            Init_Framerate_Plus()
        end
    })
    initializer= e.AddPanel_Check({
        name= (e.onlyChinese and '登入' or LOG_IN)..' WoW: '..(e.onlyChinese and '显示' or SHOW),
        tooltip=  MicroButtonTooltipText(FRAMERATE_LABEL, "TOGGLEFPS"),
        GetValue= function() return Save.framerateLogIn end,
        category= Category,
        SetValue= function()
            Save.framerateLogIn= not Save.framerateLogIn and true or nil
            Init_Framerate_Plus()
            if Save.framerateLogIn and not FramerateFrame:IsShown() then
                FramerateFrame:Toggle()
            end
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save.frameratePlus then return true else return false end end)


end















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            WoWToolsSave[SYSTEM_MESSAGES]= nil--清除，旧版本数据
            Category, Layout= e.AddPanel_Sub_Category({name= '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'..(e.onlyChinese and '菜单 Plus' or addName)})

            if Save.plus then
                Init_Plus()
                Init_Framerate_Plus()--系统，fts
            end
        elseif arg1=='Blizzard_Settings' then
            Init_Options()--初始, 选项
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)