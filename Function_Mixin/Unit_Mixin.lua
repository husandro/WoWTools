local e= select(2, ...)

WoWTools_UnitMixin={}

function WoWTools_UnitMixin:Get_NPC_Name()
    if UnitExists('npc') then
        local name= GetUnitName('npc')
        if name then
            return
                select(5, self:Get_Unit_Color('npc', nil))
                ..e.cn(name, {unit='npc', isName=true})
                ..'|r'
        end
    end
    return ''
end

--职业颜色
function WoWTools_UnitMixin:Get_Unit_Color(unit, guid)
    local r, g, b, hex, classFilename
    if UnitExists(unit) then
        if UnitIsUnit('player', unit) then
            r,g,b,hex= e.Player.r, e.Player.g, e.Player.b, e.Player.col
        else
            classFilename= UnitClassBase(unit)
        end
    elseif guid then
        classFilename = select(2, GetPlayerInfoByGUID(guid))
    end
    if classFilename then
        r, g, b, hex= GetClassColor(classFilename)
        hex= hex and '|c'..hex
    end

    r, g, b, hex =r or 1, g or 1, b or 1, hex or '|cffffffff'

    return {r=r, g=g, b=b, hex=hex},--1
        r,--2
        g,
        b,
        hex--5
end
