local id, e = ...





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

WoWTools_UseItemsMixin={
    Save= P_Tabs,
    P_Tabs=P_Tabs,
    addName=nil
}




function WoWTools_UseItemsMixin:Find_Type(type, ID)
    for index, ID2 in pairs(self.Save[type]) do
        if ID2==ID then
            return index
        end
    end
end























































--[[function Init_Menu_List(_, level, type)
    local info
    if type then
        for index, ID in pairs(WoWTools_UseItemsMixin.Save[type]) do
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
                    StaticPopup_Show('WoWToolsToolsUseItemsRemove',arg1.name, '', arg1)
                end
                info.tooltipOnButton=true
                info.tooltipTitle='|cnRED_FONT_COLOR:'..REMOVE..'|r'
            end
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        local cleraAllText='|cnRED_FONT_COLOR:'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..'|r '..(type=='spell' and (e.onlyChinese and '法术' or SPELLS) or type=='item' and (e.onlyChinese and '物品' or ITEMS) or (e.onlyChinese and '装备' or EQUIPSET_EQUIP))..' #'..'|cnGREEN_FONT_COLOR:'..#WoWTools_UseItemsMixin.Save[type]..'|r'
        info={--清除全部
            text=cleraAllText,
            notCheckable=true,
            keepShownOnClick=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '重新加载UI' or RELOADUI,
            arg1=cleraAllText,
            arg2= type,
            func=function(_, arg1, arg2)
                StaticPopup_Show('WoWToolsToolsUseItemsRemove', arg1 ,nil, {type=arg2, clearAll=true})
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
            text=text..' |cnGREEN_FONT_COLOR:'..#WoWTools_UseItemsMixin.Save[type2]..'|r',
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
            WoWTools_Mixin:Reload()
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
            StaticPopup_Show('WoWToolsUseItemsRESETALL')
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level);
    e.LibDD:UIDropDownMenu_AddButton({text=WoWTools_UseItemsMixin.addName, isTitle=true, notCheckable=true}, level);
    e.LibDD:UIDropDownMenu_AddButton({
        text= e.onlyChinese and '拖曳: 物品, 法术, 装备' or format('%s: %s, %s, %s', DRAG_MODEL, SPELLS, ITEMS, BAG_FILTER_EQUIPMENT),
        isTitle=true,
        notCheckable=true
    }, level)
end]]







































































--###
--初始
--###
local function Init()
    StaticPopupDialogs['WoWToolsToolsUseItemsRemove']={
        text=WoWTools_UseItemsMixin.addName..'|n|n%s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1='|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r',
        button2=e.onlyChinese and '取消' or CANCEL,
        OnAccept = function(_, data)
            if data.clearAll then
                WoWTools_UseItemsMixin.Save[data.type]={}
                WoWTools_Mixin:Reload()
            else
                if WoWTools_UseItemsMixin.Save[data.type][data.index] and WoWTools_UseItemsMixin.Save[data.type][data.index]==data.ID then
                    table.remove(WoWTools_UseItemsMixin.Save[data.type], data.index)
                    print(WoWTools_ToolsButtonMixin:GetName(), WoWTools_UseItemsMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r'..(e.onlyChinese and '完成' or COMPLETE), data.name, '|cnRED_FONT_COLOR:'..REQUIRES_RELOAD..'|r')
                else
                    print(WoWTools_ToolsButtonMixin:GetName(), WoWTools_UseItemsMixin.addName,'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '错误' or ERROR_CAPS)..'|r', e.onlyChinese and '未发现物品' or	BROWSE_NO_RESULTS, data.name)
                end
            end
        end,
    }

    StaticPopupDialogs['WoWToolsUseItemsRESETALL']={--重置所有
        text=WoWTools_UseItemsMixin.addName..'|n|n'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI),
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= e.onlyChinese and '重置' or RESET,
        button2= e.onlyChinese and '取消' or CANCEL,
        OnAccept = function()
            WoWTools_UseItemsMixin.Save=nil
            WoWTools_Mixin:Reload()
        end,
    }

    StaticPopupDialogs['WoWToolsUseItemsADD']={--添加, 移除
        text=WoWTools_UseItemsMixin.addName..'|n|n%s: %s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= e.onlyChinese and '添加' or ADD,
        button2= e.onlyChinese and '取消' or CANCEL,
        button3= e.onlyChinese and '移除' or REMOVE,
        OnShow = function(self, data)
            local find=WoWTools_UseItemsMixin:Find_Type(data.type, data.ID)
            data.index=find
            self.button3:SetEnabled(find)
            self.button1:SetEnabled(not find)
        end,
        OnAccept = function(_, data)
            table.insert(WoWTools_UseItemsMixin.Save[data.type], data.ID)
            print(WoWTools_ToolsButtonMixin:GetName(), WoWTools_UseItemsMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r', e.onlyChinese and '完成' or COMPLETE, data.name, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        OnAlt = function(_, data)
            table.remove(Save[data.type], data.index)
            print(WoWTools_ToolsButtonMixin:GetName(), WoWTools_UseItemsMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', e.onlyChinese and '完成' or COMPLETE, data.name, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
    }

    WoWTools_ToolsButtonMixin:Init_All_Buttons()
    WoWTools_ToolsButtonMixin:Init_Button()
    WoWTools_ToolsButtonMixin:Init_SpellFlyoutButton()--法术书，界面, Flyout, 菜单
end


















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            local btn= WoWTools_ToolsButtonMixin:GetButton()
            if btn then

                


                --if (not WoWToolsSave or not WoWToolsSave[addName..'Tools']) and PlayerHasToy(156833) and Save.item[1]==194885 then
                    --Save.item[1] = 156833
                --end

                if WoWToolsSave[USE_ITEM..'Tools'] then
                    WoWTools_UseItemsMixin.Save= WoWToolsSave[USE_ITEM..'Tools']
                    WoWTools_UseItemsMixin.Save.flyout= WoWTools_UseItemsMixin.Save.flyout or {}
                    WoWToolsSave[USE_ITEM..'Tools']=nil
                else
                    WoWTools_UseItemsMixin.Save = WoWToolsSave['Tools_UseItems'] or WoWTools_UseItemsMixin.Save
                end
                

                WoWTools_UseItemsMixin.addName= '|A:soulbinds_tree_conduit_icon_utility:0:0|a'..(e.onlyChinese and '使用物品' or USE_ITEM)


                for _, ID in pairs(WoWTools_UseItemsMixin.Save.item) do
                    e.LoadData({id=ID, type='item'})
                end
                for _, ID in pairs(WoWTools_UseItemsMixin.Save.spell) do
                    e.LoadData({id=ID, type='spell'})
                end
                for _, ID in pairs(WoWTools_UseItemsMixin.Save.equip) do
                    e.LoadData({id=ID, type='item'})
                end

                C_Timer.After(2.3, function()
                    if UnitAffectingCombat('player') then
                        self:RegisterEvent("PLAYER_REGEN_ENABLED")
                    else
                        Init()--初始
                    end
                end)

                if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                    WoWTools_UseItemsMixin:Init_UI_Toy()
                end

            else
                self:UnregisterEvent('ADDON_LOADED')
            end

        elseif arg1=='Blizzard_Collections' then
            WoWTools_UseItemsMixin:Init_UI_Toy()

        elseif arg1=='Blizzard_PlayerSpells' then--法术书
            WoWTools_ToolsButtonMixin:Init_PlayerSpells()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_UseItems']=WoWTools_UseItemsMixin.Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        Init()--初始
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)