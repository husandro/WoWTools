local function Save()
    return WoWToolsSave['Plus_Bank2']
end

local PURCHASE_TAB_ID= -1
local BODER_LEFT= 3

local function Set_TabInfoText(label, tabData, isName)
    label:SetText(
        '|T'..(tabData.icon or 0)..':0|t'
        ..(isName and tabData.name and tabData.name..' ' or '')
        ..(WoWTools_BankMixin:GetFlagsText(tabData.depositFlags, false) or '')
        ..'|cnGREEN_FONT_COLOR:'
        ..(C_Container.GetContainerNumFreeSlots(tabData.ID) or '')
    )
end

local function Set_Tab_Label_OnEnter(self, tabID)
    if tabID and tabID~=-1 then
        WoWTools_BankMixin:AddBankTabSettingsToTooltip(self, BankPanel:GetTabData(tabID))
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.left
            ..'|cnGREEN_FONT_COLOR:<'
            ..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)
            ..'>|A:dressingroom-button-appearancelist-up:0:0|a'
        )
        GameTooltip:Show()
        --SetCursor('Interface\\CURSOR\\openhand')
    end
    self:SetAlpha(0.5)
end








local function Init()
    --BankPanel 标题
    BankPanel.Header.Text:SetShadowOffset(1, -1)

--替换，原生
    function BankPanel:RefreshHeaderText()
        if Save().allBank then
            self.Header.Text:SetText('')
        else
            Set_TabInfoText(self.Header.Text, self:GetTabData(self.selectedTabID), true)

            if self:GetActiveBankType() == Enum.BankType.Account then
                self.Header.Text:SetTextColor(0,0.8,1)
            else
                self.Header.Text:SetTextColor(1,0.5,0)
            end
        end
    end

--提取，菜单
    BankPanel.Header.Text:EnableMouse(true)
    BankPanel.Header.Text:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
    end)
    BankPanel.Header.Text:SetScript('OnEnter', function(self)
        WoWTools_BankMixin:AddBankTabSettingsToTooltip(self, BankPanel:GetSelectedTabData())
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.left
            ..'|cnGREEN_FONT_COLOR:<'
            ..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)
            ..'>|A:dressingroom-button-appearancelist-up:0:0|a'
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    BankPanel.Header.Text:SetScript('OnMouseUp', function(self)
        self:SetAlpha(0.5)
    end)
    BankPanel.Header.Text:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            MenuUtil.CreateContextMenu(self:GetParent(), function(_, root)
                WoWTools_BankMixin:Init_Out_Menu(root, BankPanel:GetSelectedTabData())
            end)
        else
            local tabID= BankPanel:GetSelectedTabID()
            for btn in BankPanel.bankTabPool:EnumerateActive() do
                if btn.tabData and btn.tabData.ID==tabID then
                    btn:OnClick(d)
                    break
                end
            end
        end
        self:SetAlpha(0.3)
    end)



    Init=function()end
end








local function Init_UI()
    if not Save().allBank then
        return
    end

--新建，标签，提示
    BankPanel.tabNames= {}
--更新，信息
    hooksecurefunc(BankPanel.TabSettingsMenu, 'OkayButton_OnClick', function()
        if not Save().allBank then
            return
        end
        C_Timer.After(0.7, function()
            for _, lable in pairs(BankPanel.tabNames) do
                local btn= select(2, lable:GetPoint(1))
                local tabID= btn and btn:GetBankTabID()
                local tabData= tabID and BankPanel:GetTabData(tabID)
                if tabData then
                    Set_TabInfoText(lable, tabData)
                end
            end
        end)
    end)

--SearchBox
    BankItemSearchBox:ClearAllPoints()
    BankItemSearchBox:SetPoint('TOPRIGHT', -56, -25)--<Anchor point="TOPRIGHT" x="-56" y="-33"/>

--存放各种材料
    BankPanel.AutoDepositFrame:ClearAllPoints()
    BankPanel.AutoDepositFrame:SetWidth(47)
    BankPanel.AutoDepositFrame:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -42,0)

    BankPanel.AutoDepositFrame.DepositButton:ClearAllPoints()
    BankPanel.AutoDepositFrame.DepositButton:SetPoint('RIGHT')
    BankPanel.AutoDepositFrame.DepositButton:SetSize(23, 23)
    BankPanel.AutoDepositFrame.DepositButton.Left:SetAlpha(0)
    BankPanel.AutoDepositFrame.DepositButton.Right:SetAlpha(0)
    BankPanel.AutoDepositFrame.DepositButton:HookScript('OnMouseUp', function(self)
        self:SetAlpha(1)
    end)
    BankPanel.AutoDepositFrame.DepositButton:HookScript('OnMouseDown', function(self)
        self:SetAlpha(0.5)
    end)

    BankPanel.AutoDepositFrame.DepositButton:SetText('')
--替换，原生
    function BankPanel.AutoDepositFrame.DepositButton:UpdateTextForBankType()
        self:SetNormalAtlas(self:GetActiveBankType() == Enum.BankType.Account
            and 'quest-important-available'
            or 'Professions_Tracking_Fish'
        )
    end
    BankPanel.AutoDepositFrame.DepositButton:SetScript('OnLeave', GameTooltip_Hide)
    BankPanel.AutoDepositFrame.DepositButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_TextMixin:CN(self:GetBestTextForBankType()))
        GameTooltip:Show()
    end)

--Check 包括可交易的材料
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:ClearAllPoints()--24,23
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetPoint('RIGHT', BankPanel.AutoDepositFrame.DepositButton, 'LEFT')
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetScript('OnLeave', GameTooltip_Hide)
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_TextMixin:CN(self.text))
        GameTooltip:Show()
    end)

    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox.Text:ClearAllPoints()
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox.Text:SetAlpha(0)
    --[[hooksecurefunc(BankPanel.AutoDepositFrame.IncludeReagentsCheckbox, 'Init', function(self)
        self.Text:SetText('')
    end)]]

--钱
    WoWTools_TextureMixin:CreateBG(BankPanel.MoneyFrame, {point=function(icon)
        icon:SetPoint('TOPLEFT', BankPanelGoldButtonText, -2, 2)
        icon:SetPoint('BOTTOMRIGHT', BankPanelCopperButtonText, 2, -2)
    end, isColor=true})
    local function Set_Money_Point()
        BankPanel.MoneyFrame:ClearAllPoints()
        if Save().allBank then
            BankPanel.MoneyFrame:SetPoint('RIGHT', BankPanel.AutoDepositFrame.IncludeReagentsCheckbox, 'LEFT', -8, 0)
        else
            BankPanel.MoneyFrame:SetPoint('BOTTOMRIGHT', -3, 3)
        end
    end
    Set_Money_Point()

    Init_UI=function()
        Set_Money_Point()
    end
end










local function Create_Tab_Label(frame, indexTab)
    if frame.tabNames[indexTab] then
        return
    end

    frame.tabNames[indexTab]= WoWTools_LabelMixin:Create(BankFrame.TitleContainer, {muose=true})
    frame.tabNames[indexTab]:SetScript('OnLeave', function(f)
        GameTooltip:Hide()
        --ResetCursor()
        f:SetAlpha(1)
    end)

    frame.tabNames[indexTab]:SetScript('OnEnter', function(self)
        local tabID= select(2, self:GetPoint(1)):GetBankTabID()
        Set_Tab_Label_OnEnter(self, tabID)
    end)
    frame.tabNames[indexTab]:SetScript('OnMouseUp', function(f)
        f:SetAlpha(0.5)
    end)

    frame.tabNames[indexTab]:SetScript('OnMouseDown', function(self, d)
        local tabID= select(2, self:GetPoint(1)):GetBankTabID()
        local tabData= tabID and BankPanel:GetTabData(tabID)
        if not tabData or not tabData.ID or tabData.ID==-1 then
            return
        end
--提取
        if d=='LeftButton' then
            MenuUtil.CreateContextMenu(frame, function(_, root)
                WoWTools_BankMixin:Init_Out_Menu(root, tabData)
            end)
            Set_Tab_Label_OnEnter(self, tabID)
        else
--设置
           for btn in BankPanel.bankTabPool:EnumerateActive() do
                if btn.tabData and btn.tabData.ID==tabID then
                    btn:OnClick(d)
                    break
                end
           end
        end
        self:SetAlpha(0.3)
    end)

end




--整全一起
local function Init_All()
    if not Save().allBank then
        return
    end

    local function GenerateItemSlotsForSelectedTab(self)
        if not C_Bank.AreAnyBankTypesViewable() then
            return
        end
        self.itemButtonPool:ReleaseAll()

        if not self.selectedTabID or self.selectedTabID == PURCHASE_TAB_ID then
            return;
        end

        local isAccount= self:GetActiveBankType() == Enum.BankType.Account
        local line= Save().line or 2
        local num= isAccount and Save().accountNum or Save().num or 15
        local x, y= BODER_LEFT, -63
        local index=0
        local width= BODER_LEFT*2
        local indexTab= 0
        local newContainer= line>8 and line or 8

        for _, bankTabData in ipairs(self.purchasedBankTabData or {}) do
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
                    Create_Tab_Label(self, indexTab)
                    self.tabNames[indexTab]:SetPoint('BOTTOMLEFT', btn, 'TOPLEFT', 0, 3)
                    Set_TabInfoText(self.tabNames[indexTab], bankTabData)
                end
    --x,y
                index= index+1
                local isNewContainer= containerSlotID==numSlot
                if select(2, math.modf(index/num))==0 or isNewContainer then

                    x= x+ 37 +line+ (isNewContainer and newContainer or 0)
                    y= -63
                    width= width+ 37+ line+  (isNewContainer and newContainer or 0)


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
            width- line+ 3 -newContainer,
            63+ (37+line)*num -line + BODER_LEFT+3
        )
    end

--替换，原生
    BankPanel.GenerateItemSlotsForSelectedTab= GenerateItemSlotsForSelectedTab

    BankPanel:HookScript('OnEvent', function(self, event, ...)
        if not Save().allBank then
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

    Init_All=function()
        if Save().allBank then
            BankPanel.GenerateItemSlotsForSelectedTab= GenerateItemSlotsForSelectedTab
        else
            BankPanel.GenerateItemSlotsForSelectedTab= BankPanelMixin.GenerateItemSlotsForSelectedTab
            BankFrame:SetSize(738, 460)
            for _, label in pairs(BankPanel.tabNames) do
                label:SetText('')
            end
        end
        --BankPanel.Header.Text:SetAlpha(Save().allBank and 0 or 1)
        BankPanel:RefreshBankPanel()
    end
end





--C_Container.SortBank(Enum.BankType.Guild)










--移动，银行
local function Init_Move()
    BankPanel:SetPoint('TOPRIGHT')
    BankPanel:SetPoint('BOTTOMRIGHT')

    WoWTools_MoveMixin:Setup(BankFrame, {
        setSize=true, minW=80, minH=140,
    --[[sizeUpdateFunc= function()
    end, ]]sizeRestFunc= function()
        Save().num=15
        Save().accountNum= nil
        --BankFrame:SetSize(738, 460)
        BankPanel:GenerateItemSlotsForSelectedTab()
    end, sizeStopFunc= function()
        if BankPanel.PurchasePrompt:IsShown()
            or BankPanel.LockPrompt:IsShown()
            or not C_Bank.AreAnyBankTypesViewable()
        then
            return
        end
        local line= Save().line or 2
        local h= math.ceil((BankFrame:GetHeight()-63-BODER_LEFT+line)/(37+line))
        if BankPanel:GetActiveBankType() == Enum.BankType.Account then
            Save().accountNum= h
        else
            Save().num= h
        end
        BankPanel:GenerateItemSlotsForSelectedTab()
    end})
    WoWTools_MoveMixin:Setup(BankPanel.TabSettingsMenu, {frame=BankFrame})
    WoWTools_MoveMixin:Setup(BankCleanUpConfirmationPopup)


    BankPanel.PurchasePrompt:HookScript('OnShow', function()
        BankFrame:SetSize(738, 460)
    end)
    BankPanel.LockPrompt:HookScript('OnShow', function()
        BankFrame:SetSize(738, 460)
    end)

    BankFrame.ResizeButton.setSize= Save().allBank
    Init_Move=function()
        BankFrame.ResizeButton.setSize= Save().allBank
    end
end














function WoWTools_MoveMixin.Frames:BankFrame()
    Init_Move()--移动，银行
end


function WoWTools_BankMixin:Init_AllBank()
    Init()
    Init_UI()
    Init_All()--整全一起
    Init_Move()--移动，银行
end
