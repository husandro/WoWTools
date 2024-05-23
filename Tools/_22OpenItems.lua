local id, e = ...
local addName=format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, ITEMS)
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

        [204075]=15,--雏龙的暗影烈焰纹章碎片 10.1
        [204076]=15,
        [204077]=15,
        [204717]=2,
        [190328]=10,--活力之霜
        [190322]=10,--活力秩序

        --10.2
        [208396]=2,--分裂的梦境火花
        --10.2.7
        --[219273]=1,--历久经验帛线 从 219256 到 219282
        


    },
    no={--禁用使用
        [64402]=true,--协同战旗
        [6948]=true,--炉石
        --[140192]=true,--达拉然炉石
        --[110560]=true,--要塞炉石
        [23247]=true,--燃烧之花
        [168416]=true,
        [109076]=true,
        [132119]=true,
        [193902]=true,
        [37863]=true,

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
        [92675]=true,--无瑕野兽战斗石
        [92741]=true,--无瑕战斗石

        --10.0
        [194510]=true,--伊斯卡拉鱼叉
        [199197]=true,--瓶装精
        [200613]=true,--艾拉格风石碎片
        [18149]=true,--召回符文
        [194701]=true,--不祥海螺
        [192749]=true,--时空水晶

        [204439]=true,--研究宝箱钥匙
        [194743]=true,--古尔查克的指示器
        [194730]=true,--鳞腹鲭鱼
        [194519]=true,--欧索利亚的协助
        [202620]=true,--毒素解药
        [191529]=true,--卓然洞悉
        [191526]=true,--次级卓然洞悉
        [193915]=true,
        [190320]=true,

        --10.1
        [203708]=true,--蜗壳哨
        [205982]=true,--失落的挖掘地图
        [207057]=true,--雪白战狼的赐福
        --10.2
        [208066]=true,--小小的梦境之种
        [208067]=true,--饱满的梦境之种
        [208047]=true,--硕大的梦境之种
        [210014]=true,--神秘的恒久之种
        [190324]=true,--觉醒秩序

        --12.2.7
        [217956]=true,
        [217608]=true,
        [217607]=true,
        [217606]=true,
        [217605]=true,
        [217930]=true,
        [217929]=true,
        [217928]=true,

        [217731]=true,
        [217730]=true,
        [217901]=true,

        [89770]=true,--一簇牦牛毛
        [219940]=true,--流星残片
        [95350]=true,---乌古的咒语

    },
    pet=true,
    open=true,
    toy=true,
    mount=true,
    mago=true,
    ski=true,
    alt=true,
    noItemHide= true,--not e.Player.husandro,
    --disabledCheckReagentBag= true,--禁用，检查，材料包
}






local button
local Bag= {}
local Combat





if e.Player.class=='ROGUE' then
    e.LoadDate({id=1804, type='spell'})--开锁 Pick Lock
end







--QUEST_REPUTATION_REWARD_TOOLTIP = "在%2$s中的声望提高%1$d点";
local function setCooldown()--冷却条
    local start, duration, enable
    if button:IsShown() then
        if Bag.bag and Bag.slot then
            local itemID = C_Container.GetContainerItemID(Bag.bag, Bag.slot)
            if itemID then
                start, duration, enable = C_Container.GetItemCooldown(itemID)
                button.texture:SetDesaturated(duration and duration>2 or not enable)
            end
        end
        e.Ccool(button, start, duration, nil, true,nil, true)
    end
end











local function setAtt(bag, slot, icon, itemID, spellID)--设置属性
    --if UnitAffectingCombat('player') or not UnitIsConnected('player') or UnitInVehicle('player') then
    if not button:CanChangeAttribute()  then
        Combat= true
        return
    end
    local num
    if bag and slot then
        Bag={bag=bag, slot=slot}
        if spellID then
            button:SetAttribute("macrotext1",'/cast '..(GetSpellInfo(spellID) or spellID)..'\n/use '..bag ..' '..slot)
        else
            button:SetAttribute("macrotext1", '/use '..bag..' '..slot)
        end

        button.texture:SetTexture(icon)
        num = C_Item.GetItemCount(itemID)
        num= num~=1 and num or ''
        button:SetShown(true)
    else
        button:SetAttribute("macrotext1", '')
        button:SetShown(not Save.noItemHide)
    end
    setCooldown()--冷却条
    button.count:SetText(num or '')
    button.texture:SetShown(bag and slot)
    Combat=nil
end











local equipItem--是装备时, 打开角色界面
local function get_Items()--取得背包物品信息
    --if UnitAffectingCombat('player') or not UnitIsConnected('player') then
    if not button:CanChangeAttribute() then
        Combat=true
        return
    end

    equipItem=nil
    Bag={}
    local itemMinLevel, classID, subclassID, _, info
    local bagMax= Save.disabledCheckReagentBag and NUM_BAG_FRAMES or (NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES )
    for bag= Enum.BagIndex.Backpack, bagMax do--Constants.InventoryConstants.NumBagSlots
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            info = C_Container.GetContainerItemInfo(bag, slot)
            local duration, enable
            if info and info.itemID then
                itemMinLevel, _, _, _, _, _, _, classID, subclassID= select(5, C_Item.GetItemInfo(info.itemID))
                duration, enable = select(2, C_Container.GetContainerItemCooldown(bag, slot))
            end

            
            if info
                and info.itemID
                and info.hyperlink
                and not info.isLocked
                and info.iconFileID
                and (not Save.no[info.itemID] or Save.use[info.itemID])--禁用使用
                and C_PlayerInfo.CanUseItem(info.itemID)--是否可使用
                and not (duration and duration>2 or enable==0) and classID~=8--冷却
                and ((itemMinLevel and itemMinLevel<=e.Player.level) or not itemMinLevel)--使用等级
            then
                --e.LoadDate({id=info.itemID, type='item'})
                if Save.use[info.itemID] then--自定义
                    if Save.use[info.itemID]<=info.stackCount then
                        setAtt(bag, slot, info.iconFileID, info.itemID)
                        return
                    end

                else
                    local dateInfo= e.GetTooltipData({hyperLink=info.hyperlink, red=true, onlyRed=true, text={LOCKED}})
                    if not dateInfo.red then--不出售, 可以使用                        

                        if info.hasLoot then--可打开
                            if Save.open then
                                if dateInfo.text[LOCKED] and e.Player.class=='ROGUE' then--DZ
                                    setAtt(bag, slot, info.iconFileID, info.itemID, 1804)--开锁 Pick Lock
                                else--if not dateInfo.text[LOCKED] then
                                    setAtt(bag, slot, info.iconFileID, info.itemID)
                                end
                                return
                            end

                        elseif classID==9 then--配方                    
                            if Save.ski then
                                if subclassID == 0 then
                                    if C_Item.GetItemSpell(info.hyperlink) then
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

                        elseif classID==4 or classID==2 then-- itemEquipLoc and _G[itemEquipLoc] then--幻化
                            if Save.mago then --and info.quality then
                                local  isCollected, isSelf= select(2, e.GetItemCollected(info.hyperlink, nil, nil, true))
                                if not isCollected and isSelf then
                                    setAtt(bag, slot, info.iconFileID, info.itemID)
                                    equipItem=true
                                    return
                                end
                            end

                        elseif Save.alt and ((classID~=12 and (classID==0 and subclassID==8 or classID~=0))
                           or (classID==15 and subclassID==4)
                        )
                        then-- 8 使用: 在龙鳞探险队中的声望提高1000点
                            local spell= select(2, C_Item.GetItemSpell(info.hyperlink))
                            if spell  and not C_Item.IsAnimaItemByID(info.hyperlink) and C_Item.IsUsableItem(info.hyperlink) then
                                --and IsUsableSpell(spell)
                                if info.itemID==207002 then--封装命运
                                    if not e.WA_GetUnitBuff('player', 415603, 'HELPFUL') then
                                        setAtt(bag, slot, info.iconFileID, info.itemID)
                                        return
                                    end
                                else
                                    setAtt(bag, slot, info.iconFileID, info.itemID)
                                    return
                                end
                            end
                        elseif PlayerGetTimerunningSeasonID() and (info.itemID>=219256 and info.itemID<=219282) and C_Item.IsUsableItem(info.hyperlink) then--将帛线织入你的永恒潜能披风，使你获得的经验值永久提高12%。
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
    get_Items()
end

















--####
--菜单
--####
local function setMenuList(_, level, menuList)--主菜单
    local info={}
    if menuList=='USE' then
        local find
        for itemID, num in pairs(Save.use) do--二级, 使用
            e.LoadDate({id=itemID, type='item'})
            info={
                text= (select(2, C_Item.GetItemInfo(itemID)) or  ('itemID: '..itemID)).. (num>1 and ' |cnGREEN_FONT_COLOR:x'..num..'|r' or ''),
                icon= C_Item.GetItemIconByID(itemID),
                checked=true,
                keepShownOnClick=true,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '移除' or REMOVE,
                tooltipText=num>1 and '|n'..(e.onlyChinese and '组合物品' or COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS))..'|n'..(e.onlyChinese and '数量' or AUCTION_STACK_SIZE)..': '..num..'|nitemID: '..itemID,
                func=function()
                    Save.use[itemID]=nil
                    get_Items()
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info,level)
            find= true
        end
        if find then
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            info={
                text= e.onlyChinese and '全部清除' or CLEAR_ALL,
                notCheckable=true,
                keepShownOnClick=true,
                func=function()
                    Save.use={}
                    get_Items()
                    e.LibDD:CloseDropDownMenus()
                end
            }
        else
            info={
                text=e.onlyChinese and '无' or NONE,
                isTitle=true,
                notCheckable=true,
            }
        end
        e.LibDD:UIDropDownMenu_AddButton(info,level)
        return

    elseif menuList=='NO' then
        local find
        for itemID, _ in pairs(Save.no) do
            e.LoadDate({id=itemID, type='item'})
            info={
                text=select(2, C_Item.GetItemInfo(itemID)) or  ('itemID: '..itemID),
                icon=C_Item.GetItemIconByID(itemID),
                checked=true,
                keepShownOnClick=true,
                tooltipOnButton=true,
                tooltipTitle=REMOVE,
                tooltipText= 'itemID: '..itemID,
                func=function()
                    Save.no[itemID]=nil
                    get_Items()
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            find=true
        end
        if find then
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            info={
                text= e.onlyChinese and '全部清除' or CLEAR_ALL,
                notCheckable=true,
                keepShownOnClick=true,
                func=function()
                    Save.no={}
                    get_Items()
                    e.LibDD:CloseDropDownMenus()
                end,
            }
        else
            info={
                text=e.onlyChinese and '无' or NONE,
                isTitle=true,
                notCheckable=true,
            }
        end
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end


    info={
        keepShownOnClick=true,
        notCheckable=true,
        tooltipOnButton=true,
    }
    if Bag.bag and Bag.slot then
        info.text=C_Container.GetContainerItemLink(Bag.bag, Bag.slot) or ('bag: '..Bag.bag ..' slot: '..Bag.slot)
        local bagInfo=C_Container.GetContainerItemInfo(Bag.bag, Bag.slot)
        info.icon= bagInfo and bagInfo.iconFileID
        info.func=function()
            setDisableCursorItem()--禁用当物品
        end
        if not UnitAffectingCombat('player') then
            info.tooltipTitle='|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE)..'|r'..e.Icon.mid..(e.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP)
        end
    else
        info.text=addName..': '..(e.onlyChinese and '无' or  NONE)
        info.isTitle=true
        info.tooltipTitle= e.onlyChinese and '使用/禁用' or (USE..'/'..DISABLE)
        info.tooltipText= e.onlyChinese and '拖曳物品到这里' or (DRAG_MODEL..ITEMS)
    end

    e.LibDD:UIDropDownMenu_AddButton(info, level)
    e.LibDD:UIDropDownMenu_AddSeparator(level)

    local no,use= 0, 0
    for _ in pairs(Save.no) do
        no=no+1
    end
    for _ in pairs(Save.use) do
        use=use+1
    end

    info={--自定义禁用列表
        text= (e.onlyChinese and '禁用' or DISABLE)..' #'..no,
        notCheckable=1,
        menuList='NO',
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={--自定义使用列表
        text= (e.onlyChinese and '使用' or USE)..' #'..use,
        notCheckable=1,
        menuList='USE',
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '<右键点击打开>' or ITEM_OPENABLE,
        checked=Save.open,
        keepShownOnClick=true,
        func=function()
            Save.open= not Save.open and true or nil
            get_Items()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '宠物' or PET,
        tooltipOnButton=true,
        tooltipTitle= '<3',
        checked=Save.pet,
        keepShownOnClick=true,
        func=function()
            Save.pet= not Save.pet and true or nil
            get_Items()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '玩具' or TOY,
        checked=Save.toy,
        keepShownOnClick=true,
        func=function()
            Save.toy= not Save.toy and true or nil
            get_Items()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '坐骑' or MOUNTS,
        checked=Save.mount,
        keepShownOnClick=true,
        func=function()
            Save.mount= not Save.mount and true or nil
            get_Items()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '幻化' or TRANSMOGRIFY,
        checked=Save.mago,
        keepShownOnClick=true,
        func=function()
            Save.mago= not Save.mago and true or nil
            get_Items()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '配方' or TRADESKILL_SERVICE_LEARN,
        checked=Save.ski,
        keepShownOnClick=true,
        func=function()
            Save.ski= not Save.ski and true or nil
            get_Items()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '其它' or BINDING_HEADER_OTHER,
        checked=Save.alt,
        keepShownOnClick=true,
        func=function()
            Save.alt= not Save.alt and true or nil
            get_Items()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)


    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '材料包' or EQUIP_CONTAINER_REAGENT:gsub(EQUIPSET_EQUIP,''),
        checked= not Save.disabledCheckReagentBag,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '检查' or WHO,
        func= function()
            Save.disabledCheckReagentBag= not Save.disabledCheckReagentBag and true or nil
            get_Items()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
        keepShownOnClick=true,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '未发现物品' or BROWSE_NO_RESULTS,
        func=function()
            Save.noItemHide= not Save.noItemHide and true or nil
            button:SetShown(Bag.bag or not Save.noItemHide)
        end,
        checked= Save.noItemHide
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddButton({text= e.onlyChinese and '拖曳物品: 使用/禁用' or (DRAG_MODEL..ITEMS..'('..USE..'/'..DISABLE..')'), isTitle=true, notCheckable=true})
end

















--######
--初始化
--######
local function Init()
    button= e.Cbtn2({
        name= 'WoWToolsOpenItemsButton',
        parent=_G['WoWToolsMountButton'],
        click=true,-- right left
        notSecureActionButton=nil,
        notTexture=nil,
        showTexture=true,
        sizi=nil,
    })

    button:SetPoint('RIGHT', _G['HearthstoneToolsButton'], 'LEFT')
    button:SetAttribute("type1", "macro")
    button.count=e.Cstr(button, {size=10, color=true})--10, nil, nil, true)
    button.count:SetPoint('BOTTOM',0,2)

    get_Items()--设置属性

    function button:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if Bag.bag and Bag.slot then
            local itemLink= C_Container.GetContainerItemLink(Bag.bag, Bag.slot)
            if itemLink and itemLink:find('Hbattlepet:%d+') then
                BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(itemLink))
                e.tips:Hide()
            else
                e.tips:SetBagItem(Bag.bag, Bag.slot)
                if not UnitAffectingCombat('player') then
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.Icon.mid..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE))
                    e.tips:AddLine(e.Icon.right..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL))
                end
                e.tips:Show()
                if (BattlePetTooltip) then
                    BattlePetTooltip:Hide()
                end
            end
            e.FindBagItem(true, {itemLink= itemLink})--查询，背包里物品
        else
            e.tips:AddDoubleLine(id, e.cn(addName))
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
            e.tips:Show()
            if (BattlePetTooltip) then
                BattlePetTooltip:Hide()
            end
        end
    end


    button:SetScript("OnEnter",  function(self)
        self:set_tooltips()
        self:SetScript('OnUpdate', function (self, elapsed)
            self.elapsed = (self.elapsed or 0.3) + elapsed
            if self.elapsed > 0.3 then
                self.elapsed = 0
                if Bag.bag and Bag.slot and GameTooltip:IsOwned(self) then
                    local itemID= C_Container.GetContainerItemID(Bag.bag, Bag.slot)
                    if itemID~=select(3, GameTooltip:GetItem()) then
                        self:set_tooltips()
                    end
                end
            end
        end)
    end)
    button:SetScript("OnLeave",function(self)
        GameTooltip_Hide()
        ResetCursor()
        get_Items()
        e.FindBagItem(false)--查询，背包里物品
        self:SetScript('OnUpdate',nil)
        self.elapsed=nil
    end)
    button:SetScript("OnMouseDown", function(self,d)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID and itemLink then
            if Bag.bag and Bag.slot and itemLink== C_Container.GetContainerItemLink(Bag.bag, Bag.slot) then
                return
            end
            --添加，移除
            StaticPopupDialogs['OpenItmesUseOrDisableItem']={
                text=id..' '..addName..'|n|n%s|n%s|n|n'..(e.onlyChinese and '合成物品' or COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS))..' >1: ',
                whileDead=true, hideOnEscape=true, exclusive=true,
                hasEditBox=true,
                button1='|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '使用' or USE)..'|r',
                button2= e.onlyChinese and '取消' or CANCEL,
                button3='|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE)..'|r',
                OnShow = function(self2, data)
                    self2.editBox:SetNumeric(true)
                    local num=Save.use[data.itemID]
                    if not num then
                        local useStr=ITEM_SPELL_TRIGGER_ONUSE..'(.+)'--使用：
                        local dateInfo= e.GetTooltipData({bag=nil, guidBank=nil, merchant=nil, inventory=nil, hyperLink=data.itemLink, itemID=nil, text={useStr}, onlyText=true, wow=nil, onlyWoW=nil, red=nil, onlyRed=nil})--物品提示，信息 使用：
                        num= dateInfo.text[useStr] and dateInfo.text[useStr]:match('%d+')
                        num= num and tonumber(num)
                    end
                    num=num or 1
                    self2.editBox:SetNumber(num)
                    self2.editBox:SetAutoFocus(false)
                    self2.editBox:ClearFocus()
                end,
                OnHide= function(self2)
                    self2.editBox:SetText("")
                    e.call('ChatEdit_FocusActiveWindow')
                end,
                OnAccept = function(self2, data)
                    local num= self2.editBox:GetNumber()
                    num = num<1 and 1 or num
                    Save.use[data.itemID]=num
                    Save.no[data.itemID]=nil
                    get_Items()--取得背包物品信息
                    print(id, '|cnGREEN_FONT_COLOR:'..e.cn(addName)..'|r', num>1 and (e.onlyChinese and '合成物品' or COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS))..': '..'|cnGREEN_FONT_COLOR:'..num..'|r' or '', data.itemLink)
                end,
                OnAlt = function(self2, data)
                    Save.no[data.itemID]=true
                    Save.use[data.itemID]=nil
                    get_Items()--取得背包物品信息
                    print(id, e.cn(addName), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE)..'|r', data.itemLink)
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
            StaticPopup_Show('OpenItmesUseOrDisableItem', icon, list, {itemID=itemID, itemLink=itemLink})
            ClearCursor()
            return
        end


        local key= IsModifierKeyDown()
        if (d=='RightButton' and not key) then
            if not self.Menu then
                button.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")--菜单列表
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
            if SendMailFrame:IsShown() then
                MailFrame:SetShown(false)
            end
        end
    end)

    button:SetScript('OnMouseWheel',function(self, d)
        if d == 1 and not IsModifierKeyDown() then
            if Bag.slot and Bag.bag then
                setDisableCursorItem()--禁用当物品
                e.LibDD:CloseDropDownMenus()
                self:set_tooltips()
            end
        end
    end)

    C_Timer.After(2, get_Items)
end



















local panel= CreateFrame("Frame")
--##########
--注册， 事件
--##########
function panel:set_Events()--注册， 事件
    if IsInInstance() and C_ChallengeMode.IsChallengeModeActive() then
       -- self:UnregisterEvent('BAG_UPDATE')
        self:UnregisterEvent('BAG_UPDATE_DELAYED')
        self:UnregisterEvent('BAG_UPDATE_COOLDOWN')
        self:UnregisterEvent('PLAYER_REGEN_DISABLED')
        self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        if not UnitAffectingCombat('player') then
            button:SetShown(false)
        end
    else
       -- self:RegisterEvent('BAG_UPDATE')
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        self:RegisterEvent('BAG_UPDATE_COOLDOWN')
        self:RegisterEvent('PLAYER_REGEN_DISABLED')
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        get_Items()
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
                Init()
                self:RegisterEvent('CHALLENGE_MODE_START')
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent("PLAYER_LOGOUT")
            end
            self:UnregisterEvent("ADDON_LOADED")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_ENTERING_WORLD' or event=='CHALLENGE_MODE_START' then
        self:set_Events()--注册， 事件

    elseif event=='BAG_UPDATE_DELAYED' then-- or event=='BAG_UPDATE' then
            get_Items()

    elseif event=='PLAYER_REGEN_DISABLED' then
        if Save.noItemHide then
            button:SetShown(false)
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if Combat then
            get_Items()
        else
            button:SetShown(Bag.bag or not Save.noItemHide)
        end

    elseif event=='BAG_UPDATE_COOLDOWN' then
        setCooldown()--冷却条

    end
end)
