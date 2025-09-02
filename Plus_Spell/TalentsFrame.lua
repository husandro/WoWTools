local function Save()
    return WoWToolsSave['Plus_Spell']
end

--[[local function Call_Bg()
    WoWTools_DataMixin:Call(PlayerSpellsFrame.TalentsFrame.UpdateSpecBackground, PlayerSpellsFrame.TalentsFrame)
    --PlayerSpellsFrame.TalentsFrame:UpdateSpecBackground()
end]]











local function Init()
--天赋, 点数 Blizzard_SharedTalentButtonTemplates.lua Blizzard_ClassTalentButtonTemplates.lua
    hooksecurefunc(ClassTalentButtonSpendMixin, 'UpdateSpendText', function(btn)
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
    end)



    --WoWTools_SpellMixin:Set_UI()




    Init=function()
        --Set_TalentsFrameBg()
    end
end







function WoWTools_SpellMixin:Init_TalentsFrame()
    if Save().talentsFramePlus and C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
        Init()
    end
end
