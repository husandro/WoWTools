

--设置单位, 玩家
function WoWTools_TooltipMixin:Set_Unit_Player(tooltip, name, unit, guid)
    if self:IsInCombatDisabled(tooltip)
        or not WoWTools_UnitMixin:UnitExists(unit)
        or not canaccessvalue(name)
        or not canaccessvalue(unit)
        or not canaccessvalue(guid)
    then
        return
    end

    local realm= select(2, UnitName(unit)) or WoWTools_DataMixin.Player.Realm--服务器
    local isPlayer = UnitIsPlayer(unit)
    local isSelf= WoWTools_UnitMixin:UnitIsUnit('player', unit)--我
    local isGroupPlayer= (not isSelf and WoWTools_DataMixin.GroupGuid[guid]) and true or nil--队友
    local r, g, b, col = select(2, WoWTools_UnitMixin:GetColor(unit, nil))--颜色
    local isInCombat= PlayerIsInCombat()
    local englishFaction = isPlayer and UnitFactionGroup(unit)
    local textLeft, text2Left, textRight, text2Right='', '', '', ''
    local tooltipName=tooltip:GetName() or 'GameTooltip'

    local size= ':'..self.iconSize..':0'..self.iconSize

    guid= guid or UnitGUID(unit)

--图像
    tooltip.Portrait:SetAtlas(WoWTools_DataMixin.Icon[englishFaction] or 'Neutral')
    --tooltip.Portrait:SetShown(true)

--取得玩家信息
    local info= WoWTools_DataMixin.UnitItemLevel[guid]
    if info then
        if not isInCombat then
            WoWTools_UnitMixin:GetNotifyInspect(nil, unit)--取得装等
        end

        if info.itemLevel then--设置装等
            if info.itemLevel>1 then
                textLeft= info.itemLevel
            end
        end
        if info.specID then--设置天赋
            local icon, role= select(4, GetSpecializationInfoByID(info.specID))
            if icon then
                text2Left= '|T'..icon..':0|t'..(WoWTools_DataMixin.Icon[role] or '')
            end
        end
    else
        WoWTools_UnitMixin:GetNotifyInspect(nil, unit)--取得装等
    end

--设置，背景
    tooltip:Set_BG_Color(r,g,b, 0.2)


--设置 textLeft
    local isWarModeDesired= C_PvP.IsWarModeDesired()--争模式
    local statusIcon, statusText= WoWTools_UnitMixin:GetOnlineInfo(unit)--单位，状态信息
    if statusIcon and statusText then
        textLeft= textLeft..statusIcon..statusText

    elseif isGroupPlayer then--队友
        local reason=UnitPhaseReason(unit)
        if reason then
            if reason==0 then
                textLeft= (WoWTools_DataMixin.onlyChinese and '不同了阶段' or format(ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS, '', MAP_BAR_THUNDER_ISLE_TITLE0:gsub('1','')))..textLeft
            elseif reason==1 then
                textLeft= (WoWTools_DataMixin.onlyChinese and '不在同位面' or format(ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS,'', WoWTools_DataMixin.Player.layer))..textLeft
            elseif reason==2 then--战争模
                textLeft= (isWarModeDesired and (WoWTools_DataMixin.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF) or (WoWTools_DataMixin.onlyChinese and '开启战争模式' or ERR_PVP_WARMODE_TOGGLE_ON))..textLeft
            elseif reason==3 then
                textLeft= (WoWTools_DataMixin.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)..textLeft
            end
        end
    end
    if not IsInInstance() and UnitHasLFGRandomCooldown(unit) then
        text2Left= text2Left..'|T236347:0|t'
    end

--设置 textRight
    local region= WoWTools_RealmMixin:Get_Region(realm)--服务器，EU， US
    textRight=realm
        ..(isSelf
            and '|A:auctionhouse-icon-favorite:0:0|a'
            or (realm==WoWTools_DataMixin.Player.Realm and '|A:common-icon-checkmark:0:0|a')
            or (WoWTools_DataMixin.Player.Realms[realm] and '|A:Adventures-Checkmark:0:0|a')
            or ''
        )
        ..(region and region.col or '')

--设置 text2Right
    if isSelf then
--头衔
        local titleID= GetCurrentTitle()
        if titleID and titleID>0 then
            local titleName= GetTitleName(titleID)
            text2Right= WoWTools_TextMixin:CN(titleName, {titleID= titleID})
            if text2Right then
                text2Right= format(text2Right, '')
            end
        end
    else

        local lineLeft1=_G[tooltipName..'TextLeft1']--名称
        if lineLeft1 then
            local t= lineLeft1:GetText()
            if t and t:find('|A:') then
                text2Right= tooltip.text2Right:GetText() or ''
            else
                text2Right= lineLeft1:GetText():gsub(name, '')
                text2Right= text2Right:gsub('-'..realm, '')
            end
        end
    end

    tooltip.textLeft:SetText(textLeft)
    tooltip.text2Left:SetText(text2Left)
    tooltip.textRight:SetText(textRight)
    tooltip.text2Right:SetText(text2Right)

    tooltip.textLeft:SetTextColor(r, g, b)
    tooltip.text2Left:SetTextColor(r, g, b)
    tooltip.textRight:SetTextColor(r, g, b)
    tooltip.text2Right:SetTextColor(r, g, b)



    local lineLeft1=_G[tooltipName..'TextLeft1']--名称
    if lineLeft1 then
        lineLeft1:SetText(
            (isSelf and '|A:auctionhouse-icon-favorite:0:0|a' or WoWTools_UnitMixin:GetIsFriendIcon(nil, guid, nil) or '')
            ..'|A:common-icon-rotateright:0:0|a'..name..'|A:common-icon-rotateleft:0:0|a'
        )
        local lineRight1= _G[tooltipName..'TextRight1']
        if lineRight1 then
            local text= ' '
--魔兽世界时光徽章
            if isSelf then
                C_WowTokenPublic.UpdateMarketPrice()
                local price= C_WowTokenPublic.GetCurrentMarketPrice()
                if price and price>0 then
--取得WOW物品数量
                    local all, numPlayer= WoWTools_ItemMixin:GetWoWCount(122284)
                    text= all..(numPlayer>1 and '('..numPlayer..')' or '')..'|A:token-choice-wow:0:0|a'..WoWTools_DataMixin:MK(price/10000,3)..'|A:Front-Gold-Icon:0:0|a'
                end
            end
            lineRight1:SetText(text)
            lineRight1:SetShown(true)
        end
    end

--公会
    local isInGuild= IsPlayerInGuildFromGUID(guid)
    local lineLeft2= isInGuild and _G[tooltipName..'TextLeft2']
    if lineLeft2 then
        local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit)

        --local lineRight2= _G[tooltipName..'TextRight2']
        if guildName then
            guildName= WoWTools_TextMixin:sub(guildName, 24, 12)
            local rank=''
            if guildRankIndex then
                guildRankName= WoWTools_TextMixin:sub(guildRankName, 8, 4)
                rank= guildRankIndex==0 and '|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0|t'
                    or (guildRankIndex==1 and '|TInterface\\GroupFrame\\UI-Group-AssistantIcon:0|t')
                    or (' '..(guildRankName or guildRankIndex))
            end

            lineLeft2:SetText(
                '|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'
                ..guildName
                ..rank
            )
        else
            local text=lineLeft2:GetText()
            if text and text~='' and not text:find('|A:') then
                lineLeft2:SetText(
                    '|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'
                    ..(text:match('(.-)%-') or text)
                )
            end
        end
    end

    local lineLeft3= isInGuild and _G[tooltipName..'TextLeft3'] or _G[tooltipName..'TextLeft2']
    if lineLeft3 then
        local classFilename= select(2, UnitClass(unit))--职业名称
        local sex = UnitSex(unit)
        local raceName, raceFile= UnitRace(unit)
        local level= UnitLevel(unit)
        local text= sex==2
                    and '|A:charactercreate-gendericon-male-selected'..size..'|a'
                    or ('|A:charactercreate-gendericon-female-selected'..size..'|a')

        if GetMaxLevelForLatestExpansion()==level then
            text= text.. level
        else
            text= text..'|cnGREEN_FONT_COLOR:'..level..'|r'
        end

        local effectiveLevel= UnitEffectiveLevel(unit)
        if effectiveLevel and effectiveLevel>0 and effectiveLevel~=level then
            text= text..'(|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r) '
        end

        info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)--挑战, 分数
        if info and info.currentSeasonScore and info.currentSeasonScore>0 then
            text= text..' '..(WoWTools_UnitMixin:GetRaceIcon(unit, guid, raceFile, {sex=sex, size=self.iconSize}) or '')
                    ..' '..WoWTools_UnitMixin:GetClassIcon(nil, nil, classFilename, {size=self.iconSize})
                    ..' '..(UnitIsPVP(unit) and  '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and 'PvP' or PVP)..'|r' or (WoWTools_DataMixin.onlyChinese and 'PvE' or TRANSMOG_SET_PVE))
                    ..' |A:recipetoast-icon-star:0:0|a'..info.currentSeasonScore..'|r'

            if info.runs and info.runs then
                local bestRunLevel=0
                for _, run in pairs(info.runs) do
                    if run.bestRunLevel and run.bestRunLevel>bestRunLevel then
                        bestRunLevel=run.bestRunLevel
                    end
                end
                if bestRunLevel>0 then
                    text= text..' (|cnGREEN_FONT_COLOR:'..bestRunLevel..'|r)'
                end
            end
        else
            text= text..' '..(WoWTools_UnitMixin:GetRaceIcon(unit, guid, raceFile, {sex=sex, size=self.iconSize})  or '')
                    ..(WoWTools_TextMixin:CN(raceName) or WoWTools_TextMixin:CN(raceFile) or '')
                    ..' '..(WoWTools_UnitMixin:GetClassIcon(unit, guid, classFilename, {size=self.iconSize}) or '')
                    ..' '..(UnitIsPVP(unit) and '(|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and 'PvP' or TRANSMOG_SET_PVP)..'|r)' or ('('..(WoWTools_DataMixin.onlyChinese and 'PvE' or TRANSMOG_SET_PVE)..')'))
        end
        lineLeft3:SetText(text)

        --[[local lineRight3= isInGuild and _G[tooltipName..'TextRight3'] or _G[tooltipName..'TextRight2']
        if lineRight3 then
            lineRight3:SetText(' ')
            lineRight3:SetShown(true)
        end]]
    end

    local hideLine--取得网页，数据链接
    local num= isInGuild and 4 or 3
    for i=1, tooltip:NumLines() or 0, 1 do
        local lineLeft=_G[tooltipName..'TextLeft'..i]
        if lineLeft then
            local show=true
            if i==num then
                if isSelf then
--位面ID, 战争模式
                    lineLeft:SetText(
                        WoWTools_DataMixin.Player.Layer
                        and WoWTools_DataMixin.Language.layer..WoWTools_DataMixin.Icon.icon2..WoWTools_DataMixin.Player.Layer
                        or ' '
                    )
                    local lineRight= _G[tooltipName..'TextRight'..i]
                    if lineRight then
                        if isWarModeDesired then
                            lineRight:SetText('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE))
                        else
                            lineRight:SetText(WoWTools_DataMixin.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF)
                        end
                        lineLeft:SetShown(true)
                    end
                elseif isGroupPlayer then--队友位置
                    local mapID= C_Map.GetBestMapForUnit(unit)--地图ID
                    if mapID then
                        local mapInfo= C_Map.GetMapInfo(mapID)
                        if mapInfo and mapInfo.name then
                            lineLeft:SetText('|A:poi-islands-table:0:0|a'..mapInfo.name)
                            lineLeft:SetShown(true)
                        end
                    end
                else
                    if not hideLine  then
                        hideLine=lineLeft
                    else
                        show=false
                    end
                end
            elseif i>num then
                if not hideLine then
                    hideLine=lineLeft
                else
                    show=false
                end
            end
            if show then
                lineLeft:SetTextColor(r,g,b)
                local lineRight= _G[tooltipName..'TextRight'..i]
                if lineRight and lineRight:IsShown()then
                    lineRight:SetTextColor(r,g,b)
                end
            else
                lineLeft:SetText('""')
                lineLeft:SetShown(false)
                local lineRight= _G[tooltipName..'TextRight'..i]
                if lineRight then
                    lineRight:SetText('')
                    lineRight:SetShown(false)
                end
            end
        end
    end
    if isInCombat then
        if hideLine then
            hideLine:SetText('')
            hideLine:SetShown(false)
        end
    else
        self:Set_Web_Link(hideLine, {unitName=name, realm=realm, col=col})--取得单位, raider.io 网页，数据链接
    end

    if tooltip.StatusBar then
        tooltip.StatusBar:SetStatusBarColor(r,g,b)
    end

    self:Set_Item_Model(tooltip, {unit=unit, guid=guid})--设置, 3D模型

    self:Set_Width(tooltip)--设置，宽度

    WoWTools_TooltipMixin:CalculatePadding(tooltip)
    --if hideLine then
        --tooltip:Show()
    --end
end