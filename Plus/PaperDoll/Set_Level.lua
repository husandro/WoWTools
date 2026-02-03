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
        GameTooltip:SetText(WoWTools_PaperDollMixin.addName..WoWTools_DataMixin.Icon.icon2)
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
--专精
        local spec
        local icon, role= select(4, PlayerUtil.GetCurrentSpecID())
        if icon then
            spec= '|T'..icon..':'.. size..'|t'
            if role then
                spec= spec..'|A:spec-role-'..role..':'..size..':'..size..'|a'
            end
        end
--等级
        level= UnitLevel("player") or 1
        local effectiveLevel = UnitEffectiveLevel("player") or 1
        if effectiveLevel ~= level then
            level = EFFECTIVE_LEVEL_FORMAT:format('|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r', level)
        else
            level= format('%d', level)
        end


        CharacterLevelText:SetText(
            (WoWTools_UnitMixin:GetFaction('player', nil, true, {size=size}) or '')
            ..(WoWTools_UnitMixin:GetRaceIcon('player', nil, nil, {size=size}) or '')
            ..(WoWTools_UnitMixin:GetClassIcon('player', nil, nil, {size=size}) or '')
            ..(spec or '')
            ..format(WoWTools_DataMixin.onlyChinese and '等级 %s' or TOOLTIP_UNIT_LEVEL, level)
        )
    end)


    CharacterFrame.specRole= CharacterFrame.PortraitContainer:CreateTexture('WoWToolsPaperDollSpecRoleTexture', 'OVERLAY', nil, 7)
    CharacterFrame.specRole:SetSize(22,22)
    CharacterFrame.specRole:SetPoint('BOTTOMRIGHT')



    WoWTools_DataMixin:Hook(CharacterFrame, 'SetPortraitToSpecIcon', function(self)
        local specialization = C_SpecializationInfo.GetSpecialization()
        local atlas
        if specialization ~= nil then
            local role = select(5, C_SpecializationInfo.GetSpecializationInfo(specialization));
            if role then
                atlas= 'UI-LFG-RoleIcon-'..role
            end
        end
        if atlas then
            self.specRole:SetAtlas(atlas)
        else
            self.specRole:SetTexture(0)
        end
    end)

    Init=function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetLevel')
    end
end





















function WoWTools_PaperDollMixin:Init_SetLevel()
    Init()
end