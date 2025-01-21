local id, e= ...

if e.Player.class~='HUNTER' then --or C_AddOns.IsAddOnLoaded("ImprovedStableFrame") then
    e.dropdownIconForPetSpec={}
    return
else
    e.dropdownIconForPetSpec = {
        [STABLE_PET_SPEC_CUNNING] = "cunning-icon-small",
        [STABLE_PET_SPEC_FEROCITY] = "ferocity-icon-small",
        [STABLE_PET_SPEC_TENACITY] = "tenacity-icon-small",
    }
end


WoWTools_StableFrameMixin={
    Save={
        --hideIndex=true,--隐藏索引
        --hideTalent=true,--隐藏天赋
       -- modelScale=0.65,

        --line=15,

        --10.2.7
        --show_All_List=true,显示，所有宠物，图标列表
        --sortDown= true,--排序, 降序
        --all_List_Size==28--图标表表，图标大小
        --showTexture=true,--显示，材质
        sortType='specialization',
        all_List_Size=28
    }
}


local function Init()
    WoWTools_StableFrameMixin:Init_Menu()
    WoWTools_StableFrameMixin:Set_StableFrame_List()
    WoWTools_StableFrameMixin:Init_StableFrame_Plus()
    WoWTools_StableFrameMixin:Init_UI()
end





local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_StableFrameMixin.Save= WoWToolsSave['Other_HunterPet'] or WoWTools_StableFrameMixin.Save

            WoWTools_StableFrameMixin.addName= '|A:groupfinder-icon-class-hunter:0:0|a'..(e.onlyChinese and '猎人兽栏' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UnitClass('player'), STABLE_STABLED_PET_LIST_LABEL))


            --添加控制面板
             e.AddPanel_Check({
                name= WoWTools_StableFrameMixin.addName,
                tooltip= nil,
                Value= not WoWTools_StableFrameMixin.Save.disabled,
                GetValue=function() return not WoWTools_StableFrameMixin.Save.disabled end,
                SetValue= function()
                    WoWTools_StableFrameMixin.Save.disabled = not WoWTools_StableFrameMixin.Save.disabled and true or nil
                    print(e.addName, WoWTools_StableFrameMixin.addName, e.GetEnabeleDisable(not WoWTools_StableFrameMixin.Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if not WoWTools_StableFrameMixin.Save.disabled then
               Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Other_HunterPet']= WoWTools_StableFrameMixin.Save
        end
    end

end)