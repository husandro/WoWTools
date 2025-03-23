
local addName= '|A:newplayertutorial-drag-cursor:0:0|aTooltips'

WoWTools_TooltipMixin={
    Save={
        setDefaultAnchor=true,--指定点
        --AnchorPoint={},--指定点，位置
        --cursorRight=nil,--'ANCHOR_CURSOR_RIGHT',

        setCVar=WoWTools_DataMixin.Player.husandro,
        ShowOptionsCVarTips=WoWTools_DataMixin.Player.husandro,--显示选项中的CVar
        inCombatDefaultAnchor=true,
        ctrl= WoWTools_DataMixin.Player.husandro,--取得网页，数据链接

        --模型
        modelSize=100,--大小
        --modelLeft=true,--左边
        modelX= 0,
        modelY= -15,
        modelFacing= -0.3,--方向
        showModelFileID=WoWTools_DataMixin.Player.husandro,--显示，文件ID
        --WidgetSetID=848,--自定义，监视 WidgetSetID
        --disabledNPCcolor=true,--禁用NPC颜色
        --hideHealth=true,----生命条提示
        --UNIT_POPUP_RIGHT_CLICK= true,--<右键点击设置框体>
    },
    addName=addName,
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

    --[[hooksecurefunc("UnitFrame_UpdateTooltip", function(self)
        for i = GameTooltip:NumLines(), 3, -1 do
            local line = _G["GameTooltipTextLeft"..i]
            local text = line and line:GetText()
            if text == UNIT_POPUP_RIGHT_CLICK then
                GameTooltip:SetUnit(self.unit, self.hideStatusOnTooltip)
                line= _G["GameTooltipTextLeft"..(i-1)]
                print(line:GetText()==' ')
                break
            end
        end
    end)]]

--移除，<右键点击设置框体> 替换原生
    if not Save().UNIT_POPUP_RIGHT_CLICK then
        function UnitFrame_UpdateTooltip (self)
            GameTooltip_SetDefaultAnchor(GameTooltip, self);
            if ( GameTooltip:SetUnit(self.unit, self.hideStatusOnTooltip) ) then    
                self.UpdateTooltip = UnitFrame_UpdateTooltip;
            else
                self.UpdateTooltip = nil;
            end
        end
    end

end








--Save().WidgetSetID = Save().WidgetSetID or 0
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')
panel:RegisterEvent('PLAYER_LEAVING_WORLD')



panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWTools_TooltipMixin.Save= WoWToolsSave['Plus_Tootips'] or WoWTools_TooltipMixin.Save
            WoWTools_TooltipMixin.addName= addName


            WoWTools_TooltipMixin:Init_Category()
            WoWTools_TooltipMixin:Init_WoWHeadText()

            if Save().disabled then
                Load_Addon= function()end
                self:UnregisterEvent('PLAYER_ENTERING_WORLD')
                self:UnregisterEvent('PLAYER_LEAVING_WORLD')
                self:UnregisterEvent(event)
                return
            end

            Init()--初始
            
        else
            Load_Addon(arg1)

            --[[if arg1=='Blizzard_Settings' then
                WoWTools_TooltipMixin:Init_CVar_Value() --显示选项中的CVar
            end]]
        end


    elseif event=='PLAYER_ENTERING_WORLD' then
        if Save().setCVar and Save().graphicsViewDistance and not InCombatLockdown() then
            C_CVar.SetCVar('graphicsViewDistance', Save().graphicsViewDistance)--https://wago.io/ZtSxpza28
            Save().graphicsViewDistance=nil
        end

    elseif event=='PLAYER_LEAVING_WORLD' then
        if Save().setCVar then
            if not InCombatLockdown() then
                Save().graphicsViewDistance= C_CVar.GetCVar('graphicsViewDistance')
                SetCVar("graphicsViewDistance", 0)
            else
                Save().graphicsViewDistance=nil
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            WoWToolsSave['Plus_Tootips']=Save()
        end
    end
end)
