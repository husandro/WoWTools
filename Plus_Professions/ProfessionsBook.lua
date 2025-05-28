if PlayerGetTimerunningSeasonID() then
    return
end


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

    function btn:set_alpha()
        local enabled= Save().wangquePrefessionText
        self:SetAlpha(enabled and 1 or 0.2)
        self:SetNormalAtlas(enabled and WoWTools_DataMixin.Icon.icon or 'talents-button-reset')
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
        self:set_alpha()
        self:set_tooltips()
    end)
    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_alpha()
    end)
    btn:SetScript('OnEnter', btn.set_tooltips)
    btn:set_alpha()

    --自动输入，忘却，文字，专业
    hooksecurefunc(StaticPopupDialogs["UNLEARN_SKILL"], "OnShow", function(self)
        if Save().wangquePrefessionText then
            self.editBox:SetText(UNLEARN_SKILL_CONFIRMATION);
        end
    end)

    Init=function()end
end





function WoWTools_ProfessionMixin:Init_ProfessionsBook()
    Init()
end










--专业书
function WoWTools_TextureMixin.Events:Blizzard_ProfessionsBook()
    ProfessionsBookPage1:SetPoint('TOPLEFT', ProfessionsBookFrame, 'TOPLEFT', 0, -23)
    ProfessionsBookPage1:SetPoint('BOTTOM',0, -15)
    ProfessionsBookPage2:SetPoint('BOTTOMRIGHT', 15, -15)
    self:SetNineSlice(ProfessionsBookFrame, true, nil, nil)
    self:SetNineSlice(ProfessionsBookFrameInset, nil, true, nil)
    self:HideTexture(ProfessionsBookFrameBg)
    self:HideTexture(ProfessionsBookFrameInset.Bg)
    self:SetButton(ProfessionsBookFrameCloseButton, {all=true})

    ProfessionsBookFrameTutorialButton:SetFrameLevel(ProfessionsBookFrameCloseButton:GetFrameLevel()+1)
    self:SetFrame(ProfessionsBookFrameTutorialButton, {alpha=0.3})

    self:Init_BGMenu_Frame(
        ProfessionsBookFrame,--框架, frame.PortraitContainer
        'ProfessionsBookFrame',--名称
        nil,--Texture
        {
        settings=function(textureName, alphaValue)--设置内容时，调用
            ProfessionsBookPage1:SetShown(not textureName)
            ProfessionsBookPage2:SetShown(not textureName)
            ProfessionsBookPage1:SetAlpha(alphaValue or 1)
            ProfessionsBookPage2:SetAlpha(alphaValue or 1)
            if ProfessionsBookFrame.Add_Background and not textureName then
                ProfessionsBookFrame.Add_Background:SetShown(false)
            end
        end,
        --isHook=true,--是否Hook icon.Set_BGTexture= Set_BGTexture
        isAddBg=true,--是否添加背景
        alpha=1,
    })

    PrimaryProfession1.bg= PrimaryProfession1:CreateTexture(nil, 'BACKGROUND')
    PrimaryProfession1.bg:SetAtlas('delves-affix-mask')
    PrimaryProfession1.bg:SetAllPoints(PrimaryProfession1Icon)

    PrimaryProfession2.bg= PrimaryProfession2:CreateTexture(nil, 'BACKGROUND')
    PrimaryProfession2.bg:SetAtlas('delves-affix-mask')
    PrimaryProfession2.bg:SetAllPoints(PrimaryProfession2Icon)

    self:HideTexture(PrimaryProfession1SpellButtonBottomNameFrame)
    self:HideTexture(PrimaryProfession2SpellButtonBottomNameFrame)

    self:HideTexture(SecondaryProfession1SpellButtonLeftNameFrame)
    self:HideTexture(SecondaryProfession1SpellButtonRightNameFrame)

    self:HideTexture(SecondaryProfession2SpellButtonLeftNameFrame)
    self:HideTexture(SecondaryProfession2SpellButtonRightNameFrame)

    self:HideTexture(SecondaryProfession3SpellButtonLeftNameFrame)
    self:HideTexture(SecondaryProfession3SpellButtonRightNameFrame)


end



--专业书
function WoWTools_MoveMixin.Events:Blizzard_ProfessionsBook()
    self:Setup(ProfessionsBookFrame)
end