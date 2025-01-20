local id, e= ...
if e.Player.class~='HUNTER' then --or C_AddOns.IsAddOnLoaded("ImprovedStableFrame") then
    return
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




