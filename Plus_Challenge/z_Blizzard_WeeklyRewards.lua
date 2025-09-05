
--周奖励界面界面
--#############
local function Init()
--添加一个按钮，打开挑战界面
    local btn= WoWTools_ButtonMixin:Cbtn(WeeklyRewardsFrame, {
        texture='Interface\\Icons\\achievement_bg_wineos_underxminutes',
        size=32,
        isType2=true,
        notBorder=true,
        name='WoWToolsChallengePlusOpenChallengesFrameButton',
    })
    btn:SetFrameStrata('HIGH')
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '史诗钥石地下城' or CHALLENGES)
        GameTooltip:Show()
        self:SetButtonState('NORMAL')
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetButtonState('NORMAL')
        GameTooltip:Hide()
    end)
    btn:SetScript('OnClick', function()
        PVEFrame_ToggleFrame('ChallengesFrame', 3)
    end)
    btn:SetScript('OnHide', function(self)
        self:SetButtonState('NORMAL')
    end)
    btn:SetPoint('RIGHT',-4,-42)

--移动，图片
    WoWTools_DataMixin:Hook(WeeklyRewardsFrame, 'UpdateOverlay', function(self)--Blizzard_WeeklyRewards.lua
        if self.Overlay and self.Overlay:IsShown() then--未提取,提示
            self.Overlay:ClearAllPoints()
            self.Overlay:SetPoint('TOPLEFT', 23,-23)
        end
    end)

    --未提取,提示
    if WeeklyRewardExpirationWarningDialog then
        function WeeklyRewardExpirationWarningDialog:set_hide()--GreatVaultRetirementWarningFrameMixin:OnShow()
            if not C_WeeklyRewards.HasInteraction() then
                local title = _G["EXPANSION_NAME"..LE_EXPANSION_LEVEL_CURRENT];
                local text
                if title then
                    title= WoWTools_TextMixin:CN(title)
                    if C_WeeklyRewards.ShouldShowFinalRetirementMessage() then
                        text= format(WoWTools_DataMixin.onlyChinese and '所有未领取的奖励都会在%s上线后消失。' or GREAT_VAULT_RETIRE_WARNING_FINAL_WEEK, title)
                    elseif C_WeeklyRewards.HasAvailableRewards() or C_WeeklyRewards.HasGeneratedRewards() or C_WeeklyRewards.CanClaimRewards() then
                        text= format(WoWTools_DataMixin.onlyChinese and '本周后就不能获得新的奖励了。|n%s上线后，所有未领取的奖励都会丢失。' or GREAT_VAULT_RETIRE_WARNING, title);
                    end
                    if text then
                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_ChallengeMixin.addName,'|n|cffff00ff',text)
                    end
                end
            end
            self:Hide()
        end
        WeeklyRewardExpirationWarningDialog:HookScript('OnShow', WeeklyRewardExpirationWarningDialog.set_hide)
        if WeeklyRewardExpirationWarningDialog:IsShown() then
            WeeklyRewardExpirationWarningDialog:set_hide()
        end
    end

    Init=function()end
end


function WoWTools_ChallengeMixin:Blizzard_WeeklyRewards()
    Init()
end