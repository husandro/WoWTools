--命令，按钮，列表
local e= select(2, ...)

















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
    elseif spellID==698--[召唤仪式]ss
        or spellID==29893--[制造灵魂之井]ss
        or spellID==111771--[恶魔传送门]ss
        or spellID==342601--[末日仪式]ss
        or spellID==20707--[灵魂石]ss
        or spellID==114018--[潜伏帷幕]DZ
        or spellID==2825--[嗜血]sm
        or spellID==414664--[群体隐形]fs
    then
        return '/cast '..name..'\n/y '..(C_Spell.GetSpellLink(spellID) or name)



    --设置，光标，焦点， 目标，再设置焦点，
    elseif spellID==118--[变形术]fs
        or spellID==34477--[误导]lr
        or spellID==5782--[恐惧]ss
        or spellID==57934--[嫁祸诀窍]dz
        or spellID==111673--[控制亡灵]
    then
        return '/stopcasting\n/cast [target=mouseover,harm,exists][target=target,harm,exists][target=focus,harm,exists]'
            ..name..';'..name
            ..'\n/focus [target=focus,noexists][target=focus,dead]target'

    --停止施法
    elseif spellID==78675--[日光术]xd
        or spellID==33786--[旋风]xd

        or spellID==57994--[风剪]sm
        or spellID==51490--[雷霆风暴]sm
        or spellID==108271--[星界转移]

        or spellID==45438--[寒冰屏障]fs
        or spellID==2139--[法术反制]fs

        or spellID==147362--[反制射击]lr

        or spellID==104773--[不灭决心]ss
        or spellID==111400--[爆燃冲刺]ss
        or spellID==6789--[死亡缠绕]ss
        or spellID==710--[放逐术]ss
        or spellID==8122--[心灵尖啸]ms
        or spellID==15487--[沉默]ms
        or spellID==47585--[消散]ms


    then
        return '/stopcasting\n/cast '..name

    elseif spellID==145205--[百花齐放]xd

        or spellID==192077--[狂风图腾]
        or spellID==192058--[电能图腾]sm
        or spellID==51485--[陷地图腾]sm
        or spellID==192222--[岩浆图腾]sm
        or spellID==198838--[大地之墙图腾]sm
        or spellID==2484--[地缚图腾]
        or spellID==73920--[治疗之雨]sm
        or spellID==61882--[地震术]sm
        or spellID==6196--[视界术]sm

        or spellID==358385--[山崩]dm
        or spellID==357210--[深呼吸]dm

        or spellID==113724--[冰霜之环]fs
        or spellID==2120--[烈焰风暴]fs
        or spellID==190356--[暴风雪]fs
        or spellID==198149--[寒冰宝珠]fs PVP天赋

        or spellID==187650--[冰冻陷阱]lr
        or spellID==187698--[焦油陷阱]lr
        or spellID==109248--[束缚射击]lr
        or spellID==162488--[精钢陷阱]lr
        or spellID==236776--[高爆陷阱]lr
        or spellID==1543--[照明弹]lr
        or spellID==6197--[鹰眼术]lr
        or spellID==260243--[乱射]lr
        or spellID==257284--[猎人印记]lr
        or spellID==190925--[鱼叉猛刺]lr

        or spellID==30283--[暗影之怒]ss
        or spellID==1122--[召唤地狱火]ss
        or spellID==152108--[大灾变]ss
        or spellID==5740--[火焰之雨]ss

        or spellID==453--[安抚心灵]ms
        or spellID==34861--[圣言术：灵]ms
        or spellID==62618--[真言术：障]ms
        or spellID==32375--[群体驱散]ms

        or spellID==195457--[抓钩]dz

        or spellID==189110--[地狱火撞击]dh
        or spellID==191427--[恶魔变形]dh
        or spellID==204596--[烈焰咒符]dh
        or spellID==202137--[沉默咒符]dh
        or spellID==390163--[极乐敕令]dh
        or spellID==207684--[悲苦咒符]dh
        or spellID==389807--[锁链咒符]dh
        or spellID==389810--[烈焰咒符]dh T
        or spellID==389815--[极乐敕令]dh T
        or spellID==389809--[沉默咒符]dh T

        or spellID==6544--[英勇飞跃]zs
    then
        return '/cast [@cursor]'..name
    end
end














--创建，目标，功击，按钮
--####################
local function Create_Button(name)
    local btn= WoWTools_ButtonMixin:Cbtn(MacroSaveButton, {size={60,22}, type=false})
    function btn:find_text(right)
        return (MacroFrameText:GetText() or ''):find(WoWTools_TextMixin:Magic(right and self.text2 or self.text))
    end
   function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()

        e.tips:AddDoubleLine(e.addName, WoWTools_MacroMixin.addName)
        local col= UnitAffectingCombat('player') and '|cnRED_FONT_COLOR:' and (self:find_text() and '|cff9e9e9e') or ''
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(col..self.text..(self.tip or ''), e.Icon.left)
        if self.text2 then
            e.tips:AddLine(' ')
            col= self:find_text(true) and '|cff9e9e9e' or ''
        end
        e.tips:AddDoubleLine(col..self.text2..(self.tip2 or ''), e.Icon.right)
        e.tips:Show()
    end
    btn:SetScript('OnClick', function(self, d)
        if UnitAffectingCombat('player') then
            return
        end
        if d=='LeftButton' then
            if self.textCursor then
                MacroFrameText:SetCursorPosition(self.textCursor)
            end
            MacroFrameText:Insert(self.text)
            MacroFrameText:SetFocus()

        elseif d=='RightButton' and self.text2 then
            if self.text2Cursor then
                MacroFrameText:SetCursorPosition(self.text2Cursor)
            end
            MacroFrameText:Insert(self.text2)
            MacroFrameText:SetFocus()
        end
        self:set_tooltips()
    end)
    btn:SetText(name)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript("OnEnter", btn.set_tooltips)
    return btn
end















--创建，法术，列表
--##############
local function Create_Spell_Menu(root, spellID, icon, name, index)--创建，法术，列表
    e.LoadData({id=spellID, type='spell'})

    local  macroText= Get_Spell_Macro(name, spellID)
    local sub=root:CreateButton(
        index..' '
        ..WoWTools_SpellMixin:GetName(spellID)--取得法术，名称
        ..(macroText and '|cnGREEN_FONT_COLOR:*|r' or ''),
    function(data)
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
        --MacroFrameText:SetCursorPosition(0)
        MacroFrameText:Insert(text)
        MacroFrameText:SetFocus()

        return MenuResponse.Open
    end, {name=name, spellID=spellID, icon=icon, tooltip=macroText})

--技能，提示
    WoWTools_SetTooltipMixin:Set_Menu(sub)


--修改，当前图标
    sub:CreateButton(
        '|T'..(icon or 0)..':0|t'
        ..(e.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL)),
    function(data)
        WoWTools_MacroMixin:SetMacroTexture(data.icon)
        return MenuResponse.Open
    end, {icon=icon})

--查询
    sub:CreateButton(
        '|A:common-search-magnifyingglass:0:0|a'..(e.onlyChinese and '查询' or WHO),
    function(data)
        -- PlayerSpellsUtil.OpenToSpellBookTabAtSpell(spellID, knownSpellsOnly, toggleFlyout, flyoutReason)
        PlayerSpellsUtil.OpenToSpellBookTabAtSpell(data.spellID, false, true, false)
        return MenuResponse.Open
    end, {spellID=spellID})

--链接至聊天栏
    sub:CreateButton(
        (e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT),
    function(data)
        local link= WoWTools_SpellMixin:GetLink(data.spellID, false)
        WoWTools_ChatMixin:Chat(link, nil, true)
        return MenuResponse.Open
    end, {spellID=spellID})

end
    --[[e.LibDD:UIDropDownMenu_AddButton({
        text= format('|A:%s:0:0|a', texture or '')..name..(macroText and '|cnGREEN_FONT_COLOR:*|r' or ''),
        tooltipOnButton=true,
        tooltipTitle=headText,
        tooltipText=tipText,
        colorCode=color,
        icon=icon,
        tSizeX=32,
        tSizeY=32,
        --keepShownOnClick=true,
        arg1={spellName=name, spellID=spellID, icon=spellIcon},

        notCheckable=true,
        func= function(_, tab)
            if IsShiftKeyDown() then
                local link=C_Spell.GetSpellLink(tab.spellID) or C_Spell.GetSpellName(tab.spellID) or tab.spellID
                link= 'spellID=='..tab.spellID..'--'..link
                WoWTools_ChatMixin:Chat(link, nil, true)
                --if not ChatEdit_InsertLink(link) then
                    --ChatFrame_OpenChat(link)
                --end

           -- elseif IsControlKeyDown() then
                --e.call(SpellBookFrame_OpenToSpell, tab.spellID)
                --print(e.addName, WoWTools_MacroMixin.addName, '|cnRED_FONT_COLOR:BUG|r', 'Ctrl+'..e.Icon.left..(e.onlyChinese and '查询' or WHO))

            elseif IsAltKeyDown() then
                WoWTools_MacroMixin:SetMacroTexture(tab.icon)--修改，当前图标
            else
                local text=''
                local macroText2, showName= Get_Spell_Macro(tab.spellName, tab.spellID)
                local macro= MacroFrameText:GetText() or ''
                if not macro:find('#showtooltip') then
                    text= '#showtooltip'..(showName and ' '..showName or '')..'\n'
                end
                if not macro:find('/targetenemy') then
                    text= text..'/targetenemy [noharm][dead]\n'
                end

                text= text..(macroText2 or ('/cast '..tab.spellName))..'\n'

                --MacroFrameText:SetCursorPosition(0)
                MacroFrameText:Insert(text)
                MacroFrameText:SetFocus()
            end
        end
    }, 1)]]





























local function Init_Normal_Menu(_, root, num)
    local sub
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
        sub=root:CreateButton(
            e.onlyChinese and '解散水元素' or 'PetDismiss',
        function()
            MacroFrameText:Insert('/script PetDismiss()\n')
            MacroFrameText:SetFocus()
            return MenuResponse.Open
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine('/script PetDismiss()')
        end)
    end
end
--[[
if HasExtraActionBar() then
local slot = i + ((GetExtraBarIndex() or 19) - 1) * (NUM_ACTIONBAR_BUTTONS or 12)
local actionType, spell = GetActionInfo(slot)
if actionType== "spell" and spell then--and ActionTab[spell] then
end
end
]]





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

    if self.index==1 then
        Init_Normal_Menu(self, root, num)
    end

end

























--命令，按钮，列表
--##############
local function Init_List()
    local last, btn
    --local size= 24
    for i=1, 12 do
        local data= C_SpellBook.GetSpellBookSkillLineInfo(i)--shouIdHide name numSpellBookItems iconID isGuild itemIndexOffset
        if data and data.name and not data.shouIdHide then
            btn= WoWTools_ButtonMixin:CreateMenu(MacroFrame, {hideIcon=true})
            btn:SetNormalTexture(data.iconID or 0)

            btn.name= data.name
            btn.index= i

            btn:SetScript('OnLeave', GameTooltip_Hide)
            btn:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.cn(self.name), self.index)
                e.tips:Show()
            end)
            if not last then
                btn:SetPoint('TOPLEFT', MacroFrame, 'BOTTOMLEFT', 0, -4)
            else
                btn:SetPoint('LEFT', last, 'RIGHT')
            end
            btn:SetupMenu(Init_SpellBook_Menu)
            last= btn
        end
    end






    --PVP， 天赋，法术
    local pvpButton= WoWTools_ButtonMixin:Cbtn(last, {atlas='pvptalents-warmode-swords'})--pvptalents-warmode-swords-disabled
    pvpButton:SetPoint('LEFT', last, 'RIGHT')
    pvpButton:SetScript('OnMouseDown', function(self)
        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function()
            local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(1)
            if slotInfo and  slotInfo.availableTalentIDs then
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
                        return a < b;
                end)
                for _, talentID in pairs(slotInfo.availableTalentIDs) do
                    local talentInfo = C_SpecializationInfo.GetPvpTalentInfo(talentID) or {}
                    if talentInfo.spellID and talentInfo.name and not C_Spell.IsSpellPassive(talentInfo.spellID) then
                        Create_Spell_Menu(talentInfo.spellID, talentInfo.icon, talentInfo.name, talentInfo.selected and e.Icon.select)
                    end
                end
            end
        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)--主菜单
    end)









    --角色，装备
    local equipButton= WoWTools_ButtonMixin:Cbtn(last, {size=size, atlas=WoWTools_UnitMixin:GetRaceIcon({unit='player', reAtlas=true})})--atlas=e.Player.sex==2 and 'charactercreate-gendericon-male-selected' or 'charactercreate-gendericon-female-selected'})--pvptalents-warmode-swords-disabled
    equipButton:SetPoint('LEFT', last, 'RIGHT')
    equipButton:SetScript('OnMouseDown', function(self)
        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function()
            for slot=1,22 do
                local textureName = GetInventoryItemTexture("player", slot)
                if textureName then
                    local itemLink = GetInventoryItemLink('player', slot)
                    local name = itemLink and C_Item.GetItemNameByID(itemLink)
                    if name and itemLink then
                        local spellName, spellID= C_Item.GetItemSpell(itemLink)
                        local spellTexture

                        if spellID then
                            e.LoadData({id=spellID, type='spell'})
                            spellTexture= C_Spell.GetSpellTexture(spellID)

                        end
                        e.LibDD:UIDropDownMenu_AddButton({
                            text='|T'..textureName..':0|t'..itemLink..(((slot==13 or slot==14) and spellID) and format('|A:%s:0:0|a', e.Icon.toLeft) or ''),
                            notCheckable=true,
                            icon= spellID and e.Icon.select or nil,
                            tooltipOnButton=true,
                            tooltipTitle='Alt '..(textureName and '|T'..textureName..':0|t' or '')
                                    ..(e.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL))
                                    ..'|n|cnGREEN_FONT_COLOR:'..(spellID and '/use|r ' or '/equip ')..name..'|r',
                            tooltipText= '|n'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS, slot)
                                    ..(spellID and '|n|n' or '')
                                    ..(spellTexture and '|T'..spellTexture..':0|t' or '')
                                    ..(spellID and C_Spell.GetSpellLink(spellID) or spellName or spellID or '')..(spellID and ' '..spellID or ''),
                            arg1={name=name, spellID=spellID, icon=textureName},
                            func= function(_, tab)
                                if IsAltKeyDown() then
                                    WoWTools_MacroMixin:SetMacroTexture(tab.icon)--修改，当前图标
                                else
                                    MacroFrameText:Insert(
                                        (tab.spellID and '/use '..tab.name or ('/equip '..tab.name)..'\n')
                                    )
                                    MacroFrameText:SetFocus()
                                end
                            end
                        }, 1)
                    end
                end
            end
        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)--主菜单
    end)








    --谈话
    local spellchButton= WoWTools_ButtonMixin:Cbtn(last, {size=size, atlas='communities-icon-chat'})
    function spellchButton:Chat_Init_menu(list, level)--表情，列表 
        for _, value in pairs(list or {}) do
            local i = 1;
            local token = _G["EMOTE"..i.."_TOKEN"];
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
                e.LibDD:UIDropDownMenu_AddButton({
                    text=label,
                    notCheckable=true,
                    arg1=label,
                    func= function(_, arg1)
                        MacroFrameText:Insert(arg1..'\n')
                        MacroFrameText:SetFocus()
                    end,
                }, level)
            end
        end
    end
    spellchButton:SetPoint('LEFT', last, 'RIGHT')
    spellchButton:SetScript('OnMouseDown', function(self)
        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function(_, level)
            self:Chat_Init_menu(TextEmoteSpeechList, level)
        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)
    end)
    last= spellchButton

    --表情
    local emoteButton= WoWTools_ButtonMixin:Cbtn(last, {size=size, texture='Interface\\Addons\\WoWTools\\Sesource\\Emojis\\greet'})
    emoteButton:SetPoint('LEFT', last, 'RIGHT')
    emoteButton:SetScript('OnMouseDown', function(self)
        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function(_, level)
            self:GetParent():Chat_Init_menu(EmoteList, level)
        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)
    end)
    last= emoteButton



    --常用，宏
    local starButton= WoWTools_ButtonMixin:Cbtn(last, {size=size, atlas='PetJournal-FavoritesIcon'})
    starButton:SetPoint('LEFT', last, 'RIGHT')
    starButton:SetScript('OnMouseDown', function(self)
        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function(_, level, menuList)
            local macroList={
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
            for _, info in pairs(macroList) do
                if menuList then
                    if menuList==info.text then
                        for _, macro in pairs(info.tab) do
                            e.LibDD:UIDropDownMenu_AddButton({
                                text=macro.text:gsub('\n', ' '),
                                notCheckable=true,
                                arg1=macro.text,
                                icon=macro.icon,
                                tooltipOnButton=true,
                                tooltipTitle= macro.tips and '|cff2aa2ff'..macro.tips or nil,
                                func= function(_, arg1)
                                    MacroFrameText:Insert(arg1)
                                    MacroFrameText:SetFocus()
                                end
                            }, level)
                        end
                    end
                else
                    e.LibDD:UIDropDownMenu_AddButton({
                        text=info.text,
                        notCheckable=true,
                        arg1=info.macro,
                        menuList=info.tab and info.text,
                        hasArrow=info.tab and true or nil,
                        func= function(_, arg1)
                            if arg1 then
                                MacroFrameText:Insert(arg1)
                                MacroFrameText:SetFocus()
                            end
                        end,
                    }, level)
                end

            end
        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)--主菜单
    end)
    last=nil
end















local function Init_Other_Button()
    --目标
    local attck= Create_Button(e.onlyChinese and '目标' or TARGET)
    attck:SetPoint('LEFT', MacroEditButton, 'RIGHT',8,0)
    attck.text='#showtooltip\n/targetenemy [noharm][dead]\n'
    attck.text2='/cancelaura '
    attck.textCursor=0
    attck.text2Cursor=nil
    attck.tip=nil
    attck.tip2=e.onlyChinese and '光环名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AURAS, NAME)



    --攻击
    local cancel= Create_Button(e.onlyChinese and '攻击' or ATTACK)
    cancel:SetPoint('LEFT', attck, 'RIGHT')
    cancel.text= '/petattack\n/startattack\n'
    cancel.text2= '/petfollow\n/stopattack\n/stopcasting\n'
end



function WoWTools_MacroMixin:Init_List_Button()

    
    Init_List()
    Init_Other_Button()
end