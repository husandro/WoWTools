--整合
local e= select(2, ...)

local function Save()
    return WoWTools_BankFrameMixin.Save
end




--设置，frame到最左边，为隐藏
local function BagFrame_SetPoint_ToLeft(bagFrame)
    if not bagFrame.set_point_toleft then
        if bagFrame.ResizeButton then
            bagFrame.ResizeButton:SetClampedToScreen(false)
        end
        function bagFrame:set_point_toleft()
            bagFrame:ClearAllPoints()
            bagFrame:SetPoint('RIGHT', UIParent, 'LEFT', -60, 0)            
            bagFrame:SetAlpha(0)
        end
        bagFrame:HookScript('OnEnter', bagFrame.set_point_toleft)
       
    end
    bagFrame:set_point_toleft()
end







 --索引，提示
 local function set_index_label(btn, index)
    if not btn.indexLable and Save().showIndex then
        btn.indexLable= WoWTools_LabelMixin:CreateLabel(btn, {layer='BACKGROUND', color={r=1,g=1,b=1}})
        btn.indexLable:SetPoint('CENTER')
        btn.indexLable:SetAlpha(0.2)
    end
    if btn.indexLable then
        btn.indexLable:SetText(Save().showIndex and index or '')
    end
end




local function IsValid_AccountBankPanel()
    return AccountBankPanel.selectedTabID and AccountBankPanel.selectedTabID>=0
end














local function Set_AccountBankPanel()
    if not AccountBankPanel.selectedTabID or AccountBankPanel.selectedTabID == -1 then
        return

    elseif BankFrame.activeTabIndex==3 then            
        AccountBankPanel:ClearAllPoints()
        AccountBankPanel:SetAllPoints()
        return
    end

    AccountBankPanel:ClearAllPoints()
    AccountBankPanel:SetPoint('TOPLEFT', BankFrame, 'TOPRIGHT')
    local numRows = Save().num
    local lastColumnStarterButton
    local lastCreatedButton
    local currentColumn = 1
    local x= Save().line

    local containerSlotID=0

    local tab={}
    for button in AccountBankPanel:EnumerateValidItems() do
        table.insert(tab, 1, button)
    end
    for _, button in pairs(tab) do
        containerSlotID= containerSlotID+1
        local isFirstButton = containerSlotID == 1
        local needNewColumn = (containerSlotID % numRows) == 1

        if isFirstButton then
            button:SetPoint("TOPLEFT", AccountBankPanel, "TOPLEFT", 8, -60)
            lastColumnStarterButton = button

        elseif needNewColumn then
            currentColumn = currentColumn + 1
            button:SetPoint("TOPLEFT", lastColumnStarterButton, "TOPRIGHT", x, 0)
            lastColumnStarterButton = button
        else
            button:SetPoint("TOPLEFT", lastCreatedButton, "BOTTOMLEFT", 0, -x)
        end
        lastCreatedButton = button
        set_index_label(button, button:GetContainerSlotID())--索引，提示
    end
    AccountBankPanel:SetSize(
        8+(currentColumn*37)+((currentColumn-1)*x)+8,
        36+(numRows*(37+x))+68
    )
end

















local function Init()
    local SetAllBank= CreateFrame('Frame', 'WoWTools_SetAllBankButton')

    --设置，银行，按钮
    if not BankSlotsFrame.IsCombinedBagContainer then
        function BankSlotsFrame:IsCombinedBagContainer()
            return false
        end
    end

    function SetAllBank:set_bank()
        self.last=nil--给材料包
        self.num=0
        local last

        local tab={}

--基础包
        for i=1, NUM_BANKGENERIC_SLOTS do--NUM_BANKGENERIC_SLOTS 28
            local btn= BankSlotsFrame["Item"..i]
            if btn then
                btn:ClearAllPoints()
                if not self.last then
                    btn:SetPoint('TOPLEFT', 8,-60)
                    self.last=btn
                    self.num= self.num+1
                    last=btn
                else
                    btn:SetPoint('TOP', last, 'BOTTOM', 0, -Save().line)
                    last=btn
                end
                btn.index=i
                set_index_label(btn, i)--索引，提示
                table.insert(tab, btn)
            end
        end

--背包
        local num=0
        local bagindex
        local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES--5+1

        for i=1, NUM_BANKBAGSLOTS do
            local bag= i+ numBag
            bagindex= bagindex and bagindex+1 or bag
            local bagFrame= _G['ContainerFrame'..bag]
            local bagID= bagFrame and bagFrame:GetID() or 0
            if bagFrame and bagID>= numBag then

                BagFrame_SetPoint_ToLeft(bagFrame)--设置，frame到最左边，为隐藏

                for _, btn in bagFrame:EnumerateValidItems()  do
                    if bagFrame:IsShown() then
                        num=num+1
                        btn:SetParent(BankSlotsFrame)
                        btn:ClearAllPoints()
                        btn:SetPoint('TOP', last, 'BOTTOM', 0, -Save().line)
                        last=btn
                        table.insert(tab, btn)
                        btn:SetShown(true)
                        set_index_label(btn, num+NUM_BANKGENERIC_SLOTS)--索引，提示
                    else
                        btn:SetShown(false)
                    end
                    
               end
            end
        end

        
        
        for i=Save().num+1, #tab, Save().num do--NUM_BANKGENERIC_SLOTS 28
            local btn= tab[i]
            if btn then
                btn:ClearAllPoints()
                btn:SetPoint('LEFT', self.last, 'RIGHT', Save().line, 0)
                self.last= btn
                self.num= self.num+1
            end
        end
      

        --材料包
        for i=1, NUM_BANKBAGSLOTS do--NUM_BANKBAGSLOTS 7
            local btn= BankSlotsFrame['Bag'..i]
            if btn then
                btn:ClearAllPoints()
                if i==1 then
                    btn:SetPoint('TOPLEFT', _G['BankFrameItem'..Save().num], 'BOTTOMLEFT', 0,-8)
                else
                    btn:SetPoint('LEFT', BankSlotsFrame['Bag'..(i-1)], 'RIGHT', Save().line, 0)        
                end
            end
        end
    end










    --设置，材料，按钮
    function SetAllBank:set_reagent(tabindex)
        if not IsReagentBankUnlocked() then
            return
        end
        if tabindex==2 then
            local slotOffsetX = 49;
            local slotOffsetY = 44;
            local index = 1;
            for column = 1, ReagentBankFrame.numColumn or 7 do
                local leftOffset = 6;
                for subColumn = 1, ReagentBankFrame.numSubColumn or 2 do
                    for row = 0, ReagentBankFrame.numRow-1 do
                        local button=ReagentBankFrame["Item"..index]
                        if button then
                            set_index_label(button, index)--索引，提示
                            button:ClearAllPoints()
                            button:SetPoint("TOPLEFT", ReagentBankFrame["BG"..column], "TOPLEFT", leftOffset, -(3+row*slotOffsetY));
                            index = index + 1;
                        end
                    end
                    leftOffset = leftOffset + slotOffsetX;
                end
            end
        else

            self.reagentNum= 0
            local btnNum=0
            for index, btn in ReagentBankFrame:EnumerateItems() do
                btn:ClearAllPoints()
                if index==1 then
                    btn:SetPoint('LEFT', self.last, 'RIGHT', Save().line+6, 0)
                    self.last=btn
                    self.reagentNum= self.reagentNum+1
                else
                    btn:SetPoint('TOP', ReagentBankFrame["Item"..(index-1)], 'BOTTOM', 0, -Save().line)
                end
                if not btn.Bg then
                    btn.Bg= btn:CreateTexture(nil, 'BACKGROUND')
                    btn.Bg:SetAllPoints(btn)
                    btn.Bg:SetAtlas('ChallengeMode-DungeonIconFrame')
                    btn.Bg:SetVertexColor(0,1,0)
                end
                set_index_label(btn, index)--索引，提示
                btnNum=index
            end
            for i=Save().num+1, btnNum, Save().num do
                local btn= ReagentBankFrame["Item"..i]
                btn:ClearAllPoints()
                btn:SetPoint('LEFT', self.last, 'RIGHT', Save().line, 0)
                self.last= btn
                self.reagentNum= self.reagentNum+1
            end 
        end
    end












--设置，外框，大小
    function SetAllBank:set_size(tabindex)
        if tabindex==1 then
            local num= SetAllBank.num + (SetAllBank.reagentNum or 0)
            BankFrame:SetSize(
                8+(num*37)+((num-1)*Save().line)+8+6,
                (Save().num+1)*37 +((Save().num-1)*Save().line)+64+8+6
            )
        end
    end







    function SetAllBank:settings(tabindex)--如果没有tabIndex，为设置，全部
        local index= tabindex or BankFrame.activeTabIndex
        if index==1 then
            
            do
                if IsReagentBankUnlocked() then
                    ReagentBankFrame:SetShown(true)
                end

                if IsValid_AccountBankPanel() then
                    AccountBankPanel:SetShown(true)
                end
            end
            do self:set_bank() end
            do self:set_reagent(1) end

        elseif index==2 then
            do self:set_reagent(2) end
        end
        SetAllBank:set_size(index)--设置，外框，大小
        if not tabindex then
            e.call(AccountBankPanel.GenerateItemSlotsForSelectedTab, AccountBankPanel)
        end
    end




    hooksecurefunc('BankFrame_ShowPanel', function()
        local index= BankFrame.activeTabIndex
        if index==1 then
            if IsReagentBankUnlocked() then
                ReagentBankFrame:SetShown(true)
            end
            if IsValid_AccountBankPanel() then
                AccountBankPanel:SetShown(true)
            end
            SetAllBank:settings(index)

        elseif index==2 then
            SetAllBank:settings(index)

        elseif index==3 then
            e.call(AccountBankPanel.GenerateItemSlotsForSelectedTab, AccountBankPanel)
        end
        
        --[[if not IsReagentBankUnlocked() and ReagentBankFrame.UnlockInfo then
            ReagentBankFrame.UnlockInfo:SetShown(BankFrame.activeTabIndex==2)
        end]]
    end)

    hooksecurefunc('BankFrameItemButtonBag_OnClick', function()
        SetAllBank:settings(BankFrame.activeTabIndex)
    end)

    BankFramePurchaseButton:SetWidth(BankFramePurchaseButton:GetFontString():GetWidth()+12)






--购买，背包栏
    hooksecurefunc('UpdateBagSlotStatus', function()
        if BankFramePurchaseInfo and BankFramePurchaseInfo:IsShown() then
            BankFramePurchaseInfo:ClearAllPoints()
            BankFramePurchaseInfo:SetPoint('Top', BankFrame, 'BOTTOM',0, -28)
            WoWTools_TextureMixin:CreateBackground(BankFramePurchaseInfo, {isAllPoint=true})
        end
        SetAllBank:settings(BankFrame.activeTabIndex)
    end)


    hooksecurefunc(AccountBankPanel, 'GenerateItemSlotsForSelectedTab', Set_AccountBankPanel)


    SetAllBank:set_bank()--设置，银行，按钮
end






































--整合
function WoWTools_BankFrameMixin:Init_Plus()
    Init()
end

