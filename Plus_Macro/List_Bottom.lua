--命令，按钮，列表
local e= select(2, ...)
local function Save()
    return WoWTools_MacroMixin.Save
end
local Frame





--'/cast [@cursor]'..name
local CursorTab={
    [145205]= true,--[百花齐放]xd

    [192077]= true,--[狂风图腾]
    [192058]= true,--[电能图腾]sm
    [51485]= true,--[陷地图腾]sm
    [192222]= true,--[岩浆图腾]sm
    [198838]= true,--[大地之墙图腾]sm
    [2484]= true,--[地缚图腾]
    [73920]= true,--[治疗之雨]sm
    [61882]= true,--[地震术]sm
    [6196]= true,--[视界术]sm

    [358385]= true,--[山崩]dm
    [357210]= true,--[深呼吸]dm

    [113724]= true,--[冰霜之环]fs
    [2120]= true,--[烈焰风暴]fs
    [190356]= true,--[暴风雪]fs
    [198149]= true,--[寒冰宝珠]fs PVP天赋

    [187650]= true,--[冰冻陷阱]lr
    [187698]= true,--[焦油陷阱]lr
    [109248]= true,--[束缚射击]lr
    [162488]= true,--[精钢陷阱]lr
    [236776]= true,--[高爆陷阱]lr
    [1543]= true,--[照明弹]lr
    [6197]= true,--[鹰眼术]lr
    [260243]= true,--[乱射]lr
    [257284]= true,--[猎人印记]lr
    [190925]= true,--[鱼叉猛刺]lr

    [30283]= true,--[暗影之怒]ss
    [1122]= true,--[召唤地狱火]ss
    [152108]= true,--[大灾变]ss
    [5740]= true,--[火焰之雨]ss

    [453]= true,--[安抚心灵]ms
    [34861]= true,--[圣言术：灵]ms
    [62618]= true,--[真言术：障]ms
    [32375]= true,--[群体驱散]ms

    [195457]= true,--[抓钩]dz

    [189110]= true,--[地狱火撞击]dh
    [191427]= true,--[恶魔变形]dh
    [204596]= true,--[烈焰咒符]dh
    [202137]= true,--[沉默咒符]dh
    [390163]= true,--[极乐敕令]dh
    [207684]= true,--[悲苦咒符]dh
    [389807]= true,--[锁链咒符]dh
    [389810]= true,--[烈焰咒符]dh T
    [389815]= true,--[极乐敕令]dh T
    [389809]= true,--[沉默咒符]dh T

    [6544]= true,--[英勇飞跃]zs
    [818]= true,--/烹饪用火
}

--停止施法 '/stopcasting\n/cast '..name
local StopCastingTab={
    [78675]= true,--[日光术]xd
    [33786]= true,--[旋风]xd

    [57994]= true,--[风剪]sm
    [51490]= true,--[雷霆风暴]sm
    [108271]= true,--[星界转移]

    [45438]= true,--[寒冰屏障]fs
    [2139]= true,--[法术反制]fs

    [147362]= true,--[反制射击]lr

    [104773]= true,--[不灭决心]ss
    [111400]= true,--[爆燃冲刺]ss
    [6789]= true,--[死亡缠绕]ss
    [710]= true,--[放逐术]ss
    [8122]= true,--[心灵尖啸]ms
    [15487]= true,--[沉默]ms
    [47585]= true,--[消散]ms
}

--设置，光标，焦点， 目标，再设置焦点，
local SetFocusTab={
    [118]= true,--[变形术]fs
    [34477]= true,--[误导]lr
    [5782]= true,--[恐惧]ss
    [57934]= true,--[嫁祸诀窍]dz
    [111673]= true,--[控制亡灵]
}

--'/cast '..name..'\n/y '..(C_Spell.GetSpellLink(spellID) or name)
local SayTab={
    [698]= true,--[召唤仪式]ss
    [29893]= true,--[制造灵魂之井]ss
    [111771]= true,--[恶魔传送门]ss
    [342601]= true,--[末日仪式]ss
    [20707]= true,--[灵魂石]ss
    [114018]= true,--[潜伏帷幕]DZ
    [2825]= true,--[嗜血]sm
    [414664]= true,--[群体隐形]fs
}













--常用，宏
local MacroList={
    {text='ping', icon='Ping_Map_Whole_Assist', macro=SLASH_PING1,
        tab={
            {text=SLASH_PING1},-- icon='Ping_Map_Whole_NonThreat'},
            {text=SLASH_PING1..' [target=mouseover,exists][target=target,exists]'..BINDING_NAME_PINGATTACK..'\n', icon='Ping_Map_Whole_Attack'},
            {text=SLASH_PING1..' [target=mouseover,exists][target=target,exists]'..BINDING_NAME_PINGASSIST..'\n', icon='Ping_Map_Whole_Assist'},
            {text=SLASH_PING1..' [target=mouseover,exists][target=target,exists]'..BINDING_NAME_PINGONMYWAY..'\n', icon='Ping_Map_Whole_OnMyWay'},
            {text=SLASH_PING1..' [target=mouseover,exists][target=target,exists]'..BINDING_NAME_PINGWARNING..'\n', icon='Ping_Map_Whole_Warning'}
        }
    },
    {text='worldmarker',  macro='/wm [@cursor]1',
        tab={
            {text='/wm [@cursor]1\n', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_6'},
            {text='/wm [@cursor]2\n', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_4'},
            {text='/wm [@cursor]3\n', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_3'},
            {text='/wm [@cursor]4\n', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_7'},
            {text='/wm [@cursor]5\n', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_1'},
            {text='/wm [@cursor]6\n', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_2'},
            {text='/wm [@cursor]7\n', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_5'},
            {text='/wm [@cursor]8\n', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_8'},
            {text='/cwm 0\n', icon='talents-button-reset'},
        }
    },
    {text= 'SetRaidTarget', macro='/target [@mouseover]\n/script SetRaidTarget("target",1)',
        tab={
            {text='/target [@mouseover]\n/script SetRaidTarget("target",1)', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_1'},
            {text='/target [@mouseover]\n/script SetRaidTarget("target",2)', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_2'},
            {text='/target [@mouseover]\n/script SetRaidTarget("target",3)', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_3'},
            {text='/target [@mouseover]\n/script SetRaidTarget("target",4)', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_4'},
            {text='/target [@mouseover]\n/script SetRaidTarget("target",5)', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_5'},
            {text='/target [@mouseover]\n/script SetRaidTarget("target",6)', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_6'},
            {text='/target [@mouseover]\n/script SetRaidTarget("target",7)', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_7'},
            {text='/target [@mouseover]\n/script SetRaidTarget("target",8)', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_8'},
        }
    },
    {text='rt', macro='{rt1}',
        tab={
            {text='{rt1}', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_1'},
            {text='{rt2}', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_2'},
            {text='{rt3}', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_3'},
            {text='{rt4}', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_4'},
            {text='{rt5}', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_5'},
            {text='{rt6}', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_6'},
            {text='{rt7}', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_7'},
            {text='{rt8}', icon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_8'},
        }
    },
    {text='button',  macro='btn:1',
        tab={
            {text='btn:n', tips='OnClick()'},
            {text='bar:n', tips='GetActionBarPage()'},
            {text='bonusbar, bonusbar:n', tips='HasBonusActionBar()'},
            {text='cursor', tips='GetCursorInfo()'},
            {text='extrabar', tips='HasExtraActionBar()'},
            {text='mod, mod:key, mod:action', tips='IsModifierKeyDown() or IsModifiedClick(action)'},
            {text='overridebar', tips='HasOverrideActionBar()'},
            {text='possessbar', tips='possessbar'},
            {text='shapeshift', tips='HasTempShapeshiftActionBar()'},
            {text='vehicleui', tips='HasVehicleActionBar()'},
        }
    },
    {text='@target',  macro='[@target]',
        tab={
            {text='exists', tips='UnitExists()'},
            {text='help', tips='UnitCanAssist()'},
            {text='harm', tips='UnitCanAttack()'},
            {text='dead', tips='UnitIsDeadOrGhost()'},
            {text='party', tips='	UnitInParty() '},

            {text='raid', tips='UnitInRaid()'},
            {text='unithasvehicleui', tips='UnitInVehicle()'},
        }
    },
    {text='@player',  macro='[@player]',
        tab={

            {text='canexitvehicle', tips='CanExitVehicle()'},
            {text='channeling, channeling:spellName', tips='UnitChannelInfo("player")'},
            {text='combat', tips='UnitAffectingCombat("player")'},
            {text='equipped:type, worn:type', tips='IsEquippedItemType(type)'},
            {text='flyable', tips='IsFlyableArea()'},

            {text='form:n, stance:n', tips='form:n, stance:n'},
            {text='group, group:party, group:raid', tips='IsInGroup(), IsInRaid()'},
            {text='indoors', tips='IsIndoors()'},
            {text='outdoors', tips='IsOutdoors()'},
            {text='known:name', tips='GetSpellInfo(name)'},
            {text='known:spellID', tips='IsPlayerSpell(spellID)'},
            {text='mounted', tips='IsMounted()'},
            {text='pet:name, pet:family', tips='UnitCreatureFamily("pet")'},
            {text='petbattle', tips='C_PetBattles.IsInBattle()'},
            {text='pvpcombat', tips='PvP talents are usable'},
            {text='resting', tips='IsResting()'},
            {text='spec:n', tips='GetSpecialization()'},
            {text='stealth', tips='IsStealthed()'},
            {text='advflyable', tips='IsAdvancedFlyableArea()'},
            {text='swimming', tips='IsSubmerged()'},
            {text='flying', tips='IsFlying()'},
        }
    },
    {text='@mouseover', macro='[@mouseover]'},
    {text='@cursor', macro='[@cursor]'},
}













--自定义，职业，法术宏
--##################
local function Get_Spell_Macro(name, spellID)
    if spellID==6603 then--自动攻击
        return '/startattack'


    --MS
    elseif spellID==73325 then--[信仰飞跃]ms
        return '/cast [target=mouseover,help,exists][target=target,help,exists][target=targettarget,help,exists][target=focus,help,exists]'..name, name

    elseif spellID==232698 then--[暗影形态]
        return '/cast [noform]'..name, name

    --SS
    elseif spellID==6201 then--[制造治疗石]ss
        local right= C_Spell.GetSpellName(29893)--[制造灵魂之井] ss
        local alt= C_Spell.GetSpellName(6201)--[制造治疗石] ss
        local ctrl= C_Spell.GetSpellName(698)--[召唤仪式]ss
        local shift= C_Spell.GetSpellName(20707)--[灵魂石]ss
        local itemName= C_Item.GetItemInfo(5512)--[治疗石]ss
        if itemName and alt and ctrl and right and shift then
            return '/stopcasting'
                ..'\n/cast [mod:alt]'..alt
                ..'\n/cast [mod:ctrl]'..ctrl
                ..'\n/cast [mod:shift]'..shift
                ..'\n/use [btn:1]'..itemName
                ..'\n/cast [btn:2]'..right
        end
    elseif spellID==48018--[恶魔法阵]ss
        or spellID==48020--[恶魔法阵：传送]ss
    then
        local alt= C_Spell.GetSpellName(48018)
        local spellName= C_Spell.GetSpellName(48020)
        if alt and spellName then
            return '/cast [mod:alt,@cursor]'.. alt
                ..'\n/cast '..spellName
        end
    elseif spellID==755 then--[生命通道]ss
        return '/stopcasting\n/cast [target=pet]'..name

    --LR
    elseif spellID==5384 then--[假死]LR
        if IsSpellKnownOrOverridesKnown(209997) then
            local spellName= C_Spell.GetSpellName(209997)
            if spellName then
                return '/petfollow\n/cast '..spellName..'\n/cast '..name
            end
        end
        return '/petfollow\n/cast '..name
    elseif spellID==2643--[多重射击]LR
        or spellID==257620--[多重射击]LR
        or spellID==187708--[削凿]LR
    then
        local spellName= C_Spell.GetSpellName(186265)
        if spellName then
            return '/cancelaura '..spellName..'\n/cast '..name
        end

    --FS
    elseif spellID==212653--[闪光术]
        or spellID==1953--[闪现术]
        or spellID==66--[隐形术]
        or spellID==110959--[强化隐形术]
    then
        local cancel= C_Spell.GetSpellName(45438)--[寒冰屏障]
        local text='/stopcasting'
        if cancel then
            text= text..'\n/cancelaura '..cancel
        end
        return text..'\n/cast '..name

    --FS
    elseif spellID==190336 then--[造餐术]
        local spellName= C_Spell.GetSpellName(190336)
        local itemName= C_Item.GetItemNameByID(113509)
        if spellName and itemName then
            return '/use [btn:1]'..itemName..'\n/cast [btn:2]'..spellName
        end

    elseif spellID==130 then--[缓落术]
        return '/cast '..name..'\n/cancelaura [mod:alt]'..name



    --alt@player, @cursor
    elseif spellID==121536 --[天堂之羽]ms
        or spellID==43265--[枯萎凋零]dk
        or spellID==51052--[反魔法领域]
    then
        return '/cast [mod,@player][@cursor]'..name


    --mouseover， 或自已，Alt取消BUFF
    elseif spellID==1706 --[漂浮术]ms
        or spellID==546--[水上行走]sm
    then
        return '/cast [target=mouseover,help,exists][@player]'..name
            ..'\n/cancelaura [mod:alt]'..name

    --喊话
    elseif SayTab[spellID] then
        return '/cast '..name..'\n/y '..(C_Spell.GetSpellLink(spellID) or name)



--设置，光标，焦点， 目标，再设置焦点，
    elseif SetFocusTab[spellID] then
        return '/stopcasting\n/cast [target=mouseover,harm,exists][target=target,harm,exists][target=focus,harm,exists]'
            ..name..';'..name
            ..'\n/focus [target=focus,noexists][target=focus,dead]target'

--停止施法
    elseif StopCastingTab[spellID] then
        return '/stopcasting\n/cast '..name

--@cursor
    elseif CursorTab[spellID] then
        return '/cast [@cursor]'..name
    end
end















--二级，菜单
local function Sub_Menu(root, tab)
    local sub

--技能，提示
    WoWTools_SetTooltipMixin:Set_Menu(root)

    local body= tab.body

    sub=root:CreateButton(
         '|T'..(tab.icon or 134400)..':0|t'..(WoWTools_Mixin.onlyChinese and '新建' or NEW),
    function(data)
        WoWTools_MacroMixin:CreateMacroNew(' ', nil, data.body)--新建，宏
        return MenuResponse.Open
    end, {name=tab.name, icon=tab.icon, body=body, itemLink=tab.itemLink, spellID=tab.spellID})
    WoWTools_SetTooltipMixin:Set_Menu(sub)

    root:CreateDivider()

--修改，当前图标
    if tab.icon then
        sub=root:CreateButton(
            '|T'..(tab.icon or 0)..':0|t'
            ..(WoWTools_Mixin.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL)),
        function(data)
            if InCombatLockdown() then return end
            WoWTools_MacroMixin:SetMacroTexture(data.icon)
            return MenuResponse.Open
        end, tab)
        sub:SetEnabled(MacroFrameSelectedMacroButton:IsShown())
    end
--查询
    --[[if tab.spellID then
        sub=root:CreateButton(--bug
            '|A:common-search-magnifyingglass:0:0|a'..(WoWTools_Mixin.onlyChinese and '查询' or WHO),
        function(data)
            PlayerSpellsUtil.OpenToSpellBookTabAtSpell(data.spellID, false, true, false)--knownSpellsOnly, toggleFlyout, flyoutReason
            return MenuResponse.Open
        end, tab)
        WoWTools_SetTooltipMixin:Set_Menu(sub)--技能，提示
    end]]

--链接至聊天栏
    if tab.spellID or tab.itemLink then
        sub=root:CreateButton(
            (WoWTools_Mixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT),
        function(data)
            local link= data.itemLink or WoWTools_SpellMixin:GetLink(data.spellID, false)
            WoWTools_ChatMixin:Chat(link, nil, true)
            return MenuResponse.Open
        end, tab)
        WoWTools_SetTooltipMixin:Set_Menu(sub)--技能，提示
    end
end









--创建，法术，列表
--##############
local function Create_Spell_Menu(root, spellID, icon, name, index)--创建，法术，列表
    WoWTools_Mixin:Load({id=spellID, type='spell'})

    local macroText= Get_Spell_Macro(name, spellID)
    local info=  {name=name, spellID=spellID, icon=icon, tooltip=macroText}

    local sub=root:CreateButton(
        index..' '
        ..WoWTools_SpellMixin:GetName(spellID)--取得法术，名称
        ..(macroText and '|cnGREEN_FONT_COLOR:*|r' or ''),
    function(data)

        if InCombatLockdown() then return end

        local text=''
        local macroText2, showName= Get_Spell_Macro(data.name, data.spellID)
        local macro= MacroFrameText:GetText() or ''
        if not macro:find('#showtooltip') then
            text= '#showtooltip'..(showName and ' '..showName or '')..'\n'
        end
        if not macro:find('/targetenemy') then
            text= text..'/targetenemy [noharm][dead]\n'
        end
        text= text..(macroText2 or ('/cast '..data.name))..'\n'

        --新建，宏
        if not WoWTools_MacroMixin:GetSelectIndex() and WoWTools_MacroMixin:IsCanCreateNewMacro() then
            WoWTools_MacroMixin:CreateMacroNew(nil, nil, text)
        else
            --MacroFrameText:SetCursorPosition(0)
            MacroFrameText:Insert(text)
            MacroFrameText:SetFocus()
        end

        return MenuResponse.Open
    end, info)



        local macroText2, showName= Get_Spell_Macro(name, spellID)
        local body= '#showtooltip'..(showName and ' '..showName or '')..'\n'
        body= body..'/targetenemy [noharm][dead]\n'
        body= body..(macroText2 or ('/cast '..name))

    --二级，菜单
    Sub_Menu(sub, {
        icon=icon,
        spellID=spellID,
        name=' ',
        body=body,
    })
end




















local function Init_SpellBook_Menu(self, root)
    if WoWTools_MenuMixin:CheckInCombat(root) then--战斗中
        return
    end

    local info= C_SpellBook.GetSpellBookSkillLineInfo(self.index)
    local num=0
    if info and info.name and info.itemIndexOffset and info.numSpellBookItems and info.numSpellBookItems>0 then
        for index= info.itemIndexOffset+1, info.itemIndexOffset+ info.numSpellBookItems do
            local spellData= C_SpellBook.GetSpellBookItemInfo(index, Enum.SpellBookSpellBank.Player) or {}--skillLineIndex itemType isOffSpec subName actionID name iconID isPassive spellID
            if not spellData.isPassive and spellData.spellID and spellData.name then
                num= num+1
                Create_Spell_Menu(root, spellData.spellID, spellData.iconID, spellData.name, num)
            end
        end
    end

--添加，自定义
    if self.index~=1 then
        return
    end

--区域，技能
    for _, zone in pairs( C_ZoneAbility.GetActiveAbilities() or {}) do
        if zone.spellID and not C_Spell.IsSpellPassive(zone.spellID) then
            local zoneName= C_Spell.GetSpellName(zone.spellID)
            local zoneIcon= C_Spell.GetSpellTexture(zone.spellID)
            if zoneName and zoneIcon then
                num= num+1
                Create_Spell_Menu(root, zone.spellID, zoneIcon, zoneName, num)
            end
        end
    end
--FS
    if e.Player.class=='MAGE' then
        local sub=root:CreateButton(
            WoWTools_Mixin.onlyChinese and '解散水元素' or 'PetDismiss',
        function()
            if InCombatLockdown() then return end
            MacroFrameText:Insert('/script PetDismiss()\n')
            MacroFrameText:SetFocus()
            return MenuResponse.Open
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine('/script PetDismiss()')
        end)
    end
end


















--PVP，天赋，法术
local function Init_PvP_Menu(_, root)
    local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(1)
    if not slotInfo or not slotInfo.availableTalentIDs or WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    table.sort(slotInfo.availableTalentIDs, function(a, b)
        local talentInfoA = C_SpecializationInfo.GetPvpTalentInfo(a) or {};
        local talentInfoB = C_SpecializationInfo.GetPvpTalentInfo(b) or {};

        local unlockedA = talentInfoA.unlocked;
        local unlockedB = talentInfoB.unlocked;

        if (unlockedA ~= unlockedB) then
            return unlockedA;
        end

        if (not unlockedA) then
            local reqLevelA = C_SpecializationInfo.GetPvpTalentUnlockLevel(a);
            local reqLevelB = C_SpecializationInfo.GetPvpTalentUnlockLevel(b);

            if (reqLevelA ~= reqLevelB) then
                return reqLevelA < reqLevelB;
            end
        end
        return a < b
    end)

    local num=0
    for _, talentID in pairs(slotInfo.availableTalentIDs) do
        local talentInfo = C_SpecializationInfo.GetPvpTalentInfo(talentID) or {}
        if talentInfo.spellID and talentInfo.name and not C_Spell.IsSpellPassive(talentInfo.spellID) then
            num= num+1
            Create_Spell_Menu(root,
                talentInfo.spellID,
                talentInfo.icon,
                talentInfo.name,
                talentInfo.selected and '|A:AlliedRace-UnlockingFrame-Checkmark:0:0|a' or num
            )
        end
    end
end















local function Init_Equip_Menu(_, root)
    if WoWTools_MenuMixin:CheckInCombat(root) then--战斗中
        return
    end
    local sub, icon, name, spellID, itemLink
    for slot=1,22 do
        local textureName = GetInventoryItemTexture("player", slot)
        if textureName then
            itemLink = GetInventoryItemLink('player', slot) or 0
            name= itemLink and C_Item.GetItemNameByID(itemLink)
            if itemLink and name then

                icon= C_Item.GetItemIconByID(itemLink)
                spellID= select(2, C_Item.GetItemSpell(itemLink))

                WoWTools_Mixin:Load({id=spellID, type='spell'})
                WoWTools_Mixin:Load({id=itemLink, type='item'})

                sub= root:CreateButton(
                    slot..' '
                    ..'|T'..(icon or 0)..':0|t'
                    ..itemLink
                    ..(spellID and '|A:auctionhouse-icon-favorite:0:0|a' or ''),

                function(data)
                    if InCombatLockdown() then return end
                    MacroFrameText:Insert((data.spellID and '/use ' or '/equip ')..data.name..'\n')
                    MacroFrameText:SetFocus()
                    return MenuResponse.Open

                end, {spellID=spellID, name=name, itemLink=itemLink})
            end
--二级，菜单
            Sub_Menu(sub, {
                icon=icon,
                itemLink=itemLink,
                spellID=spellID,
                name=' ',
                body='#showtooltip\n/targetenemy [noharm][dead]\n'..(spellID and '/use ' or '/equip ')..name
            })
        end
    end
end








--谈话，表情
local function Init_Chat_Menu(root, listTab)
    if WoWTools_MenuMixin:CheckInCombat(root) then--战斗中
        return
    end
    local i, sub
    for _, value in pairs(listTab or {}) do
        i = 1
        local token = _G["EMOTE"..i.."_TOKEN"]
        while ( i < 627 ) do--local MAXEMOTEINDEX = 627;
            if ( token == value ) then
                break;
            end
            i = i + 1;
            token = _G["EMOTE"..i.."_TOKEN"];
        end
        local label = _G["EMOTE"..i.."_CMD1"];
        if ( not label ) then
            label = value;
        end
        if label then
            sub=root:CreateButton(
                e.cn(label),
            function(data)
                if InCombatLockdown() then return end
                MacroFrameText:Insert(data.label..'\n')
                MacroFrameText:SetFocus()
                return MenuResponse.Open
            end, {label=label})
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.label..' ')
            end)
        end

    end
end








--常用，宏
local function Init_MacroList_Menu(_, root)
    local sub
    for _, info in pairs(MacroList) do
        sub=root:CreateButton(
            info.text,
        function(data)
            if not InCombatLockdown() and data.macro then
                MacroFrameText:Insert(data.macro)
                MacroFrameText:SetFocus()
            end
            return MenuResponse.Open
        end, {macro=info.macro})
        sub:SetTooltip(function(tooltip, description)
            if description.data.macro then
                tooltip:AddLine(description.data.macro, nil, nil, nil, true)
            end
        end)

        local num= 0
        for index, macro in pairs(info.tab or {}) do
            sub:CreateButton(
                macro.text:gsub('\n', ' '),
            function(data)
                if not InCombatLockdown() then
                    MacroFrameText:Insert(data.text)
                    MacroFrameText:SetFocus()
                end
                return MenuResponse.Open
            end, {text=macro.text, icon=macro.icon, tips=macro.tips})
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.tips,  nil, nil, nil, true)
            end)
            num= index
        end
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end
end







local function Set_Button_OnEnter(btn)
    if not btn.name then
        return
    end
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(e.cn(self.name), self.index)
        GameTooltip:Show()
    end)
end

















--命令，按钮，列表
local function Init()
    Frame= CreateFrame("Frame", nil, MacroFrame)
    WoWTools_MacroMixin.BottomListFrame= Frame

    Frame:SetSize(1,1)
    Frame:SetPoint('TOPLEFT', MacroFrame, 'BOTTOMLEFT', 0, -20)

    local last= Frame
    local btn

--法术书
    for i=1, 12 do
        local data= C_SpellBook.GetSpellBookSkillLineInfo(i)--shouIdHide name numSpellBookItems iconID isGuild itemIndexOffset
        if data and data.name and not data.shouIdHide then
            btn= WoWTools_ButtonMixin:Cbtn(Frame, {
                texture=data.iconID,
                name='WoWToolsMacroBottomListButton'..i,
                isType2=true,
            })
            btn:SetPoint('LEFT', last, 'RIGHT')
            btn.name= data.name
            btn.index= i
            btn:SetScript('OnMouseDown', function(self)
                MenuUtil.CreateContextMenu(self, Init_SpellBook_Menu)
            end)
            --btn:SetupMenu(Init_SpellBook_Menu)
            Set_Button_OnEnter(btn)
            last= btn
        end
    end

--PVP，天赋，法术
    local pvpButton= WoWTools_ButtonMixin:Cbtn(Frame, {
            atlas='pvptalents-warmode-swords',
            isType2=true,
            name='WoWToolsMacroBottomListPVPButton'
        })
    pvpButton:SetNormalAtlas('')
    pvpButton:SetPoint('LEFT', last, 'RIGHT')
    pvpButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_PvP_Menu)
    end)
    pvpButton.name= WoWTools_Mixin.onlyChinese and 'PvP天赋' or PVP_LABEL_PVP_TALENTS
    Set_Button_OnEnter(pvpButton)
    last=pvpButton

--角色，装备
    local equipButton= WoWTools_ButtonMixin:Cbtn(Frame, {
        atlas=WoWTools_UnitMixin:GetRaceIcon({unit='player', reAtlas=true}),
        isType2=true,
        name='WoWToolsMacroBottomListEquipButton',
    })
    equipButton:SetPoint('LEFT', last, 'RIGHT')
    equipButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Equip_Menu)
    end)
    equipButton.name= WoWTools_Mixin.onlyChinese and '装备' or EQUIPSET_EQUIP
    Set_Button_OnEnter(equipButton)
    last=equipButton

--谈话
    local spellchButton= WoWTools_ButtonMixin:Cbtn(Frame, {
        atlas='voicechat-icon-textchat-silenced',
        isType2=true,
        name='WoWToolsMacroBottomListVoiceChatButton'
    })
    spellchButton:SetPoint('LEFT', last, 'RIGHT')

    spellchButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, function(_, root)
            Init_Chat_Menu(root, TextEmoteSpeechList)
        end)
    end)
    spellchButton.name= WoWTools_Mixin.onlyChinese and '谈话' or VOICEMACRO_LABEL
    Set_Button_OnEnter(spellchButton)
    last=spellchButton

--表情
    local emoteButton= WoWTools_ButtonMixin:Cbtn(Frame, {
            atlas='transmog-icon-chat',
            isType2=true,
            name='WoWToolsMacroBottomListEmoteButton'
        })
    emoteButton:SetPoint('LEFT', last, 'RIGHT')

    emoteButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, function(_, root)
            Init_Chat_Menu(root, EmoteList)
        end)
    end)
    emoteButton.name= WoWTools_Mixin.onlyChinese and '表情' or EMOTE
    Set_Button_OnEnter(emoteButton)
    last= emoteButton



--常用，宏
    local macroListButton= WoWTools_ButtonMixin:Cbtn(Frame, {
        atlas='PetJournal-FavoritesIcon',
        isType2=true,
        name='WoWToolsMacroBottomListNormalButton'
    })
    macroListButton:SetPoint('LEFT', last, 'RIGHT')
    --macroListButton:SetupMenu(Init_MacroList_Menu)
    macroListButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_MacroList_Menu)
    end)

--设置
    function Frame:settings()
        self:SetScale(Save().bottomListScale or 1)
        self:SetShown(not Save().hideBottomList)
    end

    Frame:settings()
end


















function WoWTools_MacroMixin:Init_List_Button()
    Init()
end