--宏列表，位置
local e= select(2, ...)
local function Save()
    return WoWTools_MacroMixin.Save
end

local Button, NoteEditBox









local function Init_Menu(self, root)
    if WoWTools_MenuMixin:CheckInCombat(root) then--战斗中
        return
    end

    local sub

    sub=root:CreateButton(
        e.onlyChinese and '选择位置' or CHOOSE_LOCATION,
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

    
--打开选项界面
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MacroMixin.addName,})
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
end















--备注
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

    NoteEditBox:SetShown((point and point<3 and MacroFrame.macroBase==0) and true or false)
end








local function Init_EditBox()
    NoteEditBox=WoWTools_EditBoxMixn:CreateMultiLineFrame(MacroFrame, {
        font='GameFontHighlightSmall',
        instructions= e.onlyChinese and '备注' or LABEL_NOTE
    })
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





function WoWTools_MacroMixin:Init_Button()
    Init_EditBox()
    hooksecurefunc(MacroFrame, 'ChangeTab', Init_ChangeTab)
    Init()
end