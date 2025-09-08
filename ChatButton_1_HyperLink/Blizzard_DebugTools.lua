--fstack 增强 TableAttributeDisplay
local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end

local btn











local function Init()
    if Save().disabedFrameStackPlus or not C_AddOns.IsAddOnLoaded('Blizzard_DebugTools') then
        return
    end




    btn= WoWTools_ButtonMixin:Cbtn(TableAttributeDisplay, {
        size=26,
        name='WoWToolsHyperLinkTableAttributeDisplayButton',
    })

    btn:SetPoint('BOTTOM', TableAttributeDisplay.CloseButton, 'TOP')
    btn:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
    btn:SetScript('OnClick', function(self)
        FrameStackTooltip_ToggleDefaults()
        self:set_tooltip()
    end)
    btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HyperLink.addName)
        GameTooltip:AddDoubleLine('|cff00ff00FST|rACK', WoWTools_DataMixin.Icon.left..WoWTools_TextMixin:GetEnabeleDisable(C_CVar.GetCVarBool('fstack_enabled'), nil))
        GameTooltip:Show()
    end
    btn:SetScript('OnEnter',  btn.set_tooltip)
    btn:SetScript('OnHide', function()
        if Save().autoHideTableAttributeDisplay and FrameStackTooltip:IsVisible() then
            FrameStackTooltip_ToggleDefaults()
        end
    end)


    local edit= CreateFrame("EditBox", 'WoWToolsHyperLinkTableAttributeDisplayEdit', btn, 'InputBoxTemplate')
    WoWTools_TextureMixin:SetEditBox(edit)
    edit:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMLEFT')
    edit:SetPoint('TOPLEFT', TableAttributeDisplay, 'TOPLEFT', 36, 24 )
    edit:SetAutoFocus(false)
    edit:ClearFocus()
    edit:SetScript('OnUpdate', function(self2, elapsed)
        self2.elapsed= (self2.elapsed or 0.3) +elapsed
        if self2.elapsed>0.3 then
            self2.elapsed=0
            if not self2:HasFocus() then
                local text = TableAttributeDisplay.TitleButton.Text:GetText()
                if text and text~='' then
                    edit:SetText(text:match('%- (.+)') or text)
                end
            end
        end
    end)
    edit:SetScript("OnKeyUp", function(s, key)
        if IsControlKeyDown() and key == "C" then
            print(
                WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r',
                s:GetText()
            )
        end
    end)



    local check= WoWTools_ButtonMixin:Cbtn(btn, {
        name='WoWToolsHyperLinkTableAttributeDisplayHideCheckBox',
        isCheck=true
    })
    function check:settings()
        Save().autoHideTableAttributeDisplay= not Save().autoHideTableAttributeDisplay and true or false
    end
    function check:tooltip(tooltip)
        tooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HyperLink.addName)
        tooltip:AddDoubleLine('|cff00ff00FST|rACK', WoWTools_DataMixin.onlyChinese and '自动关闭' or format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, CLOSE))
    end
    check:SetPoint('RIGHT', edit, 'LEFT', -2, 0)
    check:SetChecked(Save().autoHideTableAttributeDisplay)


--[[GetAttributeSource
--GetTableInspector
--GetAttributeData 
    WoWTools_DataMixin:Hook(TableAttributeDisplay, 'UpdateLines', function(self)
        if not self.dataProviders then
            return
        end
        for _, line in ipairs(self.lines) do
        end
    end)
    WoWTools_DataMixin:Hook(TableAttributeLineReferenceMixin, 'Initialize', function(line, attributeSource, index, attributeData)
                    local text
            local focusedTable = attributeSource:GetFocusedTable()
            if focusedTable and  focusedTable.GetObjectType then
                text= focusedTable:GetObjectType()
            end
            if focusedTable.GetSize then
                text= (text and text..' ' or '')
                    ..format('%i|cffffffffx|r%i', focusedTable:GetSize())
            end
            print(text)
    end)
]]

    local objectTypeLabel= WoWTools_LabelMixin:Create(edit, {mouse=true})
    objectTypeLabel:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    objectTypeLabel:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2..' :GetObjectType()'
        )
        GameTooltip:AddLine(WoWTools_DataMixin.Icon.icon2..' :GetSize()')
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    objectTypeLabel:SetPoint('BOTTOMLEFT', edit, 'TOPLEFT', 0, 2)




    local function set_objectType(focusedTable)
        local text
        if focusedTable then
            if focusedTable.GetObjectType then
                text= focusedTable:GetObjectType()
            end
            if focusedTable.GetSize then
                text= (text and text..' ' or '')
                    ..format('%i|cffffffffx|r%i', focusedTable:GetSize())
            end
        end

        objectTypeLabel:SetText(text or '')
    end

    hooksecurefunc(TableInspectorMixin, 'InspectTable', function(_, focusedTable)
        set_objectType(focusedTable)
    end)

    hooksecurefunc(TableAttributeDisplay, 'InspectTable', function(_, focusedTable)--self.focusedTable= focusedTable
        set_objectType(focusedTable)
    end)

    Init=function()
        btn:SetShown(not Save().disabedFrameStackPlus)
    end
end




    --[[local iconLabel= WoWTools_LabelMixin:Create(edit, {mouse=true})
    iconLabel:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    iconLabel:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2..'texture or atlas'..WoWTools_DataMixin.Icon.left
        )
        GameTooltip:Show()
    end)
    iconLabel:SetScript('OnMouseDown', function(self)
        edit:SetText(self:GetText())
    end)
    iconLabel:SetPoint('LEFT', objectTypeLabel, 'RIGHT',4, 2)
    iconLabel:SetPoint('BOTTOMRIGHT', edit, 'TOPRIGHT', 0, 2)
    ]]




--fstack 增强 TableAttributeDisplay
function WoWTools_HyperLink:Blizzard_DebugTools()
    Init()
end