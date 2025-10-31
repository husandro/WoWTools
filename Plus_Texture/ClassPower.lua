--[[
职业 1WARRIOR 2PALADIN 3HUNTER 4ROGUE 5PRIEST 6DEATHKNIGHT 7SHAMAN 8MAGE 9WARLOCK 10MONK 11DRUID 12DEMONHUNTER 13EVOKER
ClassResourceBarMixin:UpdateMaxPower()
]]
local function Save()
    return WoWToolsSave['Plus_Texture'] or {}
end

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







local function Init()
    if not Save().classPowerNum then
        return
    end

--2 PALADIN QS 骑士
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

    PaladinPowerBarFrame:HookScript('OnEnter', function(self)
        self.Background:SetShown(true)
        self.ActiveTexture:SetShown(true)
    end)
    PaladinPowerBarFrame:HookScript('OnLeave', function(self)
        self.Background:SetShown(false)
        self.ActiveTexture:SetShown(false)
    end)





--4 ROGUE 盗贼
    WoWTools_DataMixin:Hook(RogueComboPointBarFrame, 'UpdateMaxPower',function(self)
        C_Timer.After(0.5, function()
            for _, btn in pairs(self.classResourceButtonTable or {}) do
                WoWTools_TextureMixin:HideTexture(btn.BGActive)
                WoWTools_TextureMixin:HideTexture(btn.BGInactive)
                WoWTools_TextureMixin:SetAlphaColor(btn.BGShadow, nil, nil, 0.3)
                set_Num_Texture(btn)
            end
        end)
    end)
    if ClassNameplateBarRogueFrame and ClassNameplateBarRogueFrame.classResourceButtonTable then
        for _, btn in pairs(ClassNameplateBarRogueFrame.classResourceButtonTable) do
            WoWTools_TextureMixin:HideTexture(btn.BGActive)
            WoWTools_TextureMixin:HideTexture(btn.BGInactive)
            WoWTools_TextureMixin:SetAlphaColor(btn.BGShadow, nil, nil, 0.3)
            set_Num_Texture(btn)
        end
    end






--6 DEATHKNIGHT 死亡骑士
    for _, btn in pairs(RuneFrame.Runes or {}) do
        WoWTools_TextureMixin:HideTexture(btn.BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
    end

    for _, btn in pairs(DeathKnightResourceOverlayFrame.Runes or {}) do
        WoWTools_TextureMixin:HideTexture(btn.BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
    end







--7 SHAMAN 萨满
    for btn in TotemFrame.totemPool:EnumerateActive() do
        WoWTools_TextureMixin:SetAlphaColor(btn.Border, nil, nil, 0.3)
    end

    WoWTools_DataMixin:Hook(TotemButtonMixin, 'OnLoad', function(self)
        WoWTools_TextureMixin:SetAlphaColor(self.Border, nil, nil, 0.3)
    end)








--8 MAGE 法师
    WoWTools_DataMixin:Hook(MageArcaneChargesFrame, 'UpdateMaxPower', function(self)
        for btn in self.classResourceButtonPool:EnumerateActive() do
            if not btn.numTexture then
                set_Num_Texture(btn)
                WoWTools_TextureMixin:HideTexture(btn.ArcaneBG)
                WoWTools_TextureMixin:SetAlphaColor(btn.ArcaneBGShadow, true)
--背景
                btn.ArcaneBGShadow:SetSize(btn.ArcaneBGShadow:GetWidth()-6, btn.ArcaneBGShadow:GetHeight()-6)
                WoWTools_DataMixin:Hook(btn, 'SetActive', function(b)
                    b.ArcaneBGShadow:SetAlpha(b.isActive and 1 or 0)
                    b.numTexture:SetAlpha(b.isActive and 0 or 1)
                end)
            end
        end
    end)
    for _, btn in pairs(ClassNameplateBarMageFrame.classResourceButtonTable) do
        set_Num_Texture(btn)
        WoWTools_TextureMixin:HideTexture(btn.ArcaneBG)
        WoWTools_TextureMixin:SetAlphaColor(btn.ArcaneBGShadow, true)
        btn.ArcaneBGShadow:SetSize(btn.ArcaneBGShadow:GetWidth()-6, btn.ArcaneBGShadow:GetHeight()-6)
        WoWTools_DataMixin:Hook(btn, 'SetActive', function(b)
            b.ArcaneBGShadow:SetAlpha(b.isActive and 1 or 0)
            b.numTexture:SetAlpha(b.isActive and 0 or 1)
        end)
    end



--9 WARLOCK 术士 WoWTools_DataMixin:Hook(WarlockPowerFrame, 'UpdateMaxPower', function(self)
    for btn in WarlockPowerFrame.classResourceButtonPool:EnumerateActive() do
        set_Num_Texture(btn)
        WoWTools_TextureMixin:SetAlphaColor(btn.Background, true)
        WoWTools_DataMixin:Hook(btn, 'Update', function(b)
            local isShow= b.fillAmount>0
            b.Background:SetAlpha(isShow and 0 or 0.5)
            b.numTexture:SetAlpha(isShow and 0 or 1)
        end)
    end

    for _, btn in pairs(ClassNameplateBarWarlockFrame.classResourceButtonTable) do
        set_Num_Texture(btn)
        WoWTools_TextureMixin:SetAlphaColor(btn.Background, true)
        WoWTools_DataMixin:Hook(btn, 'Update', function(b)
            local isShow= b.fillAmount>0
            b.Background:SetAlpha(isShow and 0 or 0.5)
            b.numTexture:SetAlpha(isShow and 0 or 1)
        end)
    end


--10 MONK 武僧
    local function set_MonkHarmonyBarFrame(btn)
        if btn then
            WoWTools_TextureMixin:HideTexture(btn.Chi_BG_Active)
            WoWTools_TextureMixin:HideTexture(btn.BGInactive)
            WoWTools_TextureMixin:SetAlphaColor(btn.Chi_BG, nil, nil, 0.2)
            set_Num_Texture(btn, nil, false)
        end
    end

    WoWTools_DataMixin:Hook(MonkHarmonyBarFrame, 'UpdateMaxPower', function(self)
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
    WoWTools_DataMixin:Hook(MonkHarmonyBarFrame, 'UpdatePower', function(self)
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








--11 DRUID
    WoWTools_DataMixin:Hook(DruidComboPointBarFrame, 'UpdateMaxPower', function(frame)
        for btn in frame.classResourceButtonPool:EnumerateActive() do
            if not btn.numTexture then
                set_Num_Texture(btn)
                WoWTools_TextureMixin:HideTexture(btn.BG_Active)
                WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
            end
        end
    end)

    for _, btn in pairs(ClassNameplateBarFeralDruidFrame.classResourceButtonTable) do
        WoWTools_TextureMixin:HideTexture(btn.BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
        set_Num_Texture(btn)
    end









--13 EVOKER 龙人 唤魔者
    for _, btn in pairs(EssencePlayerFrame.classResourceButtonTable or {}) do
        WoWTools_TextureMixin:SetAlphaColor(btn.EssenceFillDone.CircBGActive, true)
        set_Num_Texture(btn, nil, false)
    end






    Init=function()end
end



function WoWTools_TextureMixin:Init_Class_Power()
    Init()
end