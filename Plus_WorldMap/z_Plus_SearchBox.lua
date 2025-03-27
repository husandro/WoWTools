






local function Init()
    --C_CVar.GetCVarBool('displayQuestID')
    QuestScrollFrame.SearchBox:SetWidth(301- 20*2)

    local btnCollapse= WoWTools_ButtonMixin:Cbtn(QuestScrollFrame.SearchBox, {size=22, atlas='NPE_ArrowUp'})--campaign_headericon_closed
    btnCollapse:SetPoint('LEFT', QuestScrollFrame.SearchBox, 'RIGHT')
    btnCollapse:SetScript('OnLeave', GameTooltip_Hide)
    btnCollapse:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(not WoWTools_DataMixin.onlyChinese and HUD_EDIT_MODE_COLLAPSE_OPTIONS or "收起选项 |A:editmode-up-arrow:16:11:0:3|a")
        GameTooltip:AddLine(WoWTools_WorldMapMixin.addName)
        GameTooltip:Show()
    end)
    btnCollapse:SetScript("OnMouseDown", function()
        for i=1, C_QuestLog.GetNumQuestLogEntries() do
            CollapseQuestHeader(i)
        end
    end)

    local btnExpand= WoWTools_ButtonMixin:Cbtn(QuestScrollFrame.SearchBox, {size=20, atlas='NPE_ArrowDown'})
    btnExpand:SetPoint('LEFT', btnCollapse, 'RIGHT')
    btnExpand:SetScript('OnLeave', GameTooltip_Hide)
    btnExpand:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(not WoWTools_DataMixin.onlyChinese and HUD_EDIT_MODE_EXPAND_OPTIONS or "展开选项 |A:editmode-down-arrow:16:11:0:-7|a")
        GameTooltip:AddLine(WoWTools_WorldMapMixin.addName)
        GameTooltip:Show()
    end)
    btnExpand:SetScript("OnMouseDown", function()
        for i=1, C_QuestLog.GetNumQuestLogEntries() do
            ExpandQuestHeader(i)
        end
    end)
end




function WoWTools_WorldMapMixin:Init_Plus_SearchBox()
    Init()
end