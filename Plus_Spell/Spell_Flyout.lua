--Flyout, 技能，提示
--'|A:common-icon-backarrow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '法术弹出框' or 'SpellFlyout')

local SpellTab={}--WoWTools_DataMixin.ChallengesSpellTabs


--[[local function Vstr(t)--垂直文字
    local len = select(2, t:gsub("[^\128-\193]", ""))
    if(len == #t) then
        return t:gsub(".", "%1|n")
    else
        return t:gsub("([%z\1-\127\194-\244][\128-\191]*)", "%1|n")
    end
end]]

local CALL_PET_SPELL_IDS = {
	[0883]=1,
	[83242]=2,
	[83243]=3,
	[83244]=4,
	[83245]=5,
}




local function GetHunterPetSpellText(spellID, isLeftPoint)
    local index= CALL_PET_SPELL_IDS[spellID]
    local info= index and C_StableInfo.GetStablePetInfo(index)
    if not info then
        return
    end

    local texture

    local icon

    for _, abilitie in pairs(info.abilities or info.petAbilities or {}) do
        texture= C_Spell.GetSpellTexture(abilitie)
        if texture and texture>0 then
            icon= (icon and icon..(isLeftPoint and '' or '|n' ) or '')..'|T'..texture..':18|t'
        end
    end

    local atlas = WoWTools_DataMixin.Icon[info.specialization]
    if atlas then
        icon= (icon and icon..(isLeftPoint and '' or '|n' ) or '').. (atlas and '|A:'..atlas..':0:0|a' or '')
    end

    for _, abilitie in pairs(info.specAbilities or {}) do
        texture= C_Spell.GetSpellTexture(abilitie)
        if texture and texture>0 then
            icon= (icon and icon..(isLeftPoint and '' or '|n' ) or '')..'|T'..texture..':18|t'
        end
    end

    return icon
end








local function GetSpellText(spellID)
    if C_Spell.IsSpellPassive(spellID) then
        return
    end

    local text
    local des= C_Spell.GetSpellDescription(spellID)
    des= WoWTools_TextMixin:CN(des)
    if des then
        text= des:match('|cff00ccff(.-)|r')
            or des:match('传送至(.-)入口处')--传送至永茂林地入口处。
            or des:match('传送到(.-)的入口')--传送到自由镇的入口
            or des:match('将施法者传送到(.-)入口')--将施法者传送到青龙寺入口。

            or des:match('Teleportiert zum Eingang des (.-)%.')--Teleportiert zum Eingang des Immergrünen Flors.
            or des:match('Teleport to the entrance to (.-)%.')--Teleport to the entrance to The Everbloom.
            or des:match('Teletransporte a la entrada del (.-)%.')--Teletransporte a la entrada del Vergel Eterno.
            or des:match('Téléporte à l’entrée de la (.-)%.')--Téléporte à l’entrée de la Flore éternelle.

            or des:match('Teletrasporta all\'ingresso di (.-)%.')--Teletrasporta all'ingresso di Verdeterno.
            or des:match('Teletrasporta all\'ingresso del (.-)%.')
            or des:match('Teletrasporta all\'ingresso dell\'(.-)%.')

            or des:match('Teleporta para a entrada de (.-)')--Teleporta para a entrada de Floretérnia.
            or des:match('Телепортирует заклинателя в (.-)%.')--Телепортирует заклинателя в Вечное Цветение.
            or des:match('(.-) 입구로 순간이동합니다')--상록숲 입구로 순간이동합니다.
    end
    if not text then
        text= WoWTools_TextMixin:CN(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true})
        if not text then
            text= select(2, GetCallPetSpellInfo(spellID))
            text= WoWTools_TextMixin:CN(text)
        end
        text=text:match('%-(.+)') or text
        text=text:match('：(.+)') or text
        text=text:match(':(.+)') or text
        text=text:gsub(' %d','')
        text=text:gsub(SUMMONS,'')
    end

    return text
end







local function Set_Text(self, text)
    if self.spellText then
        self.spellText:SetText(text or '')
    end
end
































local function Init()

    if WoWTools_DataMixin.onlyChinese then
        for _, info in pairs(WoWTools_DataMixin.ChallengesSpellTabs or {}) do
            if info.spell and info.name then
                SpellTab[info.spell]=info.name
            end
        end
    end

--Flyout, 技能，提示
    WoWTools_DataMixin:Hook(SpellFlyoutPopupButtonMixin, 'UpdateGlyphState', function(self)
        if not self.spellID then
            Set_Text(self, nil)
            return
        end

        local p=self:GetPoint(1)
        local isLeftPoint= (p=='TOP') or (p=='BOTTOM')

        local hunterPetText= GetHunterPetSpellText(self.spellID, isLeftPoint)
        local text= hunterPetText or SpellTab[self.spellID]  or  GetSpellText(self.spellID)


        if text then
            if not self.spellText then
                self.spellText= WoWTools_LabelMixin:Create(self, {color={r=1,g=1,b=1}, justifyH='CENTER', size=14})
                self.TextBg= self:CreateTexture(nil, 'BACKGROUND')


                self.TextBg:SetPoint('TOPLEFT', self.spellText,-6, 6)
                self.TextBg:SetPoint('BOTTOMRIGHT', self.spellText, 6,-6 )
                self.TextBg:SetAtlas('ChallengeMode-guild-background')
            end


            if isLeftPoint~=self.isLeftPoint then
                self.spellText:ClearAllPoints()
                if isLeftPoint then
                    self.spellText:SetPoint('RIGHT', self, 'LEFT',-1, 0)
                else
                    self.spellText:SetPoint('BOTTOM', self, 'TOP', 0, 1)
                end
                self.isLeftPoint= isLeftPoint
            end

            if not hunterPetText and not isLeftPoint then
                text= WoWTools_TextMixin:Vstr(text)--垂直文字
            end

        elseif self.spellText then
            self.spellText:ClearAllPoints()
            self.isLeftPoint=nil
        end

        Set_Text(self, text)
    end)

    WoWTools_DataMixin:Hook(SpellFlyout, 'Toggle',  GameTooltip_Hide)--隐藏

    Init=function()end
end








function WoWTools_SpellMixin:Init_Spell_Flyout()
    if WoWToolsSave['Plus_Spell'].flyoutText then
        Init()
    end
end