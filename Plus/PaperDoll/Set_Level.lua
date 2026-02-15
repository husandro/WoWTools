--更改,等级文本
--PaperDollFrame.lua
--Init_ChromieTime()--时空漫游战役, 提示
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end






local function Init()
    if Save().notLevel then
        return
    end

    CharacterLevelText:SetFontObject('GameFontNormal')
    CharacterLevelText:SetShadowOffset(1,-1)
    CharacterTrialLevelErrorText:SetFontObject('GameFontNormalSmall2')
    WoWTools_ColorMixin:SetLabelColor(CharacterLevelText)

    CharacterLevelText:SetJustifyH('LEFT')
    CharacterLevelText:EnableMouse(true)
    CharacterLevelText:HookScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    CharacterLevelText:HookScript('OnEnter', function(self)
        local info = C_PlayerInfo.GetPlayerCharacterData()
        if Save().notLevel or not info then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip_SetTitle(GameTooltip, WoWTools_PaperDollMixin.addName..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            'name |cffffffff'..info.name,
            'fileName |cffffffff'..info.fileName
        )
        GameTooltip:AddDoubleLine(
            'sex |cffffffff'
            ..(info.sex==Enum.UnitSex.Male and '|A:charactercreate-gendericon-male-selected:0:0|a'..(WoWTools_DataMixin.onlyChinese and '男' or BODY_1)
                or (info.sex==Enum.UnitSex.Female and '|A:charactercreate-gendericon-female-selected:0:0|a'..(WoWTools_DataMixin.onlyChinese and '女' or BODY_2))
                or ''
            )
            ..' '..info.sex,
            info.createScreenIconAtlas and '|A:'..info.createScreenIconAtlas..':0:0|a|cffffffff'..info.createScreenIconAtlas
        )
        GameTooltip:AddDoubleLine('GUID |cffffffff'..WoWTools_DataMixin.Player.GUID,
                'displayID |cffffffff'..C_PlayerInfo.GetDisplayID()
        )
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '满级' or GUILD_RECRUITMENT_MAXLEVEL,
            GetMaxLevelForLatestExpansion(), nil,nil,nil,
            1,1,1
        )

        GameTooltip:AddLine(' ')

        local expansionID = UnitChromieTimeID('player')--时空漫游战役 PartyUtil.lua
        local option = C_ChromieTime.GetChromieTimeExpansionOption(expansionID)
        local expansion = option and WoWTools_TextMixin:CN(option.name) or (WoWTools_DataMixin.onlyChinese and '无' or NONE)
        if option and option.previewAtlas then
            expansion= '|A:'..option.previewAtlas..':0:0|a'..expansion
        end

        GameTooltip:AddLine(
            (WoWTools_DataMixin.onlyChinese and '选择时空漫游战役' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHROMIE_TIME_SELECT_EXAPANSION_BUTTON, CHROMIE_TIME_PREVIEW_CARD_DEFAULT_TITLE))
            ..': '
            ..WoWTools_TextMixin:GetEnabeleDisable(C_PlayerInfo.CanPlayerEnterChromieTime())
        )
        GameTooltip:AddLine(
            format(
                WoWTools_DataMixin.onlyChinese and '你目前处于|cffffffff时空漫游战役：%s|r' or PARTY_PLAYER_CHROMIE_TIME_SELF_LOCATION,

                expansion or WoWTools_TextMixin:GetYesNo(false)
            )
        )

       -- GameTooltip:AddLine(' ')
        for _, data in pairs(C_ChromieTime.GetChromieTimeExpansionOptions() or {}) do
            local col= data.alreadyOn and '|cffff00ff' or ''-- option and option.id==info.id
            local icon=data.previewAtlas and '|A:'..data.previewAtlas..':0:0|a' or ''
            GameTooltip:AddDoubleLine(
                (data.alreadyOn and '|A:common-icon-rotateright:0:0|a' or '')
                ..col
                ..icon
                ..WoWTools_TextMixin:CN(data.name)
                ..(data.alreadyOn and '|A:common-icon-rotateleft:0:0|a' or '')
                ..' |cffffffff'
                .. data.id,

                col
                ..(WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE)..': '
                ..WoWTools_TextMixin:GetYesNo(data.completed)
                ..icon
            )
        end

        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)


    WoWTools_DataMixin:Hook('PaperDollFrame_SetLevel', function()
         if Save().notLevel then
            return
        end
        local size= 18
        local level
        level= UnitLevel("player") or 1
        local effectiveLevel = UnitEffectiveLevel("player") or 1
        if effectiveLevel ~= level then
            level = EFFECTIVE_LEVEL_FORMAT:format('|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r', level)
        else
            level= format('%d', level)
        end

        CharacterLevelText:SetTextToFit(
            (WoWTools_UnitMixin:GetFaction('player', nil, true, {size=size}) or '')
            ..(WoWTools_UnitMixin:GetRaceIcon('player', nil, nil, {size=size}) or '')
            ..(WoWTools_UnitMixin:GetClassIcon('player', nil, nil, {size=size}) or '')
            ..format(WoWTools_DataMixin.onlyChinese and '等级 %s' or TOOLTIP_UNIT_LEVEL, level)
        )
    end)


--专精，职责
    CharacterFrame.specRole= CharacterFrame.PortraitContainer:CreateTexture('WoWToolsPaperDollSpecRoleTexture', 'OVERLAY', nil, 7)
    CharacterFrame.specRole:SetSize(22,22)
    CharacterFrame.specRole:SetPoint('BOTTOMRIGHT',2,0)



    WoWTools_DataMixin:Hook(CharacterFrame, 'UpdatePortrait', function(self)
        local atlas, specialization

        if self.activeSubframe == "PaperDollFrame" and not Save().notLevel then
            specialization= C_SpecializationInfo.GetSpecialization()
        end
        if specialization ~= nil then
            local role = select(5, C_SpecializationInfo.GetSpecializationInfo(specialization))
            if role then
                atlas= GetMicroIconForRole(role)
            end
        end
        if atlas then
            self.specRole:SetAtlas(atlas)
        else
            self.specRole:SetTexture(0)
        end
    end)












    local Frame= CreateFrame('Frame', 'WoWToolsPaperDollAllDurationFrame', PaperDollItemsFrame)
    Frame:SetSize(1, 1)
    Frame:SetPoint('RIGHT', CharacterLevelText, 'LEFT')

--战争模式
    Frame.warMode= Frame:CreateTexture(nil, 'BORDER')
    Frame.warMode:SetPoint('RIGHT', Frame, 'LEFT')
    Frame.warMode:SetSize(18, 18)
    Frame.warMode:SetAtlas('pvptalents-warmode-swords')
    Frame.warMode:EnableMouse(true)
    function Frame.warMode:GetWarModeDesired()
        return UnitPopupSharedUtil.IsInWarModeState()
    end
    Frame.warMode:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip_Hide()
    end)
    Frame.warMode:SetScript('OnEnter', function(self)
        self:SetAlpha(0.3)
        if WarmodeButtonMixin then
            WarmodeButtonMixin.OnEnter(self)
            return
        end

        GameTooltip:SetOwner(PlayerFrame, "ANCHOR_LEFT")
        GameTooltip_SetTitle(GameTooltip, WoWTools_UnitMixin.addName..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE, WoWTools_TextMixin:GetEnabeleDisable(C_PvP.IsWarModeDesired())..WoWTools_DataMixin.Icon.left)

        if not C_PvP.ArePvpTalentsUnlocked() then
			GameTooltip_AddErrorLine(
                GameTooltip,
                format(
                    WoWTools_DataMixin.onlyChinese and '在%d级解锁' or PVP_TALENT_SLOT_LOCKED,
                    C_PvP.GetPvpTalentsUnlockedLevel()
                ),
            true)

        elseif not C_PvP.CanToggleWarMode(true) or not C_PvP.CanToggleWarMode(false) or InCombatLockdown() then
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '当前不能操作' or SPELL_FAILED_NOT_HERE, 1,0,0)
		end
        GameTooltip:Show()
    end)

    Frame.warModeBg= Frame:CreateTexture(nil, 'BACKGROUND')
    Frame.warModeBg:SetSize(26, 26)
    Frame.warModeBg:SetPoint('CENTER', Frame.warMode)
    Frame.warModeBg:SetAtlas('pvptalents-talentborder-glow')


--装备,总耐久度
    Frame.durabiliy= Frame:CreateFontString(nil, 'BORDER', 'GameFontNormal')
    Frame.durabiliy:SetShadowOffset(1,-1)
    Frame.durabiliy:SetPoint('RIGHT', Frame.warMode, 'LEFT',0,1)
    Frame.durabiliy:EnableMouse(true)
    WoWTools_ColorMixin:SetLabelColor(Frame.durabiliy)
    Frame.durabiliy:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    Frame.durabiliy:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip_SetTitle(GameTooltip, WoWTools_PaperDollMixin.addName..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(' ')
        WoWTools_DurabiliyMixin:OnEnter()
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)

    function Frame:settings()
        self.durabiliy:SetText(WoWTools_DurabiliyMixin:Get(true))
        self.warMode:SetDesaturated(not C_PvP.IsWarModeDesired())
        self.warMode:SetShown(C_PvP.ArePvpTalentsUnlocked())
        self.warModeBg:SetShown(C_PvP.CanToggleWarMode(true) or C_PvP.CanToggleWarMode(false))
    end

    function Frame:set_event()
        if self:IsVisible() and not Save().notLevel then
            self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')

            --self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('PLAYER_FLAGS_CHANGED')
            self:RegisterEvent('PLAYER_UPDATE_RESTING')

            self:settings()
        else
            self:UnregisterAllEvents()
            self.durabiliy:SetText('')
        end
    end

    Frame:SetScript('OnShow', Frame.set_event)
    Frame:SetScript('OnHide', Frame.set_event)
    Frame:SetScript('OnEvent', Frame.settings)
    Frame:set_event()




    Init=function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetLevel')
        WoWTools_DataMixin:Call(CharacterFrame.UpdatePortrait, CharacterFrame)
        _G['WoWToolsPaperDollAllDurationFrame']:SetShown(not Save().notLevel)
    end
end


















function WoWTools_PaperDollMixin:Init_SetLevel()
    Init()
end