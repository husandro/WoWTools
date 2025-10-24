--传送门
local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end






local function Create_Button(frame)
    if frame.spellPort then
        return
    end

    frame.spellPort= WoWTools_ButtonMixin:Cbtn(nil, {
        isSecure=true,
        size= 26,--52
        icon= 'hide',
    })

    function frame.spellPort:set_alpha()
        frame.spellPort:SetAlpha(
            (
                C_SpellBook.IsSpellInSpellBook(self.spellID)
                or GameTooltip:IsOwned(self)
            ) and 1 or 0.3
        )
    end
    
    frame.spellPort:SetFrameStrata('HIGH')


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
        WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID})
    end)

    frame.spellPort:SetScript('OnEvent', function(self, event)
        if event=='SPELL_UPDATE_COOLDOWN' then
            WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID})

        elseif event=='PLAYER_REGEN_DISABLED' then
            self:SetShown(false)
        elseif event=='PLAYER_REGEN_ENABLED' then
            self:SetShown(true)
        end
    end)


    frame:HookScript('OnShow', function(self)
        if not InCombatLockdown() then
            self.spellPort:SetShown(true)
        end
        self.spellPort:RegisterEvent('PLAYER_REGEN_DISABLED')
        self.spellPort:RegisterEvent('PLAYER_REGEN_ENABLED')
    end)
    frame:HookScript('OnHide', function(self)
        if not InCombatLockdown() then
            self.spellPort:SetShown(false)
        end
        self.spellPort:UnregisterAllEvents()
    end)

    frame.spellPort:RegisterEvent('PLAYER_REGEN_DISABLED')
    frame.spellPort:RegisterEvent('PLAYER_REGEN_ENABLED')
end












local function Set_Update()--Blizzard_ChallengesUI.lua
    local self= ChallengesFrame
    if not self.maps or #self.maps==0 then
        return
    end

    for i=1, #self.maps do
        local frame = self.DungeonIcons[i]
        local data= WoWTools_ChallengesSpellData[frame.mapID]

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

            frame.spellPort:GetNormalTexture():SetDesaturated(not C_SpellBook.IsSpellInSpellBook(spellID))

            WoWTools_CooldownMixin:SetFrame(frame.spellPort, {spellID=spellID})

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
    if not ChallengesFrame or not ChallengesFrame:IsVisible() then
        return
    end
    if InCombatLockdown() then
        if not IsInCombat then
            IsInCombat= true
            EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
                if IsInCombat then
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

    WoWTools_DataMixin:Hook(ChallengesFrame, 'Update', function()
        Is_Check()
    end)

    Init=function()
        Is_Check()
    end
end





function WoWTools_ChallengeMixin:ChallengesUI_Porta()
    Init()
end
