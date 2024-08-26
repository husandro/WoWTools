local e= select(2, ...)
--SecureScrollTemplates.xml
--SecureUIPanelTemplates.lua

WoWTools_EditBoxMixn={
    index=1
}

function WoWTools_EditBoxMixn:Create(frame, tab)
    self.index= self.index+1
    local name= tab.name or format('%s%d', 'WoWTools_Edit', self.index)
    local font= tab.font or 'ChatFontNormal'
    local template= tab.Template
    local setID= tab.setID

    local editBox= CreateFrame('EditBox', name, frame, template, setID)
    editBox:SetAutoFocus(false)
    editBox:ClearFocus()
    editBox:SetFontObject(font)
    
    editBox:SetScript('OnEscapePressed', EditBox_ClearFocus)
    editBox:SetScript('OnHide', function(s) s:SetText('') s:ClearFocus() end)

    return editBox
end







function WoWTools_EditBoxMixn:CreateMultiLineFrame(frame, tab)
    self.index= self.index+1
    tab= tab or {}
    
    local name= tab.name or format('%s%d', 'WoWTools_EditScrollFrame', self.index)--名称
    --local font= tab.font or 'GameFontHighlightSmall'--字体 ChatFontNormal
    local isShowLinkTooltip= tab.isShowLinkTooltip--超链接
    local instructions= tab.instructions--使用说明

    local scrollFrame= CreateFrame('ScrollFrame', name, frame, 'ScrollFrameTemplate')--InputScrollFrameTemplate

    local level= scrollFrame:GetFrameLevel()
    if scrollFrame.ScrollBar then
        scrollFrame.ScrollBar:ClearAllPoints()
        scrollFrame.ScrollBar:SetPoint('TOPRIGHT', -10, -10)
        scrollFrame.ScrollBar:SetPoint('BOTTOMRIGHT', -10, 10)
    end

    e.Set_ScrollBar_Color_Alpha(scrollFrame)

    scrollFrame.bg= CreateFrame('Frame', name..'BG', scrollFrame, 'TooltipBackdropTemplate')
    scrollFrame.bg:SetPoint('TOPLEFT', -5, 5)
    scrollFrame.bg:SetPoint('BOTTOMRIGHT', 0, -5)
    scrollFrame.bg:SetFrameLevel(level+1)
    e.Set_NineSlice_Color_Alpha(scrollFrame.bg, true, nil, nil, true)

    --[[scrollFrame.editBox= CreateFrame('EditBox', name..'Edit', scrollFrame)
    scrollFrame.editBox:SetAutoFocus(false)
    scrollFrame.editBox:ClearFocus()
    
    
    scrollFrame.editBox:SetFontObject(font)]]

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
    self:SetInstructions(scrollFrame.editBox, instructions, scrollFrame)
    
    function scrollFrame:SetText(...)
        self.editBox:SetText(...)
    end
    function scrollFrame:GetText()
        return self.editBox:GetText()
    end
    function scrollFrame:ClearFocus()
        self.editBox:ClearFocus()
    end
    function scrollFrame:SetFocus()
        self.editBox:SetFocus()
    end

    return scrollFrame
end



function WoWTools_EditBoxMixn:HookInstructions(editBox)
    editBox:HookScript('OnTextChanged', function(s)
        s.Instructions:SetShown(s:GetText() == "")
    end)
end

function WoWTools_EditBoxMixn:SetInstructions(editBox, instructions, frame)
    if not instructions then
        return
    end
    editBox= frame and frame.editBox or editBox
    if not editBox then
        return
    end
    editBox.Instructions=e.Cstr(editBox, {layer='BORDER', color={r=0.35, g=0.35, b=0.35}})
    editBox.Instructions:SetPoint('TOPLEFT')
    editBox.Instructions:SetText(instructions)    
    if frame then
        function frame:SetInstructions(text)
            if text then
                self.editBox.Instructions:SetText(text or '')
            end
        end
        self:HookInstructions(frame.editBox)       
    end    
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
