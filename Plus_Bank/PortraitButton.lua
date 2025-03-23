

local function Save()
    return WoWTools_BankMixin.Save
end






local function Init()
    local isReagentFrame = not Save().disabledBankBag
    local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES--5+1
    for index=1, NUM_BANKBAGSLOTS do
        local bag= index+ numBag
        local frame= _G['ContainerFrame'..bag]
        local btn= BankSlotsFrame['Bag'..index]
        if frame and btn then

            for _, button in frame:EnumerateValidItems()  do
                if button then
                    button:SetParent(isReagentFrame and BankSlotsFrame or frame)
                    button:SetShown(true)
                end
            end

            frame.PortraitButton:ClearAllPoints()

            if not isReagentFrame then
                function frame:bank_settings()
                end
                frame.PortraitButton:SetParent(frame)
                frame.PortraitButton:SetShown(true)
                frame:SetAlpha(1)
                if frame.ResizeButton then
                    frame.ResizeButton:SetClampedToScreen(true)
                end
                frame.PortraitButton:SetPoint('LEFT', frame.PortraitContainer.portrait, 'RIGHT', 2,0)
            else
                function frame:bank_settings()
                    self:ClearAllPoints()
                    self:SetPoint('RIGHT', UIParent, 'LEFT', -60, 0)
                    self:SetAlpha(0)
                    self.PortraitButton:SetShown(self:IsShown())
                end
                frame:SetParent(frame.BankSlotButton)
                if frame.ResizeButton then
                    frame.ResizeButton:SetClampedToScreen(false)
                end
                frame.PortraitButton:SetPoint('TOPLEFT', btn,-2,2)
            end


            if not frame.BankSlotButton then
                frame:HookScript('OnEnter', function(self)
                    self:bank_settings()
                end)
                frame:HookScript('OnShow', function(self)
                    self:bank_settings()
                end)
                frame:HookScript('OnHide', function(self)
                    self:bank_settings()
                end)


                btn.MatchesBagID= frame.PortraitButton:GetParent().MatchesBagID

                frame.BankSlotButton= btn

   
                frame.PortraitButton:SetSize(20,20)--37
                frame.PortraitButton:SetNormalAtlas(WoWTools_DataMixin.Icon.icon)
                frame.PortraitButton:SetPushedAtlas('bag-border-highlight')
                frame.PortraitButton:SetHighlightAtlas('bag-border')
                frame.PortraitButton:SetFrameLevel(btn:GetFrameLevel()+100)

                frame.FilterIcon.Icon:SetParent(frame.PortraitButton)
                frame.FilterIcon.Icon:ClearAllPoints()
                frame.FilterIcon.Icon:SetAllPoints()
            end

            frame:bank_settings()
        end
    end
end






function WoWTools_BankMixin:Set_PortraitButton()
    Init()
end