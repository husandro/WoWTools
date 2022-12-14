local id, e = ...
local addName = COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK..EMBLEM_SYMBOL
local Save={
    channels={--频道名称替换 
        ['世界'] = '[世]',
        [GENERAL]='['..GENERAL..']',
        ['本地']='[本地]',
        [PET_BATTLE_COMBAT_LOG]='['..PET..']',
    },
    text={--内容颜色,
        ['来人']=true,
        ['成就']=true,
    },
    groupWelcome=true,
    guildWelcome=true,
}

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

local Magic=function(s)  local t={'%%', '%.', '%(','%)','%+', '%-', '%*', '%?', '%[', '%^', '%$'} for _,v in pairs(t) do s=s:gsub(v,'%%'..v) end return s end --  ( ) . % + - * ? [ ^ $
local MK=function(k,b) if not b then b=1 end if k>=1e6 then k=string.format('%.'..b..'fm',k/1e6) elseif k>= 1e4 and GetLocale() == "zhCN" then k=string.format('%.'..b..'fw',k/1e4) elseif k>=1e3 then k=string.format('%.'..b..'fk',k/1e3) else k=string.format('%i',k) end return k end--加k 9.1
local Race=function(u, race, sex2) local s =u and select(2,UnitRace(u)) or race local sex= u and UnitSex(u) or sex2 if s and (sex==2 or sex==3 ) then s= s=='Scourge' and 'Undead' or s=='HighmountainTauren' and 'highmountain' or s=='ZandalariTroll' and 'zandalari' or s=='LightforgedDraenei' and 'lightforged' or s s=string.lower(s) sex= sex==2 and 'male' or sex==3 and 'female' return '|A:raceicon-'..s..'-'..sex..':0:0|a' end end--角色图标
local Class=function(u, c, icon) c=c or select(2, UnitClass(u)) c=c and 'groupfinder-icon-class-'..c or nil if c then if icon then return '|A:'..c ..':0:0|a' else return c end end end--职业图标
local Name=UnitName('player')

local set_LOOT_ITEM= LOOT_ITEM:gsub('%%s', '(.+)')--%s获得了战利品：%s。

local function SetChannels(link)
    local name=link:match('%[(.-)]')
    if name then
        for k, v in pairs(Save.channels) do
            if name:find(k) then
                return link:gsub('%[.-]', v)
            end
        end
    end
end

local function Realm(link)--去服务器为*, 加队友种族图标,和N,T
    local name=link:match('|Hplayer:.-|h%[|cff......(.-)|r]') or link:match('|Hplayer:.-|h%[(.-)]|h')
    if name == e.Player.name or name==e.Player.name_server then
        return '['..e.Player.col..COMBATLOG_FILTER_STRING_ME..'|r]'
    else
        local server=link:match('|Hplayer:.-|h%[.-%-(.-)|r]|h') or link:match('|Hplayer:.-|h%[(.-)]|h')
        local  text
        local tab=e.GroupGuid[name]--队伍成员
        if tab and tab.unit then--玩家种族图标
            local race=e.Race(tab.unit)
            text= race
            if tab.combatRole=='HEALER' or tab.combatRole=='TANK' then--职业图标
                text= (text or '')..e.Icon[tab.combatRole]..(tab.subgroup or '')
            end
        end
        if server then
            if server== e.Player.server then
                return (text or '')..link:gsub('%-'..server..'|r]|h', '|r]|h')
            elseif e.Player.servers[server] then
                return (text or '')..link:gsub('%-'..server..'|r]|h', GREEN_FONT_COLOR_CODE..'*|r|r]|h')
            else
                return (text or '')..link:gsub('%-'..server..'|r]|h', '*|r]|h')
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
        local mountID=item and C_MountJournal.GetMountFromItem(id2) or C_MountJournal.GetMountFromSpell(id2)
        if  mountID then
            local _, _, icon, _, _, _, _, _, _, _, isCollected =C_MountJournal.GetMountInfoByID(mountID)
            if select(11, C_MountJournal.GetMountInfoByID(mountID)) then
                return e.Icon.select2, icon
            else
                return e.Icon.info2, icon
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
    local t=link
    local icon=C_Item.GetItemIconByID(link)
    if icon then----加图标        
        t='|T'..icon..':0|t'..t
    end
    local id2, _, _, _, _, classID, subclassID=GetItemInfoInstant(link)
    id2=id2 or link:match('Hitem:(%d+)')
    if classID==2 or classID==4 then
        local lv=GetDetailedItemLevelInfo(link)--装等
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
                        t=t..e.Icon.okTransmog2
                    else
                        t=t..e.Icon.transmogHide2
                    end
                end
            end
        end
    elseif  classID==15 and (subclassID==2 or subclassID==5) then
        if  subclassID==2 then----宠物数量
            local _, _, petType, _, _, _, _, _, _, _, _, _, speciesID=C_PetJournal.GetPetInfoByItemID(id2)
            local nu=Pet(speciesID)
            if nu then
                t=(PetType(petType) or '')..t..nu
            end
        elseif subclassID==5 then--坐骑是不收集            
            local nu= Mount(id2, true)
            if nu then
                t=t..nu
            end
        end
    elseif C_ToyBox.GetToyInfo(id2) then--玩具
        t=PlayerHasToy(id2) and t..e.Icon.select2 or t..e.Icon.info2
    end
    local bag=GetItemCount(link, true)--数量
    if bag and bag>0 then
        t=t..e.Icon.bag2..MK(bag, 3)
    end
    if t~=link then
        return t
    end
end

local function Spell(link)--法术图标
    local t=link
    local icon= select(3, GetSpellInfo(link))
    local id2=link:match('Hspell:(%d+)')
    if icon then
        return '|T'..icon..':0|t'..link
    elseif id2 then
        icon = GetSpellTexture(id2)
        if icon then
            t='|T'..icon..':0|t'..t
        end
    end

    local nu=Mount(id2)
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
            return (PetType(petType) or '') .. (icon and '|T'..icon..':0|t' or '')..link..nu
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
        local icon = GetSpellTexture(id2)
        if icon then
            return '|T'..icon..':0|t'..link
        end
    end
end

local function Enchant(link)--附魔
    local id2=link:match('Henchant:(%d+)')
    if id2 then
        local icon = GetSpellTexture(id2)
        if icon then
            return '|T'..icon..':0|t'..link
        end
    end
end

local function Currency(link)--货币
    local info= C_CurrencyInfo.GetCurrencyInfoFromLink(link)
    if info and info.iconFileID then
        local nu=''
        if info.quantity and info.quantity>0 then
            nu=MK(info.quantity, 3)
        end
        return  '|T'..info.iconFileID..':0|t'..link..nu
    end
end

local function Achievement(link)--成就
    local id2=link:match('Hachievement:(%d+)')
    if id2 then
        local _, _, _, completed, _, _, _, _, _, icon = GetAchievementInfo(id2)
        local texture=icon and '|T'..icon..':0|t' or ''
        return texture..link..(completed and e.Icon.select2 or e.Icon.info2)
    end
end

local function Quest(link)--任务
    local id2=link:match('Hquest:(%d+)')
    if id2 then
        local wow= C_QuestLog.IsAccountQuest(id2) and e.Icon.wow2 or ''--帐号通用        
        if C_QuestLog.IsQuestFlaggedCompleted(id2) then
            return wow..link..e.Icon.select2
        else
            return wow..link..e.Icon.info2
        end
    end
end

local function Talent(link)--天赋
    local id2=link:match('Htalent:(%d+)')
    if id2 then
        local _, _, icon, _, _, _, _, _ ,_, known=GetTalentInfoByID(id2)
        if icon then
            return '|T'..icon..':0|t'..link..(known and e.Icon.select2 or e.Icon.info2)
        end
    end
end

local function Pvptal(link)--pvp天赋
    local id2=link:match('Hpvptal:(%d+)')
    if id2 then
        local _, _, icon, _, _, _, _, _ ,_, known=GetPvpTalentInfoByID(id2)
        return '|T'..icon..':0|t'..link..(known and e.Icon.select2 or e.Icon.info2)
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
                return link..e.Icon.select2
            elseif co>0 then
                return link..YELLOW_FONT_COLOR_CODE..co..'/'..to..'|r'
            else
                return link..RED_FONT_COLOR_CODE..co..'/'..to..'|r'
            end
        end
    end
end

local function Transmogillusion(link)--幻化
    local illusionID=link:match('Htransmogillusion:(%d+)')
    if illusionID then
        local info=C_TransmogCollection.GetIllusionInfo(illusionID)
        if info then
            local icon=e.Icon.transmogHide2
            if info.isCollected and info.isUsable then
                icon=e.Icon.okTransmog2
            elseif info.isCollected then
                icon=e.Icon.select2
            end
            return link..icon
        end
    end
end

local function TransmogAppearance(link)--幻化
    local appearanceID=link:match('Htransmogillusion:(%d+)')
    if appearanceID then
        local has=C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(appearanceID)
        if has then
            return link.e.Icon.select2
        else
            return link..e.Icon.info2
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
            return texture..link..GetKeyAffix({affix1, affix2, affix3, affix4})
        end
    end
end

local function DungeonScore(link)--史诗钥石评分
    local score, guid, itemLv=link:match('|HdungeonScore:(%d+):(.-):.-:%d+:(%d+):')
    local t=link
    if score and score~='0' then
        t=score..link
    end
    if guid then
        local _, class, _, race, sex = GetPlayerInfoByGUID(guid)
        race=Race(nil, race, sex)
        class=Class(nil, class, true)
        t=class and class..t or t
        t=race and race..t or t
    end
    if itemLv and itemLv~='0' then
        t=t..itemLv
    end
    local nu=#C_MythicPlus.GetRunHistory()
    if nu>0 then
        t=t..' |cff00ff00'..nu..'/'..#C_MythicPlus.GetRunHistory(false, true)..'|r'
    end
    if t~=link then
        return t
    end
end

local function Journal(link)--冒险指南 |Hjournal:0:1031:14|h[Uldir]|h 0=Instance, 1=Encounter, 2=Section
    local journalType, journalID, journalName=link:match('Hjournal:(%d+):(%d+):.-%[(.-)]')
    if journalID then
        if journalType=='2' then
           local sectionID = select(3, EJ_HandleLinkPath(journalType, journalID))
           if sectionID then
                local info = C_EncounterJournal.GetSectionInfo(sectionID)
                if info and info.abilityIcon then
                    return '|T'..info.abilityIcon..':0|t'..link
                end
           end
        elseif journalType=='1' and journalName then
            local _, encounterID = EJ_HandleLinkPath(journalType, journalID)
            for index=1,9 do
                local _, name, _, _, iconImage = EJ_GetCreatureInfo(index, encounterID)
                if name and iconImage then
                    if name==journalName then
                        return '|T'..iconImage..':0|t'..link
                    end
                else
                    break
                end
            end
        elseif journalType=='0' then--Instance
            local buttonImage2 = select(6, EJ_GetInstanceInfo(journalID))
            if buttonImage2 then
                return '|T'..buttonImage2..':0|t'..link
            end
        end
    end
end

local function Instancelock(link)
    local guid, InstanceID, DifficultyID=link:match('Hinstancelock:(.-):(%d+):(%d+):')
    local t=link
    if guid then
        local _, class, _, race, sex = GetPlayerInfoByGUID(guid)
        race=Race(nil, race, sex)
        class=Class(nil, class, true)
        t=class and class..t or t
        t=race and race..t or t
    end
    if DifficultyID and InstanceID then
        local name=GetDifficultyInfo(DifficultyID)
        if name then
            t=t..'|Hjournal:0:'..InstanceID..':'..DifficultyID..'|h['..name..']|h'
        end
    end
    if t~=link then
        return t
    end
end

local function TransmogSet(link)--幻化套装
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
                    return e.Icon.select2
                elseif n==0 then
                    return link..RED_FONT_COLOR_CODE..n..'/'..to..'|r'
                else
                    return link..YELLOW_FONT_COLOR_CODE..n..'/'..to..'|r'
                end
            end
        end
    end
end

local function setMount(link)--设置,坐骑
    local spellID= link:match('mount:(%d+)')
    if spellID then
        local mount,icon= Mount(spellID)
        if mount then
            return (icon and '|T'..icon..':0|t' or '')..link..mount
        end
    end
end

local function Waypoint(text)--地图标记xy, 格式 60.0 70.5
    local uiMapID= WorldMapFrame:IsShown() and WorldMapFrame.mapID or C_Map.GetBestMapForUnit("player")
    if uiMapID and C_Map.CanSetUserWaypointOnMap(uiMapID) then
        local x, y= text:match('(%d+%.%d) (%d+%.%d)')
        if x and y then
            return '|cffffff00|Hworldmap:'..uiMapID..':'..x:gsub('%.','')..'0:'..y:gsub('%.','')..'0|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a'..text..']|h|r'
        end
    end
end

local showTimestamps--聊天中时间戳
local playerName=UnitName('player')
local function setAddMessageFunc(self, s, ...)
    local petChannel=s:find('|Hchannel:.-'..PET_BATTLE_COMBAT_LOG..']|h') and true or false

    s=s:gsub('|Hchannel:.-]|h', SetChannels)
    s=s:gsub('|Hplayer:.-]|h', Realm)
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

    s=s:gsub('(%d+%.%d %d+%.%d)', Waypoint)--地图标记xy, 格式 60.0 70.5

    if not showTimestamps and s:find(set_LOOT_ITEM) then--	%s获得了战利品：%s。
        local unitName= s:match(set_LOOT_ITEM)
        if unitName then
            if unitName==playerName then
                s=s:gsub(unitName..'['..e.Player.col..(e.onlyChinse and '我' or COMBATLOG_FILTER_STRING_ME)..'|r]')
            else
                s=s:gsub(Magic(unitName), e.PlayerLink(unitName))
            end
        end
    end
    for k, _ in pairs(Save.text) do--内容加颜色
        s=s:gsub(k, '|cnGREEN_FONT_COLOR:'..k..'|r')
    end

    return self.ADD(self, s, ...)
end

--#########
--使用，禁用
--#########
local function setUseDisabled()
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
    panel.texture:SetShown(not Save.disabed)--SetDesaturated(Save.disabed)
end
local function setFunc()--使用，禁用
    Save.disabed= not Save.disabed and true or nil
    print(id, addName, e.GetEnabeleDisable(not Save.disabed))
    setUseDisabled()
end

--###########
--设置控制面板
--###########
local function setPanel()
    local frame = CreateFrame("FRAME");
    frame.name = e.onlyChinse and '超链接图标' or addName;
    frame.parent =id;
    InterfaceOptions_AddCategory(frame)

    local str=e.Cstr(frame)--内容加颜色
    str:SetPoint('TOPLEFT')
    str:SetText(e.onlyChinse and '颜色: 关键词 (|cnGREEN_FONT_COLOR:空格|r) 分开' or (COLOR..': '..KBASE_DEFAULT_SEARCH_TEXT..'|cnGREEN_FONT_COLOR:( '..KEY_SPACE..' )|r'))
    local editBox=e.CeditBox(frame)
    editBox:SetPoint('TOPLEFT', str, 'BOTTOMLEFT',0,-5)
    editBox:SetTextColor(0,1,0)
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
    btn:SetText(e.onlyChinse and '更新' or UPDATE)
    btn:SetPoint('TOPLEFT', editBox, 'TOPRIGHT',5, 0)
    btn:SetScript('OnMouseDown', function()
        Save.text={}
        local n=0
        local s=editBox:GetText()
        if s:gsub(' ','')~='' then
            s=s..' '
            s=s:gsub('\n', ' ')
            s:gsub('.- ', function(t)
                t=t:gsub(' ','')
                if t and t~='' then
                    t=Magic(t)
                    Save.text[t]=true
                    n=n+1
                    print(n..')'..COLOR, t)
                end
            end)
        end
        print(id, addName, e.onlyChinse and '颜色' or COLOR, '|cnGREEN_FONT_COLOR:#'..n..(e.onlyChinse and '完成' or COMPLETE)..'|r', e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local str2=e.Cstr(frame)--频道名称替换
    str2:SetPoint('TOPLEFT', editBox, 'BOTTOMLEFT', 0,-20)
    str2:SetText(e.onlyChinse and '频道名称替换: 关键词|cnGREEN_FONT_COLOR:=|r替换' or (CHANNEL_CHANNEL_NAME..': '..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL..'  |cnGREEN_FONT_COLOR:= |r'))
    local editBox2=e.CeditBox(frame)
    editBox2:SetPoint('TOPLEFT', str2, 'BOTTOMLEFT',0,-5)
    if Save.channels then
        local t3=''
        for k, v in pairs(Save.channels) do
            if t3~='' then t3=t3..'\n' end
            t3=t3..k..'='..v
        end
       editBox2:SetText(t3)
    end
    local btn2=CreateFrame('Button', nil, editBox2, 'UIPanelButtonTemplate')
    btn2:SetSize(80,28)
    btn2:SetText(e.onlyChinse and '更新' or UPDATE)
    btn2:SetPoint('TOPLEFT', editBox2, 'TOPRIGHT',5, 0)
    btn2:SetScript('OnMouseDown', function()
        Save.channels={}
        local n=0
        local s=editBox2:GetText()
        if s:gsub(' ','')~='' then
            s=s..' '
            s=s:gsub('\n', ' ')
            s:gsub('.-=.- ', function(t)
                local name,name2=t:match('(.-)=(.-) ')
                if name and name2 and name~='' and name2~='' then
                    name=Magic(name)
                    Save.channels[name]=name2
                    n=n+1
                    print(n..')'..CHANNELS..': ',name, REPLACE, name2)
                end
            end)
        end
        print(id, addName, e.onlyChinse and '频道名称替换' or (CHANNEL_CHANNEL_NAME..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL), '|cnGREEN_FONT_COLOR:#'..n..(e.onlyChinse and '完成' or COMPLETE)..'|r',  e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
    end)
end

--#############
--欢迎加入, 信息
--#############
local function set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    if (not Save.guildWelcome or not IsInGuild()) and not Save.groupWelcome then
        panel:UnregisterEvent('CHAT_MSG_SYSTEM')
    else
        panel:RegisterEvent('CHAT_MSG_SYSTEM')
    end
end

local raidMS=ERR_RAID_MEMBER_ADDED_S:gsub("%%s", "(.+)")--%s加入了团队。
local partyMS= JOINED_PARTY:gsub("%%s", "(.+)")--%s加入了队伍。
local guildMS= ERR_GUILD_JOIN_S:gsub("%%s", "(.+)")--加入了公会

local function setMsg_CHAT_MSG_SYSTEM(text)--欢迎加入, 信息
    if not text or (not Save.guildWelcome and not Save.groupWelcome) then
        return
    end
    if text:find(raidMS) or text:find(partyMS) then
        if Save.groupWelcome and UnitIsGroupLeader('player') then
            local name=text:match(raidMS) or text:match(partyMS)
            if name then
                e.Chat(Save.groupWelcomeText or EMOTE103_CMD1:gsub('/',''), name)
            end
        end
    elseif text:find(guildMS) then
        if Save.guildWelcome then
            local name=text:match(guildMS)
            if name then
                C_Timer.After(2, function()
                    SendChatMessage((Save.guildWelcomeText or EMOTE103_CMD1:gsub('/',''))..' '.. name.. ' ' ..GUILD_INVITE_JOIN, "GUILD");
                end)
            end
        end
    end
end

--#################
--Shift+点击设置焦点
--#################
local Frame = {
    ['PlayerFrame']=true,
    ['PetFrame']=true,
    ['PartyMemberFrame1']=true,
    ['PartyMemberFrame2']=true,
    ['PartyMemberFrame3']=true,
    ['PartyMemberFrame4']=true,
    ['PartyMemberFrame1PetFrame']=true,
    ['PartyMemberFrame2PetFrame']=true,
    ['PartyMemberFrame3PetFrame']=true,
    ['PartyMemberFrame4PetFrame']=true,
    ['TargetFrame']=true,
    ['TargetofTargetFrame']=true,
    ['Boss1TargetFrame']=true,
    ['Boss2TargetFrame']=true,
    ['Boss3TargetFrame']=true,
    ['Boss4TargetFrame']=true,
    ['Boss5TargetFrame']=true,
    ['FocusFrameToT']=true,
    ['TargetFrameToT']=true,
    ['FocusFrame']=true,
}
local function set_Shift_Click_facur()
    if UnitAffectingCombat('player') then
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
    local key = 'shift'--设置快快捷键
    for frame, _ in pairs(Frame) do--设置焦点
        if _G[frame] and _G[frame]:CanChangeAttribute() then
            if frame=='FocusFrame' then--取消焦点
                _G[frame]:SetAttribute(key..'-type1','macro')
                _G[frame]:SetAttribute(key..'-macrotext1','/clearfocus')
            else
                _G[frame]:SetAttribute(key..'-type1', 'focus')
            end
            Frame[frame]=nil
        end
    end
    panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
end



--#####
--对话框
--#####
StaticPopupDialogs[id..addName..'WELCOME']={--区域,设置对话框
    text=id..' '..addName..'\n\n'..	EMOTE103_CMD1:gsub('/','').. JOIN..' |cnGREEN_FONT_COLOR:%s|r',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
	timeout = 60,
    hasEditBox=1,
    button1= SLASH_CHAT_MODERATE2:gsub('/', ''),
    button2=CANCEL,
    button3=DISABLE,
    OnShow = function(self, data)
        local text=data.guild and Save.guildWelcomeText or data.group and Save.groupWelcomeText
        text=text or EMOTE103_CMD1:gsub('/','')
        self.editBox:SetText(text)
        self.button3:SetEnabled(data.guild and Save.guildWelcome  or  data.group and Save.groupWelcome)
	end,
    OnAccept = function(self, data)
		local text= self.editBox:GetText()
        if data.guild then
            Save.guildWelcomeText= text
            Save.guildWelcome=true
        elseif data.group then
            Save.groupWelcomeText= text
            Save.groupWelcome=true
        end
        CloseDropDownMenus()
        set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
	end,
    OnAlt = function(self, data)
        if data.guild then
            Save.guildWelcome=nil
        else
            Save.groupWelcome=nil
        end
        CloseDropDownMenus()
        set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    end,
    EditBoxOnTextChanged=function(self, data)
        local text= self:GetText()
        self:GetParent().button1:SetEnabled(text:gsub(' ', '')~='')
    end,
    EditBoxOnEscapePressed = function(s)
        s:GetParent():Hide()
    end,
}

--#####
--主菜单
--#####
local function InitMenu(self, level, type)
    local info
    if type=='Welcome' then--欢迎
        info={
            text= e.onlyChinse and '队伍新成员' or SPELL_TARGET_TYPE14_DESC,--队伍新成员
            checked=Save.groupWelcome,
            tooltipOnButton=true,
            tooltipTitle=LFG_LIST_CROSS_FACTION:format(PARTY_PROMOTE),
            tooltipText=Save.groupWelcomeText or EMOTE103_CMD1:gsub('/',''),
            func=function()
                StaticPopup_Show(id..addName..'WELCOME', e.onlyChinse and '队伍新成员' or SPELL_TARGET_TYPE14_DESC, nil, {group= true})
            end,
        }
        UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinse and '公会新成员' or LFG_LIST_GUILD_MEMBER,--公会新成员
            checked=Save.guildWelcome,
            tooltipOnButton=true,
            tooltipTitle=Save.guildWelcomeText or EMOTE103_CMD1:gsub('/',''),
            colorCode= not IsInGuild() and '|cff606060',--不在公会
            func=function()
                StaticPopup_Show(id..addName..'WELCOME', e.onlyChinse and '公会新成员' or LFG_LIST_GUILD_MEMBER, nil, {guild= true})
            end,
        }
        UIDropDownMenu_AddButton(info, level)

    else
        info={
            text= (e.onlyChinse and '超链接图标'or addName)..e.Icon.left..e.GetEnabeleDisable(not Save.disabed),
            checked=not Save.disabed,
            func=function()
                setFunc()--使用，禁用
            end,
        }
        UIDropDownMenu_AddButton(info, level)

        local bool= C_CVar.GetCVarBool('textToSpeech')--文本转语音
        info={
            text= (e.onlyChinse and '文本转语音' or TEXT_TO_SPEECH)..e.GetEnabeleDisable(bool),
            checked=bool,
            tooltipOnButton=true,
            tooltipTitle='CVar: textToSpeech',
            func=function()
                if C_CVar.GetCVarBool('textToSpeech') then
                    C_CVar.SetCVar("textToSpeech", 0)
                else
                    C_CVar.SetCVar("textToSpeech", 1)
                end
                print(id, addName, e.onlyChinse and '文本转语音' or TEXT_TO_SPEECH..': '..e.GetEnabeleDisable(C_CVar.GetCVarBool('textToSpeech')))
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinse and '欢迎加入' or (EMOTE103_CMD1:gsub('/','')..JOIN),
            checked= Save.guildWelcome or Save.groupWelcome,
            func=function()
                Save.guildWelcome=nil
                Save.groupWelcome=nil
                set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
            end,
            menuList='Welcome',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinse and '设置焦点' or SET_FOCUS,
            checked=Save.setFucus,
            tooltipOnButton=true,
            tooltipTitle='Shift + '..e.Icon.left,
            tooltipText= e.onlyChinse and '仅限系统\n\n如果出现错误: 请取消' or LFG_LIST_CROSS_FACTION:format(SYSTEM)..'\n\n'..ENABLE_ERROR_SPEECH..': '..CANCEL,
            func= function()
                if Save.setFucus then
                    Save.setFucus=nil
                    print(id,addName, e.onlyChinse and '设置' or  SETTINGS, e.onlyChinse and '|cnRED_FONT_COLOR:重新加载UI|r' or '|cnGREEN_FONT_COLOR:'..RELOADUI..'|r')
                else
                    Save.setFucus=true
                    set_Shift_Click_facur()--Shift+点击设置焦点
                end
            end,
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={--重载
            text= e.onlyChinse and '重新加载UI' or RELOADUI,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle='/reload',
            colorCode='|cffff0000',
            func=function()
                C_UI.Reload()
            end
        }
        UIDropDownMenu_AddButton(info, level)
    end
end

DEFAULT_CHAT_FRAME.ADD=DEFAULT_CHAT_FRAME.AddMessage

--####
--初始
--####
local function Init()
    panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')
    WoWToolsChatButtonFrame.last=panel

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')
    panel.texture:SetAtlas(e.Icon.icon)
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            setFunc()--使用，禁用
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)

    if not Save.disabed then--使用，禁用
        setUseDisabled()
    else
        panel.texture:SetDesaturated(true)
    end

    setPanel()--设置控制面板
    set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    if Save.setFucus then--Shift+点击设置焦点
        set_Shift_Click_facur()
        panel:RegisterEvent('GROUP_ROSTER_UPDATE')
    end

    showTimestamps= C_CVar.GetCVar("showTimestamps")~='none' and true or nil
end

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('CVAR_UPDATE')

panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
        else
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            Save.Cvar= Save.Cvar or {}
            Init()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='CHAT_MSG_SYSTEM' then
        setMsg_CHAT_MSG_SYSTEM(arg1)--欢迎加入, 信息

    elseif event=='GROUP_ROSTER_UPDATE' or event=='PLAYER_REGEN_ENABLED' then
        set_Shift_Click_facur()--Shift+点击设置焦点

    elseif event=='CVAR_UPDATE' then
        if arg1=='showTimestamps' then
            showTimestamps= arg2~='none' and true or nil
        end
	end
end)
