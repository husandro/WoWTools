
local function Save()
    return WoWToolsSave['Tools_Hearthstone']
end










--#####
--主菜单
--#####
local function Init_Menu(self, root)
    local sub, sub2, name
    WoWTools_HearthstoneMixin:Init_Menu_Toy(self, root)

--选项
    root:CreateDivider()
    sub=WoWTools_ToolsMixin:OpenMenu(root, WoWTools_HearthstoneMixin.addName)

    sub2=sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '绑定位置' or SPELL_TARGET_CENTER_LOC, function()
        return Save().showBindName
    end, function()
        Save().showBindName= not Save().showBindName and true or nil
        self:set_location()--显示, 炉石, 绑定位置
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(self:get_location())
    end)

    sub2:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '截取名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHORT, NAME), function()
        return Save().showBindNameShort
    end, function()
        Save().showBindNameShort= not Save().showBindNameShort and true or nil
        self:set_location()--显示, 炉石, 绑定位置
    end)

--移除未收集
    sub:CreateDivider()
    name= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '移除未收集' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REMOVE, NOT_COLLECTED))
    sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            local n=0
            for itemID in pairs(Save().items) do
                if not PlayerHasToy(itemID) then
                    Save().items[itemID]=nil
                    n=n+1
                    print(n, WoWTools_DataMixin.onlyChinese and '移除' or REMOVE, WoWTools_ItemMixin:GetLink(itemID))
                end
            end
            if n>0 then
                self:Init_Random(Save().lockedToy)
            end
        end})
        return MenuResponse.Open
    end, {name=name})
    

--全部清除
    name= '|A:common-icon-redx:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
    sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            Save().items={}
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_HearthstoneMixin.addName, WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
            self:Rest_Random()
        end})
        return MenuResponse.Open
    end, {name=name})



--还原
    local all= 0
    for _ in pairs(WoWTools_HearthstoneMixin:Get_P_Items()) do
        all=all+1
    end
    name= '|A:common-icon-undo:0:0|a'..(WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)..' '..all
    sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            Save().items= WoWTools_HearthstoneMixin:Get_P_Items()
            self:Rest_Random()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_HearthstoneMixin.addName, '|cnGREEN_FONT_COLOR:', WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)
        end})
        return MenuResponse.Open
    end, {name=name})


--设置
    sub:CreateDivider()
    sub2=sub:CreateButton(
        '|A:common-icon-zoomin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS),
    function()
        WoWTools_LoadUIMixin:Journal(3)
        return MenuResponse.Open
    end
    )
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText(WoWTools_DataMixin.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
    end)
end












function WoWTools_HearthstoneMixin:Setup_Menu()
    MenuUtil.CreateContextMenu(self.ToyButton, function(...) Init_Menu(...) end)
end