
WoWTools_CursorMixin={
    Color={r=WoWTools_DataMixin.Player.r, g=WoWTools_DataMixin.Player.g, b= WoWTools_DataMixin.Player.b, a=1},
    DefaultTexture= 'bonusobjectives-bar-starburst',
    DefaultGCDTexture= 'Interface\\Addons\\WoWTools\\Source\\Mouse\\Aura73',
}

local P_Save={
    disabled= not WoWTools_DataMixin.Player.husandro,
    disabledGCD= not WoWTools_DataMixin.Player.husandro,
    color={r=0, g=1, b= 0, a=1},
    usrClassColor=true,
    size=32,--8 64
    gravity=512, -- -512 512
    duration=0.3,--0.1 4
    rotate=32,-- 0 32
    atlasIndex=1,
    rate=0.03,--刷新
    X=40,--移位
    Y=-30,
    alpha=1,--透明
    maxParticles= 50,--数量
    minDistance=3,--距离
    randomTexture=true,--随机, 图片
    --randomTextureInCombat=true,--战斗中，也随机，图片
    Atlas={
        'bonusobjectives-bar-starburst',--星星
        'Adventures-Buff-Heal-Burst',--雪
        'OBJFX_StarBurst',--太阳
        'worldquest-questmarker-glow',--空心圆
        'Relic-Frost-TraitGlow',
        'Relic-Holy-TraitGlow',
        'Relic-Life-TraitGlow',
        'Relic-Iron-TraitGlow',
        'Relic-Wind-TraitGlow',
        'Relic-Water-TraitGlow',
        'Azerite-Trait-RingGlow',
        'AzeriteFX-Whirls',
        'ArtifactsFX-Whirls',
        'ArtifactsFX-SpinningGlowys',
        'Azerite-TitanBG-Glow-Rank2',
        '!ItemUpgrade_FX_FrameDecor_IdleGlow',
        'Artifacts-Anim-Sparks',
        'AftLevelup-SoftCloud',
        'BossBanner-RedLightning',
        'Cast_Channel_Sparkles_01',
        'ChallengeMode-Runes-GlowLarge',
        'ChallengeMode-Runes-Shockwave',
        'CovenantSanctum-Reservoir-Idle-Kyrian-Speck',
        'CovenantSanctum-Reservoir-Idle-Kyrian-Glass',
        [[Interface\Addons\WoWTools\Source\Mouse\Aura121]],

        [[Interface\Addons\WoWTools\Source\Mouse\Aura73.tga]],
        [[Interface\Addons\WoWTools\Source\Mouse\Aura94.tga]],
        [[Interface\Addons\WoWTools\Source\Mouse\Aura103.tga]],
        [[Interface\Addons\WoWTools\Source\Mouse\Aura142.tga]],
    },
    GCDTexture={
        [[Interface\Addons\WoWTools\Source\Mouse\Aura73.tga]],
        [[Interface\Addons\WoWTools\Source\Mouse\Aura94.tga]],
        [[Interface\Addons\WoWTools\Source\Mouse\Aura103.tga]],
        [[Interface\Addons\WoWTools\Source\Mouse\Aura142.tga]],
    },
    gcdSize=15,
    gcdTextureIndex=1,
    gcdAlpha=1,
    gcdX=0,
    gcdY=0,
    --gcdDrawBling=false,
    --gcdReverse=false,
}



local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Cursor']= WoWToolsSave['Plus_Cursor'] or P_Save
            P_Save=nil

            WoWTools_CursorMixin.addName= '|A:newplayertutorial-icon-mouse-turn:0:0|a'..(WoWTools_DataMixin.onlyChinese and '鼠标' or MOUSE_LABEL)

            self:RegisterEvent('PLAYER_ENTERING_WORLD')

            WoWTools_CursorMixin:Set_Options(self)

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_Settings' and WoWToolsSave then
            WoWTools_CursorMixin:Set_Options(self)
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_CursorMixin:Cursor_Settings()
        WoWTools_CursorMixin:GCD_Settings()
        self:UnregisterEvent(event)
    end
end)