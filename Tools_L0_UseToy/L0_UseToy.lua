
local addName

local P_Items={
    [122129]=true,[169347]=true,[174873]=true,[140160]=true,[180873]=true,[188699]=true,[38301]=true,
    [147843]=true,[174830]=true,[32782]=true,[37254]=true,[186702]=true,[186686]=true,[64456]=true,
    [174924]=true,[169865]=true,[187139]=true,[183901]=true,[44719]=true,[188701]=true,[183988]=true,
    [141331]=true,[118937]=true,[88566]=true,[68806]=true,[104262]=true,[141862]=true,[127668]=true,
    [128807]=true,[103685]=true,[134031]=true,[127659]=true,[166678]=true,[86571]=true,[133511]=true,
    [166663]=true,[64646]=true,[134034]=true,[105898]=true,[134831]=true,[119215]=true,[1973]=true,
    [129149]=true,[142452]=true,[170198]=true,[129952]=true,[119421]=true,[118938]=true,[168014]=true,
    [129926]=true,[116115]=true,[116440]=true,[128310]=true,[127864]=true,[116758]=true,[163750]=true,
    [134032]=true,[87528]=true,[119092]=true,[113096]=true,[53057]=true,[116139]=true,[129938]=true,
    [35275]=true,[116067]=true,[104294]=true,[86568]=true,[118244]=true,[43499]=true,[128471]=true,
    [72159]=true,[122283]=true,[129093]=true,[167931]=true,[170154]=true,[179393]=true,[183986]=true,
    [190926]=true,[190457]=true,[120276]=true,[173984]=true,[187705]=true,[184318]=true,[184447]=true,
    [35227]=true,[169303]=true,[166779]=true,[79769]=true,[134022]=true,[174874]=true,[183903]=true,
    [122119]=true,[183856]=true,[64997]=true,[138900]=true,[49703]=true,[190333]=true,[184223]=true,
    [52201]=true,[166308]=true,[122117]=true,[129113]=true,
    [198537]=true,--[泰瓦恩的小号]
    [191891]=true,--[啾讽教授完美得无可置喙的鹰身人伪装]
    [202022]=true,--[耶努的风筝]
    [198039]=true,--感激之岩
    [205963]=true,--闻盐
    [208658]=true,--谦逊之镜 使用: 变身为一个悔改的堕落艾瑞达。 (2​小时 冷却)
    [210656]=true,--冬幕节袜子
    [217726]=true,--砮皂之韧 10.2.7 
    [217724]=true,
    [217723]=true,
    [217725]=true,
    [220777]=true,--
    [224552]=true,--洞穴探索者的火炬
    [228914]=true,--爱蛛者眼镜
    [245567]=true,--卡雷什记忆水晶
}
local ModifiedTab={
    --[[[69775]='Alt',--维库饮水角
    [109183]='Ctrl',--世界缩小器
    [134032]='Shift',--精英旗帜]]
}
local ModifiedMenuTab={
    --[[{type='Alt', itemID=69775},
    {type='Ctrl', itemID=109183},
    {type='Shift', itemID=134032},]]
}
for itemID in pairs(ModifiedTab) do
    WoWTools_DataMixin:Load({id=itemID, type='item'})
end
for itemID in pairs(P_Items) do
    WoWTools_DataMixin:Load({id=itemID, type='item'})
end

local P_Save={
    items=P_Items,
    showBindNameShort=true,
    showBindName=true,
    lockedToy=nil,
    Alt=69775,--维库饮水角
    Ctrl=109183,--世界缩小器
    Shift=86568,--重拳先生的铜罗盘

}


local function Save()
    return WoWToolsSave['Tools_UseToy']
end




local ToyButton
local function Set_Alt_Table()
    ModifiedTab={
        [Save().Alt or 69775]='Alt',--维库饮水角
        [Save().Ctrl or 109183]='Ctrl',--世界缩小器
        [Save().Shift or 86568]='Shift',--精英旗帜
    }
    ModifiedMenuTab={
        {type='Alt', itemID=Save().Alt or 69775},
        {type='Ctrl', itemID=Save().Ctrl or 109183},
        {type='Shift', itemID=Save().Shift or 86568}
    }
end

local function Set_Alt_Menu(root, itemID)
    local sub
    root:CreateDivider()
    for _, info in pairs(ModifiedMenuTab) do
        sub=root:CreateCheckbox(info.type..'|T'..(C_Item.GetItemIconByID(info.itemID) or 0)..':0|t',
            function(data)
                return Save()[data.type]== data.itemID2
            end, function(data)
                if Save()[data.type]==data.itemID2 then
                    Save()[data.type]=nil
                else
                    Save()[data.type]= data.itemID2
                end
                Set_Alt_Table()
                ToyButton:set_alt()
                return MenuResponse.Refresh
            end,
            {type=info.type, itemID=info.itemID, itemID2=itemID}
        )
        WoWTools_SetTooltipMixin:Set_Menu(sub)
    end
end
















local function Remove_Toy(itemID)--移除
    Save().items[itemID]=nil
    local isSelect, isLock= ToyButton:Check_Random_Value(itemID)
    if isLock or isSelect then
        if isSelect then
            ToyButton:Set_SelectValue_Random(nil)
        end
        if isLock then
            Save().lockedToy=nil
            ToyButton:Set_LockedValue_Random(nil)
        end
    elseif ToyButton.itemID==itemID then
        ToyButton:Init_Random(Save().lockedToy)
    end
    print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_DataMixin.onlyChinese and '移除' or REMOVE, WoWTools_ItemMixin:GetLink(itemID))
end



local function Add_Toy(itemID)--添加
    Save().items[itemID]= true
    ToyButton:Init_Random(Save().lockedToy)--初始
end



local function Add_Remove_Toy(itemID)--移除/添加
    if itemID then
        if Save().items[itemID] then
            Remove_Toy(itemID)--移除
        else
            Add_Toy(itemID)--添加
        end
    end
end


--设置，物品，提示
local function Set_Menu_Tooltip(tooltip, desc)
    if desc.data then
        WoWTools_SetTooltipMixin:Setup(tooltip, {itemID=desc.data.itemID})--设置，物品，提示
    end
end



local function set_ToggleCollectionsJournal(data)
    WoWTools_LoadUIMixin:Journal(3)
    if data.name or data.itemID then
        local name= data.name or select(2, C_ToyBox.GetToyInfo(data.itemID)) or C_Item.GetItemNameByID(data.itemID)
        if name then
            C_ToyBoxInfo.SetDefaultFilters()
            if ToyBox.searchBox then
                ToyBox.searchBox:SetText(name)
            end
        end
    end
    return MenuResponse.Open
end



local function get_not_cooldown_toy()--发现就绪
    local duration = select(2, C_Item.GetItemCooldown(ToyButton.itemID))
    if duration and duration>3 then
        for itemID in pairs(P_Items) do
            if PlayerHasToy(itemID) then
                duration= select(2, C_Item.GetItemCooldown(itemID))
                if duration and duration<3 then
                    return itemID
                end
            end
        end
    end
end

























local function Init_Menu_Toy(_, root)
    local sub, sub2, name, toyName, icon
    local index=0
    for itemID in pairs(Save().items) do
        WoWTools_DataMixin:Load({id=itemID, type='item'})

        toyName, icon = select(2, C_ToyBox.GetToyInfo(itemID))
        index= index+ 1

        icon= '|T'..(icon or 0)..':0|t'
        name=WoWTools_TextMixin:CN(toyName, {itemID=itemID, isName=true})
        if name then
            name=name:match('|c........(.-)|r') or name
        else
            name='itemID '.. itemID
        end

        local alt= (Save().Alt==itemID and 'A' or '')
            ..(Save().Ctrl==itemID and 'C' or '')
            ..(Save().Shift==itemID and 'S' or '')
        alt= alt~='' and '|cnGREEN_FONT_COLOR:['..alt..']|r' or alt
--名称，锁定
        local has= PlayerHasToy(itemID)
        local isLoked= Save().lockedToy==itemID
        sub=root:CreateCheckbox(
            (isLoked and '|cnGREEN_FONT_COLOR:' or (has and '' or '|cff9e9e9e'))
            ..index..') '
            ..alt..icon
            ..name
            ..(isLoked and '|A:AdventureMapIcon-Lock:0:0|a' or '')--锁定
            ..(has and WoWTools_CooldownMixin:GetText(nil, itemID) or ''),--CD
            function(data)
                return ToyButton.itemID==data.itemID
            end, function(data)
                if data.has then
                    if not Save().lockedToy then
                        local toy= ToyButton.Selected_Value~=data.itemID and data.itemID or nil
                        ToyButton:Set_SelectValue_Random(toy)
                    end
                end
                return MenuResponse.Refresh
            end,
            {itemID=itemID, name=toyName, has=has}
        )
        sub:SetTooltip(Set_Menu_Tooltip)

        sub2=sub:CreateCheckbox(
            (has and '' or '|cff9e9e9e')
            ..icon
            ..(WoWTools_DataMixin.onlyChinese and '锁定' or LOCK)..'|A:AdventureMapIcon-Lock:0:0|a',
        function(data)
            return Save().lockedToy==data.itemID
        end, function(data)
            if data.has then
                Save().lockedToy= Save().lockedToy~=data.itemID and itemID or nil
                ToyButton:Init_Random(Save().lockedToy)
            end
            return MenuResponse.Refresh
        end, {itemID=itemID, name=toyName, has=has})
        sub2:SetTooltip(Set_Menu_Tooltip)

--设置
        sub2=sub:CreateButton(
            '|A:common-icon-zoomin:0:0|a'
            ..MicroButtonTooltipText(WoWTools_DataMixin.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"),
            set_ToggleCollectionsJournal,
            {itemID=itemID, name=toyName}
        )
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
        end)

        Set_Alt_Menu(sub, itemID)

--移除
        sub:CreateDivider()
        sub2=sub:CreateButton(
            '|A:common-icon-redx:0:0|a'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE),
            function(data)
                Remove_Toy(data.itemID)--移除
                return MenuResponse.Refresh
            end,
            {itemID=itemID, name=toyName}
        )
        sub2:SetTooltip(Set_Menu_Tooltip)
    end

    WoWTools_MenuMixin:SetScrollMode(root)
end










--#####
--主菜单
--#####
local function Init_Menu(self, root)
    local sub, sub2, name
--选项

    sub=WoWTools_ToolsMixin:OpenMenu(root, addName)


--移除未收集
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
                ToyButton:Init_Random(Save().lockedToy)
            end
        end})
        return MenuResponse.Open
    end, {name=name})


--全部清除
    name='|A:common-icon-redx:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
    sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            Save().items={}
            print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
            ToyButton:Rest_Random()
        end})
    end, {name=name})


--还原
    local all= 0
    for _ in pairs(P_Items) do
        all=all+1
    end
    name= '|A:common-icon-undo:0:0|a'..(WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)..' '..all
    sub2=sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            Save().items= P_Items
            ToyButton:Rest_Random()
            print(WoWTools_DataMixin.Icon.icon2..addName, '|cnGREEN_FONT_COLOR:', WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)
        end})
        return MenuResponse.Open
    end, {name=name})

--设置
    sub:CreateDivider()
    sub2=sub:CreateButton(
        '|A:common-icon-zoomin:0:0|a'
        ..MicroButtonTooltipText(WoWTools_DataMixin.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"),
        set_ToggleCollectionsJournal
    )
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS))
    end)

--设置捷键
    WoWTools_KeyMixin:SetMenu(self, sub, {
        name=addName,
        key=Save().KEY,
        GetKey=function(key)
            Save().KEY=key
            WoWTools_KeyMixin:Setup(ToyButton)--设置捷键
        end,
        OnAlt=function(s)
            Save().KEY=nil
            WoWTools_KeyMixin:Setup(ToyButton)--设置捷键
        end,
    })




    root:CreateDivider()


    Init_Menu_Toy(self, root)
end








































--#############
--玩具界面, 按钮
--#############
local function setToySpellButton_UpdateButton(btn)--标记, 是否已选取
    if not btn.useToy then
        btn.useToy= WoWTools_ButtonMixin:Cbtn(btn,{size=16, texture=133567})
        btn.useToy:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT', 16, 0)

        function btn.useToy:get_itemID()
            return self:GetParent().itemID
        end
        function btn.useToy:set_alpha()
            self:SetAlpha(Save().items[self:get_itemID()] and 1 or 0.1)
        end
        function btn.useToy:set_tooltips()
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, addName)
            GameTooltip:AddLine(' ')
            local itemID=self:get_itemID()
            local icon= C_Item.GetItemIconByID(itemID)
            GameTooltip:AddDoubleLine(
                (icon and '|T'..icon..':0|t' or '')..(itemID and C_ToyBox.GetToyLink(itemID) or itemID),
                WoWTools_TextMixin:GetEnabeleDisable(Save().items[itemID])..WoWTools_DataMixin.Icon.left
            )
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
            GameTooltip:Show()
            self:SetAlpha(1)
        end
        btn.useToy:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                Add_Remove_Toy(self:get_itemID())--移除/添加
                self:set_tooltips()
                self:set_alpha()
            else
                MenuUtil.CreateContextMenu(self, function(...) Init_Menu_Toy(...) end)
            end
        end)
        btn.useToy:SetScript('OnLeave', function(self) GameTooltip:Hide() self:set_alpha() end)
        btn.useToy:SetScript('OnEnter', btn.useToy.set_tooltips)
    end
    btn.useToy:set_alpha()
end






















--###
--初始
--###
local function Init()
    WoWTools_KeyMixin:Init(ToyButton, function() return Save().KEY end)


    --[[ToyButton:SetAttribute("type1", "item")
    ToyButton:SetAttribute("alt-type1", "item")
    ToyButton:SetAttribute("shift-type1", "item")
    ToyButton:SetAttribute("ctrl-type1", "item")]]
    ToyButton:SetAttribute("type1", "toy")
    ToyButton:SetAttribute("alt-type1", "toy")
    ToyButton:SetAttribute("shift-type1", "toy")
    ToyButton:SetAttribute("ctrl-type1", "toy")

    ToyButton.text=WoWTools_LabelMixin:Create(ToyButton, {size=10, color={r=1,g=1,b=1}})
    ToyButton.text:SetPoint('BOTTOMRIGHT', ToyButton)


    --设置 Alt Shift Ctrl
    function ToyButton:set_alt()
        self.isAltEvent=nil
        if not self:CanChangeAttribute() then
            self.isAltEvent=true
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end
        for itemID, type in pairs(ModifiedTab) do

            --local name= C_Item.GetItemNameByID(itemID) or select(2,  C_ToyBox.GetToyInfo(itemID))
            --if name then
                self:SetAttribute(type.."-toy1",  itemID)

            --[[else
                self.isAltEvent=true
            end]]
        end
        --[[if self.isAltEvent then
            self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
        end]]
    end





    --CD
    function ToyButton:set_cool()
        WoWTools_CooldownMixin:SetFrame(self, {itemID=self.itemID})--主图标冷却
    end







    ToyButton:SetScript('OnEvent', function(self, event, itemID, success)
        if event=='ITEM_DATA_LOAD_RESULT' then
            if success then
                if ModifiedTab[itemID] then
                    self:set_alt()
                elseif Save().items[itemID] then
                    self:Set_Random_Event()--is_Random_Eevent
                end
                if not self.is_Random_Eevent then
                    self:UnregisterEvent('ITEM_DATA_LOAD_RESULT')
                end
            end

        elseif event=='PLAYER_REGEN_ENABLED' then
            if self.isAltEvent then
                self:set_alt()
            end
            if self.is_Random_Eevent then
                self:Set_Random_Event()--is_Random_Eevent
            end
            if not self.isAltEvent and not self.is_Random_Eevent then
                self:UnregisterEvent('PLAYER_REGEN_ENABLED')
            end

        elseif event=='TOYS_UPDATED' or event=='NEW_TOY_ADDED' then
            self:Init_Random(Save().lockedToy)

        elseif event=='BAG_UPDATE_COOLDOWN' then
            self:set_cool()
        end
    end)


--Tooltip
    function ToyButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(self.itemID), (WoWTools_KeyMixin:IsKeyValid(self) or '').. WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        local name, col
        for _, data in pairs(ModifiedMenuTab) do
            name, col=WoWTools_ItemMixin:GetName(data.itemID)
            col= col or ''
            GameTooltip:AddDoubleLine(col..name, col..data.type..'+'..WoWTools_DataMixin.Icon.left)
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '随机' or 'Random',
            (ToyButton.Locked_Value and '' or '|cnGREEN_FONT_COLOR:#'..#self.Random_List..'|r')
            ..(ToyButton.Selected_Value and '|A:transmog-icon-checkmark:0:0|a' or '')
            ..(ToyButton.Locked_Value and '|A:AdventureMapIcon-Lock:0:0|a' or '')
            ..WoWTools_DataMixin.Icon.mid
        )


--发现就绪
        local duration= select(2, C_Item.GetItemCooldown(self.itemID))
        if duration and duration>4 then
            ToyButton:Get_Random_Value()
        end

        GameTooltip:Show()
    end


    ToyButton:SetScript("OnEnter",function(self)
        WoWTools_ToolsMixin:EnterShowFrame(self)
        self:set_tooltips()
        self:SetScript('OnUpdate', function (s, elapsed)
            s.elapsed = (s.elapsed or 0.3) + elapsed
            if s.elapsed > 0.3 and s.itemID then
                s.elapsed = 0
                if GameTooltip:IsOwned(s) and select(3, GameTooltip:GetItem())~=s.itemID then
                    s:set_tooltips()
                end
            end
        end)
        if self:CanChangeAttribute() then
            local itemID= Save().lockedToy or get_not_cooldown_toy()--发现就绪
            if itemID then
                self.Selected_Value=itemID
                self:Set_Random_Value(itemID)
            end
        end
    end)

    ToyButton:SetScript("OnLeave",function(self)
        GameTooltip:Hide()
        self:SetScript('OnUpdate',nil)
        self.elapsed=nil
    end)

    ToyButton:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
        end
    end)

    ToyButton:SetScript("OnMouseUp", function(self, d)
        if d=='LeftButton' then
            self:Get_Random_Value()
        end
    end)
    ToyButton:SetScript('OnMouseWheel', function(self)
        self.Selected_Value=nil
        self:Get_Random_Value()
    end)











    Mixin(ToyButton, WoWTools_RandomMixin)

    function ToyButton:Get_Random_Data()--取得数据库, {数据1, 数据2, 数据3, ...}
        local tab={}
        for itemID in pairs(Save().items) do
            if PlayerHasToy(itemID) then
                local duration= select(2, C_Item.GetItemCooldown(itemID))
                if duration and duration<3 then
                    table.insert(tab, itemID)
                end
            end
        end
        return tab
    end

    function ToyButton:Set_Random_Value(itemID)--设置，随机值
        self.is_Random_Eevent=nil
        if not self:CanChangeAttribute() then
            self.is_Random_Eevent=true
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end
        local name=C_Item.GetItemNameByID(itemID) or select(2, C_ToyBox.GetToyInfo(itemID))
        if not name then
            self.is_Random_Eevent=true
            self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
            return
        end
        self.itemID=itemID
        --self:SetAttribute('item1', name)
        self:SetAttribute('toy1', itemID)
        self.texture:SetTexture(C_Item.GetItemIconByID(itemID) or 0)
        self:set_cool()
        self.text:SetText(self.Random_Numeri>0 and self.Random_Numeri or '')
    end
    function ToyButton:Set_OnlyOneValue_Random()--当数据 <=1 时，设置值
        self:Set_Random_Value( self.Locked_Value or self.Selected_Value or self.Random_List[1] or 6948)
    end

    ToyButton:Init_Random(Save().lockedToy)--初始








    function ToyButton:set_event()
        if self:IsVisible() then
            self:RegisterEvent('TOYS_UPDATED')
            self:RegisterEvent('NEW_TOY_ADDED')
            self:RegisterEvent('BAG_UPDATE_COOLDOWN')
            self:Get_Random_Value()
        else
            self:UnregisterAllEvents()
            WoWTools_CooldownMixin:SetFrame(self)--主图标冷却
        end
    end

    ToyButton:SetScript('OnShow', ToyButton.set_event)
    ToyButton:SetScript('OnHide', ToyButton.set_event)
    ToyButton:set_event()









    ToyButton:set_alt()

    C_Timer.After(4, function()
        ToyButton:Get_Random_Value()
    end)
    Init=function()end
end


























--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Tools_UseToy']= WoWToolsSave['Tools_UseToy'] or P_Save

            addName='|A:collections-icon-favorites:0:0|a'..(WoWTools_DataMixin.onlyChinese and '随机玩具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, USE, TOY))


            ToyButton= WoWTools_ToolsMixin:CreateButton({
                name='UseToy',
                tooltip=addName,
            })

            if ToyButton then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')

                for itemID in pairs(Save().items) do
                    WoWTools_DataMixin:Load({id=itemID, type='item'})
                end

                Set_Alt_Table()

                if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                    WoWTools_DataMixin:Hook('ToySpellButton_UpdateButton', function(...)
                        setToySpellButton_UpdateButton(...)
                    end)
                    self:UnregisterEvent(event)
                end
            else
                self:UnregisterAllEvents()
            end

        elseif arg1=='Blizzard_Collections' and WoWToolsSave then
           WoWTools_DataMixin:Hook('ToySpellButton_UpdateButton', function(...)
                setToySpellButton_UpdateButton(...)
            end)
            self:UnregisterEvent(event)
        end

    elseif event == 'PLAYER_ENTERING_WORLD' then
        Init()--初始
        self:UnregisterEvent(event)
    end
end)