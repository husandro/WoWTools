if PlayerGetTimerunningSeasonID() then
    return
end


local function Save()
    return WoWToolsSave['Plus_Professions']
end


local UNLEARN_SKILL_CONFIRMATION= UNLEARN_SKILL_CONFIRMATION







--专业书
local function Init()
    local btn2= WoWTools_ButtonMixin:Cbtn(ProfessionsBookFrame, {size=22})
    btn2:SetPoint('TOP', ProfessionsBookFramePortrait, 'BOTTOM')
    function btn2:set_alpha()
        self:SetAlpha(Save().wangquePrefessionText and 1 or 0.3)
        self:SetNormalAtlas(not Save().wangquePrefessionText and WoWTools_DataMixin.Icon.icon or 'talents-button-reset')
    end
    function btn2:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '自动输入 ‘忘却’' or (TRADE_SKILLS ..': '..UNLEARN_SKILL_CONFIRMATION))..WoWTools_TextMixin:GetEnabeleDisable(Save().wangquePrefessionText), (WoWTools_DataMixin.onlyChinese and '双击' or BUFFER_DOUBLE)..WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '你确定要忘却%s并遗忘所有已经学会的配方？如果你选择回到此专业，你的专精知识将依然存在。|n|n在框内输入 \"忘却\" 以确认。' or UNLEARN_SKILL, nil,nil,nil, true)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_ProfessionMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(1)
    end
    btn2:SetScript("OnDoubleClick", function(self)
        Save().wangquePrefessionText= not Save().wangquePrefessionText and true or nil
        self:set_alpha()
        self:set_tooltips()
    end)
    btn2:SetScript('OnLeave', function(self) GameTooltip:Hide() self:set_alpha()end)
    btn2:SetScript('OnEnter', btn2.set_tooltips)
    btn2:set_alpha()

    --自动输入，忘却，文字，专业
    hooksecurefunc(StaticPopupDialogs["UNLEARN_SKILL"], "OnShow", function(self)
        if Save().wangquePrefessionText or IsPublicBuild() then
            self.editBox:SetText(UNLEARN_SKILL_CONFIRMATION);
        end
    end)

    Init=function()end
end





function WoWTools_ProfessionMixin:Init_ProfessionsBook()
    Init()
end