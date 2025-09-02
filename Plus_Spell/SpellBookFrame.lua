

local function Init_Menu(self, root)
    local sub
    local name, _, numSlots2= GetFlyoutInfo(self.flyoutID)
    if not name or not numSlots2 then
        return
    end

    sub=root:CreateTitle(WoWTools_TextMixin:CN(name))
    root:CreateDivider()

    for slot= 1, numSlots2 do
        local flyoutSpellID, overrideSpellID, isKnown, spellName = GetFlyoutSlotInfo(self.flyoutID, slot)
        local spellID= overrideSpellID or flyoutSpellID
        if spellID then
            sub= root:CreateButton(
                '|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'
                ..(isKnown and '' or '|cnRED_FONT_COLOR:')
                ..(WoWTools_TextMixin:CN(spellName, {spellID=spellID, isName=true}) or spellID),
            function(data)
                local spellLink= WoWTools_SpellMixin:GetLink(data.spellID, false)
                WoWTools_ChatMixin:Chat(spellLink or data.spellID, nil, true)
                return MenuResponse.Open
            end, {spellID=spellID})
            WoWTools_SetTooltipMixin:Set_Menu(sub)

            --[[sub:CreateButton(--bug
                WoWTools_DataMixin.onlyChinese and '查询' or WHO,
            function(data)
                PlayerSpellsUtil.OpenToSpellBookTabAtSpell(data.spellID, false, true, true)--knownSpellsOnly, toggleFlyout, flyoutReason
                return MenuResponse.Open
            end, {spellID=spellID})]]
        end
    end

    root:CreateDivider()
--打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_SpellMixin.addName, category=WoWTools_SpellMixin.Category})
    
--SetScrollMod
    WoWTools_MenuMixin:SetScrollMode(root)
end







local function Init_All_Flyout()

    local y= -145
    for _, data in pairs(WoWTools_DataMixin.FlyoutID) do--1024 MAX_SPELLS

        local btn= WoWTools_ButtonMixin:Cbtn(PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame, {
            atlas= data.isRaid and 'Raid',
            texture=not data.isRaid and 519384,
            size=32
        })

        btn:SetPoint('TOPLEFT', 22, y)

        btn:SetScript('OnClick', function(self)
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
        end)

        btn:SetScript('OnLeave', GameTooltip_Hide)-- function(self) self:SetAlpha(isKnown and 0.1 or 0.5) GameTooltip:Hide() end)
        btn:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()

            local spells={}
            for _, spellinfo in pairs(WoWTools_DataMixin.ChallengesSpellTabs) do
                if spellinfo.spell then
                    spells[spellinfo.spell]=true
                end
            end

            local name, description, numSlots2= GetFlyoutInfo(self.flyoutID)
            GameTooltip:AddLine(name, 1,1,1)
            GameTooltip:AddLine(description, nil,nil,nil,true)
            GameTooltip:AddLine(' ')

            for slot= 1, numSlots2 do
                local flyoutSpellID, overrideSpellID, isKnown2, spellName = GetFlyoutSlotInfo(self.flyoutID, slot)
                local spellID= overrideSpellID or flyoutSpellID
                if spellID then
                    WoWTools_DataMixin:Load({id=spellID, type='spell'})
                    local name2= WoWTools_TextMixin:CN(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true})
                    local icon= C_Spell.GetSpellTexture(spellID)
                    if name2 and icon then
                        GameTooltip:AddDoubleLine(
                            '|T'..icon..':0|t'
                            ..(not isKnown2 and ' |cnRED_FONT_COLOR:' or '')
                            ..WoWTools_TextMixin:CN(name2)..'|r',

                            (not isKnown2 and '|cnRED_FONT_COLOR:' or '')
                            ..spellID
                            ..' '
                            ..(WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)
                            ..'('..slot
                            ..(spells[spellID] and ''
                                or (WoWTools_DataMixin.Player.husandro and '|A:UI-LFG-PendingMark:0:0|a' or '')--为挑战数据，标记是否有数据，需要更新
                            )
                        )
                    else
                        GameTooltip:AddDoubleLine((not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..spellName..'|r',(not isKnown2 and '|cnRED_FONT_COLOR:' or '')..spellID..' '..(WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)..'('..slot)
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



        btn.flyoutID= data.flyoutID

        btn:set_text()

        btn:SetScript('OnShow', btn.set_text)

        y= y-52

    end
end












local function Init()
    hooksecurefunc(SpellBookItemMixin, 'UpdateVisuals', function(frame)
        frame.Button.ActionBarHighlight:SetVertexColor(0,1,0)
        if (frame.spellBookItemInfo.itemType == Enum.SpellBookItemType.Flyout) then
            frame.Button.Arrow:SetVertexColor(1,0,1)
            frame.Button.Border:SetVertexColor(1,0,1)
        else
            frame.Button.Arrow:SetVertexColor(1,1,1)
            frame.Button.Border:SetVertexColor(1,1,1)
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