local id, e= ...
local Icon={
    S='|A:GarrMission_EncounterBar-CheckMark:0:0|a',--√
    mago='|A:transmog-icon-hidden:0:0|a',
    magoOK='|T132288:0|t',
    no='|A:questlegendary:0:0|a',
    wow='|A:Icon-WoW:0:0|a',
}

local HEX=function(r, g, b, a) r = r <= 1 and r >= 0 and r or 0 g = g <= 1 and g >= 0 and g or 0 b = b <= 1 and b >= 0 and b or 0 a=a or 1 a =  a <= 1 and a >= 0 and a or 1 return '|c'..string.format("%02x%02x%02x%02x",a*255, r*255, g*255, b*255) end
local Magic=function(s)  local t={'%%', '%.', '%(','%)','%+', '%-', '%*', '%?', '%[', '%^', '%$'} for _,v in pairs(t) do s=s:gsub(v,'%%'..v) end return s end --  ( ) . % + - * ? [ ^ $
local MK=function(k,b) if not b then b=1 end if k>=1e6 then k=string.format('%.'..b..'fm',k/1e6) elseif k>= 1e4 and GetLocale() == "zhCN" then k=string.format('%.'..b..'fw',k/1e4) elseif k>=1e3 then k=string.format('%.'..b..'fk',k/1e3) else k=string.format('%i',k) end return k end--加k 9.1
local Race=function(u, race, sex2) local s =u and select(2,UnitRace(u)) or race local sex= u and UnitSex(u) or sex2 if s and (sex==2 or sex==3 ) then s= s=='Scourge' and 'Undead' or s=='HighmountainTauren' and 'highmountain' or s=='ZandalariTroll' and 'zandalari' or s=='LightforgedDraenei' and 'lightforged' or s s=string.lower(s) sex= sex==2 and 'male' or sex==3 and 'female' return '|A:raceicon-'..s..'-'..sex..':0:0|a' end end--角色图标
local Class=function(u, c, icon) c=c or select(2, UnitClass(u)) c=c and 'groupfinder-icon-class-'..c or nil if c then if icon then return '|A:'..c ..':0:0|a' else return c end end end--职业图标

local col='|c'..select(4,GetClassColor(UnitClassBase('player')));
local Name=col..UnitName('player');

local Channels={--频道名称替换 
    ['大脚'] = '[世]',
    ['Test'] = '[T]',
    ['测试'] = '[测]',
    [GENERAL]='['..GENERAL..']'
};

--[[
for _, v in pairs(e.config.gsub) do
    local a=_G[v.a] or v.a;
    local b=_G[v.b] or v.b;
    if a:gsub(' ','')~='' and b:gsub(' ','')~='' then
        Channels[a]='['..b..']';        
    end
end
]]

local function Channel(link)
    local name=link:match('%[(.-)]');
    if name then
        for k, v in pairs(Channels) do
            if name:find(k) then
                return link:gsub('%[.-]', v);
            end
        end    
    end    
end

local Realms={};--多服务器
for _, v in pairs(GetAutoCompleteRealms()) do 
    Realms[v]=true;
end

local function Realm(link)--去服务器为*
    local name=link:match('|Hplayer:.-|h%[(.-)|r]|h')
    if name ==Name then
        return link:gsub(name, col..COMBATLOG_FILTER_STRING_ME);        
    else
        local server=link:match('|Hplayer:.-|h%[.-%-(.-)|r]|h');
        if server then
            if Realms[server] then
                return link:gsub('%-'..server..'|r]|h', GREEN_FONT_COLOR_CODE..'*|r|r]|h')
            else
                return link:gsub('%-'..server..'|r]|h', '*|r]|h');
            end    
        end    
    end
end

local function Pet(speciesID)
    if speciesID then 
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID);
        if numCollected and limit then 
            if numCollected == limit then
                return GREEN_FONT_COLOR_CODE..'['..numCollected ..'/'.. limit..']|r';
            elseif numCollected==0 then
                return RED_FONT_COLOR_CODE..'['..numCollected ..'/'.. limit..']|r';
            else
                return YELLOW_FONT_COLOR_CODE..'['..numCollected ..'/'.. limit..']|r';            
            end            
        end
    end
end

local function Mount(id, item)
    if id then
        local mountID=item and C_MountJournal.GetMountFromItem(id) or C_MountJournal.GetMountFromSpell(id);
        if  mountID then
            if select(11, C_MountJournal.GetMountInfoByID(mountID)) then
                return Icon.S;
            else 
                return Icon.no;            
            end                    
        end     
    end    
end

local function PetType(petType)
    local type=PET_TYPE_SUFFIX[petType];
    if type then 
        return '|TInterface\\Icons\\Icon_PetFamily_'..type..':0|t'
    end    
end

local function Item(link)--物品超链接    
    local t=link;
    local icon=C_Item.GetItemIconByID(link);
    if icon then----加图标        
        t='|T'..icon..':0|t'..t;
    end    
    local id, _, _, _, _, classID, subclassID=GetItemInfoInstant(link);
    id=id or link:match('Hitem:(%d+)');
    if classID==2 or classID==4 then
        local lv=GetDetailedItemLevelInfo(link);--装等
        if lv and lv>10 then
            t=t..'['..lv..']';
        end
        local sourceID=select(2,C_TransmogCollection.GetItemInfo(link))-- or select(2,C_TransmogCollection.GetItemInfo(id));--幻化
        if sourceID then             
            local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
            if sourceInfo then                
                if sourceInfo.isCollected then
                    t=t..Icon.magoOK;
                else
                    t=t..Icon.mago;
                end
                local hasItemData, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID);--玩家是否可收集
                if hasItemData and not canCollect then
                    t=t..Icon.no;
                end                            
            end
        end        
    elseif  classID==15 and (subclassID==2 or subclassID==5) then        
        if  subclassID==2 then----宠物数量
            local _, _, petType, _, _, _, _, _, _, _, _, _, speciesID=C_PetJournal.GetPetInfoByItemID(id);
            local nu=Pet(speciesID);
            if nu then
                t=(PetType(petType) or '')..t..nu;
            end
        elseif subclassID==5 then--坐骑是不收集            
            local nu= Mount(id, true);
            if nu then
                t=t..nu;
            end
        end                            
    elseif C_ToyBox.GetToyInfo(id) then--玩具
        t=PlayerHasToy(id) and t..Icon.S or t..Icon.no;        
    end    
    local bag=GetItemCount(link, true);--数量
    if bag and bag>0 then
        t=t..GREEN_FONT_COLOR_CODE..'[*'..MK(bag, 3)..']|r';
    end
    if t~=link then
        return t;    
    end    
end

local function Spell(link)--法术图标
    local t=link;
    local icon= select(3, GetSpellInfo(link));    
    local id=link:match('Hspell:(%d+)');    
    if icon then
        return '|T'..icon..':0|t'..link;
    else        
        if id then
            icon = GetSpellTexture(id);
            if icon then 
                t='|T'..icon..':0|t'..t;
            end    
        end
    end
    local nu= Mount(id);
    if nu then
        t=t..nu;
    end
    if t~=link then 
        return t;
    end
end

local function PetLink(link)--宠物超链接
    local speciesID =link:match('Hbattlepet:(%d+)');
    if speciesID  then 
        local nu=Pet(speciesID );
        if nu then
            local _, icon, petType= C_PetJournal.GetPetInfoBySpeciesID(speciesID);
            return (PetType(petType) or '') .. (icon and '|T'..icon..':0|t' or '')..link..nu;
        end
    end
end

local function PetAblil(link)--宠物技能
    local id=link:match('HbattlePetAbil:(%d+)');
    if id then 
        local _, _, icon, _, _, _, petType=C_PetBattles.GetAbilityInfoByID(id);
        if icon then 
            local icon2=PetType(petType);
            return (icon2 or '')..'|T'..icon..':0|t'..link;
        end
    end
end

local function Trade(link)--贸易技能
    local id=link:match('Htrade:.-:(%d+):');
    if id then
        local icon = GetSpellTexture(id);
        if icon then 
            return '|T'..icon..':0|t'..link;
        end    
    end
end

local function Enchant(link)--附魔
    local id=link:match('Henchant:(%d+)');
    if id then
        local icon = GetSpellTexture(id);
        if icon then 
            return '|T'..icon..':0|t'..link;
        end    
    end
end

local function Currency(link)--货币
    local info= C_CurrencyInfo.GetCurrencyInfoFromLink(link);
    if info and info.iconFileID then
        local nu='';
        if info.quantity and info.quantity>0 then
            nu=MK(info.quantity, 3);
        end
        return  '|T'..info.iconFileID..':0|t'..link..nu;            
    end
end

local function Achievement(link)--成就
    local id=link:match('Hachievement:(%d+)');
    if id then
        local _, _, _, completed, _, _, _, _, _, icon = GetAchievementInfo(id);
        icon=icon and '|T'..icon..':0|t' or '';
        return icon..link..(completed and Icon.S or Icon.no);
    end
end

local function Quest(link)--任务
    local id=link:match('Hquest:(%d+)');
    if id then
        local wow= C_QuestLog.IsAccountQuest(id) and Icon.wow or '';--帐号通用        
        if C_QuestLog.IsQuestFlaggedCompleted(id) then
            return wow..link..Icon.S;
        else
            return wow..link..Icon.no;
        end
    end
end

local function Talent(link)--天赋
    local id=link:match('Htalent:(%d+)');
    if id then
        local _, _, icon, _, _, _, _, _ ,_, known=GetTalentInfoByID(id)
        if icon then
            return '|T'..icon..':0|t'..link..(known and Icon.S or Icon.no);            
        end
    end
end

local function Pvptal(link)--pvp天赋
    local id=link:match('Hpvptal:(%d+)');
    if id then
        local _, _, icon, _, _, _, _, _ ,_, known=GetPvpTalentInfoByID(id);
        return '|T'..icon..':0|t'..link..(known and Icon.S or Icon.no);
    end
end


local function Outfit(link)--外观方案链接
    local list = C_TransmogCollection.GetItemTransmogInfoListFromOutfitHyperlink(link);    
    if list then
        local co,to=0,0;
        for _,v in pairs(list) do
            local appearanceID=v.appearanceID;--v.illusionID
            local illusionID=v.illusionID;            
            if appearanceID and appearanceID>0 then
                local hide=C_TransmogCollection.IsAppearanceHiddenVisual(appearanceID);
                if not hide then
                    local has=C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(appearanceID);                    
                    if has then
                        co=co+1;
                    end                
                    to=to+1;                    
                end
            end
            
            if illusionID and illusionID>0 then
                local info = C_TransmogCollection.GetIllusionInfo(illusionID);
                if info then
                    if info.isCollected then
                        co=co+1;
                    end
                    to=to+1;
                end                
            end
        end
        if to>0 then
            if to==co then
                return link..Icon.S;
            elseif co>0 then
                return link..YELLOW_FONT_COLOR_CODE..co..'/'..to..'|r';                 
            else                
                return link..RED_FONT_COLOR_CODE..co..'/'..to..'|r';                 
            end
        end
    end
end

local function Transmogillusion(link)--幻化
    local illusionID=link:match('Htransmogillusion:(%d+)');
    if illusionID then
        local info=C_TransmogCollection.GetIllusionInfo(illusionID);
        if info then
            return link..((info.isCollected and info.isUsable) and Icon.magoOK) or (info.isCollected and Icon.S) or Icon.mago;            
        end
    end
end

local function TransmogAppearance(link)--幻化
    local appearanceID=link:match('Htransmogillusion:(%d+)');
    if appearanceID then
        local has=C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(appearanceID);                    
        if has then 
            return link.Icon.S;
        else
            return link..Icon.no;
        end
    end
end

local function GetKeyAffix(affixs)--钥石
    local icon='';
    for _, v in pairs(affixs) do
        if v and v ~='0' then
            local icon2=select(3, C_ChallengeMode.GetAffixInfo(v));
            if icon2 then icon=icon..'|T'..icon2..':0|t' end
        end
    end    
    return icon;
end
local function Keystone(link)
    local item, _, affix1, affix2, affix3, affix4= link:match('Hkeystone:(%d+):(%d+):%d+:(%d+):(%d+):(%d+):(%d+)');
    if item then 
        local  icon=C_Item.GetItemIconByID(item);        
        if icon then
            icon= '|T'..icon..':0|t';
            return icon..link..GetKeyAffix({affix1, affix2, affix3, affix4});            
        end        
    end
end

local function DungeonScore(link)--史诗钥石评分
    local score, guid, itemLv=link:match('|HdungeonScore:(%d+):(.-):.-:%d+:(%d+):');
    local t=link;
    if score and score~='0' then
        t=score..link;
    end
    if guid then
        local _, class, _, race, sex = GetPlayerInfoByGUID(guid);
        race=Race(nil, race, sex);
        class=Class(nil, class, true);
        t=class and class..t or t;
        t=race and race..t or t;        
    end
    if itemLv and itemLv~='0' then
        t=t..itemLv;
    end 
    local nu=#C_MythicPlus.GetRunHistory();
    if nu>0 then
        t=t..' |cff00ff00'..nu..'/'..#C_MythicPlus.GetRunHistory(false, true)..'|r';
    end    
    if t~=link then
        return t;
    end
end

local function Journal(link)--冒险指南
    local journalType, journalID=link:match('Hjournal:(%d+):(%d+):');
    if journalID and journalType=='0' then--Instance
        local buttonImage2 = select(6, EJ_GetInstanceInfo(journalID));
        if buttonImage2 then
            return '|T'..buttonImage2..':0|t'..link;
        end
    end    
end

local ColorText={};--内容加颜色
--[[
for _, v in pairs(e.config.color) do 
    local s=v.a..' ';
    s=s:gsub('\n', ' ');
    s=Magic(s);
    s:gsub('(.-) ', function(t)
            ColorText[t]=HEX(v.b[1], v.b[2], v.b[3], v.b[4]);            
    end);
end
]]

local function Instancelock(link)
    local guid, InstanceID, DifficultyID=link:match('Hinstancelock:(.-):(%d+):(%d+):');
    local t=link;
    if guid then
        local _, class, _, race, sex = GetPlayerInfoByGUID(guid);
        race=Race(nil, race, sex);
        class=Class(nil, class, true);
        t=class and class..t or t;
        t=race and race..t or t;        
    end
    if DifficultyID and InstanceID then
        local name=GetDifficultyInfo(DifficultyID);
        if name then 
            t=t..'|Hjournal:0:'..InstanceID..':'..DifficultyID..'|h['..name..']|h';
        end
    end
    if t~=link then
        return t;
    end
end

local function TransmogSet(link)--幻化套装
    local setID=link:match('transmogset:(%d+)');
    if setID then
        --[[        local set = C_TransmogSets.GetSetInfo(setID);
        if set then
            if set.collected then
                return link..Icon.S;
            elseif se.collected==false then
                return link..Icon.no;
            end
        end]]
        
        local info=C_TransmogSets.GetSetPrimaryAppearances(setID);
        if info then
            local n,to=0,0;
            for _,v in pairs(info) do
                to=to+1;
                if v.collected then
                    n=n+1;
                end;
            end;
            if to>0 then            
                if n==to then
                    return Icon.S;
                elseif n==0 then
                    return link..RED_FONT_COLOR_CODE..n..'/'..to..'|r';
                else                
                    return link..YELLOW_FONT_COLOR_CODE..n..'/'..to..'|r';
                end
            end        
        end        
    end
end

local function Add(self, s, ...)
    s=s:gsub('|Hchannel:.-]|h', Channel);
    s=s:gsub('|Hplayer:.-]|h', Realm);
    s=s:gsub('|Hitem:.-]|h',Item);
    s=s:gsub('|Hspell:.-]|h',Spell);
    
    s=s:gsub('|Hbattlepet:.-]|h',PetLink);
    s=s:gsub('|HbattlePetAbil:.-]|h',PetAblil);    
    
    s=s:gsub('|Htrade:.-]|h', Trade);
    s=s:gsub('|Henchant:.-]|h', Enchant); 
    s=s:gsub('|Hcurrency:.-]|h', Currency); 
    s=s:gsub('|Hachievement:.-]|h', Achievement); 
    s=s:gsub('|Hquest:.-]|h', Quest);
    s=s:gsub('|Htalent:.-]|h', Talent);
    s=s:gsub('|Hpvptal:.-]|h', Pvptal);
    
    s=s:gsub('|Houtfit:.-]|h', Outfit);----外观方案链接    
    s=s:gsub('|Htransmogillusion:.-]|h', Transmogillusion);    
    s=s:gsub('|Htransmogappearance:.-]|h', TransmogAppearance);    
    s=s:gsub('|Htransmogset:.-]|h', TransmogSet);
    
    s=s:gsub('|Hkeystone:.-]|h', Keystone);
    s=s:gsub('|HdungeonScore:.-]|h', DungeonScore);
    s=s:gsub('|Hjournal:.-]|h', Journal);
    s=s:gsub('|Hinstancelock:.-]|h', Instancelock);
    
    
    
    for k, v in pairs(ColorText) do--内容加颜色
        s=s:gsub(k, v..k..'|r');
    end    
    return self.ADD(self, s, ...);
end

for i = 3,   NUM_CHAT_WINDOWS do--NUM_CHAT_WINDOWS
    local frame = _G["ChatFrame"..i];
    if frame then
        if not frame.ADD then frame.ADD=frame.AddMessage end
        frame.AddMessage=Add;
    end    
end

local Frame=DEFAULT_CHAT_FRAME;
if not Frame.ADD then Frame.ADD=Frame.AddMessage end
Frame.AddMessage=Add; 

Frame.editBox:SetAltArrowKeyMode(false);--alt +方向= 移动