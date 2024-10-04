--创建，空，按钮
local e= select(2, ...)
local function Save()
    return WoWTools_MacroMixin.Save
end









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




--创建，宏
--#######
local function Create_Macro_Button(name, icon, boy)
    if MacroNewButton:IsEnabled() and not UnitAffectingCombat('player') then
        local index = CreateMacro(name or ' ', icon or 134400, boy or '', MacroFrame.macroBase>0)- MacroFrame.macroBase
        MacroFrame:SelectMacro(index or 1)
        e.call(MacroFrame.Update, MacroFrame)
    end
end









--创建，空，按钮
--#############
local function Init()
    MacroFrame.newButton= WoWTools_ButtonMixin:Cbtn(MacroFrame, {size={22,22}, name='MacroNewEmptyButton', atlas='communities-chat-icon-plus'})
    function MacroFrame.newButton:set_atlas()
        self:SetNormalAtlas(MacroNewButton:IsEnabled() and 'communities-chat-icon-plus' or 'communities-chat-icon-minus')
    end
    MacroFrame.newButton:SetPoint('BOTTOMLEFT', MacroFrameTab2, 'BOTTOMRIGHT',2 ,0)
    MacroFrame.newButton:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
    function MacroFrame.newButton:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MacroMixin.addName)
        e.tips:AddLine(' ')
        local bat= UnitAffectingCombat('player')
        e.tips:AddDoubleLine(
            ((not MacroNewButton:IsEnabled() or bat) and '|cff9e9e9e' or '')
            ..(e.onlyChinese and '新建' or NEW), e.Icon.left
        )
        e.tips:AddDoubleLine((bat and '|cff9e9e9e' or '')..(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU), e.Icon.right)
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
            Create_Macro_Button(nil, nil, '')
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
                for index, tab in pairs(Save().mcaro) do
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
                                table.remove(Save().mcaro, arg2)
                                s:GetParent():Hide()
                            elseif not IsModifierKeyDown() then
                                Create_Macro_Button(arg1.name, arg1.icon, arg1.body)
                            end
                        end
                    }, level)
                end

                --清除，全部，保存宏
                e.LibDD:UIDropDownMenu_AddSeparator(level)
                local num= #Save().mcaro
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
                        StaticPopupDialogs['WoWTools_DeleteAllSaveMacro']={
                            text=((e.onlyChinese and '全部清除' or CLEAR_ALL)..' |cnGREEN_FONT_COLOR:#'..num)
                            ..('|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '危险！危险！危险！' or (VOICEMACRO_1_Sc_0..VOICEMACRO_1_Sc_0..VOICEMACRO_1_Sc_0))),
                            whileDead=true, hideOnEscape=true, exclusive=true,acceptDelay=3,
                            button1= e.onlyChinese and '确认' or RPE_CONFIRM,
                            button2= e.onlyChinese and '取消' or CANCEL,
                            OnAccept = function()
                                Save().mcaro={}
                                print(e.addName,WoWTools_MacroMixin.addName, e.onlyChinese and '全部清除' or CLEAR_ALL)
                            end,
                            EditBoxOnEscapePressed= function(s)
                                s:ClearFocus()
                                s:GetParent():Hide()
                            end,
                        }
                        StaticPopup_Show('WoWTools_DeleteAllSaveMacro')
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
            local selectIndex= WoWTools_MacroMixin:GetSelectIndex()
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
                            table.insert(Save().mcaro, {name=tab.name, icon=tab.icon, body=tab.body})
                            print(tab.body,'|n','|T'..icon..':0|t'..tab.name,'|n', WoWTools_MacroMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '保存' or SAVE))
                        end
                    },1)
                else
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= '|cff9e9e9e'..(e.onlyChinese and '保存' or SAVE),
                        notCheckable=true,
                        isTitle=true,
                    }, level)
                end
            else
                e.LibDD:UIDropDownMenu_AddButton({
                    text= '|cff9e9e9e'..(e.onlyChinese and '保存' or SAVE),
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
                    StaticPopupDialogs['WoWTools_DeleteAllMacro']={
                        text=(isGolbal
                            and ((e.onlyChinese and '通用宏' or GENERAL_MACROS)..' #'..global)
                            or (e.Player.col..format(e.onlyChinese and '%s专用宏' or CHARACTER_SPECIFIC_MACROS,  UnitName('player'))..'|r #'..perChar)
                        )
                        ..('|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '危险！危险！危险！' or (VOICEMACRO_1_Sc_0..VOICEMACRO_1_Sc_0..VOICEMACRO_1_Sc_0))),
                        whileDead=true, hideOnEscape=true, exclusive=true, acceptDelay=3,
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
                                e.call(MacroFrame.Update, MacroFrame)
                            end
                        end,
                        EditBoxOnEscapePressed= function(s)
                            s:ClearFocus()
                            s:GetParent():Hide()
                        end,
                    }
                    StaticPopup_Show('WoWTools_DeleteAllMacro')
                end
            }, level)
        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)--主菜单
    end)
    hooksecurefunc(MacroFrame, 'UpdateButtons', function(self)
        self.newButton:set_atlas()
    end)
end













function WoWTools_MacroMixin:Init_Create_Button()--创建，空，按钮
    Init()
end