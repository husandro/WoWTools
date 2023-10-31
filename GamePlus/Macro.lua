local id, e= ...


local addName= MACRO--宏
local Save={
    disabled= not e.Player.husandro
}




local function Create_Button(name)
    local btn= e.Cbtn(MacroEditButton, {size={60,22}, type=false})
    function btn:find_text(right)
        return (MacroFrameText:GetText() or ''):find(e.Magic(right and self.text2 or self.text))
    end
   function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
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
    btn:SetScript('OnLeave', function() e.tips:Hide() end)
    btn:SetScript("OnEnter", btn.set_tooltips)
    return btn
end



local SelectionIndex
local function Init()
    local w, h= 350, 600--672, 672
    MacroFrame:SetSize(w, h)--<Size x="338" y="424"/>
    MacroFrameScrollFrame:SetSize(w-43, h/2-45)
    MacroFrameText:SetSize(w-43, h/2-45)
    MacroFrameTextBackground:SetSize(w-33, h/2-30)
    MacroHorizontalBarLeft:SetWidth(w-85)


    --设置，宏，图标，位置，长度
    hooksecurefunc(MacroFrame, 'ChangeTab', function(self, tabID)
        self.MacroSelector:ClearAllPoints()
        if tabID==1 then
            --self.MacroSelector:SetSize(w-38,h-12)
            self.MacroSelector:SetSize(315,588)
            self.MacroSelector:SetPoint('TOPRIGHT', self, 'TOPLEFT',10,-12)
        else
            self.MacroSelector:SetSize(319,146)
            self.MacroSelector:SetPoint('TOPLEFT', 12,-66)
        end
    end)

    --宏，提示
    local function set_btn_tooltips(self)
        
        if self.selectionIndex then
            local index= self.selectionIndex+ MacroFrame.macroBase
            local name, icon, body = GetMacroInfo(index)
            if name and icon and body then
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine('|T'..icon..':0|t'..name, index)
                e.tips:AddLine(body)
                e.tips:Show()
            end
        end
    end
    hooksecurefunc(MacroButtonMixin, 'OnLoad', function(self)
        self:HookScript('OnEnter', set_btn_tooltips)
        self:HookScript('OnLeave', function() e.tips:Hide() end)
        local texture= self:GetRegions()
        texture:SetAlpha(0.3)
    end)
    MacroFrameSelectedMacroButton:HookScript('OnEnter', set_btn_tooltips)
    MacroFrameSelectedMacroButton:HookScript('OnLeave', function() e.tips:Hide() end)

    --选定宏，index提示
    MacroFrame.numSelectionLable= e.Cstr(MacroFrame)
    MacroFrame.numSelectionLable:SetPoint('BOTTOM', MacroFrameSelectedMacroButton, 'TOP')
    MacroFrame.numSelectionLable:SetScript('OnLeave', function() e.tips:Hide() end)
    MacroFrame.numSelectionLable:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(self:GetText(), e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)
        e.tips:Show()
    end)
    hooksecurefunc(MacroFrame, 'SelectMacro', function(self, index)
        self.numSelectionLable:SetText(index and index+MacroFrame.macroBase or '')
        --index= index and index+MacroFrame.macroBase or nil
        MacroFrameSelectedMacroButton.selectionIndex= index
    end)
    --[[hooksecurefunc(SelectorButtonMixin, 'OnClick', function(self)
        local actualIndex = MacroFrame:GetMacroDataIndex(self:GetElementData())
        if actualIndex then
            actualIndex= actualIndex- MacroFrame.macroBase
        end
        MacroFrameSelectedMacroButton.numSelectionLable:SetText(actualIndex or '')
    end)]]



    MacroEditButton:SetSize(60,22)--170 22
    MacroEditButton:SetText(e.onlyChinese and '名称' or NAME)

    local attck= Create_Button(e.onlyChinese and '目标' or TARGET)
    attck:SetPoint('LEFT', MacroEditButton, 'RIGHT')
    attck.text=[[#showtooltip
/targetenemy [noharm][dead]
]]
    attck.text2=[[/cancelaura ]]
    attck.textCursor=0
    attck.text2Cursor=nil
    attck.tip=nil
    attck.tip2=e.onlyChinese and '光环名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AURAS, NAME)


    local cnacel= Create_Button(e.onlyChinese and '攻击' or ATTACK)
    cnacel:SetPoint('LEFT', attck, 'RIGHT')
    cnacel.text=[[/petattack
/startattack
]]
    cnacel.text2=[[/petfollow
/stopattack
/stopcasting
]]

    --MacroFrameText:HookScript('OnTextChanged', function(self)
    --local num= (self:GetNumLetters() + string.len(attck.text)) >255
    --attck:SetEnabled(not num)

    --宏数量
    --Blizzard_MacroUI.lua
    MacroFrameTab1.label= e.Cstr(MacroFrameTab1)
    MacroFrameTab1.label:SetPoint('BOTTOM', MacroFrameTab1, 'TOP', 0, -10)
    MacroFrameTab2.label= e.Cstr(MacroFrameTab2)
    MacroFrameTab2.label:SetPoint('BOTTOM', MacroFrameTab2, 'TOP', 0, -10)
    hooksecurefunc(MacroFrame, 'Update', function()
    	local numAccountMacros, numCharacterMacros
        numAccountMacros, numCharacterMacros = GetNumMacros()
        numAccountMacros= numAccountMacros or 0
        numAccountMacros= numAccountMacros==MAX_ACCOUNT_MACROS and '|cnRED_FONT_COLOR:'..numAccountMacros or numAccountMacros

        numCharacterMacros= numCharacterMacros or 0
        numCharacterMacros= numCharacterMacros==MAX_CHARACTER_MACROS and '|cnRED_FONT_COLOR:'..numCharacterMacros or numCharacterMacros

        MacroFrameTab1.label:SetText(numAccountMacros..'/'..MAX_ACCOUNT_MACROS)
        MacroFrameTab2.label:SetText(numCharacterMacros..'/'..MAX_CHARACTER_MACROS)
    end)
end


local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if PetStableFrame then
                Save= WoWToolsSave[addName] or Save

                --添加控制面板
                e.AddPanel_Check({
                    name= e.onlyChinese and '宏' or addName,
                    tooltip= ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中错误' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ERRORS)))
                        ..'|r|n'..(e.onlyChinese and '备注：如果错误，请取消此选项' or 'note: If you get error, please disable this'),
                    value= not Save.disabled,
                    func= function()
                        Save.disabled = not Save.disabled and true or nil
                        print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                    end
                })

                if Save.disabled  then
                    self:UnregisterEvent('ADDON_LOADED')
                end
            end

        elseif arg1=='Blizzard_MacroUI' then
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    elseif event=='PET_STABLE_SHOW' then
        Init()
        panel:UnregisterEvent('PET_STABLE_SHOW')
    end
end)