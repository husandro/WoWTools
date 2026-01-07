WoWTools_ProfessionMixin={}

local function Save()
    return WoWToolsSave['Plus_Professions']
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1== 'WoWTools' then

        WoWToolsSave['Plus_Professions']= WoWToolsSave['Plus_Professions'] or {
            setButton=true,
            ArcheologySound=true, --考古学
            showArcheologyBar=WoWTools_DataMixin.Player.husandro,
        }

        WoWTools_ProfessionMixin.addName= '|A:Professions_Icon_FirstTimeCraft:0:0|a'..(WoWTools_DataMixin.onlyChinese and '专业' or PROFESSIONS_TRACKER_HEADER_PROFESSION)

        --添加控制面板
        WoWTools_PanelMixin:OnlyCheck({
            name= WoWTools_ProfessionMixin.addName,
            tooltip= WoWTools_ProfessionMixin.addName,
            GetValue= function() return not Save().disabled end,
            SetValue= function()
                Save().disabled= not Save().disabled and true or nil
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_ProfessionMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        })

        if Save().disabled then
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        else
            WoWTools_ProfessionMixin:Init_Archaeology()--考古学

            if C_AddOns.IsAddOnLoaded("Blizzard_TrainerUI") then
                WoWTools_ProfessionMixin:Init_Blizzard_TrainerUI()--添一个,全学,专业, 按钮
            end
            if C_AddOns.IsAddOnLoaded("Blizzard_Professions") then
                WoWTools_ProfessionMixin:Init_ProfessionsFrame()--初始
            end
 
            --[[if C_AddOns.IsAddOnLoaded("Blizzard_ProfessionsBook") then
                WoWTools_ProfessionMixin:Init_ProfessionsBook()--专业书
            end]]
        end

    elseif arg1== 'Blizzard_TrainerUI' and WoWToolsSave then
        WoWTools_ProfessionMixin:Init_Blizzard_TrainerUI()--添一个,全学,专业, 按钮

    elseif arg1== 'Blizzard_Professions' and WoWToolsSave then --10.1.5
        WoWTools_ProfessionMixin:Init_ProfessionsFrame()--初始


    --[[elseif arg1=='Blizzard_ProfessionsBook' and WoWToolsSave then--专业书
        WoWTools_ProfessionMixin:Init_ProfessionsBook()]]
    end
end)