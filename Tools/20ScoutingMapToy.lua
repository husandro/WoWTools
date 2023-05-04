local id, e = ...
--local addName= ADVENTURE_MAP_TITLE..TOY
local panel= CreateFrame("Frame")

local ToyTab={
    [187869]={14663, 14303, 14304, 14305, 14306},--暗影界
    [187875]={10665,10666, 10667, 10668, 10669, 11543},--破碎群岛
    [187895]={8938, 8939, 8940, 8941, 8937, 8942, 10260},--德拉诺
    [187896]={6977, 6975, 6976, 6979, 6351, 6978, 6969},--潘达利亚旅行指南]
    [187897]={4864, 4863, 4866, 4865, 4825},--大灾变
    [187898]={1267, 1264, 1268, 1269, 1265, 1266, 1263, 1457, 1270},--诺森德
    [187899]={865, 862, 866, 843, 864, 867, 863},--外域
    [187900]={12558, 12556, 13776, 12557, 12559, 13712, 12560, 12561},--库尔提拉斯和赞达拉
    --LM
    [150743]={736, 842, 750, 851, 857, 855, 853, 856, 850, 845, 848, 852, 854, 847, 728, 849, 844, 4996, 846, 861, 860},--卡利姆多
    [150746]={858, 859, 627, 776, 775, 768, 765, 802, 782, 766, 772, 777, 779, 770, 774, 780, 769, 773, 778, 841, 4995, 761, 771, 781, 868},--东部王国
    --BL
    [150744]={736, 842, 750, 851, 857, 855, 853, 856, 850, 845, 848, 852, 854, 847, 728, 849, 844, 4996, 846, 861, 860},--卡利姆多
    [150745]={858, 859, 627, 776, 775, 768, 765, 802, 782, 766, 772, 777, 779, 770, 774, 780, 769, 773, 778, 841, 4995, 761, 771, 781, 868},--东部王国
}

for itemID, _ in pairs(ToyTab) do
    e.LoadDate({id=itemID, type='item'})
end


local function Get_Use_Toy()
    local bat= UnitAffectingCombat('player')
    if bat or e.Player.faction=='Neutral' then
        if not bat and panel.btn then
            panel.btn:SetShown(false)
        end
        return
    end

    local notFindName
    for itemID, tab in pairs(ToyTab) do
        if PlayerHasToy(itemID) and C_ToyBox.IsToyUsable(itemID) then
            for _, achievementID  in pairs(tab) do
                local _, name, _, _, _, _, _, _, _, _, _, _, wasEarnedByMe=GetAchievementInfo(achievementID)
                if name and not wasEarnedByMe then
                    if not panel.btn then
                        panel.btn=e.Cbtn2(nil, WoWToolsMountButton, true)
                        panel.btn:SetAttribute("type*", "item")
                        panel.btn:SetPoint('BOTTOM', WoWToolsOpenItemsButton, 'TOP')--自定义位置
                        panel.btn:SetScript('OnLeave', function() e.tips:Hide() end)
                        panel.btn:SetScript('OnEnter', function(self2)
                            if self2.itemID then
                                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                                e.tips:ClearLines()
                                e.tips:SetToyByItemID(self2.itemID)
                                e.tips:AddLine(' ')
                                if e.onlyChinese then
                                    e.tips:AddLine('|cnRED_FONT_COLOR:使用, 请勿太快')
                                else
                                    e.tips:AddLine('|cnRED_FONT_COLOR:note: '..ERR_GENERIC_THROTTLE)
                                end
                                e.tips:Show()
                            end
                        end)
                    end
                    local itemName, _, _, _, _, _, _, _, _, itemTexture= GetItemInfo(itemID)
                    itemName=itemName or  C_Item.GetItemNameByID(itemID) or itemID
                    itemTexture= itemTexture or C_Item.GetItemIconByID(itemID) or 0
                    panel.btn:SetAttribute("item*", itemName)
                    panel.btn.texture:SetTexture(itemTexture)
                    panel.btn:SetShown(true)
                    panel.btn.itemID=itemID
                    return

                elseif not name then
                    notFindName=true
                end
            end
        end
    end

    if panel.btn then
        panel.btn:SetShown(false)
    end
    if not notFindName then
        panel:UnregisterAllEvents()
        Toy=nil
    end
end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1== id then
            if not e.toolsFrame.disabled then
                if not IsAddOnLoaded('Blizzard_AchievementUI') then
                    LoadAddOn("Blizzard_AchievementUI")
                end
                if not IsAddOnLoaded('Blizzard_ToyBox') then
                    LoadAddOn("Blizzard_ToyBox")
                end

                C_Timer.After(2, function()
                    ToggleAchievementFrame()
                    if AchievementFrame and AchievementFrame:IsVisible() then
                        ToggleAchievementFrame()
                    end
                end)

                C_Timer.After(4, function()
                    panel:RegisterEvent('PLAYER_REGEN_DISABLED')
                    panel:RegisterEvent("PLAYER_REGEN_ENABLED")
                    panel:RegisterEvent('UI_ERROR_MESSAGE')
                    panel:RegisterEvent('CRITERIA_UPDATE')
                    panel:RegisterEvent('RECEIVED_ACHIEVEMENT_LIST')
                    Get_Use_Toy()
                end)
            else
                Toy=nil
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event=='PLAYER_REGEN_DISABLED' then
        if panel.btn then
            panel.btn:SetShown(false)
        end

    else
        C_Timer.After(1, function() Get_Use_Toy() end)
    end
end)