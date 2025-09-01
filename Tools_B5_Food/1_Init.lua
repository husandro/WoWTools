
WoWTools_FoodMixin={}




--5512/治疗石 113509/魔法汉堡
local ClassSpells={--{item=5512, alt=nil, shift=nil, ctrl=nil}
    WARRIOR= {shift=6673},--zs 6673/战斗怒吼
    PALADIN= {},--qs
    HUNTER= {},--lr
    ROGUE= {},--dz
    PRIEST= {shift=21562,},--ms 21562/真言术：韧
    DEATHKNIGHT= {},--dk
    SHAMAN= {shift=462854},--sm 462854/天怒
    MAGE= {item=113509, shift=1459, alt=190336},--fs 113509/魔法汉堡 190336/造餐术 190336/造餐术
    WARLOCK= {alt=29893, shift=698, ctrl=6201},--ss 29893/制造灵魂之井 6201/制造治疗石 698/召唤仪式
    MONK= {},--ws
    DRUID= {shift=1126},--xd 1126/野性印记
    DEMONHUNTER= {},--dh
    EVOKER= {shift=364342},--ev 364342/青铜龙的祝福
}


local P_Save={
    noUseItems={},--禁用物品
    autoLogin= WoWTools_DataMixin.Player.husandro,--启动,查询
    --isShowBackground=WoWTools_DataMixin.Player.husandro,--背景--旧数据
    --onlyMaxExpansion=true,--仅本版本物品
    borderAlpha= 0,
    bgAlpha=0,
    olnyUsaItem=true,
    numLine=12,
    autoWho=WoWTools_DataMixin.Player.husandro,
    class={
        [0]={
            [1]=true,--药水
            [2]=true,--药剂
            [3]=true,--合计
            [5]=true,--食物
            [7]=WoWTools_DataMixin.Is_Timerunning,
            [8]=WoWTools_DataMixin.Is_Timerunning,--其它
        },
        [15]={
            [4]=true,
        }
    },
    addItems={
        [113509]=true,--魔法汉堡
        [80610]=true,--魔法布丁
        [65499]=true,--魔法蛋糕
        [43523]=true,--魔法酪饼
        [43518]=true,--魔法馅饼
        [5512]=true,--治疗石
    },
    DisableClassID={
        [1]=true,
        [3]=true,
        [5]=true,
        [6]=true,
        [7]=true,
        [8]=true,
        [9]=true,
        [10]=true,
        [11]=true,
        [12]=true,
        [13]=true,
        [14]=true,
        [16]=true,
        [18]=true,
        [17]=true,
        [19]=true,
    },
    spells=ClassSpells,
}



local function Save()
    return WoWToolsSave['Tools_Foods']
end



local PaneIDs={
    [113509]=true,--魔法汉堡
    [80610]=true,--魔法布丁
    [65499]=true,--魔法蛋糕
    [43523]=true,--魔法酪饼
    [43518]=true,--魔法馅饼
    [5512]=true,--治疗石
}








function WoWTools_FoodMixin:Get_Item_Valid(itemID)

    if itemID
        and itemID~=self.Button.itemID
        and not Save().noUseItems[itemID]
        and not Save().addItems[itemID]
        and (Save().olnyUsaItem and C_Item.GetItemSpell(itemID) or not Save().olnyUsaItem)
    then
        local classID, subClassID, _, expacID = select(12, C_Item.GetItemInfo(itemID))
        if Save().class[classID]
            and Save().class[classID][subClassID]
            and (WoWTools_DataMixin.Is_Timerunning
                    or (Save().onlyMaxExpansion
                        and (PaneIDs[itemID] or WoWTools_DataMixin.ExpansionLevel==expacID)
                        or not Save().onlyMaxExpansion
                    )
                )
        then
            return classID, subClassID
        end
    end
end


















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")



panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Tools_Foods']= WoWToolsSave['Tools_Foods'] or P_Save

            Save().spells= Save().spells or ClassSpells

            local class= Save().spells[WoWTools_DataMixin.Player.Class]

            if not class then
                Save().spells[WoWTools_DataMixin.Player.Class]= {}
            else
                WoWTools_Mixin:Load({id=class.item, type='item'})
                WoWTools_Mixin:Load({id=class.alt, type='spell'})
                WoWTools_Mixin:Load({id=class.shift, type='spell'})
                WoWTools_Mixin:Load({id=class.ctrl, type='spell'})
            end

            WoWTools_FoodMixin.addName= '|A:Food:0:0|a'..(WoWTools_DataMixin.onlyChinese and '食物' or POWER_TYPE_FOOD)

            WoWTools_FoodMixin.Button= WoWTools_ToolsMixin:CreateButton({
                name='Food',
                tooltip=WoWTools_FoodMixin.addName,
                isMoveButton=true,
                option=function(category, layout, initializer)
                    WoWTools_PanelMixin:OnlyButton({
                        category=category,
                        layout=layout,
                        tooltip=WoWTools_FoodMixin.addName,
                        buttonText= WoWTools_DataMixin.onlyChinese and '还原位置' or RESET_POSITION,
                        SetValue= function()
                            Save().point=nil
                            if WoWTools_FoodMixin.Button and not WoWTools_FrameMixin:IsLocked(WoWTools_FoodMixin.Button) then
                                Save().point=nil
                                WoWTools_FoodMixin.Button:set_point()
                            end
                        end
                    }, initializer)
                end
            })

            if WoWTools_FoodMixin.Button then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')

                if Save().autoLogin or Save().autoWho  then
                    self:RegisterEvent('BAG_UPDATE_DELAYED')
                end
            end
            self:UnregisterEvent(event)
        end

    elseif event == 'PLAYER_ENTERING_WORLD' then
        WoWTools_FoodMixin:Set_AltSpell()
        WoWTools_FoodMixin:Init_Button()
        WoWTools_FoodMixin:Init_Check()
        self:UnregisterEvent(event)

    elseif event=='BAG_UPDATE_DELAYED' then
        WoWTools_FoodMixin:Check_Items()
        self:UnregisterEvent(event)
    end
end)