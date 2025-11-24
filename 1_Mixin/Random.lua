WoWTools_RandomMixin={
    Random_List={},--存放数据列表 {数据1, 数据2, 数据3, ...}
    isOneValue_Random=false,-- 当数据 <=1 
    Random_Numeri=0,--数据，数量

    Locked_Value=nil,--or value, 锁定值

    is_Check_Combat_Random=true,-- 是否要检查 frame:CanChangeAttribute()，如果不是安全按钮，可以设置 false
    is_Random_Eevent=false,--当 is_Check_Combat_Random 和 not frame:CanChangeAttribute() 注册事件 PLAYER_REGEN_ENABLED
}

function WoWTools_RandomMixin:Get_Random_Data()--取得数据库, {数据1, 数据2, 数据3, ...}
    return {}
end
function WoWTools_RandomMixin:Check_Random()--当真时Check_Random() 或 isOneValue_Random 真时 退出取得，随机值
end
function WoWTools_RandomMixin:Set_Random_Value()--设置，随机值
end
function WoWTools_RandomMixin:Set_OnlyOneValue_Random()--当数据 <=1 时，设置值
end

function WoWTools_RandomMixin:Get_Random_List()--得到，数据列表
    if self.Locked_Value or self.Selected_Value or self:Check_Random() then
        self:Set_OnlyOneValue_Random()
    else
        self.Random_List= self:Get_Random_Data() or {}
        self.Random_Numeri= #self.Random_List
        self.isOneValue_Random= self.Random_Numeri<=1
        if self.isOneValue_Random then
            self:Set_OnlyOneValue_Random()
        end
    end
end

function WoWTools_RandomMixin:Get_Random_Value()
    if self.Locked_Value or self.Selected_Value or self:Check_Random() then
        return
    end

    self.is_Random_Eevent= nil
    if self.is_Check_Combat_Random and not self:CanChangeAttribute() then
        self.is_Random_Eevent= true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end

    if not self.isOneValue_Random and self.Random_Numeri>0 then
        local index= math.random(1, self.Random_Numeri)
        local value= self.Random_List[index]
        self:Set_Random_Value(value)
        table.remove(self.Random_List, index)
        self.Random_Numeri= self.Random_Numeri-1
        if self.Random_Numeri==0 then
            self:Get_Random_List()
        end
        if self.set_tooltip and self:IsMouseOver() then
            self:set_tooltip()
        end
    end
end

function WoWTools_RandomMixin:Set_SelectValue_Random(value)--is_Random_Eevent
    self.Selected_Value= value
    self:Init_Random(self.Locked_Value)
end

function WoWTools_RandomMixin:Set_LockedValue_Random(value)--设置，锁定
    self.Locked_Value= value
    self:Init_Random(value)
end

function WoWTools_RandomMixin:Set_Random_Event()--is_Random_Eevent
    if self.isOneValue_Random then
        self:Set_OnlyOneValue_Random()
    else
        self:Get_Random_Value()
    end
end

function WoWTools_RandomMixin:Check_Random_Value(value)
    return self.Selected_Value==value, self.Locked_Value==value, self:Check_Random()==value
end

function WoWTools_RandomMixin:Rest_Random()
    self.Selected_Value=nil
    self.Locked_Value=nil
    self:Init_Random()
end

function WoWTools_RandomMixin:Init_Random(lockValue)
    self.Locked_Value= lockValue
    do
        self:Get_Random_List()
    end
    self:Get_Random_Value()
end





