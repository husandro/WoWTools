local id, e = ...
local addName = COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK..EMBLEM_SYMBOL
local Save={
    channels={--频道名称替换 
        --['世界'] = '[世]',
    },
    text={--内容颜色,
        [ACHIEVEMENTS]=true,
    },
    groupWelcome= e.Player.husandro,--欢迎
    groupWelcomeText= e.Player.cn and EMOTE103_CMD1:gsub('/','') or 'Hi{rt1}',
    guildWelcome= true,
    --guildWelcomeText='',
    welcomeOnlyHomeGroup=true,--仅限, 手动组队
    setPlayerSound= e.Player.husandro,--播放, 声音
    setFucus= e.Player.husandro,--焦点
    focusKey='Shift',--焦点,快捷键, Ctrl, Alt
}
local button
local panel= CreateFrame("Frame")

local Magic=function(s)  local t={'%%', '%.', '%(','%)','%+', '%-', '%*', '%?', '%[', '%^', '%$'} for _,v in pairs(t) do s=s:gsub(v,'%%'..v) end return s end --  ( ) . % + - * ? [ ^ $
local MK=function(k,b) if not b then b=1 end if k>=1e6 then k=string.format('%.'..b..'fm',k/1e6) elseif k>= 1e4 and GetLocale() == "zhCN" then k=string.format('%.'..b..'fw',k/1e4) elseif k>=1e3 then k=string.format('%.'..b..'fk',k/1e3) else k=string.format('%i',k) end return k end--加k 9.1
local Race=function(u, race, sex2) local s =u and select(2,UnitRace(u)) or race local sex= u and UnitSex(u) or sex2 if s and (sex==2 or sex==3 ) then s= s=='Scourge' and 'Undead' or s=='HighmountainTauren' and 'highmountain' or s=='ZandalariTroll' and 'zandalari' or s=='LightforgedDraenei' and 'lightforged' or s s=string.lower(s) sex= sex==2 and 'male' or sex==3 and 'female' return '|A:raceicon-'..s..'-'..sex..':0:0|a' end end--角色图标
local Class=function(u, c, icon) c=c or select(2, UnitClass(u)) c=c and 'groupfinder-icon-class-'..c or nil if c then if icon then return '|A:'..c ..':0:0|a' else return c end end end--职业图标
--local Name=UnitName('player')

local set_LOOT_ITEM= LOOT_ITEM:gsub('%%s', '(.+)')--%s获得了战利品：%s。

local function SetChannels(link)
    local name=link:match('%[(.-)]')
    if name then
        if name:find(WORLD) then
            return link:gsub('%[.-]', '['..e.WA_Utf8Sub(WORLD, 2, 5)..']')
        end
        for k, v in pairs(Save.channels) do--自定义
            if name:find(k) then
                return link:gsub('%[.-]', v)
            end
        end
        if name:find(GENERAL_LABEL) then--综合
            return link:gsub('%[.-]', '['..e.WA_Utf8Sub(GENERAL_LABEL, 2, 5)..']')
        end

        name= name:match('%d+%. (.+)') or name:match('%d+．(.+)') or name--去数字
        name= name:match('%- (.+)') or name:match('：(.+)') or name:match(':(.+)') or name
        name=e.WA_Utf8Sub(name, 2, 5)
        return link:gsub('%[.-]', '['..name..']')
    end
end

local function Realm(link)--去服务器为*, 加队友种族图标,和N,T
    local split= LinkUtil.SplitLink(link)
    local name= split and split:match('player:(.-):') or link:match('|Hplayer:.-|h%[|cff......(.-)|r]') or link:match('|Hplayer:.-|h%[(.-)]|h')
    local server= name and name:match('%-(.+)')
    if name==e.Player.name_realm or name==e.Player.name then
        return e.Icon.toRight2..e.Player.col..COMBATLOG_FILTER_STRING_ME..'|r'..e.Icon.toLeft2
    else
        local text= e.GetPlayerInfo({unit=nil, guid=nil, name=name,  reName=false, reRealm=false})
        if server then
            --[[local realm= e.Get_Region(server)--服务器，EU， US {col=, text=, realm=}
            if realm then
                text= text and realm.col..text or realm.col
            end]]
            if server== e.Player.realm then
                return (text or '')..link:gsub('%-'..server..'|r]|h', '|r]|h')
            elseif e.Player.Realms[server] then
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
        local mountID= item and C_MountJournal.GetMountFromItem(id2) or C_MountJournal.GetMountFromSpell(id2)
        if  mountID then
            local _, _, icon, _, _, _, _, _, _, _, isCollected =C_MountJournal.GetMountInfoByID(mountID)
            if isCollected then
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

--[[local function Talent(link)--天赋
    local id2=link:match('Htalent:(%d+)')
    if id2 then
        local _, _, icon, _, _, _, _, _ ,_, known=GetTalentInfoByID(id2)
        if icon then
            return '|T'..icon..':0|t'..link..(known and e.Icon.select2 or e.Icon.info2)
        end
    end
end]]

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
        local x, y= text:match('(%d+%.%d). (%d+%.%d)')
        if x and y then
            return '|cffffff00|Hworldmap:'..uiMapID..':'..x:gsub('%.','')..'0:'..y:gsub('%.','')..'0|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a'..text..']|h|r'
        end
    end
end

local showTimestamps--聊天中时间戳
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

    if not showTimestamps and s:find(set_LOOT_ITEM) then--	%s获得了战利品：%s。
        local unitName= s:match(set_LOOT_ITEM)
        if unitName then
            if unitName==e.Player.name then
                s=s:gsub(unitName..'['..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r]')
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
    button.texture:SetShown(not Save.disabed)--SetDesaturated(Save.disabed)
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
    frame.name = e.onlyChinese and '超链接图标' or addName;
    frame.parent =id;
    InterfaceOptions_AddCategory(frame)

    local str=e.Cstr(frame)--内容加颜色
    str:SetPoint('TOPLEFT')
    str:SetText(e.onlyChinese and '颜色: 关键词 (|cnGREEN_FONT_COLOR:空格|r) 分开' or (COLOR..': '..KBASE_DEFAULT_SEARCH_TEXT..'|cnGREEN_FONT_COLOR:( '..KEY_SPACE..' )|r'))
    local editBox=e.Cedit(frame)
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
    btn:SetText(e.onlyChinese and '更新' or UPDATE)
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
        print(id, addName, e.onlyChinese and '颜色' or COLOR, '|cnGREEN_FONT_COLOR:#'..n..(e.onlyChinese and '完成' or COMPLETE)..'|r', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local str2=e.Cstr(frame)--频道名称替换
    str2:SetPoint('TOPLEFT', editBox, 'BOTTOMLEFT', 0,-20)
    str2:SetText(e.onlyChinese and '频道名称替换: 关键词|cnGREEN_FONT_COLOR:=|r替换' or (CHANNEL_CHANNEL_NAME..': '..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL..'  |cnGREEN_FONT_COLOR:= |r'))
    local editBox2=e.Cedit(frame)
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
    btn2:SetText(e.onlyChinese and '更新' or UPDATE)
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
        print(id, addName, e.onlyChinese and '频道名称替换' or (CHANNEL_CHANNEL_NAME..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL), '|cnGREEN_FONT_COLOR:#'..n..(e.onlyChinese and '完成' or COMPLETE)..'|r',  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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
        if Save.groupWelcome and UnitIsGroupLeader('player') and (Save.welcomeOnlyHomeGroup and IsInGroup(LE_PARTY_CATEGORY_HOME) or not Save.welcomeOnlyHomeGroup) then
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



--#########
--事件, 声音
--#########
local function set_START_TIMER_Event()--事件, 声音
    if Save.setPlayerSound then
        panel:RegisterEvent('START_TIMER')
        panel:RegisterEvent('STOP_TIMER_OF_TYPE')
    else
        panel:UnregisterEvent('START_TIMER')
        panel:UnregisterEvent('STOP_TIMER_OF_TYPE')
    end
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
        e.LibDD:CloseDropDownMenus()
        set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
	end,
    OnAlt = function(self, data)
        if data.guild then
            Save.guildWelcome=nil
        else
            Save.groupWelcome=nil
        end
        e.LibDD:CloseDropDownMenus()
        set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    end,
    EditBoxOnTextChanged=function(self, data)
        local text= self:GetText()
        self:GetParent().button1:SetEnabled(text:gsub(' ', '')~='')
    end,
    EditBoxOnEscapePressed = function(s)
        s:SetAutoFocus(false)
        s:ClearFocus()
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
            text= e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER,--公会新成员
            checked=Save.guildWelcome,
            tooltipOnButton=true,
            tooltipTitle=Save.guildWelcomeText or EMOTE103_CMD1:gsub('/',''),
            colorCode= not IsInGuild() and '|cff606060',--不在公会
            func=function()
                StaticPopup_Show(id..addName..'WELCOME', e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER, nil, {guild= true})
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC,--队伍新成员
            checked=Save.groupWelcome,
            tooltipOnButton=true,
            tooltipTitle=LFG_LIST_CROSS_FACTION:format(PARTY_PROMOTE),
            tooltipText=Save.groupWelcomeText or EMOTE103_CMD1:gsub('/',''),
            func=function()
                StaticPopup_Show(id..addName..'WELCOME', e.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC, nil, {group= true})
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={--仅限, 手动组队,不是在随机队伍里
            text= e.onlyChinese and format('仅限%s', '组队邀请') or LFG_LIST_CROSS_FACTION:format(GROUP_INVITE),
            checked= Save.welcomeOnlyHomeGroup,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '随机' or LFG_TYPE_RANDOM_DUNGEON,
            tooltipText= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '不是' or NO),
            func= function()
                Save.welcomeOnlyHomeGroup= not Save.welcomeOnlyHomeGroup and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end


    info={
        text= (e.onlyChinese and '超链接图标'or addName),
        icon= 'newplayertutorial-icon-mouse-leftbutton',
        checked=not Save.disabed,
        func=function()
            setFunc()--使用，禁用
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={--文本转语音
        text= (e.onlyChinese and '文本转语音' or TEXT_TO_SPEECH),
        icon= 'chatframe-button-icon-TTS',
        checked= C_CVar.GetCVarBool('textToSpeech'),
        disabled= UnitAffectingCombat('player'),
        tooltipOnButton=true,
        tooltipTitle='CVar: textToSpeech',
        func=function()
            C_CVar.SetCVar("textToSpeech", not C_CVar.GetCVarBool('textToSpeech') and '1' or '0' )
            print(id, addName, e.onlyChinese and '文本转语音' or TEXT_TO_SPEECH..': '..e.GetEnabeleDisable(C_CVar.GetCVarBool('textToSpeech')))
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '事件声音' or EVENTS_LABEL..SOUND,
        icon= 'chatframe-button-icon-voicechat',
        checked= Save.setPlayerSound,
        colorCode= (not C_CVar.GetCVarBool('Sound_EnableAllSound') or C_CVar.GetCVar('Sound_MasterVolume')=='0') and '|cff606060',
        func= function()
            Save.setPlayerSound= not Save.setPlayerSound and true or nil
            e.setPlayerSound= Save.setPlayerSound
            if Save.setPlayerSound then
                e.PlaySound()--播放, 声音
            end
            set_START_TIMER_Event()--事件, 声音
            print(id, addName, e.onlyChinese and "播放" or SLASH_STOPWATCH_PARAM_PLAY1, e.onlyChinese and '事件声音' or EVENTS_LABEL..SOUND)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '欢迎加入' or (EMOTE103_CMD1:gsub('/','')..JOIN),
        checked= Save.guildWelcome or Save.groupWelcome,
        func=function()
            Save.guildWelcome=nil
            Save.groupWelcome=nil
            set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
        end,
        menuList='Welcome',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= '|cffff00ffETR|rACE',
        icon= 'minimap-genericevent-hornicon',
        checked= IsAddOnLoaded("Blizzard_EventTrace") and EventTrace:IsShown(),
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '事件记录' or EVENTTRACE_HEADER,
        func= function()
            if not IsAddOnLoaded('Blizzard_EventTrace') then
                UIParentLoadAddOn("Blizzard_EventTrace")
            else
                EventTrace:SetShown(not EventTrace:IsShown() and true or false)
            end
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= '|cff00ff00FST|rACK',
        icon= 'QuestLegendaryTurnin',
        checked= IsAddOnLoaded("Blizzard_DebugTools") and FrameStackTooltip_IsFramestackEnabled(),--Blizzard_DebugTools.lua
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '框架栈' or DEBUG_FRAMESTACK,
        tooltipText='|cnGREEN_FONT_COLOR:Alt|r '..(e.onlyChinese and '切换' or HUD_EDIT_MODE_SWITCH)
                    ..'\n|cnGREEN_FONT_COLOR:Ctrl|r '..(e.onlyChinese and '显示' or SHOW)
                    ..'\n|cnGREEN_FONT_COLOR:Shift|r '..(e.onlyChinese and '材质信息' or TEXTURES_SUBHEADER..INFO)
                    ..'\n|cnGREEN_FONT_COLOR:Ctrl+C|r '.. (e.onlyChinese and '复制' or CALENDAR_COPY_EVENT)..' \"File\" '..(e.onlyChinese and '类型' or TYPE),
        func= function()--Bindings.xml
            if not IsAddOnLoaded("Blizzard_DebugTools") then
                LoadAddOn("Blizzard_DebugTools")
            end
            FrameStackTooltip_ToggleDefaults()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    --e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={--重载
        text= e.onlyChinese and '重新加载UI' or RELOADUI,
        notCheckable=true,
        tooltipOnButton=true,
        tooltipTitle='/reload',
        colorCode='|cffff0000',
        func=function()
            e.Reload()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end

DEFAULT_CHAT_FRAME.ADD=DEFAULT_CHAT_FRAME.AddMessage

--####
--初始
--####
local function Init()
    button:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')

    WoWToolsChatButtonFrame.last=button
    button.texture:SetAtlas(e.Icon.icon)

    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            setFunc()--使用，禁用
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)

    if not Save.disabed then--使用，禁用
        setUseDisabled()
    else
        button.texture:SetDesaturated(true)
    end

    setPanel()--设置控制面板
    set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员


    showTimestamps= C_CVar.GetCVar("showTimestamps")~='none' and true or nil

    if Save.setPlayerSound then
        set_START_TIMER_Event()--事件, 声音
    end

    LFGListInviteDialog:SetScript("OnShow", function(self)--队伍查找器, 接受邀请
        if Save.setPlayerSound then
            e.PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
        end
        e.Ccool(self, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条
        local status, _, _, role= select(2,C_LFGList.GetApplicationInfo(self.resultID))
        if status=="invited" then
            local info= C_LFGList.GetSearchResultInfo(self.resultID)
            if self.AcceptButton and self.AcceptButton:IsEnabled() and info then
                print(id, addName,
                    info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and '|T4352494:0|t'..e.GetKeystoneScorsoColor(info.leaderOverallDungeonScore) or '',--地下城史诗,分数
                    info.leaderPvpRatingInfo and  info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 and '|A:pvptalents-warmode-swords:0:0|a|cnRED_FONT_COLOR:'..info.leaderPvpRatingInfo.rating..'|r' or '',--PVP 分数
                    info.leaderName and (e.onlyChinese and '%s邀请你加入' or COMMUNITY_INVITATION_FRAME_INVITATION_TEXT):format(e.PlayerLink(info.leaderName)..' ') or '',--	%s邀请你加入
                    info.name and info.name or '',--名称
                    e.Icon[role] or '',
                    info.numMembers and (e.onlyChinese and '队员' or PLAYERS_IN_GROUP)..'|cff00ff00 '..info.numMembers..'|r' or '',--队伍成员数量
                    info.autoAccept and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '自动邀请' or AUTO_JOIN:gsub(JOIN,INVITE))..'|r' or '',--对方是否开启, 自动邀请
                    info.activityID and '|cffff00ff'..C_LFGList.GetActivityFullName(info.activityID)..'|r' or '',--查找器,类型
                    info.isWarMode~=nil and info.isWarMode ~= C_PvP.IsWarModeDesired() and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '战争模式' or TALENT_FRAME_LABEL_WARMODE)..'|r' or ''
                )
            end
        end
    end)
end

--###########
--加载保存数据
--###########

panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" then
        if arg1 == id then
            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                Save= WoWToolsSave[addName] or Save
                Save.Cvar= Save.Cvar or {}
                e.setPlayerSound= Save.setPlayerSound--播放, 声音

                button=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

                Init()
                panel:RegisterEvent('CVAR_UPDATE')
                panel:RegisterEvent("PLAYER_LOGOUT")
            end
            --panel:UnregisterEvent('ADDON_LOADED')

        elseif arg1=='Blizzard_DebugTools' then--FSTACK Blizzard_DebugTools.lua
            local btn= e.Cbtn(TableAttributeDisplay, {icon='hide', size={40,40}})
            btn:SetPoint("BOTTOMRIGHT", TableAttributeDisplay.TitleButton, 'TOPRIGHT',0,2)
            btn:SetNormalAtlas(e.Icon.icon)
            btn:SetScript('OnClick', FrameStackTooltip_ToggleDefaults)

            local edit= CreateFrame("EditBox", nil, TableAttributeDisplay, 'InputBoxTemplate')
            edit:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMLEFT')
            edit:SetSize(390, 20)
            edit:SetAutoFocus(false)
            edit:ClearFocus()
            edit.elapsed= 0
            edit:SetScript('OnUpdate', function(self2, elapsed)
                    self2.elapsed= self2.elapsed +elapsed
                    if self2.elapsed>0.3 then
                        if not self2:HasFocus() then
                            local text = TableAttributeDisplay.TitleButton.Text:GetText()
                            if text and text~='' then
                                edit:SetText(text:match('%- (.+)') or text)
                            end
                        end
                    end
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    elseif event=='CHAT_MSG_SYSTEM' then
        setMsg_CHAT_MSG_SYSTEM(arg1)--欢迎加入, 信息

    elseif event=='CVAR_UPDATE' then
        if arg1=='showTimestamps' then
            showTimestamps= arg2~='none' and true or nil
        end

    elseif event=='START_TIMER' then--播放, 声音
        if arg2==0 and arg3==0 then
            button.timerType= nil
            if button.timer4 then button.timer4:Cancel() end
            if button.timer3 then button.timer3:Cancel() end
            if button.timer2 then button.timer2:Cancel() end
            if button.timer1 then button.timer1:Cancel() end
            if button.timer0 then button.timer0:Cancel() end

        elseif arg1 and arg2 and arg2>3 and not button.timerType then
            button.timerType=arg1
            if arg2>20 then
                button.timer4= C_Timer.NewTimer(arg2-10, function()--3
                    e.PlaySound()
                end)
            elseif arg2>=7 then
                e.PlaySound()
            end
            button.timer3= C_Timer.NewTimer(arg2-3, function()--3
                e.PlaySound(115003)
            end)
            button.timer2= C_Timer.NewTimer(arg2-2, function()--2
                e.PlaySound(115003)
            end)
            button.timer1= C_Timer.NewTimer(arg2-1, function()--1
                e.PlaySound(115003)
            end)
            button.timer0= C_Timer.NewTimer(arg2, function()--0
                e.PlaySound(114995 )--63971)
                button.timerType=nil
            end)
        end
    elseif event=='STOP_TIMER_OF_TYPE' then
        button.timerType= nil
        if button.timer4 then button.timer4:Cancel() end
        if button.timer3 then button.timer3:Cancel() end
        if button.timer2 then button.timer2:Cancel() end
        if button.timer1 then button.timer1:Cancel() end
        if button.timer0 then button.timer0:Cancel() end
	end
end)
