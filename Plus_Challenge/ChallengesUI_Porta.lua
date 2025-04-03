--传送门
local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end






local function Create_Button(frame)
    if frame.spellPort then
        return
    end

    frame.spellPort= WoWTools_ButtonMixin:Cbtn(frame, {
        isSecure=true,
        size= 26,--52
        icon= 'hide',
    })

    function frame.spellPort:set_alpha()
        frame.spellPort:SetAlpha(
            (
                IsSpellKnownOrOverridesKnown(self.spellID)
                or GameTooltip:IsOwned(self)
            ) and 1 or 0.3
        )
    end

    frame.spellPort:SetAttribute("type", "spell")
    frame.spellPort:RegisterEvent('SPELL_UPDATE_COOLDOWN')

    frame.spellPort:SetPoint('BOTTOMRIGHT', frame)--, 4,-4)

    frame.spellPort:SetScript("OnLeave",function(self)
        GameTooltip:Hide()
        self:set_alpha()
    end)
    frame.spellPort:SetScript("OnEnter",function(self)
        WoWTools_SetTooltipMixin:Frame(self)
        self:SetAlpha(1)
    end)

    frame.spellPort:SetScript('OnHide', function(self)
        self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
    end)

    frame.spellPort:SetScript('OnShow', function(self)
        self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        WoWTools_CooldownMixin:SetFrame(self, {spell=self.spellID})
    end)

    frame.spellPort:SetScript('OnEvent', function(self)
        WoWTools_CooldownMixin:SetFrame(self, {spell=self.spellID})
    end)
end












local function Set_Update()--Blizzard_ChallengesUI.lua
    local self= ChallengesFrame
    if not self.maps or #self.maps==0 then
        return
    end

    for i=1, #self.maps do
        local frame = self.DungeonIcons[i]
        local data= WoWTools_DataMixin.ChallengesSpellTabs[frame.mapID]

        local spellID= data and data.spell

        --spellID= 1543

        if spellID then
            Create_Button(frame)

            frame.spellPort.spellID= spellID

            local texture= C_Spell.GetSpellTexture(spellID)
            if texture then
                frame.spellPort:SetNormalTexture(texture)
            else
                frame.spellPort:SetNormalAtlas('WarlockPortal-Yellow-32x32')
            end

            frame.spellPort:GetNormalTexture():SetDesaturated(not IsSpellKnownOrOverridesKnown(spellID))

            WoWTools_CooldownMixin:SetFrame(frame.spellPort, {spell=spellID})

            frame.spellPort:set_alpha()

            if frame.spellPort:CanChangeAttribute() then
                frame.spellPort:SetAttribute("spell",  spellID)--local name= C_Spell.GetSpellName(frame.spellID) 
                frame.spellPort:SetShown(not Save().hidePort)
                frame.spellPort:SetScale(Save().portScale or 1)
            end
        end
    end
end






local IsInCombat
local function Is_Check()
    if InCombatLockdown() then
        if not IsInCombat then
            IsInCombat= true
            EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
                if ChallengesFrame and ChallengesFrame:IsVisible() and IsInCombat then
                    Set_Update()
                end
                IsInCombat= nil
                EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
            end)
        end
    else
        Set_Update()
        IsInCombat= nil
    end
end








--####
--初始
--####
local function Init()
    if Save().hidePort then
        return
    end

    hooksecurefunc(ChallengesFrame, 'Update', function()
        Is_Check()
    end)

    Init=function()
        Is_Check()
    end
end





function WoWTools_ChallengeMixin:ChallengesUI_Porta()
    Init()
end
