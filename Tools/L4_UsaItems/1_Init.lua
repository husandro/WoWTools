WoWTools_UseItemsMixin={}

local P_Tabs={
    item={
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
        221966,--虫洞发生器：卡兹阿加
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
        --226373,--恒久诺格弗格药剂
    },
    spell={
        436854,--/切换飞行模式
        83958,--移动银行
        69046,--[呼叫大胖],种族特性
        50977,--[黑锋之门]
        193753,--[传送：月光林地]
        556,--[星界传送]
        18960,--[梦境行者]
        126892,--[禅宗朝圣]
    },
    equip={
        65274,65360, 63206, 63207, 63352, 63353,--协同披风
        103678,--迷时神器
        142469,--魔导大师的紫罗兰印戒
        144391, 144392,--拳手的重击指环
    },
    flyout={
    },
}


local function Save()
    return WoWToolsPlayerDate['Tools_UseItems']
end


function WoWTools_UseItemsMixin:Find_Type(type, ID)
    for index, ID2 in pairs(Save()[type] or {}) do
        if ID2==ID then
            return index
        end
    end
end



function WoWTools_UseItemsMixin:Init_Menu(root)
    local sub, sub2, num
    for text, type in pairs({
        [WoWTools_DataMixin.onlyChinese and '物品' or ITEMS]='item',
        [WoWTools_DataMixin.onlyChinese and '法术' or SPELLS]='spell',
        [WoWTools_DataMixin.onlyChinese and '装备' or EQUIPSET_EQUIP]='equip'
    }) do
        num= #Save()[type]
        sub=root:CreateButton(
            text,
        function(data)
            if data.type=='item' then
                WoWTools_LoadUIMixin:Journal(3)--加载，收藏，UI
            elseif data.type=='spell' then
                PlayerSpellsUtil.OpenToSpellBookTab()
            else
                WoWTools_LoadUIMixin:OpenPaperDoll(1, 1)--打开/关闭角色界面
            end
            return MenuResponse.Open
        end, {type=type, rightText= num})
        WoWTools_MenuMixin:SetRightText(sub)


        for index, ID in pairs(Save()[type]) do
            local name= (type=='item' or type=='equip')
                and WoWTools_ItemMixin:GetName(ID)
                or WoWTools_SpellMixin:GetName(ID)
                or ID

            local isToy, spellID, itemID
            if type=='item' then
                isToy= C_ToyBox.GetToyInfo(ID)
                itemID=ID
                WoWTools_DataMixin:Load(itemID, 'item')

            elseif type=='equip' then
                itemID=ID
                WoWTools_DataMixin:Load(itemID, 'item')

            else
                spellID=ID
                WoWTools_DataMixin:Load(spellID, 'spell')
            end

            local isSpell= spellID and C_SpellBook.IsSpellInSpellBook(spellID)

            sub2=sub:CreateButton(
                (isSpell and '|cnWARNING_FONT_COLOR:' or '')
                ..name,
            function(data)
--玩具箱
                if data.isToy then
                    WoWTools_LoadUIMixin:Journal(3, {toyItemID=data.itemID})
--已学，法术 bug
                elseif data.spellID and C_SpellBook.IsSpellInSpellBook(data.spellID) then
                    WoWTools_LoadUIMixin:SpellBook(3, data.spellID)
--其他
                else
                    StaticPopup_Show('WoWTools_OK',
                        (WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|n|n'..data.name..'|n',
                        nil,
                        {SetValue=function()
                            table.remove(Save()[data.type], data.index)
                        end}
                    )
                end
                return MenuResponse.Open
            end, {index=index, type=type, isToy=isToy, spellID=spellID, itemID=itemID, name=name, rightText=index})
--tooltip
            WoWTools_SetTooltipMixin:Set_Menu(sub2)
            WoWTools_MenuMixin:SetRightText(sub2)
        end

        if num>0 then
            sub:CreateDivider()
        end

        if num>1 then
--全部清除
            WoWTools_MenuMixin:ClearAll(sub, function()
                Save()[type]={}
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_UseItemsMixin.addName, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
        end
        sub:CreateButton(
            (WoWTools_DataMixin.onlyChinese and '重置' or RESET)..' |cnGREEN_FONT_COLOR:#'..#P_Tabs[type],
        function(data)
            StaticPopup_Show('WoWTools_OK',
                (WoWTools_DataMixin.onlyChinese and '重置' or RESET)..'|n|n'..data.text..'|n',
                nil,
                {SetValue=function()
                   Save()[data.type]= P_Tabs[data.type]
                   print(WoWTools_DataMixin.Icon.icon2..WoWTools_UseItemsMixin.addName, data.text, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end}
            )
        end, {type=type, text=text})

        WoWTools_MenuMixin:SetScrollMode(sub)
    end

--打开，选项
    root:CreateDivider()
    sub=WoWTools_ToolsMixin:OpenMenu(root, WoWTools_UseItemsMixin.addName)

--全部重置
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT,
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)..'|n|n'..(WoWTools_DataMixin.onlyChinese and "重新加载UI" or RELOADUI),
            nil,
            {SetValue=function()
                WoWToolsPlayerDate['Tools_UseItems']= nil
                WoWTools_DataMixin:Reload()
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_UseItemsMixin.addName, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end}
        )
    end)
    sub:CreateDivider()

--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
end















local function Init()
    StaticPopupDialogs['WoWToolsUseItemsADD']={--添加, 移除
        text= WoWTools_UseItemsMixin.addName..'|n|n%s: %s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= WoWTools_DataMixin.onlyChinese and '添加' or ADD,
        button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        button3= WoWTools_DataMixin.onlyChinese and '移除' or REMOVE,
        OnShow = function(self, data)
            local find=WoWTools_UseItemsMixin:Find_Type(data.type, data.ID)
            data.index=find
            local b1= self.button1 or self:GetButton1()
            local b3= self:GetButton3()
            b1:SetEnabled(not find)
            b3:SetEnabled(find)
        end,
        OnAccept = function(_, data)
            table.insert(Save()[data.type], data.ID)
            print(WoWTools_ToolsMixin.addName, WoWTools_UseItemsMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..'|r', WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE, data.name, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        OnAlt = function(_, data)
            table.remove(Save()[data.type], data.index)
            print(WoWTools_ToolsMixin.addName, WoWTools_UseItemsMixin.addName, '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|r', WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE, data.name, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
    }


    local btn=WoWTools_ButtonMixin:Cbtn(WoWTools_ToolsMixin:Get_MainButton().Frame, {
        atlas='Soulbinds_Tree_Conduit_Icon_Utility',
        size=22,
        name='WoWToolsToolsUseItemsAddMainButton'
    })
    btn:SetPoint('TOPLEFT', WoWTools_ToolsMixin:Get_MainButton(), 'TOPRIGHT')

    btn:SetScript('OnMouseDown',function(self, d)--添加, 移除
        local infoType, itemID, itemLink ,spellID= GetCursorInfo()
        if infoType == "item" and itemID and itemLink then
            local itemEquipLoc= select(4, C_Item.GetItemInfoInstant(itemLink))
            local slot= WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
            local type = slot and 'equip' or 'item'
            local text = slot and (WoWTools_DataMixin.onlyChinese and '装备' or EQUIPSET_EQUIP) or (WoWTools_DataMixin.onlyChinese and '物品' or ITEMS)
            local icon = select(5, C_Item.GetItemInfoInstant(itemLink))
            StaticPopup_Show('WoWToolsUseItemsADD', text , (icon and '|T'..icon..':0|t' or '')..itemLink, {type=type, name=itemLink, ID=itemID})
            ClearCursor()

        elseif infoType =='spell' and spellID then
            local spellLink=C_Spell.GetSpellLink(spellID) or ((WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)..' ID: '..spellID)
            local icon=C_Spell.GetSpellTexture(spellID)
            StaticPopup_Show('WoWToolsUseItemsADD',  WoWTools_DataMixin.onlyChinese and '法术' or SPELLS , (icon and '|T'..icon..':0|t' or '')..spellLink, {type='spell', name=spellLink, ID=spellID})
            ClearCursor()

        else
            MenuUtil.CreateContextMenu(self, WoWTools_UseItemsMixin.Init_Menu)
        end
    end)
    btn:SetScript('OnEnter',function (self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_ToolsMixin.addName, WoWTools_UseItemsMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '拖曳: 添加' or (DRAG_MODEL..': '..ADD))
        GameTooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '法术, 物品, 装备' or (SPELLS..', '..ITEMS..', '..EQUIPSET_EQUIP)))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
        self:SetAlpha(1.0)
    end)
    btn:SetScript('OnLeave', function (self)
        self:SetAlpha(0.3)
        GameTooltip:Hide()
    end)

    C_Timer.After(8, function()
        btn:SetAlpha(0.3)
    end)

    WoWTools_UseItemsMixin:Init_PlayerSpells()--法术书
    WoWTools_UseItemsMixin:Init_UI_Toy()

    Init=function()end
end










--加载保存数据
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsPlayerDate['Tools_UseItems']= WoWToolsPlayerDate['Tools_UseItems'] or P_Tabs

            WoWTools_UseItemsMixin.addName= '|A:soulbinds_tree_conduit_icon_utility:0:0|a'..(WoWTools_DataMixin.onlyChinese and '使用物品' or USE_ITEM)

            WoWTools_ToolsMixin:Set_AddList(function(category)
                WoWTools_PanelMixin:OnlyCheck({
                category= category,
                name= WoWTools_UseItemsMixin.addName,
                tooltip= WoWTools_UseItemsMixin.addName..'|n'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                end})
            end)

--禁用，Tools模块，退出
            if WoWTools_ToolsMixin:Get_MainButton() and not Save().disabled then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')

                for _, ID in pairs(Save().item) do
                   WoWTools_DataMixin:Load(ID, 'item')
                end
                for _, ID in pairs(Save().spell) do
                   WoWTools_DataMixin:Load(ID, 'spell')
                end
                for _, ID in pairs(Save().equip) do
                   WoWTools_DataMixin:Load(ID, 'item')
                end
            else
                self:SetScript('OnEvent', nil)
            end

            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        Init()
        WoWTools_UseItemsMixin:Init_All_Buttons()
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)