local id, e = ...




--5512/治疗石 113509/魔法汉堡
local ClassSpells={--{item=5512, alt=nil, shift=nil, ctrl=nil}
    WARRIOR= {alt=nil, shift=6673, ctrl=nil},--zs 6673/战斗怒吼
    PALADIN= {alt=nil, shift=nil, ctrl=nil},--qs

    HUNTER= {alt=nil, shift=nil, ctrl=nil},--lr

    ROGUE= {alt=nil, shift=nil, ctrl=nil},--dz

    PRIEST= {shift=21562,},--ms 21562/真言术：韧

    DEATHKNIGHT= {alt=nil, shift=nil, ctrl=nil},--dk

    SHAMAN= {alt=nil, shift=nil, ctrl=nil},--sm

    MAGE= {item=113509, shift=1459, alt=190336},--fs 113509/魔法汉堡 190336/造餐术 190336/造餐术

    WARLOCK= {alt=29893, shift=698, ctrl=6201},--ss 29893/制造灵魂之井 6201/制造治疗石 698/召唤仪式

    MONK= {alt=nil, shift=nil, ctrl=nil},--ws

    DRUID= {alt=nil, shift=1126, ctrl=nil},--xd 1126/野性印记

    DEMONHUNTER= {alt=nil, shift=nil, ctrl=nil},--dh

    EVOKER= {alt=nil, shift=nil, ctrl=nil},--ev
}


WoWTools_FoodMixin={
Save={
    noUseItems={},--禁用物品
    --autoLogin= e.Player.husandro,--启动,查询
    isShowBackground=e.Player.husandro,
    onlyMaxExpansion=true,--仅本版本物品
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
addName= nil,
UseButton=nil
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
    do
        WoWTools_FoodMixin:Set_AltSpell()
    end
    WoWTools_FoodMixin:Init_Button()
    WoWTools_FoodMixin:Init_Check()
    if Save().autoLogin or Save().autoWho then
        WoWTools_FoodMixin:Check_Items()
    end
   
end










local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then

            WoWTools_FoodMixin.Save= WoWToolsSave['Tools_Foods'] or Save()

            Save().spells= Save().spells or ClassSpells
            Save().spells[e.Player.class]= Save().spells[e.Player.class] or {}--不要删除

            WoWTools_FoodMixin.addName= '|A:Food:0:0|a'..(e.onlyChinese and '食物' or POWER_TYPE_FOOD)

            UseButton= WoWTools_ToolsButtonMixin:CreateButton({
                name='Food',
                tooltip=WoWTools_FoodMixin.addName,
                isMoveButton=true,
                option=function(Category, layout, initializer)
                    e.AddPanel_Button({
                        category=Category,
                        layout=layout,
                        tooltip=WoWTools_FoodMixin.addName,
                        buttonText= e.onlyChinese and '还原位置' or RESET_POSITION,
                        SetValue= function()
                            Save().point=nil
                            if UseButton and not UnitAffectingCombat('player') then
                                Save().point=nil
                                UseButton:set_point()
                            end
                        end
                    }, initializer)
                end
            })

            if UseButton then
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