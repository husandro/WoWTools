local P_Save={
    specButton={
    --isUIParent=true
    --scale=1
    --isToTOP=true
    --point={}
    --strata='MEDIUM'
    --hideInCombat=true
    enabled=true,
    },
    flyoutText=true,--法术弹出框
    actionButtonRangeColor=true,

    spellBookPlus=true,
    talentsFramePlus=true,
}








local function  Blizzard_PlayerSpells()
    WoWTools_SpellMixin:Init_TalentsFrame()
    WoWTools_SpellMixin:Init_SpellBookFrame()
    WoWTools_SpellMixin:Init_Spec_Button()

    Blizzard_PlayerSpells=function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('LOADING_SCREEN_DISABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['Other_SpellFrame']=nil--旧数扰
            WoWToolsSave['Other_SpellFlyout']=nil

            WoWToolsSave['Plus_Spell'] = WoWToolsSave['Plus_Spell'] or P_Save

            WoWTools_SpellMixin.addName= '|A:UI-HUD-MicroMenu-SpellbookAbilities-Mouseover:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)

            WoWTools_SpellMixin:Init_Options()


            if WoWToolsSave['Plus_Spell'].disabled then
                self:UnregisterAllEvents()

            elseif C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
                Blizzard_PlayerSpells()
            end

        elseif arg1=='Blizzard_Settings' and WoWToolsSave then
            WoWTools_SpellMixin:Init_Options()

            if C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_PlayerSpells' and WoWToolsSave then--天赋
            Blizzard_PlayerSpells()

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                self:UnregisterEvent(event)
            end
        end

    elseif event=='LOADING_SCREEN_DISABLED' then
        WoWTools_SpellMixin:Init_Spec_Button()
        WoWTools_SpellMixin:Init_Spell_Flyout()
        WoWTools_SpellMixin:Init_ActionButton_UpdateRange()--法术按键, 颜色
        self:UnregisterEvent(event)
    end
end)