--Flyout, 技能，提示
local id, e= ...
local Save={}
local SpellTab={}--e.ChallengesSpellTabs
local addName

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

    local atlas = e.dropdownIconForPetSpec[info.specialization]
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
    des= e.cn(des)
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
        text= e.cn(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true})
        if not text then
            text= select(2, GetCallPetSpellInfo(spellID))
            text= e.cn(text)
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






--Flyout, 技能，提示
local function set_SpellFlyoutButton_UpdateGlyphState(self)
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
end












local function Init_Menu(self, root)
    local sub
    local name, _, numSlots2= GetFlyoutInfo(self.flyoutID)
    if not name or not numSlots2 then
        return
    end

    sub=root:CreateTitle(e.cn(name))
    root:CreateDivider()

    for slot= 1, numSlots2 do
        local flyoutSpellID, overrideSpellID, isKnown, spellName = GetFlyoutSlotInfo(self.flyoutID, slot)
        local spellID= overrideSpellID or flyoutSpellID
        if spellID then
            sub= root:CreateButton(
                '|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'
                ..(isKnown and '' or '|cnRED_FONT_COLOR:')
                ..(e.cn(spellName, {spellID=spellID, isName=true}) or spellID),
            function(data)
                local spellLink= WoWTools_SpellMixin:GetLink(data.spellID, false)
                WoWTools_ChatMixin:Chat(spellLink or data.spellID, nil, true)
                return MenuResponse.Open
            end, {spellID=spellID})
            WoWTools_SetTooltipMixin:Set_Menu(sub)

            --[[sub:CreateButton(--bug
                e.onlyChinese and '查询' or WHO,
            function(data)
                PlayerSpellsUtil.OpenToSpellBookTabAtSpell(data.spellID, false, true, true)--knownSpellsOnly, toggleFlyout, flyoutReason
                return MenuResponse.Open
            end, {spellID=spellID})]]
        end
    end
end














local function Init_All_Flyout()
    --if not e.Player.IsMaxLevel or e.Is_Timerunning then return end
    --https://wago.tools/db2/SpellFlyout?build=11.0.0.55288&locale=zhCN
    local tab={
        232,--'英雄之路：地心之战--11
        231,--英雄之路：巨龙时代团队副本
        227,--巨龙时代 10

        220,--暗影国度 9
        222,--英雄之路：暗影国度团队副本

        223,--争霸艾泽拉斯 8
        224,--军团再临 7
        96,--德拉诺这王 6
        84,--熊猫人之谜 5
        230,--大地的裂变 4
        --巫妖王之怒 3
        --燃烧的远征 2
        --经典旧世 1
    }
    local y= -145
    for _, flyoutID in pairs(tab) do--1024 MAX_SPELLS

        local btn= WoWTools_ButtonMixin:Cbtn(PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame, {
            texture=519384,
            size=32
        })

        btn:SetPoint('TOPLEFT', 22, y)

        btn:SetScript('OnClick', function(self)
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end)

        btn:SetScript('OnLeave', GameTooltip_Hide)-- function(self) self:SetAlpha(isKnown and 0.1 or 0.5) GameTooltip:Hide() end)
        btn:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()

            local name, description, numSlots2= GetFlyoutInfo(self.flyoutID)
            GameTooltip:AddLine(name, 1,1,1)
            GameTooltip:AddLine(description, nil,nil,nil,true)
            GameTooltip:AddLine(' ')

            for slot= 1, numSlots2 do
                local flyoutSpellID, overrideSpellID, isKnown2, spellName = GetFlyoutSlotInfo(self.flyoutID, slot)
                local spellID= overrideSpellID or flyoutSpellID
                if spellID then
                    WoWTools_Mixin:Load({id=spellID, type='spell'})
                    local name2= e.cn(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true})
                    local icon= C_Spell.GetSpellTexture(spellID)
                    if name2 and icon then
                        GameTooltip:AddDoubleLine('|T'..icon..':0|t'..(not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..e.cn(name2)..'|r', (not isKnown2 and '|cnRED_FONT_COLOR:' or '').. spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
                    else
                        GameTooltip:AddDoubleLine((not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..spellName..'|r',(not isKnown2 and '|cnRED_FONT_COLOR:' or '')..spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
                    end
                end
            end

            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('flyoutID '..self.flyoutID, addName)
            GameTooltip:Show()
        end)

        btn.Text= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
        btn.Text:SetPoint('BOTTOM',0,2)
        btn.flyoutID= flyoutID

        function btn:set_text()
            local numSlots= select(3, GetFlyoutInfo(self.flyoutID)) or 0
            local num=0
            for slot= 1, numSlots do
                local isKnown2 = select(3, GetFlyoutSlotInfo(self.flyoutID, slot))
                if isKnown2 then
                    num= num+1
                end
            end

            btn.Text:SetText(
                (num==numSlots and '|cnGREEN_FONT_COLOR:' or '')
                .. num..'/'..numSlots
            )
        end

        btn:set_text()
        btn:SetScript('OnShow', btn.set_text)

        y= y-46

    end

end










local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave['Other_SpellFlyout'] or Save

            addName= '|A:common-icon-backarrow:0:0|a'..(e.onlyChinese and '法术弹出框' or 'SpellFlyout')

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                Value= not Save.disabled,
                GetValue=function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            })

            if Save.disabled then
                self:UnregisterEvent(event)
            else
                if e.onlyChinese then
                    for _, info in pairs(e.ChallengesSpellTabs or {}) do
                        if info.spell and info.name then
                            SpellTab[info.spell]=info.name
                        end
                    end
                end

                hooksecurefunc(SpellFlyoutPopupButtonMixin, 'UpdateGlyphState', set_SpellFlyoutButton_UpdateGlyphState)

                hooksecurefunc(SpellFlyout, 'Toggle',  GameTooltip_Hide)--隐藏
            end

        elseif arg1=='Blizzard_PlayerSpells' then--天赋
            Init_All_Flyout()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Other_SpellFlyout']=Save
        end
    end
end)