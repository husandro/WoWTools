local id, e = ...
local addName= USE_ITEM
local addName2

local panel= CreateFrame("Frame")
local button

local P_Item_Tabs={
    --156833,--[凯蒂的印哨]
    194885,--[欧胡纳栖枝]收信
    40768,--[移动邮箱]
    114943,--[终极版侏儒军刀]
    168667,--[布林顿7000]

    49040,--[基维斯]
    144341,--[可充电的里弗斯电池]

    128353,--[海军上将的罗盘]
    167075,--[超级安全传送器：麦卡贡]
    168222,--[加密的黑市电台]
    184504, 184501, 184503, 184502, 184500, 64457,--[侍神者的袖珍传送门：奥利波斯]
    198156,--龙洞发生器-巨龙群岛
    172924,--[虫洞发生器：暗影界]
    168807,--[虫洞发生器：库尔提拉斯]
    168808,--[虫洞发生器：赞达拉]
    151652,--[虫洞发生器：阿古斯]
    112059,--[虫洞离心机]
    87215,--[虫洞发生器：潘达利亚]
    48933,--[虫洞发生器：诺森德]
    30542,--[空间撕裂器 - 52区]
    151016,--[开裂的死亡之颅]
    136849, 52251,--[自然道标]
    139590,--[传送卷轴：拉文霍德]
    87216,--[热流铁砧]
    85500,--[垂钓翁钓鱼筏]
    37863,--[烈酒的遥控器]
    --141605,--[飞行管理员的哨子]
    200613,--艾拉格风石碎片
}
local P_Spell_Tabs={
    83958,--移动银行
    69046,--[呼叫大胖],种族特性
    50977,--[黑锋之门]
    193753,--[传送：月光林地]
    556,--[星界传送]
    18960,--[梦境行者]
    126892,--[禅宗朝圣]
}
local P_Flyout_Tab={
}
local P_Equip_Tab={
    65274,65360, 63206, 63207, 63352, 63353,--协同披风
    103678,--迷时神器
    142469,--魔导大师的紫罗兰印戒
    144391, 144392,--拳手的重击指环
}


local Save= {
        item=P_Item_Tabs,
        spell=P_Spell_Tabs,
        flyout=P_Flyout_Tab,
        equip=P_Equip_Tab
}

local function find_Type(type, ID)
    for index, ID2 in pairs(Save[type]) do
        if ID2==ID then
            return index
        end
    end
end

local function get_Find(ID, spell)
    if spell then
        if IsSpellKnownOrOverridesKnown(ID) then
            return true
        end
    else
        if C_Item.GetItemCount(ID)>0 or (PlayerHasToy(ID) and C_ToyBox.IsToyUsable(ID)) then
            return true
        end
    end
end

local function set_button_Event(self, isShown)--事件
    local tab={}
    if self.spellID then
        tab= {
            'SPELL_UPDATE_USABLE',
            'SPELL_UPDATE_COOLDOWN',
        }
    elseif self.itemID then
        tab={
            'BAG_UPDATE_DELAYED',
            'BAG_UPDATE_COOLDOWN'
        }
    end
    if isShown then
        FrameUtil.RegisterFrameForEvents(self, tab)
    else
        FrameUtil.UnregisterFrameForEvents(self, tab)
    end
end





















































--####
--物品
--####
local function set_Equip_Slot(self)--装备
    if UnitAffectingCombat('player') then
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
    local slotItemID=GetInventoryItemID('player', self.slot)
    local slotItemLink=GetInventoryItemLink('player', self.slot)
    local name= slotItemLink and C_Item.GetItemInfo(slotItemLink) or slotItemID and C_Item.GetItemNameByID(slotItemID)
    if name and slotItemID~=self.itemID and self:GetAttribute('item2')~=name then
        self:SetAttribute('item2', name)
        self.slotEquipName=name
        local icon = C_Item.GetItemIconByID(slotItemID)
        if icon and not self.slotTexture then--装备前的物品,提示
            self.slotequipedTexture=self:CreateTexture(nil, 'OVERLAY')
            self.slotequipedTexture:SetPoint('BOTTOMRIGHT',-7,9)
            self.slotequipedTexture:SetSize(8,8)
            self.slotequipedTexture:SetTexture(icon)
            self.slotequipedTexture:SetDrawLayer('OVERLAY', 2)
        end
    elseif not name then
        self:SetAttribute('item2', nil)
    end
    if slotItemID==self.itemID and not self.equipedTexture then--自身已装备提示
        self.equipedTexture=self:CreateTexture(nil, 'OVERLAY')
        self.equipedTexture:SetPoint('BOTTOMLEFT',2,5)
        self.equipedTexture:SetSize(15,15)
        self.equipedTexture:SetAtlas('charactercreate-icon-customize-body-selected')
        self.equipedTexture:SetDrawLayer('OVERLAY', 2)
    end

    if self.equipedTexture then
        self.equipedTexture:SetShown(slotItemID==self.itemID)
    end
    if  self.slotequipedTexture then
        self.slotequipedTexture:SetShown(slotItemID==self.itemID)
    end
    self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

local function set_Item_Count(self)--数量
    local num = C_Item.GetItemCount(self.itemID, false, true, true)
    if not PlayerHasToy(self.itemID) then
        if num~=1 and not self.count then
            self.count=e.Cstr(self, {size=10, color=true})--10,nil,nil,true)
            self.count:SetPoint('BOTTOMRIGHT',-2, 9)
        end
        if self.count then
            self.count:SetText(num~=1 and num or '')
        end
    end
    self.texture:SetDesaturated(num==0 and not PlayerHasToy(self.itemID))
end

local function set_Bling_Quest(self)--布林顿任务
    local complete=C_QuestLog.IsQuestFlaggedCompleted(56042)
    if not self.quest then
        self.quest=e.Cstr(self, {size=8})
        self.quest:SetPoint('BOTTOM',0,8)
    end
    self.quest:SetText(complete and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '完成' or COMPLETE)..'|r' or '|A:questlegendary:0:0|a')
end
local function init_Item_Button(self, equip)--设置按钮
    self:SetScript('OnEnter', function()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetItemByID(self.itemID)
        e.tips:Show()
        e.FindBagItem(true, {itemID= self.itemID})--查询，背包里物品
    end)
    self:SetScript('OnLeave', function() e.FindBagItem(false) GameTooltip_Hide() end)
    self:SetScript("OnEvent", function(self2, event, arg1)
        if event=='BAG_UPDATE_DELAYED' then
            set_Item_Count(self2)
        elseif event=='BAG_UPDATE_COOLDOWN' then
            e.SetItemSpellCool(self2, {item=self2.itemID})
        elseif event=='QUEST_COMPLETE' then
            set_Bling_Quest(self2)
        elseif event=='PLAYER_EQUIPMENT_CHANGED' or 'PLAYER_REGEN_ENABLED' then
            set_Equip_Slot(self2)
        end
    end)
    self:SetScript('OnShow', function(self2)
        set_button_Event(self2, true)--事件
        e.SetItemSpellCool(self, {item=self.itemID})
        set_Item_Count(self)
    end)
    self:SetScript('OnHide', function(self2)
        set_button_Event(self2)--事件
    end)

    if equip then
        self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        self:SetScript('OnMouseUp',function()
            local frame=PaperDollFrame
            if frame and not frame:IsVisible() then
                ToggleCharacter("PaperDollFrame");
            end
        end)
        set_Equip_Slot(self)
    end
    if self.itemID==168667 or self.itemID==87214 or self==111821 then--布林顿任务
        self:RegisterEvent('QUEST_COMPLETE')
        set_Bling_Quest(self)
    end
end









--法术
local function set_Spell_Count(self)--次数
    local data= self.spellID and C_Spell.GetSpellCharges(self.spellID) or {}
    local num, max= data.currentCharges, data.maxCharges
    if max and max>1 and not self.count then
        self.count=e.Cstr(self, {color=true})--nil,nil,nil,true)
        self.count:SetPoint('BOTTOMRIGHT',-2, 9)
    end
    if self.count then
        self.count:SetText((max and max>1) and num or '')
    end
    self.texture:SetDesaturated(num and num>0)
end

local function init_Spell_Button(self)--设置按钮
    self:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetSpellByID(self2.spellID)
        e.tips:Show()
    end)
    self:SetScript('OnLeave', GameTooltip_Hide)
    self:SetScript("OnEvent", function(self2, event)
        if event=='SPELL_UPDATE_USABLE' then
            set_Spell_Count(self2)
        elseif event=='SPELL_UPDATE_COOLDOWN' then
            e.SetItemSpellCool(self2, {spell=self2.spellID})
        end
    end)
    self:SetScript('OnShow', function(self2)
        set_button_Event(self2, true)
        e.SetItemSpellCool(self2, {spell=self2.spellID})
        set_Spell_Count(self2)
    end)
    self:SetScript('OnHide', function(self2)
        set_button_Event(self2)
    end)
end








local function Init_All_Buttons()
    for _, itemID in pairs(Save.item) do
        local name ,icon
        if get_Find(itemID) then
            name = C_Item.GetItemNameByID(itemID)
            icon = C_Item.GetItemIconByID(itemID)
            if name and icon then
                local btn= e.Cbtn2({
                    name=id..addName..name,
                    parent= e.toolsFrame,
                    click=true,-- right left
                    notSecureActionButton=nil,
                    notTexture=nil,
                    showTexture=true,
                    sizi=nil,
                })

                btn.itemID=itemID
                init_Item_Button(btn)
                e.ToolsSetButtonPoint(btn)--设置位置
                btn:SetAttribute('type', 'item')
                btn:SetAttribute('item', name)
                btn.texture:SetTexture(icon)
            end
        end
   end

    for _, itemID in pairs(Save.equip) do
        local name ,icon
        if C_Item.GetItemCount(itemID)>0 then
            name = C_Item.GetItemNameByID(itemID)
            local itemEquipLoc, icon2 = select(4, C_Item.GetItemInfoInstant(itemID))
            icon =icon2 or C_Item.GetItemIconByID(itemID)
            local slot= e.GetItemSlotID(itemEquipLoc)

            if name and icon and slot then
                local btn= e.Cbtn2({
                    name=nil,
                    parent= e.toolsFrame,
                    click=true,-- right left
                    notSecureActionButton=nil,
                    notTexture=nil,
                    showTexture=true,
                    sizi=nil,
                })
                btn.itemID=itemID
                btn.slot=slot
                init_Item_Button(btn, true)
                e.ToolsSetButtonPoint(btn)--设置位置
                btn:SetAttribute('type', 'item')
                btn:SetAttribute('item', name)
                btn:SetAttribute('type2', 'item')
                btn.texture:SetTexture(icon)
            end
        end
    end

    for _, spellID in pairs(Save.spell) do
        if IsSpellKnownOrOverridesKnown(spellID) then
            local name= C_Spell.GetSpellName(spellID)
            local icon= C_Spell.GetSpellTexture(spellID)
            if name and icon then
                if name and icon then
                    local btn= e.Cbtn2({
                        name=nil,
                        parent= e.toolsFrame,
                        click=true,-- right left
                        notSecureActionButton=nil,
                        notTexture=nil,
                        showTexture=true,
                        sizi=nil,
                    })
                    btn.spellID=spellID
                    init_Spell_Button(btn)
                    e.ToolsSetButtonPoint(btn)--设置位置
                    btn:SetAttribute('type', 'spell')
                    btn:SetAttribute('spell', name)
                    btn.texture:SetTexture(icon)
                end
            end
        end
    end
end
--[[f not e.Player.husandro then
    return
end
local tab= {103}
    for _, flyoutID in pairs(tab) do --Save.flyout) do
        local name, description, numSlots, isKnown = GetFlyoutInfo(flyoutID)
        
        if isKnown then
            local btn= CreateFrame('CheckButton', id..'ToolsFlyout'..name, e.toolsFrame, 'SpellFlyoutButtonTemplate')--SmallActionButtonTemplate SpellFlyoutButtonTemplate
            
            local btn= e.Cbtn2({
                name=nil,
                parent= e.toolsFrame,
                click=true,-- right left
                notSecureActionButton=nil,
                notTexture=nil,
                showTexture=true,
                sizi=nil,
            })
            --btn.flyoutId=flyoutID
            --btn.spellID= flyoutID

           

            e.ToolsSetButtonPoint(btn)--设置位置
            btn:SetAttribute("type", "flyout")
--btn:SetAttribute("spell", flyoutID)
            btn:SetAttribute("flyout", flyoutID)
            btn:SetAttribute("flyoutDirection", 'RIGHT')
            --btn:SetAttribute('spellID', flyoutID)
            --btn:SetAttribute("flyoutDirection", "LEFT")
            --btn.texture:SetTexture(519384)
        end
    end
    ]]




































--#############
--玩具界面, 菜单
--#############
local function Init_Opetions_ToyBox(btn)--标记, 是否已选取
    if not btn.useItem then
        btn.useItem= e.Cbtn(btn,{size={16,16}, atlas='soulbinds_tree_conduit_icon_utility'})
        btn.useItem:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT', 32, 0)
        function btn.useItem:get_itemID()
            return self:GetParent().itemID
        end
        function btn.useItem:set_alpha()
            local find=find_Type('item', self:get_itemID())
            self:SetAlpha(find and 1 or 0.1)
        end
        function btn.useItem:set_tooltips()
            local itemID=self:get_itemID()
            if not itemID then
                return
            end
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.toolsFrame.addName, addName2)
            e.tips:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            e.tips:AddLine(' ')
            
            local icon= C_Item.GetItemIconByID(itemID)
            local find=find_Type('item', itemID)
            e.tips:AddDoubleLine(
                (icon and '|T'..icon..':0|t' or '')..(C_ToyBox.GetToyLink(itemID) or itemID)..' '..e.GetEnabeleDisable(find),
                e.Icon.left
            )
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
            self:SetAlpha(1)
        end

        btn.useItem:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                local itemID= self:GetParent().itemID
                if not itemID then
                    return
                end
                local find=find_Type('item', itemID)
                if find then
                    table.remove(Save.item, find)
                else
                    table.insert(Save.item, itemID)
                end
                self:set_tooltips()
                self:set_alpha()
            else
                e.LibDD:ToggleDropDownMenu(1, nil, button.Menu, self, 15, 0)
            end
        end)
        btn.useItem:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha() end)
        btn.useItem:SetScript('OnEnter', btn.useItem.set_tooltips)
    end
    btn.useItem:set_alpha()
end











local function set_Use_Spell_Button(btn, spellID)
    if not btn.useSpell then
        btn.useSpell= e.Cbtn(btn, {size={16,16}, atlas='soulbinds_tree_conduit_icon_utility'})
        btn.useSpell:SetPoint('TOP', btn, 'BOTTOM')
        function btn.useSpell:set_alpha()
            if self.spellID then
                self:SetAlpha(find_Type('spell', self.spellID) and 1 or 0.2)
            end
        end
        function btn.useSpell:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.toolsFrame.addName, addName2)
            e.tips:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            e.tips:AddLine(' ')
            if self.spellID then
                local text
                local icon= C_Spell.GetSpellTexture(self.spellID)
                text= icon and '|T'..icon..':0|t' or ''
                text= text..(C_Spell.GetSpellLink(self.spellID) or self.spellID)
                e.tips:AddDoubleLine(text..' '..e.GetEnabeleDisable(find_Type('spell', self.spellID)), e.Icon.left)
            end
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
            self:SetAlpha(1)
        end
        btn.useSpell:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha()  end)
        btn.useSpell:SetScript('OnEnter', btn.useSpell.set_tooltips)
        btn.useSpell:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                if self.spellID then
                    local findIndex= find_Type('spell', self.spellID)
                    if findIndex then
                        table.remove(Save.spell, findIndex)
                    else
                        table.insert(Save.spell, self.spellID)
                    end
                    self:set_tooltips()
                    self:set_alpha()
                end
            else
                e.LibDD:ToggleDropDownMenu(1, nil, button.Menu, self, 15, 0)
            end
        end)
    end
    
    btn.useSpell.spellID= spellID
    btn.useSpell:set_alpha()
    btn.useSpell:SetShown(spellID and true or false)    
end












function Init_Menu_List(_, level, type)
    local info
    if type then
        for index, ID in pairs(Save[type]) do
            local name, icon
            if type=='spell' then
                name= C_Spell.GetSpellName(ID)
                icon= C_Spell.GetSpellTexture(ID)
            else
                name= C_Item.GetItemNameByID(ID)
                icon=C_Item.GetItemIconByID(ID)
            end
            name=name or (type..'ID '..ID)
            local text=(icon and '|T'..icon..':0|t' or '') ..name
            info={
                text= name,
                notCheckable=true,
                icon=icon,
                keepShownOnClick=true,
            }

            if (type=='spell' and not IsSpellKnownOrOverridesKnown(ID)) or ((type=='item' or type=='equip') and C_Item.GetItemCount(ID)==0 and not PlayerHasToy(ID)) then
                info.text=format('|A:%s:0:0|a%s', e.Icon.disabled, info.text)
                info.colorCode='|cff9e9e9e'
            end

            local isToy= type=='item' and C_ToyBox.GetToyInfo(ID)
            if isToy then
                info.text= '|A:soulbinds_tree_conduit_icon_utility:0:0|a'..info.text
                info.tooltipOnButton=true
                info.tooltipTitle= e.onlyChinese and '添加/移除' or (ADD..'/'..REMOVE)
                info.tooltipText= (e.onlyChinese and '藏品->玩具箱' or (COLLECTIONS..'->'..TOY_BOX))..e.Icon.left
                info.arg1=ID
                info.func=function(_, arg1)
                    if ToyBox and not ToyBox:IsVisible() then
                        ToggleCollectionsJournal(3)
                    end
                    local name2= arg1 and select(2, C_ToyBox.GetToyInfo(arg1))
                    if name2 then
                        C_ToyBoxInfo.SetDefaultFilters()
                        if ToyBox.searchBox then
                            ToyBox.searchBox:SetText(name2)
                        end
                    end
                end
            else
                info.arg1={type=type, index=index, name=text, ID=ID}
                info.func=function(_, arg1)
                    StaticPopup_Show(id..addName..'REMOVE',arg1.name, '', arg1)
                end
                info.tooltipOnButton=true
                info.tooltipTitle='|cnRED_FONT_COLOR:'..REMOVE..'|r'
            end
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        local cleraAllText='|cnRED_FONT_COLOR:'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..'|r '..(type=='spell' and (e.onlyChinese and '法术' or SPELLS) or type=='item' and (e.onlyChinese and '物品' or ITEMS) or (e.onlyChinese and '装备' or EQUIPSET_EQUIP))..' #'..'|cnGREEN_FONT_COLOR:'..#Save[type]..'|r'
        info={--清除全部
            text=cleraAllText,
            notCheckable=true,
            keepShownOnClick=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '重新加载UI' or RELOADUI,
            arg1=cleraAllText,
            arg2= type,
            func=function(_, arg1, arg2)
                StaticPopup_Show(id..addName..'REMOVE', arg1 ,nil, {type=arg2, clearAll=true})
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    local tab={
        [e.onlyChinese and '物品' or ITEMS]='item',
        [e.onlyChinese and '法术' or SPELLS]='spell',
        [e.onlyChinese and '装备' or EQUIPSET_EQUIP]='equip'
    }
    for text, type2 in pairs(tab) do
        info={
            text=text..' |cnGREEN_FONT_COLOR:'..#Save[type2]..'|r',
            notCheckable=true,
            hasArrow=true,
            menuList=type2,
            keepShownOnClick=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level);
    end
    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '重新加载UI' or RELOADUI,
        notCheckable=true,
        keepShownOnClick=true,
        tooltipOnButton=true,
        tooltipTitle=SLASH_RELOAD2,
        func=function()
            e.Reload()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level);
    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '重置' or RESET,
        colorCode='|cffff0000',
        notCheckable=true,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT,
        tooltipText= e.onlyChinese and '重新加载UI' or RELOADUI,
        func=function()
            StaticPopup_Show(id..addName..'RESETALL')
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level);
    e.LibDD:UIDropDownMenu_AddButton({text=addName2, isTitle=true, notCheckable=true}, level);
    e.LibDD:UIDropDownMenu_AddButton({
        text= e.onlyChinese and '拖曳: 物品, 法术, 装备' or format('%s: %s, %s, %s', DRAG_MODEL, SPELLS, ITEMS, BAG_FILTER_EQUIPMENT),
        isTitle=true,
        notCheckable=true
    }, level)
end
    
































--选项，操作，按钮
local function Init_Options_Button()
    StaticPopupDialogs[id..addName..'REMOVE']={
        text=id..' '..addName2..'|n|n%s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1='|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r',
        button2=e.onlyChinese and '取消' or CANCEL,
        OnAccept = function(_, data)
            if data.clearAll then
                Save[data.type]={}
                e.Reload()
            else
                if Save[data.type][data.index] and Save[data.type][data.index]==data.ID then
                    table.remove(Save[data.type], data.index)
                    print(e.toolsFrame.addName, addName2, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r'..(e.onlyChinese and '完成' or COMPLETE), data.name, '|cnRED_FONT_COLOR:'..REQUIRES_RELOAD..'|r')
                else
                    print(e.toolsFrame.addName, addName2,'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '错误' or ERROR_CAPS)..'|r', e.onlyChinese and '未发现物品' or	BROWSE_NO_RESULTS, data.name)
                end
            end
        end,
    }

    StaticPopupDialogs[id..addName..'RESETALL']={--重置所有
        text=id..' '..addName2..'|n|n'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI),
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= e.onlyChinese and '重置' or RESET,
        button2= e.onlyChinese and '取消' or CANCEL,
        OnAccept = function()
            Save=nil
            e.Reload()
        end,
    }

    StaticPopupDialogs[id..addName..'ADD']={--添加, 移除
        text=id..' '..addName2..'|n|n%s: %s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= e.onlyChinese and '添加' or ADD,
        button2= e.onlyChinese and '取消' or CANCEL,
        button3= e.onlyChinese and '移除' or REMOVE,
        OnShow = function(self, data)
            local find=find_Type(data.type, data.ID)
            data.index=find
            self.button3:SetEnabled(find)
            self.button1:SetEnabled(not find)
        end,
        OnAccept = function(_, data)
            table.insert(Save[data.type], data.ID)
            print(e.toolsFrame.addName, addName2, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r', e.onlyChinese and '完成' or COMPLETE, data.name, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        OnAlt = function(_, data)
            table.remove(Save[data.type], data.index)
            print(e.toolsFrame.addName, addName2, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', e.onlyChinese and '完成' or COMPLETE, data.name, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
    }


    button.Menu=CreateFrame("Frame", nil, button, "UIDropDownMenuTemplate")
    e.LibDD:UIDropDownMenu_Initialize(button.Menu, Init_Menu_List, 'MENU')--主菜单


    button:SetScript('OnMouseDown',function(self, d)--添加, 移除
        local infoType, itemID, itemLink ,spellID= GetCursorInfo()
        if infoType == "item" and itemID and itemLink then
            local itemEquipLoc= select(4, C_Item.GetItemInfoInstant(itemLink))
            local slot= e.GetItemSlotID(itemEquipLoc)
            local type = slot and 'equip' or 'item'
            local text = slot and (e.onlyChinese and '装备' or EQUIPSET_EQUIP) or (e.onlyChinese and '物品' or ITEMS)
            local icon = C_Item.GetItemIconByID(itemLink)
            StaticPopup_Show(id..addName..'ADD', text , (icon and '|T'..icon..':0|t' or '')..itemLink, {type=type, name=itemLink, ID=itemID})
            ClearCursor()

        elseif infoType =='spell' and spellID then
            local spellLink=C_Spell.GetSpellLink(spellID) or ((e.onlyChinese and '法术' or SPELLS)..' ID: '..spellID)
            local icon=GetSpellTexture(spellID)
            StaticPopup_Show(id..addName..'ADD', SPELLS , (icon and '|T'..icon..':0|t' or '')..spellLink, {type='spell', name=spellLink, ID=spellID})
            ClearCursor()

        else            
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)
    button:SetScript('OnEnter',function (self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.toolsFrame.addName, addName2)
        e.tips:AddDoubleLine(e.onlyChinese and '拖曳' or DRAG_MODEL, e.onlyChinese and '添加' or ADD)
        e.tips:AddDoubleLine(e.onlyChinese and '法术' or SPELLS, e.onlyChinese and '物品，装备' or (ITEMS..', '..EQUIPSET_EQUIP), 0,1,0, 0,1,0)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:Show()
        self:SetAlpha(1.0)
    end)
    button:SetScript('OnLeave', function (self)
        self:SetAlpha(0.1)
        e.tips:Hide()
    end)
end








































--###
--初始
--###
local function Init()
    Init_All_Buttons()
    Init_Options_Button()
    
    hooksecurefunc('SpellFlyoutButton_UpdateGlyphState', function(self)--法术书，界面, Flyout, 菜单
        local frame= self:GetParent():GetParent()
        if not frame or not frame.useSpell or not self.spellID or C_Spell.IsSpellPassive(self.spellID) then
            if self.useSpell then
                self.useSpell:SetShown(false)
            end
        else
            set_Use_Spell_Button(self, self.spellID)
        end
    end)
end





--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("PLAYER_REGEN_ENABLED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            button=e.Cbtn(e.toolsFrame, {atlas='Soulbinds_Tree_Conduit_Icon_Utility', size={20,20}})
            button:SetPoint('BOTTOMLEFT', e.toolsFrame, 'TOPRIGHT',-2,5)

            if not WoWToolsSave[addName..'Tools'] then
                button:SetAlpha(1)
            else
                button:SetAlpha(0.1)
            end

            if (not WoWToolsSave or not WoWToolsSave[addName..'Tools']) and PlayerHasToy(156833) and Save.item[1]==194885 then
                Save.item[1] = 156833
            end

            Save= WoWToolsSave[addName..'Tools'] or Save
            Save.flyout= Save.flyout or {}

            addName2= '|A:soulbinds_tree_conduit_icon_utility:0:0|a'..(e.onlyChinese and '使用物品' or addName)

            if not e.toolsFrame.disabled then
                for _, ID in pairs(Save.item) do
                    e.LoadDate({id=ID, type='item'})
                end
                for _, ID in pairs(Save.spell) do
                    e.LoadDate({id=ID, type='spell'})
                end
                for _, ID in pairs(Save.equip) do
                    e.LoadDate({id=ID, type='item'})
                end

                C_Timer.After(2.3, function()
                    if UnitAffectingCombat('player') then
                        self.combat= true
                    else
                        Init()--初始
                    end
                end)
            else
                self:UnregisterAllEvents()
                self:SetShown(false)
            end

        elseif arg1=='Blizzard_Collections' then
            hooksecurefunc('ToySpellButton_UpdateButton', Init_Opetions_ToyBox)--玩具界面, 菜单

        elseif arg1=='Blizzard_PlayerSpells' then--法术书
            hooksecurefunc(SpellBookItemMixin, 'UpdateVisuals', function(frame)
                set_Use_Spell_Button(frame.Button, frame.spellBookItemInfo.spellID)
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then

            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if self.combat then
            self.combat=nil
            Init()--初始
        end
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)