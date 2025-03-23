--宠物，信息，提示

if WoWTools_DataMixin.Player.Class~='HUNTER' then
    return
end










--宠物，信息，提示
local function SetTooltip(frame, pet)
    if WoWTools_StableFrameMixin.Save.HideTips then
        return
    end

    GameTooltip:SetOwner(frame, "ANCHOR_LEFT", -12, 0)
    GameTooltip:ClearLines()
    local i=1
    for indexType, name in pairs(pet) do
        local col= (select(2, math.modf(i/2))==0 and '|cffffffff') or '|cff00ccff'
        if type(name)=='table' then
            if indexType=='petAbilities' or indexType=='specAbilities' then
                GameTooltip:AddDoubleLine(
                    col
                    ..(indexType=='petAbilities'
                        and (WoWTools_Mixin.onlyChinese and '基础技能' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BASE_SETTINGS_TAB, ABILITIES))
                        or (WoWTools_Mixin.onlyChinese and '专精技能' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPECIALIZATION, ABILITIES))
                    ),
                    WoWTools_StableFrameMixin:GetAbilitieIconForTab(name, false)
                )
            end

        elseif indexType=='specialization' then
            local atlas = WoWTools_DataMixin.Icon[name]
            GameTooltip:AddDoubleLine(col..(WoWTools_Mixin.onlyChinese and '专精' or SPECIALIZATION), (atlas and '|A:'..atlas..':22:22|a' or '')..col..WoWTools_TextMixin:CN(name))

        elseif indexType=='level' then
            GameTooltip:AddDoubleLine(col..(WoWTools_Mixin.onlyChinese and '等级' or LEVEL), col..name)

        elseif indexType=='name' then
            GameTooltip:AddDoubleLine(col..(WoWTools_Mixin.onlyChinese and '名字' or NAME), col..WoWTools_TextMixin:CN(name))

        elseif indexType=='icon' then
            GameTooltip:AddDoubleLine(col..(WoWTools_Mixin.onlyChinese and '图标' or EMBLEM_SYMBOL), col..format('|T%d:14|t%d', name, name))

        elseif indexType=='familyName' then
            GameTooltip:AddDoubleLine(col..(WoWTools_Mixin.onlyChinese and '族系' or STABLE_SORT_TYPE_LABEL), col..WoWTools_TextMixin:CN(name))

        elseif indexType=='type' then
            GameTooltip:AddDoubleLine(col..(WoWTools_Mixin.onlyChinese and '类型' or TYPE), col..WoWTools_TextMixin:CN(name))

        elseif indexType=='isFavorite' then
            GameTooltip:AddDoubleLine(col..(WoWTools_Mixin.onlyChinese and '收藏' or FAVORITES), col..WoWTools_TextMixin:GetYesNo(name, true))

        elseif indexType=='isExotic' then
            GameTooltip:AddDoubleLine(col..(WoWTools_Mixin.onlyChinese and '特殊' or STABLE_EXOTIC_TYPE_LABEL), col..WoWTools_TextMixin:GetYesNo(name, true))
        else

            name= (name==false or name==true) and col..WoWTools_TextMixin:GetYesNo(name, true)
                or name
            GameTooltip:AddDoubleLine(col..indexType, col..name)
        end
        i=i+1
    end
    GameTooltip:AddDoubleLine(
        WoWTools_Mixin.onlyChinese and '食物' or PET_DIET_TEMPLATE,
        table.concat(C_StableInfo.GetStablePetFoodTypes(pet.slotID), LIST_DELIMITER)
    )
    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '拖曳' or DRAG_MODEL, WoWTools_DataMixin.Icon.left)

    if GameTooltip.playerModel and pet.displayID and pet.displayID>0 then
        GameTooltip.playerModel:SetDisplayInfo(pet.displayID)
        GameTooltip.playerModel:SetShown(true)
    end
end



function WoWTools_StableFrameMixin:Set_Tooltips(frame, petInfo)
    SetTooltip(frame, petInfo)
end