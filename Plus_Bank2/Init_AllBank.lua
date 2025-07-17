
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

    self.itemButtonPool:ReleaseAll()

	if not self.selectedTabID or self.selectedTabID == PURCHASE_TAB_ID then
		return;
	end


    local line= Save().line or 2
    local num= Save().num or 15
    local x, y= 26, -63
    local index=0
    local numWidth= 0
    local indexTab= 0
    local isAccount= self:GetActiveBankType() == Enum.BankType.Account

    for _, bankTabData in ipairs(self.purchasedBankTabData) do
        local numSlot= C_Container.GetContainerNumSlots(bankTabData.ID)
        for containerSlotID = 1, numSlot do
--新建
            local btn = self.itemButtonPool:Acquire()--37 x 37
            btn:SetPoint("TOPLEFT", self, "TOPLEFT", x, y)
            btn:Init(self.bankType, bankTabData.ID, containerSlotID)
            btn:Show()
--Tab名称 和 空格
            if containerSlotID==1 and y==-63 then
                indexTab= indexTab+1
                if not self.tabNames[indexTab] then
                    self.tabNames[indexTab]= WoWTools_LabelMixin:Create(self)
                end
                self.tabNames[indexTab]:SetPoint('BOTTOMLEFT', btn, 'TOPLEFT')
                self.tabNames[indexTab]:SetText(
                    '|T'..(bankTabData.icon or 0)..':0|t'
                    ..(bankTabData.name or '')
                    ..'|cnGREEN_FONT_COLOR:'
                    ..(C_Container.GetContainerNumFreeSlots(bankTabData.ID) or '')
                )
                if isAccount then
                    self.tabNames[indexTab]:SetTextColor(0,0.8,1)
                else
                    self.tabNames[indexTab]:SetTextColor(1,0.5,0)
                end
            end
--x,y
            index= index+1
            if select(2, math.modf(index/num))==0 or containerSlotID==numSlot then
                x= x+ 37 +line
                y= -63
                numWidth= numWidth+1
            else
                y= (y-37)-line
            end
        end
        index= 0
    end

--清除，其它
    for i= indexTab+1, #self.tabNames do
        if self.tabNames[i] then
            self.tabNames[i]:SetText('')
        end
    end

--设置大小
    BankFrame:SetSize(
        52+(37+line)*numWidth,
        63+(37+line)*num+26-line
    )
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
    BankPanel.MoneyFrame:SetPoint('BOTTOM', 0, 1)
    --BankPanel.MoneyFrame:SetPoint('TOPRIGHT', BankPanel, 'BOTTOMRIGHT')

--整全一起
    BankPanel.tabNames= {}
    BankPanel.GenerateItemSlotsForSelectedTab= GenerateItemSlotsForSelectedTab
    BankPanel:HookScript('OnEvent', function(self, event, ...)
        if not Save().plus then
            return
        end
        if event=='ITEM_LOCK_CHANGED' then
            local bankTabID, containerSlotID= ...
            if bankTabID ~= self:GetSelectedTabID() then
                for itemButton in self:EnumerateValidItems() do
                    if itemButton:GetContainerSlotID() == containerSlotID
                        and itemButton:GetBankTabID()== bankTabID
                    then
                        itemButton:Refresh()
                        return
                    end
                end
            end
        elseif event== 'BAG_UPDATE' then
            local containerID = ...
            if self.selectedTabID ~= containerID and self:GetTabData(containerID) then
               self:MarkDirty()
            end
        end
    end)
    hooksecurefunc(BankPanel, 'RefreshHeaderText', function(self)
        if Save().allBank then
            self.Header.Text:SetText('')
        end
    end)

    --hooksecurefunc(BankPanel, 'GenerateItemSlotsForSelectedTab', GenerateItemSlotsForSelectedTab)
    --BankPanelMixin:GenerateItemSlotsForSelectedTab()
    --BankFrame:UpdateWidthForSelectedTab()




    Init=function()
        if Save().allBank then
            BankPanel.GenerateItemSlotsForSelectedTab= GenerateItemSlotsForSelectedTab
        else
            BankPanel.GenerateItemSlotsForSelectedTab= BankPanelMixin.GenerateItemSlotsForSelectedTab
            BankFrame:SetSize(738, 460)
            for _, label in pairs(BankPanel.tabNames) do
                label:SetText('')
            end
        end
        --WoWTools_Mixin:Call(BankFrame, 'UpdateWidthForSelectedTab', BankFrame)
        BankPanel:RefreshBankPanel()
    end
end






local function Init_Move()
    BankPanel:SetPoint('TOPRIGHT')
    BankPanel:SetPoint('BOTTOMRIGHT')

    WoWTools_MoveMixin:Setup(BankFrame, {
        setSize=true, minW=80, minH=140,
    sizeUpdateFunc= function()

        --Init()
    end, sizeRestFunc= function()
        Save().num=15
        --BankFrame:SetSize(738, 460)
        BankPanel:GenerateItemSlotsForSelectedTab()
    end, sizeStopFunc= function()
        local line= Save().line
        local h= math.ceil((BankFrame:GetHeight()+line-63-26)/(37+line))
        Save().num= h
        BankPanel:GenerateItemSlotsForSelectedTab()
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
