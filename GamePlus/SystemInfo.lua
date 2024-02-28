local id, e = ...
local addName= SYSTEM_MESSAGES--MAINMENU_BUTTON
local Save={
    --hideFpsMs=false,
    money=true,
    moneyWoW=true,
    --moneyBit=0,
    equipmetLevel=true,
    durabiliy=true,
    perksPoints=true,
    parent= e.Player.husandro,--父框架
    size= 11,
    --framerateSize=12,
    --frameratePlus=true,--为FramerateText 帧数, 建立一个按钮, 移动, 大小
    --framerateLogIn=false,--进入游戏时,显示系统FPS

    --disabledMicroMenuPlus=true,--OnEnter Plus
}

local panel= CreateFrame("Frame")
local Labels
local Frames
local button
local MoveFPSFrame--为FramerateText 帧数, 建立一个按钮, 移动, 大小




















--########
--设置, 钱
--########
local function get_Mony_Tips()
    local numPlayer, allMoney= 0, 0
    local tab={}
    for guid, infoMoney in pairs(e.WoWDate or {}) do
        if infoMoney.Money then

            local nameText= e.GetPlayerInfo({guid=guid, faction=infoMoney.faction, reName=true, reRealm=true})
            local moneyText= GetCoinTextureString(infoMoney.Money)

            local class= select(2, GetPlayerInfoByGUID(guid))
            local col= '|c'..select(4, GetClassColor(class))

            numPlayer=numPlayer+1
            allMoney= allMoney + infoMoney.Money

            table.insert(tab, {text=nameText, money=moneyText, col=col, index=infoMoney.Money})
        end
    end
    table.sort(tab, function(a,b) return a.index< b.index end)

    local all=(e.onlyChinese and '角色' or CHARACTER)..'|cnGREEN_FONT_COLOR:'..numPlayer..'|r  '
            ..(e.onlyChinese and '总计: ' or FROM_TOTAL)
            ..'|cnGREEN_FONT_COLOR:'..(allMoney >=10000 and e.MK(allMoney/10000, 3) or GetCoinTextureString(allMoney))..'|r'

            --table.insert(tab, {text= all,
    return all, tab
end



















--########
--设置, 钱
--########
local function set_Money()
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
        if Save.parent then
            Labels.money:SetText(e.MK(money/1e4, Save.moneyBit or 0))
        else--Coin-Gold Interface/moneyframe/ui-goldicon
            Labels.money:SetText('|A:Coin-Gold:8:8|a'..e.MK(money/1e4, Save.moneyBit or 0)..' ')
        end
    else
        Labels.money:SetText(GetMoneyString(money,true))
    end
end
local function set_Money_Event()
    if Save.money then
        panel:RegisterEvent('PLAYER_MONEY')
        Labels.money= Labels.money or e.Cstr(button, {size=Save.size, color=true})--建立,或设置,Labels
        set_Money()
    else
        panel:UnregisterEvent('PLAYER_MONEY')
        if Labels.money then
            Labels.money:SetText('')
        end
    end
end
























--##################
--设置装等,耐久度,事件
--##################
local function set_Durabiliy()
    local text, value= e.GetDurabiliy(not Save.parent)
    if Save.parent then
        text= text:gsub('%%', '')..' '
    end
    Labels.durabiliy:SetText(text)
    e.Set_HelpTips({frame=button, topoint=Labels.durabiliy, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=true, show=value<=30})--设置，提示
end

local function set_EquipmentLevel()--装等
    local to, cu= GetAverageItemLevel()
    local text, red
    if to and cu and to>0 then
        text=math.modf(cu)
        if to-cu>5 then
            text='|cnRED_FONT_COLOR:'..text..'|r'
            red= true
        end
        if not Save.parent then
            text= (e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:8:8|a' or '|A:charactercreate-gendericon-female-selected:8:8|a')..text..' '
        end
    end
    Labels.equipmentLevel:SetText(text or '')
    if e.Player.levelMax then
        e.Set_HelpTips({frame=button, topoint=Labels.equipmentLevel, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=nil, show=red and not C_PvP.IsArena() and not C_PvP.IsBattleground()})--设置，提示
    end
end

local function set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
    if Save.equipmetLevel or Save.durabiliy then
        panel:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    else
        panel:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
    end

    if Save.equipmetLevel then
        Labels.equipmentLevel= Labels.equipmentLevel or e.Cstr(button, {size=Save.size, color=true})--建立,或设置,Labels create_Set_lable(button, 'equipmentLevel')--建立,或设置,Labels
        C_Timer.After(2, set_EquipmentLevel) --角色图标显示装等  
    else
        if Labels.equipmentLevel then
            Labels.equipmentLevel:SetText('')
        end
    end

    if Save.durabiliy then
        panel:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        Labels.durabiliy= Labels.durabiliy or e.Cstr(button, {size=Save.size, color=true})--建立,或设置,Labels create_Set_lable(button, 'durabiliy')--建立,或设置,Labels
        set_Durabiliy()
    else
        panel:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
        if Labels.durabiliy then
            Labels.durabiliy:SetText('')
        end
    end
end

























--##################
--设置, fps, ms, 数值
--##################
local function set_Fps_Ms(self, elapsed)
    self.elapsed = (self.elapsed or 0.4) + elapsed
    if self.elapsed > 0.4 then
        self.elapsed = 0
        local latencyHome, latencyWorld= select(3, GetNetStats())--ms
        local ms= math.max(latencyHome, latencyWorld) or 0
        local fps=GetFramerate() or 0
        fps=math.modf(fps)

        if Save.parent then
            Labels.ms:SetText(ms>400 and '|cnRED_FONT_COLOR:'..ms..'|r' or ms>120 and ('|cnYELLOW_FONT_COLOR:'..ms..'|r') or ms)
            Labels.fps:SetText(fps<10 and '|cnGREEN_FONT_COLOR:'..math.modf(fps)..'|r' or fps<20 and '|cnYELLOW_FONT_COLOR:'..math.modf(fps)..'|r' or math.modf(fps))
        else
            Labels.ms:SetText((ms>400 and '|cnRED_FONT_COLOR:'..ms..'|r' or ms>120 and ('|cnYELLOW_FONT_COLOR:'..ms..'|r') or ms)..'ms ')
            Labels.fps:SetText((fps<10 and '|cnGREEN_FONT_COLOR:'..math.modf(fps)..'|r' or fps<20 and '|cnYELLOW_FONT_COLOR:'..math.modf(fps)..'|r' or math.modf(fps))..'fps')
        end
    end
end
local function set_Fps_Ms_Show_Hide()--设置, fps, ms, 数值
    panel:SetShown(not Save.hideFpsMs)
    if Save.hideFpsMs then
        if Labels.fps then
            Labels.fps:SetText('')
            Labels.ms:SetText('')
        end
    else
        if not Save.hideFpsMs and not Labels.fps then
            Labels.fps= e.Cstr(button, {size=Save.size, color=true})--建立,或设置,Labels  create_Set_lable(button, 'fps')--建立,或设置,Labels
            Labels.ms= e.Cstr(button, {size=Save.size, color=true})--建立,或设置,Labels create_Set_lable(button, 'ms')--建立,或设置,Labels
            panel:HookScript("OnUpdate", set_Fps_Ms)
        end
    end
end























--###########
--贸易站, 点数
--Blizzard_EncounterJournal/Blizzard_MonthlyActivities.lua
local function Get_Perks_Info()
    local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo()
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

local function set_perksActivitiesLastPoints_CVar()--贸易站, 点数  MonthlyActivitiesFrameMixin:UpdateActivities(retainScrollPosition, activitiesInfo)
    --local value= GetCVar("perksActivitiesLastPoints")
    local text
    local cur, max, info= Get_Perks_Info()
    if cur then
        info =info or {}
        if cur== max then
            text= (info.quantity and '|cnGREEN_FONT_COLOR:'..e.MK(info.quantity, 1)..'|r' or '')
        else
            text= format('%i%%', cur/max*100)
        end
        if not Save.parent then
            text=(info.iconFileID  and '|T'..info.iconFileID..':0|t' or '|A:activities-complete-diamond:0:0|a')..text..' '
        end
    end
    Labels.perksPoints:SetText(text or '')
end
local function set_perksActivitiesLastPoints_Event()
    if Save.perksPoints and not ( IsTrialAccount() or IsVeteranTrialAccount()) then
        Labels.perksPoints= Labels.perksPoints or e.Cstr(button, {size=Save.size, color=true})--建立,或设置,Labels create_Set_lable(button, 'perksPoints')--建立,或设置,Labels
        panel:RegisterEvent('CVAR_UPDATE')
        panel:RegisterEvent('PERKS_ACTIVITY_COMPLETED')
        panel:RegisterEvent('PERKS_ACTIVITIES_UPDATED')
        --panel:RegisterEvent('PLAYER_ENTERING_WORLD')
        set_perksActivitiesLastPoints_CVar()
    else
        panel:UnregisterEvent('CVAR_UPDATE')
        panel:UnregisterEvent('PERKS_ACTIVITY_COMPLETED')
        panel:UnregisterEvent('PERKS_ACTIVITIES_UPDATED')
        --panel:UnregisterEvent('PLAYER_ENTERING_WORLD')
        if Labels.perksPoints then
            Labels.perksPoints:SetText('')
        end
    end
end














 --公会
 local function Init_Guild()
    if not Save.parent then
        return
    end

    local guildFrame= CreateFrame("Frame")
    guildFrame:RegisterEvent('GUILD_ROSTER_UPDATE')
    guildFrame:RegisterEvent('PLAYER_GUILD_UPDATE')
    Labels.guild= e.Cstr(GuildMicroButton, {size=Save.size, color=true})
    Labels.guild:SetPoint('TOP', 0, -3)
    function Labels.guild:set_text()
        local num = select(2, GetNumGuildMembers()) or 0
        self:SetText(num>0 and num or '')
    end
    guildFrame:SetScript('OnEvent', Labels.guild.set_text)
    Labels.guild:set_text()
end















--#################
--设置 Label Poinst
--#################
local function set_Label_Point(clear)--设置 Label Poinst
    local tab={
        'fps',
        'ms',
        'money',
        'perksPoints',
        'durabiliy',
        'equipmentLevel',
        --'guild',
    }
    local last
    for _, text in pairs(tab) do
        local label=Labels[text]
        if label then
            if clear then
                label:ClearAllPoints()
            end
            if Save.parent then
                if text=='fps' then
                    label:SetPoint('TOP', MainMenuMicroButton, 0, -3)
                    label:SetParent(MainMenuMicroButton)
                elseif text=='ms' then
                    label:SetPoint('BOTTOM', MainMenuMicroButton, 'BOTTOM')
                    label:SetParent(MainMenuMicroButton)

                elseif text=='money' then
                    label:SetPoint('TOP', MainMenuBarBackpackButton,0,-6)
                    label:SetParent(MainMenuBarBackpackButton)

                elseif text=='perksPoints' then
                    label:SetPoint('TOP', EJMicroButton, 0, -3)
                    label:SetParent(EJMicroButton)

                elseif text=='durabiliy' then
                    label:SetPoint('BOTTOM', CharacterMicroButton)
                    label:SetParent(CharacterMicroButton)

                elseif text=='equipmentLevel' then
                    label:SetPoint('TOP', CharacterMicroButton, 0, -3)
                    label:SetParent(CharacterMicroButton)
                end

            else
                label:SetPoint('RIGHT',last or button, 'LEFT')
                label:SetParent(button)
                last= label
            end
        end
    end

    if Labels.guild then
        if not Save.parent then
            Labels.guild:SetText('')
        else
            Labels.guild:set_text()
        end
    else
        Init_Guild()
    end
end














--每秒帧数 Plus
--############
local function Init_Framerate_Plus()
    if not Save.frameratePlus then
        return
    end
    MoveFPSFrame= e.Cbtn(FramerateFrame, {size={12,12}, icon='hide'})
    MoveFPSFrame:SetPoint('RIGHT',FramerateFrame.FramerateText)

    MoveFPSFrame:SetMovable(true)
    MoveFPSFrame:RegisterForDrag("RightButton");
    MoveFPSFrame:SetClampedToScreen(true)
    MoveFPSFrame:SetScript("OnDragStart", function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
            local frame= FramerateFrame
            if not frame:IsMovable()  then
                frame:SetMovable(true)
            end
            frame:StartMoving()
        end
    end)
    MoveFPSFrame:SetScript("OnDragStop", function()
        FramerateFrame:StopMovingOrSizing()
        Save.frameratePoint={FramerateFrame:GetPoint(1)}
        Save.frameratePoint[2]=nil
        ResetCursor()
    end)
    MoveFPSFrame:SetScript("OnMouseUp", ResetCursor)
    MoveFPSFrame:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    MoveFPSFrame:SetScript('OnLeave', function()
        e.tips:Hide()
        button:SetButtonState('NORMAL')
    end)
    MoveFPSFrame:SetScript('OnEnter', function(self2)--提示
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '字体大小' or FONT_SIZE, (Save.framerateSize or 12)..e.Icon.mid)
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
        button:SetButtonState('PUSHED')
    end)

    MoveFPSFrame:SetScript('OnMouseWheel',function(self, d)
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

    function MoveFPSFrame:set_size()--修改大小
        e.Cstr(nil, {size=Save.framerateSize or 12, changeFont=FramerateFrame.FramerateText, color=true})--Save.size, nil , Labels.fpsms, true)    
    end
    MoveFPSFrame:set_size()


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



























--MicroMenu Plus
local function Init_MicroMenu_Plus()
    if Save.disabledMicroMenuPlus then
        return
    end




    --角色
    CharacterMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
        local text=  e.GetDurabiliy(true, true)
        e.tips:AddLine(' ')
        e.tips:AddLine('|A:Warfronts-BaseMapIcons-Alliance-Armory-Minimap:0:0|a'..(e.onlyChinese and '耐久度' or DURABILITY)..' '..text)
        local item, cur, pvp= GetAverageItemLevel()
        cur= cur or 0
        item= item or 0
        pvp= pvp or 0
        e.tips:AddDoubleLine(
            (e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')
            ..(e.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL)..(cur==item and format(' |cnGREEN_FONT_COLOR:%.2f|r', cur) or format(' |cnRED_FONT_COLOR:%.2f|r/%.2f', cur, item)),
            format('%.02f', pvp)..' PvP|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a')
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
        button:set_alpha(true)
    end)
    CharacterMicroButton:HookScript('OnLeave', function()
        button:set_alpha(false)
    end)


    --天赋
    TalentMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
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
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
        button:set_alpha(true)
    end)
    TalentMicroButton:HookScript('OnLeave', function()
        button:set_alpha(false)
    end)

   


    --冒险指南
    LFDMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
        e.Get_Weekly_Rewards_Activities({showTooltip=true})--周奖励，提示
        e.tips:Show()
        button:set_alpha(true)
    end)
    LFDMicroButton:HookScript('OnLeave', function()
        button:set_alpha(false)
    end)







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
        button:set_alpha(true)
    end)
    EJMicroButton:HookScript('OnLeave', function()
        button:set_alpha(false)
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
        button:set_alpha(true)
    end)
    MainMenuMicroButton:HookScript('OnLeave', function()
        button:set_alpha(false)
    end)
    MainMenuMicroButton:EnableMouseWheel(true)--主菜单, 打开插件选项
    MainMenuMicroButton:HookScript('OnMouseWheel', function()
        e.call('InterfaceOptionsFrame_OpenToCategory', id)
    end)





    --提示，背包，总数
    MainMenuBarBackpackButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
        local text2, tab2= get_Mony_Tips()
        e.tips:AddLine(text2)

        for _, tab in pairs(tab2) do
            e.tips:AddDoubleLine(tab.text, tab.col..tab.money)
        end

        e.tips:AddLine(' ')

        local num= 0
        local tab={}
        for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
            local freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i)
            local numSlots= C_Container.GetContainerNumSlots(i) or 0
            if bagFamily == 0 and numSlots>0 and freeSlots then
                num= num + numSlots
                local icon
                if i== BACKPACK_CONTAINER then
                    icon= e.Icon.bag2
                else
                    local inventoryID = C_Container.ContainerIDToInventoryID(i)
                    local texture = inventoryID and GetInventoryItemTexture('player', inventoryID)
                    if texture then
                        icon= '|T'..texture..':0|t'
                    end
                end
                table.insert(tab, (freeSlots==0 and '|cnRED_FONT_COLOR:' or '')..(i+1)..') '..numSlots..(icon or '')..(freeSlots>0 and '|cnGREEN_FONT_COLOR:' or '')..freeSlots)
            end
        end

        e.tips:AddLine(num..' '..(e.onlyChinese and '总计' or TOTAL))
        for _, text in pairs(tab) do
            e.tips:AddLine(text)
        end
        e.tips:AddLine(' ')
        e.tips:AddLine(id..'  '..addName)


        e.tips:Show()
        button:set_alpha(true)
    end)
    MainMenuBarBackpackButton:HookScript('OnLeave', function()
        button:set_alpha(false)
    end)

end





























--#####
--主菜单
--#####
local function InitMenu(_, level, type)--主菜单
    local info
    if type=='wowMony' then
        info={
            text='WoW',
            checked= Save.moneyWoW,
            func= function()
                Save.moneyWoW= not Save.moneyWoW and true or nil
                set_Money_Event()
                set_Label_Point(true)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)
        return
    elseif type=='LOG_IN' then
        info={
            text= (e.onlyChinese and '登入' or LOG_IN)..' WoW: '..e.GetShowHide(true),
            checked= Save.framerateLogIn,
            func= function()
                Save.framerateLogIn= not Save.framerateLogIn and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)

        info={
            text= (e.onlyChinese and '重置位置' or RESET_POSITION),
            tooltipOnButton=true,
            tooltipTitle='CENTER',
            notCheckable=true,
            disabled= not Save.frameratePoint,
            func= function()
                Save.frameratePoint=nil
                if MoveFPSFrame then
                    FramerateFrame:ClearAllPoints()
                    FramerateFrame:SetPoint('CENTER')
                end
                print(id,e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)
        return
    end

    info={
        text= 'fps ms',
        checked= not Save.hideFpsMs,
        tooltipOnButton=true,
        tooltipTitle=format(e.onlyChinese and  "延迟：|n%.0f ms （本地）|n%.0f ms （世界）" or MAINMENUBAR_LATENCY_LABEL, select(3, GetNetStats())),
        func= function()
            Save.hideFpsMs= not Save.hideFpsMs and true or nil
            set_Fps_Ms_Show_Hide()--设置, fps, ms, 数值
            set_Label_Point(true)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    local text2, tab2= get_Mony_Tips()
    info={
        text= '|A:Coin-Gold:8:8|a'..(e.onlyChinese and '钱' or MONEY),
        checked=Save.money,
        menuList='wowMony',
        hasArrow=true,
        tooltipOnButton=true,
        tooltipTitle=text2,
        func= function()
            Save.money= not Save.money and true or nil
            set_Money_Event()--设置, 钱, 事件
            set_Label_Point(true)
        end
    }
    for _, tab3 in pairs(tab2) do
        info.tooltipText= (info.tooltipText or '')..'|n'..tab3.col..tab3.money.. ' '.. tab3.text..'|r'

    end
    e.LibDD:UIDropDownMenu_AddButton(info,level)


    info={
        text= '|A:activities-complete-diamond:0:0|a'..(e.onlyChinese and '旅行者日志进度' or MONTHLY_ACTIVITIES_PROGRESSED),
        checked=Save.perksPoints,
        func= function()
            Save.perksPoints= not Save.perksPoints and true or nil
            set_perksActivitiesLastPoints_Event()--贸易站, 点数
            set_Label_Point(true)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)


    info={
        text= '|A:Warfronts-BaseMapIcons-Alliance-Armory-Minimap:0:0|a'..(e.onlyChinese and '耐久度' or DURABILITY),
        checked= Save.durabiliy,
        func= function()
            Save.durabiliy = not Save.durabiliy and true or false
            set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
            set_Label_Point(true)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    info={
        text= (e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')..(e.onlyChinese and '装备等级' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EQUIPSET_EQUIP, LEVEL)),
        checked=Save.equipmetLevel,
        func= function()
            Save.equipmetLevel= not Save.equipmetLevel and true or nil
            set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
            set_Label_Point(true)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= (e.onlyChinese and '框架' or DEBUG_FRAMESTACK)..' MicroMenu',
        checked= Save.parent,
        tooltipOnButton=true,
        tooltipTitle= 'SetParent(MicroMenu)',
        colorCode= not StoreMicroButton:IsVisible() and '|cnRED_FONT_COLOR:',
        func= function()
            Save.parent= not Save.parent and true or nil
            set_Label_Point(true)--设置parent
            --[[for str, label in pairs(Labels) do
                create_Set_lable(label, str)
            end]]
            set_Money()--设置, 钱
            set_EquipmentLevel()--装等
            set_perksActivitiesLastPoints_CVar()--贸易站, 点数
            set_Durabiliy()--设置装等,耐久度,事件
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= (e.onlyChinese and '每秒帧数:' or FRAMERATE_LABEL)..' Plus',
        checked= Save.frameratePlus,
        menuList='LOG_IN',
        hasArrow=true,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '移动/大小' or (NPE_MOVE..'/'..e.Player.L.size),
        tooltipText= (e.onlyChinese and '系统' or SYSTEM)..' FPS',
        func= function()
            Save.frameratePlus= not Save.frameratePlus and true or nil
            if Save.frameratePlus and not MoveFPSFrame then
                Init_Framerate_Plus()--每秒帧数 Plus
            else
                print(id, e.cn(addName), e.GetEnabeleDisable(Save.frameratePlus) ,e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    info={
        text= 'MicroMenu Plus',
        checked= not Save.disabledMicroMenuPlus,
        tooltipOnButton=true,
        tooltipTitle= 'OnEnter',
        func= function()
            Save.disabledMicroMenuPlus= not Save.disabledMicroMenuPlus and true or nil
            print(id, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= '|A:mechagon-projects:0:0|a'..(e.onlyChinese and '选项' or OPTIONS),
        notCheckable=true,
        func= function()
            e.OpenPanelOpting('|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'..(e.onlyChinese and '系统信息' or addName))
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)
    info={
        text= id ..' '.. e.cn(addName),
        isTitle=true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)
end



































--######
--初始化
--######
local function Init()
    Frames={}

    Labels={}

    button=e.Cbtn(nil, {icon='hide',size={12,12}})
    button.texture= button:CreateTexture()
    button.texture:SetAllPoints(button)
    button.texture:SetAtlas(e.Icon.icon)

    e.Set_Label_Texture_Color(button.texture, {type='Texture', alpha=0.5})--设置颜色
    function button:set_alpha(show)
        if show then
            self.texture:SetAlpha(1)
            self:SetButtonState('PUSHED')
        else
            self:SetButtonState('NORMAL')
            self.texture:SetAlpha(0.5)
        end
    end
    button:SetFrameStrata('HIGH')
    button:SetMovable(true)
    button:RegisterForDrag("RightButton");
    button:SetClampedToScreen(true);
    button:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
            e.LibDD:CloseDropDownMenus()
        end
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
        ResetCursor()
    end)
    button:SetScript("OnMouseUp", ResetCursor)
    button:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' and IsAltKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    function button:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '每秒帧数' or FRAMERATE_FREQUENCY, format("%.1f", GetFramerate())..e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE, (Save.size or 12)..e.Icon.mid)
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
        if self.moveFPSFrame then
            self.moveFPSFrame:SetButtonState('PUSHED')
        end
        self:set_alpha(true)
    end
    button:SetScript('OnMouseWheel',function(self, d)
        if IsModifierKeyDown() then
            return
        end
        local size=Save.size or 12
        if d==1 then
            size=size+1
            size = size>72 and 72 or size
        elseif d==-1 then
            size=size-1
            size= size<6 and 6 or size
        end
        Save.size=size
        self:set_Label_Size_Color()
        self:set_tooltip()
    end)

    button:SetScript('OnClick', function(self, d)
        if d=='RightButton' then--移动光标
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, button, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        elseif d=='LeftButton' then
            FramerateFrame:Toggle()
        end
    end)
    button:SetScript('OnLeave', function(self)
        e.tips:Hide()
        if self.moveFPSFrame then
            self.moveFPSFrame:SetButtonState('NORMAL')
        end
        self:set_alpha(false)
    end)
    button:SetScript('OnEnter', button.set_tooltip)


    --设置位置
    function button:set_Label_Size_Color()
        for _, label in pairs(Labels) do
            e.Cstr(nil, {size=Save.size, changeFont=label, color=true})--Save.size, nil , Labels.fpsms, true)    
        end
    end
    function button:set_point()
        if Save.point then
            button:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        else
            button:SetPoint('BOTTOMRIGHT',-30, -2)
        end
    end
    button:set_point()
    button:set_Label_Size_Color()



    Init_MicroMenu_Plus()--MicroMenu Plus


    C_Timer.After(2, function()
        set_Money_Event()--设置,钱,事件
        set_Fps_Ms_Show_Hide()--设置, fps, ms, 数值
        set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
        set_perksActivitiesLastPoints_Event()--贸易站, 点数
        set_Label_Point()--设置 Label Poinst
        Init_Framerate_Plus()--每秒帧数 Plus
        Init_Guild()--公会
        if Save.parent and Labels.ms then
            MainMenuMicroButton.MainMenuBarPerformanceBar:ClearAllPoints()
            MainMenuMicroButton.MainMenuBarPerformanceBar:SetPoint('BOTTOM',0,-6)
        end
    end)






end








































panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

             --添加控制面板
             e.AddPanel_Check_Button({
                checkName= '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'..(e.onlyChinese and '系统信息' or addName),
                checkValue= not Save.disabled,
                checkFunc= function()
                    Save.disabled= not Save.disabled and true or nil
                    if not Save.disabled and not button then
                        Init()
                    else
                        print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                    end
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save.point=nil
                    if button then
                        Save.point=nil
                        button:ClearAllPoints()
                        button:set_point()--设置位置
                    end
                    print(id, e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= e.cn(addName),
                layout= nil,
                category= nil,
            })


            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                C_Timer.After(2, Init)
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_MONEY' then
        C_Timer.After(0.5, set_Money)

    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        set_Durabiliy()

    elseif event=='PLAYER_EQUIPMENT_CHANGED' then
        if Save.durabiliy then
            set_Durabiliy()
        end
        if Save.equipmetLevel then
            C_Timer.After(0.5, function()
                set_EquipmentLevel()--角色图标显示装等
            end)
        end

    elseif event=='CVAR_UPDATE' then
        if arg1=='perksActivitiesLastPoints' then
            set_perksActivitiesLastPoints_CVar()--贸易站, 点数
        end

    elseif event=='PERKS_ACTIVITY_COMPLETED' or event=='PERKS_ACTIVITIES_UPDATED' then
        C_Timer.After(2, set_perksActivitiesLastPoints_CVar)--贸易站, 点数

    elseif event=='GUILD_ROSTER_UPDATE' or event=='PLAYER_GUILD_UPDATE' then

    end
end)


