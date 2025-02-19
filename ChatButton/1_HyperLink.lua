local id, e = ...
local addName
local Save={
    --disabed=true, --使用，禁用
    --notShowPlayerInfo=true,--不处理，玩家信息

    channels={--频道名称替换 
        --['世界'] = '[世]',
    },
    text={--内容颜色,
        [ACHIEVEMENTS]=true,
    },
    disabledKeyColor= not e.Player.husandro,--禁用，内容颜色，和频道名称替换

    groupWelcome= e.Player.husandro,--欢迎
    groupWelcomeText= e.Player.cn and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}',

    guildWelcome= e.Player.husandro,
    guildWelcomeText= e.Player.cn and '宝贝，欢迎你加入' or EMOTE103_CMD1:gsub('/',''),

    welcomeOnlyHomeGroup=true,--仅限, 手动组队

    setPlayerSound= e.Player.husandro,--播放, 声音
    Cvar={}
    --disabledNPCTalking=true,--禁用，隐藏NPC发言    
    --disabledTalkingPringText=true,--禁用，隐藏NPC发言，文本

    --not_Add_Reload_Button=true,--添加 RELOAD 按钮
}

local LinkButton, Category
local LOOT_ITEM= LOOT_ITEM--= WoWTools_TextMixin:Magic(LOOT_ITEM)--:gsub('%%s', '(.+)')--%s获得了战利品：%s。
local CHAT_SAY_SEND= CHAT_SAY_SEND

DEFAULT_CHAT_FRAME.ADD= DEFAULT_CHAT_FRAME.AddMessage














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

        if not Save.disabledKeyColor then
            for k, v in pairs(Save.channels) do--自定义
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
        if  subclassID==2 then----宠物数量
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














local IsShowTimestamps--聊天中时间戳
local function setAddMessageFunc(self, s, ...)
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

    s=s:gsub('(%d+%.%d%d %d+%.%d%d)', Waypoint)--地图标记xy, 格式 60.00 70.50

    if not Save.notShowPlayerInfo then--不处理，玩家信息
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

    if not Save.disabledKeyColor then
        for k, _ in pairs(Save.text) do--内容加颜色
            s=s:gsub(k, '|cnGREEN_FONT_COLOR:'..k..'|r')
        end
    end

    s= s:gsub(CHAT_SAY_SEND, '|A:transmog-icon-chat:0:0|a ')

    return self.ADD(self, s, ...)
end



























--#########
--使用，禁用
--#########
local function Set_HyperLlinkIcon()
    for i = 3, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame"..i]
        if frame then
            if Save.disabed then
                if frame.ADD then
                    frame.AddMessage=frame.ADD
                end
            else
                if not frame.ADD then
                    frame.ADD=frame.AddMessage
                end
                frame.AddMessage=setAddMessageFunc
            end
        end
    end
    if Save.disabed then
        DEFAULT_CHAT_FRAME.AddMessage=DEFAULT_CHAT_FRAME.ADD
    else
        DEFAULT_CHAT_FRAME.AddMessage=setAddMessageFunc
        DEFAULT_CHAT_FRAME.editBox:SetAltArrowKeyMode(false)--alt +方向= 移动
    end

    LinkButton.texture:SetAtlas(not Save.disabed and e.Icon.icon or e.Icon.disabled)
end




























--###########
--设置控制面板
--###########
--local Category, Layout
local function Init_Panel()
    local frame= CreateFrame('Frame')
    Category= e.AddPanel_Sub_Category({name=addName, frame=frame, category=WoWTools_ChatButtonMixin.Category})

    local function Cedit(self)
        local frame= CreateFrame('Frame',nil, self, 'ScrollingEditBoxTemplate')--ScrollTemplates.lua
        frame:SetPoint('CENTER')
        frame:SetSize(500,250)
        frame.texture= frame:CreateTexture(nil, "BACKGROUND")
        frame.texture:SetAllPoints()
        frame.texture:SetAtlas('CreditsScreen-Background-0')
        frame.texture:SetAlpha(0.3)

        return frame
    end

    local str=WoWTools_LabelMixin:Create(frame)--内容加颜色
    str:SetPoint('TOPLEFT')
    str:SetText(e.onlyChinese and '颜色: 关键词 (|cnGREEN_FONT_COLOR:空格|r) 分开' or (COLOR..': '..KBASE_DEFAULT_SEARCH_TEXT..'|cnGREEN_FONT_COLOR:( '..KEY_SPACE..' )|r'))
    local editBox=Cedit(frame)
    editBox:SetPoint('TOPLEFT', str, 'BOTTOMLEFT',0,-5)

    if Save.text then
        local s=''
        for k, _ in pairs(Save.text) do
            if s~='' then s=s..' ' end
            s=s..k
        end
        editBox:SetText(s)
    end
    local btn=CreateFrame('Button', nil, editBox, 'UIPanelButtonTemplate')
    btn:SetSize(80,28)
    btn:SetText(e.onlyChinese and '更新' or UPDATE)
    btn:SetPoint('BOTTOMRIGHT')
    btn:SetScript('OnMouseDown', function(self)
        Save.text={}
        local n=0
        local s=self:GetParent():GetInputText() or ''
        if s:gsub(' ','')~='' then
            s=s..' '
            s=s:gsub('|n', ' ')
            s=s:gsub('.- ', function(t)
                t=t:gsub(' ','')
                if t and t~='' then
                    t=WoWTools_TextMixin:Magic(t)
                    Save.text[t]=true
                    n=n+1
                    print(n..')'..(e.onlyChinese and '颜色' or COLOR), t)
                end
            end)
        end
        print(WoWTools_Mixin.addName, addName, e.onlyChinese and '颜色' or COLOR, '|cnGREEN_FONT_COLOR:#'..n..(e.onlyChinese and '完成' or COMPLETE)..'|r', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local str2=WoWTools_LabelMixin:Create(frame)--频道名称替换
    str2:SetPoint('TOPLEFT', editBox, 'BOTTOMLEFT', 0,-20)
    str2:SetText(e.onlyChinese and '频道名称替换: 关键词|cnGREEN_FONT_COLOR:=|r替换' or (CHANNEL_CHANNEL_NAME..': '..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL..'  |cnGREEN_FONT_COLOR:= |r'))
    local editBox2=Cedit(frame)
    editBox2:SetPoint('TOPLEFT', str2, 'BOTTOMLEFT',0,-5)
    if Save.channels then
        local t3=''
        for k, v in pairs(Save.channels) do
            if t3~='' then t3=t3..'|n' end
            t3=t3..k..'='..v
        end
       editBox2:SetText(t3)
    end
    local btn2=CreateFrame('Button', nil, editBox2, 'UIPanelButtonTemplate')
    btn2:SetSize(80,28)
    btn2:SetText(e.onlyChinese and '更新' or UPDATE)
    btn2:SetPoint('BOTTOMRIGHT')
    btn2:SetScript('OnMouseDown', function(self)
        Save.channels={}
        local n=0
        local s=self:GetParent():GetInputText() or ''
        if s:gsub(' ','')~='' then
            s=s..' '
            s=s:gsub('|n', ' ')
            s=s:gsub('.-=.- ', function(t)
                local name,name2=t:match('(.-)=(.-) ')
                if name and name2 and name~='' and name2~='' then
                    name=WoWTools_TextMixin:Magic(name)
                    Save.channels[name]=name2
                    n=n+1
                    print(n..')'..(e.onlyChinese and '频道' or CHANNELS)..': ',name, e.onlyChinese and '替换' or REPLACE, name2)
                end
            end)
        end
        print(WoWTools_Mixin.addName, addName, e.onlyChinese and '频道名称替换' or (CHANNEL_CHANNEL_NAME..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL), '|cnGREEN_FONT_COLOR:#'..n..(e.onlyChinese and '完成' or COMPLETE)..'|r',  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
end



















--#############
--欢迎加入, 信息
--#############
local raidMS=ERR_RAID_MEMBER_ADDED_S:gsub("%%s", "(.+)")--%s加入了团队。
local partyMS= JOINED_PARTY:gsub("%%s", "(.+)")--%s加入了队伍。
local guildMS= ERR_GUILD_JOIN_S:gsub("%%s", "(.+)")--加入了公会

local function Event_CHAT_MSG_SYSTEM(_, text)--欢迎加入, 信息
    if not text then
        return
    end
    local group= Save.groupWelcome and text:match(raidMS) or text:match(partyMS)
    local guild= Save.guildWelcome and text:match(guildMS)
    if group then
        if UnitIsGroupLeader('player') and (Save.welcomeOnlyHomeGroup and IsInGroup(LE_PARTY_CATEGORY_HOME) or not Save.welcomeOnlyHomeGroup) then
            WoWTools_ChatMixin:Chat(Save.groupWelcomeText or EMOTE103_CMD1:gsub('/',''), group, nil)
        end
    elseif guild and IsInGuild() and text:find(guildMS) then
        C_Timer.After(2, function()
            SendChatMessage(Save.guildWelcomeText..' '.. guild.. ' ' ..GUILD_INVITE_JOIN, "GUILD")
        end)
    end
end










local function Create_Texture_Tips(btn, data)--atlas, coord)
    if not btn then
        return
    end
    if data and not btn.Texture then
        btn.Texture= btn:CreateTexture(nil, 'BORDER')
        btn.Texture:SetSize(26, 26)--200, 36
        btn.Texture:SetPoint('RIGHT', btn, 'LEFT', 6,0)
        --btn.Texture:SetPoint('LEFT', btn, 'RIGHT', -6,0)
    end
    if btn.Texture then
        if data and data[1] then
            btn.Texture:SetAtlas(data[1])
        else
            btn.Texture:SetTexture(nil)
        end
        if data and data[2] then
            btn.Texture:SetTexCoord(1,0,1,0)
        end
    end

    local font= btn:GetFontString()
    local r, g, b
    if data and data[3] then
        r, g, b= data[3][1], data[3][2], data[3][3]
    elseif data then
        r, g, b= 1, 1, 1
    end
    font:SetTextColor(r or 1, g or 0.82, b or 0)

end


--添加 RELOAD 按钮
local function Init_Add_Reload_Button()
    if Save.not_Add_Reload_Button or SettingsPanel.AddOnsTab.reload then
        if SettingsPanel.AddOnsTab.reload then
            SettingsPanel.AddOnsTab.reload:SetShown(not Save.not_Add_Reload_Button)
        end
        return
    end

    --for _, frame in pairs({SettingsPanel.AddOnsTab}) do
        local frame= SettingsPanel.AddOnsTab
        if frame then
            frame.reload= CreateFrame('Button', nil, frame, 'GameMenuButtonTemplate')
            frame.reload:SetText(e.onlyChinese and '重新加载UI' or RELOADUI)
            frame.reload:SetScript('OnLeave', GameTooltip_Hide)
            frame.reload:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(WoWTools_Mixin.addName, 'Tools '..addName)
                e.tips:AddDoubleLine(e.onlyChinese and '重新加载UI' or RELOADUI, '|cnGREEN_FONT_COLOR:'..SLASH_RELOAD1)
                e.tips:Show()
            end)
            frame.reload:SetScript('OnClick', function() WoWTools_Mixin:Reload() end)
            Create_Texture_Tips(frame.reload, 'BattleBar-SwapPetIcon')
        end
    --end


    SettingsPanel.AddOnsTab.reload:SetPoint('RIGHT', SettingsPanel.ApplyButton, 'LEFT', -15,0)
    WoWTools_LabelMixin:Create(nil, {changeFont= SettingsPanel.OutputText, size=14})
    SettingsPanel.OutputText:ClearAllPoints()
    SettingsPanel.OutputText:SetPoint('BOTTOMLEFT', 20, 18)




--Blizzard_GameMenu/Standard/GameMenuFrame.lua
        local dataButton={--layoutIndex
            [GAMEMENU_OPTIONS]= {'mechagon-projects', false},--选项
            [HUD_EDIT_MODE_MENU]= {'UI-HUD-Minimap-CraftingOrder-Up', false},--编辑模式
            [MACROS]= {'NPE_Icon', false},--宏命令设置

            [ADDONS]= {'dressingroom-button-appearancelist-up', false},--插件
            [LOG_OUT]= {'perks-warning-large', false, {0,0.8,1}},--登出
            [EXIT_GAME]= {'Ping_Chat_Warning', false, {0,0.8,1}},--退出游戏
            [RETURN_TO_GAME]= {'poi-traveldirections-arrow', true, {0,1,0}},--返回游戏
        }
        hooksecurefunc(GameMenuFrame, 'InitButtons', function(self)
            for btn in self.buttonPool:EnumerateActive() do
                local data= dataButton[btn:GetText()]
                Create_Texture_Tips(btn, data)
            end

            self:AddSection()

            local btn = self:AddButton(e.onlyChinese and '重新加载UI' or RELOADUI, function()
                WoWTools_Mixin:Reload()
            end)
            Create_Texture_Tips(btn, {'BattleBar-SwapPetIcon', false, {1,1,1}})
        end)
    end










--隐藏NPC发言
local VoHandle
local function Set_Talking()
    if Save.disabledNPCTalking then
        return
    end

    local _, _, vo, _, _, _, name, text = C_TalkingHead.GetCurrentLineInfo()
    TalkingHeadFrame:CloseImmediately()

    if not vo or vo<=0 then
        return
    end

    if ( VoHandle ) then
        StopSound(VoHandle)
        VoHandle = nil
    end

    local success, vo2 = e.PlaySound(vo, true)--PlaySound(vo, "Talking Head", true, true)
    if ( success ) then
        VoHandle = vo2
    end

    if not Save.disabledTalkingPringText and text then
        print(e.Icon.icon2
            ..'|cffff00ff'..(name or '')
            ..'|r|A:voicechat-icon-textchat-silenced:0:0|a|cff00ff00'
            ..(text or '')
        )
    end
end






--队伍查找器, 接受邀请
local function Set_LFGListInviteDialog_OnShow(self)
    if Save.setPlayerSound then
        e.PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
    end
    e.Ccool(self, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条
    local status, _, _, role= select(2,C_LFGList.GetApplicationInfo(self.resultID))
    if status=="invited" then
        local info= C_LFGList.GetSearchResultInfo(self.resultID)
        if self.AcceptButton and self.AcceptButton:IsEnabled() and info then
            print(WoWTools_Mixin.addName, addName,
                info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and '|T4352494:0|t'..WoWTools_WeekMixin:KeystoneScorsoColor(info.leaderOverallDungeonScore) or '',--地下城史诗,分数
                info.leaderPvpRatingInfo and info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 and '|A:pvptalents-warmode-swords:0:0|a|cnRED_FONT_COLOR:'..info.leaderPvpRatingInfo.rating..'|r' or '',--PVP 分数
                info.leaderName and (e.onlyChinese and '%s邀请你加入' or COMMUNITY_INVITATION_FRAME_INVITATION_TEXT):format(WoWTools_UnitMixin:GetLink(info.leaderName)..' ') or '',--	%s邀请你加入
                info.name,--名称
                e.Icon[role] or '',
                info.numMembers and (e.onlyChinese and '队员' or PLAYERS_IN_GROUP)..'|cff00ff00 '..info.numMembers..'|r' or '',--队伍成员数量
                info.autoAccept and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '自动邀请' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, INVITE))..'|r' or '',--对方是否开启, 自动邀请
                info.activityID and '|cffff00ff'..C_LFGList.GetActivityFullName(info.activityID)..'|r' or '',--查找器,类型
                info.isWarMode~=nil and info.isWarMode ~= C_PvP.IsWarModeDesired() and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '战争模式' or TALENT_FRAME_LABEL_WARMODE)..'|r' or ''
            )
        end
    end
end






--#########
--事件, 声音
--#########
local function Set_PlayerSound()--事件, 声音
    if not Save.setPlayerSound then
        return
    end
    if not UnitAffectingCombat('player') then
        if not C_CVar.GetCVarBool('Sound_EnableAllSound') then
            C_CVar.SetCVar('Sound_EnableAllSound', '1')
            print(WoWTools_Mixin.addName, addName, '|cnGREEN_FONT_COLOR:CVar Sound_EnableAllSound|r', e.onlyChinese and '开启声效' or ENABLE_SOUND)
        end
        if C_CVar.GetCVar('Sound_MasterVolume')=='0' then
            C_CVar.SetCVar('Sound_MasterVolume', '1.0')
            print(WoWTools_Mixin.addName, addName, '|cnGREEN_FONT_COLOR:CVar Sound_MasterVolume|r', e.onlyChinese and '主音量' or MASTER_VOLUME, '1')
        end

        if C_CVar.GetCVar('Sound_DialogVolume')=='0' then
            C_CVar.SetCVar('Sound_DialogVolume', '1.0')
            print(WoWTools_Mixin.addName, addName, '|cnGREEN_FONT_COLOR:CVar Sound_DialogVolume|r',e.onlyChinese and '对话' or DIALOG_VOLUME, '1')
        end
        if not C_CVar.GetCVarBool('Sound_EnableDialog') then
            C_CVar.SetCVar('Sound_EnableDialog', '1')
            print(WoWTools_Mixin.addName, addName, '|cnGREEN_FONT_COLOR:CVar Sound_EnableDialog|r', e.onlyChinese and '启用对话' or ENABLE_DIALOG)
        end
    end
end


local function Event_START_TIMER(_, arg1, arg2, arg3)
    if not Save.setPlayerSound then
        return
    end
    if arg2==0 and arg3==0 then
        LinkButton.timerType= nil
        if LinkButton.timer4 then LinkButton.timer4:Cancel() end
        if LinkButton.timer3 then LinkButton.timer3:Cancel() end
        if LinkButton.timer2 then LinkButton.timer2:Cancel() end
        if LinkButton.timer1 then LinkButton.timer1:Cancel() end
        if LinkButton.timer0 then LinkButton.timer0:Cancel() end

    elseif arg1 and arg2 and arg2>3 and not LinkButton.timerType then
        LinkButton.timerType=arg1
        if arg2>20 then
            LinkButton.timer4= C_Timer.NewTimer(arg2-10, function()--3
                e.PlaySound()
            end)
        elseif arg2>=7 then
            e.PlaySound()
        end
        LinkButton.timer3= C_Timer.NewTimer(arg2-3, function()--3
            e.PlaySound(115003)
        end)
        LinkButton.timer2= C_Timer.NewTimer(arg2-2, function()--2
            e.PlaySound(115003)
        end)
        LinkButton.timer1= C_Timer.NewTimer(arg2-1, function()--1
            e.PlaySound(115003)
        end)
        LinkButton.timer0= C_Timer.NewTimer(arg2, function()--0
            e.PlaySound(114995 )--63971)
            LinkButton.timerType=nil
        end)
    end
end


local function Event_STOP_TIMER_OF_TYPE()
    LinkButton.timerType= nil
    if LinkButton.timer4 then LinkButton.timer4:Cancel() end
    if LinkButton.timer3 then LinkButton.timer3:Cancel() end
    if LinkButton.timer2 then LinkButton.timer2:Cancel() end
    if LinkButton.timer1 then LinkButton.timer1:Cancel() end
    if LinkButton.timer0 then LinkButton.timer0:Cancel() end
end
























--#####
--主菜单
--#####
local function Init_Menu(_, root)
    local sub, tre, col
    local isInBat= UnitAffectingCombat('player')

    --超链接图标
    sub= root:CreateCheckbox(e.onlyChinese and '超链接图标'or addName, function()
        return not Save.disabed
    end, function()
        Save.disabed= not Save.disabed and true or nil
        print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save.disabed))
        Set_HyperLlinkIcon()
    end)

    --关键词
    sub:CreateCheckbox(e.Player.L.key, function()--关键词, 内容颜色，和频道名称替换
        return not Save.disabledKeyColor
    end, function()
        Save.disabledKeyColor= not Save.disabledKeyColor and true or nil
    end)

    sub:CreateButton('|A:mechagon-projects:0:0|a'..(e.onlyChinese and '设置关键词' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, e.Player.L.key)), function()
        if not Category then
            e.OpenPanelOpting()
        end
        e.OpenPanelOpting(Category, addName)
    end)


    --玩家信息
    sub:CreateDivider()
    tre= sub:CreateCheckbox(e.onlyChinese and '玩家信息' or PLAYER_MESSAGES, function()
        return not Save.notShowPlayerInfo
    end, function()
        Save.notShowPlayerInfo= not Save.notShowPlayerInfo and true or nil
    end)
    tre:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, WoWTools_UnitMixin:GetPlayerInfo('player', nil, nil, {reLink=true}))
    end)


    --事件声音
    col= isInBat and '|cnRED_FONT_COLOR:' or (
            not C_CVar.GetCVarBool('Sound_EnableAllSound')
            or C_CVar.GetCVar('Sound_MasterVolume')=='0'
            or C_CVar.GetCVar('Sound_DialogVolume')=='0'
            or not C_CVar.GetCVarBool('Sound_EnableDialog')
        ) and '|cff9e9e9e' or ''
    sub=root:CreateCheckbox(col..'|A:chatframe-button-icon-voicechat:0:0|a'..(e.onlyChinese and '事件声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTS_LABEL, SOUND)), function()
        return Save.setPlayerSound
    end, function()
        if UnitAffectingCombat('player') then
            return
        end
        Save.setPlayerSound= not Save.setPlayerSound and true or nil
        e.setPlayerSound= Save.setPlayerSound
        if Save.setPlayerSound then
            e.PlaySound()--播放, 声音
        end
        Set_PlayerSound()
        print(WoWTools_Mixin.addName, addName, e.onlyChinese and "播放" or SLASH_STOPWATCH_PARAM_PLAY1, e.onlyChinese and '事件声音' or EVENTS_LABEL..SOUND)
    end)
    sub:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, e.Get_CVar_Tooltips({name='Sound_EnableAllSound', msg=e.onlyChinese and '开启声效' or ENABLE_SOUND}))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, e.Get_CVar_Tooltips({name='Sound_MasterVolume', msg=e.onlyChinese and '主音量' or MASTER_VOLUME}))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, e.Get_CVar_Tooltips({name='Sound_DialogVolume', msg=e.onlyChinese and '对话' or DIALOG_VOLUME}))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, e.Get_CVar_Tooltips({name='Sound_EnableDialog', msg=e.onlyChinese and '启用对话' or ENABLE_DIALOG }))
    end)


    --禁用，隐藏NPC发言
    sub:CreateCheckbox(e.onlyChinese and '隐藏NPC发言' or (HIDE..' (NPC) '..VOICE_TALKING), function()
        return not Save.disabledNPCTalking
    end, function()
        Save.disabledNPCTalking= not Save.disabledNPCTalking and true or nil
    end)
    --文本
    sub:CreateCheckbox('|A:communities-icon-chat:0:0|a'..(e.onlyChinese and '文本' or LOCALE_TEXT_LABEL), function()
        return not Save.disabledTalkingPringText
    end, function()
        Save.disabledTalkingPringText= not Save.disabledTalkingPringText and true or nil
    end)


    --欢迎加入
    sub=root:CreateCheckbox(e.onlyChinese and '欢迎加入' or (EMOTE103_CMD1:gsub('/','')..JOIN), function()
        return Save.guildWelcome or Save.groupWelcome
    end, function()
        if Save.guildWelcome or Save.groupWelcome then
            Save.guildWelcome=nil
            Save.groupWelcome=nil
        else
            Save.guildWelcome=true
            Save.groupWelcome=true
        end
    end)

    --公会新成员
    tre=sub:CreateCheckbox(e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER, function()
        return Save.guildWelcome
    end, function()
        Save.guildWelcome= not Save.guildWelcome and true or nil
    end)
    tre:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, Save.guildWelcomeText)
    end)

    tre= sub:CreateButton('|A:communities-guildbanner-background:0:0|a'..(e.onlyChinese and '修改' or EDIT), function ()
        StaticPopup_Show('WoWTools_EditText',
            (e.onlyChinese and '欢迎加入' or 'Welcome to join')..'|n|A:communities-guildbanner-background:0:0|a'..(e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER),
            nil,
            {
                text=Save.guildWelcomeText,
                SetValue= function(self)
                    local text= self.editBox:GetText()
                    Save.guildWelcomeText= text
                    print(WoWTools_Mixin.addName, addName, text)
                end
            }
        )
    end)
    tre:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, Save.guildWelcomeText)
    end)

    --队伍新成员
    sub:CreateDivider()
    tre=sub:CreateCheckbox(e.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC, function ()
        return Save.groupWelcome
    end, function ()
        Save.groupWelcome= not Save.groupWelcome and true or nil
        set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    end)
    tre:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, Save.groupWelcomeText)
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddInstructionLine(tooltip,  e.onlyChinese and '仅限队长或团长' or format(LFG_LIST_CROSS_FACTION, LEADER))
    end)

    tre=sub:CreateCheckbox(e.onlyChinese and '仅限组队邀请' or format(LFG_LIST_CROSS_FACTION, GROUP_INVITE), function ()
        return Save.welcomeOnlyHomeGroup
    end, function ()
        Save.welcomeOnlyHomeGroup= not Save.welcomeOnlyHomeGroup and true or nil
    end)
    tre:SetTooltip(function (tooltip)
        GameTooltip_AddNormalLine(tooltip, Save.groupWelcomeText)
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddErrorLine(tooltip, e.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)
    end)

    tre= sub:CreateButton('|A:socialqueuing-icon-group:0:0|a'..(e.onlyChinese and '修改' or EDIT), function ()
        StaticPopup_Show('WoWTools_EditText',
            (e.onlyChinese and '欢迎加入' or 'Welcome to join')..'|n|A:socialqueuing-icon-group:0:0|a'..(e.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC),
            nil,
            {
                text=Save.groupWelcomeText,
                SetValue= function(self)
                    local text= self.editBox:GetText()
                    Save.groupWelcomeText=text
                    print(WoWTools_Mixin.addName, addName, text)
                end
            }
        )
    end)
    tre:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, Save.groupWelcomeText)
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddInstructionLine(tooltip,  e.onlyChinese and '仅限队长或团长' or format(LFG_LIST_CROSS_FACTION, LEADER))
    end)


    --文本转语音    
    sub=root:CreateCheckbox((isInBat and '|cnRED_FONT_COLOR:' or '')..'|A:chatframe-button-icon-TTS:0:0|a'..(e.onlyChinese and '文本转语音' or TEXT_TO_SPEECH), function ()
        return C_CVar.GetCVarBool('textToSpeech')
    end, function ()
        if not UnitAffectingCombat('player') then
            C_CVar.SetCVar("textToSpeech", not C_CVar.GetCVarBool('textToSpeech') and '1' or '0' )
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('/tts')
    end)

    --etrace
    root:CreateDivider()
    root:CreateButton('|A:minimap-genericevent-hornicon:0:0|a|cffff00ffETR|rACE', function ()
        if not C_AddOns.IsAddOnLoaded('Blizzard_EventTrace') then
            C_AddOns.LoadAddOn("Blizzard_EventTrace")
        end
        EventTrace:OnShow()
        return MenuResponse.Open
    end)

    --fstack
    sub=root:CreateButton('|A:QuestLegendaryTurnin:0:0|a|cff00ff00FST|rACK', function ()
        if not C_AddOns.IsAddOnLoaded("Blizzard_DebugTools") then
            C_AddOns.LoadAddOn("Blizzard_DebugTools")
        end
        FrameStackTooltip_ToggleDefaults()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function (tooltip)
        GameTooltip_AddNormalLine(tooltip, '|cnGREEN_FONT_COLOR:Alt|r '..(e.onlyChinese and '切换' or HUD_EDIT_MODE_SWITCH))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, '|cnGREEN_FONT_COLOR:Ctrl|r '..(e.onlyChinese and '显示' or SHOW))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, '|cnGREEN_FONT_COLOR:Shift|r '..(e.onlyChinese and '材质信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TEXTURES_SUBHEADER, INFO)))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, '|cnGREEN_FONT_COLOR:Ctrl+C|r '.. (e.onlyChinese and '复制' or CALENDAR_COPY_EVENT)..' \"File\" '..(e.onlyChinese and '类型' or TYPE))
    end)

    root:CreateButton(
        '|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '颜色选择器' or COLOR_PICKER),
    function()
        if ColorPickerFrame:IsShown() then
            ColorPickerFrame:Hide()
        else
            WoWTools_ColorMixin:ShowColorFrame(e.Player.r, e.Player.g, e.Player.b, 1, nil, nil)
        end
        return MenuResponse.Open
    end)

    root:CreateDivider()
    sub=WoWTools_MenuMixin:Reload(root, false)

    tre=sub:CreateCheckbox(e.onlyChinese and '添加按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, 'Button'), function ()
        return not Save.not_Add_Reload_Button
    end, function ()
        Save.not_Add_Reload_Button= not Save.not_Add_Reload_Button and true or nil
        Init_Add_Reload_Button()
    end)
    tre:SetTooltip(function (tooltip)
        GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '主菜单' or MAINMENU_BUTTON)
        GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '选项' or OPTIONS)
    end)
end













local function Init_Blizzard_DebugTools()
    if not LinkButton then
        return
    end
    local btn= WoWTools_ButtonMixin:Cbtn(TableAttributeDisplay, {icon='hide', size={28,28}})
    btn:SetPoint('BOTTOM', TableAttributeDisplay.CloseButton, 'TOP')
    btn:SetNormalAtlas(e.Icon.icon)
    btn:SetScript('OnClick', FrameStackTooltip_ToggleDefaults)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine('|cff00ff00FST|rACK', e.GetEnabeleDisable(true)..'/'..e.GetEnabeleDisable(false))
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, addName)
        e.tips:Show()
    end)

    local edit= CreateFrame("EditBox", nil, TableAttributeDisplay, 'InputBoxTemplate')
    edit:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMLEFT')
    edit:SetPoint('TOPLEFT', TableAttributeDisplay, 'TOPLEFT', 10, 24 )
    edit:SetAutoFocus(false)
    edit:ClearFocus()
    edit:SetScript('OnUpdate', function(self2, elapsed)
        self2.elapsed= (self2.elapsed or 0.3) +elapsed
        if self2.elapsed>0.3 then
            self2.elapsed=0
            if not self2:HasFocus() then
                local text = TableAttributeDisplay.TitleButton.Text:GetText()
                if text and text~='' then
                    edit:SetText(text:match('%- (.+)') or text)
                end
            end
        end
    end)
    edit:SetScript("OnKeyUp", function(s, key)
        if IsControlKeyDown() and key == "C" then
            print(WoWTools_Mixin.addName, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r', s:GetText())
        end
    end)
end












local function Set_Event(self, event, arg1, arg2, arg3)

if event=='START_TIMER' then--播放, 声音

    elseif event=='STOP_TIMER_OF_TYPE' then

    end
end







local function Set_Button()
    --事件, 声音, 提示图标
    LinkButton.setPlayerSoundTips= LinkButton:CreateTexture(nil,'OVERLAY')
    LinkButton.setPlayerSoundTips:SetPoint('BOTTOMLEFT',4, 4)
    LinkButton.setPlayerSoundTips:SetSize(12,12)
    LinkButton.setPlayerSoundTips:SetAtlas('chatframe-button-icon-voicechat')

    function LinkButton:HandlesGlobalMouseEvent(_, event)
        return event == "GLOBAL_MOUSE_DOWN"-- and buttonName == "RightButton"
    end
    function LinkButton:Settings()
        self.texture:SetAtlas(not Save.disabed and e.Icon.icon or e.Icon.disabled)
        self.setPlayerSoundTips:SetShown(Save.setPlayerSound)
    end

    LinkButton:SetupMenu(Init_Menu)

    LinkButton:Settings()
end




--####
--初始
--####
local function Init()

    e.setPlayerSound= Save.setPlayerSound--播放, 声音
    LOOT_ITEM= LOCALE_zhCN and '(.-)获得了战利品' or WoWTools_TextMixin:Magic(LOOT_ITEM)



    Set_Button()
    if not Save.disabed then--使用，禁用
        Set_HyperLlinkIcon()
    end

--事件, 公会新成员, 队伍新成员
    EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_SYSTEM", Event_CHAT_MSG_SYSTEM)

--事件, 声音
    Set_PlayerSound()
    EventRegistry:RegisterFrameEventAndCallback("START_TIMER", Event_START_TIMER)
    EventRegistry:RegisterFrameEventAndCallback("STOP_TIMER_OF_TYPE", Event_STOP_TIMER_OF_TYPE)

--队伍查找器, 接受邀请
    LFGListInviteDialog:SetScript("OnShow", Set_LFGListInviteDialog_OnShow)

--隐藏NPC发言
    EventRegistry:RegisterFrameEventAndCallback("TALKINGHEAD_REQUESTED", Set_Talking)

--是否有，聊天中时间戳
    IsShowTimestamps= C_CVar.GetCVar("showTimestamps")~='none' and true or nil
    EventRegistry:RegisterFrameEventAndCallback("CVAR_UPDATE", function(_,arg1,arg2)
        if arg1=='showTimestamps' then
            IsShowTimestamps= arg2~='none' and true or nil
        end
    end)



    Init_Add_Reload_Button()--添加 RELOAD 按钮
end













local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1 == id then
            Save= WoWToolsSave['ChatButton_HyperLink'] or Save
            addName= '|A:bag-reagent-border-empty:0:0|a'..(e.onlyChinese and '超链接图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL))
            LinkButton= WoWTools_ChatButtonMixin:CreateButton('HyperLink', addName)

            if LinkButton then
                Init()
            else
                DEFAULT_CHAT_FRAME.ADD= nil
                self:UnregisterAllEvents()
            end

        elseif arg1=='Blizzard_Settings' then
            Init_Panel()--设置控制面板

        elseif arg1=='Blizzard_DebugTools' then--FSTACK Blizzard_DebugTools.lua
            Init_Blizzard_DebugTools()
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_HyperLink']=Save
        end
    end
end)









