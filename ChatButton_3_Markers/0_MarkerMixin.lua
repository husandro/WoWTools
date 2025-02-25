WoWTools_MarkerMixin={}


function WoWTools_MarkerMixin:Set_Taget(unit, index)--设置,目标,标记
    if index and CanBeRaidTarget(unit) then
        local marker= GetRaidTargetIndex(unit)
        if marker==index or (not marker and index==0) then
            return
        end
        SetRaidTarget(unit, index)
    end
end

local Color={
    [1]={r=1, g=1, b=0, col='|cffffff00'},--星星, 黄色
    [2]={r=1, g=0.45, b=0.04, col='|cffff7f3f'},--圆形, 橙色
    [3]={r=1, g=0, b=1, col='|cffa335ee'},--菱形, 紫色
    [4]={r=0, g=1, b=0, col='|cff1eff00'},--三角, 绿色
    [5]={r=0.6, g=0.6, b=0.6, col='|cffffffff'},--月亮, 白色
    [6]={r=0.1, g=0.2, b=1, col='|cff0070dd'},--方块, 蓝色
    [7]={r=1, g=0, b=0, col='|cffff2020'},--十字, 红色
    [8]={r=1, g=1, b=1, col='|cffffffff'},--骷髅,白色
}
function WoWTools_MarkerMixin:SetColor(index)
    return Color[index]
end
