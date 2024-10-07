local e= select(2, ...)





local function Delete_Macro(self)
    local index= MacroFrame:GetSelectedIndex()
    if not IsAltKeyDown()
        or UnitAffectingCombat('player')
        or not MacroDeleteButton:IsEnabled()
        or (not index or index~=self.selectionIndex)
    then
        return
    end

    local selectIndex= self.selectionIndex-- or WoWTools_MacroMixin:GetSelectIndex()
    local name, icon, body
    if selectIndex then
        name, icon, body = GetMacroInfo(selectIndex)
    end
    e.call(MacroFrame.DeleteMacro, MacroFrame)

    if name then
        print(WoWTools_MacroMixin.addName,
            '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE),
            '|r'..(selectIndex-(MacroFrame.macroBase or 0)), WoWTools_MacroMixin:GetName(name, icon))
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
        if self.selectionIndex then
            MacroFrame:SelectMacro(self.selectionIndex)
        end
    end

    local sub
    local index= WoWTools_MacroMixin:GetSelectIndex()
    local isSelect= index and self.selectionIndex==index

--修改   
    sub=root:CreateButton(
        e.onlyChinese and '修改' or EDIT,
    function()
        if not UnitAffectingCombat('player') then
            e.call(MacroEditButton_OnClick, MacroFrame, self)
        end
    end, {index=index})
    WoWTools_MacroMixin:SetTooltips(self)
    sub:SetEnabled(isSelect)

--删除
    sub=root:CreateButton(
        e.onlyChinese and '删除' or DELETE,
    function()
        Delete_Macro(self)
    end, {index=index})
    WoWTools_MacroMixin:SetTooltips(self)

--新建
    root:CreateDivider()
    sub=root:CreateButton(
        '|A:communities-chat-icon-plus:0:0|a'..(e.onlyChinese and '新建' or NEW),
    function()
        WoWTools_MacroMixin:CreateMacroNew()--新建，宏
    end)
    sub:SetEnabled(WoWTools_MacroMixin:IsCanCreateNewMacro())
--保存
    root:CreateDivider()
    WoWTools_MacroMixin:Save_Macro_Menu(self, root)
end






















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
    
    
    MacroFrameScrollFrame:HookScript('OnSizeChanged', function(self)
        local w= self:GetWidth()
        MacroFrameText:SetWidth(w)
    end)



    MacroFrameScrollFrame:ClearAllPoints()
    MacroFrameScrollFrame:SetPoint('TOPLEFT', MacroFrame, 'LEFT', 12, -83)
    MacroFrameScrollFrame:SetPoint('BOTTOMRIGHT', -32, 45)


    e.Set_Move_Frame(MacroFrame, {needSize=true, setSize=true, minW=338, minH=424,
        sizeRestFunc=function(btn)
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
end


















local function Init_Other()

--宏，提示
    hooksecurefunc(MacroButtonMixin, 'OnLoad', function(btn)
        if btn.OnDoubleClick then
            return
        end

        btn:HookScript('OnEnter', function(self)--设置，宏，提示
            WoWTools_MacroMixin:SetTooltips(self)
        end)
        btn:HookScript('OnLeave', function()
            e.tips:Hide()
        end)

        local texture2= btn:GetRegions()
        texture2:SetAlpha(0.3)--按钮，背景
        btn.Name:SetWidth(48)--名称，长度
        btn.SelectedTexture:ClearAllPoints()--设置，选项，特效
        btn.SelectedTexture:SetPoint('CENTER')
        btn.SelectedTexture:SetSize(44,44)
        btn.SelectedTexture:SetVertexColor(0,1,1)
        
--删除，宏 Alt+双击
        btn:SetScript('OnDoubleClick', function(self)
            local index= MacroFrame:GetSelectedIndex()
            if not IsAltKeyDown()
                or UnitAffectingCombat('player')
                or not MacroDeleteButton:IsEnabled()
                or (not index or index~=self.selectionIndex)
            then
                return
            end
            Delete_Macro(self)
        end)

--右击，菜单
        btn:HookScript('OnMouseDown', function(frame, d)
            if d=='RightButton' then
                MenuUtil.CreateContextMenu(frame, Init_Menu)
            end
        end)
    end)

    hooksecurefunc(MacroFrame.MacroSelector, 'setupCallback', function(self, _, name)--Blizzard_MacroUI.lua
        if name ~= nil then
            self.Name:SetText(WoWTools_TextMixin:sub(name, 2, 4))
        end
    end)

--Blizzard_ScrollBoxSelector.lua
    MacroFrame.MacroSelector:HookScript('OnSizeChanged', function(self)
        local value= math.max(6, math.modf(self:GetWidth()/49))
        if self:GetStride()~= value then
            self:SetCustomStride(value)
            self:Init()
        end
    end)




    --保存，提示
    MacroSaveButton.saveTip= MacroSaveButton:CreateTexture(nil, 'OVERLAY')
    MacroSaveButton.saveTip:SetPoint('LEFT')
    MacroSaveButton.saveTip:SetSize(18, 18)
    MacroSaveButton.saveTip:SetAtlas('auctionhouse-icon-favorite')
    MacroSaveButton.saveTip:Hide()
    local function set_saveTip()
        local show= false
        local index= WoWTools_MacroMixin:GetSelectIndex()
        if index then
            show= select(3, GetMacroInfo(index))~= MacroFrameText:GetText()
        end
        MacroSaveButton.saveTip:SetShown(show)
    end
    MacroFrameText:HookScript('OnTextChanged', set_saveTip)
    MacroSaveButton:HookScript('OnClick', set_saveTip)





    --宏数量
    --Blizzard_MacroUI.lua
    MacroFrameTab1.label= WoWTools_LabelMixin:Create(MacroFrameTab1)
    MacroFrameTab1.label:SetPoint('BOTTOM', MacroFrameTab1, 'TOP', 0, -8)
    MacroFrameTab1.label:SetAlpha(0.7)
    MacroFrameTab2.label= WoWTools_LabelMixin:Create(MacroFrameTab2)
    MacroFrameTab2.label:SetPoint('BOTTOM', MacroFrameTab2, 'TOP', 0, -8)
    MacroFrameTab2.label:SetAlpha(0.7)
    MacroFrameTab2.label:SetTextColor(e.Player.r, e.Player.g, e.Player.b)


    hooksecurefunc(MacroFrame, 'Update', function()
    	local numAccountMacros, numCharacterMacros
        numAccountMacros, numCharacterMacros = GetNumMacros()
        numAccountMacros= numAccountMacros or 0
        numAccountMacros= numAccountMacros==MAX_ACCOUNT_MACROS and '|cff9e9e9e'..numAccountMacros or numAccountMacros

        numCharacterMacros= numCharacterMacros or 0
        numCharacterMacros= numCharacterMacros==MAX_CHARACTER_MACROS and '|cff9e9e9e'..numCharacterMacros or numCharacterMacros

        MacroFrameTab1.label:SetText(numAccountMacros..'/'..MAX_ACCOUNT_MACROS)
        MacroFrameTab2.label:SetText(numCharacterMacros..'/'..MAX_CHARACTER_MACROS)
    end)
end









function WoWTools_MacroMixin:Init_Set_UI()
    Init()
    Init_Other()
end