
local ScrollFrame














local function Init()
    --MacroFrameScrollFrame.ScrollBar:SetHideIfUnscrollable(true)
    --MacroFrame.MacroSelector.ScrollBar:SetHideIfUnscrollable(true)
    --MacroFrame.MacroSelector.ScrollBar:SetHideIfUnscrollable(true)
    
--输入宏命令，字符
    MacroFrameEnterMacroText:SetText('')
    MacroFrameEnterMacroText:Hide()
    MacroFrameText.Instructions= WoWTools_LabelMixin:Create(MacroFrameText, {layer='BORDER', color={r=0.35, g=0.35, b=0.35}})
    MacroFrameText.Instructions:SetPoint('TOPLEFT')
    MacroFrameText.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '输入宏命令' or ENTER_MACRO_LABEL)
    MacroFrameText:HookScript('OnTextChanged', function(s)
        s.Instructions:SetShown(s:GetText() == "")
    end)
-- "已使用%d个字符，最多255个";
    MacroFrameCharLimitText:SetParent(MacroFrameScrollFrame)
    MacroFrameCharLimitText:ClearAllPoints()
    MacroFrameCharLimitText:SetPoint('BOTTOMRIGHT', MacroFrameScrollFrame)
    MacroFrameCharLimitText:SetTextColor(0.93, 0.82, 0)
    MacroFrameCharLimitText:SetAlpha(0.75)
    MacroFrameText:HookScript('OnTextChanged', function(self)
        local num=self:GetNumLetters() or 0
        MacroFrameCharLimitText:SetFormattedText((num==255 and '|cff9e9e9e' or '')..num..'/255')
    end)

--设置，焦点
    MacroFrameTextBackground.NineSlice:HookScript('OnMouseDown', function(_, d)
        if d=='LeftButton' then
            MacroFrameText:SetFocus()
        end
    end)


--角色，专用宏，颜色
    MacroFrameTab2.Text:SetTextColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)


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


    local regions= {MacroFrame:GetRegions()}
    for index, frame in pairs(regions) do
--标题，上升，原生看FrameStrate太低了
        if frame:GetObjectType()=='FontString' and frame:GetText()==CREATE_MACROS then
            if WoWTools_DataMixin.onlyChinese then
                frame:SetText('创建宏')
            end
            frame:SetParent(MacroFrame.TitleContainer)

--列表 和 MacroFrameText 中间的分割线
        elseif frame==MacroHorizontalBarLeft then
            frame:SetTexture(0)
            frame:Hide()
            local f= regions[index+1]
            if f and f:GetObjectType()=='Texture' then
                f:SetTexture(0)
                f:Hide()
            end
        end
    end


--选定宏，按钮
    MacroFrameSelectedMacroButton:ClearAllPoints()
    MacroFrameSelectedMacroButton:SetPoint('BOTTOMLEFT', MacroFrameScrollFrame, 'TOPLEFT', 6, 12)
    local region= MacroFrameSelectedMacroButton:GetRegions()--外框
    if region and region:GetObjectType()=='Texture' then
        region:Hide()
    end

--选定宏，名称
    MacroFrameSelectedMacroName:ClearAllPoints()
    MacroFrameSelectedMacroName:SetPoint('TOPLEFT', MacroFrameSelectedMacroButton, 'TOPRIGHT', 4, 4)
    MacroFrameSelectedMacroName:SetFontObject('GameFontNormal')

--修改，按钮
    MacroEditButton:ClearAllPoints()
    MacroEditButton:SetPoint('BOTTOMLEFT', MacroFrameSelectedMacroButton, 'BOTTOMRIGHT', 2, -2)
    MacroEditButton:SetSize(60,22)--170 22
    MacroEditButton:SetText(WoWTools_DataMixin.onlyChinese and '修改' or EDIT)

--取消，按钮
    --MacroCancelButton:ClearAllPoints()
    --MacroCancelButton:SetPoint('')
--保存，按钮
    MacroSaveButton:ClearAllPoints()
    MacroSaveButton:SetPoint('BOTTOM', MacroCancelButton, 'TOP', 0, 2)

--EditBox
    MacroFrameText:ClearAllPoints()
    MacroFrameText:SetAllPoints(MacroFrameScrollFrame)

--MacroFrameText 背景
    MacroFrameTextBackground:ClearAllPoints()
    MacroFrameTextBackground:SetPoint('TOPLEFT',MacroFrameScrollFrame, -4, 4)
    MacroFrameTextBackground:SetPoint('BOTTOMRIGHT', MacroFrameScrollFrame, 4,-4)


end













-- 恢复宏选择框的滚动条位置
local function Init_Scroll()
    ScrollFrame= CreateFrame("Frame", nil, MacroFrame)


    ScrollFrame:RegisterEvent("UPDATE_MACROS")
    ScrollFrame:SetScript("OnEvent", function(self)
        self.tempScrollPer = MacroFrame.MacroSelector.ScrollBox.scrollPercentage
    end)


    hooksecurefunc(MacroFrame, "SelectMacro", function(self)
        if ScrollFrame.tempScrollPer and not WoWTools_FrameMixin:IsLocked(MacroFrame) then-- 恢复宏选择框的滚动条位置
            self.MacroSelector.ScrollBox:SetScrollPercentage(ScrollFrame.tempScrollPer)
        end
        ScrollFrame.tempScrollPer = nil
    end)



    ScrollFrame:SetScript('OnShow', function(self)
        self:RegisterEvent("UPDATE_MACROS")
        C_Timer.After(0.1, function()
            local index= self.selectionIndex
            if index and not WoWTools_FrameMixin:IsLocked(MacroFrame) then
                if index>MAX_ACCOUNT_MACROS then
                    index= index-MAX_ACCOUNT_MACROS
                    WoWTools_Mixin:Call(MacroFrame.ChangeTab, MacroFrame, 2)
                end

                MacroFrame:SelectMacro(index)
                MacroFrame.MacroSelector.ScrollBox:SetScrollPercentage(self.tempScrollPer2)

            end
            self.selectionIndex=nil
            self.tempScrollPer2=nil
        end)
    end)



    ScrollFrame:SetScript('OnHide', function(self)
        self:UnregisterEvent("UPDATE_MACROS")
        self.selectionIndex= WoWTools_MacroMixin:GetSelectIndex()

        self.tempScrollPer2=  MacroFrame.MacroSelector.ScrollBox.scrollPercentage
    end)
end










function WoWTools_MacroMixin:Init_Set_UI()
    Init()
    Init_Scroll()--恢复宏选择框的滚动条位置
end