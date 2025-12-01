
WoWTools_CombatMixin={}
local P_Save= {
    textScale=1.2,
    SayTime=120,--每隔
    disabledSayTime= not WoWTools_DataMixin.Player.husandro,
    --AllOnlineTime=true,--进入游戏时,提示游戏,时间

    bat={num= 0, time= 0},--战斗数据
    pet={num= 0,  win=0, capture=0},
    ins={num= 0, time= 0, kill=0, dead=0},
    afk={num= 0, time= 0},


    inCombatScale=1,--战斗中缩放
}

local function Save()
    return WoWToolsSave['ChatButton_Combat']
end










local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2, name
    local isInCombat= UnitAffectingCombat('player')
--战斗信息

    sub=root:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '战斗信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, INFO), function()
        return not Save().disabledText
    end, function()
        self:set_Click()
    end)

    sub:CreateCheckbox((WoWTools_DataMixin.onlyChinese and '时间类型' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TIME_LABEL:gsub(HEADER_COLON,''), TYPE))..' '.. SecondsToTime(35), function()
        return Save().timeTypeText
    end, function()
        Save().timeTypeText= not Save().timeTypeText and true or nil
    end)

    sub2=sub:CreateCheckbox((WoWTools_DataMixin.onlyChinese and '战斗时间' or COMBAT)..'|A:communities-icon-chat:0:0|a|cnGREEN_FONT_COLOR:'..Save().SayTime, function()
        return not Save().disabledSayTime
    end, function()
        Save().disabledSayTime= not Save().disabledSayTime and true or false
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '说' or SAY)
    end)

    sub2:CreateButton(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS, function()
        StaticPopup_Show('WoWTools_EditText',
        WoWTools_CombatMixin.addName
        ..'|n|n'.. (WoWTools_DataMixin.onlyChinese and '时间戳' or EVENTTRACE_TIMESTAMP)..' '..(WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
        ..'|n|n>= 60 '..WoWTools_TextMixin:GetEnabeleDisable(true),
        nil,
        {
            OnShow=function(s)
                local edit= s.editBox or s:GetEditBox()
                edit:SetNumeric(true)
                edit:SetNumber(Save().SayTime or 120)
            end,
            OnHide=function(s)
                s.editBox:SetNumeric(false)
            end,
            SetValue= function(s)
                local edit= s.editBox or s:GetEditBox()
                local num=edit:GetNumber()
                WoWTools_ChatMixin:Chat(WoWTools_TimeMixin:SecondsToClock(num), nil, nil)
                Save().SayTime= num
            end,
            EditBoxOnTextChanged=function(s)
                local num= s:GetNumber() or 0
                local p= s:GetParent()
                local b1= p:GetButton1()
                b1:SetEnabled(num>=60 and num<2147483647)
            end,
        }
    )
        return MenuResponse.Open
    end)

    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save().SayTime
        end, setValue=function(value)
            Save().SayTime= math.floor(value)
            WoWTools_ChatMixin:Chat(WoWTools_TimeMixin:SecondsToClock(Save().SayTime), nil, nil)
        end,
        name= WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS,
        minValue=60,
        maxValue=600,
        step=1,
        bit=nil,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '时间戳' or EVENTTRACE_TIMESTAMP)
        end,
    })
    sub2:CreateSpacer()

    --[[sub2:CreateButton(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS, function()
        StaticPopup_Show('WoWToolsChatButtonCombatSayTime')
        return MenuResponse.Open
    end)]]

    sub:CreateDivider()
    sub:CreateButton(WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION, function()
        Save().textFramePoint=nil
        if _G['WoWToolsChatCombatTrackButton'] then
            _G['WoWToolsChatCombatTrackButton']:set_Point()
        end
        print(
            WoWTools_CombatMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
        )
        return MenuResponse.Open
    end)

    name= (isInCombat and '|cff626262' or '')..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
    sub2=sub:CreateButton(
        name,
    function()
        StaticPopup_Show('WoWTools_RestData',
            WoWTools_CombatMixin.addName
            ..'\n'
            ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
            ..'\n\n|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI),
        nil,
        function()
            WoWToolsSave['ChatButton_Combat']= nil
            WoWTools_DataMixin:Reload()
        end)

        return MenuResponse.Open
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
    end)



--缩放
    root:CreateDivider()

    sub= WoWTools_MenuMixin:Scale(self, root, function()
        return Save().inCombatScale or 1
    end, function(value)
        Save().inCombatScale= value

        self:set_Sacle_InCombat(true)
        self:SetButtonState('NORMAL')
        if self:GetScale()==value then
            C_Timer.After(3, function()
                self:set_Sacle_InCombat(UnitAffectingCombat('player'))
            end)
        end
    end)
    if sub then
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '战斗中缩放'
                    or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, UI_SCALE)
            )
        end)
    end

--游戏时间
    local tab=WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Time
    sub=root:CreateCheckbox(
        tab.totalTime and WoWTools_TimeMixin:SecondsToFullTime(tab.totalTime, tab.upData)
        or (WoWTools_DataMixin.onlyChinese and '游戏时间' or TOKEN_REDEEM_GAME_TIME_TITLE or SLASH_PLAYED2:gsub('/', '')),
    function()
        return Save().AllOnlineTime
    end, function ()
        Save().AllOnlineTime = not Save().AllOnlineTime and true or nil
        RequestTimePlayed()
    end, tab)
    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '游戏时间' or TOKEN_REDEEM_GAME_TIME_TITLE or SLASH_PLAYED2:gsub('/', ''),
            WoWTools_TimeMixin:SecondsToFullTime(desc.data.totalTime, desc.data.upData)
        )
        tooltip:AddDoubleLine(
            format(WoWTools_DataMixin.onlyChinese and '你在这个等级的游戏时间：%s' or TIME_PLAYED_LEVEL, ''),
            WoWTools_TimeMixin:SecondsToFullTime(desc.data.levelTime, desc.data.upData)
        )
    end)

    --[[local timeAll=0
    local numPlayer=0
    for guid, tab2 in pairs(WoWTools_WoWDate or {}) do
        local time= tab2.Time and tab2.Time.totalTime
        if time and time>0 then
            numPlayer= numPlayer+1
            timeAll= timeAll + time
            sub:CreateTitle(
                WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true, factionName=tab.faction})
                ..'|A:socialqueuing-icon-clock:0:0|a'
                ..SecondsToTime(time)
            )
        end
    end
    WoWTools_MenuMixin:SetScrollMode(sub)

    sub:CreateDivider()
    if timeAll>0 then
        sub:CreateTitle((WoWTools_DataMixin.onlyChinese and '总计：' or FROM_TOTAL).. SecondsToTime(timeAll))
    end]]
    WoWTools_DataMixin:OpenWoWItemListMenu(self, root, 'Time')--战团，物品列表

    root:CreateDivider()
    sub=root:CreateButton(
        '|T'..FRIENDS_TEXTURE_AFK..':0|t'
        ..(UnitIsAFK('player') and '|cff626262' or '')
        ..(WoWTools_DataMixin.onlyChinese and '暂离' or 'AFK'),
    function()
        WoWTools_ChatMixin:SendText(SLASH_CHAT_AFK1)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(SLASH_CHAT_AFK1)
    end)
end














local function Init()
    local btn= WoWTools_ChatMixin:GetButtonForName('Combat')

    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -2)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 4)

    btn.IconMask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask')
    btn.IconMask:SetPoint("TOPLEFT", btn, "TOPLEFT", 6.5, -6.5)
    btn.IconMask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -8.5, 8.5)

    btn.texture2=btn:CreateTexture(nil, 'OVERLAY')
    --btn.texture2:SetAllPoints(btn)
    btn.texture2:SetPoint("TOPLEFT", btn, "TOPLEFT", -2,2)
    btn.texture2:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2,-2)
    btn.texture2:AddMaskTexture(btn.IconMask)
    btn.texture2:SetColorTexture(1,0,0)
    btn.texture2:SetShown(false)

    function btn:set_texture()
        self.texture:SetAtlas(WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction] or WoWTools_DataMixin.Icon['Neutral'])
        self.texture:SetDesaturated(Save().disabledText and true or false)--禁用/启用 TrackButton, 提示
    end



    function btn:set_Sacle_InCombat(bat)--提示，战斗中
        self.texture2:SetShown(bat)
        self:SetScale(bat and Save().inCombatScale or 1)
    end

    function btn:set_Click()
        Save().disabledText = not Save().disabledText and true or nil
        self:set_texture()
        WoWTools_CombatMixin:Init_TrackButton()
    end

    function btn:set_tooltip()
        self:set_owner()
        WoWTools_CombatMixin:Set_Combat_Tooltip(GameTooltip)
        GameTooltip:Show()
    end

    function btn:set_OnMouseDown()
        self:set_Click()
    end

    --[[function btn:HandlesGlobalMouseEvent(_, event)
        return event == "GLOBAL_MOUSE_DOWN"-- and buttonName == "RightButton";
    end]]


    function btn:set_OnLeave()
        if _G['WoWToolsChatCombatTrackButton'] then
            _G['WoWToolsChatCombatTrackButton']:SetButtonState('NORMAL')
        end
    end

    function btn:set_OnEnter()
        if _G['WoWToolsChatCombatTrackButton'] then
            _G['WoWToolsChatCombatTrackButton']:SetButtonState('PUSHED')
        end
    end




    btn:RegisterEvent('PLAYER_REGEN_DISABLED')
    btn:RegisterEvent('PLAYER_REGEN_ENABLED')
    --btn:RegisterEvent('PLAYER_ENTERING_WORLD')
    btn:RegisterEvent('NEUTRAL_FACTION_SELECT_RESULT')

    btn:SetScript("OnEvent", function(self, event)--提示，战斗中, 是否在战场
        if event=='PLAYER_REGEN_ENABLED' then
            self:set_Sacle_InCombat(false)--提示，战斗中
            
        elseif event=='PLAYER_REGEN_DISABLED' then
            self:set_Sacle_InCombat(true)

        elseif event=='NEUTRAL_FACTION_SELECT_RESULT' then
            self:set_texture()
        end
    end)

    btn:set_Sacle_InCombat(UnitAffectingCombat('player'))--提示，战斗中  
    btn:set_texture()

    btn:SetupMenu(Init_Menu)

    Init=function()end
end














local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWToolsSave['ChatButton_Combat']= WoWToolsSave['ChatButton_Combat'] or P_Save
    P_Save=nil

    WoWTools_CombatMixin.addName= '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'..(WoWTools_DataMixin.onlyChinese and '战斗信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, INFO))

    local notData= not WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Time.totalTime
                or not WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Time.upData

    if WoWTools_ChatMixin:CreateButton('Combat', WoWTools_CombatMixin.addName) then--禁用Chat Button
        if WoWToolsSave['ChatButton_Combat'].SayTime==0 then
            WoWToolsSave['ChatButton_Combat'].disabledSayTime= true
            WoWToolsSave['ChatButton_Combat'].SayTime=120
        end

        Init()

        WoWTools_CombatMixin:Init_TrackButton()

        if WoWToolsSave['ChatButton_Combat'].AllOnlineTime or notData then
            RequestTimePlayed()--总游戏时间
        end

    elseif notData then
        RequestTimePlayed()
    end

    self:SetScript('OnEvent', nil)
    self:UnregisterEvent(event)
end)