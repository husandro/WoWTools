local id, e = ...
local addName= CALENDAR_FILTER_HOLIDAYS
local Save={
    onGoing=true,--仅限: 正在活动
    --disabled= not e.Player.husandro
    --left=e.Player.husandro,--内容靠左
    --toTopTrack=true,--向上
    --showDate= true,--时间
}
local panel= CreateFrame('Frame')
local TrackButton
local Initializer





local eventTab={-- [',''},
[658]={'烟花庆典', '艾泽拉斯的大庆典！每个种族的主城中都会燃放美丽的烟花，每小时一次，整夜不停！'},
[1335]={'巨龙时代地下城活动', '在此活动期间，每个“巨龙时代”地下城的最终首领都会在被击败后额外奖励玩家一件物品'},
[642]={'赛艇大会','艾泽拉斯的居民需要休息。让我们去千针石林划船吧！'},
[1396]={'艾泽拉斯之秘','这片土地充满了秘密！隐世的奇珍，失窃的财宝，探明的线索…… 这背后是谁的阴谋？寻找捍卫者，帮他们查出真相！每天下午3点（太平洋时间）都会有新的秘密被发掘！'},
[691]={'时尚试炼','掸去肩甲上的征尘，加入艾泽拉斯的时尚比拼吧！与任意主城的幻化师对话，参与时尚试炼'},
[1525]={'《魔兽世界》幻境新生-熊猫人之谜','永恒龙军团正在调查潘达利亚的历史。重新游玩“熊猫人之谜”内容更新，体验全新赛季技能，赢取全新赛季奖励！'},
[1052]={'云游节','前往卡桑琅丛林的海龟沙滩，纪念刘浪和神真子的传奇。这是沉思的时刻，也是欢歌的时刻'},
[1462]={'《炉石传说》10周年','一起在瓦德拉肯、暴风城和奥格瑞玛庆祝这款给大家带来十年欢乐的卡牌游戏吧！'},
[1429]={'诺森德杯','驭龙者受到艾泽拉斯骑手会的邀请，前往诺森德参加各地的赛事！和瓦德拉肯的安德斯塔兹领主谈谈，了解更多信息。'},
--[563]={'战场假日活动','在此活动期间，随机战场奖励的荣誉值提高。荣耀在战场上等着你！'},
[1053]={'免费t恤日','目击者称，艾泽拉斯有多处出现了T恤商，而且他们的T恤……不要钱！！！甚至还有传言说，有艺人正在主城中发放免费的二手衬衫！'},
[1425]={'紊乱时间流','青铜龙军团再次发现时间流变得越发紊乱，有好几条时间流在与我们的时间流迅速交叉！ 连续完成时空漫游地下城后，你会获得时间流学识，暂时提升你获得的经验值。此外，在限定时间内，瓦德拉肯的卡兹拉提供的时空漫游任务奖励也会提升，会变为全新的英雄等级牢窟珍宝箱。'},
--[1335]={'巨龙时代地下城活动','在此活动期间，每个“巨龙时代”地下城的最终首领都会在被击败后额外奖励玩家一件物品'},
[1382]={'贪婪的特使','诡谲的烈风从另一个世界吹来，还有零星的传闻说，手持麻袋的奇怪生物现身于世…… 快去找找，看看它们究竟藏着什么样的财宝！'},
[648]={'亮顶节','今天，赞加沼泽孢子村的孢子人们将举行他们一年一度的蘑菇节。尽可能帮助他们保护伟大的弗肖，不要让她死亡！'},
[645]={'春日气球节','这是一个风和日丽的日子……最适合坐着热气球观光了。快乘上热气球饱览美景，结交新朋友吧'},
[1395]={'卡利姆多杯','驭龙者受到艾泽拉斯骑手会的邀请，前往卡利姆多参加各地的赛事！和瓦德拉肯的安德斯塔兹领主谈谈，了解更多信息。'},
[635]={'志愿军日','今天，艾泽拉斯和德拉诺的居民将共同表彰他们的保卫者所作出的贡献。向一名卫兵敬礼以表达你的敬意吧！'},
[694]={'枭兽节','今天，月光林地将举办一场有关枭兽的有趣庆典。快来看看你能学到些什么吧！'},
--[561]={'竞技场练习赛假日活动','在此活动期间，竞技场练习赛奖励的荣誉值提高。你是否愿意响应战斗的召唤呢？'},
[692]={'舞会','今天，奥格瑞玛和暴风城的主拍卖行已经清场并改为了舞会！快来展示一下你们的阵营荣誉感吧'},
[560]={'埃匹希斯假日活动','在此活动期间，埃匹希斯水晶的产量将离奇增长，德拉诺各地的敌人掉落水晶的概率将大幅提高。'},
[644]={'安戈洛狂欢节','安戈洛环形山的恐龙越来越焦躁了。该去拜访它们一下了！'},
[638]={'甲虫的召唤','历史上的今天，甲虫之锣被敲响，开启了安其拉的大门。代表你的阵营收集补给品，或者击杀暮光之锤和其拉虫族的部队。获胜的阵营可以将自己的旗帜挂在甲虫之锣旁，直至年末！'},
[1400]={'东部王国杯','驭龙者受到艾泽拉斯骑手会的邀请，前往东部王国参加各地的赛事！和瓦德拉肯的安德斯塔兹领主谈谈，了解更多信息。'},
[634]={'角鹰兽孵化日','今天是乱羽角鹰兽孵化的日子。前往位于菲拉斯的乱羽高地，亲眼见证这一奇景吧！'},
[407]={'外域杯','驭龙者受到艾泽拉斯骑手会的邀请，前往外域参加各地的赛事！和瓦德拉肯的安德斯塔兹领主谈谈，了解更多信息。'},
[1216]={'托加斯特-丧魂合唱队','丧魂在托加斯特，罪魂之塔中肆虐！'},
[647]={'蝌蚪远足日','今天，北风苔原的冬鳍部族的幼年鱼人们将完成他们穿越西部裂谷的旅程。'},
[696]={'诺莫瑞根马拉松','和侏儒们一起向他们百折不挠的精神致敬！跨越东部王国，从诺莫瑞根南下，一直跑到藏宝海湾！'},
[1054]={'幽光之星', 'GG工程公司在瓦丝琪尔的深海里发现了冷光生物。他们急需你的帮助才能展开研究，因为这些生物很快就会重新消失在深海中！'},
[1383]={'欢迎来到庇护之地','诡谲的烈风从另一个世界吹来，令英雄们感到精力愈加充沛。 活动期间，角色获得更多的经验值和声望。'},
[918]={'荆棘战争','黑海岸烽烟再起，部落和联盟会在这个限时事件中争夺对泰达希尔的控制权！'},
[1432]={'阿梅达希尔-梦境之愿','深入圣泉神殿，追击菲莱克，不能让他吞噬阿梅达希尔之心！'},
[564]={'德拉诺地下城活动','在此活动期间，击败任意100级英雄或史诗地下城里的敌人可获得相应德拉诺阵营的声望'},
--[1217]={'暗影界地下城活动','在此活动期间，每个“暗影国度”地下城的最终首领都会在被击败后额外奖励玩家一件物品。'},
[1316]={'宿命团队副本-统御圣所','本周内，统御圣所的首领难度提高并拥有一项特殊的词缀强化。掉落的战利品的物品等级提高。'},
[1217]={'暗影界地下城活动','在此活动期间，每个“暗影国度”地下城的最终首领都会在被击败后额外奖励玩家一件物品。'},
[1215]={'托加斯特-无拘黑暗','无拘黑暗已被释放到了托加斯特，罪魂之塔！'},
[965]={'荆棘战争','黑海岸烽烟再起，部落和联盟会在这个限时事件中争夺对泰达希尔的控制权！'},
[1214]={'托加斯特-浪骸野兽','浪骸野兽已被释放到了托加斯特，罪魂之塔！'},
--[591]={'军团再临-地下城活动','在此活动期间，每个“军团再临”地下城的最终首领都会在被击败后额外奖励玩家一件物品。'},
[941]={'争霸艾泽拉斯-地下城活动','在此活动期间，每个“争霸艾泽拉斯”地下城的最终首领都会在被击败后额外奖励玩家一件物品'},


[341]={'仲夏火焰节', '一个欢笑与庆祝的时刻，以纪念一年中最热的季节。'},
[327]={'春节', '月光林地的德鲁伊每年都会举行一次庆典，以庆祝他们对一股远古的邪恶力量所取得的胜利。在春节期间，艾泽拉斯的人民可以祭拜睿智的祖先，共享美味的盛宴，还有……绚丽的烟花！'},
[201]={'儿童周', '让孤儿看看英雄的生活是怎样的！拜访暴风城的孤儿监护员奈丁加尔，奥格瑞玛的孤儿监护员巴特维尔，沙塔斯城的孤儿院长莫希，达拉然的孤儿监护员艾蕊娅，达萨罗的看护者帕戴，或是伯拉勒斯的孤儿院长维斯特森。让孩子们梦想成真吧！'},
[423]={'情人节', '艾泽拉斯的各大主城中弥漫着某种气息。工匠齐聚一堂，展开了馈赠盛典。市民们会收到所爱之人饱含善意和爱意的礼物。'},
[324]={'万圣节', '万圣节是被遗忘者庆祝自己摆脱天灾军团控制的节日。 艾泽拉斯的旅店老板们会向所有上门问候的人送出糖果或恶作剧，到处都是欢乐的笑声。'},
[372]={'美酒节', '美酒节最初是矮人的节日，但现在已经成为了艾泽拉斯所有种族都喜欢的节日！ 前往铁炉堡外面的联盟营地，或是奥格瑞玛外面的部落营地参加狂欢吧！'},
[398]={'海盗日', '德梅萨船长正在地精城市藏宝海湾征募海盗。 如果你对海盗生涯感兴趣的话，就去各大主城拜访她和她的随从们吧！'},
[321]={'收获节', '收获节的意义，在于纪念那些为帮助朋友和伙伴而牺牲的英雄们。奥格瑞玛和铁炉堡外都在举行盛宴，向那些英雄表示敬意。'},
[181]={'复活节', '复活节到了。许多彩蛋巧妙地隐藏在每个种族的新手区域——年轻的英雄们初次检验自己力量的地方，你能找到多少呢？'},
[141]={'冬幕节', '冬天爷爷正在带着烟林牧场的礼物访问铁炉堡和奥格瑞玛。整个艾泽拉斯到处充满着节日的喜庆气氛！'},
[409]={'悼念日', '在悼念日，人们会聚集在墓地来告慰逝者的亡魂。 届时任何主城的公墓都会举行仪式，在那里有悼念日食品、舞蹈、化装聚会和其他活动。'},
[404]={'感恩节','感恩节是一场感谢好运，并将自己的幸福和周围的人们共同分享的节日。'},
[62]={'焰火表演','在日落之后，伴随着每小时一次的焰火舞会，仲夏火焰节将缓缓落下帷幕。 想要观看表演的话，可以前去各大主城或者藏宝海湾。'},

--循环 事件
[479]={'暗月马戏团', '暗月马戏团已经开张营业！ 去拜访希拉斯·暗月和他的马戏团，玩一玩考验头脑和胆量的游戏，看一看来自艾泽拉斯各地的奇特珍品……还有更多的乐趣在等着你！'},
[587]={'漫游大地裂变','在此活动期间，35级及以上玩家可以加入特殊的随机时空漫游地下城队列，将玩家的角色及物品等级降低到“大地的裂变”的旧地下城的相同水平。在时空漫游中，首领会掉落适合玩家真实等级的战利品。 在“大地的裂变”时空漫游期间，你可以组建一个10人到30人的团队，前往奥格瑞玛或暴风城，与沃尔姆谈话以进入火焰之地团队副本的时空漫游版本。'},
[559]={'漫游燃烧远征', '在此活动期间，30级及以上玩家可以加入特殊的随机时空漫游地下城队列，将玩家的角色及物品等级降低到“燃烧的远征”的旧地下城的相同水平。在时空漫游中，首领会掉落适合玩家真实等级的战利品。 在“燃烧的远征”时空漫游期间，你可以组建一个10人到30人的团队，前往外域的沙塔斯，与沃尔姆谈话以进入黑暗神殿团队副本的时空漫游版本。'},
[562]={'漫游巫妖王之怒', '在此活动期间，30级及以上玩家可以加入特殊的随机时空漫游地下城队列，将玩家的角色及物品等级降低到“巫妖王之怒”的旧地下城的相同水平。在时空漫游中，首领会掉落适合玩家真实等级的战利品。 在“巫妖王之怒”时空漫游期间，你可以组建一个10人到30人的团队，前往诺森德的达拉然，与沃尔姆谈话以进入奥杜尔团队副本的时空漫游版本。'},
[592]={'世界任务奖励活动','在此活动期间，完成世界任务会额外奖励对应阵营的声望值。'},
[563]={'战场假日活动','在此活动期间，随机战场奖励的荣誉值提高。荣耀在战场上等着你！'},
[561]={'竞技场练习赛假日活动','在此活动期间，竞技场练习赛奖励的荣誉值提高。你是否愿意响应战斗的召唤呢？'},
[565]={'宠物对战假日活动','在此活动期间，你的宠物可获得双倍经验值！快出去战斗吧！'},
[646]={'肯瑞托旅店趴','艾泽拉斯的法师们也需要休闲。快去你所在地的酒吧，进入传送门，参加旅店趴活动吧！'},
[591]={'军团再临-地下城活动','在此活动期间，每个“军团再临”地下城的最终首领都会在被击败后额外奖励玩家一件物品。'},

[1235]={'PvP乱斗-人机对决'},
[1240]={'PvP乱斗-深风大灌篮'},
[1120]={'PvP乱斗-经典阿什兰'},
[664]={'PvP乱斗-战歌争夺战'},
[666]={'PvP乱斗-阿拉希暴风雪'},
[1233]={'PvP乱斗-决战影踪派'},
[663]={'PvP乱斗-引力失效'},
[1311]={'PvP乱斗-单排轮斗'},
[667]={'PvP乱斗-爆棚乱战'},
[702]={'PvP乱斗-六人战'},
[1452]={'PvP乱斗-战场闪电战'},
[1047]={'PvP乱斗-碟中碟'},
[662]={'PvP乱斗-南海镇vs塔伦米尔'},
[1170]={'PvP乱斗-魔古接力'},


[590]={'魔兽世界周年庆典'},
[693]={'魔兽世界十三周年'},
[589]={'魔兽世界十二周年'},
[566]={'魔兽世界十一周年'},
[514]={'魔兽世界十周年'},
[808]={'魔兽世界十五周年'},
[1181]={'魔兽世界十六周年'},
[1225]={'魔兽世界十七周年'},
[1262]={'魔兽世界十八周年'},
[1397]={'魔兽世界十九周年'},
[1501]={'《魔兽世界》二十一周年'},
}











local function _CalendarFrame_SafeGetName(name)
	if ( not name or name == "" ) then
		return e.onlyChinese and '未知' or UNKNOWN;
	end
	return name;
end

local function _CalendarFrame_IsPlayerCreatedEvent(calendarType)
	return
		calendarType == "PLAYER" or
		calendarType == "GUILD_ANNOUNCEMENT" or
		calendarType == "GUILD_EVENT" or
		calendarType == "COMMUNITY_EVENT";
end

local function _CalendarFrame_IsSignUpEvent(calendarType, inviteType)
	return (calendarType == "GUILD_EVENT" or calendarType == "COMMUNITY_EVENT") and inviteType == Enum.CalendarInviteType.Signup;
end

local CALENDAR_CALENDARTYPE_TOOLTIP_NAMEFORMAT = {
	["PLAYER"] = {
		[""]				= "%s",
	},
	["GUILD_ANNOUNCEMENT"] = {
		[""]				= "%s",
	},
	["GUILD_EVENT"] = {
		[""]				= "%s",
	},
	["COMMUNITY_EVENT"] = {
		[""]				= "%s",
	},
	["SYSTEM"] = {
		[""]				= "%s",
	},
	["HOLIDAY"] = {
		["START"]			= e.onlyChinese and '%s 开始' or CALENDAR_EVENTNAME_FORMAT_START,
		["END"]				= e.onlyChinese and '%s 结束' or CALENDAR_EVENTNAME_FORMAT_END,
		[""]				= "%s",
		["ONGOING"]			= "%s",
	},
	["RAID_LOCKOUT"] = {
		[""]				= e.onlyChinese and '%s解锁' or CALENDAR_EVENTNAME_FORMAT_RAID_LOCKOUT,
	},
};

local function set_Time_Color(eventTime, hour, minute, init)
    if hour and minute then
        local seconds= hour*3600 + minute*60
        local time= GetServerTime()
        if (init and time< seconds)
          or (not init and time> seconds)
        then
            return '|cff828282'..eventTime..'|r', false
        end
    end
    return eventTime, true
end

local function set_Quest_Completed(tab)--任务是否完成
    for _, questID in pairs(tab) do
        local completed= C_QuestLog.IsQuestFlaggedCompleted(questID)
        if completed then
            return format('|A:%s:0:0|a', e.Icon.select)
        end
    end
end

local CALENDAR_EVENTTYPE_TEXTURES = {
	[Enum.CalendarEventType.Raid]		= "Interface\\LFGFrame\\LFGIcon-Raid",
	[Enum.CalendarEventType.Dungeon]	= "Interface\\LFGFrame\\LFGIcon-Dungeon",
	--[Enum.CalendarEventType.PvP]		=  e.Player.faction=='Alliance' and "Interface\\Calendar\\UI-Calendar-Event-PVP02" or (e.Player.faction=='Horde' and "Interface\\Calendar\\UI-Calendar-Event-PVP01") or "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[Enum.CalendarEventType.Meeting]	= "Interface\\Calendar\\MeetingIcon",
	[Enum.CalendarEventType.Other]		= "Interface\\Calendar\\UI-Calendar-Event-Other",
}






local function Get_Button_Text(event)
    local icon,atlas
    local findQuest
    local text
    local texture
    local title

    if eventTab[event.eventID] then
        title=eventTab[event.eventID][1]
    end
    title= title or e.cn(event.title)


    if _CalendarFrame_IsPlayerCreatedEvent(event.calendarType) then--自定义,事件
        local invitInfo= C_Calendar.EventGetInvite(event.index) or {}
        if invitInfo.guid then
            atlas= e.GetPlayerInfo({guid=invitInfo.guid, reAtlas=true})
        end
        if UnitIsUnit("player", event.invitedBy) then--我
            atlas= atlas or e.GetUnitRaceInfo({unit='player',reAtlas=true})
        else
            if _CalendarFrame_IsSignUpEvent(event.calendarType, event.inviteType) then
                local inviteStatusInfo = CalendarUtil.GetCalendarInviteStatusInfo(event.inviteStatus);
                if event.inviteStatus== Enum.CalendarStatus.NotSignedup or event.inviteStatus == Enum.CalendarStatus.Signedup then
                    text = inviteStatusInfo.name;
                else
                    text = format(e.onlyChinese and '已登记（%s）' or CALENDAR_SIGNEDUP_FOR_GUILDEVENT_WITH_STATUS, inviteStatusInfo.name);
                end
            else
                if ( event.calendarType == "GUILD_ANNOUNCEMENT" ) then
                    text = format(e.onlyChinese and '由%s创建' or CALENDAR_ANNOUNCEMENT_CREATEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
                    atlas= 'communities-icon-chat'
                else
                    text = format( e.onlyChinese and '被%s邀请' or CALENDAR_EVENT_INVITEDBY_PLAYER, _CalendarFrame_SafeGetName(event.invitedBy));
                end
            end
            atlas= atlas or 'charactercreate-icon-dice'
        end


    elseif ( event.calendarType == "RAID_LOCKOUT" ) then
        title= format(
            CALENDAR_CALENDARTYPE_TOOLTIP_NAMEFORMAT[event.calendarType][event.sequenceType],
            GetDungeonNameWithDifficulty(title, event.difficultyName)
        )
        atlas='worldquest-icon-raid'

    elseif event.calendarType=='HOLIDAY' then
        if title:find(PLAYER_DIFFICULTY_TIMEWALKER) or--时空漫游
            event.eventID==1063 or
            event.eventID==616 or
            event.eventID==617 or
            event.eventID==623 or
            event.eventID==629 or
            event.eventID==643 or--熊猫人之迷
            event.eventID==654 or
            event.eventID==1068 or
            event.eventID==1277 or
            event.eventID==1269
        then

            local tab={40168, 40173, 40786, 45563, 55499, 40168, 40173, 40787, 45563, 55498, 64710,64709,
                72725,--迷离的时光之路 熊猫人之迷
            }
            local isCompleted= set_Quest_Completed(tab)--任务是否完成
            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            title=(e.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)
            findQuest= isCompleted and true or findQuest
            icon=463446--1166[时空扭曲徽章]

        elseif event.eventID==479 then--暗月--CALENDAR_FILTER_DARKMOON = "暗月马戏团"--515[暗月奖券]
            local tab={36471, 32175}
            local isCompleted= set_Quest_Completed(tab)--任务是否完成
            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            findQuest=isCompleted and true or findQuest
            icon=134481

        elseif event.eventID==324 or event.eventID==1405 then--万圣节
            icon= 236546--33226[奶糖]
        elseif event.eventID==423 then--情人节
            icon=235468
        elseif event.eventID==181 then
            icon= 235477
        elseif event.eventID==691 then
            icon=1500867
        elseif event.iconTexture then
            icon=event.iconTexture
        end
    end


    if event.eventType== Enum.CalendarEventType.PvP or  title:find(PVP) or event.eventID==561 then
        atlas= 'pvptalents-warmode-swords'--pvp

    elseif event.calendarType=='HOLIDAY' and event.eventID then

        if event.title:find(PLAYER_DIFFICULTY_TIMEWALKER)--时空漫游
            or event.eventID==1063
            or event.eventID==616
            or event.eventID==617
            or event.eventID==623
            or event.eventID==629
            or event.eventID==643--熊猫人之迷
            or event.eventID==654
            or event.eventID==1068
            or event.eventID==1277
            or event.eventID==1269
         then

            local tab={40168, 40173, 40786, 45563, 55499, 40168, 40173, 40787, 45563, 55498, 64710,64709,
            72725,--迷离的时光之路 熊猫人之迷
            }
            local isCompleted= set_Quest_Completed(tab)--任务是否完成

            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            findQuest= isCompleted
            icon=463446--1166[时空扭曲徽章]

        elseif event.eventID==479 then--暗月--CALENDAR_FILTER_DARKMOON = "暗月马戏团"
            local tab={36471, 32175}
            local isCompleted= set_Quest_Completed(tab)--任务是否完成
            texture= isCompleted or '|A:AutoQuest-Badge-Campaign:0:0|a'
            findQuest=isCompleted
            icon=134481--515[暗月奖券]

        elseif event.eventID==324 or event.eventID==1405 then--万圣节
            icon= 236546--33226[奶糖]
        elseif event.eventID==423 then--情人节
            icon=235468
        elseif event.eventID==181 then
            icon= 235477
        elseif event.eventID==691 then
            icon=1500867
        elseif event.iconTexture then
            icon=event.iconTexture
        end
    end
    title= e.cn(title:match(HEADER_COLON..'(.+)') or title)
    title= not event.isValid and '|cff606060'..title..'|r' or title
    local msg
    if Save.left then
        msg= ((Save.showDate and event.eventTime) and event.eventTime..' ' or '')
            ..(text and text..' ' or '')
            ..(texture or '')
            ..title
    else
        msg= title
            ..(texture or '')
            ..(text and ' '..text or '')
            ..((Save.showDate and event.eventTime) and ' '..event.eventTime or '')
    end

    icon= icon or CALENDAR_EVENTTYPE_TEXTURES[event.eventType]
    return msg, icon, atlas, findQuest
end





--TrackButton，提示
local function Set_TrackButton_Pushed(show, text)
	if TrackButton then
		TrackButton:SetButtonState(show and 'PUSHED' or "NORMAL")
	end
    if text then
		text:SetAlpha(show and 0.5 or 1)
	end
end

local function _CalendarFrame_IsTodayOrLater(month, day, year)--Blizzard_Calendar.lua
	local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime() or {};
	return currentCalendarTime.month==month and
	    currentCalendarTime.monthDay== day and
        currentCalendarTime.year== year
end

--设置,显示内容 Blizzard_Calendar.lua CalendarDayButton_OnEnter(self)
local function Set_TrackButton_Text(monthOffset, day)
    if Save.hide or not TrackButton then
        if TrackButton then
            TrackButton:set_Shown()
        end
        return
    end
    if not monthOffset or not day then
        local info= C_Calendar.GetEventIndex()
        if info then
            monthOffset=info.offsetMonths
            day=info.monthDay
        else
            local currentCalendarTime= C_DateAndTime.GetCurrentCalendarTime()
            if currentCalendarTime then
                monthOffset=0
                day= currentCalendarTime.monthDay
            end
        end
    end

    local events = {};
    local findQuest
    local isToDay

    if day and monthOffset then
        local monthInfo = C_Calendar.GetMonthInfo(monthOffset);
        if monthInfo then
            isToDay=_CalendarFrame_IsTodayOrLater(monthInfo.month, day, monthInfo.year)
        end
    end

    local numEvents = (day and monthOffset) and C_Calendar.GetNumDayEvents(monthOffset, day) or 0
    if numEvents>0 then
        for i = 1, numEvents do
            local event = C_Calendar.GetDayEvent(monthOffset, day, i);
            if event and event.title then
                local isValid
                if (event.sequenceType == "ONGOING") then
                    event.eventTime = format(CALENDAR_TOOLTIP_DATE_RANGE, FormatShortDate(event.startTime.monthDay, event.startTime.month), FormatShortDate(event.endTime.monthDay, event.endTime.month));
                    isValid=true
                elseif (event.sequenceType == "END") then
                    event.eventTime, isValid = set_Time_Color(GameTime_GetFormattedTime(event.endTime.hour, event.endTime.minute, true), event.startTime.hour, event.startTime.minute)
                else
                    event.eventTime, isValid = set_Time_Color(GameTime_GetFormattedTime(event.startTime.hour, event.startTime.minute, true), event.startTime.hour, event.startTime.minute, true)
                end

                if _CalendarFrame_IsPlayerCreatedEvent(event.calendarType)
                    or not isToDay--今天
                    or not Save.onGoing
                    or (Save.onGoing and isValid)
                then
                    event.index= i
                    event.isValid= isValid
                    local text, texture, atlas, findQuest2= Get_Button_Text(event)
                    if text then
                        event.tab={text= text, texture=texture, atlas= atlas}

                        findQuest= (not findQuest and findQuest2) and true or findQuest

                        tinsert(events, event);
                    end
                end
            end
        end
        table.sort(events, function(a, b)
            if ((a.sequenceType == "ONGOING") ~= (b.sequenceType == "ONGOING")) then
                return a.sequenceType ~= "ONGOING";
            elseif (a.sequenceType == "ONGOING" and a.sequenceIndex ~= b.sequenceIndex) then
                return a.sequenceIndex > b.sequenceIndex;
            end
            if (a.startTime.hour ~= b.startTime.hour) then
                return a.startTime.hour < b.startTime.hour;
            end
            return a.startTime.minute < b.startTime.minute;
        end)
    end



   local last
	for index, event in ipairs(events) do
        local btn= TrackButton.btn[index]
        if not btn then
            btn= e.Cbtn(TrackButton.Frame, {size={14,14}, icon='hide'})
            if Save.toTopTrack then
                btn:SetPoint('BOTTOM', last or TrackButton, 'TOP')
            else
			    btn:SetPoint('TOP', last or TrackButton, 'BOTTOM')
            end
            btn:SetScript('OnLeave', function(self)
				e.tips:Hide()
				Set_TrackButton_Pushed(false, self.text)--TrackButton，提示
			end)

            btn:SetScript('OnEnter', function(self)
                if Save.left then
                    GameTooltip:SetOwner(self.text, "ANCHOR_LEFT")
                else
                    GameTooltip:SetOwner(self.text, "ANCHOR_RIGHT")
                end
                e.tips:ClearLines()
                local title, description
                if (self.monthOffset and self.day and self.index) then
                    local holidayInfo= C_Calendar.GetHolidayInfo(self.monthOffset, self.day, self.index);
                    if (holidayInfo) then
                        if eventTab[self.eventID] then
                            title= eventTab[self.eventID][1]
                            description= eventTab[self.eventID][2]
                        end
                        title= title or holidayInfo.name
                        description = description or holidayInfo.description;

                        if (holidayInfo.startTime and holidayInfo.endTime) then
                            description=format(e.onlyChinese and '%1$s|n|n开始：%2$s %3$s|n结束：%4$s %5$s' or CALENDAR_HOLIDAYFRAME_BEGINSENDS,
                                e.cn(description),
                                FormatShortDate(holidayInfo.startTime.monthDay, holidayInfo.startTime.month),
                                GameTime_GetFormattedTime(holidayInfo.startTime.hour, holidayInfo.startTime.minute, true),
                                FormatShortDate(holidayInfo.endTime.monthDay, holidayInfo.endTime.month),
                                GameTime_GetFormattedTime(holidayInfo.endTime.hour, holidayInfo.endTime.minute, true)
                            )
                        end
                    else
                        local raidInfo = C_Calendar.GetRaidInfo(self.monthOffset, self.day, self.index);
                        if raidInfo and raidInfo.calendarType == "RAID_LOCKOUT" then
                            title = GetDungeonNameWithDifficulty(raidInfo.name, raidInfo.difficultyName);
                            description= format(e.onlyChinese and '你的%1$s副本将在%2$s解锁。' or CALENDAR_RAID_LOCKOUT_DESCRIPTION, e.cn(title),  GameTime_GetFormattedTime(raidInfo.time.hour, raidInfo.time.minute, true))
                        end
                    end
                    if title or description then
                        if title then
                            e.tips:AddLine(e.cn(title))
                        end
                        if description then
                            e.tips:AddLine(' ')
                            e.tips:AddLine(description, nil,nil,nil,true)
                            e.tips:AddLine(' ')
                        end
                    end
                end
                e.tips:AddDoubleLine('eventID', self.eventID)
                e.tips:AddDoubleLine(id, Initializer:GetName())
                e.tips:Show()
				Set_TrackButton_Pushed(true, self.text)--TrackButton，提示
			end)


            btn.text= e.Cstr(btn, {color=true})
            function btn:set_text_point()
                if Save.left then
                    self.text:SetPoint('RIGHT', self, 'LEFT',1, 0)
                else
                    self.text:SetPoint('LEFT', self, 'RIGHT', -1, 0)
                end
                self.text:SetJustifyH(Save.left and 'RIGHT' or 'LEFT')
            end
            btn:set_text_point()

			TrackButton.btn[index]=btn
		else
			btn:SetShown(true)
		end
		last=btn


        btn.index= event.index
        btn.day=day
        btn.monthOffset= monthOffset
        btn.eventID= event.eventID

        btn.text:SetText(event.tab.text)

		if event.tab.atlas then
			btn:SetNormalAtlas(event.tab.atlas)
		else
			btn:SetNormalTexture(event.tab.texture or event.iconTexture or 0)
		end
	end

    TrackButton:UnregisterEvent('QUEST_COMPLETE')
    if findQuest then
        TrackButton:RegisterEvent('QUEST_COMPLETE')
    end

    if (day and not isToDay) then
        TrackButton:SetNormalAtlas( 'UI-HUD-Calendar-'..day..'-Mouseover')
    else
        TrackButton:SetNormalTexture(0)
    end

    for index= #events+1, #TrackButton.btn do
		local btn=TrackButton.btn[index]
		btn.text:SetText('')
		btn:SetShown(false)
		btn:SetNormalTexture(0)
	end

    TrackButton.monthOffset= monthOffset
    TrackButton.day= day
    TrackButton:SetID(day or 0)
end










local function Init_TrackButton()
    TrackButton= e.Cbtn(nil, {icon='hide', size={18,18}, pushe=true})

    TrackButton.texture=TrackButton:CreateTexture()
    TrackButton.texture:SetAllPoints(TrackButton)
    TrackButton.texture:SetAlpha(0.5)
    TrackButton.texture:SetAtlas(e.Icon.icon)

    TrackButton.Frame= CreateFrame('Frame',nil, TrackButton)
    TrackButton.Frame:SetPoint('BOTTOM')
    TrackButton.Frame:SetSize(1,1)

    TrackButton.btn={}

    TrackButton:RegisterForDrag("RightButton")
    TrackButton:SetMovable(true)
    TrackButton:SetClampedToScreen(true)
    TrackButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    TrackButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)

    function TrackButton:set_Events()--设置事件
        if Save.hide then
            self:UnregisterAllEvents()
        else
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')

            self:RegisterEvent('CALENDAR_UPDATE_EVENT_LIST')
            self:RegisterEvent('CALENDAR_UPDATE_EVENT')
            self:RegisterEvent('CALENDAR_NEW_EVENT')
            self:RegisterEvent('CALENDAR_OPEN_EVENT')
            self:RegisterEvent('CALENDAR_CLOSE_EVENT')
        end
    end


    function TrackButton:set_Shown()
        local hide= IsInInstance() or C_PetBattles.IsInBattle() or UnitAffectingCombat('player')
        self:SetShown(not hide)
        self.texture:SetShown(Save.hide and true or false)
        self.Frame:SetShown(not hide and not Save.hide)
    end


    function TrackButton:set_Scale()
        self.Frame:SetScale(Save.scale or 1)
    end


    function TrackButton:set_Tooltips()
        if self.monthOffset and self.day then
            CalendarDayButton_OnEnter(self)
            e.tips:AddLine(' ')
        else
            if Save.left then
                e.tips:SetOwner(self, "ANCHOR_LEFT")
            else
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
            end
            e.tips:ClearLines()
        end
        e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭日历' or GAMETIME_TOOLTIP_TOGGLE_CALENDAR, e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.scale or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:Show()
    end
    TrackButton:SetScript('OnMouseUp', ResetCursor)
    TrackButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then
            Calendar_Toggle()

        elseif d=='RightButton' then
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)
                    local info
                    info={
                        text=e.onlyChinese and '显示' or SHOW,
                        checked=not Save.hide,
                        func= function()
                            Save.hide= not Save.hide and true or nil
                            Set_TrackButton_Text()
                            TrackButton:set_Events()--设置事件
                            TrackButton:set_Shown()
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)

                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    info={
                        text= e.onlyChinese and '向左平移' or BINDING_NAME_STRAFELEFT,--向左平移
                        checked=not Save.left,
                        func= function()
                            Save.left= not Save.left and true or nil
                            for _, btn in pairs(TrackButton.btn) do
                                btn.text:ClearAllPoints()
                                btn:set_text_point()
                            end
                            Set_TrackButton_Text()
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)

                    info={
						text=e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP,
						icon='bags-greenarrow',
						checked= Save.toTopTrack,
						func= function()
							Save.toTopTrack = not Save.toTopTrack and true or nil
							local last
							for index= 1, #TrackButton.btn do
								local btn=TrackButton.btn[index]
								btn:ClearAllPoints()
								if Save.toTopTrack then
									btn:SetPoint('BOTTOM', last or TrackButton, 'TOP')
								else
									btn:SetPoint('TOP', last or TrackButton, 'BOTTOM')
								end
								last=btn
							end
							Set_TrackButton_Text()
						end
					}
					e.LibDD:UIDropDownMenu_AddButton(info, level)


                    info={
                        text= e.onlyChinese and '仅限: 正在活动' or LFG_LIST_CROSS_FACTION:format(CALENDAR_TOOLTIP_ONGOING),
                        checked= Save.onGoing,
                        func= function()
                            Save.onGoing= not Save.onGoing and true or nil
                            Set_TrackButton_Text()
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)

                    info={
                        text= e.onlyChinese and '时间' or TIME_LABEL,
                        checked= Save.showDate,
                        func= function()
                            Save.showDate= not Save.showDate and true or nil
                            Set_TrackButton_Text()
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)


    TrackButton:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            local sacle=Save.scale or 1
            if d==1 then
                sacle=sacle+0.05
            elseif d==-1 then
                sacle=sacle-0.05
            end
            if sacle>4 then
                sacle=4
            elseif sacle<0.4 then
                sacle=0.4
            end
            print(id, Initializer:GetName(), e.onlyChinese and '缩放' or UI_SCALE, sacle)
            Save.scale=sacle
            self:set_Scale()
            self:set_Tooltips()
        end
    end)
    TrackButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        --self.texture:SetAlpha(0.5)
    end)
    TrackButton:SetScript('OnEnter', function(self)
        self:set_Tooltips()
        --self.texture:SetAlpha(1)
    end)

    function TrackButton:set_Point()--设置, 位置
        if Save.point then
            self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        elseif e.Player.husandro then
            self:SetPoint('TOPLEFT', 150,0)
        else
            self:SetPoint('BOTTOMRIGHT', _G['!KalielsTrackerFrame'] or ObjectiveTrackerBlocksFrame, 'TOPLEFT', -35, -10)
        end
    end

    TrackButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD'
        or event=='PLAYER_REGEN_DISABLED'
        or event=='PLAYER_REGEN_ENABLED'
        or event=='PET_BATTLE_OPENING_DONE'
        or event=='PET_BATTLE_CLOSE'
        then
            self:set_Shown()
        else
            Set_TrackButton_Text()
        end
    end)



    TrackButton:set_Point()
    TrackButton:set_Scale()
    TrackButton:set_Shown()
    TrackButton:set_Events()
    Set_TrackButton_Text()

    hooksecurefunc('CalendarDayButton_Click', function(button)
        Set_TrackButton_Text(button.monthOffset, button.day)
    end)
    CalendarFrame:HookScript('OnHide', function()
        Set_TrackButton_Text()
        Set_TrackButton_Pushed(false)--TrackButton，提示

    end)
    CalendarFrame:HookScript('OnShow', function()
        Set_TrackButton_Pushed(true)--TrackButton，提示
        C_Timer.After(2, function()
            Set_TrackButton_Pushed(false)
        end)
    end)
end



























local function calendar_Uptate()
    local indexInfo = C_Calendar.GetEventIndex()
    local info= indexInfo and C_Calendar.GetDayEvent(indexInfo.offsetMonths, indexInfo.monthDay, indexInfo.eventIndex) or {}
    local text
    if info.eventID then
        local head, desc
        if eventTab[info.eventID] then
            head, desc= eventTab[info.eventID][1], eventTab[info.eventID][2]
        end
        text= (info.iconTexture and '|T'..info.iconTexture..':0|t'..info.iconTexture..'|n' or '')
            ..'eventID '..info.eventID
            ..(info.title and '|n'..info.title or '')
            ..(head and '|n'..head or '')
        if head then
            CalendarViewHolidayFrame.Header:Setup(head)
        end
        if desc then
            if (info.startTime and info.endTime) then
                desc = format('%1$s|n|n开始：%2$s %3$s|n结束：%4$s %5$s', desc, FormatShortDate(info.startTime.monthDay, info.startTime.month), GameTime_GetFormattedTime(info.startTime.hour, info.startTime.minute, true), FormatShortDate(info.endTime.monthDay, info.endTime.month), GameTime_GetFormattedTime(info.endTime.hour, info.endTime.minute, true));
            end
            CalendarViewHolidayFrame.ScrollingFont:SetText(desc)
        end
        
    end
    if text and not CalendarViewHolidayFrame.Text then
        CalendarViewHolidayFrame.Text= e.Cstr(CalendarViewHolidayFrame, {mouse=true, color={r=0, g=0.68, b=0.94, a=1}})
        CalendarViewHolidayFrame.Text:SetPoint('BOTTOMLEFT',12,12)
        CalendarViewHolidayFrame.Text:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
        CalendarViewHolidayFrame.Text:SetScript('OnEnter', function(self)
            self:SetAlpha(0.3)
            if not self.eventID then return end
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('https://www.wowhead.com/event='..self.eventID, e.Icon.left)
            e.tips:Show()
        end)
        CalendarViewHolidayFrame.Text:SetScript('OnMouseDown', function(frame)
            if not frame.eventID then return end
            e.Show_WoWHead_URL(true, 'event', frame.eventID, nil)
        end)

        CalendarViewHolidayFrame.Texture2=CalendarViewHolidayFrame:CreateTexture()
        local w,h= CalendarViewHolidayFrame:GetSize()
        CalendarViewHolidayFrame.Texture2:SetSize(w-70, h-70)
        CalendarViewHolidayFrame.Texture2:SetPoint('CENTER',40,-40)
        CalendarViewHolidayFrame.Texture2:SetAlpha(0.5)
    end
    if CalendarViewHolidayFrame.Text then
        CalendarViewHolidayFrame.Text.eventID= info.eventID or nil
        CalendarViewHolidayFrame.Text:SetText(text or '')
        CalendarViewHolidayFrame.Texture2:SetTexture(info.iconTexture or 0)
    end
end


--#########
--初始，插件
--#########
local CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS		= 4;
local function ShouldDisplayEventOnCalendar(event)
	local shouldDisplayBeginEnd = event and event.sequenceType ~= "ONGOING";
	if ( event.sequenceType == "END" and event.dontDisplayEnd ) then
		shouldDisplayBeginEnd = false;
	end
	return shouldDisplayBeginEnd;
end

local function Init_Blizzard_Calendar()
    hooksecurefunc('CalendarFrame_UpdateDayEvents', function(index, day, monthOffset, selectedEventIndex, contextEventIndex)
        local dayButtonName= 'CalendarDayButton'..index

        local numEvents = C_Calendar.GetNumDayEvents(monthOffset, day);
        local eventIndex = 1;
        local eventButtonIndex = 1;        
        while ( eventButtonIndex <= CALENDAR_DAYBUTTON_MAX_VISIBLE_EVENTS and eventIndex <= numEvents ) do
            local eventButtonText1 = _G[dayButtonName..'EventButton'..eventButtonIndex.."Text1"];--CalendarDayButton16EventButton1Text1
            local event = C_Calendar.GetDayEvent(monthOffset, day, eventIndex);
            if ShouldDisplayEventOnCalendar(event) then
                local title= eventTab[event.eventID] and eventTab[event.eventID][1]
                if title then--and not event.isCustomTitle  then
                    eventButtonText1:SetText(title)
                end
                eventButtonIndex = eventButtonIndex + 1;
            end
            eventIndex = eventIndex + 1;
        end
    end)
    if CalendarViewHolidayFrame.update then
        hooksecurefunc(CalendarViewHolidayFrame, 'update', calendar_Uptate)--提示节目ID
    end
    hooksecurefunc('CalendarViewHolidayFrame_Update', calendar_Uptate)

    hooksecurefunc('CalendarCreateEventInviteListScrollFrame_Update', function()
        local namesReady = C_Calendar.AreNamesReady();
        local frame= CalendarCreateEventInviteList.ScrollBox
        if namesReady or not frame:GetView()  then
            for index, btn in pairs(frame:GetFrames()) do--ScrollBox.lua
                local inviteInfo = C_Calendar.EventGetInvite(index)
                if inviteInfo and inviteInfo.guid then
                    btn.Class:SetText(e.GetPlayerInfo({guid=inviteInfo.guid, name=inviteInfo.name}))
                end
            end
        end
    end)


    --Blizzard_Calendar.lua
    CalendarCreateEventFrame:HookScript('OnShow', function(self)
        if self.menu then
            return
        end
        self.menu=CreateFrame("Frame", nil, CalendarCreateEventFrame, "UIDropDownMenuTemplate")
        self.menu:SetPoint('BOTTOMLEFT', CalendarCreateEventFrame, 'BOTTOMRIGHT', -22,74)
        e.LibDD:UIDropDownMenu_SetWidth(self.menu, 60)
        e.LibDD:UIDropDownMenu_SetText(self.menu, e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)
        e.LibDD:UIDropDownMenu_Initialize(self.menu, function(_, level)
            local map=e.GetUnitMapName('player');--玩家区域名称
            local inviteTab={}
            for index = 1, C_Calendar.GetNumInvites() do
                local inviteInfo = C_Calendar.EventGetInvite(index);
                if inviteInfo and inviteInfo.name then
                    inviteTab[inviteInfo.name]= true
                end
            end
            local find
            for i=1 ,BNGetNumFriends() do
                local wow=C_BattleNet.GetFriendAccountInfo(i);
                local wowInfo= wow and wow.gameAccountInfo
                if wowInfo and wowInfo.playerGuid and wowInfo.characterName and not inviteTab[wowInfo.characterName] and wowInfo.wowProjectID==1 then

                    local text= e.GetPlayerInfo({guid=wowInfo.playerGuid, faction=wowInfo.factionName, name=wowInfo.characterName, reName=true, reRealm=true})--角色信息
                    if wowInfo.areaName then --位置
                        if wowInfo.areaName==map then
                            text=text..'|A:poi-islands-table:0:0|a'
                        else
                            text=text..' '..wowInfo.areaName
                        end
                    end

                    if wowInfo.characterLevel and wowInfo.characterLevel~=MAX_PLAYER_LEVEL and wowInfo.characterLevel>0 then--等级
                        text=text ..' |cff00ff00'..wowInfo.characterLevel..'|r'
                    end
                    if not wowInfo.isOnline then
                        text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                    end
                    local info={
                        text=text,
                        notCheckable=true,
                        tooltipOnButton=true,
                        tooltipTitle= wow and wow.note,
                        arg1= wowInfo.characterName..(wowInfo.realmName and '-'..wowInfo.realmName or ''),
                        func=function(self2, arg1)
                            CalendarCreateEventInviteEdit:SetText(arg1)
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    find=true
                end
            end
            if not find then
                e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
            end
        end)
        self.menu.Button:SetScript('OnMouseDown', function(self2)
            e.LibDD:ToggleDropDownMenu(1, nil, self2:GetParent(), self2, 15, 0)
        end)

        local menu2=CreateFrame("Frame", nil, CalendarCreateEventFrame, "UIDropDownMenuTemplate")
        menu2:SetPoint('TOPRIGHT', self.menu, 'BOTTOMRIGHT')
        e.LibDD:UIDropDownMenu_SetWidth(menu2, 60)
        e.LibDD:UIDropDownMenu_SetText(menu2, e.onlyChinese and '好友' or FRIEND)
        e.LibDD:UIDropDownMenu_Initialize(menu2, function(_, level)
            local map=e.GetUnitMapName('player');--玩家区域名称
            local inviteTab={}
            for index = 1, C_Calendar.GetNumInvites() do
                local inviteInfo = C_Calendar.EventGetInvite(index);
                if inviteInfo and inviteInfo.name then
                    inviteTab[inviteInfo.name]= true
                end
            end
            local find
            for i=1 , C_FriendList.GetNumFriends() do
                local game=C_FriendList.GetFriendInfoByIndex(i)
                if game and game.name and not inviteTab[game.name] then--and not game.afk and not game.dnd then
                    local text=e.GetPlayerInfo({guid=game.guid, name=game.name,  reName=true, reRealm=true})--角色信息
                    text= (game.level and game.level~=MAX_PLAYER_LEVEL and game.level>0) and text .. ' |cff00ff00'..game.level..'|r' or text--等级
                    if game.area and game.connected then
                        if game.area == map then--地区
                            text= text..'|A:poi-islands-table:0:0|a'
                        else
                            text= text..' |cnGREEN_FONT_COLOR:'..game.area..'|r'
                        end
                    elseif not game.connected then
                        text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                    end

                    local info={
                        text=text,
                        notCheckable= true,
                        tooltipOnButton=true,
                        tooltipTitle=game.notes,
                        icon= game.afk and FRIENDS_TEXTURE_AFK or game.dnd and FRIENDS_TEXTURE_DND,
                        arg1= game.name,
                        func=function(_, arg1)
                            CalendarCreateEventInviteEdit:SetText(arg1)
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    find=true
                end
            end
            if not find then
                e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
            end
        end)
        menu2.Button:SetScript('OnMouseDown', function(self2)
            e.LibDD:ToggleDropDownMenu(1, nil, self2:GetParent(), self2, 15, 0)
        end)

        local last=CreateFrame("Frame", nil, CalendarCreateEventFrame, "UIDropDownMenuTemplate")
        last:SetPoint('TOPRIGHT', menu2, 'BOTTOMRIGHT')
        e.LibDD:UIDropDownMenu_SetWidth(last, 60)
        e.LibDD:UIDropDownMenu_SetText(last, e.onlyChinese and '公会' or GUILD)
        e.LibDD:UIDropDownMenu_Initialize(last, function(_, level)
            local map=e.GetUnitMapName('player')
            local inviteTab={}
            for index = 1, C_Calendar.GetNumInvites() do
                local inviteInfo = C_Calendar.EventGetInvite(index);
                if inviteInfo and inviteInfo.name then
                    inviteTab[inviteInfo.name]= true
                end
            end
            local find
            for index=1,  GetNumGuildMembers() do
                local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
                if name and guid and not inviteTab[name] and isOnline and name~=e.Player.name_realm then
                    local text=e.GetPlayerInfo({guid=guid, name=name,  reName=true, reRealm=true})--名称
                    text=(lv and lv~=MAX_PLAYER_LEVEL and lv>0) and text..' |cnGREEN_FONT_COLOR:'..lv..'|r' or text--等级
                    if zone then--地区
                        text= zone==map and text..'|A:poi-islands-table:0:0|a' or text..' '..zone
                    end
                    text= rankName and text..' '..rankName..(rankIndex or '') or text
                    local info={
                        text=text,
                        notCheckable=true,
                        tooltipOnButton=true,
                        tooltipTitle=publicNote or '',
                        tooltipText=officerNote or '',
                        icon= status==1 and FRIENDS_TEXTURE_AFK or status==2 and FRIENDS_TEXTURE_DND,
                        arg1=name,
                        func=function(_, arg1)
                            CalendarCreateEventInviteEdit:SetText(arg1)
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    find=true
                end
            end
            if not find then
                e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
            end
        end)
        last.Button:SetScript('OnMouseDown', function(self2)
            e.LibDD:CloseDropDownMenus()
            e.LibDD:ToggleDropDownMenu(1, nil, self2:GetParent(), self2, 15, 0)
        end)
    end)
end

















panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            Initializer= e.AddPanel_Check_Button({
                checkName= '|A:GarrisonTroops-Health:0:0|a'..(e.onlyChinese and '节日' or addName),
                checkValue= not Save.disabled,
                checkFunc= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save.point=nil
                    if TrackButton then
                        TrackButton:ClearAllPoints()
                        TrackButton:set_Point()
                    end
                    print(id, Initializer:GetName(), e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= e.cn(addName),
                layout= nil,
                category= nil,
            })

            if  Save.disabled then
                panel:UnregisterAllEvents()
            else

                if not e.onlyChinese or LOCALE_zhCN or LOCALE_zhTW then
                    eventTab={}
                else
                    local tab= WoWToolsSave[BUG_CATEGORY15] or {disabled= not e.Player.husandro}
                    if tab.disabled then
                        eventTab={}
                    end
                end


                Calendar_LoadUI()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_Calendar' then
            Init_Blizzard_Calendar()--初始，插件
            Init_TrackButton()
            C_Timer.After(2, function()
                --[[e.call('Calendar_Toggle')
                C_Timer.After(2, function()
                    if CalendarFrame:IsShown() then
                        e.call('Calendar_Toggle')
                    end
                    Init_Blizzard_Calendar()--初始，插件
                    Init_TrackButton()
                end)]]
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
