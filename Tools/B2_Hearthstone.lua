local id, e = ...
local addName

local P_Items={
    [142542]=true,--城镇传送之书
    [162973]=true,--冬天爷爷的炉石
    [163045]=true,--无头骑士的炉石
    [165669]=true,--春节长者的炉石
    [165670]=true,--小匹德菲特的可爱炉石
    [165802]=true,--复活节的炉石
    [166746]=true,--吞火者的炉石
    [166747]=true,--美酒节狂欢者的炉石
    [168907]=true,--全息数字化炉石
    [172179]=true,--永恒旅者的炉石
    [188952]=true,--被统御的炉石
    [190196]=true,--开悟者炉石
    [190237]=true,--掮灵传送矩阵
    [193588]=true,--时光旅行者的炉石
    [200630]=true,--欧恩伊尔轻风贤者的炉石, 找不到数据
    [209035]=true,--烈焰炉石
    [212337]=true,--炉之石
    [210455]=true,--德莱尼全息宝石
    [93672]=true,--黑暗之门
    [206195]=true,--纳鲁之路
    [208704]=true,--幽邃住民的土灵炉石
}
local ModifiedTab={
    [6948]='shift',--炉石
    [110560]='ctrl',--要塞炉石
    [140192]='alt',--达拉然炉石
}


local ModifiedMenuTab={
    {type='Alt', itemID=140192},
    {type='Ctrl', itemID=110560},
    {type='Shift', itemID=6948},
}

for itemID in pairs(ModifiedTab) do
    WoWTools_Mixin:Load({id=itemID, type='item'})
end

for itemID in pairs(P_Items) do
    WoWTools_Mixin:Load({id=itemID, type='item'})
end


local Save={
    items=P_Items,
    showBindNameShort=true,
    showBindName=true,
    lockedToy=nil,
}

local ToyButton



















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
    print(e.Icon.icon2.. addName, e.onlyChinese and '移除' or REMOVE, WoWTools_ItemMixin:GetLink(itemID))
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
        WoWTools_SetTooltipMixin:Setup(tooltip, {itemID=desc.data.itemID})--设置，物品，提示
    end
    ToyButton:set_tooltip_location(tooltip)
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
    for itemID in pairs(Save.items) do
        WoWTools_Mixin:Load({id=itemID, type='item'})

        toyName, icon = select(2, C_ToyBox.GetToyInfo(itemID))
        index= index+ 1

        icon= '|T'..(icon or 0)..':0|t'
        name=e.cn(toyName, {itemID=itemID, isName=true})
        if name then
            name=name:match('|c........(.-)|r') or name
        else
            name='itemID '.. itemID
        end

--名称
        local has= PlayerHasToy(itemID)
        local isLoked= Save.lockedToy==itemID
        sub=root:CreateCheckbox(
            (isLoked and '|cnGREEN_FONT_COLOR:' or (has and '' or '|cff9e9e9e'))
            ..index..') '..icon
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
    WoWTools_MenuMixin:SetGridMode(root, index)
end










--#####
--主菜单
--#####
local function Init_Menu(self, root)
    local sub, sub2
    Init_Menu_Toy(self, root)

--选项
    root:CreateDivider()
    sub=WoWTools_ToolsMixin:OpenMenu(root, addName)

    sub2=sub:CreateCheckbox(e.onlyChinese and '绑定位置' or SPELL_TARGET_CENTER_LOC, function()
        return Save.showBindName
    end, function()
        Save.showBindName= not Save.showBindName and true or nil
        self:set_location()--显示, 炉石, 绑定位置
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(ToyButton:get_location())
    end)

    sub2:CreateCheckbox(e.onlyChinese and '截取名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHORT, NAME), function()
        return Save.showBindNameShort
    end, function()
        Save.showBindNameShort= not Save.showBindNameShort and true or nil
        self:set_location()--显示, 炉石, 绑定位置
    end)

--移除未收集
    sub:CreateDivider()
    sub2=sub:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '移除未收集' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REMOVE, NOT_COLLECTED)), function()
        if IsControlKeyDown() then
            local n=0
            for itemID in pairs(Save.items) do
                if not PlayerHasToy(itemID) then
                    Save.items[itemID]=nil
                    n=n+1
                    print(n, e.onlyChinese and '移除' or REMOVE, WoWTools_ItemMixin:GetLink(itemID))
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
            print(e.Icon.icon2.. addName, e.onlyChinese and '全部清除' or CLEAR_ALL)
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
            print(e.Icon.icon2.. addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)
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
end








































--#############
--玩具界面, 按钮
--#############
local function setToySpellButton_UpdateButton(btn)--标记, 是否已选取
    if not btn.hearthstone then
        btn.hearthstone= WoWTools_ButtonMixin:Cbtn(btn,{size=16, texture=134414})
        btn.hearthstone:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT')

        function btn.hearthstone:get_itemID()
            return self:GetParent().itemID
        end
        function btn.hearthstone:set_alpha()
            self:SetAlpha(Save.items[self:get_itemID()] and 1 or 0.1)
        end
        function btn.hearthstone:set_tooltips()
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
            GameTooltip:AddLine(' ')
            local itemID=self:get_itemID()
            local icon= C_Item.GetItemIconByID(itemID)
            GameTooltip:AddDoubleLine(
                (icon and '|T'..icon..':0|t' or '')..(itemID and C_ToyBox.GetToyLink(itemID) or itemID),
                e.GetEnabeleDisable(Save.items[itemID])..e.Icon.left
            )
            GameTooltip:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            GameTooltip:Show()
            self:SetAlpha(1)
        end
        btn.hearthstone:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                Add_Remove_Toy(self:get_itemID())--移除/添加
                self:set_tooltips()
                self:set_alpha()
            else
                MenuUtil.CreateContextMenu(self, Init_Menu_Toy)
            end
        end)
        btn.hearthstone:SetScript('OnLeave', function(self) GameTooltip:Hide() self:set_alpha() end)
        btn.hearthstone:SetScript('OnEnter', btn.hearthstone.set_tooltips)
    end
    btn.hearthstone:set_alpha()
end






















--###
--初始
--###
local function Init()
    for itemID, _ in pairs(Save.items) do
        WoWTools_Mixin:Load({id=itemID, type='item'})
    end

    ToyButton:SetAttribute("type1", "item")
    ToyButton:SetAttribute("Alt-type1", "macro")
    ToyButton:SetAttribute("Shift-type1", "item")
    ToyButton:SetAttribute("Ctrl-type1", "item")

    ToyButton.alt= ToyButton:CreateTexture(nil,'BORDER')--达拉然炉石
    ToyButton.alt:SetSize(10, 10)
    ToyButton.alt:SetPoint('BOTTOMRIGHT',-3,3)
    ToyButton.alt:SetDrawLayer('OVERLAY',2)
    ToyButton.alt:AddMaskTexture(ToyButton.mask)
    ToyButton.alt:SetTexture(1444943)

    ToyButton.ctrl= ToyButton:CreateTexture(nil,'OVERLAY')--要塞炉石
    ToyButton.ctrl:SetSize(10, 10)
    ToyButton.ctrl:SetPoint('BOTTOMLEFT',2,2)
    ToyButton.ctrl:SetDrawLayer('OVERLAY',2)
    ToyButton.ctrl:AddMaskTexture(ToyButton.mask)
    ToyButton.ctrl:SetTexture(1041860)

    ToyButton.shift= ToyButton:CreateTexture(nil,'OVERLAY')--炉石
    ToyButton.shift:SetSize(10, 10)
    ToyButton.shift:SetPoint('TOPLEFT',2,-2)
    ToyButton.shift:SetDrawLayer('OVERLAY',2)
    ToyButton.shift:AddMaskTexture(ToyButton.mask)
    ToyButton.shift:SetTexture(134414)


    ToyButton.textureModifier= ToyButton:CreateTexture(nil, 'OVERLAY', nil, 1)
    ToyButton.textureModifier:SetAllPoints()
    ToyButton.textureModifier:AddMaskTexture(ToyButton.mask)
    ToyButton.textureModifier.Shift= 134414
    ToyButton.textureModifier.Ctrl=1041860
    ToyButton.textureModifier.Alt=1444943

    ToyButton.text=WoWTools_LabelMixin:Create(ToyButton, {size=10, color=true, justifyH='CENTER'})
    ToyButton.text:SetPoint('TOP', ToyButton, 'BOTTOM',0,5)


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
                if type=='alt' then
                    self:SetAttribute("alt-macrotext1",  '/usetoy '..name)
                else
                    self:SetAttribute(type.."-item1",  name)
                end
            else
                self.isAltEvent=true
            end
        end
        if self.isAltEvent then
            self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
        end
    end





    --取得，炉石, 绑定位置
    function ToyButton:get_location()
        return e.cn(GetBindLocation())
    end

    --显示, 炉石, 绑定位置
    function ToyButton:set_location()
        local text
        if Save.showBindName then
            text= self:get_location()
            if text and Save.showBindNameShort then
                text= WoWTools_TextMixin:sub(text, 2, 5)
            end
        end
        self.text:SetText(text or '')
    end

    --提示, 炉石, 绑定位置，文本
    function ToyButton:set_tooltip_location(tooltip)
        if tooltip.textLeft then
            tooltip.textLeft:SetText(self:get_location() or '')
        end
    end

    --CD
    function ToyButton:set_cool()
        e.SetItemSpellCool(self, {item=self.itemID})--主图标冷却
    end







    ToyButton:SetScript('OnEvent', function(self, event, arg1, arg2)
        if event=='ITEM_DATA_LOAD_RESULT' then
            if arg2 then--success then
                if ModifiedTab[arg1] then
                    self:set_alt()
                elseif Save.items[arg1] then
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

        elseif event=='HEARTHSTONE_BOUND' then
            self:set_location()

        elseif event=='UI_MODEL_SCENE_INFO_UPDATED' then
            self.isSelected=nil
            self:Get_Random_Value()

        elseif event=='BAG_UPDATE_COOLDOWN' then
            self:set_cool()

        elseif event=='MODIFIER_STATE_CHANGED' then
            local icon
            if arg2==1 then
                icon = arg1:find('SHIFT') and self.textureModifier.Shift
                    or arg1:find('CTRL') and self.textureModifier.Ctrl
                    or arg1:find('ALT') and self.textureModifier.Alt
                    
            end
            self.textureModifier:SetTexture(icon or 0)
        end
    end)


--Tooltip
    function ToyButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(self.itemID), e.Icon.left)
        GameTooltip:AddLine(' ')
        local name, col
        for _, data in pairs(ModifiedMenuTab) do
            name, col=WoWTools_ItemMixin:GetName(data.itemID)
            col= col or ''
            GameTooltip:AddDoubleLine(col..name, col..data.type..'+'..e.Icon.left)
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        GameTooltip:AddDoubleLine(
            e.onlyChinese and '随机' or 'Random',
            (ToyButton.Locked_Value and '' or '|cnGREEN_FONT_COLOR:#'..#self.Random_List..'|r')
            ..(ToyButton.Selected_Value and '|A:transmog-icon-checkmark:0:0|a' or '')
            ..(ToyButton.Locked_Value and '|A:AdventureMapIcon-Lock:0:0|a' or '')
            ..e.Icon.mid
        )


--发现就绪
        local duration= self.itemID and select(2, C_Item.GetItemCooldown(self.itemID))
        if duration and duration>3 then
            local itemID= get_not_cooldown_toy()
            if itemID then
                GameTooltip:AddDoubleLine(
                    '|T'..(C_Item.GetItemIconByID(itemID) or 0)..':32|t|cnGREEN_FONT_COLOR:'
                    ..(e.onlyChinese and '发现就绪' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BATTLE_PET_SOURCE_11, READY)),
                    e.Icon.right
                )
            end
        end

        GameTooltip:Show()

        self:set_tooltip_location(GameTooltip)
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
            local itemID= get_not_cooldown_toy()--发现就绪
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
        self:Get_Random_Value()
    end)

    ToyButton:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    ToyButton:SetScript("OnMouseUp", function(self, d)
        self:Get_Random_Value()
    end)
    ToyButton:SetScript('OnMouseWheel', function(self)
        self.Selected_Value=nil
        self:Get_Random_Value()
    end)











    Mixin(ToyButton, WoWTools_RandomMixin)

    function ToyButton:Get_Random_Data()--取得数据库, {数据1, 数据2, 数据3, ...}
        local tab={}
        for itemID in pairs(Save.items) do
            if PlayerHasToy(itemID) then
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
        self.texture:SetTexture(C_Item.GetItemIconByID(itemID) or 134414)
        self:set_cool()
    end
    function ToyButton:Set_OnlyOneValue_Random()--当数据 <=1 时，设置值
        self:Set_Random_Value(self.Selected_Value or self.Locked_Value or self.Random_List[1] or 6948)
    end

    ToyButton:Init_Random(Save.lockedToy)--初始








    function ToyButton:set_event()
        if self:IsVisible() then
            self:RegisterEvent('HEARTHSTONE_BOUND')
            self:RegisterEvent('TOYS_UPDATED')
            self:RegisterEvent('NEW_TOY_ADDED')
            self:RegisterEvent('UI_MODEL_SCENE_INFO_UPDATED')
            self:RegisterEvent('BAG_UPDATE_COOLDOWN')
            self:RegisterEvent('MODIFIER_STATE_CHANGED')
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
        ToyButton:set_location()
        ToyButton:Get_Random_Value()
    end)
end


























--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('PLAYER_LOGIN')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then

            Save= WoWToolsSave['Tools_Hearthstone'] or Save
            addName='|A:delves-bountiful:0:0|a'..(e.onlyChinese and '炉石' or TUTORIAL_TITLE31)

            ToyButton= WoWTools_ToolsMixin:CreateButton({
                name='Hearthstone',
                tooltip=addName,
            })

            if not ToyButton then
                self:UnregisterEvent(event)
                self:UnregisterEvent('PLAYER_LOGIN')
            end
        elseif arg1=='Blizzard_Collections' then
            hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_LOGIN' then
        Init()--初始
        self:UnregisterEvent(event)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_Hearthstone']=Save
        end
    end
end)