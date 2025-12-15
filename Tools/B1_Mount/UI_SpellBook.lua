--法术书，选项
local function SaveLog()
    return WoWToolsPlayerDate['Tools_Mounts']
end




local function Create_Button(btn)
    btn.mountSpell= CreateFrame('Button', nil, btn, 'WoWToolsButtonTemplate')--WoWTools_ButtonMixin:Cbtn(btn, {size=16, atlas='hud-microbutton-Mounts-Down'})
    btn.mountSpell:SetNormalTexture('Interface\\Icons\\MountJournalPortrait')
    btn.mountSpell:SetSize(16,16)
    btn.mountSpell:SetPoint('TOP', btn, 'BOTTOM', -8, 0)

    function btn.mountSpell:settings()
        if self.spellID then
            self:SetAlpha(
                (self:IsMouseOver() or  SaveLog().Spell[self.spellID]) and 1
                or 0.2)
        end
        self:SetShown(self.spellID and not C_Spell.IsSpellPassive(self.spellID))
    end

    function btn.mountSpell:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_ToolsMixin.addName, WoWTools_MountMixin.addName)
        GameTooltip_AddErrorLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            WoWTools_SpellMixin:GetName(self.spellID)
            ..' '..WoWTools_TextMixin:GetEnabeleDisable(SaveLog().Spell[self.spellID]),

            WoWTools_DataMixin.Icon.left
        )
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        self:SetAlpha(1)
    end
    btn.mountSpell:SetScript('OnLeave', function(self) GameTooltip:Hide() self:settings()  end)
    btn.mountSpell:SetScript('OnEnter', function(self)
        self:set_tooltips()
        self:SetAlpha(1)
    end)
    btn.mountSpell:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            SaveLog().Spell[self.spellID]= not SaveLog().Spell[self.spellID] and true or nil
            self:set_tooltips()
            WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
            self:settings()
        else
            WoWTools_MountMixin:Init_Menu_Spell(self)
        end
    end)
end






local function Init()
    WoWTools_DataMixin:Hook(SpellBookItemMixin, 'UpdateVisuals', function(frame)
        if not frame.Button.mountSpell then
            Create_Button(frame.Button)
        end
        
        frame.Button.mountSpell.spellID= frame.spellBookItemInfo.spellID
        frame.Button.mountSpell:settings()
    end)
    Init=function()end
end





function WoWTools_MountMixin:Init_UI_SpellBook_Menu()--法术书，选项

    if C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
        Init()
    else
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_PlayerSpells' then
                Init()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
    end
end