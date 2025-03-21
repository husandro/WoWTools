local id, e= ...

WoWTools_TargetMixin={
    Save= {
        target= true,
        targetTextureNewTab={},
        targetTextureName='common-icon-rotateright',

        targetColor= {r=1,g=1,b=1,a=1},--颜色
        targetInCombat=true,--战斗中，提示
        targetInCombatColor={r=1, g=0, b=0, a=1},--战斗中，颜色
        w=40,
        h=20,
        x=0,
        y=0,
        scale=1.5,
        elapsed=0.5,
        TargetFramePoint='LEFT',--'TOP', 'HEALTHBAR','LEFT'
        --top=true,--位于，目标血条，上方

        creature= true,--怪物数量
        creatureFontSize=10,
        --creatureNotParentTarget=true,--自定义位置
        --creatureUIParent=true,--放在UIPrent
        --creaturePoint={},--位置

        unitIsMe=true,--提示， 目标是你
        unitIsMeTextrue= 'auctionhouse-icon-favorite',
        unitIsMeSize=12,
        unitIsMePoint='TOPLEFT',
        unitIsMeParent='healthBar',--name
        unitIsMeX=0,
        unitIsMeY=-2,
        unitIsMeColor={r=1,g=1,b=1,a=1},

        quest= true,
        --questShowAllFaction=nil,--显示， 所有玩家派系
        questShowPlayerClass=true,--显示，玩家职业
        questShowInstance=e.Player.husandro,--在副本显示
    }
}










local isHooked
function WoWTools_TargetMixin:Set_All_Init()
    if not isHooked then
        hooksecurefunc(NamePlateBaseMixin, 'OnRemoved', function(plate)--移除所有
            if WoWTools_TargetMixin.isMeFrame then
                WoWTools_TargetMixin.isMeFrame:hide_plate(plate)
            end
            if WoWTools_TargetMixin.questFrame then
                WoWTools_TargetMixin.questFrame:hide_plate(plate)
            end
        end)
        isHooked=true
    end

    WoWTools_TargetMixin:Init_targetFrame()
    WoWTools_TargetMixin:Init_numFrame()
    WoWTools_TargetMixin:Init_questFrame()
    WoWTools_TargetMixin:Init_isMeFrame()
end












local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            WoWTools_TargetMixin.Save= WoWToolsSave['Plus_Target'] or WoWTools_TargetMixin.Save

            local addName= '|A:common-icon-rotateright:0:0|a'..(e.onlyChinese and '目标' or TARGET)
            WoWTools_TargetMixin.addName= addName

            WoWTools_TargetMixin:Init_Options()

            if not WoWTools_TargetMixin.Save.disabled then
                WoWTools_TargetMixin:Set_All_Init()
            end

        elseif arg1=='Blizzard_Settings' then
            WoWTools_TargetMixin:Blizzard_Settings()

            if WoWTools_TargetMixin.addName then
                self:UnregisterEvent(event)
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Target']= WoWTools_TargetMixin.Save
        end
    end
end)