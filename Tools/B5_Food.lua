local id, e = ...
local addName
local Save={
    noUseItems={},--禁用物品
    --autoLogin= e.Player.husandro,--启动,查询
    onlyMaxExpansion=true,--仅本版本物品
    olnyUsaItem=true,
    numLine=2,
    autoWho=e.Player.husandro,
    class={
        [0]={
            [1]=true,--药水
            [2]=true,--药剂
            [3]=true,--合计
            [5]=true,--食物
            [7]=e.Is_Timerunning,
            [8]=e.Is_Timerunning,--其它
        }
    },
    addItems={
        [113509]=true,--魔法汉堡
        [80610]=true,--魔法布丁
        [65499]=true,--魔法蛋糕
        [43523]=true,--魔法酪饼
        [43518]=true,--魔法馅饼
    },
    DisableClassID={
        [1]=true,
        [3]=true,
        [5]=true,
        [6]=true,
        [7]=true,
        [8]=true,
        [9]=true,
        [10]=true,
        [11]=true,
        [12]=true,
        [13]=true,
        [14]=true,
        [16]=true,
        [18]=true,
        [17]=true,
        [19]=true,
    }
}

local panel= CreateFrame("Frame")
local Buttons={}
local UseButton

local PaneIDs={
    [113509]=true,--魔法汉堡
    [80610]=true,--魔法布丁
    [65499]=true,--魔法蛋糕
    [43523]=true,--魔法酪饼
    [43518]=true,--魔法馅饼
}










local function Get_Item_Valid(itemID)
    if itemID
        and itemID~=UseButton.itemID
        and not Save.noUseItems[itemID]
        and not Save.addItems[itemID]
        and (Save.olnyUsaItem and C_Item.GetItemSpell(itemID) or not Save.olnyUsaItem)
    then
        local classID, subClassID, _, expacID = select(12, C_Item.GetItemInfo(itemID))
        if Save.class[classID]
            and Save.class[classID][subClassID]
            and (e.Is_Timerunning
                    or (Save.onlyMaxExpansion
                        and (PaneIDs[itemID] or e.ExpansionLevel==expacID)
                        or not Save.onlyMaxExpansion
                    )
                )
        then
            return classID, subClassID
        end
    end
end















local function Set_Button_Function(btn)
    btn:SetAttribute("type1", "item")
    btn.count= e.Cstr(btn, {size=12, color={r=1,g=1,b=1}})--10, nil,nil, true)
    btn.count:SetPoint('BOTTOMRIGHT', -4,4)
    btn.numCount=0
    btn.enableCooldown=true

    function btn:set_attribute()
        local icon= C_Item.GetItemIconByID(self.itemID)
        local name=  C_Item.GetItemNameByID(self.itemID)
        self.texture:SetTexture(icon or 0)

        if not icon or not name then
            self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
        end

        if self:CanChangeAttribute() then
            self:SetAttribute("item1", name)
        else
            self.isSetAttributeInCombat=true
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
    end

    function btn:set_cool()
        local start, duration, enable = C_Container.GetItemCooldown(self.itemID)
        e.Ccool(self, start, duration, nil, true, nil, true)--冷却条
        btn.enableCooldown= enable
    end

    function btn:set_alpha(alpha)
        alpha= alpha or (self.numCount>0 and 1) or 0.3
        self.border:SetAlpha(alpha)
        self.texture:SetAlpha(alpha)
    end

    function btn:set_count()
        local num= C_Item.GetItemCount(self.itemID, false, true, true, false)--  false, true, true)
        self.count:SetText(num==0 and '|cff9e9e9e0|r' or (num~=1 and num) or '')
        self.numCount=num
        self:set_alpha()
    end


    function btn:set_desaturated()
        self.texture:SetDesaturated(not self.enableCooldown or self.numCount==0)
    end

    function btn:settings()
        self:set_attribute()
        do
            self:set_cool()
            self:set_count()
        end
        self:set_desaturated()
    end
end



















local function Create_Button(index)
    local btn= Button_Mixin:CreateSecure({parent=UseButton, setID=index})

    Set_Button_Function(btn)

    function btn:set_event()
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        self:RegisterEvent('BAG_UPDATE_COOLDOWN')
    end

    btn:SetScript("OnEvent", function(self, event, arg1, arg2)
        if event=='BAG_UPDATE_DELAYED' then
            self:set_count()
            self:set_desaturated()

        elseif event=='BAG_UPDATE_COOLDOWN' then
            self:set_cool()
            self:set_desaturated()

        elseif event=='GET_ITEM_INFO_RECEIVED' then
            if arg1==self.itemID and arg2 then
                self:set_attribute()
                self:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
            end

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:set_attribute()
            self.isSetAttributeInCombat=nil
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end)


    btn:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        WoWTools_BagMixin:Find()
        self:set_alpha()
    end)

    btn:SetScript('OnEnter', function(self)
        local isInCombat= UnitAffectingCombat('player')
        WoWTools_SpellItemMixin:SetTooltip(e.tips, {
            itemID=self.itemID,
            tooltip='|n|A:dressingroom-button-appearancelist-up:0:0|a'
                ..(isInCombat and '|cff9e9e9e' or '')
                ..(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..e.Icon.right,
        }, nil, self)
        if not isInCombat then
            self:settings()
        end
        self:set_alpha(1)
        WoWTools_BagMixin:Find(true, {itemID= self.itemID})--查询，背包里物品
    end)

    btn:SetScript('OnMouseDown',function(self, d)
        if UnitAffectingCombat('player') then
            return
        end
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, function(f, root)
                root:CreateButton('|T'..(C_Item.GetItemIconByID(f.itemID) or 0)..':0|t'..(e.onlyChinese and '禁用' or DISABLE), function()
                    Save.noUseItems[self.itemID]=true
                    Save.addItems[self.itemID]=nil
                    print(e.addName, addName, e.onlyChinese and '禁用' or DISABLE, WoWTools_ItemMixin:GetLink(self.itemID))
                    UseButton:Check_Items()
                end)
            end)
        end
    end)

    function btn:set_point()
        self:ClearAllPoints()
        self:SetPoint('RIGHT', Buttons[self:GetID()-1] or UseButton, 'LEFT')
        --[[local index2= self:GetID()
        local  num= Save.numLine

        if index2==1 then
            self:SetPoint('RIGHT', UseButton, 'LEFT')--位置

        elseif index2<=num and select(2, math.modf(index2/num))==0 then
            self:SetPoint('RIGHT', Buttons[index2-1] or UseButton, 'LEFT')
        else
            self:SetPoint('BOTTOM', Buttons[index2- num-1] or UseButton, 'TOP')
        end]]
    end
    table.insert(Buttons, btn)--添加

    btn:set_event()
    return btn
end





























local function Check_All_SubClass(setClassID)
    Save.class[setClassID]= Save.class[setClassID] or {}
    for subClassID= 0, 20 do
        local subClass=C_Item.GetItemSubClassInfo(setClassID, subClassID)
        if subClass then
            Save.class[setClassID][subClassID]=true
        else
            break
        end
    end
end








local function Check_All_Menu(self, root, setClassID)
    root:CreateDivider()
    local sub=root:CreateButton(e.onlyChinese and '勾选所有' or CHECK_ALL, function(data)
        if IsControlKeyDown() or data.classID then
            do
                if data.classID then
                    Check_All_SubClass(data.classID)
                else
                    Save.class={}
                    for classID=0, 20 do
                        if not Save.DisableClassID[classID] then
                            class= C_Item.GetItemClassInfo(classID)
                            if class then
                                Save.class[classID]= {}
                                Check_All_SubClass(classID)
                            else
                                break
                            end
                        end
                    end
                end
            end
            self:Check_Items()
        end
        return MenuResponse.Refresh
    end, {classID=setClassID})
    if not setClassID then
        sub:SetTooltip(function(tooltip) tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left) end)
    end

    --撤选所有
    sub=root:CreateButton(e.onlyChinese and '撤选所有' or UNCHECK_ALL, function(data)
        if IsControlKeyDown() or data.classID then
            if data.classID then
                Save.class[data.classID]= nil
            else
                Save.class={}
            end
            self:Check_Items()
        end
        return MenuResponse.Refresh
    end, {classID=setClassID})
    if not setClassID then
        sub:SetTooltip(function(tooltip) tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left) end)
    end
end


















--#####
--主菜单
--#####
local function Init_Menu(self, root)
    if UnitAffectingCombat('player') then
        root:CreateTitle(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

    local sub, sub2, sub3, class, subClass, find
    local items={
        --[classID]={num=0,[subClassID]=0}
    }
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info= C_Container.GetContainerItemInfo(bag, slot) or {}
            local classID, subClassID= Get_Item_Valid(info.itemID)
            if classID and subClassID then
                local num= info.stackCount or 1
                items[classID]= items[classID] or {num=0}--class
                items[classID].num= items[classID].num+ num
                items[classID][subClassID]= (items[classID][subClassID] or 0)+ num--subClass
            end
        end
    end

--查找
    sub=root:CreateButton('|cnGREEN_FONT_COLOR:|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '查找' or WHO).. e.Icon.mid, function()
        self:Check_Items(true)
    end)

--隐藏
    sub2=sub:CreateButton(e.onlyChinese and '隐藏' or HIDE, function() return MenuResponse.Open end)
    for classID=0, 20 do
        class= C_Item.GetItemClassInfo(classID)
        if class then
            sub2:CreateCheckbox(classID..' '..e.cn(class)..' '..(items[classID] and items[classID].num or ''), function(data)
                return Save.DisableClassID[data.classID]
            end, function(data)
                Save.DisableClassID[data.classID]= not Save.DisableClassID[data.classID] and true or nil
                self:Check_Items()
                return MenuResponse.Refresh
            end, {classID=classID})
        end
    end

--禁用
    sub2=sub:CreateButton(e.onlyChinese and '禁用' or DISABLE, function() return MenuResponse.Open end)
    find=0
    for itemID in pairs(Save.noUseItems) do
        find=find+1
        sub3=sub2:CreateCheckbox(find..') '..WoWTools_SpellItemMixin:GetName(nil, itemID), function(data)
            return Save.noUseItems[data.itemID]
        end, function(data)
            Save.noUseItems[data.itemID]= not Save.noUseItems[data.itemID] and true or nil
            self:Check_Items()
        end, {itemID=itemID})
        WoWTools_SpellItemMixin:SetTooltip(nil, nil, sub3, nil)
    end
    if find>1 then
        sub2:CreateDivider()
        sub2:CreateButton(e.onlyChinese and '全部清除' or CLEAR_ALL, function()
            Save.noUseItems={}
            self:Check_Items()
        end)
        WoWTools_MenuMixin:SetNumButton(sub2, find)
    end


--登录游戏时: 查找
    sub:CreateDivider()
    sub2=sub:CreateCheckbox(e.onlyChinese and '登录游戏时: 查找' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_TWITTER_SIGN_IN, GAME)..': '..WHO, function()
        return Save.autoLogin
    end, function()
        Save.autoLogin= not Save.autoLogin and true or nil
        if Save.autoLogin then
            self:Check_Items()
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '自动查找' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, WHO))
    end)

--自动查找
    sub2=sub:CreateCheckbox(e.onlyChinese and '自动查找' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, UPDATE), function()
        return Save.autoWho
    end, function()
        Save.autoWho= not Save.autoWho and true or nil
        if Save.autoWho then
            self:Check_Items()
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '事件' or EVENTS_LABEL)
        tooltip:AddLine('BAG_UPDATE_DELAYED')
        tooltip:AddLine(' ')
        GameTooltip_AddErrorLine(tooltip, e.onlyChinese and '高CPU' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIGH, 'CPU'))
    end)

--仅当前版本物品
    if not e.Is_Timerunning then--时光
        sub:CreateCheckbox(e.onlyChinese and '仅当前版本物品' or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, GAME_VERSION_LABEL)), function()
            return Save.onlyMaxExpansion
        end, function()
            Save.onlyMaxExpansion= not Save.onlyMaxExpansion and true or nil
            self:Check_Items()
        end)
    end

--仅限 C_Item.GetItemSpell(itemID)
    sub2=sub:CreateCheckbox(e.onlyChinese and '可使用' or format(LFG_LIST_CROSS_FACTION, USE), function()
        return Save.olnyUsaItem
    end, function()
        Save.olnyUsaItem= not Save.olnyUsaItem and true or nil
        self:Check_Items()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('C_Item.GetItemSpell(itemID)')
    end)
--缩放
    sub:CreateDivider()
    sub2=select(2, WoWTools_MenuMixin:Scale(sub, function()
        return Save.scale or 1
    end, function(value)
        Save.scale= value
        self:set_scale()
    end))

    sub:CreateButton(
        (not Save.point and '|cff9e9e9e' or '')
        ..(e.onlyChinese and '还原位置' or RESET_POSITION),
    function()
        if not UnitAffectingCombat('player') then
            Save.point=nil
            self:set_point()
        end
    end )

    sub2= select(2, WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save.strata= data
        self:set_strata()
    end))

    sub2=sub:CreateButton(e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS, function()return MenuResponse.Open end)
    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save.numLine
        end, setValue=function(value)
            Save.numLine=value
            UseButton:Check_Items()
        end,
        --name=,
        minValue=1,
        maxValue=60,
        step=1,
        bit=nil,
    })
    sub2:CreateSpacer()





--自定义
    sub=root:CreateButton(e.onlyChinese and '自定义' or CUSTOM, function() return MenuResponse.Open end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '拖曳物品添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS, ADD)))
    end)

    find=0
    for itemID in pairs(Save.addItems) do
        find=find+1
        sub2=sub:CreateCheckbox(find..') '..WoWTools_SpellItemMixin:GetName(nil, itemID), function(data)
            return Save.addItems[data.itemID]
        end, function(data)
            Save.addItems[data.itemID]= not Save.addItems[data.itemID] and true or nil
            self:Check_Items()
        end, {itemID=itemID})
        WoWTools_SpellItemMixin:SetTooltip(nil, nil, sub2, nil)
    end
    if find>1 then
        sub:CreateDivider()
        sub:CreateButton(e.onlyChinese and '全部清除' or CLEAR_ALL, function()
            Save.addItems={}
            self:Check_Items()
        end)
        WoWTools_MenuMixin:SetNumButton(sub, find)
    end

--总是显示
    sub:CreateCheckbox(e.onlyChinese and '总是显示' or BATTLEFIELD_MINIMAP_SHOW_ALWAYS, function()
        return Save.addItemsShowAll
    end, function()
        Save.addItemsShowAll= not Save.addItemsShowAll and true or nil
    end)


    find=nil
    for classID=0, 20 do
        if not Save.DisableClassID[classID] then
            class= C_Item.GetItemClassInfo(classID)
            if class then
                if not find then
                    root:CreateDivider()
                    find=true
                end

                sub=root:CreateCheckbox(classID..' '..e.cn(class)..' '..(items[classID] and items[classID].num or ''), function(data)
                    return Save.class[data.classID]
                end, function(data)
                    if Save.class[data.classID] then
                        Save.class[data.classID]= nil
                    else
                        Save.class[data.classID]= Save.class[data.classID] or {}
                        for i=0, 20 do
                            local name= C_Item.GetItemSubClassInfo(data.classID, i)
                            if name and name~='' then
                                Save.class[data.classID][i]=true
                            end
                        end
                    end
                    self:Check_Items()
                end, {classID=classID})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine(
                        Save.class[description.data.classID]
                        and (e.onlyChinese and '撤选所有' or UNCHECK_ALL)
                        or (e.onlyChinese and '勾选所有' or CHECK_ALL)
                    )
                end)



                for subClassID= 0, 20 do
                    subClass=C_Item.GetItemSubClassInfo(classID, subClassID)
                    if subClass and subClass~='' then
                        sub:CreateCheckbox(
                            subClassID..' '..e.cn(subClass)..' '
                            ..(items[classID] and items[classID][subClassID] or ''),
                        function(data)
                            return Save.class[data.classID] and Save.class[data.classID][data.subClassID]
                        end, function(data)
                            if Save.class[data.classID] and Save.class[data.classID][data.subClassID] then
                                Save.class[data.classID][data.subClassID]=nil
                            else
                                Save.class[data.classID]= Save.class[data.classID] or {}
                                Save.class[data.classID][data.subClassID]= true
                            end
                            self:Check_Items()
                        end, {classID=classID, subClassID=subClassID})
                    else
                        break
                    end
                end

                Check_All_Menu(self, sub, classID)
            else
                break
            end
        end
    end

    Check_All_Menu(self, root, nil)
end

























local function Add_Item(info)
    local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(info.itemLink or info.itemID)
    StaticPopup_Show('WoWTools_Item', addName, nil, {
        link= info.itemLink or itemLink,
        itemID=info.itemID,
        name= e.cn(itemName, {itemID=info.itemID, isName=true}),
        color= {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()},
        texture= itemTexture,
        count=C_Item.GetItemCount(info.itemID, true, true, true, true),
        OnShow=function(self, data)
           self.button1:SetEnabled(not Save.addItems[data.itemID])
           self.button3:SetEnabled(Save.addItems[data.itemID])
        end,
        SetValue = function(_, data)
            Save.addItems[data.itemID]= true
            UseButton:Check_Items()
        end,
        OnAlt = function(_, data)
            Save.addItems[data.itemID]= nil
            UseButton:Check_Items()
        end
    })
end
















--####
--初始
--####
local function Init()
    UseButton.RePoint={UseButton:GetPoint(1)}
    UseButton.texture:SetTexture(538745)

    function UseButton:Check_Items(isPrint)--检查,物品
        if self.isChecking then--正在查询
            return
        elseif not self:CanChangeAttribute() then
            self.isCheckInCombat=true
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end
        self.isChecking=true



        local new={}
        local items={}
        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local itemID= C_Container.GetContainerItemID(bag, slot)
                if Get_Item_Valid(itemID) then
                    items[itemID]=true
                end
            end
        end
        for itemID in pairs(items) do
            table.insert(new, itemID)
        end
        table.sort(new)

        items={}
        for itemID in pairs(Save.addItems) do
            if Save.addItemsShowAll or C_Item.GetItemCount(itemID, false, true, true, false)>0 then
                table.insert(items, itemID)
            end
        end
        table.sort(items)
        for _, itemID in pairs(items) do
            table.insert(new, 1, itemID)
        end

        local index=0
        for _, itemID in pairs(new) do
            index= index +1
            local btn= Buttons[index] or Create_Button(index)--创建            
            btn.itemID= itemID
            btn:settings()
            btn:set_point()
            if not btn:IsShown() then
                btn:set_event()
                btn:Show()
            end
        end

        for i=Save.numLine, index, Save.numLine do
            local btn= Buttons[i]
            if btn then
                btn:ClearAllPoints()
                btn:SetPoint('BOTTOM', Buttons[i-Save.numLine] or UseButton, 'TOP')
            end
        end


        for i= index , #Buttons do
            local btn= Buttons[i]
            if btn and btn:IsShown() then
                btn.itemID=nil
                btn:SetAttribute("type1", nil)
                btn:SetAttribute("item1", nil)
                btn.texture:SetTexture(0)
                btn:Hide()
                e.Ccool(btn)
                btn:UnregisterAllEvents()
            end
        end

        if isPrint then
            print(e.addName, addName, e.onlyChinese and '查询完成' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WHO, COMPLETE) )
        end
        self.isChecking=nil
    end














    function UseButton:set_strata()
        self:SetFrameStrata(Save.strata or 'MEDIUM')
    end

    function UseButton:set_point()
        self:ClearAllPoints()
        if Save.point and Save.point[1] then
            self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        else
            self:SetPoint(self.RePoint[1], self.RePoint[2], self.RePoint[3], self.RePoint[4], self.RePoint[5])
        end
    end

    function UseButton:set_scale()
        if not UnitAffectingCombat('player') then
            self:SetScale(Save.scale or 1)
        end
    end


    function UseButton:get_tooltip_item()
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID and itemLink and self.itemID~=itemID then
            return itemID, itemLink
        end
    end


    UseButton:RegisterForDrag("RightButton")
    UseButton:SetMovable(true)
    UseButton:SetClampedToScreen(true)
    UseButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    UseButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)
    UseButton:SetScript("OnMouseDown", function(self, d)
        local itemID, itemLink = self:get_tooltip_item()
        if itemID and itemLink then
            Add_Item({itemID=itemID, itemLink=itemLink})
            ClearCursor()
            return
        end

        if d=='RightButton' then
            if not IsModifierKeyDown() then--菜单
                MenuUtil.CreateContextMenu(self, Init_Menu)
            elseif IsAltKeyDown() then--移动
                SetCursor('UI_MOVE_CURSOR')
            end
        end
    end)


    UseButton:SetScript("OnMouseUp", ResetCursor)
    UseButton:SetScript('OnMouseWheel',function(self, d)
        if not IsModifierKeyDown() then
            if UnitAffectingCombat('player') then
                print(addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            else
                self:Check_Items(true)
            end
        end
    end)



    UseButton:SetScript('OnEvent', function(self, event, arg1, arg2)
        if event=='BAG_UPDATE_DELAYED' then
            if Save.autoWho then
                self:Check_Items()--检查,物品
            end
            self:set_count()
            self:set_desaturated()

        elseif event=='BAG_UPDATE_COOLDOWN' then
            self:set_cool()
            self:set_desaturated()

        elseif event=='GET_ITEM_INFO_RECEIVED' then
            if arg1==self.itemID and arg2 then
                self:set_attribute()
                self:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
            end

        elseif event=='PLAYER_REGEN_ENABLED' then
            if self.isCheckInCombat then
                self:Check_Items()--检查,物品
                self.isCheckInCombat=nil
            end
            if self.isSetAttributeInCombat then
                self:set_attribute()
                self.isSetAttributeInCombat=nil
            end
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end)


    function UseButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT");
        e.tips:ClearLines()
        local itemID, itemLink = self:get_tooltip_item()
        if itemID and itemLink then
            e.tips:AddDoubleLine(WoWTools_SpellItemMixin:GetName(nil, itemID), e.onlyChinese and '添加自定义' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, CUSTOM))
        else
            e.tips:AddDoubleLine(e.addName, addName)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
            e.tips:AddDoubleLine((UnitAffectingCombat('player') and '|cff9e9e9e' or '')..(e.onlyChinese and '查询' or WHO), e.Icon.mid)

            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(
                (Save.onlyMaxExpansion and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e')
                ..(e.onlyChinese and '仅当前版本物品'
                    or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, GAME_VERSION_LABEL))
                ),
                e.GetEnabeleDisable(Save.onlyMaxExpansion)
            )
        end

        e.tips:Show()
    end
    UseButton:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        WoWTools_BagMixin:Find()--查询，背包里物品
        self:set_alpha()
    end)
    UseButton:SetScript("OnEnter",function(self)
        self:set_tooltip()
        WoWTools_BagMixin:Find(true, {itemID= self.itemID})--查询，背包里物品
        self:set_alpha(1)
    end)










    UseButton:RegisterEvent('BAG_UPDATE_DELAYED')
    UseButton:RegisterEvent('BAG_UPDATE_COOLDOWN')
    UseButton.itemID= 5512--治疗石 538745
    Set_Button_Function(UseButton)
    UseButton:settings()

    if Save.autoLogin or Save.autoWho then
        UseButton:Check_Items()
    end


    UseButton:set_strata()
    UseButton:set_scale()
    if Save.point then
        UseButton:set_point()
    end
end






















--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then

            if WoWToolsSave[POWER_TYPE_FOOD..'Tools'] then
                WoWToolsSave[POWER_TYPE_FOOD..'Tools']= nil
            end

            Save= WoWToolsSave['Tools_Foods'] or Save

            addName= '|A:Food:0:0|a'..(e.onlyChinese and '食物' or POWER_TYPE_FOOD)

            UseButton= WoWTools_ToolsButtonMixin:CreateButton({
                name='Food',
                tooltip=addName,
                isMoveButton=true,
                option=function(Category, layout, initializer)
                    e.AddPanel_Button({
                        category=Category,
                        layout=layout,
                        tooltip=addName,
                        buttonText= e.onlyChinese and '还原位置' or RESET_POSITION,
                        SetValue= function()
                            Save.point=nil
                            if UseButton and not UnitAffectingCombat('player') then
                                Save.point=nil
                                UseButton:set_point()
                            end
                        end
                    }, initializer)
                end
            })

            if UseButton then


                Init()--初始
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_Foods']=Save
        end
    end
end)