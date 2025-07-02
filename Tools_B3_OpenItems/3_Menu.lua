

local function Save()
    return WoWToolsSave['Tools_OpenItems']
end





local function Edit_Item(self, info)

    StaticPopup_Show('WoWTools_EditText',
        WoWTools_OpenItemMixin.addName..'|n|n'
        ..WoWTools_ItemMixin:GetName(info.itemID)..'|n|n'
        ..format(WoWTools_DataMixin.onlyChinese and '发现：%s' or ERR_ZONE_EXPLORED,
        Save().no[info.itemID] and self.noText
        or (Save().use[info.itemID] and self.useText)
        or (WoWTools_DataMixin.onlyChinese and '新' or NEW)
    ),
    nil,
    {
        itemID=info.itemID,
        itemLink=info.itemLink,

        text=Save().use[info.itemID],
        OnShow=function(s, data)
            local edit= s.editBox or s:GetEditBox()
            local b3= s.button3 or s:GetButton3()
            edit:SetNumeric(true)
            local useStr=ITEM_SPELL_TRIGGER_ONUSE..'(.+)'--使用：
            local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=nil, guidBank=nil, merchant=nil, inventory=nil, hyperLink=data.itemLink, itemID=data.itemID, text={useStr}, onlyText=true, wow=nil, onlyWoW=nil, red=nil, onlyRed=nil})--物品提示，信息 使用：
            local num= dateInfo.text[useStr] and dateInfo.text[useStr]:match('%d+')
            num= num and tonumber(num)

            edit:SetNumber(num or Save().use[data.itemID] or 1)
            b3:SetText(self.noText)
        end,
        OnHide=function(s)
            local edit= s.editBox or s:GetEditBox()
            edit:SetNumeric(false)
            edit:ClearFocus()
        end,
        SetValue= function(s, data)
            local edit= s.editBox or s:GetEditBox()
            local num= edit:GetNumber()
            num = num<1 and 1 or num
            Save().use[data.itemID]=num
            Save().no[data.itemID]=nil
            WoWTools_OpenItemMixin:Get_Item()--取得背包物品信息                        
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_OpenItemMixin.addName,
                WoWTools_ItemMixin:GetLink(data.itemID),
                num>1 and
                    (WoWTools_DataMixin.onlyChinese and '合成物品' or COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS))..': '..'|cnGREEN_FONT_COLOR:'..num..'|r'
                    or self.useText
            )
        end,
        OnAlt=function(_, data)
            Save().no[data.itemID]=true
            Save().use[data.itemID]=nil
            WoWTools_OpenItemMixin:Get_Item()--取得背包物品信息
            print(WoWTools_DataMixin.addName, WoWTools_OpenItemMixin.addName,
                WoWTools_ItemMixin:GetLink(info.itemID),
                self.noText
            )
        end,
        EditBoxOnTextChanged=function(s)
            local num= s:GetNumber()
            local p=s:GetParent()
            local b1= p.button1 or p:GetButton1()
            if num>1 then
                b1:SetText('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '合成' or AUCTION_STACK_SIZE)..' '..num..'|r')
            else
                b1:SetText('|cnGREEN_FONT_COLOR:'..self.useText..'|r');
            end
        end,
    }
    )
    
end















local function Remove_NoUse_Menu(self, root, itemID, type, numUse)
    WoWTools_Mixin:Load({type='item', id=itemID})


    local sub=root:CreateButton(
        (numUse and '|cnGREEN_FONT_COLOR:'..numUse..'=|r ' or '')
        ..WoWTools_ItemMixin:GetName(itemID),
    function(data)
        Edit_Item(self, data)
        return MenuResponse.Open
    end, {itemID=itemID, type=type})

    WoWTools_SetTooltipMixin:Set_Menu(sub)

    if type=='use' then
        sub:CreateButton(
            WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '修改' or EDIT),
        function(data)
            Edit_Item(self, data)
            return MenuResponse.Open
        end, {itemID=itemID, type=type})
        sub:CreateDivider()
    end
--移除
    sub:CreateButton(
        '|A:common-icon-redx:0:0|a'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE),
    function(data)
        Save()[data.type][data.itemID]=nil

        print(WoWTools_DataMixin.Icon.icon2..WoWTools_OpenItemMixin.addName,
            Save()[data.type][data.itemID]
            and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|r'
            or ('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '物品不存在' or SPELL_FAILED_ITEM_GONE)),

            WoWTools_ItemMixin:GetLink(data.itemID),
            data.type=='no' and self.noText or self.useText
        )

        WoWTools_OpenItemMixin:Get_Item()

        return MenuResponse.Open
    end, {itemID=itemID, type=type})
end




local function Remove_All_Menu(self, root, type, num)
    local name= (type=='use' and '|A:jailerstower-wayfinder-rewardcheckmark:0:0|a' or '|A:talents-button-reset:0:0|a')
                ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..num

    root:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            local index=0
                local type2= data.type=='no' and self.noText or self.useText
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_OpenItemMixin.addName)
                for itemID in pairs(Save()[data.type]) do
                    index= index+1
                    print(
                        index..')',
                        WoWTools_DataMixin.onlyChinese and '移除' or REMOVE,
                        WoWTools_ItemMixin:GetLink(itemID),
                        '|A:common-icon-redx:0:0|a'..type2
                    )
                end
                print(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL, '|A:common-icon-redx:0:0|a|cnGREEN_FONT_COLOR:#',  index)
                Save()[data.type]={}
                WoWTools_OpenItemMixin:Get_Item()
        end})
        return MenuResponse.Open
        
    end, {type=type, name=name})
    root:CreateDivider()
end
























local function Init_Menu(self, root)
    local sub, sub2

    if self:IsValid() then
        sub= root:CreateButton(
            select(2, self:GetItemName(true)),
            function() self:set_disabled_current_item() end,
            {itemLink=self:GetItemLink()}
        )
        sub:SetTooltip(function(tooltip)
            tooltip:AddDoubleLine(self.noText)
            tooltip:AddDoubleLine(WoWTools_DataMixin.Icon.mid..(WoWTools_DataMixin.onlyChinese and '向上滚动' or COMBAT_TEXT_SCROLL_UP))

        end)
    else
        sub=root:CreateButton(WoWTools_DataMixin.onlyChinese and '无' or  NONE)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '使用/禁用' or (USE..'/'..DISABLE))
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '拖曳物品到这里' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS))
        end)
    end
    root:CreateDivider()

    local no, use= 0, 0
    for _ in pairs(Save().no) do
        no=no+1
    end
    for _ in pairs(Save().use) do
        use=use+1
    end

--自定义禁用列表
    sub= root:CreateButton(
        self.noText..' #'..no,
    function() return MenuResponse.Open end)

    if no>2 then
        Remove_All_Menu(self, sub, 'no', no)
    end
    local index=0
    for itemID in pairs(Save().no) do
        index= index+1
        Remove_NoUse_Menu(self, sub, itemID, 'no', nil)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)


--自定义使用列表
    sub=root:CreateButton(
        self.useText..' #'..use,
    function() return MenuResponse.Open end)

    if use>2 then
        Remove_All_Menu(self, sub, 'use', use)
    end
    index=0
    for itemID, numUse in pairs(Save().use) do
        index= index+1
        Remove_NoUse_Menu(self, sub, itemID, 'use', numUse)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)


local OptionsList={{
    name=WoWTools_DataMixin.onlyChinese and '<右键点击打开>' or ITEM_OPENABLE,
    type='open'
},{
    name=WoWTools_DataMixin.onlyChinese and '坐骑' or MOUNTS or ITEM_OPENABLE,
    type='mount'
},{
    name=WoWTools_DataMixin.onlyChinese and '幻化' or TRANSMOGRIFY,
    type='mago'
}, {
    name=WoWTools_DataMixin.onlyChinese and '配方' or TRADESKILL_SERVICE_LEARN,
    type='ski'
}, {
    name=WoWTools_DataMixin.onlyChinese and '其它' or BINDING_HEADER_OTHER,
    type='alt'
}, {
    name=WoWTools_DataMixin.onlyChinese and '材料' or BAG_FILTER_REAGENTS,
    type='reagent',
    tooltip=WoWTools_DataMixin.onlyChinese and '检查' or WHO,
},
}
    for _, info in pairs(OptionsList) do
        sub= root:CreateCheckbox(
            info.name,
        function(data)
            return Save()[data.type]
        end, function(data)
            Save()[data.type]= not Save()[data.type] and true
            WoWTools_OpenItemMixin:Get_Item()
        end, {type=info.type, tooltip=info.tooltip})
        if info.tooltip then
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.tooltip)
            end)
        end
    end

    root:CreateDivider()

--打开, 选项界面，菜单

    sub= WoWTools_ToolsMixin:OpenMenu(root, WoWTools_OpenItemMixin.addName, self:get_key_text())

--设置捷键
    WoWTools_KeyMixin:SetMenu(self, sub, {
        name= WoWTools_OpenItemMixin.addName,
        key=Save().KEY,
        GetKey=function(key)
            Save().KEY= key
            self:settings()
        end,
        OnAlt=function()
            Save().KEY=nil
            self:settings()
        end,
    })

    sub:CreateDivider()
    sub2=sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS))
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(self.useText, self.noText)
    end)
end














function WoWTools_OpenItemMixin:Setup_Menu()
    MenuUtil.CreateContextMenu(self.OpenButton, function(...) Init_Menu(...) end)
end

function WoWTools_OpenItemMixin:Edit_Item(...)
    Edit_Item(...)
end