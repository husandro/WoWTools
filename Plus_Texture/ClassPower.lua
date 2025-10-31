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
        local size= Save().classPowerNumSize or 23
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
    for i=1, 5 do--UnitPowerMax('player', Enum.PowerType.HolyPower)
        local btn= PaladinPowerBarFrame["rune"..i]
        if btn then
            set_Num_Texture(btn, i, false)
            WoWTools_DataMixin:Hook(btn, 'SetVisualState', function(b)
                b.numTexture:SetShown(b.visualState==PaladinPowerBar.VisualState.Inactive)
            end)
        end
        btn= ClassNameplateBarPaladinFrame["rune"..i]
        if btn then
            set_Num_Texture(btn, i, false)
            WoWTools_DataMixin:Hook(btn, 'SetVisualState', function(b)
                b.numTexture:SetShown(b.visualState==PaladinPowerBar.VisualState.Inactive)
            end)
        end
    end
--背景
    WoWTools_TextureMixin:SetAlphaColor(PaladinPowerBarFrame.Background, nil, nil, 0.3)
    WoWTools_TextureMixin:SetAlphaColor(PaladinPowerBarFrame.ActiveTexture, nil, nil, 0.3)
    PaladinPowerBarFrame.Background:Hide()
    PaladinPowerBarFrame.ActiveTexture:Hide()
    PaladinPowerBarFrame:HookScript('OnEnter', function(self)
        self.Background:Show()
        self.ActiveTexture:Show()
    end)
    PaladinPowerBarFrame:HookScript('OnLeave', function(self)
        self.Background:Hide()
        self.ActiveTexture:Hide()
    end)
    WoWTools_TextureMixin:HideTexture(ClassNameplateBarPaladinFrame.Background)
    WoWTools_TextureMixin:HideTexture(ClassNameplateBarPaladinFrame.ActiveTexture)





--4 ROGUE 盗贼
    WoWTools_DataMixin:Hook(RogueComboPointBarFrame, 'UpdateMaxPower',function(self)
        for btn in self.classResourceButtonPool:EnumerateActive() do
            if not btn.numTexture then
                set_Num_Texture(btn)
                WoWTools_TextureMixin:HideTexture(btn.BGActive)
                WoWTools_TextureMixin:HideTexture(btn.BGInactive)
                WoWTools_TextureMixin:SetAlphaColor(btn.BGShadow, nil, nil, 0.3)
                btn.SlashFBUncharged:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
                btn.SlashFBCharged:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
                WoWTools_DataMixin:Hook(btn, 'Update', function(b)
                    b.numTexture:SetShown(not b.isFull)
                end)
            end
        end
    end)
    for _, btn in pairs(ClassNameplateBarRogueFrame.classResourceButtonTable) do
        set_Num_Texture(btn)
        WoWTools_TextureMixin:HideTexture(btn.BGActive)
        WoWTools_TextureMixin:HideTexture(btn.BGInactive)
        WoWTools_TextureMixin:SetAlphaColor(btn.BGShadow, nil, nil, 0.3)
        btn.SlashFBUncharged:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
        btn.SlashFBCharged:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
        WoWTools_DataMixin:Hook(btn, 'Update', function(b)
            b.numTexture:SetShown(not b.isFull)
        end)
    end





--6 DEATHKNIGHT 死亡骑士
    for _, btn in pairs(RuneFrame.Runes or {}) do
        set_Num_Texture(btn)
        WoWTools_TextureMixin:HideTexture(btn.BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
        WoWTools_TextureMixin:SetAlphaColor(btn.BG_Shadow, nil, nil, 0.2)
        WoWTools_TextureMixin:HideTexture(btn.Rune_Inactive)
--满，隐藏
        WoWTools_DataMixin:Hook(btn, 'UpdateState', function(b)
            b.numTexture:SetShown(not b.lastRuneState.runeReady)
        end)
--更新，天赋颜色
        WoWTools_DataMixin:Hook(btn, 'UpdateSpec', function(b, specIndex)
            if specIndex==3 then
                b.numTexture:SetVertexColor(0.5, 1, 0.5)
            else
                b.numTexture:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
            end
        end)
    end
--重新排序，数字
    WoWTools_DataMixin:Hook(RuneFrame, 'UpdateRunes', function(self)
        for newLayoutIndex, runeIndex in ipairs(self.runeIndices) do
            local btn= self.Runes[runeIndex]
            if btn and btn.numTexture then
                btn.numTexture:SetAtlas('services-number-'..newLayoutIndex)
            end
        end
    end)

    for _, btn in pairs(DeathKnightResourceOverlayFrame.Runes or {}) do
        set_Num_Texture(btn)
        WoWTools_TextureMixin:HideTexture(btn.BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
        WoWTools_TextureMixin:SetAlphaColor(btn.BG_Shadow, nil, nil, 0.2)
        WoWTools_TextureMixin:HideTexture(btn.Rune_Inactive)
--满，隐藏
        WoWTools_DataMixin:Hook(btn, 'UpdateState', function(b)
            b.numTexture:SetShown(not b.lastRuneState.runeReady)
        end)
--更新，天赋颜色
        WoWTools_DataMixin:Hook(btn, 'UpdateSpec', function(b, specIndex)
            if specIndex==3 then
                b.numTexture:SetVertexColor(0.5, 1, 0.5)
            else
                b.numTexture:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
            end
        end)
    end
    WoWTools_DataMixin:Hook(DeathKnightResourceOverlayFrame, 'UpdateRunes', function(self)
        for newLayoutIndex, runeIndex in ipairs(self.runeIndices) do
            local btn= self.Runes[runeIndex]
            if btn and btn.numTexture then
                btn.numTexture:SetAtlas('services-number-'..newLayoutIndex)
            end
        end
    end)






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



--9 WARLOCK 术士 
    WoWTools_DataMixin:Hook(WarlockPowerFrame, 'UpdateMaxPower', function(self)
        for btn in self.classResourceButtonPool:EnumerateActive() do
            if not btn.numTexture then
                set_Num_Texture(btn)
                WoWTools_TextureMixin:SetAlphaColor(btn.Background, true)
                WoWTools_DataMixin:Hook(btn, 'Update', function(b)
                    local isShow= b.fillAmount>0
                    b.Background:SetAlpha(isShow and 0 or 0.5)
                    b.numTexture:SetAlpha(isShow and 0 or 1)
                end)
            end
        end
    end)
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
    WoWTools_DataMixin:Hook(MonkHarmonyBarFrame, 'UpdateMaxPower', function(frame)
        for btn in frame.classResourceButtonPool:EnumerateActive() do
            if not btn.numTexture then
               set_Num_Texture(btn, nil, false)
                btn.numTexture:SetVertexColor(0.5, 1, 0.5)
                WoWTools_TextureMixin:HideTexture(btn.Chi_BG_Active)
                WoWTools_TextureMixin:HideTexture(btn.BGInactive)
                WoWTools_TextureMixin:HideTexture(btn.Chi_BG)
                WoWTools_DataMixin:Hook(btn, 'SetActive', function(b)
                    b.numTexture:SetAlpha(b.active and 0 or 1)
                end)
            end
        end
    end)
    for _, btn in pairs(ClassNameplateBarWindwalkerMonkFrame.classResourceButtonTable) do
        set_Num_Texture(btn, nil, false)
        btn.numTexture:SetVertexColor(0.5, 1, 0.5)
        WoWTools_TextureMixin:HideTexture(btn.Chi_BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BGInactive)
        WoWTools_TextureMixin:HideTexture(btn.Chi_BG)
        WoWTools_DataMixin:Hook(btn, 'SetActive', function(b)
            b.numTexture:SetAlpha(b.active and 0 or 1)
        end)
    end






--11 DRUID 德鲁伊
    WoWTools_DataMixin:Hook(DruidComboPointBarFrame, 'UpdateMaxPower', function(frame)
        for btn in frame.classResourceButtonPool:EnumerateActive() do
            if not btn.numTexture then
                set_Num_Texture(btn)
                WoWTools_TextureMixin:HideTexture(btn.BG_Active)
                WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
                WoWTools_TextureMixin:SetAlphaColor(btn.BG_Shadow, nil, nil, 0.8)
                WoWTools_DataMixin:Hook(btn, 'SetActive', function(b)
                    b.numTexture:SetAlpha(b.isActive and 0 or 1)
                end)
            end
        end
    end)
    for _, btn in pairs(ClassNameplateBarFeralDruidFrame.classResourceButtonTable) do
        set_Num_Texture(btn)
        WoWTools_TextureMixin:HideTexture(btn.BG_Active)
        WoWTools_TextureMixin:HideTexture(btn.BG_Inactive)
        WoWTools_TextureMixin:SetAlphaColor(btn.BG_Shadow, nil, nil, 0.8)
        WoWTools_DataMixin:Hook(btn, 'SetActive', function(b)
            b.numTexture:SetAlpha(b.isActive and 0 or 1)
        end)
    end









--13 EVOKER 龙人 唤魔者
    WoWTools_DataMixin:Hook(EssencePlayerFrame, 'UpdateMaxPower', function(frame)
        for btn in frame.classResourceButtonPool:EnumerateActive() do
            if not btn.numTexture then
                set_Num_Texture(btn, nil, false)
                btn.numTexture:SetVertexColor(0.5, 1, 0.5)
                WoWTools_TextureMixin:SetAlphaColor(btn.EssenceFillDone.CircBG, true)
                WoWTools_TextureMixin:SetAlphaColor(btn.EssenceFillDone.CircBGActive, true)
                WoWTools_TextureMixin:SetAlphaColor(btn.EssenceFillDone.RimGlow, true)
                WoWTools_TextureMixin:SetAlphaColor(btn.EssenceDepleting.CircBGActive, true)
                WoWTools_TextureMixin:SetAlphaColor(btn.EssenceDepleting.EssenceBG, nil, true, 0)
                WoWTools_TextureMixin:SetAlphaColor(btn.EssenceDepleting.FXRimGlow, true)
                WoWTools_TextureMixin:SetAlphaColor(btn.EssenceFilling.EssenceBG, nil, true, 0)
            end
        end
    end)
    for _, btn in pairs(ClassNameplateBarDracthyrFrame.classResourceButtonTable) do
        set_Num_Texture(btn, nil, false)
        btn.numTexture:SetVertexColor(0.5, 1, 0.5)
        WoWTools_TextureMixin:SetAlphaColor(btn.EssenceFillDone.CircBG, true)
        WoWTools_TextureMixin:SetAlphaColor(btn.EssenceFillDone.CircBGActive, true)
        WoWTools_TextureMixin:SetAlphaColor(btn.EssenceFillDone.RimGlow, true)
        WoWTools_TextureMixin:SetAlphaColor(btn.EssenceDepleting.CircBGActive, true)
        WoWTools_TextureMixin:SetAlphaColor(btn.EssenceDepleting.EssenceBG, nil, true, 0)
        WoWTools_TextureMixin:SetAlphaColor(btn.EssenceDepleting.FXRimGlow, true)
        WoWTools_TextureMixin:SetAlphaColor(btn.EssenceFilling.EssenceBG, nil, true, 0)
    end




Init=function()
    local s= Save().classPowerNumSize or 23
    local function set_size(self)
        if self and self.numTexture then
            self.numTexture:SetSize(s, s)
        end
    end

--2 PALADIN QS 骑士
    for i=1, 5 do
        set_size(PaladinPowerBarFrame["rune"..i])
        set_size(ClassNameplateBarPaladinFrame["rune"..i])
    end

--4 ROGUE 盗贼
    for btn in RogueComboPointBarFrame.classResourceButtonPool:EnumerateActive() do
        set_size(btn)
    end
    for _, btn in pairs(ClassNameplateBarRogueFrame.classResourceButtonTable) do
        set_size(btn)
    end

--6 DEATHKNIGHT 死亡骑士
    for _, btn in pairs(RuneFrame.Runes or {}) do
        set_size(btn)
    end
    for _, btn in pairs(DeathKnightResourceOverlayFrame.Runes or {}) do
        set_size(btn)
    end

--8 MAGE 法师
    for btn in MageArcaneChargesFrame.classResourceButtonPool:EnumerateActive() do
        set_size(btn)
    end
    for _, btn in pairs(ClassNameplateBarMageFrame.classResourceButtonTable) do
        set_size(btn)
    end

--9 WARLOCK 术士
    for btn in WarlockPowerFrame.classResourceButtonPool:EnumerateActive() do
        set_size(btn)
    end
    for _, btn in pairs(ClassNameplateBarWarlockFrame.classResourceButtonTable) do
        set_size(btn)
    end

--10 MONK 武僧
    for btn in MonkHarmonyBarFrame.classResourceButtonPool:EnumerateActive() do
        set_size(btn)
    end
    for _, btn in pairs(ClassNameplateBarWindwalkerMonkFrame.classResourceButtonTable) do
        set_size(btn)
    end

--11 DRUID 德鲁伊
    for btn in DruidComboPointBarFrame.classResourceButtonPool:EnumerateActive() do
        set_size(btn)
    end
    for _, btn in pairs(DruidComboPointBarFrame.classResourceButtonTable) do
        set_size(btn)
    end

--13 EVOKER 龙人 唤魔者
    for btn in EssencePlayerFrame.classResourceButtonPool:EnumerateActive() do
        set_size(btn)
    end
    for _, btn in pairs(ClassNameplateBarDracthyrFrame.classResourceButtonTable) do
        set_size(btn)
    end


end
end



function WoWTools_TextureMixin:Init_Class_Power()
    Init()
end