

WoWTools_AttributesMixin={}

local P_Save={
    redColor= '|cffff4800',
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
    --barToLeft=WoWTools_DataMixin.Player.husandro,--bar,放左边
    scale= 1.1,--缩放
    vertical=3,--上下，间隔
    horizontal=9,--左右， 间隔
    setMaxMinValue= true,--增加,减少值
    bitPrecet=0,--百分比，位数
    onlyDPS=true,--四属性, 仅限DPS
    --useNumber= WoWTools_DataMixin.Player.husandro,--使用数字
    --notText=false,--禁用，数值
    textColor= {r=1,g=1,b=1,a=1},--数值，颜色
    bit=0,--数值，位数
    --disabledDragonridingSpeed=true,--禁用，驭空术UI，速度
    --disabledVehicleSpeed=true, --禁用，载具，速度

    --[[--目标，移动，速度
    showTargetSpeed
    targetMovePoint
    targetMoveTextToLeft
    strataTargetMove
    scaleTargetMove
    disableTargetName
    ]]

    hideInPetBattle=true,--宠物战斗中, 隐藏
    buttonAlpha=0.3,--专精，图标，透明度
    --hide=false,--显示，隐藏
    --gsubText
    --strlower
    --strupper
    showBG=WoWTools_DataMixin.Player.husandro,

}

-- STAT_CATEGORY_ATTRIBUTES--PaperDollFrame.lua

local function Save()
    return WoWToolsSave['Plus_Attributes'] or {}
end













local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Attributes']= WoWToolsSave['Plus_Attributes'] or P_Save
            P_Save=nil

            WoWTools_AttributesMixin.addName= '|A:charactercreate-icon-customize-body-selected:0:0|a'..(WoWTools_DataMixin.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES)

            WoWTools_AttributesMixin:Init_Options()

            if Save().disabled then
                self:SetScript('OnEvent', nil)
            else
                self:RegisterEvent("PLAYER_ENTERING_WORLD")
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        do
            WoWTools_AttributesMixin:Create_Button()
        end
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置

        WoWTools_AttributesMixin:Init_Dragonriding_Speed()--驭空术UI，速度
        WoWTools_AttributesMixin:Init_Vehicle_Speed()--载具，移动，速度
        WoWTools_AttributesMixin:Init_Target_Speed()--目标，移动，速度


        self:UnregisterEvent(event)
        self:SetScript('OnEvent', nil)
    end
end)