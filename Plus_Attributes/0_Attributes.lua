local id, e= ...

WoWTools_AttributesMixin={
Save={
    redColor= '|cffff0000',
    greenColor='|cff00ff00',
    font={r=0, g=0, b=0, a=1, x=1, y=-1},--阴影
    tab={
        ['STATUS']={bit=2},
        ['CRITCHANCE']= {r=0.99, g=0.35, b=0.31},
        ['HASTE']= {r=0, g=1, b=0.77},
        ['MASTERY']= {r=0.82, g=0.28, b=0.82},
        ['VERSATILITY']= {r=0, g=0.77, b=1},--双属性, damageAndDefense=true, onlyDefense=true,仅防卫
        ['LIFESTEAL']= {r=1, g=0.33, b=0.5},
        ['AVOIDANCE']= {r=0.90, g=0.80, b=0.60},--'闪避'

        ['ARMOR']={r=0.71, g=0.55, b=0.22, a=1},--护甲
        ["DODGE"]= {r=1, g=0.51, b=1},--躲闪
        ["PARRY"]= {r=0.59, g=0.85, b=1},
        ["BLOCK"]= {r=0.75, g=0.53, b=0.78},
        ["STAGGER"]= {r=0.38, g=1, b=0.62},

        ["SPEED"]= {r=1, g=0.82, b=0},--, current=true},--移动
    },
    --toLeft=true--数值,
    bar= true,--进度条
    barTexture2=true,--样式2
    barWidth= -60,--bar, 宽度
    barX=22,--bar,移位
    --barToLeft=e.Player.husandro,--bar,放左边
    scale= 1.1,--缩放
    vertical=3,--上下，间隔
    horizontal=9,--左右， 间隔
    setMaxMinValue= true,--增加,减少值
    bitPrecet=0,--百分比，位数
    onlyDPS=true,--四属性, 仅限DPS
    --useNumber= e.Player.husandro,--使用数字
    --notText=false,--禁用，数值
    textColor= {r=1,g=1,b=1,a=1},--数值，颜色
    bit=0,--数值，位数
    --disabledDragonridingSpeed=true,--禁用，驭空术UI，速度
    --disabledVehicleSpeed=true, --禁用，载具，速度

    hideInPetBattle=true,--宠物战斗中, 隐藏
    buttonAlpha=0.3,--专精，图标，透明度
    --hide=false,--显示，隐藏
    --gsubText
    --strlower
    --strupper
    showBG=e.Player.husandro,

}
}

-- STAT_CATEGORY_ATTRIBUTES--PaperDollFrame.lua

local function Save()
    return WoWTools_AttributesMixin.Save
end







--####
--初始
--####
local function Init()
    WoWTools_AttributesMixin:Init_Dragonriding_Speed()--驭空术UI，速度
    WoWTools_AttributesMixin:Init_Vehicle_Speed()--载具，移动，速度

    do
        WoWTools_AttributesMixin:Create_Button()
    end
    WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
end








local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            WoWTools_AttributesMixin.Save= WoWToolsSave['Plus_Attributes'] or WoWTools_AttributesMixin.Save

            WoWTools_AttributesMixin.addName= '|A:charactercreate-icon-customize-body-selected:0:0|a'..(e.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES)

            WoWTools_AttributesMixin.PanelFrame= CreateFrame('Frame')
            WoWTools_AttributesMixin.Category= e.AddPanel_Sub_Category({name=WoWTools_AttributesMixin.addName, frame=WoWTools_AttributesMixin.PanelFrame})--添加控制面板

            e.ReloadPanel({panel=WoWTools_AttributesMixin.PanelFrame, addName=WoWTools_AttributesMixin.addName, restTips=nil, checked=not Save().disabled, clearTips=nil, reload=false,--重新加载UI, 重置, 按钮
                disabledfunc=function()
                    Save().disabled = not Save().disabled and true or nil
                    if not Save().disabled and not WoWTools_AttributesMixin.Button then
                        do
                            Init()
                        end
                        WoWTools_AttributesMixin:Init_Options()
                    else
                        print(e.addName, WoWTools_AttributesMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
                    end
                end,
                clearfunc= function()
                    WoWTools_AttributesMixin.Save=nil
                    WoWTools_Mixin:Reload()
                end
            })

            if not Save().disabled then
                Init()
            end

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                WoWTools_AttributesMixin:Init_Options()
                self:UnregisterEvent('Blizzard_Settings')
            end

        elseif arg1=='Blizzard_Settings' then
            WoWTools_AttributesMixin:Init_Options()

        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Attributes']= WoWTools_AttributesMixin.Save
        end
    end
end)











