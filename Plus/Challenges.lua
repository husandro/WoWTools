if not C_MythicPlus.GetCurrentSeason() then
    return
end

local id, e = ...


--[[
https://wago.io/dungeonports
https://wago.io/meD8JMW3C
C_MythicPlus.GetCurrentSeason()
https://wago.tools/db2/MapChallengeMode?build=11.0.2.55399&locale=zhCN
]]
e.ChallengesSpellTabs={
    [399]= {spell=393256, ins=1202, name='红玉', spellName='利爪防御者之路', spellDes='传送到|cff00ccff红玉新生法池|r的入口。'},--传送到红玉新生法池的入口。 利爪防御者之路
    [400]= {spell=393262, ins=1198, name='诺库德', spellName='啸风平原之路', spellDes='|cff00ccff传送至诺库德阻击战|r的入口。'},--传送至诺库德阻击战的入口。 啸风平原之路
    [401]= {spell=393279, ins=1203, name='魔馆', spellName='奥秘之路',  spellDes='传送至|cff00ccff碧蓝魔馆|r的入口。'},--传送至碧蓝魔馆的入口。 奥秘之路
    [402]= {spell=393273, ins=1201, name='学院', spellName='巨龙学位之路', spellDes='传送到|cff00ccff艾杰斯亚学院|r的入口。'},--传送到艾杰斯亚学院的入口。 巨龙学位之路
    [403]= {spell=393222, ins=1197, name='奥达曼遗产', spellName='看护者遗产之路', spellDes='传送到|cff00ccff奥达曼|r：|cffff00ff提尔的遗产|r的入口。'},--传送到奥达曼：提尔的遗产的入口 看护者遗产之路    
    [404]= {spell=393276, ins=1199, name='奈萨鲁斯', spellName='黑曜宝藏之路', spellDes='传送到|cff00ccff奈萨鲁斯|r的入口。'},--传送到奈萨鲁斯的入口。 黑曜宝藏之路
    [405]= {spell=393267, ins=1196, name='蕨皮山谷', spellName='腐木之路',  spellDes='传送到|cff00ccff蕨皮山谷|r的入口。'},--传送到蕨皮山谷的入口。 腐木之路
    [406]= {spell=393283, ins=1204, name='注能大厅', spellName='泰坦水库之路', spellDes='传送到|cff00ccff注能大厅|r的入口。'},----传送到注能大厅的入口 泰坦水库之路

    [198]= {spell=424163, ins=762, name='黑心林地', spellName='梦魇之王之路', spellDes='传送到|cff00ccff黑心林地|r的入口。'},--黑心林地 Darkheart Thicket (Legion)
    [199]= {spell=424153, ins=740, name='黑鸦堡垒', spellName='上古恐惧之路', spellDes='传送到|cff00ccff黑鸦堡垒|r的入口'},--黑鸦堡垒 Black Rook Hold (Legion)
    [168]= {spell=159901, ins=556, name='永茂林地', spellName='青翠之路', spellDes='传送至|cff00ccff永茂林地|r入口处。'},--永茂林地 The Everbloom (Warlords of Draenor)    
    [248]= {spell=424167, ins=1021, name='庄园', spellName='巫心灾厄之路', spellDes='传送到|cff00ccff维克雷斯庄园|r的入口。'},--维克雷斯庄园 Waycrest Manor (Battle for Azeroth)
    [244]= {spell=424187, ins=1176, name='阿塔达萨', spellName='鎏金皇陵之路', spellDes='传送到|cff00ccff阿塔达萨|r的入口。'},--阿塔达萨 Atal'Dazar (Battle for Azeroth)
    [463]= {spell=424197, ins=1209, name='陨落', insName='永恒黎明', spellName='扭曲之光之路', spellDes='传送到|cff00ccff永恒黎明|r的入口。'},--永恒黎明：迦拉克隆的陨落 Dawn of the Infinite: Galakrond's Fall
    [464]= {spell=424197, ins=1209, name='崛起', insName='永恒黎明', spellName='扭曲之光之路', spellDes='传送到|cff00ccff永恒黎明|r的入口。'},--永恒黎明：姆诺兹多的崛起 Dawn of the Infinite: Murozond's Rise    
    [456]= {spell=424142, ins=65, name='潮汐王座', spellName='猎潮者之路', spellDes='传送到潮|cff00ccff汐王座|r的入口。'},--潮汐王座 Throne of the Tides (Cataclysm)

    [206]= {spell=410078, ins=767, name='巢穴', spellName='大地守护者之路', spellDes='传送到|cff00ccff奈萨里奥的巢穴|r的入口。'},--奈萨里奥的巢穴
    [245]= {spell=410071, ins=1001, name='自由镇', spellName='无拘海匪之路', spellDes='传送到|cff00ccff自由镇|r的入口。'},--自由镇
    [251]= {spell=410074, ins=1022, name='地渊孢林', spellName='腐败丛生之路', spellDes='传送到|cff00ccff地渊孢林|r的入口'},--地渊孢林
    [438]= {spell=410080, ins=68, name='旋云之巅', spellName='风神领域之路', spellDes='传送到|cff00ccff旋云之巅|r的入口。'},--旋云之巅

    [2]={spell=131204, ins=313, name='青龙寺', spellDes='将施法者传送到|cff00ccff青龙寺|r入口。'},
    [200]={spell=393764, ins=721, name='英灵殿', spellName='证明价值之路', spellDes='传送到|cff00ccff英灵殿|r的入口。'},
    [210]={spell=393766, ins=800, name='群星庭院', spellName='大魔导师之路', spellDes='传送到|cff00ccff群星庭院|r的入口。'},
    [165]={spell=159899, ins=537, name='影月墓地', spellName='新月之路', spellDes='传送至|cff00ccff影月墓地|r入口处。'},

    [391]={spell=367416, ins=1194, name='天街', spellName='街头商贩之路', spellDes='传送至|cff00ccff塔扎维什，帷纱集市|r入口处。'},
    [392]={spell=367416, ins=1194, name='宏图', spellName='街头商贩之路', spellDes='传送至|cff00ccff塔扎维什，帷纱集市|r入口处。'},
    [166]={spell=159900, ins=536, name='恐轨车站', spellName='暗轨之路', spellDes='传送至|cff00ccff恐轨车站|r入口处。'},
    [369]={spell=373274, ins=1178, name='麦卡贡垃圾场', spellName='机械王子之路', spellDes='传送到|cff00ccff麦卡贡|r行动的入口。'},
    [370]={spell=373274, ins=1178, name='麦卡贡车间', spellName='机械王子之路', spellDes='传送到|cff00ccff麦卡贡|r行动的入口。'},


    [169]={spell=159896, ins=558, name='钢铁码头', spellName='铁船之路', spellDes='传送至|cff00ccff钢铁码头|r入口处。'},
    [227]={spell=373262, ins=860, name='卡拉赞', spellName='堕落守护者之路', spellDes='传送到|cff00ccff卡拉赞|r的入口。'},
    [234]={spell=373262, ins=860, name='卡拉赞', spellName='堕落守护者之路', spellDes='传送到|cff00ccff卡拉赞|r的入口。'},


    [56]={spell=131205, ins=302, name='风暴烈酒酿造厂', spellName='烈酒之路', spellDes='将施法者传送到|cff00ccff风暴烈酒酿造厂|r入口。'},
    [57]={spell=131225, ins=303, name='残阳关', spellName='残阳之路', spellDes='传送至|cff00ccff残阳关|r入口处。'},
    [58]={spell=131206, ins=321, name='影踪禅院', spellName='影踪派之路', spellDes='将施法者传送到|cff00ccff影踪禅院|r入口。'},
    [59]={spell=131228, ins=324, name='砮皂寺', spellName='玄牛之路', spellDes='传送至|cff00ccff围攻砮皂寺|r入口处'},
    [60]={spell=131222, ins=321, name='魔古山宫殿', spellName='魔古皇帝之路', spellDes='传送至|cff00ccff魔古山宫殿|r入口处。'},
    [76]={spell=131232, ins=246, name='通灵学院', spellName='通灵师之路', spellDes='传送至|cff00ccff通灵学院|r入口处。'},
    [77]={spell=131231, ins=311, name='血色大厅', spellName='血色利刃之路', spellDes='传送至|cff00ccff血色大厅|r入口处。'},
    [78]={spell=131229, ins=316, name='血色修道院', spellName='血色法冠之路', spellDes='传送至|cff00ccff血色修道院|r入口处。'},




    [163]={spell=159895, ins=385, name='渣矿井', spellName='血槌之路', spellDes='传送至|cff00ccff血槌炉渣矿井|r入口处。'},
    [167]={spell=159902, ins=559, name='上黑石塔', spellName='火山之路', spellDes='传送至|cff00ccff黑石塔上层|r入口处。'},
    [161]={spell=159898, ins=476, name='通天峰', spellName='通天之路', spellDes='传送至|cff00ccff通天峰|r入口处。'},
    [164]={spell=159897, ins=547, name='奥金顿', spellName='警戒者之路', spellDes='传送至|cff00ccff奥金顿|r入口处。'},
    [379]={spell=354463, ins=1183, name='凋魂之殇', spellName='瘟疫之路', spellDes='传送到|cff00ccff凋魂之殇|r的入口。'},
    [375]={spell=354464, ins=1184, name='塞兹仙林', spellName='雾林之路', spellDes='传送到|cff00ccff塞兹仙林|r的迷雾的入口。'},
    [377]={spell= 354468, ins=1188, name='彼界', spellName='狡诈之神之路', spellDes='传送到|cff00ccff彼界|r入口。'},

    [380]={spell=354469, ins=1189, name='赤红深渊', spellName='石头守望者之路', spellDes='传送至|cff00ccff赤红深渊|r入口。'},
    [378]={spell=354465, ins=1185, name='赎罪大厅', spellName='罪魂之路', spellDes='传送到|cff00ccff赎罪大厅|r的入口。'},
    [382]={spell=354467, ins=1187, name='伤逝剧场', spellName='不败之路', spellDes='传送到|cff00ccff伤逝剧场|r的入口。'},
    [376]={spell=354462, ins=1182, name='通灵战潮', spellName='勇者之路', spellDes='传送到|cff00ccff通灵战潮|r的入口。'},
    [381]={spell=354466, ins=1186, name='晋升高塔', spellName='晋升者之路', spellDes='传送到|cff00ccff晋升高塔|r的入口。'},

    [499]= {spell=445444, ins=1267, name='圣焰隐修院', spellName='圣焰隐修院之路', spellDes='传送至|cff00ccff圣焰隐修院|r入口处。'},
    [500]= {spell=445443, ins=1268, name='驭雷栖巢', spellName='驭雷栖巢之路', spellDes='传送至|cff00ccff驭雷栖巢|r入口处。'},
    [501]= {spell=445269, ins=1269, name='矶石宝库', spellName='矶石宝库之路', spellDes='传送至|cff00ccff矶石宝库|r入口处。'},
    [502]= {spell=445416, ins=1274, name='千丝之城', spellName='千丝之城之路', spellDes='传送至|cff00ccff千丝之城|r入口处。'},
    [503]= {spell=445417, ins=1271, name='回响之城', spellName='艾拉-卡拉，回响之城之路', spellDes='传送至|cff00ccff艾拉%-卡拉，回响之城入|r口处'},
    [504]= {spell=445441, ins=1210, name='暗焰裂口', spellName='暗焰裂口之路', spellDes='传送至|cff00ccff暗焰裂口|r入口处。'},
    [505]= {spell=445414, ins=1270, name='破晨号', spellName='破晨号之路', spellDes='传送至|cff00ccff破晨号|r入口处。'},
    [506]= {spell=445440, ins=1272, name='燧酿酒庄', spellName='酒庄之路', spellDes='传送至|cff00ccff燧酿酒庄|r入口处。'},
    [507]= {spell=445424, ins=71, name='格瑞姆巴托', spellName='格瑞姆巴托之路', spellDes='传送至|cff00ccff格瑞姆巴托|r入口处。'},
}

--if C_MythicPlus.GetCurrentSeason()==12 then
for _, tab in pairs(e.ChallengesSpellTabs) do
    e.LoadData({id=tab.spell, type='spell'})
end


if not e.Player.levelMax or PlayerGetTimerunningSeasonID() then
    return
end

local addName= CHALLENGES
local Save= {
    --hideIns=true,--隐藏，副本，挑战，信息
    --insScale=0.8,--副本，缩放

    --hideTips=true,--提示信息
    --tipsScale=0.8,--提示信息，缩放
    rightX= 2,--右边，提示，位置
    rightY= -22,

    hidePort= not e.Player.husandro,--传送门
    portScale=e.Player.husandro and 0.85 or 1,--传送门, 缩放

    --hideKeyUI=true,--挑战,钥石,插入界面
    --slotKeystoneSay=true,--插入, KEY时, 说
}
local panel=CreateFrame("Frame")
local TipsFrame
local Initializer





--[[(资料来自)：
ttps://www.wowhead.com/guide/mythic-plus-dungeons/dragonflight-season-4/overview#mythic-affixes
AngryKeystones Schedule

1 Overflowing,
2 Skittish
3 Volcanic
4 Necrotic
5 Teeming
6 Raging
7 Bolstering
8 Sanguine
9 Tyrannical
10 Fortified
11 Bursting
12 Grievous
13 Explosive
14 Quaking
16 Infested
117 Reaping
119 Beguiling
120 Awakened
121 Prideful
122 Inspiring
123 Spiteful
124 Storming
134 Entangling
135：Afflicted
136 Incorporeal
137 Shielding
]]
local affixSchedule = {--C_MythicPlus.GetCurrentSeason() C_MythicPlus.GetCurrentUIDisplaySeason()
    --season=12,--当前赛季
    [1]={[1]=9, [2]=124, [3]=6},	--Tyrannical Storming Raging
    [2]={[1]=10, [2]=134, [3]=7},	--Fortified Entangling Bolstering
    [3]={[1]=9, [2]=136, [3]=123},	--Tyrannical Incorporeal Spiteful
    [4]={[1]=10, [2]=135, [3]=6},	--Fortified 	Afflicted	Raging
    [5]={[1]=9, [2]=3, [3]=8},	--Tyrannical Volcanic 	Sanguine
    [6]={[1]=10, [2]=124, [3]=11},	--Fortified 	Storming Bursting
    [7]={[1]=9, [2]=135, [3]=7},	--Tyrannical Afflicted 	Bolstering
    [8]={[1]=10, [2]=136, [3]=8},	--Fortified 	Incorporeal Sanguine
    [9]={[1]=9, [2]=134, [3]=11},	--Tyrannical Entangling Bursting
    [10]={[1]=10, [2]=3, [3]=123},	--Fortified 	Volcanic 	Spiteful
}






--难度 每周 掉落
--https://www.wowhead.com/cn/guide/mythic-plus-dungeons/dragonflight-season-4
local LimitMaxKeyLevel=20--限制，显示等级,不然，数据会出错
local function Level_Text(text)
    local tab={
        ['Veteran']= format('%s%s|r', '|cff00ff00', e.onlyChinese and '老兵' or 'Veteran'),
        ['Champion']= format('%s%s|r', '|cff2aa2ff', e.onlyChinese and '勇士' or FOLLOWERLIST_LABEL_CHAMPIONS),
        ['Hero']= format('%s%s|r', '|cffff00ff', e.onlyChinese and '英雄' or ITEM_HEROIC),
        ['Myth']= format('%s%s|r', '|cffb78f6a', e.onlyChinese and '史诗' or ITEM_QUALITY4_DESC),
    }
    return tab[text] or text
end
local function Get_Week_Item_Level(level)
    level= min(LimitMaxKeyLevel, level)
    level= max(2, level)
    local tab={
        [2]='597'..Level_Text('Champion')..'1/8  606'..Level_Text('Champion')..'4/8',
        [3]='597'..Level_Text('Champion')..'1/8  610'..Level_Text('Hero')..'1/6',
        [4]='600'..Level_Text('Champion')..'2/8  610'..Level_Text('Hero')..'1/6',
        [5]='603'..Level_Text('Champion')..'3/8  613'..Level_Text('Hero')..'2/6',
        [6]='606'..Level_Text('Champion')..'4/8  613'..Level_Text('Hero')..'2/6',

        [7]='610'..Level_Text('Hero')..'1/6  616'..Level_Text('Hero')..'3/6',
        [8]='610'..Level_Text('Hero')..'1/6  619'..Level_Text('Hero')..'3/6',
        [9]='613'..Level_Text('Hero')..'2/6  619'..Level_Text('Hero')..'4/6',
        [10]='613'..Level_Text('Hero')..'2/6  623'..Level_Text('Myth')..'2/4',
    }
    return tab[level] or tab[10]
end





local function get_Bag_Key()--查找，包的key
    for bagID= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do--Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES ,Constants.InventoryConstants.NumBagSlots
        for slotID=1, C_Container.GetContainerNumSlots(bagID) do
            local info = C_Container.GetContainerItemInfo(bagID, slotID)
            if info and info.itemID and C_Item.IsItemKeystoneByID(info.itemID) and info.hyperlink then
                return info.hyperlink, info, bagID, slotID
            end
        end
    end
end

local function getBagKey(self, point, x, y, parent) --KEY链接
    local find=point:find('LEFT')
    local i=1
    for bagID= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do
        for slotID=1, C_Container.GetContainerNumSlots(bagID) do
            local icon, itemLink, itemID
            local info= C_Container.GetContainerItemInfo(bagID, slotID)
            if info then
                icon=info.iconFileID
                itemLink=info.hyperlink
                itemID= info.itemID
            end
            if itemID and itemLink and C_Item.IsItemKeystoneByID(itemID) then
                if not self['key'..i] then
                    self['key'..i]= WoWTools_ButtonMixin:Cbtn(parent or self, {size={16,16}, texture=icon})
                    --[[CreateFrame("Button", nil, parent or self)
,                   self['key'..i]:SetHighlightAtlas('Forge-ColorSwatchSelection')
                    self['key'..i]:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress')
                    self['key'..i]:SetSize(16, 16)
                    self['key'..i]:SetNormalTexture(icon)]]
                    self['key'..i].item=itemLink
                    if i==1 then
                        self['key'..i]:SetPoint(point, self, x, y)
                    else
                        if find then
                            self['key'..i]:SetPoint(point, self['key'..(i-1)], 'TOPLEFT', 0, 0)
                        else
                            self['key'..i]:SetPoint(point, self['key'..(i-1)], 'TOPRIGHT', 0, 0)
                        end
                    end
                    self['key'..i]:SetScript("OnMouseDown",function(self2, d2)--发送链接
                            if d2=='LeftButton' then
                                e.Chat(self2.item, nil, nil)
                            else
                                e.Chat(self2.item, nil, true)
                                --if not ChatEdit_InsertLink(self2.item) then
                                    --ChatFrame_OpenChat(self2.item)
                                --end
                            end
                    end)
                    self['key'..i]:SetScript("OnEnter",function(self2)
                            e.tips:SetOwner(self2, "ANCHOR_LEFT")
                            e.tips:ClearLines()
                            e.tips:SetHyperlink(self2.item)
                            e.tips:AddDoubleLine(e.onlyChinese and '发送信息' or SEND_MESSAGE, e.Icon.left)
                            e.tips:AddDoubleLine(e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, e.Icon.right)
                            e.tips:Show()
                    end)
                    self['key'..i]:SetScript("OnLeave",function()
                            e.tips:Hide()
                    end)
                    self['key'..i].bag=e.Cstr(self['key'..i])
                    if point:find('LEFT') then
                        self['key'..i].bag:SetPoint('LEFT', self['key'..i], 'RIGHT', 0, 0)
                    else
                        self['key'..i].bag:SetPoint('RIGHT', self['key'..i], 'LEFT', 0, 0)
                    end
                    self['key'..i].bag:SetText(itemLink)
                end
                if self['key'..i] and self==ChallengesFrame then
                    self['key'..i]:SetShown(not Save.hideTips)
                end
                i=i+1
            end
        end
    end
end























--##################
--挑战,钥石,插入,界面
--##################
local function UI_Party_Info(self)--队友位置
    if Save.hideKeyUI then
        return
    end
    local UnitTab={}
    local name, uiMapID=e.GetUnitMapName('player')
    local text
    local all= GetNumGroupMembers()
    for i=1, all do
        local unit='party'..i
        if i==all then
            unit='player'
        end
        local guid=UnitGUID(unit)
        if guid then
            text= text and text..'|n' or ''

            local stat=GetReadyCheckStatus(unit)
            if stat=='ready' then
                text= text..format('|A:%s:0:0|a', e.Icon.select)
            elseif stat=='waiting' then
                text= text..'  '
            elseif stat=='notready' then
                text= format('%s|A:%s:0:0|a', text, e.Icon.disabled)
            end

            local tab= e.UnitItemLevel[guid]--装等
            if tab then
                if tab.itemLevel then
                    text= text..'|A:charactercreate-icon-customize-body-selected:0:0|a'..tab.itemLevel
                else
                    table.insert(UnitTab, unit)
                end
            end

            local info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)--挑战, 分数
            if info and info.currentSeasonScore and info.currentSeasonScore>0 then
                text= text..e.GetKeystoneScorsoColor(info.currentSeasonScore, true)
                if info.runs and info.runs then
                    local bestRunLevel=0
                    for _, run in pairs(info.runs) do
                        if run.bestRunLevel and run.bestRunLevel>bestRunLevel then
                            bestRunLevel=run.bestRunLevel
                        end
                    end
                    if bestRunLevel>0 then
                        text= text..'('..bestRunLevel..')'
                    end
                end
            end

            text= text..e.GetPlayerInfo({guid=guid, unit=unit, name=name, reName=true, reRealm=true})--信息

            local name2, uiMapID2=e.GetUnitMapName(unit)
            if (name and name==name2) or (uiMapID and uiMapID==uiMapID2) then--地图名字
                text=text..format('|A:%s:0:0|a', e.Icon.select)
            elseif name2 then
                text=text ..'|A:poi-islands-table:0:0|a'..name2
            else
                text= text.. '|A:questlegendary:0:0|a'
            end

            local reason=UnitPhaseReason(unit)--位面
            if reason then
                if reason==0 then--不同了阶段
                    text= text ..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '不同了阶段' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('',  MAP_BAR_THUNDER_ISLE_TITLE0:gsub('1','')))..'|r'
                elseif reason==1 then--不在同位面
                    text= text ..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '不在同位面' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', e.Player.L.layer))..'|r'
                elseif reason==2 then--战争模式
                    text= text ..(C_PvP.IsWarModeDesired() and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '开启战争模式' or ERR_PVP_WARMODE_TOGGLE_ON)..'|r')
                elseif reason==3 then
                    text= text..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)..'|r'
                end
            end


        end
    end
    if not self.partyLable then
        self.partyLable=e.Cstr(self.keyFrame)--队伍信息
        --self.party:SetPoint('BOTTOMLEFT', _G['MoveZoomInButtonPerChallengesKeystoneFrame'] or self, 'TOPLEFT')
        self.partyLable:SetPoint('TOPLEFT', self, 'TOPRIGHT')
    end
    self.partyLable:SetText(text or '')
    e.GetNotifyInspect(UnitTab)--取得装等
end

local function init_Blizzard_ChallengesUI()--挑战,钥石,插入界面
    local self=ChallengesKeystoneFrame

    self.keyFrame= CreateFrame('Frame', nil, self)
    self.keyFrame:SetPoint('TOPLEFT')
    self.keyFrame:SetSize(1,1)
    self.keyFrame:SetFrameStrata('HIGH')
    self.keyFrame:SetFrameLevel(7)

    self.ready = CreateFrame("Button",nil, self.keyFrame, 'UIPanelButtonTemplate')--就绪
    self.ready:SetText((e.onlyChinese and '就绪' or READY)..format('|A:%s:0:0|a', e.Icon.select))
    self.ready:SetPoint('LEFT', self.StartButton, 'RIGHT',2, 0)
    self.ready:SetSize(100,24)
    self.ready:SetScript("OnMouseDown", DoReadyCheck)

    self.mark = CreateFrame("Button",nil, self.keyFrame, 'UIPanelButtonTemplate')--标记
    self.mark:SetText(e.Icon['TANK']..(e.onlyChinese and '标记' or EVENTTRACE_MARKER)..e.Icon['HEALER'])
    self.mark:SetPoint('RIGHT', self.StartButton, 'LEFT',-2, 0)
    self.mark:SetSize(100,24)
    self.mark:SetScript("OnMouseDown",function()
        local n=GetNumGroupMembers()
        for i=1,n  do
            local u='party'..i
            if i==n then u='player' end
            if CanBeRaidTarget(u) then
                local r=UnitGroupRolesAssigned(u)
                local index=GetRaidTargetIndex(u)
                if r=='TANK' then
                    if index~=2 then SetRaidTarget(u, 2) end
                elseif r=='HEALER' then
                    if index~=1 then SetRaidTarget(u, 1) end
                else
                    if index and index>0 then SetRaidTarget(u, 0) end
                end
            end
        end
    end)

    self.clear = CreateFrame("Button",nil, self.keyFrame, 'UIPanelButtonTemplate')--清除KEY
    self.clear:SetPoint('RIGHT', self, -15, -50)
    self.clear:SetSize(70,24)
    self.clear:SetText(e.onlyChinese and '清除' or  SLASH_STOPWATCH_PARAM_STOP2)
    self.clear:SetScript("OnMouseDown",function()
        C_ChallengeMode.RemoveKeystone()
        ChallengesKeystoneFrame:Reset()
        ItemButtonUtil.CloseFilteredBags(ChallengesKeystoneFrame)
        ClearCursor()
    end)

    self.ins = CreateFrame("Button",nil, self.keyFrame, 'UIPanelButtonTemplate')--插入
    self.ins:SetPoint('BOTTOMRIGHT', self.clear, 'TOPRIGHT', 0, 2)
    self.ins:SetSize(70,24)
    self.ins:SetText(e.onlyChinese and '插入' or  COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN)
    self.ins:SetScript("OnMouseDown",function()
            if UnitAffectingCombat('player') then
                print(e.addName, Initializer:GetName(),'|cnRED_FONT_COLOR:', e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
                return
            end
            ItemButtonUtil.OpenAndFilterBags(ChallengesKeystoneFrame)
            if ItemButtonUtil.GetItemContext() == nil then return end
            local itemLocation = ItemLocation:CreateEmpty()
            for bagID= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do--ContainerFrame.lua
                for slotIndex = 1, ContainerFrame_GetContainerNumSlots(bagID) do
                    itemLocation:SetBagAndSlot(bagID, slotIndex)
                    if ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation) == ItemButtonUtil.ItemContextMatchResult.Match then
                        C_Container.UseContainerItem(bagID, slotIndex)
                        return
                    end
                end
            end
            print(e.addName, CHALLENGE_MODE_KEYSTONE_NAME:format('|cnRED_FONT_COLOR:'..(e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..'|r'))
    end)

    self:HookScript('OnShow', function(self2)
        if Save.hideKeyUI then
            return
        end
        getBagKey(self2, 'BOTTOMRIGHT', -15, 170, self2.keyFrame)--KEY链接
        UI_Party_Info(self2)
        self2.inseSayTips=true--插入, KEY时, 说

        --地下城挑战，分数，超链接
        local dungeonScore = C_ChallengeMode.GetOverallDungeonScore()--DungeonScoreInfoMixin:OnClick() Blizzard_ChallengesUI.lua
        if dungeonScore and dungeonScore>0 then
            local link = GetDungeonScoreLink(dungeonScore, UnitName("player"))
            if not self2.dungeonScoreLink then
                self2.dungeonScoreLink= e.Cstr(self2.keyFrame, {mouse=true, size=16})
                self2.dungeonScoreLink:SetPoint('BOTTOMRIGHT', ChallengesKeystoneFrame, -15, 145)
                self2.dungeonScoreLink:SetScript('OnMouseDown', function(self3, d)
                    if not self3.link then
                        return
                    end
                    if d=='LeftButton' then
                       e.Chat(self3.link, nil, nil)
                    elseif d=='RightButton' then
                        e.Chat(self3.link, nil, true)
                        --if not ChatEdit_InsertLink(self3.link) then
                        --ChatFrame_OpenChat(self3.link)
                    end
                    self3:SetAlpha(0.5)
                end)
                self2.dungeonScoreLink:SetScript('OnEnter', function(self3)
                    self3:SetAlpha(0.7)
                    e.tips:SetOwner(self3, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddLine(self3.link)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.onlyChinese and '发送信息' or SEND_MESSAGE, e.Icon.left)
                    e.tips:AddDoubleLine(e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, e.Icon.right)
                    e.tips:Show()
                end)
                self2.dungeonScoreLink:SetScript('OnLeave', function(self3)
                    self3:SetAlpha(1)
                    e.tips:Hide()
                end)
                self2.dungeonScoreLink:SetScript('OnMouseUp', function(self3)
                    self3:SetAlpha(0.7)
                end)
            end
            self2.dungeonScoreLink.link= link
            self2.dungeonScoreLink:SetText(e.GetKeystoneScorsoColor(dungeonScore))
        end
    end)

    if self.DungeonName then
        self.DungeonName:ClearAllPoints()
        self.DungeonName:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 15, 110)
        self.DungeonName:SetJustifyH('LEFT')
    end
    if self.TimeLimit then
        self.TimeLimit:ClearAllPoints()
        self.TimeLimit:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -15, 120)
        self.TimeLimit:SetJustifyH('RIGHT')
    end

    --##############
    --插入, KEY时, 说
    --##############
    local check= CreateFrame("CheckButton", nil, self.keyFrame, "InterfaceOptionsCheckButtonTemplate")--插入, KEY时, 说
    check:SetPoint('RIGHT', self.ins, 'LEFT')
    check:SetChecked(Save.slotKeystoneSay)
    check:SetAlpha(0.5)
    check:SetScript('OnMouseDown', function()
        Save.slotKeystoneSay= not Save.slotKeystoneSay and true or nil
    end)
    check:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '插入' or  COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN, '|A:transmog-icon-chat:0:0|a'..(e.onlyChinese and '说' or SAY))
        e.tips:Show()
        self2:SetAlpha(1)
    end)
    check:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
    hooksecurefunc(self, 'OnKeystoneSlotted',function(self2)--插入, KEY时, 说
        if not Save.slotKeystoneSay or not C_ChallengeMode.HasSlottedKeystone() or not self2.inseSayTips then
            return
        end
        local mapChallengeModeID, affixes, powerLevel = C_ChallengeMode.GetSlottedKeystoneInfo()
        if not mapChallengeModeID then
            return
        end
        local name,_, timeLimit= C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
        if not name then
            return
        end
        local journalInstanceID= e.ChallengesSpellTabs[mapChallengeModeID] and e.ChallengesSpellTabs[mapChallengeModeID].ins
        if journalInstanceID then
            name = select(8, EJ_GetInstanceInfo(journalInstanceID)) or name
        end
        local m= name..'('.. powerLevel..'): '
        for _,v in pairs(affixes or {}) do
            local name2=C_ChallengeMode.GetAffixInfo(v)
            if name2 then
                m=m..name2..', '
            end
        end
        m=m..e.SecondsToClock(timeLimit)
        e.Chat(m, nil, nil)
        self2.inseSayTips=nil
    end)

    self:HookScript("OnUpdate", function (self2, elapsed)--更新队伍数据
        self.elapsed= (self.elapsed or 0.8) + elapsed
        if self.elapsed > 0.8 then
            self.elapsed=0
            UI_Party_Info(self2)
        end
        local inse= C_ChallengeMode.HasSlottedKeystone()
        self2.ins:SetEnabled(not inse)
        self2.clear:SetEnabled(inse)
    end)


    self.countdown = CreateFrame("Button",nil, self.keyFrame, 'UIPanelButtonTemplate')--倒计时7秒
    self.countdown:SetText((e.onlyChinese and '倒计时' or PLAYER_COUNTDOWN_BUTTON)..' 7')
    self.countdown:SetPoint('TOP', self, 'BOTTOM',100, 5)
    self.countdown:SetSize(150,24)
    self.countdown:SetScript("OnMouseDown",function()
        C_PartyInfo.DoCountdown(7)
    end)
    self.countdown2 = CreateFrame("Button",nil, self.keyFrame, 'UIPanelButtonTemplate')--倒计时7秒
    self.countdown2:SetText((e.onlyChinese and '取消' or CANCEL)..' 0')
    self.countdown2:SetPoint('TOP', self, 'BOTTOM',-100, 5)
    self.countdown2:SetSize(100,24)
    self.countdown2:SetScript("OnMouseDown",function()
        C_PartyInfo.DoCountdown(0)
        e.Chat(e.Player.cn and '停止! 停止! 停止!' or 'Stop! Stop! Stop!', nil, nil)
    end)
    self.countdown2:SetScript('OnLeave', GameTooltip_Hide)
    self.countdown2:SetScript('OnEnter', function(frame)
        e.tips:SetOwner(frame, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(' ', '|A:transmog-icon-chat:0:0|a'..(e.Player.cn and '停止! 停止! 停止!' or 'Stop! Stop! Stop!'))
        e.tips:Show()
    end)
end






















--##################
--史诗钥石地下城, 界面
--词缀日程表AngryKeystones Schedule.lua
local function Init_Affix()
    if --C_AddOns.IsAddOnLoaded("AngryKeystones")
        not e.Player.levelMax
        or not affixSchedule
        or TipsFrame.affixesButton
        --or C_MythicPlus.GetCurrentSeason()~= affixSchedule.season
    then
        affixSchedule=nil
        return
    end
    local currentWeek
    local max= 0
    local currentAffixes = C_MythicPlus.GetCurrentAffixes()
    if currentAffixes then
        for index, affixes in ipairs(affixSchedule) do
            if not currentWeek then
                local matches = 0
                for _, affix in ipairs(currentAffixes) do
                    if affix.id == affixes[1] or affix.id == affixes[2] or affix.id == affixes[3] then
                        matches = matches + 1
                    end
                end
                if matches >= 3 then
                    currentWeek = index
                end
            end
            max=max+1
        end
    end

    if not currentWeek then
        affixSchedule=nil
        return
    end

    local one= currentWeek+1
    one= one>max and 1 or one
    --[[local due= one+1
        due= due>max and 1 or due
    local tre= due+1
        tre= tre>max and 1 or tre]]

    --local affixs={affixSchedule[one], affixSchedule[due], affixSchedule[tre]}
    --for index, tab in pairs(affixs) do
    for i=1, 3 do
        local btn= WoWTools_ButtonMixin:Cbtn(TipsFrame, {size={22,22}, isType2=true, icon='hide'})--建立 Affix 按钮
        local affixID= affixSchedule[one][i]
        btn.affixInfo= affixID
        btn:SetSize(24, 24)
        btn.Border= btn:CreateTexture(nil, "BORDER")
        btn.Border:SetAllPoints()
        btn.Border:SetAtlas("ChallengeMode-AffixRing-Sm")
        btn.Portrait = btn:CreateTexture(nil, "BACKGROUND")
        btn.Portrait:SetAllPoints(btn.Border)
        local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID);
        SetPortraitToTexture(btn.Portrait, filedataid)--btn.SetUp = ScenarioChallengeModeAffixMixin.SetUp
        btn:SetScript("OnEnter", ChallengesKeystoneFrameAffixMixin.OnEnter)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        btn.affixID = affixID
        btn:SetPoint('TOP', ChallengesFrame.WeeklyInfo.Child.AffixesContainer, 'BOTTOM', ((i-1)*24)-24, -3)---((index-1)*24))

        if i==1 then
            local label= e.Cstr(btn)
            label:SetPoint('RIGHT', btn, 'LEFT')
            label:SetText(one)
            --if index==1 then
            --label:SetTextColor(0,1,0)
            label:EnableMouse(true)
            label.affixSchedule= affixSchedule
            label.currentWeek= currentWeek
            label.max= max
            label:SetScript('OnLeave', function(self) self:SetAlpha(1) end)
            label:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(Initializer:GetName())
                e.tips:AddLine(' ')
                for idx=1, self.max do
                    local tab= self.affixSchedule[idx]
                    local text=''
                    for i2=1, 3 do
                        local affixID= tab[i2]
                        local name, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
                        text= text..'|T'..filedataid..':0|t'..e.cn(name)..'  '
                    end
                    local col= idx==self.currentWeek and '|cnGREEN_FONT_COLOR:' or (select(2, math.modf(idx/2))==0 and '|cffff8200') or '|cffffffff'
                    e.tips:AddLine(col..(idx<10 and '  ' or '')..idx..') '..text)
                end
                e.tips:Show()
                self:SetAlpha(0.3)
            end)
            --end
        end
    end
    --end
    --ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:ClearAllPoints()
    --ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetPoint('BOTTOM', 0, -12)
end


local function GetNum(mapID, all)--取得完成次数,如 1/10
    local nu, to=0,0
    local info
    if all then
        info=C_MythicPlus.GetRunHistory(true, true) or {}--全部
    else
        info=C_MythicPlus.GetRunHistory(false, true) or {}--本周
    end
    for _,v in pairs(info) do
        if v.mapChallengeModeID==mapID then
            if v.completed then
                nu=nu+1
            end
            to=to+1
        end
    end
    if to>0 then
        return '|cff00ff00'..nu..'|r/'..to, nu, to
    end
end

















--所以角色信息
--###########
local function create_lable(btn, point, text, col, size)
    if not text or text=='' then
        return
    end
    local label= e.Cstr(btn, {size=size or 10, mouse=true, color=col})
    if point==1 then
        label:SetPoint('TOPRIGHT', btn, 'TOPLEFT')
    elseif point==2 then
        label:SetPoint('RIGHT', btn, 'LEFT')
    elseif point==3 then
        label:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMLEFT')
    elseif point=='b' then
        label:SetPoint('BOTTOM')
    elseif point=='l' then
        label:SetPoint('TOPLEFT')
        label.num= text
    elseif point=='r' then
        label:SetPoint('TOPRIGHT')
    end

    label:SetText(text)
    label.point= point
    label:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
    label:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(
            self.point==1 and (e.onlyChinese and '团队副本' or RAIDS)
            or self.point==2 and (e.onlyChinese and '地下城' or DUNGEONS)
            or self.point==3 and PVP
            or self.point=='b' and (e.onlyChinese and '史诗钥石评分' or DUNGEON_SCORE)
            or self.point=='l' and (e.onlyChinese and '本周次数' or format(CURRENCY_THIS_WEEK, format(ARCHAEOLOGY_COMPLETION,self.num)))
            or self.point=='r' and (e.onlyChinese and '本周最高等级' or format(CURRENCY_THIS_WEEK, BEST))
        )
        e.tips:AddLine('|cffffffff'..(self:GetText() or ''))
        e.tips:Show()
        self:SetAlpha(0.5)
    end)
end
local function All_Player_Info()--所以角色信息   
    local last
    for guid, info in pairs(e.WoWDate) do--[e.Player.guid].Keystone
        local link= info.Keystone.link
        if link and guid~=e.Player.guid then
            local _, englishClass, _, _, _, namePlayer, realm = GetPlayerInfoByGUID(guid)
            if namePlayer and namePlayer~='' then
                local classColor = englishClass and C_ClassColor.GetClassColor(englishClass)
                local btn= WoWTools_ButtonMixin:Cbtn(TipsFrame, {size={30,30}, atlas=e.GetUnitRaceInfo({guid=guid, reAtlas=true})})
                if not last then
                    btn:SetPoint('TOPRIGHT', ChallengesFrame, 'TOPLEFT', -4, 0)
                else
                    btn:SetPoint('TOPRIGHT', last, 'BOTTOMRIGHT')
                end

                btn.link=link
                function btn:set_tooltips(frame)
                    e.tips:SetOwner(frame, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetHyperlink(self.link)
                    e.tips:Show()
                    frame:SetAlpha(0.3)
                end
                btn:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
                btn:SetScript('OnEnter', function(self)
                    self:set_tooltips(self)
                end)

                local score= e.GetKeystoneScorsoColor(info.Keystone.score, false, nil)
                local weekNum= info.Keystone.weekNum and info.Keystone.weekNum>0 and info.Keystone.weekNum
                local weekLevel= info.Keystone.weekLevel and info.Keystone.weekLevel>0 and info.Keystone.weekLevel
                create_lable(btn, 1, info.Keystone.weekPvE, classColor)--团队副本
                create_lable(btn, 2, info.Keystone.weekMythicPlus, classColor)--挑战
                create_lable(btn, 3, info.Keystone.weekPvP, classColor)--pvp
                create_lable(btn, 'b', score, {r=1,g=1,b=1}, 12)--分数
                create_lable(btn, 'l', weekNum, {r=1,g=1,b=1})--次数
                create_lable(btn, 'r', weekLevel, {r=1,g=1,b=1})--次数

                if e.onlyChinese then--取得中文，副本名称
                    local mapID, name= link:match('|Hkeystone:%d+:(%d+):.+%[(.+) %(%d+%)]')
                    mapID= mapID and tonumber(mapID)
                    if mapID and name and e.ChallengesSpellTabs[mapID] and e.ChallengesSpellTabs[mapID].name then
                        link= link:gsub(name, e.ChallengesSpellTabs[mapID].name)
                    end
                end
                local nameLable= e.Cstr(btn, {color= classColor})--名字
                nameLable:SetPoint('TOPRIGHT', btn, 'BOTTOMRIGHT')
                nameLable:SetText(
                    (namePlayer or '')
                    ..((realm and realm~='') and '-'..realm or '')
                    ..(e.Class(nil, englishClass) or '')
                    ..(e.GetUnitFaction(nil, info.faction, false) or '')
                )

                local keyLable= e.Cstr(btn, {mouse=true})--KEY
                keyLable:SetPoint('RIGHT', nameLable, 'LEFT')
                keyLable:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
                keyLable:SetScript('OnEnter', function(self)
                    self:GetParent():set_tooltips(self)
                end)
                keyLable:SetText(link)

                last= nameLable
            end
        end
    end
end
























local function set_All_Text()--所有记录
    --###
    --历史
    --####
    local last
    if not ChallengesFrame.runHistoryLable then
        ChallengesFrame.runHistoryLable= e.Cstr(TipsFrame, {mouse=true, size=14})--最右边, 数据
        ChallengesFrame.moveRightTipsButton= WoWTools_ButtonMixin:Cbtn(TipsFrame, {size={22,22}, atlas='common-icon-rotateright'})
        ChallengesFrame.moveRightTipsButton:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
        ChallengesFrame.moveRightTipsButton:SetPoint('TOP', PVEFrameCloseButton, 'BOTTOM', -8, 0)
        ChallengesFrame.moveRightTipsButton:SetAlpha(0.3)
        function ChallengesFrame.moveRightTipsButton:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.addName, Initializer:GetName())
            e.tips:AddLine(' ')
            e.tips:AddLine(e.onlyChinese and '移动' or BUTTON_LAG_MOVEMENT)
            e.tips:AddDoubleLine('x: '..Save.rightX, 'Shift+'..e.Icon.mid)
            e.tips:AddDoubleLine('y: '..Save.rightY, 'Alt+'..e.Icon.mid)
            e.tips:Show()
            self:SetAlpha(1)
        end
        ChallengesFrame.moveRightTipsButton:SetScript('OnLeave', function(self) self:SetAlpha(0.3) GameTooltip_Hide() end)
        ChallengesFrame.moveRightTipsButton:SetScript('OnEnter', ChallengesFrame.moveRightTipsButton.set_tooltips)
        function ChallengesFrame.moveRightTipsButton:set_point()
            ChallengesFrame.runHistoryLable:ClearAllPoints()
            ChallengesFrame.runHistoryLable:SetPoint('TOPLEFT', ChallengesFrame, 'TOPRIGHT', Save.rightX, Save.rightY)
        end
        ChallengesFrame.moveRightTipsButton:SetScript('OnMouseWheel', function(self, d)
            local x= Save.rightX
            local y= Save.rightY
            if IsShiftKeyDown() then
                x= d==1 and x+5 or x-5
            elseif IsAltKeyDown() then
                y= d==1 and y+5 or y-5
            end
            Save.rightX= x
            Save.rightY= y
            self:set_point()
            self:set_tooltips()
        end)
        ChallengesFrame.moveRightTipsButton:set_point()


        ChallengesFrame.runHistoryLable:SetScript('OnLeave', function(self2) self2:SetAlpha(1) end)
        ChallengesFrame.runHistoryLable:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()

            local curMaps = {}
            for _, v in pairs( (C_ChallengeMode.GetMapTable() or {})) do
                curMaps[v]=true
            end

            local tabs={}
            local completed, all= 0,0
            for _, info in pairs(C_MythicPlus.GetRunHistory(true, true) or {}) do
                local mapID=info.mapChallengeModeID
                tabs[mapID]= tabs[mapID] or
                            {
                                level=0,--最高等级
                                c=0,
                                t=0,
                                mapID= mapID,
                                isCurrent= curMaps[mapID],--本赛季
                            }
                tabs[mapID].t= tabs[mapID].t+1
                if info.completed then
                    tabs[mapID].c= tabs[mapID].c+1
                    tabs[mapID].level= (info.level and info.level>tabs[mapID].level) and info.level or tabs[mapID].level
                    completed= completed+ 1
                end
                all= all+1
            end

            local newTab={}
            for _, tab in pairs(tabs) do
                if tab.isCurrent then
                    table.insert(newTab, tab)
                else
                    table.insert(newTab, 1, tab)
                end
            end
            e.tips:AddDoubleLine(e.onlyChinese and '历史' or HISTORY, completed..'/'..all)

            for _, tab in pairs(newTab) do
                local name, _, _, texture= C_ChallengeMode.GetMapUIInfo(tab.mapID)
                if name then
                    if e.onlyChinese and not LOCALE_zhCN then
                        name= e.ChallengesSpellTabs[tab.mapID] and e.ChallengesSpellTabs[tab.mapID].name or name
                    end
                    local text= (texture and '|T'..texture..':0|t' or '').. name..' ('..tab.level..') '
                    local text2= tab.c..'/'..tab.t
                    if tab.isCurrent then
                        local bestOverAllScore = select(2, C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(tab.mapID)) or 0
                        local score, col= e.GetKeystoneScorsoColor(bestOverAllScore, nil, true)
                        text= (col and col:WrapTextInColorCode(text) or text)..score
                        text2= col and col:WrapTextInColorCode(text2) or text2
                    else
                        text='|cff828282'..text
                        text2='|cff828282'..text2
                    end
                    e.tips:AddDoubleLine(text, text2)
                end
            end
            e.tips:Show()
            self2:SetAlpha(0.5)
        end)
    end
    ChallengesFrame.runHistoryLable:SetText(
        (e.onlyChinese and '历史' or HISTORY)
        ..' |cff00ff00'..#C_MythicPlus.GetRunHistory(true)
        ..'|r/'..#C_MythicPlus.GetRunHistory(true, true)
    )
    last= ChallengesFrame.runHistoryLable



    --#######
    --本周记录
    --#######
    local completed, all= 0,0
    local tabs={}
    for _, tab in pairs(C_MythicPlus.GetRunHistory(false, true) or {}) do
        local mapID= tab.mapChallengeModeID
        if tab and tab.level and mapID and mapID>0 and tab.thisWeek then
            if not tabs[mapID] then
                tabs[mapID]={
                    LV={},--{level, completed}
                    runScore= 0,--分数
                    c=0,
                    t=0,
                    completed=false,
                    mapID= mapID,
                }
            end

            tabs[mapID].runScore= (tab.runScore and tab.runScore> tabs[mapID].runScore) and tab.runScore or tabs[mapID].runScore

            table.insert(tabs[mapID].LV, {
                level=tab.level,
                text=tab.completed and '|cff00ff00'..tab.level..'|r' or '|cff828282'..tab.level..'|r'})

            if tab.completed then
                completed= completed+1
                tabs[mapID].c= tabs[mapID].c +1
            end
            tabs[mapID].t=tabs[mapID].t+1
            all= all+1
        end
    end

    local newTab={}
    for _, tab in pairs(tabs) do
        table.insert(newTab, tab)
    end
    table.sort(newTab, function(a, b)  return a.runScore> b.runScore end)


    local weekText
    for _, tab in pairs(newTab) do
        local name, _, _, texture = C_ChallengeMode.GetMapUIInfo(tab.mapID)
        if name then
            if e.onlyChinese then
                name= e.ChallengesSpellTabs[tab.mapID] and e.ChallengesSpellTabs[tab.mapID].name or name
            end
            weekText= weekText and weekText..'|n' or ''
            local bestOverAllScore = select(2, C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(tab.mapID)) or 0
            local score= e.GetKeystoneScorsoColor(bestOverAllScore, nil, true)

            weekText= weekText..(texture and '|T'..texture..':0|t' or '')
                    ..(tab.c>0 and '|cff00ff00' or '|cff828282')..tab.c..'|r/'..tab.t
                    ..' '..score..' '..name--(col and col:WrapTextInColorCode(name) or name)
            table.sort(tab.LV, function(a, b) return a.level> b.level end)
            for _,v2 in pairs(tab.LV) do
                weekText= weekText..' '..v2.text
            end
        end
    end
    if not ChallengesFrame.weekCompledLabel then
        ChallengesFrame.weekCompledLabel= e.Cstr(TipsFrame)--最右边, 数据
        ChallengesFrame.weekCompledLabel:SetPoint('TOPLEFT', last, 'BOTTOMLEFT')
    end
    ChallengesFrame.weekCompledLabel:SetText(
        (e.onlyChinese and '本周' or CHALLENGE_MODE_THIS_WEEK)
        ..' |cff00ff00'..completed..'|r/'..all--.. ' '..(e.Get_Week_Rewards_Text(1) or '')
        ..(weekText and '|n'..weekText or '')
    )
    last= ChallengesFrame.weekCompledLabel


    --#############
    --难度 每周 掉落
    --#############
    if not ChallengesFrame.weekLootItemLevelLable then
        ChallengesFrame.weekLootItemLevelLable= e.Cstr(TipsFrame, {mouse=true})--最右边, 数据
        ChallengesFrame.weekLootItemLevelLable:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0,-12)
        function ChallengesFrame.weekLootItemLevelLable:get_Loot_itemLevel(level)
            --local col= self.curLevel==level and '|cff00ff00' or (select(2, math.modf(level/2))==0 and '|cffff8200') or '|cffffffff'
            local weeklyRewardLevel2 = C_MythicPlus.GetRewardLevelForDifficultyLevel(level)
            weeklyRewardLevel2= max(weeklyRewardLevel2, 2)
            weeklyRewardLevel2= min(weeklyRewardLevel2, LimitMaxKeyLevel)
            local week= level..') '..(Get_Week_Item_Level(level) or '')
            local curkey= self.curKey==level and '|T4352494:0|t' or ''
            local curLevel= self.curLevel==level and format('|A:%s:0:0|a', e.Icon.select) or ''
            return week..curkey..curLevel
        end
        ChallengesFrame.weekLootItemLevelLable:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
        ChallengesFrame.weekLootItemLevelLable:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(self:GetText())
            for level=2, LimitMaxKeyLevel do--限制，显示等级                
                e.tips:AddLine(self:get_Loot_itemLevel(level))
            end
            e.tips:Show()
            self:SetAlpha(0.5)
        end)
    end
    ChallengesFrame.weekLootItemLevelLable:SetText(e.onlyChinese and '难度 每周 掉落' or (PROFESSIONS_CRAFTING_STAT_TT_DIFFICULTY_HEADER..' '..CALENDAR_REPEAT_WEEKLY..' '..LOOT))

    local lootText

    --限制，显示等级
    local curLevel=0
    local curKey= C_MythicPlus.GetOwnedKeystoneLevel() or 0
    local runInfo = C_MythicPlus.GetRunHistory(false, true) or {}--本周记录
    for _, runs  in pairs(runInfo) do
        curLevel= runs and runs.level and runs.level>curLevel and runs.level or curLevel
    end
    curLevel= max(curLevel, curKey)
    local minNum= max(2, curLevel-3)
    local maxNum = min(curLevel+3, LimitMaxKeyLevel)

    ChallengesFrame.weekLootItemLevelLable.curLevel= curLevel
    ChallengesFrame.weekLootItemLevelLable.curKey= curKey

    for level=minNum, maxNum do--显示，物品等级
        local text= ChallengesFrame.weekLootItemLevelLable:get_Loot_itemLevel(level)
        if text then
            lootText= lootText and lootText..'|n'..text or text
        end
    end

    if not ChallengesFrame.weekLootItemLevelLable2 then
        ChallengesFrame.weekLootItemLevelLable2= e.Cstr(TipsFrame)--最右边, 数据
        ChallengesFrame.weekLootItemLevelLable2:SetPoint('TOPLEFT', ChallengesFrame.weekLootItemLevelLable, 'BOTTOMLEFT')
    end
    ChallengesFrame.weekLootItemLevelLable2:SetText(lootText or '')
    last= ChallengesFrame.weekLootItemLevelLable2


    --##########
    --所有角色KEY
    --[[##########
    local keyText
    for guid, info in pairs(e.WoWDate or {}) do
        if guid~=e.Player.guid and info.Keystone.link then
            local icon= C_Item.GetItemIconByID(info.Keystone.link)
            --|Hkeystone:180653:244:2:10:0:0:0|h[Chiave del Potere: Atal'dazar (2)]|h
            local link= info.Keystone.link
            if e.onlyChinese and not LOCALE_zhCN then
                --  ( ) . % + - * ? [ ^ $
                local mapID, name= link:match('|Hkeystone:%d+:(%d+):.+%[(.+) %(%d+%)]')
                mapID= mapID and tonumber(mapID)
                if mapID and name and e.ChallengesSpellTabs[mapID] and e.ChallengesSpellTabs[mapID].name then
                    link= link:gsub(name, e.ChallengesSpellTabs[mapID].name)
                end
            end

            keyText= (keyText and keyText..'|n' or '')
                .. (info.Keystone.weekNum or 0)
                .. (info.Keystone.weekMythicPlus and ' |cnGREEN_FONT_COLOR:('..info.Keystone.weekMythicPlus..') ' or '')
                ..e.GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true})
                ..' |T'..((not icon or icon==134400) and 4352494 or icon)..':0|t'..link--info.Keystone.link
            ..(info.Keystone.score and ' ' or '')..(e.GetKeystoneScorsoColor(info.Keystone.score))
       end
    end

    if not ChallengesFrame.playerAllKey then
        ChallengesFrame.playerAllKey= e.Cstr(TipsFrame)--最右边, 数据
        ChallengesFrame.playerAllKey:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0,-12)
    end
    ChallengesFrame.playerAllKey:SetText(keyText or '')
    last=ChallengesFrame.playerAllKe]]

    --物品，货币提示
    e.ItemCurrencyLabel({frame=TipsFrame, point={'TOPLEFT', last, 'BOTTOMLEFT',0, -12}})
    last=nil
end


























local function set_Update()--Blizzard_ChallengesUI.lua
    local self= ChallengesFrame
    if not self.maps or #self.maps==0 then
        return
    end

    local currentChallengeMapID= C_MythicPlus.GetOwnedKeystoneChallengeMapID()--当前, KEY地图,ID
    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()--当前KEY，等级




    for i=1, #self.maps do
        local frame = self.DungeonIcons[i]
        if frame and frame.mapID then
            local insTab=e.ChallengesSpellTabs[frame.mapID] or {}
            frame.spellID= insTab.spell
            frame.journalInstanceID= insTab.ins
            if not frame.setTips then
                frame:HookScript('OnEnter', function(self2)--提示
                    if not self2.mapID or Save.hideIns then
                        return
                    end
                    local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self2.mapID)
                    if intimeInfo then
                        e.tips:AddLine(' ')
                        for index, info in pairs(intimeInfo.members) do
                            if info.name then
                                if index==1 then
                                    if intimeInfo.completionDate and intimeInfo.level then--完成,日期
                                        local d=intimeInfo.completionDate
                                        local time= format('|cnGREEN_FONT_COLOR:%s:%s %d/%d/%d %s', d.hour<10 and '0'..d.hour or d.hour, d.minute<10 and '0'..d.minute or d.minute, d.day, d.month, d.year, '('..intimeInfo.level..')')
                                        local time2
                                        if overtimeInfo and overtimeInfo.completionDate and overtimeInfo.level then
                                            d=overtimeInfo.completionDate
                                            time2= format('|cffff0000%s %s:%s %d/%d/%d', '('..overtimeInfo.level..')', d.hour<10 and '0'..d.hour or d.hour, d.minute<10 and '0'..d.minute or d.minute, d.day, d.month, d.year)
                                        end
                                        e.tips:AddDoubleLine(time, time2)
                                    end
                                end

                                local text, text2= '', nil
                                if info.specID then
                                    local icon, role= select(4, GetSpecializationInfoByID(info.specID))
                                    text= e.Icon[role]..'|T'..icon..':0|t'
                                end
                                text= info.name== e.Player.name and text..info.name..'|A:auctionhouse-icon-favorite:0:0|a' or text..info.name
                                if info.classID then
                                    local classFile= select(2, GetClassInfo(info.classID))
                                    local argbHex = classFile and select(4, GetClassColor(classFile))
                                    if argbHex then
                                        text= '|c'..argbHex..text..'|r'
                                    end
                                end
                                if overtimeInfo and overtimeInfo.members and overtimeInfo.members[index] and overtimeInfo.members[index].name then
                                    local info2= overtimeInfo.members[index]
                                    text2= info2.name== e.Player.name and ('|A:auctionhouse-icon-favorite:0:0|a'..info2.name) or info2.name
                                    if info2.specID then
                                        local icon, role= select(4, GetSpecializationInfoByID(info.specID))
                                        text2= text2..'|T'..icon..':0|t'..e.Icon[role]
                                    end
                                    if info2.classID then
                                        local classFile= select(2, GetClassInfo(info2.classID))
                                        local argbHex = classFile and select(4, GetClassColor(classFile))
                                        if argbHex then
                                            text2= '|c'..argbHex..text2..'|r'
                                        end
                                    end
                                end
                                e.tips:AddDoubleLine(text, text2)

                                if index==#intimeInfo.members and intimeInfo.affixIDs then
                                    local affix, affix2='', ''
                                    for index2, v in pairs(intimeInfo.affixIDs) do
                                        local filedataid = select(3, C_ChallengeMode.GetAffixInfo(v))
                                        if filedataid then
                                            affix= affix.. '|T'..filedataid..':0|t'
                                        end
                                        if overtimeInfo and overtimeInfo.affixIDs and overtimeInfo.affixIDs[index2] then
                                            filedataid = select(3, C_ChallengeMode.GetAffixInfo(overtimeInfo.affixIDs[index2]))
                                            if filedataid then
                                                affix2= affix2.. '|T'..filedataid..':0|t'
                                            end
                                        end
                                    end
                                    if affix ~='' then
                                        e.tips:AddDoubleLine(affix, affix2)
                                    end
                                end
                            end
                        end
                    end

                    e.tips:AddLine(' ')
                    local timeLimit, texture, backgroundTexture = select(3, C_ChallengeMode.GetMapUIInfo(self2.mapID))
                    local a=GetNum(self2.mapID, true) or RED_FONT_COLOR_CODE..(e.onlyChinese and '无' or NONE)..'|r'--所有
                    local w=GetNum(self2.mapID) or RED_FONT_COLOR_CODE..(e.onlyChinese and '无' or NONE)..'|r'--本周
                    e.tips:AddDoubleLine((e.onlyChinese and '历史' or HISTORY)..': '..a, (e.onlyChinese and '本周' or CHALLENGE_MODE_THIS_WEEK)..': '..w)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine('mapChallengeModeID |cnGREEN_FONT_COLOR:'.. self2.mapID..'|r', timeLimit and (e.onlyChinese and '限时' or GROUP_FINDER_PVE_PLAYSTYLE3)..' '.. SecondsToTime(timeLimit))
                    if texture and backgroundTexture then
                        e.tips:AddDoubleLine('|T'..texture..':0|t'..texture, '|T'..backgroundTexture..':0|t'..backgroundTexture)
                    end
                    e.tips:Show()
                end)

                --[[if e.Player.husandro then
                    frame:EnableMouse(true)
                    frame:SetScript('OnMouseDown', function(self2)
                        e.call(EncounterJournal_LoadUI)
                        
                        if self2.journalInstanceID and EncounterJournal then
                            ToggleEncounterJournal()
                            --EncounterJournal_OpenJournal([difficultyID, instanceID, encounterID, sectionID, creatureID, itemID, tierIndex])
                            EncounterJournal_TierDropDown_Select(nil, 11)
                           -- EncounterJournal_OpenJournal(DifficultyUtil.ID.DungeonChallenge, self2.journalInstanceID);
                        end
                    end)
                end]]

                frame.setTips=true
            end

             --#########
            --名称, 缩写
            --#########
            local nameText = not Save.hideIns and C_ChallengeMode.GetMapUIInfo(frame.mapID)--名称
            if nameText then
                if not frame.nameLable then
                    frame.nameLable=e.Cstr(frame, {size=10, mouse= true, justifyH='CENTER'})
                    frame.nameLable:SetPoint('BOTTOM', frame, 'TOP', 0, 3)
                    frame.nameLable:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
                    frame.nameLable:SetScript('OnEnter', function(self2)
                        if self2.name then
                            e.tips:SetOwner(self2:GetParent(), "ANCHOR_LEFT")
                            e.tips:ClearLines()
                            e.tips:AddLine(self2.name..' ')
                            e.tips:Show()
                        end
                        self2:SetAlpha(0.5)
                    end)
                end
                frame.nameLable.name= nameText
                --  ( ) . % + - * ? [ ^ $
                if (e.onlyChinese or LOCALE_zhCN) and e.ChallengesSpellTabs[frame.mapID] then
                    nameText= e.ChallengesSpellTabs[frame.mapID].name
                else
                    nameText=nameText:match('%((.+)%)') or nameText
                    nameText=nameText:match('%（(.+)%）') or nameText
                    nameText=nameText:match('%- (.+)') or nameText
                    nameText=nameText:match(HEADER_COLON..'(.+)') or nameText
                    nameText=nameText:match('·(.+)') or nameText
                    nameText=e.WA_Utf8Sub(nameText, 5, 12)
                end
                frame.nameLable:SetScale(Save.insScale or 1)
            end
            if frame.nameLable then
                frame.nameLable:SetText(nameText or '')
            end

            --######### BUG
            --名称, 缩写
            --[[#########
            local nameText = not Save.hideIns and C_ChallengeMode.GetMapUIInfo(frame.mapID)--名称
            if nameText then
                if not frame.nameFrame then
                    frame.nameFrame=CreateFrame('Frame', nil, frame)
                    frame.nameFrame:SetHyperlinksEnabled(true)
                    frame.nameFrame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
                    frame.nameFrame.Text= e.Cstr(frame.nameFrame, {size=10, mouse= true, justifyH='CENTER'})
                    frame.nameFrame.Text:SetPoint('BOTTOM', frame, 'TOP', 0, 3)
                    frame.nameFrame:SetAllPoints(frame.nameFrame.Text)
                    --frame.nameFrame.Text:HookScript('OnMouseDown', function(self2) self2:SetAlpha(0) end)
                    --frame.nameFrame.Text:HookScript('OnMouseUp', function(self2) self2:SetAlpha(0.5) end)
                    frame.nameFrame.Text:HookScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
                    frame.nameFrame.Text:HookScript('OnEnter', function(self2)
                        if not self2.name then
                            return
                        end
                        e.tips:SetOwner(self2, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddLine(self2.name..(self2:GetParent().link and e.Icon.left or ' '))--加空，去掉，翻译
                        local text= self2:GetText()
                        if text~=self2.name then
                            e.tips:AddLine(text)
                        end
                        e.tips:Show()
                        self2:SetAlpha(0.5)
                    end)
                end
                frame.nameFrame.Text.name= nameText

                if (e.onlyChinese or LOCALE_zhCN) and e.ChallengesSpellTabs[frame.mapID] then
                    nameText= e.ChallengesSpellTabs[frame.mapID].name
                else
                    nameText=nameText:match('%((.+)%)') or nameText
                    nameText=nameText:match('%（(.+)%）') or nameText
                    nameText=nameText:match('%- (.+)') or nameText
                    nameText=nameText:match(HEADER_COLON..'(.+)') or nameText
                    nameText=nameText:match('·(.+)') or nameText
                    nameText=e.WA_Utf8Sub(nameText, 5, 12)
                end
                frame.nameFrame.Text:SetScale(Save.insScale or 1)
                frame.nameFrame.link= frame.journalInstanceID and select(8, EJ_GetInstanceInfo(frame.journalInstanceID))
                if frame.nameFrame.link then
                    nameText= frame.nameFrame.link:gsub('%[(.-)]', nameText)
                end
                
            end
            if frame.nameFrame then
                frame.nameFrame.Text:SetText(nameText or '')
            end]]


            --#########
            --分数，最佳
            --#########
            local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(frame.mapID)
            local affixScores, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(frame.mapID)
            if (overAllScore and intimeInfo or overtimeInfo) then
                if not frame.scoreLable then--分数
                    frame.scoreLable=e.Cstr(frame, {size=10, mouse=true})
                    frame.scoreLable:SetPoint('BOTTOMLEFT', frame, 0, 24)
                    frame.scoreLable:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
                    frame.scoreLable:SetScript('OnEnter', function(self2)
                        if self2.score then
                            e.tips:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                            e.tips:ClearLines()
                            e.tips:AddLine(format(e.onlyChinese and '史诗钥石评分：%s' or CHALLENGE_COMPLETE_DUNGEON_SCORE, self2.score))
                            e.tips:Show()
                            self2:SetAlpha(0.5)
                        end
                    end)

                    --###########
                    --移动层数位置
                    --###########
                    if frame.HighestLevel then
                        frame.HighestLevel:ClearAllPoints()
                        frame.HighestLevel:SetPoint('LEFT', 0, 12)
                        frame.HighestLevel:EnableMouse(true)
                        frame.HighestLevel:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
                        frame.HighestLevel:SetScript('OnEnter', function(self2)
                            e.tips:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                            e.tips:ClearLines()
                            e.tips:AddLine(format(e.onlyChinese and '最佳%s' or DUNGEON_SCORE_BEST_AFFIX, (e.onlyChinese and '等级' or LEVEL)..': '..self2:GetText()))
                            e.tips:Show()
                            self2:SetAlpha(0.5)
                        end)
                    end
                end
                frame.scoreLable:SetText((overAllScore and not Save.hideIns) and '|A:AdventureMapIcon-MissionCombat:16:16|a'..e.GetKeystoneScorsoColor(overAllScore,nil,true) or '')
                frame.scoreLable.score= overAllScore
                frame.scoreLable:SetScale(Save.insScale or 1)

                if affixScores and #affixScores > 0 then --最佳 
                    local nameA, _, filedataidA = C_ChallengeMode.GetAffixInfo(10)
                    local nameB, _, filedataidB = C_ChallengeMode.GetAffixInfo(9)
                    for _, info in ipairs(affixScores) do
                        local text
                        local label=frame['affixInfo'..info.name]
                        if info.level and info.level>0 and info.durationSec and (info.name == nameA or info.name==nameB) and not Save.hideIns then
                            if not label then
                                label= e.Cstr(frame, {justifyH='RIGHT', mouse=true})
                                if info.name== nameA then
                                    label:SetPoint('BOTTOMLEFT',frame)
                                else
                                    label:SetPoint('BOTTOMLEFT', frame, 0, 12)
                                end
                                label:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
                                label:SetScript('OnEnter', function(self2)
                                    e.tips:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                                    e.tips:ClearLines()
                                    e.tips:AddDoubleLine(format(e.onlyChinese and '最佳%s' or DUNGEON_SCORE_BEST_AFFIX, self2.name),
                                                            self2.overTime and '|cff828282'..format(e.onlyChinese and '%s (超时)' or DUNGEON_SCORE_OVERTIME_TIME, e.SecondsToClock(self2.durationSec)) or e.SecondsToClock(self2.durationSec)
                                                        )
                                    e.tips:Show()
                                    self2:SetAlpha(0.5)
                                end)
                                frame['affixInfo'..info.name]= label
                            end
                            local level= info.overTime and '|cff828282'..info.level..'|r' or info.level
                            local icon='|T'..(info.name == nameA and filedataidA or filedataidB)..':0|t'
                            text= icon..level

                            label.overTime= info.overTime
                            label.durationSec= info.durationSec
                            label.name= icon..info.name..': '..level
                        end
                        if label then
                            label:SetScale(Save.insScale or 1)
                            label:SetText(text or '')
                        end
                    end
                end

                --#####################
                --副本 完成/总次数 (全部)
                --#####################
                local numText
                if not Save.hideIns then
                    local all, completed, totale= GetNum(frame.mapID, true)
                    local week= GetNum(frame.mapID)--本周
                    if all or week then
                        if not frame.completedLable then
                            frame.completedLable=e.Cstr(frame, {mouse=true})
                            frame.completedLable:SetPoint('TOPLEFT', frame)
                            frame.completedLable:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
                            frame.completedLable:SetScript('OnEnter', function(self2)
                                if self2.all or self2.week then
                                    e.tips:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                                    e.tips:ClearLines()
                                    e.tips:AddDoubleLine(
                                        e.onlyChinese and '历史 |cnGREEN_FONT_COLOR:完成|r/总计' or (HISTORY..' |cnGREEN_FONT_COLOR:'..COMPLETE..'|r/'..TOTAL) ,
                                        self2.all or (e.onlyChinese and '无' or NONE)
                                    )
                                    e.tips:AddDoubleLine(e.onlyChinese and '本周' or CHALLENGE_MODE_THIS_WEEK, self2.week and '('..self2.week..')' or (e.onlyChinese and '无' or NONE))
                                    if self2.completed and self2.totale and self2.completed < self2.totale then
                                        e.tips:AddLine(' ')
                                        e.tips:AddDoubleLine(self2.totale..' - |cnGREEN_FONT_COLOR:'..self2.completed..'|r =', '|cnRED_FONT_COLOR:'..format(e.onlyChinese and '%s (超时)' or DUNGEON_SCORE_OVERTIME_TIME, self2.totale-self2.completed))
                                    end
                                    e.tips:Show()
                                    self2:SetAlpha(0.5)
                                end
                            end)
                        end
                        numText= (all or '')..((week and week~=all) and ' |cffffffff(|r'..week..'|cffffffff)|r' or '')
                        frame.completedLable.all=all or week
                        frame.completedLable.week= week
                        frame.completedLable.completed= completed
                        frame.completedLable.totale= totale
                    end
                end
                if frame.completedLable then
                    frame.completedLable:SetScale(Save.insScale or 1)
                    frame.completedLable:SetText(numText or '')
                end
            end

            --################
            --提示, 包里KEY地图
            --################
            local findKey= currentChallengeMapID== frame.mapID and not Save.hideIns or false
            if findKey and not frame.currentKey then--提示, 包里KEY地图
                frame.currentKey= frame:CreateTexture(nil, 'OVERLAY', nil, self:GetFrameLevel()+1)
                frame.currentKey:SetPoint('RIGHT', frame, 0, 8)
                frame.currentKey:SetAtlas('common-icon-checkmark')
                frame.currentKey:SetSize(22,22)
                frame.currentKey:EnableMouse(true)
                frame.currentKey:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) self2.label:SetAlpha(1) end)
                frame.currentKey:SetScript('OnEnter', function(self2)
                    e.tips:SetOwner(self2:GetParent(), "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    local bagID, slotID= select(3, get_Bag_Key())--查找，包的key
                    if bagID and slotID then
                        e.tips:SetBagItem(bagID, slotID)
                    end
                    e.tips:Show()
                    self2:SetAlpha(0.3)
                    self2.label:SetAlpha(0.3)
                end)
                --当前KEY，等级
                frame.currentKey.label=e.Cstr(frame)
                frame.currentKey.label:SetPoint('TOP', frame.currentKey,-2,2)
            end
            if frame.currentKey then
                frame.currentKey:SetScale(Save.insScale or 1)
                frame.currentKey:SetShown(findKey)
                frame.currentKey.label:SetText(keyStoneLevel or '')
            end

            --#####
            --传送门
            --#####
            if not Save.hidePort then
                if frame.spellID then
                    if not frame.spellPort then
                        local h=frame:GetWidth()/3 +8
                        local texture= C_Spell.GetSpellTexture(frame.spellID)
                        frame.spellPort= WoWTools_ButtonMixin:Cbtn(frame, {type=true, size={h, h}, texture=texture, atlas='WarlockPortal-Yellow-32x32', pushe=not texture})
                        frame.spellPort:SetPoint('BOTTOMRIGHT', frame)--, 4,-4)
                        frame.spellPort:SetScript("OnEnter",function(self2)
                            local parent= self2:GetParent()
                            if parent.spellID then
                                e.tips:SetOwner(parent, "ANCHOR_RIGHT")
                                e.tips:ClearLines()
                                e.tips:SetSpellByID(parent.spellID)
                                if not IsSpellKnownOrOverridesKnown(parent.spellID) then--没学会
                                    e.tips:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '法术尚未学会' or SPELL_FAILED_NOT_KNOWN))
                                end
                                e.tips:Show()
                                self2:SetAlpha(1)
                            end
                        end)
                        frame.spellPort:SetScript("OnLeave",function(self2)
                            e.tips:Hide()
                            local spellID=self2:GetParent().spellID
                            self2:SetAlpha(spellID and IsSpellKnownOrOverridesKnown(spellID) and 1 or 0.3)
                        end)
                        frame.spellPort:SetScript('OnHide', function(self2)
                            self2:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
                        end)
                        frame.spellPort:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                        frame.spellPort:SetScript('OnShow', function(self2)
                            self2:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                            e.SetItemSpellCool(self2, {spell=self2:GetParent().spellID})
                        end)
                        frame.spellPort:SetScript('OnEvent', function(self2)
                            e.SetItemSpellCool(self2, {spell=self2:GetParent().spellID})
                        end)
                    end
                end
            end
            if frame.spellPort and frame.spellPort:CanChangeAttribute() then
                if frame.spellID and IsSpellKnownOrOverridesKnown(frame.spellID) then
                    local name= C_Spell.GetSpellName(frame.spellID)
                    frame.spellPort:SetAttribute("type", "spell")
                    frame.spellPort:SetAttribute("spell", name or frame.spellID)
                    frame.spellPort:SetAlpha(1)
                else
                    frame.spellPort:SetAlpha(0.3)
                end
                frame.spellPort:SetShown(not Save.hidePort)
                frame.spellPort:SetScale(Save.portScale or 1)
            end
        end
    end

    --[[if ChallengesFrame.WeeklyInfo.Child.WeeklyChest and ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus and ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:GetText()==MYTHIC_PLUS_COMPLETE_MYTHIC_DUNGEONS then
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetText('')--隐藏，完成史诗钥石地下城即可获得
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:Hide()
    end
    if ChallengesFrame and ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child and ChallengesFrame.WeeklyInfo.Child.Description then
        ChallengesFrame.WeeklyInfo.Child.Description:SetText('')
        ChallengesFrame.WeeklyInfo.Child.Description:Hide()
    end]]
end























--周奖励界面界面
--#############
local function Init_WeeklyRewardsFrame()
    --添加一个按钮，打开挑战界面
    WeeklyRewardsFrame.showChallenges =WoWTools_ButtonMixin:Cbtn(WeeklyRewardsFrame, {texture='Interface\\Icons\\achievement_bg_wineos_underxminutes', size={42,42}})--所有角色,挑战
    WeeklyRewardsFrame.showChallenges:SetPoint('RIGHT',-4,-42)
    WeeklyRewardsFrame.showChallenges:SetFrameStrata('HIGH')

    WeeklyRewardsFrame.showChallenges:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(e.onlyChinese and '史诗钥石地下城' or CHALLENGES, e.Icon.left)
        e.tips:Show()
        self2:SetButtonState('NORMAL')
    end)
    WeeklyRewardsFrame.showChallenges:SetScript("OnLeave",GameTooltip_Hide)
    WeeklyRewardsFrame.showChallenges:SetScript('OnMouseDown', function()
        PVEFrame_ToggleFrame('ChallengesFrame', 3)
    end)
    WeeklyRewardsFrame:HookScript('OnShow', function(self)
        self.showChallenges:SetButtonState('NORMAL')
    end)

    --移动，图片
    hooksecurefunc(WeeklyRewardsFrame, 'UpdateOverlay', function(self)--Blizzard_WeeklyRewards.lua
        if self.Overlay and self.Overlay:IsShown() then--未提取,提示
            --self.Overlay:SetScale(0.61)
            self.Overlay:ClearAllPoints()
            self.Overlay:SetPoint('TOPLEFT', 2,-2)
        end
    end)

    --未提取,提示
    if WeeklyRewardExpirationWarningDialog then
        function WeeklyRewardExpirationWarningDialog:set_hide()--GreatVaultRetirementWarningFrameMixin:OnShow()
            if not C_WeeklyRewards.HasInteraction() then
                local title = _G["EXPANSION_NAME"..LE_EXPANSION_LEVEL_CURRENT];
                local text
                if title then
                    title= e.cn(title)
                    if C_WeeklyRewards.ShouldShowFinalRetirementMessage() then
                        text= format(e.onlyChinese and '所有未领取的奖励都会在%s上线后消失。' or GREAT_VAULT_RETIRE_WARNING_FINAL_WEEK, title)
                    elseif C_WeeklyRewards.HasAvailableRewards() or C_WeeklyRewards.HasGeneratedRewards() or C_WeeklyRewards.CanClaimRewards() then
                        text= format(e.onlyChinese and '本周后就不能获得新的奖励了。|n%s上线后，所有未领取的奖励都会丢失。' or GREAT_VAULT_RETIRE_WARNING, title);
                    end
                    if text then
                        print(e.addName, Initializer:GetName(),'|n|cffff00ff',text)
                    end
                end
            end
            self:Hide()
        end
        WeeklyRewardExpirationWarningDialog:HookScript('OnShow', WeeklyRewardExpirationWarningDialog.set_hide)
        if WeeklyRewardExpirationWarningDialog:IsShown() then
            WeeklyRewardExpirationWarningDialog:set_hide()
        end
    end
end




















--########################
--打开周奖励时，提示拾取专精
--########################
local WeekRewardLookFrame
local function set_Week_Reward_Look_Specialization()
    if not C_WeeklyRewards.HasAvailableRewards() or WeekRewardLookFrame or not e.Player.levelMax then
        return
    elseif C_WeeklyRewards.HasAvailableRewards() then
        print(e.addName, Initializer:GetName(),'|cffff00ff'..(e.onlyChinese and "返回宏伟宝库，获取你的奖励" or WEEKLY_REWARDS_RETURN_TO_CLAIM))
    end

    WeekRewardLookFrame= CreateFrame("Frame")
    WeekRewardLookFrame:SetSize(40,40)
    WeekRewardLookFrame:SetPoint("CENTER", -100, 60)
    WeekRewardLookFrame:SetShown(false)
    WeekRewardLookFrame:RegisterEvent('PLAYER_UPDATE_RESTING')
    WeekRewardLookFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    function WeekRewardLookFrame:set_Event()
        if not C_WeeklyRewards.HasAvailableRewards() then
            self:UnregisterAllEvents()
            self:SetShown(false)
            return
        end
        self:UnregisterEvent('UNIT_SPELLCAST_SENT')
        if IsResting() then
            self:RegisterEvent('UNIT_SPELLCAST_SENT')
        end
    end

    function WeekRewardLookFrame:set_Show(show)
        if self.time and not self.time:IsCancelled() then
            self.time:Cancel()
        end
        self:SetShown(show)
        e.Ccool(self, nil, show and 4 or 0, nil, true, true, true)
    end
    function WeekRewardLookFrame:set_Texture()
        if not self.texture then
            self.texture= self:CreateTexture(nil, 'BACKGROUND')
            self.texture:SetAllPoints(self)
            self:SetScript('OnEnter', function(frame)
                frame:set_Show(false)
                print(e.addName, Initializer:GetName(), '|cffff00ff', e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)
            end)
            local texture= self:CreateTexture(nil,'BORDER')
            texture:SetSize(60,60)
            texture:SetPoint('CENTER',3,-3)
            texture:SetAtlas('UI-HUD-UnitFrame-TotemFrame-2x')
        end
        self:set_Show(true)
        self.time= C_Timer.NewTimer(4, function()
            self:SetShown(false)
        end)
        local loot = GetLootSpecialization()
        local texture
        if loot and loot>0 then
            texture= select(4, GetSpecializationInfoByID(loot))
        else
            texture= select(4, GetSpecializationInfo(GetSpecialization() or 0))
        end
        SetPortraitToTexture(self.texture, texture or 0)
    end
    WeekRewardLookFrame:SetScript('OnEvent', function(self, event, unit, target, _, spellID)
        if event=='PLAYER_UPDATE_RESTING' or event=='PLAYER_ENTERING_WORLD' then
            self:set_Event()

        elseif spellID==392391 and unit=='player' and target and target:find(RATED_PVP_WEEKLY_VAULT) then
            self:set_Texture()
        end
    end)

    WeekRewardLookFrame:set_Event()
end

































--####
--初始
--####
local function Init()
    TipsFrame= CreateFrame("Frame",nil, ChallengesFrame)
    TipsFrame:SetFrameStrata('HIGH')
    TipsFrame:SetFrameLevel(7)
    TipsFrame:SetPoint('CENTER')
    TipsFrame:SetSize(1, 1)
    TipsFrame:SetShown(not Save.hideTips)
    TipsFrame:SetScale(Save.tipsScale or 1)

    local check= WoWTools_ButtonMixin:Cbtn(ChallengesFrame, {size={18,18}, icon='hide'})-- not Save.hideIns})
    check.texture= check:CreateTexture()
    check.texture:SetAllPoints(check)
    check.texture:SetAlpha(0.3)
    function check:set_Texture()
        self.texture:SetAtlas(not Save.hideIns and e.Icon.icon or e.Icon.disabled)
    end
    check:set_Texture()
    check:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
    if _G['MoveZoomInButtonPerPVEFrame'] then
        check:SetPoint('RIGHT', _G['MoveZoomInButtonPerPVEFrame'], 'LEFT', -18,0)
    else
        check:SetPoint('LEFT', PVEFrame.TitleContainer)
    end
    check:SetScript("OnClick", function(self)
        Save.hideIns = not Save.hideIns and true or nil
        --self:SetNormalAtlas(not Save.hideIns and e.Icon.icon or e.Icon.disabled)
        self:set_Texture()
        set_Update()
    end)
    check:SetScript('OnMouseWheel', function(self, d)--缩放
        local scale= Save.insScale or 1
        if d==1 then
            scale= scale-0.05
        else
            scale= scale+0.05
        end
        scale= scale>2.5 and 2.5 or scale
        scale= scale<0.4 and 0.4 or scale
        print(e.addName, Initializer:GetName(), e.onlyChinese and '副本' or INSTANCE, e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..scale)
        Save.insScale= scale==1 and nil or scale
        set_Update()
        self:set_Tooltips()
    end)
    function check:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '显示/隐藏' or SHOW..'/'..HIDE, (e.onlyChinese and '副本' or INSTANCE)..e.Icon.left..(e.onlyChinese and '信息' or INFO))
        e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE,'|cnGREEN_FONT_COLOR:'..(Save.insScale or 1)..'|r'.. e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
        e.tips:Show()
    end
    check:SetScript("OnEnter",function(self)
        self:set_Tooltips()
        self.texture:SetAlpha(1)
    end)
    check:SetScript("OnLeave",function(self)
        e.tips:Hide()
        self.texture:SetAlpha(0.3)
    end)


    local tipsButton= WoWTools_ButtonMixin:Cbtn(check, {size={18,18}, atlas=not Save.hideTips and 'FXAM-QuestBang' or e.Icon.disabled})
    if _G['MoveZoomInButtonPerPVEFrame'] then
        tipsButton:SetPoint('RIGHT', _G['MoveZoomInButtonPerPVEFrame'], 'LEFT')
    else
        tipsButton:SetPoint('LEFT', check, 'RIGHT')
    end
    tipsButton:SetAlpha(0.5)
    tipsButton:SetScript('OnClick', function(self)
        Save.hideTips= not Save.hideTips and true or nil
        TipsFrame:SetShown(not Save.hideTips)
        self:SetNormalAtlas(not Save.hideTips and 'FXAM-QuestBang' or e.Icon.disabled)
    end)
    tipsButton:SetScript('OnMouseWheel', function(self, d)--缩放
        local scale= Save.tipsScale or 1
        if d==1 then
            scale= scale-0.05
        else
            scale= scale+0.05
        end
        scale= scale>2.5 and 2.5 or scale
        scale= scale<0.4 and 0.4 or scale
        print(e.addName, Initializer:GetName(), e.onlyChinese and '信息' or INFO,  e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..scale)
        Save.tipsScale= scale==1 and nil or scale
        TipsFrame:SetScale(scale)
        self:set_Tooltips()
    end)
    function tipsButton:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '显示/隐藏' or SHOW..'/'..HIDE, e.Icon.left..(e.onlyChinese and '信息' or INFO))
        e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE,'|cnGREEN_FONT_COLOR:'..(Save.tipsScale or 1)..'|r'.. e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
        e.tips:Show()
    end
    tipsButton:SetScript('OnEnter', function(self)
        self:set_Tooltips()
        self:SetAlpha(1)
    end)
    tipsButton:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)


    --传送门
    local spellButton= WoWTools_ButtonMixin:Cbtn(check, {size={18,18}, atlas= not Save.hidePort and 'WarlockPortal-Yellow-32x32' or e.Icon.disabled})
    spellButton:SetPoint('LEFT', _G['MoveZoomInButtonPerPVEFrame'] or tipsButton, 'RIGHT')
    spellButton:SetAlpha(0.5)
    spellButton:SetScript('OnClick', function(self)
        Save.hidePort= not Save.hidePort and true or nil
        set_Update()
        self:SetNormalAtlas(not Save.hidePort and 'WarlockPortal-Yellow-32x32' or e.Icon.disabled)
    end)
    spellButton:SetScript('OnMouseWheel', function(self, d)--缩放
        if UnitAffectingCombat('player') then
            return
        end
        local scale= Save.portScale or 1
        if d==1 then
            scale= scale-0.05
        else
            scale= scale+0.05
        end
        scale= scale>2.5 and 2.5 or scale
        scale= scale<0.4 and 0.4 or scale
        print(e.addName, Initializer:GetName(), format(e.onlyChinese and "%s的传送门" or UNITNAME_SUMMON_TITLE14, e.onlyChinese and '缩放' or UI_SCALE), '|cnGREEN_FONT_COLOR:'..scale)
        Save.portScale= scale==1 and nil or scale
        set_Update()
        self:set_Tooltips()
    end)
    function spellButton:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        if e.onlyChinese then
            e.tips:AddDoubleLine('挑战20层','限时传送门')
            e.tips:AddDoubleLine('提示：', '如果出现错误，请禁用此功能')
        else
            e.tips:AddLine(format(UNITNAME_SUMMON_TITLE14, CHALLENGE_MODE..' (20) '))
            e.tips:AddDoubleLine(LABEL_NOTE, 'If you get error, please disable this')
        end
        e.tips:AddLine(' ')
        for _, tab in pairs(e.ChallengesSpellTabs) do
            local spellLink= C_Spell.GetSpellLink(tab.spell) or C_Spell.GetSpellName(tab.spell) or ('ID'.. tab.spell)
            local icon= C_Spell.GetSpellTexture(tab.spell)
            e.tips:AddDoubleLine((icon and '|T'..icon..':0|t' or '')..spellLink,
                                'spellID '..tab.spell..' '..
                                (IsSpellKnownOrOverridesKnown(tab.spell) and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已获得' or ACHIEVEMENTFRAME_FILTER_COMPLETED)
                                                        or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '未获得' or FOLLOWERLIST_LABEL_UNCOLLECTED))
                                )
                            )
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示/隐藏' or e.GetShowHide(nil, true), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..(Save.portScale or 1)..'|r'.. e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
        e.tips:Show()
    end
    spellButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:SetAlpha(0.5)
    end)
    spellButton:SetScript('OnEnter', function(self)
        self:set_Tooltips()
        self:SetAlpha(1)
    end)

    --Init_Affix()

    --周奖励，提示
    e.Get_Weekly_Rewards_Activities({frame=TipsFrame, point={'TOPLEFT', ChallengesFrame, 'TOPLEFT', 10, -53}})

    All_Player_Info()--所以角色信息
    C_Timer.After(2, set_All_Text)--所有记录

    hooksecurefunc(ChallengesFrame, 'Update', set_Update)

    ChallengesFrame:HookScript('OnShow', function()
        --Affix()
        --周奖励，提示
        e.Get_Weekly_Rewards_Activities({frame=TipsFrame, point={'TOPLEFT', ChallengesFrame, 'TOPLEFT', 10, -53}})
        C_Timer.After(2, set_All_Text)--所有记录
        --set_Update()
    end)


    if ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child then--隐藏, 赛季最佳
        if ChallengesFrame.WeeklyInfo.Child.SeasonBest then
            ChallengesFrame.WeeklyInfo.Child.SeasonBest:SetText('')
        end
   end

    if ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child then
        if ChallengesFrame.WeeklyInfo.Child.Description and ChallengesFrame.WeeklyInfo.Child.Description:IsVisible() then
            local text= ChallengesFrame.WeeklyInfo.Child.Description:GetText()
            if text==MYTHIC_PLUS_MISSING_KEYSTONE_MESSAGE then
                ChallengesFrame.WeeklyInfo.Child.Description:SetText()
                print(e.addName, Initializer:GetName())
                print('|cffff00ff',text)
            end
        end
    end

    if C_AddOns.IsAddOnLoaded("AngryKeystones") then
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:ClearAllPoints()
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest.RunStatus:SetPoint('BOTTOM', ChallengesFrame.WeeklyInfo.Child.WeeklyChest, 0, -55)
    end

    --#################
    --挑战,钥石,插入界面
    --#################
    local btn= WoWTools_ButtonMixin:Cbtn(ChallengesKeystoneFrame, {size={18,18}, icon= not Save.hideKeyUI})
    btn:SetFrameStrata('HIGH')
    btn:SetFrameLevel(7)
    btn:SetAlpha(0.5)
    if _G['MoveZoomInButtonPerChallengesKeystoneFrame'] then
        btn:SetPoint('LEFT', _G['MoveZoomInButtonPerChallengesKeystoneFrame'], 'RIGHT')
    else
        btn:SetPoint('RIGHT', ChallengesKeystoneFrame.CloseButton, 'LEFT')
    end
    btn:SetScript("OnClick", function(self)
        Save.hideKeyUI = not Save.hideKeyUI and true or nil
        if ChallengesKeystoneFrame.keyFrame then
            ChallengesKeystoneFrame.keyFrame:SetShown(not Save.hideKeyUI)
        elseif not Save.hideKeyUI then
            init_Blizzard_ChallengesUI()
        end
        self:SetNormalAtlas(not Save.hideKeyUI and e.Icon.icon or e.Icon.disabled)
    end)
    btn:SetScript("OnEnter",function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '显示/隐藏' or SHOW..'/'..HIDE, e.Icon.left)
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
        e.tips:Show()
        self:SetAlpha(1)
    end)
    btn:SetScript("OnLeave",function(self)
        e.tips:Hide()
        self:SetAlpha(0.5)
    end)
    if not Save.hideKeyUI then
        init_Blizzard_ChallengesUI()
    end



end































--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("CHALLENGE_MODE_COMPLETED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if e.Is_Timerunning then
                self:UnregisterAllEvents()
                return
            end

            Save= WoWToolsSave[addName] or Save
            Save.rightX= Save.rightX or 2--右边，提示，位置
            Save.rightY= Save.rightY or -22

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|A:UI-HUD-MicroMenu-Groupfinder-Mouseover:0:0|a'..(e.onlyChinese and '史诗钥石地下城' or addName),
                tooltip= e.cn(addName),
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.addName, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled then
                self:UnregisterAllEvents()
            else
                C_Timer.After(2, set_Week_Reward_Look_Specialization)--打开周奖励时，提示拾取专精
            end
            self:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_ChallengesUI' then--挑战,钥石,插入界面
            Init()--史诗钥石地下城, 界面

        elseif arg1=='Blizzard_WeeklyRewards' then
            Init_WeeklyRewardsFrame()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='CHALLENGE_MODE_COMPLETED' then
        if Save.slotKeystoneSay then
            local itemLink= get_Bag_Key()--查找，包的key
            if itemLink then
                C_Timer.After(2, function()
                    e.Chat(itemLink, nil, nil)
                end)
            end
        end
    end
end)

--panel:RegisterEvent('CHALLENGE_MODE_START')
--[[elseif event=='CHALLENGE_MODE_START' then -赏金, 说 Bounty
    if Save.hideKeyUI then
        return
    end
    local tab = select(2, C_ChallengeMode.GetActiveKeystoneInfo()) or {}
    for _, info  in pairs(tab) do
        local activeAffixID=select(3, C_ChallengeMode.GetAffixInfo(info))
        if activeAffixID==136177 then
            C_Timer.After(6, function()
                local chat={}

                local n=GetNumGroupMembers()
                local IDs2={373113, 373108, 373116, 373121}
                for i=1, n do
                    local u= i==n and 'player' or 'party'..i
                    local name2=i==n and COMBATLOG_FILTER_STRING_M or UnitName(u)
                    if UnitExists(u) and name2 then
                        local buff
                        for _, v in pairs(IDs2) do
                            local name=e.WA_GetUnitBuff(u, v)
                            if  name then
                                local link= C_Spell.GetSpellLink(v)
                                if link or name then
                                    buff=i..')'..name2..': '..(link or name)
                                    break
                                end
                            end
                        end
                        buff=buff or (i..')'..name2..': '..NONE)
                        table.insert(chat, buff)
                    end
                end

                for _, v in pairs(chat) do
                    if not Save.slotKeystoneSay then
                        print(v)
                    else
                        e.Chat(v)
                    end
                end
            end)
            break
        end
    end
end]]
