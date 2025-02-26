--宠物，信息，提示
local e= select(2, ...)
if e.Player.class~='HUNTER' then
    return
end










--宠物，信息，提示
local function SetTooltip(frame, pet)
    if WoWTools_StableFrameMixin.Save.HideTips then
        return
    end

    e.tips:SetOwner(frame, "ANCHOR_LEFT", -12, 0)
    e.tips:ClearLines()
    local i=1
    for indexType, name in pairs(pet) do
        local col= (select(2, math.modf(i/2))==0 and '|cffffffff') or '|cff00ccff'
        if type(name)=='table' then
            if indexType=='petAbilities' or indexType=='specAbilities' then
                e.tips:AddDoubleLine(
                    col
                    ..(indexType=='petAbilities'
                        and (e.onlyChinese and '基础技能' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BASE_SETTINGS_TAB, ABILITIES))
                        or (e.onlyChinese and '专精技能' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPECIALIZATION, ABILITIES))
                    ),
                    WoWTools_StableFrameMixin:GetAbilitieIconForTab(name, false)
                )
            end

        elseif indexType=='specialization' then
            local atlas = e.dropdownIconForPetSpec[name]
            e.tips:AddDoubleLine(col..(e.onlyChinese and '专精' or SPECIALIZATION), (atlas and '|A:'..atlas..':22:22|a' or '')..col..e.cn(name))

        elseif indexType=='level' then
            e.tips:AddDoubleLine(col..(e.onlyChinese and '等级' or LEVEL), col..name)

        elseif indexType=='name' then
            e.tips:AddDoubleLine(col..(e.onlyChinese and '名字' or NAME), col..e.cn(name))

        elseif indexType=='icon' then
            e.tips:AddDoubleLine(col..(e.onlyChinese and '图标' or EMBLEM_SYMBOL), col..format('|T%d:14|t%d', name, name))

        elseif indexType=='familyName' then
            e.tips:AddDoubleLine(col..(e.onlyChinese and '族系' or STABLE_SORT_TYPE_LABEL), col..e.cn(name))

        elseif indexType=='type' then
            e.tips:AddDoubleLine(col..(e.onlyChinese and '类型' or TYPE), col..e.cn(name))

        elseif indexType=='isFavorite' then
            e.tips:AddDoubleLine(col..(e.onlyChinese and '收藏' or FAVORITES), col..e.GetYesNo(name, true))

        elseif indexType=='isExotic' then
            e.tips:AddDoubleLine(col..(e.onlyChinese and '特殊' or STABLE_EXOTIC_TYPE_LABEL), col..e.GetYesNo(name, true))
        else

            name= (name==false or name==true) and col..e.GetYesNo(name, true)
                or name
            e.tips:AddDoubleLine(col..indexType, col..name)
        end
        i=i+1
    end
    e.tips:AddDoubleLine(
        e.onlyChinese and '食物' or PET_DIET_TEMPLATE,
        table.concat(C_StableInfo.GetStablePetFoodTypes(pet.slotID), LIST_DELIMITER)
    )
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(e.onlyChinese and '拖曳' or DRAG_MODEL, e.Icon.left)

    if e.tips.playerModel and pet.displayID and pet.displayID>0 then
        e.tips.playerModel:SetDisplayInfo(pet.displayID)
        e.tips.playerModel:SetShown(true)
    end
end



function WoWTools_StableFrameMixin:Set_Tooltips(frame, petInfo)
    SetTooltip(frame, petInfo)
end