--角色 CharacterMicroButton 
local e= select(2, ...)
--MainMenuBarMicroButtons.lua




local function Init()
    local frame= CreateFrame('Frame')


    frame.Text= WoWTools_LabelMixin:Create(CharacterMicroButton,  {size=WoWTools_MainMenuMixin.Save.size, color=true})
    frame.Text:SetPoint('TOP', CharacterMicroButton, 0,  -3)

    frame.Text2= WoWTools_LabelMixin:Create(CharacterMicroButton,  {size=WoWTools_MainMenuMixin.Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', CharacterMicroButton, 0, 3)

    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)
    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text2)

    function frame:settings()
        local to, cu= GetAverageItemLevel()--装等
        local text
        if to and cu and to>0 then
            text=math.modf(cu)
            if to-cu>10 then
                text='|cnRED_FONT_COLOR:'..text..'|r'
                if IsInsane() and not WoWTools_MapMixin:IsInPvPArea() then
                    WoWTools_FrameMixin:HelpFrame({frame=self, topoint=self.Text, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, show=true})--设置，提示
                end
            end
        end
        self.Text:SetText(text or '')

        local text2, value= WoWTools_DurabiliyMixin:Get(false)--耐久度
        self.Text2:SetText(text2:gsub('%%', ''))
        WoWTools_FrameMixin:HelpFrame({frame=CharacterMicroButton, topoint=self.text2, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=true, show=value<30})--设置，提示
    end

    frame:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
    frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    frame:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
    frame:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame:SetScript('OnEvent', function(self) C_Timer.After(0.6, function() self:settings() end) end)
    --C_Timer.After(2, function() frame:settings() end)

    CharacterMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end

        GameTooltip:AddLine(' ')
        WoWTools_DurabiliyMixin:OnEnter()

        GameTooltip:AddLine(' ')
        local bat= UnitAffectingCombat('player')

        GameTooltip:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(WoWTools_Mixin.onlyChinese and '角色' or CHARACTER)..'|r'
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_Mixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP)
        )
        GameTooltip:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or (C_Reputation.GetNumFactions()>0 and '|cffffffff') or '|cff828282')..(WoWTools_Mixin.onlyChinese and '声望' or REPUTATION)..'|r'
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or (C_CurrencyInfo.GetCurrencyListSize() > 0 and '|cffffffff') or '|cff828282')
            ..(WoWTools_Mixin.onlyChinese and '货币' or TOKENS)..'|r'
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_Mixin.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
        )

        GameTooltip:Show()
    end)


    CharacterMicroButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() then
            ToggleCharacter("ReputationFrame")
        end
    end)

    CharacterMicroButton:EnableMouseWheel(true)
    CharacterMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        if d==1 then
            if not PaperDollFrame:IsShown() then
                ToggleCharacter("PaperDollFrame")
            end
        elseif d==-1 then
            if not TokenFrame:IsShown() then
                ToggleCharacter("TokenFrame")
            end
        end
    end)
end



function WoWTools_MainMenuMixin:Init_Character()
    Init()
end