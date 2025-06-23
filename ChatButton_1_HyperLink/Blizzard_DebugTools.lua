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
    btn:SetScript('OnClick', function(self, d)
        --[[if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, function(_, root)
                local sub=root:CreateButton(
                    '|A:QuestLegendaryTurnin:0:0|a|cff00ff00FST|rACK',
                
                function ()
                    FrameStackTooltip_ToggleDefaults()
                    return MenuResponse.Open
                end)

                sub:SetTooltip(function (tooltip)
                    tooltip:AddLine('|cnGREEN_FONT_COLOR:Alt|r '..(WoWTools_DataMixin.onlyChinese and '切换' or HUD_EDIT_MODE_SWITCH))
                    tooltip:AddLine(' ')
                    tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl|r '..(WoWTools_DataMixin.onlyChinese and '显示' or SHOW))
                    tooltip:AddLine(' ')
                    tooltip:AddLine('|cnGREEN_FONT_COLOR:Shift|r '..(WoWTools_DataMixin.onlyChinese and '材质信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TEXTURES_SUBHEADER, INFO)))
                    tooltip:AddLine(' ')
                    tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+C|r '.. (WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)..' \"File\" '..(WoWTools_DataMixin.onlyChinese and '类型' or TYPE))
                end)


            end)
        else]]
            FrameStackTooltip_ToggleDefaults()
        
        --[[if Save().autoHideTableAttributeDisplay and FrameStackTooltip:IsVisible() then
            FrameStackTooltip_ToggleDefaults()
        end]]
        self:set_tooltip()
    end)
    btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HyperLink.addName)
        GameTooltip:AddDoubleLine('|cff00ff00FST|rACK', WoWTools_DataMixin.Icon.left..WoWTools_TextMixin:GetEnabeleDisable(C_CVar.GetCVarBool('fstack_enabled'), nil))
       -- GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
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
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_HyperLink.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r', s:GetText())
        end
    end)

    local check= CreateFrame('CheckButton', 'WoWToolsHyperLinkTableAttributeDisplayHideCheckBox', btn, 'UICheckButtonTemplate')
    check:SetPoint('RIGHT', edit, 'LEFT')
    check:SetChecked(Save().autoHideTableAttributeDisplay)
    check:HookScript('OnClick', function()
        Save().autoHideTableAttributeDisplay= not Save().autoHideTableAttributeDisplay and true or nil
    end)
    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HyperLink.addName)
        GameTooltip:AddDoubleLine('|cff00ff00FST|rACK', WoWTools_DataMixin.onlyChinese and '自动关闭' or format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, CLOSE))
        GameTooltip:Show()
    end)

    Init=function()
        btn:SetShown(not Save().disabedFrameStackPlus)
    end
end









--fstack 增强 TableAttributeDisplay
function WoWTools_HyperLink:Blizzard_DebugTools()
    Init()
end