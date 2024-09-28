local id, e = ...
local addName
WoWTools_EncounterMixin={
Save={
    wowBossKill={},
    loot= {[e.Player.class]= {}},
    favorites={},--副本收藏
},
addName=nil
}

local function Save()
    return WoWTools_EncounterMixin.Save
end



function WoWTools_EncounterMixin:GetBossNameSort(name)--取得怪物名称, 短名称
    name= e.cn(name)
    name=name:gsub('(,.+)','')
    name=name:gsub('(，.+)','')
    name=name:gsub('·.+','')
    name=name:gsub('%-.+','')
    name=name:gsub('<.+>', '')
    return name
end



local panel=CreateFrame("Frame")
local Button







local ITEM_CLASSES_ALLOWED= format(ITEM_CLASSES_ALLOWED, '(.+)')
local ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"






































local function set_EncounterJournal_Keystones_Tips(self)--险指南界面, 挑战
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(e.onlyChinese and '史诗钥石地下城' or CHALLENGES, e.Icon.left)
    for guid, info in pairs(e.WoWDate or {}) do
        if guid and  info.Keystone.link then
            e.tips:AddDoubleLine(
                (info.Keystone.weekNum or 0)
                .. (info.Keystone.weekMythicPlus and ' |cnGREEN_FONT_COLOR:('..info.Keystone.weekMythicPlus..') ' or '')
                ..WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true})
                ..(info.Keystone.score and ' ' or '')..(WoWTools_WeekMixin:KeystoneScorsoColor(info.Keystone.score)),
                info.Keystone.link)
        end
    end
    e.tips:Show()
end

local function set_EncounterJournal_Money_Tips(self)--险指南界面, 钱
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    local numPlayer, allMoney  = 0, 0
    for guid, info in pairs(e.WoWDate or {}) do
        if info.Money then
            e.tips:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo({ guid=guid, faction=info.faction, reName=true, reRealm=true}), C_CurrencyInfo.GetCoinTextureString(info.Money))
            numPlayer=numPlayer+1
            allMoney= allMoney + info.Money
        end
    end
    if allMoney==0 then
        e.tips:AddDoubleLine(e.onlyChinese and '钱' or MONEY, e.onlyChinese and '无' or NONE)
    else
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '角色' or CHARACTER)..' '..numPlayer..' '..(e.onlyChinese and '总计：' or FROM_TOTAL)..WoWTools_Mixin:MK(allMoney/10000, 3), C_CurrencyInfo.GetCoinTextureString(allMoney))
    end
    e.tips:Show()
end

















--############################
--BOSS战时, 指定拾取, 专精, 事件
--############################
local function set_Loot_Spec_Event()
    if Save().hideEncounterJournal then
        panel:UnregisterEvent('ENCOUNTER_START')
        panel:UnregisterEvent('ENCOUNTER_END')
    else
        panel:RegisterEvent('ENCOUNTER_START')
        panel:RegisterEvent('ENCOUNTER_END')
    end
end










--################
--冒险指南界面初始化
--################
local function Init_EncounterJournal()--冒险指南界面
    Button= WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {icon=not Save().hideEncounterJournal, size={22,22}})--按钮, 总开关
    Button:SetPoint('RIGHT',-22, -2)
    function Button:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
        e.tips:AddDoubleLine(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, e.GetEnabeleDisable(not Save().hideEncounterJournal).. e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '奖励' or QUEST_REWARDS, e.GetShowHide(not Save().hideEncounterJournal_All_Info_Text)..e.Icon.right)
        e.tips:Show()
    end
    Button:SetScript('OnEnter', Button.set_Tooltips)
    Button:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            Save().hideEncounterJournal= not Save().hideEncounterJournal and true or nil
            self:set_Shown()
            self:SetNormalAtlas(Save().hideEncounterJournal and e.Icon.disabled or e.Icon.icon )
            set_Loot_Spec_Event()--BOSS战时, 指定拾取, 专精, 事件
            e.call(EncounterJournal_ListInstances)

        elseif d=='RightButton' then
            Save().hideEncounterJournal_All_Info_Text= not Save().hideEncounterJournal_All_Info_Text and true or nil
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
        end
        self:set_Tooltips()
    end)
    Button:SetScript("OnLeave",GameTooltip_Hide)
    Button.btn={}

    Button.btn.instance =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--所有角色副本
    Button.btn.instance:SetPoint('RIGHT', Button, 'LEFT')
    Button.btn.instance:SetNormalAtlas('animachannel-icon-kyrian-map')
    Button.btn.instance:SetScript('OnEnter',function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine((e.onlyChinese and '副本' or INSTANCE)..e.Icon.left..e.GetShowHide(Save().showInstanceBoss), e.onlyChinese and '已击杀' or DUNGEON_ENCOUNTER_DEFEATED)
        e.tips:AddLine(' ')
        for guid, info in pairs(e.WoWDate or {}) do
            if guid and info then
                local find
                for bossName, tab in pairs(info.Instance.ins) do----ins={[名字]={[难度]=已击杀数}}
                    local text
                    for difficultyName, killed in pairs(tab) do
                        text= (text and text..' ' or '')..difficultyName..killed
                    end
                    e.tips:AddDoubleLine(bossName, text)
                    find= true
                end
                if find then
                    e.tips:AddLine(WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}))
                end
            end
        end
        e.tips:Show()
    end)
    Button.btn.instance:SetScript("OnLeave",GameTooltip_Hide)
    Button.btn.instance:SetScript('OnClick', function()
        if  Save().showInstanceBoss then
            Save().showInstanceBoss=nil
        else
            Save().showInstanceBoss=true
            Save().hideInstanceBossText=nil
        end
        WoWTools_EncounterMixin:InstanceBoss_Settings()
        if panel.instanceBoss then
            panel.instanceBoss:SetButtonState('PUSHED')
        end
    end)


    Button.btn.Worldboss =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--所有角色已击杀世界BOSS
    Button.btn.Worldboss:SetPoint('RIGHT', Button.btn.instance, 'LEFT')
    Button.btn.Worldboss:SetNormalAtlas('poi-soulspiritghost')
    Button.btn.Worldboss:SetScript('OnEnter',function(self)
        WoWTools_EncounterMixin:GetWorldData(self)
    end)--提示
    Button.btn.Worldboss:SetScript('OnMouseDown', function(self2, d)
        if  Save().showWorldBoss then
            Save().showWorldBoss=nil
        else
            Save().showWorldBoss=true
            Save().hideWorldBossText=nil
        end
        WoWTools_EncounterMixin:WorldBoss_Settings()
        if panel.WorldBoss then
            panel.WorldBoss:SetButtonState('PUSHED')
        end
    end)
    Button.btn.Worldboss:SetScript("OnLeave",GameTooltip_Hide)

    if e.Player.levelMax then
        Button.btn.keystones =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--所有角色,挑战
        Button.btn.keystones:SetPoint('RIGHT', Button.btn.Worldboss, 'LEFT')
        Button.btn.keystones:SetNormalTexture(4352494)
        Button.btn.keystones:SetScript('OnEnter',set_EncounterJournal_Keystones_Tips)
        Button.btn.keystones:SetScript("OnLeave",GameTooltip_Hide)
        Button.btn.keystones:SetScript('OnMouseDown', function()
            PVEFrame_ToggleFrame('ChallengesFrame', 3)
        end)
    end
    Button.btn.money =WoWTools_ButtonMixin:Cbtn(EncounterJournal.TitleContainer, {icon='hide', size={22,22}})--钱
    Button.btn.money:SetPoint('RIGHT', Button.btn.keystones or Button.btn.Worldboss, 'LEFT')
    Button.btn.money:SetNormalAtlas('Front-Gold-Icon')
    Button.btn.money:SetScript('OnEnter',set_EncounterJournal_Money_Tips)
    Button.btn.money:SetScript("OnLeave",GameTooltip_Hide)


    function Button:set_Shown()
        for _, btn in pairs(self.btn) do
            btn:SetShown(not Save().hideEncounterJournal)
        end
    end

    Button:set_Shown()





    





















    --Boss, 战利品, 信息
    hooksecurefunc(EncounterJournalItemMixin,'Init', function(btn)--Blizzard_EncounterJournal.lua
        local itemText--专精图标, 幻化，坐骑，宠物
        local tips--itemText提示用
        local classText--物品专精
        local upText--升级：


        local slotText= btn.slot and btn.slot:GetText()
        local isEquipItem= not Save().hideEncounterJournal and slotText and slotText~=''--是装备物品
        if not Save().hideEncounterJournal and btn.link then
            if isEquipItem then
                local specTable = C_Item.GetItemSpecInfo(btn.link) or {}--专精图标
                local specTableNum=#specTable
                if specTableNum>0 then
                    local specA=''
                    local class
                    table.sort(specTable, function (a2, b2) return a2<b2 end)
                    tips= e.onlyChinese and '拾取专精' or format(PROFESSIONS_SPECIALIZATION_TITLE, UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LOOT )
                    for _,  specID in pairs(specTable) do
                        local _, name,_, icon2, _, classFile= GetSpecializationInfoByID(specID)
                        if icon2 and classFile then
                            specA = specA..((class and class~=classFile) and '  ' or '')..'|T'..icon2..':0|t'
                            class=classFile
                            tips= tips..'|n|T'..icon2..':0|t'..e.cn(name)
                        end
                    end
                    if specA~='' then
                        itemText= (itemText or '')..specA
                    end

                end
                --物品是否收集, 返回图标, 幻化
                local item, collected, isSelf = WoWTools_CollectedMixin:Item(btn.link, nil, true)
                if item and not collected then
                    itemText= (itemText or '')..item
                    tips= tips and tips..'|n|n' or ''
                    tips= tips
                        ..item
                        ..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
                        ..(not isSelf and ' |cffffffff'..(e.onlyChinese and '其他职业' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OTHER, CLASS))..'|r' or '')
                end
            else
                local itemID= btn.itemID or C_Item.GetItemInfoInstant(btn.link)
                if itemID then
                    itemText= WoWTools_CollectedMixin:Mount(nil, itemID)--坐骑物品
                    itemText= itemText or select(3, WoWTools_CollectedMixin:Pet(nil, itemID, true))--宠物物品
                    itemText= itemText or WoWTools_CollectedMixin:Toy(itemID)--玩具,是否收集
                end
            end

            --拾取, 职业
            --local classStr= format(ITEM_CLASSES_ALLOWED, '(.+)')
            --local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"

            local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=btn.link, text={ITEM_CLASSES_ALLOWED, ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT}, red=true})--物品提示，信息 format(ITEM_CLASSES_ALLOWED, '(.+)') --"职业：%s"
            classText= dateInfo.text[ITEM_CLASSES_ALLOWED]
            upText= dateInfo.text[ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT]
            if classText then
                if WoW_Tools_Chinese_CN then--汉化

                    classText= string.gsub(classText..', ', '(.-), ', function(a)
                        local b= e.cn(a)
                        if b then
                            return b..' '
                        end
                    end)
                end
                local className= UnitClass('player')
                local locaClass= className and not classText:find(className) or dateInfo.red

                if locaClass then
                    classText =  '|cff9e9e9e'..classText..'|r'
                end
            end

        end

        if itemText and not btn.itemText then
            btn.itemText= WoWTools_LabelMixin:CreateLabel(btn, {mouse=true, fontName='GameFontBlack', notFlag=true, color={r=0.25, g=0.1484375, b=0.02}, notShadow=true, layer='OVERLAY'})
            btn.itemText:SetPoint('TOPRIGHT', -10,-4)
            btn.itemText:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
            btn.itemText:SetScript('OnEnter', function(self)
                if self.tips then
                    e.tips:SetOwner(self, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddLine(self.tips)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
                    e.tips:Show()
                end
                self:SetAlpha(0.3)
            end)
        end
        if btn.itemText then
            btn.itemText:SetText(itemText or '')
            btn.itemText.tips= tips
        end

        --拾取, 职业
        if classText and not btn.classLable then
            btn.classLable= WoWTools_LabelMixin:CreateLabel(btn, {fontName='GameFontBlack', notFlag=true, color={r=0.25, g=0.1484375, b=0.02}, notShadow=true, layer='OVERLAY'})
            btn.classLable:SetPoint('BOTTOM', btn.IconBorder, 'BOTTOMRIGHT', 140, 4)--<Size x="321" y="45"/>
        end
        if btn.classLable then
            btn.classLable:SetText(classText or '')
        end

        if upText and not btn.upText then
            btn.upText= WoWTools_LabelMixin:CreateLabel(btn, {fontName='GameFontBlack', notFlag=true, color={r=0.25, g=0.1484375, b=0.02}, notShadow=true, layer='OVERLAY'})
            btn.upText:SetPoint('TOPRIGHT', -10,-16)
        end
        if btn.upText then
            btn.upText:SetText(upText or '')
        end

        --显示, 物品, 属性
        WoWTools_ItemStatsMixin:SetItem(btn, not Save().hideEncounterJournal and btn.link, {point= btn.IconBorder})

        local spellID--物品法术，提示
        if (btn.link or btn.itemID) and not Save().hideEncounterJournal then
            spellID= select(2, C_Item.GetItemSpell(btn.link or btn.itemID))
            if spellID and not btn.spellTexture then
                btn.spellTexture= btn:CreateTexture(nil, 'OVERLAY')
                btn.spellTexture:SetSize(16,16)
                btn.spellTexture:SetPoint('LEFT', btn.IconBorder, 'RIGHT',-6,0)
                btn.spellTexture:SetScript('OnMouseDown', function(self)
                    if self.spellID then
                        WoWTools_ChatMixin:Chat( C_Spell.GetSpellLink(self.spellID) or self.spellID, nil, true)
                    end
                end)
                btn.spellTexture:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
                btn.spellTexture:SetScript('OnEnter', function(self)
                    if self.spellID then
                        e.tips:SetOwner(self, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:SetSpellByID(self.spellID)
                        e.tips:Show()
                    end
                    self:SetAlpha(0.5)
                end)
            end
        end
        if btn.spellTexture then
            btn.spellTexture.spellID= spellID
            btn.spellTexture:SetShown(spellID and true or false)
            if spellID then
                e.LoadData({id=spellID, type='spell'})
                SetPortraitToTexture(btn.spellTexture, C_Spell.GetSpellTexture(spellID) or 'soulbinds_tree_conduit_icon_utility')
            end
        end
    end)

















    --#######################
    --BOSS战时, 指定拾取, 专精
    --#######################
    local function set_Loot_Spec_Texture(self)
        if self.dungeonEncounterID then
        
            local specID=Save().loot[e.Player.class][self.dungeonEncounterID]
            local icon= specID and select(4, GetSpecializationInfoByID(specID))
            if icon then
                self:SetNormalTexture(icon)
            else
                self:SetNormalAtlas(e.Icon.icon)
            end
            self:SetAlpha(icon and 1 or 0.3)
        end
        self:SetShown(self.dungeonEncounterID)
    end


    local function set_Loot_Spec_Menu_Init(self, level, type)
        local info
        if type=='CLEAR' then
            for class= 1, GetNumClasses() do
                local classInfo = C_CreatureInfo.GetClassInfo(class)
                if classInfo and classInfo.classFile then
                    Save().loot[classInfo.classFile]= Save().loot[classInfo.classFile] or {}
                    local n=0
                    for _, _ in pairs(Save().loot[classInfo.classFile]) do
                        n= n+1
                    end
                    local col= select(4, GetClassColor(classInfo.classFile))
                    col= col and '|c'..col or col
                    info={
                        text= (WoWTools_UnitMixin:GetClassIcon(nil, classInfo.classFile) or '')..e.cn(classInfo.className)..(e.Player.class==classInfo.classFile and '|A:auctionhouse-icon-favorite:0:0|a' or '')..(n>0 and ' |cnGREEN_FONT_COLOR:#'..n..'|r' or ''),
                        colorCode= col,
                        notCheckable=true,
                        arg1= classInfo.classFile,
                        arg2= classInfo.className,
                        hasArrow= n>0,
                        menuList= classInfo.classFile,
                        func= function(_, arg1, arg2)
                            Save().loot[arg1]={}
                            print(e.addName, WoWTools_EncounterMixin.addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, WoWTools_UnitMixin:GetClassIcon(nil, arg1), arg2, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH)))
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end
            end
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            info={
                text= e.onlyChinese and '全部清除' or CLEAR_ALL,
                icon='bags-button-autosort-up',
                notCheckable=true,
                func= function()
                    Save().loot={[e.Player.class]={}}
                    print(e.addName, WoWTools_EncounterMixin.addName, e.onlyChinese and '全部清除' or CLEAR_ALL, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH)))
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            return
        elseif type then
            local col= select(4, GetClassColor(type))
            col= col and '|c'..col or col
            for dungeonEncounterID, specID in pairs(Save().loot[type]) do
                info={
                    text='dungeonEncounterID |cnGREEN_FONT_COLOR:'..dungeonEncounterID..'|r',
                    icon= select(4,  GetSpecializationInfoByID(specID)),
                    colorCode= col,
                    notCheckable= true,
                    arg1=type,
                    arg2=dungeonEncounterID,
                    func= function(_, arg1, arg2)
                        Save().loot[arg1][arg2]=nil
                        print(e.addName, WoWTools_EncounterMixin.addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, WoWTools_UnitMixin:GetClassIcon(nil, arg1), arg2, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH)))
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
            return
        end

        local curSpec= GetSpecialization()
        local find
        for specIndex= 1, GetNumSpecializations() do
            local specID, name, _ , icon= GetSpecializationInfo(specIndex)
            if icon and specID and name then
                e.LibDD:UIDropDownMenu_AddButton({
                    text=e.cn(name)..(curSpec==specIndex and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
                    colorCode= e.Player.col,
                    icon=icon,
                    checked= Save().loot[e.Player.class][self.dungeonEncounterID]== specID,
                    tooltipOnButton=true,
                    tooltipTitle= self.encounterID and EJ_GetEncounterInfo(self.encounterID) or '',
                    tooltipText= 'specID '..specID..'|n'..(self.dungeonEncounterID and 'dungeonEncounterID '..self.dungeonEncounterID or ''),
                    arg1= {
                        dungeonEncounterID=self.dungeonEncounterID,
                        specID= specID,
                        button=self.button},
                    func=function(_,arg1)
                        if not Save().loot[e.Player.class][arg1.dungeonEncounterID] or Save().loot[e.Player.class][arg1.dungeonEncounterID]~= arg1.specID then
                            Save().loot[e.Player.class][arg1.dungeonEncounterID]=arg1.specID
                        else
                            Save().loot[e.Player.class][arg1.dungeonEncounterID]=nil
                        end
                        set_Loot_Spec_Texture(arg1.button)
                    end
                }, level)
                find=true
            end
        end
        if find then
            info= {
                text= e.onlyChinese and '无' or NONE,
                icon= 'xmarksthespot',
                checked= not Save().loot[e.Player.class][self.dungeonEncounterID],
                arg1= self.dungeonEncounterID,
                arg2= self.button,
                --keepShownOnClick=true,
                func=function(_,arg1, arg2)
                    Save().loot[e.Player.class][arg1]=nil
                    set_Loot_Spec_Texture(arg2)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        local name=self.encounterID and EJ_GetEncounterInfo(self.encounterID)
        if name and self.dungeonEncounterID then
            info= {
                text= e.cn(name)..' '..self.dungeonEncounterID,
                notCheckable=true,
                isTitle=true,
            }
        end
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
            notCheckable=true,
            hasArrow=true,
            menuList='CLEAR',
            keepShownOnClick=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        --e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION,
            icon= WoWTools_UnitMixin:GetClassIcon('player', e.Player.class, true) or  'Banker',
            isTitle=true,
            notCheckable=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text=id..' '..WoWTools_EncounterMixin.addName,
            isTitle=true,
            notCheckable=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    local function set_Loot_Spec(button)
        if not button.LootButton then
            button.LootButton= WoWTools_ButtonMixin:Cbtn(button, {size={20,20}, icon='hide'})
            button.LootButton:SetPoint('LEFT', button, 'RIGHT')
            button.LootButton:SetNormalAtlas(e.Icon.icon)
            button.LootButton:SetScript('OnMouseDown', function(self)
                local menu= EncounterJournal.encounter.LootSpecMenu
                if not menu then
                    menu= CreateFrame("Frame", nil, EncounterJournal.encounter, "UIDropDownMenuTemplate")
                    e.LibDD:UIDropDownMenu_Initialize(menu, set_Loot_Spec_Menu_Init, 'MENU')
                end
                menu.dungeonEncounterID=self.dungeonEncounterID
                menu.button=self
                menu.encounterID= self.encounterID
                e.LibDD:ToggleDropDownMenu(1, nil, menu, self, 15,0)
            end)
        end
        local dungeonEncounterID= button.encounterID and select(7, EJ_GetEncounterInfo(button.encounterID))
        button.LootButton.dungeonEncounterID= dungeonEncounterID
        button.LootButton.encounterID= button.encounterID
        set_Loot_Spec_Texture(button.LootButton)
        button.LootButton:SetShown(not Save().hideEncounterJournal)
    end


    EncounterJournal.encounter.instance.mapButton:SetScript('OnEnter', function(self3)--综述,小地图提示
        local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, _, mapID= EJ_GetInstanceInfo()
        if not name then
            return
        end
        e.tips:SetOwner(self3, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(link or name, (dungeonAreaMapID and 'UiMapID|cnGREEN_FONT_COLOR:'..dungeonAreaMapID..'|r' or '')..(mapID and ' mapID|cnGREEN_FONT_COLOR:'..mapID..'|r' or ''))
        e.tips:AddLine(' ')
        e.tips:AddLine(description, nil,nil,nil, true)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(bgImage and '|T'..bgImage..':26|t'..bgImage, loreImage and '|T'..loreImage..':26|t'..loreImage)
        e.tips:AddDoubleLine(buttonImage1 and '|T'..buttonImage1..':26|t'..buttonImage1, buttonImage2 and '|T'..buttonImage2..':26|t'..buttonImage2)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
        e.tips:Show()
    end)
    EncounterJournal.encounter.instance.mapButton:SetScript('OnLeave', GameTooltip_Hide)


    hooksecurefunc(EncounterJournal.encounter.info.BossesScrollBox, 'SetScrollTargetOffset', function(frame)
        if not frame:GetView() then
            return
        end
        for _, button in pairs(frame:GetFrames()) do
            if not button.OnEnter then
                button:SetScript('OnEnter', function(self)
                    if not Save().hideEncounterJournal and self.encounterID then
                        local name2, _, journalEncounterID, rootSectionID, _, journalInstanceID, dungeonEncounterID, instanceID2= EJ_GetEncounterInfo(self.encounterID)--button.index= button.GetOrderIndex()
                        e.tips:SetOwner(self, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        local cnName= e.cn(name2, true)
                        e.tips:AddDoubleLine(cnName and cnName..' '..name2 or name2,  'journalEncounterID: '..'|cnGREEN_FONT_COLOR:'..(journalEncounterID or self.encounterID)..'|r')
                        e.tips:AddDoubleLine(instanceID2 and 'instanceID: '..instanceID2 or ' ', (rootSectionID and rootSectionID>0) and 'JournalEncounterSectionID: '..rootSectionID or ' ')
                        if dungeonEncounterID then
                            e.tips:AddDoubleLine('dungeonEncounterID: |cffff00ff'..dungeonEncounterID, (journalInstanceID and journalInstanceID>0) and 'journalInstanceID: '..journalInstanceID or ' ' )
                            local numKill=Save().wowBossKill[dungeonEncounterID]
                            if numKill then
                                e.tips:AddDoubleLine(e.onlyChinese and '击杀' or KILLS, '|cnGREEN_FONT_COLOR:'..numKill..' |r'..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
                            end
                        end
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
                        e.tips:Show()
                    end
                end)
                button:SetScript('OnLeave', GameTooltip_Hide)
            end
            set_Loot_Spec(button)--BOSS战时, 指定拾取, 专精
        end
    end)






















    --战利品, 套装, 收集数 Blizzard_LootJournalItems.lua
    if EncounterJournal.LootJournalItems.ItemSetsFrame and EncounterJournal.LootJournalItems.ItemSetsFrame.ScrollBox and EncounterJournal.LootJournalItems.ItemSetsFrame.ScrollBox.Update then
        hooksecurefunc(EncounterJournal.LootJournalItems.ItemSetsFrame.ScrollBox, 'Update', function(self)
            local view = self:GetView()
            if not view or not view.frames then
                return
            end
            for _, frame in pairs(view.frames) do
                local coll, all, text= 0, 0, nil
                for _, btn in pairs(frame.ItemButtons or {}) do
                    local has= false
                    local itemLink= not Save().hideEncounterJournal and btn:IsShown() and btn.itemLink
                    if itemLink then--itemID
                        has = C_TransmogCollection.PlayerHasTransmogByItemInfo(itemLink)
                        all= all+1
                        coll= has and coll+1 or coll
                    end
                    WoWTools_ItemStatsMixin:SetItem(btn, itemLink, {hideLevel=true, hideSet=true})

                    if has and not btn.collection then
                        btn.collection= btn:CreateTexture()
                        btn.collection:SetSize(10,10)
                        btn.collection:SetPoint('TOP', btn, 'BOTTOM',0,2)
                        btn.collection:SetAtlas(e.Icon.select)
                    end
                    if btn.collection then
                        btn.collection:SetShown(has)
                    end
                end
                if not frame.setNum then
                    frame.setNum= WoWTools_LabelMixin:CreateLabel(frame)
                    frame.setNum:SetPoint('RIGHT', frame.SetName)
                end
                if all>0 then
                    if coll==all then
                        text= format('|A:%s:0:0|a', e.Icon.select)
                    else
                        text= format('%s%d/%d', coll==0 and '|cff9e9e9e' or '', coll, all)
                    end
                end
                frame.setNum:SetText(text or '')
            end

        end)
    end













    --BOSS技能 Blizzard_EncounterJournal.lua
    local function EncounterJournal_SetBullets_setLink(text)--技能加图标
        local find
        text=text:gsub('|Hspell:.-]|h',function(link)
            local texture= link:match('Hspell:(%d+)')
            if texture then
                local icon= C_Spell.GetSpellTexture(texture)
                if icon then
                    find=true
                    return '|T'..icon..':0|t'..link
                end
            end
        end)
        if find then
            return text
        end
    end
    hooksecurefunc('EncounterJournal_SetBullets', function(object, description, hideBullets)
        if Save().hideEncounterJournal then
            return
        end
        if not string.find(description, "%$bullet") then
            local text=EncounterJournal_SetBullets_setLink(description)
            if text then
                object.Text:SetText(text)
                object:SetHeight(object.Text:GetContentHeight())
            end
            return
        end
        local desc = strtrim(string.match(description, "(.-)%$bullet"))
        if (desc) then
            local text=EncounterJournal_SetBullets_setLink(desc)
            if text then
                object.Text:SetText(text)
                object:SetHeight(object.Text:GetContentHeight())
            end
        end

        local bullets = {}
        local k = 1
        local parent = object:GetParent()
        for v in string.gmatch(description,"%$bullet([^$]+)") do
            tinsert(bullets, v)
        end
        for j = 1,#bullets do
            local text = strtrim(bullets[j]).."|n|n"
            if (text and text ~= "") then
                text=EncounterJournal_SetBullets_setLink(text)
			    local bullet = parent.Bullets and parent.Bullets[k]
                if text and bullet then
                    bullet.Text:SetText(text)
                    if (bullet.Text:GetContentHeight() ~= 0) then
                        bullet:SetHeight(bullet.Text:GetContentHeight())
                    end
                end
                k = k + 1
            end
        end
    end)

    hooksecurefunc('EncounterJournal_UpdateButtonState', function(frame)--技能提示
        if frame.hook then
            return
        end

        frame:HookScript("OnEnter", function(self)
            local spellID= self:GetParent().spellID--self3.link
            e.LoadData({id=spellID, type='spell'})
            if not Save().hideEncounterJournal and spellID and spellID>0 then
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(spellID)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine((IsInGroup() and '|A:communities-icon-chat:0:0|a' or '')..(e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT), e.Icon.right)
                e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
                e.tips:Show()
            end
        end)
        frame:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
        frame:HookScript('OnClick', function(self, d)
            local spellID= self:GetParent().spellID--self3.link
            if not Save().hideEncounterJournal and spellID and spellID>0 and d=='RightButton' then
                local link= C_Spell.GetSpellLink(spellID) or spellID
                WoWTools_ChatMixin:Chat(link, nil, not IsInGroup())
            end
        end)
        frame.hook=true
    end)

    --BOSS模型 Blizzard_EncounterJournal.lua
    hooksecurefunc('EncounterJournal_DisplayCreature', function(self)
        local text=''
        if not Save().hideEncounterJournal and self.displayInfo and EncounterJournal.encounter and EncounterJournal.encounter.info and EncounterJournal.encounter.info.model and EncounterJournal.encounter.info.model.imageTitle then
            if not EncounterJournal.creatureDisplayIDText then
                EncounterJournal.creatureDisplayIDText=WoWTools_LabelMixin:CreateLabel(self,{size=10, fontType=EncounterJournal.encounter.info.model.imageTitle})--10, EncounterJournal.encounter.info.model.imageTitle)
                EncounterJournal.creatureDisplayIDText:SetPoint('BOTTOM', EncounterJournal.encounter.info.model.imageTitle, 'TOP', 0 , 10)
            end
            if EncounterJournal.iconImage  then
                text= text..'|T'..EncounterJournal.iconImage..':0|t'..EncounterJournal.iconImage..'|n'
            end
            if self.id then
                text= text..'JournalEncounterCreatureID '.. self.id..'|n'
            end
            if self.uiModelSceneID  then
                text= text..'uiModelSceneID '..self.uiModelSceneID..'|n'
            end
            text= text..'CreatureDisplayID ' .. self.displayInfo
            local name= e.cn(self.name, true)--汉化
            if name then
                text= text..'|n'..name
            end
        end
        if EncounterJournal.creatureDisplayIDText then
            EncounterJournal.creatureDisplayIDText:SetText(text)
        end
    end)


















    --可能会，出错误，不知，不是这问题，不要删除
    --#####
    --贸易站
    --#####
    hooksecurefunc(EncounterJournalMonthlyActivitiesFrame.ScrollBox, 'SetScrollTargetOffset', function(self2)
        if Save().hideEncounterJournal or not self2:GetView() then
            return
        end
        for _, btn in pairs(self2:GetFrames()) do
            if not btn.showPerksActivityID then
                btn:HookScript('OnEnter', function(self3)
                    if self3.id and not Save().hideEncounterJournal then
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine('perksActivityID', self3.id)
                        e.tips:AddDoubleLine((self3.completed and '|cff9e9e9e' or '|cff00ff00')..(e.onlyChinese and '追踪' or TRACKING), e.Icon.left)
                        e.tips:AddDoubleLine((not C_PerksActivities.GetPerksActivityChatLink(self3.id) and '|cff9e9e9e' or '|cff00ff00')..(e.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK), e.Icon.right)
                        e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
                        e.tips:Show()
                    end
                end)

                btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
                btn:HookScript('OnClick', function(self3, d)
                    if IsModifierKeyDown() or not self3.id or Save().hideEncounterJournal then
                        return
                    end
                    if d=='RightButton' then
                        local link=C_PerksActivities.GetPerksActivityChatLink(self3.id)
                        WoWTools_ChatMixin:Chat(link, nil, true)


                    elseif d=='LeftButton' then
                        if self3.tracked then
                            C_PerksActivities.RemoveTrackedPerksActivity(self3.id)
                        elseif not self3.completed then
                            C_PerksActivities.AddTrackedPerksActivity(self3.id)
                        end
                    end
                end)

                btn.showPerksActivityID= true
            end
        end
    end)

    if not Save().hideEncounterJournal and Save().EncounterJournalTier then--记录上次选择TAB
        local max= EJ_GetNumTiers()
        if max then
            local tier= math.min(Save().EncounterJournalTier, max)
            if tier~= max then
                EJ_SelectTier(tier)
            end
        end
    end

    --记录上次选择版本
    hooksecurefunc('EJ_SelectTier', function(tier)
        Save().EncounterJournalTier=tier
    end)
end




















--######
--初始化
--######
local function Init()
   
    WoWTools_EncounterMixin:Init_DungeonEntrancePin()--世界地图，副本，提示
    WoWTools_EncounterMixin:WorldBoss_Settings()
    WoWTools_EncounterMixin:InstanceBoss_Settings()
end





















--###########
--加载保存数据
--###########
local lootSpceLog--BOSS战时, 指定拾取, 专精, 还原, 专精拾取
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            
            WoWTools_EncounterMixin.Save= WoWToolsSave['Adventure_Journal'] or Save()

            Save().loot[e.Player.class]= Save().loot[e.Player.class] or {}

            WoWTools_EncounterMixin.addName= '|A:UI-HUD-MicroMenu-AdventureGuide-Mouseover:0:0|a'..(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL)

            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_EncounterMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_EncounterMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })


            if Save().disabled then
                self:UnregisterAllEvents()
            else
                if not Save().hideEncounterJournal then
                    set_Loot_Spec_Event()--BOSS战时, 指定拾取, 专精, 事件
                end

                Init()
            end
            self:RegisterEvent("PLAYER_LOGOUT")


        elseif arg1=='Blizzard_EncounterJournal' then---冒险指南
            WoWTools_EncounterMixin:Init_UI_ListInstances()
            Init_EncounterJournal()--冒险指南界面
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
            self:RegisterEvent('BOSS_KILL')
            self:RegisterEvent('UPDATE_INSTANCE_INFO')
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('WEEKLY_REWARDS_UPDATE')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Adventure_Journal']=Save
        end

    elseif event=='UPDATE_INSTANCE_INFO' then
        C_Timer.After(2, function()
            WoWTools_EncounterMixin:InstanceBoss_Settings()--显示副本击杀数据
            WoWTools_EncounterMixin:WorldBoss_Settings()--显示世界BOSS击杀数据Text
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
        end)

    elseif event=='BOSS_KILL' and arg1 then
        Save().wowBossKill[arg1]= Save().wowBossKill[arg1] and Save().wowBossKill[arg1] +1 or 1--Boss击杀数量

    elseif event=='WEEKLY_REWARDS_UPDATE' then
        C_Timer.After(2, function()
            WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
        end)

    elseif event=='ENCOUNTER_START' and arg1 then--BOSS战时, 指定拾取, 专精
        local indicatoSpec=Save().loot[e.Player.class][arg1]
        if indicatoSpec then
            local loot = GetLootSpecialization()
            local spec = GetSpecialization()
            spec= spec and GetSpecializationInfo(spec)
            local loot2= loot==0 and spec or loot
            if loot2~= indicatoSpec then
                lootSpceLog= loot
                SetLootSpecialization(indicatoSpec)
                local _, name, _, icon, role = GetSpecializationInfoByID(indicatoSpec)
                print(e.addName, WoWTools_EncounterMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)..'|r', e.Icon[role], icon and '|T'..icon..':0|t', name and '|cffff00ff'..name)
            end
        end

    elseif event=='ENCOUNTER_END' then--BOSS战时, 指定拾取, 专精, 还原, 专精拾取
        if lootSpceLog  then
            SetLootSpecialization(lootSpceLog)
            if lootSpceLog==0 then
                local spec = GetSpecialization()
                lootSpceLog= spec and GetSpecializationInfo(spec) or lootSpceLog
            end
            local _, name, _, icon, role = GetSpecializationInfoByID(lootSpceLog)
            print(e.addName, WoWTools_EncounterMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)..'|r', e.Icon[role], icon and '|T'..icon..':0|t', name and '|cffff00ff'..name)
            lootSpceLog=nil
        end
    end
end)