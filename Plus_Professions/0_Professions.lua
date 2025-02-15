local id, e = ...

WoWTools_ProfessionMixin={
Save={
    setButton=true,
    --disabledClassTrainer=true,--隐藏，全学，按钮
    --disabledEnchant=true,--禁用，自动放入，附魔纸
    --disabled--禁用，按钮
    ArcheologySound=true, --考古学
    --showFuocoButton=nil,--专业，界面上显示 烹饪用火按钮， 战斗不能隐藏
},
}


local function Save()
    return WoWTools_ProfessionMixin.Save
end

local UNLEARN_SKILL_CONFIRMATION= UNLEARN_SKILL_CONFIRMATION


local function Load_AddOn()
    if C_AddOns.IsAddOnLoaded("Blizzard_TrainerUI") then
        WoWTools_ProfessionMixin:Init_Blizzard_TrainerUI()--添一个,全学,专业, 按钮
    end
    if C_AddOns.IsAddOnLoaded("Blizzard_Professions") then
        WoWTools_ProfessionMixin:Init_ProfessionsFrame()--初始
    end
    if C_AddOns.IsAddOnLoaded("Blizzard_ArchaeologyUI") then
        WoWTools_ProfessionMixin:Init_Archaeology()--考古学
    end
    if C_AddOns.IsAddOnLoaded("Blizzard_ProfessionsBook") then
        WoWTools_ProfessionMixin:Init_ProfessionsBook()--专业书
    end

    --自动输入，忘却，文字，专业
    hooksecurefunc(StaticPopupDialogs["UNLEARN_SKILL"], "OnShow", function(self)
        if Save().wangquePrefessionText or IsPublicBuild() then
            self.editBox:SetText(UNLEARN_SKILL_CONFIRMATION);
        end
    end)
end














--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            if PlayerGetTimerunningSeasonID() then
                self:UnregisterAllEvents()
                return
            end

            WoWTools_ProfessionMixin.Save= WoWToolsSave['Plus_Professions'] or WoWTools_ProfessionMixin.Save
            WoWTools_ProfessionMixin.addName= '|A:Professions_Icon_FirstTimeCraft:0:0|a'..(e.onlyChinese and '专业' or PROFESSIONS_TRACKER_HEADER_PROFESSION)

            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_ProfessionMixin.addName,
                tooltip= WoWTools_ProfessionMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_Mixin.addName, WoWTools_ProfessionMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save().disabled then
                self:UnregisterEvent('ADDON_LOADED')
            else
                Load_AddOn()
            end

        elseif arg1== 'Blizzard_TrainerUI' then
            WoWTools_ProfessionMixin:Init_Blizzard_TrainerUI()--添一个,全学,专业, 按钮

        elseif arg1== 'Blizzard_Professions' then --10.1.5
            WoWTools_ProfessionMixin:Init_ProfessionsFrame()--初始

        elseif arg1=='Blizzard_ArchaeologyUI' then
            WoWTools_ProfessionMixin:Init_Archaeology()

        elseif arg1=='Blizzard_ProfessionsBook' then--专业书
            WoWTools_ProfessionMixin:Init_ProfessionsBook()
        end


    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Professions']= WoWTools_ProfessionMixin.Save
        end

    end
end)