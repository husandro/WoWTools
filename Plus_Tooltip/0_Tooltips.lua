
local id, e = ...
local addName= '|A:newplayertutorial-drag-cursor:0:0|aTooltips'
local Initializer, Layout= e.AddPanel_Sub_Category({name=addName})

WoWTools_TooltipMixin={
    Save={
        setDefaultAnchor=true,--指定点
        --AnchorPoint={},--指定点，位置
        --cursorRight=nil,--'ANCHOR_CURSOR_RIGHT',

        setCVar=e.Player.husandro,
        ShowOptionsCVarTips=e.Player.husandro,--显示选项中的CVar
        inCombatDefaultAnchor=true,
        ctrl= e.Player.husandro,--取得网页，数据链接

        --模型
        modelSize=100,--大小
        --modelLeft=true,--左边
        modelX= 0,
        modelY= -15,
        modelFacing= -0.3,--方向
        showModelFileID=e.Player.husandro,--显示，文件ID
        --WidgetSetID=848,--自定义，监视 WidgetSetID
        --disabledNPCcolor=true,--禁用NPC颜色
        --hideHealth=true,----生命条提示
    },
    addName=addName,
    Initializer=Initializer,
    Layout=Layout,
    WoWHead= 'https://www.wowhead.com/',
    AddOn={},
}









local function Save()
    return WoWTools_TooltipMixin.Save
end

local function Load_Addon(name, isLoaddedName)
    if isLoaddedName then
        if C_AddOns.IsAddOnLoaded(isLoaddedName) then
            name= isLoaddedName
        end
    end
    if name and WoWTools_TooltipMixin.AddOn[name] and not Save().disabled then
        WoWTools_TooltipMixin.AddOn[name]()
    end
end
















--设置，宽度
function WoWTools_TooltipMixin:Set_Width(tooltip)
    local w= tooltip:GetWidth()
    local w2= tooltip.textLeft:GetStringWidth()+ tooltip.text2Left:GetStringWidth()+ tooltip.textRight:GetStringWidth()
    if w<w2 then
        tooltip:SetMinimumWidth(w2)
    end
end


--设置单位
function WoWTools_TooltipMixin:Set_Unit(tooltip)--设置单位提示信息
    local name, unit, guid= TooltipUtil.GetDisplayedUnit(tooltip)
    if not name or not UnitExists(unit) or not guid then
        return
    end
    if UnitIsPlayer(unit) then
        WoWTools_TooltipMixin:Set_Unit_Player(tooltip, name, unit, guid)

    elseif (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then--宠物TargetFrame.lua
        WoWTools_TooltipMixin:Set_Pet(tooltip, UnitBattlePetSpeciesID(unit))

    else
        WoWTools_TooltipMixin:Set_Unit_NPC(tooltip, name, unit, guid)
    end
end












--初始
local function Init()
    for _, name in pairs(
        {
         'Blizzard_AchievementUI',
         'Blizzard_Collections',
         'Blizzard_ChallengesUI',
         'Blizzard_OrderHallUI',
         'Blizzard_FlightMap',
         'Blizzard_Professions',
         'Blizzard_ClassTalentUI',
         'Blizzard_PlayerChoice',
         'Blizzard_GenericTraitUI',
         'Blizzard_Settings',
        }
    )do
        Load_Addon(nil, name)
    end
    
    WoWTools_TooltipMixin:Init_StatusBar()--生命条提示
    WoWTools_TooltipMixin:Init_Hook()
    WoWTools_TooltipMixin:Init_BattlePet()
    WoWTools_TooltipMixin:Init_Settings()
    WoWTools_TooltipMixin:Init_SetPoint()
    WoWTools_TooltipMixin:Init_CVar()

    WoWTools_TooltipMixin:Set_Init_Item(GameTooltip)
    --WoWTools_TooltipMixin:Set_Init_Item(GlueTooltip)

    EventRegistry:RegisterFrameEventAndCallback("PLAYER_LEAVING_WORLD", function()
        if Save().setCVar then
            if not UnitAffectingCombat('player') then
                Save().graphicsViewDistance= C_CVar.GetCVar('graphicsViewDistance')
                SetCVar("graphicsViewDistance", 0)
            else
                Save().graphicsViewDistance=nil
            end
        end
    end)
    EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()--https://wago.io/ZtSxpza28
        if Save().setCVar and Save().graphicsViewDistance and not UnitAffectingCombat('player') then
            C_CVar.SetCVar('graphicsViewDistance', Save().graphicsViewDistance)
            Save().graphicsViewDistance=nil
        end
    end)

end








--Save().WidgetSetID = Save().WidgetSetID or 0
EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1==id then
        WoWTools_TooltipMixin.Save= WoWToolsSave['Plus_Tootips'] or WoWTools_TooltipMixin.Save
        WoWTools_TooltipMixin.addName= addName

        e.AddPanel_Check({
            name= e.onlyChinese and '启用' or ENABLE,
            tooltip= addName,
            GetValue= function() return not Save().disabled end,
            category= Initializer,
            func= function()
                Save().disabled= not Save().disabled and true or nil
                print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        })

        WoWTools_TooltipMixin:Init_WoWHeadText()

        if Save().disabled then
            Load_Addon= function()end
            EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
        end

        Init()--初始
    else
        Load_Addon(arg1)
    end
end)

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
    if not e.ClearAllSave then
        WoWToolsSave['Plus_Tootips']= WoWTools_TooltipMixin.Save
    end
end)