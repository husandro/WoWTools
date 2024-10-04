--更改,等级文本
--PaperDollFrame.lua
--Init_ChromieTime()--时空漫游战役, 提示
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end






local function Init()
    WoWTools_ColorMixin:SetLabelTexture(CharacterLevelText, {type='FontString'})

    CharacterLevelText:SetJustifyH('LEFT')
    CharacterLevelText:EnableMouse(true)
    CharacterLevelText:HookScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
    CharacterLevelText:HookScript('OnEnter', function(self)
        local info = C_PlayerInfo.GetPlayerCharacterData()
        if Save().hide or not info then
            return
        end
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_PaperDollMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddLine('name |cnGREEN_FONT_COLOR:'..info.name)
        e.tips:AddLine('fileName |cnGREEN_FONT_COLOR:'..info.fileName)
        e.tips:AddLine('sex |cnGREEN_FONT_COLOR:'..info.sex)
        e.tips:AddLine('displayID |cnGREEN_FONT_COLOR:'..C_PlayerInfo.GetDisplayID())
        e.tips:AddDoubleLine((info.createScreenIconAtlas and '|A:'..info.createScreenIconAtlas..':0:0|a' or '')..'createScreenIconAtlas', info.createScreenIconAtlas)
        e.tips:AddDoubleLine('GUID', UnitGUID('player'))
        e.tips:AddLine(' ')

        local expansionID = UnitChromieTimeID('player')--时空漫游战役 PartyUtil.lua
        local option = C_ChromieTime.GetChromieTimeExpansionOption(expansionID)
        local expansion = option and e.cn(option.name) or (e.onlyChinese and '无' or NONE)
        if option and option.previewAtlas then
            expansion= '|A:'..option.previewAtlas..':0:0|a'..expansion
        end
        local text= format(e.onlyChinese and '你目前处于|cffffffff时空漫游战役：%s|r' or PARTY_PLAYER_CHROMIE_TIME_SELF_LOCATION, expansion)
        e.tips:AddDoubleLine((e.onlyChinese and '选择时空漫游战役' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHROMIE_TIME_SELECT_EXAPANSION_BUTTON, CHROMIE_TIME_PREVIEW_CARD_DEFAULT_TITLE))..': '..e.GetEnabeleDisable(C_PlayerInfo.CanPlayerEnterChromieTime()),
                                text
                            )
        e.tips:AddLine(' ')
        for _, info2 in pairs(C_ChromieTime.GetChromieTimeExpansionOptions() or {}) do
            local col= info2.alreadyOn and '|cffff00ff' or ''-- option and option.id==info.id
            e.tips:AddDoubleLine((info2.alreadyOn and format('|A:%s:0:0|a', e.Icon.toRight) or '')..col..(info2.previewAtlas and '|A:'..info2.previewAtlas..':0:0|a' or '')..info2.name..(info2.alreadyOn and format('|A:%s:0:0|a', e.Icon.toLeft) or '')..col..' ID '.. info2.id, col..(e.onlyChinese and '完成' or COMPLETE)..': '..e.GetYesNo(info2.completed))
            --e.tips:AddDoubleLine(' ', col..(info.mapAtlas and '|A:'..info.mapAtlas..':0:0|a'.. info.mapAtlas))
            --e.tips:AddDoubleLine(' ', col..(info.previewAtlas and '|A:'..info.previewAtlas..':0:0|a'.. info.previewAtlas))
            --e.tips:AddDoubleLine(' ', col..(e.onlyChinese and '完成' or COMPLETE)..': '..e.GetYesNo(info.completed))
        end

        e.tips:Show()
        self:SetAlpha(0.3)
    end)
end

















local function Settings()
    if Save().hide then
        return
    end

    local race= WoWTools_UnitMixin:GetRaceIcon({unit='player', guid=nil , race=nil , sex=nil , reAtlas=true})
    local class= WoWTools_UnitMixin:GetClassIcon('player', nil, true)
    local level
    level= UnitLevel("player")
    local effectiveLevel = UnitEffectiveLevel("player")

    if ( effectiveLevel ~= level ) then
        level = EFFECTIVE_LEVEL_FORMAT:format('|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r', level)
    end
    local faction= format('|A:%s:26:26|a', e.Icon[e.Player.faction] or '')

    CharacterLevelText:SetText('  '..faction..(race and '|A:'..race..':26:26|a' or '')..(class and '|A:'..class..':26:26|a  ' or '')..level)
end







function WoWTools_PaperDollMixin:Init_SetLevel()
    Init()
    hooksecurefunc('PaperDollFrame_SetLevel', Settings)
end