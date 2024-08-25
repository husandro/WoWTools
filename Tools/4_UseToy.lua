local id, e = ...
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
    [220777]=true,--樱花之路
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
    e.LoadDate({id=itemID, type='item'})
end
for itemID in pairs(P_Items) do
    e.LoadDate({id=itemID, type='item'})
end

local Save={
    items=P_Items,
    showBindNameShort=true,
    showBindName=true,
    lockedToy=nil,
    Alt=69775,--维库饮水角
    Ctrl=109183,--世界缩小器
    Shift=134032,--精英旗帜

}
local ToyButton

local function Set_Alt_Table()
    ModifiedTab={
        [Save.Alt or 69775]='Alt',--维库饮水角
        [Save.Ctrl or 109183]='Ctrl',--世界缩小器
        [Save.Shift or 134032]='Shift',--精英旗帜
    }
    ModifiedMenuTab={
        {type='Alt', itemID=Save.Alt or 69775},
        {type='Ctrl', itemID=Save.Ctrl or 109183},
        {type='Shift', itemID=Save.Ctrl or 134032}
    }
end

local function Set_Alt_Menu(root, itemID)
    local sub
    root:CreateDivider()
    for _, info in pairs(ModifiedMenuTab) do
        sub=root:CreateCheckbox(info.type..'|T'..(C_Item.GetItemIconByID(info.itemID) or 0)..':0|t',
            function(data)
                return Save[data.type]== data.itemID2
            end, function(data)
                if Save[data.type]==data.itemID2 then
                    Save[data.type]=nil
                else
                    Save[data.type]= data.itemID2
                end
                Set_Alt_Table()
                ToyButton:set_alt()
                return MenuResponse.Refresh
            end,
            {type=info.type, itemID=info.itemID, itemID2=itemID}
        )
        WoWTools_SpellItemMixin:SetTooltip(nil, nil, sub, nil)
    end
end
















local function Remove_Toy(itemID)--移除
    Save.items[itemID]=nil
    local isSelect, isLock= ToyButton:Check_Random_Value(itemID)
    if isLock or isSelect then
        if isSelect then
            ToyButton:Set_SelectValue_Random(nil)
        end
        if isLock then
            Save.lockedToy=nil
            ToyButton:Set_LockedValue_Random(nil)
        end
    elseif ToyButton.itemID==itemID then
        ToyButton:Init_Random(Save.lockedToy)
    end
    print(e.addName, addName, e.onlyChinese and '移除' or REMOVE, ItemUtil.GetItemHyperlink(itemID) or itemID)
end



local function Add_Toy(itemID)--添加
    Save.items[itemID]= true
    ToyButton:Init_Random(Save.lockedToy)--初始
end



local function Add_Remove_Toy(itemID)--移除/添加
    if itemID then
        if Save.items[itemID] then
            Remove_Toy(itemID)--移除
        else
            Add_Toy(itemID)--添加
        end
    end
end


--设置，物品，提示
local function Set_Menu_Tooltip(tooltip, desc)
    if desc.data then
        WoWTools_SpellItemMixin:SetTooltip(tooltip, {itemID=desc.data.itemID})--设置，物品，提示
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
    local cd = select(2, C_Item.GetItemCooldown(ToyButton.itemID)) or 0
    if cd>3 then
        for itemID in pairs(P_Items) do
            if PlayerHasToy(itemID) and select(2, C_Item.GetItemCooldown(itemID))<3 then
                return itemID
            end
        end
    end
end

























local function Init_Menu_Toy(_, root)
    local sub, sub2, name, toyName, icon
    local index=0
    for itemID in pairs(Save.items) do
        e.LoadDate({id=itemID, type='item'})

        toyName, icon = select(2, C_ToyBox.GetToyInfo(itemID))
        index= index+ 1

        icon= '|T'..(icon or 0)..':0|t'
        name=e.cn(toyName, {itemID=itemID, isName=true})
        if name then
            name=name:match('|c........(.-)|r') or name
        else
            name='itemID '.. itemID
        end

        local alt= (Save.Alt==itemID and 'A' or '')
            ..(Save.Ctrl==itemID and 'C' or '')
            ..(Save.Shift==itemID and 'S' or '')
        alt= alt~='' and '|cnGREEN_FONT_COLOR:['..alt..']|r' or alt
--名称
        local has= PlayerHasToy(itemID)
        local isLoked= Save.lockedToy==itemID
        sub=root:CreateCheckbox(
            (isLoked and '|cnGREEN_FONT_COLOR:' or (has and '' or '|cff9e9e9e'))
            ..index..') '
            ..alt..icon
            ..name
            ..(isLoked and '|A:AdventureMapIcon-Lock:0:0|a' or '')--锁定
            ..(has and e.GetSpellItemCooldown(nil, itemID) or ''),--CD
            function(data)
                return ToyButton.itemID==data.itemID
            end, function(data)
                if data.has then
                    local toy= ToyButton.Selected_Value~=data.itemID and data.itemID or nil
                    ToyButton:Set_SelectValue_Random(toy)
                end                
            end,
            {itemID=itemID, name=toyName, has=has}
        )
        sub:SetTooltip(Set_Menu_Tooltip)

        sub2=sub:CreateCheckbox(
            (has and '' or '|cff9e9e9e')
            ..icon
            ..(e.onlyChinese and '锁定' or LOCK)..'|A:AdventureMapIcon-Lock:0:0|a',
        function(data)
            return Save.lockedToy==data.itemID
        end, function(data)
            if data.has then
                local toy= Save.lockedToy~=data.itemID and itemID or nil
                Save.lockedToy= toy
                ToyButton:Set_LockedValue_Random(toy)
            end
        end, {itemID=itemID, name=toyName, has=has})
        sub2:SetTooltip(Set_Menu_Tooltip)


        sub2=sub:CreateButton(
            '|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '设置' or SETTINGS),
            set_ToggleCollectionsJournal,
            {itemID=itemID, name=toyName}
        )
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(MicroButtonTooltipText(e.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
        end)

        Set_Alt_Menu(sub, itemID)

        sub:CreateDivider()
        sub2=sub:CreateButton(
            '|A:common-icon-redx:0:0|a'..(e.onlyChinese and '移除' or REMOVE),
            function(data)
                Remove_Toy(data.itemID)--移除
                return MenuResponse.Open
            end,
            {itemID=itemID, name=toyName}
        )
        sub2:SetTooltip(Set_Menu_Tooltip)
    end
    --WoWTools_MenuMixin:SetNumButton(root, index)
    WoWTools_MenuMixin:SetScrollButton(root, 30)
end










--#####
--主菜单
--#####
local function Init_Menu(self, root)
    local sub, sub2
--选项
    
    sub=WoWTools_ToolsButtonMixin:OpenMenu(root, addName)


--移除未收集
    sub2=sub:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '移除未收集' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REMOVE, NOT_COLLECTED)), function()
        if IsControlKeyDown() then
            local n=0
            for itemID in pairs(Save.items) do
                if not PlayerHasToy(itemID) then
                    Save.items[itemID]=nil
                    n=n+1
                    print(n, ItemUtil.GetItemHyperlink(itemID) or ('itemID '..itemID), e.onlyChinese and '移除' or REMOVE)
                end
            end
            if n>0 then
                ToyButton:Init_Random(Save.lockedToy)
            else
                return MenuResponse.Open
            end
        else
            return MenuResponse.Open
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left)
    end)

--全部清除
    sub2=sub:CreateButton('|A:common-icon-redx:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL), function()
        if IsControlKeyDown() then
            Save.items={}
            print(e.addName, addName, e.onlyChinese and '全部清除' or CLEAR_ALL)
            ToyButton:Rest_Random()
        else
            return MenuResponse.Open
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left)
    end)


--还原
    local all= 0
    for _ in pairs(P_Items) do
        all=all+1
    end
    sub2=sub:CreateButton('|A:common-icon-undo:0:0|a'..(e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)..' '..all, function()
        if IsControlKeyDown() then
            Save.items= P_Items
            ToyButton:Rest_Random()
            print(e.addName, addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)
        else
            return MenuResponse.Open
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left)
    end)

--设置
    sub:CreateDivider()
    sub2=sub:CreateButton(
        '|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '设置' or SETTINGS),
        set_ToggleCollectionsJournal,
        {}
    )
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText(e.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
    end)

--设置捷键
    sub:CreateSpacer()
WoWTools_Key_Button:SetMenu(sub, {
    name=addName,
    key=Save.KEY,
    GetKey=function(key)
        Save.KEY=key
        WoWTools_Key_Button:Setup(ToyButton)--设置捷键
    end,
    OnAlt=function(s)
        Save.KEY=nil
        WoWTools_Key_Button:Setup(ToyButton)--设置捷键
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
        btn.useToy= e.Cbtn(btn,{size={16,16}, texture=133567})
        btn.useToy:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT', 16, 0)

        function btn.useToy:get_itemID()
            return self:GetParent().itemID
        end
        function btn.useToy:set_alpha()
            self:SetAlpha(Save.items[self:get_itemID()] and 1 or 0.1)
        end
        function btn.useToy:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.addName, addName)
            e.tips:AddLine(' ')
            local itemID=self:get_itemID()
            local icon= C_Item.GetItemIconByID(itemID)
            e.tips:AddDoubleLine(
                (icon and '|T'..icon..':0|t' or '')..(itemID and C_ToyBox.GetToyLink(itemID) or itemID),
                e.GetEnabeleDisable(Save.items[itemID])..e.Icon.left
            )
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
            self:SetAlpha(1)
        end
        btn.useToy:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                Add_Remove_Toy(self:get_itemID())--移除/添加
                self:set_tooltips()
                self:set_alpha()
            else
                MenuUtil.CreateContextMenu(self, Init_Menu_Toy)
            end
        end)
        btn.useToy:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha() end)
        btn.useToy:SetScript('OnEnter', btn.useToy.set_tooltips)
    end
    btn.useToy:set_alpha()
end






















--###
--初始
--###
local function Init()
    WoWTools_Key_Button:Init(ToyButton, function() return Save.KEY end)

    for itemID, _ in pairs(Save.items) do
        e.LoadDate({id=itemID, type='item'})
    end

    ToyButton:SetAttribute("type1", "item")
    ToyButton:SetAttribute("alt-type1", "item")
    ToyButton:SetAttribute("shift-type1", "item")
    ToyButton:SetAttribute("ctrl-type1", "item")

    ToyButton.text=e.Cstr(ToyButton, {size=10, color={r=1,g=1,b=1}})
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
            local name= C_Item.GetItemNameByID(itemID) or select(2,  C_ToyBox.GetToyInfo(itemID))
            if name then
                self:SetAttribute(type.."-item1",  name)
            else
                self.isAltEvent=true
            end
        end
        if self.isAltEvent then
            self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
        end
    end





    --CD
    function ToyButton:set_cool()
        e.SetItemSpellCool(self, {item=self.itemID})--主图标冷却
    end




 
    

    ToyButton:SetScript('OnEvent', function(self, event, itemID, success)
        if event=='ITEM_DATA_LOAD_RESULT' then
            if success then
                if ModifiedTab[itemID] then
                    self:set_alt()
                elseif Save.items[itemID] then
                    self:Set_Random_Event()--is_Random_Eevent
                end
                if not self.isAltEvent and not self.is_Random_Eevent then
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
            self:Init_Random(Save.lockedToy)

        elseif event=='BAG_UPDATE_COOLDOWN' then
            self:set_cool()
        end
    end)


--Tooltip
    function ToyButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_SpellItemMixin:GetName(nil, self.itemID), (WoWTools_Key_Button:IsKeyValid(self) or '').. e.Icon.left)
        e.tips:AddLine(' ')
        local name, col
        for _, data in pairs(ModifiedMenuTab) do
            name, col=WoWTools_SpellItemMixin:GetName(nil, data.itemID)
            col= col or ''
            e.tips:AddDoubleLine(col..name, col..data.type..'+'..e.Icon.left)
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:AddDoubleLine(
            e.onlyChinese and '随机' or 'Random',
            (ToyButton.Locked_Value and '' or '|cnGREEN_FONT_COLOR:#'..#self.Random_List..'|r')
            ..(ToyButton.Selected_Value and '|A:transmog-icon-checkmark:0:0|a' or '')
            ..(ToyButton.Locked_Value and '|A:AdventureMapIcon-Lock:0:0|a' or '')
            ..e.Icon.mid
        )


--发现就绪
        if select(2, C_Item.GetItemCooldown(self.itemID))>4 then
            ToyButton:Get_Random_Value()
        end
        e.tips:Show()
    end


    ToyButton:SetScript("OnEnter",function(self)
        WoWTools_ToolsButtonMixin:EnterShowFrame(self)
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
            local itemID= get_not_cooldown_toy()--发现就绪
            if itemID then
                self.Selected_Value=itemID
                self:Set_Random_Value(itemID)
            end
        end
    end)

    ToyButton:SetScript("OnLeave",function(self)
        e.tips:Hide()
        self:SetScript('OnUpdate',nil)
        self.elapsed=nil
    end)

    ToyButton:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)
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
        for itemID in pairs(Save.items) do
            if PlayerHasToy(itemID) and select(2, C_Item.GetItemCooldown(itemID))<3 then
            --if PlayerHasToy(itemID) then
                table.insert(tab, itemID)
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
        self:SetAttribute('item1', name)
        self.texture:SetTexture(C_Item.GetItemIconByID(itemID) or 0)
        self:set_cool()
        self.text:SetText(self.Random_Numeri>0 and self.Random_Numeri or '')
    end
    function ToyButton:Set_OnlyOneValue_Random()--当数据 <=1 时，设置值
        self:Set_Random_Value(self.Selected_Value or self.Locked_Value or self.Random_List[1] or 6948)
    end

    ToyButton:Init_Random(Save.lockedToy)--初始








    function ToyButton:set_event()
        if self:IsVisible() then
            self:RegisterEvent('TOYS_UPDATED')
            self:RegisterEvent('NEW_TOY_ADDED')
            self:RegisterEvent('BAG_UPDATE_COOLDOWN')
            self:Get_Random_Value()
        else
            self:UnregisterAllEvents()
            e.SetItemSpellCool(self)--主图标冷却
        end
    end

    ToyButton:SetScript('OnShow', ToyButton.set_event)
    ToyButton:SetScript('OnHide', ToyButton.set_event)
    ToyButton:set_event()










    ToyButton:set_alt()
    C_Timer.After(4, function()
        ToyButton:Get_Random_Value()
    end)
end


























--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            --旧版本
            
            if WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY)..'Tools'] then
                Save= WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY)..'Tools']
                WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY)..'Tools']=nil
            else
                Save= WoWToolsSave['Tools_UseToy'] or Save
            end
            
            addName='|A:collections-icon-favorites:0:0|a'..(e.onlyChinese and '使用玩具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY))

            ToyButton= WoWTools_ToolsButtonMixin:CreateButton({
                name='UseToy',
                tooltip=addName,
            })

            if ToyButton then
                Set_Alt_Table()                
                Init()--初始
            else
                self:UnregisterEvent('ADDON_LOADED')
            end

        elseif arg1=='Blizzard_Collections' then
            hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_UseToy']=Save
        end
    end
end)