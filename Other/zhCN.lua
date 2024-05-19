local id, e = ...
if LOCALE_zhCN or LOCALE_zhTW then
    return
end





local function Init()
e.strText[C_Item.GetItemSubClassInfo(2, 0)]= "单手斧"
e.strText[C_Item.GetItemSubClassInfo(2, 4)]= "单手锤"
e.strText[C_Item.GetItemSubClassInfo(2, 7)]= "单手剑"
e.strText[C_Item.GetItemSubClassInfo(2, 9)]= "战刃"
e.strText[C_Item.GetItemSubClassInfo(2, 15)]= "匕首"
e.strText[C_Item.GetItemSubClassInfo(2, 13)]= "拳套"
e.strText[C_Item.GetItemSubClassInfo(2, 19)]= "魔杖"
e.strText[C_Item.GetItemSubClassInfo(2, 1)]= "双手斧"
e.strText[C_Item.GetItemSubClassInfo(2, 5)]= "双手锤"
e.strText[C_Item.GetItemSubClassInfo(2, 8)]= "双手剑"
e.strText[C_Item.GetItemSubClassInfo(2, 6)]= "长柄武器"
e.strText[C_Item.GetItemSubClassInfo(2, 10)]= "法杖"
e.strText[C_Item.GetItemSubClassInfo(2, 2)]= "弓"
e.strText[C_Item.GetItemSubClassInfo(2, 18)]= "弩"
e.strText[C_Item.GetItemSubClassInfo(2, 3)]= "枪械"
e.strText[C_Item.GetItemSubClassInfo(2, 16)]= "投掷武器"
e.strText[C_Item.GetItemSubClassInfo(2, 20)]= "鱼竿"

e.strText[C_Item.GetItemSubClassInfo(1, 0)]= "容器"
e.strText[C_Item.GetItemSubClassInfo(1, 2)]= "草药"
e.strText[C_Item.GetItemSubClassInfo(1, 3)]= "附魔"
e.strText[C_Item.GetItemSubClassInfo(1, 4)]= "工程"
e.strText[C_Item.GetItemSubClassInfo(1, 5)]= "宝石"
e.strText[C_Item.GetItemSubClassInfo(1, 6)]= "矿石"
e.strText[C_Item.GetItemSubClassInfo(1, 7)]= "制皮"
e.strText[C_Item.GetItemSubClassInfo(1, 8)]= "铭文"
e.strText[C_Item.GetItemSubClassInfo(1, 9)]= "钓鱼"
e.strText[C_Item.GetItemSubClassInfo(1, 10)]= "烹饪"
e.strText[C_Item.GetItemSubClassInfo(1, 11)]= "材料"
e.strText[C_Item.GetItemSubClassInfo(3, 11)]= "神器圣物"
e.strText[C_Item.GetItemSubClassInfo(3, 0)]= "智力"
e.strText[C_Item.GetItemSubClassInfo(3, 1)]= "敏捷"
e.strText[C_Item.GetItemSubClassInfo(3, 2)]= "力量"
e.strText[C_Item.GetItemSubClassInfo(3, 3)]= "耐力"
e.strText[C_Item.GetItemSubClassInfo(3, 5)]= "爆击"
e.strText[C_Item.GetItemSubClassInfo(3, 6)]= "精通"
e.strText[C_Item.GetItemSubClassInfo(3, 7)]= "急速"
e.strText[C_Item.GetItemSubClassInfo(3, 8)]= "全能"
e.strText[C_Item.GetItemSubClassInfo(3, 10)]= "复合属性"
e.strText[C_Item.GetItemSubClassInfo(8, 0)] = "头部"
e.strText[C_Item.GetItemSubClassInfo(8, 1)] = "颈部"
e.strText[C_Item.GetItemSubClassInfo(8, 2)] = "肩部"
e.strText[C_Item.GetItemSubClassInfo(8, 3)] = "披风"
e.strText[C_Item.GetItemSubClassInfo(8, 4)] = "胸部"
e.strText[C_Item.GetItemSubClassInfo(8, 5)] = "手腕"
e.strText[C_Item.GetItemSubClassInfo(8, 6)] = "手部"
e.strText[C_Item.GetItemSubClassInfo(8, 7)] = "腰部"
e.strText[C_Item.GetItemSubClassInfo(8, 8)] = "腿部"
e.strText[C_Item.GetItemSubClassInfo(8, 9)] = "脚部"
e.strText[C_Item.GetItemSubClassInfo(8, 10)] = "手指"
e.strText[C_Item.GetItemSubClassInfo(8, 11)] = "武器"
e.strText[C_Item.GetItemSubClassInfo(8, 12)] = "双手武器"
e.strText[C_Item.GetItemSubClassInfo(8, 13)] = "盾牌/副手"
e.strText[C_Item.GetItemSubClassInfo(0, 0)] = "爆炸物和装置"
e.strText[C_Item.GetItemSubClassInfo(0, 1)] = "药水"
e.strText[C_Item.GetItemSubClassInfo(0, 2)] = "药剂"
e.strText[C_Item.GetItemSubClassInfo(0, 3)] = "合剂和瓶剂"
e.strText[C_Item.GetItemSubClassInfo(0, 5)] = "食物和饮水"
e.strText[C_Item.GetItemSubClassInfo(0, 7)] = "绷带"
e.strText[C_Item.GetItemSubClassInfo(0, 9)] = "凡图斯符文"
e.strText[C_Item.GetItemSubClassInfo(16, 1)] = "|cffc69b6d战士|r"
e.strText[C_Item.GetItemSubClassInfo(16, 2)] = "|cfff48cba圣骑士|r"
e.strText[C_Item.GetItemSubClassInfo(16, 3)] = "|cffaad372猎人|r"
e.strText[C_Item.GetItemSubClassInfo(16, 4)] = "|cfffff468盗贼|r"
e.strText[C_Item.GetItemSubClassInfo(16, 5)] = "|cffffffff牧师|r"
e.strText[C_Item.GetItemSubClassInfo(16, 6)] = "|cffc41e3a死亡骑士|r"
e.strText[C_Item.GetItemSubClassInfo(16, 7)] = "|cff0070dd萨满|r"
e.strText[C_Item.GetItemSubClassInfo(16, 8)] = "|cff3fc7eb法师|r"
e.strText[C_Item.GetItemSubClassInfo(16, 9)] = "|cff8788ee术士|r"
e.strText[C_Item.GetItemSubClassInfo(16, 10)] = "|cff00ff98武僧|r"
e.strText[C_Item.GetItemSubClassInfo(16, 11)] = "|cffff7c0a德鲁伊|r"
e.strText[C_Item.GetItemSubClassInfo(16, 12)] = "|cffa330c9恶魔猎手|r"
e.strText[GetClassInfo(13)] = "|cff33937f唤魔师|r"

e.strText[C_Item.GetItemSubClassInfo(7, 5)] = "布料"
e.strText[C_Item.GetItemSubClassInfo(7, 6)] = "皮料"
e.strText[C_Item.GetItemSubClassInfo(7, 7)] = "金属和矿石"
e.strText[C_Item.GetItemSubClassInfo(7, 8)] = "烹饪"
e.strText[C_Item.GetItemSubClassInfo(7, 9)] = "草药"
e.strText[C_Item.GetItemSubClassInfo(7, 12)] = "附魔材料"
e.strText[C_Item.GetItemSubClassInfo(7, 16)] = "铭文"
e.strText[C_Item.GetItemSubClassInfo(7, 4)] = "珠宝加工"
e.strText[C_Item.GetItemSubClassInfo(7, 1)] = "零件"
e.strText[C_Item.GetItemSubClassInfo(7, 10)] = "元素"
e.strText[C_Item.GetItemSubClassInfo(7, 18)] = "附加材料"
e.strText[C_Item.GetItemSubClassInfo(7, 19)] = "成品材料"
e.strText[C_Item.GetItemSubClassInfo(9, 1)] = "制皮"
e.strText[C_Item.GetItemSubClassInfo(9, 2)] = "裁缝"
e.strText[C_Item.GetItemSubClassInfo(9, 3)] = "工程"
e.strText[C_Item.GetItemSubClassInfo(9, 4)] = "锻造"
e.strText[C_Item.GetItemSubClassInfo(9, 6)] = "炼金术"
e.strText[C_Item.GetItemSubClassInfo(9, 8)] = "附魔"
e.strText[C_Item.GetItemSubClassInfo(9, 10)] = "珠宝加工"
e.strText[C_Item.GetItemSubClassInfo(9, 11)] = "铭文"
e.strText[C_Item.GetItemSubClassInfo(9, 5)] = "烹饪"
e.strText[C_Item.GetItemSubClassInfo(9, 7)] = "急救"
e.strText[C_Item.GetItemSubClassInfo(9, 9)] = "钓鱼"
e.strText[C_Item.GetItemSubClassInfo(9, 0)] = "书籍"
e.strText[C_Item.GetItemSubClassInfo(19, 5)] = "采矿"
e.strText[C_Item.GetItemSubClassInfo(19, 3)] = "草药学"
e.strText[C_Item.GetItemSubClassInfo(19, 10)] = "剥皮"
e.strText[C_Item.GetItemSubClassInfo(17, 0)] = "人形"
e.strText[C_Item.GetItemSubClassInfo(17, 1)] = "龙类"
e.strText[C_Item.GetItemSubClassInfo(17, 2)] = "飞行"
e.strText[C_Item.GetItemSubClassInfo(17, 3)] = "亡灵"
e.strText[C_Item.GetItemSubClassInfo(17, 4)] = "小动物"
e.strText[C_Item.GetItemSubClassInfo(17, 5)] = "魔法"
e.strText[C_Item.GetItemSubClassInfo(17, 6)] = "元素"
e.strText[C_Item.GetItemSubClassInfo(17, 7)] = "野兽"
e.strText[C_Item.GetItemSubClassInfo(17, 8)] = "水栖"
e.strText[C_Item.GetItemSubClassInfo(17, 9)] = "机械"
e.strText[C_Item.GetItemSubClassInfo(15, 0)] = "垃圾"
e.strText[C_Item.GetItemSubClassInfo(15, 1)] = "材料"
e.strText[C_Item.GetItemSubClassInfo(15, 3)] = "节日"
e.strText[C_Item.GetItemSubClassInfo(15, 5)] = "坐骑"
e.strText[C_Item.GetItemSubClassInfo(15, 6)] = "坐骑装备"
e.strText[C_Item.GetItemSubClassInfo(18, 0)] = "时光徽章"

e.strText[C_Item.GetItemSubClassInfo(4, 4)]= "板甲"
e.strText[C_Item.GetItemSubClassInfo(4, 3)]= "锁甲"
e.strText[C_Item.GetItemSubClassInfo(4, 2)]= "皮甲"
e.strText[C_Item.GetItemSubClassInfo(4, 1)]= "布甲"

e.strText[format('\124T%s.tga:16:16:0:0\124t %s', FRIENDS_TEXTURE_ONLINE, FRIENDS_LIST_AVAILABLE)] = "|TInterface\\FriendsFrame\\StatusIcon-Online:16:16|t 有空"
e.strText[format('\124T%s.tga:16:16:0:0\124t %s', FRIENDS_TEXTURE_AFK, FRIENDS_LIST_AWAY)] = "|TInterface\\FriendsFrame\\StatusIcon-Away:16:16|t 离开"
e.strText[format('\124T%s.tga:16:16:0:0\124t %s', FRIENDS_TEXTURE_DND, FRIENDS_LIST_BUSY)] = "|TInterface\\FriendsFrame\\StatusIcon-DnD:16:16|t 忙碌"


e.strText[SPLASH_BATTLEFORAZEROTH_8_1_0_2_RIGHT_TITLE] = "达萨罗之战"
e.strText[EXPANSION_NAME2] = "巫妖王之怒"
e.strText[GLYPHS] = "雕文"
e.strText[AUCTION_HOUSE_DROPDOWN_REMOVE_FAVORITE] = "从偏好中移除"
e.strText[AUCTION_HOUSE_DROPDOWN_SET_FAVORITE] = "设置为偏好"
e.strText[TOOLTIP_BATTLE_PET] = "战斗宠物"
e.strText[COMBAT_LOG] = "战斗记录"
e.strText[GRAPHICS_HEADER] = "图形"
e.strText[ADDON_DISABLED] = "禁用"
e.strText[EMOTE67_CMD1] = "/不"








local fanctionTab={
    {1168, '公会', '公会声望代表了你在公会中的个人地位，购买公会奖励时需要达到与之对应的声望。公会声望会在你获得公会经验值时自动获得。'},
    {2414, '暗影国度'},
    {1118, '经典旧世'},
    {2503, '马鲁克半人马', '各个半人马氏族遨游于欧恩哈拉平原。他们听取轻风的召唤，探求狩猎的刺激。'},
    {2574, '梦境守望者', '许多种族的构成的同盟，誓要守护翡翠梦境，抗击所有威胁。'},
    {2564, '峈姆鼹鼠人', '鼹鼠人城镇峈姆位于巨龙群岛地下的查拉雷克洞窟深处。这些友善的商人以其热情好客的性格、灵敏的嗅觉和奇特的以物易物贸易系统而闻名'},
    {2511, '伊斯卡拉海象人', '伊斯卡拉海象人已经在巨龙群岛上生活了许多世代，他们和谐共处，热衷于讲述周遭世界的故事。'},
    {2510, '瓦德拉肯联军', '瓦德拉肯联军的大本营位于其最古老的城市，象征着所有龙族力量的结合体。他们不仅要保护自己的家园——这片群岛，还要保护整个艾泽拉斯。'},
    {2550, '钴蓝集所', '钴蓝集所曾是蓝龙用奥术魔法构建神器造物的地方。现在这里落入了碎裂之焰的手上，他们企图将这里的魔法用于战争。'},
    {2544, '工匠商盟-巨龙群岛支部'},
    {2517, '拉希奥', '长久以来，拉希奥的目标都专注于保护艾泽拉斯，现在，他的目光转向了黑龙军团的未来……以及他的宿命。'},
    {2518, '萨贝里安', '萨贝里安培养了新一代未被腐化的黑龙，而且为了保护他们不惜付出一切。'},
    {2553, '索莉多米', '索莉多米的时光旅行者们穿行于时间流之间，保护我们的世界不受无穷的平行宇宙的侵袭。当我们的时间线遭受时光袭击，或者即将分崩离析之时，索莉多米会率领众人维系秩序。'},
    {2507, '龙鳞探险队', '探险者协会和神圣遗物学会联合组成的探险队，他们是一群勇敢无畏的冒险者、学者和匠人，想发现巨龙群岛的万千奥秘'},
    {2615, '艾泽拉斯档案馆'},
    {2526, '冬裘熊怪', '冬裘熊怪使用的语言似乎没人能听懂。也许将来人们会得知更多的奥秘。'},
    {2568, '格里梅罗格竞速者', '布里谷尔不会让随便什么人跟滑仔一起竞技。你能证明自己是个合格的蜗牛训练师吗？'},
    {470, '棘齿城'},
    {2593, '桶腿船团', '一群不合群的海盗，充满自由精神，聚集在桶腿船长的旗下。'},
}

local  spellTab={
    {818, '烹饪用火', '点起一堆营火，使附近所有冒险者的全能提高1，并可以在营火旁烹饪'},
    {80451, '勘测', '在挖掘地点勘测古迹残片。每次勘测都会指引你靠近残片所在地点。'},

    {381870, '驭龙者之育', '收集到草药或矿石后，使你的精力充能速率提高400%，持续3秒。'},
    {381871, '巨龙捕猎', '击败一名敌人后，使你的精力充能速率提高10%，持续3秒。|n|n此效果每10秒只能触发一次。'},

    {376777, '驭龙术基础', '当从高处坠落时，你的巨龙群岛幼龙会展开翅膀向前滑翔。|n|n前进方向指向地面会获得更大动力。恢复水平可以将动力转向前方。|n|n前进方向指向天空会使你减速。速度降到最低时，你将开始向前缓慢降落。|n|n你也会获得以下技能：'},
    {372608, '向前突进', '向前振翅。'},
    {372610, '冲天升腾', '向上振翅。'},
    {383359, '精力', '驭龙术技能会消耗精力。无论骑乘与否，在地面每待30秒都会恢复1点精力。'},
    {383363, '升空', '骑乘驭龙术坐骑时，跳跃两次即可飞向上方并开始向前滑翔。'},
    {383366, '碧空热血', '驭龙飞行达到高速时，你每15秒恢复1点精力。'},
    {373586, '群岛强风', '你现在可以侦测并利用强风来改变你的飞行方向并推动你前进，从而提高你在顺风方向的速度。'},
    {361584, '回旋急冲', '向前螺旋冲刺一大段距离，提高速度。'},
    {374990, '青铜时光之锁', '在你的位置时间线上标记一个寻路点。使用青铜回溯来回溯到此位置。'},
    {403092, '空中急停', '向后扇动飞翼，降低前进速度。'},
    {425782, '复苏之风', '发掘尚未使用的潜力，立即恢复1点精力。'},

    {432257, '苦涩传承之路', '传送到|cff00ccff亚贝鲁斯，焰影熔炉|r的入口。'},--Dragonflight https://wago.io/meD8JMW3C
    {432258, '熏火梦境之路', '传送到|cff00ccff阿梅达希尔，梦境之愿|r的入口。'},
    {432254, '原始囚龙之路', '传送到|cff00ccff化身巨龙牢窟|r的入口。'},
    {373190, '大帝之路', '传送到|cff00ccff纳斯利亚堡|r的入口。'},--Shadowlands
    {373191, '磨难灵魂之路', '传送到|cff00ccff统御圣所|r的入口。'},
    {373192, '初诞者之路', '传送到|cff00ccff初诞者圣墓|r的入口。'},

    {131228, '玄牛之路', '传送至|cff00ccff围攻砮皂寺|r入口处'},
    {131222, '魔古皇帝之路', '传送至|cff00ccff魔古山宫殿|r入口处。'},
    {131225, '残阳之路', '传送至|cff00ccff残阳关|r入口处。'},
    {131206, '影踪派之路', '将施法者传送到|cff00ccff影踪禅院|r入口。'},
    {131205, '烈酒之路', '将施法者传送到|cff00ccff风暴烈酒酿造厂|r入口。'},
    {131232, '通灵师之路', '传送至|cff00ccff通灵学院|r入口处。'},
    {131231, '血色利刃之路', '传送至|cff00ccff血色大厅|r入口处。'},
    {131229, '血色法冠之路', '传送至|cff00ccff血色修道院|r入口处。'},
}

if e.Player.class=='HUNTER' then
    table.insert(spellTab, {1462, '野兽知识', '收集目标野兽的相关资料，显示其饮食习惯、技能、专精、能否被驯服，以及是否属于奇珍异兽。'})
    table.insert(spellTab, {2641, '解散宠物', '暂时解散你的宠物。之后你可以重新召唤它。'})
    table.insert(spellTab, {6991, '喂养宠物', '使用指定的食物为你的宠物喂食，立即为其恢复50%的总生命值。无法在战斗中使用。|n|n你可以使用野兽知识技能，确认自己的宠物喜欢吃哪种食物。'})
    table.insert(spellTab, {136, '治疗宠物', '在10 sec内为你的宠物恢复50%的最大生命值。|n[|cff00ccff荒野医疗|r]: 每次使用治疗宠物进行治疗时，都有25%的几率为你的宠物净化一个有害的魔法效果。'})
    table.insert(spellTab, {982, '复活宠物', '复活你的宠物，并为其恢复100%的基础生命值'})
    table.insert(spellTab, {1515, '驯服野兽', '尝试驯服一只野兽，使其成为你的伙伴。一旦你因为任何原因而失去了它的注意力，驯服过程就将失败。|n|n你必须解散任何当前激活的野兽伙伴并且有一个空的召唤宠物空格才能驯服新宠物。只有野兽控制专精的猎人才能驯服奇珍异兽。'})

elseif e.Player.class=='MAGE' then
    if e.Player.faction=='Horde' then--部落
        table.insert(spellTab, {3567, '传送-奥格瑞玛', '将你传送到|cff00ccff奥格瑞玛|r。'})
        table.insert(spellTab, {11417, '传送门-奥格瑞玛', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff奥格瑞玛|r。'})
        table.insert(spellTab, {3563, '传送-幽暗城', '将你传送到|cff00ccff幽暗城|r'})
        table.insert(spellTab, {11418,'传送门-幽暗城', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff幽暗城|r。'})
        table.insert(spellTab, {3566, '传送-雷霆崖', '将你传送到|cff00ccff雷霆崖'})
        table.insert(spellTab, {11420, '传送门-雷霆崖', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff雷霆崖|r。'})
        table.insert(spellTab, {32272, '传送-银月城', '将你传送到|cff00ccff银月城|r。'})
        table.insert(spellTab, {32267, '传送门-银月城', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff银月城|r。'})
        table.insert(spellTab, {49358, '传送-斯通纳德', '将你传送到|cff00ccff斯通纳德|r。'})
        table.insert(spellTab, {49361, '传送门-斯通纳德', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff斯通纳德|r。'})
        table.insert(spellTab, {35715, '传送-沙塔斯', '将你传送到|cff00ccff沙塔斯|r。'})
        table.insert(spellTab, {35717, '传送门-沙塔斯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff沙塔斯城|r。'})
        table.insert(spellTab, {53140, '传送-达拉然-诺森德', '将你传送到|cff00ccff诺森德的达拉然|r。'})
        table.insert(spellTab, {53142, '传送门-达拉然-诺森德', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff达拉然。'})
        table.insert(spellTab, {88344, '传送-托尔巴拉德', '将你传送到|cff00ccff托尔巴拉德|r。'})
        table.insert(spellTab, {88346, '传送门-托尔巴拉德', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff托尔巴拉德|r。'})
        table.insert(spellTab, {132627, '传送-锦绣谷', '将你传送到|cff00ccff锦绣谷|r。'})
        table.insert(spellTab, {132626, '传送门-锦绣谷', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff锦绣谷|r。'})
        table.insert(spellTab, {176242, '传送-战争之矛', '将你传送至|cff00ccff战争之矛。'})
        table.insert(spellTab, {176244, '传送门-战争之矛', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff战争之矛|r。'})
        table.insert(spellTab, {281404, '传送-达萨罗', '将你传送|cff00ccff到达萨罗|r。'})
        table.insert(spellTab, {281402, '传送门-达萨罗', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff达萨罗|r。'})
    elseif e.Player.faction=='Alliance' then
        table.insert(spellTab, {3561, '传送-暴风城', '将你传送到|cff00ccff暴风城|r。'})
        table.insert(spellTab, {10059, '传送门-暴风城', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff暴风城|r。'})
        table.insert(spellTab, {3562, '传送-铁炉堡', '将你传送到|cff00ccff铁炉堡|r。'})
        table.insert(spellTab, {11416, '传送门-铁炉堡', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff铁炉堡|r。'})
        table.insert(spellTab, {3565, '传送-达纳苏斯', '将你传送到|cff00ccff达纳苏斯|r。'})
        table.insert(spellTab, {11419, '传送门-达纳苏斯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff达纳苏斯|r。'})
        table.insert(spellTab, {32271, '传送-埃索达', '将你传送到|cff00ccff埃索达|r。'})
        table.insert(spellTab, {32266, '传送门-埃索达', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff埃索达|r。'})
        table.insert(spellTab, {49359, '传送-塞拉摩', '将你传送到|cff00ccff塞拉摩|r。'})
        table.insert(spellTab, {49360, '传送门-塞拉摩', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff塞拉摩|r。'})
        table.insert(spellTab, {33690, '传送-沙塔斯', '将你传送到|cff00ccff沙塔斯|r。'})
        table.insert(spellTab, {33691, '传送门-沙塔斯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff沙塔斯城|r。'})
        table.insert(spellTab, {53140, '传送-达拉然-诺森德', '将你传送到|cff00ccff诺森德的达拉然|r。'})
        table.insert(spellTab, {53142, '传送门-达拉然-诺森德', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff达拉然|r。'})
        table.insert(spellTab, {88342, '传送-托尔巴拉德', '将你传送到|cff00ccff托尔巴拉德|r。'})
        table.insert(spellTab, {88345, '传送门-托尔巴拉德', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff托尔巴拉德|r。'})
        table.insert(spellTab, {132621, '传送-锦绣谷', '将你传送到|cff00ccff锦绣谷|r。'})
        table.insert(spellTab, {132620, '传送门-锦绣谷', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff锦绣谷城|r。'})
        table.insert(spellTab, {176248, '传送-暴风之盾', '将你传送到|cff00ccff暴风之盾|r。'})
        table.insert(spellTab, {176246, '传送门-暴风之盾', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff暴风之盾|r。'})
        table.insert(spellTab, {281403, '传送-伯拉勒斯', '将你传送到|cff00ccff伯拉勒斯|r。'})
        table.insert(spellTab, {281400, '传送门-伯拉勒斯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff伯拉勒斯|r。'})
    end
    table.insert(spellTab, {224869, '传送-达拉然-破碎群岛', '将你传送至破碎群岛的|cff00ccff达拉然|r。'})
    table.insert(spellTab, {224871, '传送门-达拉然-破碎群岛', '制造一个传送门，将使用传送门的队伍成员传送到破碎群岛的|cff00ccff达拉然|r。'})
    table.insert(spellTab, {344587, '传送-奥利波斯', '将你传送至|cff00ccff奥利波斯|r。'})
    table.insert(spellTab, {344597, '传送门-奥利波斯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff奥利波斯|r。'})
    table.insert(spellTab, {395277, '传送-瓦德拉肯', '将你传送到|cff00ccff瓦德拉肯|r。'})
    table.insert(spellTab, {395289, '传送门-瓦德拉肯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff瓦德拉肯|r。'})
    table.insert(spellTab, {120145, '远古传送-达拉然', '将你传送到|cff00ccff达拉然|r。'})
    table.insert(spellTab, {193759, '传送-守护者圣殿', '将你传送至|cff00ccff守护者圣殿|r。'})
end


local curcurrencyTab={
    {2796, '苏生奇梦', '苏生奇梦可以给复苏化生台充能，使其可以将难以置信的能量灌注到护甲里'},

    {2707, '幼龙的酣梦纹章', '从巨龙时代第3赛季的某些户外活动、普通难度的阿梅达希尔以及6到10级的史诗钥石地下城获得'},
    {2706, '雏龙的酣梦纹章', '从巨龙时代第3赛季的许多户外活动、随机难度的阿梅达希尔以及不高于5级的史诗钥石地下城获得。'},
    {2708, '魔龙的酣梦纹章', '从巨龙时代第3赛季的英雄难度的阿梅达希尔以及11到15级的史诗钥石地下城获得'},
    {2709, '守护巨龙的酣梦纹章', '从巨龙时代第3赛季的史诗难度的阿梅达希尔以及不低于16级的史诗钥石地下城获得。'},
    {2594, '超因果箔片', '时光能量颗粒。灌注了足够的力量，所以化为了实体。提尔要塞水库的商人很珍视它。'},
    {2657, '迷之碎片', '通过协助巨龙群岛的艾泽拉斯档案师获得。可以在索德拉苏斯的供给商阿丽丝塔处换取物品。'},
    {2650, '翡翠露滴', '灌注了翡翠梦境的滋养特性的露水，可以让任何植物绽放。 用来让翡翠梦境的植物复苏。'},
    {2777, '梦境注能', '用来抽出生物的酣梦精华。 中心营地的艾莉阿娜会对此感兴趣的。'},
    {2245, '飞珑石', '通过完成世界任务、团队副本、地下城、竞技场比赛以及其他活动获得。用来给满级装备升级。'},
    {2003, '巨龙群岛补给', '各类物资和建筑材料，可以帮助巨龙群岛的友善阵营对抗拜荒者。用来购买通过名望解锁的物品。'},
    {2122, '风暴徽记', '标志着对平息了原始风暴的勇敢冒险者的认可。用来升级原始风暴装备。'},
    {2118, '元素涌流', '被击败的敌人的精华，灌注了原始风暴的力量。 用来在瓦德拉肯的密斯莱莎处以及莫库特村的多个商人处采购物品。'},

    {2123, '血腥硬币', '在巨龙群岛的血腥战斗中获得。'},
    {1792, '荣誉点数', '用来购买非评级的PvP装备。'},
    {1602, '征服点数', '从评级PvP活动获得。用来购买评级PvP装备。'},

    {1166, '时空扭曲徽章', '在时空漫游地下城中获得，可以在主城的时空漫游商人处换取货物。'},
    {515, '暗月奖券', '在暗月马戏团的游戏中获胜或完成工作人员交付的任务后获得。'},
    {2032, '商贩标币', '商贩标币可以用来在商栈交易商品。'},

    {2812, '守护巨龙的觉醒纹章', '从巨龙时代第4赛季的史诗难度的团队副本以及不低于+6级的史诗钥石地下城获得。'},
    {2809, '魔龙的觉醒纹章', '从巨龙时代第4赛季的英雄难度的团队副本以及不超过+5级的史诗钥石地下城获得。'},
    {2806, '雏龙的觉醒纹章', '从巨龙时代第4赛季的许多户外活动、随机难度的团队副本以及英雄地下城获得。'},
    {2807, '幼龙的觉醒纹章', '从巨龙时代第4赛季的某些户外活动、普通难度的团队副本以及+0级的史诗地下城获得。'},
    {2912, '苏生觉醒', '苏生觉醒可以给复苏化生台充能，使其可以将不可思议的能量灌注到护甲里。'},
}

local specTab={
    {71, '武器'}, {72, '狂怒'}, {73, '防护'},
    {65, '神圣'}, {66, '防护'}, {70, '惩戒'},
    {250, '鲜血'}, {251, '冰霜'}, {252, '邪恶'},
    {253, '野兽控制'}, {254, '射击'}, {255, '生存'},
    {102, '平衡'}, {103, '野性'}, {104, '守护'}, {105, '恢复'},
    {262, '元素'}, {263, '增强'}, {264, '恢复'},
    {259, '奇袭'}, {260, '狂徒'}, {261, '敏锐'},
    {268, '酒仙'}, {270, '织雾'}, {269, '踏风'},
    {265, '痛苦'}, {266, '恶魔学识'}, {267, '毁灭'},
    {62, '奥术'}, {63, '火焰'}, {64, '冰霜'},
    {577, '浩劫'}, {581, '复仇'},
    {256, '戒律'}, {257, '神圣'}, {258, '暗影'},
    {1467, '湮灭'}, {1468, '恩护'}, {1473, '增辉'},
    --{, ''}, {, ''}, {, ''},
}


local raceTab={
    [1] = "人类",
    [2] = "兽人",
    [3] = "矮人",
    [4] = "暗夜精灵",
    [5] = "亡灵",
    [6] = "牛头人",
    [7] = "侏儒",
    [8] = "巨魔",
    [9] = "地精",
    [10] = "血精灵",
    [11] = "德莱尼",
    [22] = "狼人",
    [24] = "熊猫人",
    [25] = "熊猫人",
    [26] = "熊猫人",
    [27] = "夜之子",
    [28] = "至高岭牛头人",
    [29] = "虚空精灵",
    [30] = "光铸德莱尼",
    [31] = "赞达拉巨魔",
    [32] ="库尔提拉斯人",
    [34] = "黑铁矮人",
    [35] = "狐人",
    [36] = "玛格汉兽人",
    [37] = "机械侏儒",
    [52] = "龙希尔",
    [70] = "龙希尔",
}


local affixTab= {
    {3, '火山', '在战斗中，敌人会周期性地令远处的玩家脚下喷发出岩浆柱。'},
    {6, '暴怒', '非首领敌人在生命值降至30%时将被激怒，暂时免疫群体控制效果。'},
    {7, '激励', '任何非首领敌人死亡时，其临死的哀嚎将强化附近的盟友，使其伤害暂时提高20%。'},
    {8, '血池', '非首领敌人被击杀后会留下一个缓慢消失的脓液之池，可以治疗其盟友，并且伤害玩家。'},
    {9, '残暴', '首领的生命值提高30%，首领及其爪牙造成的伤害最多提高15%。'},
    {10, '强韧', '非首领敌人的生命值提高20%，造成的伤害最高提高30%。'},
    {11, '崩裂', '非首领敌人被击杀时会爆炸，令所有玩家在4秒内受到伤害。此效果可叠加。'},
    {123, '怨毒', '从非首领敌人的尸体中会出现敌人并追击随机玩家。'},
    {124, '风雷', '战斗中敌人会周期性地召唤伤害性的旋风。'},
    {134, '纠缠', '在战斗中，纠缠藤蔓会周期性地出现，并诱捕玩家。'},
    {135, '受难', '在战斗中，受难之魂会周期性地出现，并向玩家寻求帮助。'},
    {136, '虚体', '在战斗中，虚体生物会周期性地出现，并试图削弱玩家。'},
}



for _, info in pairs(spellTab) do
    e.LoadDate({id=info[1], type='spell'})
end

C_Timer.After(2, function()
    for _, info in pairs(spellTab) do
        if info[2] then
            local name= GetSpellInfo(info[1])
            if name then
                e.strText[name]=  info[2]
            end
        end
        if info[3] then
            local des= GetSpellDescription(info[1])
            if des then
                e.strText[des]= info[3]
            end
        end
    end
    for _, info in pairs(e.ChallengesSpellTabs) do
        if info.spell then
            if info.spellName then
                local name= GetSpellInfo(info.spell)
                if name then
                    e.strText[name]=  info.spellName
                end
            end
            if info.spellDes then
                local des= GetSpellDescription(info.spell)
                if des then
                    e.strText[des]= info.spellDes
                end
            end
        end
    end
    for _, info in pairs(fanctionTab) do
        local name, description = GetFactionInfoByID(info[1])
        if name then
            e.strText[name] = info[2]
        end
        if description and info[3] then
            e.strText[description]= info[3]
        end
    end
    for _, curTab in pairs(curcurrencyTab) do
        local info =C_CurrencyInfo.GetCurrencyInfo(curTab[1]) or {}
        if info.name then
            e.strText[info.name]= curTab[2]
        end
        if info.description and curTab[3] then
            e.strText[info.description]= curTab[3]
        end
    end
    for _, info in pairs(specTab) do
        local name, description, _, role= select(2, GetSpecializationInfoByID(info[1]))
        if name and info[2] then
            e.strText[name]= info[2]..(e.Icon[role] or '')
        end
        if description and info[3] then
            e.strText[description]= info[3]
        end
    end
    for raceID, name in pairs(raceTab) do
        local info = C_CreatureInfo.GetRaceInfo(raceID) or {}
        if info.clientFileString then
            e.strText[info.clientFileString]= name
        end
    end
    for _, info in pairs(affixTab) do
        local name, description = C_ChallengeMode.GetAffixInfo(info[1])
        if name then
            e.strText[name]= info[2]
        end
        if info[3] and description then
            e.strText[description]= info[3]
        end
    end

    specTab=nil
    spellTab=nil
    fanctionTab=nil
    curcurrencyTab=nil
    raceTab=nil
    affixTab=nil
end)

end



local panel= CreateFrame("Frame")

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        local Save= WoWToolsSave[BUG_CATEGORY15] or {}
        if e.onlyChinese and not Save.disabled then
            Init()
        else
            Init=function() end
        end
        panel:UnregisterAllEvents()
    end
end)
