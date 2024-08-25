local id, e = ...
local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY)
local panel= CreateFrame('Frame')
local ToyButton
local ItemsTab={}--存放有效

local P_Items= {
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

local Save={
    items=P_Items,
}

local ModifiedTab={
    alt=69775,--[维库饮水角]
    shift=134032,--[精英旗帜]
    ctrl=109183,--[世界缩小器]
}
for _, itemID in pairs(ModifiedTab) do
    e.LoadDate({id=itemID, type='item'})
end



























--#########
--主图标冷却
--#########
local function setCooldown()--主图标冷却
    if ToyButton:IsShown() then
        e.SetItemSpellCool(ToyButton, {item=ToyButton.itemID})--冷却条
    end
end

local function getToy()--生成, 有效表格
    ItemsTab={}
    for itemID ,_ in pairs(Save.items) do
        e.LoadDate({id=itemID, type='item'})
        if not e.Player.husandr and PlayerHasToy(itemID) then
            table.insert(ItemsTab, itemID)
        end
    end
end

local function setAtt(set)--设置属性
    if not ToyButton:IsVisible() or UnitAffectingCombat('player') or (GameTooltip:IsOwned(ToyButton) and not set) then
        return
    end

    local icon
    local tab={}

    for _, itemID in pairs(ItemsTab) do
        local duration = select(2 ,C_Item.GetItemCooldown(itemID))
        if (duration and duration<2) and C_ToyBox.IsToyUsable(itemID) then
            table.insert(tab, itemID)
        end
    end

    local num=#tab
    ToyButton.count:SetText(num)
    if num>0 then
        local itemID=tab[math.random(1, num)]
        if itemID then
            icon = C_Item.GetItemIconByID(itemID)
            if icon then
                ToyButton.texture:SetTexture(icon)
            end
            local  name= select(2, C_ToyBox.GetToyInfo(itemID)) or C_Item.GetItemNameByID(itemID) or itemID
            ToyButton:SetAttribute('item1', name)
            ToyButton.itemID=itemID
        end
    else
        ToyButton:SetAttribute('item1', nil)
        ToyButton.itemID=nil
    end
    setCooldown()--主图标冷却
    ToyButton.texture:SetShown(icon)
end

local function getAllSaveNum()--Save中玩具数量
    local num=0
    for _ in pairs(Save.items) do
        num= num +1
    end
    return num
end






























--玩具界面, 菜单, --标记, 是否已选取
function Init_SetButtonOption()
    hooksecurefunc('ToySpellButton_UpdateButton', function(btn)
        if btn.toy then
            btn.toy:set_alpha()
            return
        end
        btn.toy= e.Cbtn(btn,{size={16,16}, texture=133567})
        btn.toy:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT', 16,0)
        function btn.toy:get_itemID()
            return self:GetParent().itemID
        end
        function btn.toy:set_alpha()
            self:SetAlpha(Save.items[self:get_itemID()] and 1 or 0.1)
        end

        function btn.toy:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.addName, 'Tools |T133567:0|t'..(e.onlyChinese and '随机玩具' or addName))
            e.tips:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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

        btn.toy:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                local itemID=self:get_itemID()
                Save.items[itemID]= not Save.items[itemID] and true or nil
                getToy()--生成, 有效表格
                setAtt()--设置属性
                self:set_tooltips()
                self:set_alpha()
            else
                e.LibDD:ToggleDropDownMenu(1, nil, ToyButton.Menu, self, 15, 0)
            end
        end)
        btn.toy:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha() end)
        btn.toy:SetScript('OnEnter', btn.toy.set_tooltips)

    end)
end


































--######
--快捷键
--######
local function set_KEY()--设置捷键
    if Save.KEY then
        e.SetButtonKey(ToyButton, true, Save.KEY)
        if #Save.KEY==1 then
            if not ToyButton.KEY then
                ToyButton.KEYstring=e.Cstr(ToyButton, {size=10, color=true})--10, nil, nil, true, 'OVERLAY')
                ToyButton.KEYstring:SetPoint('BOTTOMRIGHT', ToyButton.border, 'BOTTOMRIGHT',-4,4)
            end
            ToyButton.KEYstring:SetText(Save.KEY)
            if ToyButton.KEYtexture then
                ToyButton.KEYtexture:SetShown(false)
            end
        else
            if not ToyButton.KEYtexture then
                ToyButton.KEYtexture=ToyButton:CreateTexture(nil,'OVERLAY')
                ToyButton.KEYtexture:SetPoint('BOTTOM', ToyButton.border,'BOTTOM',-1,-5)
                ToyButton.KEYtexture:SetAtlas('NPE_ArrowDown')
                if not e.Player.useColor then
                    ToyButton.KEYtexture:SetDesaturated(true)
                end
                ToyButton.KEYtexture:SetSize(20,15)
            end
            ToyButton.KEYtexture:SetShown(true)
        end
    else
        e.SetButtonKey(ToyButton)
        if ToyButton.KEYstring then
            ToyButton.KEYstring:SetText('')
        end
        if ToyButton.KEYtexture then
            ToyButton.KEYtexture:SetShown(false)
        end
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
    local cd = select(2, C_Item.GetItemCooldown(ToyButton.itemID)) or 0
    if cd>3 then
        for itemID in pairs(P_Items) do
            if PlayerHasToy(itemID) and select(2, C_Item.GetItemCooldown(itemID))<3 then
                return itemID
            end
        end
    end
end










local ModifiedTab={
    [6948]='Shift',--炉石
    [110560]='Ctrl',--要塞炉石
    [140192]='Alt',--达拉然炉石
}

local ModifiedMenuTab={
    {type='Alt', itemID=140192, col=function() return (PlayerHasToy(140192) and C_ToyBox.IsToyUsable(140192)) and '' or '|cff9e9e9e' end},
    {type='Ctrl', itemID=110560, col=function() return (PlayerHasToy(110560) and C_ToyBox.IsToyUsable(110560)) and '' or '|cff9e9e9e' end},
    {type='Shift', itemID=6948, col=function() return C_Item.GetItemCount(6948)==0 and '|cff9e9e9e' or '' end},
}

for itemID in pairs(ModifiedTab) do
    e.LoadDate({id=itemID, type='item'})
end

for itemID in pairs(P_Items) do
    e.LoadDate({id=itemID, type='item'})
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
    WoWTools_MenuMixin:SetNumButton(root, index)
end










--#####
--主菜单
--#####
local function Init_Menu(self, root)
    local sub, sub2
    --[[sub= root:CreateButton(
        addName..' '..ToyButton.Random_Numeri,
        set_ToggleCollectionsJournal,
        {}
    )
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText(e.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
    end)]]

    Init_Menu_Toy(self, root)

--选项
    root:CreateDivider()
    sub=WoWTools_ToolsButtonMixin:OpenMenu(root, addName)

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

--[[位于上方
    WoWTools_MenuMixin:ToTop(sub, {
        name=nil,
        GetValue=function()
            return Save.toFrame
        end,
        SetValue=function()
            Save.toFrame = not Save.toFrame and true or nil
            WoWTools_ToolsButtonMixin:RestAllPoint()--重置所有按钮位置
        end,
        tooltip=nil,
        isReload=false,--重新加载UI
    })
]]
--移除未收集
    sub:CreateDivider()
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
end













--#####
--主菜单
--#####
function Init_Menu(_, root)
    
end
local function InitMenu(_, level, menuList)--主菜单
    local info
    if menuList=='TOY' then
        for _, itemID in pairs(ItemsTab) do
            local _, toyName, icon = C_ToyBox.GetToyInfo(itemID)
            info={
                text= toyName or itemID,
                icon= icon or C_Item.GetItemIconByID(itemID),
                colorCode=not PlayerHasToy(itemID) and '|cff9e9e9e',
                keepShownOnClick=true,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '添加/移除' or (ADD..'/'..REMOVE),
                tooltipText= (e.onlyChinese and '藏品->玩具箱' or (COLLECTIONS..'->'..TOY_BOX))..e.Icon.left,
                arg1= itemID,
                func=function(_, arg1)
                    if ToyBox and not ToyBox:IsVisible() then
                        ToggleCollectionsJournal(3)
                    end
                    local name= arg1 and select(2, C_ToyBox.GetToyInfo(arg1))
                    if name then
                        C_ToyBoxInfo.SetDefaultFilters()
                        if ToyBox.searchBox then
                            ToyBox.searchBox:SetText(name)
                        end
                    end
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={--清除
            text='|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..(e.onlyChinese and '玩具' or TOY)..'|r '..#ItemsTab..'/'..getAllSaveNum(),
            icon= 'bags-button-autosort-up',
            keepShownOnClick=true,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '清除全部' or CLEAR_ALL,
            func=function ()
                StaticPopup_Show(id..addName..'RESETALL')
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif menuList=='notTOY' then
        local num=0
        for itemID, _ in pairs(Save.items) do
            if not PlayerHasToy(itemID) then
                local _, toyName, icon = C_ToyBox.GetToyInfo(itemID)
                info={
                    text= toyName or itemID,
                    icon= icon or C_Item.GetItemIconByID(itemID),
                    colorCode='|cff9e9e9e',
                    notCheckable=true,
                    keepShownOnClick=true,
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '添加/移除' or (ADD..'/'..REMOVE),
                    tooltipText= (e.onlyChinese and '藏品->玩具箱' or (COLLECTIONS..'->'..TOY_BOX))..e.Icon.left,
                    arg1= itemID,
                    func=function(_, arg1)
                        if ToyBox and not ToyBox:IsVisible() then
                            ToggleCollectionsJournal(3)
                        end
                        local name= arg1 and select(2, C_ToyBox.GetToyInfo(arg1))
                        if name then
                            C_ToyBoxInfo.SetDefaultFilters()
                            if ToyBox.searchBox then
                                ToyBox.searchBox:SetText(name)
                            end
                        end
                    end,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                num=num+1
            end
        end

        if num>0 then
            e.LibDD:UIDropDownMenu_AddSeparator(level)
        end
        info={
            text= '|cnRED_FONT_COLOR:#'..num..' '..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..' ('..(e.onlyChinese and '未收集' or NOT_COLLECTED)..')',
            icon= 'bags-button-autosort-up',
            notCheckable=true,
            func= function()
                local num2=0
                for itemID, _ in pairs(Save.items) do
                    if not PlayerHasToy(itemID) then
                        Save.items[itemID]= nil
                        num2= num2+1
                    end
                end
                print(e.addName, e.cn(addName), e.onlyChinese and '未收集' or NOT_COLLECTED, '|cnRED_FONT_COLOR:#'..num2..'|r', e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif menuList=='SETTINGS' then--设置菜单
        info={--快捷键,设置对话框
            text= e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL,--..(Save.KEY and ' |cnGREEN_FONT_COLOR:'..Save.KEY..'|r' or ''),
            checked=Save.KEY and true or nil,
            disabled=UnitAffectingCombat('player'),
            keepShownOnClick=true,
            func=function()
                StaticPopupDialogs[id..addName..'KEY']={--快捷键,设置对话框
                    text=id..' '..addName..'|n'..(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)..'|n|nQ, BUTTON5',
                    whileDead=true, hideOnEscape=true, exclusive=true,
                    hasEditBox=true,
                    button1= e.onlyChinese and '设置' or SETTINGS,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    button3= e.onlyChinese and '取消' or REMOVE,
                    OnShow = function(self2, data)
                        self2.editBox:SetText(Save.KEY or ';')
                        if Save.KEY then
                            self2.button1:SetText(e.onlyChinese and '修改' or EDIT)--修该
                        end
                        self2.button3:SetEnabled(Save.KEY and true or false)
                    end,
                    OnHide= function(self2)
                        self2.editBox:SetText("")
                        e.call(ChatEdit_FocusActiveWindow)
                    end,
                    OnAccept = function(self2, data)
                        local text= self2.editBox:GetText()
                        text=text:gsub(' ','')
                        text=text:gsub('%[','')
                        text=text:gsub(']','')
                        text=text:upper()
                        Save.KEY=text
                        set_KEY()--设置捷键
                    end,
                    OnAlt = function()
                        Save.KEY=nil
                        set_KEY()--设置捷键
                    end,
                    EditBoxOnTextChanged=function(self2, data)
                        local text= self2:GetText()
                        text=text:gsub(' ','')
                        self2:GetParent().button1:SetEnabled(text~='')
                    end,
                    EditBoxOnEscapePressed = function(s)
                        s:SetAutoFocus(false)
                        s:ClearFocus()
                        s:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'KEY')
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)


        info={--重置所有
            text= e.onlyChinese and '重置' or RESET,
            colorCode="|cffff0000",
            notCheckable=true,
            keepShownOnClick=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT,
            func=function ()
                StaticPopup_Show(id..addName..'RESETALL')
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    info={
        text='|cnGREEN_FONT_COLOR:'..#ItemsTab..'|r '..(e.onlyChinese and '玩具' or TOY),
        notCheckable=true,
        menuList='TOY',
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text=e.onlyChinese and '未收集' or NOT_COLLECTED,
        notCheckable=true,
        menuList='notTOY',
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    -- e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text=Save.KEY or (e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL),
        notCheckable=true,
        menuList='SETTINGS',
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end







--#############
--玩具界面, 按钮
--#############
local function setToySpellButton_UpdateButton(btn)--标记, 是否已选取
    if not btn.toy then
        btn.toy= e.Cbtn(btn,{size={16,16}, texture=133567})
        btn.toy:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT', 16, 0)

        function btn.toy:get_itemID()
            return self:GetParent().itemID
        end
        function btn.toy:set_alpha()
            self:SetAlpha(Save.items[self:get_itemID()] and 1 or 0.1)
        end
        function btn.toy:set_tooltips()
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
        btn.toy:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                Add_Remove_Toy(self:get_itemID())--移除/添加
                self:set_tooltips()
                self:set_alpha()
            else
                MenuUtil.CreateContextMenu(self, Init_Menu_Toy)
            end
        end)
        btn.toy:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha() end)
        btn.toy:SetScript('OnEnter', btn.toy.set_tooltips)
    end
    btn.toy:set_alpha()
end






































local function Init()

    ToyButton:SetAttribute("type1", "item")
    ToyButton:SetAttribute("alt-type1", "item")
    ToyButton:SetAttribute("shift-type1", "item")
    ToyButton:SetAttribute("ctrl-type1", "item")

    ToyButton.alt= ToyButton:CreateTexture(nil,'OVERLAY')--达拉然炉石
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



    ToyButton.text=e.Cstr(ToyButton, {size=10, color=true, justifyH='CENTER'})--10, nil, nil, true, nil, 'CENTER')
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
                self:SetAttribute(type.."-item1",  name)
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
                text= e.WA_Utf8Sub(text, 2, 5)
            end
        end
        self.text:SetText(text or '')
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

        elseif event=='HEARTHSTONE_BOUND' then
            self:set_location()

        elseif event=='UI_MODEL_SCENE_INFO_UPDATED' then
            self.isSelected=nil
            self:Get_Random_Value()

        elseif event=='BAG_UPDATE_COOLDOWN' then
            self:set_cool()
        end
    end)


--Tooltip
    function ToyButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_SpellItemMixin:GetName(nil, self.itemID), e.Icon.left)
        e.tips:AddLine(' ')
        local name, col
        for _, data in pairs(ModifiedMenuTab) do
            name, col=WoWTools_SpellItemMixin:GetName(nil, data.itemID)
            e.tips:AddDoubleLine(data.col()..name, (col or '')..data.type..'+'..e.Icon.left)
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
        if select(2, C_Item.GetItemCooldown(self.itemID))>3 then
            local itemID= get_not_cooldown_toy()
            if itemID then
                e.tips:AddDoubleLine(
                    '|T'..(C_Item.GetItemIconByID(itemID) or 0)..':32|t|cnGREEN_FONT_COLOR:'
                    ..(e.onlyChinese and '发现就绪' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BATTLE_PET_SOURCE_11, READY)),
                    e.Icon.right
                )
            end
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
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            if WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY)] then
                Save= WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY)]
                WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY)]=nil
            else
                Save= WoWToolsSave['Tools_UseToy'] or Save
            end

            ToyButton= WoWTools_ToolsButtonMixin:CreateButton({
                name='UseToy',
                tooltip='|A:collections-icon-favorites:0:0|a'..(e.onlyChinese and '使用玩具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY)),
            })
            if ToyButton then                
                Init()--初始
            else
                self:UnregisterEvent('PLAYER_LOGOUT')
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