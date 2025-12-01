
local function Save()
    return WoWToolsSave['ChatButton_Combat'] or {}
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

    tooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '战斗' or COMBAT)..'|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a'..SecondsToTime(Save().bat.time),
        Save().bat.num..' '..(WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    )
    tooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '宠物' or PET)..'|A:worldquest-icon-petbattle:0:0|a'..Save().pet.win..'|r/'..Save().pet.num..' |T646379:0|t'..Save().pet.capture,
        PetAll.win..'/'..PetAll.num
    )

    tooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '离开' or AFK)..'|A:socialqueuing-icon-clock:0:0|a'..SecondsToTime(Save().afk.time),
        Save().afk.num..' '..(WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    )
    tooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE)..'|A:BuildanAbomination-32x32:0:0|a'..Save().ins.kill..'|A:poi-soulspiritghost:0:0|a'..Save().ins.dead,
        Save().ins.num..' '..(WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)..' |A:CrossedFlagsWithTimer:0:0|a'..WoWTools_TimeMixin:Info(Save().ins.time)
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
    if OnCombatTime then--战斗时间
        local combat, sec = WoWTools_TimeMixin:Info(OnCombatTime, not Save().timeTypeText)
        if not Save().disabledSayTime then--喊话
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
        text= text .. (WoWTools_DataMixin.onlyChinese and '离开' or AFK)..'|A:socialqueuing-icon-clock:0:0|a'..WoWTools_TimeMixin:Info(OnAFKTime, not Save().timeTypeText)
    end

    if OnPetTime then
        text= text and text..'|n' or ''
        text= text ..(PetRound.text or '|TInterface\\Icons\\PetJournalPortrait:0|t')..' '..WoWTools_TimeMixin:Info(OnPetTime, not Save().timeTypeText)
    end

    if OnInstanceTime then
        text= text and text..'|n' or LastText and (LastText..'|n') or ''
        text=text..'|A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..'|A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|A:CrossedFlagsWithTimer:0:0|a'..WoWTools_TimeMixin:Info(OnInstanceTime, not Save().timeTypeText)
    end
    self.text:SetText(text or LastText or '')
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
    local save= Save()
    if UnitIsAFK('player') then
        if not OnAFKTime then--AFk时,播放声音
            OnAFKTime= time
            WoWTools_DataMixin:PlaySound(SOUNDKIT.READY_CHECK)--播放, 声音
        end
        LastText=nil

    elseif OnAFKTime then
        local text, sec = WoWTools_TimeMixin:Info(OnAFKTime, not save.timeTypeText)
        LastText= '|A:socialqueuing-icon-clock:0:0|a|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '离开' or AFK)..text..'|r'
        save.afk.num= save.afk.num + 1
        save.afk.time= save.afk.time + sec
        print(
            WoWTools_CombatMixin.addName..WoWTools_DataMixin.Icon.icon2,
            LastText
        )
        OnAFKTime=nil
    end

    if UnitAffectingCombat('player') then
        OnCombatTime= OnCombatTime or time
        LastText=nil
    elseif OnCombatTime then
        local text, sec=WoWTools_TimeMixin:Info(OnCombatTime, not save.timeTypeText)
        LastText= '|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a|cnGREEN_FONT_COLOR:'..text..'|r'
        if sec>10 then
            save.bat.num= save.bat.num + 1
            save.bat.time= save.bat.time + sec
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
            save.pet.win= save.pet.win +1
            if PetRound.capture then--捕获
                PetAll.capture= PetAll.capture +1
                save.pet.capture= save.pet.capture +1
            end
        end
        PetAll.num= PetAll.num +1--次数
        save.pet.num= save.pet.num +1

        LastText=(PetRound.text or '')..(PetRound.win and '|T646379:0|t' or ' ')..WoWTools_TimeMixin:Info(OnPetTime, not save.timeTypeText)
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
            save.pet.win..'/'..save.pet.num,
            (save.pet.capture>0 and save.pet.capture..' |T646379:0|t' or '')
        )
    end

    if IsInInstance() then--副本
        OnInstanceTime= OnInstanceTime or time
        InstanceDate.map= InstanceDate.map or WoWTools_MapMixin:GetUnit('player')


    elseif OnInstanceTime then
        local text, sec= WoWTools_TimeMixin:Info(OnInstanceTime, not save.timeTypeText)
        if sec>60 or InstanceDate.dead>0 or InstanceDate.kill>0 then
            save.ins.num= save.ins.num +1
            save.ins.time= save.ins.time +sec
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


















local function Init()--设置显示内容, 父框架TrackButton, 内容btn.text
    if Save().disabledText then
        return
    end

    local btn= CreateFrame('Button', 'WoWToolsChatCombatTrackButton', UIParent, 'WoWToolsButtonTemplate') --[[WoWTools_ButtonMixin:Cbtn(WoWToolsChatButtonFrame, {
        name='WoWToolsChatCombatTrackButton',
        size=22,
        icon='hide'
    })]]

    btn.texture= btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetAtlas('Adventure-MissionEnd-Line')
    btn.texture:SetAlpha(0.3)
    btn.texture:SetPoint('BOTTOMLEFT')
    btn.texture:SetSize(22,10)

    btn.text= btn:CreateFontString(nil, 'BORDER', 'ChatFontNormal')-- WoWTools_LabelMixin:Create(TrackButton, {color=true})
    btn.text:SetTextColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
    btn.text:SetPoint('BOTTOMLEFT', 0, 8)

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

    function btn:set_Point()
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
    btn:SetScript("OnMouseDown", function(_, d)
        if d=='RightButton' and IsAltKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    btn:SetScript("OnClick", function(self, d)--清除
        if d=='LeftButton' and not IsModifierKeyDown() then
            self.text:SetText('')
        end
    end)

    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().textScale or 1),'Alt+'..WoWTools_DataMixin.Icon.mid)
        GameTooltip:AddLine(' ')
        WoWTools_CombatMixin:Set_Combat_Tooltip(GameTooltip)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CombatMixin.addName)
        GameTooltip:Show()
    end

    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
        WoWTools_ChatMixin:GetButtonForName('Combat'):SetButtonState('PUSHED')
    end)
    btn:SetScript("OnLeave", function()
        WoWTools_ChatMixin:GetButtonForName('Combat'):SetButtonState('NORMAL')
    end)

    --[[btn:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            local sacle=Save().textScale or 1
            if d==1 then
                sacle=sacle+0.05
            elseif d==-1 then
                sacle=sacle-0.05
            end
            sacle=sacle>4 and 4 or sacle
            sacle=sacle<0.4 and 0.4 or sacle
            Save().textScale=sacle
            self:settings()
            self:set_tooltip()
        end
    end)]]

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
                Save().ins.dead= Save().ins.dead +1
                OnInstanceDeadCheck= true
            else
                OnInstanceDeadCheck=nil
            end
        elseif event=='UNIT_FLAGS' and arg1 then--杀怪,数量
            if arg1:find('nameplate') and UnitIsEnemy(arg1, 'player') and UnitIsDead(arg1) then
                if IsInArena and UnitIsPlayer(arg1) or not IsInArena then
                    InstanceDate.kill= InstanceDate.kill +1
                    Save().ins.kill= Save().ins.kill +1
                end
            end
        elseif event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED' then
            Init_Date(self)--初始, 数据
        end
    end)


    function btn:settings()
        self.text:SetScale(Save().textScale or 1)
        self.Bg:SetAlpha(Save().textAlpha or 0.5)
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

    btn:set_Point()
    btn:settings()
    btn:set_event()

    Init_Date(btn)--初始, 数据



    if IsInInstance() and C_ChallengeMode.IsChallengeModeActive() then--挑战时，死亡，数据
        InstanceDate.dead= C_ChallengeMode.GetDeathCount() or 0
    end


    Init=function()        
        local show= not Save().disabledText
print(btn)
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


