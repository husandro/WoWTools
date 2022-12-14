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
local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel.textFrame=e.Cbtn(WoWToolsChatButtonFrame, nil, nil, nil, nil, true, {20,20})

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
            text= text ..'|cnRED_FONT_COLOR:'..(e.onlyChinse and '战斗' or COMBAT)..'|r|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a'..combat
        end
    end

    if OnAFKTime then
        text= text and text..'\n' or ''
        text= text .. (e.onlyChinse and '离开' or AFK)..e.Icon.clock2..e.GetTimeInfo(OnAFKTime, not Save.timeTypeText)
    end

    if OnPetTime then
        text= text and text..'\n' or ''
        text= text ..(PetRound.text or '|TInterface\\Icons\\PetJournalPortrait:0|t')..' '..e.GetTimeInfo(OnPetTime, not Save.timeTypeText)
    end

    if OnInstanceTime then
        text= text and text..'\n' or (LastText and LastText..'\n' or '')
        text=text..'|A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..'|A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|A:CrossedFlagsWithTimer:0:0|a'..e.GetTimeInfo(OnInstanceTime, not Save.timeTypeText)
    end
    panel.text:SetText(text or LastText or '')
end

local function check_Event()--检测事件
    if not panel.updatFrame then
        return
    end

    local time=GetTime()
    if UnitIsAFK('player') then
        OnAFKTime= OnAFKTime or time
        LastText=nil

    elseif OnAFKTime then
        local text, sec = e.GetTimeInfo(OnAFKTime, not Save.timeTypeText)
        LastText= e.Icon.clock2..'|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '离开' or AFK)..text..'|r'
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
        print(id, addName, e.onlyChinse and '宠物对战' or PET_BATTLE_PVP_QUEUE, LastText, Save.pet.win..'/'..Save.pet.num, (Save.pet.capture>0 and Save.pet.capture..' |T646379:0|t' or ''));

        PetRound={}
        OnPetTime=nil
    end

    if IsInInstance() then--副本
        OnInstanceTime= OnInstanceTime or time
        InstanceDate.map= InstanceDate.map or e.GetUnitMapName('player')
        panel:RegisterEvent('PLAYER_DEAD')--死亡
        panel:RegisterEvent('PLAYER_UNGHOST')
        panel:RegisterEvent('PLAYER_ALIVE')
        panel:RegisterEvent('UNIT_FLAGS')--杀怪
    elseif OnInstanceTime then
        local text, sec= e.GetTimeInfo(OnInstanceTime, not Save.timeTypeText)
        if sec>60 or InstanceDate.dead>0 or InstanceDate.kill>0 then
            Save.ins.num= Save.ins.num +1
            Save.ins.time= Save.ins.time +sec
        end
        LastText='|cnGREEN_FONT_COLOR:|A:CrossedFlagsWithTimer:0:0|a'..text..' |A:BuildanAbomination-32x32:0:0|a'..InstanceDate.kill..' |A:poi-soulspiritghost:0:0|a'..InstanceDate.dead..'|r'
        print(id, INSTANCE, InstanceDate.map or '', text)
        panel:UnregisterEvent('PLAYER_DEAD')
        panel:UnregisterEvent('PLAYER_UNGHOST')
        panel:UnregisterEvent('PLAYER_ALIVE')
        panel:UnregisterEvent('UNIT_FLAGS')
        InstanceDate={time= 0, kill=0, dead=0}--副本数据{dead死亡,kill杀怪, map地图}
        OnInstanceTime=nil
    end
    panel.updatFrame:SetShown((OnAFKTime or OnCombatTime or OnPetTime or OnInstanceTime) and true or false)--设置更新数据,显示/隐藏 panel.updatFrame
    setText()--设置显示内容
end


local function setTexture()--设置,图标, 颜色
    local texture
    if not Save.specializationTexture then
        local faction=UnitFactionGroup('player')
        if faction=='Alliance' then
            texture= 255130
        elseif faction=='Horde' then
            texture= 2565244
        end
    else
        local specializationID=GetSpecialization()--当前专精
        if specializationID then
            texture = select(4, GetSpecializationInfo(specializationID))
        end
    end
    if texture then
        panel.texture:SetTexture(texture)
    else
        panel.texture:SetAtlas('Mobile-MechanicIcon-Powerful')
    end

    if Save.classColor then
        local r,g,b= GetClassColor(UnitClassBase('player'))
        if panel.text then
            panel.text:SetTextColor(r,g,b)
        end
        panel.texture2:SetColorTexture(r,g,b)
    else
        if panel.text then
            panel.text:SetTextColor(0.8, 0.8, 0.8)
        end
        panel.texture2:SetColorTexture(1,0,0)
    end
end

local function setTextFrame()--设置显示内容, 父框架panel.textFrame, 内容panel.text
    if Save.disabledText then
        return
    end

    if Save.textFramePoint then
        panel.textFrame:SetPoint(Save.textFramePoint[1], UIParent, Save.textFramePoint[3], Save.textFramePoint[4], Save.textFramePoint[5])
    else
        panel.textFrame:SetPoint('BOTTOMLEFT', panel, 'BOTTOMRIGHT')
    end
    panel.textFrame:RegisterForDrag("RightButton")
    panel.textFrame:SetMovable(true)
    panel.textFrame:SetClampedToScreen(true)
    panel.textFrame:SetScript("OnDragStart", function(self, d)
        if not IsModifierKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    panel.textFrame:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.textFramePoint={self:GetPoint(1)}
        Save.textFramePoint[2]=nil
        print(id, addName, RESET_POSITION, 'Alt+'..e.Icon.right)
    end)
    panel.textFrame:SetScript("OnMouseDown", function(self,d)
        if d=='LeftButton' then--提示移动
            panel.text:SetText('')

        elseif d=='RightButton' and not IsModifierKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='RightButton' and IsAltKeyDown() then--还原
            Save.textFramePoint=nil
            panel.textFrame:ClearAllPoints()
            panel.textFrame:SetPoint('BOTTOMLEFT', panel, 'BOTTOMRIGHT')
        end
    end)
    panel.textFrame:SetScript("OnMouseUp", function(self, d)
        ResetCursor()
    end)
    panel.textFrame:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinse and '清除' or CLEAR or KEY_NUMLOCK_MAC, e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinse and '缩放' or UI_SCALE,'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        --if Save.bat.num>0 then--战斗
            e.tips:AddDoubleLine((e.onlyChinse and '战斗' or COMBAT)..'|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a'..SecondsToTime(Save.bat.time), Save.bat.num..' '..(e.onlyChinse and '次' or VOICEMACRO_LABEL_CHARGE1))
        --end
        --if Save.pet.num>0 then--宠物战斗
            e.tips:AddDoubleLine((PetAll.num>0 and PetAll.win..'/'..PetAll.num or (e.onlyChinse and '宠物' or PET))..'|A:worldquest-icon-petbattle:0:0|a'..Save.pet.win..'|r/'..Save.pet.num, Save.pet.capture..' |T646379:0|t')
        --end
        --if Save.afk.num>0 then--AFK
            e.tips:AddDoubleLine((e.onlyChinse and '离开' or AFK)..e.Icon.clock2..SecondsToTime(Save.afk.time), Save.afk.num..' '..(e.onlyChinse and '次' or VOICEMACRO_LABEL_CHARGE1))
        --end
        --if Save.ins.num>0 then
           e.tips:AddDoubleLine((e.onlyChinse and '副本' or INSTANCE)..'|A:BuildanAbomination-32x32:0:0|a'..Save.ins.kill..'|A:poi-soulspiritghost:0:0|a'..Save.ins.dead, Save.ins.num..' '..(e.onlyChinse and '次' or VOICEMACRO_LABEL_CHARGE1)..' |A:CrossedFlagsWithTimer:0:0|a'..e.GetTimeInfo(Save.ins.time))
        --end
        e.tips:Show()
    end)
    panel.textFrame:SetScript("OnLeave", function(self, d)
        e.tips:Hide()
        self:SetButtonState('NORMAL')
    end)
    panel.textFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            local text=panel.text:GetText()
            if not text or text=='' then
                panel.text:SetText(UI_SCALE)
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
            print(id, addName, e.onlyChinse and '缩放' or UI_SCALE, sacle)
            panel.text:SetScale(sacle)
            Save.textScale=sacle
        end
    end)

    panel.text=e.Cstr(panel.textFrame)
    panel.text:SetPoint('BOTTOMLEFT')
    if Save.textScale and Save.textScale~=1 then
        panel.text:SetScale(Save.textScale)
    end

    panel.updatFrame=CreateFrame("Frame", nil, panel)
    panel.updatFrame:SetShown(true)

    local timeElapsed = 0
    panel.updatFrame:HookScript("OnUpdate", function (self, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 0.3 then
            timeElapsed = 0
            setText()--设置显示内容
        end
    end)

    panel:RegisterEvent('PLAYER_FLAGS_CHANGED')--AFK

    panel:RegisterEvent('PET_BATTLE_OPENING_DONE')--宠物战斗
    panel:RegisterEvent('PET_BATTLE_CLOSE')
    panel:RegisterEvent('PET_BATTLE_PET_ROUND_RESULTS')
    panel:RegisterEvent('PET_BATTLE_FINAL_ROUND')
    panel:RegisterEvent('PET_BATTLE_CAPTURED')
    panel:RegisterEvent('PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE')

    panel:RegisterEvent('PLAYER_ENTERING_WORLD')--副本,杀怪,死亡
    check_Event()--检测事件

    isInPvPInstance=C_PvP.IsBattleground() or C_PvP.IsArena()--是否在战场
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    if type=='SETTINGS' then
        info={--图标类型
            text= e.onlyChinse and ('图标类型: |cnGREEN_FONT_COLOR:'..(not Save.specializationTexture and '派系|r' or '专精|r')) or (EMBLEM_SYMBOL..': |cnGREEN_FONT_COLOR:'..(not Save.specializationTexture and FACTION or SPECIALIZATION)..'|r'),
            checked= Save.specializationTexture,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '类型' or TYPE,
            tooltipText= e.onlyChinse and '派系\n专精' or FACTION..'\n'..SPECIALIZATION,
            func= function()
                Save.specializationTexture= not Save.specializationTexture and true or nil
                setTexture()--设置,图标
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={--时间类型
            text= (e.onlyChinse and '时间类型' or TIME_LABEL)..' |cnGREEN_FONT_COLOR:'..(Save.timeTypeText and SecondsToTime(35) or '00:35')..'|r',
            checked= Save.timeTypeText,
            tooltipOnButton=true,
            tooltipTitle=  e.onlyChinse and '类型' or TYPE,
            tooltipText='00:35\n'..SecondsToTime(35),
            func= function()
                Save.timeTypeText= not Save.timeTypeText and true or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinse and '战斗中缩放 1.3' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..UI_SCALE..' 1.3',
            checked= Save.combatScale,
            disabled= UnitAffectingCombat('player'),
            func= function()
                Save.combatScale= not Save.combatScale and true or nil
                if Save.combatScale and UnitAffectingCombat('player') then--战斗中缩放
                    panel:SetScale(1.3)
                else
                    panel:SetScale(1)
                end
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinse and '隐藏|cnRED_FONT_COLOR:战斗|r文本' or (HIDE..'|cnRED_FONT_COLOR:'..COMBAT..'|r'..LOCALE_TEXT_LABEL),
            checked= Save.hideCombatText,
            func= function()
                Save.hideCombatText= not Save.hideCombatText and true or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinse and '职业颜色' or CLASS_COLORS,
            checked= Save.classColor,
            colorCode= Save.classColor and e.Player.col or '|cffd0d0d0',
            func=function()
                Save.classColor= not Save.classColor and true or nil
                setTexture()--设置,图标, 颜色
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={--
            text= ((e.onlyChinse and '战斗时间' or COMBAT)..'|A:communities-icon-chat:0:0|a'..(e.onlyChinse and '每: ' or EVENTTRACE_TIMESTAMP)..Save.Say),
            checked= Save.Say and true or nil,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '说' or SAY,
            func= function()
                Save.Say= not Save.Say and 120 or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)


        local tab=e.WoWSave[e.Player.guid].Time
        info={
            text= e.onlyChinse and '总游戏时间'..((tab and tab.totalTime) and ': '..SecondsToTime(tab.totalTime) or '') or TIME_PLAYED_TOTAL:format((tab and tab.totalTime) and SecondsToTime(tab.totalTime) or ''),
            checked= Save.AllOnlineTime,
            tooltipOnButton= true,
            tooltipTitle= e.onlyChinse and ('你在这个等级的游戏时间：%s'):format((tab and tab.levelTime) and '\n'..SecondsToTime(tab.levelTime) or '') or TIME_PLAYED_LEVEL:format((tab and tab.levelTime) and '\n'..SecondsToTime(tab.levelTime) or ''),
            menuList='AllOnlineTime',
            hasArrow=true,
            func= function()
                Save.AllOnlineTime = not Save.AllOnlineTime and true or nil
                if Save.AllOnlineTime then
                    RequestTimePlayed()
                end
            end
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinse and '重置所有' or RESET..ALL,
            colorCode='|cffff0000',
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '重新加载UI' or RELOADUI,
            tooltipText=SLASH_RELOAD1,
            notCheckable=true,
            func=function()
                Save=nil
                C_UI.Reload()
            end
        }
        UIDropDownMenu_AddButton(info, level)

    elseif type=='AllOnlineTime' then--3级,所有角色时间
        local timeAll=0
        for guid, tab in pairs(e.WoWSave) do
            local time= tab.Time and tab.Time.totalTime
            if time and time>0 then
                timeAll= timeAll + time
                info= {
                    text=e.GetPlayerInfo(nil, guid, true)..e.Icon.clock2..SecondsToTime(time),
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle= tab.Time.levelTime and format(e.onlyChinse and '你在这个等级的游戏时间：%s' or TIME_PLAYED_LEVEL, '\n'..SecondsToTime(tab.Time.levelTime)),
                }
                UIDropDownMenu_AddButton(info, level)
            end
        end
        if timeAll>0 then
            UIDropDownMenu_AddSeparator(level)
            info={
                text= (e.onlyChinse and '总计：' or FROM_TOTAL).. SecondsToTime(timeAll),
                notCheckable=true,
                isTitle=true
            }
            UIDropDownMenu_AddButton(info, level)
        end

    else
        info={--在线时间
            text= (e.onlyChinse and '在线' or GUILD_ONLINE_LABEL)..e.Icon.clock2..e.GetTimeInfo(OnLineTime),
            isTitle=true,
            notCheckable=true
        }
        UIDropDownMenu_AddButton(info, level)

        local tab=e.WoWSave[e.Player.guid].Time
        if tab and tab.totalTime then
            info={
                text= (e.onlyChinse and '总计' or TOTAL)..e.Icon.clock2..SecondsToTime(tab.totalTime),
                isTitle=true,
                notCheckable=true
            }
            UIDropDownMenu_AddButton(info, level)
        end
        UIDropDownMenu_AddSeparator(level)

        info={
            text= e.onlyChinse and '设置' or SETTINGS,
            notCheckable=true,
            hasArrow=true,
            menuList='SETTINGS',
            colorCode= Save.disabledText and '|cff606060',
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinse and '信息' or INFO,
            checked= not Save.disabledText,
            func=function()
                Save.disabledText= not Save.disabledText and true or nil
                print(id, addName, '|cnRED_FONT_COLOR:'..REQUIRES_RELOAD)
            end
        }
        UIDropDownMenu_AddButton(info, level)
    end
end


--####
--初始
--####
local function Init()
    OnLineTime=GetTime()

    panel:SetPoint('BOTTOMLEFT',WoWToolsChatButtonFrame.last, 'BOTTOMRIGHT')--设置位置

    panel.texture2=panel:CreateTexture(nil, 'OVERLAY')
    panel.texture2:SetAllPoints(panel)
    panel.texture2:AddMaskTexture(panel.mask)
    panel.texture2:SetShown(false)

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")--菜单框架
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetScript('OnMouseDown', function(self, d)
        ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
    end)


    setTextFrame()--设置显示内容,框架 panel.textFrame,内容 panel.text
    C_Timer.After(2, setTexture)--设置,图标, 颜色

    if Save.AllOnlineTime or not e.WoWSave[e.Player.guid].Time.totalTime then--总游戏时间
        RequestTimePlayed()
    end
end

local function setPetText()--宠物战斗, 设置显示内容
    local text= format(e.onlyChinse and '%d轮' or PET_BATTLE_COMBAT_LOG_NEW_ROUND, PetRound.round or 0)
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

--###########
--加载保存数据
--###########

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:RegisterEvent('PLAYER_REGEN_DISABLED')
panel:RegisterEvent('PLAYER_REGEN_ENABLED')

panel:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')

panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
        else
            if WoWToolsSave and not WoWToolsSave[addName] then
                panel.textFrame:SetButtonState('PUSHED')
            end
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        panel.texture2:SetShown(false)
        check_Event()--检测事件
        if Save.combatScale then--战斗中缩放
            panel:SetScale(1)
        end

    elseif event=='PLAYER_REGEN_DISABLED' then
        panel.texture2:SetShown(true)
        check_Event()--检测事件
        if Save.combatScale then--战斗中缩放
            panel:SetScale(1.3)
        end

    elseif event=='PLAYER_SPECIALIZATION_CHANGED' then
        setTexture()--设置,图标

    elseif event=='PLAYER_FLAGS_CHANGED' then--AFK
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
        --local InstanceDate={num= 0, time= 0, kill=0, dead=0}--副本数据{dead死亡,kill杀怪, map地图}

    elseif event=='UNIT_FLAGS' and arg1 then--杀怪,数量
        if arg1:find('nameplate') and UnitIsEnemy(arg1, 'player') and UnitIsDead(arg1) then
            if isInPvPInstance and UnitIsPlayer(arg1) or not isInPvPInstance then
                InstanceDate.kill= InstanceDate.kill +1
                Save.ins.kill= Save.ins.kill +1
            end
        end
    end
end)

