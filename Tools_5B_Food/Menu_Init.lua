--主菜单
local e= select(2, ...)
local function Save()
    return WoWTools_FoodMixin.Save
end









local function AltSpell_Menu(self, root)
    --法术书
    local sub
    for i=1, 12 do
        local spell= C_SpellBook.GetSpellBookSkillLineInfo(i)--shouIdHide name numSpellBookItems iconID isGuild itemIndexOffset
        if spell and spell.name and not spell.shouIdHide then
            sub=root:CreateButton(
                '|T'..(spell.iconID or 0)..':0|t'..e.cn(spell.name),
            function()
                return MenuResponse.Open
            end)
            local info= C_SpellBook.GetSpellBookSkillLineInfo(i)
            if info and info.name and info.itemIndexOffset and info.numSpellBookItems and info.numSpellBookItems>0 then
                for index= info.itemIndexOffset+1, info.itemIndexOffset+ info.numSpellBookItems do
                    local spellData= C_SpellBook.GetSpellBookItemInfo(index, Enum.SpellBookSpellBank.Player) or {}--skillLineIndex itemType isOffSpec subName actionID name iconID isPassive spellID
                    if not spellData.isPassive and spellData.spellID and spellData.name then
                        
                        
                    end
                end
            end
        end
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
    local sub=root:CreateButton(e.onlyChinese and '勾选所有' or CHECK_ALL, function(data)
        if IsControlKeyDown() or data.classID then
            do
                if data.classID then
                    Check_All_SubClass(data.classID)
                else
                    Save().class={}
                    for classID=0, 20 do
                        if not Save().DisableClassID[classID] then
                            class= C_Item.GetItemClassInfo(classID)
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
        sub:SetTooltip(function(tooltip) tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left) end)
    end

    --撤选所有
    sub=root:CreateButton(e.onlyChinese and '撤选所有' or UNCHECK_ALL, function(data)
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
        sub:SetTooltip(function(tooltip) tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left) end)
    end
end



















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
    sub=root:CreateButton((Save().autoWho and '|cnGREEN_FONT_COLOR:' or '')..'|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '查找' or WHO).. e.Icon.mid, function()
        WoWTools_FoodMixin:Check_Items(true)
    end)

--隐藏
    sub2=sub:CreateButton(e.onlyChinese and '隐藏' or HIDE, function() return MenuResponse.Open end)
    for classID=0, 20 do
        class= C_Item.GetItemClassInfo(classID)
        if class then
            sub2:CreateCheckbox(classID..' '..e.cn(class)..' '..(items[classID] and items[classID].num or ''), function(data)
                return Save().DisableClassID[data.classID]
            end, function(data)
                Save().DisableClassID[data.classID]= not Save().DisableClassID[data.classID] and true or nil
                WoWTools_FoodMixin:Check_Items()
                return MenuResponse.Refresh
            end, {classID=classID})
        end
    end

--禁用
    sub2=sub:CreateButton(e.onlyChinese and '禁用' or DISABLE, function() return MenuResponse.Open end)
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
    if find>1 then
        sub2:CreateDivider()
        sub2:CreateButton(e.onlyChinese and '全部清除' or CLEAR_ALL, function()
            Save().noUseItems={}
            WoWTools_FoodMixin:Check_Items()
        end)
        WoWTools_MenuMixin:SetGridMode(sub2, find)
    end


--登录游戏时: 查找
    sub:CreateDivider()
    sub:CreateCheckbox(e.onlyChinese and '登录游戏时: 查找' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_TWITTER_SIGN_IN, GAME)..': '..WHO, function()
        return Save().autoLogin
    end, function()
        Save().autoLogin= not Save().autoLogin and true or nil
        if Save().autoLogin then
            WoWTools_FoodMixin:Check_Items()
        end
    end)

--自动查找
    sub2=sub:CreateCheckbox(e.onlyChinese and '自动查找' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, UPDATE), function()
        return Save().autoWho
    end, function()
        Save().autoWho= not Save().autoWho and true or nil
        if Save().autoWho then
            WoWTools_FoodMixin:Check_Items()
        end
        WoWTools_FoodMixin.CheckFrame:set_event()
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
            return Save().onlyMaxExpansion
        end, function()
            Save().onlyMaxExpansion= not Save().onlyMaxExpansion and true or nil
            WoWTools_FoodMixin:Check_Items()
        end)
    end

--仅限 C_Item.GetItemSpell(itemID)
    sub2=sub:CreateCheckbox(e.onlyChinese and '可使用' or format(LFG_LIST_CROSS_FACTION, USE), function()
        return Save().olnyUsaItem
    end, function()
        Save().olnyUsaItem= not Save().olnyUsaItem and true or nil
        WoWTools_FoodMixin:Check_Items()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('C_Item.GetItemSpell(itemID)')
    end)
--缩放
    sub:CreateDivider()

    --显示背景
    WoWTools_MenuMixin:ShowBackground(sub,
    function()
        return Save().isShowBackground
    end, function()
        Save().isShowBackground= not Save().isShowBackground and true or nil
        self:set_background()
    end)

    sub2=select(2, WoWTools_MenuMixin:Scale(sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        self:set_scale()
    end))



    sub2= select(2, WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:set_strata()
    end))

    sub2=sub:CreateButton(e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS, function()return MenuResponse.Open end)
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

--重置位置
    sub:CreateDivider()
    WoWTools_MenuMixin:RestPoint(sub, Save().point and not UnitAffectingCombat('player'), function()
        if not UnitAffectingCombat('player') then
            Save().point=nil
            self:set_point()
        end
    end)

--打开选项界面
    WoWTools_ToolsButtonMixin:OpenMenu(sub, WoWTools_FoodMixin.addName)--打开, 选项界面，菜单

--自定义
    sub=root:CreateButton(e.onlyChinese and '自定义' or CUSTOM, function() return MenuResponse.Open end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '拖曳物品添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS, ADD)))
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
    if find>0 then
        sub:CreateDivider()
        sub:CreateButton(e.onlyChinese and '全部清除' or CLEAR_ALL, function()
            Save().addItems={}
            WoWTools_FoodMixin:Check_Items()
        end)
        WoWTools_MenuMixin:SetGridMode(sub, find)
    end

--总是显示
    sub:CreateCheckbox(e.onlyChinese and '总是显示' or BATTLEFIELD_MINIMAP_SHOW_ALWAYS, function()
        return Save().addItemsShowAll
    end, function()
        Save().addItemsShowAll= not Save().addItemsShowAll and true or nil
    end)


    find=nil
    for classID=0, 20 do
        if not Save().DisableClassID[classID] then
            class= C_Item.GetItemClassInfo(classID)
            if class then
                if not find then
                    root:CreateDivider()
                    find=true
                end

                sub=root:CreateCheckbox(classID..' '..e.cn(class)..' '..(items[classID] and items[classID].num or ''), function(data)
                    return Save().class[data.classID]
                end, function(data)
                    if Save().class[data.classID] then
                        Save().class[data.classID]= nil
                    else
                        Save().class[data.classID]= Save().class[data.classID] or {}
                        for i=0, 20 do
                            local name= C_Item.GetItemSubClassInfo(data.classID, i)
                            if name and name~='' then
                                Save().class[data.classID][i]=true
                            end
                        end
                    end
                    WoWTools_FoodMixin:Check_Items()
                end, {classID=classID})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine(
                        Save().class[description.data.classID]
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