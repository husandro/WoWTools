
--宏
function WoWTools_MoveMixin.Events:Blizzard_MacroUI()
    if WoWToolsSave['Plus_Macro2'].disabled then
        self:Setup(MacroFrame)
    end
end


--宏
function WoWTools_TextureMixin.Events:Blizzard_MacroUI()
    self:SetFrame(MacroFrame, {notAlpha=true})
    self:SetNineSlice(MacroFrameInset, true)
    self:SetNineSlice(MacroFrame, true)
    self:SetNineSlice(MacroFrameTextBackground, true, nil, nil, true)
    self:HideTexture(MacroFrameBg)
    self:SetAlphaColor(MacroFrameInset.Bg)
    self:SetAlphaColor(MacroHorizontalBarLeft, true)
    self:HideTexture(MacroFrameSelectedMacroBackground)
    self:SetScrollBar(MacroFrame.MacroSelector)
    self:SetScrollBar(_G['WoWToolsMacroPlusNoteEditBox'])
    self:SetScrollBar(MacroFrameScrollFrame)
    self:SetButton(MacroFrameCloseButton, {all=true})
end
