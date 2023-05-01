local id, e = ...
local addName=UNWRAP..ITEMS
local Save={
    use={--定义,使用物品, [ID]=数量(或组合数量)
        [190198]=5,
        [201791]=1,--龙类驯服手册》
        [198969]=1,--守护者的印记,  研究以使你的巨龙群岛工程学知识提高1点。

        [198790]=1,--10.0 加，声望物品
        [201781]=1,
        [201783]=1,
        [201779]=1,

        [201922]=1,--伊斯卡拉海象人徽章
        [200287]=1,
        [202092]=1,
        [200453]=1,

        [201924]=1,--瓦德拉肯联军徽章
        [202093]=1,
        [200455]=1,
        [200289]=1,

        [201923]=1,--马鲁克半人马徽章
        [200288]=1,
        [202094]=1,
        [200454]=1,


        [200285]=1,--龙鳞探险队徽章
        [201921]=1,
        [200452]=1,
        [202091]=1,
        [201782]=1,--提尔的祝福


        [204573]=1,--10.07 源石宝石
        [204574]=1,
        [204575]=1,
        [204576]=1,
        [204577]=1,
        [204578]=1,
        [204579]=1,

        --[[[190315]=10,--[活力之土] 没， 包含材料包
        [190328]=10,--[活力之霜]
        [198326]=10,--[活力之气]
        [190320]=10,--[活力之火]]
        
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
        [86143]=true,--pet
        [5512]=true,--SS糖

        [6948]=true,--10.0
        [194510]=true,
        [199197]=true,
        [200613]=true,
        [18149]=true,
        [194701]=true,
        [192749]=true,
        [140192]=true,
        [110560]=true,
        [204439]=true,
        [194743]=true,
        [194730]=true,
        [194519]=true,
        [202620]=true,

        --10.1
        [203708]=true
    },
    pet=true,
    open=true,
    toy=true,
    mount=true,
    mago=true,
    ski=true,
    alt=true,
    noItemHide= not e.Player.husandro,
}
local Combat, Bag, Opening= nil,{},nil
local panel= CreateFrame("Frame")
local button


--QUEST_REPUTATION_REWARD_TOOLTIP = "在%2$s中的声望提高%1$d点";
local function setCooldown()--冷却条
    if button:IsShown() then
        if Bag.bag and Bag.slot then
            local itemID = C_Container.GetContainerItemID(Bag.bag, Bag.slot)
            if itemID then
                local start, duration, enable = GetItemCooldown(itemID)
                button.texture:SetDesaturated(enable==1 and duration and duration>2)
                e.Ccool(button, start, duration, nil, true,nil, true)
                return
            end
        end
    end
    if button.cooldown then
        button.cooldown:Clear()
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

        Bag={bag=bag, slot=slot}

        button:SetAttribute("macrotext", '/use '..bag..' '..slot)
        button.texture:SetTexture(icon)
        num = GetItemCount(itemID)
        num= num~=1 and num or ''
        button:SetShown(true)
        --button:SetAttribute("type", "macro")
    else
        button:SetAttribute("macrotext", '')
        button:SetShown(not Save.noItemHide)
    end
    setCooldown()--冷却条
    button.count:SetText(num or '')
    button.texture:SetShown(bag and slot)
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
            local duration, enable = select(2, C_Container.GetContainerItemCooldown(bag, slot))
            local classID= info and info.itemID and select(6, GetItemInfoInstant(info.itemID))

            if info and info.itemID and info.hyperlink and not info.isLocked and info.iconFileID and not (duration and duration>2 or enable==0) and classID~=8 then
                e.LoadDate({id=info.itemID, type='item'})
                if Save.use[info.itemID] then--自定义
                    if Save.use[info.itemID]<=info.stackCount then
                        setAtt(bag, slot, info.iconFileID, info.itemID)
                        return
                    end

                elseif not Save.no[info.itemID] and not e.GetTooltipData({hyperLink=info.hyperlink, red=true, onlyRed=true}).red then--不出售, 可以使用
                    local _, _, _, _, itemMinLevel, _, _, _, itemEquipLoc, _, _, classID2, subclassID= GetItemInfo(info.hyperlink)
                    classID= classID or classID2
                    if itemEquipLoc and _G[itemEquipLoc] then--幻化
                        if Save.mago and (itemMinLevel and itemMinLevel<=e.Player.level or not itemMinLevel) and info.quality then--and (not info.isBound or (classID==4 and (subclassID==0 or subclassID==5))) then
                            local  isCollected, isSelf= select(2, e.GetItemCollected(info.hyperlink))
                            if not isCollected and isSelf then
                                setAtt(bag, slot, info.iconFileID, info.itemID)
                                equipItem=true
                                return
                            end
                        end

                    elseif info.hyperlink:find('Hbattlepet:(%d+)') or (classID==15 and subclassID==2) then--宠物, 收集数量
                        if Save.pet then
                            local speciesID = info.hyperlink:match('Hbattlepet:(%d+)') or select(13, C_PetJournal.GetPetInfoByItemID(info.itemID))--宠物物品                        
                            if speciesID then
                                local numCollected, limit= C_PetJournal.GetNumCollectedInfo(speciesID)
                                if numCollected and limit and numCollected <  limit then
                                    setAtt(bag, slot, info.iconFileID, info.itemID)
                                    return
                                end
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

                    elseif C_ToyBox.GetToyInfo(info.itemID) then
                        if Save.toy and not PlayerHasToy(info.itemID) then--玩具 
                            setAtt(bag, slot, info.iconFileID, info.itemID)
                            return
                        end

                    elseif Save.alt and classID~=0 then
                        local spell= select(2, GetItemSpell(info.hyperlink))
                        if spell and IsUsableSpell(spell) and not C_Item.IsAnimaItemByID(info.hyperlink) then
                            setAtt(bag, slot, info.iconFileID, info.itemID)
                            return
                        end
                        --[[if classID==0 and subclassID==8  then--声望，物品
                            setAtt(bag, slot, info.iconFileID, info.itemID)
                            return
                        else
                            --print(C_Item.IsItemSpecificToPlayerClass(info.hyperlink), info.hyperlink)
                        if C_Item.IsItemSpecificToPlayerClass(info.hyperlink) then
                            setAtt(bag, slot, info.iconFileID, info.itemID)
                            return
                        else]]
                        --[[if classID==15 and subclassID==4 then--其它
                            if info.itemID == 193201 or info.itemID==191251 then--钥匙框架
                                if GetItemCount(193201)>=3 and GetItemCount(191251)>=30 then
                                    setAtt(bag, slot, info.iconFileID, info.itemID)
                                    return
                                end
                            elseif not C_Item.IsAnimaItemByID(info.hyperlink) then
                                
                                setAtt(bag, slot, info.iconFileID, info.itemID)
                                return
                            end
                        end]]
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
        text= e.onlyChinese and '全部清除' or CLEAR_ALL,
        notCheckable=true,
        func=function()
            Save.use={}
            getItems()
            e.LibDD:CloseDropDownMenus()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)
    for itemID, num in pairs(Save.use) do
        info={
            text= (select(2, GetItemInfo(itemID)) or  ('itemID: '..itemID)).. (num>1 and ' |cnGREEN_FONT_COLOR:x'..num..'|r' or ''),
            icon= C_Item.GetItemIconByID(itemID),
            checked=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '移除' or REMOVE,
            tooltipText=num>1 and '\n'..(e.onlyChinese and '组合物品' or COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS))..'\n'..(e.onlyChinese and '数量' or AUCTION_STACK_SIZE)..': '..num..'\nitemID: '..itemID,
            func=function()
                Save.use[itemID]=nil
                getItems()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)
    end
end
local function setNoMenu(level)--二级,禁用
    local info={
        text= e.onlyChinese and '全部清除' or CLEAR_ALL,
        notCheckable=true,
        func=function()
            Save.no={}
            getItems()
            e.LibDD:CloseDropDownMenus()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    for itemID, _ in pairs(Save.no) do
        info={
            text=select(2, GetItemInfo(itemID)) or  ('itemID: '..itemID),
            icon=C_Item.GetItemIconByID(itemID),
            checked=true,
            tooltipOnButton=true,
            tooltipTitle=REMOVE,
            tooltipText= 'itemID: '..itemID,
            func=function()
                Save.no[itemID]=nil
                getItems()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
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

    local t={}
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
            t.tooltipTitle='|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE)..'|r'..e.Icon.mid..(e.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP)
        end
    else
        t.text=addName..': '..(e.onlyChinese and '无' or  NONE)
        t.isTitle=true
        t.tooltipOnButton=true
        t.tooltipTitle= e.onlyChinese and '使用/禁用' or (USE..'/'..DISABLE)
        t.tooltipText= e.onlyChinese and '拖曳物品到这里' or (DRAG_MODEL..ITEMS)
    end

    e.LibDD:UIDropDownMenu_AddButton(t)
    e.LibDD:UIDropDownMenu_AddSeparator()

    local no,use= 0, 0
    for _ in pairs(Save.no) do
        no=no+1
    end
    for _ in pairs(Save.use) do
        use=use+1
    end
    t={}--自定义禁用列表
    t.text= (e.onlyChinese and '禁用' or DISABLE)..' #'..no
    t.notCheckable=1
    t.menuList='NO'
    t.hasArrow=true
    e.LibDD:UIDropDownMenu_AddButton(t)

    t={}--自定义使用列表
    t.text= (e.onlyChinese and '使用' or USE)..' #'..use
    t.notCheckable=1
    t.menuList='USE'
    t.hasArrow=true
    e.LibDD:UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinese and '<右键点击打开>' or ITEM_OPENABLE,
        checked=Save.open,
        func=function()
            Save.open= not Save.open and true or nil
            getItems()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinese and '宠物' or PET,
        tooltipOnButton=true,
        tooltipTitle= '<3',
        checked=Save.pet,
        func=function()
            Save.pet= not Save.pet and true or nil
            getItems()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinese and '玩具' or TOY,
        checked=Save.toy,
        func=function()
            Save.toy= not Save.toy and true or nil
            getItems()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinese and '坐骑' or MOUNTS,
        checked=Save.mount,
        func=function()
            Save.mount= not Save.mount and true or nil
            getItems()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinese and '幻化' or TRANSMOGRIFY,
        checked=Save.mago,
        func=function()
            Save.mago= not Save.mago and true or nil
            getItems()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinese and '配方' or TRADESKILL_SERVICE_LEARN,
        checked=Save.ski,
        func=function()
            Save.ski= not Save.ski and true or nil
            getItems()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(t)

    t={
        text= e.onlyChinese and '其它' or BINDING_HEADER_OTHER,
        checked=Save.alt,
        func=function()
            Save.alt= not Save.alt and true or nil
            getItems()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(t)

    e.LibDD:UIDropDownMenu_AddSeparator()
    t={
        text= e.onlyChinese and '自动隐藏' or (AUTO_JOIN:gsub(JOIN,'')..HIDE),
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '未发现物品' or BROWSE_NO_RESULTS,
        func=function()
            Save.noItemHide= not Save.noItemHide and true or nil
            button:SetShown(Bag.bag or not Save.noItemHide)
        end,
        checked= Save.noItemHide
    }
    e.LibDD:UIDropDownMenu_AddButton(t)

    e.LibDD:UIDropDownMenu_AddButton({text= e.onlyChinese and '拖曳物品: 使用/禁用' or (DRAG_MODEL..ITEMS..'('..USE..'/'..DISABLE..')'), isTitle=true, notCheckable=true})
end


--########
--设置属性
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
                e.tips:AddDoubleLine(e.Icon.mid..(e.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP), e.onlyChinese and '禁用' or DISABLE, 1,0,0, 1,0,0 )
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
    button:SetAttribute("type", "macro")
    button.count=e.Cstr(button, {size=10, color=true})--10, nil, nil, true)
    button.count:SetPoint('BOTTOM',0,2)

    getItems()--设置属性

    button:SetScript("OnEnter",function(self)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID and itemLink then
            if Bag.bag and Bag.slot and itemLink== C_Container.GetContainerItemLink(Bag.bag, Bag.slot) then
                return
            end
            --添加，移除
            StaticPopupDialogs['OpenItmesUseOrDisableItem']={
                text=id..' '..addName..'\n\n%s\n%s\n\n'..(e.onlyChinese and '合成物品' or COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS))..' >1: ',
                whileDead=1,
                hideOnEscape=1,
                exclusive=1,
                timeout = 60,
                hasEditBox=1,
                button1='|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '使用' or USE)..'|r',
                button2=CANCEL,
                button3='|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE)..'|r',
                OnShow = function(self2, data)
                    self2.editBox:SetNumeric(true)
                    local num=Save.use[data.itemID] or 1
                    self2.editBox:SetNumber(num)
                    self2.editBox:SetAutoFocus(false)
                    self2.editBox:ClearFocus()
                end,
                OnAccept = function(self2, data)
                    local num= self2.editBox:GetNumber()
                    num = num<1 and 1 or num
                    Save.use[data.itemID]=num
                    Save.no[data.itemID]=nil
                    getItems()--取得背包物品信息
                    print(id, '|cnGREEN_FONT_COLOR:'..addName..'|r', num>1 and (e.onlyChinese and '合成物品' or COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS))..': '..'|cnGREEN_FONT_COLOR:'..num..'|r' or '', data.itemLink)
                end,
                OnAlt = function(self2, data)
                    Save.no[data.itemID]=true
                    Save.use[data.itemID]=nil
                    getItems()--取得背包物品信息
                    print(id, addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE)..'|r', data.itemLink)
                end,
                EditBoxOnTextChanged=function(self2)
                   local num= self2:GetNumber()
                    if num>1 then
                       self2:GetParent().button1:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '合成' or AUCTION_STACK_SIZE)..' '..num..'|r')
                    else
                        self2:GetParent().button1:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '使用' or USE)..'|r');
                    end
                end,
                EditBoxOnEscapePressed = function(s)
                    s:SetAutoFocus(false)
                    s:ClearFocus()
                    s:GetParent():Hide()
                end,
            }

            local icon
            icon= C_Item.GetItemIconByID(itemID)
            icon = icon and '|T'..icon..':0|t'..itemLink or ''
            local list=Save.use[itemID] and (e.onlyChinese and '当前列表' or PROFESSIONS_CURRENT_LISTINGS)..': |cff00ff00'..(e.onlyChinese and '使用' or USE)..'|r' or Save.no[itemID] and (e.onlyChinese and '当前列表' or PROFESSIONS_CURRENT_LISTINGS)..': |cffff0000'..(e.onlyChinese and '禁用' or DISABLE)..'|r' or ''
            StaticPopup_Show('OpenItmesUseOrDisableItem',icon,list, {itemID=itemID, itemLink=itemLink})
            ClearCursor()
        else
            shoTips(self)--显示提示
        end
    end)
    button:SetScript("OnLeave",function()
        e.tips:Hide()
        BattlePetTooltip:Hide()
        ResetCursor()
    end)
    button:SetScript("OnMouseDown", function(self,d)
        local key= IsModifierKeyDown()
        if (d=='RightButton' and not key) or not(Bag.bag and Bag.slot) then
            if not self.Menu then
                button.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")--菜单列表
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, setMenuList, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        else
            if d=='LeftButton' and not key and equipItem and not PaperDollFrame:IsVisible() then
                ToggleCharacter("PaperDollFrame")
            end
            if MerchantFrame:IsVisible() then
                MerchantFrame:SetShown(false)
            end
        end
    end)

    button:SetScript('OnMouseWheel',function(self,d)
        if d == 1 and not IsModifierKeyDown() then
            if Bag.slot and Bag.bag then
                setDisableCursorItem()--禁用当物品
                e.LibDD:CloseDropDownMenus()
                shoTips(self)--显示提示
            end
        end
    end)

    C_Timer.After(2, function() getItems() end)
end

--##########
--注册， 事件
--##########
local function set_Events()--注册， 事件
    if IsInInstance() and C_ChallengeMode.IsChallengeModeActive() then
        --panel:UnregisterEvent('BAG_UPDATE')
        panel:UnregisterEvent('BAG_UPDATE_DELAYED')
        panel:UnregisterEvent('BAG_UPDATE_COOLDOWN')
        panel:UnregisterEvent('PLAYER_REGEN_DISABLED')
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
        if not UnitAffectingCombat('player') then
            button:SetShown(false)
        end
    else
        --panel:RegisterEvent('BAG_UPDATE')
        panel:RegisterEvent('BAG_UPDATE_DELAYED')
        panel:RegisterEvent('BAG_UPDATE_COOLDOWN')
        panel:RegisterEvent('PLAYER_REGEN_DISABLED')
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
        getItems()
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName..'Tools'] or Save
            if not e.toolsFrame.disabled then

                button= e.Cbtn2('WoWToolsOpenItemsButton', WoWToolsMountButton)
                button:SetPoint('RIGHT', HearthstoneToolsButton, 'LEFT')

                panel:RegisterEvent('CHALLENGE_MODE_START')
                panel:RegisterEvent('PLAYER_ENTERING_WORLD')
                panel:RegisterEvent("PLAYER_LOGOUT")
                Init()
            end
            panel:UnregisterEvent("ADDON_LOADED")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_ENTERING_WORLD' or event=='CHALLENGE_MODE_START' then
        set_Events()--注册， 事件

    elseif  event=='BAG_UPDATE_DELAYED' then-- event=='BAG_UPDATE' orthen
            getItems()

    elseif event=='PLAYER_REGEN_DISABLED' then
        if Save.noItemHide then
            button:SetShown(false)
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if Combat then
            getItems()
        else
            button:SetShown(Bag.bag or not Save.noItemHide)
        end

    elseif event=='BAG_UPDATE_COOLDOWN' then
        setCooldown()--冷却条

    end
end)
