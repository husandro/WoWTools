local id, e = ...
local addName= HUD_EDIT_MODE_MICRO_MENU_LABEL..' Plus'
local Save={
    plus=true,
    size=10,
}

local Frames














--装等, 耐久度 CharacterMicroButton
local function Init_Durabiliy()
    local frame= CreateFrame("Frame")
    table.insert(Frames, frame)

    frame.Text= e.Cstr(CharacterMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', CharacterMicroButton, 0,  -3)
    frame.Text2= e.Cstr(CharacterMicroButton,  {size=Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', CharacterMicroButton, 0, 3)

    function frame:settings()
        local to, cu= GetAverageItemLevel()--装等
        local text, red
        if to and cu and to>0 then
            text=math.modf(cu)
            if to-cu>10 then
                text='|cnRED_FONT_COLOR:'..text..'|r'
                red= true
            end
        end
        self.Text:SetText(text or '')
        if e.Player.levelMax then
            e.Set_HelpTips({frame=self, topoint=self.Text, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=nil, show=red and not C_PvP.IsArena() and not C_PvP.IsBattleground()})--设置，提示
        end

        local text, value= e.GetDurabiliy(false, false)--耐久度
        self.Text2:SetText(text:gsub('%%', ''))
        e.Set_HelpTips({frame=self, topoint=self.Text2, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=true, show=value<30})--设置，提示
    end
    frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    frame:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    CharacterMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        local item, cur, pvp= GetAverageItemLevel()
        cur= cur or 0
        item= item or 0
        pvp= pvp or 0
        e.tips:AddDoubleLine(
            (e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')
            ..(e.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL)..(cur==item and format(' |cnGREEN_FONT_COLOR:%.2f|r', cur) or format(' |cnRED_FONT_COLOR:%.2f|r/%.2f', cur, item)),
            format('%.02f', pvp)..' PvP|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a')
        e.tips:AddLine(' ')
        local text=  e.GetDurabiliy(true, true)
        e.tips:AddLine('|A:Warfronts-BaseMapIcons-Alliance-Armory-Minimap:0:0|a'..(e.onlyChinese and '耐久度' or DURABILITY)..' '..text)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
    end)
end








--天赋
local function Init_Talent()
    local frame= CreateFrame("Frame")
    table.insert(Frames, frame)

    frame.Texture= TalentMicroButton:CreateTexture(nil, 'BORDER')
    frame.Texture:SetPoint('TOP', -0, -5)
    frame.Texture:SetSize(16, 16)
    frame.Texture2= TalentMicroButton:CreateTexture(nil, 'BORDER')
    frame.Texture2:SetPoint('BOTTOM', 0, 3)
    frame.Texture2:SetSize(16, 16)

    function frame:settings()
        local lootID=  GetLootSpecialization()
        local specID=  PlayerUtil.GetCurrentSpecID()
        local icon2
        local icon = specID and select(4, GetSpecializationInfoByID(specID))
        if lootID>0 and specID and specID~= lootID then
            icon2 = select(4, GetSpecializationInfoByID(lootID))
        end
        self.Texture:SetTexture(icon or 0)
        self.Texture2:SetTexture(icon2 or 0)
    end
    frame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'Player')
    frame:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    --frame:RegisterEvent('PLAYER_TALENT_UPDATE')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    TalentMicroButton:HookScript('OnEnter', function()
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
        e.GetQuestAllTooltip()--所有，任务，提示
        e.tips:Show()
    end)
end






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
                text= (info.quantity and '|cnGREEN_FONT_COLOR:'..e.MK(info.quantity, 1)..'|r' or '')
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









local function Init_Store()
    local frame= CreateFrame('Frame')
    table.insert(Frames, frame)

    frame.Text= e.Cstr(StoreMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', StoreMicroButton, 0,  -3)

    function frame:settings()
        local text
        local price= C_WowTokenPublic.GetCurrentMarketPrice() or 0
        if price>0 then
            text= e.MK(price/10000, 1)
        end
        self.Text:SetText(text or '')
    end
    frame:RegisterEvent('TOKEN_MARKET_PRICE_UPDATED')
    frame:SetScript('OnEvent', frame.settings)
    C_WowTokenPublic.UpdateMarketPrice()
    C_Timer.After(2, function() frame:settings() end)

    QuestLogMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        C_WowTokenPublic.UpdateMarketPrice()
        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            local all, numPlayer= e.GetItemWoWNum(122284)--取得WOW物品数量
            GameTooltipTextRight1:SetText(col..all..(numPlayer>1 and '('..numPlayer..')' or '')..'|A:token-choice-wow:0:0|a'..e.MK(price/10000,3)..'|r|A:Front-Gold-Icon:0:0|a')
            GameTooltipTextRight1:SetShown(true)
        end
        e.tips:Show()
    end)
end





local function Init_Help()
    local frame= CreateFrame("Frame")
    table.insert(Frames, frame)

    frame.Text= e.Cstr(HelpMicroButton,  {size=Save.size, color=true})
    frame.Text:SetPoint('TOP', HelpMicroButton, 0,  -3)
    frame.Text2= e.Cstr(HelpMicroButton,  {size=Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', HelpMicroButton, 0, 3)

    function frame:settings()
        local to, cu= GetAverageItemLevel()--装等
        local text, red
        if to and cu and to>0 then
            text=math.modf(cu)
            if to-cu>10 then
                text='|cnRED_FONT_COLOR:'..text..'|r'
                red= true
            end
        end
        self.Text:SetText(text or '')
        if e.Player.levelMax then
            e.Set_HelpTips({frame=self, topoint=self.Text, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=nil, show=red and not C_PvP.IsArena() and not C_PvP.IsBattleground()})--设置，提示
        end

        local text, value= e.GetDurabiliy(false, false)--耐久度
        self.Text2:SetText(text:gsub('%%', ''))
        e.Set_HelpTips({frame=self, topoint=self.Text2, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=true, show=value<30})--设置，提示
    end
    frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    frame:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    frame:HookScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0.4) + elapsed
        if self.elapsed > 0.4 then
            self.elapsed = 0
            local latencyHome, latencyWorld= select(3, GetNetStats())--ms
            local ms= math.max(latencyHome, latencyWorld) or 0
            local fps=GetFramerate() or 0
            fps=math.modf(fps)
            frame.Text:SetText(ms>400 and '|cnRED_FONT_COLOR:'..ms..'|r' or ms>120 and ('|cnYELLOW_FONT_COLOR:'..ms..'|r') or ms)
            frame.Text2:SetText(fps<10 and '|cnGREEN_FONT_COLOR:'..math.modf(fps)..'|r' or fps<20 and '|cnYELLOW_FONT_COLOR:'..math.modf(fps)..'|r' or math.modf(fps))
        end
    end)
    C_Timer.After(2, function() frame:settings() end)
end











--每秒帧数 Plus
--############

local function Init_Framerate_Plus()
    if not Save.frameratePlus then
        return
    end
    local btn= e.Cbtn(FramerateFrame, {size={14,14}, icon='hide'})
    btn:SetPoint('RIGHT',FramerateFrame.FramerateText)

    btn:SetMovable(true)
    btn:RegisterForDrag("RightButton");
    btn:SetClampedToScreen(true)
    btn:SetScript("OnDragStart", function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
            local frame= FramerateFrame
            if not frame:IsMovable()  then
                frame:SetMovable(true)
            end
            frame:StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function()
        FramerateFrame:StopMovingOrSizing()
        Save.frameratePoint={FramerateFrame:GetPoint(1)}
        Save.frameratePoint[2]=nil
        ResetCursor()
    end)
    btn:SetScript("OnMouseUp", ResetCursor)
    btn:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    btn:SetScript('OnLeave', function()
        e.tips:Hide()
        button:SetButtonState('NORMAL')
    end)
    btn:SetScript('OnEnter', function(self2)--提示
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '字体大小' or FONT_SIZE, (Save.framerateSize or 12)..e.Icon.mid)
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
        button:SetButtonState('PUSHED')
    end)

    btn:SetScript('OnMouseWheel',function(self, d)
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
        print(id, e.cn(addName), e.onlyChinese and '字体大小' or FONT_SIZE,'|cnGREEN_FONT_COLOR:'..size)
    end)

    function btn:set_size()--修改大小
        e.Cstr(nil, {size=Save.framerateSize or 12, changeFont=FramerateFrame.FramerateText, color=true})--Save.size, nil , Labels.fpsms, true)    
    end
    btn:set_size()


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

    if Save.framerateLogIn and not FramerateFrame:IsShown() then
        FramerateFrame:Toggle()
    end
end








local function Init_Plus()
    if Save.disable then
        return
    end
    if not Frames then
        Frames={}
        Init_Durabiliy()--装等, 耐久度
        Init_Talent()--天赋
        Init_Achievement()--成就
        Init_Quest()--任务
        Init_LFD()
        Init_EJ()
        Init_Store()
        Init_Help()
        Init_Framerate_Plus()
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
local Category, Layout
local function Init_Options()--初始, 选项
    e.AddPanel_Header(Layout, e.onlyChinese and '选项' or OPTIONS)

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

            e.AddPanel_Check({
                name= e.onlyChinese and '启用' or ENABLE,
                tooltip= e.cn(addName),
                value= not Save.disabled,
                category= Category,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

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