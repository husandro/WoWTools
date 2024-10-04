--宏列表，位置
local e= select(2, ...)
local function Save()
    return WoWTools_MacroMixin.Save
end






--宏列表，位置
local function Init()
    local toRightButton= WoWTools_ButtonMixin:Cbtn(MacroFrame.TitleContainer, {size={20,20}, icon='hide'})
    toRightButton:SetAlpha(0.5)
    if _G['MoveZoomInButtonPerMacroFrame'] then
        toRightButton:SetPoint('RIGHT', _G['MoveZoomInButtonPerMacroFrame'], 'LEFT')
    else
        toRightButton:SetPoint('LEFT',0, -2)
    end
    function toRightButton:set_texture()
        if Save().toRightLeft==1 then--左边
            self:SetNormalAtlas(e.Icon.toLeft)
        elseif Save().toRightLeft==2 then--右边
            self:SetNormalAtlas(e.Icon.toRight)
        else--默认
            self:SetNormalAtlas(e.Icon.icon)
        end
    end
    function toRightButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MacroMixin.addName)
        e.tips:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat'))
        e.tips:AddLine(' ')
        e.tips:AddLine((e.onlyChinese and '图标' or EMBLEM_SYMBOL)..':', e.Icon.left)
        local text= e.onlyChinese and '备注' or LABEL_NOTE
        text= (Save().toRightLeft and MacroFrame.macroBase==0) and '|cnGREEN_FONT_COLOR:'..text..'|r'
            or ('|cff9e9e9e'..text..'|r')
        e.tips:AddDoubleLine(format('|A:%s:0:0|a', e.Icon.toLeft)..(e.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT), (Save().toRightLeft==1 and format('|A:%s:0:0|a', e.Icon.select) or '')..text)
        e.tips:AddDoubleLine(format('|A:%s:0:0|a', e.Icon.toRight)..(e.onlyChinese and '右' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT), (Save().toRightLeft==2 and format('|A:%s:0:0|a', e.Icon.select) or '')..text)
        e.tips:AddDoubleLine('|A:'..e.Icon.icon..':0:0|a'..(e.onlyChinese and '默认' or DEFAULT), not Save().toRightLeft and format('|A:%s:0:0|a', e.Icon.select))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
    end
    toRightButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            if not Save().toRightLeft then
                Save().toRightLeft=1--左边
            elseif Save().toRightLeft==1 then
                Save().toRightLeft=2--右边
            elseif Save().toRightLeft==2 then
                Save().toRightLeft=nil--默认
            end
            Save().toRight= not Save().toRight and true or nil
            MacroFrame:ChangeTab(1)
            self:set_texture()
            self:set_tooltips()
        else
            e.OpenPanelOpting(nil, WoWTools_MacroMixin.addName)
        end
    end)
    toRightButton:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
    toRightButton:SetScript('OnEnter', toRightButton.set_tooltips)
    toRightButton:set_texture()



    --设置，宏，图标，位置，长度
    hooksecurefunc(MacroFrame, 'ChangeTab', function(self, tabID)
        self.MacroSelector:ClearAllPoints()
        if tabID==1 and (Save().toRightLeft==1 or Save().toRightLeft==2) then
            if Save().toRightLeft==1 then--左边
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
        if not MacroFrame.NoteEditBox and Save().toRightLeft and MacroFrame.macroBase==0 then
            MacroFrame.NoteEditBox=WoWTools_EditBoxMixn:CreateMultiLineFrame(MacroFrame, {
                font='GameFontHighlightSmall',
                instructions= e.onlyChinese and '备注' or LABEL_NOTE
            })
            MacroFrame.NoteEditBox:SetPoint('TOPLEFT', 8, -65)
            MacroFrame.NoteEditBox:SetPoint('BOTTOMRIGHT', MacroFrame, 'RIGHT', -6, 0)

            function MacroFrame.NoteEditBox:set_text()
                self:SetText(Save().noteText or '')
            end


            MacroFrame.NoteEditBox.editBox:SetScript('OnHide', function(s)--保存备注
                Save().noteText= s:GetText()
                s:ClearFocus()
            end)
            MacroFrame.NoteEditBox.editBox:SetScript('OnShow', MacroFrame.NoteEditBox.set_text)
            if MacroFrame.NoteEditBox:IsShown() then
                MacroFrame.NoteEditBox:set_text()
            end
        end

        if self.NoteEditBox then
            self.NoteEditBox:SetShown((Save().toRightLeft and MacroFrame.macroBase==0) and true or false)
        end
    end)
end






function WoWTools_MacroMixin:Init_Macro_List()
    Init()
end