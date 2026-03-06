
WoWTools_CombatMixin={}

local function Save()
    return WoWToolsSave['ChatButton_Combat']
end










local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

--战斗信息
    local sub=root:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '战斗信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, INFO), function()
        return not Save().button.disabled
    end, function()
        self:set_Click()
    end)

--重置位置
    sub:CreateButton(
        (Save().textFramePoint and '' or '|cff626262')
        ..(WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION),
    function()
        Save().button.point=nil
        WoWTools_CombatMixin:Init_TrackButton()
        return MenuResponse.Refresh
    end)
--战斗信息, 选项
    --WoWTools_CombatMixin:Init_TrackMenu(self, sub)

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
                self:set_Sacle_InCombat(InCombatLockdown())
            end)
        end
    end)
    if sub then
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '战斗中缩放'
                    or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, HOUSING_EXPERT_DECOR_SUBMODE_SCALE)
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

    WoWTools_DataMixin:OpenWoWItemListMenu(self, root, 'Time')--战团，物品列表

    root:CreateDivider()
    sub=root:CreateButton(
        '|T'..FRIENDS_TEXTURE_AFK..':0|t'
        ..(WoWTools_UnitMixin:UnitIsAFK('player') and '|cff626262' or '')
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
        self.texture:SetDesaturated(Save().button.disabled and true or false)--禁用/启用 TrackButton, 提示
    end



    function btn:set_Sacle_InCombat(bat)--提示，战斗中
        self.texture2:SetShown(bat)
        self:SetScale(bat and Save().inCombatScale or 1)
    end

    function btn:set_Click()
        Save().button.disabled = not Save().button.disabled and true or nil
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

    btn:set_Sacle_InCombat(InCombatLockdown())--提示，战斗中  
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

    WoWToolsSave['ChatButton_Combat']= WoWToolsSave['ChatButton_Combat'] or {
        textScale=1,
        inCombatScale=1,--战斗中缩放
        button={
            disabled= not WoWTools_DataMixin.Player.husandro,
            InstanceDate={num=0, time=0, kill=0, dead=0, map=nil, onInsTime=nil},
        }
    }


    WoWToolsPlayerDate['CombatTimeLog']= WoWToolsPlayerDate['CombatTimeLog'] or {
        bat={num= 0, time= 0},--战斗数据
        pet={num= 0, win=0, capture=0},
        ins={num= 0, time= 0, kill=0, dead=0},
        afk={num= 0, time= 0},
    }

    if not Save().button then--旧数据
        Save().button= {
            disabled= Save().disabledText,
            isNotClockType= Save().timeTypeText,
            bgAlpha= Save().textAlpha,
            scale= Save().textScale,
            strata= Save().trckStrata,
            point= Save().textFramePoint,
            InstanceDate={num=0, time=0, kill=0, dead=0, map=nil, onInsTime=nil},
        }

        Save().disabledText= nil
        Save().disabledSayTime= nil
        Save().SayTime= nil
        Save().textAlpha= nil
        Save().textScale= nil
        Save().textFramePoint= nil
    end


    WoWTools_CombatMixin.addName= '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'..(WoWTools_DataMixin.onlyChinese and '战斗信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, INFO))

    local notData= not WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Time.totalTime
                or not WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Time.upData

    if WoWTools_ChatMixin:CreateButton('Combat', WoWTools_CombatMixin.addName) then--禁用Chat Button

        Init()

        WoWTools_CombatMixin:Init_TrackButton()

        if Save().AllOnlineTime or notData then
            RequestTimePlayed()--总游戏时间
        end

    elseif notData then
        RequestTimePlayed()
    end

    self:SetScript('OnEvent', nil)
    self:UnregisterEvent(event)
end)