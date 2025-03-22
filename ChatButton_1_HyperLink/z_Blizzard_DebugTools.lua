--fstack 增强 TableAttributeDisplay
local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end

local btn











local function Init()
    if  Save().disabedFrameStackPlus or not TableAttributeDisplay then
        return
    end


    btn= WoWTools_ButtonMixin:Cbtn(TableAttributeDisplay, {
        size=26,
        name='WoWToolsHyperLinkTableAttributeDisplayButton',
    })

    btn:SetPoint('BOTTOM', TableAttributeDisplay.CloseButton, 'TOP')
    btn:SetNormalAtlas(WoWTools_DataMixin.Icon.icon)
    btn:SetScript('OnClick', function(self)
        FrameStackTooltip_ToggleDefaults()
        if Save().autoHideTableAttributeDisplay and FrameStackTooltip:IsVisible() then
            FrameStackTooltip_ToggleDefaults()
        end
        self:set_tooltip()
    end)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_HyperLink.addName)
        GameTooltip:AddDoubleLine('|cff00ff00FST|rACK', WoWTools_TextMixin:GetEnabeleDisable(FrameStackTooltip:IsVisible()))
        GameTooltip:Show()
    end
    btn:SetScript('OnEnter',  btn.set_tooltip)
    btn:SetScript('OnHide', function()
        if Save().autoHideTableAttributeDisplay and FrameStackTooltip:IsVisible() then
            FrameStackTooltip_ToggleDefaults()
        end
    end)


    local edit= CreateFrame("EditBox", 'WoWToolsHyperLinkTableAttributeDisplayEdit', btn, 'InputBoxTemplate')
    WoWTools_TextureMixin:SetSearchBox(edit)
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
            print(WoWTools_DataMixin.Icon.icon2.. WoWTools_HyperLink.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r', s:GetText())
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
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_HyperLink.addName)
        GameTooltip:AddDoubleLine('|cff00ff00FST|rACK', WoWTools_Mixin.onlyChinese and '自动关闭' or format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, CLOSE))
        GameTooltip:Show()
    end)

    return true
end










--fstack 增强 TableAttributeDisplay
function WoWTools_HyperLink:Blizzard_DebugTools()
    if Init() then
        Init=function()
            btn:SetShown(not self.Save.disabedFrameStackPlus)
        end
    end
end