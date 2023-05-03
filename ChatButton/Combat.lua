local id, e = ...
local addName= COMBAT..TIMEMANAGER_TOOLTIP_TITLE
local Save= {textScale=1.2,
        Say=120,
        --AllOnlineTime=true,--进入游戏时,提示游戏,时间
        combatScale=true,--战斗中缩放
        bat={num= 0, time= 0},--战斗数据
        pet={num= 0,  win=0, capture=0},
        ins={num= 0, time= 0, kill=0, dead=0},
        afk={num= 0, time= 0},
        hideCombatText= true,--隐藏, 战斗, 文本
}
local button

local OnLineTime--在线时间
local OnCombatTime--战斗时间
local OnAFKTime--AFK时间
local OnPetTime--宠物战斗
local LastText--最后时间提示
local OnInstanceTime--副本
local OnInstanceDeadCheck--副本,死亡,测试点
local isInPvPInstance--是否在战场

local PetAll={num= 0,  win=0, capture=0}--宠物战斗,全部,数据
local PetRound={}--宠物战斗, 本次,数据
local InstanceDate={num= 0, time= 0, kill=0, dead=0}--副本数据{dead死亡,kill杀怪, map地图}

local chatStarTime
local function setText()--设置显示内容
    local text
    if OnCombatTime then--战斗时间
        local combat, sec = e.GetTimeInfo(OnCombatTime, not Save.timeTypeText)
        if Save.Say then--喊话
            sec=math.floor(sec)
            if sec ~= chatStarTime and sec > 0 and sec%Save.Say==0  then
                chatStarTime=sec
                if IsInInstance() then
                    local time=SecondsToClock(sec)
                    time=time:gsub('：',':')
                    e.Chat(time, nil, true)
                end
            end
        end
        text= text and text..'\n' or ''
        if Save.hideCombatText then
            text= text ..'|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a|cnRED_FONT_COLOR:'..combat..'|r'
        else
            text= text ..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗' or COMBAT)..'|r|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a'..combat
        end
    end

    if OnAFKTime then
        text= text and text..'\n' or ''
        text= text .. (e.onlyChinese and '离开' or AFK)..e.Icon.clock2..e.GetTimeInfo(OnAFKTime, not Save.timeTypeText)
    end

    if OnPetTime then
        text= text and text..'\n' or ''
        text= text ..(PetRound.text or '|TInterface\\Icons\\PetJournalPortrait:0|t')..' '..e.GetTimeInfo(OnPetTime, not Save.timeTypeText)
    end

    if OnInstanceTime then
        text= text and text..'\n' or LastText and (LastText..'\n') or ''
        text=text..'|A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..'|A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|A:CrossedFlagsWithTimer:0:0|a'..e.GetTimeInfo(OnInstanceTime, not Save.timeTypeText)
    end
    button.text:SetText(text or LastText or '')
end

local function setPetText()--宠物战斗, 设置显示内容
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

local function check_Event()--检测事件
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
        print(id, addName, LastText)
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
            --print(id, addName, LastText)
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
        print(id, addName, e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE, LastText, Save.pet.win..'/'..Save.pet.num, (Save.pet.capture>0 and Save.pet.capture..' |T646379:0|t' or ''));

        PetRound={}
        OnPetTime=nil
    end

    if IsInInstance() then--副本
        OnInstanceTime= OnInstanceTime or time
        InstanceDate.map= InstanceDate.map or e.GetUnitMapName('player')
        button.textButton:RegisterEvent('PLAYER_DEAD')--死亡
        button.textButton:RegisterEvent('PLAYER_UNGHOST')
        button.textButton:RegisterEvent('PLAYER_ALIVE')
        button.textButton:RegisterEvent('UNIT_FLAGS')--杀怪
    elseif OnInstanceTime then
        local text, sec= e.GetTimeInfo(OnInstanceTime, not Save.timeTypeText)
        if sec>60 or InstanceDate.dead>0 or InstanceDate.kill>0 then
            Save.ins.num= Save.ins.num +1
            Save.ins.time= Save.ins.time +sec
        end
        LastText='|cnGREEN_FONT_COLOR:|A:CrossedFlagsWithTimer:0:0|a'..text..' |A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..' |A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|r'
        print(id, InstanceDate.map or e.onlyChinese and '副本' or INSTANCE, text)
        button.textButton:UnregisterEvent('PLAYER_DEAD')
        button.textButton:UnregisterEvent('PLAYER_UNGHOST')
        button.textButton:UnregisterEvent('PLAYER_ALIVE')
        button.textButton:UnregisterEvent('UNIT_FLAGS')
        InstanceDate={time= 0, kill=0, dead=0}--副本数据{dead死亡,kill杀怪, map地图}
        OnInstanceTime=nil
    end
    button.frame:SetShown((OnAFKTime or OnCombatTime or OnPetTime or OnInstanceTime) and true or false)--设置更新数据,显示/隐藏 button.frame
    setText()--设置显示内容
end


local function set_Text_Button()--设置显示内容, 父框架button.textButton, 内容button.text
    if Save.disabledText then
        if button.textButton then
            button.textButton:UnregisterAllEvents()
            button.textButton:SetShown(false)
        end
        return
    end

    if not button.textButton then
        button.textButton= e.Cbtn(WoWToolsChatButtonFrame, {icon='hide', size={20,20}})

        if Save.textFramePoint then
            button.textButton:SetPoint(Save.textFramePoint[1], UIParent, Save.textFramePoint[3], Save.textFramePoint[4], Save.textFramePoint[5])
        else
            button.textButton:SetPoint('BOTTOMLEFT', button, 'BOTTOMRIGHT')
        end
        button.textButton:RegisterForDrag("RightButton")
        button.textButton:SetMovable(true)
        button.textButton:SetClampedToScreen(true)
        button.textButton:SetScript("OnDragStart", function(self, d)
            if not IsModifierKeyDown() and d=='RightButton' then
                self:StartMoving()
            end
        end)
        button.textButton:SetScript("OnDragStop", function(self)
            ResetCursor()
            self:StopMovingOrSizing()
            Save.textFramePoint={self:GetPoint(1)}
            Save.textFramePoint[2]=nil
            print(id, addName, e.onlyChinese and '重设到默认位置' or HUD_EDIT_MODE_RESET_POSITION, 'Alt+'..e.Icon.right)
        end)
        button.textButton:SetScript("OnMouseDown", function(self,d)
            if d=='LeftButton' then--提示移动
                button.text:SetText('')

            elseif d=='RightButton' and not IsModifierKeyDown() then--移动光标
                SetCursor('UI_MOVE_CURSOR')

            elseif d=='RightButton' and IsAltKeyDown() then--还原
                Save.textFramePoint=nil
                button.textButton:ClearAllPoints()
                button.textButton:SetPoint('BOTTOMLEFT', button, 'BOTTOMRIGHT')
            end
        end)
        button.textButton:SetScript("OnMouseUp", function(self, d)
            ResetCursor()
        end)
        button.textButton:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE,'Alt+'..e.Icon.mid)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine((e.onlyChinese and '战斗' or COMBAT)..'|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a'..SecondsToTime(Save.bat.time), Save.bat.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
            e.tips:AddDoubleLine((PetAll.num>0 and PetAll.win..'/'..PetAll.num or (e.onlyChinese and '宠物' or PET))..'|A:worldquest-icon-petbattle:0:0|a'..Save.pet.win..'|r/'..Save.pet.num, Save.pet.capture..' |T646379:0|t')
            e.tips:AddDoubleLine((e.onlyChinese and '离开' or AFK)..e.Icon.clock2..SecondsToTime(Save.afk.time), Save.afk.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
            e.tips:AddDoubleLine((e.onlyChinese and '副本' or INSTANCE)..'|A:BuildanAbomination-32x32:0:0|a'..Save.ins.kill..'|A:poi-soulspiritghost:0:0|a'..Save.ins.dead, Save.ins.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)..' |A:CrossedFlagsWithTimer:0:0|a'..e.GetTimeInfo(Save.ins.time))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine((e.onlyChinese and '本周%s' or CURRENCY_THIS_WEEK):format('CD'), SecondsToTime(C_DateAndTime.GetSecondsUntilWeeklyReset()))
            e.tips:Show()
        end)
        button.textButton:SetScript("OnLeave", function(self, d)
            e.tips:Hide()
            self:SetButtonState('NORMAL')
        end)
        button.textButton:SetScript('OnMouseWheel', function(self, d)--缩放
            if IsAltKeyDown() then
                local text=button.text:GetText()
                if not text or text=='' then
                    button.text:SetText(UI_SCALE)
                end
                local sacle=Save.textScale or 1
                if d==1 then
                    sacle=sacle+0.1
                elseif d==-1 then
                    sacle=sacle-0.1
                end
                if sacle>3 then
                    sacle=3
                elseif sacle<0.6 then
                    sacle=0.6
                end
                print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, sacle)
                button.text:SetScale(sacle)
                Save.textScale=sacle
            end
        end)
        button.textButton:SetScript('OnEvent', function(self, event, arg1)
            if event=='PLAYER_FLAGS_CHANGED' then--AFK
                check_Event()--检测事件

            elseif event=='PET_BATTLE_OPENING_DONE' then
                check_Event()--检测事件

            elseif event=='PET_BATTLE_PVP_DUEL_REQUESTED' then--宠物战斗
                PetRound.PVP =true
                setPetText()--宠物战斗, 设置显示内容
            elseif (event=='PET_BATTLE_PET_ROUND_RESULTS' or event=='PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE') and arg1 then
                PetRound.round=arg1
                setPetText()--宠物战斗, 设置显示内容
            elseif event=='PET_BATTLE_CAPTURED' and arg1 and arg1==2 then--捕获
                PetRound.capture=true
                setPetText()--宠物战斗, 设置显示内容
            elseif event=='PET_BATTLE_FINAL_ROUND' and arg1 then--结束
                if arg1==1 then--赢
                    PetRound.win=true
                end
                setPetText()--宠物战斗, 设置显示内容
            elseif event=='PET_BATTLE_CLOSE' then
                check_Event()--检测事件

            elseif event=='PLAYER_ENTERING_WORLD' then--副本,杀怪,死亡
                isInPvPInstance=C_PvP.IsBattleground() or C_PvP.IsArena()--是否在战场
                check_Event()--检测事件

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
                    if isInPvPInstance and UnitIsPlayer(arg1) or not isInPvPInstance then
                        InstanceDate.kill= InstanceDate.kill +1
                        Save.ins.kill= Save.ins.kill +1
                    end
                end
            end
        end)

        button.text= e.Cstr(button.textButton, {color=true})
        button.text:SetPoint('BOTTOMLEFT')
        if Save.textScale and Save.textScale~=1 then
            button.text:SetScale(Save.textScale)
        end

        button.frame=CreateFrame("Frame", nil, button.textButton)
        button.frame.elapsed=0
        button.frame:HookScript("OnUpdate", function (self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed > 0.3 then
                self.elapsed = 0
                setText()--设置显示内容
            end
        end)
    end

    button.textButton:RegisterEvent('PLAYER_FLAGS_CHANGED')--AFK
    button.textButton:RegisterEvent('PET_BATTLE_OPENING_DONE')--宠物战斗
    button.textButton:RegisterEvent('PET_BATTLE_CLOSE')
    button.textButton:RegisterEvent('PET_BATTLE_PET_ROUND_RESULTS')
    button.textButton:RegisterEvent('PET_BATTLE_FINAL_ROUND')
    button.textButton:RegisterEvent('PET_BATTLE_CAPTURED')
    button.textButton:RegisterEvent('PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE')
    button.textButton:RegisterEvent('PLAYER_ENTERING_WORLD')--副本,杀怪,死亡
    button.textButton:SetShown(true)

    check_Event()--检测事件

    isInPvPInstance=C_PvP.IsBattleground() or C_PvP.IsArena()--是否在战场
end




local function set_textButton_Disabled_Enable()--禁用, 启用, textButton
    Save.disabledText = not Save.disabledText and true or nil
    set_Text_Button()
    if not Save.disabledText then
        button.textButton:SetButtonState('PUSHED')
    end
    button.texture:SetDesaturated(Save.disabledText)
end


--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    if type=='SETTINGS' then
        info={--时间类型
            text= (e.onlyChinese and '时间类型' or TIME_LABEL)..' |cnGREEN_FONT_COLOR:'..(Save.timeTypeText and SecondsToTime(35) or '00:35')..'|r',
            checked= Save.timeTypeText,
            tooltipOnButton=true,
            tooltipTitle=  e.onlyChinese and '类型' or TYPE,
            tooltipText='00:35\n'..SecondsToTime(35),
            func= function()
                Save.timeTypeText= not Save.timeTypeText and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '战斗中缩放 1.3' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..UI_SCALE..' 1.3',
            checked= Save.combatScale,
            disabled= UnitAffectingCombat('player'),
            func= function()
                Save.combatScale= not Save.combatScale and true or nil
                if Save.combatScale and UnitAffectingCombat('player') then--战斗中缩放
                    button:SetScale(1.3)
                else
                    button:SetScale(1)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '隐藏|cnRED_FONT_COLOR:战斗|r文本' or (HIDE..'|cnRED_FONT_COLOR:'..COMBAT..'|r'..LOCALE_TEXT_LABEL),
            checked= Save.hideCombatText,
            func= function()
                Save.hideCombatText= not Save.hideCombatText and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= ((e.onlyChinese and '战斗时间' or COMBAT)..'|A:communities-icon-chat:0:0|a'..(e.onlyChinese and '每: ' or EVENTTRACE_TIMESTAMP)..Save.Say),
            checked= Save.Say and true or nil,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '说' or SAY,
            func= function()
                Save.Say= not Save.Say and 120 or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)


        local tab=WoWDate[e.Player.guid].Time
        info={
            text= e.onlyChinese and '总游戏时间'..((tab and tab.totalTime) and ': '..SecondsToTime(tab.totalTime) or '') or TIME_PLAYED_TOTAL:format((tab and tab.totalTime) and SecondsToTime(tab.totalTime) or ''),
            checked= Save.AllOnlineTime,
            menuList='AllOnlineTime',
            hasArrow=true,
            func= function()
                Save.AllOnlineTime = not Save.AllOnlineTime and true or nil
                if Save.AllOnlineTime then
                    RequestTimePlayed()
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '重置所有' or RESET..ALL,
            colorCode='|cffff0000',
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '重新加载UI' or RELOADUI,
            tooltipText=SLASH_RELOAD1,
            notCheckable=true,
            func=function()
                Save=nil
                e.Reload()
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif type=='AllOnlineTime' then--3级,所有角色时间
        local timeAll=0
        for guid, tab in pairs(WoWDate) do
            local time= tab.Time and tab.Time.totalTime
            if time and time>0 then
                timeAll= timeAll + time
                info= {
                    text= e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true})..e.Icon.clock2..'  '..SecondsToTime(time),
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle= tab.Time.levelTime and format(e.onlyChinese and '你在这个等级的游戏时间：%s' or TIME_PLAYED_LEVEL, '\n'..SecondsToTime(tab.Time.levelTime)),
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

    else
        info={--在线时间
            text= (e.onlyChinese and '在线' or GUILD_ONLINE_LABEL)..e.Icon.clock2..e.GetTimeInfo(OnLineTime),
            isTitle=true,
            notCheckable=true
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        local tab=WoWDate[e.Player.guid].Time
        if tab and tab.totalTime then
            info={
                text= (e.onlyChinese and '总计' or TOTAL)..e.Icon.clock2..SecondsToTime(tab.totalTime),
                isTitle=true,
                notCheckable=true
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)


        info={
            text= e.onlyChinese and '信息' or INFO,
            checked= not Save.disabledText,
            hasArrow=true,
            menuList='SETTINGS',
            func=set_textButton_Disabled_Enable--禁用, 启用, textButton
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end
end


--####
--初始
--####
local function Init()
    OnLineTime=GetTime()

    button:SetPoint('BOTTOMLEFT', WoWToolsChatButtonFrame.last, 'BOTTOMRIGHT')--设置位置

    button.texture:SetDesaturated(Save.disabledText)

    button.texture2=button:CreateTexture(nil, 'OVERLAY')
    button.texture2:SetAllPoints(button)
    button.texture2:AddMaskTexture(button.mask)
    button.texture2:SetColorTexture(1,0,0)
    button.texture2:SetShown(false)

    button:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            if not self.Menu then
                self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")--菜单框架
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
        elseif d=='LeftButton' then
            set_textButton_Disabled_Enable()--禁用, 启用, textButton
        end
    end)

    button:SetScript('OnEnter', function(self)
        if self.textButton and self.textButton:IsShown() then
            self.textButton:SetButtonState('PUSHED')
        end
        WoWToolsChatButtonFrame:SetButtonState('PUSHED')
    end)
    button:SetScript('OnLeave', function(self)
        if self.textButton then
            self.textButton:SetButtonState('NORMAL')
        end
        WoWToolsChatButtonFrame:SetButtonState('NORMAL')
    end)

    set_Text_Button()--设置显示内容,框架 button.textButton,内容 button.text

    if e.Player.faction=='Alliance' then
        button.texture:SetTexture(255130)
    elseif e.Player.faction=='Horde' then
        button.texture:SetTexture(2565244)
    else
        button.texture:SetAtlas('nameplates-icon-flag-neutral')
    end

    if Save.AllOnlineTime or not WoWDate[e.Player.guid].Time.totalTime then--总游戏时间
        RequestTimePlayed()
    end
end



--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                button=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
                Save= WoWToolsSave[addName] or Save

                panel:RegisterEvent('PLAYER_REGEN_DISABLED')
                panel:RegisterEvent('PLAYER_REGEN_ENABLED')
                panel:RegisterEvent("PLAYER_LOGOUT")

                Init()
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        button.texture2:SetShown(false)
        if Save.combatScale then--战斗中缩放
            button:SetScale(1)
        end
        if not Save.disabledText then
            check_Event()--检测事件
        end

    elseif event=='PLAYER_REGEN_DISABLED' then
        button.texture2:SetShown(true)
        if Save.combatScale then--战斗中缩放
            button:SetScale(1.3)
        end
        if not Save.disabledText then
            check_Event()--检测事件
        end
    end
end)

