local function Save()
    return WoWToolsSave['Plus_Professions']
end


local UNLEARN_SKILL_CONFIRMATION= UNLEARN_SKILL_CONFIRMATION







--专业书
local function Init()
    local btn= WoWTools_ButtonMixin:Cbtn(ProfessionsBookFrameCloseButton, {
        name='WoWtoolsUNLEARN_SKILLButton',
        size=22,
    })
    btn:SetPoint('RIGHT', ProfessionsBookFrameCloseButton, 'LEFT')

    function btn:settings()
        local enabled= Save().wangquePrefessionText
        self:SetAlpha(GameTooltip:IsOwned(self) and 1 or 0.3)
        if enabled then
            self:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        else
            self:SetNormalAtlas('talents-button-reset')
        end
    end
    function btn:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '自动输入 ‘忘却’' or (TRADE_SKILLS ..': '..UNLEARN_SKILL_CONFIRMATION))
            ..WoWTools_TextMixin:GetEnabeleDisable(Save().wangquePrefessionText),

            WoWTools_DataMixin.Icon.left
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '你确定要忘却%s并遗忘所有已经学会的配方？如果你选择回到此专业，你的专精知识将依然存在。|n|n在框内输入 \"忘却\" 以确认。' or UNLEARN_SKILL, nil,nil,nil, true)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_ProfessionMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(1)
    end

    btn:SetScript('OnClick', function(self)
        Save().wangquePrefessionText= not Save().wangquePrefessionText and true or nil
        self:settings()
        self:set_tooltips()
    end)
    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:settings()
    end)
    btn:SetScript('OnEnter', btn.set_tooltips)
    btn:settings()

    --自动输入，忘却，文字，专业
    StaticPopupDialogs["UNLEARN_SKILL"].acceptDelay= 1
    WoWTools_DataMixin:Hook(StaticPopupDialogs["UNLEARN_SKILL"], "OnShow", function(self)
        if Save().wangquePrefessionText then
            local edit= self.editBox or self:GetEditBox()
            edit:SetText(UNLEARN_SKILL_CONFIRMATION);
        end
    end)

    Init=function()end
end





function WoWTools_ProfessionMixin:Init_ProfessionsBook()
    Init()
end











