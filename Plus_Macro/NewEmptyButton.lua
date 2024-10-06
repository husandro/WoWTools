--创建，空，按钮
local e= select(2, ...)
local function Save()
    return WoWTools_MacroMixin.Save
end
--[[
local global, perChar = GetNumMacros()
local isGolbal= MacroFrame.macroBase==0
local isZero= (isGolbal and global==0) or (not isGolbal and perChar==0)
local isMax= (isGolbal and MacroFrame.macroMax==global) or (not isGolbal and MacroFrame.macroMax==perChar)
]]

local Button





--新建，宏，列表
--#############
local MacroButtonList={
    {macro='/reload', name='reload'},--134400
    {macro='/fstack', name='fstack'},
    {macro='/etrace', name='etrace'},
    {macro='#showtooltip\n/cast [mod:alt]\n/cast [mod:ctrl]\n/cast [mod:shift][noflyable]\n/cast [advflyable]\n/cast [swimming]\n/cast [flyable]', name='Mount'},
    {macro='/click ExtraActionButton1', name='Extra'},
    --{macro=, name=, icon=, },
}



local function Init_Menu(_, root)
--战斗中/已满
    if not MacroNewButton:IsEnabled() then
        root:CreateTitle(e.onlyChinese and '已满' or LFG_LIST_APP_FULL)
        return
    elseif WoWTools_MenuMixin:CheckInCombat() then
        return
    end



--列表
    local sub, sub2, sub3, num, num2, text
    for _, tab in pairs(MacroButtonList) do
        sub=root:CreateButton(
            '|T'..(tab.icon or 0)..':0|t'..tab.name,
        function(data)
--新建，宏
            WoWTools_MacroMixin:CreateMacroNew(data.name, data.icon, data.macro)
            return MenuResponse.Open
        end, {name=tab.name, icon=tab.icon, macro=tab.macro})
--提示
        sub:SetTooltip(function(tooltip, description)
            tooltip:AddLine( '|T'..(description.data.icon or 0)..':0|t'
                ..(WoWTools_MacroMixin:GetSpaceName(description.data.name) or '')
            )
            tooltip:AddLine(' ')
            tooltip:AddLine(description.data.macro, nil, nil, nil, true)
        end)
--禁用/启用
    end

    


--保存
    root:CreateDivider()
    local selectIndex= WoWTools_MacroMixin:GetSelectIndex()
    local name, icon, body, saveName
    if selectIndex then
        name, icon, body = GetMacroInfo(selectIndex)
        local itemName, itemLink= GetMacroItem(selectIndex)
        local spellID= GetMacroSpell(selectIndex)
        e.LoadData({id=itemLink, type='item'})
        e.LoadData({id=spellID, type='spell'})
        local spellName= spellID and C_Spell.GetSpellName(spellID)

        saveName= (icon and ' |T'..(icon or 134400)..':0|t')..(name==' ' and itemName or spellName or name or ' ')
    end
    sub=root:CreateCheckbox(
        ((not saveName or body=='') and '|cff9e9e9e' or '')
        ..(e.onlyChinese and '保存' or SAVE)..(saveName or ''),
    function(data)
        return data.saveName and Save().macro[data.saveName]
    end, function(data)
        if data.saveName and data.body and data.body~='' then
            Save().macro[data.saveName]= not Save().macro[data.saveName] and {name=name, icon=icon, body=body} or nil
        end
    end, {name=name, icon=icon, body=body, saveName=saveName})

    sub:SetTooltip(function(tooltip, description)
        tooltip:AddLine(description.data.saveName)
        tooltip:AddLine(description.data.body)
    end)

--保存，列表
    num=0
    for saveName2, tab in pairs(Save().macro) do
--新建, 列表内容
        sub2=sub:CreateButton(
            saveName2,
        function(data)
            WoWTools_MacroMixin:CreateMacroNew(data.tab.name, data.tab.icon, data.tab.body)--新建，宏
        end, {saveName=saveName, tab=tab})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.saveName)
            if description.data.tab.body then
                tooltip:AddLine(description.data.tab.body)
                tooltip:AddLine(' ')
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '新建' or NEW)..e.Icon.left)
            else
                tooltip:AddLine((e.onlyChinese '无' or NONE))
            end
        end)
--删除
        sub3=sub2:CreateCheckbox(
            '|A:128-RedButton-Delete:0:0|a'
            ..(e.onlyChinese and '删除' or DELETE),
        function(data)
            return Save().macro[data.saveName2]
        end, function(data)
            Save().macro[data.saveName2]= not Save().macro[data.saveName2] and data.tab or nil

            if Save().macro[data.saveName2] then
                print(WoWTools_MacroMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '保存' or SAVE))
            else
                print(WoWTools_MacroMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE))
                print(data.tab.body)
            end
        end, {saveName2=saveName2, tab=tab})
        sub3:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.saveName2)
            tooltip:AddLine(description.data.tab.body)
        end)
        num=num+1
    end

    if num>1 then
--全部清除
        sub:CreateDivider()
        WoWTools_MenuMixin:ClearAll(sub, function() Save().macro={} end)
--SetGridMode
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end








    
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MacroMixin.addName,})

    
    num, num2= GetNumMacros()
    text= (e.onlyChinese and '全部删除，通用宏' or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DELETE, ALL)..', '..GENERAL_MACROS))
    ..(num==0 and '|cff9e9e9e' or '')..num
    sub:CreateButton(
        '|A:128-RedButton-Delete:0:0|a'..text,
    function()
        StaticPopup_Show('WoWTools_OK',
        '|A:128-RedButton-Delete:32:32|a'..text,
        nil,
        {SetValue=function()
            if UnitAffectingCombat('player') then return end
            print(WoWTools_MacroMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE))
            for i = GetNumMacros(), 1, -1 do
                if IsModifierKeyDown() or UnitAffectingCombat('player') then
                    return
                end
                name, icon, body = GetMacroInfo(i)
                DeleteMacro(i)
                print(i..') |T'..(icon or 134400)..':0|t'..(WoWTools_MacroMixin:GetSpaceName(name) or ''), '|cff9e9e9eAlt'..(e.onlyChinese and '取消' or CANCEL))
            end
        end})
    end)
end




--创建，空，按钮
--#############
local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(MacroFrame, {size={22,22}, name='WoWTools_MacroNewEmptyButton', icon='hide'})
    Button.texture= Button:CreateTexture(nil, 'ARTWORK')
    Button.texture:SetAtlas('communities-chat-icon-plus')
    Button.texture:SetAllPoints()

    Button:SetPoint('BOTTOMLEFT', MacroFrameTab2, 'BOTTOMRIGHT',2 ,0)
    Button:SetScript('OnLeave', GameTooltip_Hide)
    function Button:set_Tooltips()
        local col= WoWTools_MacroMixin:IsCanCreateNewMacro() and '' or '|cff9e9e9e'
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(col..(e.onlyChinese and '新建' or NEW)..e.Icon.left, e.Icon.right..col..(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU))
        e.tips:Show()
    end

    Button:SetScript('OnEnter', Button.set_Tooltips)
    Button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            WoWTools_MacroMixin:CreateMacroNew()--新建，宏
        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    Button:SetScript('OnMouseUp', Button.set_Tooltips)


    hooksecurefunc(MacroFrame, 'UpdateButtons', function()
        if WoWTools_MacroMixin:IsCanCreateNewMacro() then
            Button.texture:SetVertexColor(0,1,0)
        else
            Button.texture:SetVertexColor(1,1,1)
        end
    end)
end
    --[[MacroFrame.newButton:SetScript('OnMouseDown', function(self, d)--MacroPopupFrameMixin:OkayButton_OnClick()
        if UnitAffectingCombat('player') then
            return
        end


        --添加，空，按钮
        if d=='LeftButton' then
            WoWTools_MacroMixin:CreateMacroNew(nil, nil, '')
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
                for index, tab in pairs(Save().macro) do
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
                                table.remove(Save().macro, arg2)
                                s:GetParent():Hide()
                            elseif not IsModifierKeyDown() then
                                WoWTools_MacroMixin:CreateMacroNew(arg1.name, arg1.icon, arg1.body)
                            end
                        end
                    }, level)
                end

                --清除，全部，保存宏
                e.LibDD:UIDropDownMenu_AddSeparator(level)
                local num= #Save().macro
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
                                Save().macro={}
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
                        WoWTools_MacroMixin:CreateMacroNew(arg1.name, arg1.icon, arg1.body)
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
                            table.insert(Save().macro, {name=tab.name, icon=tab.icon, body=tab.body})
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
    end)]]














function WoWTools_MacroMixin:Init_AddNew_Button()--创建，空，按钮
    Init()
end