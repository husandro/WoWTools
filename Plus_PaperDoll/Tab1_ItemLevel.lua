--总装等
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end
local LabelPvE, LabelPvP









local function Init()
    if LabelPvE then
        LabelPvE:SetShown(not Save().hide)
        LabelPvE:SetShown(not Save().hide)
        WoWTools_PaperDollMixin:Set_Tab1_ItemLevel()
        return
    end
        
    
--物品等级
    LabelPvE=WoWTools_LabelMixin:Create(PaperDollSidebarTab1, {justifyH='CENTER', mouse=true})
    LabelPvE:SetPoint('BOTTOM')
    LabelPvE:EnableMouse(true)
    LabelPvE:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
    LabelPvE:SetScript('OnMouseDown', function()
        e.call(PaperDollFrame_SetSidebar, PaperDollSidebarTab1, 1)--PaperDollFrame.lua
    end)
    LabelPvE:SetScript('OnEnter', function(self)
        if not self.avgItemLevel then
            return
        end
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip)
        e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
        e.tips:AddLine(' ')
        e.tips:AddLine('|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '物品等级：%d' or CHARACTER_LINK_ITEM_LEVEL_TOOLTIP, self.avgItemLevel or ''))
        e.tips:AddDoubleLine(e.addName, WoWTools_PaperDollMixin.addName)
        e.tips:Show()
        self:SetAlpha(0.3)
    end)


--PvP物品等级
    LabelPvP=WoWTools_LabelMixin:Create(PaperDollSidebarTab1, {justifyH='CENTER', mouse=true})
    LabelPvP:SetPoint('TOP')
    LabelPvP:SetScript('OnMouseDown', function(self)
        e.call(PaperDollFrame_SetSidebar, PaperDollSidebarTab1, 1)
    end)
    LabelPvP:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
    LabelPvP:SetScript('OnEnter', function(self)
        if not self.avgItemLevelPvp then
            return
        end
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip)
        e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
        e.tips:AddLine(' ')
        e.tips:AddLine('|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and 'PvP物品等级 %d' or ITEM_UPGRADE_PVP_ITEM_LEVEL_STAT_FORMAT, self.avgItemLevel or '0'))
        e.tips:AddDoubleLine(e.addName, WoWTools_PaperDollMixin.addName)
        e.tips:Show()
        self:SetAlpha(0.3)
    end)
end








function WoWTools_PaperDollMixin:Set_Tab1_ItemLevel()
    local pve, pvp=0, 0
    if not Save().hide then
        local _
        pve,_, pvp= GetAverageItemLevel()
    end
    LabelPvE.avgItemLevel= pve
    LabelPvE.avgItemLevelPvp= pvp
    LabelPvE:SetText(pve>0 and format('%i', pve) or '')
    LabelPvP:SetText(pvp>0 and format('%i', pvp) or '')
end

function WoWTools_PaperDollMixin:Init_Tab1_ItemLevel()
    Init()
end