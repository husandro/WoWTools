local id, e = ...
local addName = format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL)
local Save={
    --disabed=true, --使用，禁用
    --notShowPlayerInfo=true,--不处理，玩家信息

    channels={--频道名称替换 
        --['世界'] = '[世]',
    },
    text={--内容颜色,
        [ACHIEVEMENTS]=true,
    },
    --disabledKeyColor= true,--禁用，内容颜色，和频道名称替换

    groupWelcome= e.Player.husandro,--欢迎
    --groupWelcomeText= e.Player.cn and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}',

    guildWelcome= e.Player.husandro,
    --guildWelcomeText= e.Player.cn and '宝贝，欢迎你加入' or EMOTE103_CMD1:gsub('/',''),

    welcomeOnlyHomeGroup=true,--仅限, 手动组队

    setPlayerSound= e.Player.husandro,--播放, 声音

    --disabledNPCTalking=true,--禁用，隐藏NPC发言    
    --disabledTalkingPringText=true,--禁用，隐藏NPC发言，文本

    --not_Add_Reload_Button=true,--添加 RELOAD 按钮
}
local button
local panel= CreateFrame("Frame")
DEFAULT_CHAT_FRAME.ADD= DEFAULT_CHAT_FRAME.AddMessage

local not_Colleced_Icon='|A:questlegendary:0:0|a'

local LOOT_ITEM= e.Magic(LOOT_ITEM)--:gsub('%%s', '(.+)')--%s获得了战利品：%s。


local function SetChannels(link)
    local name=link:match('%[(.-)]')
    if name then
        if name:find(WORLD) then
            return link:gsub('%[.-]', '['..e.WA_Utf8Sub(WORLD, 2, 5)..']')
        end

        if not Save.disabledKeyColor then
            for k, v in pairs(Save.channels) do--自定义
                if name:find(k) then
                    return link:gsub('%[.-]', v)
                end
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
        return e.Icon.toRight2..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r'..e.Icon.toLeft2
    else
        local text= e.GetPlayerInfo({name=name})
        if server then
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
    local itemID= link:match('Hitem:(%d+)')
    local t=link
    local icon, classID, subclassID= select(5, C_Item.GetItemInfoInstant(itemID))
    t= icon and '|T'..icon..':0|t'..t or t--加图标
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
        t= PlayerHasToy(itemID) and (t..e.Icon.select2) or (t..'|A:questlegendary:0:0|a')
    end
    local bag= C_Item.GetItemCount(link, true, false, true)--数量
    if bag and bag>0 then
        t=t..e.Icon.bag2..e.MK(bag, 3)
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
            nu=e.MK(info.quantity, 3)
            if (info.quantity==info.maxQuantity--最大数
                or (info.canEarnPerWeek and info.maxWeeklyQuantity==info.quantityEarnedThisWeek)--本周
                or (info.useTotalEarnedForMaxQty and info.totalEarned==info.maxQuantity)--赛季
            ) then
                nu= '|cnRED_FONT_COLOR:'..nu..'|r'
            end
        end
        return  '|T'..info.iconFileID..':0|t'..link..nu
    end
end

local function Achievement(link)--成就
    local id2=link:match('Hachievement:(%d+)')
    if id2 then
        local _, _, _, completed, _, _, _, _, _, icon = GetAchievementInfo(id2)
        local texture=icon and '|T'..icon..':0|t' or ''
        return texture..link..(completed and e.Icon.select2 or '|A:questlegendary:0:0|a')
    end
end

local function Quest(link)--任务
    local id2=link:match('Hquest:(%d+)')
    if id2 then
        local wow= C_QuestLog.IsAccountQuest(id2) and e.Icon.wow2 or ''--帐号通用        
        if C_QuestLog.IsQuestFlaggedCompleted(id2) then
            return wow..link..e.Icon.select2
        else
            return wow..link..'|A:questlegendary:0:0|a'
        end
    end
end

--[[local function Talent(link)--天赋
    local id2=link:match('Htalent:(%d+)')
    if id2 then
        local _, _, icon, _, _, _, _, _ ,_, known=GetTalentInfoByID(id2)
        if icon then
            return '|T'..icon..':0|t'..link..(known and e.Icon.select2 or '|A:questlegendary:0:0|a')
        end
    end
end]]

local function Pvptal(link)--pvp天赋
    local id2=link:match('Hpvptal:(%d+)')
    if id2 then
        local _, _, icon, _, _, _, _, _ ,_, known=GetPvpTalentInfoByID(id2)
        return '|T'..icon..':0|t'..link..(known and e.Icon.select2 or '|A:questlegendary:0:0|a')
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
            local icon='|A:transmog-icon-hidden:0:0|a'
            if info.isCollected and info.isUsable then
                icon='|T132288:0|t'
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
            return link..'|A:questlegendary:0:0|a'
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
    local t=e.GetPlayerInfo({guid=guid})..e.GetKeystoneScorsoColor(score)
    t=t..link
    if itemLv and itemLv~='0' then
        t=t..'|A:charactercreate-icon-customize-body-selected:0:0|a'..itemLv
    end
    return t
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
    local t=e.GetPlayerInfo({guid=guid})..link
    if DifficultyID and InstanceID then
        local name= GetDifficultyInfo(DifficultyID)
        if name then
            t=t..'|Hjournal:0:'..InstanceID..':'..DifficultyID..'|h['..name..']|h'
        end
    end
   return t
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
        s=s:gsub('|Hplayer:.-]|h', Realm)

        if not showTimestamps and s:find(LOOT_ITEM) then--	%s获得了战利品：%s。
            local unitName= s:match(LOOT_ITEM)
            if unitName then
                if unitName==e.Player.name then
                    s=s:gsub(unitName..'['..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..'|r]')
                else
                    s=s:gsub(e.Magic(unitName), e.PlayerLink(unitName))
                end
            end
        end
    end

    if not Save.disabledKeyColor then
        for k, _ in pairs(Save.text) do--内容加颜色
            s=s:gsub(k, '|cnGREEN_FONT_COLOR:'..k..'|r')
        end
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

    button.texture:SetAtlas(not Save.disabed and e.Icon.icon or e.Icon.disabled)
end
local function setFunc()--使用，禁用
    Save.disabed= not Save.disabed and true or nil
    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabed))
    setUseDisabled()
end




--###########
--设置控制面板
--###########
--local Category, Layout
local function Init_Panel()
    --Category, Layout= e.AddPanel_Sub_Category({name= e.cn(addName), frame= panel})
    e.AddPanel_Sub_Category({name=e.onlyChinese and '超链接图标' or e.cn(addName), frame=panel})

    local function Cedit(self)
        local frame= CreateFrame('Frame',nil, self, 'ScrollingEditBoxTemplate')--ScrollTemplates.lua
        frame:SetPoint('CENTER')
        frame:SetSize(500,250)
        frame.texture= frame:CreateTexture(nil, "BACKGROUND")
        frame.texture:SetAllPoints(frame)
        frame.texture:SetAtlas('CreditsScreen-Background-0')
        frame.texture:SetAlpha(0.3)

        return frame
    end

    local str=e.Cstr(panel)--内容加颜色
    str:SetPoint('TOPLEFT')
    str:SetText(e.onlyChinese and '颜色: 关键词 (|cnGREEN_FONT_COLOR:空格|r) 分开' or (COLOR..': '..KBASE_DEFAULT_SEARCH_TEXT..'|cnGREEN_FONT_COLOR:( '..KEY_SPACE..' )|r'))
    local editBox=Cedit(panel)
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
            s:gsub('.- ', function(t)
                t=t:gsub(' ','')
                if t and t~='' then
                    t=e.Magic(t)
                    Save.text[t]=true
                    n=n+1
                    print(n..')'..COLOR, t)
                end
            end)
        end
        print(id, e.cn(addName), e.onlyChinese and '颜色' or COLOR, '|cnGREEN_FONT_COLOR:#'..n..(e.onlyChinese and '完成' or COMPLETE)..'|r', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local str2=e.Cstr(panel)--频道名称替换
    str2:SetPoint('TOPLEFT', editBox, 'BOTTOMLEFT', 0,-20)
    str2:SetText(e.onlyChinese and '频道名称替换: 关键词|cnGREEN_FONT_COLOR:=|r替换' or (CHANNEL_CHANNEL_NAME..': '..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL..'  |cnGREEN_FONT_COLOR:= |r'))
    local editBox2=Cedit(panel)
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
            s:gsub('.-=.- ', function(t)
                local name,name2=t:match('(.-)=(.-) ')
                if name and name2 and name~='' and name2~='' then
                    name=e.Magic(name)
                    Save.channels[name]=name2
                    n=n+1
                    print(n..')'..(e.onlyChinese and '频道' or CHANNELS)..': ',name, e.onlyChinese and '替换' or REPLACE, name2)
                end
            end)
        end
        print(id, e.cn(addName), e.onlyChinese and '频道名称替换' or (CHANNEL_CHANNEL_NAME..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL), '|cnGREEN_FONT_COLOR:#'..n..(e.onlyChinese and '完成' or COMPLETE)..'|r',  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
end



















--#############
--欢迎加入, 信息
--#############
local function set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    if (Save.guildWelcome and IsInGuild() ) or Save.groupWelcome then
        panel:RegisterEvent('CHAT_MSG_SYSTEM')
    else
        panel:UnregisterEvent('CHAT_MSG_SYSTEM')
    end
end

local raidMS=ERR_RAID_MEMBER_ADDED_S:gsub("%%s", "(.+)")--%s加入了团队。
local partyMS= JOINED_PARTY:gsub("%%s", "(.+)")--%s加入了队伍。
local guildMS= ERR_GUILD_JOIN_S:gsub("%%s", "(.+)")--加入了公会

local function setMsg_CHAT_MSG_SYSTEM(text)--欢迎加入, 信息
    if not text then
        return
    end
    if text:find(raidMS) or text:find(partyMS) then
        if Save.groupWelcome and UnitIsGroupLeader('player') and (Save.welcomeOnlyHomeGroup and IsInGroup(LE_PARTY_CATEGORY_HOME) or not Save.welcomeOnlyHomeGroup) then
            local name=text:match(raidMS) or text:match(partyMS)
            if name then
                e.Chat(Save.groupWelcomeText or EMOTE103_CMD1:gsub('/',''), name, nil)
            end
        end
    elseif text:find(guildMS) then
        if Save.guildWelcome and IsInGuild() then
            local name=text:match(guildMS)
            if name then
                C_Timer.After(2, function()
                    SendChatMessage(Save.guildWelcomeText..' '.. name.. ' ' ..GUILD_INVITE_JOIN, "GUILD");
                end)
            end
        end
    end
end












--添加 RELOAD 按钮
local function Init_Add_Reload_Button()
    if Save.not_Add_Reload_Button or GameMenuFrame.reload then
        if GameMenuFrame.reload then
            GameMenuFrame.reload:SetShown(not Save.not_Add_Reload_Button)
            SettingsPanel.AddOnsTab.reload:SetShown(not Save.not_Add_Reload_Button)
        end
        return
    end
    for _, frame in pairs({GameMenuFrame, SettingsPanel.AddOnsTab}) do
        frame.reload= CreateFrame('Button', nil, frame, 'GameMenuButtonTemplate')
        frame.reload:SetFormattedText('%s|A:characterundelete-RestoreButton:0:0|a',e.onlyChinese and '重新加载UI' or RELOADUI)
--|TInterface\\Vehicles\\UI-Vehicles-Button-Exit-Up:0|t
        frame.reload:SetScript('OnLeave', GameTooltip_Hide)
        frame.reload:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, 'Tools '..e.cn(addName))
            e.tips:AddDoubleLine(e.onlyChinese and '重新加载UI' or RELOADUI, '|cnGREEN_FONT_COLOR:'..SLASH_RELOAD1)
            e.tips:Show()
        end)
        frame.reload:SetScript('OnClick', e.Reload)
    end

    GameMenuFrame.reload:SetPoint('TOP', GameMenuButtonQuit, 'BOTTOM', 0, -2)

    --GameMenuFrame.reload:SetPoint('TOP', GameMenuButtonContinue, 'BOTTOM', 0, -20)

    hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', function(self)
        if not Save.not_Add_Reload_Button then
            GameMenuButtonContinue:ClearAllPoints()
            GameMenuButtonContinue:SetPoint('TOP', GameMenuFrame.reload, 'BOTTOM', 0, -16)
            self:SetHeight(self:GetHeight()+ 16)
        end
    end)

    SettingsPanel.AddOnsTab.reload:SetPoint('RIGHT', SettingsPanel.ApplyButton, 'LEFT', -15,0)
    e.Cstr(nil, {changeFont= SettingsPanel.OutputText, size=14})
    SettingsPanel.OutputText:ClearAllPoints()
    SettingsPanel.OutputText:SetPoint('BOTTOMLEFT', 20, 18)


end













--##########
--隐藏NPC发言
--##########
local function set_Talking()
    if Save.disabledNPCTalking then
        if panel.talkingFrame then
            panel:UnregisterAllEvents()
        end
        return
    end

    if not panel.talkingFrame then
        panel.talkingFrame= CreateFrame("Frame", nil, panel)
        panel.talkingFrame:SetScript('OnEvent', function(self)
            local _, _, vo, _, _, _, name, text = C_TalkingHead.GetCurrentLineInfo()
            TalkingHeadFrame:CloseImmediately()
            if vo and vo>0 then
                if ( self.voHandle ) then
                    StopSound(self.voHandle);
                    self.voHandle = nil;
                end
                local success, voHandle = e.PlaySound(vo, true)--PlaySound(vo, "Talking Head", true, true);
                if ( success ) then
                    self.voHandle = voHandle;
                end
                if not Save.disabledTalkingPringText and text then
                    print('|cff00ff00'..name..'|r','|cffff00ff'..text..'|r',id, e.cn(addName), 'soundKitID', vo)
                end
            end
        end)
    end
    panel.talkingFrame:RegisterEvent('TALKINGHEAD_REQUESTED')
end












--#########
--事件, 声音
--#########
local function set_START_TIMER_Event()--事件, 声音
    if Save.setPlayerSound then
        panel:RegisterEvent('START_TIMER')
        panel:RegisterEvent('STOP_TIMER_OF_TYPE')
        if not C_CVar.GetCVarBool('Sound_EnableAllSound') then
            C_CVar.SetCVar('Sound_EnableAllSound', '1')
            print(id, e.cn(addName), '|cnGREEN_FONT_COLOR:CVar Sound_EnableAllSound|r', e.onlyChinese and '开启声效' or ENABLE_SOUND)
        end
        if C_CVar.GetCVar('Sound_MasterVolume')=='0' then
            C_CVar.SetCVar('Sound_MasterVolume', '1.0')
            print(id, e.cn(addName), '|cnGREEN_FONT_COLOR:CVar Sound_MasterVolume|r', e.onlyChinese and '主音量' or MASTER_VOLUME, '1')
        end

        if C_CVar.GetCVar('Sound_DialogVolume')=='0' then
            C_CVar.SetCVar('Sound_DialogVolume', '1.0')
            print(id, e.cn(addName), '|cnGREEN_FONT_COLOR:CVar Sound_DialogVolume|r',e.onlyChinese and '对话' or DIALOG_VOLUME, '1')
        end
        if not C_CVar.GetCVarBool('Sound_EnableDialog') then
            C_CVar.SetCVar('Sound_EnableDialog', '1')
            print(id, e.cn(addName), '|cnGREEN_FONT_COLOR:CVar Sound_EnableDialog|r', e.onlyChinese and '启用对话' or ENABLE_DIALOG)
        end
        if not button.setPlayerSoundTips then
            button.setPlayerSoundTips= button:CreateTexture(nil,'OVERLAY')
            button.setPlayerSoundTips:SetPoint('BOTTOMLEFT',4, 4)
            button.setPlayerSoundTips:SetSize(12,12)
            button.setPlayerSoundTips:SetAtlas('chatframe-button-icon-voicechat')
        end

    else
        panel:UnregisterEvent('START_TIMER')
        panel:UnregisterEvent('STOP_TIMER_OF_TYPE')
    end
    if button.setPlayerSoundTips then
        button.setPlayerSoundTips:SetShown(Save.setPlayerSound)
    end
end













--#####
--主菜单
--#####
local function InitMenu(_, level, menuList)
    local info
    if menuList=='modifyGuildWelcomeText' then--三级
        info={
            text= e.onlyChinese and '修改' or EDIT,--公会新成员
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle=Save.guildWelcomeText,
            keepShownOnClick=true,
            func=function()
                StaticPopupDialogs[id..addName..'modifyGuildWelcome']={--区域,设置对话框
                    text=id..' '..addName..'|n|n'..(e.onlyChinese and '欢迎加入' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,  EMOTE103_CMD1:gsub('/',''), JOIN))..'|n'..(e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER),
                    whileDead=true, hideOnEscape=true, exclusive=true,
                    hasEditBox=true,
                    button1= e.onlyChinese and '修改' or EDIT,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    OnShow = function(self)
                        self.editBox:SetText(Save.guildWelcomeText)
                    end,
                    OnAccept = function(self)
                        local text= self.editBox:GetText()
                        Save.guildWelcomeText= text
                        print(id,e.cn(addName), text)
                    end,
                    EditBoxOnTextChanged=function(self)
                        local text= self:GetText() or ''
                        self:GetParent().button1:SetEnabled(text:gsub(' ', '')~='')
                    end,
                    EditBoxOnEscapePressed = function(self2)
                        self2:SetAutoFocus(false)
                        self2:ClearFocus()
                        self2:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'modifyGuildWelcome')
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    elseif menuList=='modifyGroupWelcomeText' then--三级
        info={
            text= e.onlyChinese and '修改' or EDIT,--公会新成员
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle=Save.groupWelcomeText,
            keepShownOnClick=true,
            func=function()
                StaticPopupDialogs[id..addName..'modifyGroupWelcome']={--区域,设置对话框
                    text=id..' '..addName..'|n|n'..(e.onlyChinese and '欢迎加入' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,  EMOTE103_CMD1:gsub('/',''), JOIN))..'|n'..(e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER),
                    whileDead=true, hideOnEscape=true, exclusive=true,
                    hasEditBox=true,
                    button1= e.onlyChinese and '修改' or EDIT,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    OnShow = function(self)
                        self.editBox:SetText(Save.groupWelcomeText)
                    end,
                    OnAccept = function(self)
                        local text= self.editBox:GetText()
                        Save.groupWelcomeText= text
                        e.Chat(text, e.Player.name, nil)
                    end,
                    EditBoxOnTextChanged=function(self)
                        local text= self:GetText() or ''
                        self:GetParent().button1:SetEnabled(text:gsub(' ', '')~='')
                    end,
                    EditBoxOnEscapePressed = function(self2)
                        self2:SetAutoFocus(false)
                        self2:ClearFocus()
                        self2:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'modifyGroupWelcome')
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='Welcome' then--欢迎
        info={
            text= e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER,--公会新成员
            checked= Save.guildWelcome,
            tooltipOnButton=true,
            tooltipTitle= Save.guildWelcomeText,
            tooltipText= not IsInGuild() and e.onlyChinese and '你现在没有加入任何一个公会' or ERR_GUILD_PLAYER_NOT_IN_GUILD or nil,
            colorCode= (not IsInGuild() or not Save.guildWelcomeText)  and '|cff606060' or nil,--不在公会
            keepShownOnClick=true,
            hasArrow=true,
            menuList='modifyGuildWelcomeText',
            func=function()
                Save.guildWelcome= not Save.guildWelcome and true or nil
                set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC,--队伍新成员
            checked= Save.groupWelcome,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '仅限队长或团长' or format(LFG_LIST_CROSS_FACTION, LEADER ),
            tooltipText=Save.groupWelcomeText,
            keepShownOnClick=true,
            hasArrow=true,
            menuList='modifyGroupWelcomeText',
            func=function()
                Save.groupWelcome= not Save.groupWelcome and true or nil
                set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={--仅限, 手动组队,不是在随机队伍里
            text= e.onlyChinese and format('仅限%s', '组队邀请') or LFG_LIST_CROSS_FACTION:format(GROUP_INVITE),
            checked= Save.welcomeOnlyHomeGroup,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '随机' or LFG_TYPE_RANDOM_DUNGEON,
            tooltipText= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '不是' or NO),
            keepShownOnClick=true,
            func= function()
                Save.welcomeOnlyHomeGroup= not Save.welcomeOnlyHomeGroup and true or nil

            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='NPCTalkingText' then--3级，菜单
        info={
            text= e.onlyChinese and '文本' or LOCALE_TEXT_LABEL,
            checked= not Save.disabledTalkingPringText,
            --disabled= Save.disabledNPCTalking,
            keepShownOnClick=true,
            func= function()
                Save.disabledTalkingPringText= not Save.disabledTalkingPringText and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)


    elseif menuList=='NPCTalking' then--禁用，隐藏NPC发言
        info={--仅限, 手动组队,不是在随机队伍里
            text= e.onlyChinese and '隐藏NPC发言' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, ' (NPC) '..VOICE_TALKING),
            checked= not Save.disabledNPCTalking,
            tooltipOnButton=true,
            --disabled= not Save.setPlayerSound,
            tooltipTitle= e.onlyChinese and '隐藏对话特写头像' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL),
            keepShownOnClick=true,
            hasArrow=true,
            menuList='NPCTalkingText',
            func= function()
                Save.disabledNPCTalking= not Save.disabledNPCTalking and true or nil
                set_Talking()--隐藏NPC发言
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='KeyColorSettings' then--3级
        info={
            text= e.onlyChinese and '设置' or SETTINGS,
            notCheckable=true,
            keepShownOnClick=true,
            func= function() e.OpenPanelOpting() end,--nil, e.onlyChinese and '超链接图标' or addName) end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='KeyColor' then--内容颜色，和频道名称替换
        info={
            text= e.Player.L.key,--关键词
            checked= not Save.disabledKeyColor,
            colorCode= Save.disabed and '|cff606060' or nil,
            keepShownOnClick=true,
            hasArrow=true,
            menuList='KeyColorSettings',
            func=function()
                Save.disabledKeyColor= not Save.disabledKeyColor and true or nil
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info= {
            text= e.onlyChinese and '玩家信息' or PLAYER_MESSAGES,
            checked= not Save.notShowPlayerInfo,
            func= function()
                Save.notShowPlayerInfo= not Save.notShowPlayerInfo and true or nil
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif menuList=='RELOAD_BUTTON' then
        info= {
            text= e.onlyChinese and '添加按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, 'Button'),
            checked= not Save.not_Add_Reload_Button,
            tooltipOnButton=true,
            tooltipTitle=e.onlyChinese and '主菜单|n选项' or format('%s|n%s', MAINMENU_BUTTON, OPTIONS),
            func= function()
                Save.not_Add_Reload_Button= not Save.not_Add_Reload_Button and true or nil
                Init_Add_Reload_Button()
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    if menuList then
        return
    end

    info={
        text= '|A:newplayertutorial-icon-mouse-leftbutton:0:0|a'..(e.onlyChinese and '超链接图标'or addName),
        checked=not Save.disabed,
        keepShownOnClick=true,
        hasArrow=true,
        menuList='KeyColor',
        func=function()
            setFunc()--使用，禁用
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={--文本转语音
        text= '|A:chatframe-button-icon-TTS:0:0|a'..(e.onlyChinese and '文本转语音' or TEXT_TO_SPEECH),
        checked= C_CVar.GetCVarBool('textToSpeech'),
        disabled= UnitAffectingCombat('player'),
        tooltipOnButton=true,
        tooltipTitle='CVar: textToSpeech',
        keepShownOnClick=true,
        func=function()
            C_CVar.SetCVar("textToSpeech", not C_CVar.GetCVarBool('textToSpeech') and '1' or '0' )
            print(id, e.cn(addName), e.onlyChinese and '文本转语音' or TEXT_TO_SPEECH..': '..e.GetEnabeleDisable(C_CVar.GetCVarBool('textToSpeech')))
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= '|A:chatframe-button-icon-voicechat:0:0|a'..(e.onlyChinese and '事件声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTS_LABEL, SOUND)),
        checked= Save.setPlayerSound,
        colorCode= (
            not C_CVar.GetCVarBool('Sound_EnableAllSound')
            or C_CVar.GetCVar('Sound_MasterVolume')=='0'
            or C_CVar.GetCVar('Sound_DialogVolume')=='0'
            or not C_CVar.GetCVarBool('Sound_EnableDialog')
        ) and '|cff606060',
        tooltipOnButton=true,
        tooltipTitle= e.Get_CVar_Tooltips({name='Sound_EnableAllSound', msg=e.onlyChinese and '开启声效' or ENABLE_SOUND})..'|n|n'
                ..e.Get_CVar_Tooltips({name='Sound_MasterVolume', msg=e.onlyChinese and '主音量' or MASTER_VOLUME})..'|n|n'
                ..e.Get_CVar_Tooltips({name='Sound_DialogVolume', msg=e.onlyChinese and '对话' or DIALOG_VOLUME})..'|n|n'
                ..e.Get_CVar_Tooltips({name='Sound_EnableDialog', msg=e.onlyChinese and '启用对话' or ENABLE_DIALOG }),
        --keepShownOnClick=true,
        hasArrow=true,
        menuList='NPCTalking',
        disabled= UnitAffectingCombat('player'),
        func= function()
            Save.setPlayerSound= not Save.setPlayerSound and true or nil
            e.setPlayerSound= Save.setPlayerSound
            if Save.setPlayerSound then
                e.PlaySound()--播放, 声音
            end
            set_START_TIMER_Event()--事件, 声音
            set_Talking()--隐藏NPC发言
            print(id, e.cn(addName), e.onlyChinese and "播放" or SLASH_STOPWATCH_PARAM_PLAY1, e.onlyChinese and '事件声音' or EVENTS_LABEL..SOUND)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '欢迎加入' or (EMOTE103_CMD1:gsub('/','')..JOIN),
        checked= Save.guildWelcome or Save.groupWelcome,
        keepShownOnClick=true,
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
        text= '|A:minimap-genericevent-hornicon:0:0|a|cffff00ffETR|rACE',
        checked= C_AddOns.IsAddOnLoaded("Blizzard_EventTrace") and EventTrace:IsShown(),
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '事件记录' or EVENTTRACE_HEADER,
        keepShownOnClick=true,
        func= function()
            if not C_AddOns.IsAddOnLoaded('Blizzard_EventTrace') then
                C_AddOns.LoadAddOn("Blizzard_EventTrace")
            else
                EventTrace:SetShown(not EventTrace:IsShown() and true or false)
            end
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)


    info={
        text= '|A:QuestLegendaryTurnin:0:0|a|cff00ff00FST|rACK',
        checked= C_AddOns.IsAddOnLoaded("Blizzard_DebugTools") and FrameStackTooltip_IsFramestackEnabled(),--Blizzard_DebugTools.lua
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '框架栈' or DEBUG_FRAMESTACK,
        tooltipText='|cnGREEN_FONT_COLOR:Alt|r '..(e.onlyChinese and '切换' or HUD_EDIT_MODE_SWITCH)
                    ..'|n|cnGREEN_FONT_COLOR:Ctrl|r '..(e.onlyChinese and '显示' or SHOW)
                    ..'|n|cnGREEN_FONT_COLOR:Shift|r '..(e.onlyChinese and '材质信息' or TEXTURES_SUBHEADER..INFO)
                    ..'|n|cnGREEN_FONT_COLOR:Ctrl+C|r '.. (e.onlyChinese and '复制' or CALENDAR_COPY_EVENT)..' \"File\" '..(e.onlyChinese and '类型' or TYPE),
        keepShownOnClick=true,
        func= function()--Bindings.xml
            if not C_AddOns.IsAddOnLoaded("Blizzard_DebugTools") then
                C_AddOns.LoadAddOn("Blizzard_DebugTools")
            end
            FrameStackTooltip_ToggleDefaults()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    --e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={--重载
        text= '|TInterface\\Vehicles\\UI-Vehicles-Button-Exit-Up:0|t'..(e.onlyChinese and '重新加载UI' or RELOADUI),
        notCheckable=true,
        tooltipOnButton=true,
        tooltipTitle= SLASH_RELOAD1,-- '/reload',
        colorCode='|cffff0000',
        keepShownOnClick=true,
        hasArrow=true,
        menuList='RELOAD_BUTTON',
        func= e.Reload,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end













--####
--初始
--####
local function Init()
    button= e.Cbtn2({
        name=nil,
        parent=WoWToolsChatButtonFrame,
        click=true,-- right left
        notSecureActionButton=true,
        notTexture=nil,
        showTexture=true,
        sizi=nil,
    })

    button:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')

    WoWToolsChatButtonFrame.last=button
    button.texture:SetAtlas(e.Icon.icon)


    button:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            setFunc()--使用，禁用
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)

    if not Save.disabed then--使用，禁用
        setUseDisabled()
    else
        button.texture:SetAtlas(not Save.disabed and e.Icon.icon or e.Icon.disabled)
    end

    set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员

    showTimestamps= C_CVar.GetCVar("showTimestamps")~='none' and true or nil

    set_START_TIMER_Event()--事件, 声音


    LFGListInviteDialog:SetScript("OnShow", function(self)--队伍查找器, 接受邀请
        if Save.setPlayerSound then
            e.PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
        end
        e.Ccool(self, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条
        local status, _, _, role= select(2,C_LFGList.GetApplicationInfo(self.resultID))
        if status=="invited" then
            local info= C_LFGList.GetSearchResultInfo(self.resultID)
            if self.AcceptButton and self.AcceptButton:IsEnabled() and info then
                print(id, e.cn(addName),
                    info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and '|T4352494:0|t'..e.GetKeystoneScorsoColor(info.leaderOverallDungeonScore) or '',--地下城史诗,分数
                    info.leaderPvpRatingInfo and  info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 and '|A:pvptalents-warmode-swords:0:0|a|cnRED_FONT_COLOR:'..info.leaderPvpRatingInfo.rating..'|r' or '',--PVP 分数
                    info.leaderName and (e.onlyChinese and '%s邀请你加入' or COMMUNITY_INVITATION_FRAME_INVITATION_TEXT):format(e.PlayerLink(info.leaderName)..' ') or '',--	%s邀请你加入
                    info.name and info.name or '',--名称
                    e.Icon[role] or '',
                    info.numMembers and (e.onlyChinese and '队员' or PLAYERS_IN_GROUP)..'|cff00ff00 '..info.numMembers..'|r' or '',--队伍成员数量
                    info.autoAccept and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '自动邀请' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, INVITE))..'|r' or '',--对方是否开启, 自动邀请
                    info.activityID and '|cffff00ff'..C_LFGList.GetActivityFullName(info.activityID)..'|r' or '',--查找器,类型
                    info.isWarMode~=nil and info.isWarMode ~= C_PvP.IsWarModeDesired() and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '战争模式' or TALENT_FRAME_LABEL_WARMODE)..'|r' or ''
                )
            end
        end
    end)


    set_Talking()--隐藏NPC发言

    Init_Add_Reload_Button()--添加 RELOAD 按钮
end










--###########
--加载保存数据
--###########
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" then
        if arg1 == id then
            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                Save= WoWToolsSave[addName] or Save
                Save.Cvar= Save.Cvar or {}
                e.setPlayerSound= Save.setPlayerSound--播放, 声音
                Save.groupWelcomeText= Save.groupWelcomeText or (e.Player.cn and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}')
                Save.guildWelcomeText= Save.guildWelcomeText or (e.Player.cn and '宝贝，欢迎你加入' or EMOTE103_CMD1:gsub('/',''))

                Init()
                panel:RegisterEvent('CVAR_UPDATE')
            else
                DEFAULT_CHAT_FRAME.ADD= nil
            end

        elseif arg1=='Blizzard_Settings' then
            Init_Panel()--设置控制面板

        elseif arg1=='Blizzard_DebugTools' then--FSTACK Blizzard_DebugTools.lua
            if WoWToolsChatButtonFrame.disabled then
                return
            end
            local btn= e.Cbtn(TableAttributeDisplay, {icon='hide', size={28,28}})
            btn:SetPoint('BOTTOM', TableAttributeDisplay.CloseButton, 'TOP')
            btn:SetNormalAtlas(e.Icon.icon)
            btn:SetScript('OnClick', FrameStackTooltip_ToggleDefaults)
            btn:SetScript('OnLeave', GameTooltip_Hide)
            btn:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine('|cff00ff00FST|rACK', e.GetEnabeleDisable(true)..'/'..e.GetEnabeleDisable(false))
                e.tips:AddDoubleLine(id, e.cn(addName))
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
                    print(id, e.cn(addName), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r', s:GetText())
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
