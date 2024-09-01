local id, e = ...
local addName
local Save={
    itemClass={},--物品类型
    noUseItems={},--禁用物品
    --autoLogin= e.Player.husandro,--启动,查询
    onlyMaxExpansion=true,--仅本版本物品
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
    }
}

local panel= CreateFrame("Frame")
local Buttons={}
local UseButton
local DisableClassID={
    [6]=true,
    [10]=true,
    [11]=true,
    [13]=true,
    [14]=true,
    [16]=true,
    [18]=true,
}





local function Get_Item_Valid(itemID)
    return itemID
        and itemID~=5512--治疗石
        and not Save.noUseItems[itemID]
        and C_Item.GetItemSpell(itemID)
end















local function Set_Button_Function(btn)
    btn:SetAttribute("type1", "item")
    btn.count= e.Cstr(btn, {size=12, color=true})--10, nil,nil, true)
    btn.count:SetPoint('BOTTOMRIGHT', -4,4)
    btn.numCount=0
    btn.enableCooldown=true

    btn:SetScript("OnLeave", function()
        GameTooltip_Hide()
        WoWTools_BagMixin:Find(false)
    end)

    function btn:set_attribute()
        local icon= C_Item.GetItemIconByID(self.itemID) or 0
        self.texture:SetTexture(icon)

        local name=  C_Item.GetItemNameByID(self.itemID)

        if not icon or not name then
            self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
        end

        if self:CanChangeAttribute() then
            if name then
                self:SetAttribute("item1", name)
            end
        else
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
    end

    function btn:set_cool()
        local start, duration, enable = C_Container.GetItemCooldown(self.itemID)
        e.Ccool(self, start, duration, nil, true, nil, true)--冷却条
        btn.enableCooldown= enable
    end

    function btn:set_count()
        local num= C_Item.GetItemCount(self.itemID, false, true, true, false)--  false, true, true)
        self.count:SetText(
            num>1 and num
            or ((num==1 and Save.autoWho) and num)
            or ''
        )
        self.numCount=num
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
    local btn= Button_Mixin:CreateSecure({parent=UseButton})

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
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end)


    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        if UnitAffectingCombat('player') then
            return
        end
        WoWTools_SpellItemMixin:SetTooltip(e.tips, {
            itemID=self.itemID,
            tooltip='|A:dressingroom-button-appearancelist-up:0:0|a'
                ..(UnitAffectingCombat('player') and '|cff9e9e9e' or '')
                ..(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..e.Icon.right,
        }, nil, self)
        self:settings()
    end)

    btn:SetScript('OnMouseDown',function(self, d)
        if UnitAffectingCombat('player') then
            return
        end
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, function(f, root)
                root:CreateButton(e.onlyChinese and '禁用' or DISABLE, function()
                    Save.noUseItems[self.itemID]=true
                    print(e.addName, addName, e.onlyChinese and '禁用' or DISABLE, WoWTools_ItemMixin:GetLink(self.itemID))
                    UseButton:Check_Items()
                end)
            end)
        end
    end)

    btn:SetPoint('RIGHT', index==1 and UseButton or Buttons[index-1], 'LEFT')--位置
    table.insert(Buttons, btn)--添加

    btn:set_event()
    return btn
end










































































--#####
--主菜单
--#####
local function Init_Menu(self, root)
    if UnitAffectingCombat('player') then
        root:CreateTitle(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

    local sub, sub2, class, subClass

--查找
    sub=root:CreateButton('|cnGREEN_FONT_COLOR:|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '查找' or WHO).. e.Icon.mid, function()
        self:Check_Items(true)
    end)

--勾选所有
    sub2=sub:CreateButton(e.onlyChinese and '勾选所有' or CHECK_ALL, function()
        if not IsControlKeyDown() then
            return
        end
        do
            Save.class={}
            for classID=0, 20 do
                if not DisableClassID[classID] then
                    class= C_Item.GetItemClassInfo(classID)
                    if class then
                        Save.class[classID]= {}
                        for subClassID= 0, 20 do
                            subClass=C_Item.GetItemSubClassInfo(classID, subClassID)
                            if subClass then
                                Save.class[classID][subClassID]=true
                            end
                        end
                    else
                        break
                    end
                end
            end
        end
        self:Check_Items()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip) tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left) end)

--撤选所有
    sub2=sub:CreateButton(e.onlyChinese and '撤选所有' or UNCHECK_ALL, function()
        if IsControlKeyDown() then
            Save.class={}
            self:Check_Items()   
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip) tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left) end)


    sub:CreateDivider()
--登录游戏时: 查找
    sub2=sub:CreateCheckbox(e.onlyChinese and '登录游戏时: 查找' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_TWITTER_SIGN_IN, GAME)..': '..WHO, function()
        return Save.autoLogin
    end, function()
        Save.autoLogin= not Save.autoLogin and true or nil
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
        GameTooltip_AddErrorLine(tooltip, e.onlyChinese and '高CPU' or 'High CPU')
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


    root:CreateDivider()
    local items={
        --[classID]={num=0,[subClassID]=0}
    }
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info= C_Container.GetContainerItemInfo(bag, slot)
            local itemID= info and info.itemID
            if Get_Item_Valid(itemID) then
                local classID, subClassID, _, expacID = select(12, C_Item.GetItemInfo(itemID))
                if subClassID and classID
                    and (e.Is_Timerunning
                            or (Save.onlyMaxExpansion and (itemID==113509 or e.ExpansionLevel==expacID) or not Save.onlyMaxExpansion)
                        )
                then
                    local num= info.stackCount or 1
                    items[classID]= items[classID] or {num=0}--class
                    items[classID].num= items[classID].num+ num
                    items[classID][subClassID]= (items[classID][subClassID] or 0)+ num--subClass

                end
            end
        end
    end



    for classID=0, 20 do
        if not DisableClassID[classID] then
            class= C_Item.GetItemClassInfo(classID)
            if class then
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
            else
                break
            end
        end
    end

end



--[[local function InitMenu(self, level, type)--主菜单
    if UnitAffectingCombat('player') then
        return
    end
    local info
    if type=='DISABLE' then
        for itemID, _ in pairs(Save.noUseItems) do
            local itemLink= WoWTools_ItemMixin:GetLink(itemID)
            local itemTexture= C_Item.GetItemIconByID(itemID)
            info={
                text= itemLink or ('itemID '..itemID),
                notCheckable=true,
                keepShownOnClick=true,
                icon=itemTexture,
                tooltipOnButton=true,
                tooltipTitle=e.Icon.left..(e.onlyChinese and '移除' or REMOVE),
                func=function()
                    Save.noUseItems[itemID]=nil
                    self:Check_Items()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            keepShownOnClick=true,
            func= function()
                Save.noUseItems={}
                self:Check_Items()
                print(e.addName, addName, CLEAR_ALL, DISABLE, ITEMS, DONE)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='WHO' then
        info= {
            text= e.onlyChinese and '登录游戏时: 查找' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_TWITTER_SIGN_IN, GAME),
            keepShownOnClick=true,
            tooltipOnButton=true,
            tooltipTitle=AUTO_JOIN:gsub(JOIN,WHO),
            tooltipText='1 '..VOICEMACRO_LABEL_CHARGE1,
            checked=Save.autoLogin,
            func= function()
                Save.autoLogin= not Save.autoLogin and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info= {--自动, 更新物品, 查询
            text= e.onlyChinese and '自动查找' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, UPDATE),
            tooltipOnButton=true,
            tooltipTitle=(e.onlyChinese and '事件' or EVENTS_LABEL)..': BAG_UPDATE_DELAYED',
            checked=Save.autoWho,
            keepShownOnClick=true,
            func= function()
                Save.autoWho= not Save.autoWho and true or nil
                if Save.autoWho then
                    self:Check_Items()
                end
                set_autowho_event()--设置事件,自动更新
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

if not e.Is_Timerunning then
        info={
            text= e.onlyChinese and '仅当前版本物品' or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, GAME_VERSION_LABEL)),
            checked= Save.onlyMaxExpansion,
            keepShownOnClick=true,
            tooltipOnButton=true,
            tooltipTitle= e.ExpansionLevel,
            func= function()
                Save.onlyMaxExpansion= not Save.onlyMaxExpansion and true or nil
                self:Check_Items()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
end
        return

    elseif type then
        for _, tab in pairs(ItemClass) do
            if type==tab.className then
                info={
                    text=tab.subClassID..' '..e.cn(tab.subclassName),
                    keepShownOnClick=true,
                    checked= Save.itemClass[tab.className..tab.subclassName],
                    tooltipOnButton=true,
                    tooltipTitle= tab.className.. ' classID |cnGREEN_FONT_COLOR:'..tab.classID..'|r',
                    tooltipText= tab.subclassName..' subClassID |cnGREEN_FONT_COLOR:'..tab.subClassID..'|r',
                    func=function()
                        Save.itemClass[tab.className..tab.subclassName]= not Save.itemClass[tab.className..tab.subclassName] and true or nil
                        self:Check_Items()
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        return
    end

    local classNum=get_Save_itemClass_Select()
    info={
        text='|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '查找' or WHO).. e.Icon.mid..' '..classNum,
        colorCode='|cff00ff00',
        notCheckable=true,
        disabled=classNum==0,
        menuList='WHO',
        hasArrow=true,
        keepShownOnClick=true,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN,
        func= function()
            self:Check_Items()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    local find={}
    for index, tab in pairs(ItemClass) do
        if not find[tab.className] then
            info={
                text= tab.classID.. ' '..e.cn(tab.className)..' '..get_Save_Numer_SubClass(tab.className),
                notCheckable=true,
                keepShownOnClick=true,
                menuList=tab.className,
                hasArrow=true,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            find[tab.className]=true
        end
    end

    info={
        text='|A:bags-greenarrow:0:0|a'.. (e.onlyChinese and '全部取消' or CALENDAR_EVENT_REMOVED_MAIL_SUBJECT:format(ALL)),
        colorCode= '|cffff0000',
        notCheckable=true,
        keepShownOnClick=true,
        func= function()
            Save.itemClass={}
            self:Check_Items()
            print(e.addName, addName, CALENDAR_EVENT_REMOVED_MAIL_SUBJECT:format(ALL), DONE)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info= {
        text= e.onlyChinese and '禁用' or DISABLE,
        notCheckable=true,
        keepShownOnClick=true,
        menuList='DISABLE',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info= {
        text= e.Icon.right.. (e.onlyChinese and '移动' or NPE_MOVE),
        isTitle= true,
        notCheckable= true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '还原位置' or RESET_POSITION,
        notCheckable=true,
        colorCode= not Save.point and'|cff9e9e9e',
        keepShownOnClick=true,
        func=function()
            Save.point=nil
            UseButton:set_point()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end]]























--####
--初始
--####
local function Init()
    UseButton.RePoint={UseButton:GetPoint(1)}

    function UseButton:Check_Items(isPrint)--检查,物品
        if self.isChecking then--正在查询
            return
        elseif not self:CanChangeAttribute() then
            self.bat=true
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end
        self.isChecking=true

        local items={}
        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local itemID= C_Container.GetContainerItemID(bag, slot)
                if Get_Item_Valid(itemID) then
                    local classID, subClassID, _, expacID = select(12, C_Item.GetItemInfo(itemID))
                    if subClassID and Save.class[classID] and Save.class[classID][subClassID]
                        and (e.Is_Timerunning
                                or (Save.onlyMaxExpansion and (itemID==113509 or e.ExpansionLevel==expacID) or not Save.onlyMaxExpansion)
                            )
                    then
                        items[itemID]=true
                    end
                end
            end
        end

        local new={}
        for itemID in pairs(items) do
            table.insert(new, itemID)
        end
        table.sort(new)


        local index=1
        for _, itemID in pairs(new) do
            local btn= Buttons[index] or Create_Button(index)--创建
            btn.itemID= itemID
            btn:settings()
            if not btn:IsShown() then
                btn:set_event()
                btn:Show()
            end
            index= index +1
        end

        for i= index , #Buttons do
            local btn= Buttons[i]
            btn.itemID=nil
            btn:SetAttribute("type1", nil)
            btn:SetAttribute("item1", nil)
            btn.texture:SetTexture(0)
            btn:SetShown(false)
            e.Ccool(btn)
            btn:UnregisterAllEvents()
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



    UseButton:SetScript('OnEvent', function(self, event)
        if event=='BAG_UPDATE_DELAYED' then
            self:Check_Items()--检查,物品

        elseif event=='PLAYER_REGEN_ENABLED' then
            if self.bat then
                self:Check_Items()--检查,物品
                self.bat=nil

            elseif self.setInitBat then
                Init()--初始
                self.setInitBat=nil
            end
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end)


    function UseButton:set_tooltip()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((UnitAffectingCombat('player') and '|cff9e9e9e' or '')..(e.onlyChinese and '查询' or WHO), e.Icon.mid)
        e.tips:Show()
    end
    UseButton:SetScript('OnLeave', GameTooltip_Hide)
    UseButton:SetScript("OnEnter",function(self)
        self:set_tooltip()
        WoWTools_BagMixin:Find(true, {itemID= self.itemID})--查询，背包里物品
    end)













    if Save.autoLogin or Save.autoWho then
        UseButton:Check_Items()
    end

    UseButton.itemID= 5512--治疗石 538745
    Set_Button_Function(UseButton)


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
                Save= WoWToolsSave[POWER_TYPE_FOOD..'Tools']
                WoWToolsSave[POWER_TYPE_FOOD..'Tools']= nil
                Save.itemClass=nil
                Save.class=class
            else
                Save= WoWToolsSave['Tools_Food'] or Save
            end
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
            WoWToolsSave['Tools_Food']=Save
        end
    end
end)