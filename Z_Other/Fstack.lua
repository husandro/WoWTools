

















--fstack 增强 TableAttributeDisplay
local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end






local function Set_BGAlpha(self)
    if self.DialogBG then
        self.DialogBG:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Background\\Black.tga')
        self.DialogBG:SetAlpha(Save().debugTooltBgAlpha or 0.75)
    end
end

local function Init_Menu(self, root)
    WoWTools_MenuMixin:BgAplha(root,
    function()
        return Save().debugTooltBgAlpha or 0.75
    end, function(value)
        Save().debugTooltBgAlpha= value
        Set_BGAlpha(self:GetParent())
    end, function()
        Save().debugTooltBgAlpha= nil
        Set_BGAlpha(self:GetParent())
    end)

    --打开选项界面
    root:CreateDivider()
    WoWTools_OtherMixin:OpenOption(root, '|A:QuestLegendaryTurnin:0:0|a|cff00ff00FST|rACK')
    --WoWTools_ChatMixin:Open_SettingsPanel(root, WoWTools_HyperLink.addName)
end



local function Set_CheckBox(check, atlas)
    check.Label:SetText('')
    check.Label:SetAlpha(0)
    check:HookScript('OnLeave', WoWToolsButton_OnLeave)
    check:HookScript('OnEnter', WoWToolsButton_OnEnter)

    WoWTools_TextureMixin:SetCheckBox(check, atlas)
end














local function Init_Create(frame)
    if frame.WoWToolsButton then
        return
    end



--/fstack
    frame.WoWToolsButton= CreateFrame('Button', nil, frame, 'WoWToolsButtonTemplate')
    frame.WoWToolsButton:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
    frame.WoWToolsButton:SetPoint('RIGHT', frame, 'TOPRIGHT', -20, -44)


    Set_BGAlpha(frame)

    frame.WoWToolsButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            FrameStackTooltip_ToggleDefaults()
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    function frame.WoWToolsButton:tooltip()
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.Icon.icon2
            ..'|cff00ff00FST|rACK'
            ..WoWTools_DataMixin.Icon.left
            ..WoWTools_TextMixin:GetEnabeleDisable(not C_CVar.GetCVarBool('fstack_enabled')),

            WoWTools_DataMixin.Icon.right
            ..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
        )
    end

--更多信息
    frame.WoWToolsInfoButton= CreateFrame('Button', nil, frame.WoWToolsButton, 'WoWToolsButtonTemplate')
    frame.WoWToolsInfoButton:SetPoint('RIGHT', frame.WoWToolsButton, 'LEFT')
    frame.WoWToolsInfoButton:SetNormalAtlas('Garr_Building-AddFollowerPlus')
    frame.WoWToolsInfoButton.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '更多信息' or CLICK_FOR_DETAILS)
    frame.WoWToolsInfoButton:SetScript('OnClick', function(self)
        if C_CVar.GetCVarBool("fstack_enabled") then
            FrameStackTooltip_ToggleDefaults()
        end
        local p= self:GetParent():GetParent()--.dataProviders focusedTable
        WoWTools_DataMixin:Info(p.focusedTable)
    end)

    local check
    if frame==TableAttributeDisplay then
        check= CreateFrame('CheckButton', 'WoWToolsTableInspectorTableInspectorCheckxButton', frame.WoWToolsButton, 'WoWToolsCheckTemplate')
        function check:tooltip(tooltip)
            tooltip:AddLine(
                '/|cff00ff00FST|rACK'
                ..WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_DataMixin.onlyChinese and '自动关闭' or format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, CLOSE))
            )
        end
        function check:settings()
            Save().autoHideTableAttributeDisplay= not Save().autoHideTableAttributeDisplay and true or false
        end
        check:SetChecked(Save().autoHideTableAttributeDisplay)
        check:SetPoint('RIGHT', frame.WoWToolsInfoButton, 'LEFT')
        check:SetScript('OnHide', function()
            if Save().autoHideTableAttributeDisplay and FrameStackTooltip:IsVisible() then
                FrameStackTooltip_ToggleDefaults()
            end
        end)
        WoWTools_TextureMixin:SetCheckBox(check)
    end

    frame.WoWToolsLabel= frame.WoWToolsButton:CreateFontString(nil, 'ARTWORK', 'ChatFontNormal')-- WoWTools_LabelMixin:Create(frame.WoWToolsButton, {mouse=true})
    frame.WoWToolsLabel:SetJustifyH('RIGHT')
    frame.WoWToolsLabel:SetPoint('RIGHT', check or frame.WoWToolsInfoButton, 'LEFT')
    frame.WoWToolsLabel:SetScript('OnHide', function(self)
        self:SetText('')
    end)





    frame.WoWToolsEdit= CreateFrame("EditBox", nil, frame.WoWToolsButton, 'InputBoxTemplate')
    WoWTools_TextureMixin:SetEditBox(frame.WoWToolsEdit, {alpha=1})
    frame.WoWToolsEdit:SetPoint('RIGHT', frame.TitleButton.Text)
    frame.WoWToolsEdit:SetSize(23, 23)
    frame.WoWToolsEdit:SetAutoFocus(false)
    frame.WoWToolsEdit:ClearFocus()

    frame.WoWToolsEdit.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
    frame.WoWToolsEdit:SetScript('OnLeave', function(self)
        ResetCursor()
        WoWToolsButton_OnLeave(self)
    end)
    frame.WoWToolsEdit:SetScript('OnEnter', function(self)
        SetCursor('Interface\\CURSOR\\Cast')
        WoWToolsButton_OnEnter(self)
    end)

    frame.WoWToolsEdit:SetScript('OnHide', function(self)
        self:SetText('')
        self:ClearFocus()
    end)

    frame.WoWToolsEdit:SetScript('OnEditFocusGained', function(self)
        local p= self:GetParent():GetParent()
        local label=p.TitleButton.Text

        local text
        if p.focusedTable and p.focusedTable.GetDebugName then
            text= p.focusedTable:GetDebugName()
        end
        text= text or label:GetText() or ''
        self:SetText(text:match('Frame Attributes %- (.+)') or text)
        self:SetWidth(label:GetWidth())
        label:SetAlpha(0)
        GameTooltip:Hide()
        ResetCursor()
        self:HighlightText()
         if C_CVar.GetCVarBool("fstack_enabled") then
            FrameStackTooltip_ToggleDefaults()
        end
    end)
    frame.WoWToolsEdit:SetScript('OnEditFocusLost', function(self)
        self:GetParent():GetParent().TitleButton.Text:SetAlpha(1)
        self:SetWidth(23)
        self:SetText('')
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

    frame.OpenParentButton.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '上移一层' or BINDING_NAME_HOUSING_LAYOUTFLOOR_UP)
    frame.OpenParentButton:HookScript('OnLeave', WoWToolsButton_OnLeave)
    frame.OpenParentButton:HookScript('OnEnter', WoWToolsButton_OnEnter)

    frame.NavigateBackwardButton.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '后退' or BACK)
    frame.NavigateBackwardButton:HookScript('OnLeave', WoWToolsButton_OnLeave)
    frame.NavigateBackwardButton:HookScript('OnEnter', WoWToolsButton_OnEnter)

    frame.NavigateForwardButton.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '前进' or BINDING_NAME_MOVEFORWARD)
    frame.NavigateForwardButton:HookScript('OnLeave', WoWToolsButton_OnLeave)
    frame.NavigateForwardButton:HookScript('OnEnter', WoWToolsButton_OnEnter)

    frame.VisibilityButton.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '显示' or SHOW)
    Set_CheckBox(frame.VisibilityButton)--, 'AlliedRace-UnlockingFrame-GenderSelectionGlow')


    frame.HighlightButton.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '高亮' or frame.HighlightButton.Label:GetText())
    frame.HighlightButton:ClearAllPoints()
    frame.HighlightButton:SetPoint('LEFT', frame.VisibilityButton, 'RIGHT')
    Set_CheckBox(frame.HighlightButton, 'loottoast-itemborder-glow')

    frame.DynamicUpdateButton.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '动态更新' or frame.HighlightButton.Label:GetText())
    frame.DynamicUpdateButton:ClearAllPoints()
    frame.DynamicUpdateButton:SetPoint('LEFT', frame.HighlightButton, 'RIGHT')
    Set_CheckBox(frame.DynamicUpdateButton)--, 'AlliedRace-UnlockingFrame-GenderMouseOverGlow')

    frame.FilterBox:SetPoint('RIGHT', frame.WoWToolsLabel, 'LEFT')



















end











local function Init()
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
    WoWTools_DataMixin:Hook(TableInspectorMixin, 'OnLoad', function(frame)
        Init_Create(frame)
    end)




    local function set_objectType(self, focusedTable)
        if not self.WoWToolsLabel then
            return
        end
        local text

        focusedTable= focusedTable or self.focusedTable
        if focusedTable then
            if focusedTable.GetObjectType then
                text= focusedTable:GetObjectType()
            end
            if focusedTable.GetSize then
                text= (text and text..' ' or '')
                    ..format('%i|cffffd200x|r%i', focusedTable:GetSize())
            end
        end
        self.WoWToolsLabel:SetText(text or '')
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
        --TableAttributeDisplay.WoWToolsButton:SetShown(not Save().disabedFrameStackPlus)
    end
end














--fstack 增强 TableAttributeDisplay


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1== 'WoWTools' then
        if WoWTools_OtherMixin:AddOption(
            'FSTACK',
            '|A:QuestLegendaryTurnin:0:0|a|cff00ff00FST|rACK',
            'Blizzard_DebugTools|n/fstack'
        ) then
            Init()
        end

        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)