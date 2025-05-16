local P_Save={
    --clickToMove= WoWTools_DataMixin.Player.husandro,--禁用, 点击移动
    ClickMoveButton={
        --disabled= not WoWTools_DataMixin.Player.husandro,
        --Point,
        --Scale=1,
        --Strata='MEDIUM'
        PlayerFrame=true,
        lock_autoInteract=WoWTools_DataMixin.Player.husandro and '1' or nil,
        lock_cameraSmoothStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
        lock_cameraSmoothTrackingStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
    },
    TypeButton={
        --disabled=true,
        --point={},
        --hideFrame=true,
        --scale=1,
        --strata='MEDIUM',
        --allShow=WoWTools_DataMixin.Player.husandro,
        showBackground=true,
    },
    Plus={
        --disabled=true,
    },
    AbilityButton={
        --disabled=true,
        --point..name={},
        --[[scaleEnemy2=0.85,
        scaleEnemy3=0.85,
        scaleAlly2=0.85,
        scaleAlly3=0.85,]]
        --sacle..name=1
        --strata..name='MEDIUM'
        --hide..name=true
        --hideBackground..name=true,
    }
}






local function Blizzard_Collections()
    PetJournal:HookScript('OnShow', function()
        WoWTools_PetBattleMixin:TypeButton_SetShown()
    end)
    PetJournal:HookScript('OnHide', function()
        WoWTools_PetBattleMixin:TypeButton_SetShown()
    end)
    Blizzard_Collections=function()end
end



local function Init()
    WoWTools_PetBattleMixin:Set_TypeButton()--宠物，类型
    WoWTools_PetBattleMixin:Init_AbilityButton()--宠物对战，技能按钮
    WoWTools_PetBattleMixin:ClickToMove_Button()--点击移动，按钮
    Init=function()end
end














local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Plus_PetBattle2']= WoWToolsSave['Plus_PetBattle2'] or P_Save

            WoWTools_PetBattleMixin.addName= '|A:WildBattlePetCapturable:0:0|a'..(WoWTools_DataMixin.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)
            WoWTools_PetBattleMixin.addName3= '|A:transmog-nav-slot-feet:0:0|a'..(WoWTools_DataMixin.onlyChinese and '点击移动按钮'or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLICK_TO_MOVE, 'Button'))
            WoWTools_PetBattleMixin.addName4= '|A:WildBattlePetCapturable:0:0|a'..(WoWTools_DataMixin.onlyChinese and '宠物类型' or PET_FAMILIES)
            WoWTools_PetBattleMixin.addName6= '|A:plunderstorm-icon-offensive:0:0|a'..(WoWTools_DataMixin.onlyChinese and '技能按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PET_BATTLE_ABILITIES_LABEL, 'Button'))

            WoWTools_PetBattleMixin:Init_Options()

            if WoWToolsSave['Plus_PetBattle2'].disabled then
                WoWTools_PetBattleMixin:Set_Options()
                self:UnregisterAllEvents()

            else
                Init()
                
                if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                    WoWTools_PetBattleMixin:Set_Options()
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                    Blizzard_Collections()
                end
            end

        elseif arg1=='Blizzard_Collections' and WoWToolsSave then
            Blizzard_Collections()

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_Settings' and WoWToolsSave then
            WoWTools_PetBattleMixin:Set_Options()

            if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                self:UnregisterEvent(event)
            end
        end
    end
end)