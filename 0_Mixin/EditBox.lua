--SecureScrollTemplates.xml
--SecureUIPanelTemplates.lua
local index=1
WoWTools_EditBoxMixin={}







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





function WoWTools_EditBoxMixin:Create(frame, tab)
    --index= index+1
    tab= tab or {}

    local name= tab.name-- or format('%s%d', 'WoWTools_EditBox', index)
    local font= tab.font or 'ChatFontNormal'
    local template= tab.isSearch and 'SearchBoxTemplate' or tab.Template--SearchBoxTemplate
    local setID= tab.setID

    local text= tab.text
    local atlas= tab.atlas
    local texture= tab.texture

    local editBox= CreateFrame('EditBox', name, frame, template, setID)
    editBox:SetAutoFocus(false)
    editBox:ClearFocus()
    editBox:SetFontObject(font)
    editBox:SetTextColor(1,1,1)
    editBox:SetHeight(23)

    editBox:SetScript('OnEscapePressed', function(...) EditBox_ClearFocus(...) end)
    editBox:SetScript('OnHide', function(s) if s:HasFocus() then s:ClearFocus() end end)
    WoWTools_TextureMixin:SetEditBox(editBox)

    if editBox.Instructions then
        editBox.Instructions:SetText(text or (WoWTools_DataMixin.onlyChinese and '搜索' or SEARCH))
    end
    if editBox.searchIcon then
        if atlas then
            editBox.searchIcon:SetAtlas(atlas)
        elseif texture then
            editBox.searchIcon:SetTexture(texture)
        end
    end

    return editBox
end












--local font= tab.font or 'GameFontHighlightSmall'--字体 ChatFontNormal
function WoWTools_EditBoxMixin:CreateFrame(frame, tab)
    --index= index+1
    tab= tab or {}


    local name= tab.name --or ((frame:GetName() or 'WoWTools')..'ScrollFrame'..index)--.. format('%s%d', 'WoWTools_EditScrollFrame', index)--名称
    local isLink= tab.isLink--超链接
    local text= tab.text--使用说明
    --local clearButton= tab.clear

    local scrollFrame= CreateFrame('ScrollFrame', name, frame, 'ScrollFrameTemplate')--InputScrollFrameTemplate SecureUIPanelTemplates.xml

    local level= scrollFrame:GetFrameLevel()

    scrollFrame.ScrollBar:ClearAllPoints()--MinimalScrollBar
    scrollFrame.ScrollBar:SetPoint('TOPRIGHT', -8, -17)
    scrollFrame.ScrollBar:SetPoint('BOTTOMRIGHT', -8, 12)
    WoWTools_TextureMixin:SetScrollBar(scrollFrame, true)

    scrollFrame.BGFrame= CreateFrame('Frame', nil, scrollFrame, 'TooltipBackdropTemplate')
    scrollFrame.BGFrame:SetPoint('TOPLEFT', -5, 5)
    scrollFrame.BGFrame:SetPoint('BOTTOMRIGHT', 0, -5)
    scrollFrame.BGFrame:SetFrameLevel(level+1)
    scrollFrame.BGFrame:EnableMouse(true)
    scrollFrame.BGFrame:SetScript('OnMouseDown', function(s)
        s:GetParent().editBox:SetFocus()
    end)
    WoWTools_TextureMixin:SetNineSlice(scrollFrame.BGFrame)


    scrollFrame.editBox= CreateFrame('EditBox', nil, scrollFrame)--, 'SearchBoxTemplate')
    --scrollFrame.editBox:SetMaxLetters(100000)
    scrollFrame.editBox:SetAutoFocus(false)
    scrollFrame.editBox:ClearFocus()
    scrollFrame.editBox:SetFontObject('ChatFontNormal')
   -- scrollFrame.editBox:SetTextColor(1,1,1)
    scrollFrame.editBox:SetPoint('TOPLEFT', scrollFrame, 'TOPLEFT')
    scrollFrame.editBox:SetPoint('BOTTOMRIGHT', scrollFrame, 'BOTTOMRIGHT')

    scrollFrame.editBox:SetScript('OnEscapePressed', EditBox_ClearFocus)
    scrollFrame.editBox:SetScript('OnHide', function(s)
        if s:HasFocus() then
            s:ClearFocus()
        end
    end)
    WoWTools_TextureMixin:SetEditBox(scrollFrame.editBox)

    scrollFrame.editBox:SetMultiLine(true)
    scrollFrame.editBox:SetFrameLevel(level+2)
    scrollFrame.editBox:SetScript('OnUpdate', function(s, elapsed) ScrollingEdit_OnUpdate(s, elapsed, s:GetParent()) end)
    scrollFrame.editBox:SetScript('OnCursorChanged', ScrollingEdit_OnCursorChanged)


    scrollFrame.editBox.Instructions= WoWTools_LabelMixin:Create(scrollFrame.editBox, {layer='BORDER', color={r=0.35, g=0.35, b=0.35}})
    scrollFrame.editBox.Instructions:SetPoint('TOPLEFT')
    scrollFrame.editBox.Instructions:SetText(text or '')
    scrollFrame.editBox.Instructions:Hide()

    scrollFrame.editBox.Instructions2= WoWTools_LabelMixin:Create(scrollFrame.editBox, {layer='BORDER', color={r=0.52, g=0.52, b=0.52}})
    scrollFrame.editBox.Instructions2:SetPoint('BOTTOMRIGHT', scrollFrame)
    scrollFrame.editBox.Instructions2:Hide()

    scrollFrame.editBox:SetScript('OnEditFocusGained', function(s)
        s.Instructions2:SetShown(true)
    end)
    scrollFrame.editBox:SetScript('OnEditFocusLost', function(s)
        s.Instructions2:SetShown(false)
    end)
    scrollFrame.editBox:SetScript('OnTextChanged', function(s)
        s.Instructions:SetShown(s:GetText() == "")
        local line= s:GetNumLines() or 0
        local num= WoWTools_Mixin:MK(s:GetNumLetters() or 0, 1)
        s.Instructions2:SetText(num..' - '..line)
    end)
    scrollFrame:HookScript('OnSizeChanged', function(s)
        s.editBox:SetWidth(s:GetWidth()-23)
    end)

--超链接
    if isLink then
        scrollFrame.editBox:SetHyperlinksEnabled(true)
        scrollFrame.editBox:SetScript('OnHyperlinkLeave', GameTooltip_Hide)
        scrollFrame.editBox:SetScript('OnHyperlinkEnter', function(s, link)
            if link then
                GameTooltip:SetOwner(s, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetHyperlink(link)
                GameTooltip:Show()
            end
        end)
        scrollFrame:SetScript('OnHyperlinkClick', function(s, link, text2)--, region)
            SetItemRef(link, text2, s, nil)
        end)
    end



    scrollFrame:SetScrollChild(scrollFrame.editBox)

    scrollFrame.SetInstructions= function(s, t)
        if t then
            s.editBox.Instructions:SetText(t)
        end
    end
    scrollFrame.SetText= function(s, ...)
        s.editBox:SetText(...)
    end
    scrollFrame.GetText= function(s)
        return s.editBox:GetText()
    end
    scrollFrame.ClearFocus= function(s)
        s.editBox:ClearFocus()
    end
    scrollFrame.SetFocus= function(s)
        s.editBox:SetFocus()
    end

    return scrollFrame
end






function WoWTools_EditBoxMixin:Setup(edit,  tab)
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
