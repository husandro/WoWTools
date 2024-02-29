local id, e = ...
local addName= HUD_EDIT_MODE_MICRO_MENU_LABEL..' Plus'
local Save={
    plus=true,
    size=10,
}

local Frames














--角色 CharacterMicroButton
local function Init_Character()
    local frame= CreateFrame("Frame")
    table.insert(Frames, frame)

    frame.Text= e.Cstr(CharacterMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', CharacterMicroButton, 0,  -3)
    frame.Text2= e.Cstr(CharacterMicroButton,  {size=Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', CharacterMicroButton, 0, 3)

    function frame:settings()
        local to, cu= GetAverageItemLevel()--装等
        local text
        if to and cu and to>0 then
            text=math.modf(cu)
            if to-cu>10 then
                text='|cnRED_FONT_COLOR:'..text..'|r'
                if IsInsane() and not C_PvP.IsArena() and not C_PvP.IsBattleground() then
                    e.Set_HelpTips({frame=self, topoint=self.Text, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, show=true})--设置，提示
                end
            end
        end
        self.Text:SetText(text or '')

        local text, value= e.GetDurabiliy(false, false)--耐久度
        self.Text2:SetText(text:gsub('%%', ''))
        e.Set_HelpTips({frame=CharacterMicroButton, topoint=self.text2, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=true, show=value<30})--设置，提示
    end
    frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    frame:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
    frame:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame:SetScript('OnEvent', frame.settings)
    --C_Timer.After(2, function() frame:settings() end)

    CharacterMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
        local text= e.GetDurabiliy(true, true)
        
        e.tips:AddLine(' ')
        e.tips:AddLine((e.onlyChinese and '耐久度a' or DURABILITY)..text)
        local item, cur, pvp= GetAverageItemLevel()
        cur= cur or 0
        item= item or 0
        pvp= pvp or 0
        e.tips:AddDoubleLine(
            (e.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL)
            ..(e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')
            ..(cur==item and format(' |cnGREEN_FONT_COLOR:%.2f|r', cur) or format(' |cnRED_FONT_COLOR:%.2f|r/%.2f', cur, item)),
            format('%.02f', pvp)..' PvP|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a')
        e.tips:Show()
    end)
end








--天赋
local function Init_Talent()
    local frame= CreateFrame("Frame")
    --table.insert(Frames, frame)
    TalentMicroButton.frame= frame

    TalentMicroButton.Portrait= TalentMicroButton:CreateTexture(nil, 'BORDER', nil, 1)
    --TalentMicroButton.Portrait:SetAllPoints(TalentMicroButton)
    TalentMicroButton.Portrait:SetPoint('CENTER')

    TalentMicroButton.Portrait:SetSize(22, 28)




    TalentMicroButton.Texture2= TalentMicroButton:CreateTexture(nil, 'BORDER', nil, 2)
    TalentMicroButton.Texture2:SetPoint('BOTTOMRIGHT', -8, 6)
    TalentMicroButton.Texture2:SetSize(20, 24)
    TalentMicroButton.Texture2:SetScale(0.5)

    local mask= TalentMicroButton:CreateMaskTexture(nil, 'BORDER', nil, 3)
    mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetPoint('CENTER',0,-1)
    mask:SetSize(19, 24)
    --mask:SetAllPoints(TalentMicroButton.Portrait)
    TalentMicroButton.Portrait:AddMaskTexture(mask)

    mask= TalentMicroButton:CreateMaskTexture(nil, 'BORDER', nil, 4)
    mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
    mask:SetAllPoints(TalentMicroButton.Texture2)
    TalentMicroButton.Texture2:AddMaskTexture(mask)

    function frame:settings()
        local lootID=  GetLootSpecialization()
        local specID=  PlayerUtil.GetCurrentSpecID()
        local icon2
        local icon = specID and select(4, GetSpecializationInfoByID(specID))
        if lootID>0 and specID and specID~= lootID then
            icon2 = select(4, GetSpecializationInfoByID(lootID))
        end
        TalentMicroButton.Portrait:SetTexture(icon or 0)
        TalentMicroButton.Texture2:SetTexture(icon2 or 0)
    end
    frame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'Player')
    frame:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    --frame:RegisterEvent('PLAYER_TALENT_UPDATE')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    TalentMicroButton:SetNormalTexture(0)
    TalentMicroButton:HookScript('OnLeave', function(self)
        self.Portrait:SetShown(true)
        self.Texture2:SetShown(true)
    end)
    TalentMicroButton:HookScript('OnEnter', function(self)
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

    frame.Text= e.Cstr(AchievementMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', AchievementMicroButton, 0,  -3)

    function frame:settings()
        local num
        num= GetTotalAchievementPoints() or 0
        num = num==0 and '' or e.MK(num,1)
        self.Text:SetText(num)
    end
    frame:RegisterEvent('ACHIEVEMENT_EARNED')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    AchievementMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        local guid= GetTotalAchievementPoints(true) or 0
        local point= GetTotalAchievementPoints() or 0
        e.tips:AddLine(' ')
        e.tips:AddLine(point..' '..(e.onlyChinese and '成就点数' or ACHIEVEMENT_POINTS))
        if guid>0 then
            e.tips:AddLine(guid..' '..(e.onlyChinese and '公会成就' or GUILD_ACHIEVEMENTS_TITLE))
        end
        e.tips:Show()
    end)
end





















--任务
local function Init_Quest()
    local frame= CreateFrame('Frame')
    table.insert(Frames, frame)

    frame.Text= e.Cstr(QuestLogMicroButton,  {size=Save.size, color=true})
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
        e.GetQuestAllTooltip()--所有，任务，提示
        e.tips:Show()
    end)
end













--公会 GuildMicroButton
local function Init_Guild()
    local frame= CreateFrame("Frame")
    table.insert(Frames, frame)

    frame.Text= e.Cstr(GuildMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', GuildMicroButton, 0,  -3)
    --frame.Text2= e.Cstr(GuildMicroButton,  {size=Save.size, color=true})
    --frame.Text2:SetPoint('BOTTOM', GuildMicroButton, 0, 3)

    function frame:settings()
        local online = select(2, GetNumGuildMembers())
        self.Text:SetText((online and online>1) and online-1 or '')
    end
    frame:RegisterEvent('GUILD_ROSTER_UPDATE')
    frame:RegisterEvent('PLAYER_GUILD_UPDATE')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    GuildMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        local all, online, app = GetNumGuildMembers()
        if all and all>0 then
            local guildName, description, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
            e.tips:AddLine(guildName)
            e.tips:AddLine(description, nil,nil,nil, true)
            e.tips:AddLine(' ')

            e.tips:Show()
        end
    end)
end




















--地下城查找器
local function Init_LFD()
    LFDMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
        e.Get_Weekly_Rewards_Activities({showTooltip=true})--周奖励，提示
        e.tips:Show()
    end)
end





























 --冒险指南
 local function Init_EJ()
    local frame= CreateFrame('Frame')
    table.insert(Frames, frame)

    frame.Text= e.Cstr(EJMicroButton,  {size=Save.size, color=true})
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
                text= (info.quantity and e.MK(info.quantity, 1) or e.Icon.select2)
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
            e.tips:AddDoubleLine(id, e.cn(addName))
        end
        e.tips:Show()
    end)
end



























--商店
local function Init_Store()
    local frame= CreateFrame('Frame')
    table.insert(Frames, frame)

    frame.Text= e.Cstr(StoreMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', StoreMicroButton, 0,  -3)
    frame.Text2= e.Cstr(StoreMicroButton,  {size=Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', StoreMicroButton, 0, 3)
    
    StoreMicroButton.Text2= frame.Text2

    function frame:settings()
        local text
        local price= C_WowTokenPublic.GetCurrentMarketPrice() or 0
        if price>0 then
            text= e.MK(price/10000, 0)
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
            e.tips:AddDoubleLine('|A:token-choice-wow:0:0|a'..e.MK(price/10000,3), GetCoinTextureString(price) )
            e.tips:AddLine(' ')
        end
        local bagAll,bankAll,numPlayer=0,0,0--帐号数据
        for guid, info in pairs(e.WoWDate or {}) do
            local tab=info.Item[122284]
            if tab and guid then
                e.tips:AddDoubleLine(e.GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), e.Icon.bank2..(tab.bank==0 and '|cff606060'..tab.bank..'|r' or tab.bank)..' '..e.Icon.bag2..(tab.bag==0 and '|cff606060'..tab.bag..'|r' or tab.bag))
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
            e.tips:AddDoubleLine(e.GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), e.Icon.bank2..(tab.bank==0 and '|cff606060'..tab.bank..'|r' or tab.bank)..' '..e.Icon.bag2..(tab.bag==0 and '|cff606060'..tab.bag..'|r' or tab.bag))
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

    frame.Text= e.Cstr(MainMenuMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', MainMenuMicroButton, 0,  -3)
    frame.Text2= e.Cstr(MainMenuMicroButton,  {size=Save.size, color=true})
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
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
    end)
    MainMenuMicroButton:EnableMouseWheel(true)--主菜单, 打开插件选项
    MainMenuMicroButton:HookScript('OnMouseWheel', function()
        e.OpenPanelOpting('|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or addName))
    end)
   -- MainMenuMicroButton.MainMenuBarPerformanceBar:ClearAllPoints()
    --MainMenuMicroButton.MainMenuBarPerformanceBar:SetPoint('BOTTOM')
end




















--每秒帧数 Plus
--############
local FramerateButton
local function Init_Framerate_Plus()
    if not Save.frameratePlus or FramerateButton then
        return
    end
    FramerateButton= e.Cbtn(FramerateFrame, {size={14,14}, icon='hide'})
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
        e.tips:AddDoubleLine(id, e.cn(addName))
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
        e.Cstr(nil, {size=Save.framerateSize or 12, changeFont=FramerateFrame.FramerateText, color=true})--Save.size, nil , Labels.fpsms, true)    
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

        Init_Framerate_Plus()--系统，fts        
    else
        for _, frame in pairs(Frames) do
            if frame.Text then
                e.Cstr(nil, {size=Save.size, changeFont=frame.Text, color=true})
            end
            if frame.Text2 then
                e.Cstr(nil, {size=Save.size, changeFont=frame.Text2, color=true})
            end
        end
    end

    --[[local tab= {
        'CharacterMicroButton',--菜单
        'SpellbookMicroButton',
        'TalentMicroButton',
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
        --'CharacterReagentBag0Slot',--材料包
    }]]
end



























--###########
--添加控制面板
--###########

local function Init_Options()--初始, 选项
    local Category, Layout= e.AddPanel_Sub_Category({name= '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'..(e.onlyChinese and '菜单 Plus' or addName)})
    --[[e.AddPanel_Check({
        name= e.onlyChinese and '启用' or ENABLE,
        tooltip= e.cn(addName),
        value= not Save.disabled,
        category= Category,
        func= function()
            Save.disabled= not Save.disabled and true or nil
            print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })

    e.AddPanel_Header(Layout, e.onlyChinese and '选项' or OPTIONS)]]

    local initializer2= e.AddPanel_Check({
        name= 'Plus',
        tooltip= e.cn(addName),
        value= Save.plus,
        category= Category,
        func= function()
            Save.plus= not Save.plus and true or nil
            if Save.plus and not Frames then
                Init_Plus()
            else
                print(id, e.cn(addName), e.GetEnabeleDisable(Save.plus), e.onlyChinese and '重新加载UI' or RELOADUI)
            end
        end
    })
    local initializer= e.AddPanelSider({
        name= e.onlyChinese and '字体大小' or FONT_SIZE,
        value= Save.size,
        minValue= 8,
        maxValue= 18,
        setp= 1,
        tooltip= e.cn(addName),
        category= Category,
        func= function(_, _, value2)
            local value3= e.GetFormatter1to10(value2, 8, 18)
            Save.size=value3
            Init_Plus()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save.plus then return true else return false end end)

    e.AddPanel_Header(Layout, e.onlyChinese and '系统' or SYSTEM)
    initializer2= e.AddPanel_Check({
        name= (e.onlyChinese and '每秒帧数:' or FRAMERATE_LABEL)..' Plus',
        tooltip= e.cn(addName),
        value= Save.frameratePlus,
        category= Category,
        func= function()
            Save.frameratePlus= not Save.frameratePlus and true or nil
            if FramerateButton then
                print(id, e.cn(addName), e.GetEnabeleDisable(Save.frameratePlus), e.onlyChinese and '重新加载UI' or RELOADUI)
            end
            Init_Framerate_Plus()
        end
    })
    initializer= e.AddPanel_Check({
        name= (e.onlyChinese and '登入' or LOG_IN)..' WoW: '..(e.onlyChinese and '显示' or SHOW),
        tooltip= e.cn(addName),
        value= Save.framerateLogIn,
        category= Category,
        func= function()
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



            Init_Plus()

        elseif arg1=='Blizzard_Settings' then
            Init_Options()--初始, 选项
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)