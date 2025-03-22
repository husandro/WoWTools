local id, e = ...




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


WoWTools_FoodMixin={
Save={
    noUseItems={},--禁用物品
    autoLogin= e.Player.husandro,--启动,查询
    isShowBackground=e.Player.husandro,--背景
    --onlyMaxExpansion=true,--仅本版本物品
    olnyUsaItem=true,
    numLine=12,
    autoWho=e.Player.husandro,
    class={
        [0]={
            [1]=true,--药水
            [2]=true,--药剂
            [3]=true,--合计
            [5]=true,--食物
            [7]=e.Is_Timerunning,
            [8]=e.Is_Timerunning,--其它
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
},
}


local function Save()
    return WoWTools_FoodMixin.Save
end


local UseButton
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
        and itemID~=UseButton.itemID
        and not self.Save.noUseItems[itemID]
        and not self.Save.addItems[itemID]
        and (self.Save.olnyUsaItem and C_Item.GetItemSpell(itemID) or not self.Save.olnyUsaItem)
    then
        local classID, subClassID, _, expacID = select(12, C_Item.GetItemInfo(itemID))
        if self.Save.class[classID]
            and self.Save.class[classID][subClassID]
            and (e.Is_Timerunning
                    or (self.Save.onlyMaxExpansion
                        and (PaneIDs[itemID] or e.ExpansionLevel==expacID)
                        or not self.Save.onlyMaxExpansion
                    )
                )
        then
            return classID, subClassID
        end
    end
end












local function Init()
    WoWTools_FoodMixin.UseButton= UseButton

    WoWTools_FoodMixin:Set_AltSpell()
    WoWTools_FoodMixin:Init_Button()
    WoWTools_FoodMixin:Init_Check()
    if Save().autoWho then
        WoWTools_FoodMixin:Check_Items()
    end

    if Save().autoLogin then
        C_Timer.After(2, function()
            WoWTools_FoodMixin:Check_Items()
        end)
    end
end










local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWTools_FoodMixin.Save= WoWToolsSave['Tools_Foods'] or Save()

            Save().spells= Save().spells or ClassSpells

            local class= Save().spells[e.Player.class]
            if not class then
                Save().spells[e.Player.class]= {}
            else
                WoWTools_Mixin:Load({id=class.item, type='item'})
                WoWTools_Mixin:Load({id=class.alt, type='spell'})
                WoWTools_Mixin:Load({id=class.shift, type='spell'})
                WoWTools_Mixin:Load({id=class.ctrl, type='spell'})
            end

            local addName= '|A:Food:0:0|a'..(WoWTools_Mixin.onlyChinese and '食物' or POWER_TYPE_FOOD)
            WoWTools_FoodMixin.addName= addName

            UseButton= WoWTools_ToolsMixin:CreateButton({
                name='Food',
                tooltip=addName,
                isMoveButton=true,
                option=function(category, layout, initializer)
                    e.AddPanel_Button({
                        category=category,
                        layout=layout,
                        tooltip=addName,
                        buttonText= WoWTools_Mixin.onlyChinese and '还原位置' or RESET_POSITION,
                        SetValue= function()
                            Save().point=nil
                            if UseButton and UseButton:CanChangeAttribute() then
                                Save().point=nil
                                UseButton:set_point()
                            end
                        end
                    }, initializer)
                end
            })

            if UseButton then
                WoWTools_FoodMixin.Button= UseButton
               Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_Foods']=Save()
        end
    end
end)