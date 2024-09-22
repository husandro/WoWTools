local id, e = ...
local addName
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
        [87779]=1,--远古郭莱储物箱钥匙

        --11
        [229899]=100,--宝匣钥匙碎片
        [224025]=10,--爆裂碎片
        [219191]=15,--草草写下的纸条


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

        --熊猫人之谜
        [102464]=true,--黑色灰烬
        [94233]=true,--镫恒的咒语

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

        --10.2.7
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
        
        --11
        [224185]=true--导蟹树枝

    },
    pet=true,
    open=true,
    toy=true,
    mount=true,
    mago=true,
    ski=true,
    alt=true,
    --noItemHide= true,--not e.Player.husandro,
    KEY=e.Player.husandro and 'F',
    --reagent= true,--禁用，检查，材料包
}






local OpenButton
local useText, noText




if e.Player.class=='ROGUE' then
    e.LoadData({id=1804, type='spell'})--开锁 Pick Lock
end











local function setAtt(bag, slot, icon, itemID, spellID, isUseMacro)--设置属性
    --if UnitAffectingCombat('player') or not UnitIsConnected('player') or UnitInVehicle('player') then
    if OpenButton.isDisabled then
        return
    elseif not OpenButton:CanChangeAttribute()  then
        OpenButton.isInCombat=true
        return
    end
    local num
    if bag and slot then
        if spellID then
            OpenButton:SetAttribute('type1', 'spell')
            OpenButton:SetAttribute('spell1', C_Spell.GetSpellName(spellID) or spellID)
            OpenButton:SetAttribute('target-item', bag..' '..slot)

        elseif isUseMacro then
            OpenButton:SetAttribute('type1', 'macro')
            OpenButton:SetAttribute("macrotext1", '/use '..bag..' '..slot)
            OpenButton:SetAttribute('target-item', nil)

        else
            OpenButton:SetAttribute('type1', 'item')
            OpenButton:SetAttribute('item1', (bag..' '..slot))
            OpenButton:SetAttribute('target-item', nil)
        end

        OpenButton.texture:SetTexture(icon)
        num = C_Item.GetItemCount(itemID)
        num= num~=1 and num or ''
        OpenButton:SetShown(true)
        OpenButton:SetBagAndSlot(bag, slot)
    else
        OpenButton:SetAttribute('type1', nil)
        OpenButton:SetAttribute('item1', nil)
        OpenButton:SetAttribute('spell1', nil)
        OpenButton:SetAttribute('macrotext1', nil)
        OpenButton:SetAttribute('target-item', nil)
        OpenButton:Clear()
    end




    OpenButton.count:SetText(num or '')
    OpenButton.texture:SetShown(bag and slot)
    OpenButton:set_key(not bag or not slot)
    OpenButton.IsInCheck=nil
end











local function get_Items()--取得背包物品信息
    if OpenButton.IsInCheck then
        return
    elseif not OpenButton:CanChangeAttribute() then
        OpenButton.isInCombat=true
        return
    end

    OpenButton.IsEquipItem=nil--是装备时, 打开角色界面
    OpenButton.IsInCheck=nil
    OpenButton:Clear()


    local itemMinLevel, classID, subclassID, _, info
    local bagMax= Save.reagent and (NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES ) or NUM_BAG_FRAMES
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
                --and C_PlayerInfo.CanUseItem(info.itemID)--是否可使用
                and not (duration and duration>2 or enable==0) and classID~=8--冷却
                and ((itemMinLevel and itemMinLevel<=e.Player.level) or not itemMinLevel)--使用等级
                and classID~=13
            then
                --e.LoadData({id=info.itemID, type='item'})
                if Save.use[info.itemID] then--自定义
                    if Save.use[info.itemID]<=info.stackCount then
                        setAtt(bag, slot, info.iconFileID, info.itemID)
                        return
                    end

                elseif C_Item.IsCosmeticItem(info.hyperlink) then--装饰品
                    if Save.mago then--and not C_Item.IsCosmeticItem(info.itemID) then --and info.quality then
                        local  isCollected, isSelf= select(2, WoWTools_CollectedMixin:Item(info.hyperlink, nil, nil, true))
                        if not isCollected and isSelf then
                            setAtt(bag, slot, info.iconFileID, info.itemID, nil, true)
                            return
                        end
                    end

                elseif C_Item.IsCurioItem(info.hyperlink) then--珍玩 SPELL_FAILED_CUSTOM_ERROR_1042 = "你的收藏中已经有了这个珍玩。";
                    local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=info.hyperlink, text={SPELL_FAILED_CUSTOM_ERROR_1042}, onlyText=true})
                    if not dateInfo.text[SPELL_FAILED_CUSTOM_ERROR_1042] then
                        setAtt(bag, slot, info.iconFileID, info.itemID)
                        return
                    end


                elseif classID==4 or classID==2 then-- itemEquipLoc and _G[itemEquipLoc] then--幻化
                    if Save.mago then--and not C_Item.IsCosmeticItem(info.itemID) then --and info.quality then
                        local  isCollected, isSelf= select(2, WoWTools_CollectedMixin:Item(info.hyperlink, nil, nil, true))
                        if not isCollected and isSelf then
                            setAtt(bag, slot, info.iconFileID, info.itemID)
                            OpenButton.IsEquipItem= true
                            return
                        end
                    end

                else
                    local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=info.hyperlink, red=true, text={LOCKED}})
                    if not dateInfo.red and C_PlayerInfo.CanUseItem(info.itemID) then--是否可使用 then--不出售, 可以使用
                        
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

                        elseif Save.alt
                            and C_Item.IsUsableItem(info.hyperlink)
                            and ((classID~=12 and (classID==0 and subclassID==8 or classID~=0))
                           or (classID==15 and subclassID==4)
                        )
                        then-- 8 使用: 在龙鳞探险队中的声望提高1000点
                            local spell= select(2, C_Item.GetItemSpell(info.hyperlink))
                            if spell  and not C_Item.IsAnimaItemByID(info.hyperlink) then
                                --and C_Spell.IsSpellUsable(spell)
                                if info.itemID==207002 then--封装命运
                                    if not WoWTools_AuraMixin:Get('player', 415603, 'HELPFUL') then
                                        setAtt(bag, slot, info.iconFileID, info.itemID)
                                        return
                                    end
                                else
                                    setAtt(bag, slot, info.iconFileID, info.itemID)
                                    return
                                end
                            end
                        elseif e.Is_Timerunning and (info.itemID>=219256 and info.itemID<=219282) then--将帛线织入你的永恒潜能披风，使你获得的经验值永久提高12%。
                            setAtt(bag, slot, info.iconFileID, info.itemID)
                            return
                        end
                    end
                end
            end
        end
    end
    setAtt()
    OpenButton:set_key(true)
end





















local function Edit_Item(info)
    StaticPopup_Show('WoWTools_EditText',
        addName..'|n|n'
        ..WoWTools_ItemMixin:GetName(info.itemID)..'|n|n'
        ..format(e.onlyChinese and '发现：%s' or ERR_ZONE_EXPLORED,
        Save.no[info.itemID] and noText
        or (Save.use[info.itemID] and useText)
        or (e.onlyChinese and '新' or NEW)
    ),
    nil,
    {
        itemID=info.itemID,
        itemLink=info.itemLink,

        text=Save.use[info.itemID],
        OnShow=function(s, data)
            s.editBox:SetNumeric(true)
            local useStr=ITEM_SPELL_TRIGGER_ONUSE..'(.+)'--使用：
            local dateInfo= WoWTools_ItemMixin:GetTooltip({bag=nil, guidBank=nil, merchant=nil, inventory=nil, hyperLink=data.itemLink, itemID=data.itemID, text={useStr}, onlyText=true, wow=nil, onlyWoW=nil, red=nil, onlyRed=nil})--物品提示，信息 使用：
            local num= dateInfo.text[useStr] and dateInfo.text[useStr]:match('%d+')
            num= num and tonumber(num)
            s.editBox:SetNumber(num or Save.use[data.itemID] or 1)
            s.button3:SetText(noText)
        end,
        OnHide=function(s)
            s.editBox:SetNumeric(false)
        end,
        SetValue= function(s, data)
            local num= s.editBox:GetNumber()
            num = num<1 and 1 or num
            Save.use[data.itemID]=num
            Save.no[data.itemID]=nil
            get_Items()--取得背包物品信息                        
            print(e.addName, addName,
                WoWTools_ItemMixin:GetLink(data.itemID),
                num>1 and
                    (e.onlyChinese and '合成物品' or COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS))..': '..'|cnGREEN_FONT_COLOR:'..num..'|r'
                    or useText
            )
        end,
        OnAlt=function(_, data)
            Save.no[data.itemID]=true
            Save.use[data.itemID]=nil
            get_Items()--取得背包物品信息
            print(e.addName, e.cn(addName),
                WoWTools_ItemMixin:GetLink(info.itemID),
                noText
            )
        end,
        EditBoxOnTextChanged=function(s)
            local num= s:GetNumber()
            if num>1 then
                s:GetParent().button1:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '合成' or AUCTION_STACK_SIZE)..' '..num..'|r')
            else
                s:GetParent().button1:SetText('|cnGREEN_FONT_COLOR:'..useText..'|r');
            end
        end,
    }
    )
    return MenuResponse.Open
end













local function Remove_NoUse_Menu_SetValue(data)
    print(e.addName, addName,
        Save[data.type][data.itemID]
        and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r'
        or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '物品不存在' or SPELL_FAILED_ITEM_GONE)),

        WoWTools_ItemMixin:GetLink(data.itemID),
        data.type=='no' and noText or useText
    )
    Save[data.type][data.itemID]=nil
    get_Items()
    return MenuResponse.Open
end



local function Remove_NoUse_Menu(root, itemID, type, numUse)
    e.LoadData({type='item', id=itemID})
    local tab=  {itemID=itemID, type=type}
    local sub=root:CreateButton(
        (numUse and numUse..'= ' or '')
        ..WoWTools_ItemMixin:GetName(itemID),
        Edit_Item,
        tab
    )
    WoWTools_SetTooltipMixin:Set_Menu(sub)

    if type=='use' then
        sub:CreateButton(
            e.Icon.left..(e.onlyChinese and '修改' or EDIT),
            Edit_Item,
            {itemID=itemID}
        )
        sub:CreateDivider()
    end
    --移除
    sub:CreateButton(
        '|A:common-icon-redx:0:0|a'..(e.onlyChinese and '移除' or REMOVE),
        Remove_NoUse_Menu_SetValue,
        tab
    )
end




local function Remove_All_Menu(root, type, num)
    root:CreateButton(
        (type=='use' and '|A:jailerstower-wayfinder-rewardcheckmark:0:0|a' or '|A:talents-button-reset:0:0|a')
        ..(e.onlyChinese and '全部清除' or CLEAR_ALL)..' #'..num,
    function(data)
        local index=0
        local type2= data.type=='no' and noText or useText
        print(e.addName, addName)
        for itemID in pairs(Save[data.type]) do
            index= index+1
            print(
                index..')',
                e.onlyChinese and '移除' or REMOVE,
                WoWTools_ItemMixin:GetLink(itemID),
                '|A:common-icon-redx:0:0|a'..type2
            )
        end
        print(e.onlyChinese and '全部清除' or CLEAR_ALL, '|A:common-icon-redx:0:0|a|cnGREEN_FONT_COLOR:#',  index)
        Save[data.type]={}
        get_Items()
    end, {type=type})
    root:CreateDivider()
end














--####
--菜单
--####
local function Init_Menu(self, root)
    local sub, sub2

    if self:IsValid() then
        sub= root:CreateButton(
            select(2, self:GetItemName(true)),
            function() self:set_disabled_current_item() end,
            {itemLink=self:GetItemLink()}
        )
        sub:SetTooltip(function(tooltip)
            tooltip:AddDoubleLine(noText)
            tooltip:AddDoubleLine(e.Icon.mid..(e.onlyChinese and '向上滚动' or COMBAT_TEXT_SCROLL_UP))

        end)
    else
        sub=root:CreateButton(e.onlyChinese and '无' or  NONE)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '使用/禁用' or (USE..'/'..DISABLE))
            tooltip:AddLine(e.onlyChinese and '拖曳物品到这里' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS))
        end)
    end
    root:CreateDivider()

    local no, use= 0, 0
    for _ in pairs(Save.no) do
        no=no+1
    end
    for _ in pairs(Save.use) do
        use=use+1
    end

--自定义禁用列表
    sub= root:CreateButton(
        noText..' #'..no,
    function() return MenuResponse.Open end)

    if no>2 then
        Remove_All_Menu(sub, 'no', no)
    end
    local index=0
    for itemID in pairs(Save.no) do
        index= index+1
        Remove_NoUse_Menu(sub, itemID, 'no', nil)
    end
    WoWTools_MenuMixin:SetGridMode(sub, no)


--自定义使用列表
    sub=root:CreateButton(
        useText..' #'..use,
    function() return MenuResponse.Open end)

    if use>2 then
        Remove_All_Menu(sub, 'use', use)
    end
    index=0
    for itemID, numUse in pairs(Save.use) do
        index= index+1
        Remove_NoUse_Menu(sub, itemID, 'use', numUse)
    end
    WoWTools_MenuMixin:SetGridMode(sub, use)


local OptionsList={{
    name=e.onlyChinese and '<右键点击打开>' or ITEM_OPENABLE,
    type='open'
},{
    name=e.onlyChinese and '坐骑' or MOUNTS or ITEM_OPENABLE,
    type='mount'
},{
    name=e.onlyChinese and '幻化' or TRANSMOGRIFY,
    type='mago'
}, {
    name=e.onlyChinese and '配方' or TRADESKILL_SERVICE_LEARN,
    type='ski'
}, {
    name=e.onlyChinese and '其它' or BINDING_HEADER_OTHER,
    type='alt'
}, {
    name=e.onlyChinese and '材料' or BAG_FILTER_REAGENTS,
    type='reagent',
    tooltip=e.onlyChinese and '检查' or WHO,
},
}
    for _, info in pairs(OptionsList) do
        sub= root:CreateCheckbox(
            info.name,
        function(data)
            return Save[data.type]
        end, function(data)
            Save[data.type]= not Save[data.type] and true
            get_Items()
        end, {type=info.type, tooltip=info.tooltip})
        if info.tooltip then
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.tooltip)
            end)
        end
    end

    root:CreateDivider()

--打开, 选项界面，菜单
    sub= WoWTools_ToolsButtonMixin:OpenMenu(root, addName, Save.KEY)

--设置捷键
    WoWTools_Key_Button:SetMenu(sub, {
        name=addName,
        key=Save.KEY,
        GetKey=function(key)
            Save.KEY=key
            OpenButton:settings()
        end,
        OnAlt=function(s)
            Save.KEY=nil
            OpenButton:settings()
        end,
    })

    sub:CreateDivider()
    sub2=sub:CreateTitle(
        e.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS),
    function()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(useText, noText)
    end)
end
























--######
--初始化
--######
local function Init()

    OpenButton.count=WoWTools_LabelMixin:CreateLabel(OpenButton, {size=10, color={r=1,g=1,b=1}})--10, nil, nil, true)
    OpenButton.count:SetPoint('BOTTOMRIGHT')

    WoWTools_Key_Button:Init(OpenButton, function() return Save.KEY end)
    Mixin(OpenButton, WoWTools_ItemLocationMixin)

    function OpenButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local bagID, slotIndex= self:GetBagAndSlot()
        if self:IsBagAndSlot() then
            local itemLink= C_Container.GetContainerItemLink(bagID, slotIndex)
            if itemLink and itemLink:find('Hbattlepet:%d+') then
                BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(itemLink))
                e.tips:Hide()
            else
                e.tips:SetBagItem(bagID, slotIndex)
                if not UnitAffectingCombat('player') then
                    e.tips:AddLine(' ')
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.Icon.mid..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP), noText)
                    e.tips:AddDoubleLine(e.Icon.right..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), (WoWTools_Key_Button:IsKeyValid(self) or '')..e.Icon.left)
                    e.tips:AddDoubleLine(e.Icon.mid..'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN), e.onlyChinese and '刷新' or REFRESH)
                    e.tips:Show()
                end

                if (BattlePetTooltip) then
                    BattlePetTooltip:Hide()
                end
            end
            WoWTools_BagMixin:Find(true, {itemLink= itemLink})--查询，背包里物品
        else
            e.tips:AddDoubleLine(e.addName, e.cn(addName))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.Icon.right..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), WoWTools_Key_Button:IsKeyValid(self))
            e.tips:AddDoubleLine(e.Icon.mid..'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN), e.onlyChinese and '刷新' or REFRESH)
            e.tips:Show()
            if (BattlePetTooltip) then
                BattlePetTooltip:Hide()
            end
        end


    end


    OpenButton:SetScript("OnEnter",  function(self)
        get_Items()
        WoWTools_ToolsButtonMixin:EnterShowFrame(self)
        self:set_tooltips()
        self:SetScript('OnUpdate', function (s, elapsed)
            s.elapsed = (s.elapsed or 0.3) + elapsed
            if s.elapsed > 0.3 then
                s.elapsed = 0
                if GameTooltip:IsOwned(s) then
                    local itemID= self:GetItemID()
                    if itemID then
                        if itemID~=select(3, GameTooltip:GetItem()) then
                            s:set_tooltips()
                        end
                    else
                        get_Items()
                    end
                end
            end
        end)
    end)
    OpenButton:SetScript("OnLeave",function(self)
        GameTooltip_Hide()
        ResetCursor()
        get_Items()
        WoWTools_BagMixin:Find(false)--查询，背包里物品
        self:SetScript('OnUpdate',nil)
        self.elapsed=nil
    end)
    OpenButton:SetScript("OnMouseDown", function(self,d)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID and itemLink then
            if self:IsValid() and self:GetItemID()==itemID then
                return
            end
            Edit_Item({itemID=itemID, itemLink=itemLink})
            ClearCursor()
            return
        end


        local key= IsModifierKeyDown()
        if (d=='RightButton' and not key) then
            MenuUtil.CreateContextMenu(self, Init_Menu)

        else
            if d=='LeftButton' and not key and OpenButton.IsEquipItem and not PaperDollFrame:IsVisible() then
                ToggleCharacter("PaperDollFrame")
            end
            if MerchantFrame:IsShown() and MerchantFrame:CanChangeAttribute() then
                MerchantFrame:Hide()
            end
            if SendMailFrame:IsShown() and SendMailFrame:CanChangeAttribute() then
                MailFrame:Hide()
            end
            if ScrappingMachineFrame and ScrappingMachineFrame:IsShown() and ScrappingMachineFrame:CanChangeAttribute() then
                ScrappingMachineFrame:Hide()
            end
        end
    end)

    OpenButton:SetScript('OnMouseWheel',function(self, d)
        if IsModifierKeyDown() then
            return
        end
        if d == 1 then
            self:set_disabled_current_item()--禁用当物品
            self:set_tooltips()
        elseif d==-1 then
            self:settings()
        end
    end)
    OpenButton:SetScript('OnShow', function(self)
        self:settings()
        get_Items()
    end)

    OpenButton:SetScript('OnHide', function(self)
        self:settings()
    end)



    OpenButton:SetScript('OnEvent', function(self, event)

        if event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_MAP_CHANGED' then--出进副本
            self:SetShown(not IsInInstance() or WoWTools_MapMixin:IsInDelve())
            self:settings()

        elseif event=='PLAYER_MOUNT_DISPLAY_CHANGED'--上下坐骑
            or event=='UNIT_ENTERED_VEHICLE'--车辆
            or event=='UNIT_EXITED_VEHICLE'
            or event=='PET_BATTLE_CLOSE'
            or event=='PET_BATTLE_OPENING_DONE'

        then
            self:settings()

        elseif event=='BAG_UPDATE_COOLDOWN' then--冷却
            self:set_cooldown()

        elseif event=='PLAYER_REGEN_DISABLED' then
            ClearOverrideBindings(self)--清除KEY
            WoWTools_Key_Button:SetTexture(self)

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:set_key(false)
            if self.isInCombat then
                get_Items()
            end

        elseif event=='BAG_UPDATE_DELAYED' then
            get_Items()
        end
    end)







    OpenButton:RegisterEvent('PLAYER_MAP_CHANGED')
    OpenButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    OpenButton.events={
        'BAG_UPDATE_COOLDOWN',
        'BAG_UPDATE_DELAYED',
        'PLAYER_REGEN_DISABLED',
        'PLAYER_REGEN_ENABLED',
        'PET_BATTLE_CLOSE',
        'PET_BATTLE_OPENING_DONE'
    }
    OpenButton.eventUnit={
        'UNIT_ENTERED_VEHICLE',--车辆
        'UNIT_EXITED_VEHICLE',
    }

    function OpenButton:settings()
        self.isDisabled= (IsInInstance() and not WoWTools_MapMixin:IsInDelve())
                        or not self:IsVisible()
                        or not C_PetBattles.IsInBattle()
                        or not UnitHasVehicleUI('player')

        if self.isDisabled then
            FrameUtil.UnregisterFrameForEvents(self, self.events)
            FrameUtil.UnregisterFrameForEvents(self, self.eventUnit)
        else
            FrameUtil.RegisterFrameForEvents(self, self.events)
            FrameUtil.RegisterFrameForUnitEvents(self, self.eventUnit, 'player')
        end

        if Save.KEY and not self.isDisabled then
            self:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')--上下坐骑
        else
            self:UnregisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
        end

        if self:CanChangeAttribute() then
            self:set_key(self.isDisabled)
            self:SetShown(not self.isDisabled)
        else
            self.isInCombat=true
        end
    end

--设置捷键
    function OpenButton:set_key()
        if Save.KEY then
            WoWTools_Key_Button:Setup(OpenButton,
                self.isDisabled
                or not self:IsValid()
                or IsMounted()
                or UnitInVehicle('player')
                or (IsInInstance() and not WoWTools_MapMixin:IsInDelve())
                or C_PetBattles.IsInBattle()
            )
        end
    end

    function OpenButton:set_cooldown()--冷却条
        local start, duration, enable
        if self:IsValid() then
            start, duration, enable = OpenButton:GetItemCooldown()
            self.texture:SetDesaturated(not enable)
        end
        e.Ccool(OpenButton, start, duration, nil, true,nil, true)
    end

    function OpenButton:set_disabled_current_item()--禁用当物品
        if self:IsValid() then
            local itemID= self:GetItemID()
            if itemID then
                Save.no[itemID]=true
                Save.use[itemID]=nil
            end
            get_Items()
        end
        return MenuResponse.Open
    end

    OpenButton:settings()
    C_Timer.After(4, get_Items)
end


















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave['Tools_OpenItems'] or Save
            addName= '|A:BonusLoot-Chest:0:0|a'..(e.onlyChinese and '打开物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, ITEMS))
            OpenButton= WoWTools_ToolsButtonMixin:CreateButton({
                name='OpenItems',
                tooltip=addName,
            })

            if OpenButton then
                noText= '|A:talents-button-reset:0:0|a'..(e.onlyChinese and '禁用' or DISABLE)
                useText= '|A:jailerstower-wayfinder-rewardcheckmark:0:0|a'..(e.onlyChinese and '使用' or USE)

                Init()

            end
            self:UnregisterEvent("ADDON_LOADED")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_OpenItems'] = Save
        end
    end
end)