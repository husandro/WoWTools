local e= select(2, ...)
local addName
local function Save()
    return WoWTools_GossipMixin.Save
end





local SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING= SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING
--Blizzard_PlayerChoice
local function Init()
    --命运, 字符
    hooksecurefunc(StaticPopupDialogs["CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING"], "OnShow",function(s)
        if Save().gossip and s.editBox then
            s.editBox:SetText(SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING)
        end
    end)


    --自动选择奖励 Blizzard_PlayerChoice.lua
    local function Send_Player_Choice_Response(optionInfo)
        if optionInfo then
            C_PlayerChoice.SendPlayerChoiceResponse(optionInfo.buttons[1].id)
            print(e.Icon.icon2..(optionInfo.spellID and C_Spell.GetSpellLink(optionInfo.spellID) or ''),
                '|n',
                '|T'..(optionInfo.choiceArtID or 0)..':0|t'..optionInfo.rarityColor:WrapTextInColorCode(optionInfo.description or '')
            )
            PlayerChoiceFrame:OnSelectionMade()
            C_PlayerChoice.OnUIClosed()
            for optionFrame in PlayerChoiceFrame.optionPools:EnumerateActiveByTemplate(PlayerChoiceFrame.optionFrameTemplate) do
                optionFrame:SetShown(false)
            end
        end
    end
    hooksecurefunc(PlayerChoiceFrame, 'SetupOptions', function(frame)
        if IsModifierKeyDown() or not Save().gossip then
            return
        end

        local tab={}
        local soloOption = (#frame.choiceInfo.options == 1)
        for optionFrame in frame.optionPools:EnumerateActiveByTemplate(frame.optionFrameTemplate) do
            if optionFrame.optionInfo then
                local enabled= not optionFrame.optionInfo.disabledOption and optionFrame.optionInfo.spellID and optionFrame.optionInfo.spellID>0
                if not optionFrame.check and enabled then
                    optionFrame.check= CreateFrame("CheckButton", nil, optionFrame, "InterfaceOptionsCheckButtonTemplate")
                    optionFrame.check:SetPoint('BOTTOM' ,0, -40)
                    optionFrame.check:SetScript('OnClick', function(self3)
                        local optionInfo= self3:GetParent().optionInfo
                        if optionInfo and optionInfo.spellID then
                            Save().choice[optionInfo.spellID]= not Save().choice[optionInfo.spellID] and (optionInfo.rarity or 0) or nil
                            if Save().choice[optionInfo.spellID] then
                                Send_Player_Choice_Response(optionInfo)
                            end
                        else
                            print(e.addName, addName,'|cnRED_FONT_COLOR:', not e.onlyChinese and ERRORS..' ('..UNKNOWN..')' or '未知错误')
                        end
                    end)
                    optionFrame.check:SetScript('OnLeave', GameTooltip_Hide)
                    optionFrame.check:SetScript('OnEnter', function(self3)
                        local optionInfo= self3:GetParent().optionInfo
                        e.tips:SetOwner(self3:GetParent(), "ANCHOR_BOTTOMRIGHT")
                        e.tips:ClearLines()
                        if optionInfo and optionInfo.spellID then
                            e.tips:SetSpellByID(optionInfo.spellID)
                        end
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(e.addName, addName)
                        e.tips:Show()
                    end)
                    --[[optionFrame.check.Text2=WoWTools_LabelMixin:Create(optionFrame.check)
                    optionFrame.check.Text2:SetPoint('RIGHT', optionFrame.check, 'LEFT')
                    optionFrame.check.Text2:SetTextColor(0,1,0)
                    optionFrame.check:SetScript('OnUpdate', function(self3, elapsed)
                        self3.elapsed = (self3.elapsed or 1) + elapsed
                        if self3.elapsed>=1 then
                            local text, count
                            local aura= self3.spellID and C_UnitAuras.GetPlayerAuraBySpellID(self3.spellID)
                            if aura then
                                local value= aura.expirationTime-aura.duration
                                local time= GetTime()
                                time= time < value and time + 86400 or time
                                time= time - value
                                text= WoWTools_TimeMixin:SecondsToClock(aura.duration- time)
                                count= select(3, WoWTools_AuraMixin:Get('player', self3.spellID, 'HELPFUL'))
                                count= count and count>1 and count or nil
                            end
                            self3.Text:SetText(text or '')
                            self3.Text2:SetText(count or '')
                            self3.elapsed=0
                        end
                    end)]]
                end

                if optionFrame.check then
                    optionFrame.check.elapsed=1.1
                    optionFrame.check.spellID= optionFrame.optionInfo.spellID
                    optionFrame.check:SetShown(enabled)
                    if enabled then
                        local saveChecked= Save().choice[optionFrame.optionInfo.spellID]
                        optionFrame.check:SetChecked(saveChecked)
                        if saveChecked or (soloOption and Save().unique) then
                            optionFrame.optionInfo.rarity = optionFrame.optionInfo.rarity or 0
                            table.insert(tab, optionFrame.optionInfo)
                        end
                    end
                end
            end
        end
        if #tab>0 then
            table.sort(tab, function(a,b)
                if a.rarity== b.rarity then
                    return a.spellID> b.spellID
                else
                    return a.rarity> b.rarity
                end
            end)
            Send_Player_Choice_Response(tab[1])
        end
    end)

    hooksecurefunc(PlayerChoiceNormalOptionTemplateMixin,'SetupButtons', function(frame)
        local info2= frame.optionInfo or {}
        if not info2.disabledOption and info2.buttons
            and info2.buttons[2] and info2.buttons[2].id
        then
            if not PlayerChoiceFrame.allButton then
                PlayerChoiceFrame.allButton= WoWTools_ButtonMixin:Cbtn(PlayerChoiceFrame, {size={60,22}, type=false, icon='hide'})
                PlayerChoiceFrame.allButton:SetPoint('BOTTOMRIGHT')
                PlayerChoiceFrame.allButton:SetFrameStrata('DIALOG')
                PlayerChoiceFrame.allButton:SetScript('OnLeave', GameTooltip_Hide)
                PlayerChoiceFrame.allButton:SetScript('OnEnter', function(s)
                    e.tips:SetOwner(s, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(e.addName , addName)
                    e.tips:AddLine(' ')
                    e.tips:AddLine(s.tips or (e.onlyChinese and '使用' or USE))
                    e.tips:AddDoubleLine(' ', format(e.onlyChinese and '%d次' or ITEM_SPELL_CHARGES, 44)..e.Icon.left)
                    e.tips:AddDoubleLine(' ', format(e.onlyChinese and '%d次' or ITEM_SPELL_CHARGES, 100)..e.Icon.right)
                    e.tips:AddDoubleLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '停止' or SLASH_STOPWATCH_PARAM_STOP1), 'Alt')
                    e.tips:Show()
                end)
                PlayerChoiceFrame.allButton:SetScript('OnHide', function(s)
                    if s.time and not s.time:IsCancelled() then
                        s.time:Cancel()
                    end
                end)
                function PlayerChoiceFrame.allButton:set_text()
                    self:SetText(
                        (not self.time or self.time:IsCancelled()) and (e.onlyChinese and '全部' or ALL)
                        or (e.onlyChinese and '停止' or SLASH_STOPWATCH_PARAM_STOP1)
                    )
                end
                PlayerChoiceFrame.allButton:SetScript('OnClick', function(s, d)
                    if s.time and not s.time:IsCancelled() then
                        s.time:Cancel()
                        s:set_text()
                        print(e.addName,addName,'|cnRED_FONT_COLOR:', e.onlyChinese and '停止' or SLASH_STOPWATCH_PARAM_STOP1)
                        return
                    else
                        s:set_text()
                    end
                    local n= 0
                    local all= d=='LeftButton' and 43 or 100

                    if s.buttonID then
                        C_PlayerChoice.SendPlayerChoiceResponse(s.buttonID)
                    end
                    s.time=C_Timer.NewTicker(0.65, function()
                        local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo() or {}
                        local info= choiceInfo.options and choiceInfo.options[1] or {}
                        if info
                            and not info.disabledOption
                            and info.buttons
                            and info.buttons[2]

                            and info.buttons[2].id
                            and not info.buttons[2].disabled
                            and not IsModifierKeyDown()
                            and s:IsEnabled()
                            and s:IsShown()
                        then
                            C_PlayerChoice.SendPlayerChoiceResponse(info.buttons[2].id)--Blizzard_PlayerChoiceOptionBase.lua
                            n=n+1
                            print(e.addName, addName, '|cnGREEN_FONT_COLOR:'..n..'|r', '('..all-n..')', '|cnRED_FONT_COLOR:Alt' )
                            --self.parentOption:OnSelected()
                        elseif s.time then
                        s.time:Cancel()
                        print(e.addName,addName,'|cnRED_FONT_COLOR:', e.onlyChinese and '停止' or SLASH_STOPWATCH_PARAM_STOP1, '|r'..n)
                        end
                        s:set_text()
                    end, all)
                end)
            end
            PlayerChoiceFrame.allButton.buttonID= info2.buttons[2].id
            PlayerChoiceFrame.allButton.tips=info2.buttons[2].text
            PlayerChoiceFrame.allButton.disabled= info2.buttons[2].disabled
            PlayerChoiceFrame.allButton:SetEnabled(not info2.buttons[2].disabled and true or false)
            PlayerChoiceFrame.allButton:set_text()
            PlayerChoiceFrame.allButton:SetShown(true)
        elseif PlayerChoiceFrame.allButton then
            PlayerChoiceFrame.allButton:SetShown(false)
        end
    end)




    --PlayerChoiceGenericPowerChoiceOptionTemplat
    hooksecurefunc(PlayerChoicePowerChoiceTemplateMixin, 'Setup', function(frame)
        if frame.settings then
            frame:settings()
            return
        end

        function frame:settings()
            local text, charges, applications
            local data= frame.optionInfo
            if data and data.spellID then
                local info= C_UnitAuras.GetPlayerAuraBySpellID(data.spellID)
                if info then
                    applications= info.applications
                    if info.expirationTime then
                        text= WoWTools_TimeMixin:Info(nil, false, nil, info.expirationTime)
                        applications= applications==0 and 1 or applications
                    end
                    if info.charges then
                        charges=info.charges
                        if info.maxCharges then
                            if info.charges==info.maxCharges then
                                charges= '|cnRED_FONT_COLOR:'..charges..'/'..info.maxCharges..'|r'
                            else
                                charges= charges..'/|cnRED_FONT_COLOR:'..info.maxCharges..'|r'
                            end
                        end
                    end
                end
                text= text or (e.onlyChinese and '无' or NONE)
            end
            frame.TimeText:SetText(text or '')
            frame.ChargeText:SetText(charges or '')
            frame.ApplicationsText:SetText(applications or '')

            frame.frameTips:SetShown(data.spellID)
        end

        frame.TimeText= WoWTools_LabelMixin:Create(frame, {color={r=0, g=1, b=0}, size=18})
        frame.TimeText:SetPoint('TOP', frame.Artwork, 'BOTTOM', 0, -4)
        frame.ChargeText= WoWTools_LabelMixin:Create(frame,  {color={r=0, g=1, b=0}, size=18})
        frame.ChargeText:SetPoint('CENTER', frame.Artwork, 0, 0)
        frame.ApplicationsText= WoWTools_LabelMixin:Create(frame, {color={r=1, g=1, b=1}, size=22})
        frame.ApplicationsText:SetPoint('BOTTOMRIGHT', frame.Artwork, -6, 6)

        frame.frameTips= CreateFrame('Frame', nil, frame)
        frame.frameTips:SetPoint('TOPLEFT')
        frame.frameTips:SetSize(1,1)
        frame.frameTips:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= (self.elapsed or 2)+ elapsed
            if self.elapsed<1 then
                return
            end
            self.elapsed= 0
            self:GetParent():settings()
        end)
        frame:SetScript('OnHide',function(self)
            self.frameTips:SetShown(false)
            self.elapsed=nil
        end)

        frame:settings()
    end)


end















function WoWTools_GossipMixin:Init_PlayerChoice()
    Init()
    addName= self.addName
end