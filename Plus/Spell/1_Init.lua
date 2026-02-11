
local function Save()
    return WoWToolsSave['Plus_Spell']
end





local function Init()
    if not C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_PlayerSpells' then
                Init()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end


    WoWTools_SpellMixin:Init_TalentsFrame()
    WoWTools_SpellMixin:Init_SpellBookFrame()
    WoWTools_SpellMixin:Init_Spec_Button()


    Init=function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['Other_SpellFrame']=nil--旧数扰
            WoWToolsSave['Other_SpellFlyout']=nil

            WoWToolsSave['Plus_Spell'] = WoWToolsSave['Plus_Spell'] or {
                specButton={
                isUIParent=WoWTools_DataMixin.Player.husandro,
                scale= WoWTools_DataMixin.Player.husandro and 0.6 or 1,
                --isToTOP=true
                --point={}
                --strata='MEDIUM'
                --hideInCombat=true
                enabled=true,
                },

                bg={
                    texture={},
                    show=true,
                    --icon='',
                },
                setUITexture=true,

                flyoutText=true,--法术弹出框
                actionButtonRangeColor=true,

                spellBookPlus=true,
                talentsFramePlus=true,
            }


            if not Save().bg then
                Save().bg={texture={},show=true}
            end

            WoWTools_SpellMixin.addName= '|A:UI-HUD-MicroMenu-SpellbookAbilities-Mouseover:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)

            if Save().disabled then
                self:SetScript('OnEvent', nil)
            else
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                Init()
            end
            self:UnregisterEvent(event)

        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_SpellMixin:Init_Options()
        WoWTools_SpellMixin:Init_Spec_Button()
        WoWTools_SpellMixin:Init_Spell_Flyout()
        WoWTools_SpellMixin:Init_ActionButton_UpdateRange()--法术按键, 颜色
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)