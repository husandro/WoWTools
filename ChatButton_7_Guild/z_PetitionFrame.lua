--新建，公会, 签名 OfferPetition
local e= select(2, ...)
local function Save()
    return WoWTools_GuildMixin.Save
end


local check

local function Init()
    if IsInGuild() then
        return
    end

    check= CreateFrame('CheckButton', 'PetitionFrameAutoPetitionTargetCheckBox', PetitionFrame, 'InterfaceOptionsCheckButtonTemplate')

    check:SetPoint('TOPLEFT', 50, -33)
    check.Text:SetText(e.onlyChinese and '目标' or TARGET)
    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetChecked(not Save().disabledPetitionTarget)
    check:SetScript('OnClick', function(self)
        Save().disabledPetitionTarget= not self:GetChecked()
        self:set_event()
    end)
    check:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_ChatMixin.addName, WoWTools_GuildMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(e.onlyChinese and '自动要求签名' or  format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, REQUEST_SIGNATURE), e.onlyChinese and '目标' or TARGET)
        GameTooltip:Show()
    end)

    function check:OfferPetition(unit)
        unit= unit or 'player'
        local guid= UnitGUID('target')
        if not UnitIsPlayer('target')
            or IsPlayerInGuildFromGUID(guid)
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

    PetitionFrame:HookScript('OnHide', function()
        check:set_event()
    end)
    PetitionFrame:HookScript('OnShow', function()
        check:set_event()
    end)
end





function WoWTools_GuildMixin:Init_PetitionFrame()--新建，公会, 签名 OfferPetition
    Init()
end
