--职业
local function Save()
    return WoWTools_TextureMixin.Save
end

local IsHook










local function set_Num_Texture(self, num, color, parent)
    if self and not self.numTexture and (self.layoutIndex or num) then
        self.numTexture= (parent or self):CreateTexture(nil, 'OVERLAY', nil, 7)
        local size= Save().classPowerNumSize or 12
        self.numTexture:SetSize(size, size)
        self.numTexture:SetPoint('CENTER', self, 'CENTER')
        self.numTexture:SetAtlas('services-number-'..(num or self.layoutIndex))
        if color~=false then
            if not color then
                WoWTools_TextureMixin:SetAlphaColor(self.numTexture, true)
            else
                self.numTexture:SetVertexColor(color.r, color.g, color.b)
            end
        end
    end
end

local function set_MonkHarmonyBarFrame(btn)
    if btn then
        WoWTools_TextureMixin:HideTexture(btn.Chi_BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BGInactive)
        WoWTools_TextureMixin:SetAlphaColor(btn.Chi_BG, nil, nil, 0.2)
        set_Num_Texture(btn, nil, false)
    end
end


local function set_DruidComboPointBarFrame(frame)
    for btn, _ in pairs(frame or {}) do
        WoWTools_TextureMixin:HideTexture(btn.BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
        set_Num_Texture(btn)
    end
end












--PALADIN QS
local function QS()
    if not PaladinPowerBarFrame then
        return
    end

    WoWTools_TextureMixin:SetAlphaColor(PaladinPowerBarFrame.Background, nil, nil,0.3)
    WoWTools_TextureMixin:SetAlphaColor(PaladinPowerBarFrame.ActiveTexture, nil, nil, 0.3)
    PaladinPowerBarFrame.Background:SetShown(false)
    PaladinPowerBarFrame.ActiveTexture:SetShown(false)

    WoWTools_TextureMixin:HideTexture(PaladinPowerBarFrame.ActiveTexture, true)
    if ClassNameplateBarPaladinFrame then
        WoWTools_TextureMixin:HideTexture(ClassNameplateBarPaladinFrame.Background)
        WoWTools_TextureMixin:HideTexture(ClassNameplateBarPaladinFrame.ActiveTexture)
    end
    local maxHolyPower = UnitPowerMax('player', Enum.PowerType.HolyPower)--UpdatePower
    for i=1,maxHolyPower do
        local holyRune = PaladinPowerBarFrame["rune"..i]
        set_Num_Texture(holyRune, i, false)
    end

    if IsHook then
        return
    end


    PaladinPowerBarFrame:HookScript('OnEnter', function(self)
        self.Background:SetShown(true)
        self.ActiveTexture:SetShown(true)
    end)
    PaladinPowerBarFrame:HookScript('OnLeave', function(self)
        self.Background:SetShown(false)
        self.ActiveTexture:SetShown(false)
    end)
end




--MAGE 法师
local function FS()
    if not MageArcaneChargesFrame then
        return
    end

    for _, mage in pairs(MageArcaneChargesFrame.classResourceButtonTable) do
        WoWTools_TextureMixin:HideTexture(mage.ArcaneBG)
    end

    if ClassNameplateBarMageFrame and ClassNameplateBarMageFrame.classResourceButtonTable then
        for _, mage in pairs(ClassNameplateBarMageFrame.classResourceButtonTable) do
            WoWTools_TextureMixin:HideTexture(mage.ArcaneBG)
        end
    end
end




---DRUID
local function XD()
    if not DruidComboPointBarFrame then
        return
    end

    set_DruidComboPointBarFrame(DruidComboPointBarFrame.classResourceButtonPool.activeObjects)

    for _, btn in pairs(ClassNameplateBarFeralDruidFrame.classResourceButtonTable) do
        WoWTools_TextureMixin:HideTexture(btn.BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
        set_Num_Texture(btn)
    end

    if IsHook then
        return
    end

    DruidComboPointBarFrame:HookScript('OnEvent', function(self)
        set_DruidComboPointBarFrame(self.classResourceButtonPool.activeObjects)
    end)
end








--ROGUE
local function DZ()
    if not RogueComboPointBarFrame or IsHook then
        return
    end

    hooksecurefunc(RogueComboPointBarFrame, 'UpdateMaxPower',function(self)
        C_Timer.After(0.5, function()
            for _, btn in pairs(self.classResourceButtonTable or {}) do
                WoWTools_TextureMixin:HideTexture(btn.BGActive)
                WoWTools_TextureMixin:HideTexture(btn.BGInactive)
                WoWTools_TextureMixin:SetAlphaColor(btn.BGShadow, nil, nil, 0.3)
                set_Num_Texture(btn)
            end
            if ClassNameplateBarRogueFrame and ClassNameplateBarRogueFrame.classResourceButtonTable then
                for _, btn in pairs(ClassNameplateBarRogueFrame.classResourceButtonTable) do
                    WoWTools_TextureMixin:HideTexture(btn.BGActive)
                    WoWTools_TextureMixin:HideTexture(btn.BGInactive)
                    WoWTools_TextureMixin:SetAlphaColor(btn.BGShadow, nil, nil, 0.3)
                    set_Num_Texture(btn)
                end
            end
        end)
    end)
end










--MONK
local function WS()
    if not MonkHarmonyBarFrame or IsHook then
        return
    end

    hooksecurefunc(MonkHarmonyBarFrame, 'UpdateMaxPower', function(self)
        C_Timer.After(0.5, function()
            for i = 1, #self.classResourceButtonTable do
                set_MonkHarmonyBarFrame(self.classResourceButtonTable[i])
            end
            local tab= ClassNameplateBarWindwalkerMonkFrame and ClassNameplateBarWindwalkerMonkFrame.classResourceButtonTable or {}
            for i = 1, #tab do
                set_MonkHarmonyBarFrame(tab[i])
            end
        end)
    end)
    hooksecurefunc(MonkHarmonyBarFrame, 'UpdatePower', function(self)
        for _, btn in pairs(self.classResourceButtonTable or {}) do
            if btn.Chi_BG then
                btn.Chi_BG:SetAlpha(0.2)
            end
        end
        if ClassNameplateBarWindwalkerMonkFrame then
            for _, btn in pairs(ClassNameplateBarWindwalkerMonkFrame.classResourceButtonTable or {}) do
                if btn.Chi_BG then
                    btn.Chi_BG:SetAlpha(0.2)
                end
            end
        end
    end)
end











--DEATHKNIGHT
local function DK()
    if not RuneFrame then
        return
    end

    for _, btn in pairs(RuneFrame.Runes or {}) do
        WoWTools_TextureMixin:HideTexture(btn.BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
    end

    for _, btn in pairs(DeathKnightResourceOverlayFrame.Runes or {}) do
        WoWTools_TextureMixin:HideTexture(btn.BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
    end
end






--SHAMAN
local function SM()
    if not TotemButtonMixin then
        return
    end

    for btn in TotemFrame.totemPool:EnumerateActive() do
        WoWTools_TextureMixin:SetAlphaColor(btn.Border, nil, nil, 0.3)
    end

    if IsHook then
        return
    end

    hooksecurefunc(TotemButtonMixin, 'OnLoad', function(self)
        WoWTools_TextureMixin:SetAlphaColor(self.Border, nil, nil, 0.3)
    end)
end








--EVOKER EssenceFramePlayer.lua
local function EV()
    if not EssencePlayerFrame then
        return
    end

    for _, btn in pairs(EssencePlayerFrame.classResourceButtonTable or {}) do
        WoWTools_TextureMixin:SetAlphaColor(btn.EssenceFillDone.CircBGActive, true)
        set_Num_Texture(btn, nil, false)
    end
end












local function Init()
    if not Save().classPowerNum then
        return
    end

    do
        QS()
        FS()
        XD()
        DZ()
        WS()
        DK()
        SM()
        C_Timer.After(2, EV)
    end

    IsHook=true
end



function WoWTools_TextureMixin:Init_Class_Power()
    Init()
end