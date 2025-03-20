--超链接，图标 ItemRef.lua
local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end

local LOOT_ITEM = LOCALE_zhCN and '(.-)获得了战利品' or WoWTools_TextMixin:Magic(LOOT_ITEM)
local CHAT_SAY_SEND= CHAT_SAY_SEND
local IsShowTimestamps--聊天中时间戳

DEFAULT_CHAT_FRAME.P_AddMessage= DEFAULT_CHAT_FRAME.AddMessage












local function cn_Link_Text(link, tabInfo)
    local name= link:match('|h%[|c........(.-)|r]|h') or link:match('|h%[(.-)]|h')
    if name then
        local new= e.cn(name, tabInfo)--汉化
        if new and name~=new then

            name= name:match('|c........(.-)|r') or name
            name= WoWTools_TextMixin:Magic(name)
            link= link:gsub(name, new)
        end
    end
    return link
end

local function SetChannels(link)
    local name=link:match('%[(.-)]')
    if name then
        if name:find(WORLD) then
            return link:gsub('%[.-]', '['..WoWTools_TextMixin:sub(e.cn(WORLD), 2, 6)..']')
        end

--关键词, 内容颜色，和频道名称替换
        if not Save().disabledKeyColor then
            for k, v in pairs(Save().channels) do--自定义
                if name:find(k) then
                    return link:gsub('%[.-]', v)
                end
            end
        end

        if name:find(GENERAL_LABEL) then--综合
            return link:gsub('%[.-]', '['..WoWTools_TextMixin:sub(e.cn(GENERAL_LABEL), 2, 6)..']')
        end

        name= name:match('%d+%. (.+)') or name:match('%d+．(.+)') or name--去数字
        name= name:match('%- (.+)') or name:match('：(.+)') or name:match(':(.+)') or name
        name=WoWTools_TextMixin:sub(e.cn(name), 2, 6)
        return link:gsub('%[.-]', '['..name..']')
    end
end

local function Set_Realm(link)--去服务器为*, 加队友种族图标,和N,T
    local split= LinkUtil.SplitLink(link)
    local name= split and split:match('player:(.-):') or link:match('|Hplayer:.-|h%[|cff......(.-)|r]') or link:match('|Hplayer:.-|h%[(.-)]|h')
    local server= name and name:match('%-(.+)')
    if name==e.Player.name_realm or name==e.Player.name then
        return '[|A:auctionhouse-icon-favorite:0:0|a'..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r]'
    else
        local text= WoWTools_UnitMixin:GetPlayerInfo(nil, nil, name)
        if server then
            if server== e.Player.realm then
                return (text or '')..link:gsub('%-'..server..'|r]|h', '|r]|h')
            else
                return (text or '')..link:gsub('%-'..server..'|r]|h', (e.Player.Realms[server] and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')..'*|r|r]|h')
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
            if numCollected == limit then
                return GREEN_FONT_COLOR_CODE..'['..numCollected ..'/'.. limit..']|r'
            elseif numCollected==0 then
                return RED_FONT_COLOR_CODE..'['..numCollected ..'/'.. limit..']|r'
            else
                return YELLOW_FONT_COLOR_CODE..'['..numCollected ..'/'.. limit..']|r'
            end
        end
    end
end

local function Mount(id2, item)
    if id2 then
        local mountID= item and C_MountJournal.GetMountFromItem(id2) or C_MountJournal.GetMountFromSpell(id2)
        if  mountID then
            local _, _, icon, _, _, _, _, _, _, _, isCollected =C_MountJournal.GetMountInfoByID(mountID)
            if isCollected then
                return format('|A:%s:0:0|a', e.Icon.select), icon
            else
                return '|A:questlegendary:0:0|a', icon
            end
        end
    end
end

local function PetType(petType)
    local type=PET_TYPE_SUFFIX[petType]
    if type then
        return '|TInterface\\Icons\\Icon_PetFamily_'..type..':0|t'
    end
end

local function Item(link)--物品超链接
    local itemID, _, _, _, icon, classID, subclassID= C_Item.GetItemInfoInstant(link)
    local t= cn_Link_Text(link, {itemID=itemID, isName=true})
    t= icon and '|T'..icon..':0|t'..t or t--加图标
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
                    if hasItemData and canCollect then
                        t=t..'|T132288:0|t'
                    else
                        t=t..'|A:transmog-icon-hidden:0:0|a'
                    end
                end
            end
        end
    elseif classID==15 and (subclassID==2 or subclassID==5) then
        if  subclassID==2 then--宠物数量
            local _, _, petType, _, _, _, _, _, _, _, _, _, speciesID=C_PetJournal.GetPetInfoByItemID(itemID)
            local nu=Pet(speciesID)
            if nu then
                t=(PetType(petType) or '')..t..nu
            end
        elseif subclassID==5 then--坐骑是不收集            
            local nu= Mount(itemID, true)
            if nu then
                t=t..nu
            end
        end
    elseif C_ToyBox.GetToyInfo(itemID) then--玩具
        t= PlayerHasToy(itemID) and (t..format('|A:%s:0:0|a', e.Icon.select)) or (t..'|A:questlegendary:0:0|a')
    end
    local bag= C_Item.GetItemCount(link, true, false, true)--数量
    if bag and bag>0 then
        t=t..'|A:bag-main:0:0|a'..WoWTools_Mixin:MK(bag, 3)
    end

    if t~=link then
        return t
    end
end

local function Spell(link)--法术图标
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
    local t=cn_Link_Text(link, {spellID=spellID, isName=true})
    local icon= C_Spell.GetSpellTexture(link)
    if icon then
        t= '|T'..icon..':0|t'..t
    end
    local nu=Mount(spellID)
    if nu then
        t=t..nu
    end
    if t~=link then
        return t
    end
end

local function PetLink(link)--宠物超链接
    local speciesID =link:match('Hbattlepet:(%d+)')
    if speciesID  then
        local nu=Pet(speciesID )
        if nu then
            local _, icon, petType= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
            return (PetType(petType) or '') .. (icon and '|T'..icon..':0|t' or '')..cn_Link_Text(link)..nu
        end
    end
end

local function PetAblil(link, petChannel)--宠物技能
    local id2=link:match('HbattlePetAbil:(%d+)')
    if id2 then
        local _, _, icon, _, _, _, petType=C_PetBattles.GetAbilityInfoByID(id2)
        if petType then
            if petChannel then
                return PetType(petType)..link
            elseif icon then
                return (PetType(petType) or '')..'|T'..icon..':0|t'..link
            end
        end
    end
end

local function Trade(link)--贸易技能
    local id2=link:match('Htrade:.-:(%d+):')
    if id2 then
        local icon = C_Spell.GetSpellTexture(id2)
        if icon then
            return '|T'..icon..':0|t'..cn_Link_Text(link)
        end
    end
end

local function Enchant(link)--附魔
    local id2=link:match('Henchant:(%d+)')
    if id2 then
        local icon = C_Spell.GetSpellTexture(id2)
        if icon then
            return '|T'..icon..':0|t'..cn_Link_Text(link)
        end
    end
end

local function Currency(link)--货币 "|cffffffff|Hcurrency:1744|h[Corrupted Memento]|h|r"
    local info, num, _, _, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(nil, nil, link)
    if info and info.iconFileID  then
        local numText
        if num then
            numText=(isMax and '|cnRED_FONT_COLOR:' or ((canWeek or canEarned or canQuantity) and '|cnGREEN_FONT_COLOR:' ) or '|cffffffff')
                ..WoWTools_Mixin:MK(num,3)..'|r'
                ..(WoWTools_CurrencyMixin:GetAccountIcon(info.currencyID) or '')
        end
        return  '|T'..info.iconFileID..':0|t'..cn_Link_Text(link)..(numText or '')
    end
end

local function Achievement(link)--成就
    local id2=link:match('Hachievement:(%d+)')
    if id2 then
        local _, _, _, completed, _, _, _, _, _, icon = GetAchievementInfo(id2)
        local texture=icon and '|T'..icon..':0|t' or ''
        return texture..cn_Link_Text(link)..(completed and format('|A:%s:0:0|a', e.Icon.select) or '|A:questlegendary:0:0|a')
    end
end

local function Quest(link)--任务
    local id2=link:match('Hquest:(%d+)')
    if id2 then
        local wow= C_QuestLog.IsAccountQuest(id2) and e.Icon.wow2 or ''--帐号通用        
        if C_QuestLog.IsQuestFlaggedCompleted(id2) then
            return wow..cn_Link_Text(link)..format('|A:%s:0:0|a', e.Icon.select)
        else
            return wow..cn_Link_Text(link)..'|A:questlegendary:0:0|a'
        end
    end
end

--[[local function Talent(link)--天赋
    local id2=link:match('Htalent:(%d+)')
    if id2 then
        local _, _, icon, _, _, _, _, _ ,_, known=GetTalentInfoByID(id2)
        if icon then
            return '|T'..icon..':0|t'..link..(known and format('|A:%s:0:0|a', e.Icon.select) or '|A:questlegendary:0:0|a')
        end
    end
end]]

local function Pvptal(link)--pvp天赋
    local id2=link:match('Hpvptal:(%d+)')
    if id2 then
        local _, _, icon, _, _, _, _, _ ,_, known=GetPvpTalentInfoByID(id2)
        return '|T'..icon..':0|t'..cn_Link_Text(link)..(known and format('|A:%s:0:0|a', e.Icon.select) or '|A:questlegendary:0:0|a')
    end
end


local function Outfit(link)--外观方案链接
    local list = C_TransmogCollection.GetItemTransmogInfoListFromOutfitHyperlink(link)
    if list then
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
                return cn_Link_Text(link)..format('|A:%s:0:0|a', e.Icon.select)
            elseif co>0 then
                return cn_Link_Text(link)..YELLOW_FONT_COLOR_CODE..co..'/'..to..'|r'
            else
                return cn_Link_Text(link)..RED_FONT_COLOR_CODE..co..'/'..to..'|r'
            end
        end
    end
end

local function Transmogillusion(link)--幻化
    local illusionID=link:match('Htransmogillusion:(%d+)')
    if illusionID then
        local info=C_TransmogCollection.GetIllusionInfo(illusionID)
        if info then
            local icon='|A:transmog-icon-hidden:0:0|a'
            if info.isCollected and info.isUsable then
                icon='|T132288:0|t'
            elseif info.isCollected then
                icon=format('|A:%s:0:0|a', e.Icon.select)
            end
            return cn_Link_Text(link)..icon
        end
    end
end

local function TransmogAppearance(link)--幻化
    local appearanceID=link:match('Htransmogillusion:(%d+)')
    if appearanceID then
        local has=C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(appearanceID)
        if has then
            return cn_Link_Text(link).format('|A:%s:0:0|a', e.Icon.select)
        else
            return cn_Link_Text(link)..'|A:questlegendary:0:0|a'
        end
    end
end

local function GetKeyAffix(affixs)--钥石
    local icon=''
    for _, v in pairs(affixs) do
        if v and v ~='0' then
            local icon2=select(3, C_ChallengeMode.GetAffixInfo(v))
            if icon2 then icon=icon..'|T'..icon2..':0|t' end
        end
    end
    return icon
end
local function Keystone(link)
    local item, _, affix1, affix2, affix3, affix4= link:match('Hkeystone:(%d+):(%d+):%d+:(%d+):(%d+):(%d+):(%d+)')
    if item then
        local  icon=C_Item.GetItemIconByID(item)
        if icon then
            local texture= '|T'..icon..':0|t'
            return texture..cn_Link_Text(link)..GetKeyAffix({affix1, affix2, affix3, affix4})
        end
    end
end

local function DungeonScore(link)--史诗钥石评分
    local score, guid, itemLv=link:match('|HdungeonScore:(%d+):(.-):.-:%d+:(%d+):')
    local t=WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil)..WoWTools_WeekMixin:KeystoneScorsoColor(score)
    t=t..cn_Link_Text(link)
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
                    return '|T'..info.abilityIcon..':0|t'..cn_Link_Text(link)
                end
           end
        elseif type==1 and journalName then
            local _, encounterID = EJ_HandleLinkPath(type, journalID)
            for index=1,9 do
                local _, name, _, _, iconImage = EJ_GetCreatureInfo(index, encounterID)
                if name and iconImage then
                    if name==journalName then
                        return '|T'..iconImage..':0|t'..cn_Link_Text(link)
                    end
                else
                    break
                end
            end
        elseif type==0 then--Instance
            local buttonImage2 = select(6, EJ_GetInstanceInfo(journalID))
            if buttonImage2 then
                return '|T'..buttonImage2..':0|t'..cn_Link_Text(link)
            end
        end
    end
end

local function Instancelock(link)
    local guid, InstanceID, DifficultyID=link:match('Hinstancelock:(.-):(%d+):(%d+):')
    local t=WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil)..cn_Link_Text(link)
    if DifficultyID and InstanceID then
        local name= WoWTools_MapMixin:GetDifficultyColor(nil, tonumber(DifficultyID)) or GetDifficultyInfo(DifficultyID)
        if name then--[[|Hjournal:0:320:5|h[Terrazza dell'Eterna Primavera]|h]]
            t=t..'|Hjournal:0:'..InstanceID..':'..DifficultyID..'|h['..name..']|h'
        end
    end
   return t
end

local function TransmogSet(link)--幻化套装
    local t= cn_Link_Text(link)
    local setID=link:match('transmogset:(%d+)')
    if setID then
        local info=C_TransmogSets.GetSetPrimaryAppearances(setID)
        if info then
            local n,to=0,0
            for _,v in pairs(info) do
                to=to+1
                if v.collected then
                    n=n+1
                end
            end
            if to>0 then
                if n==to then
                    t= t..format('|A:%s:0:0|a', e.Icon.select)
                elseif n==0 then
                    t= t..RED_FONT_COLOR_CODE..n..'/'..to..'|r'
                else
                    t= t..YELLOW_FONT_COLOR_CODE..n..'/'..to..'|r'
                end
            end
        end
    end
    if t~=link then
        return t
    end
end

local function setMount(link)--设置,坐骑
    local spellID= link:match('mount:(%d+)')
    if spellID then
        local mount,icon= Mount(spellID)
        if mount then
            return (icon and '|T'..icon..':0|t' or '')..cn_Link_Text(link)..mount
        end
    end
end

local function Waypoint(text)--地图标记xy, 格式 60.0 70.5
    local uiMapID= WorldMapFrame:IsShown() and WorldMapFrame.mapID or C_Map.GetBestMapForUnit("player")
    if uiMapID and C_Map.CanSetUserWaypointOnMap(uiMapID) then
        local x, y= text:match('(%d+%.%d). (%d+%.%d)')
        if x and y then
            return '|cffffff00|Hworldmap:'..uiMapID..':'..x:gsub('%.','')..'0:'..y:gsub('%.','')..'0|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a'..text..']|h|r'
        end
    end
end


--[[
Guild Finder (8.2.5) invite link.
clubFinder : clubFinderId
Example: "|cffffd100|HclubFinder:ClubFinder-1-19160-1598-53720920|h[Guild: Happy Leveling]|h|r"
See also: GetClubFinderLink()
|HclubFinder:ClubFinder-1-6991-3299-447003|h[公会: Test Guild]|h'

local function ClubFinder(text)--社区
    local clubFinderGUID= text:match('|HclubFinder:(.-)|h[')
    
    local clubInfo = clubFinderGUID and C_ClubFinder.GetRecruitingClubInfoFromFinderGUID(clubFinderGUID)
    print(text, clubInfo, clubFinderGUID)
    if clubInfo then
        info= clubFinderGUID
        for k, v in pairs(info or {}) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR') for k2,v2 in pairs(v) do print(k2,v2) end print('|cffff0000---',k, '---END') else print(k,v) end end print('|cffff00ff——————————')
    end
end
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
    --s=s:gsub('|Htalent:.-]|h', Talent)
    s=s:gsub('|Hpvptal:.-]|h', Pvptal)

    s=s:gsub('|Houtfit:.-]|h', Outfit)----外观方案链接    
    s=s:gsub('|Htransmogillusion:.-]|h', Transmogillusion)
    s=s:gsub('|Htransmogappearance:.-]|h', TransmogAppearance)
    s=s:gsub('|Htransmogset:.-]|h', TransmogSet)

    s=s:gsub('|Hkeystone:.-]|h', Keystone)
    s=s:gsub('|HdungeonScore:.-]|h', DungeonScore)
    s=s:gsub('|Hjournal:.-]|h', Journal)
    s=s:gsub('|Hinstancelock:.-]|h', Instancelock)

--社区 Example: "|cffffd100|HclubFinder:ClubFinder-1-19160-1598-53720920|h[Guild: Happy Leveling]|h|r"
   -- s=s:gsub('|HclubFinder:-]|h', ClubFinder)

    s=s:gsub('(%d+%.%d%d %d+%.%d%d)', Waypoint)--地图标记xy, 格式 60.00 70.50

    if not Save().notShowPlayerInfo then--不处理，玩家信息
        s=s:gsub('|Hplayer:.-]|h', Set_Realm)
        if not IsShowTimestamps then
            local unitName= s:match(LOOT_ITEM)--	%s获得了战利品：%s。
            if unitName then
                if unitName==e.Player.name or unitName==YOU then
                    s=s:gsub(unitName, '[|A:auctionhouse-icon-favorite:0:0|a'..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r]')
                else
                    s=s:gsub(WoWTools_TextMixin:Magic(unitName), WoWTools_UnitMixin:GetLink(unitName))
                end
            end
        end
    end

--关键词, 内容颜色，和频道名称替换
    if not Save().disabledKeyColor then
        for k, _ in pairs(Save().text) do--内容加颜色
            s=s:gsub(k, '|cnGREEN_FONT_COLOR:'..k..'|r')
        end
    end

    s= s:gsub(CHAT_SAY_SEND, '|A:transmog-icon-chat:0:0|a ')

    return self.P_AddMessage(self, s, ...)
end












local function Set_HyperLlinkIcon()
    for i = 3, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame"..i]
        if frame then
            if Save().linkIcon then
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
    end

    if Save().linkIcon then
        DEFAULT_CHAT_FRAME.AddMessage= New_AddMessage
        DEFAULT_CHAT_FRAME.editBox:SetAltArrowKeyMode(false)--alt +方向= 移动
    else
        DEFAULT_CHAT_FRAME.AddMessage= DEFAULT_CHAT_FRAME.P_AddMessage
    end

    LinkButton.texture:SetAtlas(
        Save().linkIcon and e.Icon.icon or e.Icon.disabled
    )
    --LinkButton.texture:SetDeaturation(C_Cvar.GetCVarBool(''))
end






local function Init()
--是否有，聊天中时间戳
    IsShowTimestamps= C_CVar.GetCVar('showTimestamps')~='none'
    EventRegistry:RegisterFrameEventAndCallback("CVAR_UPDATE", function(_, arg1, arg2, ...)
        if arg1=='showTimestamps' then
            IsShowTimestamps= arg2~='none'
        end
        if Save().linkIcon and Save().showCVarValue then
            print(e.Icon.icon2..WoWTools_HyperLink.addName, arg1, arg2, ...)
        end
        print(arg1,arg2)
    end)
    return true
end





--超链接，图标
function WoWTools_HyperLink:Init_Link_Icon()
    C_Timer.After(0.3, function()
        if Init() then
            Init=function()end
        end
    end)

    Set_HyperLlinkIcon()
end



--[[ChatFrame.lua
聊天选项
local hyperlink = string.format("|Haadcopenconfig|h[%s]", RESTRICT_CHAT_CONFIG_HYPERLINK);

]]
