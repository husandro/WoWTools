local e= select(2, ...)

--z_ItemInteractionFrame.lua
--套装，转换，货币, 不指定, 值可能是nil
--e.SetItemCurrencyID=nil








--WoWTools_LabelMixin:ItemCurrencyTips
e.ItemCurrencyTips= {---物品升级界面，挑战界面，物品，货币提示
    {type='currency', id=3008},--神勇石

    {type='currency', id=3107},--风化安德麦纹章
    {type='currency', id=3112},--蚀刻安德麦纹章
    {type='currency', id=3113},--符文安德麦纹章
    {type='currency', id=3114},--鎏金安德麦纹章

    {type='currency', id=e.SetItemCurrencyID, show=true},--套装，转换，货币
    {type='currency', id=1602, line=true},--征服点数
    {type='currency', id=1191},--勇气点数
}







--挑战数据 Challenges.lua
local function Level_Text(text)
    local tab={
        ['Veteran']= format('%s%s|r', '|cff00ff00', e.onlyChinese and '老兵' or 'Veteran'),
        ['Champion']= format('%s%s|r', '|cff2aa2ff', e.onlyChinese and '勇士' or FOLLOWERLIST_LABEL_CHAMPIONS),
        ['Hero']= format('%s%s|r', '|cffff00ff', e.onlyChinese and '英雄' or ITEM_HEROIC),
        ['Myth']= format('%s%s|r', '|cffb78f6a', e.onlyChinese and '神话' or ITEM_QUALITY4_DESC),
    }
    return tab[text] or text
end
function e.GetChallengesWeekItemLevel(level, limitMaxKeyLevel)--LimitMaxKeyLevel --限制，显示等级,不然，数据会出错
    level= min(limitMaxKeyLevel or 20, level)
    level= max(2, level)
    local tab={
        [2]='639'..Level_Text('Champion')..'2/8  649'..Level_Text('Hero')..'1/6|T5872051:0|t10',
        [3]='639'..Level_Text('Champion')..'2/8  649'..Level_Text('Hero')..'1/6|T5872051:0|t12',
        [4]='642'..Level_Text('Champion')..'3/8  652'..Level_Text('Hero')..'2/6|T5872051:0|t14',
        [5]='645'..Level_Text('Champion')..'4/8  652'..Level_Text('Hero')..'2/6|T5872051:0|t16',
        [6]='649'..Level_Text('Hero')..'1/6  655'..Level_Text('Hero')..'3/6|T5872051:0|t18',

        [7]='649'..Level_Text('Hero')..'1/6  658'..Level_Text('Hero')..'4/6|T5872049:0|t10',
        [8]='652'..Level_Text('Hero')..'2/6  658'..Level_Text('Hero')..'4/6|T5872049:0|t12',
        [9]='652'..Level_Text('Hero')..'2/6  658'..Level_Text('Hero')..'4/6|T5872049:0|t14',
        [10]='655'..Level_Text('Hero')..'3/6  662'..Level_Text('Myth')..'1/6|T5872049:0|t16',
        [11]='655'..Level_Text('Hero')..'3/6  662'..Level_Text('Myth')..'1/6|T5872049:0|t18',
        [12]='655'..Level_Text('Hero')..'3/6  662'..Level_Text('Myth')..'1/6|T5872049:0|t20',
    }
    return tab[level] or tab[10]
end











--[[
Challenges.lua
https://wago.io/dungeonports
https://wago.io/meD8JMW3C
C_MythicPlus.GetCurrentSeason()
https://wago.tools/db2/MapChallengeMode?locale=zhCN
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

    [353]= {spell=464256, ins=1023, name='围攻伯拉勒斯', spellName='困守孤港之路', spellDes='传送到|cff00ccff围攻伯拉勒斯|r的入口。'},--围攻伯拉勒斯

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
    [525]= {spell=1216786, ins=1298, name='水闸行动', spellName='水闸行动之路', spellDes='传送至|cff00ccff水闸行动|r入口处。'},
}

--双法术，
if e.Player.faction=='Alliance' then
    e.ChallengesSpellTabs[353].spell= 445418 --围攻伯拉勒斯
end




