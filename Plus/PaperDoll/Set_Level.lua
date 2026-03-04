--更改,等级文本
--PaperDollFrame.lua
--Init_ChromieTime()--时空漫游战役, 提示
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end

local btn




local function Init()
    if Save().notLevel then
        return
    end

    btn= CreateFrame('Button', 'WoWToolsPaperDollLevelButton', PaperDollFrame, 'WowToolsButtonTemplate')
    btn:SetFrameStrata('HIGH')
    btn:SetSize(18,18)
    btn:SetPoint('TOPLEFT', CharacterLevelText)
    btn:SetPoint('BOTTOMLEFT', CharacterLevelText)
    btn:SetWidth(23)

    function btn:tooltip()
        local info = C_PlayerInfo.GetPlayerCharacterData()
        if not info then
            return
        end

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
    end

    CharacterLevelText:SetFontObject('WoWToolsFont')
    CharacterTrialLevelErrorText:SetFontObject('GameFontNormalSmall2')
    WoWTools_ColorMixin:SetLabelColor(CharacterLevelText)
    CharacterLevelText:SetJustifyH('LEFT')

    WoWTools_DataMixin:Hook('PaperDollFrame_SetLevel', function()
         if Save().notLevel then
            return
        end
        local size= 18
        local levelText

        local maxLevel= GetMaxLevelForLatestExpansion() or 0
        local level= UnitLevel("player") or 1
        local effectiveLevel = UnitEffectiveLevel("player") or 1

        if maxLevel> level then
            levelText= format('%d/%d', level, maxLevel)
        else
            levelText= format('%d', level)
        end

        if effectiveLevel ~= level then
            levelText = EFFECTIVE_LEVEL_FORMAT:format('|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r', levelText)--%s（%s）
        end

        CharacterLevelText:SetTextToFit(
            (WoWTools_UnitMixin:GetFaction('player', nil, true, {size=size}) or '')
            ..(WoWTools_UnitMixin:GetRaceIcon('player', nil, nil, {size=size}) or '')
            ..(WoWTools_UnitMixin:GetClassIcon('player', nil, nil, {size=size}) or '')
            ..format(WoWTools_DataMixin.onlyChinese and '等级 %s' or TOOLTIP_UNIT_LEVEL, levelText)
        )
    end)


--专精，职责
    CharacterFrame.specRole= btn:CreateTexture('WoWToolsPaperDollSpecRoleTexture', 'OVERLAY', nil, 7)
    CharacterFrame.specRole:SetSize(22,22)
    CharacterFrame.specRole:SetPoint('BOTTOMRIGHT', CharacterFrame.PortraitContainer, 2,0)



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















--战争模式
    local war= CreateFrame("Button", 'WoWToolsPaperDollWarModeButton', btn, 'WoWToolsButton2Template')
    war:SetPoint('RIGHT', btn, 'LEFT')
    war:SetSize(18, 18)
    war.texture:SetAtlas('pvptalents-warmode-swords')

    war.border:SetAtlas('talents-node-choiceflyout-circle-greenglow')
    war.border:SetPoint('TOPLEFT', -5, 5)
    war.border:SetAlpha(1)
    war.border:SetDrawLayer('BACKGROUND')

    function war:GetWarModeDesired()
        return UnitPopupSharedUtil.IsInWarModeState()
    end

    war:SetScript('OnEnter', function(self)
        if WarmodeButtonMixin then
            WarmodeButtonMixin.OnEnter(self)
            GameTooltip:AddLine(' ')
        else
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
        end

        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE)
            ..": |cnHIGHLIGHT_FONT_COLOR:"..WoWTools_TextMixin:GetEnabeleDisable(C_PvP.IsWarModeDesired())
        )

        if not C_PvP.ArePvpTalentsUnlocked() then
            if not WarmodeButtonMixin then
                GameTooltip_AddErrorLine(GameTooltip, format(
                    WoWTools_DataMixin.onlyChinese and '在%d级解锁' or PVP_TALENT_SLOT_LOCKED,
                    C_PvP.GetPvpTalentsUnlockedLevel() or 10
                ))
            end

        elseif not C_PvP.CanToggleWarMode(true) or not C_PvP.CanToggleWarMode(false) or InCombatLockdown() then
            GameTooltip_AddErrorLine(GameTooltip,
                WoWTools_DataMixin.onlyChinese and '当前不能操作' or SPELL_FAILED_NOT_HERE
            )
        end

        GameTooltip:Show()
    end)

    war:SetScript('OnClick', function()
        WoWTools_LoadUIMixin:SpellBook(2)
    end)



    function war:settings()
        self.texture:SetDesaturated(not C_PvP.IsWarModeDesired())
        local enabled= C_PvP.ArePvpTalentsUnlocked()
        self.border:SetShown(enabled and (C_PvP.CanToggleWarMode(true) or C_PvP.CanToggleWarMode(false)))
        self:SetAlpha(enabled and 1 or 0.3)
    end

    war:SetScript('OnHide', war.UnregisterAllEvents)
    war:SetScript('OnShow', function(self)
        self:RegisterEvent('PLAYER_FLAGS_CHANGED')
        self:RegisterEvent('PLAYER_UPDATE_RESTING')
        self:settings()
    end)
    war:SetScript('OnEvent', war.settings)










--装备,总耐久度
    local du= CreateFrame('Button', 'WoWToolsPaperDollDurabiliyButton', btn, 'WoWToolsButton2Template')
    du:SetPoint('RIGHT', war, 'LEFT')
    du:SetSize(18, 18)
    du.texture:SetPoint('TOPLEFT', -3, 3)
    du.texture:SetPoint('BOTTOMRIGHT', 3, -3)
    du.texture:RemoveMaskTexture(du.IconMask)

    du.Text= du:CreateFontString(nil, "BORDER", 'WoWToolsFont')
    du.Text:SetPoint('RIGHT', du, 'LEFT', 4, 0)
    du.Text:SetJustifyH('RIGHT')
    function du:tooltip()
        WoWTools_DurabiliyMixin:OnEnter()
    end

    function du:settings()
        local durabiliy, _, icon= WoWTools_DurabiliyMixin:Get(false)
        self.Text:SetText(durabiliy)
        self.texture:SetAtlas(icon:match('|A:(.-):'))
    end

    du:SetScript('OnShow', function(self)
        self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
        self:settings()
    end)
    du:SetScript('OnHide', du.UnregisterAllEvents)
    du:SetScript('OnEvent', du.settings)



    Init=function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetLevel')
        _G['WoWToolsPaperDollLevelButton']:SetShown(not Save().notLevel)
    end
end


















function WoWTools_PaperDollMixin:Init_SetLevel()
    Init()
end