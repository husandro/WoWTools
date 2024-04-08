local id, e = ...
local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, TIMEMANAGER_TOOLTIP_TITLE)
local Save= {textScale=1.2,
        Say=120,
        --SayTime=120,--每隔

        --AllOnlineTime=true,--进入游戏时,提示游戏,时间

        bat={num= 0, time= 0},--战斗数据
        pet={num= 0,  win=0, capture=0},
        ins={num= 0, time= 0, kill=0, dead=0},
        afk={num= 0, time= 0},
        

        inCombatScale=1.3,--战斗中缩放
}
local button
local TrackButton


local OnLineTime--在线时间

local OnCombatTime--战斗时间
local OnAFKTime--AFK时间
local OnPetTime--宠物战斗
local OnInstanceTime--副本

local LastText--最后时间提示
local OnInstanceDeadCheck--副本,死亡,测试点



local PetAll={num= 0,  win=0, capture=0}--宠物战斗,全部,数据
local PetRound={}--宠物战斗, 本次,数据
local InstanceDate={num= 0, time= 0, kill=0, dead=0}--副本数据{dead死亡,kill杀怪, map地图}












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
        (e.onlyChinese and '离开' or AFK)..e.Icon.clock2..SecondsToTime(Save.afk.time),
        Save.afk.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    )
    e.tips:AddDoubleLine(
        (e.onlyChinese and '副本' or INSTANCE)..'|A:BuildanAbomination-32x32:0:0|a'..Save.ins.kill..'|A:poi-soulspiritghost:0:0|a'..Save.ins.dead,
        Save.ins.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)..' |A:CrossedFlagsWithTimer:0:0|a'..e.GetTimeInfo(Save.ins.time)
    )
    e.tips:AddLine(' ')
    local time=e.GetTimeInfo(OnLineTime)
    e.tips:AddDoubleLine((e.onlyChinese and '在线' or GUILD_ONLINE_LABEL)..e.Icon.clock2, time)---在线时间
    local tab=e.WoWDate[e.Player.guid].Time
    e.tips:AddDoubleLine((e.onlyChinese and '总计' or TOTAL)..e.Icon.clock2, tab.totalTime and SecondsToTime(tab.totalTime))
    e.tips:AddDoubleLine(
        (e.onlyChinese and '本周%s' or CURRENCY_THIS_WEEK):format('CD'),
        SecondsToTime(C_DateAndTime.GetSecondsUntilWeeklyReset())
    )
end














local chatStarTime
local function set_TrackButton_Text()--设置显示内容
    local text
    if OnCombatTime then--战斗时间
        local combat, sec = e.GetTimeInfo(OnCombatTime, not Save.timeTypeText)
        if Save.SayTime>0 then--喊话
            sec=math.floor(sec)
            if sec ~= chatStarTime and sec > 0 and sec%Save.SayTime==0  then--IsInInstance()
                chatStarTime=sec
                e.Chat(e.SecondsToClock(sec), nil, nil)
            end
        end
        text= '|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a|cnRED_FONT_COLOR:'..combat..'|r'
    end

    if OnAFKTime then
        text= text and text..'|n' or ''
        text= text .. (e.onlyChinese and '离开' or AFK)..e.Icon.clock2..e.GetTimeInfo(OnAFKTime, not Save.timeTypeText)
    end

    if OnPetTime then
        text= text and text..'|n' or ''
        text= text ..(PetRound.text or '|TInterface\\Icons\\PetJournalPortrait:0|t')..' '..e.GetTimeInfo(OnPetTime, not Save.timeTypeText)
    end

    if OnInstanceTime then
        text= text and text..'|n' or LastText and (LastText..'|n') or ''
        text=text..'|A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..'|A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|A:CrossedFlagsWithTimer:0:0|a'..e.GetTimeInfo(OnInstanceTime, not Save.timeTypeText)
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
        local text, sec = e.GetTimeInfo(OnAFKTime, not Save.timeTypeText)
        LastText= e.Icon.clock2..'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '离开' or AFK)..text..'|r'
        Save.afk.num= Save.afk.num + 1
        Save.afk.time= Save.afk.time + sec
        print(id, e.cn(addName), LastText)
        OnAFKTime=nil
    end

    if UnitAffectingCombat('player') then
        OnCombatTime= OnCombatTime or time
        LastText=nil
    elseif OnCombatTime then
        local text, sec=e.GetTimeInfo(OnCombatTime, not Save.timeTypeText)
        LastText= '|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a|cnGREEN_FONT_COLOR:'..text..'|r'
        if sec>10 then
            Save.bat.num= Save.bat.num + 1
            Save.bat.time= Save.bat.time + sec
            --print(id, e.cn( addName), LastText)
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

        LastText=(PetRound.text or '')..(PetRound.win and '|T646379:0|t' or ' ')..e.GetTimeInfo(OnPetTime, not Save.timeTypeText)
        if PetRound.win then
            LastText='|cnGREEN_FONT_COLOR:'..LastText..'|r'
        else
            LastText='|cnRED_FONT_COLOR:'..LastText..'|r'
        end
        print(id, e.cn( addName), e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE, LastText, Save.pet.win..'/'..Save.pet.num, (Save.pet.capture>0 and Save.pet.capture..' |T646379:0|t' or ''));

        PetRound={}
        OnPetTime=nil
    end

    if IsInInstance() then--副本
        OnInstanceTime= OnInstanceTime or time
        InstanceDate.map= InstanceDate.map or e.GetUnitMapName('player')


    elseif OnInstanceTime then
        local text, sec= e.GetTimeInfo(OnInstanceTime, not Save.timeTypeText)
        if sec>60 or InstanceDate.dead>0 or InstanceDate.kill>0 then
            Save.ins.num= Save.ins.num +1
            Save.ins.time= Save.ins.time +sec
        end
        LastText='|cnGREEN_FONT_COLOR:|A:CrossedFlagsWithTimer:0:0|a'..text..' |A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..' |A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|r'
        print(id, InstanceDate.map or e.onlyChinese and '副本' or INSTANCE, text)

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

    TrackButton= e.Cbtn(WoWToolsChatButtonFrame, {icon='hide', size={22,22}, pushe=true})

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
        if Save.textFramePoint then
            TrackButton:SetPoint(Save.textFramePoint[1], UIParent, Save.textFramePoint[3], Save.textFramePoint[4], Save.textFramePoint[5])
        else
            TrackButton:SetPoint('BOTTOMLEFT', button, 'BOTTOMRIGHT')
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

    TrackButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE,'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        set_Tooltips_Info()
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
        button:SetButtonState('PUSHED')
    end)
    TrackButton:SetScript("OnLeave", function()
        button:SetButtonState("NORMAL")
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
            print(id, e.cn( addName), e.onlyChinese and '缩放' or UI_SCALE,"|cnGREEN_FONT_COLOR:", sacle)
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
                if button.isInPvPInstance and UnitIsPlayer(arg1) or not button.isInPvPInstance then
                    InstanceDate.kill= InstanceDate.kill +1
                    Save.ins.kill= Save.ins.kill +1
                end
            end
        elseif event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED' then
            TrackButton_Frame_Init_Date()--初始, 数据
        end
    end)

    TrackButton.text= e.Cstr(TrackButton, {color=true})
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


















--####
--初始
--####
local function Init()
    OnLineTime=GetTime()

    button:SetPoint('BOTTOMLEFT', WoWToolsChatButtonFrame.last, 'BOTTOMRIGHT')--设置位置

    if e.Player.faction=='Alliance' then
        button.texture:SetTexture(255130)
    elseif e.Player.faction=='Horde' then
        button.texture:SetTexture(2565244)
    else
        button.texture:SetAtlas('nameplates-icon-flag-neutral')
    end

    button.texture2=button:CreateTexture(nil, 'OVERLAY')
    button.texture2:SetAllPoints(button)
    button.texture2:AddMaskTexture(button.mask)
    button.texture2:SetColorTexture(1,0,0)
    button.texture2:SetShown(false)


    function button:set_texture_Desaturated()--禁用/启用 TrackButton, 提示
        self.texture:SetDesaturated(Save.disabledText and true or false)
    end

    function button:Is_In_Arena()--是否在战场
        self.isInPvPInstance= e.Is_In_PvP_Area()--是否在，PVP区域中
    end

    function button:set_Sacle_InCombat(bat)--提示，战斗中
        self.texture2:SetShown(bat)
        if Save.combatScale then
            self:SetScale(bat and Save.inCombatScale or 1)
        end
    end

    function button:set_Click()
        Save.disabledText = not Save.disabledText and true or nil
        button:set_texture_Desaturated()
        Init_TrackButton()
    end
    button:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")--菜单框架
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level, type)--主菜单
                    local info
                    if type=='AllOnlineTime' then--3级,所有角色时间
                        local timeAll=0
                        for guid, tab in pairs(e.WoWDate or {}) do
                            local time= tab.Time and tab.Time.totalTime
                            if time and time>0 then
                                timeAll= timeAll + time
                                info= {
                                    text= e.GetPlayerInfo({guid=guid,  reName=true, reRealm=true, factionName=tab.faction})..e.Icon.clock2..'  '..SecondsToTime(time),
                                    notCheckable=true,
                                    tooltipOnButton=true,
                                    tooltipTitle= tab.Time.levelTime and format(e.onlyChinese and '你在这个等级的游戏时间：%s' or TIME_PLAYED_LEVEL, '|n'..SecondsToTime(tab.Time.levelTime)),
                                }
                                e.LibDD:UIDropDownMenu_AddButton(info, level)
                            end
                        end
                        if timeAll>0 then
                            e.LibDD:UIDropDownMenu_AddSeparator(level)
                            info={
                                text= (e.onlyChinese and '总计：' or FROM_TOTAL).. SecondsToTime(timeAll),
                                notCheckable=true,
                                isTitle=true
                            }
                            e.LibDD:UIDropDownMenu_AddButton(info, level)
                        end

                    elseif type=='Settings' then
                        info={
                            text=e.onlyChinese and '重置位置' or RESET_POSITION,
                            notCheckable=true,
                            colorCode= (not Save.textFramePoint or Save.disabledText) and '|cff606060',
                            func= function()
                                Save.textFramePoint=nil
                                if TrackButton then
                                    TrackButton:ClearAllPoints()
                                    TrackButton:set_Point()
                                end
                                print(id,e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
                            end
                        }
                        e.LibDD:UIDropDownMenu_AddButton(info, level)
                        e.LibDD:UIDropDownMenu_AddSeparator(level)

                        info={
                            text= e.onlyChinese and '重置所有' or RESET..ALL,
                            colorCode='|cffff0000',
                            tooltipOnButton=true,
                            tooltipTitle= (e.onlyChinese and '全部清除' or CLEAR_ALL)..' Shift+'..e.Icon.left,
                            tooltipText= '|n'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|n'..SLASH_RELOAD1,
                            notCheckable=true,
                            disabled= UnitAffectingCombat('player'),
                            func=function()
                                if IsShiftKeyDown() then
                                    Save=nil
                                    e.Reload()
                                end
                            end
                        }
                        e.LibDD:UIDropDownMenu_AddButton(info, level)
                    end

                    if type then
                        return
                    end

                    local tab=e.WoWDate[e.Player.guid].Time
                    info={
                        text= e.onlyChinese and '总游戏时间'..((tab and tab.totalTime) and ': '..SecondsToTime(tab.totalTime) or '') or TIME_PLAYED_TOTAL:format((tab and tab.totalTime) and SecondsToTime(tab.totalTime) or ''),
                        checked= Save.AllOnlineTime,
                        menuList='AllOnlineTime',
                        hasArrow=true,
                        keepShownOnClick=true,
                        func= function()
                            Save.AllOnlineTime = not Save.AllOnlineTime and true or nil
                            if Save.AllOnlineTime then
                                RequestTimePlayed()
                            end
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)

                    info={
                        text= (e.onlyChinese and '战斗中缩放' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, UI_SCALE))
                                ..' |cnGREEN_FONT_COLOR:'..Save.inCombatScale,
                        disabled= UnitAffectingCombat('player'),
                        notCheckable=true,
                        keepShownOnClick=true,
                        func= function()
                                StaticPopupDialogs[id..addName..'inCombatScale']= StaticPopupDialogs[id..addName..'inCombatScale'] or {
                                    text=id..' '..addName..'|n|n'
                                        ..(e.onlyChinese and '缩放' or UI_SCALE)
                                        ..'|n 0.4 - 4 ',
                                    whileDead=true, hideOnEscape=true, exclusive=true,
                                    hasEditBox=true,
                                    button1= e.onlyChinese and '设置' or SETTINGS,
                                    button2= e.onlyChinese and '取消' or CANCEL,
                                    OnShow = function(s)
                                        s.editBox:SetText(Save.inCombatScale)
                                    end,
                                    OnAccept = function(s)
                                        local num
                                        num= s.editBox:GetText() or ''
                                        num= tonumber(num)
                                        Save.inCombatScale= num
                                        print(id, e.cn( addName), e.onlyChinese and '缩放' or UI_SCALE,'|cnGREEN_FONT_COLOR:', num)
                                        button:set_Sacle_InCombat(true)
                                        C_Timer.After(3, function()
                                            button:set_Sacle_InCombat(UnitAffectingCombat('player'))
                                        end)
                                    end,
                                    EditBoxOnTextChanged=function(s)
                                        local num
                                        num= s:GetText() or ''
                                        num= tonumber(num)
                                        s:GetParent().button1:SetEnabled(num and num>=0.4 and num<=4)
                                    end,
                                    EditBoxOnEscapePressed = function(s)
                                        s:SetAutoFocus(false)
                                        s:ClearFocus()
                                        s:GetParent():Hide()
                                    end,
                                }
                                StaticPopup_Show(id..addName..'inCombatScale')
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    e.LibDD:UIDropDownMenu_AddSeparator(level)

                    info={
                        text= (e.onlyChinese and '信息' or INFO)..'|A:auctionhouse-ui-dropdown-arrow-up:0:0|a',
                        checked= not Save.disabledText,
                        hasArrow=true,
                        menuList='Settings',
                        func=button.set_Click,
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)

                    info={--时间类型
                        text= (e.onlyChinese and '时间类型' or TIME_LABEL)..' |cnGREEN_FONT_COLOR:'..(Save.timeTypeText and SecondsToTime(35) or '00:35')..'|r',
                        checked= Save.timeTypeText,
                        tooltipOnButton=true,
                        tooltipTitle=  e.onlyChinese and '类型' or TYPE,
                        tooltipText='00:35|n'..SecondsToTime(35),
                        keepShownOnClick=true,
                        colorCode= Save.disabledText and '|cff606060' or nil,
                        func= function()
                            Save.timeTypeText= not Save.timeTypeText and true or nil
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    


                    info={
                        text= (
                            (e.onlyChinese and '战斗时间' or COMBAT)
                            ..'|A:communities-icon-chat:0:0|a'
                            ..(Save.SayTime==0 and e.GetEnabeleDisable(false) or ((e.onlyChinese and '每: ' or EVENTTRACE_TIMESTAMP)..Save.SayTime))
                        ),
                        tooltipOnButton=true,
                        tooltipTitle= e.onlyChinese and '说' or SAY,
                        keepShownOnClick=true,
                        notCheckable=true,
                        colorCode= Save.disabledText and '|cff606060' or nil,
                        func= function()
                            StaticPopupDialogs[id..addName..'SayTime']= StaticPopupDialogs[id..addName..'SayTime'] or {
                                text= id..' '..addName
                                    ..'|n|n'.. (e.onlyChinese and '时间戳' or EVENTTRACE_TIMESTAMP)..' '..(e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
                                    ..'|n|n>= 60 '..e.GetEnabeleDisable(true)
                                    ..'|n= 0  '..e.GetEnabeleDisable(false),
                                whileDead=true, hideOnEscape=true, exclusive=true,
                                hasEditBox=true,
                                button1= e.onlyChinese and '设置' or SETTINGS,
                                button2= e.onlyChinese and '取消' or CANCEL,
                                OnShow = function(s)
                                    s.editBox:SetText(Save.SayTime)
                                    s.button1:SetText(Save.SayTime==0 and e.GetEnabeleDisable(false) or (e.onlyChinese and '设置' or SETTINGS))
                                end,
                                OnAccept = function(s)
                                    local num
                                    num= s.editBox:GetText() or ''
                                    num= tonumber(num)
                                    if num>0 then
                                        e.Chat(e.SecondsToClock(num), nil, nil)
                                    else
                                        print(id, e.cn( addName), e.GetEnabeleDisable(false))
                                    end
                                    Save.SayTime= num
                                end,
                                EditBoxOnTextChanged=function(s)
                                    local num
                                    num= s:GetText() or ''
                                    num= tonumber(num)
                                    local parent=s:GetParent()
                                    parent.button1:SetEnabled(num and (num>=60 or num==0))
                                    parent.button1:SetText(num==0 and (e.onlyChinese and '禁用' or DISABLE) or (e.onlyChinese and '设置' or SETTINGS) )
                                end,
                                EditBoxOnEscapePressed = function(s)
                                    s:SetAutoFocus(false)
                                    s:ClearFocus()
                                    s:GetParent():Hide()
                                end,
                            }
                            StaticPopup_Show(id..addName..'SayTime')
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)

                    
                end, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
            
        elseif d=='LeftButton' then
            button:set_Click()
        end
    end)

    button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        set_Tooltips_Info()
        e.tips:Show()
        Set_TrackButton_Pushed(true)--TrackButton，提示
        WoWToolsChatButtonFrame:SetButtonState('PUSHED')
    end)
    button:SetScript('OnLeave', function()
        Set_TrackButton_Pushed(false)--TrackButton，提示
        WoWToolsChatButtonFrame:SetButtonState('NORMAL')
        e.tips:Hide()
    end)





    button:RegisterEvent('PLAYER_REGEN_DISABLED')
    button:RegisterEvent('PLAYER_REGEN_ENABLED')
    button:RegisterEvent('PLAYER_ENTERING_WORLD')
    button:SetScript("OnEvent", function(self, event)--提示，战斗中, 是否在战场
        if event=='PLAYER_REGEN_ENABLED' then
            self:set_Sacle_InCombat(false)--提示，战斗中
        elseif event=='PLAYER_REGEN_DISABLED' then
            self:set_Sacle_InCombat(true)
        elseif event=='PLAYER_ENTERING_WORLD' then
            self:Is_In_Arena()
        end
    end)

    button:set_Sacle_InCombat(UnitAffectingCombat('player'))--提示，战斗中
    button:Is_In_Arena()--是否在战场
    button:set_texture_Desaturated()--禁用/启用 TrackButton, 提示
    

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

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.inCombatScale= Save.inCombatScale or 1.3
            Save.SayTime= Save.SayTime or 120

            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                button= e.Cbtn2({
                    name=nil,
                    parent=WoWToolsChatButtonFrame,
                    click=true,-- right left
                    notSecureActionButton=true,
                    notTexture=nil,
                    showTexture=true,
                    sizi=nil,
                })



                panel:RegisterEvent("PLAYER_LOGOUT")

                Init()
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end


    end
end)

