--更改,等级文本
--PaperDollFrame.lua
--Init_ChromieTime()--时空漫游战役, 提示
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end






local function Init()
    WoWTools_ColorMixin:Setup(CharacterLevelText, {type='FontString'})

    CharacterLevelText:SetJustifyH('LEFT')
    CharacterLevelText:EnableMouse(true)
    CharacterLevelText:HookScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    CharacterLevelText:HookScript('OnEnter', function(self)
        local info = C_PlayerInfo.GetPlayerCharacterData()
        if Save().hide or not info then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_PaperDollMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine('name |cnGREEN_FONT_COLOR:'..info.name)
        GameTooltip:AddLine('fileName |cnGREEN_FONT_COLOR:'..info.fileName)
        GameTooltip:AddLine('sex |cnGREEN_FONT_COLOR:'..info.sex)
        GameTooltip:AddLine('displayID |cnGREEN_FONT_COLOR:'..C_PlayerInfo.GetDisplayID())
        GameTooltip:AddDoubleLine((info.createScreenIconAtlas and '|A:'..info.createScreenIconAtlas..':0:0|a' or '')..'createScreenIconAtlas', info.createScreenIconAtlas)
        GameTooltip:AddDoubleLine('GUID', UnitGUID('player'))
        GameTooltip:AddLine(' ')

        local expansionID = UnitChromieTimeID('player')--时空漫游战役 PartyUtil.lua
        local option = C_ChromieTime.GetChromieTimeExpansionOption(expansionID)
        local expansion = option and WoWTools_TextMixin:CN(option.name) or (WoWTools_DataMixin.onlyChinese and '无' or NONE)
        if option and option.previewAtlas then
            expansion= '|A:'..option.previewAtlas..':0:0|a'..expansion
        end

        GameTooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '选择时空漫游战役' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHROMIE_TIME_SELECT_EXAPANSION_BUTTON, CHROMIE_TIME_PREVIEW_CARD_DEFAULT_TITLE))
            ..': '
            ..WoWTools_TextMixin:GetEnabeleDisable(C_PlayerInfo.CanPlayerEnterChromieTime()),

            format(
                WoWTools_DataMixin.onlyChinese and '你目前处于|cffffffff时空漫游战役：%s|r' or PARTY_PLAYER_CHROMIE_TIME_SELF_LOCATION,

                expansion or WoWTools_TextMixin:GetYesNo(false)
            )
        )

        GameTooltip:AddLine(' ')
        for _, info2 in pairs(C_ChromieTime.GetChromieTimeExpansionOptions() or {}) do
            local col= info2.alreadyOn and '|cffff00ff' or ''-- option and option.id==info.id
            GameTooltip:AddDoubleLine((info2.alreadyOn and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight) or '')..col..(info2.previewAtlas and '|A:'..info2.previewAtlas..':0:0|a' or '')..info2.name..(info2.alreadyOn and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft) or '')..col..' ID '.. info2.id, col..(WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE)..': '..WoWTools_TextMixin:GetYesNo(info2.completed))
        end

        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)

    WoWTools_DataMixin:Hook('PaperDollFrame_SetLevel', function()
         if Save().hide then
            return
        end

        local level
        level= UnitLevel("player") or 1
        local effectiveLevel = UnitEffectiveLevel("player") or 1

        if effectiveLevel ~= level then
            level = EFFECTIVE_LEVEL_FORMAT:format('|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r', level)
        else
            level= format('%d', level)
        end

        CharacterLevelText:SetText(
            (WoWTools_UnitMixin:GetFaction('player', nil, true, {size=26}) or '')
            ..(WoWTools_UnitMixin:GetRaceIcon('player', nil, nil, {size=26}) or '')
            ..(WoWTools_UnitMixin:GetClassIcon('player', nil, nil, {size=26}) or '')
            ..format(WoWTools_DataMixin.onlyChinese and '等级 %s' or TOOLTIP_UNIT_LEVEL, level)
        )
    end)

    Init=function()end
end





















function WoWTools_PaperDollMixin:Init_SetLevel()
    Init()
end