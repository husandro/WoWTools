--[[
Get
OnEnter
]]

local e= select(2, ...)
WoWTools_DurabiliyMixin={}









--耐久度
local function get_durabiliy_color(cur, max)
    if not cur or not max or max<=0 or cur>max then
        return '', 100, ''
    end
    local value= cur/max*100
    local text= format('%i%%', value)
    local icon
    if value<=0 then
        text= '|cff9e9e9e'..text..'|r'
        icon= '|A:Warfronts-BaseMapIcons-Empty-Armory-Minimap:0:0|a'
    elseif value<30 then
        text= '|cnRED_FONT_COLOR:'..text..'|r'
        icon= '|A:Warfronts-BaseMapIcons-Horde-Heroes-Minimap:0:0|a'
    elseif value<60 then
        text= '|cnYELLOW_FONT_COLOR:'..text..'|r'
        icon= '|A:Warfronts-BaseMapIcons-Horde-ConstructionHeroes-Minimap:0:0|a'
    elseif value<90 then
        text= '|cnGREEN_FONT_COLOR:'..text..'|r'
        icon= '|A:Warfronts-BaseMapIcons-Alliance-ConstructionHeroes-Minimap:0:0|a'
    else
        text= '|cffff7f00'..text..'|r'
        icon= '|A:Warfronts-BaseMapIcons-Alliance-Armory-Minimap:0:0|a'
    end
    return text, value, icon
end












function WoWTools_DurabiliyMixin:Get(reTexture)--耐久度
    local cur, max= 0, 0
    for i= 1, 18 do
        local cur2, max2 = GetInventoryItemDurability(i)
        if cur2 and max2 and max2>0 then
            cur= cur +cur2
            max= max +max2
        end
    end
    local text, value, icon= get_durabiliy_color(cur, max)
    if reTexture then
        text= icon..text
    end
    return text, value
end












--耐久度, 提示
function WoWTools_DurabiliyMixin:OnEnter()
    local tabSlot={
        {1, 10},
        {2, 6},
        {3, 7},
        {15, 8},
        {5, 11},
        {4, 12},
        {19, 13},
        {9, 14},
        {16, 17},
    }

    local num, cur2, max2= 0, 0, 0
    local isRepair, cur, max, text, _, icon, a, b


    for index, tab in pairs(tabSlot) do

        a = GetInventoryItemTexture('player', tab[1])
        a = a and '|T'..a..':0|t'
        b = GetInventoryItemTexture('player', tab[2])
        b = b and '|T'..b..':0|t'

        if not a or tab[1]==4 or tab[1]==19 then
            a=  WoWTools_ItemMixin:GetEquipSlotIcon(tab[1])
        elseif a then
            cur, max = GetInventoryItemDurability(tab[1])
            if cur and max and max>0 then
                isRepair= cur<max
                text, _, icon= get_durabiliy_color(cur, max)
                a= a..icon..text..' '..max..'/'..(isRepair and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:')..cur..'|r'
                if isRepair then
                    num= num+1
                    a=a..'|A:SpellIcon-256x256-Repair:0:0|a'
                end
                cur2= cur2+cur
                max2= max2+max
            end
        end
        if b then
            cur, max = GetInventoryItemDurability(tab[2])
            if cur and max and max>0 then
                isRepair= cur<max
                text, _, icon= get_durabiliy_color(cur, max)
                b= (isRepair and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:')..cur..'|r/'..max..' '..text..icon..b
                if isRepair then
                    num= num+1
                    b='|A:SpellIcon-256x256-Repair:0:0|a'..b
                end
                cur2= cur2+cur
                max2= max2+max
            end
        end
        b= b or  WoWTools_ItemMixin:GetEquipSlotIcon(tab[2])
        local s= index==9 and '    ' or ''
        GameTooltip:AddDoubleLine(s..(a or ' '), b..s)
    end

    local euip=''--装备管理
    for _, setID in pairs(C_EquipmentSet.GetEquipmentSetIDs() or {}) do
        local name, texture, _, isEquipped= C_EquipmentSet.GetEquipmentSetInfo(setID)
        if isEquipped and name then
            euip= ' |cffff00ff'..name..'|r'..(texture and '|T'..texture..':0|t' or '')
            break
        end
    end

    local co = GetRepairAllCost()--显示，修理所有，金钱
    local coText=''
    if co and co>0 then
        coText= ' |cnRED_FONT_COLOR:'..GetMoneyString(co)..'|r'
    end

    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(
        (e.onlyChinese and '耐久度' or DURABILITY)..' ('..(max2>0 and math.modf(cur2/max2*100) or 100)..'%)'..coText,
         '('..(num>0 and '|cnRED_FONT_COLOR:' or '|cff9e9e9e')..num..'|r) '..(e.onlyChinese and '修理物品' or REPAIR_ITEMS)..euip
    )

    local item, cur3, pvp= GetAverageItemLevel()
    cur3= cur3 or 0
    item= item or 0
    pvp= pvp or 0
    GameTooltip:AddDoubleLine(
        (e.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL)
        ..(e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')
        ..(cur3==item and format(' |cnGREEN_FONT_COLOR:%.2f|r', cur3) or format(' |cnRED_FONT_COLOR:%.2f|r/%.2f', cur3, item)),
        format('%.02f', pvp)..' PvP|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a')
end



