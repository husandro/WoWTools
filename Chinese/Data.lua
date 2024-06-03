if LOCALE_zhCN or LOCALE_zhTW then
    return
end
local e = select(2, ...)










local instanceBossTab={-- []='',
    [691]='怒之煞',
    [725]='炮舰',
    [814]='纳拉克',
    [826]='乌达斯塔',

    [857]='朱鹤赤精',
    [859]='玄牛砮皂',
    [861]='斡耳朵斯',
    [858]='青龙玉珑',
    [860]='白虎雪怒',

    [1262]='鲁克玛',
}




local instanceTab={--{, ''},
    --经典怀旧服
    {227, '黑暗深渊'},
    {229, '黑石塔'},
    {64, '影牙城堡'},
    {230, '厄运之槌'},
    {232, '玛拉顿'},
    {241, '祖尔法拉克'},
    {239, '奥达曼'},
    {237, '沉没的神庙'},
    {236, '斯坦索姆'},
    {742, '黑翼之巢'},
    {744, '安其拉'},

    --燃烧的远征
    {745, '卡拉赞'},
    {751, '黑暗神殿'},
    {254, '禁魔监狱'},
    {247, '奥金尼地穴'},
    {252, '塞泰克大厅'},
    {251, '旧希尔斯布莱德丘陵'},
    {249, '魔导师平台'},

    --巫妖王之怒
    {271, '安卡赫特:古代王国'},
    {272, '艾卓-尼鲁布'},
    {279, '净化斯坦索姆'},
    {275, '闪电大厅'},
    {286, '乌特加德之巅'},
    {284, '冠军的试炼'},
    {282, '魔环'},
    {273, '达克萨隆要塞'},
    {285, '乌特加德城堡'},
    {754, '纳克萨玛斯'},
    {759, '奥杜尔'},
    {757, '十字军的试炼'},
    {761, '红玉圣殿'},

    --大灾变
    {184, '时光之末'},
    {70, '起源大厅'},
    {72, '暮光堡垒'},
    {73, '黑翼血环'},
    {187, '巨龙之魂'},

    --熊猫人之谜
    {362, '雷电王座'},
    {317, '魔古山宝库'},
    {369, '决战奥格瑞玛'},

    {324, '围攻砮皂寺'},
    {302, '风暴烈酒酿造厂'},
    {246, '通灵学院'},
    {316, '血色修道院'},
    {311, '血色大厅'},
    {321, '魔古山宫殿'},

    {1194, '塔扎维什,帷纱集市'},


    --德拉诺之王
    {477, '悬槌堡'},
    {457, '黑石铸造厂'},

    --军团再临
    {726, '魔法回廊'},
    {900, '永夜大教堂'},
    {716, '艾萨拉之眼'},
    {727, '冥口峭壁'},
    {777, '紫罗兰监狱'},
    {946, '安托鲁斯,燃烧王座'},
    {959, '勇气试炼'},
    {1031, '奥迪尔'},
    {1177, '风暴熔炉'},
    {1180, '尼奥罗萨,觉醒之城'},

    {1023, '围攻伯拉勒斯'},
    {1041, '诸王之眠'},
    {1036, '风暴神殿'},
    {1030, '塞塔里斯神庙'},
    {1002, '托尔达戈'},
    {1012, '暴富矿区'},
    {1190, '纳斯利亚堡'},
    {1193, '统御圣所'},
    {1195, '初诞者圣墓'},

    --巨龙时代
    {1205, '巨龙群岛'},
    {1200, '化身巨龙牢窟'},
    {1208, '亚贝鲁斯,焰影熔炉'},
    {1207, '阿梅达希尔,梦境之愿'},

}






local fanctionTab={ --{', ''},
    {2640, '布莱恩·铜须', },

    {2506, '巨龙时代'},
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
    {2615, '艾泽拉斯档案馆', '龙鳞探险队的一个学者组织，致力于为子孙后代保护文物。'},
    {2526, '冬裘熊怪', '冬裘熊怪使用的语言似乎没人能听懂。也许将来人们会得知更多的奥秘。'},
    {2568, '格里梅罗格竞速者', '布里谷尔不会让随便什么人跟滑仔一起竞技。你能证明自己是个合格的蜗牛训练师吗？'},

    {2414, '暗影国度'},
    {2464, '魅夜王庭', '心能枯竭和德鲁斯特入侵占用了寒冬女王和荒猎团的大量注意力。现在只能依靠魅夜王庭的宗主来保护灵种，并保护林地。'},
    {2439, '宣罪者', '这些档案员对指控者忠心耿耿，致力于复原并归档被宫务大臣和他的审判官盟友打碎的罪碑。'},
    {2445, '灰烬王庭', '雷文德斯有了新的王庭，雷纳索尔王子希望联合整个暗影界的盟友，并增强他的盟约的影响力。'},
    {2413, '收割者之庭', '在德纳修斯大帝统治了无数时代后，雷文德斯的权力现在属于整个收割者之庭。这些温西尔贵族承担着救赎骄傲之魂这一神圣的使命。'},
    {2407, '晋升者', '格里恩历经艰难险阻，最终净化了凡人的负担后，会获得参加晋升仪式的资格，从而获得双翼，并向执政官发誓，永远为她效忠。'},
    {2470, '死亡先锋军', '暗影界四大盟约为突击统御圣所而结成的联军。'},
    {2465, '荒猎团', '荒猎团在危急时刻受到了寒冬女王的召唤，他们召集了全炽蓝仙野最优秀的男女猎手。面对着心能枯竭和重重危险，荒猎团已经准备好守护这片森林。'},
    {2478, '开悟者', '开悟者以前是艾财团的成员，但他们已经放弃了对利润和荣耀的追求，转而虔心侍奉初诞者。获得开悟者的青睐后，他们也许会乐意分享自己收集的知识。'},
    {2432, '威-娜莉', '威·娜莉对噬渊的了解远胜任何人，如果你赢得了她的尊敬，说不定她就会把信息分享一点给你。'},
    {2472, '档案员卷宗', '刻希亚的侍神者全心全意地研究着来自暗影界各处的圣物。他们在档案员的领导下，投入到找回失散在刻希亚各处的圣物的工作中。这些圣物在渊誓大军入侵后散失了。'},
    {2410, '不朽军团', '很久以前，兵主建立了玛卓克萨斯的五大密院，希望借此训练出最终极的战斗力。这支坚强的部队运用着力量、智慧和计谋，发誓守护暗影界，抵御一切威胁。'},
    {2422, '法夜', '荒猎团在危急时刻受到了寒冬女王的召唤，他们召集了全炽蓝仙野最优秀的男女猎手。面对着心能枯竭和重重危险，荒猎团已经准备好守护这片森林。'},


    --争霸艾泽拉斯
    {2104, '争霸艾泽拉斯'},
    {2415, '莱加尼', '这群魔古对泰坦守护者莱十分忠诚，他们的使命是击退来犯的恩佐斯的爪牙，守护纳拉克煞引擎。'},
    {2159, '第七军团', '联盟军队中的精英部队，目前专注于破坏部落在赞达拉的行动。'},
    {2157, '荣耀战团', '部落大军中的特种部队，专注于破坏联盟在库尔提拉斯的行动。'},
    {2103, '赞达拉帝国', '赞达拉巨魔统治着艾泽拉斯最古老的帝国，这些强大的巨魔会与令人敬畏的洛阿神灵做交易，换取他们的力量，赞达拉的海军在无尽之海上也是所向披靡。'},
    {2160, '普罗德摩尔海军部', '普罗德摩尔家族是人中龙凤，执掌着艾泽拉斯最精良的海军，足以号令大海。数十年来，他们在权力中心伯拉勒斯领导着库尔提拉斯。'},
    {2373, '破镣者', '这些难民一直受到纳迦的压迫，于是他们联合起来，想要反抗，并重获自由。'},
    {2163, '始祖龟求知者', '始祖龟求知者周游世界并利用他们的巨大财富来分类并保存禁忌的知识。'},
    {2391, '锈栓抵抗军', '锈栓抵抗军战斗在第一线，想要反抗麦卡贡国王，阻止他的邪恶计划。'},
    {2417, '奥丹姆联军', '奥丹姆联军是由托维尔人牵头建立的松散同盟，建立的目的是为了击退敌军，保护起源熔炉。'},
    {2158, '沃顿奈', '沃顿奈是流亡者和拾荒者的组织，他们依靠对沙漠的了解逐步发展壮大，而其他人只能在这里枯萎凋亡。'},
    {2164, '艾泽拉斯的勇士', '萨格拉斯的燃烧之刃对艾泽拉斯造成了巨大的创伤，由麦格尼·铜须招募而来的艾泽拉斯的勇士正在努力治愈这些伤口，以拯救这个濒死的世界。'},
    {2400, '波涛之刃剑鱼人', '波涛之刃剑鱼人是一支古老的深海战斗种族，徜徉于海洋中最深邃最危险的地带。'},
    {2162, '风暴之末', '风暴之末是农民、匠人、士兵和神秘的海贤们的家，他们希望夺回斯托颂谷地，并且确立自己在库尔提拉斯的地位。'},
    {2161, '灰烬骑士团', '灰烬骑士团是个古老的库尔提拉斯组织，它的重生是为了对抗女巫的威胁。骑士团利用他们所获得的知识指引他们的利刃，以此英勇战斗。'},
    {2395, '蜜背蜂群', '一种特别的蜜蜂，以其超大的体形而闻名。虽然它们最近才来到斯托颂谷地，但它们的存在已经迅速在冒险者和昆虫爱好者当中流传开来。'},
    {2156, '塔兰吉远征队', '塔兰吉公主和他的盟友正努力保护赞达拉不受鲜血巨魔的侵扰。'},
    {2376, '先知奥利', '先知奥利是位睿智而强大的萨满，拥有号令元素的力量'},
    {2427, '亚基宝宝'},
    {2370, '恐龙训练-恐角龙'},
    {2390, '维姆-盐心'},
    {2233, '恐龙训练-翼手龙'},
    {2377, '剑客伊诺瓦里', '剑客伊诺瓦里是位老练的战士，他赢得了剑鱼人的尊敬。'},
    {2120, '库尔提拉斯-提拉加德', ''},
    {2375, '猎人阿卡纳', '猎人阿卡纳是位久经沙场的老猎人，拥有了不起的生存技巧。'},
    {2389, '奈莉-锐鳍', ''},
    {2388, '鲍恩-分鳃', ''},
    {2264, '库尔提拉斯-德鲁斯瓦', '岛国库尔提拉斯盛产艾泽拉斯最一流的水手。'},
    {2265, '库尔提拉斯-斯托颂', '岛国库尔提拉斯盛产艾泽拉斯最一流的水手。'},

    --军团再临
    {1834, '军团再临'},
    {2018, '复仇之爪', '半神艾维娜的盟友，破碎群岛所有有翼生物的守护者。'},
    {1859, '堕夜精灵', '这些被放逐的夜之子精灵由于被切断了和暗夜井的联系，饱受戒断魔瘾的痛苦。他们反对同胞与燃烧军团结盟，并为某种救赎而战。'},
    {2165, '圣光军团', '阿古斯陷落后，德莱尼精英战士追随始祖纳鲁泽拉跨越宇宙，打响了旨在消灭燃烧军团的永恒之战。从那时起，燃烧的远征的其他幸存者也加入了光铸者的行列。'},
    {1948, '瓦拉加尔', '他们是被奥丁选中的战士，发誓在生前及死后都效忠于他。'},
    {2101, '莎乐丝', '住在瀑布旁的神秘枯法者'},
    {1975, '咒法师马戈斯', '马戈斯曾是一名肯瑞托学徒，他通过钓鱼来舒缓生活的压力。'},
    {1900, '法罗迪斯宫廷', '由幽灵组成的法罗迪斯宫廷及它的盟友们正在阿苏纳被诅咒的岛屿上持续抗击入侵者。'},
    {2098, '守护者蕾娜', '瓦尔莎拉的护渔人。'},
    {2045, '抗魔联军', '各大势力的联军，致力于击败萨格拉斯之墓和破碎海滩的燃烧军团。'},
    {2099, '阿库勒-河角', '河流和鱼类大师。'},
    {1894, '守望者', '自从燃烧军团在古尔丹的帮助下攻破守望者地窟后，剩下的少数守望者就决心重建她们的监狱并追捕那些趁乱逃跑的恐怖野兽。'},
    {2100, '科尔宾', '有着一双明亮睿智眼睛的渡鸦，喜欢鱼。'},
    {1883, '织梦者', '德鲁伊和他们在瓦尔莎拉的盟友从不可考的年代起，就一直守护着翡翠梦境。'},
    {2102, '英帕斯', '被人从远方召唤的英帕斯正在收集贝壳，希望能制造出一座“魔法传送门”返回家乡。'},
    {2170, '阿古斯防卫军', '虽然有许多人都在燃烧军团征服阿古斯时奋起抗争，但并不是所有人都成功逃离了。而今在新的友军的鼓舞下，这些难民和流亡者已经联合起来，为夺回家园而战。'},
    {1828, '高岭部族', '高岭部族的人口已经逐年减少，随着卓格巴尔的威胁加剧，他们需要寻找新的盟友来拯救他们的家园。'},
    {2135, '克罗米', '克罗诺姆（简称克罗米）是一头活跃、亲切的青铜龙。拉近你与她之间关系将增强她在场景战役“克罗米之死”中的力量。'},
    {2097, '活水-伊丽西娅', '阿苏纳的皇家池塘古老的守护者。'},
    {1947, '伊利达雷', '发誓要不惜一切代价对抗燃烧军团的精灵。'},
    {1815, '吉尔尼斯幸存者'},
    {1984, '急救队', '欧莉萨拉和安吉莉克住在浮空城达拉然。她们在这里救死扶伤，治病救人。她们还向需要医疗补给的旅行者出售物品。'},

    --德拉诺之王
    {1444, '德拉诺之王'},
    {1445, '霜狼兽人', '霜火岭的霜狼兽人是一群紧密团结在一起的凶猛战士。他们能很好地适应德拉诺残酷的环境。'},
    {1711, '热砂保护协会', '热砂保护协会的地精们致力于将珍贵的遗物从纳格兰的食人魔手中解放出来。毋庸置疑，他们必然是怀着崇高的目标——把遗物卖出最高的价钱——来做这件事的。'},
    {1708, '嘲颅兽人', '嘲颅氏族的家园位于德拉诺最蛮荒的边界。他们会对来自各方的毁灭威胁报以疯狂的癫笑。'},
    {1515, '鸦人流亡者', '在黑暗中挣扎的鸦人流亡者在苦苦追寻着光明的未来。'},
    {1850, '刃牙追猎者', '危机四伏的塔纳安丛林吸引来艾泽拉斯和德拉诺出类拔萃的猎手。想要击败塔纳安的野兽，你就得比他们更野。'},
    {1849, '觉醒教派', '作为一场残酷内战的幸存者，这些四面受敌的鸦人希望找回埃匹希斯神器是帮助他们和平重建鸦人文明的关键。'},
    {1710, '沙塔尔防御者', '努力想要夺回主城的沙塔斯城防御者，但却遭到来自内部的背叛。'},
    {1731, '主教议会', '在五位强大的大主教率领下，德拉诺的德莱尼在这个蛮荒的世界中欣欣向荣。'},
    {1847, '先知之手', '伊瑞尔集结了幸存下来的大主教们，并以维伦的名义发动了攻势。当前他们正试图在塔纳安丛林建立据点，誓要将古尔丹的阴谋彻底粉碎。'},
    {1848, '沃金之锋', '要想守护艾泽拉斯，就必须在德拉诺取得决定性胜利。为此，部落酋长沃金召集了麾下最最精锐的勇士在塔纳安丛林建立据点，只为打倒古尔丹等邪恶势力。'},
    {1739, '薇薇安', '你的私人保镖，驻扎在你的兵营里。你可以通过邀请薇薇安一起战斗，与她建立起友谊。'},
    {1740, '艾达-晨光', '你的私人保镖，驻扎在你的兵营里。你可以通过邀请艾达一起战斗，与她建立起友谊。'},
    {1735, '要塞保镖', '驻扎在你兵营中的保镖。'},
    {1738, '防御者艾萝娜', '你的私人保镖，驻扎在你的兵营里。你可以通过邀请艾萝娜一起战斗，与她建立起友谊。'},
    {1733, '德尔瓦-铁拳', '你的私人保镖，驻扎在你的兵营里。你可以通过邀请德尔瓦一起战斗，与他建立起友谊。'},
    {1737, '鸦爪祭司伊沙尔', '你的私人保镖，驻扎在你的兵营里。你可以通过邀请伊沙尔一起战斗，与他建立起友谊。'},
    {1736, '托莫克', '你的私人保镖，驻扎在你的兵营里。你可以通过邀请托莫克一起战斗，与他建立起友谊'},
    {1732, '热砂港德拉诺探险队', '德拉诺有着无限的商机和极其有限的竞争。'},
    {1741, '利奥拉', '你的私人保镖，驻扎在你的兵营里。你可以通过邀请利奥拉一起战斗，与他建立起友谊。'},



    --熊猫人之谜
    {1245, '熊猫人之谜'},
    {1216, '尚喜武院', '备受尊重的尚喜大师教导过无数渴望冒险的熊猫人英雄，尚喜武院的历史也可以追溯至三代人之前。'},
    {1435, '影踪突袭营', '这些勇敢的影踪派成员们深入雷电王座，全力以赴遏制暗藏其中的邪恶势力，也为自己千百年来饱受雷电之王奴役的遭遇伸张正义。'},
    {1242, '珠鳍锦鱼人', '一支内敛而守序的鱼形人种族。'},
    {1337, '卡拉克西', '令整支螳螂妖虫群发疯的堕落之源并没有影响到这些螳螂妖长者。他们希望与潘达利亚的其他种族合作，从而找到令族群和女皇恢复如初的方法。'},
    {1302, '垂钓翁', '授人以鱼不如授人以渔，这群名为垂钓翁的熊猫人不光想着填饱族人的肚子，还希望能够提高自己的钓鱼本领。'},
    {1269, '金莲教', '这支神秘的熊猫人教派意图一劳永逸地解决魔古族带来的麻烦。'},
    {1376, '神盾守备军', '潘达利亚的联盟部队，驻扎在卡桑琅丛林的雄狮港。'},
    {1271, '云端翔龙骑士团', '东方之寺的守护者'},
    {1359, '黑王子', '黑王子拉希奥是黑龙族群的最后一员。传说他对忠诚效命者的报酬十分丰厚。'},
    {1345, '游学者', '作为潘达利亚秘密的守护者，这些勇敢的学者周游大陆，希望能以史为鉴，继往开来。'},
    {1387, '肯瑞托远征军', '被吉安娜的怒火点燃，肯瑞托远征军誓要夺取雷神岛，捍卫联盟的荣耀！'},
    {1270, '影踪派', '这个神秘莫测的熊猫人门派守护着潘达利亚的天神寺庙。'},
    {1341, '至尊天神', '勇敢的熊猫人为了保卫潘达利亚的四方神寺而与邪恶的煞战斗。'},
    {1492, '皇帝少昊', '少昊是逝去已久的熊猫人皇帝，是一位值得敬重的人物。'},
    {1375,  '统御先锋军', '潘达利亚的部落部队，驻扎在卡桑琅丛林的统御岗哨。'},
    {1388, '夺日者先锋军', '被赶离达拉然后，夺日者先锋军致力于在雷神岛的废墟间寻找强大的魔古族神器，万一部落分崩离析，好将未来掌握在自己手中。'},
    {1358, '纳特-帕格', '纳特是全世界最负盛名的钓鱼大师与美酒爱好者，在他暴躁易怒的外表下藏着一颗好为人师的心。'},
    {1228, '森林猢狲', '一支活泼、暴躁而短命的猴族。'},
    {1272, '阡陌客', '阡陌客是一个由热爱和平与劳作的熊猫人结成的农业组织。他们终日辛勤耕作，只为满足熊猫人一族对美食的终极追求。'},
    {1280, '迪娜-泥爪', '迪娜·泥爪最喜欢生活中那些精美的物品。'},
    {1275, '艾拉', '艾拉渴望成为一名伟大的酒仙，但她还有很多路要走！'},
    {1282, '玉儿-采苇', '相比其他健忘的镇民，玉儿·采苇更了解这片土地的历史。'},
    {1278, '阿烁', '作为一个壮实、自豪的农场保卫者，阿烁总会在你需要一个强壮的打手时出现。'},
    {1277, '吱吱', '如果你有关于绵羊的问题，吱吱一定能帮你解答。'},
    {1276, '老农山掌', '老农山掌是四邻八乡最有经验的养鸡专业户'},
    {1283, '农夫老方', '农夫老方家种的蔬菜可是汇风岭一绝！'},
    {1279, '郝瀚-泥爪', '作为阡陌客的可敬领袖，郝瀚·泥爪责任重大。'},
    {1281, '吉娜-泥爪', '经营半山市集使吉娜·泥爪变成了一位强势的女性！'},
    {1273, '醉鬼贾古', '贾古很容易找到——只要去看看风暴烈酒酿造厂出品的最廉价的酒桶底部就行了。'},
    {1351, '酒仙会', '这些高贵的熊猫人守护着世代相传的酿酒秘诀，为了酿造出烈性美酒而甘冒奇险。'},
    {1440, '暗矛起义军', '沃金已经公开宣布反抗加尔鲁什·地狱咆哮。在部落和联盟军队的帮助下，他正在收集资源，准备对奥格瑞玛发动总攻。'},

    --大地的裂变
    {1162, '大地的裂变'},
    {1135, '大地之环', '艾泽拉斯最强大的萨满祭司都聚集到了一起，期望能够维持这个世界各股元素力量之间的平衡。在这场大灾变中，他们正竭力修复死亡之翼的来临对世界造成的伤害。'},
    {1171, '塞拉赞恩', '塞拉赞恩和她的石领主子嗣们统治着土元素位面深岩之洲。在见证了死亡之翼及其追随者对她的国度造成的伤害后，塞拉赞恩对所有外来者都充满了敌意。'},
    {1173, '拉穆卡恒', '拉穆卡恒的猫形子民是奥丹姆守护者托维尔一族的后裔。尽管他们失去了石头的身体，但保护泰坦秘密的使命仍然留在了他们一成不变的传统中。'},
    {1158, '海加尔守护者', '圣山海加尔面临着毁灭的威胁，塞纳里奥议会集结了最强大的成员，与他们的翡翠绿龙盟友一同抵御着拉格纳罗斯和暮光之锤的入侵。'},
    {1172, '龙喉氏族', '这支狂放不羁的兽人氏族曾经在死亡之翼的授意下奴役了红龙军团和阿莱克丝塔萨。如今龙喉氏族的数量和实力都已不如往昔，他们在暮光高地上建立了家园。'},
    {1178, '地狱咆哮近卫军', '地狱咆哮近卫军是部落的一支精英部队，由最骁勇善战的老兵编制而成。加尔鲁什亲自选拔了这些战士，并命令他们夺取托尔巴拉德。只许成功，不许失败。'},
    {1174, '蛮锤部族', '蛮锤部族以他们近乎鲁莽的勇气和出类拔萃的狮鹫骑战技艺而闻名。因为黑铁矮人的诅咒，他们失去了在格瑞姆巴托的家园。在那之后，蛮锤矮人们分散地定居在暮光高地上。'},
    {1177, '巴拉丁典狱官', '这支曾经由雷吉纳德·巴拉丁二世公爵率领的精锐之师和海岛要塞托尔巴拉德有着深厚的历史渊源。他们加入了联盟军队，旨在击退部落入侵者并捍卫这座极具战略意义的岛屿。'},
    {1204, '海加尔复仇者', '火元素领主带来的毁灭激怒了塞纳里奥议会。他们主动出击，直捣拉格纳罗斯在火焰之地的巢穴。'},

    --巫妖王之怒
    {1097, '巫妖王之怒'},
    {1090, '肯瑞托', '统治达拉然的法师和大法师们。由于蓝龙军团和亡灵天灾造成的威胁，他们将整座城市传送到了诺森德的腹地。'},
    {1037, '联盟先遣军', '联盟派往诺森德的多支部队的统称，由无畏远征军领导。同时也包括一些非军事组织，如探险者协会。'},
    {1094, '银色盟约', '这支高等精灵中的精锐部队拒绝让血精灵进入肯瑞托。他们联合在温蕾萨·风行者的旗帜下，与诺森德的联盟军队并肩作战。'},
    {1105, '神谕者', '索拉查盆地的鳄鱼人将自己视为该区域中存留的泰坦科技的守护者（虽然他们基本不了解这种科技）。目前他们正在与狼獾人进行着不断激化的领土战争。'},
    {1073, '卡鲁亚克', '海象人是坚韧而和平的种族，通过捕鲸和捕鱼谋生。他们的家园最近正在遭受凶猛的攻击，急需来自外界的援手。'},
    {1156, '灰烬审判军', '在提里奥·弗丁与达里安·莫格莱尼的共同协议下，银色北伐军与黑锋骑士团决定暂时放下分歧、统一战线，合力攻入冰冠堡垒，击败巫妖王。'},
    {1098, '黑锋骑士团', '在脱离了巫妖王的控制之后，这些曾经效命于他的死亡骑士联合起来，在大领主达里安·莫格莱尼的领导下对抗巫妖王。'},
    {1119, '霍迪尔之子', '这支风暴峭壁的冰霜巨人部族非常好战，他们定居在丹尼芬雷。'},
    {1106, '银色北伐军', '提里奥·弗丁领导的银色北伐军是由白银之手骑士团和银色黎明重组而成的，他们的目标是击溃巫妖王的军队。'},
    {1124, '夺日者', '在大法师艾萨斯·夺日者的努力下，一贯被达拉然据之门外的部落也获准进入这座城市。他的追随者保卫着以他的名字命名的夺日者圣殿。'},
    {1091, '龙眠联军', '由于蓝龙军团粗暴地干涉凡人种族使用魔法的权利，其余的龙族不得不联合在红龙军团旗下，与这些狂乱的同胞抗衡。'},
    {1094, '银色盟约', '这支高等精灵中的精锐部队拒绝让血精灵进入肯瑞托。他们联合在温蕾萨·风行者的旗帜下，与诺森德的联盟军队并肩作战。'},
    {1050, '无畏远征军', '联盟在诺森德的主力部队，由瓦里安·乌瑞恩国王统领，对抗天灾军团。'},
    {1037, '联盟先遣军', '联盟派往诺森德的多支部队的统称，由无畏远征军领导。同时也包括一些非军事组织，如探险者协会。'},
    {1104, '狂心氏族', '这群凶猛的狼獾人被天灾军团追杀，偶然来到了索拉查盆地，遂决定在此安家。由于极富攻击性，他们与被称为神谕者的鳄鱼人部族成水火之势。'},
    {1085, '战歌远征军', '部落的主力部队由加尔鲁什·地狱咆哮率领，向盘踞在诺森德的阿尔萨斯和天灾军团发起挑战。'},
    {1052, '部落先遣军', '部落派往诺森德的多支部队的统称，由战歌远征军充当先头部队。'},
    {1068, '探险者协会', '这个组织致力于通过发掘泰坦遗留下来的古器追寻矮人种族的起源。最近他们来到诺森德的多处古迹进行研究。'},
    {1126, '霜脉矮人', '这个神秘的冰霜矮人种族定居在风暴峭壁。他们最近与探险者协会成为了朋友，并且欢迎联盟的成员造访他们的家园。'},
    {1067, '复仇之手', '这支由希尔瓦娜斯·风行者派遣的被遗忘者势力想要在诺森德散播他们最新研制成功的瘟疫病菌，以此来向阿尔萨斯复仇。'},
    {1064, '牦牛人', '这些坚强的牦牛人是牛头人的同类，在部落远征诺森德的战役中，他们成为了具有重要价值的斥候。'},
    {1117, '索拉查盆地'},


    --燃烧的远征
    {980, '燃烧的远征'},
    {989, '时光守护者', '这些由诺兹多姆亲自挑选的青铜龙无时无刻不在监视着时光之穴。'},
    {1015, '灵翼之龙', '这种罕见的龙是死亡之翼的后代，受到原始的虚空能量影响后发生了变异。现在，他们正在努力摆脱死亡之翼的血脉带来的阴影，找寻自己的命运。'},
    {1031, '沙塔尔天空卫队', '一支由沙塔斯城建立的空中武装力量，职责是应对潜伏在外域天空中的威胁。'},
    {1077, '破碎残阳', '沙塔斯城的精锐部队，目标是向太阳之井的凯尔萨斯王子发动最终的攻势。'},
    {933, '星界财团', '由星界巨商哈拉麦德领导的星界财团是一个结构松散的商业联盟，其成员都是从事走私、贸易或盗窃的虚灵。'},
    {934, '占星者', '由先知沃雷塔尔领导的这群血精灵拒绝跟随凯尔萨斯。他们加入了沙塔斯城的纳鲁联军，这令奥尔多感到非常不安。'},
    {978, '库雷尼', '在德莱尼语中意为“得到救赎”。这些从各种奴役和控制中逃出来的破碎者在纳格兰建立了自己的家园，寻找自己真正的命运。'},
    {942, '塞纳里奥远征队', '塞纳里奥议会派往外域研究生态的探险队。在黑暗之门开启后，远征队迅速壮大，并获得了自治权。'},
    {932, '奥尔多', '一个古老的德莱尼祭司组织，起初由维伦领导。现在他们在高阶女祭司伊沙娜的指引下为沙塔斯城的纳鲁效力。与占星者势力敌对。'},
    {941, '玛格汉', '这群隐居的棕皮兽人逃脱了恶魔的腐蚀，并在天崩地裂的外域中保持了古老的传统。'},
    {970, '孢子村', '生活在外域的孢子人是一个非常温和的种族。他们的家园就坐落在赞加沼泽南部的沼泽地中。'},
    {1038, '奥格瑞拉', '聪明而开化的奥格瑞拉食人魔居住在刀锋山的西部区域，那里富产的埃匹希斯水晶使得他们的智商远远超越了其他野蛮的同类。'},
    {946, '荣耀堡', '这座前哨基地坐落在地狱火半岛上，由第一批深入德拉诺的联盟精英部队“洛萨之子”的残余力量坚守。现在他们得到了来自暴风城和铁炉堡的支援。'},
    {967, '紫罗兰之眼', '一个由肯瑞托为了调查麦迪文和监视他的活动而建立的秘密组织。'},
    {1012, '灰舌死誓者', '来自破碎者灰舌部族的精英勇士，表面上与伊利丹结盟。这些勇士是阿卡玛最信任的部下，并参与了他的秘密计划。'},
    {935, '沙塔尔', '沙塔尔是一群统治沙塔斯城的强大纳鲁人的组织。在奥尔多和占星者的帮助下，他们正在领导针对伊利丹和燃烧军团的战斗。'},
    {1011, '贫民窟', '来自各个地方、各个种族的避难者在沙塔斯城的聚集地。在贫民窟中，善行善举总是会很快传遍所有人的耳朵。'},
    {990, '流沙之鳞', '隶属于青铜龙军团的秘密组织，由诺兹多姆最亲密的伴侣索莉多米领导。'},
    {922, '塔奎林', '塔奎林曾是一座高等精灵的城镇，但是在天灾军团入侵奎尔萨拉斯之后被废弃了。现在，被遗忘者和血精灵联手夺回了这座城镇。'},
    {947, '萨尔玛', '由萨尔派出的远征军在地狱火半岛建立的要塞。萨尔玛是部落在外域的大部分行动的根据地。'},
    {936, '沙塔斯城'},


    --经典旧世
    {1118, '经典旧世'},
    {749, '海达希亚水元素', '这些元素生物定居于艾萨拉的东部的一座小岛上，是拉格纳罗斯及其军团的死敌。'},
    {909, '暗月马戏团', '一个向全世界展示着各类珍奇异宝的马戏团。马戏团位于一座神秘的岛屿上，只在每月的第一周开放。'},
    {529, '银色黎明', '一个致力于从亡灵天灾军团的威胁下拯救艾泽拉斯世界的组织。银色黎明的据点遍布东西瘟疫之地。'},
    {21, '藏宝海湾', '一个由黑水海盗的头目，大财主里维加兹经营的繁荣的海港城市。它也是热砂集团的一部分，主要仇敌是血帆海盗。'},
    {87, '血帆海盗', '一群嗜血的海盗，所有海上商人的公敌。藏宝海湾的死敌。'},
    {609, '塞纳里奥议会', '塞纳里奥议会的德鲁伊是自然的守卫者，他们定居于宁静的月光林地。'},
    {576, '木喉要塞', '作为最后一支尚未堕落的熊怪部族，木喉部族正致力于保留他们那种独特的精神修行之道，并试图终结其他熊怪部族的痛苦。'},
    {349, '拉文霍德', '这个由盗贼与刺客组成的行会只欢迎那些有着出色实力的人进入他们的领地。他们也是辛迪加的仇敌。'},
    {59, '瑟银兄弟会', '瑟银兄弟会的矮人有着无与伦比的制造技术，并致力于解开黑石山中的全部秘密'},
    {72, '暴风城', '这座人类势力的最后堡垒目前由年轻但是睿智的国王安度因·乌瑞恩统治着。'},
    {470, '棘齿城', '热砂集团的成员，这座城市给许多希望在贫瘠之地做生意的人提供了一个开放和中立的天堂。'},
    {530, '暗矛巨魔', '一群被放逐的巨魔，加入了萨尔领导下的部落。他们现在将杜隆塔尔当作自己的新家，并与兽人盟友们一起生活在那里。'},
    {910, '诺兹多姆的子嗣', '青铜龙军团的后代，时间的守卫者，对凡人种族漠不关心。'},
    {369, '加基森', '热砂集团的首府，诸多优秀地精技师、炼金师和商人的家乡。'},
    {69, '达纳苏斯', '坐落在泰达希尔岛上的联盟城市，暗夜精灵的首都，由月之女祭司泰兰德·语风统治。'},
    {76, '奥格瑞玛', '这座由萨尔建立的部落城市是许多兽人氏族的家园。'},
    {169, '热砂港'},
    {81, '雷霆崖', '贝恩·血蹄及其领导下的牛头人的家园，壮丽而伟大的部落城市。'},
    {577, '永望镇', '热砂集团经营之下的一座贸易城市，坐落于冬泉谷的两条主要干道的交叉处。'},
    {510, '污染者', '污染者试图为部落夺取阿拉希盆地的重要资源'},
    {68, '幽暗城', '希尔瓦娜斯·风行者领导下的被遗忘者与部落之间建立起了微弱的同盟关系，并在洛丹伦地下遗迹的深处建立起了这座城市。'},
    {70, '辛迪加', '一个主要由人类组成的犯罪组织，目前占据着奥特兰克山脉与希尔斯布莱德丘陵的部分地区。'},
    {509, '阿拉索联军', '阿拉索联军正试图为暴风城夺回阿拉希盆地。'},
    {589, '冬刃豹训练师', '这是一些专门在冬泉谷地区驯养冬泉霜刃豹的暗夜精灵。'},
    {890, '银翼要塞', '灰谷地区坚定的守卫者，目前正与战歌氏族在战歌峡谷中激烈交战'},
    {47, '铁炉堡', '这座联盟的大都市是丹莫罗矮人们的骄傲，也是麦格尼国王的家。'},
    {270, '赞达拉部族', '这群居住在尤亚姆巴岛的巨魔正在努力招募全世界的勇士，希望他们能够帮助自己对抗祖尔格拉布中的邪神哈卡以及他的阿塔莱祭司们。'},
    {54, '诺莫瑞根', '诺莫瑞根以前的居民，现在流亡到了新工匠镇并居住在此，联盟方的重要成员。'},
    {809, '辛德拉', '一群居住在厄运之槌的精灵后裔，他们仍然具有着相当渊博的智慧与学识，并保守着一些伟大的秘密。'},
    {92, '吉尔吉斯半人马', '一群居住在凄凉之地南方的半人马，玛格拉姆半人马的仇敌。'},
    {889, '战歌氏族', '战歌氏族是最具攻击性的兽人氏族，目前正与暗夜精灵的银翼哨兵部队在战歌峡谷激烈地交战中。'},
    {729, '霜狼氏族', '霜狼氏族正在努力将雷矛探险队赶出奥特兰克山谷。'},
    {93, '玛格拉姆半人马', '一群居住在凄凉之地东部的半人马，吉尔吉斯半人马的仇敌。'},
    {469, '联盟'},
    {730, '雷矛卫队', '一群在奥特兰克山谷建立了永久居所的矮人，正与霜狼氏族的兽人激烈交战中。'},
    {67, '部落'},
    {892, '部落军队'},
    {891, '联盟部队'},

    {1168, '公会', '公会声望代表了你在公会中的个人地位，购买公会奖励时需要达到与之对应的声望。公会声望会在你获得公会经验值时自动获得。'},
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

    --if e.Player.class=='HUNTER' then
    {1462, '野兽知识', '收集目标野兽的相关资料，显示其饮食习惯、技能、专精、能否被驯服，以及是否属于奇珍异兽。'},
    {2641, '解散宠物', '暂时解散你的宠物。之后你可以重新召唤它。'},
    {6991, '喂养宠物', '使用指定的食物为你的宠物喂食，立即为其恢复50%的总生命值。无法在战斗中使用。|n|n你可以使用野兽知识技能，确认自己的宠物喜欢吃哪种食物。'},
    {136, '治疗宠物', '在10 sec内为你的宠物恢复50%的最大生命值。|n[|cff00ccff荒野医疗|r]: 每次使用治疗宠物进行治疗时，都有25%的几率为你的宠物净化一个有害的魔法效果。'},
    {982, '复活宠物', '复活你的宠物，并为其恢复100%的基础生命值'},
    {1515, '驯服野兽', '尝试驯服一只野兽，使其成为你的伙伴。一旦你因为任何原因而失去了它的注意力，驯服过程就将失败。|n|n你必须解散任何当前激活的野兽伙伴并且有一个空的召唤宠物空格才能驯服新宠物。只有野兽控制专精的猎人才能驯服奇珍异兽。'},

    --elseif e.Player.class=='MAGE' then
    --if e.Player.faction=='Horde' then--部落
    {3567, '传送-奥格瑞玛', '将你传送到|cff00ccff奥格瑞玛|r。'},
    {11417, '传送门-奥格瑞玛', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff奥格瑞玛|r。'},
    {3563, '传送-幽暗城', '将你传送到|cff00ccff幽暗城|r'},
    {11418,'传送门-幽暗城', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff幽暗城|r。'},
    {3566, '传送-雷霆崖', '将你传送到|cff00ccff雷霆崖'},
    {11420, '传送门-雷霆崖', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff雷霆崖|r。'},
    {32272, '传送-银月城', '将你传送到|cff00ccff银月城|r。'},
    {32267, '传送门-银月城', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff银月城|r。'},
    {49358, '传送-斯通纳德', '将你传送到|cff00ccff斯通纳德|r。'},
    {49361, '传送门-斯通纳德', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff斯通纳德|r。'},
    {35715, '传送-沙塔斯', '将你传送到|cff00ccff沙塔斯|r。'},
    {35717, '传送门-沙塔斯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff沙塔斯城|r。'},
    {53140, '传送-达拉然-诺森德', '将你传送到|cff00ccff诺森德的达拉然|r。'},
    {53142, '传送门-达拉然-诺森德', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff达拉然。'},
    {88344, '传送-托尔巴拉德', '将你传送到|cff00ccff托尔巴拉德|r。'},
    {88346, '传送门-托尔巴拉德', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff托尔巴拉德|r。'},
    {132627, '传送-锦绣谷', '将你传送到|cff00ccff锦绣谷|r。'},
    {132626, '传送门-锦绣谷', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff锦绣谷|r。'},
    {176242, '传送-战争之矛', '将你传送至|cff00ccff战争之矛。'},
    {176244, '传送门-战争之矛', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff战争之矛|r。'},
    {281404, '传送-达萨罗', '将你传送|cff00ccff到达萨罗|r。'},
    {281402, '传送门-达萨罗', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff达萨罗|r。'},
    --elseif e.Player.faction=='Alliance' then
    {3561, '传送-暴风城', '将你传送到|cff00ccff暴风城|r。'},
    {10059, '传送门-暴风城', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff暴风城|r。'},
    {3562, '传送-铁炉堡', '将你传送到|cff00ccff铁炉堡|r。'},
    {11416, '传送门-铁炉堡', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff铁炉堡|r。'},
    {3565, '传送-达纳苏斯', '将你传送到|cff00ccff达纳苏斯|r。'},
    {11419, '传送门-达纳苏斯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff达纳苏斯|r。'},
    {32271, '传送-埃索达', '将你传送到|cff00ccff埃索达|r。'},
    {32266, '传送门-埃索达', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff埃索达|r。'},
    {49359, '传送-塞拉摩', '将你传送到|cff00ccff塞拉摩|r。'},
    {49360, '传送门-塞拉摩', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff塞拉摩|r。'},
    {33690, '传送-沙塔斯', '将你传送到|cff00ccff沙塔斯|r。'},
    {33691, '传送门-沙塔斯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff沙塔斯城|r。'},
    {53140, '传送-达拉然-诺森德', '将你传送到|cff00ccff诺森德的达拉然|r。'},
    {53142, '传送门-达拉然-诺森德', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff达拉然|r。'},
    {88342, '传送-托尔巴拉德', '将你传送到|cff00ccff托尔巴拉德|r。'},
    {88345, '传送门-托尔巴拉德', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff托尔巴拉德|r。'},
    {132621, '传送-锦绣谷', '将你传送到|cff00ccff锦绣谷|r。'},
    {132620, '传送门-锦绣谷', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff锦绣谷城|r。'},
    {176248, '传送-暴风之盾', '将你传送到|cff00ccff暴风之盾|r。'},
    {176246, '传送门-暴风之盾', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff暴风之盾|r。'},
    {281403, '传送-伯拉勒斯', '将你传送到|cff00ccff伯拉勒斯|r。'},
    {281400, '传送门-伯拉勒斯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff伯拉勒斯|r。'},
    --end
    {224869, '传送-达拉然-破碎群岛', '将你传送至破碎群岛的|cff00ccff达拉然|r。'},
    {224871, '传送门-达拉然-破碎群岛', '制造一个传送门，将使用传送门的队伍成员传送到破碎群岛的|cff00ccff达拉然|r。'},
    {344587, '传送-奥利波斯', '将你传送至|cff00ccff奥利波斯|r。'},
    {344597, '传送门-奥利波斯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff奥利波斯|r。'},
    {395277, '传送-瓦德拉肯', '将你传送到|cff00ccff瓦德拉肯|r。'},
    {395289, '传送门-瓦德拉肯', '制造一个传送门，将使用传送门的队伍成员传送到|cff00ccff瓦德拉肯|r。'},
    {120145, '远古传送-达拉然', '将你传送到|cff00ccff达拉然|r。'},
    {193759, '传送-守护者圣殿', '将你传送至|cff00ccff守护者圣殿|r。'},
    --end
}



























local curcurrencyTab={-- {', ''},
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



    {2812, '守护巨龙的觉醒纹章', '从巨龙时代第4赛季的史诗难度的团队副本以及不低于+6级的史诗钥石地下城获得。'},
    {2809, '魔龙的觉醒纹章', '从巨龙时代第4赛季的英雄难度的团队副本以及不超过+5级的史诗钥石地下城获得。'},
    {2806, '雏龙的觉醒纹章', '从巨龙时代第4赛季的许多户外活动、随机难度的团队副本以及英雄地下城获得。'},
    {2807, '幼龙的觉醒纹章', '从巨龙时代第4赛季的某些户外活动、普通难度的团队副本以及+0级的史诗地下城获得。'},
    {2912, '苏生觉醒', '苏生觉醒可以给复苏化生台充能，使其可以将不可思议的能量灌注到护甲里。'},

    --熊猫人之谜
    {738, '次级好运护符', '携带次级好运护符能带来好运，并能最终兑换战火徽记，使玩家在赢得团队副本战斗后有机会使用一枚硬币来赢取额外的奖励。'},
    {777, '永恒铸币', '你在恍惚中感觉到这枚铸币过去与未来的拥有者的手指拂过你的掌心，仿佛时间的界限被模糊了。你可以用它在永恒岛上换取强大且多样性的奖励。'},
    {697, '长者的好运符', '长者好运符的拥有者在战胜魔古山宝库、恐惧之心、永春台中的首领，以及怒之煞或萨莱斯的兵团后有机会使用一枚硬币来赢取额外的奖励。'},
    {752, '魔古命运符文', '魔古命运符文的拥有者也许能在战胜雷电王座中的首领后，以及在战胜纳拉克或乌达斯塔后获得额外的战利品奖励。'},
    {789, '染血铸币', '从死于永恒岛周围迷雾中的敌人身上摸来的铸币。'},
    {776, '战火徽记', '拥有战火徽记的幸运儿有机会在决战奥格瑞玛、天神试炼和斡耳朵圣殿中用一枚徽记换取一份额外奖励。'},


    --其它
    {2778, '青铜', '伊特努丝的永恒龙盟友用松散的时间帛线压缩成青铜铸币进行交易。'},
    {2032, '商贩标币', '商贩标币可以用来在商栈交易商品。'},
    {81, '美食家奖章', '造访各个主城以及诺森德的达拉然的特殊烹饪供应商，购买罕见的烹饪配方、香料以及大厨的帽子！'},
    {515, '暗月奖券', '在暗月马戏团的游戏中获胜或完成工作人员交付的任务后获得。'},
    {2588, '艾泽拉斯骑手会徽章', '在艾泽拉斯骑手会的比赛中获得。可以用来在瓦德拉肯和艾泽拉斯骑手会的商人交易商品。'},
    {1379, '时尚试炼奖币', '通过参与时尚试炼获得。可以在绝大多数主城兑换可幻化的装备。'},
    {402, '铁掌徽记', '代表你受到了烹饪世家——铁掌家族的嘉许。可在半山市集的库房管理员处兑换烹饪配料和其它物品。'},
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

















local function Init_Add_Data()
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

    e.strText[C_Item.GetItemClassInfo(7)] = "商业技能"
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

    e.strText[C_Item.GetItemClassInfo(8)] = "物品强化"

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

    e.strText[C_Item.GetItemClassInfo(13)] = "钥匙"
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

    e.strText[C_Item.GetItemClassInfo(15)] = "杂项"
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
end














--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self)
    local Save= WoWToolsSave[BUG_CATEGORY15] or {}
    do
        if e.onlyChinese and not Save.disabled then
            for journalEncounterID, name in pairs(instanceBossTab) do
                local bossName= EJ_GetEncounterInfo(journalEncounterID)
                if bossName then
                    e.strText[bossName]= name
                end
            end

            for _, info in pairs(instanceTab) do
                local name= EJ_GetInstanceInfo(info[1])
                if name then
                    e.strText[name]= info[2]
                end
            end

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

            for mapChallengeModeID, info in pairs(e.ChallengesSpellTabs) do
                if info.spell then
                    if info.spellName then
                        local name= GetSpellInfo(info.spell)
                        e.strText[name]= info.spellName
                    end
                    if info.spellDes then
                        local desc = GetSpellDescription(info.spell)
                        if desc then
                            e.strText[desc]= info.spellDes
                        end
                    end
                end
                if info.insName and info.ins then
                    local name, description= EJ_GetInstanceInfo(info.ins)
                    if name then
                        e.strText[name]= info.insName
                    end
                    if info.insDesc and description then
                        e.strText[description]= info.insDesc
                    end
                end
                if info.name then
                    local name= C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
                    if name then
                        e.strText[name]= info.name
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
            C_Timer.After(2, Init_Add_Data)
        else
            Init_Add_Data=function()end
        end
    end
    specTab=nil
    spellTab=nil
    fanctionTab=nil
    curcurrencyTab=nil
    raceTab=nil
    affixTab=nil
    instanceTab=nil
    instanceBossTab=nil
    self:UnregisterEvent('ADDON_LOADED')
end)