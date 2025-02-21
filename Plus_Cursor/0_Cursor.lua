local id, e= ...
WoWTools_CursorMixin={
Save={
    disabled= not e.Player.husandro,
    disabledGCD= not e.Player.husandro,
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
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura121]],

        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura73.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura94.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura103.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura142.tga]],
    },
    GCDTexture={
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura73.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura94.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura103.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura142.tga]],
    },
    gcdSize=15,
    gcdTextureIndex=1,
    gcdAlpha=1,
    gcdX=0,
    gcdY=0,
    --gcdDrawBling=false,
    --gcdReverse=false,
},
Color={r=e.Player.r, g=e.Player.g, b= e.Player.b, a=1},
addName=nil,
DefaultTexture= 'bonusobjectives-bar-starburst',
DefaultGCDTexture=[[Interface\Addons\WoWTools\Sesource\Mouse\Aura73.tga]],
CursorFrame=nil,
GCDFrame=nil,
}



local gcdFrame

local function Save()
    return WoWTools_CursorMixin.Save
end








--####
--颜色
--####
function WoWTools_CursorMixin:Set_Color()
    if Save().usrClassColor then
        WoWTools_CursorMixin.Color={r=e.Player.r, g=e.Player.g, b= e.Player.b, a=1}
    else
        WoWTools_CursorMixin.Color=Save().color
    end
end











EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1==id then
        WoWTools_CursorMixin.Save= WoWToolsSave['Plus_Cursor'] or WoWTools_CursorMixin.Save
        WoWTools_CursorMixin.addName= '|A:ClickCast-Icon-Mouse:0:0|a'..(e.onlyChinese and '鼠标' or MOUSE_LABEL)

        WoWTools_CursorMixin:Set_Color()

        local frame= CreateFrame('Frame')
        WoWTools_CursorMixin.OptionsFrame= frame
        e.AddPanel_Sub_Category({
            name= WoWTools_CursorMixin.addName,
            frame= frame,
            disabled= Save().disabled and  Save().disabledGCD,
        })

        e.ReloadPanel({panel=frame, addName=WoWTools_CursorMixin.addName, restTips=true, checked=nil, clearTips=nil, reload=false,--重新加载UI, 重置, 按钮
            disabledfunc=nil,
            clearfunc= function() WoWTools_CursorMixin.Save=nil WoWTools_Mixin:Reload() end}
        )

        --Cursor, 启用/禁用
        frame.cursorCheck=CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
        frame.cursorCheck:SetChecked(not Save().disabled)
        frame.cursorCheck:SetPoint("TOPLEFT", 0, -35)
        frame.cursorCheck.text:SetText('1)'..(e.onlyChinese and '启用' or ENABLE).. ' Cursor')
        frame.cursorCheck:SetScript('OnMouseDown', function()
            Save().disabled = not Save().disabled and true or nil
            if not Save().disabled and not WoWTools_CursorMixin.CursorFrame then
                WoWTools_CursorMixin:Init_Cursor()
            end
            if WoWTools_CursorMixin.CursorFrame then
                WoWTools_CursorMixin:Cursor_SetEvent()--随机, 图片，事件
                WoWTools_CursorMixin.CursorFrame:SetShown(not Save().disabled)
            end
            WoWTools_CursorMixin:Init_Options()
            WoWTools_CursorMixin:Init_Cursor_Options()
        end)

        --GCD, 启用/禁用
        frame.gcdCheck=CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
        frame.gcdCheck:SetChecked(not Save().disabledGCD)
        frame.gcdCheck:SetPoint("TOPLEFT", frame, 'TOP', 0, -35)
        frame.gcdCheck.text:SetText('2)'..(e.onlyChinese and '启用' or ENABLE).. ' GCD')
        frame.gcdCheck:SetScript('OnMouseDown', function()
            Save().disabledGCD = not Save().disabledGCD and true or nil
            if not Save().disabledGCD and not gcdFrame then
                WoWTools_CursorMixin:Init_GCD()
            end
            if not Save().disabledGCD then
                WoWTools_CursorMixin:ShowGCDTips()--显示GCD图片
            else
                WoWTools_CursorMixin:GCD_Settings()--设置 GCD
            end
            WoWTools_CursorMixin:Init_Options()
            WoWTools_CursorMixin:Init_GCD_Options()
        end)

        if not Save().disabled then
            C_Timer.After(2, function()
                WoWTools_CursorMixin:Init_Cursor()
            end)
        end
        if not Save().disabledGCD then
            C_Timer.After(2, function()
                WoWTools_CursorMixin:Init_GCD()
            end)
        end

    elseif arg1=='Blizzard_Settings' then
        WoWTools_CursorMixin:Init_Options()
        WoWTools_CursorMixin:Init_Cursor_Options()
        WoWTools_CursorMixin:Init_GCD_Options()
        if Save().addName then
            EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
        end
    end
end)

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
    if not e.ClearAllSave then
        WoWToolsSave['Plus_Cursor']=WoWTools_CursorMixin.Save
    end
end)




