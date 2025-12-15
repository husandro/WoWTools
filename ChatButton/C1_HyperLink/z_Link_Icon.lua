--[[
    超链接，图标
    ItemRef.lua
    LinkUtil.lua
    {'%.', '%(','%)','%+', '%-', '%*', '%?', '%[', '%^'}
]]
local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end

local LOOT_ITEM = LOCALE_zhCN and '(.-)获得了战利品' or WoWTools_TextMixin:Magic(LOOT_ITEM)
local IsShowTimestamps--聊天中时间戳
local Size=':0:0'--图标大小
--DEFAULT_CHAT_FRAME.P_AddMessage= DEFAULT_CHAT_FRAME.AddMessage



local function Get_CompletedIcon(isCompleted)
    return isCompleted and '|A:common-icon-checkmark:0:0|a' or '|A:questlegendary:0:0|a'
end







local function SetChannels(link)
    local name=link:match('%[(.-)]')
    if not name then
        return
    elseif name:find(WORLD) then
        return link:gsub('%[.-]', '['..WoWTools_TextMixin:sub(WoWTools_TextMixin:CN(WORLD), 2, 6)..']')
    end

--关键词, 内容颜色，和频道名称替换
    if not Save().disabledKeyColor then
        for k, v in pairs(Save().channels or {}) do--自定义
            if name:find(k) then
                return link:gsub('%[.-]', v)
            end
        end
    end

    if name:find(GENERAL_LABEL) then--综合
        return link:gsub('%[.-]', '['..WoWTools_TextMixin:sub(WoWTools_TextMixin:CN(GENERAL_LABEL), 2, 6)..']')
    end

    name= name:match('%d+%. (.+)') or name:match('%d+．(.+)') or name--去数字
    name= name:match('%- (.+)') or name:match('：(.+)') or name:match(':(.+)') or name
    name=WoWTools_TextMixin:sub(WoWTools_TextMixin:CN(name), 2, 6)
    return link:gsub('%[.-]', '['..name..']')
end

local function Set_Realm(link)--去服务器为*, 加队友种族图标,和N,T
    local name
    local split= LinkUtil.SplitLink(link)
    if split then
        name= split:match('player:(.-):')
    end
    name= name or link:match('|Hplayer:.-|h%[|cff......(.-)|r]') or link:match('|Hplayer:.-|h%[(.-)]|h')

    if not name then
        return
    end

    local server= name:match('%-(.+)')
    if name==WoWTools_DataMixin.Player.Name_Realm or name==WoWTools_DataMixin.Player.Name then
        return '[|A:auctionhouse-icon-favorite:0:0|a'
            ..WoWTools_DataMixin.Player.col
            ..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
            ..'|r]'
    else
        local text= WoWTools_UnitMixin:GetPlayerInfo(nil, nil, name)
        if server then
            if server== WoWTools_DataMixin.Player.Realm then
                return (text or '')..link:gsub('%-'..server..'|r]|h', '|r]|h')
            else
                return (text or '')..link:gsub('%-'..server..'|r]|h', (WoWTools_DataMixin.Player.Realms[server] and '|cnGREEN_FONT_COLOR:' or '|cnWARNING_FONT_COLOR:')..'*|r|r]|h')
            end
        elseif text then
            return text..link
        end
    end
end

local function Pet(speciesID)
    if speciesID then
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        if numCollected and limit then
            return (
                    numCollected == limit and GREEN_FONT_COLOR_CODE
                    or (numCollected==0 and WARNING_FONT_COLOR_CODE)
                    or YELLOW_FONT_COLOR_CODE
                )
                ..'['..numCollected ..'/'.. limit..']|r'
        end
    end
end
--坐骑
local function Mount(itemID, spellID)
    local mountID= (
        itemID and C_MountJournal.GetMountFromItem(itemID)
        or spellID and C_MountJournal.GetMountFromSpell(spellID)
    )
    if mountID then
        local _, _, icon, _, _, _, _, _, _, _, isCollected =C_MountJournal.GetMountInfoByID(mountID)
        return Get_CompletedIcon(isCollected), icon
    end
end







--宠物类型
local function PetType(petType)
    local type=PET_TYPE_SUFFIX[petType]
    if type then
        return '|TInterface\\Icons\\Icon_PetFamily_'..type..Size..'|t'
    end
end







--物品，超链接
local function Item(link)
    local itemID, _, _, _, icon, classID, subclassID= C_Item.GetItemInfoInstant(link)

    if not itemID then
        return
    end

    local t= WoWTools_HyperLink:CN_Link(link, {itemID=itemID, isName=true})
    t= icon and '|T'..icon..Size..'|t'..t or t--加图标
    if classID==2 or classID==4 then
        local lv=C_Item.GetDetailedItemLevelInfo(link)--装等
        if lv and lv>10 then
            t=t..'['..lv..']'
        end
        local sourceID=select(2,C_TransmogCollection.GetItemInfo(link))--幻化
        if sourceID then
            local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
            if sourceInfo then
                if not sourceInfo.isCollected then
                    local hasItemData, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID)--玩家是否可收集
                    t=t..(
                        hasItemData and canCollect and
                        '|T132288:0|t'
                        or '|A:transmog-icon-hidden:0:0|a'
                    )
                end
            end
        end
    elseif classID==15 and (subclassID==2 or subclassID==5) then
        if  subclassID==2 then--宠物数量
            local _, _, petType, _, _, _, _, _, _, _, _, _, speciesID=C_PetJournal.GetPetInfoByItemID(itemID)
            t=(PetType(petType) or '')
                ..t
                ..(Pet(speciesID) or '')

        elseif subclassID==5 then--坐骑是不收集            
            t= t..(Mount(itemID, nil) or '')
        end

    elseif C_ToyBox.GetToyInfo(itemID) then--玩具
        t= t..Get_CompletedIcon(PlayerHasToy(itemID))
    end

--物品数量
    if not Save().notShowItemCount then
        t=t..WoWTools_ItemMixin:GetCount(itemID, {isWoW=true})
    end

    if t~=link then
        return t
    end
end









--法术图标
local function Spell(link)
    local spellID
    spellID= (C_Spell.GetSpellInfo(link) or {}).spellID

    if not spellID then
        spellID= link:match('Hspell:(%d+)')
        if spellID  then
            spellID= spellID and tonumber(spellID)
        end
    end

    if not spellID then
        return
    end

    local t= WoWTools_HyperLink:CN_Link(link, {spellID=spellID, isName=true})

    local icon= C_Spell.GetSpellTexture(link)
    t= (icon and '|T'..icon..Size..'|t' or '')..t

    t=t..(Mount(nil, spellID) or '')

    if t~=link then
        return t
    end
end

local function PetLink(link)--宠物超链接
    local speciesID =link:match('Hbattlepet:(%d+)')
    if not speciesID  then
        return
    end
    local _, icon, petType= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    return (PetType(petType) or '')
        ..(icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
        ..(Pet(speciesID) or '')
end


--battlePetAbil : abilityID : maxHealth : power : speed
--|HbattlePetAbil:493:1465:264:301|h[Zoccolata]|h
local function PetAblil(link, petChannel)--宠物技能
    local abilityID=link:match('HbattlePetAbil:(%d+)')
    if not abilityID then
        return
    end
    local abilityID2, _, icon, _, _, _, petType=C_PetBattles.GetAbilityInfoByID(abilityID)
    local cnName= WoWTools_TextMixin:CN(nil, {petAbilityID=abilityID2, isName=true})
    if cnName then
        link= link:gsub('%[.-]', '['..cnName..']')
    end
    if petType then
        if petChannel then
            return PetType(petType)..link
        else
            return (PetType(petType) or '')..'|T'..(icon or 0)..Size..'|t'..link
        end
    elseif cnName then
        return link
    end
end

local function Trade(link)--贸易技能
    local id2=link:match('Htrade:.-:(%d+):')
    if not id2 then
        return
    end

    local icon = C_Spell.GetSpellTexture(id2)

    return (icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
end

local function Enchant(link)--附魔
    local id2=link:match('Henchant:(%d+)')
    if not id2 then
        return
    end
    local icon = C_Spell.GetSpellTexture(id2)
    return (icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
end

local function Currency(link)--货币 "|cffffffff|Hcurrency:1744|h[Corrupted Memento]|h|r"
    local info, num, _, _, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(nil, nil, link)
    if not info or not info.iconFileID then
        return
    end
    return
        '|T'..info.iconFileID..Size..'|t'
        ..WoWTools_HyperLink:CN_Link(link)
        ..(isMax and '|cnWARNING_FONT_COLOR:' or ((canWeek or canEarned or canQuantity) and '|cnGREEN_FONT_COLOR:' ) or '|cffffffff')
        ..(num and WoWTools_DataMixin:MK(num,3))
        ..'|r'
        ..(WoWTools_CurrencyMixin:GetAccountIcon(info.currencyID) or '')
end

local function Achievement(link)--成就
    local id2=link:match('Hachievement:(%d+)')
    if not id2 then
        return
    end
    local _, _, _, completed, _, _, _, _, _, icon = GetAchievementInfo(id2)
    return (icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
        ..Get_CompletedIcon(completed)
end

local function Quest(link)--任务
    local id2=link:match('Hquest:(%d+)')
    if not id2 then
        return
    end
    return (C_QuestLog.IsAccountQuest(id2) and WoWTools_DataMixin.Icon.wow2 or '')--帐号通用
        ..WoWTools_HyperLink:CN_Link(link)
        ..Get_CompletedIcon(C_QuestLog.IsQuestFlaggedCompleted(id2))
end

local function Talent(link)--天赋
    local id2=link:match('Htalent:(%d+)')
    if not id2 then
        return
    end
    local _, _, icon, _, _, _, _, _ ,_, known= GetTalentInfoByID(id2)
    return (icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
        ..Get_CompletedIcon(known)
end

local function Pvptal(link)--pvp天赋
    local id2=link:match('Hpvptal:(%d+)')
    if not id2 then
        return
    end
    local _, _, icon, _, _, _, _, _ ,_, known=GetPvpTalentInfoByID(id2)
    return (icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
        ..Get_CompletedIcon(known)
end


--外观方案链接
local function Outfit(link)
    local list = C_TransmogCollection.GetItemTransmogInfoListFromOutfitHyperlink(link)
    if not list then
        return
    end
    local co,to=0,0
    for _,v in pairs(list) do
        local appearanceID=v.appearanceID--v.illusionID
        local illusionID=v.illusionID
        if appearanceID and appearanceID>0 then
            local hide=C_TransmogCollection.IsAppearanceHiddenVisual(appearanceID)
            if not hide then
                local has=C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(appearanceID)
                if has then
                    co=co+1
                end
                to=to+1
            end
        end
        if illusionID and illusionID>0 then
            local info = C_TransmogCollection.GetIllusionInfo(illusionID)
            if info then
                if info.isCollected then
                    co=co+1
                end
                to=to+1
            end
        end
    end
    if to>0 then
        if to==co then
            return WoWTools_HyperLink:CN_Link(link)
                ..Get_CompletedIcon(true)
        else
            return WoWTools_HyperLink:CN_Link(link)
                ..(co>0 and YELLOW_FONT_COLOR_CODE or WARNING_FONT_COLOR_CODE)
                ..co..'/'..to..'|r'
        end
    end
end

--幻化
local function Transmogillusion(link)
    local illusionID=link:match('Htransmogillusion:(%d+)')
    local info= illusionID and C_TransmogCollection.GetIllusionInfo(illusionID)
    if not info then
        return
    end
    return WoWTools_HyperLink:CN_Link(link)
        ..(
            info.isCollected and info.isUsable and '|T132288:0|t'
            or Get_CompletedIcon(info.isCollected)
        )
end

--幻化
local function TransmogAppearance(link)
    local appearanceID=link:match('Htransmogappearance:(%d+)')
    if appearanceID then
        return WoWTools_HyperLink:CN_Link(link)
            ..Get_CompletedIcon(C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(appearanceID))
    end
end


--钥石
local function Keystone(link)
    local itemID, _, _, affix1, affix2, affix3, affix4= link:match('Hkeystone:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)')
    return
        '|T'..(select(5, C_Item.GetItemInfoInstant(link)) or 525134)..Size..'|t'
        ..WoWTools_HyperLink:CN_Link(link, {itemID=tonumber(itemID), isName=true})
        ..(WoWTools_HyperLink:GetKeyAffix(link, {affix1, affix2, affix3, affix4}) or '')
end


--史诗钥石评分
local function DungeonScore(link)
    local score, guid, itemLv=link:match('|HdungeonScore:(%d+):(.-):.-:%d+:(%d+):')
    local t=WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil)
        ..(score=='0' and '0' or WoWTools_ChallengeMixin:KeystoneScorsoColor(score))
    t=t..WoWTools_HyperLink:CN_Link(link)
    if itemLv and itemLv~='0' then
        t=t..'|A:charactercreate-icon-customize-body-selected:0:0|a'..itemLv
    end
    return t
end

local function Journal(link)--冒险指南 |Hjournal:0:1031:14|h[Uldir]|h 0=Instance, 1=Encounter, 2=Section
    local journalType, journalID, journalName=link:match('Hjournal:(%d+):(%d+):.-%[(.-)]')
    local type= journalID and journalType and tonumber(journalType)
    if  type then
        if type==2 then
           local sectionID = select(3, EJ_HandleLinkPath(type, journalID))
           if sectionID then
                local info = C_EncounterJournal.GetSectionInfo(sectionID)
                if info and info.abilityIcon then
                    return '|T'..info.abilityIcon..Size..'|t'..WoWTools_HyperLink:CN_Link(link)
                end
           end
        elseif type==1 and journalName then
            local _, encounterID = EJ_HandleLinkPath(type, journalID)
            for index=1,9 do
                local _, name, _, _, iconImage = EJ_GetCreatureInfo(index, encounterID)
                if name and iconImage then
                    if name==journalName then
                        return '|T'..iconImage..Size..'|t'..WoWTools_HyperLink:CN_Link(link)
                    end
                else
                    break
                end
            end
        elseif type==0 then--Instance
            local buttonImage2 = select(6, EJ_GetInstanceInfo(journalID))
            if buttonImage2 then
                return '|T'..buttonImage2..Size..'|t'..WoWTools_HyperLink:CN_Link(link)
            end
        end
    end
end

local function Instancelock(link)
    local guid, InstanceID, DifficultyID=link:match('Hinstancelock:(.-):(%d+):(%d+):')
    local t=WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil)..WoWTools_HyperLink:CN_Link(link)
    if DifficultyID and InstanceID then
        local name= WoWTools_MapMixin:GetDifficultyColor(nil, tonumber(DifficultyID)) or GetDifficultyInfo(DifficultyID)
        if name then--[[|Hjournal:0:320:5|h[Terrazza dell'Eterna Primavera]|h]]
            return t..'|Hjournal:0:'..InstanceID..':'..DifficultyID..'|h['..name..']|h'
        end
    end
end

--旅行者日志
--"|cffffff00|Hperksactivity:6|h[Completa 5 spedizioni Mitiche+]|h|r"
local function Perksactivity(link)
    local perksActivityID, name
    perksActivityID, name= link:match('|Hperksactivity:(%d+)|h%[(.+)]|h')
    perksActivityID= perksActivityID and tonumber(perksActivityID)
    if not perksActivityID or not name then
        return
    end

    local t=link
--汉化
    local info= WoWTools_ChineseMixin and WoWTools_ChineseMixin:GetPerksActivityInfo(tonumber(perksActivityID))
    if info and info[1] then
        t= t:gsub(name, info[1])
    end

--是否完成
    info= C_PerksActivities.GetPerksActivityInfo(perksActivityID)
    if info then
        t= t..Get_CompletedIcon(info.completed)
    end

    if t and t~=link then
        return t
    end
end

local function TransmogSet(link)--幻化套装
    local t= WoWTools_HyperLink:CN_Link(link)
    local setID=link:match('transmogset:(%d+)')
    local info= setID and C_TransmogSets.GetSetPrimaryAppearances(setID)
    if not info then
        return
    end
    local n,to=0,0
    for _,v in pairs(info) do
        to=to+1
        if v.collected then
            n=n+1
        end
    end
    if to>0 then
        if n==to then
            t= t..Get_CompletedIcon(true)
        else
            t= t..(n==0 and WARNING_FONT_COLOR_CODE or YELLOW_FONT_COLOR_CODE)..n..'/'..to..'|r'
        end
    end
    if t~=link then
        return t
    end
end

local function setMount(link)--设置,坐骑
    local spellID= link:match('mount:(%d+)')
    local mount, icon= Mount(nil, spellID)
    if mount then
        return (icon and '|T'..icon..Size..'|t' or '')..WoWTools_HyperLink:CN_Link(link)..mount
    end
end

--地图标记xy, 格式 60.10 70.50
--|cffffff00|Hworldmap:84:7222:2550|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a Map Pin Location]|h|r
local function Waypoint(text)
    local uiMapID= WoWTools_WorldMapMixin:GetMapID()
    if uiMapID and C_Map.CanSetUserWaypointOnMap(uiMapID) then
        local x, y= text:match('(%d+%.%d%d) (%d+%.%d%d)')
        if x and y then
            return '|Hworldmap:'..uiMapID..':'..x:gsub('%.','')..':'..y:gsub('%.','')..'|h['..text..']|h'
        end
    end
end
--return '|cffffff00|Hworldmap:'..uiMapID..':'..x:gsub('%.','')..'0:'..y:gsub('%.','')..'0|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a'..text..']|h|r'




--社区查找器 |HclubFinder:ClubFinder-1-6991-3299-447003|h[Gilda: Test Guild]|h
local function ClubFinder(link)
    local clubFinderGUID= link:match('|HclubFinder:(.-)|h%[')
    local clubInfo = clubFinderGUID and C_ClubFinder.GetRecruitingClubInfoFromFinderGUID(clubFinderGUID)
    if clubInfo then
        return
            (clubInfo.isGuild and '|A:hud-microbutton-Guild-Banner:0:0|a' or '')
            ..(clubInfo.isCrossFaction and '|A:CrossedFlags:0:0|a' or '')
            ..link
    end
end
--[[
local function Housing(link)
    print(link)
end


社区 |HclubTicket:WMo42zSmYP|h[Unisciti a: asdfasd]|h
CommunitiesHyperlink.lua CommunitiesHyperlink_OnEvent
]]
local function New_AddMessage(self, s, ...)
    local petChannel=s:find('|Hchannel:.-'..PET_BATTLE_COMBAT_LOG..']|h') and true or false

    s=s:gsub('|Hchannel:.-]|h', SetChannels)

    s=s:gsub('|Hitem:.-]|h',Item)
    s=s:gsub('|Hspell:.-]|h',Spell)
    s=s:gsub('|Hmount:.-]|h',setMount)

    s=s:gsub('|Hbattlepet:.-]|h',PetLink)
    s=s:gsub('|HbattlePetAbil:.-]|h',function(link) return PetAblil(link, petChannel) end)

    s=s:gsub('|Htrade:.-]|h', Trade)
    s=s:gsub('|Henchant:.-]|h', Enchant)
    s=s:gsub('|Hcurrency:.-]|h', Currency)
    s=s:gsub('|Hachievement:.-]|h', Achievement)
    s=s:gsub('|Hquest:.-]|h', Quest)
    s=s:gsub('|Htalent:.-]|h', Talent)
    s=s:gsub('|Hpvptal:.-]|h', Pvptal)

    s=s:gsub('|Houtfit:.-]|h', Outfit)----外观方案链接    
    s=s:gsub('|Htransmogillusion:.-]|h', Transmogillusion)
    s=s:gsub('|Htransmogappearance:.-]|h', TransmogAppearance)
    s=s:gsub('|Htransmogset:.-]|h', TransmogSet)

    s=s:gsub('|Hkeystone:.-]|h', Keystone)
    s=s:gsub('|HdungeonScore:.-]|h', DungeonScore)
    s=s:gsub('|Hjournal:.-]|h', Journal)
    s=s:gsub('|Hinstancelock:.-]|h', Instancelock)

    s=s:gsub('|Hperksactivity:.-]|h', Perksactivity)
    --s=s:gsub('|Hhousing:.-]|h', Housing)

    s=s:gsub('|HclubFinder:.-]|h', ClubFinder)
    --s=s:gsub('|HclubTicket:.-]|h', ClubTicket)

    if not Save().notShowMapPin then
        s=s:gsub('(%d+%.%d%d %d+%.%d%d)', Waypoint)--地图标记xy, 格式 60.00 70.50
    end


    if not Save().notShowPlayerInfo then--不处理，玩家信息
        s=s:gsub('|Hplayer:.-]|h', Set_Realm)
        if not IsShowTimestamps then
            local unitName= s:match(LOOT_ITEM)--	%s获得了战利品：%s。
            if unitName then
                if unitName==WoWTools_DataMixin.Player.Name or unitName==YOU then
                    s=s:gsub(unitName, '[|A:auctionhouse-icon-favorite:0:0|a'..WoWTools_DataMixin.Player.col..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r]')
                else
                    s=s:gsub(WoWTools_TextMixin:Magic(unitName), WoWTools_UnitMixin:GetLink(nil, nil, unitName, false))
                end
            end
        end
    end

--关键词, 内容颜色，和频道名称替换
    if not Save().disabledKeyColor then
        for k in pairs(WoWToolsPlayerDate['HyperLinkColorText']) do--内容加颜色
            s=s:gsub(k, '|cnGREEN_FONT_COLOR:'..k..'|r')
        end
    end

    s= s:gsub(CHAT_SAY_SEND, '|A:transmog-icon-chat:0:0|a ')

    return self.P_AddMessage(self, s, ...)
end








local function Set_AddMessage(frame, enable)
    if not frame then
        return
    end

    if enable then
        if not frame.P_AddMessage then
            frame.P_AddMessage= frame.AddMessage
        end
        frame.AddMessage= New_AddMessage
    else
        if frame.P_AddMessage then
            frame.AddMessage= frame.P_AddMessage
        end
    end
end



local function Set_HyperLlinkIcon(btn)
    local enable= Save().linkIcon and not C_SocialRestrictions.IsChatDisabled()

    for i = 3, NUM_CHAT_WINDOWS do
        Set_AddMessage(_G["ChatFrame"..i], enable)
    end

    Set_AddMessage(DEFAULT_CHAT_FRAME, enable)

    local btn= WoWTools_ChatMixin:GetButtonForName('HyperLink')
    if btn then
        btn.texture:SetAtlas(enable and 'orderhalltalents-done-glow' or 'voicechat-icon-STT-on')
        btn.texture:SetDesaturated(not enable)
    end
end


















local function Init()
--是否有，聊天中时间戳
    IsShowTimestamps= C_CVar.GetCVar('showTimestamps')~='none'

    EventRegistry:RegisterFrameEventAndCallback("CVAR_UPDATE", function(_, arg1, arg2, ...)
        if arg1=='showTimestamps' then
            IsShowTimestamps= arg2~='none'
        end
        if Save().showCVarName then
            print(
                WoWTools_DataMixin.Icon.icon2
                ..'|A:voicechat-icon-STT-on:0:0|a|cffff00ffCVar|r|cff00ff00',
                arg1,
                '|r',
                arg2,
                ...
            )
        end
    end)

--CVar 名称
    WoWTools_DataMixin:Hook('ChatConfigFrame_OnChatDisabledChanged', function()
        Set_HyperLlinkIcon()
    end)

    Set_HyperLlinkIcon()

    Init=function()
        Set_HyperLlinkIcon()
    end
end





--超链接，图标
function WoWTools_HyperLink:Init_Link_Icon()
    self:Link_Icon_Settings()
    Init()
end

function WoWTools_HyperLink:Link_Icon_Settings()
    local s= Save().iconSize or 0
    s = s<8  and 0 or s
    Size= ':'..s..':'..s
end

--[[ChatFrame.lua
聊天选项
local hyperlink = string.format("|Haadcopenconfig|h[%s]", RESTRICT_CHAT_CONFIG_HYPERLINK);

]]
