WoWTools_LFDMixin={}


local function Get_IsInProposal()
    local proposalExists, _, _, _, _, _, _, _, _, _, _, _, _, _, isSilent = GetLFGProposal()
    return proposalExists or isSilent
end



--显示 LFGDungeonReadyDialog
function WoWTools_LFDMixin:ShowMenu_LFGDungeonReadyDialog(root)
    if LFGDungeonReadyPopup:IsShown() then
        return true

    elseif Get_IsInProposal() then
        return false
    end

    root:CreateDivider()

    local sub= root:CreateButton(
        WoWTools_Mixin.onlyChinese and '显示进入' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, ENTER_LFG),
    function()
        if Get_IsInProposal() then
            if LFGDungeonReadyPopup:IsShown() then
                StaticPopupSpecial_Show(LFGDungeonReadyPopup)
            else
                StaticPopupSpecial_Hide(LFGDungeonReadyPopup)
            end
        end
        return MenuResponse.Open
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('LFGDungeonReadyPopup')
        tooltip:AddDoubleLine(WoWTools_LFDMixin.addName, WoWTools_ChatButtonMixin.addName)
    end)

    return true
end

StaticPopupSpecial_Show(LFGDungeonReadyPopup)
        