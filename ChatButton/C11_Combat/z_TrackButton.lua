local function Save()
    return WoWToolsSave['ChatButton_Combat']
end
local function SaveLog()
    return WoWToolsPlayerDate['CombatTimeLog']
end

local OnCombatTime--战斗时间
local OnAFKTime--AFK时间
local OnPetTime--宠物战斗
local OnInstanceTime--副本

local LastText--最后时间提示
local OnInstanceDeadCheck--副本,死亡,测试点

local PetAll={num= 0,  win=0, capture=0}--宠物战斗,全部,数据
local PetRound={}--宠物战斗, 本次,数据
local InstanceDate={num= 0, time= 0, kill=0, dead=0}--副本数据{dead死亡,kill杀怪, map地图}
local IsInArena--是否在战场

local EventTab={
    'PLAYER_FLAGS_CHANGED',--AFK
    'PET_BATTLE_OPENING_DONE',--宠物战斗
    'PET_BATTLE_CLOSE',
    'PET_BATTLE_PET_ROUND_RESULTS',
    'PET_BATTLE_FINAL_ROUND',
    'PET_BATTLE_CAPTURED',
    'PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE',
    'PLAYER_ENTERING_WORLD',--副本,杀怪,死亡
    'PLAYER_REGEN_DISABLED',
    'PLAYER_REGEN_ENABLED',
}

local InstanceEventTab={
    'PLAYER_DEAD',--死亡
    'PLAYER_UNGHOST',
    'PLAYER_ALIVE',
    'UNIT_FLAGS',--杀怪
}





function WoWTools_CombatMixin:Set_Combat_Tooltip(tooltip)
    if  Save().disabledText then
        return
    end

    local log= SaveLog()

    tooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '战斗' or COMBAT)
        ..'|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a'
        ..SecondsToTime(log.bat.time),

        log.bat.num
        ..' '
        ..(WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    )
    tooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '宠物' or PET)
        ..'|A:worldquest-icon-petbattle:0:0|a'
        ..log.pet.win..'|r/'..log.pet.num
        ..' |T646379:0|t'..log.pet.capture,

        PetAll.win..'/'..PetAll.num
    )

    tooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '离开' or AFK)
        ..'|A:socialqueuing-icon-clock:0:0|a'
        ..SecondsToTime(log.afk.time),

        log.afk.num..' '
        ..(WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    )
    tooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE)
        ..'|A:BuildanAbomination-32x32:0:0|a'
        ..log.ins.kill
        ..'|A:poi-soulspiritghost:0:0|a'..log.ins.dead,

        log.ins.num..' '
        ..(WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
        ..' |A:CrossedFlagsWithTimer:0:0|a'
        ..WoWTools_TimeMixin:Info(log.ins.time)
    )
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '在线' or GUILD_ONLINE_LABEL)..'|A:socialqueuing-icon-clock:0:0|a', SecondsToTime(GetSessionTime()))--time)---在线时间
    local tab=WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Time
    tooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '总计' or TOTAL)..'|A:socialqueuing-icon-clock:0:0|a',  tab.totalTime and SecondsToTime(tab.totalTime))
    tooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '本周%s' or CURRENCY_THIS_WEEK):format('CD')..' ('..format(WoWTools_DataMixin.onlyChinese and '第%d周' or WEEKS_ABBR, WoWTools_DataMixin.Player.Week)..date('%Y')..')',
        SecondsToTime(C_DateAndTime.GetSecondsUntilWeeklyReset())
    )
end

















local chatStarTime
local function Set_Text(self)--设置显示内容
    local text
    local timeTypeText= Save().timeTypeText
 
--战斗时间
    if OnCombatTime then
        local combat, sec = WoWTools_TimeMixin:Info(OnCombatTime, not timeTypeText)
--喊话
        if not Save().disabledSayTime then
            sec=math.floor(sec)
            if sec ~= chatStarTime and sec > 0 and sec%Save().SayTime==0  then--IsInInstance()
                chatStarTime=sec
                WoWTools_ChatMixin:Chat(WoWTools_TimeMixin:SecondsToClock(sec), nil, nil)
            end
        end
        text= '|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a|cnWARNING_FONT_COLOR:'..combat..'|r'
    end

    if OnAFKTime then
        text= text and text..'|n' or ''
        text= text .. (WoWTools_DataMixin.onlyChinese and '离开' or AFK)..'|A:socialqueuing-icon-clock:0:0|a'..WoWTools_TimeMixin:Info(OnAFKTime, not timeTypeText)
    end

    if OnPetTime then
        text= text and text..'|n' or ''
        text= text ..(PetRound.text or '|TInterface\\Icons\\PetJournalPortrait:0|t')
            ..' '..WoWTools_TimeMixin:Info(OnPetTime, not timeTypeText)
    end

    if OnInstanceTime then
        text= text and text..'|n' or LastText and (LastText..'|n') or ''
        text=text..'|A:BuildanAbomination-32x32:0:0|a'
            ..InstanceDate.kill..'|A:poi-soulspiritghost:0:0|a'
            ..InstanceDate.dead..'|A:CrossedFlagsWithTimer:0:0|a'
            ..WoWTools_TimeMixin:Info(OnInstanceTime, not timeTypeText)
    end
    text= text or LastText

    self.text:SetText(text or '')
    self.texture:SetShown(not text)
    self.Bg:SetShown(text)
end











local function set_Pet_Text()--宠物战斗, 设置显示内容
    local text= format(WoWTools_DataMixin.onlyChinese and '%d轮' or PET_BATTLE_COMBAT_LOG_NEW_ROUND, PetRound.round or 0)
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













local function Init_Date(self)--初始, 数据
    local time=GetTime()
    local log= SaveLog()
    local timeTypeText= Save().timeTypeText

--AFK时间
    if UnitIsAFK('player') then
        if not OnAFKTime then--AFk时,播放声音
            OnAFKTime= time
            WoWTools_DataMixin:PlaySound(SOUNDKIT.READY_CHECK)--播放, 声音
        end
        LastText=nil

    elseif OnAFKTime then
        local text, sec = WoWTools_TimeMixin:Info(OnAFKTime, not timeTypeText)
        LastText= '|A:socialqueuing-icon-clock:0:0|a|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '离开' or AFK)..text..'|r'
        log.afk.num= log.afk.num + 1
        log.afk.time= log.afk.time + sec
        print(
            WoWTools_CombatMixin.addName..WoWTools_DataMixin.Icon.icon2,
            LastText
        )
        OnAFKTime=nil
    end

--战斗时间
    if PlayerIsInCombat() then
        OnCombatTime= OnCombatTime or time
        LastText=nil
    elseif OnCombatTime then
        local text, sec=WoWTools_TimeMixin:Info(OnCombatTime, not timeTypeText)
        LastText= '|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a|cnGREEN_FONT_COLOR:'..text..'|r'
        if sec>10 then
            log.bat.num= log.bat.num + 1
            log.bat.time= log.bat.time + sec
        end
        OnCombatTime=nil
        chatStarTime=nil
    end

--宠物战斗
    if C_PetBattles.IsInBattle() then
        OnPetTime= OnPetTime or time
        LastText=nil
    elseif OnPetTime then
        if PetRound.win then--赢
            PetAll.win= PetAll.win +1
            log.pet.win= log.pet.win +1
            if PetRound.capture then--捕获
                PetAll.capture= PetAll.capture +1
                log.pet.capture= log.pet.capture +1
            end
        end
        PetAll.num= PetAll.num +1--次数
        log.pet.num= log.pet.num +1

        LastText=(PetRound.text or '')..(PetRound.win and '|T646379:0|t' or ' ')..WoWTools_TimeMixin:Info(OnPetTime, not timeTypeText)
        if PetRound.win then
            LastText='|cnGREEN_FONT_COLOR:'..LastText..'|r'
        else
            LastText='|cnWARNING_FONT_COLOR:'..LastText..'|r'
        end
        PetRound={}
        OnPetTime=nil
        print(
            WoWTools_CombatMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_DataMixin.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE,
            LastText,
            log.pet.win..'/'..log.pet.num,
            (log.pet.capture>0 and log.pet.capture..' |T646379:0|t' or '')
        )
    end

    if IsInInstance() then--副本
        OnInstanceTime= OnInstanceTime or time
        InstanceDate.map= InstanceDate.map or WoWTools_MapMixin:GetUnit('player')


    elseif OnInstanceTime then
        local text, sec= WoWTools_TimeMixin:Info(OnInstanceTime, not log.timeTypeText)
        if sec>60 or InstanceDate.dead>0 or InstanceDate.kill>0 then
            log.ins.num= log.ins.num +1
            log.ins.time= log.ins.time +sec
        end
        LastText='|cnGREEN_FONT_COLOR:|A:CrossedFlagsWithTimer:0:0|a'
            ..text
            ..' |A:BuildanAbomination-32x32:0:0|a'
            ..InstanceDate.kill
            ..' |A:poi-soulspiritghost:0:0|a'
            ..InstanceDate.dead..'|r'

        print(
            WoWTools_CombatMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_TextMixin:CN(InstanceDate.map) or (WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE),
            text
        )

        InstanceDate={time= 0, kill=0, dead=0}--副本数据{dead死亡,kill杀怪, map地图}
        OnInstanceTime=nil
    end

    if OnAFKTime or OnCombatTime or OnPetTime or OnInstanceTime then
        self.Frame:SetShown(true)
    else
        self.Frame:SetShown(false)
        Set_Text(self)
    end
end








local function Rest_Data(self)
    OnCombatTime= nil--战斗时间
    OnAFKTime= nil--AFK时间
    OnPetTime= nil--宠物战斗
    OnInstanceTime= nil--副本

    LastText= nil

    PetAll={num= 0,  win=0, capture=0}--宠物战斗,全部,数据
    PetRound={}--宠物战斗, 本次,数据
    InstanceDate={num= 0, time= 0, kill=0, dead=0}--副本数据{dead死亡,kill杀怪, map地图}

    if IsInInstance() and C_ChallengeMode.IsChallengeModeActive() then--挑战时，死亡，数据
        InstanceDate.dead= C_ChallengeMode.GetDeathCount() or 0
    end

    Init_Date(self)
end












local function Init_Menu(_, root)
    local self= _G['WoWToolsChatCombatTrackButton']
    if not self then
        return
    end

    local sub, sub2

    root:CreateButton(
        '|cnWARNING_FONT_COLOR:'
        ..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
    function()

        Rest_Data(self)

        print(
            WoWTools_CombatMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_DataMixin.onlyChinese and '重置完成' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RESET, COMPLETE)
        )
        return MenuResponse.Open
    end)

    root:CreateDivider()

    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '时间类型' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TIME_LABEL:gsub(HEADER_COLON,''), TYPE))..' '.. SecondsToTime(35),
    function()
        return Save().timeTypeText
    end, function()
        Save().timeTypeText= not Save().timeTypeText and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_TimeMixin:SecondsToClock(35))
    end)

--战斗时间
    sub=root:CreateCheckbox((WoWTools_DataMixin.onlyChinese and '战斗时间' or COMBAT)..'|A:communities-icon-chat:0:0|a|cnGREEN_FONT_COLOR:'..Save().SayTime, function()
        return not Save().disabledSayTime
    end, function()
        Save().disabledSayTime= not Save().disabledSayTime and true or false
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '说' or SAY)
    end)


--战斗时间，说
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().SayTime or 120
        end, setValue=function(value)
            Save().SayTime= value
        end,
        name= WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS,
        minValue=60,
        maxValue=600,
        step=1,
        bit=nil,
        tooltip=function(tooltip)
            tooltip:AddDoubleLine(WoWTools_TimeMixin:SecondsToClock(Save().SayTime), WoWTools_DataMixin.onlyChinese and '时间戳' or EVENTTRACE_TIMESTAMP)
        end,
    })
    sub:CreateSpacer()
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '测试' or 'Test',
    function()
        WoWTools_ChatMixin:Chat(WoWTools_TimeMixin:SecondsToClock(Save().SayTime), nil, nil)
        return MenuResponse.Open
    end)
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '重置' or RESET,
    function()
        Save().SayTime= 120
        return MenuResponse.Refresh
    end)
--BG Alpha
    WoWTools_MenuMixin:BgAplha(root, function()
        return Save().textAlpha or 0.5
    end, function(value)
        Save().textAlpha= value
        self:settings()
    end)

--Text 缩放
    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().textScale or 1
    end, function(value)
        Save().textScale= value
        self:settings()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, root, function(strata)
        if self then
            return self:GetFrameStrata()==strata
        else
            local s= Save().trckStrata or 'MEDIUM'
            return s== strata
        end
    end, function(strata)
        Save().trckStrata= strata
        self:settings()
        return MenuResponse.Refresh
    end)


    root:CreateDivider()
    sub= WoWTools_ChatMixin:Open_SettingsPanel(root, WoWTools_CombatMixin.addName)

--重置位置
    local resetText= WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
    sub:CreateButton(
        (Save().textFramePoint and '' or '|cff626262')
        ..resetText,
    function()
        Save().textFramePoint=nil
        self:set_point()
        print(
            WoWTools_CombatMixin.addName..WoWTools_DataMixin.Icon.icon2, resetText,
            WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE
        )
        return MenuResponse.Open
    end)

    sub:CreateDivider()
    local clearText= WoWTools_DataMixin.onlyChinese and '清除记录' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RESET, EVENTTRACE_LOG_HEADER)
    sub:CreateButton(
        clearText,
    function()
        StaticPopup_Show('WoWTools_OK',
            WoWTools_CombatMixin.addName
            ..'|n|n'
            ..(clearText),
            nil,
            {SetValue=function()
                Rest_Data(self)

                WoWToolsPlayerDate['CombatTimeLog']= {
                    bat={num= 0, time= 0},--战斗数据
                    pet={num= 0, win=0, capture=0},
                    ins={num= 0, time= 0, kill=0, dead=0},
                    afk={num= 0, time= 0},
                }
                print(
                    WoWTools_CombatMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    clearText,
                    WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE
                )
            end}
        )
        return MenuResponse.Open
    end)

end















local function Init()--设置显示内容, 父框架TrackButton, 内容btn.text
    if Save().disabledText then
        return
    end

    local btn= CreateFrame('Button', 'WoWToolsChatCombatTrackButton', UIParent, 'WoWToolsButtonTemplate') --[[WoWTools_ButtonMixin:Cbtn(WoWToolsChatButtonFrame, {
        name='WoWToolsChatCombatTrackButton',
        size=22,
        icon='hide'
    })]]
    btn.text= btn:CreateFontString(nil, 'BORDER', 'ChatFontNormal')-- WoWTools_LabelMixin:Create(TrackButton, {color=true})
    btn.text:SetTextColor(PlayerUtil.GetClassColor():GetRGB())
    btn.text:SetPoint('BOTTOMLEFT')

    btn.texture= btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetAtlas('Adventure-MissionEnd-Line')
    btn.texture:SetPoint('BOTTOMLEFT')
    btn.texture:SetSize(22,10)
    WoWTools_TextureMixin:SetAlphaColor(btn.texture, true, nil, 0.5)

    btn.Bg= btn:CreateTexture(nil, "BACKGROUND")
    btn.Bg:SetColorTexture(0,0,0)
    btn.Bg:SetPoint('TOPLEFT', btn.text, -2, 2)
    btn.Bg:SetPoint('BOTTOMRIGHT', btn.text, 2, -2)

    function btn:set_event()
        self:UnregisterAllEvents()
        if self:IsShown() then
            FrameUtil.RegisterFrameForEvents(self, EventTab)

            if IsInInstance() then
                FrameUtil.RegisterFrameForEvents(self, InstanceEventTab)
            end
        end
    end

    function btn:set_point()
        self:ClearAllPoints()
        local p= Save().textFramePoint
        if p and p[1] then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint('BOTTOMLEFT', WoWTools_ChatMixin:GetButtonForName('Combat'), 'BOTTOMRIGHT')
        end
    end

    btn:RegisterForDrag("RightButton")
    btn:SetMovable(true)
    btn:SetClampedToScreen(true)
    btn:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().textFramePoint={self:GetPoint(1)}
            Save().textFramePoint[2]=nil
        end
    end)

    btn:SetScript("OnMouseUp", ResetCursor)
    btn:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    --[[btn:SetScript("OnClick", function(self, d)--清除
        if d=='LeftButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)
            --self.text:SetText('')
        end
    end)]]

    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddLine(' ')
        WoWTools_CombatMixin:Set_Combat_Tooltip(GameTooltip)
        GameTooltip:Show()
    end

    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
        WoWTools_ChatMixin:GetButtonForName('Combat'):SetButtonState('PUSHED')
    end)
    btn:SetScript("OnLeave", function()
        WoWTools_ChatMixin:GetButtonForName('Combat'):SetButtonState('NORMAL')
    end)


    btn:SetScript('OnEvent', function(self, event, arg1)
        if event=='PLAYER_FLAGS_CHANGED' then--AFK
            Init_Date(self)--初始, 数据

        elseif event=='PET_BATTLE_OPENING_DONE' then
            Init_Date(self)--初始, 数据

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
            Init_Date(self)--初始, 数据

        elseif event=='PLAYER_ENTERING_WORLD' then--副本,杀怪,死亡
            Init_Date(self)--初始, 数据
            self:set_event()
            IsInArena= WoWTools_MapMixin:IsInPvPArea()--是否在，PVP区域中

        elseif event=='PLAYER_DEAD' or event=='PLAYER_UNGHOST' or event=='PLAYER_ALIVE' then
            if event=='PLAYER_DEAD' and not OnInstanceDeadCheck then
                InstanceDate.dead= InstanceDate.dead +1
                SaveLog().ins.dead= SaveLog().ins.dead +1
                OnInstanceDeadCheck= true
            else
                OnInstanceDeadCheck=nil
            end
        elseif event=='UNIT_FLAGS' then--杀怪,数量
            if canaccessvalue(arg1) and arg1 and arg1:find('nameplate') and UnitIsEnemy(arg1, 'player') and UnitIsDead(arg1) then
                if not IsInArena or UnitIsPlayer(arg1) then
                    InstanceDate.kill= InstanceDate.kill +1
                    SaveLog().ins.kill= SaveLog().ins.kill +1
                end
            end
        elseif event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED' then
            Init_Date(self)--初始, 数据
        end
    end)


    function btn:settings()
        self.text:SetScale(Save().textScale or 1)
        self.Bg:SetAlpha(Save().textAlpha or 0.5)
        self:SetFrameStrata(Save().trckStrata or 'MEDIUM')
        if IsInInstance() and C_ChallengeMode.IsChallengeModeActive() then--挑战时，死亡，数据
            InstanceDate.dead= C_ChallengeMode.GetDeathCount() or 0
        end
    end

    btn.Frame=CreateFrame("Frame", nil, btn)
    btn.Frame:HookScript("OnUpdate", function (self, elapsed)
        self.elapsed = (self.elapsed or 0.3) + elapsed
        if self.elapsed > 0.3 then
            self.elapsed = 0
            Set_Text(self:GetParent())--设置显示内容
        end
    end)

    btn.Frame:SetScript('OnHide', function(self)
        self.elapsed= nil
    end)

    btn:set_point()
    btn:set_event()
    btn:settings()

    Init_Date(btn)--初始, 数据

    Init=function()
        local show= not Save().disabledText
        btn:SetShown(show)
        if show then
            btn:set_event()
            Init_Date(btn)--初始, 数据
        else
            btn.text:SetText('')
        end
    end
end












function WoWTools_CombatMixin:Init_TrackButton()
    Init()
end
function WoWTools_CombatMixin:Init_TrackMenu(...)
    Init_Menu(...)
end
