if PlayerGetTimerunningSeasonID() then
    return
end

local e= select(2, ...)
local function Save()
    return WoWTools_ProfessionMixin.Save
end




--专业书
local function Init()
    --自动输入，忘却，文字，专业
    --[[if IsPublicBuild() then
        return
    end]]

    local btn2= WoWTools_ButtonMixin:Cbtn(ProfessionsBookFrame, {size=22})
    btn2:SetPoint('TOP', ProfessionsBookFramePortrait, 'BOTTOM')
    function btn2:set_alpha()
        self:SetAlpha(Save().wangquePrefessionText and 1 or 0.3)
        self:SetNormalAtlas(not Save().wangquePrefessionText and WoWTools_DataMixin.Icon.icon or WoWTools_DataMixin.Icon.disabled)
    end
    function btn2:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '自动输入 ‘忘却’' or (TRADE_SKILLS ..': '..UNLEARN_SKILL_CONFIRMATION))..WoWTools_TextMixin:GetEnabeleDisable(Save().wangquePrefessionText), (WoWTools_Mixin.onlyChinese and '双击' or BUFFER_DOUBLE)..WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '你确定要忘却%s并遗忘所有已经学会的配方？如果你选择回到此专业，你的专精知识将依然存在。|n|n在框内输入 \"忘却\" 以确认。' or UNLEARN_SKILL, nil,nil,nil, true)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ProfessionMixin.addName)
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
end





function WoWTools_ProfessionMixin:Init_ProfessionsBook()
    Init()
end