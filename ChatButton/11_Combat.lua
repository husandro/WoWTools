local id, e = ...
local addName
local Save= {
    textScale=1.2,
    SayTime=120,--每隔
    disabledSayTime= not e.Player.husandro,
    --AllOnlineTime=true,--进入游戏时,提示游戏,时间

    bat={num= 0, time= 0},--战斗数据
    pet={num= 0,  win=0, capture=0},
    ins={num= 0, time= 0, kill=0, dead=0},
    afk={num= 0, time= 0},


    inCombatScale=1.3,--战斗中缩放
}
local CombatButton
local TrackButton


--local OnLineTime--在线时间

local OnCombatTime--战斗时间
local OnAFKTime--AFK时间
local OnPetTime--宠物战斗
local OnInstanceTime--副本

local LastText--最后时间提示
local OnInstanceDeadCheck--副本,死亡,测试点



local PetAll={num= 0,  win=0, capture=0}--宠物战斗,全部,数据
local PetRound={}--宠物战斗, 本次,数据
local InstanceDate={num= 0, time= 0, kill=0, dead=0}--副本数据{dead死亡,kill杀怪, map地图}







local function get_faction_texture()
    return e.Icon[e.Player.faction] or e.Icon['Neutral']
end









local function set_Tooltips_Info()
    e.tips:AddDoubleLine(
        (e.onlyChinese and '战斗' or COMBAT)..'|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a'..SecondsToTime(Save.bat.time),
        Save.bat.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    )
    e.tips:AddDoubleLine(
        (PetAll.num>0 and PetAll.win..'/'..PetAll.num or (e.onlyChinese and '宠物' or PET))..'|A:worldquest-icon-petbattle:0:0|a'..Save.pet.win..'|r/'..Save.pet.num,
        Save.pet.capture..' |T646379:0|t'
    )
    e.tips:AddDoubleLine(
        (e.onlyChinese and '离开' or AFK)..'|A:socialqueuing-icon-clock:0:0|a'..SecondsToTime(Save.afk.time),
        Save.afk.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    )
    e.tips:AddDoubleLine(
        (e.onlyChinese and '副本' or INSTANCE)..'|A:BuildanAbomination-32x32:0:0|a'..Save.ins.kill..'|A:poi-soulspiritghost:0:0|a'..Save.ins.dead,
        Save.ins.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)..' |A:CrossedFlagsWithTimer:0:0|a'..WoWTools_TimeMixin:Info(Save.ins.time)
    )
    e.tips:AddLine(' ')
    --local time=WoWTools_TimeMixin:Info(OnLineTime)
    e.tips:AddDoubleLine((e.onlyChinese and '在线' or GUILD_ONLINE_LABEL)..'|A:socialqueuing-icon-clock:0:0|a', SecondsToTime(GetSessionTime()))--time)---在线时间
    local tab=e.WoWDate[e.Player.guid].Time
    e.tips:AddDoubleLine((e.onlyChinese and '总计' or TOTAL)..'|A:socialqueuing-icon-clock:0:0|a',  tab.totalTime and SecondsToTime(tab.totalTime))
    e.tips:AddDoubleLine(
        (e.onlyChinese and '本周%s' or CURRENCY_THIS_WEEK):format('CD')..' ('..e.Player.week..')',
        SecondsToTime(C_DateAndTime.GetSecondsUntilWeeklyReset())
    )
end














local chatStarTime
local function set_TrackButton_Text()--设置显示内容
    local text
    if OnCombatTime then--战斗时间
        local combat, sec = WoWTools_TimeMixin:Info(OnCombatTime, not Save.timeTypeText)
        if not Save.disabledSayTime then--喊话
            sec=math.floor(sec)
            if sec ~= chatStarTime and sec > 0 and sec%Save.SayTime==0  then--IsInInstance()
                chatStarTime=sec
                WoWTools_ChatMixin:Chat(WoWTools_TimeMixin:SecondsToClock(sec), nil, nil)
            end
        end
        text= '|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a|cnRED_FONT_COLOR:'..combat..'|r'
    end

    if OnAFKTime then
        text= text and text..'|n' or ''
        text= text .. (e.onlyChinese and '离开' or AFK)..'|A:socialqueuing-icon-clock:0:0|a'..WoWTools_TimeMixin:Info(OnAFKTime, not Save.timeTypeText)
    end

    if OnPetTime then
        text= text and text..'|n' or ''
        text= text ..(PetRound.text or '|TInterface\\Icons\\PetJournalPortrait:0|t')..' '..WoWTools_TimeMixin:Info(OnPetTime, not Save.timeTypeText)
    end

    if OnInstanceTime then
        text= text and text..'|n' or LastText and (LastText..'|n') or ''
        text=text..'|A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..'|A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|A:CrossedFlagsWithTimer:0:0|a'..WoWTools_TimeMixin:Info(OnInstanceTime, not Save.timeTypeText)
    end
    TrackButton.text:SetText(text or LastText or '')
end











local function set_Pet_Text()--宠物战斗, 设置显示内容
    local text= format(e.onlyChinese and '%d轮' or PET_BATTLE_COMBAT_LOG_NEW_ROUND, PetRound.round or 0)
    if  C_PetBattles.IsWildBattle() then
        text=text..'|A:worldquest-icon-petbattle:0:0|a'
    elseif PetRound.PVP then
        text=text..'|A:pvptalents-warmode-swords:0:0|a'
    else
        text=text..'|A:jailerstower-animapowerlist-offense:0:0|a'
    end
    if PetAll.num>0 then
        text=text..' '..PetAll.win..'/'..PetAll.num
    end
    PetRound.text=text
end













local function TrackButton_Frame_Init_Date()--初始, 数据
    local time=GetTime()
    if UnitIsAFK('player') then
        if not OnAFKTime then--AFk时,播放声音
            OnAFKTime= time
            e.PlaySound(SOUNDKIT.READY_CHECK)--播放, 声音
        end
        LastText=nil

    elseif OnAFKTime then
        local text, sec = WoWTools_TimeMixin:Info(OnAFKTime, not Save.timeTypeText)
        LastText= '|A:socialqueuing-icon-clock:0:0|a|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '离开' or AFK)..text..'|r'
        Save.afk.num= Save.afk.num + 1
        Save.afk.time= Save.afk.time + sec
        print(e.addName, e.cn(addName), LastText)
        OnAFKTime=nil
    end

    if UnitAffectingCombat('player') then
        OnCombatTime= OnCombatTime or time
        LastText=nil
    elseif OnCombatTime then
        local text, sec=WoWTools_TimeMixin:Info(OnCombatTime, not Save.timeTypeText)
        LastText= '|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a|cnGREEN_FONT_COLOR:'..text..'|r'
        if sec>10 then
            Save.bat.num= Save.bat.num + 1
            Save.bat.time= Save.bat.time + sec
        end
        OnCombatTime=nil
        chatStarTime=nil
    end

    if C_PetBattles.IsInBattle() then--宠物战斗
        OnPetTime= OnPetTime or time
        LastText=nil
    elseif OnPetTime then
        if PetRound.win then--赢
            PetAll.win= PetAll.win +1
            Save.pet.win= Save.pet.win +1
            if PetRound.capture then--捕获
                PetAll.capture= PetAll.capture +1
                Save.pet.capture= Save.pet.capture +1
            end
        end
        PetAll.num= PetAll.num +1--次数
        Save.pet.num= Save.pet.num +1

        LastText=(PetRound.text or '')..(PetRound.win and '|T646379:0|t' or ' ')..WoWTools_TimeMixin:Info(OnPetTime, not Save.timeTypeText)
        if PetRound.win then
            LastText='|cnGREEN_FONT_COLOR:'..LastText..'|r'
        else
            LastText='|cnRED_FONT_COLOR:'..LastText..'|r'
        end
        print(e.addName, e.cn( addName), e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE, LastText, Save.pet.win..'/'..Save.pet.num, (Save.pet.capture>0 and Save.pet.capture..' |T646379:0|t' or ''));

        PetRound={}
        OnPetTime=nil
    end

    if IsInInstance() then--副本
        OnInstanceTime= OnInstanceTime or time
        InstanceDate.map= InstanceDate.map or WoWTools_MapMixin:GetUnit('player')


    elseif OnInstanceTime then
        local text, sec= WoWTools_TimeMixin:Info(OnInstanceTime, not Save.timeTypeText)
        if sec>60 or InstanceDate.dead>0 or InstanceDate.kill>0 then
            Save.ins.num= Save.ins.num +1
            Save.ins.time= Save.ins.time +sec
        end
        LastText='|cnGREEN_FONT_COLOR:|A:CrossedFlagsWithTimer:0:0|a'..text..' |A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..' |A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|r'
        print(e.addName, InstanceDate.map or e.onlyChinese and '副本' or INSTANCE, text)

        InstanceDate={time= 0, kill=0, dead=0}--副本数据{dead死亡,kill杀怪, map地图}
        OnInstanceTime=nil
    end

    if OnAFKTime or OnCombatTime or OnPetTime or OnInstanceTime then
        TrackButton.elapsed= 0.4
        TrackButton.Frame:SetShown(true)
    else
        TrackButton.Frame:SetShown(false)
        set_TrackButton_Text()
    end
end





local function Set_TrackButton_Pushed(show)--TrackButton，提示
	if TrackButton then
		TrackButton:SetButtonState(show and 'PUSHED' or "NORMAL")
	end
end





local function Init_TrackButton()--设置显示内容, 父框架TrackButton, 内容TrackButton.text
    if Save.disabledText or TrackButton then
        if TrackButton then
            if Save.disabledText then
                TrackButton:UnregisterAllEvents()
                TrackButton.text:SetText('')
            else
                TrackButton:set_instance_evnet()
                TrackButton:set_evnet()
                TrackButton_Frame_Init_Date()--初始, 数据
            end
            TrackButton:SetShown(not Save.disabledText and true or false)
        end
        return
    end

    TrackButton= WoWTools_ButtonMixin:Cbtn(WoWToolsChatButtonFrame, {icon='hide', size={22,22}, isType2=true})

    function TrackButton:set_evnet()
        self:RegisterEvent('PLAYER_FLAGS_CHANGED')--AFK
        self:RegisterEvent('PET_BATTLE_OPENING_DONE')--宠物战斗
        self:RegisterEvent('PET_BATTLE_CLOSE')
        self:RegisterEvent('PET_BATTLE_PET_ROUND_RESULTS')
        self:RegisterEvent('PET_BATTLE_FINAL_ROUND')
        self:RegisterEvent('PET_BATTLE_CAPTURED')
        self:RegisterEvent('PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE')
        self:RegisterEvent('PLAYER_ENTERING_WORLD')--副本,杀怪,死亡
        self:RegisterEvent('PLAYER_REGEN_DISABLED')
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
    end

    function TrackButton:set_instance_evnet()
        local tab={
            'PLAYER_DEAD',--死亡
            'PLAYER_UNGHOST',
            'PLAYER_ALIVE',
            'UNIT_FLAGS',--杀怪
        }
        if IsInInstance() then
            FrameUtil.RegisterFrameForEvents(self, tab)
        else
            FrameUtil.UnregisterFrameForEvents(self, tab)
        end
    end

    function TrackButton:set_Point()
        self:ClearAllPoints()
        if Save.textFramePoint then
            self:SetPoint(Save.textFramePoint[1], UIParent, Save.textFramePoint[3], Save.textFramePoint[4], Save.textFramePoint[5])
        else
            self:SetPoint('BOTTOMLEFT', CombatButton, 'BOTTOMRIGHT')
        end
    end

    TrackButton:RegisterForDrag("RightButton")
    TrackButton:SetMovable(true)
    TrackButton:SetClampedToScreen(true)
    TrackButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    TrackButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.textFramePoint={self:GetPoint(1)}
        Save.textFramePoint[2]=nil
    end)

    TrackButton:SetScript("OnMouseUp", ResetCursor)
    TrackButton:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    TrackButton:SetScript("OnClick", function(self, d)--清除
        if d=='LeftButton' and not IsModifierKeyDown() then
            self.text:SetText('')
        end
    end)

    function TrackButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.textScale or 1),'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        set_Tooltips_Info()
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.addName, e.cn(addName))
        e.tips:Show()
    end

    TrackButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        CombatButton:SetButtonState('PUSHED')
    end)
    TrackButton:SetScript("OnLeave", function()
        CombatButton:SetButtonState("NORMAL")
    end)
    TrackButton:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            local sacle=Save.textScale or 1
            if d==1 then
                sacle=sacle+0.05
            elseif d==-1 then
                sacle=sacle-0.05
            end
            sacle=sacle>4 and 4 or sacle
            sacle=sacle<0.4 and 0.4 or sacle
            Save.textScale=sacle
            self:set_text_scale()
            self:set_tooltip()
            print(e.addName, e.cn( addName), e.onlyChinese and '缩放' or UI_SCALE,"|cnGREEN_FONT_COLOR:", sacle)
        end
    end)

    TrackButton:SetScript('OnEvent', function(self, event, arg1)
        if event=='PLAYER_FLAGS_CHANGED' then--AFK
            TrackButton_Frame_Init_Date()--初始, 数据

        elseif event=='PET_BATTLE_OPENING_DONE' then
            TrackButton_Frame_Init_Date()--初始, 数据

        elseif event=='PET_BATTLE_PVP_DUEL_REQUESTED' then--宠物战斗
            PetRound.PVP =true
            set_Pet_Text()--宠物战斗, 设置显示内容
        elseif (event=='PET_BATTLE_PET_ROUND_RESULTS' or event=='PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE') and arg1 then
            PetRound.round=arg1
            set_Pet_Text()--宠物战斗, 设置显示内容
        elseif event=='PET_BATTLE_CAPTURED' and arg1 and arg1==2 then--捕获
            PetRound.capture=true
            set_Pet_Text()--宠物战斗, 设置显示内容
        elseif event=='PET_BATTLE_FINAL_ROUND' and arg1 then--结束
            if arg1==1 then--赢
                PetRound.win=true
            end
            set_Pet_Text()--宠物战斗, 设置显示内容
        elseif event=='PET_BATTLE_CLOSE' then
            TrackButton_Frame_Init_Date()--初始, 数据

        elseif event=='PLAYER_ENTERING_WORLD' then--副本,杀怪,死亡
            TrackButton_Frame_Init_Date()--初始, 数据
            self:set_instance_evnet()

        elseif event=='PLAYER_DEAD' or event=='PLAYER_UNGHOST' or event=='PLAYER_ALIVE' then
            if event=='PLAYER_DEAD' and not OnInstanceDeadCheck then
                InstanceDate.dead= InstanceDate.dead +1
                Save.ins.dead= Save.ins.dead +1
                OnInstanceDeadCheck= true
            else
                OnInstanceDeadCheck=nil
            end
        elseif event=='UNIT_FLAGS' and arg1 then--杀怪,数量
            if arg1:find('nameplate') and UnitIsEnemy(arg1, 'player') and UnitIsDead(arg1) then
                if CombatButton.isInPvPInstance and UnitIsPlayer(arg1) or not CombatButton.isInPvPInstance then
                    InstanceDate.kill= InstanceDate.kill +1
                    Save.ins.kill= Save.ins.kill +1
                end
            end
        elseif event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED' then
            TrackButton_Frame_Init_Date()--初始, 数据
        end
    end)

    TrackButton.text= WoWTools_LabelMixin:Create(TrackButton, {color=true})
    TrackButton.text:SetPoint('BOTTOMLEFT')
    function TrackButton:set_text_scale()
        self.text:SetScale(Save.textScale or 1)
    end

    TrackButton.Frame=CreateFrame("Frame", nil, TrackButton)
    TrackButton.Frame:HookScript("OnUpdate", function (self, elapsed)
        self.elapsed = (self.elapsed or 0.3) + elapsed
        if self.elapsed > 0.3 then
            self.elapsed = 0
            set_TrackButton_Text()--设置显示内容
        end
    end)

    TrackButton:set_Point()
    TrackButton:set_text_scale()
    TrackButton:set_instance_evnet()
    TrackButton:set_evnet()
    TrackButton_Frame_Init_Date()--初始, 数据
end



















local function Init_Menu(self, root)
    local sub, sub2
    local isInCombat= UnitAffectingCombat('player')

    sub=root:CreateCheckbox(e.onlyChinese and '战斗信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, INFO), function()
        return not Save.disabledText
    end, function()
        self:set_Click()
    end)

    sub:CreateCheckbox((e.onlyChinese and '时间类型' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TIME_LABEL:gsub(':',''), TYPE))..' '.. SecondsToTime(35), function()
        return Save.timeTypeText
    end, function()
        Save.timeTypeText= not Save.timeTypeText and true or nil
    end)

    sub2=sub:CreateCheckbox((e.onlyChinese and '战斗时间' or COMBAT)..'|A:communities-icon-chat:0:0|a|cnGREEN_FONT_COLOR:'..Save.SayTime, function()
        return not Save.disabledSayTime
    end, function()
        Save.disabledSayTime= not Save.disabledSayTime and true or false
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '说' or SAY)
    end)
    
    sub2:CreateButton(e.onlyChinese and '设置' or SETTINGS, function()
        StaticPopup_Show('WoWTools_EditText',
        addName
        ..'|n|n'.. (e.onlyChinese and '时间戳' or EVENTTRACE_TIMESTAMP)..' '..(e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
        ..'|n|n>= 60 '..e.GetEnabeleDisable(true),
        nil,
        {
            OnShow=function(s)
                s.editBox:SetNumeric(true)
                s.editBox:SetNumber(Save.SayTime or 120)
            end,
            OnHide=function(s)
                s.editBox:SetNumeric(false)
            end,
            SetValue= function(s)
                local num=s.editBox:GetNumber()
                WoWTools_ChatMixin:Chat(WoWTools_TimeMixin:SecondsToClock(num), nil, nil)
                Save.SayTime= num
            end,
            EditBoxOnTextChanged=function(s)
                local num= s:GetNumber() or 0
                s:GetParent().button1:SetEnabled(num>=60 and num<2147483647)
            end,
        }
    )
        return MenuResponse.Open
    end)

    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save.SayTime
        end, setValue=function(value)
            Save.SayTime= math.floor(value)
            WoWTools_ChatMixin:Chat(WoWTools_TimeMixin:SecondsToClock(Save.SayTime), nil, nil)
        end,
        name= e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS,
        minValue=60,
        maxValue=600,
        step=1,
        bit=nil,
        tooltip=function(tooltip)
            tooltip:AddLine(e.onlyChinese and '时间戳' or EVENTTRACE_TIMESTAMP)
        end,
    })
    sub2:CreateSpacer()

    --[[sub2:CreateButton(e.onlyChinese and '设置' or SETTINGS, function()
        StaticPopup_Show('WoWToolsChatButtonCombatSayTime')
        return MenuResponse.Open
    end)]]

    sub:CreateDivider()
    sub:CreateButton(e.onlyChinese and '重置位置' or RESET_POSITION, function()
        Save.textFramePoint=nil
        if TrackButton then
            TrackButton:set_Point()
        end
        print(e.addName, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        return MenuResponse.Open
    end)

    sub2=sub:CreateButton((isInCombat and '|cff9e9e9e' or '')..(e.onlyChinese and '全部清除' or CLEAR_ALL), function()
        if IsShiftKeyDown() and not UnitAffectingCombat('player') then
            Save=nil
            WoWTools_Mixin:Reload()
        end
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine('Shift+'..e.Icon.left)
        tooltip:AddLine(e.onlyChinese and '重新加载UI' or RELOADUI)
    end)





--缩放
    root:CreateDivider()
    sub2, sub= WoWTools_MenuMixin:ScaleCheck(root, function()
        return Save.inCombatScale
    end, function(value)
        Save.inCombatScale= value
        CombatButton:set_Sacle_InCombat(true)
        C_Timer.After(3, function()
            CombatButton:set_Sacle_InCombat(UnitAffectingCombat('player'))
        end)
    end,
    nil,
    function()
        return Save.combatScale
    end, function()
        Save.combatScale= not Save.combatScale and true or nil
        CombatButton:set_Sacle_InCombat(UnitAffectingCombat('player'))
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        self:set_Sacle_InCombat(UnitAffectingCombat('player'))
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
    end)

--总游戏时间
    local tab=e.WoWDate[e.Player.guid].Time
    sub=root:CreateCheckbox(e.onlyChinese and '总游戏时间'..((tab and tab.totalTime) and ': '..SecondsToTime(tab.totalTime) or '') or TIME_PLAYED_TOTAL:format((tab and tab.totalTime) and SecondsToTime(tab.totalTime) or ''), function()
        return Save.AllOnlineTime
    end, function ()
        Save.AllOnlineTime = not Save.AllOnlineTime and true or nil
        if Save.AllOnlineTime then
            RequestTimePlayed()
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(format(e.onlyChinese and '你在这个等级的游戏时间：%s' or TIME_PLAYED_LEVEL, ''))
    end)

    local timeAll=0
    local numPlayer=0
    for guid, tab2 in pairs(e.WoWDate or {}) do
        local time= tab2.Time and tab2.Time.totalTime
        if time and time>0 then
            numPlayer= numPlayer+1
            timeAll= timeAll + time
            sub:CreateButton(WoWTools_UnitMixin:GetPlayerInfo({guid=guid,  reName=true, reRealm=true, factionName=tab.faction})..'|A:socialqueuing-icon-clock:0:0|a  '..SecondsToTime(time), function()
                return MenuResponse.Open
            end)
        end
    end
    WoWTools_MenuMixin:SetGridMode(sub, numPlayer)

    if timeAll>0 then
        sub:CreateDivider()
        sub:CreateTitle((e.onlyChinese and '总计：' or FROM_TOTAL).. SecondsToTime(timeAll))

    end
end


































--####
--初始
--####
local function Init()
    --OnLineTime=GetTime()

    CombatButton.texture2=CombatButton:CreateTexture(nil, 'OVERLAY')
    CombatButton.texture2:SetAllPoints(CombatButton)
    CombatButton.texture2:AddMaskTexture(CombatButton.mask)
    CombatButton.texture2:SetColorTexture(1,0,0)
    CombatButton.texture2:SetShown(false)

    function CombatButton:set_texture()
        self.texture:SetAtlas(get_faction_texture())
        self.texture:SetDesaturated(Save.disabledText and true or false)--禁用/启用 TrackButton, 提示
    end

    function CombatButton:Is_In_Arena()--是否在战场
        self.isInPvPInstance= WoWTools_MapMixin:IsInPvPArea()--是否在，PVP区域中
    end

    function CombatButton:set_Sacle_InCombat(bat)--提示，战斗中
        self.texture2:SetShown(bat)
        if Save.combatScale then
            self:SetScale(bat and Save.inCombatScale or 1)
        end
    end

    function CombatButton:set_Click()
        Save.disabledText = not Save.disabledText and true or nil
        self:set_texture()
        Init_TrackButton()
    end


    CombatButton:SetupMenu(Init_Menu)
    function CombatButton:HandlesGlobalMouseEvent(_, event)
        return event == "GLOBAL_MOUSE_DOWN"-- and buttonName == "RightButton";
    end
    --[[CombatButton:SetScript('OnMouseDown',function(self, d)
        if d=='LeftButton' then
            if Save.On_Click_Show then
                self:set_frame_shown(not Frame:IsShown())
                e.tips:Hide()
            else
                send(self:get_emoji_text(),  self.chatFrameEditBox and 'LeftButton' or 'RightButton')
                self:set_tooltip()
            end
            self:CloseMenu()
        end
    end)]]
    --[[CombatButton:SetScript('OnMouseDown', function(self, d)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)]]

    CombatButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        set_Tooltips_Info()
        e.tips:Show()
        Set_TrackButton_Pushed(true)--TrackButton，提示
        self:state_enter()--Init_Menu)
    end)
    CombatButton:SetScript('OnLeave', function(self)
        Set_TrackButton_Pushed(false)--TrackButton，提示
        self:state_leave()
        e.tips:Hide()
    end)





    CombatButton:RegisterEvent('PLAYER_REGEN_DISABLED')
    CombatButton:RegisterEvent('PLAYER_REGEN_ENABLED')
    CombatButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    CombatButton:RegisterEvent('NEUTRAL_FACTION_SELECT_RESULT')

    CombatButton:SetScript("OnEvent", function(self, event)--提示，战斗中, 是否在战场
        if event=='PLAYER_REGEN_ENABLED' then
            self:set_Sacle_InCombat(false)--提示，战斗中
        elseif event=='PLAYER_REGEN_DISABLED' then
            self:set_Sacle_InCombat(true)
        elseif event=='PLAYER_ENTERING_WORLD' then
            self:Is_In_Arena()
        elseif event=='NEUTRAL_FACTION_SELECT_RESULT' then
            self:set_texture()
        end
    end)

    CombatButton:set_Sacle_InCombat(UnitAffectingCombat('player'))--提示，战斗中
    CombatButton:Is_In_Arena()--是否在战场    
    CombatButton:set_texture()

    if Save.AllOnlineTime or not e.WoWDate[e.Player.guid].Time.totalTime then--总游戏时间
        RequestTimePlayed()
    end

    if IsInInstance() and C_ChallengeMode.IsChallengeModeActive() then--挑战时，死亡，数据
        InstanceDate.dead= C_ChallengeMode.GetDeathCount() or 0
    end

    Init_TrackButton()
end






















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            addName= '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'..(e.onlyChinese and '战斗信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, INFO))
            Save= WoWToolsSave['ChatButton_Combat'] or Save
            CombatButton= WoWTools_ChatButtonMixin:CreateButton('Combat', addName)

            if Save.SayTime==0 then
                Save.disabledSayTime= true
                Save.SayTime=120
            end

            if CombatButton then--禁用Chat Button
                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_Combat']=Save
        end
    end
end)