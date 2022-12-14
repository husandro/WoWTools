local id, e = ...
--local addName= ADVENTURE_MAP_TITLE..TOY

local panel=e.Cbtn2(nil, WoWToolsMountButton, true)
panel:SetAttribute("type", "item")
panel:SetPoint('RIGHT', WoWToolsOpenItemsButton, 'LEFT')

local Toy={
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

for itemID, _ in pairs(Toy) do
    e.LoadSpellItemData(itemID)--加载法术, 物品数据
end

local function Get_Use_Toy()
    if UnitAffectingCombat('player') then
        panel.bat=true
        return
    end

    panel.itemID=nil
    for itemID, tab in pairs(Toy) do
        for _, achievementID  in pairs(tab) do
            if not select(13,GetAchievementInfo(achievementID)) then
                panel.itemID=itemID

                panel.bat=nil

                panel.texture:SetTexture(C_Item.GetItemIconByID(itemID))
                panel:SetAttribute("item", C_Item.GetItemNameByID(itemID) or itemID)
                panel:SetShown(true)

                return
            end
        end
        Toy[itemID]=nil
    end

    panel:SetShown(false)
    panel:UnregisterAllEvents()
end


--####
--初始
--####
local function Init()
    panel:SetScript('OnEnter', function(self)
        if self.itemID then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:SetToyByItemID(self.itemID)
            e.tips:Show()
        end
    end)
    panel:SetScript('OnLeave', function() e.tips:Hide() end)

    for itemID, _ in pairs(Toy) do
        if not(PlayerHasToy(itemID) and C_ToyBox.IsToyUsable(itemID)) then
            Toy[itemID]=nil
        end
    end

    Get_Use_Toy()
end

--###########
--加载保存数据
--###########2
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent("PLAYER_REGEN_ENABLED")
panel:RegisterEvent('PLAYER_REGEN_DISABLED')
panel:RegisterEvent('UI_ERROR_MESSAGE')
panel:RegisterEvent('RECEIVED_ACHIEVEMENT_LIST')
panel:RegisterEvent('CRITERIA_UPDATE')

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

                    ToggleAchievementFrame()
                    ToggleAchievementFrame()
            else
                panel:UnregisterAllEvents()
            end
        elseif arg1=='Blizzard_AchievementUI' then
            C_Timer.After(2, Init)--初始
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.bat or panel.itemID then
            Get_Use_Toy()
        end
    elseif event=='PLAYER_REGEN_DISABLED' then
        panel:SetShown(false)

    elseif event=='UI_ERROR_MESSAGE' and arg1==56 and arg2==SPELL_FAILED_CUSTOM_ERROR_616 then
        if panel.itemID then
            Toy[panel.itemID]=nil
            Get_Use_Toy()
        end
    elseif event=='RECEIVED_ACHIEVEMENT_LIST' then
        if panel.itemID then
            Get_Use_Toy()
        end
    end
end)