--新建，公会, 签名 OfferPetition
local e= select(2, ...)
local function Save()
    return WoWTools_GuildMixin.Save
end







local function Init()
    if IsInGuild() then
        return
    end

    local check= CreateFrame('CheckButton', 'PetitionFrameAutoPetitionTargetCheckBox', PetitionFrame, 'InterfaceOptionsCheckButtonTemplate')
    PetitionFrame.targetCheckBox= check

    check:SetPoint('TOPLEFT', 50, -33)
    check.Text:SetText(e.onlyChinese and '目标' or TARGET)
    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetChecked(not Save().disabledPetitionTarget)
    check:SetScript('OnClick', function(self)
        Save().disabledPetitionTarget= not self:GetChecked()
        self:set_event()
    end)
    check:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_ChatButtonMixin.addName, WoWTools_GuildMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '自动要求签名' or  format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, REQUEST_SIGNATURE), e.onlyChinese and '目标' or TARGET)
        e.tips:Show()
    end)

    function check:OfferPetition()
        if not UnitIsPlayer('target')
            or IsPlayerInGuildFromGUID(UnitGUID('target'))
            or UnitIsUnit('player', 'target')
            or UnitIsEnemy('player', 'target')
            or not UnitIsConnected('target')
        then
            return
        end
        OfferPetition()
    end

    function check:set_event()
        if self:IsVisible() and self:GetChecked() then
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
            self:OfferPetition()
        else
            self:UnregisterEvent('PLAYER_TARGET_CHANGED')
        end
    end

    check:SetScript('OnEvent', check.OfferPetition)

    PetitionFrame:HookScript('OnHide', function(self)
        self.targetCheckBox:set_event()
    end)
    PetitionFrame:HookScript('OnShow', function(self)
        self.targetCheckBox:set_event()
    end)
end





function WoWTools_GuildMixin:Init_PetitionFrame()--新建，公会, 签名 OfferPetition
    C_Timer.After(1, Init)
end
