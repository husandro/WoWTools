local e= select(2, ...)

--设置单位, 玩家
function WoWTools_TooltipMixin:Set_Unit_Player(tooltip, name, unit, guid)
    local realm= select(2, UnitName(unit)) or e.Player.realm--服务器
    local isPlayer = UnitIsPlayer(unit)
    local isSelf= UnitIsUnit('player', unit)--我
    local isGroupPlayer= (not isSelf and e.GroupGuid[guid]) and true or nil--队友
    local r, g, b, col = select(2, WoWTools_UnitMixin:Get_Unit_Color(unit, nil))--颜色
    local isInCombat= UnitAffectingCombat('player')
    local englishFaction = isPlayer and UnitFactionGroup(unit)
    local textLeft, text2Left, textRight, text2Right='', '', '', ''
    local tooltipName=tooltip:GetName() or 'GameTooltip'


    tooltip.Portrait:SetAtlas(e.Icon[englishFaction] or 'Neutral')
    tooltip.Portrait:SetShown(true)

    --取得玩家信息
    local info= e.UnitItemLevel[guid]
    if info then
        if not isInCombat then
            e.GetNotifyInspect(nil, unit)--取得装等
        end
        if info.itemLevel then--设置装等
            if info.itemLevel>1 then
                textLeft= info.itemLevel
            end
        end
        if info.specID then
            local icon, role= select(4, GetSpecializationInfoByID(info.specID))--设置天赋
            if icon then
                text2Left= "|T"..icon..':0|t'..(e.Icon[role] or '')
            end
        end
    else
        e.GetNotifyInspect(nil, unit)--取得装等
    end

    tooltip.backgroundColor:SetColorTexture(r, g, b, 0.2)--背景颜色
    tooltip.backgroundColor:SetShown(true)

    local isWarModeDesired= C_PvP.IsWarModeDesired()--争模式
    local statusIcon, statusText= WoWTools_UnitMixin:GetOnlineInfo(unit)--单位，状态信息
    if statusIcon and statusText then
        textLeft= textLeft..statusIcon..statusText

    elseif isGroupPlayer then--队友
        local reason=UnitPhaseReason(unit)
        if reason then
            if reason==0 then
                textLeft= (e.onlyChinese and '不同了阶段' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', MAP_BAR_THUNDER_ISLE_TITLE0:gsub('1','')))..textLeft
            elseif reason==1 then
                textLeft= (e.onlyChinese and '不在同位面' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', e.Player.layer))..textLeft
            elseif reason==2 then--战争模
                textLeft= (isWarModeDesired and (e.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF) or (e.onlyChinese and '开启战争模式' or ERR_PVP_WARMODE_TOGGLE_ON))..textLeft
            elseif reason==3 then
                textLeft= (e.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)..textLeft
            end
        end
    end
    if not IsInInstance() and UnitHasLFGRandomCooldown(unit) then
        text2Left= text2Left..'|T236347:0|t'
    end

    local region= e.Get_Region(realm)--服务器，EU， US
    textRight=realm..(isSelf and '|A:auctionhouse-icon-favorite:0:0|a' or realm==e.Player.realm and format('|A:%s:0:0|a', e.Icon.select) or e.Player.Realms[realm] and '|A:Adventures-Checkmark:0:0|a' or '')..(region and region.col or '')

    if isSelf then
        local titleID= GetCurrentTitle()
        if titleID and titleID>1 then
            local titleName= GetTitleName(titleID)
            text2Right= e.cn(titleName, {titleID= titleID})
            text2Right= text2Right and text2Right:gsub('%%s', '')
        end
    else
        local lineLeft1=_G[tooltipName..'TextLeft1']--名称
        if lineLeft1 then
            text2Right= lineLeft1:GetText():gsub(name, '')
            text2Right= text2Right:gsub('-'..realm, '')
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
            if isSelf then--魔兽世界时光徽章
                C_WowTokenPublic.UpdateMarketPrice()
                local price= C_WowTokenPublic.GetCurrentMarketPrice()
                if price and price>0 then
                    local all, numPlayer= e.GetItemWoWNum(122284)--取得WOW物品数量
                    text= all..(numPlayer>1 and '('..numPlayer..')' or '')..'|A:token-choice-wow:0:0|a'..WoWTools_Mixin:MK(price/10000,3)..'|A:Front-Gold-Icon:0:0|a'
                end
            end
            lineRight1:SetText(text)
            lineRight1:SetShown(true)
        end
    end


    local isInGuild= IsPlayerInGuildFromGUID(guid)
    local lineLeft2= isInGuild and _G[tooltipName..'TextLeft2']
    if lineLeft2 then
        local text=lineLeft2:GetText()
        if text then
            lineLeft2:SetText('|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'..text:gsub('(%-.+)',''))
            local lineRight2= _G[tooltipName..'TextRight2']
            if lineRight2 then
                lineRight2:SetText(' ')
            end
        end
    end

    local lineLeft3= isInGuild and _G[tooltipName..'TextLeft3'] or _G[tooltipName..'TextLeft2']
    if lineLeft3 then
        local classFilename= select(2, UnitClass(unit))--职业名称
        local sex = UnitSex(unit)
        local raceName, raceFile= UnitRace(unit)
        local level= UnitLevel(unit)
        local text= sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a'

        if GetMaxLevelForLatestExpansion()==level then
            text= text.. level
        else
            text= text..'|cnGREEN_FONT_COLOR:'..level..'|r'
        end

        local effectiveLevel= UnitEffectiveLevel(unit)
        if effectiveLevel~=level then
            text= text..'(|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r) '
        end

        info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)--挑战, 分数
        if info and info.currentSeasonScore and info.currentSeasonScore>0 then
            text= text..' '..(WoWTools_UnitMixin:GetRaceIcon({unit=unit, guid=guid, race=raceFile, sex=sex, reAtlas=false}) or '')
                    ..' '..WoWTools_UnitMixin:GetClassIcon(nil, classFilename)
                    ..' '..(UnitIsPVP(unit) and  '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and 'PvP' or PVP)..'|r' or (e.onlyChinese and 'PvE' or TRANSMOG_SET_PVE))
                    ..'  '..WoWTools_WeekMixin:KeystoneScorsoColor(info.currentSeasonScore,true)

            if info.runs and info.runs then
                local bestRunLevel=0
                for _, run in pairs(info.runs) do
                    if run.bestRunLevel and run.bestRunLevel>bestRunLevel then
                        bestRunLevel=run.bestRunLevel
                    end
                end
                if bestRunLevel>0 then
                    text= text..' ('..bestRunLevel..')'
                end
            end
        else
            text= text..' '..(WoWTools_UnitMixin:GetRaceIcon({unit=unit, guid=guid, race=raceFile, sex=sex, reAtlas=false})  or '')
                    ..(e.cn(raceName) or e.cn(raceFile) or '')
                    ..' '..(WoWTools_UnitMixin:GetClassIcon(nil, classFilename) or '')
                    ..' '..(UnitIsPVP(unit) and '(|cnGREEN_FONT_COLOR:'..(e.onlyChinese and 'PvP' or TRANSMOG_SET_PVP)..'|r)' or ('('..(e.onlyChinese and 'PvE' or TRANSMOG_SET_PVE)..')'))
        end
        lineLeft3:SetText(text)

        local lineRight3= isInGuild and _G[tooltipName..'TextRight3'] or _G[tooltipName..'TextRight2']
        if lineRight3 then
            lineRight3:SetText(' ')
        end
    end

    local hideLine--取得网页，数据链接
    local num= isInGuild and 4 or 3
    for i=1, tooltip:NumLines() or 0, 1 do
        local lineLeft=_G[tooltipName..'TextLeft'..i]
        if lineLeft then
            local show=true
            if i==num then
                if isSelf then--位面ID, 战争模式
                    lineLeft:SetText(e.Player.Layer and '|A:nameplates-holypower2-on:0:0|a'..e.Player.L.layer..' '..e.Player.Layer or ' ')
                    local lineRight= _G[tooltipName..'TextRight'..i]
                    if lineRight then
                        if isWarModeDesired then
                            lineRight:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE))
                        else
                            lineRight:SetText(e.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF)
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
                lineLeft:SetShown(false)
                local lineRight= _G[tooltipName..'TextRight'..i]
                if lineRight then
                    lineRight:SetShown(false)
                end
            end
        end
    end
    if isInCombat then
        if hideLine then
            hideLine:SetShown(false)
        end
    else
        self:Set_Web_Link(hideLine, {unitName=name, realm=realm, col=col})--取得单位, raider.io 网页，数据链接
    end

    self:Set_HealthBar_Unit(GameTooltipStatusBar, unit)--生命条提示
    self:Set_Item_Model(tooltip, {unit=unit, guid=guid})--设置, 3D模型

    self:Set_Width(tooltip)--设置，宽度
end