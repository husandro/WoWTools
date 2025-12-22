--fstack 增强 TableAttributeDisplay
local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end



local function Init_Create(frame)
    if frame.WoWToolsButton then
        return
    end

    frame.WoWToolsButton= CreateFrame('Button', 'WoWToolsHyperLinkTableAttributeDisplayButton', frame, 'WoWToolsButtonTemplate')
    frame.WoWToolsButton:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')

    frame.WoWToolsButton:SetPoint('BOTTOM', frame.CloseButton, 'TOP')
    frame.WoWToolsButton:SetScript('OnClick', function(self)
        FrameStackTooltip_ToggleDefaults()
        self:set_tooltip()
    end)
    function frame.WoWToolsButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HyperLink.addName)
        GameTooltip:AddDoubleLine('|cff00ff00FST|rACK', WoWTools_DataMixin.Icon.left..WoWTools_TextMixin:GetEnabeleDisable(C_CVar.GetCVarBool('fstack_enabled'), nil))
        GameTooltip:Show()
    end


    frame.WoWToolsInfoButton= CreateFrame('Button', nil, frame.WoWToolsButton, 'WoWToolsButtonTemplate')
    frame.WoWToolsInfoButton:SetPoint('RIGHT', frame.WoWToolsButton, 'LEFT')
    frame.WoWToolsInfoButton:SetNormalAtlas('Garr_Building-AddFollowerPlus')
    frame.WoWToolsInfoButton:SetScript('OnMouseDown', function(self)
        if C_CVar.GetCVarBool("fstack_enabled") then
            FrameStackTooltip_ToggleDefaults()
        end
        local p= self:GetParent():GetParent()--.dataProviders focusedTable
        WoWTools_DataMixin:Info(p.focusedTable)
    end)


    frame.WoWToolsEdit= CreateFrame("EditBox", 'WoWToolsHyperLinkTableAttributeDisplayEdit', frame.WoWToolsButton, 'InputBoxTemplate')
    WoWTools_TextureMixin:SetEditBox(frame.WoWToolsEdit)
    frame.WoWToolsEdit:SetPoint('BOTTOMRIGHT', frame.WoWToolsInfoButton, 'BOTTOMLEFT')
    frame.WoWToolsEdit:SetPoint('TOPLEFT', TableAttributeDisplay, 'TOPLEFT', 36, 24 )
    frame.WoWToolsEdit:SetAutoFocus(false)
    frame.WoWToolsEdit:ClearFocus()
    frame.WoWToolsEdit:SetScript('OnHide', function(self)
        self:SetText('')
    end)
    frame.WoWToolsEdit:SetScript('OnEditFocusLost', function(self)
        local text = TableAttributeDisplay.TitleButton.Text:GetText()
        if text and text~='' then
            self:SetText(text:match('%- (.+)') or text)
        end
    end)
    frame.WoWToolsEdit:SetScript("OnKeyUp", function(s, key)
        if IsControlKeyDown() and key == "C" then
            print(
                WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r',
                s:GetText()
            )
        end
    end)






    frame.WoWToolsLabel= frame.WoWToolsButton:CreateFontString(nil, 'ARTWORK', 'ChatFontNormal')-- WoWTools_LabelMixin:Create(frame.WoWToolsButton, {mouse=true})
    frame.WoWToolsLabel:SetPoint('BOTTOMLEFT', frame.WoWToolsEdit, 'TOPLEFT', 0, 2)
    frame.WoWToolsLabel:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    frame.WoWToolsLabel:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2..' :GetObjectType()'
        )
        GameTooltip:AddLine(WoWTools_DataMixin.Icon.icon2..' :GetSize()')
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    frame.WoWToolsLabel:SetScript('OnHide', function(self)
        self:SetText('')
    end)



    local check= CreateFrame('CheckButton', nil, frame.WoWToolsButton, 'UICheckButtonTemplate')
    function check:tooltip(tooltip)
        tooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HyperLink.addName)
        tooltip:AddDoubleLine('|cff00ff00FST|rACK', WoWTools_DataMixin.onlyChinese and '自动关闭' or format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, CLOSE))
    end
    WoWToolsButton_OnEnter(check)
    WoWToolsButton_OnLeave(check)
    check:SetPoint('RIGHT', frame.WoWToolsEdit, 'LEFT', -2, 0)
    check:SetChecked(Save().autoHideTableAttributeDisplay)
    check:SetScript('OnMouseDown', function()
        Save().autoHideTableAttributeDisplay= not Save().autoHideTableAttributeDisplay and true or false
    end)
    check:SetScript('OnHide', function()
        if Save().autoHideTableAttributeDisplay and FrameStackTooltip:IsVisible() then
            FrameStackTooltip_ToggleDefaults()
        end
    end)
    WoWTools_TextureMixin:SetCheckBox(check)
end











local function Init()
    if Save().disabedFrameStackPlus then
        return
    end

    if not C_AddOns.IsAddOnLoaded('Blizzard_DebugTools') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_DebugTools' then
                Init()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end


    Init_Create(TableAttributeDisplay)
    --WoWTools_DataMixin:Hook(TableInspectorMixin, 'OnLoad', function(frame)

    local function set_objectType(_, focusedTable)
        local text
        TableAttributeDisplay.WoWToolsLabel:SetText('')
        if focusedTable then
            if focusedTable.GetObjectType then
                text= focusedTable:GetObjectType()
            end
            if focusedTable.GetSize then
                text= (text and text..' ' or '')
                    ..format('%i|cffffffffx|r%i', focusedTable:GetSize())
            end
            if text then
                TableAttributeDisplay.WoWToolsLabel:SetText(text)
            end
        end
        text = TableAttributeDisplay.TitleButton.Text:GetText()
        if text and text~='' then
            TableAttributeDisplay.WoWToolsEdit:SetText(text:match('%- (.+)') or text)
        end
    end




    WoWTools_DataMixin:Hook(TableInspectorMixin, 'InspectTable', function(frame, focusedTable)
        set_objectType(frame, focusedTable)
    end)

    WoWTools_DataMixin:Hook(TableAttributeDisplay, 'InspectTable', function(frame, focusedTable)--self.focusedTable= focusedTable
        set_objectType(frame, focusedTable)
    end)



    WoWTools_DataMixin:Hook(TableAttributeLineMixin, 'Initialize', function(line, attributeSource, index, attributeData)
        if attributeData.type=='function' then
            line.Key.Text:SetTextColor(BLUE_FONT_COLOR:GetRGB())--|cff00bff3
        elseif attributeData.type=='table' then
            line.Key.Text:SetTextColor(ARTIFACT_GOLD_COLOR:GetRGB())--|cffe6cc80
        elseif attributeData.type=='userdata' then
            line.Key.Text:SetTextColor(WARNING_FONT_COLOR:GetRGB())--|cffff4800
        elseif attributeData.type=='region' then
            line.Key.Text:SetTextColor(ADVENTURES_HEALING_GREEN:GetRGB())--|cff00ff12
        elseif attributeData.type=='childFrame' then
            line.Key.Text:SetTextColor(ITEM_EPIC_COLOR:GetRGB())--|cffa334ee
        elseif attributeData.type=='string' then
            line.Key.Text:SetTextColor(CORRUPTION_COLOR:GetRGB())--|cff956dd1
        else
            line.Key.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        end
    end)

    Init=function()
        _G['WoWToolsHyperLinkTableAttributeDisplayButton']:SetShown(not Save().disabedFrameStackPlus)
    end
end














--fstack 增强 TableAttributeDisplay
function WoWTools_HyperLink:Init_DebugTools()
    Init()
end