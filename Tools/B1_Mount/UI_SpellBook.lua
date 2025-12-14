--法术书，选项
local function SaveLog()
    return WoWToolsPlayerDate['Tools_Mounts']
end




local function Create_Button(btn)
    btn.mountSpell= CreateFrame('Button', nil, btn, 'WoWToolsMenuTemplate')--WoWTools_ButtonMixin:Cbtn(btn, {size=16, atlas='hud-microbutton-Mounts-Down'})
    btn.mountSpell:SetNormalAtlas('hud-microbutton-Mounts-Down')
    btn.mountSpell:SetPoint('TOP', btn, 'BOTTOM', -8, 0)

    function btn.mountSpell:set_alpha()
        if self.spellID then
            self:SetAlpha(SaveLog().Spell[self.spellID] and 1 or 0.2)
        end
    end
    function btn.mountSpell:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_ToolsMixin.addName, WoWTools_MountMixin.addName)
        GameTooltip:AddLine(' ')
        if self.spellID then
            GameTooltip:AddDoubleLine(
                '|T'..(C_Spell.GetSpellTexture(self.spellID) or 0)..':0|t'
                ..(C_Spell.GetSpellLink(self.spellID) or self.spellID)
                ..' '..WoWTools_TextMixin:GetEnabeleDisable(SaveLog().Spell[self.spellID]),

                WoWTools_DataMixin.Icon.left
            )
        end
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        self:SetAlpha(1)
    end
    btn.mountSpell:SetScript('OnLeave', function(self) GameTooltip:Hide() self:set_alpha()  end)
    btn.mountSpell:SetScript('OnEnter', btn.mountSpell.set_tooltips)
    btn.mountSpell:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            if self.spellID then
                SaveLog().Spell[self.spellID]= not SaveLog().Spell[self.spellID] and true or nil
                self:set_tooltips()
                self:set_alpha()
                WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
                print(WoWTools_MountMixin.addName..WoWTools_DataMixin.Icon.icon2, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD, C_Spell.GetSpellLink(self.spellID))
            end
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
        frame.Button.mountSpell:set_alpha()
        frame.Button.mountSpell:SetShown(frame.spellBookItemInfo.spellID and true or false)
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