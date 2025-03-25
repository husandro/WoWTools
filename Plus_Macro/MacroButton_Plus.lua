



local function Delete_Macro(self)
    local index= MacroFrame:GetSelectedIndex()

    if InCombatLockdown()
        or not MacroDeleteButton:IsEnabled()
        or not index or index~=self.selectionIndex
        or WoWTools_Mixin:IsLockFrame(MacroFrame)
    then
        return
    end


    index= MacroFrame:GetMacroDataIndex(index)

    local name, icon, body = GetMacroInfo(index)

    WoWTools_Mixin:Call(MacroFrame.DeleteMacro, MacroFrame)

    if name then
        print(WoWTools_MacroMixin.addName,
            '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '删除' or DELETE),
            '|r', WoWTools_MacroMixin:GetName(name, icon)
        )
        if body and body~='' then
            print(body)
        end
    end
end










--选定, 操作
local function Init_Menu(self, root)
--战斗中
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    do
        if self.selectionIndex and self.selectionIndex~=MacroFrame:GetSelectedIndex() then
            MacroFrame:SelectMacro(self.selectionIndex)
            MacroPopupFrame:Hide()
        end
    end

    local sub
    local index= WoWTools_MacroMixin:GetSelectIndex()
    local isSelect= self:GetSelectorFrame():IsSelected(self.selectionIndex)--self.selectionIndex and self.selectionIndex==MacroFrame:GetSelectedIndex()

--保存
    WoWTools_MacroMixin:Save_Macro_Menu(self, root)

--修改
    sub=root:CreateButton(
        '|A:QuestLegendary:0:0|a'..(WoWTools_Mixin.onlyChinese and '修改' or EDIT),
    function()
        if not InCombatLockdown() then
            WoWTools_Mixin:Call(MacroEditButton_OnClick, MacroFrame, self)
        end
        return MenuResponse.Open
    end, {index=index})
    sub:SetEnabled(isSelect)
    WoWTools_MacroMixin:SetMenuTooltip(sub)

--删除
    root:CreateDivider()
    sub=root:CreateButton(
        '|A:XMarksTheSpot:0:0|a'
        ..(isSelect and '|cnRED_FONT_COLOR:' or '')..(WoWTools_Mixin.onlyChinese and '删除' or DELETE),
    function()
        Delete_Macro(self)
    end, {index=index})
    sub:SetEnabled(isSelect)
    WoWTools_MacroMixin:SetMenuTooltip(sub)

--新建
    root:CreateDivider()
    sub=root:CreateButton(
        '|A:communities-chat-icon-plus:0:0|a'..(WoWTools_Mixin.onlyChinese and '新建' or NEW),
    function()
        WoWTools_MacroMixin:CreateMacroNew()--新建，宏
        return MenuResponse.Open
    end)
    sub:SetEnabled(WoWTools_MacroMixin:IsCanCreateNewMacro())
end













--列表，按钮，操作
local function Set_OnLoad(btn)
    if btn.OnDoubleClick then
        return
    end

    function btn:set_on_enter()--设置，宏，提示
        WoWTools_MacroMixin:SetTooltips(self)
    end
    btn:HookScript('OnEnter', btn.set_on_enter)
    btn:HookScript('OnLeave', GameTooltip_Hide)

    local texture2= btn:GetRegions()
    texture2:SetAlpha(0.3)--按钮，背景
    btn.Name:SetWidth(48)--名称，长度
    btn.SelectedTexture:ClearAllPoints()--设置，选项，特效
    btn.SelectedTexture:SetPoint('CENTER')
    btn.SelectedTexture:SetSize(44,44)
    btn.SelectedTexture:SetVertexColor(0,1,1)

--删除，宏 Alt+双击
    btn:SetScript('OnDoubleClick', function(self)
       if IsAltKeyDown() then
            Delete_Macro(self)
       end
    end)

--右击，菜单
    btn:HookScript('OnMouseDown', function(frame, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(frame, Init_Menu)
            frame:set_on_enter()
        end
    end)

    btn.indexLable= WoWTools_LabelMixin:Create(btn, {color={r=0.7,g=0.7,b=0.7}})
    btn.indexLable:SetPoint('LEFT', -6, 0)
    btn.indexLable:SetAlpha(0.5)
    function btn:set_index_label()
        self.indexLable:SetText(self.selectionIndex or '')
    end
end










local function Init()
    --列表，按钮，操作
    hooksecurefunc(MacroButtonMixin, 'OnLoad', Set_OnLoad)

    --宏，名称，修改，字符长度
    hooksecurefunc(MacroFrame.MacroSelector, 'setupCallback', function(self, _, name)--Blizzard_MacroUI.lua
        if name ~= nil then
            self.Name:SetText(WoWTools_TextMixin:sub(name, 2, 4))
        end
    end)

    hooksecurefunc(MacroFrame.MacroSelector.ScrollBox, 'Update', function(self)
        if not self:GetView() then
            return
        end
        for _, btn in pairs(self:GetFrames()or {}) do
            if btn.indexLable then
                btn:set_index_label()
            end
        end
    end)
end







function WoWTools_MacroMixin:Init_MacroButton_Plus()
    Init()
end