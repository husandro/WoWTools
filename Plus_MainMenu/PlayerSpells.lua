--天赋







local function Init()
    local frame= CreateFrame('Frame')
    --table.insert(Frames, frame)
    PlayerSpellsMicroButton.frame= frame

    PlayerSpellsMicroButton.Portrait= PlayerSpellsMicroButton:CreateTexture(nil, 'BORDER', nil, 1)
    --PlayerSpellsMicroButton.Portrait:SetAllPoints(PlayerSpellsMicroButton)
    PlayerSpellsMicroButton.Portrait:SetPoint('CENTER')
    PlayerSpellsMicroButton.Portrait:SetSize(22, 28)

    PlayerSpellsMicroButton.Texture2= PlayerSpellsMicroButton:CreateTexture(nil, 'BORDER', nil, 2)
    PlayerSpellsMicroButton.Texture2:SetPoint('BOTTOMRIGHT', -8, 6)
    PlayerSpellsMicroButton.Texture2:SetSize(20, 24)
    PlayerSpellsMicroButton.Texture2:SetScale(0.5)


    if WoWToolsSave['Plus_MainMenu'].enabledMainMenuAlpha then
        PlayerSpellsMicroButton.Portrait:SetAlpha(WoWToolsSave['Plus_MainMenu'].mainMenuAlphaValue)
        PlayerSpellsMicroButton.Texture2:SetAlpha(WoWToolsSave['Plus_MainMenu'].mainMenuAlphaValue)
    end



    local mask= PlayerSpellsMicroButton:CreateMaskTexture(nil, 'BORDER', nil, 3)
    mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetPoint('CENTER',0,-1)
    mask:SetSize(19, 24)
    --mask:SetAllPoints(PlayerSpellsMicroButton.Portrait)
    PlayerSpellsMicroButton.Portrait:AddMaskTexture(mask)

    mask= PlayerSpellsMicroButton:CreateMaskTexture(nil, 'BORDER', nil, 4)
    mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
    mask:SetAllPoints(PlayerSpellsMicroButton.Texture2)
    PlayerSpellsMicroButton.Texture2:AddMaskTexture(mask)

    function frame:settings()
        local lootID=  GetLootSpecialization()
        local specID=  PlayerUtil.GetCurrentSpecID()
        local icon2
        local icon = specID and select(4, GetSpecializationInfoByID(specID))
        if lootID>0 and specID and specID~= lootID then
            icon2 = select(4, GetSpecializationInfoByID(lootID))
        end
        PlayerSpellsMicroButton.Portrait:SetTexture(icon or 0)
        PlayerSpellsMicroButton.Texture2:SetTexture(icon2 or 0)
    end
    frame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'Player')
    frame:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)


    PlayerSpellsMicroButton:SetNormalTexture(0)
    PlayerSpellsMicroButton:HookScript('OnLeave', function(self)
        self.Portrait:SetShown(true)
        self.Texture2:SetShown(true)
    end)
    PlayerSpellsMicroButton:HookScript('OnEnter', function(self)
        self.Portrait:SetShown(false)
        self.Texture2:SetShown(false)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        local a, b
        local index= GetSpecialization()--当前专精
        local specID
        if index then
            local ID, _, _, icon, role = GetSpecializationInfo(index)
            specID= ID
            if icon then
                a= '|T'..icon..':0|t'..(WoWTools_DataMixin.Icon[role] or '')
            end
        end
        local lootSpecID = GetLootSpecialization()
        if lootSpecID or specID then
            lootSpecID= lootSpecID==0 and specID or lootSpecID
            local icon, role = select(4, GetSpecializationInfoByID(lootSpecID))
            if icon then
                b= '|T'..icon..':0|t'..(WoWTools_DataMixin.Icon[role] or '')
            end
        end
        a= a or ''
        b= b or a or ''
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine((WoWTools_Mixin.onlyChinese and '当前专精' or TRANSMOG_CURRENT_SPECIALIZATION)..a)
        GameTooltip:AddLine(
            (lootSpecID==specID and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')
            ..(WoWTools_Mixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)
            ..b
        )

        GameTooltip:AddLine(' ')
        local bat= UnitAffectingCombat('player')

        GameTooltip:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(WoWTools_Mixin.onlyChinese and '专精' or TALENT_FRAME_TAB_LABEL_SPEC)..'|r'
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_Mixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP)
        )
        GameTooltip:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(WoWTools_Mixin.onlyChinese and '天赋' or TALENT_FRAME_TAB_LABEL_SPELLBOOK)..'|r'
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(WoWTools_Mixin.onlyChinese and '法术书' or TALENT_FRAME_TAB_LABEL_SPELLBOOK)..'|r'
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_Mixin.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
        )

        GameTooltip:Show()
    end)

    PlayerSpellsMicroButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() then
            WoWTools_LoadUIMixin:SpellBook(2, nil)
        end
    end)

    PlayerSpellsMicroButton:EnableMouseWheel(true)
    PlayerSpellsMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        if d==1 then
            WoWTools_LoadUIMixin:SpellBook(1, nil)
        elseif d==-1 then
            WoWTools_LoadUIMixin:SpellBook(3, nil)
        end
    end)

    Init=function()end
end








function WoWTools_MainMenuMixin:Init_Talent()--天赋
    Init()
end