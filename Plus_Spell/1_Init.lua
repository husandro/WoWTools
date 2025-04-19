local P_Save={
    specButton={
    --isUIParent=true
    --scale=1
    --isToTOP=true
    --point={}
    --strata='MEDIUM'
    --hideInCombat=true
    }
}

local function Save()
    return WoWToolsSave['Plus_Spell']
end




local function  Init()
    WoWTools_SpellMixin:Init_TalentsFrame()

    WoWTools_SpellMixin:Init_Spec_Button()

    hooksecurefunc(SpellBookItemMixin, 'UpdateVisuals', function(frame)
        frame.Button.ActionBarHighlight:SetVertexColor(0,1,0)
        if (frame.spellBookItemInfo.itemType == Enum.SpellBookItemType.Flyout) then
            frame.Button.Arrow:SetVertexColor(1,0,1)
            frame.Button.Border:SetVertexColor(1,0,1)
        else
            frame.Button.Arrow:SetVertexColor(1,1,1)
            frame.Button.Border:SetVertexColor(1,1,1)
        end
    end)

    

    Blizzard_PlayerSpells=function()end

    Init=function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('LOADING_SCREEN_DISABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            if WoWToolsSave['Other_SpellFrame'] then--旧数扰
                WoWToolsSave['Plus_Spell']= WoWToolsSave['Other_SpellFrame']
                Save().specButton= Save().specButton or {}
                WoWToolsSave['Other_SpellFrame']= nil
            else
                WoWToolsSave['Plus_Spell'] = WoWToolsSave['Plus_Spell'] or P_Save
            end

            WoWTools_SpellMixin.addName= '|A:UI-HUD-MicroMenu-SpellbookAbilities-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)

            WoWTools_SpellMixin:Init_Options()


            if Save().disabled then
                self:UnregisterAllEvents()

            elseif C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
                Init()
            end

        elseif arg1=='Blizzard_Settings' and WoWToolsSave then
            WoWTools_SpellMixin:Init_Options()

            if C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_PlayerSpells' and WoWToolsSave then--天赋
            Init()

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                self:UnregisterEvent(event)
            end
        end

    elseif event=='LOADING_SCREEN_DISABLED' then
        WoWTools_SpellMixin:Init_Spec_Button()
        WoWTools_SpellMixin:Init_ActionButton_UpdateRange()--法术按键, 颜色
        self:UnregisterEvent(event)
    end
end)