--宏列表，位置

local function Save()
    return WoWToolsSave['Plus_Macro2']
end

local Button, TargetButton, AttackButton, NoteEditBox




local PointTab={
    {value=1, text=WoWTools_DataMixin.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT},
    {value=2, text=WoWTools_DataMixin.onlyChinese and '右' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT},
    {value=3, text=WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT},
    '-',
    {value=4, text=WoWTools_DataMixin.onlyChinese and '左|右' or (HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT..'|'..HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT)}
}







local function Init_Menu(self, root)
    if WoWTools_MenuMixin:CheckInCombat(root) then--战斗中
        return
    end
    local sub, num, num2, text

--备注
    root:CreateButton(
        '|A:dressingroom-button-appearancelist-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '备注' or LABEL_NOTE),
    function()
        WoWTools_TextMixin:ShowText(
            Save().noteText,
            WoWTools_DataMixin.onlyChinese and '宏' or MACRO,
            {onHide=function(text)
                Save().noteText= text
                if NoteEditBox:IsVisible() then
                    NoteEditBox:SetText(text)
                end
            end}
        )
        return MenuResponse.Open
    end)

--布局
    root:CreateDivider()
    sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '布局' or HUD_EDIT_MODE_LAYOUT:gsub(HEADER_COLON, ''),
    function()
        return MenuResponse.Open
    end)

    for _, info in pairs (PointTab) do
        if info=='-' then
            sub:CreateDivider()
        else
            sub:CreateRadio(
                info.text,
            function(data)
                return Save().toRightLeft==data.value
            end, function(data)
                if WoWTools_MacroMixin:IsSecure() then
                    Save().toRightLeft=data.value
                    --self:set_texture()
                    WoWTools_Mixin:Call(MacroFrame.ChangeTab, MacroFrame, 1)
                    TargetButton:settings()
                end
                return MenuResponse.Refresh
            end, {value=info.value})
        end
    end

--按钮增强
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '按钮增强' or 'Button Plus',
    function()
        return not Save().hideBottomList
    end, function()
        Save().hideBottomList= not Save().hideBottomList and true or nil
        WoWTools_MacroMixin.BottomListFrame:settings()
        WoWTools_MacroMixin.NewEmptyButton:settings()
        TargetButton:settings()
    end)

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return Save().bottomListScale or 1
    end, function(value)
        Save().bottomListScale=value
        WoWTools_MacroMixin.BottomListFrame:settings()
    end)



--打开，选项界面
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MacroMixin.addName,})

    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '全部删除' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DELETE, ALL))
    sub:CreateDivider()

--删除，通用宏
    num, num2= GetNumMacros()
    text= (WoWTools_DataMixin.onlyChinese and '通用宏' or GENERAL_MACROS)..(num==0 and ' |cff9e9e9e#' or ' #')..num
    sub:CreateButton(
        '|A:XMarksTheSpot:0:0|a'..text,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        '|A:XMarksTheSpot:32:32|a|n'..data.text..'|n|n',
        nil,
        {SetValue=function()
            if not WoWTools_MacroMixin:IsSecure() then
                return
            end
            print(WoWTools_MacroMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE))
            for i = GetNumMacros(), 1, -1 do
                if IsModifierKeyDown() or UnitAffectingCombat('player') then
                    return
                end
                local name, icon = GetMacroInfo(i)
                DeleteMacro(i)
                print(i..') ', WoWTools_MacroMixin:GetName(name, icon))
            end
        end})
    end, {text=text})

--删除,专用宏
    sub:CreateDivider()
    text=format(WoWTools_DataMixin.onlyChinese and '%s专用宏' or CHARACTER_SPECIFIC_MACROS, WoWTools_UnitMixin:GetPlayerInfo(nil, WoWTools_DataMixin.Player.GUID, nil, {reName=true}))
        ..(num2==0 and ' |cff9e9e9e#' or ' #')..num2
    sub:CreateButton(
        '|A:XMarksTheSpot:0:0|a'..text,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        '|A:XMarksTheSpot:32:32|a|n'..data.text..'|n|n',
        nil,
        {SetValue=function()
            if not WoWTools_MacroMixin:IsSecure() then
                return
            end
            print(WoWTools_MacroMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE))
            for  i = MAX_ACCOUNT_MACROS + select(2,GetNumMacros()), 121, -1 do
                if IsModifierKeyDown() or UnitAffectingCombat('player') then
                    return
                end
                local name, icon = GetMacroInfo(i)
                DeleteMacro(i)
                print(i..') ', WoWTools_MacroMixin:GetName(name, icon))
            end
        end})
    end, {text=text})
end














--创建，目标，功击，按钮
--####################
local function Create_Button(name)
    local btn= WoWTools_ButtonMixin:Cbtn(TargetButton or MacroFrameSelectedMacroButton, {size={60,22}, isUI=true})
    function btn:find_text(right)
        return (MacroFrameText:GetText() or ''):find(WoWTools_TextMixin:Magic(right and self.text2 or self.text))
    end
   function btn:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()

        if InCombatLockdown() then
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        else
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MacroMixin.addName)
            local col= self:find_text() and '|cff9e9e9e' or ''
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(col..self.text..(self.tip or ''), WoWTools_DataMixin.Icon.left)
            if self.text2 then
                GameTooltip:AddLine(' ')
                col= self:find_text(true) and '|cff9e9e9e' or ''
            end
            GameTooltip:AddDoubleLine(col..self.text2..(self.tip2 or ''), WoWTools_DataMixin.Icon.right)
        end
        GameTooltip:Show()
    end
    btn:SetScript('OnClick', function(self, d)
        if InCombatLockdown() then return end
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







local function Init_Created()
--备注 EditBox
    NoteEditBox=WoWTools_EditBoxMixin:CreateMultiLineFrame(MacroFrame, {
        font='GameFontHighlightSmall',
        isInstructions= WoWTools_DataMixin.onlyChinese and '备注' or LABEL_NOTE
    })
    WoWTools_MacroMixin.NoteEditBox= NoteEditBox

    NoteEditBox:SetPoint('TOPLEFT', 8, -65)
    NoteEditBox:SetPoint('BOTTOMRIGHT', MacroFrame, 'RIGHT', -6, 0)
    NoteEditBox:Hide()
    NoteEditBox.editBox:SetScript('OnHide', function(self)--保存备注
        Save().noteText= self:GetText()
        self:SetText("")
        self:ClearFocus()
    end)
    NoteEditBox.editBox:SetScript('OnShow', function(self)
        self:SetText(Save().noteText or '')
    end)


--目标
    TargetButton= Create_Button(WoWTools_DataMixin.onlyChinese and '目标' or TARGET)
    WoWTools_MacroMixin.TargetButton= WoWTools_MacroMixin
    --TargetButton:SetPoint('LEFT', MacroEditButton, 'RIGHT',8,0)

    TargetButton.text='#showtooltip\n/targetenemy [noharm][dead]\n'
    TargetButton.text2='/cancelaura '
    TargetButton.textCursor=0
    TargetButton.text2Cursor=nil
    TargetButton.tip=nil
    TargetButton.tip2=WoWTools_DataMixin.onlyChinese and '光环名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AURAS, NAME)
    function TargetButton:settings()
        self:ClearAllPoints()
        local point= Save().toRightLeft
        if point==4 then--左|右
            self:SetPoint('BOTTOMRIGHT', MacroFrame, 'BOTTOM', 0, 4)
        else
            self:SetPoint('LEFT', MacroEditButton, 'RIGHT',8,0)
        end
        self:SetShown(not Save().hideBottomList)
    end
    TargetButton:settings()

--攻击
    AttackButton= Create_Button(WoWTools_DataMixin.onlyChinese and '攻击' or ATTACK)
    AttackButton:SetPoint('LEFT', TargetButton, 'RIGHT')
    AttackButton.text= '/petattack\n/startattack\n'
    AttackButton.text2= '/petfollow\n/stopattack\n/stopcasting\n'

end


















local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(MacroFrameCloseButton, {size=23, atlas='ui-questtrackerbutton-filter'})
    Button:SetPoint('RIGHT', MacroFrameCloseButton, 'LEFT', -2, 0)


    Button:SetScript('OnLeave', GameTooltip_Hide)
    Button:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MacroMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat'))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(' ', (WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)
    Button:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)


    Button.Text= WoWTools_LabelMixin:Create(MacroFrame.TitleContainer, {color={r=1,g=0,b=0}, size=16})
    Button.Text:SetPoint('BOTTOMRIGHT', Button, 'TOPRIGHT', 0, 2)
    Button.Text:SetText(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)


    Button:SetScript('OnShow', function(self)
        self:RegisterEvent('PLAYER_REGEN_DISABLED')
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        self.Text:SetShown(InCombatLockdown())
    end)
    Button:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
    end)
    Button:SetScript('OnEvent', function(self, event)
        self.Text:SetShown(event=='PLAYER_REGEN_DISABLED')
    end)
end












function WoWTools_MacroMixin:Init_Button()
    Init()
    Init_Created()
end