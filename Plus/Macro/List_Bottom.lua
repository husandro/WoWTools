--命令，按钮，列表

local function Save()
    return WoWToolsSave['Plus_Macro2']
end





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
            {text='/cwm 1\n/cwm 2\n/cwm 3\n/cwm 4\n/cwm 5\n/cwm 6\n/cwm 7\n/cwm 8', icon='talents-button-reset'},
        }
    },
    --[[{text= 'SetRaidTarget', macro='/target [@mouseover]\n/script SetRaidTarget("target",1)',
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
    },]]
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
            {text='exists', tips='WoWTools_UnitMixin:UnitExists()'},
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
    {text='[nostance:1]', macro= '[nostance:1]', tips=WoWTools_DataMixin.onlyChinese and '姿态条' or HUD_EDIT_MODE_STANCE_BAR_LABEL},
}








local function Find_SpellMacro(spellID)
    local tabID= PanelTemplates_GetSelectedTab(MacroFrame)
    if tabID>2 then
        return
    end
    local count= select(tabID, GetNumMacros())+ (tabID==1 and 0 or MAX_ACCOUNT_MACROS)
    local i= tabID==1 and 1 or (MAX_ACCOUNT_MACROS+1)

    for index= i, count do
        if GetMacroSpell(index)==spellID then
            return '|A:AlliedRace-UnlockingFrame-Checkmark:0:0|a'
        end
    end
    return ''
end











local Spell_Macro={

--MS
    [73325]=function(name)--[信仰飞跃]ms
        return '/cast [target=mouseover,help,exists][target=target,help,exists][target=targettarget,help,exists][target=focus,help,exists]'..name
    end,
    [232698]=function(name)
        return '/cast [noform]'..name
    end,

--SS
    [6201]=function(name)--[制造治疗石]ss
        local right= C_Spell.GetSpellName(29893)--[制造灵魂之井] ss
        local alt= name--[制造治疗石] ss
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
    end,
    [48018]=function(name)--[恶魔法阵]ss
        local alt= name
        local spellName= C_Spell.GetSpellName(48020)
        if spellName then
            return '/cast [mod:alt,@cursor]'.. alt
                ..'\n/cast '..spellName
        end
    end,
    [48020]=function(name)--[恶魔法阵：传送]ss
        local alt= C_Spell.GetSpellName(48018)
        if alt then
            return '/cast [mod:alt,@cursor]'.. alt
                ..'\n/cast '..name
        end
    end,
    [755]=function(name)--[生命通道]ss
        return '/stopcasting\n/cast [target=pet]'..name
    end,

--LR
    [5384]=function(name)--[假死]LR
        if C_SpellBook.IsSpellInSpellBook(209997) then
            local spellName= C_Spell.GetSpellName(209997)
            if spellName then
                return '/petfollow\n/cast '..spellName..'\n/cast '..name
            end
        end
        return '/petfollow\n/cast '..name
    end,
    [2643]=function(name)--[多重射击]LR
        local spellName= C_Spell.GetSpellName(186265)
        if spellName then
            return '/cancelaura '..spellName..'\n/cast '..name
        end
    end,
    [257620]=function(name)--[多重射击]LR
        local spellName= C_Spell.GetSpellName(186265)
        if spellName then
            return '/cancelaura '..spellName..'\n/cast '..name
        end
    end,
    [187708]=function(name)--[削凿]LR
        local spellName= C_Spell.GetSpellName(186265)
        if spellName then
            return '/cancelaura '..spellName..'\n/cast '..name
        end
    end,

--FS
    [212653]=function(name)--[闪光术]
        local cancel= C_Spell.GetSpellName(45438)--[寒冰屏障]
        local text='/stopcasting'
        if cancel then
            text= text..'\n/cancelaura '..cancel
        end
        return text..'\n/cast '..name
    end,
    [1953]=function(name)--[闪现术]
        local cancel= C_Spell.GetSpellName(45438)--[寒冰屏障]
        local text='/stopcasting'
        if cancel then
            text= text..'\n/cancelaura '..cancel
        end
        return text..'\n/cast '..name
    end,
    [66]=function(name)--[隐形术]
        local cancel= C_Spell.GetSpellName(45438)--[寒冰屏障]
        local text='/stopcasting'
        if cancel then
            text= text..'\n/cancelaura '..cancel
        end
        return text..'\n/cast '..name
    end,
    [110959]=function(name)--[强化隐形术]
        local cancel= C_Spell.GetSpellName(45438)--[寒冰屏障]
        local text='/stopcasting'
        if cancel then
            text= text..'\n/cancelaura '..cancel
        end
        return text..'\n/cast '..name
    end,
    [190336]=function(name)--[造餐术]
        local itemName= C_Item.GetItemNameByID(113509)
        if itemName then
            return '/use [btn:1]'..itemName..'\n/cast [btn:2]'..name
        end
    end,
    [130]=function(name)--[缓落术]
        return '/cast '..name..'\n/cancelaura [mod:alt]'..name
    end,

--MS
    [121536]=function(name)--[天堂之羽]ms
        return '/cast [mod,@player][@cursor]'..name
    end,
    [1706]=function(name)--[漂浮术]ms
        return '/cast [target=mouseover,help,exists][@player]'..name..'\n/cancelaura [mod:alt]'..name
    end,


--DK
    [43265]=function(name)--[枯萎凋零]dk
        return '/cast [mod,@player][@cursor]'..name
    end,
    [51052]=function(name)--[反魔法领域]
        return '/cast [mod,@player][@cursor]'..name
    end,

--SM
    [546]=function(name)--[水上行走]sm
        return '/cast [target=mouseover,help,exists][@player]'..name..'\n/cancelaura [mod:alt]'..name
    end,

--XD
    [8921]=function(name)--月火术
       WoWTools_DataMixin:Load(5487, 'spell')
        local spellName= PlayerUtil.GetCurrentSpecID()==104 and C_Spell.GetSpellName(5487)--104守护专精 8921/月火术 5487熊形态
        if spellName then
            return '/cast [nostance:1]'..spellName..'\n/cast '..name
        end
    end,
    [5487]=function(name)--熊形态
        return '/cast [nostance:1]'..name
    end,
    [768]=function(name)--猎豹形态
        return '/cast [nostance:2]'..name
    end,
    [783]=function(name)--旅行形态
        return '/cast [nostance:3]'..name
    end,
    [24858]=function(name)--枭兽形态
        return '/cast [nostance:4]'..name
    end,
    [106839]=function(name)--迎头痛击
        return '/focus target\n/cleartarget\n/targetenemy\n/cast '..name..'\n/target focus\n/clearfocus\n/startattack'
    end,

--自动攻击
    [6603]=function()
        return '/startattack'
    end,
}




--自定义，职业，法术宏
--##################
local function Get_Spell_Macro(name, spellID)
    local text= Spell_Macro[spellID] and Spell_Macro[spellID](name)
    if text then
        return text
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
         '|T'..(tab.icon or 134400)..':0|t'..(WoWTools_DataMixin.onlyChinese and '新建' or NEW),
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
            ..(WoWTools_DataMixin.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL)),
        function(data)
            if not WoWTools_FrameMixin:IsLocked(MacroFrame) then
                WoWTools_MacroMixin:SetMacroTexture(data.icon)
            end
            return MenuResponse.Open
        end, tab)
        sub:SetEnabled(MacroFrameSelectedMacroButton:IsShown())
    end

--查询 BUG
    if tab.spellID then
        sub=root:CreateButton(--bug
            '|A:common-search-magnifyingglass:0:0|a'
            ..(C_SpellBook.IsSpellKnown(tab.spellID) and '|cnWARNING_FONT_COLOR:' or '|cff626262')
            ..(WoWTools_DataMixin.onlyChinese and '查询' or WHO),
        function(spellID)
            WoWTools_LoadUIMixin:SpellBook(3, spellID)
            return MenuResponse.Open
        end, tab.spellID)

        sub:SetTooltip(function(tooltip)
            GameTooltip_AddErrorLine(tooltip, 'Bug')
        end)
    end

--链接至聊天栏
    if tab.spellID or tab.itemLink then
        sub=root:CreateButton(
            (WoWTools_DataMixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT),
        function(data)
            local link= data.itemLink or WoWTools_SpellMixin:GetLink(data.spellID, false)
            WoWTools_ChatMixin:Chat(link, nil, true)
            return MenuResponse.Open
        end, tab)
        WoWTools_SetTooltipMixin:Set_Menu(sub)--技能，提示
    end
end













--创建，法术，列表
local function Create_Spell_Menu(root, spellID, icon, name, index)
   WoWTools_DataMixin:Load(spellID, 'spell')

   local indexCol= index
   for _, spell in pairs(C_AssistedCombat.GetRotationSpells() or {}) do
        if spellID==spell then
            indexCol='|cffff00ff'..index..'|r'
            break
        end
   end

    local macroText= Get_Spell_Macro(name, spellID)
    local info=  {name=name, spellID=spellID, icon=icon, tooltip=macroText}

    local sub=root:CreateButton(
        indexCol..' '
        ..Find_SpellMacro(spellID)
        ..WoWTools_SpellMixin:GetName(spellID)--取得法术，名称
        ..(macroText and '|cnGREEN_FONT_COLOR:*|r' or ''),
    function(data)
        if WoWTools_FrameMixin:IsLocked(MacroFrame) then
            return
        end

        local text=''
        local macroText2= Get_Spell_Macro(data.name, data.spellID)
        local macro= MacroFrameText:GetText() or ''
        if not macro:find('#showtooltip') then
            text= '#showtooltip '.. data.name..'\n'
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



    local macroText2= Get_Spell_Macro(name, spellID)
    local body= '#showtooltip '..name..'\n'
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
    if not self:IsMouseOver() or WoWTools_MenuMixin:CheckInCombat(root) then--战斗中
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
    if WoWTools_DataMixin.Player.Class=='MAGE' then
        local sub=root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '解散水元素' or 'PetDismiss',
        function()
            if WoWTools_FrameMixin:IsLocked(MacroFrame) then
                return
            end
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
local function Init_PvP_Menu(self, root)
    local slotInfo = self:IsMouseOver() and C_SpecializationInfo.GetPvpTalentSlotInfo(1)
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















local function Init_Equip_Menu(self, root)
    if not self:IsMouseOver() or WoWTools_MenuMixin:CheckInCombat(root) then--战斗中
        return
    end
    local sub, icon, name, spellID, itemLink
    for slot=1,22 do
        local textureName = GetInventoryItemTexture("player", slot)
        if textureName then
            itemLink = GetInventoryItemLink('player', slot) or 0
            name= itemLink and C_Item.GetItemNameByID(itemLink)
            if itemLink and name then

                icon= select(5, C_Item.GetItemInfoInstant(itemLink))
                spellID= select(2, C_Item.GetItemSpell(itemLink))

               WoWTools_DataMixin:Load(spellID, 'spell')
               WoWTools_DataMixin:Load(itemLink, 'item')

                sub= root:CreateButton(
                    slot..' '
                    ..'|T'..(icon or 0)..':0|t'
                    ..WoWTools_TextMixin:CN(itemLink, {itemID= GetInventoryItemID('player', slot), isName=true})
                    ..(spellID and '|A:auctionhouse-icon-favorite:0:0|a' or ''),

                function(data)
                    if WoWTools_FrameMixin:IsLocked(MacroFrame) then
                        return
                    end
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
local function Init_Chat_Menu(self, root)
    if not self:IsMouseOver() or WoWTools_MenuMixin:CheckInCombat(root) then--战斗中
        return
    end
    local i, sub
    for _, value in pairs(self.listTab) do
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
                WoWTools_TextMixin:CN(label),
            function(data)
                if WoWTools_FrameMixin:IsLocked(MacroFrame) then
                    return
                end
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
local function Init_MacroList_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub
    for _, info in pairs(MacroList) do
        sub=root:CreateButton(
            info.text,
        function(data)
            if not WoWTools_FrameMixin:IsLocked(MacroFrame) and data.macro then
                MacroFrameText:Insert(data.macro)
                MacroFrameText:SetFocus()
            end
            return MenuResponse.Open
        end, {macro=info.macro, tips=info.tips})
        sub:SetTooltip(function(tooltip, desc)
            if desc.data.tips then
                tooltip:AddLine(desc.data.tips)
            end
            if desc.data.macro then
                tooltip:AddLine(desc.data.macro, nil, nil, nil, true)
            end
        end)

        for _, macro in pairs(info.tab or {}) do
            sub:CreateButton(
                macro.text:gsub('\n', ' '),
            function(data)
                if not WoWTools_FrameMixin:IsLocked(MacroFrame)  then
                    MacroFrameText:Insert(data.text)
                    MacroFrameText:SetFocus()
                end
                return MenuResponse.Open
            end, {text=macro.text, icon=macro.icon, tips=macro.tips})

            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.tips,  nil, nil, nil, true)
            end)
        end
        WoWTools_MenuMixin:SetScrollMode(sub)
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
        GameTooltip:AddLine(self.name)
        GameTooltip:Show()
    end)
end

















--命令，按钮，列表
local function Init()
    if Save().hideBottomList then
        return
    end

    local Frame= CreateFrame("Frame", 'WoWToolsMacroBottomListFrame', MacroFrame)
    --WoWTools_MacroMixin.BottomListFrame= Frame

    Frame.Bg= Frame:CreateTexture()
    Frame.Bg:SetColorTexture(0,0,0)
    Frame.Bg:SetPoint('TOPLEFT', Frame, -2, 5)

    Frame:SetSize(1, 1)
    Frame:SetPoint('TOPLEFT', MacroFrame, 'BOTTOMLEFT', 6, -2)

    local last= Frame
    local btn

--法术书
    for i=1, 12 do
        local data= C_SpellBook.GetSpellBookSkillLineInfo(i)--shouIdHide name numSpellBookItems iconID isGuild itemIndexOffset
        if data and data.name and not data.shouIdHide then
            btn= WoWTools_ButtonMixin:Menu(Frame, {
                texture=data.iconID,
                name='WoWToolsMacroBottomListButton'..i,
                isType2=true,
            })
            btn:SetPoint('TOPLEFT', last, 'TOPRIGHT')
            btn.name= data.name
            btn.index= i

            btn:SetupMenu(Init_SpellBook_Menu)
            Set_Button_OnEnter(btn)

            last= btn
        end
    end

--PVP，天赋，法术
    local pvpButton= WoWTools_ButtonMixin:Menu(Frame, {
        atlas='pvptalents-warmode-swords',
        isType2=true,
        name='WoWToolsMacroBottomListPVPButton'
    })
    pvpButton:SetNormalAtlas('')
    pvpButton:SetPoint('LEFT', last, 'RIGHT')
    pvpButton:SetupMenu(Init_PvP_Menu)
    pvpButton.name= WoWTools_DataMixin.onlyChinese and 'PvP天赋' or PVP_LABEL_PVP_TALENTS
    Set_Button_OnEnter(pvpButton)
    last=pvpButton

--角色，装备
    local equipButton= WoWTools_ButtonMixin:Menu(Frame, {
        atlas=WoWTools_UnitMixin:GetRaceIcon('player', nil, nil, {reAtlas=true}),
        isType2=true,
        name='WoWToolsMacroBottomListEquipButton',
    })
    equipButton:SetPoint('LEFT', last, 'RIGHT')
    equipButton:SetupMenu(Init_Equip_Menu)
    equipButton.name= WoWTools_DataMixin.onlyChinese and '装备' or EQUIPSET_EQUIP
    Set_Button_OnEnter(equipButton)
    last=equipButton

--谈话
    local spellchButton= WoWTools_ButtonMixin:Menu(Frame, {
        atlas='voicechat-icon-textchat-silenced',
        isType2=true,
        name='WoWToolsMacroBottomListVoiceChatButton'
    })
    spellchButton:SetPoint('LEFT', last, 'RIGHT')
    spellchButton.listTab= TextEmoteSpeechList
    spellchButton:SetupMenu(Init_Chat_Menu)
    spellchButton.name= WoWTools_DataMixin.onlyChinese and '谈话' or VOICEMACRO_LABEL
    Set_Button_OnEnter(spellchButton)
    last=spellchButton

--表情
    local emoteButton= WoWTools_ButtonMixin:Menu(Frame, {
            atlas='transmog-icon-chat',
            isType2=true,
            name='WoWToolsMacroBottomListEmoteButton'
        })
    emoteButton:SetPoint('LEFT', last, 'RIGHT')
    emoteButton.listTab= EmoteList
    emoteButton:SetupMenu(Init_Chat_Menu)
    emoteButton.name= WoWTools_DataMixin.onlyChinese and '表情' or EMOTE
    Set_Button_OnEnter(emoteButton)
    last= emoteButton



--常用，宏
    local macroListButton= WoWTools_ButtonMixin:Menu(Frame, {
        atlas='PetJournal-FavoritesIcon',
        isType2=true,
        name='WoWToolsMacroBottomListNormalButton'
    })
    macroListButton:SetPoint('LEFT', last, 'RIGHT')
    macroListButton:SetupMenu(Init_MacroList_Menu)
--设置
    function Frame:settings()
        self:SetScale(Save().bottomListScale or 1)
        self:SetShown(not Save().hideBottomList)
        self.Bg:SetAlpha(Save().bottomListAlpha or 0.5)
    end


    Frame.Bg:SetPoint('BOTTOMRIGHT', macroListButton, 2, -2)

    Frame:settings()

    Init=function()
        _G['WoWToolsMacroBottomListFrame']:settings()
    end
end


















function WoWTools_MacroMixin:Init_List_Button()
    Init()
end