local id, e = ...
if e.Player.region~=3 and not e.Is_PTR then-- LOCALE_zhCN or LOCALE_zhTW 
    return
end
--https://wago.tools/db2/UiMap?locale=zhCN

local tab={
[1]= '杜隆塔尔',
[2]= '火刃集会所',
[3]= '提拉加德城堡',
[4]= '提拉加德城堡',
[5]= '骷髅石',
[6]= '尘风洞穴',
[7]= '莫高雷',
[8]= '白鬃石',
[9]= '风险投资公司矿洞',
[10]= '北贫瘠之地',
[11]= '哀嚎洞穴',
[12]= '卡利姆多',
[13]= '东部王国',
[14]= '阿拉希高地',
[15]= '荒芜之地',
[16]= '奥达曼',
[17]= '诅咒之地',
[18]= '提瑞斯法林地',
[19]= '血色修道院入口',
[20]= '守护者之眠',
[21]= '银松森林',
[22]= '西瘟疫之地',
[23]= '东瘟疫之地',
[24]= '圣光之愿礼拜堂',
[25]= '希尔斯布莱德丘陵',
[26]= '辛特兰',
[27]= '丹莫罗',
[28]= '寒脊山小径',
[29]= '灰色洞穴',
[30]= '新工匠镇',
[31]= '古博拉采掘场',
[32]= '灼热峡谷',
[33]= '黑石山',
--[34]= '黑石山',
--[35]= '黑石山',
[36]= '燃烧平原',
[37]= '艾尔文森林',
[38]= '法戈第矿洞',
--[39]= '法戈第矿洞',
[40]= '玉石矿洞',
[41]= '达拉然',
[42]= '逆风小径',
[43]= '麦迪文的酒窖',
--[44]= '麦迪文的酒窖',
--[45]= '麦迪文的酒窖',
[46]= '卡拉赞墓穴',
[47]= '暮色森林',
[48]= '洛克莫丹',
[49]= '赤脊山',
[50]= '北荆棘谷',
[51]= '悲伤沼泽',
[52]= '西部荒野',
[53]= '金海岸矿洞',
[54]= '詹戈洛德矿洞',
[55]= '死亡矿井',
[56]= '湿地',
[57]= '泰达希尔',
[58]= '黑丝洞',
[59]= '地狱石',
[60]= '班尼希尔兽穴',
--[61]= '班尼希尔兽穴',
[62]= '黑海岸',
[63]= '灰谷',
[64]= '千针石林',
[65]= '石爪山脉',
[66]= '凄凉之地',
[67]= '玛拉顿',
[68]= '玛拉顿',
[69]= '菲拉斯',
[70]= '尘泥沼泽',
[71]= '塔纳利斯',
[72]= '腐化之巢',
[73]= '大裂口',
[74]= '时光之穴',
[75]= '时光之穴',
[76]= '艾萨拉',
[77]= '费伍德森林',
[78]= '安戈洛环形山',
[79]= '巨痕谷',
[80]= '月光林地',
[81]= '希利苏斯',
[82]= '暮光小径',
[83]= '冬泉谷',
[84]= '暴风城',
[85]= '奥格瑞玛',
[86]= '奥格瑞玛',
[87]= '铁炉堡',
[88]= '雷霆崖',
[89]= '达纳苏斯',
[90]= '幽暗城',
[91]= '奥特兰克山谷',
[92]= '战歌峡谷',
[93]= '阿拉希盆地',
[94]= '永歌森林',
[95]= '幽魂之地',
[96]= '阿曼尼墓穴',
[97]= '秘蓝岛',
[98]= '海潮洞窟',
[99]= '止松要塞',
[100]= '地狱火半岛',
[101]= '外域',
[102]= '赞加沼泽',
[103]= '埃索达',
[104]= '影月谷',
[105]= '刀锋山',
[106]= '秘血岛',
[107]= '纳格兰',
[108]= '泰罗卡森林',
[109]= '虚空风暴',
[110]= '银月城',
[111]= '沙塔斯城',
[112]= '风暴之眼',
[113]= '诺森德',
[114]= '北风苔原',
[115]= '龙骨荒野',
[116]= '灰熊丘陵',
[117]= '嚎风峡湾',
[118]= '冰冠冰川',
[119]= '索拉查盆地',
[120]= '风暴峭壁',
[121]= '祖达克',
[122]= '奎尔丹纳斯岛',
[123]= '冬拥湖',
[124]= '东瘟疫之地：血色领地',
[125]= '达拉然',
[126]= '达拉然',
[127]= '晶歌森林',
[128]= '远古海滩',
[129]= '魔枢',
[130]= '净化斯坦索姆',
--[131]= '净化斯坦索姆',
[132]= '安卡赫特：古代王国',
[133]= '乌特加德城堡',
--[134]= '乌特加德城堡',
--[135]= '乌特加德城堡',
--[136]= '乌特加德之巅',
--[137]= '乌特加德之巅',
[138]= '闪电大厅',
[139]= '闪电大厅',
[140]= '岩石大厅',
[141]= '永恒之眼',
[142]= '魔环',
--[143]= '魔环',
--[144]= '魔环',
--[145]= '魔环',
--[146]= '魔环',
[147]= '奥杜尔',
--[148]= '奥杜尔',
--[149]= '奥杜尔',
--[150]= '奥杜尔',
--[151]= '奥杜尔',
--[152]= '奥杜尔',
[153]= '古达克',
--[154]= '古达克',
[155]= '黑曜石圣殿',
[156]= '阿尔卡冯的宝库',
[157]= '艾卓-尼鲁布',
--[158]= '艾卓-尼鲁布',
--[159]= '艾卓-尼鲁布',
[160]= '达克萨隆要塞',
--[161]= '达克萨隆要塞',
[162]= '纳克萨玛斯',
--[163]= '纳克萨玛斯',
--[164]= '纳克萨玛斯',
--[165]= '纳克萨玛斯',
--[166]= '纳克萨玛斯',
--[167]= '纳克萨玛斯',
[168]= '紫罗兰监狱',
[169]= '征服之岛',
[170]= '洛斯加尔登陆点',
[171]= '冠军的试炼',
[172]= '十字军的试练',
[173]= '十字军的试练',
[174]= '失落群岛',
[175]= '卡亚矿洞',
[176]= '沃卡洛斯的巢穴',
[177]= '加里维克斯劳工矿井',
--[178]= '加里维克斯劳工矿井',
[179]= '吉尔尼斯',
[180]= '烬石矿脉',
[181]= '格雷迈恩庄园',
--[182]= '格雷迈恩庄园',
[183]= '灵魂洪炉',
[184]= '萨隆矿坑',
[185]= '映像大厅',
[186]= '冰冠堡垒',
--[187]= '冰冠堡垒',
--[188]= '冰冠堡垒',
--[189]= '冰冠堡垒',
--[190]= '冰冠堡垒',
--[191]= '冰冠堡垒',
--[192]= '冰冠堡垒',
--[193]= '冰冠堡垒',
[194]= '科赞',
[195]= '卡亚矿井',
--[196]= '卡亚矿井',
--[197]= '卡亚矿井',
[198]= '海加尔山',
[199]= '南贫瘠之地',
[200]= '红玉圣殿',
[201]= '柯尔普萨之森',
[202]= '吉尔尼斯城',
[203]= '瓦丝琪尔',
[204]= '无底海渊',
[205]= '烁光海床',
[206]= '双子峰',
[207]= '深岩之洲',
[208]= '暮光深渊',
[209]= '暮光深渊',
[210]= '荆棘谷海角',
[213]= '怒焰裂谷',
[217]= '吉尔尼斯废墟',
[218]= '吉尔尼斯城废墟',
[219]= '祖尔法拉克',
[220]= '阿塔哈卡神庙',
[221]= '黑暗深渊',
--[222]= '黑暗深渊',
--[223]= '黑暗深渊',
[224]= '荆棘谷',
[225]= '监狱',
[226]= '诺莫瑞根',
--[227]= '诺莫瑞根',
--[228]= '诺莫瑞根',
--[229]= '诺莫瑞根',
[230]= '奥达曼',
[231]= '奥达曼',
[232]= '熔火之心',
[233]= '祖尔格拉布',
[234]= '厄运之槌',
--[235]= '厄运之槌',
--[236]= '厄运之槌',
--[237]= '厄运之槌',
--[238]= '厄运之槌',
--[239]= '厄运之槌',
--[240]= '厄运之槌',
[241]= '暮光高地',
[242]= '黑石深渊',
--[243]= '黑石深渊',
[244]= '托尔巴拉德',
[245]= '托尔巴拉德半岛',
[246]= '破碎大厅',
[247]= '安其拉废墟',
[248]= '奥妮克希亚的巢穴',
[249]= '奥丹姆',
[250]= '黑石塔',
--[251]= '黑石塔',
--[252]= '黑石塔',
--[253]= '黑石塔',
--[254]= '黑石塔',
--[255]= '黑石塔',
[256]= '奥金尼地穴',
--[257]= '奥金尼地穴',
[258]= '塞泰克大厅',
--[259]= '塞泰克大厅',
[260]= '暗影迷宫',
[261]= '鲜血熔炉',
[262]= '幽暗沼泽',
[263]= '蒸汽地窟',
--[264]= '蒸汽地窟',
[265]= '奴隶围栏',
[266]= '生态船',
[267]= '能源舰',
--[268]= '能源舰',
[269]= '禁魔监狱',
--[270]= '禁魔监狱',
--[271]= '禁魔监狱',
[272]= '法力陵墓',
[273]= '黑色沼泽',
[274]= '旧希尔斯布莱德丘陵',
[275]= '吉尔尼斯之战',
[276]= '大漩涡',
[277]= '托维尔失落之城',
[279]= '哀嚎洞穴',
[280]= '玛拉顿',
--[281]= '玛拉顿',
[282]= '巴拉丁监狱',
[283]= '黑石岩窟',
--[284]= '黑石岩窟',
[285]= '黑翼血环',
--[286]= '黑翼血环',
[287]= '黑翼之巢',
--[288]= '黑翼之巢',
--[289]= '黑翼之巢',
--[290]= '黑翼之巢',
[291]= '死亡矿井',
--[292]= '死亡矿井',
[293]= '格瑞姆巴托',
[294]= '暮光堡垒',
--[295]= '暮光堡垒',
--[296]= '暮光堡垒',
[297]= '起源大厅',
--[298]= '起源大厅',
--[299]= '起源大厅',
[300]= '剃刀高地',
[301]= '剃刀沼泽',
[302]= '血色修道院',
--[303]= '血色修道院',
--[304]= '血色修道院',
--[305]= '血色修道院',
[306]= '通灵学院的传承',
--[307]= '通灵学院的传承',
--[308]= '通灵学院的传承',
--[309]= '通灵学院的传承',
[310]= '影牙城堡',
--[311]= '影牙城堡',
--[312]= '影牙城堡',
--[313]= '影牙城堡',
--[314]= '影牙城堡',
--[315]= '影牙城堡',
--[316]= '影牙城堡',
[317]= '斯坦索姆',
--[318]= '斯坦索姆',
[319]= '安其拉',
--[320]= '安其拉',
--[321]= '安其拉',
[322]= '潮汐王座',
--[323]= '潮汐王座',
[324]= '巨石之核',
[325]= '旋云之巅',
[327]= '安其拉：堕落王国',
[328]= '风神王座',
[329]= '海加尔峰',
[330]= '格鲁尔的巢穴',
[331]= '玛瑟里顿的巢穴',
[332]= '毒蛇神殿',
[333]= '祖阿曼',
[334]= '风暴要塞',
[335]= '太阳之井高地',
--[336]= '太阳之井高地',
[337]= '祖尔格拉布',
[338]= '熔火前线',
[339]= '黑暗神殿',
--[340]= '黑暗神殿',
--[341]= '黑暗神殿',
--[342]= '黑暗神殿',
--[343]= '黑暗神殿',
--[344]= '黑暗神殿',
--[345]= '黑暗神殿',
--[346]= '黑暗神殿',
[347]= '地狱火城墙',
[348]= '魔导师平台',
--[349]= '魔导师平台',
[350]= '卡拉赞',
--[351]= '卡拉赞',
--[352]= '卡拉赞',
--[353]= '卡拉赞',
--[354]= '卡拉赞',
--[355]= '卡拉赞',
--[356]= '卡拉赞',
--[357]= '卡拉赞',
--[358]= '卡拉赞',
--[359]= '卡拉赞',
--[360]= '卡拉赞',
--[361]= '卡拉赞',
--[362]= '卡拉赞',
--[363]= '卡拉赞',
--[364]= '卡拉赞',
--[365]= '卡拉赞',
--[366]= '卡拉赞',
[367]= '火焰之地',
--[368]= '火焰之地',
--[369]= '火焰之地',
[370]= '魔枢',
[371]= '翡翠林',
[372]= '绿石采掘场',
--[373]= '绿石采掘场',
[374]= '蛛泣洞穴',
[375]= '乌拿猴洞',
[376]= '四风谷',
[377]= '无尽回声洞窟',
[378]= '迷踪岛',
[379]= '昆莱山',
[380]= '凛风洞',
[381]= '顽灵洞',
[382]= '肘锤洞窟',
[383]= '深石窟',
--[384]= '深石窟',
[385]= '征服者陵墓',
[386]= '寇茹废墟',
[387]= '寇茹废墟',
[388]= '螳螂高原',
[389]= '砮皂寺',
[390]= '锦绣谷',
[391]= '双月殿',
--[392]= '双月殿',
[393]= '七星殿',
--[394]= '七星殿',
[395]= '郭莱古厅',
[396]= '郭莱古厅',
[397]= '风暴之眼',
[398]= '永恒之井',
[399]= '暮光审判',
--[400]= '暮光审判',
[401]= '时光之末',
--[402]= '时光之末',
--[403]= '时光之末',
--[404]= '时光之末',
--[405]= '时光之末',
--[406]= '时光之末',
[407]= '暗月岛',
--[408]= '暗月岛',
[409]= '巨龙之魂',
--[410]= '巨龙之魂',
--[411]= '巨龙之魂',
--[412]= '巨龙之魂',
--[413]= '巨龙之魂',
--[414]= '巨龙之魂',
--[415]= '巨龙之魂',
[416]= '尘泥沼泽',
[417]= '寇魔古寺',
[418]= '卡桑琅丛林',
[419]= '敖骨打废墟',
--[420]= '敖骨打废墟',
--[421]= '敖骨打废墟',
[422]= '恐惧废土',
[423]= '碎银矿脉',
[424]= '潘达利亚',
[425]= '北郡',
[426]= '回音山矿洞',
[427]= '寒脊山谷',
[428]= '霜鬃洞穴',
[429]= '青龙寺',
--[430]= '青龙寺',
[431]= '血色大厅',
--[432]= '血色大厅',
[433]= '雾纱栈道',
[434]= '远古之路',
[435]= '血色修道院',
--[436]= '血色修道院',
[437]= '残阳关',
--[438]= '残阳关',
[439]= '风暴烈酒酿造厂',
--[440]= '风暴烈酒酿造厂',
--[441]= '风暴烈酒酿造厂',
--[442]= '风暴烈酒酿造厂',
[443]= '影踪禅院',
--[444]= '影踪禅院',
--[445]= '影踪禅院',
--[446]= '影踪禅院',
[447]= '酝酿风暴',
[448]= '翡翠林',
[449]= '寇魔古寺',
[450]= '盎迦猴岛',
[451]= '突袭扎尼维斯',
[452]= '酿月祭',
[453]= '魔古山宫殿',
--[454]= '魔古山宫殿',
--[455]= '魔古山宫殿',
[456]= '永春台',
[457]= '围攻砮皂寺',
--[458]= '围攻砮皂寺',
--[459]= '围攻砮皂寺',
[460]= '幽影谷',
[461]= '试炼谷',
[462]= '纳拉其营地',
[463]= '回音群岛',
[464]= '恶鳞洞穴',
[465]= '丧钟镇',
[466]= '夜行蜘蛛洞穴',
[467]= '逐日岛',
[468]= '埃门谷',
[469]= '新工匠镇',
[470]= '霜鬃巨魔要塞',
[471]= '魔古山宝库',
--[472]= '魔古山宝库',
--[473]= '魔古山宝库',
[474]= '恐惧之心',
--[475]= '恐惧之心',
[476]= '通灵学院',
--[477]= '通灵学院',
--[478]= '通灵学院',
--[479]= '通灵学院',
[480]= '试炼场',
[481]= '遗忘之王古墓',
--[482]= '遗忘之王古墓',
[483]= '尘泥沼泽',
[486]= '卡桑琅丛林',
[487]= '王者的耐心',
[488]= '黑暗中的匕首',
--[489]= '黑暗中的匕首',
[490]= '黑暗神殿',
--[491]= '黑暗神殿',
--[492]= '黑暗神殿',
--[493]= '黑暗神殿',
--[494]= '黑暗神殿',
--[495]= '黑暗神殿',
--[496]= '黑暗神殿',
--[497]= '黑暗神殿',
[498]= '卡桑琅丛林',
[499]= '矿道地铁',
--[500]= '矿道地铁',
--[501]= '达拉然',
[502]= '达拉然',
[503]= '搏击竞技场',
[504]= '雷神岛',
[505]= '闪电矿脉',
[506]= '浮华宝库',
[507]= '巨兽岛',
[508]= '雷电王座',
--[509]= '雷电王座',
--[510]= '雷电王座',
--[511]= '雷电王座',
--[512]= '雷电王座',
--[513]= '雷电王座',
--[514]= '雷电王座',
--[515]= '雷电王座',
[516]= '雷神岛',
[517]= '闪电矿脉',
[518]= '雷电堡',
[519]= '深风峡谷',
[520]= '锦绣谷',
[521]= '锦绣谷',
[522]= '怒焰之谜',
[523]= '丹莫罗',
[524]= '公海激战',
[525]= '霜火岭',
[526]= '图格尔的巢穴',
--[527]= '图格尔的巢穴',
--[528]= '图格尔的巢穴',
--[529]= '图格尔的巢穴',
[530]= '格罗姆加尔',
[531]= '格鲁洛克岩洞',
--[532]= '格鲁洛克岩洞',
[533]= '飘雪秘境',
[534]= '塔纳安丛林',
[535]= '塔拉多',
[536]= '圣光之墓',
[537]= '幽魂陵墓',
[538]= '被破坏的埋骨地',
[539]= '影月谷',
[540]= '血棘洞穴',
[541]= '秘密巢穴',
[542]= '阿兰卡峰林',
[543]= '戈尔隆德',
[544]= '茉艾拉堡垒',
--[545]= '茉艾拉堡垒',
[546]= '狂怒裂隙',
[547]= '狂怒裂隙',
[548]= '羽颈之釜',
--[549]= '羽颈之釜',
[550]= '纳格兰',
[551]= '剑圣洞穴',
[552]= '岩壁峡谷',
[553]= '沃舒古',
[554]= '永恒岛',
[555]= '孤魂岩洞',
[556]= '决战奥格瑞玛',
--[557]= '决战奥格瑞玛',
--[558]= '决战奥格瑞玛',
--[559]= '决战奥格瑞玛',
--[560]= '决战奥格瑞玛',
--[561]= '决战奥格瑞玛',
--[562]= '决战奥格瑞玛',
--[563]= '决战奥格瑞玛',
--[564]= '决战奥格瑞玛',
--[565]= '决战奥格瑞玛',
--[566]= '决战奥格瑞玛',
--[567]= '决战奥格瑞玛',
--[568]= '决战奥格瑞玛',
--[569]= '决战奥格瑞玛',
--[570]= '决战奥格瑞玛',
[571]= '天神比武大会',
[572]= '德拉诺',
[573]= '血槌炉渣矿井',
[574]= '影月墓地',
--[575]= '影月墓地',
--[576]= '影月墓地',
[577]= '塔纳安丛林',
[578]= '幽影大厅',
[579]= '坠月挖掘场',
--[580]= '坠月挖掘场',
--[581]= '坠月挖掘场',
[582]= '坠落之月',
[585]= '霜壁矿井',
--[586]= '霜壁矿井',
--[587]= '霜壁矿井',
[588]= '阿什兰',
[589]= '阿什兰矿洞',
[590]= '霜寒晶壁',
[593]= '奥金顿',
[594]= '沙塔斯城',
[595]= '钢铁码头',
[596]= '黑石铸造厂',
--[597]= '黑石铸造厂',
--[598]= '黑石铸造厂',
--[599]= '黑石铸造厂',
--[600]= '黑石铸造厂',
[601]= '通天峰',
[602]= '通天峰',
[606]= '恐轨车站',
--[607]= '恐轨车站',
--[608]= '恐轨车站',
--[609]= '恐轨车站',
[610]= '悬槌堡',
--[611]= '悬槌堡',
--[612]= '悬槌堡',
--[613]= '悬槌堡',
--[614]= '悬槌堡',
--[615]= '悬槌堡',
[616]= '黑石塔上层',
--[617]= '黑石塔上层',
--[618]= '黑石塔上层',
[619]= '破碎群岛',
[620]= '永茂林地',
--[621]= '永茂林地',
[622]= '风暴之盾',
[623]= '希尔斯布莱德丘陵（南海镇VS塔伦米尔）',
[624]= '战争之矛',
[626]= '达拉然',
--[627]= '达拉然',
--[628]= '达拉然',
--[629]= '达拉然',
[630]= '阿苏纳',
[631]= '纳萨拉斯学院',
[632]= '欧逊努斯海窟',
[633]= '千光神殿',
[634]= '风暴峡湾',
[635]= '盾憩岛',
[636]= '风鳞洞穴',
[637]= '托林尼尔避难所',
--[638]= '托林尼尔避难所',
[639]= '阿格拉玛的宝库',
[640]= '艾尔的宝库',
[641]= '瓦尔莎拉',
[642]= '黑暗围栏',
[643]= '沉眠者地穴',
--[644]= '沉眠者地穴',
[645]= '扭曲虚空',
[646]= '破碎海滩',
[647]= '阿彻鲁斯：黑锋要塞',
--[648]= '阿彻鲁斯：黑锋要塞',
[649]= '冥狱深渊',
[650]= '至高岭',
[651]= '啮岩孤地',
[652]= '雷霆图腾',
[653]= '血炼洞穴',
[654]= '泥吻巢穴',
[655]= '生命之泉洞穴',
--[656]= '生命之泉洞穴',
[657]= '胡恩之路',
--[658]= '胡恩之路',
[659]= '黯石岩洞',
[660]= '邪能图腾洞穴',
[661]= '地狱火堡垒',
--[662]= '地狱火堡垒',
--[663]= '地狱火堡垒',
--[664]= '地狱火堡垒',
--[665]= '地狱火堡垒',
--[666]= '地狱火堡垒',
--[667]= '地狱火堡垒',
--[668]= '地狱火堡垒',
--[669]= '地狱火堡垒',
--[670]= '地狱火堡垒',
[671]= '纳沙尔海湾',
[672]= '破碎深渊马顿',
[673]= '神秘之洞',
[674]= '灵魂引擎',
--[675]= '灵魂引擎',
[676]= '破碎海滩',
[677]= '守望者地窟',
--[678]= '守望者地窟',
--[679]= '守望者地窟',
[680]= '苏拉玛',
[681]= '魔法回廊地窟',
[682]= '邪魂堡垒',
[683]= '魔法回廊地窟',
[684]= '破碎轨迹',
--[685]= '破碎轨迹',
[686]= '艾洛珊',
[687]= '凯尔巴洛',
[688]= '安诺拉魔网节点',
[689]= '月落魔网节点',
[690]= '安瑟纳尔魔网节点',
[691]= '奈耶尔的工作室',
[692]= '法兰纳尔回廊',
--[693]= '法兰纳尔回廊',
[694]= '冥口浅湾',
[695]= '苍穹要塞',
[696]= '风暴峡湾',
[697]= '艾萨拉',
[698]= '冰冠堡垒',
--[699]= '冰冠堡垒',
--[700]= '冰冠堡垒',
--[701]= '冰冠堡垒',
[702]= '虚空之光神殿',
[703]= '英灵殿',
--[704]= '英灵殿',
--[705]= '英灵殿',
[706]= '冥口峭壁',
--[707]= '冥口峭壁',
--[708]= '冥口峭壁',
[709]= '迷踪岛',
[710]= '守望者地窟',
--[711]= '守望者地窟',
--[712]= '守望者地窟',
[713]= '艾萨拉之眼',
[714]= '尼斯卡拉',
[715]= '翡翠梦境之路',
[716]= '天空之墙',
[717]= '恐痕裂隙',
[718]= '恐痕裂隙',
[719]= '破碎深渊马顿',
--[720]= '破碎深渊马顿',
--[721]= '破碎深渊马顿',
[723]= '紫罗兰监狱',
[725]= '大漩涡',
[726]= '大漩涡',
[728]= '永春台',
[729]= '碎岩之渊',
[731]= '奈萨里奥的巢穴',
[732]= '紫罗兰监狱',
[733]= '黑心林地',
[734]= '守护者圣殿',
--[735]= '守护者圣殿',
[736]= '彼岸',
[737]= '旋云之巅',
[738]= '火焰之地',
[739]= '神射手营地',
[740]= '影血堡垒',
--[741]= '影血堡垒',
[742]= '深渊之喉',
--[743]= '深渊之喉',
[744]= '奥杜尔',
--[745]= '奥杜尔',
--[746]= '奥杜尔',
[747]= '梦境林地',
[748]= '尼斯卡拉',
[749]= '魔法回廊',
[750]= '雷霆图腾',
[751]= '黑鸦堡垒',
--[752]= '黑鸦堡垒',
--[753]= '黑鸦堡垒',
--[754]= '黑鸦堡垒',
--[755]= '黑鸦堡垒',
--[756]= '黑鸦堡垒',
[757]= '乌索克之巢',
[758]= '薄暮岛礁',
[759]= '黑暗神殿',
[760]= '玛洛恩的梦魇',
[761]= '群星庭院',
--[762]= '群星庭院',
--[763]= '群星庭院',
[764]= '暗夜要塞',
--[765]= '暗夜要塞',
--[766]= '暗夜要塞',
--[767]= '暗夜要塞',
--[768]= '暗夜要塞',
--[769]= '暗夜要塞',
--[770]= '暗夜要塞',
--[771]= '暗夜要塞',
--[772]= '暗夜要塞',
[773]= '托尔巴拉德',
--[774]= '托尔巴拉德',
[775]= '埃索达',
[776]= '秘蓝岛',
[777]= '翡翠梦魇',
--[778]= '翡翠梦魇',
--[779]= '翡翠梦魇',
--[780]= '翡翠梦魇',
--[781]= '翡翠梦魇',
--[782]= '翡翠梦魇',
--[783]= '翡翠梦魇',
--[784]= '翡翠梦魇',
--[785]= '翡翠梦魇',
--[786]= '翡翠梦魇',
--[787]= '翡翠梦魇',
--[788]= '翡翠梦魇',
--[789]= '翡翠梦魇',
[790]= '艾萨拉之眼',
[791]= '青龙寺',
--[792]= '青龙寺',
[793]= '黑鸦堡垒',
[794]= '卡拉赞',
--[795]= '卡拉赞',
--[796]= '卡拉赞',
--[797]= '卡拉赞',
[798]= '魔法回廊',
[799]= '魔环',
--[800]= '魔环',
--[801]= '魔环',
--[802]= '魔环',
--[803]= '魔环',
[804]= '血色修道院',
--[805]= '血色修道院',
[806]= '勇气试炼',
--[807]= '勇气试炼',
--[808]= '勇气试炼',
[809]= '卡拉赞',
--[810]= '卡拉赞',
--[811]= '卡拉赞',
--[812]= '卡拉赞',
--[813]= '卡拉赞',
--[814]= '卡拉赞',
--[815]= '卡拉赞',
--[816]= '卡拉赞',
--[817]= '卡拉赞',
--[818]= '卡拉赞',
--[819]= '卡拉赞',
--[820]= '卡拉赞',
--[821]= '卡拉赞',
--[822]= '卡拉赞',
[823]= '萨隆矿坑',
[824]= '岛屿',
[825]= '哀嚎洞穴',
[826]= '鲜血图腾洞穴',
[827]= '斯坦索姆',
[828]= '永恒之眼',
[829]= '英灵殿',
[830]= '克罗库恩',
[831]= '维迪卡尔',
--[832]= '维迪卡尔',
[833]= '纳斯拉克斯之塔',
[834]= '寒脊山谷',
[835]= '死亡矿井',
--[836]= '死亡矿井',
[837]= '阿拉希盆地',
[838]= '黑石山之战',
[839]= '大漩涡',
[840]= '诺莫瑞根',
--[841]= '诺莫瑞根',
--[842]= '诺莫瑞根',
[843]= '决战影踪派',
[844]= '阿拉希盆地',
[845]= '永夜大教堂',
--[846]= '永夜大教堂',
--[847]= '永夜大教堂',
--[848]= '永夜大教堂',
--[849]= '永夜大教堂',
[850]= '萨格拉斯之墓',
--[851]= '萨格拉斯之墓',
--[852]= '萨格拉斯之墓',
--[853]= '萨格拉斯之墓',
--[854]= '萨格拉斯之墓',
--[855]= '萨格拉斯之墓',
--[856]= '萨格拉斯之墓',
[857]= '风神王座',
[858]= '突袭破碎海滩',
[859]= '战歌峡谷',
[860]= '红玉圣殿',
[861]= '破碎深渊马顿',
[862]= '祖达萨',
[863]= '纳兹米尔',
[864]= '沃顿',
[865]= '风暴峡湾',
--[866]= '风暴峡湾',
[867]= '阿苏纳',
[868]= '瓦尔莎拉',
[869]= '至高岭',
[870]= '至高岭',
[871]= '失落冰川',
[872]= '风暴烈酒酿造厂',
--[873]= '风暴烈酒酿造厂',
--[874]= '风暴烈酒酿造厂',
[875]= '赞达拉',
[876]= '库尔提拉斯',
[877]= '永恒猎场',
[879]= '破碎深渊马顿',
--[880]= '破碎深渊马顿',
[881]= '永恒之眼',
[882]= '艾瑞达斯',
[883]= '维迪卡尔',
[884]= '维迪卡尔',
[885]= '安托兰废土',
--[886]= '维迪卡尔',
--[887]= '维迪卡尔',
[888]= '契约大厅',
[889]= '禁魔监狱',
--[890]= '禁魔监狱',
[891]= '秘蓝岛',
--[892]= '秘蓝岛',
--[893]= '秘蓝岛',
--[894]= '秘蓝岛',
[895]= '提拉加德海峡',
[896]= '德鲁斯瓦',
[897]= '克罗米之死',
--[898]= '克罗米之死',
--[899]= '克罗米之死',
--[900]= '克罗米之死',
--[901]= '克罗米之死',
--[902]= '克罗米之死',
[903]= '执政团之座',
[904]= '希利苏斯角斗场',
[905]= '阿古斯',
[906]= '阿拉希高地',
[907]= '涌泉海滩',
[908]= '洛丹伦废墟',
[909]= '安托鲁斯，燃烧王座',
--[910]= '安托鲁斯，燃烧王座',
--[911]= '安托鲁斯，燃烧王座',
--[912]= '安托鲁斯，燃烧王座',
--[913]= '安托鲁斯，燃烧王座',
--[914]= '安托鲁斯，燃烧王座',
--[915]= '安托鲁斯，燃烧王座',
--[916]= '安托鲁斯，燃烧王座',
--[917]= '安托鲁斯，燃烧王座',
--[918]= '安托鲁斯，燃烧王座',
--[919]= '安托鲁斯，燃烧王座',
--[920]= '安托鲁斯，燃烧王座',
[921]= '侵入点：奥雷诺',
[922]= '侵入点：博尼克',
[923]= '侵入点：森加',
[924]= '侵入点：奈格塔尔',
[925]= '侵入点：萨古亚',
[926]= '侵入点：瓦尔',
[927]= '大型侵入点：深渊领主维尔姆斯',
[928]= '大型侵入点：妖女奥露拉黛儿',
[929]= '大型侵入点：主母芙努娜',
[930]= '大型侵入点：审判官梅托',
[931]= '大型侵入点：索塔纳索尔',
[932]= '大型侵入点：奥库拉鲁斯',
[933]= '万世熔炉',
--[934]= '阿塔达萨',
[935]= '阿塔达萨',
[936]= '自由镇',
[938]= '吉尔尼斯岛',
--[939]= 'Tropical Isle 8.0',
[940]= '维迪卡尔',
--[941]= '维迪卡尔',
[942]= '斯托颂谷地',
[943]= '阿拉希高地',
[946]= '宇宙',
[947]= '艾泽拉斯',
[948]= '大漩涡',
[971]= '泰洛古斯裂隙',
--[972]= '泰洛古斯裂隙',
[973]= '太阳之井',
[974]= '托尔达戈',
--[975]= '托尔达戈',
--[976]= '托尔达戈',
--[977]= '托尔达戈',
--[978]= '托尔达戈',
--[979]= '托尔达戈',
--[980]= '托尔达戈',
[981]= '安戈尔废墟',
[985]= '东部王国',
[986]= '卡利姆多',
[987]= '外域',
[988]= '诺森德',
[989]= '潘达利亚',
[990]= '德拉诺',
[991]= '赞达拉',
[992]= '库尔提拉斯',
[993]= '破碎群岛',
[994]= '阿古斯',
[997]= '提瑞斯法林地',
[998]= '幽暗城',
[1004]= '诸王之眠',
[1009]= '阿图阿曼',
[1010]= '暴富矿区！！',
[1011]= '赞达拉',
[1012]= '暴风城',
[1013]= '监狱',
[1014]= '库尔提拉斯',
[1015]= '维克雷斯庄园',
--[1016]= '维克雷斯庄园',
--[1017]= '维克雷斯庄园',
--[1018]= '维克雷斯庄园',
[1021]= '心之秘室',
[1022]= '神秘海岛',
[1029]= '维克雷斯庄园',
--[1030]= '格雷迈恩庄园',
--[1031]= '格雷迈恩庄园',
[1032]= '飞掠谷',
[1033]= '腐化泥沼',
[1034]= '青翠荒野',
[1035]= '熔火海礁',
[1036]= '恐惧群岛',
[1037]= '低语堡礁',
[1038]= '塞塔里斯神庙',
[1039]= '风暴神殿',
--[1040]= '风暴神殿',
--[1041]= '地渊孢林',
[1042]= '地渊孢林',
[1043]= '塞塔里斯神庙',
[1044]= '阿拉希高地',
[1045]= '兹洛斯，枯败之界',
[1148]= '奥迪尔',
--[1149]= '奥迪尔',
--[1150]= '奥迪尔',
--[1151]= '奥迪尔',
--[1152]= '奥迪尔',
--[1153]= '奥迪尔',
--[1154]= '奥迪尔',
--[1155]= '奥迪尔',
--[1156]= '无尽之海',
[1157]= '无尽之海',
[1158]= '阿拉希高地',
[1159]= '黑石深渊',
--[1160]= '黑石深渊',
[1161]= '伯拉勒斯',
[1162]= '围攻伯拉勒斯',
[1163]= '达萨罗',
--[1164]= '达萨罗',
--[1165]= '达萨罗',
--[1166]= '赞枢尔',
[1167]= '赞枢尔',
[1169]= '托尔达戈',
--[1170]= 'Gorgrond-Mag'har Scenario',
[1171]= '戈尔托瓦斯',
[1172]= '戈尔托瓦斯',
--[1173]= '拉斯塔哈之力号',
[1174]= '拉斯塔哈之力号',
--[1176]= '帕库之息号',
[1177]= '帕库之息号',
--[1179]= '深渊之歌号',
[1180]= '深渊之歌号',
[1181]= '祖达萨',
[1182]= '盐石矿洞',
[1183]= '荆棘之心',
[1184]= '冬寒矿洞',
--[1185]= '冬寒矿洞',
[1186]= '黑石深渊',
[1187]= '阿苏纳',
[1188]= '瓦尔莎拉',
[1189]= '至高岭',
[1190]= '风暴峡湾',
[1191]= '苏拉玛',
[1192]= '破碎海滩',
[1193]= '祖达萨',
[1194]= '纳兹米尔',
[1195]= '沃顿',
[1196]= '提拉加德海峡',
[1197]= '德鲁斯瓦',
[1198]= '斯托颂谷地',
[1203]= '黑海岸',
[1208]= '东部王国',
[1209]= '卡利姆多',
[1244]= '阿拉希高地',
[1245]= '荒芜之地',
[1246]= '诅咒之地',
[1247]= '提瑞斯法林地',
[1248]= '银松森林',
[1249]= '西瘟疫之地',
[1250]= '东瘟疫之地',
[1251]= '希尔斯布莱德丘陵',
[1252]= '辛特兰',
[1253]= '丹莫罗',
[1254]= '灼热峡谷',
[1255]= '燃烧平原',
[1256]= '艾尔文森林',
[1257]= '逆风小径',
[1258]= '暮色森林',
[1259]= '洛克莫丹',
[1260]= '赤脊山',
[1261]= '悲伤沼泽',
[1262]= '西部荒野',
[1263]= '湿地',
[1264]= '暴风城',
[1265]= '铁炉堡',
[1266]= '幽暗城',
[1267]= '永歌森林',
[1268]= '幽魂之地',
[1269]= '银月城',
[1270]= '奎尔丹纳斯岛',
[1271]= '吉尔尼斯',
[1272]= '瓦丝琪尔',
[1273]= '吉尔尼斯废墟',
[1274]= '荆棘谷',
[1275]= '暮光高地',
[1276]= '托尔巴拉德',
[1277]= '托尔巴拉德半岛',
[1305]= '杜隆塔尔',
[1306]= '莫高雷',
[1307]= '北贫瘠之地',
[1308]= '泰达希尔',
[1309]= '黑海岸',
[1310]= '灰谷',
[1311]= '千针石林',
[1312]= '石爪山脉',
[1313]= '凄凉之地',
[1314]= '菲拉斯',
[1315]= '尘泥沼泽',
[1316]= '塔纳利斯',
[1317]= '艾萨拉',
[1318]= '费伍德森林',
[1319]= '安戈洛环形山',
[1320]= '月光林地',
[1321]= '希利苏斯',
[1322]= '冬泉谷',
[1323]= '雷霆崖',
[1324]= '达纳苏斯',
[1325]= '秘蓝岛',
[1326]= '埃索达',
[1327]= '秘血岛',
[1328]= '海加尔山',
[1329]= '南贫瘠之地',
[1330]= '奥丹姆',
[1331]= '埃索达',
[1332]= '黑海岸',
[1333]= '黑海岸',
[1334]= '冬拥湖',
[1335]= '碟中碟',
[1336]= '湾林镇',
[1337]= '约伦达尔',
[1338]= '黑海岸',
[1339]= '战歌峡谷',
--[1343]= '8.1 Darkshore Outdoor Final Phase',
--[1345]= '风暴熔炉',
[1346]= '风暴熔炉',
[1347]= '赞达拉珍宝间',
--[1348]= '赞达拉珍宝间',
[1349]= '托尔达戈',
--[1350]= '托尔达戈',
--[1351]= '托尔达戈',
[1352]= '达萨罗之战',
--[1353]= '达萨罗之战',
--[1354]= '达萨罗之战',
[1355]= '纳沙塔尔',
[1356]= '达萨罗之战',
--[1357]= '达萨罗之战',
--[1358]= '达萨罗之战',
[1359]= '冰冠堡垒',
--[1360]= '冰冠堡垒',
[1361]= '旧铁炉堡',
[1362]= '风暴神殿',
[1363]= '风暴熔炉',
--[1364]= '达萨罗之战',
[1366]= '阿拉希盆地',
[1367]= '达萨罗之战',
[1371]= '诺莫瑞根A',
[1372]= '诺莫瑞根B',
[1374]= '诺莫瑞根D',
[1375]= '岩石大厅',
--[1379]= '8.3 Visions of N'Zoth-Prototype',
[1380]= '诺莫瑞根C',
[1381]= '奥迪尔',
[1382]= '奥迪尔',
[1383]= '阿拉希盆地',
[1384]= '诺森德',
[1396]= '北风苔原',
[1397]= '龙骨荒野',
[1398]= '灰熊丘陵',
[1399]= '嚎风峡湾',
[1400]= '冰冠冰川',
[1401]= '索拉查盆地',
[1402]= '风暴峭壁',
[1403]= '祖达克',
[1404]= '冬拥湖',
[1405]= '晶歌森林',
[1406]= '洛斯加尔登陆点',
[1407]= '墨水监狱',
[1408]= '阿什兰',
[1409]= '流放者离岛',
[1462]= '麦卡贡岛',
[1465]= '血色大厅',
[1467]= '外域',
[1468]= '梦境林地',
[1469]= '奥格瑞玛的幻象',
[1470]= '暴风城的幻象',
[1471]= '翡翠梦境之路',
[1472]= '巨龙之脊',
[1473]= '心之秘室',
[1474]= '大漩涡-艾泽拉斯之心',
[1475]= '翡翠梦境',
[1476]= '暮光高地',
[1478]= '阿什兰',
[1479]= '营救贝恩',
[1490]= '麦卡贡',
--[[[1491]= '麦卡贡',
[1493]= '麦卡贡',
[1494]= '麦卡贡',
[1497]= '麦卡贡',]]
[1499]= '辛艾萨莉',
--[1500]= '',
[1501]= '潮落岛',
[1502]= '琼花村',
[1504]= '纳沙塔尔',
[1505]= '斯坦索姆',
[1512]= '永恒王宫',
--[[[1513]= '永恒王宫',
[1514]= '永恒王宫',
[1515]= '永恒王宫',
[1516]= '永恒王宫',
[1517]= '永恒王宫',
[1518]= '永恒王宫',
[1519]= '永恒王宫',
[1520]= '永恒王宫',]]
[1521]= '卡拉赞墓穴',
[1522]= '崩塌的洞穴',
--[1523]= 'Solesa Naksu [DNT]',
--[1524]= '',
[1525]= '雷文德斯',
[1527]= '奥丹姆',
[1528]= '纳沙塔尔',
[1530]= '锦绣谷',
[1531]= '渣客城',
[1532]= '渣客城',
[1533]= '晋升堡垒',
[1534]= '奥格瑞玛',
[1535]= '杜隆塔尔',
[1536]= '玛卓克萨斯',
[1537]= '奥特兰克山谷',
[1538]= '黑翼血环',
--[1539]= '黑翼血环',
[1540]= '起源大厅',
--[1541]= '起源大厅',
--[1542]= '起源大厅',
[1543]= '噬渊',
[1544]= '魔古山宫殿',
--[[[1545]= '魔古山宫殿',
[1546]= '魔古山宫殿',
[1547]= '魔古山宝库',
[1548]= '魔古山宝库',
[1549]= '魔古山宝库',]]
[1550]= '暗影界',
[1552]= '时光之穴',
[1553]= '时光之穴',
[1554]= '毒蛇神殿',
[1555]= '风暴要塞',
[1556]= '海加尔峰',
[1557]= '纳克萨玛斯',
[1558]= '冰冠堡垒',
[1559]= '暮光堡垒',
[1560]= '黑翼之巢',
[1561]= '火焰之地',
[1563]= '十字军的试练',
[1565]= '炽蓝仙野',
[1569]= '晋升堡垒',
[1570]= '锦绣谷',
[1571]= '奥丹姆',
[1573]= '麦卡贡市',
--[1574]= '麦卡贡市',
[1576]= '深风峡谷',
[1577]= '吉尔尼斯城',
[1578]= '黑石深渊',
[1579]= '能量池',
[1580]= '尼奥罗萨',
--[[[1581]= '尼奥罗萨',
[1582]= '尼奥罗萨',
[1590]= '尼奥罗萨',
[1591]= '尼奥罗萨',
[1592]= '尼奥罗萨',
[1593]= '尼奥罗萨',
[1594]= '尼奥罗萨',
[1595]= '尼奥罗萨',
[1596]= '尼奥罗萨',
[1597]= '尼奥罗萨',]]
[1600]= '亚煞极地窟',
[1602]= '冰冠堡垒',
[1603]= '炽蓝仙野',
[1604]= '心之秘室',
[1609]= '暗槌堡垒',
--[1610]= '暗槌堡垒',
--[1611]= 'Dark Citadel',
--[1614]= 'JT_New_A',
[1615]= '托加斯特',
--[[[1616]= '托加斯特',
[1617]= '托加斯特',
[1618]= '托加斯特',
[1619]= '托加斯特',
[1620]= '托加斯特',
[1621]= '托加斯特',
[1623]= '托加斯特',
[1624]= '托加斯特',
[1627]= '托加斯特',
[1628]= '托加斯特',
[1629]= '托加斯特',
[1630]= '托加斯特',
[1631]= '托加斯特',
[1632]= '托加斯特',
[1635]= '托加斯特',
[1636]= '托加斯特',
[1641]= '托加斯特',]]
[1642]= '瓦尔莎拉',
[1643]= '炽蓝仙野',
[1644]= '灰烬王庭',
[1645]= '托加斯特',
[1647]= '暗影界',
[1648]= '噬渊',
[1649]= '以太地窟',
[1650]= '盲眼堡垒',
[1651]= '熔火之炉',
[1652]= '千魂窖',
--[1656]= 'Torghast-Map Floor 10 [Deprecated]',
--[1658]= 'Alpha_TG_R02',
--[1659]= 'Alpha_TG_R03',
--[1661]= 'Alpha_TG_R05',
[1662]= '女王的温室',
[1663]= '赎罪大厅',
--[1664]= '赎罪大厅',
--[1665]= '赎罪大厅',
[1666]= '通灵战潮',
--[1667]= '通灵战潮',
--[1668]= '通灵战潮',
[1669]= '塞兹仙林的迷雾',
[1670]= '奥利波斯',
--[1671]= '奥利波斯',
--[1672]= '奥利波斯',
--[1673]= '奥利波斯',
[1674]= '凋魂之殇',
[1675]= '赤红深渊',
--[1676]= '赤红深渊',
[1677]= '彼界',
--[1678]= '彼界',
--[1679]= '彼界',
--[1680]= '彼界',
[1681]= '冰冠堡垒',
--[1682]= '冰冠堡垒',
[1683]= '伤逝剧场',
--[1684]= '伤逝剧场',
--[1685]= '伤逝剧场',
--[1686]= '伤逝剧场',
[1687]= '伤逝剧场',
[1688]= '雷文德斯',
[1689]= '玛卓克萨斯',
[1690]= '候选者居所',
[1691]= '破碎林地',
[1692]= '晋升高塔',
--[1693]= '晋升高塔',
--[1694]= '晋升高塔',
--[1695]= '晋升高塔',
[1697]= '凋魂之殇',
[1698]= '兵主之座',
[1699]= '堕罪堡',
--[1700]= '堕罪堡',
[1701]= '森林之心',
--[1702]= '森林之心',
--[1703]= '森林之心',
[1705]= '托加斯特-入口',
[1707]= '极乐堡',
--[1708]= '极乐堡',
[1709]= '炽蓝仙野',
[1711]= '晋升角斗场',
[1712]= '托加斯特',
[1713]= '智慧之路',
[1714]= '卡莉娥佩的第三个厅室',
[1715]= '永恒前庭',
[1716]= '托加斯特',
[1717]= '冷锋之地',
--[1720]= 'Covenant_Ard_Torghast',
[1721]= '托加斯特',
[1724]= '沃崔克西斯',
[1726]= '北海',
--[1727]= '北海',
[1728]= '刻符者',
[1734]= '雷文德斯',
[1735]= '纳斯利亚堡',
[1736]= '托加斯特',
[1738]= '雷文德斯',
[1739]= '炽蓝仙野',
--[1740]= '炽蓝仙野',
[1741]= '玛卓克萨斯',
[1742]= '雷文德斯',
[1744]= '纳斯利亚堡',
--[[[1745]= '纳斯利亚堡',
[1746]= '纳斯利亚堡',
[1747]= '纳斯利亚堡',
[1748]= '纳斯利亚堡',]]
[1749]= '托加斯特',
[1750]= '纳斯利亚堡',
--[[[1751]= '托加斯特',
[1752]= '托加斯特',
[1753]= '托加斯特',
[1754]= '托加斯特',
[1755]= '纳斯利亚堡',]]
--[[1756]= '托加斯特',
[1757]= '托加斯特',
[1758]= '托加斯特',
[1759]= '托加斯特',
[1760]= '托加斯特',
[1761]= '托加斯特',]]
[1762]= '托加斯特，罪魂之塔',
--[[[1763]= '托加斯特',
[1764]= '托加斯特',
[1765]= '托加斯特',
[1766]= '托加斯特',
[1767]= '托加斯特',
[1768]= '托加斯特',
[1769]= '托加斯特',
[1770]= '托加斯特',
[1771]= '托加斯特',
[1772]= '托加斯特',
[1773]= '托加斯特',
[1774]= '托加斯特',
[1776]= '托加斯特',
[1777]= '托加斯特',
[1778]= '托加斯特',
[1779]= '托加斯特',
[1780]= '托加斯特',
[1781]= '托加斯特',
[1782]= '托加斯特',
[1783]= '托加斯特',
[1784]= '托加斯特',
[1785]= '托加斯特',
[1786]= '托加斯特',
[1787]= '托加斯特',
[1788]= '托加斯特',
[1789]= '托加斯特',
[1791]= '托加斯特',
[1792]= '托加斯特',
[1793]= '托加斯特',
[1794]= '托加斯特',
[1795]= '托加斯特',
[1796]= '托加斯特',
[1797]= '托加斯特',
[1798]= '托加斯特',
[1799]= '托加斯特',
[1800]= '托加斯特',
[1801]= '托加斯特',
[1802]= '托加斯特',
[1803]= '托加斯特',
[1804]= '托加斯特',
[1805]= '托加斯特',
[1806]= '托加斯特',
[1807]= '托加斯特',
[1808]= '托加斯特',
[1809]= '托加斯特',
[1810]= '托加斯特',
[1811]= '托加斯特',
[1812]= '托加斯特',]]
[1813]= '晋升堡垒',
[1814]= '玛卓克萨斯',
[1816]= '利爪之缘',
[1818]= '瓦尔仙林',
[1819]= '真菌枢纽',
[1820]= '苦楚之洞',
--[1821]= '苦楚之洞',
[1822]= '提取者休养地',
[1823]= '统御祭坛',
[1824]= '主母之穴',
[1825]= '根须地窖',
--[1826]= '根须地窖',
--[1827]= '根须地窖',
--[1829]= '',
[1833]= '托加斯特',
--[[[1834]= '托加斯特',
[1835]= '托加斯特',
[1836]= '托加斯特',
[1837]= '托加斯特',
[1838]= '托加斯特',
[1839]= '托加斯特',
[1840]= '托加斯特',
[1841]= '托加斯特',
[1842]= '托加斯特',
[1843]= '托加斯特',
[1844]= '托加斯特',
[1845]= '托加斯特',
[1846]= '托加斯特',
[1847]= '托加斯特',
[1848]= '托加斯特',
[1849]= '托加斯特',
[1850]= '托加斯特',
[1851]= '托加斯特',
[1852]= '托加斯特',
[1853]= '托加斯特',
[1854]= '托加斯特',
[1855]= '托加斯特',
[1856]= '托加斯特',
[1857]= '托加斯特',
[1858]= '托加斯特',
[1859]= '托加斯特',
[1860]= '托加斯特',
[1861]= '托加斯特',
[1862]= '托加斯特',
[1863]= '托加斯特',
[1864]= '托加斯特',
[1865]= '托加斯特',
[1867]= '托加斯特',
[1868]= '托加斯特',
[1869]= '托加斯特',
[1870]= '托加斯特',
[1871]= '托加斯特',
[1872]= '托加斯特',
[1873]= '托加斯特',
[1874]= '托加斯特',
[1875]= '托加斯特',
[1876]= '托加斯特',
[1877]= '托加斯特',
[1878]= '托加斯特',
[1879]= '托加斯特',
[1880]= '托加斯特',
[1881]= '托加斯特',
[1882]= '托加斯特',
[1883]= '托加斯特',
[1884]= '托加斯特',
[1885]= '托加斯特',
[1886]= '托加斯特',
[1887]= '托加斯特',
[1888]= '托加斯特',
[1889]= '托加斯特',
[1890]= '托加斯特',
[1891]= '托加斯特',
[1892]= '托加斯特',
[1893]= '托加斯特',
[1894]= '托加斯特',
[1895]= '托加斯特',
[1896]= '托加斯特',
[1897]= '托加斯特',
[1898]= '托加斯特',
[1899]= '托加斯特',]]
--[1900]= '托加斯特',
--[1901]= '托加斯特',
--[1902]= '托加斯特',
--[1903]= '托加斯特',
--[1904]= '托加斯特',
--[1905]= '托加斯特',
--[1907]= '托加斯特',
--[1908]= '托加斯特',
--[1909]= '托加斯特',
--[1910]= '托加斯特',
[1911]= '托加斯特-入口',
[1912]= '刻符者密牢',
[1913]= '托加斯特',
--[1914]= '托加斯特',
[1917]= '彼界',
--[1920]= '托加斯特',
--[1921]= '托加斯特',
[1922]= '德拉诺',
[1923]= '潘达利亚',
[1958]= '火焰之地',
--[1959]= '火焰之地',
[1960]= '噬渊',
[1961]= '刻希亚',
[1962]= '托加斯特',
--[1963]= '托加斯特',
--[1964]= '托加斯特',
--[1965]= '托加斯特',
--[1966]= '托加斯特',
--[1967]= '托加斯特',
--[1968]= '托加斯特',
--[1969]= '托加斯特',
[1970]= '扎雷殁提斯',
[1971]= '苍穹要塞',
[1974]= '托加斯特',
--[1975]= '托加斯特',
--[1976]= '托加斯特',
--[1977]= '托加斯特',
--[1978]= '巨龙群岛',
--[1979]= '托加斯特',
--[1980]= '托加斯特',
--[1981]= '托加斯特',
--[1982]= '托加斯特',
--[1983]= '托加斯特',
[1984]= '托加斯特',
--[1985]= '托加斯特',
--[1986]= '托加斯特',
--[1987]= '托加斯特',
--[1988]= '托加斯特',
[1989]= '塔扎维什，帷纱集市',
--[1990]= '塔扎维什，帷纱集市',
--[1991]= '塔扎维什，帷纱集市',
--[1992]= '塔扎维什，帷纱集市',
--[1993]= '塔扎维什，帷纱集市',
--[1995]= '塔扎维什，帷纱集市',
--[1996]= '塔扎维什，帷纱集市',
--[1997]= '塔扎维什，帷纱集市',
[1998]= '统御圣所',
[1999]= '统御圣所',
[2000]= '统御圣所',
[2001]= '统御圣所',
[2002]= '统御圣所',
[2003]= '统御圣所',
[2004]= '统御圣所',
[2005]= '炽蓝仙野',
[2006]= '沉思洞窟',
[2007]= '跃足兽之穴',
[2008]= '印记密室',
--[2009]= 'TG106_Floor_MM',
[2010]= '托加斯特',
--[2011]= '托加斯特',
--[2012]= '托加斯特',
[2016]= '塔扎维什，帷纱集市',
[2017]= '晋升高塔',
--[2018]= '晋升高塔',
[2019]= '托加斯特',
[2022]= '觉醒海岸',
[2023]= '欧恩哈拉平原',
[2024]= '碧蓝林海',
[2025]= '索德拉苏斯',
[2026]= '禁忌离岛废弃',
[2027]= '繁花铸造厂',
[2028]= '魂灵音室',
[2029]= '孕育栖地',
[2030]= '具现枢纽',
[2031]= '永恒者墓室',
[2042]= '熔魂之巅',
[2046]= '扎雷殁提斯',
[2047]= '初诞者圣墓',
--[2048]= '初诞者圣墓',
--[2049]= '初诞者圣墓',
--[2050]= '初诞者圣墓',
--[2051]= '初诞者圣墓',
--[2052]= '初诞者圣墓',
--[2055]= '初诞者圣墓',
[2057]= '巨龙群岛',
[2059]= '共振群山',
[2061]= '初诞者圣墓',
[2063]= '巨龙群岛',
[2066]= '化生之庭',
[2070]= '提瑞斯法林地',
[2071]= '奥达曼：提尔的遗产',
--[2072]= '奥达曼：提尔的遗产',
[2073]= '碧蓝魔馆',
--[2074]= '碧蓝魔馆',
--[2075]= '碧蓝魔馆',
--[2076]= '碧蓝魔馆',
--[2077]= '碧蓝魔馆',
[2080]= '奈萨鲁斯',
--[2081]= '奈萨鲁斯',
[2082]= '注能大厅',
--[2083]= '注能大厅',
[2084]= '翡翠梦境之路',
[2085]= '拜荒者的未来',
[2088]= '熊猫人起义',
[2089]= '黑暗帝国',
[2090]= '豺狼人战争',
[2091]= '流沙之战',
[2092]= '艾鱼拉斯',
[2093]= '诺库德阻击战',
[2094]= '红玉新生法池',
--[2095]= '红玉新生法池',
[2096]= '蕨皮山谷',
[2097]= '艾杰斯亚学院',
--[2098]= '艾杰斯亚学院',
--[2099]= '艾杰斯亚学院',
[2100]= '攻城育幼所',
[2101]= '支援育幼所',
[2102]= '战争育幼所',
[2106]= '蕨皮山谷',
[2107]= '禁忌离岛',
[2109]= '战争育幼所',
[2110]= '支援育幼所',
[2111]= '攻城育幼所',
[2112]= '瓦德拉肯',
[2118]= '禁忌离岛',
[2119]= '化身巨龙牢窟',
--[2120]= '化身巨龙牢窟',
--[2121]= '化身巨龙牢窟',
--[2122]= '化身巨龙牢窟',
--[2123]= '化身巨龙牢窟',
--[2124]= '化身巨龙牢窟',
--[2125]= '化身巨龙牢窟',
--[2126]= '化身巨龙牢窟',
[2127]= '觉醒海岸',
[2128]= '碧蓝林海',
[2129]= '欧恩哈拉平原',
[2130]= '索德拉苏斯',
[2131]= '禁忌离岛',
[2132]= '碧蓝林海',
[2133]= '查拉雷克洞窟',
[2134]= '瓦德拉肯',
--[2135]= '瓦德拉肯',
[2146]= '东部林地',
[2147]= '艾泽拉斯',
--[2149]= '欧恩哈拉平原',
[2150]= '龙颅岛',
[2151]= '禁忌离岛',
[2154]= '霜石宝库',
[2162]= '奥特兰克山谷',
[2165]= '直达通路',
[2166]= '亚贝鲁斯，焰影熔炉',
--[2167]= '亚贝鲁斯，焰影熔炉',
--[2168]= '亚贝鲁斯，焰影熔炉',
--[2169]= '亚贝鲁斯，焰影熔炉',
--[2170]= '亚贝鲁斯，焰影熔炉',
--[2171]= '亚贝鲁斯，焰影熔炉',
--[2172]= '亚贝鲁斯，焰影熔炉',
--[2173]= '亚贝鲁斯，焰影熔炉',
--[2174]= '亚贝鲁斯，焰影熔炉',
[2175]= '查拉雷克洞窟',
[2176]= '大漩涡',
[2183]= '碧蓝魔馆',
[2184]= '查拉雷克洞窟',
[2190]= '年表圣殿',
[2191]= '千禧阈限',
[2192]= '永恒位点',
[2193]= '永冬轮辐',
[2194]= '宿命路口',
[2195]= '永恒流汇',
[2196]= '扭曲之途',
[2197]= '遗忘战场',
[2198]= '永恒黎明',
[2199]= '提尔要塞水库',
[2200]= '翡翠梦境',
[2201]= '艾兹基拉斯',
[2202]= '艾泽怒斯',
[2203]= '哀泽拉斯',
[2204]= '艾鱼拉斯',
[2205]= '奥达拉斯',
[2206]= 'A.Z.E.R.O.T.H.',
[2207]= '争霸之地',
[2211]= '亚贝鲁斯，焰影熔炉',
[2213]= '尼鲁巴尔',
[2214]= '喧鸣深窟',
[2215]= '陨圣峪',
--[2216]= 'Nerub'ar_Lower',
--[2220]= '暗夜要塞',
[2221]= '暗夜要塞',
[2228]= '黑暗帝国',
[2230]= '英灵殿',
--[2231]= '英灵殿',
[2232]= '阿梅达希尔',
--[2233]= '阿梅达希尔',
--[2234]= '阿梅达希尔',
[2235]= '北部虬枝',
[2236]= '东部虬枝',
[2237]= '南部虬枝',
--[2238]= '阿梅达希尔',
--[2239]= '阿梅达希尔',
--[2240]= '阿梅达希尔',
[2241]= '翡翠梦境',
[2244]= '阿梅达希尔',
[2248]= '多恩岛',
[2249]= '真菌之愚',
[2250]= '克莱格瓦之眠',
[2251]= '水能堡',
[2252]= '巨龙群岛',
[2253]= '索瑟里尔兽穴',
[2254]= '遐思之冢',
[2255]= '艾基-卡赫特',
[2256]= '艾基-卡赫特下层',
[2257]= '阿拉希高地',
[2259]= '塔克-雷桑深渊',
[2262]= '叛徒之眠',
[2266]= '千禧阈限',
[2268]= '阿梅达希尔',
[2269]= '地匍矿洞',
[2270]= '尼鲁巴尔载具',
[2271]= '卡兹阿加载具',
[2272]= '土灵匠域载具',
[2273]= '陨圣峪载具',
[2274]= '卡兹阿加',
--[2275]= '11.0-Underground [Deprecated]',
[2276]= '卡兹阿加载具',
[2277]= '夜幕圣所',
[2291]= '尼鲁巴尔王宫',
[2292]= '蛛魔王宫团队副本_A',
[2293]= '蛛魔王宫团队副本_C',
[2294]= '蛛魔王宫团队副本_D',
[2295]= '蛛魔王宫团队副本_E',
[2296]= '蛛魔王宫团队副本_F',
[2298]= '尼鲁巴尔王宫',
[2299]= '幽暗要塞',
[2300]= '无底沉穴',
--[2301]= '无底沉穴',
[2302]= '恐惧陷坑',
[2303]= '暗焰裂口',
[2304]= '暗焰_场景',
[2305]= '达拉然场景_A',
[2306]= '达拉然场景_B',
[2307]= '达拉然场景_C',
[2308]= '圣焰隐修院',
--[2309]= '圣焰隐修院',
[2310]= '飞掠裂口',
--[2311]= '11.0-Hallowfall-[Spreading the Light]- Disabled',
[2312]= '丝菌师洞穴',
[2313]= '螺旋织纹',
[2314]= '塔克-雷桑深渊',
[2315]= '驭雷栖巢',
--[2316]= '驭雷栖巢',
--[2317]= '驭雷栖巢',
--[2318]= '驭雷栖巢',
--[2319]= '驭雷栖巢',
--[2320]= '驭雷栖巢',
[2321]= '心之秘室',
[2322]= 'EarthenStarter_A',
[2328]= '卡兹阿加-榭台',
[2330]= '圣焰隐修院',
[2335]= '燧酿酒庄',
[2339]= '多恩诺嘉尔',
[2341]= '矶石宝库',
[2343]= '千丝之城',
[2344]= '蜕躯工厂',
[2345]= '御渊溪谷',
[2347]= '螺旋织纹',
[2348]= '泽克维尔的巢穴',
}












--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, _, arg1)
    if arg1==id then
        if not e.disbledCN then
            do
                for uiMapID, name in pairs(tab) do
                    local info = C_Map.GetMapInfo(uiMapID)
                    if info and info.name and info.name~='' and name~='' then
                        e.strText[info.name]= name
                    end
                end
            end
            tab=nil
        else
            tab=nil
        end
        self:UnregisterAllEvents()
    end
end)
