
local function Save()
    return WoWToolsSave['Plus_Gossip']
end






--https://wago.io/hR_KBVGdK
local PlayerGossipTab = {
        [38054] = {icon=236722, cn='北风苔原', en='Borean Tundra', tw='北風凍原', de='Boreanische Tundra', es='Tundra Boreal', fr='Toundra Boréenne', it='Tundra Boreale', pt='Tundra Boreana', ru='Борейская тундра', ko='북풍의 땅'},--npc 35646
        [38055] = {icon=236781, cn='嚎风峡湾', en='Howling Fjord', tw='凜風峽灣', de='Der Heulende Fjord', es='Fiordo Aquilonal', fr='Fjord Hurlant', it='Fiordo Echeggiante', pt='Fiorde Uivante', ru='Ревущий фьорд', ko='울부짖는 협만'},
        [38056] = {icon=236817, cn='索拉查盆地', en='Sholazar Basin', tw='休拉薩盆地', de='Sholazarbecken', es='Cuenca de Sholazar', fr='Bassin de Sholazar', it='Bacino di Sholazar', pt='Bacia Sholazar', ru='Низина Шолазар', ko='숄라자르 분지'},
        [38057] = {icon=236795, cn='冰冠冰川', en='Icecrown', tw='寒冰皇冠', de='Eiskrone', es='Corona de Hielo', fr='La Couronne de glace', it='Corona di Ghiaccio', pt='Coroa de Gelo', ru='Ледяная Корона', ko='얼음왕관'},
        [38058] = {icon=236834, cn='风暴峭壁', en='The Storm Peaks', tw='風暴群山', de='Die Sturmgipfel', es='Las Cumbres Tormentosas', fr='Les pics Foudroyés', it='Cime Tempestose', pt='Picos Tempestuosos', ru='Грозовая гряда', ko='폭풍우 봉우리'},

        [42586] = {icon=1060981, cn='阿兰卡峰林', en='Spires of Arak', tw='阿拉卡山', de='Spitzen von Arak', es='Cumbres de Arak', fr='Flèches d’Arak', it='Guglie di Arakk', pt='Agulhas de Arak', ru='Пики Арака', ko='아라크 첨탑'},--81205
        [42587] = {icon=1060985, cn='塔拉多', en='Talador', tw='塔拉多爾', de='Talador', es='Talador', fr='Talador', it='Talador', pt='Talador', ru='Таладор', ko='탈라도르'},
        [42588] = {icon=1048304, cn='影月谷', en='Shadowmoon Valley', tw='影月谷', de='Schattenmondtal', es='Valle Sombraluna', fr='Vallée d’Ombrelune', it='Valle di Torvaluna', pt='Vale da Lua Negra', ru='Долина Призрачной Луны', ko='어둠달 골짜기'},
        [42589] = {icon=1032150, cn='纳格兰', en='Nagrand', tw='納葛蘭', de='Nagrand', es='', fr='Nagrand', it='Nagrand', pt='Nagrand', ru='Награнд', ko='나그란드'},
        [42590] = {icon=1046803, cn='戈尔隆德', en='Gorgrond', tw='格古隆德', de='Gorgrond', es='Gorgrond', fr='Gorgrond', it='Gorgrond', pt='Gorgrond', ru='Горгронд', ko='고르그론드'},
        [42591] = {icon=1031536, cn='霜火岭', en='Frostfire Ridge', tw='霜火峰', de='Frostfeuergrat', es='Cresta Fuego Glacial', fr='Crête de Givrefeu', it='Landa di Fuocogelo', pt='Serra Fogofrio', ru='Хребет Ледяного Огня', ko='서리불꽃 마루'},

        [44982] = {icon=1405803, cn='自动铁锤', en='Auto-Hammer', tw='自動鐵錘', de='Automatikhammer', es='Martillo automático', fr='Auto-marteau', it='Automartello', pt='Martelo Automático', ru='Автоматический молот', ko='자동 망치'},--101462
        [44983] = {icon=1405806, cn='故障检测晶塔', en='Failure Detection Pylon', tw='故障檢測塔', de='Fehlschlagdetektorpylon', es='Pilón detector de errores', fr='Pylône de détection des échecs', it='Pilone d\'Individuazione Fallimenti', pt='Pilar Detector de Falhas', ru='Пилон для обнаружения проблем', ko='고장 감지 변환기'},
        [44984] = {icon=134279, cn='烟火', en='Fireworks', tw='煙火', de='Feuerwerk', es='Fuegos artificiales', fr='Feux d’artifice', it='Fuochi d\'Artificio', pt='Fogos de Artifício', ru='Фейерверк', ko='불꽃놀이'},
        [44985] = {icon=351502, cn='点心桌', en='Snack Table', tw='小吃桌', de='Snacktisch', es='Mesa de merienda', fr='Table de collation', it='Tavolo per snack', pt='Mesa de lanche', ru='Пищевой', ko='스낵 테이블'},
        [44986] = {icon=134144, cn='布林顿6000', en='Blingtron 6000', tw='布靈頓 6000', de='Blingtron 6000', es='Joyatrón 6000', fr='Bling-o-tron 6000', it='Orotron 6000', pt='Blingtron 6000', ru='Блескотрон-6000', ko='블링트론 6000'},
        [44987] = {icon=2000841, cn='虫洞', en='Wormhole', tw='蟲洞', de='Wurmloch', es='Agujero de gusano', fr='Tunnel spatiotemporel', it='Tunnel Spaziotemporale', pt='Buraco de Minhoca', ru='Червоточина', ko='웜홀'},

        [46325] = {icon= 1408998, cn='阿苏纳', en='Azsuna', tw='艾蘇納', de='Azsuna', es='Azsuna', fr='Azsuna', it='Azsuna', pt='Азсуна', ru='Азсуна', ko='아즈스나'},
        [46326] = {icon= 1409010, cn='瓦尔莎拉', en='Val\'sharah', tw='維爾薩拉', de='Val\'sharah', es='Val\'sharah', fr='Val\'sharah', it='Val\'sharah', pt='Val\'sharah', ru='Валь\'шара', ko='발샤라'},
        [46327] = {icon= 1409000, cn='至高岭', en='Highmountain', tw='高嶺', de='Der Hochberg', es='Monte Alto', fr='Haut-Roc', it='Alto Monte', pt='Alta Montanha', ru='Крутогорье', ko='높은산'},
        [46328] = {icon= 1409001, cn='风暴峡湾', en='Stormheim', tw='斯鐸海姆', de='Sturmheim', es='Tormenheim', fr='Tornheim', it='Stromheim', pt='Trommheim', ru='Штормхейм', ko='스톰하임'},
        [46329] = {icon= 1409002, cn='苏拉玛', en='Suramar', tw='蘇拉瑪爾', de='Suramar', es='Suramar', fr='Suramar', it='Suramar', pt='Suramar', ru='Сурамар', ko='수라마르'},

        [51934] = {icon= 3847780, cn='奥利波斯', en='Oribos', tw='奧睿博司', de='Oribos', es='Oribos', fr='Oribos', it='Oribos', pt='Oribos', ru='Орибос', ko='오리보스'},
        [51935] = {icon= 3551337, cn='晋升堡垒', en='Bastion', tw='昇靈堡', de='Bastion', es='Bastión', fr='Le Bastion', it='Bastione', pt='Bastião', ru='Бастион', ko='승천의 보루'},
        [51936] = {icon= 3551338, cn='玛卓克萨斯', en='Maldraxxus', tw='瑪卓薩斯', de='Maldraxxus', es='Maldraxxus', fr='Maldraxxus', it='Maldraxxus', pt='Maldraxxus', ru='말드락서스', ko='말드락서스'},
        [51937] = {icon= 3551336, cn='炽蓝仙野', en='Ardenweald', tw='亞登曠野', de='', es='Ardenweald', fr='Sylvarden', it='Selvarden', pt='Ardena', ru='Арденвельд', ko='몽환숲'},
        [51938] = {icon= 3551339, cn='雷文德斯', mapID=1525},
        [51939] = {icon= 3257863, cn='噬渊', en='The Maw', tw='淵喉', de='Der Schlund', es='Las Fauces', fr='Antre', it='La Fauce', pt='A Gorja', ru='Утроба', ko='나락'},
        [51941] = {icon= 4066373, cn='刻希亚', en='Korthia', tw='科西亞', de='Korthia', es='Korthia', fr='Korthia', it='Korthia', pt='Korthia', ru='Кортия', ko='코르시아'},
        [51942] = {icon= 4226233, cn='扎雷殁提斯', mapID=1970},

        [63907] = {icon= 'lootroll-icon-need', cn='随机', en='Random', tw='隨機', de='Zufällig', es='Aleatorio', fr='Aléatoire', it='Casuale', pt='Aleatório', ru='Случайность', ko='무작위로'},
        [63911]  = {icon= 4672500, cn='觉醒海岸', mapID=2022},
        [63910]  = {icon= 4672498, cn='欧恩哈拉平原', mapID=2023},
        [63909]  = {icon= 4672495, cn='碧蓝林海', mapID=2024},
        [63908]  = {icon= 4672499, cn='索德拉苏斯', mapID=2025},
        [108016] = {icon= 4672496, cn='禁忌离岛', mapID=2151},
        [109715] = {icon= 5140838, cn='查拉雷克洞窟', mapID=2133},
        [114080] = {icon= 5390645, cn='翡翠梦境', mapID=2200},
    }










local GossipTextIcon={}--默认，自定义，对话，文本










local function Init_Data()
    GossipTextIcon={}

    if Save().not_Gossip_Text_Icon or Save().notGossipPlayerData then
        return
    end

    for gossipID, tab in pairs(PlayerGossipTab) do
        local name
        if WoWTools_DataMixin.onlyChinese then
            name= tab.cn
        elseif tab.mapID then
            local info = C_Map.GetMapInfo(tab.mapID) or {}
            name= info.name
        else
            name=(LOCALE_koKR and tab.ko)
                or (LOCALE_frFR and tab.fr)
                or (LOCALE_deDE and tab.de)
                or (LOCALE_esES and tab.es)
                or (LOCALE_zhTW and tab.tw)
                or (LOCALE_esMX and tab.es)
                or (LOCALE_ruRU and tab.ru)
                or (LOCALE_ptBR and tab.pt)
                or (LOCALE_itIT and tab.it)
                or tab.en
        end
        if name=='' or name==false then
            name= nil
        end
        if name then
            GossipTextIcon[gossipID]= {icon=tab.icon, name=name}
        end
    end

--数据在，汉化插件 WoWTools_Chinese
    if WoWTools_ChineseMixin_GossipTextData_Tabs then
        do
            for gossipID, tab in pairs(WoWTools_ChineseMixin_GossipTextData_Tabs) do
                if not GossipTextIcon[gossipID] and not Save().Gossip_Text_Icon_Player[gossipID] then
                    local hex= tab.hex and tab.hex~='' and tab.hex or nil
                    local icon= tab.icon and tab.icon~='' and tab.icon or nil
                    local name= tab.name and tab.name~='' and tab.name or nil

                    if hex or icon or name then
                        GossipTextIcon[gossipID]= {name=name, icon=icon, hex=hex}
                    end
                end
            end
        end
        WoWTools_ChineseMixin_GossipTextData_Tabs={}

        if WoWTools_DataMixin.Player.husandro then
            GossipFrameCloseButton.numText= WoWTools_LabelMixin:Create(GossipFrameCloseButton)
            GossipFrameCloseButton.numText:SetPoint('RIGHT', GossipFrameCloseButton, 'LEFT')
            hooksecurefunc(GossipOptionButtonMixin, 'Setup', function()
                local num=0
                for _, data in pairs(C_GossipInfo.GetOptions() or {}) do
                    if not GossipTextIcon[data.gossipOptionID] and not Save().Gossip_Text_Icon_Player[data.gossipOptionID] then
                        num=num+1
                    end
                end
                GossipFrameCloseButton.numText:SetText(num)
            end)
        end
    end


    PlayerGossipTab=nil
    Init_Data=function()end
end













local function Init_Menu(_, root)
    local List= _G['WoWToolsGossipTextIconOptionsList']
    if not List then
        return
    end

    local find=false
    for gossipID, tab in pairs(GossipTextIcon) do
        local icon= select(3, WoWTools_TextureMixin:IsAtlas(tab.icon)) or ''
        root:CreateCheckbox(
            icon
            ..'|c'..(tab.hex and tab.hex~='' and tab.hex or 'ffffffff')..(tab.name or '')..'|r '
            ..(Save().Gossip_Text_Icon_Player[gossipID] and '|cnGREEN_FONT_COLOR:' or '|cffffffff')
            ..gossipID,

        function(data)
            return List:get_gossipID()==data.gossipID

        end, function(data)
            List:set_date(data.gossipID)

        end, {gossipID=gossipID, tab=tab})

        find=true
    end

    if find then
        WoWTools_MenuMixin:SetScrollMode(root)
    else
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '无' or NONE)
    end
end













function WoWTools_GossipMixin:Init_Gossip_Data()
    Init_Data()
end



function WoWTools_GossipMixin:GossipData_Menu(frame)
    MenuUtil.CreateContextMenu(frame, function(...)
        Init_Menu(...)
    end)
end



function WoWTools_GossipMixin:Get_GossipData()
    return GossipTextIcon
end