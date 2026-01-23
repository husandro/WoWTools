--新建，公会, 签名 OfferPetition

local function Save()
    return WoWToolsSave['ChatButtonGuild'] or {}
end


local function Invite(unit)
    if WoWTools_UnitMixin:UnitIsUnit('player', unit)~=false
        or not WoWTools_UnitMixin:UnitGUID(unit)
        or not UnitIsConnected(unit)
        or not UnitIsPlayer(unit)
        or UnitIsEnemy('player', unit)
    then
        return
    end

    local guid= UnitGUID(unit)
    if guid and not IsPlayerInGuildFromGUID(guid) then
        OfferPetition()
    end
end















local function Init()
    if IsInGuild() then
        return
    end

    local btn= WoWTools_ButtonMixin:Cbtn(PetitionFrame, {isUI=true, size={120, 23}})

    btn:SetText(WoWTools_DataMixin.onlyChinese and '姓名板' or NAMEPLATES_LABEL)
    btn:SetPoint('TOPLEFT', 50, -33)

    btn:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:AddDoubleLine(WoWTools_ChatMixin.addName, WoWTools_GuildMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '开启友方姓名板' or NAMEPLATES_MESSAGE_FRIENDLY_ON)
        if InCombatLockdown() then
            GameTooltip_AddErrorLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        end
        GameTooltip:Show()
    end)
    btn:SetScript('OnClick', function()
        if InCombatLockdown() then
            return
        end
        C_CVar.SetCVar('nameplateShowFriends', C_CVar.GetCVarBool('nameplateShowFriends') and '0' or '1')
    end)

    local check= CreateFrame('CheckButton', 'PetitionFrameAutoPetitionTargetCheckBox', PetitionFrame, 'InterfaceOptionsCheckButtonTemplate')
    check:SetPoint('LEFT', btn, 'RIGHT', 2, 0)
    check.Text:SetText(WoWTools_DataMixin.onlyChinese and '目标' or TARGET)
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
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '自动要求签名' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, REQUEST_SIGNATURE), WoWTools_DataMixin.onlyChinese and '目标' or TARGET)
        GameTooltip:Show()
    end)

    function check:set_event()
        if self:IsVisible() and self:GetChecked() then
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
            Invite('target')
        else
            self:UnregisterEvent('PLAYER_TARGET_CHANGED')
        end
    end

    check:SetScript('OnEvent',  function()
        Invite('target')
    end)

    PetitionFrame:HookScript('OnHide', function()
        check:set_event()
    end)
    PetitionFrame:HookScript('OnShow', function()
        check:set_event()
    end)

    Init=function()end
end





function WoWTools_GuildMixin:Init_PetitionFrame()--新建，公会, 签名 OfferPetition
    Init()
end
