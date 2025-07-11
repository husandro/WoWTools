

local function Save()
    return  WoWToolsSave['Tools_UseItems']
end








local function Init_Menu(_, root)
    local sub, sub2, num
    for text, type in pairs({
        [WoWTools_DataMixin.onlyChinese and '物品' or ITEMS]='item',
        [WoWTools_DataMixin.onlyChinese and '法术' or SPELLS]='spell',
        [WoWTools_DataMixin.onlyChinese and '装备' or EQUIPSET_EQUIP]='equip'
    }) do
        num= #Save()[type]
        sub=root:CreateButton(
            text
            ..(num==0 and ' |cff9e9e9e' or ' |cnGREEN_FONT_COLOR:')
            ..num,
        function(data)
            if data.type=='item' then
                WoWTools_LoadUIMixin:Journal(3)--加载，收藏，UI
            elseif data.type=='spell' then
                PlayerSpellsUtil.OpenToSpellBookTab()
            else
                WoWTools_LoadUIMixin:PaperDoll_Sidebar(1)--打开/关闭角色界面
            end
            return MenuResponse.Open
        end, {type=type})


        for index, ID in pairs(Save()[type]) do
            local name= (type=='item' or type=='equip')
                and WoWTools_ItemMixin:GetName(ID)
                or WoWTools_SpellMixin:GetName(ID)
                or ID

            local isToy, spellID, itemID
            if type=='item' then
                isToy= C_ToyBox.GetToyInfo(ID)
                itemID=ID

            elseif type=='equip' then
                itemID=ID

            else
                spellID=ID
            end

            sub2=sub:CreateButton(name, function(data)
--玩具箱
                if data.isToy then
                    WoWTools_LoadUIMixin:Journal(3, {toyItemID=data.itemID})
--已学，法术
                elseif data.spellID and IsSpellKnownOrOverridesKnown(data.spellID) then
                    WoWTools_LoadUIMixin:SpellBook(3, data.spellID)
--其他
                else
                    StaticPopup_Show('WoWTools_OK',
                        (WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|n|n'..data.name..'|n',
                        nil,
                        {SetValue=function()
                            table.remove(Save()[data.type], data.index)
                        end}
                    )
                end
                return MenuResponse.Open
            end, {index=index, type=type, isToy=isToy, spellID=spellID, itemID=itemID, name=name})
--tooltip
            WoWTools_SetTooltipMixin:Set_Menu(sub2)
        end

        if num>0 then
            sub:CreateDivider()
        end

        if num>1 then
--全部清除
            WoWTools_MenuMixin:ClearAll(sub, function()
                Save()[type]={}
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_UseItemsMixin.addName, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
        end
        sub:CreateButton(
            (WoWTools_DataMixin.onlyChinese and '重置' or RESET)..' |cnGREEN_FONT_COLOR:#'..#WoWTools_UseItemsMixin:Get_P_Tabs()[type],
        function(data)
            StaticPopup_Show('WoWTools_OK',
                (WoWTools_DataMixin.onlyChinese and '重置' or RESET)..'|n|n'..data.text..'|n',
                nil,
                {SetValue=function()
                   Save()[data.type]= WoWTools_UseItemsMixin:Get_P_Tabs()[data.type]
                   print(WoWTools_DataMixin.Icon.icon2..WoWTools_UseItemsMixin.addName, data.text, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end}
            )
        end, {type=type, text=text})

        WoWTools_MenuMixin:SetScrollMode(sub)
    end

--打开，选项
    root:CreateDivider()
    sub=WoWTools_ToolsMixin:OpenMenu(root, WoWTools_UseItemsMixin.addName)

--全部重置
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT,
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)..'|n|n'..(WoWTools_DataMixin.onlyChinese and "重新加载UI" or RELOADUI),
            nil,
            {SetValue=function()
                WoWToolsSave['Tools_UseItems']= nil
                WoWTools_Mixin:Reload()
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_UseItemsMixin.addName, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end}
        )
    end)
    sub:CreateDivider()

--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
end









function WoWTools_UseItemsMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, function(...) Init_Menu(...) end)
end