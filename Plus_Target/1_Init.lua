WoWTools_TargetMixin={}


local P_Save= {
    target= true,
    --targetTextureNewTab={},
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
    questShowInstance=WoWTools_DataMixin.Player.husandro,--在副本显示
}





local function OnRemoved()
    WoWTools_DataMixin:Hook(NamePlateBaseMixin, 'OnRemoved', function(plate)--移除所有
        if _G['WoWToolsTarget_IsMeFrame'] then
            _G['WoWToolsTarget_IsMeFrame']:hide_plate(plate)
        end
        if _G['WoWToolsTarget_QuestFrame'] then
           _G['WoWToolsTarget_QuestFrame']:hide_plate(plate)
        end
    end)

    OnRemoved=function()end
end




function WoWTools_TargetMixin:Set_All_Init()
    if WoWToolsSave['Plus_Target'].disabled then
        return
    end

    OnRemoved()

    WoWTools_TargetMixin:Init_targetFrame()
    WoWTools_TargetMixin:Init_numFrame()
    WoWTools_TargetMixin:Init_questFrame()
    WoWTools_TargetMixin:Init_isMeFrame()
end












local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)

    if arg1== 'WoWTools' then

        WoWToolsSave['Plus_Target']= WoWToolsSave['Plus_Target'] or P_Save
        P_Save= nil

        WoWToolsPlayerDate['TargetTexture']= WoWToolsPlayerDate['TargetTexture'] or {}

        WoWTools_TargetMixin.addName= '|A:common-icon-rotateright:0:0|a'..(WoWTools_DataMixin.onlyChinese and '目标' or TARGET)

        WoWTools_TargetMixin:Set_All_Init()

        if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
            WoWTools_TargetMixin:Blizzard_Settings()
            self:UnregisterEvent(event)
        end

    elseif arg1=='Blizzard_Settings' and WoWToolsSave then
        WoWTools_TargetMixin:Blizzard_Settings()
        self:UnregisterEvent(event)
    end
end)