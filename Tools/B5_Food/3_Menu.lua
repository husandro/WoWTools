--主菜单

local function Save()
    return WoWToolsSave['Tools_Foods']
end










local function AltSpell_Menu(_, root)
    root:CreateDivider()

    --法术书
    local sub,sub2, sub3, spellSub, num
    local spells= Save().spells[WoWTools_DataMixin.Player.Class]
    --local item, alt, ctrl, shift= tab.item, tab.alt, tab.ctrl, tab.shift
    local keyTab={
        {type='Alt', spellID=spells.alt},
        {type='Ctrl', spellID=spells.ctrl},
        {type='Shift', spellID=spells.shift},
        --{type='Item', spellID=spells.item},
    }

    for _, tab in pairs(keyTab) do

        sub=root:CreateCheckbox(
            tab.type
            ..(WoWTools_SpellMixin:GetName(tab.spellID) or ''),--取得法术，名称

        function(data)
            return Save().spells[WoWTools_DataMixin.Player.Class][data.type]==data.spellID and data.spellID~=nil

        end, function(data)
            Save().spells[WoWTools_DataMixin.Player.Class][data.type]= not Save().spells[WoWTools_DataMixin.Player.Class][data.type] and data.spellID or nil
            WoWTools_FoodMixin:Init_Button()

        end, {type=string.lower(tab.type), spellID=tab.spellID})

        WoWTools_SetTooltipMixin:Set_Menu(sub)

        for i=1, 12 do
            spellSub= C_SpellBook.GetSpellBookSkillLineInfo(i)--shouIdHide name numSpellBookItems iconID isGuild itemIndexOffset
            if spellSub and spellSub.name and not spellSub.shouIdHide then
                sub2=sub:CreateButton(
                    '|T'..(spellSub.iconID or 0)..':0|t'..WoWTools_TextMixin:CN(spellSub.name),
                function()
                    return MenuResponse.Open
                end)

                local info= C_SpellBook.GetSpellBookSkillLineInfo(i)
                if info and info.name and info.itemIndexOffset and info.numSpellBookItems and info.numSpellBookItems>0 then

                    num=0
                    for index= info.itemIndexOffset+1, info.itemIndexOffset+ info.numSpellBookItems do
                        local spellData= C_SpellBook.GetSpellBookItemInfo(index, Enum.SpellBookSpellBank.Player) or {}--skillLineIndex itemType isOffSpec subName actionID name iconID isPassive spellID
                        if not spellData.isPassive and spellData.spellID and spellData.name then

                            sub3=sub2:CreateCheckbox(
                                WoWTools_SpellMixin:GetName(spellData.spellID),

                            function(data)
                                return Save().spells[WoWTools_DataMixin.Player.Class][data.type]==data.spellID

                            end, function(data)
                                Save().spells[WoWTools_DataMixin.Player.Class][data.type]= Save().spells[WoWTools_DataMixin.Player.Class][data.type]~= data.spellID and data.spellID or nil
                                WoWTools_FoodMixin:Init_Button()

                            end, {type=string.lower(tab.type), spellID=spellData.spellID})

                            WoWTools_SetTooltipMixin:Set_Menu(sub3)
                            num= num+1
                        end
                    end

                    WoWTools_MenuMixin:SetScrollMode(sub)
                end
            end
        end
        sub:CreateDivider()
        sub:CreateTitle(tab.type)
    end
end
















local function Check_All_SubClass(setClassID)
    Save().class[setClassID]= Save().class[setClassID] or {}
    for subClassID= 0, 20 do
        local subClass=C_Item.GetItemSubClassInfo(setClassID, subClassID)
        if subClass then
            Save().class[setClassID][subClassID]=true
        else
            break
        end
    end
end













local function Check_All_Menu(_, root, setClassID)
    root:CreateDivider()
    local sub=root:CreateButton(WoWTools_DataMixin.onlyChinese and '勾选所有' or CHECK_ALL, function(data)
        if IsControlKeyDown() or data.classID then
            do
                if data.classID then
                    Check_All_SubClass(data.classID)
                else
                    Save().class={}
                    for classID=0, 20 do
                        if not Save().DisableClassID[classID] then
                            local class= C_Item.GetItemClassInfo(classID)
                            if class then
                                Save().class[classID]= {}
                                Check_All_SubClass(classID)
                            else
                                break
                            end
                        end
                    end
                end
            end
            WoWTools_FoodMixin:Check_Items()
        end
        return MenuResponse.Refresh
    end, {classID=setClassID})
    if not setClassID then
        sub:SetTooltip(function(tooltip) tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..WoWTools_DataMixin.Icon.left) end)
    end

    --撤选所有
    sub=root:CreateButton(WoWTools_DataMixin.onlyChinese and '撤选所有' or UNCHECK_ALL, function(data)
        if IsControlKeyDown() or data.classID then
            if data.classID then
                Save().class[data.classID]= nil
            else
                Save().class={}
            end
            WoWTools_FoodMixin:Check_Items()
        end
        return MenuResponse.Refresh
    end, {classID=setClassID})
    if not setClassID then
        sub:SetTooltip(function(tooltip) tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..WoWTools_DataMixin.Icon.left) end)
    end
end



















local function Init_Menu(self, root)
    if not self:CanChangeAttribute() then
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

    local sub, sub2, sub3, class, subClass, find, name
    local items={
        --[classID]={num=0,[subClassID]=0}
    }
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info= C_Container.GetContainerItemInfo(bag, slot) or {}
            local classID, subClassID= WoWTools_FoodMixin:Get_Item_Valid(info.itemID)
            if classID and subClassID then
                local num= info.stackCount or 1
                items[classID]= items[classID] or {num=0}--class
                items[classID].num= items[classID].num+ num
                items[classID][subClassID]= (items[classID][subClassID] or 0)+ num--subClass
            end
        end
    end

--查找
    sub=root:CreateButton(
        (Save().autoWho and '|cnGREEN_FONT_COLOR:' or '')
        ..'|A:common-icon-zoomin:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '查找' or WHO)
        ..WoWTools_DataMixin.Icon.mid,
    function()
        WoWTools_FoodMixin:Check_Items(true)
    end)

--隐藏
    sub2=sub:CreateButton(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE, function() return MenuResponse.Open end)
    for classID=0, 20 do
        class= C_Item.GetItemClassInfo(classID)
        if class then
            sub2:CreateCheckbox(classID..' '..WoWTools_TextMixin:CN(class)..' '..(items[classID] and items[classID].num or ''), function(data)
                return Save().DisableClassID[data.classID]
            end, function(data)
                Save().DisableClassID[data.classID]= not Save().DisableClassID[data.classID] and true or nil
                WoWTools_FoodMixin:Check_Items()
                return MenuResponse.Refresh
            end, {classID=classID})
        end
    end

--禁用
    sub2=sub:CreateButton(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE, function() return MenuResponse.Open end)
    find=0
    for itemID in pairs(Save().noUseItems) do
        find=find+1
        sub3=sub2:CreateCheckbox(find..') '..WoWTools_ItemMixin:GetName(itemID), function(data)
            return Save().noUseItems[data.itemID]
        end, function(data)
            Save().noUseItems[data.itemID]= not Save().noUseItems[data.itemID] and true or nil
            WoWTools_FoodMixin:Check_Items()
        end, {itemID=itemID})
        WoWTools_SetTooltipMixin:Set_Menu(sub3)
    end
    
    sub2:CreateDivider()
    sub2:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
    function()
        StaticPopup_Show('WoWTools_OK',
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
        nil,
        {SetValue=function()
            Save().noUseItems={}
            WoWTools_FoodMixin:Check_Items()
        end})
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetScrollMode(sub2)
    


--登录游戏时: 查找
    sub:CreateDivider()
    sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '登录游戏时: 查找' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_TWITTER_SIGN_IN, GAME)..': '..WHO, function()
        return Save().autoLogin
    end, function()
        Save().autoLogin= not Save().autoLogin and true or nil
        if Save().autoLogin then
            WoWTools_FoodMixin:Check_Items()
        end
    end)

--自动查找
    sub2=sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '自动查找' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, UPDATE), function()
        return Save().autoWho
    end, function()
        Save().autoWho= not Save().autoWho and true or nil
        if Save().autoWho then
            WoWTools_FoodMixin:Check_Items()
        end
        self.CheckFrame:set_event()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '事件' or EVENTS_LABEL)
        tooltip:AddLine('BAG_UPDATE_DELAYED')
        tooltip:AddLine(' ')
        GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '高CPU' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIGH, 'CPU'))
    end)

--仅当前版本物品
    if not PlayerIsTimerunning() then--时光
        sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '仅当前版本物品' or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, GAME_VERSION_LABEL)), function()
            return Save().onlyMaxExpansion
        end, function()
            Save().onlyMaxExpansion= not Save().onlyMaxExpansion and true or nil
            WoWTools_FoodMixin:Check_Items()
        end)
    end

--仅限 C_Item.GetItemSpell(itemID)
    sub2=sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '可使用' or format(LFG_LIST_CROSS_FACTION, USE), function()
        return Save().olnyUsaItem
    end, function()
        Save().olnyUsaItem= not Save().olnyUsaItem and true or false
        WoWTools_FoodMixin:Check_Items()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('C_Item.GetItemSpell(itemID)')
    end)
--缩放
    sub:CreateDivider()

--显示背景
    WoWTools_MenuMixin:BgAplha(sub,
    function()
        return Save().bgAlpha or 0
    end, function(value)
        Save().bgAlpha= value
        self:set_background()
    end)

    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        self:set_scale()
    end)



    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:set_strata()
    end)


--数量
    sub2=sub:CreateButton(
        '|A:newplayertutorial-icon-key:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)
        ..' '.. Save().numLine,
    function()
        return MenuResponse.Open
    end)
    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save().numLine
        end, setValue=function(value)
            Save().numLine=value
            WoWTools_FoodMixin:Check_Items()
        end,
        --name=,
        minValue=1,
        maxValue=60,
        step=1,
        bit=nil,
    })
    sub2:CreateSpacer()


--外框，透明度
    sub2=sub:CreateButton(
        '|A:bag-reagent-border:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '镶边' or EMBLEM_BORDER)
        ..' '
        ..(Save().borderAlpha or 0),
    function()
        return MenuResponse.Open
    end)

--Border 透明度
    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save().borderAlpha or 0
        end, setValue=function(value)
            Save().borderAlpha=value
            WoWTools_FoodMixin:Check_Items()
        end,
        name=WoWTools_DataMixin.onlyChinese and '改变透明度' or HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })


--重置位置
    sub:CreateDivider()
    WoWTools_MenuMixin:RestPoint(self, sub, Save().point , function()
        if self:CanChangeAttribute() then
            Save().point=nil
            self:set_point()
        end
    end)

--打开选项界面
    WoWTools_ToolsMixin:OpenMenu(sub, WoWTools_FoodMixin.addName)--打开, 选项界面，菜单

--自定义
    sub=root:CreateButton(WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM, function() return MenuResponse.Open end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '拖曳物品添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS, ADD)))
    end)

    find=0
    for itemID in pairs(Save().addItems) do
        find=find+1
        sub2=sub:CreateCheckbox(find..') '..WoWTools_ItemMixin:GetName(itemID), function(data)
            return Save().addItems[data.itemID]
        end, function(data)
            Save().addItems[data.itemID]= not Save().addItems[data.itemID] and true or nil
            WoWTools_FoodMixin:Check_Items()
        end, {itemID=itemID})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end

--全部清除
    sub:CreateDivider()
    name= WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL
    sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            Save().addItems={}
            WoWTools_FoodMixin:Check_Items()
        end})
        return MenuResponse.Open
    end, {name=name})

    WoWTools_MenuMixin:SetScrollMode(sub)

--总是显示
    sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '总是显示' or BATTLEFIELD_MINIMAP_SHOW_ALWAYS, function()
        return Save().addItemsShowAll
    end, function()
        Save().addItemsShowAll= not Save().addItemsShowAll and true or nil
    end)


    find=nil
--Enum.ItemClass
    for classID=0, 20 do
        if not Save().DisableClassID[classID] then
            class= C_Item.GetItemClassInfo(classID)
            if class then
                if not find then
                    root:CreateDivider()
                    find=true
                end

                sub=root:CreateCheckbox(classID..' '..WoWTools_TextMixin:CN(class)..' '..(items[classID] and items[classID].num or ''), function(data)
                    return Save().class[data.classID]
                end, function(data)
                    if Save().class[data.classID] then
                        Save().class[data.classID]= nil
                    else
                        Save().class[data.classID]= Save().class[data.classID] or {}
                        for i=0, 20 do
                            local name2= C_Item.GetItemSubClassInfo(data.classID, i)
                            if name2 and name2~='' then
                                Save().class[data.classID][i]=true
                            end
                        end
                    end
                    WoWTools_FoodMixin:Check_Items()
                end, {classID=classID})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine(
                        Save().class[description.data.classID]
                        and (WoWTools_DataMixin.onlyChinese and '撤选所有' or UNCHECK_ALL)
                        or (WoWTools_DataMixin.onlyChinese and '勾选所有' or CHECK_ALL)
                    )
                end)



                for subClassID= 0, 20 do
                    subClass=C_Item.GetItemSubClassInfo(classID, subClassID)
                    if subClass and subClass~='' then
                        sub:CreateCheckbox(
                            subClassID..' '..WoWTools_TextMixin:CN(subClass)..' '
                            ..(items[classID] and items[classID][subClassID] or ''),
                        function(data)
                            return Save().class[data.classID] and Save().class[data.classID][data.subClassID]
                        end, function(data)
                            if Save().class[data.classID] and Save().class[data.classID][data.subClassID] then
                                Save().class[data.classID][data.subClassID]=nil
                            else
                                Save().class[data.classID]= Save().class[data.classID] or {}
                                Save().class[data.classID][data.subClassID]= true
                            end
                            WoWTools_FoodMixin:Check_Items()
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

    AltSpell_Menu(self, root)
end














function WoWTools_FoodMixin:Init_Menu(btn)
    MenuUtil.CreateContextMenu(btn, Init_Menu)
end