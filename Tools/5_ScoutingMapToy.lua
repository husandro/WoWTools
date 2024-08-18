local id, e = ...
--local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADVENTURE_MAP_TITLE, TOY)
local panel= CreateFrame("Frame")
local button

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

function panel:Requested_Achievement()
    for itemID, achievementIDs in pairs(ToyTab) do
        e.LoadDate({id=itemID, type='item'})
        for _, achievementID in pairs(achievementIDs) do
            GetAchievementCategory(achievementID)
        end
    end
end



function panel:get_Use_Toy()
    local bat= UnitAffectingCombat('player')
    if bat or e.Player.faction=='Neutral' then
        if not bat and button then
            button:SetShown(false)
        end
        return
    end
    panel:Requested_Achievement()

    local notFindName
    for itemID, tab in pairs(ToyTab) do
        if PlayerHasToy(itemID) and C_ToyBox.IsToyUsable(itemID) then
            for _, achievementID  in pairs(tab) do
                local _, name, _, _, _, _, _, _, _, _, _, _, wasEarnedByMe= GetAchievementInfo(achievementID)
                if name and not wasEarnedByMe then
                    if not button then

                        button= e.Cbtn2({
                            name=nil,
                            parent=_G['WoWToolsMountButton'],
                            click=true,-- right left
                            notSecureActionButton=nil,
                            notTexture=nil,
                            showTexture=true,
                            sizi=nil,
                        })

                        button:SetAttribute("type*", "item")
                        button:SetPoint('BOTTOM', _G['WoWToolsOpenItemsButton'], 'TOP')--自定义位置
                        button:SetScript('OnLeave', GameTooltip_Hide)
                        button:SetScript('OnEnter', function(self2)
                            if self2.itemID then
                                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                                e.tips:ClearLines()
                                e.tips:SetItemByID(self2.itemID)
                                --e.tips:SetToyByItemID(self2.itemID)
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
                    local itemName, _, _, _, _, _, _, _, _, itemTexture= C_Item.GetItemInfo(itemID)
                    itemName=itemName or  C_Item.GetItemNameByID(itemID) or itemID
                    itemTexture= itemTexture or C_Item.GetItemIconByID(itemID) or 0
                    button:SetAttribute("item*", itemName)
                    button.texture:SetTexture(itemTexture)
                    button:SetShown(true)
                    button.itemID=itemID
                    return

                elseif not name then
                    notFindName=true
                end
            end
        end
    end

    if button then
        button:SetShown(false)
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
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            
            if not e.toolsFrame.disabled then
                if not AchievementFrame then
                    AchievementFrame_LoadUI();
                end
                if not CollectionsJournal then
                    CollectionsJournal_LoadUI()
                end
                --[[if not C_AddOns.IsAddOnLoaded('Blizzard_AchievementUI') then
                    C_AddOns.LoadAddOn("Blizzard_AchievementUI")
                end
                if not C_AddOns.IsAddOnLoaded('Blizzard_ToyBox') then
                    C_AddOns.LoadAddOn("Blizzard_ToyBox")
                end]]

                C_Timer.After(2, function()
                    ToggleAchievementFrame()
                    if AchievementFrame and AchievementFrame:IsVisible() then
                        ToggleAchievementFrame()
                    end
                end)

                panel:RegisterEvent('PLAYER_REGEN_DISABLED')
                panel:RegisterEvent("PLAYER_REGEN_ENABLED")
                panel:RegisterEvent('UI_ERROR_MESSAGE')
                panel:RegisterEvent('CRITERIA_UPDATE')
                panel:RegisterEvent('RECEIVED_ACHIEVEMENT_LIST')

                C_Timer.After(4, self.get_Use_Toy)
            else
                Toy=nil
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event=='PLAYER_REGEN_DISABLED' then
        if button then
            button:SetShown(false)
        end

    else
        C_Timer.After(2, self.get_Use_Toy)
    end
end)