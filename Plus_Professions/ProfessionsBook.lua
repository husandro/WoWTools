local e= select(2, ...)
local function Save()
    return WoWTools_ProfessionMixin.Save
end




--专业书
local function Init()
    --自动输入，忘却，文字，专业
    if IsPublicBuild() then
        return
    end

    local btn2= WoWTools_ButtonMixin:Cbtn(ProfessionsBookFrame, {size={22,22}, icon='hide'})
    btn2:SetPoint('TOP', ProfessionsBookFramePortrait, 'BOTTOM')
    function btn2:set_alpha()
        self:SetAlpha(Save().wangquePrefessionText and 1 or 0.3)
        self:SetNormalAtlas(not Save().wangquePrefessionText and e.Icon.icon or e.Icon.disabled)
    end
    function btn2:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine((e.onlyChinese and '自动输入 ‘忘却’' or (TRADE_SKILLS ..': '..UNLEARN_SKILL_CONFIRMATION))..e.GetEnabeleDisable(Save().wangquePrefessionText), (e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '你确定要忘却%s并遗忘所有已经学会的配方？如果你选择回到此专业，你的专精知识将依然存在。|n|n在框内输入 \"忘却\" 以确认。' or UNLEARN_SKILL, nil,nil,nil, true)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.addName, WoWTools_ProfessionMixin.addName)
        e.tips:Show()
        self:SetAlpha(1)
    end
    btn2:SetScript("OnDoubleClick", function(self)
        Save().wangquePrefessionText= not Save().wangquePrefessionText and true or nil
        self:set_alpha()
        self:set_tooltips()
    end)
    btn2:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha()end)
    btn2:SetScript('OnEnter', btn2.set_tooltips)
    btn2:set_alpha()
end





function WoWTools_ProfessionMixin:Init_ProfessionsBook()
    Init()
end