local id, e = ...
local Save={
    use={--定义,使用物品, [ID]=数量(或组合数量)
        [190198]=5,
        [201791]=1,--龙类驯服手册》
        [198969]=1,--守护者的印记,  研究以使你的巨龙群岛工程学知识提高1点。

        [198790]=1,--10.0 加，声望物品
        [201781]=1,
        [201783]=1,
        [201779]=1,
        
        --[190315]=10,--[活力之土]
        --[190328]=10,--[活力之霜]
        --[198326]=10,--[活力之气]
        --[190320]=10,--[活力之火]

    },
    no={--禁用使用
        [139590]=true,--[传送卷轴：拉文霍德]
        [141605]=true,--[飞行管理员的哨子]
        [163604]=true,--[撒网器5000型]
        [199900]=true,--[二手勘测工具]
        [198083]=true,--探险队补给包
        [191294]=true,--小型探险锹
        [202087]=true,--匠械移除设备
        [128353]=true,--海军上将的罗盘
    },
    pet=true, open=true, toy=true, mount=true, mago=true, ski=true, alt=true,
    noItemHide=not e.Player.husandro,
}

local addName=UNWRAP..ITEMS
local Combat, Bag, Opening= nil,{},nil


local panel=e.Cbtn2('WoWToolsOpenItemsButton', WoWToolsMountButton)
panel:SetPoint('RIGHT', HearthstoneToolsButton, 'LEFT')

local function setCooldown()--冷却条
    if panel:IsShown() then
        if Bag.bag and Bag.slot then
            local itemID = C_Container.GetContainerItemID(Bag.bag, Bag.slot)
            if itemID then
                local start, duration, enable = GetItemCooldown(itemID)
                e.Ccool(panel, start, duration, nil, true,nil, true)
                return
            end
        end
    end
    if panel.cooldown then
        panel.cooldown:Clear()
    end
end

local function setAtt(bag, slot, icon, itemID)--设置属性
    if UnitAffectingCombat('player') then
        Opening= nil
        Combat= true
        return
    end
    local num
    if bag and slot then
        if UnitAffectingCombat('player') then
            Opening= nil
            Combat= true
            return
        end
        local m='/use '..bag..' '..slot
        Bag={bag=bag, slot=slot}
        panel:SetAttribute("type", "macro")
        panel:SetAttribute("macrotext", m)
        panel.texture:SetTexture(icon)
        num = GetItemCount(itemID)
        num= num~=1 and num or ''
        panel:SetShown(true)
    else
        panel:SetAttribute("macrotext", '')
        panel:SetShown(not Save.noItemHide)
    end
    setCooldown()--冷却条
    panel.count:SetText(num or '')
    panel.texture:SetShown(bag and slot)
    Combat=nil
    Opening= nil
end

local equipItem--是装备时, 打开角色界面
local function getItems()--取得背包物品信息
    if UnitAffectingCombat('player') then
        Combat=true
        return
    elseif Opening then
        return
    end

    Opening= true
    equipItem=nil
    Bag={}

    for bag=0, NUM_BAG_SLOTS do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID and info.hyperlink and not info.isLocked and info.iconFileID then
                e.LoadSpellItemData(info.itemID)--加载法术, 物品数据
                if Save.use[info.itemID] then--自定义
                    if Save.use[info.itemID]<=info.stackCount then
                        setAtt(bag, slot, info.iconFileID, info.itemID)
                        return
                    end

                elseif not Save.no[info.itemID]  and not e.GetTooltipData(true, nil, nil, {bag=bag, slot=slot}) then--不出售, 可以使用
                    local itemName, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent= GetItemInfo(info.hyperlink)
                    if itemEquipLoc and _G[itemEquipLoc] then--幻化
                        if Save.mago and (itemMinLevel and itemMinLevel<=e.Player.level or not itemMinLevel) and info.quality and info.quality>1 then--and (not info.isBound or (classID==4 and (subclassID==0 or subclassID==5))) then
                            local  isCollected, isSelf= select(2, e.GetItemCollected(info.hyperlink))
                            if not isCollected and isSelf then
                                setAtt(bag, slot, info.iconFileID, info.itemID)
                                equipItem=true
                                return
                            end
                        end

                    elseif info.hyperlink:find('Hbattlepet:(%d+)') or (classID==15 and subclassID==2) then--宠物, 收集数量
                        local speciesID = info.hyperlink:match('Hbattlepet:(%d+)') or select(13, C_PetJournal.GetPetInfoByItemID(info.itemID))--宠物物品                        
                        if speciesID then
                            local numCollected, limit= C_PetJournal.GetNumCollectedInfo(speciesID)
                            if numCollected and limit and numCollected <  limit then
                                setAtt(bag, slot, info.iconFileID, info.itemID)
                                return
                            end
                        end

                    elseif info.hasLoot then--可打开
                        if Save.open then
                            setAtt(bag, slot, info.iconFileID, info.itemID)
                            return
                        end

                    elseif classID==9 then--配方                    
                        if Save.ski then
                            if subclassID == 0 then
                                if GetItemSpell(info.hyperlink) then
                                    setAtt(bag, slot, info.iconFileID, info.itemID)
                                end
                            else
                                setAtt(bag, slot, info.iconFileID, info.itemID)
                            end
                            return
                        end

                    elseif classID==15 and  subclassID==5 then--坐骑
                        if Save.mount then
                            local mountID = C_MountJournal.GetMountFromItem(info.itemID)
                            if mountID then
                                local isCollected =select(11, C_MountJournal.GetMountInfoByID(mountID))
                                if not isCollected then
                                    setAtt(bag, slot, info.iconFileID, info.itemID)
                                    return
                                end
                            end
                        end

                    elseif classID==15 and subclassID==4 then--其它
                        if Save.alt and IsUsableItem(info.hyperlink) and not C_Item.IsAnimaItemByID(info.hyperlink) then
                            setAtt(bag, slot, info.iconFileID, info.itemID)
                            return
                        end
                    elseif C_ToyBox.GetToyInfo(info.itemID) then
                        if Save.toy and not PlayerHasToy(info.itemID) then--玩具 
                            setAtt(bag, slot, info.iconFileID, info.itemID)
                            return
                        end
                    end
                end
            end
        end
    end
    setAtt()
end

local function setDisableCursorItem()--禁用当物品
    if UnitAffectingCombat('player') then
        return
    end
    if Bag.bag and Bag.slot then
        local itemID=C_Container.GetContainerItemID(Bag.bag, Bag.slot)
        if itemID then
            Save.no[itemID]=true
            Save.use[itemID]=nil
        end
    end
    getItems()
end

--####
--菜单
--####
local function setUseMenu(level)--二级, 使用
    local info={
        text= e.onlyChinse and '全部清除' or CLEAR_ALL,
        notCheckable=true,
        func=function()
            Save.use={}
            getItems()
            CloseDropDownMenus()
        end
    }
    UIDropDownMenu_AddButton(info,level)
    for itemID, num in pairs(Save.use) do
        info={
            text= (select(2, GetItemInfo(itemID)) or  ('itemID: '..itemID)).. (num>1 and ' |cnGREEN_FONT_COLOR:x'..num..'|r' or ''),
            icon= C_Item.GetItemIconByID(itemID),
            checked=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '移除' or REMOVE,
            tooltipText=num>1 and '\n'..(e.onlyChinse and '组合物品' or COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS))..'\n'..(e.onlyChinse and '数量' or AUCTION_STACK_SIZE)..': '..num,
            func=function()
                Save.use[itemID]=nil
                getItems()
            end,
        }
        UIDropDownMenu_AddButton(info,level)
    end
end
local function setNoMenu(level)--二级,禁用
    local info={
        text= e.onlyChinse and '全部清除' or CLEAR_ALL,
        notCheckable=true,
        func=function()
            Save.no={}
            getItems()
            CloseDropDownMenus()
        end,
    }
    UIDropDownMenu_AddButton(info, level)

    for itemID, _ in pairs(Save.no) do
        info={
            text=select(2, GetItemInfo(itemID)) or  ('itemID: '..itemID),
            icon=C_Item.GetItemIconByID(itemID),
            checked=true,
            tooltipOnButton=true,
            tooltipTitle=REMOVE,
            func=function()
                Save.no[itemID]=nil
                getItems()
            end,
        }
        UIDropDownMenu_AddButton(info, level)
    end
end
local function setMenuList(self, level, menuList)--主菜单
    if menuList=='USE' then
        setUseMenu(level)
        return
    elseif menuList=='NO' then
        setNoMenu(level)
        return
    end

    local t=UIDropDownMenu_CreateInfo()
    t.notCheckable=true
    if Bag.bag and Bag.slot then
        t.text=C_Container.GetContainerItemLink(Bag.bag, Bag.slot) or ('bag: '..Bag.bag ..' slot: '..Bag.slot)
        local bagInfo=C_Container.GetContainerItemInfo(Bag.bag, Bag.slot)
        t.icon= bagInfo and bagInfo.iconFileID
        t.func=function()
            setDisableCursorItem()--禁用当物品
        end
        t.tooltipOnButton=true
        if not UnitAffectingCombat('player') then
            t.tooltipTitle='|cnRED_FONT_COLOR:'..(e.onlyChinse and '禁用' or DISABLE)..'|r'..e.Icon.mid..(e.onlyChinse and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP)
        end
    else
        t.text=addName..': '..(e.onlyChinse and '无' or  NONE)
        t.isTitle=true
        t.tooltipOnButton=true
        t.tooltipTitle= e.onlyChinse and '使用/禁用' or (USE..'/'..DISABLE)
        t.tooltipText= e.onlyChinse and '拖曳物品到这里' or (DRAG_MODEL..ITEMS)
    end

    UIDropDownMenu_AddButton(t)
    UIDropDownMenu_AddSeparator()

    local no,use= 0, 0
    for _ in pairs(Save.no) do
        no=no+1
    end
    for _ in pairs(Save.use) do
        use=use+1
    end
    t=UIDropDownMenu_CreateInfo()--自定义禁用列表
    t.text= (e.onlyChinse and '禁用' or DISABLE)..' #'..no
    t.notCheckable=1
    t.menuList='NO'
    t.hasArrow=true
    UIDropDownMenu_AddButton(t)

    t=UIDropDownMenu_CreateInfo()--自定义使用列表
    t.text= (e.onlyChinse and '使用' or USE)..' #'..use
    t.notCheckable=1
    t.menuList='USE'
    t.hasArrow=true
    UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinse and '<右键点击打开>' or ITEM_OPENABLE,
        checked=Save.open,
        func=function()
            if Save.open then
                Save.open=nil
            else
                Save.open=true
            end
            getItems()
        end
    }
    UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinse and '宠物' or PET,
        tooltipOnButton=true,
        tooltipTitle= '<3',
        checked=Save.pet,
        func=function()
            if Save.pet then
                Save.pet=nil
            else
                Save.pet=true
            end
            getItems()
        end
    }
    UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinse and '玩具' or TOY,
        checked=Save.toy,
        func=function()
            if Save.toy then
                Save.toy=nil
            else
                Save.toy=true
            end
            getItems()
        end
    }
    UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinse and '坐骑' or MOUNTS,
        checked=Save.mount,
        func=function()
            if Save.mount then
                Save.mount=nil
            else
                Save.mount=true
            end
            getItems()
        end
    }
    UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinse and '幻化' or TRANSMOGRIFY,
        checked=Save.mago,
        func=function()
            if Save.mago then
                Save.mago=nil
            else
                Save.mago=true
            end
            getItems()
        end,
    }
    UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinse and '配方' or TRADESKILL_SERVICE_LEARN,
        checked=Save.ski,
        func=function()
            if Save.ski then
                Save.ski=nil
            else
                Save.ski=true
            end
            getItems()
        end,
    }
    UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinse and '其它' or BINDING_HEADER_OTHER,
        checked=Save.alt,
        func=function()
            if Save.alt then
                Save.alt=nil
            else
                Save.alt=true
            end
            getItems()
        end
    }
    UIDropDownMenu_AddButton(t)

    UIDropDownMenu_AddSeparator()
    t={
        text= e.onlyChinse and '自动隐藏' or (AUTO_JOIN:gsub(JOIN,'')..HIDE),
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinse and '未发现物品' or BROWSE_NO_RESULTS,
        func=function()
            if Save.noItemHide  then
                Save.noItemHide =nil
            else
                Save.noItemHide =true
            end
            panel:SetShown(Bag.bag or not Save.noItemHide)
        end,
        checked= Save.noItemHide
    }
    UIDropDownMenu_AddButton(t)

    UIDropDownMenu_AddButton({text= e.onlyChinse and '拖曳物品: 使用/禁用' or (DRAG_MODEL..ITEMS..'('..USE..'/'..DISABLE..')'), isTitle=true, notCheckable=true})
end


--########
--设置属性
StaticPopupDialogs['OpenItmesUseOrDisableItem']={
    text=id..' '..addName..'\n\n%s\n%s\n\n'..COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS)..' >1: ',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
	timeout = 60,
    hasEditBox=1,
    button1='|cnGREEN_FONT_COLOR:'..USE..'|r',
    button2=CANCEL,
    button3='|cnRED_FONT_COLOR:'..DISABLE..'|r',
    OnShow = function(self, data)
        self.editBox:SetNumeric(true)
        local num=Save.use[data.itemID]
        if num and num>1 then
            self.editBox:SetNumber(num)
        end
        --self.editBox:SetAutoFocus(false)
	end,
    OnAccept = function(self, data)
		local num= self.editBox:GetNumber()
        num = num<1 and 1 or num
        Save.use[data.itemID]=num
        Save.no[data.itemID]=nil
        getItems()--取得背包物品信息
        print(id, '|cnGREEN_FONT_COLOR:'..addName..'|r', num>1 and COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS)..': '..'|cnGREEN_FONT_COLOR:'..num..'|r' or '', data.itemLink)
	end,
    OnAlt = function(self, data)
        Save.no[data.itemID]=true
        Save.use[data.itemID]=nil
        getItems()--取得背包物品信息
        print(id, addName, '|cnRED_FONT_COLOR:'..DISABLE..'|r', data.itemLink)
    end,
    EditBoxOnTextChanged=function(self)
       local num= self:GetNumber()
        if num>1 then
           self:GetParent().button1:SetText('|cnGREEN_FONT_COLOR:'..AUCTION_STACK_SIZE..num..'|r')
        else
            self:GetParent().button1:SetText('|cnGREEN_FONT_COLOR:'..USE..'|r');
        end
    end,
    EditBoxOnEscapePressed = function(s)
        s:GetParent():Hide()
    end,
}

local function shoTips(self)--显示提示
    if e.tips:IsShown() then
        e.tips:Hide()
    end
    if (BattlePetTooltip) then
		BattlePetTooltip:Hide();
	end
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    if Bag.bag and Bag.slot then
        local battlePetLink= C_Container.GetContainerItemLink(Bag.bag, Bag.slot)
        if battlePetLink and battlePetLink:find('Hbattlepet:%d+') then
            BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(battlePetLink))
        else
            e.tips:SetBagItem(Bag.bag, Bag.slot)
            if not UnitAffectingCombat('player') then
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.Icon.mid..(e.onlyChinse and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP), e.onlyChinse and '禁用' or DISABLE, 1,0,0, 1,0,0 )
            end
            e.tips:Show()
        end
    else
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end
end
--######
--初始化
--######
local function Init()
    if e.toolsFrame.size and e.toolsFrame.size~=30 then--设置大小
        panel:SetSize(e.toolsFrame.size, e.toolsFrame.size)
    end

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")--菜单列表

    panel.count=e.Cstr(panel, 10, nil, nil, true)
    panel.count:SetPoint('BOTTOM',0,2)

    UIDropDownMenu_Initialize(panel.Menu, setMenuList, 'MENU')

    getItems()--设置属性

    panel:SetScript("OnEnter",function(self)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID and itemLink then
            if Bag.bag and Bag.slot and itemLink== C_Container.GetContainerItemLink(Bag.bag, Bag.slot) then
                return
            end
            local icon
            icon= C_Item.GetItemIconByID(itemID)
            icon = icon and '|T'..icon..':0|t'..itemLink or ''
            local list=Save.use[itemID] and (e.onlyChinse and '当前列表' or PROFESSIONS_CURRENT_LISTINGS)..': |cff00ff00'..(e.onlyChinse and '使用' or USE)..'|r' or Save.no[itemID] and (e.onlyChinse and '当前列表' or PROFESSIONS_CURRENT_LISTINGS)..': |cffff0000'..(e.onlyChinse and '禁用' or DISABLE)..'|r' or ''
            StaticPopup_Show('OpenItmesUseOrDisableItem',icon,list, {itemID=itemID, itemLink=itemLink})
            ClearCursor()
        else
            shoTips(self)--显示提示
        end
    end)
    panel:SetScript("OnLeave",function()
        e.tips:Hide()
        BattlePetTooltip:Hide()
        ResetCursor()
    end)
    panel:SetScript("OnMouseDown", function(self,d)
        local key= IsModifierKeyDown()
        if (d=='RightButton' and not key) or not(Bag.bag and Bag.slot) then
            ToggleDropDownMenu(1,nil,panel.Menu,self,self:GetWidth(),0)
        else
            if d=='LeftButton' and not key and equipItem and not PaperDollFrame:IsVisible() then
                ToggleCharacter("PaperDollFrame")
            end
            if MerchantFrame:IsVisible() then
                MerchantFrame:SetShown(false)
            end
        end
    end)

    panel:SetScript('OnMouseWheel',function(self,d)
        if d == 1 and not IsModifierKeyDown() then
            if Bag.slot and Bag.bag then
                setDisableCursorItem()--禁用当物品
                CloseDropDownMenus()
                shoTips(self)--显示提示
            end
        end
    end)

    C_Timer.After(2, function() getItems() end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('BAG_UPDATE')

panel:RegisterEvent('PLAYER_REGEN_DISABLED')
panel:RegisterEvent('PLAYER_REGEN_ENABLED')
panel:RegisterEvent('BAG_UPDATE_COOLDOWN')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
            if not e.toolsFrame.disabled then
                Init()
            else
                panel:UnregisterAllEvents()
            end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='BAG_UPDATE' then
            getItems()

    elseif event=='PLAYER_REGEN_DISABLED' then
        if Save.noItemHide then
            panel:SetShown(false)
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if Combat then
            getItems()
        else
            panel:SetShown(Bag.bag or not Save.noItemHide)
        end

    elseif event=='BAG_UPDATE_COOLDOWN' then
        setCooldown()--冷却条
    end
end)
