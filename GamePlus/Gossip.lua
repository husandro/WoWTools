local id, e = ...
local addName=format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENABLE_DIALOG, QUESTS_LABEL)
local Save={
        NPC={},

        gossip= true,
        unique= true,--唯一对话
        gossipOption={},----{gossipID= text}
        choice={},--PlayerChoiceFrame
        movie={},--电影
        stopMovie=true,--如果已播放，停止播放

        quest= true,
        questOption={},
        questRewardCheck={},--{任务ID= index}
        autoSortQuest= e.Player.husandro,--仅显示当前地图任务
        autoSelectReward= e.Player.husandro,--自动选择奖励
        showAllQuestNum= e.Player.husandro,--显示所有任务数量

        --scale=1,
        --point=nil,

        --not_Gossip_Text_Icon=true,--自定义，对话，文本
        Gossip_Text_Icon_Player={--玩家，自定义，对话，文本
            [55193]={
                icon='communities-icon-invitemail',
                name=(e.Player.husandro and '打开邮件' or OPENMAIL),
                hex='ffff00ff'}
        },
        Gossip_Text_Icon_Size=22,

}


local GossipButton
local QuestButton


























local GossipTextIcon={}--默认，自定义，对话，文本
local function Init_Gossip_Text(show)
    GossipTextIcon={}
    if Save.not_Gossip_Text_Icon then
        return
    end
    --[[local find--工程
    if show then
        find=true
    else
        

        for _, type in pairs({GetProfessions()}) do
     
            local spelloffset = select(6, GetProfessionInfo(type))
            local spellID= select(7, GetSpellInfo(spelloffset+ 1, 'spell'))
            if spellID==158739 then
                find=true
                break
            end
            
        end
    end
    if find then]]
        local tabs = {--https://wago.io/hR_KBVGdK
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
        for gossipID, tab in pairs(tabs) do
            local name
            if e.onlyChinese then
                name= tab.cn
            elseif tab.mapID then
                local info = C_Map.GetMapInfo(tab.mapID) or {}
                name= info.name
            else
                name=(LOCALE_enUS and tab.en)
                    or (LOCALE_koKR and tab.ko)
                    or (LOCALE_frFR and tab.fr)
                    or (LOCALE_deDE and tab.de)
                    or (LOCALE_esES and tab.es)
                    or (LOCALE_zhTW and tab.tw)
                    or (LOCALE_esMX and tab.es)
                    or (LOCALE_ruRU and tab.ru)
                    or (LOCALE_ptBR and tab.pt)
                    or (LOCALE_itIT and tab.it)
            end
            if name=='' or name==false then
                name= nil
            end
            if name or (texture or atlas) then
                GossipTextIcon[gossipID]= {icon=tab.icon, name=name}
            end
        end
        tabs=nil
    --end
end








--自定义，对话，文本
local function Set_Gossip_Text(info)
    local gossipOptionID= info and info.gossipOptionID
    if not Save.gossip or Save.not_Gossip_Text_Icon or not gossipOptionID or not info.name then
        return
    end
    local zoneInfo= Save.Gossip_Text_Icon_Player[gossipOptionID] or GossipTextIcon[gossipOptionID]
    if not zoneInfo then
        local text= e.strText[info.name]
        if text then
            info.name=text
        end
    else
        local icon
        local name
        if zoneInfo.icon then
            local isAtlas, texture= e.IsAtlas(zoneInfo.icon)
            if isAtlas then
                icon= format('|A:%s:%d:%d|a', texture, Save.Gossip_Text_Icon_Size, Save.Gossip_Text_Icon_Size)
            else
                icon= format('|T%s:%d|t', texture, Save.Gossip_Text_Icon_Size)
            end
        end
        name= zoneInfo.name
        if zoneInfo.hex then
            name= '|c'..zoneInfo.hex..(name or info.name)..'|r'
        end
        if icon or name then
            info.name= format('%s%s', icon or '', name or '')
        end
    end
end


















local function select_Reward(questID)--自动:选择奖励
    local numQuests = GetNumQuestChoices() or 0
    if numQuests <2 then
        local frame=_G['QuestInfoRewardsFrameQuestInfoItem1']
        if frame and frame.check then
            frame.check:SetShown(false)
        end
        return
    end

    local bestValue, bestLevel= 0, 0
    local notColleced, upItem, selectItemLink, bestItem

    for i = 1, numQuests do
        local frame= _G['QuestInfoRewardsFrameQuestInfoItem'..i]
        if frame and questID then
            if not frame.check then
                frame.check=CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
                frame.check:SetPoint("TOPRIGHT")
                frame.check:SetScript('OnClick', function(self)
                    if self.questID and self.index then
                        if Save.questRewardCheck[self.questID] and Save.questRewardCheck[self.questID]==self.index then
                            Save.questRewardCheck[self.questID]=nil
                        else
                            Save.questRewardCheck[self.questID]=self.index
                        end
                        for index=1, numQuests do
                            local frame2=  _G['QuestInfoRewardsFrameQuestInfoItem'..index]
                            if frame2 and frame2.check then
                                if index==self.index then
                                    if Save.questRewardCheck[self.questID] then
                                        frame2:Click()
                                        CompleteQuest()
                                    end
                                else
                                    frame2.check:SetChecked(false)
                                end
                            end
                        end
                    end
                end)
                frame.check:SetScript('OnEnter', function(self)
                    if self.questID then
                        e.tips:SetOwner(self, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine('questID: |cnGREEN_FONT_COLOR:'..self.questID..'|r', self.index)
                        e.tips:AddDoubleLine(id, e.onlyChinese and '任务' or QUESTS_LABEL)
                        e.tips:Show()
                    end
                end)
                frame.check:SetScript('OnLeave', GameTooltip_Hide)
            end
            frame.check:SetChecked(Save.questRewardCheck[questID] and Save.questRewardCheck[questID]==i)
            frame.check.index= i
            frame.check.questID= questID
            frame.check.numQuests= numQuests
            frame.check:SetShown(true)
        end
    end

    if Save.questRewardCheck[questID] and Save.questRewardCheck[questID]<=numQuests then
        bestItem= Save.questRewardCheck[questID]
        selectItemLink= GetQuestItemLink('choice', Save.questRewardCheck[questID])
        e.LoadDate({id=selectItemLink, type='item'})
    else
        for i = 1, numQuests do
            local  itemLink = GetQuestItemLink('choice', i)
            e.LoadDate({id=itemLink, type='item'})
            if itemLink then
                local amount = select(3, GetQuestItemInfo('choice', i))--钱
                local _, _, itemQuality, itemLevel, _, _,_,_, itemEquipLoc, _, sellPrice,classID, subclassID = GetItemInfo(itemLink)
                if Save.autoSelectReward and not(classID==19 or (classID==4 and subclassID==5) or itemLevel==1) and itemQuality and itemQuality<4 and IsEquippableItem(itemLink) then--最高 稀有的 3                                
                    local invSlot = itemEquipLoc and  e.itemSlotTable[itemEquipLoc]
                    if invSlot and itemLevel and itemLevel>1 then--装等
                        local itemLinkPlayer = GetInventoryItemLink('player', invSlot)
                        if itemLinkPlayer then
                            local lv=GetDetailedItemLevelInfo(itemLinkPlayer)
                            if lv and lv>1 and itemLevel-lv>0 and (bestLevel and bestLevel<lv or not bestLevel) then
                                bestLevel=lv
                                bestItem = i
                                selectItemLink=itemLink
                                upItem=true
                            end
                        end
                    end

                    if not upItem then
                        local isCollected, isSelf= select(2, e.GetItemCollected(itemLink))--物品是否收集 
                        if isCollected==false and isSelf then
                            bestItem = i
                            selectItemLink=itemLink
                            notColleced=true
                        end
                    end

                    if not (notColleced and upItem) and amount and sellPrice then
                        local totalValue = (sellPrice and sellPrice * amount) or 0
                        if totalValue > bestValue then
                            bestValue = totalValue
                            bestItem = i
                            selectItemLink=itemLink
                        end
                    end
                end
            end
        end
    end
    if bestItem and not IsModifierKeyDown() then
        _G['QuestInfoRewardsFrameQuestInfoItem'..bestItem]:Click()--QuestFrame.lua
        if selectItemLink then
            print(id, e.onlyChinese and '任务' or QUESTS_LABEL, '|cffff00ff'..CHOOSE..'|r', selectItemLink)
        end
    end
end
















































--自定义，对话，文本，放在主菜单，前
local Gossip_Text_Icon_Frame
local function Init_Gossip_Text_Icon_Options()
    if Gossip_Text_Icon_Frame then
        Gossip_Text_Icon_Frame:SetShown(not Gossip_Text_Icon_Frame:IsShown())
        return
    end


    Gossip_Text_Icon_Frame= CreateFrame('Frame', 'Gossip_Text_Icon_Frame', UIParent)--, 'DialogBorderTemplate')--'ButtonFrameTemplate')
    Gossip_Text_Icon_Frame:SetSize(580, 370)
    Gossip_Text_Icon_Frame:SetFrameStrata('HIGH')
    Gossip_Text_Icon_Frame:SetPoint('CENTER')
    Gossip_Text_Icon_Frame:SetScript('OnHide', function()
        if GossipFrame:IsShown() then
            GossipFrame:Update()
        end
    end)
    Gossip_Text_Icon_Frame:SetScript('OnShow', function()
        if GossipFrame:IsShown() then
            GossipFrame:Update()
        end
    end)

    local border= CreateFrame('Frame', nil, Gossip_Text_Icon_Frame,'DialogBorderTemplate')
    local Header= CreateFrame('Frame', nil, Gossip_Text_Icon_Frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    Header:Setup('|A:SpecDial_LastPip_BorderGlow:0:0|a'..(e.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE)))
    local CloseButton=CreateFrame('Button', nil, Gossip_Text_Icon_Frame, 'UIPanelCloseButton')
    CloseButton:SetPoint('TOPRIGHT')

    e.Set_Alpha_Frame_Texture(border, {alpha=0.5})
    e.Set_Alpha_Frame_Texture(Header, {alpha=0.7})
    e.Set_Move_Frame(Gossip_Text_Icon_Frame, {setMove=true, minW=400, minH=200, notFuori=true, setSize=true, sizeRestFunc=function(btn)
        btn.target:SetSize(580, 370)
    end})


    local menu = CreateFrame("Frame", nil, Gossip_Text_Icon_Frame, "WowScrollBoxList")
    menu:SetPoint("TOPLEFT", 12, -30)
    menu:SetPoint("BOTTOMRIGHT", -310,12)
    Gossip_Text_Icon_Frame.menu= menu

    menu.ScrollBar  = CreateFrame("EventFrame", nil, Gossip_Text_Icon_Frame, "MinimalScrollBar")
    menu.ScrollBar:SetPoint("TOPLEFT", menu, "TOPRIGHT", 2,0)
    menu.ScrollBar:SetPoint("BOTTOMLEFT", menu, "BOTTOMRIGHT",2,0)
    
    menu.ScrollView = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(menu, menu.ScrollBar, menu.ScrollView)
-- ChannelRosterButtonTemplate LFGListApplicantMemberTemplate
    menu.ScrollView:SetElementInitializer("UIPanelButtonTemplate", function(btn, info)
        btn.gossipID= info.gossipID
        --btn.icon= info.icon
        --btn.name= info.name
        --btn.hex= info.hex
        btn:SetScript("OnClick", function(self)
            Gossip_Text_Icon_Frame.menu:set_date(self.gossipID)
        end)
        local icon
        local isAtlas, texture= e.IsAtlas(info.icon)
        if texture then
            icon= isAtlas and ('|A:'..texture..':0:0|a') or ('|T'..texture..':0|t')
        end
        btn:SetFormattedText('%s|c%s%s|r', icon or '', info.hex or 'ffffffff', info.name or '')
    end)

    function menu:set_list()
        self.dataProvider = CreateDataProvider()
        for gossipID, data in pairs(Save.Gossip_Text_Icon_Player) do
            self.dataProvider:Insert({gossipID=gossipID, icon=data.icon, name=data.name, hex=data.hex})
        end
        menu.ScrollView:SetDataProvider(self.dataProvider,  ScrollBoxConstants.RetainScrollPosition)
    end
    menu:set_list()
    

    function menu:get_gossipID()--取得gossipID
        return self.ID:GetNumber() or 0
    end
    function menu:get_name()--取得，名称
        local name= self.Name:GetText()
        if name=='' then
            return
        else
            return name
        end
    end
    function menu:get_icon()--设置，图片
        local isAtlas, texture= e.IsAtlas(self.Icon:GetText())
        return texture, isAtlas
    end
    function menu:set_texture_size()--图片，大小
        self.Texture:SetSize(Save.Gossip_Text_Icon_Size, Save.Gossip_Text_Icon_Size)
    end
    function menu:set_numlabel_text()--自定义，数量
        local n= 0
        for _ in pairs(Save.Gossip_Text_Icon_Player) do
            n=n+1
        end
        self.NumLabel:SetText(n)
    end

    function menu:set_all()
        local num= self:get_gossipID()
        local name= self:get_name()
        local icon= self:get_icon()
        local info= Save.Gossip_Text_Icon_Player[num]
        if info then
            self.gossipID=num
        else
            self.gossipID=nil
        end

        --local gossipID= self.gossipID
        --[[local text=''
        local info= gossipID and Save.Gossip_Text_Icon_Player[gossipID]
        if info then
            local icon=''
            local isAtlas, texture= e.IsAtlas(info.icon)
            if texture then
                icon= isAtlas and ('|A:'..texture..':0:0|a') or ('|T'..texture..':0|t')
            end
            text= gossipID..' '..icon..'|c'..(info.hex or 'ffffffff')..(info.name or '')..'|r'
        end
        self:SetText(text)]]
        --e.LibDD:UIDropDownMenu_SetText(self, text)--设置，菜单，文本

        local hex = self.Color.hex or 'ffffffff'
        if info then
            if info.icon==icon and info.name==name and (info.hex==hex or (not info.hex and hex=='ffffffff')) then--一样，数据
                self.Add:SetNormalAtlas(e.Icon.select)
            else--需要，更新，数据
                self.Add:SetNormalAtlas('bags-greenarrow')
            end
        else
            self.Add:SetNormalAtlas('bags-icon-addslots')
        end
        self.Delete:SetShown(self.gossipID and true or false)--显示/隐藏，删除按钮
        self.Add:SetShown(num>0 and (name or icon))--显示/隐藏，添加按钮


    end

    function menu:set_color(r, g, b, hex)--设置，颜色，颜色按钮，
        if hex then
            r,g,b= e.HEX_to_RGB(hex)
        elseif r and g and b then
            hex= e.RGB_to_HEX(r,g,b)
        else
            r,g,b,hex= 1,1,1, 'ffffffff'
        end
        self.Color.r, self.Color.g, self.Color.b, self.Color.hex= r, g, b, hex
        self.Color.Color:SetVertexColor(r,g,b,1)
        self:set_all()
    end

    function menu:get_saved_all_date(gossipID)
        return Save.Gossip_Text_Icon_Player[gossipID] or GossipTextIcon[gossipID]
    end
    function menu:set_date(gossipID)--读取，已保存数据
        if not gossipID then
            return
        end
        local name,icon,hex, name2, info
        for _, info in pairs(C_GossipInfo.GetOptions() or {}) do
            if info.gossipOptionID==gossipID then
                name2= info.name
                break
            end
        end
        info= self:get_saved_all_date(gossipID)
        if info then
            name, icon, hex= info.name, info.icon, info.hex
        end
        name= name or name2 or Save.gossipOption[gossipID] or ''
        self.ID:SetNumber(gossipID)
        self.Name:SetText(name)
        self.Icon:SetText(icon or '')
        self:set_color(nil, nil, nil, hex)
        self.GossipText:SetText(name2 or name)
    end


    function menu:add_gossip()
        if not self.Add:IsShown() then
            return
        end
        local num= self:get_gossipID()
        local texture = self:get_icon()
        local name= self:get_name()

        local r= self.Color.r or 1
        local g= self.Color.g or 1
        local b= self.Color.b or 1
        local hex
        if r~=1 and g~=1 or b~=1 then
            hex= e.RGB_to_HEX(r, g, b, 1)
        end
        if num and (name or texture) then
            Save.Gossip_Text_Icon_Player[num]= {
                name= name,
                icon= texture,
                hex= hex,
            }
            self.gossipID= num
            if GossipFrame:IsShown() then
                GossipFrame:Update()
            end
            self:set_list()
        end

        self:set_all()
        self:set_numlabel_text()
        local icon
        local isAtlas, texture= e.IsAtlas(texture)
        if texture then
            if isAtlas then
                icon= '|A:'..texture..':0:0|a'
            else
                icon= '|T'..texture..':0|t'
            end
        end
        print(id, addName, '|cnGREEN_FONT_COLOR:'..num..'|r', icon or '', '|c'..(hex or 'ffffffff'), name)
    end

    function menu:delete_gossip()
        local gossipID= self.gossipID
        if gossipID and Save.Gossip_Text_Icon_Player[gossipID] then
            local info=Save.Gossip_Text_Icon_Player[gossipID]
            Save.Gossip_Text_Icon_Player[gossipID]=nil
            print(id, addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE)..'|r|n', gossipID, info.icon, info.hex, info.name)
            self:set_list()
            if GossipFrame:IsShown() then
                GossipFrame:Update()
            end
        end
        --e.LibDD:UIDropDownMenu_SetText(self, '')
        self:set_all()
        self:set_numlabel_text()
    end


    menu.ID= CreateFrame("EditBox", nil, Gossip_Text_Icon_Frame, 'SearchBoxTemplate')
    menu.ID:SetSize(234, 22)
    menu.ID:SetNumeric(true)
    menu.ID:SetPoint('TOPLEFT', menu, 'TOPRIGHT', 25, -40)
    menu.ID:SetAutoFocus(false)
    menu.ID.Instructions:SetText('gossipOptionID '..(e.onlyChinese and '数字' or 'Numeri'))
    menu.ID.searchIcon:SetAtlas('auctionhouse-icon-favorite')
    menu.ID:HookScript("OnTextChanged", function(self) self:GetParent().menu:set_all() end)

    menu.Name= CreateFrame("EditBox", nil, Gossip_Text_Icon_Frame, 'SearchBoxTemplate')
    menu.Name:SetPoint('TOPLEFT', menu.ID, 'BOTTOMLEFT')
    menu.Name:SetSize(250, 22)
    menu.Name:SetAutoFocus(false)
    menu.Name:ClearFocus()
    menu.Name.Instructions:SetText(e.onlyChinese and '替换文本', format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REPLACE, LOCALE_TEXT_LABEL))
    menu.Name.searchIcon:SetAtlas('NPE_ArrowRight')
    menu.Name:HookScript("OnTextChanged", function(self) self:GetParent().menu:set_all() end)

    menu.Icon= CreateFrame("EditBox", nil, Gossip_Text_Icon_Frame, 'SearchBoxTemplate')
    menu.Icon:SetPoint('TOPLEFT', menu.Name, 'BOTTOMLEFT')
    menu.Icon:SetSize(250, 22)
    menu.Icon:SetAutoFocus(false)
    menu.Icon:ClearFocus()
    menu.Icon.Instructions:SetText((e.onlyChinese and '图标' or EMBLEM_SYMBOL)..' Texture or Atlas')
    menu.Icon.searchIcon:SetAtlas('NPE_ArrowRight')
    menu.Icon:HookScript("OnTextChanged", function(self)
        local frame= self:GetParent().menu
        local texture, isAtlas = frame:get_icon()
        if isAtlas and texture then
            frame.Texture:SetAtlas(texture)
        else
            frame.Texture:SetTexture(texture or 0)
        end
        frame:set_all()
    end)

    --设置，TAB键
    menu.tabGroup= CreateTabGroup(menu.ID, menu.Name, menu.Icon)
    menu.ID:SetScript('OnTabPressed', function(self) self:GetParent().tabGroup:OnTabPressed() end)
    menu.Icon:SetScript('OnTabPressed', function(self) self:GetParent().tabGroup:OnTabPressed() end)
    menu.Name:SetScript('OnTabPressed', function(self) self:GetParent().tabGroup:OnTabPressed() end)

    --设置，Enter键
    menu.ID:SetScript('OnEnterPressed', function(self)  self:GetParent():add_gossip() end)
    menu.Icon:SetScript('OnEnterPressed', function(self) self:GetParent():add_gossip() end)
    menu.Name:SetScript('OnEnterPressed', function(self) self:GetParent():add_gossip() end)

    --自定义，对话，文本，数量
    menu.NumLabel= e.Cstr(Gossip_Text_Icon_Frame, {justifyH='RIGHT'})
    menu.NumLabel:SetPoint('BOTTOM', menu, 'TOP', 0, 4)
    menu:set_numlabel_text()

    --图标
    menu.Texture= Gossip_Text_Icon_Frame:CreateTexture()
    menu.Texture:SetPoint('BOTTOM', menu.ID, 'TOP' , 0, 2)
    menu:set_texture_size()

    --对话，内容
    menu.GossipText= e.Cstr(Gossip_Text_Icon_Frame)
    menu.GossipText:SetPoint('TOP', menu.Icon, 'BOTTOM', 0,-2)

    --查找，图标，按钮
    menu.FindIcon= e.Cbtn(Gossip_Text_Icon_Frame, {size={22,22}, atlas='mechagon-projects'})
    menu.FindIcon:SetPoint('LEFT', menu.Icon, 'RIGHT', 2,0)
    menu.FindIcon:SetScript('OnLeave', GameTooltip_Hide)
    menu.FindIcon:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:AddLine(e.onlyChinese and '点击在列表中浏览' or ICON_SELECTION_CLICK)
        if not _G['TAV_CoreFrame'] then
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('|cnRED_FONT_COLOR:Texture Atlas Viewer', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)
        end
        e.tips:Show()
    end)
    menu.FindIcon:SetScript('OnClick', function(f)
        if not f.frame then
            f.frame= CreateFrame('Frame', 'Gossip_Text_Icon_Frame_IconSelectorPopupFrame', Gossip_Text_Icon_Frame, 'IconSelectorPopupFrameTemplate')
            f.frame.IconSelector:SetPoint('BOTTOMRIGHT', -10, 36)
            e.Set_Move_Frame(f.frame, {notMove=true, setSize=true, minW=524, minH=276, maxW=524, sizeRestFunc=function(btn)
                btn.target:SetSize(524, 495)
            end})


            f.frame:Hide()
            f.frame.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(e.onlyChinese and '点击在列表中浏览' or ICON_SELECTION_CLICK)
            f.frame.BorderBox.IconSelectorEditBox:SetAutoFocus(false)
            f.frame:SetScript('OnShow', function(self)
                IconSelectorPopupFrameTemplateMixin.OnShow(self);
                if self.iconDataProvider==nil then
                    self.iconDataProvider= CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.None)
                end
                self.BorderBox.IconTypeDropDown:SetSelectedValue(self.BorderBox.IconTypeDropDown:GetSelectedValue() or IconSelectorPopupFrameIconFilterTypes.All);
                self:Update()
                self.BorderBox.IconSelectorEditBox:OnTextChanged()
                local function OnIconSelected(_, icon)
                    self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);
                    self.BorderBox.IconSelectorEditBox:SetText(icon)
                end
               self.IconSelector:SetSelectedCallback(OnIconSelected);
            end)

            f.frame:SetScript('OnHide', function(self)
                IconSelectorPopupFrameTemplateMixin.OnHide(self);
                self.iconDataProvider:Release();
                self.iconDataProvider = nil;
            end)
            function f.frame:Update()
                local texture
                texture= Gossip_Text_Icon_Frame.menu:get_icon()
                if texture then
                    texture=tonumber(texture)
                end
                if not texture then
                    self.origName = "";
                    self.BorderBox.IconSelectorEditBox:SetText("");
                    local initialIndex = 1;
                    self.IconSelector:SetSelectedIndex(initialIndex);
                    self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self:GetIconByIndex(initialIndex));
                else
                    self.BorderBox.IconSelectorEditBox:SetText(texture);
                    self.BorderBox.IconSelectorEditBox:HighlightText();
                    self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(texture));
                    self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(texture);
                end
                local getSelection = GenerateClosure(self.GetIconByIndex, self);
                local getNumSelections = GenerateClosure(self.GetNumIcons, self);
                self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections);
                self.IconSelector:ScrollToSelectedIndex();
                self:SetSelectedIconText();
            end
            function f.frame:OkayButton_OnClick()
                IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self);
                local iconTexture = self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture();
                local m= Gossip_Text_Icon_Frame.menu
                m.Icon:SetText(iconTexture or '')
                local gossip= m:get_gossipID()
                if gossip==0 then
                    m.ID:SetFocus()
                else
                    m.Name:SetFocus()
                end
            end
        end
        if f.frame:IsShown() then
            f.frame:Hide()
        end
        f.frame:SetShown(true)
    end)
    if _G['TAV_CoreFrame'] then--查找，图标，按钮， Texture Atlas Viewer， 插件
        menu.tav= e.Cbtn(Gossip_Text_Icon_Frame, {size={22,22}, atlas='communities-icon-searchmagnifyingglass'})
        menu.tav:SetPoint('TOP', menu.FindIcon, 'BOTTOM', 0, -2)
        menu.tav:SetScript('OnClick', function() _G['TAV_CoreFrame']:SetShown(not _G['TAV_CoreFrame']:IsShown()) end)
        menu.tav:SetScript('OnLeave', GameTooltip_Hide)
        menu.tav:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, self.addName)
            e.tips:AddLine(' ')
            e.tips:AddLine('|cffff00ffTexture Atlas Viewer|r')
            e.tips:Show()
        end)
    end

    --颜色
    menu.Color= CreateFrame('Button', nil, Gossip_Text_Icon_Frame, 'ColorSwatchTemplate')--ColorSwatchMixin
    menu.Color:SetPoint('LEFT', menu.ID, 'RIGHT', 2,0)
    menu.Color:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    menu.Color:SetScript('OnLeave', GameTooltip_Hide)
    menu.Color:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id , e.cn(addName))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COLOR), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '默认' or DEFAULT, e.Icon.right)
        e.tips:Show()
    end)
    menu.Color:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            local R=self.r or 1
            local G=self.g or 1
            local B=self.b or 1
            e.ShowColorPicker(R, G, B, nil,
            function()--swatchFunc
                local r,g,b = e.Get_ColorFrame_RGBA()
                Gossip_Text_Icon_Frame.menu:set_color(r,g,b)
            end,
            function()--cancelFunc
                Gossip_Text_Icon_Frame.menu:set_color(R,G,B)
            end)
        else
            self.r, self.g, self.b=1,1,1
            Gossip_Text_Icon_Frame.menu:set_all()
        end
    end)

    --添加
    menu.Add= e.Cbtn(Gossip_Text_Icon_Frame, {size={22,22}, icon='hide'})
    menu.Add:SetPoint('LEFT', menu.Color, 'RIGHT', 2, 0)
    menu.Add:SetScript('OnLeave', GameTooltip_Hide)
    menu.Add:SetScript('OnEnter', function(self)
        local num= Gossip_Text_Icon_Frame.menu:get_gossipID()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id , e.cn(addName))
        e.tips:AddLine(' ')
        e.tips:AddLine(Save.Gossip_Text_Icon_Player[num] and '|cffff00ff'..(e.onlyChinese and '修改' or EQUIPMENT_SET_EDIT)..'|r' or ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD))..'|r')
        e.tips:Show()
    end)
    menu.Add:SetScript('OnClick', function(self)
        self:GetParent().menu:add_gossip()
    end)

    --删除，内容
    menu.Delete= e.Cbtn(Gossip_Text_Icon_Frame, {size={22,22}, atlas='common-icon-redx'})
    menu.Delete:SetPoint('BOTTOM', menu.Add, 'TOP', 0,2)
    menu.Delete:Hide()
    menu.Delete:SetScript('OnLeave', GameTooltip_Hide)
    menu.Delete:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, self.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '删除' or DELETE, Gossip_Text_Icon_Frame.menu.gossipID)
        e.tips:Show()
    end)
    menu.Delete:SetScript('OnClick', function(self)
        self:GetParent().menu:delete_gossip()
    end)

    

    --图标大小, 设置
    menu.Size= e.CSlider(Gossip_Text_Icon_Frame, {min=8, max=72, value=Save.Gossip_Text_Icon_Size, setp=1, color=false, w=255,
        text= e.onlyChinese and '图标大小' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        func=function(frame, value)
            value= math.modf(value)
            value= value==0 and 0 or value
            frame:SetValue(value)
            frame.Text:SetText(value)
            Save.Gossip_Text_Icon_Size= value
            local f= frame:GetParent().menu
            f:set_texture_size()
            local icon= f.Texture:GetTexture()--设置，图片，如果没有
            if not icon or icon==0 then
                f.Texture:SetTexture(3847780)
            end
            if GossipFrame:IsShown() then
                GossipFrame:Update()
            end
    end})
    menu.Size:SetPoint('TOP', menu.Icon, 'BOTTOM', 0, -36)

    --已打开，对话，列表
    menu.chat= e.Cbtn(Gossip_Text_Icon_Frame, {size={22, 22}, atlas='transmog-icon-chat'})
    menu.chat:SetPoint('LEFT', menu.Name, 'RIGHT', 2, 0)
    menu.chat:SetScript('OnClick', function(self)
        if not self.Menu then
            self.Menu= CreateFrame("Frame", nil, Gossip_Text_Icon_Frame.menu, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)
                local tab= C_GossipInfo.GetOptions() or {}
                table.sort(tab, function(a, b) return a.orderIndex< b.orderIndex end)
                local f= Gossip_Text_Icon_Frame.menu
                for _, info in pairs(tab) do
                    if info.gossipOptionID then
                        local set= Gossip_Text_Icon_Frame.menu:get_saved_all_date(info.gossipOptionID) or {}
                        local name= set.name or info.name or ''
                        local icon= set.icon or info.icon
                        local hex= set.hex
                        e.LibDD:UIDropDownMenu_AddButton({
                            text= name..info.gossipOptionID,
                            checked= info.gossipOptionID== Gossip_Text_Icon_Frame.menu:get_gossipID(),
                            colorCode= hex and '|c'..hex or (GossipTextIcon[info.gossipOptionID] and '|cnGREEN_FONT_COLOR:') or (Save.Gossip_Text_Icon_Player[info.gossipOptionID] and '|cffff00ff') or nil,
                            icon= icon,
                            tooltipOnButton=true,
                            tooltipTitle=info.gossipOptionID,
                            arg1=info.gossipOptionID,
                            func= function(_, arg1)
                                f:set_date(arg1)
                            end
                        }, level)
                    end
                end
            end, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
    end)
    menu.chat:SetShown(GossipFrame:IsShown())
    GossipFrame:HookScript('OnShow', function()--已打开，对话，列表
        Gossip_Text_Icon_Frame.menu.chat:SetShown(true)
    end)
    GossipFrame:HookScript('OnHide', function()
        Gossip_Text_Icon_Frame.menu.chat:SetShown(false)
    end)

    --默认，自定义，列表
    menu.System= e.Cbtn(Gossip_Text_Icon_Frame, {size={20, 20}, icon=true})
    menu.System:SetPoint('BOTTOMRIGHT', menu.ID, 'TOPRIGHT', 0, 2)
    menu.System:SetScript('OnLeave', GameTooltip_Hide)
    menu.System:SetScript('OnEnter', function(self)
        local n=0
        for _ in pairs(GossipTextIcon) do
            n= n+1
        end
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id , e.cn(addName))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((n>0 and '|cnGREEN_FONT_COLOR:' or '')..'#'..n, e.onlyChinese and '默认' or DEFAULT)
        e.tips:Show()
    end)
    menu.System:SetScript('OnClick', function(self)
        if not self.Menu then
            Init_Gossip_Text(true)
            self.Menu = CreateFrame("FRAME", nil, self, "UIDropDownMenuTemplate")--下拉，菜单
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)
                local find, info
                local f= Gossip_Text_Icon_Frame.menu
                local num= f:get_gossipID()
                for gossipID, tab in pairs(GossipTextIcon) do
                    info={
                        text=(num==gossipID and '|cnGREEN_FONT_COLOR:' or '|cffffffff')..gossipID..'|r |c'..(tab.hex or 'ffffffff')..(tab.name or '')..'|r',
                        icon= tab.icon,
                        checked=num==gossipID,
                        arg1= gossipID,
                        func= function(_, arg1)
                            f:set_date(arg1)--读取，已保存数据
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    find=true
                end
                if not find then
                    e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
                end
            end, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)
    
    --菜单
    --[[e.LibDD:UIDropDownMenu_Initialize(menu, function(self, level)
        local find, info
        local num= self:get_gossipID()
        for gossipID, tab in pairs(Save.Gossip_Text_Icon_Player) do
            info={
                text=(num==gossipID and '|cnGREEN_FONT_COLOR:' or '|cffffffff')..gossipID..'|r |c'..(tab.hex or 'ffffffff')..(tab.name or '')..'|r',
                icon= tab.icon,
                checked=num==gossipID,
                arg1= gossipID,
                func= function(_, arg1)
                    self:set_date(arg1)--读取，已保存数据
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            find=true
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
    end)
    menu.Text:SetScript('OnMouseDown', function(self)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15,0)
    end)
    menu.Button:SetScript('OnMouseDown', function(self)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15,0)
    end)
    menu.Text:SetTextColor(1,1,1,1)]]

    







end



























--###########
--对话，主菜单
--###########
local function Init_Menu_Gossip(_, level, type)
    local info
    if type=='OPTIONS' then
        info={
            text= e.onlyChinese and '重置位置' or RESET_POSITION,
            notCheckable=true,
            colorCode=not Save.point and '|cff606060',
            keepShownOnClick=true,
            func= function()
                Save.point=nil
                GossipButton:ClearAllPoints()
                GossipButton:set_Point()
                print(id, e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '恢复默认设置' or RESET_TO_DEFAULT,
            notCheckable=true,
            keepShownOnClick=true,
            func= function()
                StaticPopupDialogs[id..addName..'RESET_TO_DEFAULT']={
                    text=id..' '..e.cn(addName)..'|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '恢复默认设置' or RESET_TO_DEFAULT)..'|r|n|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI),
                    whileDead=true, hideOnEscape=true, exclusive=true,
                    button1= e.onlyChinese and '重置' or RESET,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    OnAccept = function()
                        Save=nil
                        e.Reload()
                    end,
                }
                StaticPopup_Show(id..addName..'RESET_TO_DEFAULT')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)


    elseif type=='CUSTOM' then
        for gossipOptionID, text in pairs(Save.gossipOption) do
            info={
                text= text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='gossipOptionID '..gossipOptionID,
                tooltipText='|n'..e.Icon.left..(e.onlyChinese and '移除' or REMOVE),
                arg1= gossipOptionID,
                func=function(_, arg1)
                    Save.gossipOption[arg1]=nil
                    print(id, e.onlyChinese and '对话' or ENABLE_DIALOG, e.onlyChinese and '移除' or REMOVE, text, 'gossipOptionID:', arg1)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            tooltipOnButton= true,
            tooltipTitle= 'Shift+'..e.Icon.left,
            notCheckable=true,
            func= function()
                if IsShiftKeyDown() then
                    Save.gossipOption={}
                    print(id, e.cn(addName), e.onlyChinese and '自定义' or CUSTOM, e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif type=='DISABLE' then--禁用NPC, 闲话,任务, 选项
        for npcID, name in pairs(Save.NPC) do
            info={
                text=name,
                tooltipOnButton=true,
                tooltipTitle= 'NPC '..npcID,
                tooltipText= e.Icon.left.. (e.onlyChinese and '移除' or REMOVE),
                notCheckable= true,
                arg1= npcID,
                func= function(_, arg1)
                    Save.NPC[arg1]=nil
                    print(id, e.cn(addName), e.onlyChinese and '移除' or REMOVE, 'NPC', arg1)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= 'Shift+'..e.Icon.left,
            func= function()
                if IsShiftKeyDown() then
                    Save.NPC={}
                    print(id, e.cn(addName), e.onlyChinese and '自定义' or CUSTOM, e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)


    elseif type=='PlayerChoiceFrame' then
        for spellID, rarity in pairs(Save.choice) do
            e.LoadDate({id=spellID, type='spell'})
            local icon= GetSpellTexture(spellID)
            local name= GetSpellLink(spellID) or ('spellID '..spellID)
            rarity= rarity+1
            local hex= select(4, C_Item.GetItemQualityColor(rarity))
            local quality=(hex and '|c'..hex or '')..(e.cn(_G['ITEM_QUALITY'..rarity..'_DESC']) or rarity)
            info={
                text=(icon and '|T'..icon..':0|t' or '')..name..' '.. quality,
                tooltipOnButton=true,
                tooltipTitle= e.Icon.left.. (e.onlyChinese and '移除' or REMOVE),
                tooltipText= 'spellID '..spellID,
                notCheckable= true,

                arg1=spellID,
                func= function(_, arg1)
                    Save.choice[arg1]=nil
                    print(id, e.cn(addName), e.onlyChinese and '选择' or CHOOSE, e.onlyChinese and '移除' or REMOVE, GetSpellLink(arg1) or ('spellID '..arg1))
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle='Shift+'..e.Icon.left,
            func= function()
                if IsShiftKeyDown() then
                    Save.choice={}
                    print(id, e.cn(addName), e.onlyChinese and '选择' or CHOOSE, e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif type=='WoWMovie' then
        local MovieList= MOVIE_LIST or {--cinematicsframe.lua
            { expansion=LE_EXPANSION_CLASSIC,
              movieIDs = { 1, 2 },
              upAtlas="StreamCinematic-Classic-Up",
              text= e.onlyChinese and '经典旧世' or nil,
            },
            { expansion=LE_EXPANSION_BURNING_CRUSADE,
              movieIDs = { 27 },
              upAtlas="StreamCinematic-BC-Up",
              text= e.onlyChinese and '燃烧的远征' or nil,
            },
            { expansion=LE_EXPANSION_WRATH_OF_THE_LICH_KING,
              movieIDs = { 18 },
              upAtlas="StreamCinematic-LK-Up",
              text= e.onlyChinese and '巫妖王之怒' or nil,
            },
            { expansion=LE_EXPANSION_CATACLYSM,
              movieIDs = { 23 },
              upAtlas="StreamCinematic-CC-Up",
              text= e.onlyChinese and '大地的裂变' or nil,
            },
            { expansion=LE_EXPANSION_MISTS_OF_PANDARIA,
              movieIDs = { 115 },
              upAtlas="StreamCinematic-MOP-Up",
              text= e.onlyChinese and '熊猫人之谜' or nil,
            },
            { expansion=LE_EXPANSION_WARLORDS_OF_DRAENOR,
              movieIDs = { 195 },
              upAtlas="StreamCinematic-WOD-Up",
              text= e.onlyChinese and '德拉诺之王' or nil,
            },
            { expansion=LE_EXPANSION_LEGION,
              movieIDs = { 470 },
              upAtlas="StreamCinematic-Legion-Up",
              text= e.onlyChinese and '军团再临' or nil,
            },
            { expansion=LE_EXPANSION_BATTLE_FOR_AZEROTH,
              movieIDs = { 852 },
              upAtlas="StreamCinematic-BFA-Up",
              text= e.onlyChinese and '争霸艾泽拉斯' or nil,
            },
            { expansion=LE_EXPANSION_SHADOWLANDS,
              movieIDs = { 936 },
              upAtlas="StreamCinematic-Shadowlands-Up",
              text= e.onlyChinese and '暗影国度' or nil,
            },
            { expansion=LE_EXPANSION_DRAGONFLIGHT,
              movieIDs = { 960 },
              upAtlas="StreamCinematic-Dragonflight-Up",
              text= e.onlyChinese and '巨龙时代' or nil,
            },
            { expansion=LE_EXPANSION_DRAGONFLIGHT,
              movieIDs = { 973 },
              upAtlas="StreamCinematic-Dragonflight2-Up",
              title=DRAGONFLIGHT_TOTHESKIES,
              disableAutoPlay=true,
              text= e.onlyChinese and '巨龙时代' or nil,
            },
        }

        for _, movieEntry in pairs(MovieList) do
            for _, movieID in pairs(movieEntry.movieIDs) do
                local isDownload= IsMovieLocal(movieID)-- IsMoviePlayable(movieID)
                local inProgress, downloaded, total = GetMovieDownloadProgress(movieID)
                info={
                    text= (movieEntry.title or movieEntry.text or _G["EXPANSION_NAME"..movieEntry.expansion])..' '..movieID,
                    tooltipOnButton=true,
                    tooltipTitle= e.Icon.left..(e.onlyChinese and '播放' or EVENTTRACE_BUTTON_PLAY),
                    tooltipText=(isDownload and '|cff606060' or '')
                                ..'Ctrl+'..e.Icon.left..(e.onlyChinese and '下载' or 'Download')
                                ..(inProgress and downloaded and total and format('|n%i%%', downloaded/total*100) or ''),
                    notCheckable=true,
                    disabled= UnitAffectingCombat('player'),
                    colorCode= not isDownload and '|cff606060' or nil,
                    icon= movieEntry.upAtlas,
                    arg1= movieID,
                    func= function(_, arg1)
                        if IsControlKeyDown() then
                            if IsMovieLocal(arg1) then
                                print(id, e.cn(addName), arg1, e.onlyChinese and '存在' or 'Exist')
                            else
                                PreloadMovie(arg1)
                                local inProgress2, downloaded2, total2 = GetMovieDownloadProgress(arg1)
                                print(id, e.cn(addName), inProgress2 and downloaded2 and total2 and format('%i%%', downloaded/total*100) or total2)
                            end
                        elseif not IsModifierKeyDown() then
                            e.LibDD:CloseDropDownMenus()
                            MovieFrame_PlayMovie(MovieFrame, arg1)
                        end
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end

    elseif type=='Movie' then
        for movieID, dateTime in pairs(Save.movie) do
            local isDownload= IsMovieLocal(movieID)-- IsMoviePlayable(movieID)
            local inProgress, downloaded, total = GetMovieDownloadProgress(movieID)
            info={
                text= movieID,
                tooltipOnButton=true,
                tooltipTitle= dateTime,
                tooltipText= '|n'
                            ..e.Icon.left..(e.onlyChinese and '播放' or EVENTTRACE_BUTTON_PLAY)
                            ..'|nShift+'..e.Icon.left..(e.onlyChinese and '移除' or REMOVE)
                            ..(isDownload and '|cff606060' or '')
                            ..'|nCtrl+'..e.Icon.left..(e.onlyChinese and '下载' or 'Download')
                            ..(inProgress and downloaded and total and format('|n%i%%', downloaded/total*100) or ''),
                notCheckable=true,
                disabled= UnitAffectingCombat('player'),
                colorCode= not isDownload and '|cff606060' or nil,
                arg1= movieID,
                func= function(_, arg1)
                    if not IsModifierKeyDown() then
                        e.LibDD:CloseDropDownMenus()
                        MovieFrame_PlayMovie(MovieFrame, arg1)
                    elseif IsControlKeyDown() then
                        if IsMovieLocal(movieID) then
                            print(id, e.cn(addName), arg1, e.onlyChinese and '存在' or 'Exist')
                        else
                            PreloadMovie(arg1)
                            local inProgress2, downloaded2, total2 = GetMovieDownloadProgress(arg1)
                            print(id, e.cn(addName), inProgress2 and downloaded2 and total2 and format('%i%%', downloaded/total*100) or total2)
                        end
                    elseif IsShiftKeyDown() then
                        Save.movie[arg1]=nil
                        print(id, e.cn(addName), e.onlyChinese and '移除' or REMOVE, 'movieID', arg1)
                    end
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        info={
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            tooltipOnButton=true,
            tooltipTitle='Shift+'..e.Icon.left,
            notCheckable=true,
            func= function()
                if IsShiftKeyDown() then
                    Save.movie={}
                    print(id, e.cn(addName), e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '跳过' or RENOWN_LEVEL_UP_SKIP_BUTTON,
            checked= Save.stopMovie,
            tooltipOnButton=true,
            tooltipTitle=e.onlyChinese and '已经播放' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ANIMA_DIVERSION_NODE_SELECTED, EVENTTRACE_BUTTON_PLAY),
            keepShownOnClick=true,
            func= function ()
                Save.stopMovie= not Save.stopMovie and true or nil
                print(id, e.cn(addName), e.GetEnabeleDisable(Save.stopMovie))
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinese and '动画字幕' or CINEMATIC_SUBTITLES,
            tooltipOnButton=true,
            tooltipTitle='CVar movieSubtitle',
            checked= C_CVar.GetCVarBool("movieSubtitle"),
            disabled= UnitAffectingCombat('player'),
            keepShownOnClick=true,
            func= function()
                C_CVar.SetCVar('movieSubtitle', C_CVar.GetCVarBool("movieSubtitle") and '0' or '1')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text='WoW',
            notCheckable=true,
            hasArrow=true,
            menuList='WoWMovie',
            keepShownOnClick=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif type=='Gossip_Text_Icon_Options_SYSTEMP' then--自带，自定义，对话，文本， 3级菜单
        for gossipID, tab in pairs(GossipTextIcon) do
            info={
                text=gossipID..' '..(tab.name or ''),
                icon= tab.icon,
                notCheckable=true,
                keepShownOnClick=true,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

    elseif type=='Gossip_Text_Icon_Options' then--自定义，对话，文本，2级菜单
        local num=0
        for _ in pairs(Save.Gossip_Text_Icon_Player) do
            num= num+1
        end
        info={
            text=(e.onlyChinese and '自定义' or CUSTOM)..(num>0 and '|cnGREEN_FONT_COLOR:' or '|cffff0000')..num..'|r',
            notCheckable=true,
            keepShownOnClick=true,
            tooltipOnButton=true,
            tooltipTitle=(e.onlyChinese and '添加/移除' or (ADD..'/'..REMOVE))..e.Icon.left,
            func= function()
                Init_Gossip_Text_Icon_Options()
            end,
                --e.OpenPanelOpting('|A:SpecDial_LastPip_BorderGlow:0:0|a'..(e.onlyChinese and '对话和任务' or addName))
            --end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        num=0
        for _ in pairs(GossipTextIcon) do
            num= num+1
        end
        info={
            text=(e.onlyChinese and '默认' or DEFAULT)..(num>0 and '|cnGREEN_FONT_COLOR:' or '')..' #'..num,
            colorCode= num==0 and '|cff606060' or nil,
            notCheckable=true,
            hasArrow= num>0,
            menuList= 'Gossip_Text_Icon_Options_SYSTEMP',
            keepShownOnClick=true,
            func= function()
                e.OpenPanelOpting()
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    if type then
        return
    end

    info={
        text=e.onlyChinese and '启用' or ENABLE,
        checked= Save.gossip,
        keepShownOnClick=true,
        func= function ()
            Save.gossip= not Save.gossip and true or nil
            GossipButton:set_Texture()--设置，图片
            GossipButton:tooltip_Show()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    e.LibDD:UIDropDownMenu_AddSeparator(level)

    info={--唯一
        text= e.onlyChinese and '唯一对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEM_UNIQUE, ENABLE_DIALOG),
        checked= Save.unique,
        keepShownOnClick=true,
        func= function()
            Save.unique= not Save.unique and true or nil
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text=e.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE),
        tooltipOnButton=true,
        tooltipTitle=e.onlyChinese and '文本' or LOCALE_TEXT_LABEL,
        checked= not Save.not_Gossip_Text_Icon,
        keepShownOnClick=true,
        hasArrow=true,
        menuList='Gossip_Text_Icon_Options',
        func= function()
           Save.not_Gossip_Text_Icon= not Save.not_Gossip_Text_Icon and true or nil
           Init_Gossip_Text()
           if GossipFrame:IsShown() then
                GossipFrame:Update()
           end
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={--自定义,闲话,选项
        text= e.onlyChinese and '自定义对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, ENABLE_DIALOG),
        menuList='CUSTOM',
        notCheckable=true,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={--禁用NPC, 闲话,任务, 选项
        text= (e.onlyChinese and '禁用' or DISABLE)..' NPC',
        menuList='DISABLE',
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '对话' or ENABLE_DIALOG,
        tooltipText= e.onlyChinese and '任务' or QUESTS_LABEL,
        notCheckable=true,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={--PlayerChoiceFrame
        text= e.onlyChinese and '选择' or CHOOSE,
        menuList='PlayerChoiceFrame',
        tooltipOnButton=true,
        tooltipTitle='PlayerChoiceFrame',
        tooltipText= 'Blizzard_PlayerChoice',
        notCheckable=true,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '电影' or 'Movie',
        menuList='Movie',
        tooltipOnButton=true,
        notCheckable=true,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '打开选项' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS),
        notCheckable=true,
        keepShownOnClick=true,
        hasArrow=true,
        menuList='OPTIONS',
        func= function()
            e.OpenPanelOpting('|A:SpecDial_LastPip_BorderGlow:0:0|a'..(e.onlyChinese and '对话和任务' or addName))
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end










--打开，自定义，对话，文本，按钮，放在主菜单，后
function Init_Gossip_Text_Icon_Options_Button()
    local btn= e.Cbtn(GossipFrame, {size={20,20}, atlas='SpecDial_LastPip_BorderGlow'})
    btn:SetPoint('TOP', GossipFrameCloseButton, 'BOTTOM', -2, -4)
    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Init_Gossip_Text_Icon_Options()
            if Gossip_Text_Icon_Frame and Gossip_Text_Icon_Frame:IsShown() then
                Gossip_Text_Icon_Frame:ClearAllPoints()
                Gossip_Text_Icon_Frame:SetPoint('TOPLEFT', GossipFrame, 'TOPRIGHT',0,-60)
            end
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu_Gossip, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)
    btn:SetAlpha(0.3)

    btn:SetScript('OnLeave', function(self) self:SetAlpha(0.3) GameTooltip_Hide() end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
    end)
end























--建立，自动选取，选项
local function Create_CheckButton(self, info)
    local gossipOptionID= info and info.gossipOptionID
    local sel= self.gossipCheckButton
    if gossipOptionID then
        if not sel then
            sel= CreateFrame("CheckButton", nil, self, 'InterfaceOptionsCheckButtonTemplate')--ChatConfigCheckButtonTemplate
            sel.Text:ClearAllPoints()
            sel.Text:SetPoint('RIGHT', sel, 'LEFT')
            sel.Text:SetTextColor(0,0,0)
            sel.Text:SetShadowOffset(1, -1)
            sel:SetPoint("RIGHT", -2, 0)
            sel:SetSize(18, 18)
            sel:SetScript("OnEnter", function(frame)
                local f= GossipButton:isShow_Gossip_Text_Icon_Frame()
                if f then
                    e.tips:SetOwner(f, "ANCHOR_BOTTOM")
                else
                    e.tips:SetOwner(frame, "ANCHOR_RIGHT")
                end
                e.tips:ClearLines()
                if frame.spellID then
                    e.tips:SetSpellByID(frame.spellID)
                    e.tips:AddLine(' ')
                end
                e.tips:AddDoubleLine('|T'..(frame.icon or 0)..':0|t'..(frame.name or ''), 'gossipOption: |cnGREEN_FONT_COLOR:'..frame.id..'|r')
                if f and not ColorPickerFrame:IsShown() then
                   f.menu:set_date(frame.id)--设置，数据
                elseif not Save.not_Gossip_Text_Icon and (Save.Gossip_Text_Icon_Player[frame.id] or GossipTextIcon[frame.id]) then
                    for _, info in pairs( C_GossipInfo.GetOptions() or {}) do
                        if info.gossipOptionID==frame.id and info.name then
                            e.tips:AddLine('|cnGREEN_FONT_COLOR:'..info.name)
                            break
                        end
                    end
                end
                e.tips:AddDoubleLine(' ')
                e.tips:AddDoubleLine(id, e.onlyChinese and '自动对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ENABLE_DIALOG))
                e.tips:Show()
            end)

            sel:SetScript("OnMouseDown", function (frame)
                Save.gossipOption[frame.id]= not Save.gossipOption[frame.id] and (frame.name or '') or nil
            end)
            self.gossipCheckButton= sel
        end
        sel.id= gossipOptionID
        sel.name= info.name
        sel.spellID= info.spellID

        sel.icon= info.overrideIconID or info.icon
        sel:SetChecked(Save.gossipOption[gossipOptionID] and true or false)
        sel.Text:SetText(GossipButton:isShow_Gossip_Text_Icon_Frame() and gossipOptionID or '')
    end
    if sel then
        sel:SetShown(gossipOptionID and true or false)
    end
end


















--###########
--对话，初始化
--###########
local function Init_Gossip()
    GossipButton= e.Cbtn(nil, {icon='hide', size={16,16}})--闲话图标

    function GossipButton:isShow_Gossip_Text_Icon_Frame()
        return Gossip_Text_Icon_Frame and Gossip_Text_Icon_Frame:IsShown() and Gossip_Text_Icon_Frame or false
    end

    function GossipButton:set_Point()--设置位置
        if Save.point then
            self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        else
            self:SetPoint('BOTTOM', _G['!KalielsTrackerFrame'] or ObjectiveTrackerBlocksFrame, 'TOP', 0 , 0)
        end
    end
    function GossipButton:set_Scale()--设置，缩放
        self:SetScale(Save.scale or 1)
    end
    function GossipButton:set_Alpha()
        self.texture:SetAlpha(Save.gossip and 1 or 0.3)
    end
    function GossipButton:set_Texture()--设置，图片
        if not self.texture then
            self.texture= self:CreateTexture()
            self.texture:SetAllPoints(self)
        end
        self.texture:SetAtlas(Save.gossip and 'SpecDial_LastPip_BorderGlow' or e.Icon.icon)
        self:set_Alpha()
    end
    function GossipButton:tooltip_Show()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.onlyChinese and '对话' or ENABLE_DIALOG)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.scale or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('|A:transmog-icon-chat:0:0|a'..e.GetEnabeleDisable(not Save.gossip), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        --e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, e.Icon.mid)
        e.tips:Show()
        self.texture:SetAlpha(1)
    end
    function GossipButton:set_shown()
        self:SetShown(not C_PetBattles.IsInBattle())
    end

    GossipButton:set_Texture()
    GossipButton:set_Scale()
    GossipButton:set_Point()
    GossipButton:set_shown()

    GossipButton:SetMovable(true)--移动
    GossipButton:SetClampedToScreen(true)
    GossipButton:RegisterForDrag('RightButton')
    GossipButton:SetScript('OnDragStart',function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    GossipButton:SetScript('OnDragStop', function(self)
        self:StopMovingOrSizing()
        ResetCursor()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)
    GossipButton:SetScript('OnMouseUp', ResetCursor)
    GossipButton:SetScript('OnMouseWheel', function(self, d)
        if IsAltKeyDown() then
            local n= Save.scale or 1
            if d==-1 then
                n= n+ 0.05
            elseif d==1 then
                n= n- 0.05
            end
            n= n>3 and 3 or n
            n= n< 0.4 and 0.4 or n
            Save.scale=n
            self:set_Scale()
            self:tooltip_Show()
            print(id, e.cn(addName), e.onlyChinese and '缩放' or UI_SCALE, n)
        --elseif not IsModifierKeyDown() then
            --e.OpenPanelOpting('|A:SpecDial_LastPip_BorderGlow:0:0|a'..(e.onlyChinese and '对话和任务' or addName))
        end
    end)
    GossipButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then--移动
            SetCursor('UI_MOVE_CURSOR')
        else
            local key=IsModifierKeyDown()
            if d=='LeftButton' and not key then--禁用，启用
                Save.gossip= not Save.gossip and true or nil
                self:set_Texture()--设置，图片
                self:tooltip_Show()
            elseif d=='RightButton' and not key then--菜单
                if not self.Menu then
                    self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                    e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu_Gossip, 'MENU')
                end
                e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
            end
        end
    end)


    GossipButton:SetScript('OnLeave', function(self) e.tips:Hide() self:set_Alpha() end)
    GossipButton:SetScript('OnEnter', GossipButton.tooltip_Show)

    GossipButton.selectGissipIDTab={}--GossipFrame，显示时用

    GossipButton:RegisterEvent('PLAY_MOVIE')--movieID
    GossipButton:RegisterEvent('PET_BATTLE_OPENING_DONE')
    GossipButton:RegisterEvent('PET_BATTLE_CLOSE')
    GossipButton:RegisterEvent('ADDON_ACTION_FORBIDDEN')
    GossipButton:SetScript('OnEvent', function(self, event, arg1, ...)
        if event=='PET_BATTLE_OPENING_DONE' or event=='PET_BATTLE_CLOSE' then
            self:set_shown()
        elseif event=='PLAY_MOVIE' then
            if arg1 then
                if Save.movie[arg1] then
                    if Save.stopMovie then
                        MovieFrame:StopMovie()
                        print(id, e.cn(addName), e.onlyChinese and '对话' or ENABLE_DIALOG,
                            '|cnRED_FONT_COLOR:'..(e.onlyChinese and '跳过' or RENOWN_LEVEL_UP_SKIP_BUTTON)..'|r',
                            'movieID|cnGREEN_FONT_COLOR:',
                            arg1
                        )
                        return
                    end
                else
                    Save.movie[arg1]= date("%d/%m/%y %H:%M:%S")
                end
                print(id, e.cn(addName), '|cnGREEN_FONT_COLOR:movieID', arg1)
            end

        elseif event=='ADDON_ACTION_FORBIDDEN'  then
            if Save.gossip then
                if StaticPopup1:IsShown() then
                    StaticPopup1:Hide()
                end
                print(id, e.cn(addName), '|n|cnRED_FONT_COLOR:',  format(e.onlyChinese and '%s已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。' or ADDON_ACTION_FORBIDDEN, arg1 or '', ...))

            end
        end
    end)
  --"%s已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。"
    if Save.gossip then
        StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"].timeout= 0.3
    end


    --[[hooksecurefunc(StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"], "OnShow",function(s)
        if Save.gossip then
            local text= StaticPopup1Text and StaticPopup1Text:GetText() or (e.onlyChinese and '%s已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。' or ADDON_ACTION_FORBIDDEN)
            print(id, e.cn(addName), '|n|cnRED_FONT_COLOR:', text)
            s:Hide()
        end
    end)]]




    --禁用此npc闲话选项
    GossipFrame.WoWToolsSelectNPC=CreateFrame("CheckButton", nil, GossipFrame, 'InterfaceOptionsCheckButtonTemplate')
    GossipFrame.WoWToolsSelectNPC:SetPoint("BOTTOMLEFT",5,2)
    GossipFrame.WoWToolsSelectNPC.Text:SetText(e.onlyChinese and '禁用' or DISABLE)
    GossipFrame.WoWToolsSelectNPC:SetScript("OnLeave", GameTooltip_Hide)
    GossipFrame.WoWToolsSelectNPC:SetScript("OnMouseDown", function (self, d)
        if not self.npc and self.name then
            return
        end
        Save.NPC[self.npc]= not Save.NPC[self.npc] and self.name or nil
        print(id, e.cn(addName), self.name, self.npc, e.GetEnabeleDisable(Save.NPC[self.npc]))
    end)
    GossipFrame.WoWToolsSelectNPC:SetScript('OnEnter',function (self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        if self.npc and self.name then
            e.tips:AddDoubleLine(self.name, 'NPC |cnGREEN_FONT_COLOR:'..self.npc..'|r')
        else
            e.tips:AddDoubleLine(e.onlyChinese and '无' or NONE, 'NPC ID')
        end
        e.tips:Show()
    end)


    GossipFrame:SetScript('OnShow', function (self)
        QuestButton.questSelect={}--已选任务, 提示用
        GossipButton.selectGissipIDTab={}
        local npc=e.GetNpcID('npc')
        self.WoWToolsSelectNPC.npc=npc
        self.WoWToolsSelectNPC.name=UnitName("npc")
        self.WoWToolsSelectNPC:SetChecked(Save.NPC[npc])
    end)




























    --自定义闲话选项, 按钮 GossipFrameShared.lua https://wago.io/MK7OiGqCu https://wago.io/hR_KBVGdK
    hooksecurefunc(GossipOptionButtonMixin, 'Setup', function(self, info)--GossipFrameShared.lua
        Create_CheckButton(self, info)--建立，自动选取，选项
        Set_Gossip_Text(info)--自定义，对话，文本

        if not info or not info.gossipOptionID then
            return
        end

        local index= info.gossipOptionID
        local gossip= C_GossipInfo.GetOptions() or {}
        local allGossip= #gossip
        local name=info.name
        local npc=e.GetNpcID('npc')

        if IsModifierKeyDown() or not index or GossipButton.selectGissipIDTab[index] then
            return
        end

        local find
        local quest= FlagsUtil.IsSet(info.flags, Enum.GossipOptionRecFlags.QuestLabelPrepend)

        if Save.gossipOption[index] then--自定义
            C_GossipInfo.SelectOption(index)
            find=true

        elseif (npc and Save.NPC[npc]) or not Save.gossip then--禁用NPC
            return

        elseif Save.quest and  (quest or name:find('0000FF') or  name:find(QUESTS_LABEL) or name:find(LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST)) then--任务
            if quest then
                name= format(e.onlyChinese and '|cnPURE_BLUE_COLOR:（任务）|r%s' or GOSSIP_QUEST_OPTION_PREPEND, info.name)
            end
            C_GossipInfo.SelectOption(index)
            find=true

        elseif allGossip==1 and Save.unique  then--仅一个
           -- if not getMaxQuest() then
                local tab= C_GossipInfo.GetActiveQuests() or {}
                for _, questInfo in pairs(tab) do
                    if questInfo.questID and questInfo.isComplete and (Save.quest or Save.questOption[questInfo.questID]) then
                        return
                    end
                end

                tab= C_GossipInfo.GetAvailableQuests() or {}
                for _, questInfo in pairs(tab) do
                    if questInfo.questID and (Save.quest or Save.questOption[questInfo.questID]) and (QuestButton.isQuestTrivialTracking and questInfo.isTrivial or not questInfo.isTrivial) then
                        return
                    end
                end
           -- end

            C_GossipInfo.SelectOption(index)
            find=true

        elseif IsInInstance() then
            if index==107571--挑战，模式，去 SX buff
                --and C_ChallengeMode.IsChallengeModeActive()
                and e.WA_GetUnitDebuff('player', nil, 'HARMFUL', {
                           [57723]= true,
                           [57724]= true,
                           [264689]= true,
                           [80354]= true,
                           [390435]= true,
                        })
            then
                C_GossipInfo.SelectOption(index)
                find=true

            elseif index==107572 then--挑战，模式, 修理
                local value= select(2, e.GetDurabiliy())
                if value<85 then
                    C_GossipInfo.SelectOption(index)
                    find=true
                end

            elseif index==56363 then--奥达曼， 传送门3
                C_GossipInfo.SelectOption(index)
                find=true
            elseif index==56364 and allGossip==2 then--奥达曼， 传送门2
                C_GossipInfo.SelectOption(index)
                find=true
            elseif index==56365 and allGossip==1 then--奥达曼， 传送门1
                C_GossipInfo.SelectOption(index)
                find=true
            end
        end

        if find then
            GossipButton.selectGissipIDTab[index]=true
            print(id, e.onlyChinese and '对话' or ENABLE_DIALOG, '|T'..(info.overrideIconID or info.icon or 0)..':0|t', '|cffff00ff'..name..'|r', index)
        end
    end)



















    --自动接取任务,多个任务GossipFrameShared.lua questInfo.questID, questInfo.title, questInfo.isIgnored, questInfo.isTrivial
    hooksecurefunc(GossipSharedAvailableQuestButtonMixin, 'Setup', function(self, info)
        Set_Gossip_Text(self, info)--自定义，对话，文本

        local questID=info and info.questID or self:GetID()
        if not questID then
            return
        end

        if not self.sel then
            self.sel=CreateFrame("CheckButton", nil, self, 'InterfaceOptionsCheckButtonTemplate')
            self.sel:SetPoint("RIGHT", -2, 0)
            self.sel:SetSize(18, 18)
            self.sel:SetScript("OnEnter", function(frame)
                e.tips:SetOwner(frame, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, e.onlyChinese and '任务' or QUESTS_LABEL)
                e.tips:AddDoubleLine(' ')
                if frame.id and frame.text then
                    e.tips:AddDoubleLine(frame.text, 'ID |cnGREEN_FONT_COLOR:'..frame.id..'|r')
                else
                    e.tips:AddDoubleLine(NONE, QUESTS_LABEL..' ID',1,0,0)
                end
                e.tips:Show()
            end)
            self.sel:SetScript("OnLeave", function ()
                e.tips:Hide()
            end)
            self.sel:SetScript("OnMouseDown", function (frame)
                if frame.id and frame.text then
                    Save.questOption[frame.id]= not Save.questOption[frame.id] and frame.text or nil
                    if Save.questOption[frame.id] then
                        C_GossipInfo.SelectAvailableQuest(frame.id)
                    end
                else
                    print(id, e.cn(addName), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE)..'|r', e.onlyChinese and '任务' or QUESTS_LABEL,'ID')
                end
            end)
        end

        local npc=e.GetNpcID('npc')
        self.sel.id= questID
        self.sel.text= info.title

        if IsModifierKeyDown() then
            return

        elseif Save.questOption[questID] then--自定义
           C_GossipInfo.SelectAvailableQuest(questID)--or self:GetID()

        elseif not Save.quest or QuestButton:not_Ace_QuestTrivial(questID) or Save.NPC[npc] then--or getMaxQuest()
            return

        else
            C_GossipInfo.SelectAvailableQuest(questID)
        end
    end)

















    --完成已激活任务,多个任务GossipFrameShared.lua
    hooksecurefunc(GossipSharedActiveQuestButtonMixin, 'Setup', function(self, info)
        Create_CheckButton(self, info)--建立，自动选取，选项
        Set_Gossip_Text(info)--自定义，对话，文本

        local npc=e.GetNpcID('npc')

        local questID=info.questID or self:GetID()
        if not questID or IsModifierKeyDown() then
            return

        elseif Save.questOption[questID] then--自定义
            C_GossipInfo.SelectActiveQuest(questID)
            return

        elseif not Save.quest or Save.NPC[npc] then--禁用任务, 禁用NPC
            return

        elseif C_QuestLog.IsComplete(questID) then
            C_GossipInfo.SelectActiveQuest(questID)
        end
    end)




end




































































--###########
--任务，主菜单
--###########
local function InitMenu_Quest(_, level, type)
    local info
    --local uiMapID = (WorldMapFrame:IsShown() and (WorldMapFrame.mapID or WorldMapFrame:GetMapID("current"))) or C_Map.GetBestMapForUnit('player')
    if type=='REWARDSCHECK' then--三级菜单 ->自动:选择奖励
        local num=0
        for questID, index in pairs(Save.questRewardCheck) do
            e.LoadDate({id=questID, type='quest'})
            info={
                text= (C_QuestLog.GetTitleForQuestID(questID) or ('questID: '..questID))..': |cnGREEN_FONT_COLOR:'..index,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='questID: '..questID,
                arg1= questID,
                func= function(_, arg1)
                    Save.questRewardCheck[arg1]=nil
                    print(id, e.cn(addName), GetQuestLink(arg1) or C_QuestLog.GetTitleForQuestID(arg1) or arg1)
                end,
            }
            num=num+1
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= 'Shift+'..e.Icon.left,
            func= function()
                if IsShiftKeyDown() then
                    Save.questRewardCheck={}
                    print(id, e.cn(addName), e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif type=='CUSTOM' then
        for questID, text in pairs(Save.questOption) do
            info={
                text= text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='questID  '..questID,
                tooltipText='|n'..e.Icon.left..(e.onlyChinese and '移除' or REMOVE),
                func=function()
                    Save.questOption[questID]=nil
                    print(id, QUESTS_LABEL, e.onlyChinese and '移除' or REMOVE, text, 'ID', questID)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= 'Shift+'..e.Icon.left,
            func= function()
                if IsShiftKeyDown() then
                    Save.questOption={}
                    print(id, QUESTS_LABEL, e.onlyChinese and '自定义' or CUSTOM, e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end


    if type then
        return
    end

    info={
        text=e.onlyChinese and '启用' or ENABLE,
        checked= Save.quest,
        keepShownOnClick=true,
        func= function ()
            Save.quest= not Save.quest and true or nil
            QuestButton:set_Texture()--设置，图片
            QuestButton:tooltip_Show()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    e.LibDD:UIDropDownMenu_AddSeparator(level)

    info={
        text='|A:TrivialQuests:0:0|a'..(e.onlyChinese and '其他任务' or MINIMAP_TRACKING_TRIVIAL_QUESTS),--低等任务
        checked= QuestButton.isQuestTrivialTracking,
        tooltipOnButton= true,
        tooltipTitle= e.onlyChinese and '追踪' or TRACKING,
        tooltipText= e.onlyChinese and '低等任务' or (LOW..LEVEL..QUESTS_LABEL),
        keepShownOnClick=true,
        func= function ()
            QuestButton:get_set_IsQuestTrivialTracking(true)--其它任务,低等任务,追踪
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={--自动:选择奖励
        text= e.onlyChinese and '自动选择奖励' or format(TITLE_REWARD, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, CHOOSE)),
        checked= Save.autoSelectReward,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '最高品质' or format(PROFESSIONS_CRAFTING_QUALITY, VIDEO_OPTIONS_ULTRA_HIGH),
        tooltipText= '|cff0000ff'..(e.onlyChinese and '稀有' or GARRISON_MISSION_RARE)..'|r',
        keepShownOnClick=true,
        menuList='REWARDSCHECK',
        hasArrow=true,
        func= function()
            Save.autoSelectReward= not Save.autoSelectReward and true or nil
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '共享任务' or SHARE_QUEST,
        checked=Save.pushable,
        colorCode= not IsInGroup() and '|cff606060',
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '仅限在队伍中' or format(LFG_LIST_CROSS_FACTION, AGGRO_WARNING_IN_PARTY),
        keepShownOnClick=true,
        func= function()
            Save.pushable= not Save.pushable and true or nil
            QuestButton:set_Event()--设置事件
            QuestButton:set_PushableQuest()--共享,任务
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL,
        checked= Save.showAllQuestNum,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '显示所有数量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, ALL),
        tooltipText= e.onlyChinese and '在副本中禁用|n任务>0' or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AGGRO_WARNING_IN_INSTANCE, DISABLE)..'|n'..QUESTS_LABEL..' >0'),
        keepShownOnClick=true,
        func= function()
            Save.showAllQuestNum= not Save.showAllQuestNum and true or nil
            QuestButton:set_Quest_Num_Text()
            QuestButton:set_Event()--设置事件
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '追踪' or TRACKING,
        isTitle= true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '自动任务追踪' or AUTO_QUEST_WATCH_TEXT,
        checked=C_CVar.GetCVarBool("autoQuestWatch"),
        tooltipOnButton=true,
        tooltipTitle= 'CVar autoQuestWatch',
        keepShownOnClick=true,
        func=function()
            C_CVar.SetCVar("autoQuestWatch", C_CVar.GetCVarBool("autoQuestWatch") and '0' or '1')
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '当前地图' or (REFORGE_CURRENT..WORLD_MAP),
        checked= Save.autoSortQuest,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '仅显示当前地图任务' or format(GROUP_FINDER_CROSS_FACTION_LISTING_WITH_PLAYSTLE, SHOW,FLOOR..QUESTS_LABEL),--仅限-本区域任务
        tooltipText= e.onlyChinese and '触发事件: 更新区域' or (EVENTS_LABEL..':' ..UPDATE..FLOOR),
        keepShownOnClick=true,
        func=function()
            Save.autoSortQuest= not Save.autoSortQuest and true or nil
            QuestButton:set_Event()--仅显示本地图任务,事件
            QuestButton:set_Only_Show_Zone_Quest()--显示本区域任务
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={--自定义,任务,选项
        text= e.onlyChinese and '自定义任务' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, QUESTS_LABEL),
        menuList='CUSTOM',
        notCheckable=true,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end
















--###########
--任务，初始化
--###########
local function Init_Quest()
    local size= GossipButton:GetWidth()
    QuestButton=e.Cbtn(GossipButton, {icon='hide', size={size, size}})--任务图标
    QuestButton:SetPoint('RIGHT', GossipButton, 'LEFT')

    function QuestButton:set_Only_Show_Zone_Quest()--显示本区域任务
        if not Save.autoSortQuest or IsInInstance() then
            return
        end
        if self.setQuestWatchTime and not self.setQuestWatchTime:IsCancelled() then
            self.setQuestWatchTime:Cancel()
        end
        self.setQuestWatchTime= C_Timer.NewTimer(1, function()
            --local uiMapID= C_Map.GetBestMapForUnit('player') or 0
            --if uiMapID and uiMapID>0 then
                for index=1, C_QuestLog.GetNumQuestLogEntries() do
                    local info = C_QuestLog.GetInfo(index)
                    if info
                        and info.questID
                        and not info.isHeader
                        --and not info.campaignID
                        --and not info.isScaling
                        --and not info.isLegendarySort
                        and not info.isHidden
                        --and not C_QuestLog.IsQuestCalling(info.questID)
                        --and not C_QuestLog.IsWorldQuest(info.questID)
                    then

                        if info.isOnMap  --or GetQuestUiMapID(info.questID)==uiMapID)
                       --     and not C_QuestLog.IsComplete(info.questID)
                            --and info.hasLocalPOI 
                        then
                            C_QuestLog.AddQuestWatch(info.questID)
                        else
                            C_QuestLog.RemoveQuestWatch(info.questID)
                        end
                    end
                end
                C_QuestLog.SortQuestWatches()
            --end
        end)
    end

    function QuestButton:set_PushableQuest(questID)--共享,任务
        if IsInGroup() and Save.pushable then
            if questID then
                if IsInGroup() and C_QuestLog.IsPushableQuest(questID) then
                    C_QuestLog.SetSelectedQuest(questID)
                    QuestLogPushQuest()
                end
            else
                for index=1, select(2,C_QuestLog.GetNumQuestLogEntries()) do
                    local info = C_QuestLog.GetInfo(index)
                    if info and info.questID and not info.isHeader then
                        C_QuestLog.SetSelectedQuest(info.questID)
                        QuestLogPushQuest()
                    end
                end
                C_QuestLog.SortQuestWatches()
            end
        end
    end

    function QuestButton:set_Alpha()
        self.texture:SetAlpha(Save.quest and 1 or 0.3)
    end
    function QuestButton:set_Texture()--设置，图片
        if not self.texture then
            self.texture= self:CreateTexture()
            self.texture:SetAllPoints()
        end
        self.texture:SetAtlas(Save.quest and 'UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest' or e.Icon.icon)--AutoQuest-Badge-Campaign
        self:set_Alpha()
    end

    function QuestButton:get_set_IsQuestTrivialTracking(setting)--其它任务,低等任务,追踪
        for trackingID=1, C_Minimap.GetNumTrackingTypes() do
            local name, _, active= C_Minimap.GetTrackingInfo(trackingID)--name, texture, active, category, nested
            if name== MINIMAP_TRACKING_TRIVIAL_QUESTS then
                if setting then
                    active= not active and true or false
                    C_Minimap.SetTracking(trackingID, active)
                end
                self.isQuestTrivialTracking = active
                break
            end
        end
    end

    function QuestButton:not_Ace_QuestTrivial(questID)--其它任务,低等任务
        return C_QuestLog.IsQuestTrivial(questID) and not self.isQuestTrivialTracking
    end

    function QuestButton:questInfo_GetQuestID()--取得， 任务ID, QuestInfo.lua
        if QuestInfoFrame.questLog then
            return C_QuestLog.GetSelectedQuest()
        else
            return GetQuestID()
        end
    end

    function QuestButton:set_Event()--设置事件
        self:UnregisterAllEvents()

        self:RegisterEvent("QUEST_LOG_UPDATE")--更新数量
        self:RegisterEvent('MINIMAP_UPDATE_TRACKING')--其它任务,低等任务,追踪
        if Save.autoSortQuest then----显示本区域任务
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('ZONE_CHANGED')
            self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
            self:RegisterEvent('SCENARIO_UPDATE')
        end
        if Save.pushable then--共享,任务
            self:RegisterEvent('GROUP_ROSTER_UPDATE')
            self:RegisterEvent('GROUP_JOINED')
            self:RegisterEvent('QUEST_ACCEPTED')
        end
        if Save.showAllQuestNum then--显示所有任务数量, 过区域时，更新当前地图任务，数量
            self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
        end
        self:RegisterEvent('PLAYER_ENTERING_WORLD')

    end
    --[[function QuestButton:get_All_Num()
        local numQuest, dayNum, weekNum, campaignNum, legendaryNum, storyNum, bountyNum, inMapNum = 0, 0, 0, 0, 0, 0, 0,0
        for index=1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(index)
            if info and not info.isHeader and not info.isHidden then
                if info.frequency== 0 then
                    numQuest= numQuest+ 1

                elseif info.frequency==  Enum.QuestFrequency.Daily then--日常
                    dayNum= dayNum+ 1

                elseif info.frequency== Enum.QuestFrequency.Weekly then--周常
                    weekNum= weekNum+ 1
                end

                if info.campaignID then
                    campaignNum= campaignNum+1
                elseif info.isLegendarySort then
                    legendaryNum= legendaryNum +1
                elseif info.isStory then
                    storyNum= storyNum +1
                elseif info.isBounty then
                    bountyNum= bountyNum+ 1
                end
                if info.isOnMap then
                    inMapNum= inMapNum +1
                end
            end
        end
        return numQuest, dayNum, weekNum, campaignNum, legendaryNum, storyNum, bountyNum, inMapNum
    end]]

    function QuestButton:tooltip_Show()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.onlyChinese and '任务' or QUESTS_LABEL)
        e.tips:AddLine(' ')
        e.GetQuestAllTooltip()--所有，任务，提示
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.quest),e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU),e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, e.Icon.mid)
        e.tips:Show()
        self.texture:SetAlpha(1)
        self:set_Only_Show_Zone_Quest()
        self:set_Quest_Num_Text()
    end
    function QuestButton:set_Quest_Num_Text()
        if IsInInstance() then
            self.Text:SetText('')
        else
            if Save.showAllQuestNum then--显示所有任务数量
                local numQuest, dayNum, weekNum, campaignNum, legendaryNum, storyNum, bountyNum, inMapNum = 0, 0, 0, 0, 0, 0, 0,0
                for index=1, C_QuestLog.GetNumQuestLogEntries() do
                    local info = C_QuestLog.GetInfo(index)
                    if info and not info.isHeader and not info.isHidden then
                        if info.frequency== 0 then
                            numQuest= numQuest+ 1

                        elseif info.frequency==  Enum.QuestFrequency.Daily then--日常
                            dayNum= dayNum+ 1

                        elseif info.frequency== Enum.QuestFrequency.Weekly then--周常
                            weekNum= weekNum+ 1
                        end

                        if info.campaignID then
                            campaignNum= campaignNum+1
                        elseif info.isLegendarySort then
                            legendaryNum= legendaryNum +1
                        elseif info.isStory then
                            storyNum= storyNum +1
                        elseif info.isBounty then
                            bountyNum= bountyNum+ 1
                        end
                        if info.isOnMap then
                            inMapNum= inMapNum +1
                        end
                    end
                end

                local need= campaignNum+ legendaryNum+ storyNum +bountyNum
                self.Text:SetText(
                    (inMapNum>0 and '|cnGREEN_FONT_COLOR:'..inMapNum..e.Icon.toLeft2..'|r ' or '')
                    ..(dayNum>0 and e.GetQestColor('Day').hex..dayNum..'|r ' or '')
                    ..(weekNum>0 and e.GetQestColor('Week').hex..weekNum..'|r ' or '')
                    ..(numQuest>0 and '|cffffffff'..numQuest..'|r ' or '')
                    ..(need>0 and e.GetQestColor('Legendary').hex..need..'|r ' or '')
                )
            else
                local num= select(2, C_QuestLog.GetNumQuestLogEntries())
                self.Text:SetText(num>0 and num or '')
            end
        end
    end
    QuestButton:SetScript("OnEvent", function(self, event, arg1)
        if event=='MINIMAP_UPDATE_TRACKING' then
            self:get_set_IsQuestTrivialTracking()--其它任务,低等任务,追踪

        elseif event=='QUEST_LOG_UPDATE' or event=='PLAYER_ENTERING_WORLD' or event=='ZONE_CHANGED_NEW_AREA' then--更新数量
            self:set_Quest_Num_Text()

        elseif event=='GROUP_ROSTER_UPDATE' then
            self:set_PushableQuest()--共享,任务

        elseif event=='QUEST_ACCEPTED' then---共享,任务
            if arg1 then
                self:set_PushableQuest(arg1)--共享,任务
            end
        else
            self:set_Only_Show_Zone_Quest()--显示本区域任务
        end
    end)

    QuestButton:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Save.quest= not Save.quest and true or nil
            self:set_Texture()--设置，图片
            self:tooltip_Show()
        elseif d=='RightButton' then
            if not self.MenuQest then
                self.MenuQest=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.MenuQest, InitMenu_Quest, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.MenuQest, self, 15, 0)
        end
    end)
    QuestButton:SetScript('OnMouseWheel', function()
        e.OpenPanelOpting(addName)
    end)

    QuestButton:SetScript('OnLeave', function(self) e.tips:Hide() self:set_Alpha() end)
    QuestButton:SetScript('OnEnter', QuestButton.tooltip_Show)

    QuestButton.questSelect={}--已选任务, 提示用
    QuestButton:set_Texture()--设置，图片
    QuestButton:get_set_IsQuestTrivialTracking()--其它任务,低等任务,追踪
    QuestButton:set_Event()--仅显示本地图任务,事件

    C_Timer.After(2, function() QuestButton:set_Only_Show_Zone_Quest() end)--显示本区域任务

    QuestButton.Text=e.Cstr(QuestButton, {justifyH='RIGHT', color=true, size= size-2})--任务数量
    QuestButton.Text:SetPoint('RIGHT', QuestButton, 'LEFT', 0, 1)






    QuestFrame.sel=CreateFrame("CheckButton", nil, QuestFrame, 'InterfaceOptionsCheckButtonTemplate')--禁用此npc,任务,选项
    QuestFrame.sel:SetPoint("TOPLEFT", QuestFrame, 40, 20)
    QuestFrame.sel.Text:SetText(e.onlyChinese and '禁用' or DISABLE)
    QuestFrame.sel:SetScript("OnMouseDown", function (self, d)
        if not self.npc and self.name then
            return
        end
        Save.NPC[self.npc]= not Save.NPC[self.npc] and self.name or nil
        print(id, e.cn(addName), self.name, self.npc, e.GetEnabeleDisable(Save.NPC[self.npc]))
    end)
    QuestFrame.sel:SetScript('OnEnter',function (self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        if self.npc and self.name then
            e.tips:AddDoubleLine(self.name, 'NPC '..self.npc)
        else
            e.tips:AddDoubleLine(NONE, 'NPC ID')
        end
        local questID=QuestButton:questInfo_GetQuestID()
        if questID then
            e.tips:AddDoubleLine('questID', questID)
        end
        e.tips:Show()
    end)
    QuestFrame.sel:SetScript("OnLeave", function()
        e.tips:Hide()
    end)

    --任务框, 自动选任务    
    QuestFrameGreetingPanel:HookScript('OnShow', function()--QuestFrame.lua QuestFrameGreetingPanel_OnShow
        local npc=e.GetNpcID('npc')
        QuestFrame.sel.npc=npc
        QuestFrame.sel.name=UnitName("npc")
        QuestFrame.sel:SetChecked(Save.NPC[npc])

        if not npc or not Save.quest or IsModifierKeyDown() or Save.NPC[npc] then
            return
        end

        local numActiveQuests = GetNumActiveQuests()
        local numAvailableQuests = GetNumAvailableQuests()
        if numActiveQuests > 0 then
            for index=1, numActiveQuests do
                if select(2,GetActiveTitle(index)) then
                    SelectActiveQuest(index)
                    return
                end
            end
        end
        if numAvailableQuests > 0 then-- and not getMaxQuest() 
            for i=(numActiveQuests + 1), (numActiveQuests + numAvailableQuests) do
                local index = i - numActiveQuests
                local isTrivial= GetAvailableQuestInfo(index)
                if (isTrivial and QuestButton.isQuestTrivialTracking) or not isTrivial then
                    SelectAvailableQuest(index)
                    return
                end
            end
       end
    end)

    --任务进度, 继续, 完成 QuestFrame.lua
    hooksecurefunc('QuestFrameProgressItems_Update', function()
        local npc=e.GetNpcID('npc')
        QuestFrame.sel.npc=npc
        QuestFrame.sel.name=UnitName("npc")
        QuestFrame.sel:SetChecked(Save.NPC[npc])

        local questID= QuestButton:questInfo_GetQuestID()

        if not questID or not Save.quest or IsModifierKeyDown() or (Save.NPC[npc] and not Save.questOption[questID]) then
            return
        end

        if not IsQuestCompletable() then--or not C_QuestOffer.GetHideRequiredItemsOnTurnIn() then
            if questID then
                local link
                local buttonIndex = 1--物品数量
                for i=1, GetNumQuestItems() do
                    local hidden = IsQuestItemHidden(i)
                    if (hidden == 0) then
                        local requiredItem = _G["QuestProgressItem"..buttonIndex]
                        if requiredItem and requiredItem.type then
                            local itemLink = GetQuestItemLink(requiredItem.type, i)
                            local name,_ , numItems = GetQuestItemInfo(requiredItem.type, i)
                            if itemLink or name then
                                link=(link or '')..(numItems and '|cnRED_FONT_COLOR:'..numItems..'x|r' or '')..(itemLink or name)
                            end
                        end
                        buttonIndex = buttonIndex+1
                    end
                end
                local text=GetProgressText()
                C_Timer.After(0.5, function()
                    local questLink=GetQuestLink(questID)
                    if not questLink then
                        local index= C_QuestLog.GetLogIndexForQuestID(questID)
                        local info2= index and C_QuestLog.GetInfo(index)
                        if info2 and info2.title and info2.level then
                            questLink= '|Hquest:'..questID..':'..info2.level..'|h['..info2.title..']|h'
                        end
                        questLink=questLink or ('|cnGREEN_FONT_COLOR:'..questID..'|r')
                    end
                    print(id, QUESTS_LABEL, questLink, text and '|cffff00ff'..text..'|r', link, QuestFrameGoodbyeButton and '|cnRED_FONT_COLOR:'..QuestFrameGoodbyeButton:GetText())
                end)
            end
            e.call('QuestGoodbyeButton_OnClick')
        else
            if not QuestButton.questSelect[questID] then--已选任务, 提示用
                C_Timer.After(0.5, function()
                    print(id, e.cn(addName), GetQuestLink(questID) or questID)
                end)
                QuestButton.questSelect[questID]=true
            end
            e.call('QuestProgressCompleteButton_OnClick')
        end
    end)

    --自动接取任务, 仅一个任务
    hooksecurefunc('QuestInfo_Display', function(template, parentFrame, acceptButton, material, mapView)--QuestInfo.lua
        local npc=e.GetNpcID('npc')
        QuestFrame.sel.npc=npc
        QuestFrame.sel.name=UnitName("npc")
        QuestFrame.sel:SetChecked(Save.NPC[npc])

        local questID= QuestButton:questInfo_GetQuestID()
        if not questID and template.canHaveSealMaterial and not QuestUtil.QuestTextContrastEnabled() and template.questLog then
            local frame = parentFrame:GetParent():GetParent()
            questID = frame.questID
        end

        if not questID
            or not Save.quest
            or (Save.NPC[npc] and not Save.questOption[questID])
            or IsModifierKeyDown()
            or QuestButton:not_Ace_QuestTrivial(questID)
            or not acceptButton
            or not acceptButton:IsVisible()
            or not acceptButton:IsEnabled()
        then
            return
        end

        local complete=IsQuestCompletable() or  C_QuestLog.IsComplete(questID)--QuestFrame.lua QuestFrameProgressPanel_OnShow(self) C_QuestLog.IsComplete(questID)
        if complete then
            select_Reward(questID)--自动:选择奖励
        end

        local itemLink=''--QuestInfo.lua QuestInfo_ShowRewards()
        for index=1, GetNumQuestChoices() do--物品
            local questItem = QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame, index)
            if questItem then
                local link=GetQuestItemLink(questItem.type, index)
                if link then
                    itemLink= itemLink..link
                end
            end
        end

        local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}--QuestInfo.lua QuestInfo_ShowRewards()
        for _, spellID in pairs(spellRewards) do
            e.LoadDate({id=spellID, type='spell'})
            local spellLink= GetSpellLink(spellID)
            itemLink= itemLink.. (spellLink or (' spellID'..spellID))
        end

        local skillName, skillIcon, skillPoints = GetRewardSkillPoints()--专业
        if skillName then
            itemLink= itemLink..(GetSpellLink(skillName) or ((skillIcon and '|T'..skillIcon..':0|t' or '')..skillName))..(skillPoints and '|cnGREEN_FONT_COLOR:+'..skillPoints..'|r' or '')
        end

        local majorFactionRepRewards = C_QuestOffer.GetQuestOfferMajorFactionReputationRewards()--名望
        if majorFactionRepRewards then
			for _, rewardInfo in ipairs(majorFactionRepRewards) do
                if rewardInfo.factionID and rewardInfo.rewardAmount then
                    local data = C_MajorFactions.GetMajorFactionData(rewardInfo.factionID)
                    if data and data.name then
                        itemLink= itemLink..(data.textureKit and '|A:MajorFactions_Icons_'..data.textureKit..'512:0:0|a' or '')..(not data.textureKit and data.name or '')..'|cnGREEN_FONT_COLOR:+'..rewardInfo.rewardAmount..'|r'
                    end
                end
            end
        end

        if not QuestButton.questSelect[questID] then--已选任务, 提示用
            C_Timer.After(0.5, function()
                print(id, QUESTS_LABEL, GetQuestLink(questID) or questID, (complete and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')..acceptButton:GetText()..'|r', itemLink)
            end)
            QuestButton.questSelect[questID]=true
        end

        if acceptButton==QuestFrameCompleteQuestButton then
            e.call('QuestRewardCompleteButton_OnClick')
        elseif acceptButton:IsEnabled() and acceptButton:IsVisible() then
            acceptButton:Click()
        end
    end)
end




























































--公会和社区 Blizzard_Communities
local function Init_Blizzard_Communities()
    --自动，申请，加入
    local function set_ClubFinderRequestToJoin(self)
        local specID = PlayerUtil.GetCurrentSpecID()
        if not self.info or not Save.gossip or not self.SpecsPool or not specID then
            return
        end
        local specName
        for btn in pairs(self.SpecsPool.activeObjects or {}) do
        if btn.specID==specID then
                btn.CheckBox:Click()
                specName= btn.SpecName:GetText()
                break
        end
        end
        local level= UnitLevel('player') or MAX_PLAYER_LEVEL
        local text
        if level< MAX_PLAYER_LEVEL then
            text= 'Level '..(level and format('%i', level) or '')
        else
            local avgItemLevel,_, avgItemLevelPvp= GetAverageItemLevel()
            local score= C_ChallengeMode.GetOverallDungeonScore() or 0
            local keyStoneLevel= C_MythicPlus.GetOwnedKeystoneLevel() or 0
            local achievement= GetTotalAchievementPoints() or 0

            text= 'Item Level '..(avgItemLevel and format('%i', avgItemLevel) or '')..'|n'--等级
                ..(avgItemLevel and avgItemLevelPvp and avgItemLevelPvp- avgItemLevel>20 and 'Item PvP '..format('%i', avgItemLevel)..'|n' or '')
            if score>1000 then--挑战
                text= text..'Keystone '..score..(keyStoneLevel and keyStoneLevel>10 and ' ('..keyStoneLevel..')' or '')
                text= text..'|n'
            end
            if achievement>10000 then--成就
                text= text..'Achievement '..achievement..'|n'
            end
            local CONQUEST_SIZE_STRINGS = {'Solo', '2v2', '3v3', '10v10'}--PVP
            for i=1, 4 do
                local rating= GetPersonalRatedInfo(i)
                if rating and rating>500 then
                    text= text..CONQUEST_SIZE_STRINGS[i]..' '..rating..'|n'
                end
            end
        end
        self.MessageFrame.MessageScroll.EditBox:SetText(text)
        if IsModifierKeyDown() then
            return
        end
        if self.Apply:IsEnabled() then
            self.Apply:Click()
            print(
                id,addName,'|cnGREEN_FONT_COLOR:', self.Apply:GetText(),'|n|cffff00ff',
                (self.info.emblemInfo and '|T'..self.info.emblemInfo..':0|t' or '')..(self.info.name or '')..(self.info.numActiveMembers and  '|cff00ccff (|A:groupfinder-waitdot:0:0|a'..self.info.numActiveMembers..')|r' or ''), '|n',
                '|cnGREEN_FONT_COLOR:'..text, specName,'|n', '|cffff7f00', self.info.comment)
        end
    end
    hooksecurefunc(ClubFinderGuildFinderFrame.RequestToJoinFrame, 'Initialize', set_ClubFinderRequestToJoin)
    hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame, 'Initialize', set_ClubFinderRequestToJoin)
    ClubFinderCommunityAndGuildFinderFrame.CommunityCards:HookScript('OnShow', function(self)
        if Save.gossip or not IsModifierKeyDown() then
            local btn= self:GetParent().OptionsList.Search
            if btn and btn:IsEnabled() then
                btn:Click()
            end
        end
    end)
    ClubFinderGuildFinderFrame.GuildCards:HookScript('OnShow', function(self)
        if Save.gossip or not IsModifierKeyDown() then
            local btn= self:GetParent().OptionsList.Search
            if btn and btn:IsEnabled() then
                btn:Click()
            end
        end
    end)
end














local SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING= SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING
--Blizzard_PlayerChoice
local function Init_Blizzard_PlayerChoice()
    --命运, 字符
    hooksecurefunc(StaticPopupDialogs["CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING"],"OnShow",function(s)
        if Save.gossip and s.editBox then
            s.editBox:SetText(SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING)
        end
    end)


    --自动选择奖励 Blizzard_PlayerChoice.lua
    local function Send_Player_Choice_Response(optionInfo)
        if optionInfo then
            C_PlayerChoice.SendPlayerChoiceResponse(optionInfo.buttons[1].id)
            print(id, e.cn(addName), (optionInfo.spellID and GetSpellLink(optionInfo.spellID) or ''),
                '|n',
                '|T'..(optionInfo.choiceArtID or 0)..':0|t'..optionInfo.rarityColor:WrapTextInColorCode(optionInfo.description or '')
            )
            PlayerChoiceFrame:OnSelectionMade()
            C_PlayerChoice.OnUIClosed()
            for optionFrame in PlayerChoiceFrame.optionPools:EnumerateActiveByTemplate(PlayerChoiceFrame.optionFrameTemplate) do
                optionFrame:SetShown(false)
            end
        end
    end
    hooksecurefunc(PlayerChoiceFrame, 'SetupOptions', function(frame)
        if IsModifierKeyDown() or not Save.gossip then
            return
        end
        local tab={}
        local soloOption = (#frame.choiceInfo.options == 1)
        for optionFrame in frame.optionPools:EnumerateActiveByTemplate(frame.optionFrameTemplate) do
            if optionFrame.optionInfo then
                local enabled= not optionFrame.optionInfo.disabledOption and optionFrame.optionInfo.spellID and optionFrame.optionInfo.spellID>0
                if not optionFrame.check and enabled then
                    optionFrame.check= CreateFrame("CheckButton", nil, optionFrame, "InterfaceOptionsCheckButtonTemplate")
                    optionFrame.check:SetPoint('BOTTOM' ,0, -40)
                    optionFrame.check:SetScript('OnClick', function(self3)
                        local optionInfo= self3:GetParent().optionInfo
                        if optionInfo and optionInfo.spellID then
                            Save.choice[optionInfo.spellID]= not Save.choice[optionInfo.spellID] and (optionInfo.rarity or 0) or nil
                            if Save.choice[optionInfo.spellID] then
                                Send_Player_Choice_Response(optionInfo)
                            end
                        else
                            print(id, e.cn(addName),'|cnRED_FONT_COLOR:', not e.onlyChinese and ERRORS..' ('..UNKNOWN..')' or '未知错误')
                        end
                    end)
                    optionFrame.check:SetScript('OnLeave', GameTooltip_Hide)
                    optionFrame.check:SetScript('OnEnter', function(self3)
                        local optionInfo= self3:GetParent().optionInfo
                        e.tips:SetOwner(self3:GetParent(), "ANCHOR_BOTTOMRIGHT")
                        e.tips:ClearLines()
                        if optionInfo and optionInfo.spellID then
                            e.tips:SetSpellByID(optionInfo.spellID)
                        end
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(id, e.cn(addName))
                        e.tips:Show()
                    end)
                    optionFrame.check.Text2=e.Cstr(optionFrame.check)
                    optionFrame.check.Text2:SetPoint('RIGHT', optionFrame.check, 'LEFT')
                    optionFrame.check.Text2:SetTextColor(0,1,0)
                    optionFrame.check:SetScript('OnUpdate', function(self3, elapsed)
                        self3.elapsed = (self3.elapsed or 1) + elapsed
                        if self3.elapsed>=1 then
                            local text, count
                            local aura= self3.spellID and C_UnitAuras.GetPlayerAuraBySpellID(self3.spellID)
                            if aura then
                                local value= aura.expirationTime-aura.duration
                                local time= GetTime()
                                time= time < value and time + 86400 or time
                                time= time - value
                                text= e.SecondsToClock(aura.duration- time)
                                count= select(3, e.WA_GetUnitBuff('player', self3.spellID, 'HELPFUL'))
                                count= count and count>1 and count or nil
                            end
                            self3.Text:SetText(text or '')
                            self3.Text2:SetText(count or '')
                            self3.elapsed=0
                        end
                    end)
                end

                if optionFrame.check then
                    optionFrame.check.elapsed=1.1
                    optionFrame.check.spellID= optionFrame.optionInfo.spellID
                    optionFrame.check:SetShown(enabled)
                    if enabled then
                        local saveChecked= Save.choice[optionFrame.optionInfo.spellID]
                        optionFrame.check:SetChecked(saveChecked)
                        if saveChecked or (soloOption and Save.unique) then
                            optionFrame.optionInfo.rarity = optionFrame.optionInfo.rarity or 0
                            table.insert(tab, optionFrame.optionInfo)
                        end
                    end
                end
            end
        end
        if #tab>0 then
            table.sort(tab, function(a,b)
                if a.rarity== b.rarity then
                    return a.spellID> b.spellID
                else
                    return a.rarity> b.rarity
                end
            end)
            Send_Player_Choice_Response(tab[1])
        end
    end)

    hooksecurefunc(PlayerChoiceNormalOptionTemplateMixin,'SetupButtons', function(frame)
        local info2= frame.optionInfo or {}
        if not info2.disabledOption and info2.buttons
            and info2.buttons[2] and info2.buttons[2].id
        then
            if not PlayerChoiceFrame.allButton then
                PlayerChoiceFrame.allButton= e.Cbtn(PlayerChoiceFrame, {size={60,22}, type=false, icon='hide'})
                PlayerChoiceFrame.allButton:SetPoint('BOTTOMRIGHT')
                PlayerChoiceFrame.allButton:SetFrameStrata('DIALOG')
                PlayerChoiceFrame.allButton:SetScript('OnLeave', GameTooltip_Hide)
                PlayerChoiceFrame.allButton:SetScript('OnEnter', function(s)
                    e.tips:SetOwner(s, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(id , e.cn(addName))
                    e.tips:AddLine(' ')
                    e.tips:AddLine(s.tips or (e.onlyChinese and '使用' or USE))
                    e.tips:AddDoubleLine(' ', format(e.onlyChinese and '%d次' or ITEM_SPELL_CHARGES, 44)..e.Icon.left)
                    e.tips:AddDoubleLine(' ', format(e.onlyChinese and '%d次' or ITEM_SPELL_CHARGES, 100)..e.Icon.right)
                    e.tips:AddDoubleLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '停止' or SLASH_STOPWATCH_PARAM_STOP1), 'Alt')
                    e.tips:Show()
                end)
                PlayerChoiceFrame.allButton:SetScript('OnHide', function(s)
                    if s.time and not s.time:IsCancelled() then
                        s.time:Cancel()
                    end
                end)
                function PlayerChoiceFrame.allButton:set_text()
                    self:SetText(
                        (not self.time or self.time:IsCancelled()) and (e.onlyChinese and '全部' or ALL)
                        or (e.onlyChinese and '停止' or SLASH_STOPWATCH_PARAM_STOP1)
                    )
                end
                PlayerChoiceFrame.allButton:SetScript('OnClick', function(s, d)
                    if s.time and not s.time:IsCancelled() then
                        s.time:Cancel()
                        s:set_text()
                        print(id,e.cn(addName),'|cnRED_FONT_COLOR:', e.onlyChinese and '停止' or SLASH_STOPWATCH_PARAM_STOP1)
                        return
                    else
                        s:set_text()
                    end
                    local n= 0
                    local all= d=='LeftButton' and 43 or 100

                    if s.buttonID then
                        C_PlayerChoice.SendPlayerChoiceResponse(s.buttonID)
                    end
                    s.time=C_Timer.NewTicker(0.65, function()
                        local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo() or {}
                        local info= choiceInfo.options and choiceInfo.options[1] or {}
                        if info
                            and not info.disabledOption
                            and info.buttons
                            and info.buttons[2]

                            and info.buttons[2].id
                            and not info.buttons[2].disabled
                            and not IsModifierKeyDown()
                            and s:IsEnabled()
                            and s:IsShown()
                        then
                            C_PlayerChoice.SendPlayerChoiceResponse(info.buttons[2].id)--Blizzard_PlayerChoiceOptionBase.lua
                            n=n+1
                            print(id, e.cn(addName), '|cnGREEN_FONT_COLOR:'..n..'|r', '('..all-n..')', '|cnRED_FONT_COLOR:Alt' )
                            --self.parentOption:OnSelected()
                        elseif s.time then
                        s.time:Cancel()
                        print(id,e.cn(addName),'|cnRED_FONT_COLOR:', e.onlyChinese and '停止' or SLASH_STOPWATCH_PARAM_STOP1, '|r'..n)
                        end
                        s:set_text()
                    end, all)
                end)
            end
            PlayerChoiceFrame.allButton.buttonID= info2.buttons[2].id
            PlayerChoiceFrame.allButton.tips=info2.buttons[2].text
            PlayerChoiceFrame.allButton.disabled= info2.buttons[2].disabled
            PlayerChoiceFrame.allButton:SetEnabled(not info2.buttons[2].disabled and true or false)
            PlayerChoiceFrame.allButton:set_text()
            PlayerChoiceFrame.allButton:SetShown(true)
        elseif PlayerChoiceFrame.allButton then
            PlayerChoiceFrame.allButton:SetShown(false)
        end
    end)
end











--其它， 自动， 选择
local function Init_Gossip_Other_Auto_Select()
    local frame= CreateFrame("Frame")
    frame:RegisterEvent('ADDON_LOADED')
    frame:SetScript('OnEvent', function(_, _, arg1)
        if arg1=='Blizzard_Communities' then
            Init_Blizzard_Communities()

        elseif arg1=='Blizzard_PlayerChoice' then
            Init_Blizzard_PlayerChoice()
        end
    end)
end


































--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED"  then
        if arg1 == id then
            Save= WoWToolsSave[addName] or Save
            Save.questOption = Save.questOption or {}
            Save.gossipOption= Save.gossipOption or {}
            Save.questRewardCheck= Save.questRewardCheck or {}
            Save.choice= Save.choice or {}
            Save.NPC= Save.NPC or {}
            Save.movie= Save.movie or {}

            Save.Gossip_Text_Icon_Player= Save.Gossip_Text_Icon_Player or {}
            Save.Gossip_Text_Icon_Size= Save.Gossip_Text_Icon_Size or 22

             --添加控制面板
             e.AddPanel_Header(nil, 'Plus')
             e.AddPanel_Check_Button({
                 checkName= '|A:SpecDial_LastPip_BorderGlow:0:0|a'..(e.onlyChinese and '对话和任务' or addName),
                 checkValue= not Save.disabled,
                 checkFunc= function()
                     Save.disabled = not Save.disabled and true or nil
                     print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                 end,
                 buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                 buttonFunc= function()
                     Save.point=nil
                     if GossipButton then
                         GossipButton:ClearAllPoints()
                         GossipButton:set_Point()
                     end
                     print(id, e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
                 end,
                 tooltip= e.cn(addName),
                 layout= nil,
                 category= nil,
             })

            if not Save.disabled then
                Init_Gossip_Text()--自定义，对话，文本
                Init_Gossip()--对话，初始化
                Init_Quest()--任务，初始化
                Init_Gossip_Other_Auto_Select()
                Init_Gossip_Text_Icon_Options_Button()--打开，自定义，对话，文本，按钮
               
                if e.Player.husandro then
                  -- Init_Gossip_Text_Icon_Options()--自定义，对话，文本，选项
                end
            else
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        --elseif arg1=='Blizzard_Settings' then
            --Init_Options()--初始, 选项
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)

            --[[e.AddPanel_Check_Button({
                checkName= '|A:CampaignAvailableQuestIcon:0:0|a'..(e.onlyChinese and '对话和任务' or addName),
                checkValue= not Save.disabled,
                checkFunc= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save.point=nil
                    if GossipButton then
                        GossipButton:ClearAllPoints()
                        GossipButton:set_Point()
                    end
                    print(id, e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= e.cn(addName),
                layout= nil,
                category= nil,
            })]]
