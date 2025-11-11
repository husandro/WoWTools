local P_Save={
    --notRaidFrame= not WoWTools_DataMixin.Player.husandro,
    raidFrameScale= WoWTools_DataMixin.Player.husandro and 0.8 or 1,
    --raidFrameAlpha=1,
    --healthbar='UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status'

    --hideBossFrame=true
    --hideCastingFrame
    --hideClassColor
}

local function Save()
    return WoWToolsSave['Plus_UnitFrame'] or {}
end



local function Init()
    WoWTools_UnitMixin:Init_PlayerFrame()--玩家
    WoWTools_UnitMixin:Init_TargetFrame()--目标

    WoWTools_UnitMixin:Init_PartyFrame()--小队
    WoWTools_UnitMixin:Init_PartyFrame_Compact()--小队, 使用团框架

    WoWTools_UnitMixin:Init_BossFrame()--BOSS
    WoWTools_UnitMixin:Init_RaidFrame()--团队
    WoWTools_UnitMixin:Init_CastingBar()--施法条

    WoWTools_UnitMixin:Init_ClassTexture()--职业, 图标， 颜色


    Init=function()end
end



local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_UnitFrame']= WoWToolsSave['Plus_UnitFrame'] or P_Save
            P_Save= nil

            WoWTools_UnitMixin.addName= '|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged:0:0|a'..(WoWTools_DataMixin.onlyChinese and '单位框体' or UNITFRAME_LABEL)

            WoWTools_UnitMixin:Init_Options()

            if Save().disabled then
                self:SetScript('OnEvent', nil)
                self:UnregisterAllEvents()
            else

                Init()

                if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                    self:SetScript('OnEvent', nil)
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_Settings' then
            WoWTools_UnitMixin:Init_Options()
            self:UnregisterEvent(event)
        end
    end
end)