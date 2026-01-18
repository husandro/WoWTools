local function Get_FlyoutNum(flyoutID)
    local numSlots= flyoutID and select(3, GetFlyoutInfo(flyoutID)) or 0
    if numSlots<=0 then
        return ''
    end

    local num=0
    for slot= 1, numSlots do
        local isKnown2 = select(3, GetFlyoutSlotInfo(flyoutID, slot))
        if isKnown2 then
            num= num+1
        end
    end

    return num..'/'..numSlots
end









local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub
    local name, _, numSlots2= GetFlyoutInfo(self.flyoutID)
    if not name or not numSlots2 then
        return
    end

    sub=root:CreateTitle(WoWTools_TextMixin:CN(name))
    root:CreateDivider()

    local spells={}
    for _, spellinfo in pairs(WoWTools_ChallengesSpellData) do
        if spellinfo.spell then
            spells[spellinfo.spell]=true
        end
    end
    local isInCombat= InCombatLockdown()
    for slot= 1, numSlots2 do
        local flyoutSpellID, overrideSpellID, isKnown, spellName = GetFlyoutSlotInfo(self.flyoutID, slot)
        local spellID= overrideSpellID or flyoutSpellID
        if spellID then
            sub= root:CreateButton(
                '|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'
                ..(isKnown and '' or '|cnWARNING_FONT_COLOR:')
                ..(WoWTools_TextMixin:CN(spellName, {spellID=spellID, isName=true}) or spellID)
                --为挑战数据，标记是否有数据，需要更新
                ..(WoWTools_DataMixin.Player.husandro and not self.isRaid and not spells[spellID] and '|A:UI-LFG-PendingMark:0:0|a' or ''),
            function(data)
                local spellLink= WoWTools_SpellMixin:GetLink(data.spellID, false)
                WoWTools_ChatMixin:Chat(spellLink or data.spellID, nil, true)
                return MenuResponse.Open
            end, {spellID=spellID})
            WoWTools_SetTooltipMixin:Set_Menu(sub)

            sub= sub:CreateButton(--bug
                WoWTools_DataMixin.onlyChinese and '查询' or WHO,
            function(data)
                if not InCombatLockdown() then
                    PlayerSpellsUtil.OpenToSpellBookTabAtSpell(data.spellID, false, true, false)--knownSpellsOnly, toggleFlyout, flyoutReason
                end
                return MenuResponse.Open
            end, {spellID=spellID})
            sub:SetEnabled(not isInCombat)
        end
    end

    root:CreateDivider()
--打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {
        name=WoWTools_SpellMixin.addName,
        category=WoWTools_SpellMixin.Category,
        name2='|A:spellbook-item-iconframe:0:0|a'..(WoWTools_DataMixin.onlyChinese and '法术书' or SPELLBOOK),
    })
    
--SetScrollMod
    WoWTools_MenuMixin:SetScrollMode(root)
    spells=nil
end







local function Init_All_Flyout()

    local y= -105
    for _, data in pairs(WoWTools_DataMixin.FlyoutID) do--1024 MAX_SPELLS

        local btn= WoWTools_ButtonMixin:Menu(PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame, {
            atlas= data.isRaid and 'Raid',
            texture=not data.isRaid and 519384,
            size=32
        })

        btn.isRaid= data.isRaid
        btn.flyoutID= data.flyoutID

        btn:SetPoint('TOPLEFT', 18, y)
        btn:SetupMenu(Init_Menu)

        btn:SetScript('OnLeave', GameTooltip_Hide)-- function(self) self:SetAlpha(isKnown and 0.1 or 0.5) GameTooltip:Hide() end)
        btn:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()

            local spells={}
            for _, spellinfo in pairs(WoWTools_ChallengesSpellData) do
                if spellinfo.spell then
                    spells[spellinfo.spell]=true
                end
            end

            local name, description, numSlots2= GetFlyoutInfo(self.flyoutID)
            GameTooltip:AddLine(name, 1,1,1)
            GameTooltip:AddLine(description, nil, nil, nil, true)
            GameTooltip:AddLine(' ')

            for slot= 1, numSlots2 do
                local flyoutSpellID, overrideSpellID, isKnown2, spellName = GetFlyoutSlotInfo(self.flyoutID, slot)
                local spellID= overrideSpellID or flyoutSpellID
                if spellID then
                   WoWTools_DataMixin:Load(spellID, 'spell')
                    local name2= WoWTools_TextMixin:CN(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true})
                    local icon= C_Spell.GetSpellTexture(spellID)
                    if name2 and icon then
                        GameTooltip:AddDoubleLine(
                            '|T'..icon..':0|t'
                            ..(not isKnown2 and ' |cnWARNING_FONT_COLOR:' or '')
                            ..WoWTools_TextMixin:CN(name2)..'|r',

                            (not isKnown2 and '|cnWARNING_FONT_COLOR:' or '')
                            ..spellID
                            ..' '
                            ..(WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)
                            ..'('..slot
--为挑战数据，标记是否有数据，需要更新
                            ..((WoWTools_DataMixin.Player.husandro and not self.isRaid and not spells[spellID] and '|A:UI-LFG-PendingMark:0:0|a' or '')
                            )
                        )
                    else
                        GameTooltip:AddDoubleLine((not isKnown2 and ' |cnWARNING_FONT_COLOR:' or '')..spellName..'|r',(not isKnown2 and '|cnWARNING_FONT_COLOR:' or '')..spellID..' '..(WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)..'('..slot)
                    end
                end
            end

            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('flyoutID '..self.flyoutID, WoWTools_SpellMixin.addName)
            GameTooltip:Show()
            spells=nil
        end)

        btn.Text= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
        btn.Text:SetPoint('BOTTOM',0,2)

--版本
        btn.ver= btn:CreateTexture(nil, "BORDER")
        btn.ver:SetSize(24,12)
        btn.ver:SetPoint('TOP', btn, 'BOTTOM', 0, 2)
        WoWTools_TextureMixin:GetWoWLog(data.ver, btn.ver)

        function btn:set_text()
            btn.Text:SetText(Get_FlyoutNum(self.flyoutID))
        end

        btn:SetScript('OnShow', function(self)
            self:set_text()
        end)
        btn:set_text()

        y= y-32-15
    end
end












local function Init()
    WoWTools_DataMixin:Hook(SpellBookItemMixin, 'UpdateVisuals', function(frame)
        if not frame.spellBookItemInfo then
            return
        end
        local r,g,b=1,1,1
        local flyoutText
        if frame:IsFlyout() then--if (frame.spellBookItemInfo.itemType == Enum.SpellBookItemType.Flyout) then
            r,g,b= 1,0,1
            if not frame.TextContainer.FlyoutText then
                frame.TextContainer.FlyoutText= frame.TextContainer:CreateFontString(nil, 'OVERLAY', 'SystemFont_Med1')
                frame.TextContainer.FlyoutText:SetPoint('BOTTOMLEFT', frame.TextContainer.Name,'TOPLEFT', 2,2)
                frame.TextContainer.FlyoutText:SetTextColor(SPELLBOOK_FONT_COLOR:GetRGB())
            end
            flyoutText= Get_FlyoutNum(frame.spellBookItemInfo.actionID)
        end
        frame.Button.Arrow:SetVertexColor(r,g,b)
        frame.Button.Border:SetVertexColor(r,g,b)
        frame.Button.ActionBarHighlight:SetVertexColor(0,1,0)
        if frame.TextContainer.FlyoutText then
            frame.TextContainer.FlyoutText:SetText(flyoutText or '')
        end
    end)




    Init_All_Flyout()

    Init=function()end
end


function WoWTools_SpellMixin:Init_SpellBookFrame()
    if WoWToolsSave['Plus_Spell'].spellBookPlus and C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
        Init()
    end
end