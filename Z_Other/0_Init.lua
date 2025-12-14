

WoWTools_OtherMixin={
    Save=function()
       return WoWToolsSave['Other'] or {}
    end,
    OpenOption=function()end
}

function WoWTools_OtherMixin:OpenOption(root, name, name2)
    return WoWTools_MenuMixin:OpenOptions(root, {
        category= self.Category,
        layout= self.Layout,
        name= name or self.addName,
        name2= name2
    })
end

function WoWTools_OtherMixin:AddOption(name, addName, tooltip)

    local enabled= not self:Save().disabledADD[name]

    local sub= WoWTools_PanelMixin:OnlyCheck({
        name= addName,
        Value= enabled,
        GetValue=function()
            return not self:Save().disabledADD[name]
        end,
        SetValue= function()
            self:Save().disabledADD[name]= not self:Save().disabledADD[name] and true or nil
        end,
        tooltip= (tooltip and tooltip..'|n|n' or '')..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
        layout= self.Layout,
        category= self.Category,
    })

    return enabled, sub
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWToolsSave['Other']=  WoWToolsSave['Other'] or {disabledADD={}}

--旧数据
    if WoWToolsSave['Other_ClassMenuColor'] and WoWToolsSave['Other_ClassMenuColor'].disabled then
        WoWTools_OtherMixin:Save().disabledADD.ClassMenuColor= true
        WoWToolsSave['Other_ClassMenuColor'].disabled= nil
    end
    if WoWToolsSave['Other_DELETE'] and WoWToolsSave['Other_DELETE'].disabled then
        WoWTools_OtherMixin:Save().disabledADD.DELETE= true
        WoWToolsSave['Other_DELETE'].disabled= nil
    end
    if WoWToolsSave['Other_MoneyFrame'] and WoWToolsSave['Other_MoneyFrame'].disabled then
        WoWTools_OtherMixin:Save().disabledADD.MoneyFrame= true
        WoWToolsSave['Other_MoneyFrame'].disabled= nil
    end


    WoWTools_OtherMixin.addName= '|A:QuestNormal:0:0|a'..(WoWTools_DataMixin.onlyChinese and '其它' or OTHER)

    WoWTools_OtherMixin.Category, WoWTools_OtherMixin.Layout= WoWTools_PanelMixin:AddSubCategory({
        name= WoWTools_OtherMixin.addName
    })


    self:SetScript('OnEvent', nil)
    self:UnregisterEvent(event)
end)