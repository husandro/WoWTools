--整合
local e= select(2, ...)

local function Save()
    return WoWTools_BankMixin.Save
end


local LastButton
local NumLeftButton=0
local NumReagentLeftButton=0
local NumAccountLeftButton=0



local function Set_Frame_Size(index)
    if index==1 then
        local line= Save().line
        local x= NumLeftButton + NumReagentLeftButton+ NumAccountLeftButton
        local y = Save().num

        BankFrame:SetSize(
            x*(37+line) + 14,

            y*(37+line) + 108
        )
    else
        BankFrame:SetSize(738, 460)
    end
end








 --索引，提示
 local function Set_IndexLabel(btn, index)
    if not btn.indexLable and Save().showIndex then
        btn.indexLable= WoWTools_LabelMixin:Create(btn, {layer='BACKGROUND', color={r=1,g=1,b=1}})
        btn.indexLable:SetPoint('CENTER')
        btn.indexLable:SetAlpha(0.2)
    end
    if btn.indexLable then
        btn.indexLable:SetText(Save().showIndex and index or '')
    end
end














local function Set_BankSlotsFrame(index)
    if index~=1 then
        return
    end

    local tab={}

--基础包
    for i=1, NUM_BANKGENERIC_SLOTS do--28
        local btn= BankSlotsFrame["Item"..i]
        if btn then
            btn.index=i
            Set_IndexLabel(btn, i)--索引，提示
            table.insert(tab, btn)
        end
    end

--背包
    if not Save().disabledBankBag then
        local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES--5+1
        for i=1, NUM_BANKBAGSLOTS do
            local frame= _G['ContainerFrame'..(i+numBag)]
            if frame then
                local isShow= frame:IsShown()
                frame:bank_settings()
                for _, btn in frame:EnumerateValidItems()  do
                    if btn then
                        if isShow then
                            table.insert(tab, btn)
                        end
                        btn:SetShown(isShow)
                    end
                end
            end
        end
    end

    LastButton= tab[1]
    LastButton:ClearAllPoints()
    LastButton:SetPoint('TOPLEFT', 8, -60)
    NumLeftButton= 1
    Set_IndexLabel(LastButton, 1)--索引，提示

    local line= Save().line
    local num= Save().num

    for i=2, #tab, 1 do
        local btn= tab[i]
        btn:ClearAllPoints()
        if select(2, math.modf((i-1)/num))==0 then
            btn:SetPoint('LEFT', LastButton, 'RIGHT', line, 0)
            LastButton= btn
            NumLeftButton= NumLeftButton+1
        else
            btn:SetPoint('TOP', tab[i-1], 'BOTTOM', 0, -line)
        end
        Set_IndexLabel(btn, i)--索引，提示
    end
end












local function Set_BankReagent(tabIndex)
    if not IsReagentBankUnlocked() or tabIndex>2 then
        return
    end


    if tabIndex==2 then
        local slotOffsetX = 49;
        local slotOffsetY = 44;
        local index = 1;
        for column = 1, ReagentBankFrame.numColumn or 7 do
            local leftOffset = 6;
            for subColumn = 1, ReagentBankFrame.numSubColumn or 2 do
                for row = 0, ReagentBankFrame.numRow-1 do
                    local button=ReagentBankFrame["Item"..index]
                    if button then
                        Set_IndexLabel(button, index)--索引，提示
                        button:ClearAllPoints()
                        button:SetPoint("TOPLEFT", ReagentBankFrame["BG"..column], "TOPLEFT", leftOffset, -(3+row*slotOffsetY));
                        index = index + 1;
                    end
                end
                leftOffset = leftOffset + slotOffsetX;
            end
        end

    elseif tabIndex==1 and not Save().disabledReagentFrame then--1

        do ReagentBankFrame:SetShown(true) end

        local line= Save().line
        local num= Save().num

        local last
        for index, btn in ReagentBankFrame:EnumerateItems() do
            btn:ClearAllPoints()
            if select(2, math.modf((index-1)/num))==0 then
                btn:SetPoint('LEFT', LastButton, 'RIGHT', line, 0)
                LastButton= btn
                NumReagentLeftButton= NumReagentLeftButton+1
            else
                btn:SetPoint('TOP', last, 'BOTTOM', 0, -line)
            end

            last= btn
            Set_IndexLabel(btn, index)--索引，提示
        end
    end
end






--C_Bank.CanPurchaseBankTab(Enum.BankType.Account)
--AccountBankPanel.PurchaseTab:IsSelected() and C_Bank.CanPurchaseBankTab(2)
--AccountBankPanel.PurchaseTab:IsPurchaseTab()
local function Set_AccountBankPanel(index)
    if Save().disabledAccountBag or AccountBankPanel.PurchaseTab:IsPurchaseTab() then
        return
    end

    do AccountBankPanel:SetShown(index==1 or index==3) end

    if index==1 then
        local line= Save().line
        local num= Save().num
        local i=1
        local last

        for btn in AccountBankPanel:EnumerateValidItems() do
            btn:ClearAllPoints()
            if select(2, math.modf((i-1)/num))==0 then
                btn:SetPoint('LEFT', LastButton, 'RIGHT', line, 0)
                LastButton= btn
                NumAccountLeftButton= NumAccountLeftButton+1
            else
                btn:SetPoint('TOP', last, 'BOTTOM', 0, -line)
            end
            last= btn
            Set_IndexLabel(btn, i)--索引，提示
            i=i+1
        end

    elseif index==3 then
        AccountBankPanel:GenerateItemSlotsForSelectedTab()
    end
end








local function Set_PortraitButton()
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
                function frame:bank_settings() end
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
                frame.PortraitButton:SetNormalAtlas(e.Icon.icon)
                frame.PortraitButton:SetPushedAtlas('bag-border-highlight')
                frame.PortraitButton:SetHighlightAtlas('bag-border')

                frame.FilterIcon.Icon:SetParent(frame.PortraitButton)
                frame.FilterIcon.Icon:ClearAllPoints()
                frame.FilterIcon.Icon:SetAllPoints()
            end

            frame:bank_settings()
        end
    end
end



local function Settings()
    NumReagentLeftButton= 0
    NumAccountLeftButton= 0
    local index= BankFrame.activeTabIndex or 1
    do Set_BankSlotsFrame(index) end
    do Set_BankReagent(index) end
    do Set_AccountBankPanel(index) end
    Set_Frame_Size(index)
end





local function Init()

--背包，需要这个函数 ContainerFrame7 - 13 <Frame name="ContainerFrame7" inherits="ContainerFrameBankTemplate"/>
    function BankSlotsFrame:IsCombinedBagContainer()
        return false
    end

    hooksecurefunc('BankFrame_ShowPanel', Settings)
    hooksecurefunc('BankFrameItemButtonBag_OnClick', Settings)
    hooksecurefunc(BankPanelTabMixin, 'OnClick', Settings)

    hooksecurefunc('BankFrameItemButton_Update', function(self)
        if self.isBag and self.set_point_toleft then
            C_Timer.After(0.3, self.set_point_toleft)
        end
    end)

--背包位
    for index=1, NUM_BANKBAGSLOTS do--NUM_BANKBAGSLOTS 7
        local btn= BankSlotsFrame['Bag'..index]
        if btn then
            btn:ClearAllPoints()
            if index==1 then
                --btn:SetPoint('TOPLEFT', _G['BankFrameItem'..Save().num], 'BOTTOMLEFT', 0,-8)
                btn:SetPoint('BOTTOMLEFT',6,6)
            else
                btn:SetPoint('LEFT', BankSlotsFrame['Bag'..(index-1)], 'RIGHT', Save().line, 0)
            end
        end
    end


--购买，背包栏
    BankFramePurchaseInfo:ClearAllPoints()
    BankFramePurchaseInfo:SetPoint('TOP', BankFrame, 'BOTTOM',0, -28)
    WoWTools_TextureMixin:CreateBackground(BankFramePurchaseInfo, {isAllPoint=true})

    return true
end








--整合
function WoWTools_BankMixin:Init_Plus()
    Set_PortraitButton()
    if Init() then
        Init= function() end
    else
        Settings('init')
    end
end
