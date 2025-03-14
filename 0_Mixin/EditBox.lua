local e= select(2, ...)
--SecureScrollTemplates.xml
--SecureUIPanelTemplates.lua

WoWTools_EditBoxMixn={
    index=1
}





local function Settings(frame)
    function frame:SetText(...)
        self.editBox:SetText(...)
    end
    function frame:GetText()
        return self.editBox:GetText()
    end
    function frame:ClearFocus()
        self.editBox:ClearFocus()
    end
    function frame:SetFocus()
        self.editBox:SetFocus()
    end
end



local function Create_Label(self, isInstructions, isMaxLetter)
    local isMultiLine= self:IsMultiLine()

    if isInstructions and not self.Instructions then
        self.Instructions=WoWTools_LabelMixin:Create(self, {layer='BORDER', color={r=0.35, g=0.35, b=0.35}})
        if isMultiLine then
            self.Instructions:SetPoint('TOPLEFT')
        else
            self.Instructions:SetPoint('LEFT')
        end
    end

    if isMaxLetter and not self.MaxLetterLabel then
        self.MaxLetterLabel=WoWTools_LabelMixin:Create(self, {color=true})
        if isMultiLine then
            self.MaxLetterLabel:SetPoint('BOTTOMRIGHT')
        else
            self.MaxLetterLabel:SetPoint('RIGHT')
        end
    end
end





function WoWTools_EditBoxMixn:Create(frame, tab)
    self.index= self.index+1
    local name= tab.name or format('%s%d', 'WoWTools_EditBox', self.index)
    local font= tab.font or 'ChatFontNormal'
    local template= tab.Template--SearchBoxTemplate
    local setID= tab.setID

    local editBox= CreateFrame('EditBox', name, frame, template, setID)
    editBox:SetAutoFocus(false)
    editBox:ClearFocus()
    editBox:SetFontObject(font)
    editBox:SetTextColor(1,1,1)

    editBox:SetScript('OnEscapePressed', EditBox_ClearFocus)
    editBox:SetScript('OnHide', function(s) s:ClearFocus() end)

    return editBox
end













function WoWTools_EditBoxMixn:CreateMultiLineFrame(frame, tab)
    self.index= self.index+1
    tab= tab or {}

    local name= tab.name or format('%s%d', 'WoWTools_EditScrollFrame', self.index)--名称
    --local font= tab.font or 'GameFontHighlightSmall'--字体 ChatFontNormal
    local isShowLinkTooltip= tab.isShowLinkTooltip--超链接
    local isInstructions= tab.isInstructions--使用说明

    local scrollFrame= CreateFrame('ScrollFrame', name, frame, 'ScrollFrameTemplate')--InputScrollFrameTemplate

    local level= scrollFrame:GetFrameLevel()
    if scrollFrame.ScrollBar then
        scrollFrame.ScrollBar:ClearAllPoints()
        scrollFrame.ScrollBar:SetPoint('TOPRIGHT', -10, -10)
        scrollFrame.ScrollBar:SetPoint('BOTTOMRIGHT', -10, 10)
    end

    WoWTools_TextureMixin:SetScrollBar(scrollFrame)

    scrollFrame.bg= CreateFrame('Frame', name..'BG', scrollFrame, 'TooltipBackdropTemplate')
    scrollFrame.bg:SetPoint('TOPLEFT', -5, 5)
    scrollFrame.bg:SetPoint('BOTTOMRIGHT', 0, -5)
    scrollFrame.bg:SetFrameLevel(level+1)
    WoWTools_TextureMixin:SetNineSlice(scrollFrame.bg, true, nil, nil, true)

    scrollFrame.editBox= self:Create(scrollFrame, tab)
    scrollFrame.editBox:SetMultiLine(true)
    scrollFrame.editBox:SetFrameLevel(level+2)
    scrollFrame.editBox:SetScript('OnUpdate', function(s, elapsed) ScrollingEdit_OnUpdate(s, elapsed, s:GetParent()) end)
    scrollFrame.editBox:SetScript('OnCursorChanged', ScrollingEdit_OnCursorChanged)

    scrollFrame:SetScrollChild(scrollFrame.editBox)
    scrollFrame:HookScript('OnSizeChanged', function(f)
       f.editBox:SetWidth(f:GetWidth()-25)
    end)

--超链接
    if isShowLinkTooltip then
        scrollFrame.editBox:SetHyperlinksEnabled(true)
        scrollFrame.editBox:SetScript('OnHyperlinkLeave', GameTooltip_Hide)
        scrollFrame.editBox:SetScript('OnHyperlinkEnter', function(s, link)
            if link then
                e.tips:SetOwner(s, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetHyperlink(link)
                e.tips:Show()
            end
        end)
        scrollFrame:SetScript('OnHyperlinkClick', function(s, link, text2)--, region)
            SetItemRef(link, text2, s, nil)
        end)
    end

--使用说明
    self:SetInstructions(scrollFrame.editBox, isInstructions, scrollFrame)

    Settings(scrollFrame)

    return scrollFrame
end



function WoWTools_EditBoxMixn:HookInstructions(editBox)
    editBox:HookScript('OnTextChanged', function(s)
        s.Instructions:SetShown(s:GetText() == "")
    end)
end

function WoWTools_EditBoxMixn:SetInstructions(editBox, isInstructions, frame)
    if not isInstructions then
        return
    end

    editBox= frame and frame.editBox or editBox

    if not editBox  then
        return
    end

    Create_Label(editBox, true, false)

    editBox.Instructions:SetText(isInstructions)

    if frame then
        function frame:SetInstructions(text)
            if text then
                self.editBox.Instructions:SetText(text or '')
            end
        end
        self:HookInstructions(frame.editBox)
    else
        self:HookInstructions(editBox)
    end
end





function WoWTools_EditBoxMixn:Setup(edit,  tab)
    tab= tab or {}

    local isInstructions= tab.isInstructions
    local isMaxLetter= tab.isMaxLetter


    Create_Label(edit, isInstructions, isMaxLetter)

    if type(isInstructions)=='string' then
        edit.Instructions:SetText(isInstructions)
    end

    if isMaxLetter then
        edit:HookScript('OnEditFocusGained', function(frame)
            frame.MaxLetterLabel:SetText(frame:GetNumLetters()..'/'..frame:GetMaxLetters())
        end)

        edit:HookScript('OnEditFocusLost', function(frame)
            frame.MaxLetterLabel:SetText("")
        end)
    end

    if isInstructions or isMaxLetter then
        edit:HookScript('OnTextChanged', function(frame)
            if frame.MaxLetterLabel then
                frame.MaxLetterLabel:SetText(frame:GetNumLetters()..'/'..frame:GetMaxLetters())
            end
            if frame.Instructions then
                frame.Instructions:SetShown(frame:GetText()=='')
            end
        end)
    end

    return edit
end


--[[scrollFrame.bg:SetScript('OnMouseDown', function(s, d)
        if d=='LeftButton' then
            local edit= s:GetParent().edit
            if not edit:HasFocus() then
                edit:SetFocus()
            end
        end
    end)]]


--[[
function e.Cedit(self)
   
end
    local anchorsWithScrollBar = {
        CreateAnchor("TOPLEFT", 4, -4);
        CreateAnchor("BOTTOMRIGHT", frame.ScrollBar, -13, 4),
    };
    
    local anchorsWithoutScrollBar = {
        CreateAnchor("TOPLEFT", 4, -4),
        CreateAnchor("BOTTOMRIGHT", -4, 4);
    };
   -- ScrollUtil.AddManagedScrollBarVisibilityBehavior(frame.editBox, frame.ScrollBar, anchorsWithScrollBar, anchorsWithoutScrollBar);
   ]]
