
local e= select(2, ...)
local function Save()
    return WoWTools_CombatMixin.Save
end


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
    tooltip:AddDoubleLine(
        (e.onlyChinese and '战斗' or COMBAT)..'|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a'..SecondsToTime(self.Save.bat.time),
        self.Save.bat.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    )
    tooltip:AddDoubleLine(
        (e.onlyChinese and '宠物' or PET)..'|A:worldquest-icon-petbattle:0:0|a'..self.Save.pet.win..'|r/'..self.Save.pet.num..' |T646379:0|t'..self.Save.pet.capture,
        PetAll.win..'/'..PetAll.num
    )
        --(PetAll.num>0 and PetAll.win..'/'..PetAll.num or (e.onlyChinese and '宠物' or PET))..'|A:worldquest-icon-petbattle:0:0|a'..self.Save.pet.win..'|r/'..self.Save.pet.num,
        --self.Save.pet.capture..' |T646379:0|t'
  
    tooltip:AddDoubleLine(
        (e.onlyChinese and '离开' or AFK)..'|A:socialqueuing-icon-clock:0:0|a'..SecondsToTime(self.Save.afk.time),
        self.Save.afk.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    )
    tooltip:AddDoubleLine(
        (e.onlyChinese and '副本' or INSTANCE)..'|A:BuildanAbomination-32x32:0:0|a'..self.Save.ins.kill..'|A:poi-soulspiritghost:0:0|a'..self.Save.ins.dead,
        self.Save.ins.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)..' |A:CrossedFlagsWithTimer:0:0|a'..WoWTools_TimeMixin:Info(self.Save.ins.time)
    )
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine((e.onlyChinese and '在线' or GUILD_ONLINE_LABEL)..'|A:socialqueuing-icon-clock:0:0|a', SecondsToTime(GetSessionTime()))--time)---在线时间
    local tab=e.WoWDate[e.Player.guid].Time
    tooltip:AddDoubleLine((e.onlyChinese and '总计' or TOTAL)..'|A:socialqueuing-icon-clock:0:0|a',  tab.totalTime and SecondsToTime(tab.totalTime))
    tooltip:AddDoubleLine(
        (e.onlyChinese and '本周%s' or CURRENCY_THIS_WEEK):format('CD')..' ('..format(e.onlyChinese and '第%d周' or WEEKS_ABBR, e.Player.week)..date('%Y')..')',
        SecondsToTime(C_DateAndTime.GetSecondsUntilWeeklyReset())
    )
end

















local chatStarTime
local function set_TrackButton_Text()--设置显示内容
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
        text= '|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a|cnRED_FONT_COLOR:'..combat..'|r'
    end

    if OnAFKTime then
        text= text and text..'|n' or ''
        text= text .. (e.onlyChinese and '离开' or AFK)..'|A:socialqueuing-icon-clock:0:0|a'..WoWTools_TimeMixin:Info(OnAFKTime, not Save().timeTypeText)
    end

    if OnPetTime then
        text= text and text..'|n' or ''
        text= text ..(PetRound.text or '|TInterface\\Icons\\PetJournalPortrait:0|t')..' '..WoWTools_TimeMixin:Info(OnPetTime, not Save().timeTypeText)
    end

    if OnInstanceTime then
        text= text and text..'|n' or LastText and (LastText..'|n') or ''
        text=text..'|A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..'|A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|A:CrossedFlagsWithTimer:0:0|a'..WoWTools_TimeMixin:Info(OnInstanceTime, not Save().timeTypeText)
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













local function TrackButton_Frame_Init_Date(self)--初始, 数据
    local time=GetTime()
    local save= Save()
    if UnitIsAFK('player') then
        if not OnAFKTime then--AFk时,播放声音
            OnAFKTime= time
            e.PlaySound(SOUNDKIT.READY_CHECK)--播放, 声音
        end
        LastText=nil

    elseif OnAFKTime then
        local text, sec = WoWTools_TimeMixin:Info(OnAFKTime, not save.timeTypeText)
        LastText= '|A:socialqueuing-icon-clock:0:0|a|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '离开' or AFK)..text..'|r'
        save.afk.num= save.afk.num + 1
        save.afk.time= save.afk.time + sec
        print(WoWTools_Mixin.addName, WoWTools_CombatMixin.addName, LastText)
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
            LastText='|cnRED_FONT_COLOR:'..LastText..'|r'
        end
        print(WoWTools_Mixin.addName,  WoWTools_CombatMixin.addName, e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE, LastText, save.pet.win..'/'..save.pet.num, (save.pet.capture>0 and save.pet.capture..' |T646379:0|t' or ''));

        PetRound={}
        OnPetTime=nil
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
        LastText='|cnGREEN_FONT_COLOR:|A:CrossedFlagsWithTimer:0:0|a'..text..' |A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..' |A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|r'
        print(WoWTools_Mixin.addName, InstanceDate.map or e.onlyChinese and '副本' or INSTANCE, text)

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















local function Set_Event()
    if not TrackButton:IsShown() then
        TrackButton:UnregisterAllEvents()
    else
        FrameUtil.RegisterFrameForEvents(TrackButton, EventTab)
    end
end








local function Init()--设置显示内容, 父框架TrackButton, 内容btn.text
    if Save().disabledText or TrackButton then
        if TrackButton then
            if Save().disabledText then
                TrackButton.text:SetText('')
            else
                TrackButton:set_instance_evnet()
                TrackButton_Frame_Init_Date(TrackButton)--初始, 数据
            end
            TrackButton:SetShown(not Save().disabledText)
            Set_Event()
        end
        return
    end

    TrackButton= WoWTools_ButtonMixin:Cbtn(WoWToolsChatButtonFrame, {size=22, icon='hide'})
    WoWTools_CombatMixin.TrackButton= TrackButton

    TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')
    TrackButton.texture:SetAtlas('Adventure-MissionEnd-Line')
    TrackButton.texture:SetAlpha(0.3)
    TrackButton.texture:SetPoint('BOTTOMLEFT')
    TrackButton.texture:SetSize(22,10)

    TrackButton.text= WoWTools_LabelMixin:Create(TrackButton, {color=true})
    TrackButton.text:SetPoint('BOTTOMLEFT', 0,8)

    function TrackButton:set_instance_evnet()
        if IsInInstance() then
            FrameUtil.RegisterFrameForEvents(self, InstanceEventTab)
        else
            FrameUtil.UnregisterFrameForEvents(self, InstanceEventTab)
        end
    end

    function TrackButton:set_Point()
        self:ClearAllPoints()
        local p= Save().textFramePoint
        if p then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint('BOTTOMLEFT', WoWTools_CombatMixin.CombatButton, 'BOTTOMRIGHT')
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
        Save().textFramePoint={self:GetPoint(1)}
        Save().textFramePoint[2]=nil
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
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        GameTooltip:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().textScale or 1),'Alt+'..e.Icon.mid)
        GameTooltip:AddLine(' ')
        WoWTools_CombatMixin:Set_Combat_Tooltip(GameTooltip)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_CombatMixin.addName)
        GameTooltip:Show()
    end

    TrackButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        WoWTools_CombatMixin.CombatButton:SetButtonState('PUSHED')
    end)
    TrackButton:SetScript("OnLeave", function()
        WoWTools_CombatMixin.CombatButton:SetButtonState('NORMAL')
    end)

    TrackButton:SetScript('OnMouseWheel', function(self, d)--缩放
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
            self:set_text_scale()
            self:set_tooltip()
            print(WoWTools_Mixin.addName, WoWTools_CombatMixin.addName, e.onlyChinese and '缩放' or UI_SCALE,"|cnGREEN_FONT_COLOR:", sacle)
        end
    end)

    TrackButton:SetScript('OnEvent', function(self, event, arg1)
        if event=='PLAYER_FLAGS_CHANGED' then--AFK
            TrackButton_Frame_Init_Date(self)--初始, 数据

        elseif event=='PET_BATTLE_OPENING_DONE' then
            TrackButton_Frame_Init_Date(self)--初始, 数据

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
            TrackButton_Frame_Init_Date(self)--初始, 数据

        elseif event=='PLAYER_ENTERING_WORLD' then--副本,杀怪,死亡
            TrackButton_Frame_Init_Date(self)--初始, 数据
            self:set_instance_evnet()
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
            TrackButton_Frame_Init_Date(self)--初始, 数据
        end
    end)


    function TrackButton:set_text_scale()
        self.text:SetScale(Save().textScale or 1)
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

    Set_Event()
    TrackButton_Frame_Init_Date(TrackButton)--初始, 数据



    if IsInInstance() and C_ChallengeMode.IsChallengeModeActive() then--挑战时，死亡，数据
        InstanceDate.dead= C_ChallengeMode.GetDeathCount() or 0
    end

end












function WoWTools_CombatMixin:Init_TrackButton()
    Init()
end


