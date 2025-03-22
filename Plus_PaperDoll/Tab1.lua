--总装等
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end
local LabelPvE, LabelPvP









local function Init()

--物品等级
    LabelPvE=WoWTools_LabelMixin:Create(PaperDollSidebarTab1, {justifyH='CENTER', mouse=true})
    LabelPvE:SetPoint('BOTTOM')
    LabelPvE:EnableMouse(true)
    LabelPvE:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
    LabelPvE:SetScript('OnMouseDown', function()
        WoWTools_Mixin:Call(PaperDollFrame_SetSidebar, PaperDollSidebarTab1, 1)--PaperDollFrame.lua
    end)
    LabelPvE:SetScript('OnEnter', function(self)
        if not self.avgItemLevel then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip)
        GameTooltip:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine('|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '物品等级：%d' or CHARACTER_LINK_ITEM_LEVEL_TOOLTIP, self.avgItemLevel or ''))
        --GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_PaperDollMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(0)
    end)


--PvP物品等级
    LabelPvP=WoWTools_LabelMixin:Create(PaperDollSidebarTab1, {justifyH='CENTER', mouse=true})
    LabelPvP:SetPoint('TOP')
    LabelPvP:SetScript('OnMouseDown', function(self)
        WoWTools_Mixin:Call(PaperDollFrame_SetSidebar, PaperDollSidebarTab1, 1)
    end)
    LabelPvP:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
    LabelPvP:SetScript('OnEnter', function(self)
        if not self.avgItemLevelPvp then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip)
        GameTooltip:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine('|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and 'PvP物品等级 %d' or ITEM_UPGRADE_PVP_ITEM_LEVEL_STAT_FORMAT, self.avgItemLevel or '0'))
        --GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_PaperDollMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(0)
    end)
end








function WoWTools_PaperDollMixin:Init_Tab1()
    Init()
end

function WoWTools_PaperDollMixin:Settings_Tab1()
    local show= not Save().hide
    local pve, pvp, cur

    if show then
        local _
        pve, cur, pvp= GetAverageItemLevel()
        if pvp==0 or pvp==pve then
            pvp=nil
        else
            pvp= format('%i', pvp)
        end
        pve= format('%i', pve)
        if pve==0 or cur-pve<=-5 then
             pve= '|cnRED_FONT_COLOR:'..pve..'|r'
        end
    end

    LabelPvE.avgItemLevel= pve
    LabelPvE.avgItemLevelPvp= pvp

    LabelPvE:SetText(pve or '')
    LabelPvP:SetText(pvp or '')
end