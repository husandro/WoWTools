local function Save()
    return WoWToolsSave['Plus_Spell']
end






--天赋, 点数 Blizzard_SharedTalentButtonTemplates.lua Blizzard_ClassTalentButtonTemplates.lua
local function set_UpdateSpendText(btn)
    local info= btn.nodeInfo-- C_Traits.GetNodeInfo btn:GetSpellID()
    local text
    if info then
        if info.currentRank and info.maxRanks and info.currentRank>0 and info.maxRanks~= info.currentRank then
            text= '/'..info.maxRanks
        end
        if text and not btn.maxText then
            btn.maxText= WoWTools_LabelMixin:Create(btn, {fontType=btn.SpendText})--nil, btn.SpendText)
            btn.maxText:SetPoint('LEFT', btn.SpendText, 'RIGHT')
            btn.maxText:SetTextColor(1, 0, 1)
            btn.maxText:EnableMouse(true)
            btn.maxText:SetScript('OnLeave', GameTooltip_Hide)
            btn.maxText:SetScript('OnEnter', function(self)
                if self.maxRanks then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '最高等级' or TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK, self.maxRanks)
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_SpellMixin.addName)
                    GameTooltip:Show()
                end
            end)
        end
    end
    if btn.maxText then
        btn.maxText.maxRanks= info and info.maxRanks
        btn.maxText:SetText(text or '')
    end
end
















local function Set_TalentsFrameBg()
    local show= not Save().HideTalentsBG
    PlayerSpellsFrame.TalentsFrame.Background:SetShown(show)
    PlayerSpellsFrame.TalentsFrame.HeroTalentsContainer.PreviewContainer.Background:SetShown(show)
    PlayerSpellsFrame.TalentsFrame.BottomBar:SetShown(show)
end

local function Init_Background()
    Menu.ModifyMenu("MENU_CLASS_TALENT_PROFILE", function(_, root)--隐藏，天赋，背景
        root:CreateDivider()
        local sub=WoWTools_MenuMixin:ShowBackground(root, function()
            return not Save().HideTalentsBG
        end, function()
            Save().HideTalentsBG= not Save().HideTalentsBG and true or nil
            Set_TalentsFrameBg()
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_SpellMixin.addName)
        end)
    end)
    Set_TalentsFrameBg()
end









function WoWTools_SpellMixin:Init_TalentsFrame()
    if WoWToolsSave['Plus_Spell'].talentsFramePlus then
        hooksecurefunc(ClassTalentButtonSpendMixin, 'UpdateSpendText', set_UpdateSpendText)--天赋, 点数 
        Init_Background()
    end
end
