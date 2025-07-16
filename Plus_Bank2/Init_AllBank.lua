
if BankFrameTab2 then
    return
end
local function Save()
    return WoWToolsSave['Plus_Bank2']
end

--[[
self:GetActiveBankType() == Enum.BankType.Account

BankPanel.selectedTabID
    bankType
    purchasedBankTabData

BankPanel.itemButtonPool
    bankTabPool


BankPanel:GetActiveBankType()
    IsBankTypeLocked()
    RefreshBankPanel()
    GenerateItemSlotsForSelectedTab()

BankFrame:GetActiveBankType()
}
]]
local PURCHASE_TAB_ID= -1

local function GenerateItemSlotsForSelectedTab(self)
    self.itemButtonPool:ReleaseAll();

	if not self.selectedTabID or self.selectedTabID == PURCHASE_TAB_ID then
		return;
	end

    local line= Save().line or 2
    local num= Save().num or 15
    local last
    local x, y= 26, -63
    local index= 1
    for _, bankTabData in ipairs(self.purchasedBankTabData) do
        for containerSlotID = 1, C_Container.GetContainerNumSlots(bankTabData.ID) do
            local btn = self.itemButtonPool:Acquire()--37 x 37
            btn:SetPoint("TOPLEFT", self, "TOPLEFT", x, y)
            btn:Init(self.bankType, bankTabData.ID, containerSlotID)
            btn:Show()

            index= index+1
            if index>=num and select(2, math.modf(index/num))==0 then
                x= x+ 37 +line
                y= -63
            else
                y= (y-37)-line
            end
            
        end
    end

        --[[for containerSlotID = 1, C_Container.GetContainerNumSlots(self.selectedTabID) do
            local button = self.itemButtonPool:Acquire();
                
            local isFirstButton = containerSlotID == 1;

            local needNewColumn = (containerSlotID % numRows) == 1;

            if isFirstButton then
                local xOffset, yOffset = 26, -63;
                button:SetPoint("TOPLEFT", self, "TOPLEFT", currentColumn * xOffset, yOffset);
                lastColumnStarterButton = button;

            elseif needNewColumn then
                currentColumn = currentColumn + 1;

                local xOffset, yOffset = 8, 0;
                -- We reached the last subcolumn, time to add space for a new "big" column
                local startNewBigColumn = (currentColumn % numSubColumns == 1);
                if startNewBigColumn then
                    xOffset = 19;
                end
                button:SetPoint("TOPLEFT", lastColumnStarterButton, "TOPRIGHT", xOffset, yOffset);
                lastColumnStarterButton = button;
            else
                local xOffset, yOffset = 0, -10;
                button:SetPoint("TOPLEFT", lastCreatedButton, "BOTTOMLEFT", xOffset, yOffset);
            end
            
            button:Init(self.bankType, self.selectedTabID, containerSlotID);
            button:Show();

            lastCreatedButton = button;
        end]]
end






local function Init()
    if not Save().allBank then
        return
    end

--存放各种材料
    BankPanel.AutoDepositFrame.DepositButton:ClearAllPoints()
    BankPanel.AutoDepositFrame.DepositButton:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -6,0)
    BankPanel.AutoDepositFrame.DepositButton:SetSize(23, 23)
    BankPanel.AutoDepositFrame.DepositButton.Left:SetAlpha(0)
    BankPanel.AutoDepositFrame.DepositButton.Right:SetAlpha(0)
    BankPanel.AutoDepositFrame.DepositButton:HookScript('OnMouseUp', function(self)
        self:SetAlpha(1)
    end)
    BankPanel.AutoDepositFrame.DepositButton:HookScript('OnMouseDown', function(self)
        self:SetAlpha(0.5)
    end)
    hooksecurefunc(BankPanel.AutoDepositFrame.DepositButton, 'UpdateTextForBankType', function(self)
        self:SetText('')
    end)

    BankPanel.AutoDepositFrame.DepositButton:SetNormalAtlas('Professions_Tracking_Fish')
    BankPanel.AutoDepositFrame.DepositButton:SetScript('OnLeave', GameTooltip_Hide)
    BankPanel.AutoDepositFrame.DepositButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_TextMixin:CN(self:GetBestTextForBankType()))
        GameTooltip:Show()
    end)

--Check 包括可交易的材料
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:ClearAllPoints()
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetPoint('RIGHT', BankPanel.AutoDepositFrame.DepositButton, 'LEFT')
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetScript('OnLeave', GameTooltip_Hide)
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_TextMixin:CN(self.text))
        GameTooltip:Show()
    end)
    hooksecurefunc(BankPanel.AutoDepositFrame.IncludeReagentsCheckbox, 'Init', function(self)
        self.Text:SetText('')
    end)

--钱
    WoWTools_TextureMixin:CreateBG(BankPanel.MoneyFrame, {point=function(icon)
        icon:SetPoint('TOPLEFT', BankPanelGoldButtonText, -2, 2)
        icon:SetPoint('BOTTOMRIGHT', BankPanelCopperButtonText, 2, -2)
    end})
    BankPanel.MoneyFrame:ClearAllPoints()
    BankPanel.MoneyFrame:SetPoint('TOPRIGHT', BankPanel, 'BOTTOMRIGHT')

--整全一起
    BankPanel.GenerateItemSlotsForSelectedTab= GenerateItemSlotsForSelectedTab
    --hooksecurefunc(BankPanel, 'GenerateItemSlotsForSelectedTab', GenerateItemSlotsForSelectedTab)
    --BankPanelMixin:GenerateItemSlotsForSelectedTab()
    
    --BankFrame:UpdateWidthForSelectedTab()




    Init=function()
        if Save().allBank then
            BankPanel.GenerateItemSlotsForSelectedTab= GenerateItemSlotsForSelectedTab
        else
            BankPanel.GenerateItemSlotsForSelectedTab= BankPanelMixin.GenerateItemSlotsForSelectedTab
        end
        --WoWTools_Mixin:Call(BankFrame, 'UpdateWidthForSelectedTab', BankFrame)
        BankPanel:GenerateItemSlotsForSelectedTab()
    end
end






local function Init_Move()
    BankPanel:SetPoint('TOPRIGHT')
    BankPanel:SetPoint('BOTTOMRIGHT')

    WoWTools_MoveMixin:Setup(BankFrame, {
        setSize=true, minW=80, minH=140,
    sizeUpdateFunc= function()
        local h= math.ceil((BankFrame:GetHeight()-108)/(Save().line+37))
        Save().num= h
        BankPanel:GenerateItemSlotsForSelectedTab()
        --Init()
    end, sizeRestFunc= function()
        Save().num=15
        Init()
        BankFrame:Hide()
        --BankFrame:SetSize(738, 460)
    end, sizeStopFunc= function()
        --Init()
    end})
    WoWTools_MoveMixin:Setup(BankPanel.TabSettingsMenu, {frame=BankFrame})
    WoWTools_MoveMixin:Setup(BankCleanUpConfirmationPopup)
    
    BankFrame.ResizeButton.setSize= Save().allBank
    Init_Move=function()
        BankFrame.ResizeButton.setSize= Save().allBank
    end
end




--移动，银行
function WoWTools_MoveMixin.Frames:BankFrame()
    Init_Move()
end

function WoWTools_BankMixin:Init_AllBank()
    Init()
    Init_Move()
end
