--宏列表，位置
local e= select(2, ...)
local function Save()
    return WoWTools_MacroMixin.Save
end

local Button, NoteEditBox, ScrollBoxBackground









local function Init_Menu(self, root)
    if WoWTools_MenuMixin:CheckInCombat(root) then--战斗中
        return
    end

    local sub


    sub=root:CreateButton(
        e.onlyChinese and '通用宏' or GENERAL_MACROS,
    function()
        return MenuResponse.Open
    end)

    for value, info in pairs ({
        {text=e.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT},
        {text=e.onlyChinese and '右' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT },
        {text=e.onlyChinese and '默认' or DEFAULT },
    }) do
        sub:CreateCheckbox(
            info.text,
        function(data)
            return Save().toRightLeft==data.value
        end, function(data)
            Save().toRightLeft=data.value
            self:set_texture()
            e.call(MacroFrame.ChangeTab, MacroFrame, 1)
        end, {value=value})
    end
--按钮增强
    sub=root:CreateCheckbox(
        e.onlyChinese and '按钮增强' or 'Button Plus',
    function()
        return not Save().hideBottomList
    end, function()
        Save().hideBottomList= not Save().hideBottomList and true or nil
        WoWTools_MacroMixin.BottomListFrame:settings()
    end)
--缩放
    WoWTools_MenuMixin:ScaleRoot(sub,
    function()
        return Save().bottomListScale or 1
    end, function(value)
        Save().bottomListScale=value
        WoWTools_MacroMixin.BottomListFrame:settings()
    end)

--打开选项界面
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MacroMixin.addName,})
end











--设置，列表
local function Init_ChangeTab(self, tabID)
    self.MacroSelector:ClearAllPoints()

    local point= Save().toRightLeft

    if tabID==1 and (point==1 or point==2) then
        if point==1 then--左边
            self.MacroSelector:SetPoint('TOPRIGHT', self, 'TOPLEFT',10,-12)
            self.MacroSelector:SetPoint('BOTTOMLEFT', -319, 0)
        else--右边
            self.MacroSelector:SetPoint('TOPLEFT', self, 'TOPRIGHT',0,-12)
            self.MacroSelector:SetPoint('BOTTOMRIGHT', 319, 0)
        end
    else
        self.MacroSelector:SetPoint('TOPLEFT', 12,-66)
        self.MacroSelector:SetPoint('BOTTOMRIGHT', MacroFrame, 'RIGHT', -6, 0)
    end

    local show=(point and point<3 and MacroFrame.macroBase==0) and true or false
    NoteEditBox:SetShown(show)
    ScrollBoxBackground:SetShown(show)
end
















local function Init_EditBox()
    NoteEditBox=WoWTools_EditBoxMixn:CreateMultiLineFrame(MacroFrame, {
        font='GameFontHighlightSmall',
        instructions= e.onlyChinese and '备注' or LABEL_NOTE
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
end














--创建，目标，功击，按钮
--####################
local function Create_Button(name)
    local btn= WoWTools_ButtonMixin:Cbtn(MacroFrameSelectedMacroButton, {size={60,22}, type=false})
    function btn:find_text(right)
        return (MacroFrameText:GetText() or ''):find(WoWTools_TextMixin:Magic(right and self.text2 or self.text))
    end
   function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()

        if UnitAffectingCombat('player') then
            e.tips:AddLine(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        else
            e.tips:AddDoubleLine(e.addName, WoWTools_MacroMixin.addName)
            local col= self:find_text() and '|cff9e9e9e' or ''
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(col..self.text..(self.tip or ''), e.Icon.left)
            if self.text2 then
                e.tips:AddLine(' ')
                col= self:find_text(true) and '|cff9e9e9e' or ''
            end
            e.tips:AddDoubleLine(col..self.text2..(self.tip2 or ''), e.Icon.right)
        end
        e.tips:Show()
    end
    btn:SetScript('OnClick', function(self, d)
        if UnitAffectingCombat('player') then return end
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




















local function Init()
    Button= WoWTools_ButtonMixin:CreateMenu(MacroFrame.TitleContainer, {hideIcon=true})
    Button:SetFrameLevel(MacroFrame.TitleContainer:GetFrameLevel()+1)
    Button:SetPoint('LEFT',0, -2)
    Button:SetAlpha(0.5)
    Button:SetupMenu(Init_Menu)

    function Button:set_texture()
        local point= Save().toRightLeft
        self:SetNormalAtlas(
            point==1 and e.Icon.toLeft--左边
            or point==2 and e.Icon.toRight--右边
            or e.Icon.icon
        )
    end

    Button:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
    Button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MacroMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat'))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(' ', (e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..e.Icon.left)
        e.tips:Show()
        self:SetAlpha(1)
    end)

    Button:set_texture()



    ScrollBoxBackground=WoWTools_TextureMixin:CreateBackground(MacroFrame.MacroSelector.ScrollBox)--, {isAllPoint=true})
    ScrollBoxBackground:SetAllPoints(MacroFrame.MacroSelector.ScrollBox.Shadows)

    Init_EditBox()
    Init_Other_Button()
    hooksecurefunc(MacroFrame, 'ChangeTab', Init_ChangeTab)--设置，列表
end












function WoWTools_MacroMixin:Init_Button()
    Init()
end