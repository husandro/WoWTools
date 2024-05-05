local id, e= ...
local addName= MACRO--宏
local Save={
    --disabled= not e.Player.husandro,
    --toRightLeft= 1,2, nil --左边 右边 默认
    spellButton=e.Player.husandro,
    mcaro={},-- {name=tab.name, icon=tab.icon, body=tab.body}
}
--Blizzard_MacroUI.lua














--新建，宏，列表
--#############
local MacroButtonList={
    {macro='/reload'},--134400
    {macro='/fstack'},
    {macro='/etrace'},
    {macro='#showtooltip\n/cast [mod:alt]\n/cast [mod:ctrl]\n/cast [mod:shift][noflyable]\n/cast [advflyable]\n/cast [swimming]\n/cast [flyable]', name='Mount'},
    {macro='/click ExtraActionButton1', name='Extra'},
    --{macro=, name=, icon=, },
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
        local right= GetSpellInfo(29893)--[制造灵魂之井] ss
        local alt= GetSpellInfo(6201)--[制造治疗石] ss
        local ctrl= GetSpellInfo(698)--[召唤仪式]ss
        local shift= GetSpellInfo(20707)--[灵魂石]ss
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
        local alt= GetSpellInfo(48018)
        local spellName= GetSpellInfo(48020)
        if alt and spellName then
            return '/cast [mod:alt,@cursor]'.. alt
                ..'\n/cast '..spellName
        end
    elseif spellID==755 then--[生命通道]ss
        return '/stopcasting\n/cast [target=pet]'..name

    --LR
    elseif spellID==5384 then--[假死]LR
        if IsSpellKnownOrOverridesKnown(209997) then
            local spellName= GetSpellInfo(209997)
            if spellName then
                return '/petfollow\n/cast '..spellName..'\n/cast '..name
            end
        end
        return '/petfollow\n/cast '..name
    elseif spellID==2643--[多重射击]LR
        or spellID==257620--[多重射击]LR
        or spellID==187708--[削凿]LR
    then
        local spellName= GetSpellInfo(186265)
        if spellName then
            return '/cancelaura '..spellName..'\n/cast '..name
        end

    --FS
    elseif spellID==212653--[闪光术]
        or spellID==1953--[闪现术]
        or spellID==66--[隐形术]
        or spellID==110959--[强化隐形术]
    then
        local cancel= GetSpellInfo(45438)--[寒冰屏障]
        local text='/stopcasting'
        if cancel then
            text= text..'\n/cancelaura '..cancel
        end
        return text..'\n/cast '..name

    --FS
    elseif spellID==190336 then--[造餐术]
        local spellName= GetSpellInfo(190336)
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
        return '/cast '..name..'\n/y '..(GetSpellLink(spellID) or name)



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








--高亮，动作条
--ActionButton.lua
--[[Bug
local function Set_Action_Focus(spellID)
    
    if not e.Player.husandro or UnitAffectingCombat('player') then--出错，尝试调用保护功能 
        return
    end
    if spellID then
        e.call('UpdateOnBarHighlightMarksBySpell', spellID)
    else
        e.call('ClearOnBarHighlightMarks')
    end
    e.call('ActionBarController_UpdateAllSpellHighlights')
end
]]


--创建，宏
--#######
local function Create_Macro_Button(name, icon, boy)
    if MacroNewButton:IsEnabled() and not UnitAffectingCombat('player') then
        local index = CreateMacro(name or ' ', icon or 134400, boy or '', MacroFrame.macroBase>0)- MacroFrame.macroBase
        MacroFrame:SelectMacro(index or 1)
        MacroFrame:Update(true)
    end
end

--取得选定宏，index
--################
local function Get_Select_Index()
    local index= MacroFrame:GetSelectedIndex()
    if index then
        return MacroFrame:GetMacroDataIndex(index)
    else
        return MacroFrame.macroBase +1
    end
end


--创建，目标，功击，按钮
--####################
local function Create_Button(name)
    local btn= e.Cbtn(MacroEditButton, {size={60,22}, type=false})
    function btn:find_text(right)
        return (MacroFrameText:GetText() or ''):find(e.Magic(right and self.text2 or self.text))
    end
   function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        local col= self:find_text() and '|cff606060' or ''
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(col..self.text..(self.tip or ''), e.Icon.left)
        if self.text2 then
            e.tips:AddLine(' ')
            col= self:find_text(true) and '|cff606060' or ''
        end
        e.tips:AddDoubleLine(col..self.text2..(self.tip2 or ''), e.Icon.right)
        e.tips:Show()
    end
    btn:SetScript('OnClick', function(self, d)
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




--修改，当前图标
--Blizzard_MacroIconSelector.lua MacroPopupFrameMixin:OkayButton_OnClick()
local function Set_Texture_Macro(iconTexture)--修改，当前图标
    if UnitAffectingCombat('player') or not iconTexture then
        return
    end
    local macroFrame =MacroFrame
    local actualIndex = Get_Select_Index()
    if actualIndex then
        local name= GetMacroInfo(actualIndex)
        local index = EditMacro(actualIndex, name, iconTexture) - macroFrame.macroBase;--战斗中，出现错误
        e.call(MacroFrame.SaveMacro, macroFrame)
        macroFrame:SelectMacro(index or 1);
        local retainScrollPosition = true;
        macroFrame:Update(retainScrollPosition);
    end
end







--创建，法术，列表
--##############
local function Create_Spell_Menu(spellID, icon, name, texture)--创建，法术，列表
    e.LoadDate({id=spellID, type='spell'})
    local isKnown= IsSpellKnownOrOverridesKnown(spellID)
    local isPassive= IsPassiveSpell(spellID)
    local spellIcon= icon

    local color
    if isPassive then
        color= '|cff606060'
    elseif not isKnown then
        color= '|cnRED_FONT_COLOR:'
    end


    --icon= icon and '|T'..icon..':0|t' or ''
    local  macroText= Get_Spell_Macro(name, spellID)
    macroText= macroText and '|cnGREEN_FONT_COLOR:'..macroText..'|n |r' or nil

    local tipText= GetSpellDescription(spellID)
    if tipText then
        local head
        if isPassive then
            head= '|cff606060'..(e.onlyChinese and '被动' or SPELL_PASSIVE)..'|r'
        end
        if not isKnown then
            head= head and head..', ' or ''
            head= head..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '未学习' or TRADE_SKILLS_UNLEARNED_TAB)..'|r'
        end

        tipText= head and head..'|n'..tipText or tipText
    end
    tipText= ((macroText or tipText) and '|n' or '')..(macroText and macroText..'|n' or '')..(tipText or '')

    local headText= (UnitAffectingCombat('player') and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:')
            ..'Alt '..icon
            ..(e.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL))
            ..'|r|n|cff606060Ctrl '..(e.onlyChinese and '查询' or WHO)..' (BUG)|r'
            ..'|nShift '..(e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT)
    e.LibDD:UIDropDownMenu_AddButton({
        text=format('|A:%s:0:0|a', texture or '')..name..(macroText and '|cnGREEN_FONT_COLOR:*|r' or ''),
        tooltipOnButton=true,
        tooltipTitle=headText,
        tooltipText=tipText,
        colorCode=color,
        icon=icon,
        tSizeX=32,
        tSizeY=32,
        arg1={spellName=name, spellID=spellID, icon=spellIcon},

        notCheckable=true,
        func= function(_, tab)
            if IsShiftKeyDown() then
                local link=GetSpellLink(tab.spellID) or GetSpellInfo(tab.spellID) or tab.spellID
                link= 'spellID=='..tab.spellID..'--'..link
                e.Chat(link, nil, true)
                --if not ChatEdit_InsertLink(link) then
                    --ChatFrame_OpenChat(link)
                --end

            elseif IsControlKeyDown() then
                e.call('SpellBookFrame_OpenToSpell', tab.spellID)
                print(id, e.cn(addName), '|cnRED_FONT_COLOR:BUG|r', 'Ctrl+'..e.Icon.left..(e.onlyChinese and '查询' or WHO))

            elseif IsAltKeyDown() then
                Set_Texture_Macro(tab.icon)--修改，当前图标
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
    }, 1)
end



--宏，提示
--#######
local function set_btn_tooltips(self, index)
    index= self.selectionIndex or index
    if index then
        index= (self.selectionIndex and self.selectionIndex+ MacroFrame.macroBase) or index
        local name, icon, body = GetMacroInfo(index)
        if name and icon and body then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine('|cffffffff'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,  e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS, index), '|cffff00ff|T'..icon..':0|t'..name)
            e.tips:AddLine(body, nil,nil,nil, true)
            e.tips:AddLine(' ')
            local col= UnitAffectingCombat('player') and '|cff606060' or '|cffffffff'
            e.tips:AddDoubleLine(
                col..(e.onlyChinese and '删除' or DELETE),
                col..'Alt+'..(e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left
            )
            local spellID= GetMacroSpell(index)
            if spellID then
                e.LoadDate({id=spellID, type='spell'})
                local spellName, _, spellIcon= GetSpellInfo(spellID)
                if spellName and spellIcon then
                    e.tips:AddDoubleLine('|T'..spellIcon..':0|t'..spellName, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '法术' or SPELLS, spellID))
                end
                --Set_Action_Focus(spellID)
            end
            e.tips:Show()
            return icon
        end
    end
end
















--创建，空，按钮
--#############
local function Init_Create_Button()
    MacroFrame.newButton= e.Cbtn(MacroFrame, {size={22,22}, name='MacroNewEmptyButton', atlas='communities-chat-icon-plus'})
    function MacroFrame.newButton:set_atlas()
        self:SetNormalAtlas(MacroNewButton:IsEnabled() and 'communities-chat-icon-plus' or 'communities-chat-icon-minus')
    end
    MacroFrame.newButton:SetPoint('BOTTOMLEFT', MacroFrameTab2, 'BOTTOMRIGHT',2 ,0)
    MacroFrame.newButton:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
    function MacroFrame.newButton:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:AddLine(' ')
        local bat= UnitAffectingCombat('player')
        e.tips:AddDoubleLine(
            ((not MacroNewButton:IsEnabled() or bat) and '|cff606060' or '')
            ..(e.onlyChinese and '新建' or NEW), e.Icon.left
        )
        e.tips:AddDoubleLine((bat and '|cff606060' or '')..(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU), e.Icon.right)
        e.tips:Show()
        self:SetAlpha(0.5)
    end
    MacroFrame.newButton:SetScript('OnEnter', MacroFrame.newButton.set_Tooltips)

    MacroFrame.newButton:SetScript('OnMouseDown', function(self, d)--MacroPopupFrameMixin:OkayButton_OnClick()
        if UnitAffectingCombat('player') then
            return
        end


        --添加，空，按钮
        if d=='LeftButton' then
            Create_Macro_Button(nil, nil, '',  MacroFrame.macroBase > 0)
            self:set_Tooltips()
            return
        end

        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function(_, level, menuList)
            local global, perChar = GetNumMacros()
            local isGolbal= MacroFrame.macroBase==0
            local isZero= (isGolbal and global==0) or (not isGolbal and perChar==0)
            local isMax= (isGolbal and MacroFrame.macroMax==global) or (not isGolbal and MacroFrame.macroMax==perChar)
            local bat= UnitAffectingCombat('player')

            if menuList=='SAVE' then--二级菜单，保存宏，列表 {name=tab.name, icon=tab.icon, body=tab.body}
                for index, tab in pairs(Save.mcaro) do
                    e.LibDD:UIDropDownMenu_AddButton({
                        text='|T'..tab.icon..':0|t'..tab.name,
                        tooltipOnButton=true,
                        tooltipTitle='|T'..tab.icon..':0|t'..tab.name,
                        tooltipText=tab.body
                            ..'|n|n|cffffffffCtrl+'..e.Icon.left..(e.onlyChinese and '删除' or DELETE),
                        arg1=tab,
                        arg2=index,
                        notCheckable=true,
                        disabled= bat or isMax,
                        keepShownOnClick=true,
                        func= function(s, arg1, arg2)
                            if IsControlKeyDown() then
                                table.remove(Save.mcaro, arg2)
                                s:GetParent():Hide()
                            elseif not IsModifierKeyDown() then
                                Create_Macro_Button(arg1.name, arg1.icon, arg1.body)
                            end
                        end
                    }, level)
                end

                --清除，全部，保存宏
                e.LibDD:UIDropDownMenu_AddSeparator(level)
                local num= #Save.mcaro
                e.LibDD:UIDropDownMenu_AddButton({
                    text= (e.onlyChinese and '全部清除' or CLEAR_ALL)..' |cnGREEN_FONT_COLOR:#'..num,
                    disabled= num==0,
                    tooltipOnButton=true,
                    tooltipTitle='Ctrl+'..e.Icon.left,
                    notCheckable=true,
                    keepShownOnClick=true,
                    func= function()
                        if not IsControlKeyDown() then
                            return
                        end
                        StaticPopupDialogs[id..addName..'DeleteAllSaveMacro']={
                            text=((e.onlyChinese and '全部清除' or CLEAR_ALL)..' |cnGREEN_FONT_COLOR:#'..num)
                            ..('|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '危险！危险！危险！' or (VOICEMACRO_1_Sc_0..VOICEMACRO_1_Sc_0..VOICEMACRO_1_Sc_0))),
                            whileDead=true, hideOnEscape=true, exclusive=true,
                            button1= e.onlyChinese and '确认' or RPE_CONFIRM,
                            button2= e.onlyChinese and '取消' or CANCEL,
                            OnAccept = function()
                                Save.mcaro={}
                                print(id,e.cn(addName), e.onlyChinese and '全部清除' or CLEAR_ALL)
                            end,
                            EditBoxOnEscapePressed= function(s)
                                s:ClearFocus()
                                s:GetParent():Hide()
                            end,
                        }
                        StaticPopup_Show(id..addName..'DeleteAllSaveMacro')
                    end
                }, level)

                return
            end

            for _, tab in pairs(MacroButtonList) do
                local name= tab.name or tab.macro:gsub('/', '')
                name = name:match("(.-)\"") or name:match("(.-)\n") or name or ' '
                local icon= tab.icon or 134400
                local head= '|T'..icon..':0|t'..name
                local body= tab.macro
                e.LibDD:UIDropDownMenu_AddButton({
                    text= name,
                    icon= tab.icon,
                    tooltipOnButton=true,
                    tooltipTitle= head,
                    tooltipText=body,
                    disabled= bat or isMax,
                    notCheckable=true,
                    keepShownOnClick=true,
                    arg1={name=name, icon=icon, body=tab.macro},
                    func= function(_, arg1)
                        Create_Macro_Button(arg1.name, arg1.icon, arg1.body)
                    end
                }, level)
            end

            e.LibDD:UIDropDownMenu_AddSeparator(level)

            --保存， 选定宏
            local selectIndex= Get_Select_Index()
            if selectIndex then
                local name, icon, body = GetMacroInfo(selectIndex)
                if name and icon and body then
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= (e.onlyChinese and '保存' or SAVE)..' |T'..icon..':0|t'..name,
                        notCheckable=true,
                        tooltipOnButton=true,
                        tooltipTitle='|T'..icon..':0|t'..name..' |cnGREEN_FONT_COLOR:('..(e.onlyChinese and '保存' or SAVE)..')',
                        tooltipText= body,
                        arg1={name=name, icon=icon, body= body},
                        menuList='SAVE',
                        hasArrow=true,
                        func= function(_, tab)
                            table.insert(Save.mcaro, {name=tab.name, icon=tab.icon, body=tab.body})
                            print(tab.body,'|n','|T'..icon..':0|t'..tab.name,'|n',id, e.cn(addName), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '保存' or SAVE))
                        end
                    },1)
                else
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= '|cff606060'..(e.onlyChinese and '保存' or SAVE),
                        notCheckable=true,
                        isTitle=true,
                    }, level)
                end
            else
                e.LibDD:UIDropDownMenu_AddButton({
                    text= '|cff606060'..(e.onlyChinese and '保存' or SAVE),
                    notCheckable=true,
                    isTitle=true,
                }, level)
            end

            --删除所有宏
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            e.LibDD:UIDropDownMenu_AddButton({
                text=(e.onlyChinese and '删除全部' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DELETE, ALL))..e.Player.col..' #'..(isGolbal and global or perChar),
                disabled= isZero or bat,
                tooltipOnButton=true,
                tooltipTitle= (
                    isGolbal
                    and ((e.onlyChinese and '通用宏' or GENERAL_MACROS))
                    or (e.Player.col..format(e.onlyChinese and '%s专用宏' or CHARACTER_SPECIFIC_MACROS,  UnitName('player')))
                )..'|cnRED_FONT_COLOR: ('..(e.onlyChinese and '所有' or ALL)..')',
                tooltipText='Ctrl+'..e.Icon.left,
                notCheckable=true,
                keepShownOnClick=true,
                func= function()
                    if not IsControlKeyDown() then
                        return
                    end
                    StaticPopupDialogs[id..addName..'DeleteAllMacro']={
                        text=(isGolbal
                            and ((e.onlyChinese and '通用宏' or GENERAL_MACROS)..' #'..global)
                            or (e.Player.col..format(e.onlyChinese and '%s专用宏' or CHARACTER_SPECIFIC_MACROS,  UnitName('player'))..'|r #'..perChar)
                        )
                        ..('|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '危险！危险！危险！' or (VOICEMACRO_1_Sc_0..VOICEMACRO_1_Sc_0..VOICEMACRO_1_Sc_0))),
                        whileDead=true, hideOnEscape=true, exclusive=true,
                        button1= e.onlyChinese and '删除全部' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DELETE, ALL),
                        button2= e.onlyChinese and '取消' or CANCEL,
                        OnShow = function(s)
                            s.button1:SetEnabled(not UnitAffectingCombat('player'))
                        end,
                        OnAccept = function()
                            if not UnitAffectingCombat('player') then
                                if isGolbal then--通用宏
                                    for i = select(1, GetNumMacros()), 1, -1 do
                                        DeleteMacro(i)
                                    end
                                else--专用宏
                                    for i = MAX_ACCOUNT_MACROS + select(2,GetNumMacros()), 121, -1 do
                                        DeleteMacro(i)
                                    end
                                end
                                MacroFrame:SelectMacro(1)
                                MacroFrame:Update(true)
                            end
                        end,
                        EditBoxOnEscapePressed= function(s)
                            s:ClearFocus()
                            s:GetParent():Hide()
                        end,
                    }
                    StaticPopup_Show(id..addName..'DeleteAllMacro')
                end
            }, level)
        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)--主菜单
    end)
    hooksecurefunc(MacroFrame, 'UpdateButtons', function(self)
        self.newButton:set_atlas()
    end)
end





















--命令，按钮，列表
--##############
local function Init_List_Button()
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




    --法术书
    local last
    for i=1, MAX_SKILLLINE_TABS do
        local name, icon, _, _, _, _, shouldHide, specID = GetSpellTabInfo(i)
        if (i==1 or i==2 or specID) and not shouldHide and name then
            local btn= e.Cbtn(MacroEditButton, {size={24,24}, texture=icon})
            btn.index= i
            if not last then
                btn:SetPoint('TOPLEFT', MacroFrameSelectedMacroButton, 'BOTTOMRIGHT',0,8)
            else
                btn:SetPoint('LEFT', last, 'RIGHT')
            end

            if i==3 then
                local texture= btn:CreateTexture(nil, 'OVERLAY')
                texture:SetAtlas('Forge-ColorSwatchSelection')
                texture:SetPoint('CENTER')
                texture:SetVertexColor(0,1,0)
                texture:SetSize(28,28)
                texture:SetAlpha(0.7)
            end
            btn:SetScript('OnMouseDown', function(self)
                e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function()
                    local _, _, offset, numSlots = GetSpellTabInfo(self.index)
                    local num=0
                    for index= offset+1, offset+ numSlots do
                        local name2, _, icon2, _, _, _, spellID= GetSpellInfo(index, BOOKTYPE_SPELL)
                        num= num +1
                        if name2 and not IsPassiveSpell(index, BOOKTYPE_SPELL) and spellID then
                            Create_Spell_Menu(spellID, icon2, name2, 'services-number-'..math.ceil(num / SPELLS_PER_PAGE))
                        end
                    end
                    if self.index==1 then
                        e.LibDD:UIDropDownMenu_AddButton({
                            text='ExtraActionButton1',
                            tooltipOnButton=true,
                            tooltipTitle='/click ExtraActionButton1',
                            notCheckable=true,
                            func= function()
                                MacroFrameText:Insert('/click ExtraActionButton1\n')
                                MacroFrameText:SetFocus()
                            end
                        }, 1)
                        if e.Player.class=='MAGE' then--FS
                            e.LibDD:UIDropDownMenu_AddButton({
                                text=e.onlyChinese and '解散水元素' or 'PetDismiss',
                                tooltipOnButton=true,
                                tooltipTitle='/script PetDismiss()',
                                notCheckable=true,
                                func= function()
                                    MacroFrameText:Insert('/script PetDismiss()\n')
                                    MacroFrameText:SetFocus()
                                end
                            }, 1)
                        end
                    end
                end, 'MENU')
                e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)--主菜单
            end)
            btn:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'player')
            btn:SetScript('OnEvent', function(self)
                self:SetNormalTexture( select(2, GetSpellTabInfo(self.index)) or 0)
            end)
            last= btn
        end
    end








    --PVP， 天赋，法术
    local pvpButton= e.Cbtn(MacroEditButton, {size={24,24}, atlas='pvptalents-warmode-swords'})--pvptalents-warmode-swords-disabled
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
                    if talentInfo.spellID and talentInfo.name then--and not IsPassiveSpell(talentInfo.spellID)then
                        Create_Spell_Menu(talentInfo.spellID, talentInfo.icon, talentInfo.name, talentInfo.selected and e.Icon.select)
                    end
                end
            end
        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)--主菜单
    end)









    --角色，装备
    local equipButton= e.Cbtn(MacroEditButton, {size={24,24}, atlas=e.GetUnitRaceInfo({unit='player', reAtlas=true})})--atlas=e.Player.sex==2 and 'charactercreate-gendericon-male-selected' or 'charactercreate-gendericon-female-selected'})--pvptalents-warmode-swords-disabled
    equipButton:SetPoint('LEFT', pvpButton, 'RIGHT')
    equipButton:SetScript('OnMouseDown', function(self)
        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function()
            for slot=1,22 do
                local textureName = GetInventoryItemTexture("player", slot)
                if textureName then
                    local itemLink = GetInventoryItemLink('player', slot)
                    local name = itemLink and C_Item.GetItemNameByID(itemLink)
                    if name then
                        local spellName, spellID= C_Item.GetItemSpell(itemLink)
                        local spellTexture

                        if spellID then
                            e.LoadDate({id=spellID, type='spell'})
                            spellTexture= GetSpellTexture(spellID)

                        end
                        e.LibDD:UIDropDownMenu_AddButton({
                            text='|T'..textureName..':0|t'..itemLink..(((slot==13 or slot==14) and spellID) and e.Icon.toLeft2 or ''),
                            notCheckable=true,
                            icon= spellID and e.Icon.select or nil,
                            tooltipOnButton=true,
                            tooltipTitle='Alt '..(textureName and '|T'..textureName..':0|t' or '')
                                    ..(e.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL))
                                    ..'|n|cnGREEN_FONT_COLOR:'..(spellID and '/use|r ' or '/equip ')..name..'|r',
                            tooltipText= '|n'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS, slot)
                                    ..(spellID and '|n|n' or '')
                                    ..(spellTexture and '|T'..spellTexture..':0|t' or '')
                                    ..(spellID and GetSpellLink(spellID) or spellName or spellID or '')..(spellID and ' '..spellID or ''),
                            arg1={name=name, spellID=spellID, icon=textureName},
                            func= function(_, tab)
                                if IsAltKeyDown() then
                                    Set_Texture_Macro(tab.icon)--修改，当前图标
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










    --常用，宏
    local starButton= e.Cbtn(MacroEditButton, {size={24,24}, atlas='PetJournal-FavoritesIcon'})
    starButton:SetPoint('LEFT', equipButton, 'RIGHT')
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




    --表情，列表 
    local function Chat_Init_menu(list, level)
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
    --谈话
    local spellchButton= e.Cbtn(MacroFrameSelectedMacroButton, {size={22,22}, atlas='communities-icon-chat'})
    spellchButton:SetPoint('TOPLEFT', MacroFrameSelectedMacroButton, 'BOTTOMLEFT',-6,-1)
    spellchButton:SetScript('OnMouseDown', function(self)
        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function(_, level)
            Chat_Init_menu(TextEmoteSpeechList, level)
        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)
    end)
    --表情
    local emoteButton= e.Cbtn(MacroFrameSelectedMacroButton, {size={22,22}, texture='Interface\\Addons\\WoWTools\\Sesource\\Emojis\\greet'})
    emoteButton:SetPoint('LEFT', spellchButton, 'RIGHT')
    emoteButton:SetScript('OnMouseDown', function(self)
        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function(_, level)
            Chat_Init_menu(EmoteList, level)
        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)
    end)
end









































--选定宏，点击，弹出菜单，自定图标
--#############################
local function Init_Select_Macro_Button()
    --选定宏，index提示
    MacroFrame.numSelectionLable= e.Cstr(MacroFrameSelectedMacroButton)
    MacroFrame.numSelectionLable:SetAlpha(0.7)
    MacroFrame.numSelectionLable:SetPoint('RIGHT', MacroFrameSelectedMacroButton, 'LEFT', -1,0)
    MacroFrame.numSelectionLable:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.7) end)
    MacroFrame.numSelectionLable:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine( e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)
        e.tips:Show()
        self:SetAlpha(1)
    end)
    hooksecurefunc(MacroFrame, 'SelectMacro', function(self, index)
        self.numSelectionLable:SetText(index and index+MacroFrame.macroBase or '')
    end)

    --选定，宏，提示
    MacroFrameSelectedMacroButton:HookScript('OnEnter', function(self)
        local icon= set_btn_tooltips(self, Get_Select_Index())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(
            '|cnGREEN_FONT_COLOR:'
            ..(e.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL))
            ..(icon and '|T'..icon..':0|t' or ''),
            e.Icon.left
        )
        e.tips:Show()
    end)
    MacroFrameSelectedMacroButton:HookScript('OnLeave', function()
        e.tips:Hide()
        --Set_Action_Focus()
    end)

    --选定宏，点击，弹出菜单，自定图标
    MacroFrameSelectedMacroButton:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    MacroFrameSelectedMacroButton:HookScript('OnMouseDown', function(self)
        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function()
            if UnitAffectingCombat('player') then
                e.LibDD:UIDropDownMenu_AddButton({
                    text=e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT,
                    notCheckable=true,
                    isTitle=true,
                }, 1)
                return
            end
            local text= MacroFrameText:GetText()
            text= text and text..'\n' or ''
            local allTab={}

            --添加，物品，法术，图标=物品名称
            local function get_SpellItem_Texture(spell, item)
                if spell then--spell 字符
                    local icon= GetSpellTexture(spell) or select(3, GetSpellInfo(spell))
                    if icon then
                        local name= GetSpellInfo(spell) or spell
                        allTab[icon]= name
                    end

                elseif item then
                    local icon= C_Item.GetItemIconByID(item) or select(5, C_Item.GetItemInfoInstant(item))
                    if icon then
                        allTab[icon]=item
                    end
                end
            end

             --法术
            text= text:gsub(SLASH_CAST1..' (.-)\n', function(t)--/施放
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_CAST2..' (.-)\n', function(t)--/spell
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_CAST3..' (.-)\n', function(t)--/cast
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_CAST4..' (.-)\n', function(t)--/法术
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_CANCELAURA1..' (.-)\n', function(t)--/cancelaura
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_CANCELAURA2..' (.-)\n', function(t)--/cancelaura
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)

            --物品
            text= text:gsub(SLASH_USE1..' (.-)\n', function(t)--/use
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)

            text= text:gsub(SLASH_USE2..' (.-)\n', function(t)--/use
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_USE_TOY1..' (.-)\n', function(t)--/使用玩具
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_USE_TOY2..' (.-)\n', function(t)--/usetoy
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            --物品
            text= text:gsub(SLASH_EQUIP1..' (.-)\n', function(t)--/equip
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)

            text= text:gsub(SLASH_EQUIP2..' (.-)\n', function(t)--/eq
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_EQUIP3..' (.-)\n', function(t)--/equip
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_EQUIP4..' (.-)\n', function(t)--/eq
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_EQUIP_TO_SLOT1..' (.-)\n', function(t)--/equipslot
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_EQUIP_TO_SLOT2..' (.-)\n', function(t)--/equipslot
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)

            --区域，技能
            for _, zoneAbilities in pairs(C_ZoneAbility.GetActiveAbilities() or {}) do
                get_SpellItem_Texture(zoneAbilities.spellID)
            end

            for icon, name in pairs(allTab) do
                e.LibDD:UIDropDownMenu_AddButton({
                    text='|T'..icon..':0|t'..name,
                    notCheckable=true,
                    arg1=icon,
                    tooltipOnButton=true,
                    tooltipTitle=e.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL),
                    tooltipText=icon,
                    func= function(_, arg1)
                        Set_Texture_Macro(arg1)--修改，当前图标
                    end
                }, 1)
            end


            e.LibDD:UIDropDownMenu_AddButton({
                text='|T134400:0|t'..(e.onlyChinese and '无' or NONE),
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=134400,
                func= function()
                    Set_Texture_Macro(134400)--修改，当前图标
                end
            }, 1)

        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)--主菜单
    end)
end



































--宏列表，位置
--###########
local function Init_Macro_List()
    local toRightButton= e.Cbtn(MacroFrame.TitleContainer, {size={20,20}, icon='hide'})
    toRightButton:SetAlpha(0.5)
    if _G['MoveZoomInButtonPerMacroFrame'] then
        toRightButton:SetPoint('RIGHT', _G['MoveZoomInButtonPerMacroFrame'], 'LEFT')
    else
        toRightButton:SetPoint('LEFT',0, -2)
    end
    function toRightButton:set_texture()
        if Save.toRightLeft==1 then--左边
            self:SetNormalAtlas(e.Icon.toLeft)
        elseif Save.toRightLeft==2 then--右边
            self:SetNormalAtlas(e.Icon.toRight)
        else--默认
            self:SetNormalAtlas(e.Icon.icon)
        end
    end
    function toRightButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat'))
        e.tips:AddLine(' ')
        e.tips:AddLine((e.onlyChinese and '图标' or EMBLEM_SYMBOL)..':', e.Icon.left)
        local text= e.onlyChinese and '备注' or LABEL_NOTE
        text= (Save.toRightLeft and MacroFrame.macroBase==0) and '|cnGREEN_FONT_COLOR:'..text..'|r'
            or ('|cff606060'..text..'|r')
        e.tips:AddDoubleLine(e.Icon.toLeft2..(e.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT), (Save.toRightLeft==1 and format('|A:%s:0:0|a', e.Icon.select) or '')..text)
        e.tips:AddDoubleLine(e.Icon.toRight2..(e.onlyChinese and '右' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT), (Save.toRightLeft==2 and format('|A:%s:0:0|a', e.Icon.select) or '')..text)
        e.tips:AddDoubleLine('|A:'..e.Icon.icon..':0:0|a'..(e.onlyChinese and '默认' or DEFAULT), not Save.toRightLeft and format('|A:%s:0:0|a', e.Icon.select))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
    end
    toRightButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            if not Save.toRightLeft then
                Save.toRightLeft=1--左边
            elseif Save.toRightLeft==1 then
                Save.toRightLeft=2--右边
            elseif Save.toRightLeft==2 then
                Save.toRightLeft=nil--默认
            end
            Save.toRight= not Save.toRight and true or nil
            MacroFrame:ChangeTab(1)
            self:set_texture()
            self:set_tooltips()
        else
            e.OpenPanelOpting('|TInterface\\MacroFrame\\MacroFrame-Icon:0|t'..(e.onlyChinese and '宏' or addName))
        end
    end)
    toRightButton:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
    toRightButton:SetScript('OnEnter', toRightButton.set_tooltips)
    toRightButton:set_texture()



    --设置，宏，图标，位置，长度
    hooksecurefunc(MacroFrame, 'ChangeTab', function(self, tabID)
        self.MacroSelector:ClearAllPoints()
        if tabID==1 and (Save.toRightLeft==1 or Save.toRightLeft==2) then
            if Save.toRightLeft==1 then--左边
                self.MacroSelector:SetPoint('TOPRIGHT', self, 'TOPLEFT',10,-12)
                self.MacroSelector:SetPoint('BOTTOMLEFT', -319, 0)
            else--右边
                self.MacroSelector:SetPoint('TOPLEFT', self, 'TOPRIGHT',0,-12)
                self.MacroSelector:SetPoint('BOTTOMRIGHT', 319, 0)
            end
           -- self.MacroSelector:SetCustomStride(6);
        else
            --self.MacroSelector:SetCustomStride(12);

            self.MacroSelector:SetPoint('TOPLEFT', 12,-66)
            self.MacroSelector:SetPoint('BOTTOMRIGHT', MacroFrame, 'RIGHT', -6, 0)
        end
        --self:Update()
        --备注
        if not MacroFrame.NoteEditBox and Save.toRightLeft and MacroFrame.macroBase==0 then
            MacroFrame.NoteEditBox= e.Cedit(MacroFrame, {font='GameFontHighlightSmall'})
            MacroFrame.NoteEditBox:SetPoint('TOPLEFT', 8, -65)
            MacroFrame.NoteEditBox:SetPoint('BOTTOMRIGHT', MacroFrame, 'RIGHT', -6, 0)
            MacroFrame.NoteEditBox.edit:SetText(Save.noteText or (e.onlyChinese and '备注' or LABEL_NOTE))
            function MacroFrame.NoteEditBox:set_save_text()--保存备注
                local text= self.edit:GetText()
                if text and text~= (e.onlyChinese and '备注' or LABEL_NOTE) and text:gsub(' ','')~='' then
                    Save.noteText= text
                end
            end
            Save.noteText=nil
        end
        if self.NoteEditBox then
            self.NoteEditBox:SetShown((Save.toRightLeft and MacroFrame.macroBase==0) and true or false)
        end
    end)
end






















--初始
--####
local function Init()
    local regions= {MacroFrame:GetRegions()}
    for index, region in pairs(regions) do
        if region==MacroHorizontalBarLeft then
            region:Hide()
            local f= regions[index+1]
            if f and f:GetObjectType()=='Texture' then
                f:Hide()
            end
            break
        end
    end



    MacroFrameTextBackground:ClearAllPoints()
    MacroFrameTextBackground:SetPoint('TOPLEFT', MacroFrame, 'LEFT', 8, -78)
    MacroFrameTextBackground:SetPoint('BOTTOMRIGHT', -8, 42)
    MacroFrameScrollFrame:HookScript('OnSizeChanged', function(f)
        MacroFrameText:SetWidth(f:GetWidth())
    end)
    MacroFrameScrollFrame:ClearAllPoints()
    MacroFrameScrollFrame:SetPoint('TOPLEFT', MacroFrame, 'LEFT', 12, -83)
    MacroFrameScrollFrame:SetPoint('BOTTOMRIGHT', -32, 45)


    e.Set_Move_Frame(MacroFrame, {needSize=true, setSize=true, minW=338, minH=424, initFunc=function() end, sizeRestFunc=function(btn)
        btn.target:SetSize(338, 424)
    end})

    --选定宏
    local region= MacroFrameSelectedMacroButton:GetRegions()--外框
    if region and region:GetObjectType()=='Texture' then
        region:Hide()
    end
    MacroFrameSelectedMacroBackground:ClearAllPoints()
    MacroFrameSelectedMacroBackground:SetPoint('BOTTOMLEFT', MacroFrameTextBackground, 'TOPLEFT', 0, 8)

    MacroEditButton:ClearAllPoints()
    MacroEditButton:SetPoint('TOPLEFT', MacroFrameSelectedMacroButton, 'TOPRIGHT',2,2)
    MacroEditButton:SetSize(60,22)--170 22
    MacroEditButton:SetText(e.onlyChinese and '修改' or EDIT)

    --选定宏，名称
    MacroFrameSelectedMacroName:ClearAllPoints()
    MacroFrameSelectedMacroName:SetPoint('BOTTOMLEFT', MacroFrameSelectedMacroButton, 'TOPLEFT')
    MacroFrameSelectedMacroName:SetFontObject('GameFontNormal')



    --输入宏命令
    MacroFrameEnterMacroText:SetText('')
    MacroFrameEnterMacroText:Hide()

    --设置，焦点
    MacroFrameTextBackground.NineSlice:HookScript('OnMouseDown', function(_, d)
        if d=='LeftButton' then
            MacroFrameText:SetFocus()
        end
    end)

    --角色，专用宏，颜色
    if MacroFrameTab2 and MacroFrameTab2.Text then
        MacroFrameTab2.Text:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
    end

    --宏，提示
    hooksecurefunc(MacroButtonMixin, 'OnLoad', function(btn)
        btn:HookScript('OnEnter', set_btn_tooltips)--设置，宏，提示
        btn:HookScript('OnLeave', function()
            e.tips:Hide()
            --Set_Action_Focus()
        end)
        local texture2= btn:GetRegions()
        texture2:SetAlpha(0.3)--按钮，背景
        btn.Name:SetWidth(48)--名称，长度
        btn.SelectedTexture:ClearAllPoints()--设置，选项，特效
        btn.SelectedTexture:SetPoint('CENTER')
        btn.SelectedTexture:SetSize(44,44)
        btn.SelectedTexture:SetVertexColor(0,1,1)
        btn:SetScript('OnDoubleClick', function()--删除，宏 Alt+双击
            if IsAltKeyDown() and not UnitAffectingCombat('player') then
                MacroFrame:DeleteMacro()
            end
        end)
    end)

    local function MacroFrameInitMacroButton(macroButton, _, name)--Blizzard_MacroUI.lua
        if name ~= nil then
            macroButton.Name:SetText(e.WA_Utf8Sub(name, 2, 4))
        end
    end
    hooksecurefunc(MacroFrame.MacroSelector,'setupCallback', MacroFrameInitMacroButton)--MacroFrame.MacroSelector:SetSetupCallback(MacroFrameInitMacroButton)






    --保存，提示
    MacroSaveButton.saveTip= MacroSaveButton:CreateTexture()
    MacroSaveButton.saveTip:SetPoint('RIGHT', MacroSaveButton, 'LEFT')
    MacroSaveButton.saveTip:SetSize(22,22)
    MacroSaveButton.saveTip:SetAtlas('common-icon-rotateright')
    MacroSaveButton.saveTip:Hide()
    local function set_saveTip()
        local show= false
        local index= Get_Select_Index()
        if index then
            show= select(3, GetMacroInfo(index))~= MacroFrameText:GetText()
        end
        MacroSaveButton.saveTip:SetShown(show)
    end
    MacroFrameText:HookScript('OnTextChanged', set_saveTip)
    MacroSaveButton:HookScript('OnClick', set_saveTip)





    --宏数量
    --Blizzard_MacroUI.lua
    MacroFrameTab1.label= e.Cstr(MacroFrameTab1)
    MacroFrameTab1.label:SetPoint('BOTTOM', MacroFrameTab1, 'TOP', 0, -8)
    MacroFrameTab1.label:SetAlpha(0.7)
    MacroFrameTab2.label= e.Cstr(MacroFrameTab2)
    MacroFrameTab2.label:SetPoint('BOTTOM', MacroFrameTab2, 'TOP', 0, -8)
    MacroFrameTab2.label:SetAlpha(0.7)
    MacroFrameTab2.label:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
    hooksecurefunc(MacroFrame, 'Update', function()
    	local numAccountMacros, numCharacterMacros
        numAccountMacros, numCharacterMacros = GetNumMacros()
        numAccountMacros= numAccountMacros or 0
        numAccountMacros= numAccountMacros==MAX_ACCOUNT_MACROS and '|cff606060'..numAccountMacros or numAccountMacros

        numCharacterMacros= numCharacterMacros or 0
        numCharacterMacros= numCharacterMacros==MAX_CHARACTER_MACROS and '|cff606060'..numCharacterMacros or numCharacterMacros

        MacroFrameTab1.label:SetText(numAccountMacros..'/'..MAX_ACCOUNT_MACROS)
        MacroFrameTab2.label:SetText(numCharacterMacros..'/'..MAX_CHARACTER_MACROS)
    end)




    MacroFrame.Menu= CreateFrame("Frame", nil, MacroFrame, "UIDropDownMenuTemplate")
    Init_Macro_List()--宏列表，位置
    Init_Select_Macro_Button()--选定宏，点击，弹出菜单，自定图标
    Init_List_Button()--命令，按钮，列表
    Init_Create_Button()--创建，空，按钮
end




















local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.mcaro= Save.mcaro or {}
            --添加控制面板
            e.AddPanel_Check({
                name= '|TInterface\\MacroFrame\\MacroFrame-Icon:0|t'..(e.onlyChinese and '宏' or addName),
                tooltip= ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中错误' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ERRORS)))
                    ..'|r|n'..(e.onlyChinese and '备注：如果错误，请取消此选项' or 'note: If you get error, please disable this'),
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            --if e.Player.husandro then
                --C_Timer.After(2, ShowMacroFrame)
           -- end

            if Save.disabled  then
                self:UnregisterEvent('ADDON_LOADED')

            elseif C_AddOns.IsAddOnLoaded("MacroToolkit") then
                print(id, e.cn(addName),
                    e.GetEnabeleDisable(false), 'MacroToolkit',
                    e.onlyChinese and '插件' or ADDONS
                )
            end
        elseif arg1=='Blizzard_MacroUI' then
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            --保存备注
            if MacroFrame and MacroFrame.NoteEditBox then
                MacroFrame.NoteEditBox:set_save_text()
            end
            WoWToolsSave[addName]=Save
        end
    end
end)