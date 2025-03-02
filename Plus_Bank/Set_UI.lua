local e= select(2, ...)

local function Save()
    return WoWTools_BankMixin.Save
end






local function Set_Button_Tooltip(self)
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()

    local free, all, regentsFree= WoWTools_BagMixin:GetFree(true)--背包，空位

    local name= (self.index==1 and '|A:Banker:0:0|a'..(e.onlyChinese and '银行' or BANK))
                or (self.index==2 and '|A:CreationCatalyst-32x32:0:0|a'..(e.onlyChinese and '材料' or BAG_FILTER_REAGENTS))
                or (self.index==3 and '|A:questlog-questtypeicon-account:0:0|a'..(e.onlyChinese and '战团' or ACCOUNT_QUEST_LABEL))
                or ''
    e.tips:AddDoubleLine(self.name, name)
    if self.tooltip then
        self.tooltip(e.tips)
    end

    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(
        '|A:bag-main:0:0|a'..(e.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL)
        ..' |cnGREEN_FONT_COLOR:'..free..'|r (|cnRED_FONT_COLOR:'..(all-free)..'|r) / '..all,
        '(|cnGREEN_FONT_COLOR:'..(free-regentsFree)..'|r+|cnGREEN_FONT_COLOR:'..regentsFree..'|r)'
    )

    free, all= WoWTools_BankMixin:GetFree(self.index)

    e.tips:AddLine(
        name
        ..' |cnGREEN_FONT_COLOR:'..free..'|r'
        ..' (|cnRED_FONT_COLOR:'..(all-free)..'|r)'
        ..' / '..all
    )

    e.tips:Show()
end









local function Set_Button(btn)


    btn.Text= WoWTools_LabelMixin:Create(btn, {color=true})
    btn.Text:SetPoint('BOTTOM', btn, 'TOP', 0, -3)

    function btn:set_text()

        local Tabs=  WoWTools_BankMixin:Take_Item(self.isOutItem, nil, nil, self.index, true, self.checkBagFunc)
        local num= #Tabs

        self.Text:SetText((num==0 and '|cff828282' or '')..num)
        if GameTooltip:IsOwned(self) then
            Set_Button_Tooltip(self)
        end
    end

    function btn:set_event()
        if self:IsVisible() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:set_text()
        else
            self:UnregisterEvent('BAG_UPDATE_DELAYED')
        end
    end

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        --[[if self.index==3 and WoWTools_BankMixin:GetIndex()==1 then
            ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged)
            print('a')
        end]]
        Set_Button_Tooltip(self)
    end)


    btn:SetScript('OnClick', function(self, d)
        if btn.index==3 and not btn.isOutItem and--系统自带，存放所有战团绑定物品，增强
            (
                d=='LeftButton'
                or self:GetItemDepositConfirmationPopup()
            )
        then
            self:OnClick()
        else

            WoWTools_BankMixin:Take_Item(self.isOutItem, nil, nil, self.index, false)
        end
    end)

    C_Timer.After(0.7, function()
        btn:SetScript('OnShow', btn.set_event)
        btn:SetScript('OnHide', btn.set_event)
        btn:SetScript('OnEvent', btn.set_text)
        btn:set_event()
    end)
end

















local function Init_BankSlotsFrame()
--移动，整理按钮, 系统自带
    BankItemAutoSortButton:ClearAllPoints()
    BankItemAutoSortButton:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -6, 0)
    BankItemAutoSortButton:SetParent(BankSlotsFrame)
    BankItemAutoSortButton:SetSize(32, 32)


--添加，取出所有
    local btnOutAll= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {
        size=23,
        atlas='Cursor_OpenHand_64',
        name='WoWToolsBankSlotFrameOutAllItemButton'
    })
    btnOutAll:SetPoint('RIGHT', BankItemAutoSortButton, 'LEFT', -2, 0)
    btnOutAll.index=1
    btnOutAll.isOutItem=true
    btnOutAll.name='|A:Cursor_OpenHand_64:0:0|a'..(e.onlyChinese and '取出所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ALL), ITEMS))
    Set_Button(btnOutAll)

    --[[btnOutAll:SetScript('OnClick', function(self)
        WoWTools_BankMixin:Take_Item(true, nil, nil, self.index, false)
    end)]]


--存放物品
    local btnInAll= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size=23, atlas='Crosshair_buy_64'})
    btnInAll:SetPoint('RIGHT', btnOutAll, 'LEFT', -2, 0)
    btnInAll.index=1
    btnInAll.isOutItem=false
    btnInAll.name= '|A:Banker:0:0|a'
        ..(e.onlyChinese and '存放所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, ALL), ITEMS))
        ..'(|cff828282'..(e.onlyChinese and '材料' or BAG_FILTER_REAGENTS)..'|r)'
    Set_Button(btnInAll)
    --[[btnInAll:SetScript('OnClick', function()
        WoWTools_BankMixin:Take_Item(false, nil, nil, 1, false)
    end)]]


--提示，标签
    local label= WoWTools_LabelMixin:Create(btnInAll, {color=true, size=14})
    label:SetPoint('RIGHT', btnInAll, 'LEFT', 4,0)
    label:SetText(e.onlyChinese and '银行' or BANK)

--空栏位，数量
    --local label2= WoWTools_LabelMixin:Create(btnInAll, {color=true, size=12, name='WoWToolsBankFreeSlotLabel'})
    --label2:SetPoint('RIGHT', label, 'LEFT', -2,0)





    BankSlotsFrame.EdgeShadows:Hide()

    BankFrame:EnableDrawLayer('BACKGROUND')
    BankFrame.Background:ClearAllPoints()
    BankFrame.Background:SetPoint('TOPLEFT', BankFrame)
    BankFrame.Background:SetPoint('BOTTOMRIGHT', BankFrame)
    WoWTools_BankMixin:Set_Background_Texture(BankFrame.Background)


--背景
    BankFrameBg:SetAtlas('UI-Frame-DialogBox-BackgroundTile',true, 'NEAREST')
    BankFrameBg:SetAlpha(0.5)

--隐藏，ITEMSLOTTEXT"物品栏位" BAGSLOTTEXT"背包栏位"
    for _, region in pairs({BankSlotsFrame:GetRegions()}) do
        if region:GetObjectType()=='FontString' then
            region:SetText('')
        end
    end

    BankSlotsFrame.NineSlice:Hide()
end

























   --取出，所有，材料
local function Init_ReagentBankFrame()


--整理材料银行
    local btnSort= CreateFrame("Button", nil, ReagentBankFrame, 'BankAutoSortButtonTemplate')
    btnSort:SetSize(32,32)
    btnSort:SetPoint('LEFT', BankItemSearchBox, 'RIGHT', 2, 0)--整理材料银行
    btnSort:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '整理材料银行' or BAG_CLEANUP_REAGENT_BANK)
        e.tips:Show()
    end)
    btnSort:SetScript('OnClick', C_Container.SortReagentBankBags)

--存放各种材料,系统自带
    local despButton= ReagentBankFrame.DespositButton
    despButton:ClearAllPoints()
    despButton:SetSize(26, 26)
    despButton:SetPoint('LEFT', btnSort, 'RIGHT', 2, 2)
    despButton:SetText('')
    despButton.Middle:Hide()
    despButton.Right:Hide()
    despButton.Left:Hide()
    despButton:SetNormalAtlas('Crosshair_buy_64')
    despButton:SetHighlightAtlas('auctionhouse-nav-button-select')
    despButton:SetPushedAtlas('auctionhouse-nav-button-select')
    --despButton:HookScript('OnLeave', GameTooltip_Hide)
    --[[despButton:HookScript('OnEnter', function(s)
        e.tips:SetOwner(s, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '存放各种材料' or REAGENTBANK_DEPOSIT)
        e.tips:Show()
    end)]]
    despButton.index=2
    despButton.isOutItem=false
    despButton.name= '|A:Banker:0:0|a'
    ..(e.onlyChinese and '存放各种材料' or REAGENTBANK_DEPOSIT)
    ..'(|cff828282'..(e.onlyChinese and '物品' or ITEMS)..'|r)'
    Set_Button(despButton)


--取出所有物品
    local btnAllOut= WoWTools_ButtonMixin:Cbtn(ReagentBankFrame, {size=23, atlas='Cursor_OpenHand_64'})
    btnAllOut:SetPoint('LEFT', despButton, 'RIGHT', 2, 0)
    btnAllOut.index=2
    btnAllOut.isOutItem=true
    btnAllOut.name= '|A:Cursor_OpenHand_64:0:0|a'
        ..(e.onlyChinese and '取出所有材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ALL), BAG_FILTER_REAGENTS))
        ..'(|cff828282'..(e.onlyChinese and '物品' or ITEMS)..'|r)'
        Set_Button(btnAllOut)

    --[[btnAllOut:SetScript('OnClick', function(self)
        WoWTools_BankMixin:Take_Item(true, nil, nil, 2, false)
        self:show_tooltips()
    end)

    function btnAllOut:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free= WoWTools_BagMixin:GetFree(true)--self:get_free()
        e.tips:AddDoubleLine(e.onlyChinese and '取出所有材料' or 'Take out all reagents',
            format('|A:4549254:0:0|a%s #%s%d',
                e.onlyChinese and '材料' or AUCTION_CATEGORY_TRADE_GOODS,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btnAllOut:show_tooltips()
        C_Timer.After(1, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btnAllOut:HookScript('OnLeave', GameTooltip_Hide)
    btnAllOut:HookScript('OnEnter', btnAllOut.set_tooltips)]]

--提示，标签
    local label= WoWTools_LabelMixin:Create(btnAllOut, {color=true, size=14})
    label:SetPoint('LEFT', btnAllOut, 'RIGHT')
    label:SetText(e.onlyChinese and '材料' or BAG_FILTER_REAGENTS)



--隐藏，背景
    ReagentBankFrame:HookScript('OnShow', function(self)
        if self.isSetPoint then--or not IsReagentBankUnlocked() then
            return
        end
        self.isSetPoint=true
        for _, region in pairs({ReagentBankFrame:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetTexture(0)
            end
        end
    end)

    ReagentBankFrame.NineSlice:Hide()
    ReagentBankFrame.EdgeShadows:Hide()
    ReagentBankFrameUnlockInfo:ClearAllPoints()
    ReagentBankFrameUnlockInfo:SetPoint('TOPLEFT', 0,-20)
    ReagentBankFrameUnlockInfo:SetPoint('BOTTOMRIGHT', 0, 8)
end





















local function Init_AccountBankPanel()

--添加，取出所有物品
    local btnAllOut= WoWTools_ButtonMixin:Cbtn(AccountBankPanel.ItemDepositFrame, {size=23, atlas='Cursor_OpenHand_64'})
    btnAllOut:SetPoint('TOPRIGHT', AccountBankPanel, -16, -31)
    btnAllOut:SetPoint('RIGHT', BankItemAutoSortButton, 'LEFT', -2, 0)
    btnAllOut.index=3
    btnAllOut.isOutItem=true
    btnAllOut.name='|A:Cursor_OpenHand_64:0:0|a'..(e.onlyChinese and '取出所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ALL), ITEMS))
    btnAllOut.tooltip=function(tooltip)
        local activeTabIndex= WoWTools_BankMixin:GetIndex()
        local tabIndex= AccountBankPanel.selectedTabID
        if (Save().allAccountBag and activeTabIndex==3) or tabIndex==-1 then
            return
        end
        local data = AccountBankPanel:GetTabData(tabIndex)
        if data and data.name then
            tooltip:AddLine('|cnGREEN_FONT_COLOR:'..data.name)
        end
    end
    Set_Button(btnAllOut)

--存放所有战团绑定物品, 增强
    local despButton= AccountBankPanel.ItemDepositFrame.DepositButton
    despButton:ClearAllPoints()
    despButton:SetPoint('RIGHT', btnAllOut, 'LEFT', -2, 0)
    despButton:SetSize(24, 24)
    despButton:SetText('')
    despButton.Middle:Hide()
    despButton.Right:Hide()
    despButton.Left:Hide()
    despButton:SetNormalAtlas('Crosshair_buy_64')
    despButton:SetHighlightAtlas('auctionhouse-nav-button-select')
    despButton:SetPushedAtlas('auctionhouse-nav-button-select')

    despButton:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    despButton.index=3
    despButton.isOutItem=false
    despButton.name= '|A:Banker:0:0|a'..(e.onlyChinese and '存放所有战团绑定物品' or ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL)..e.Icon.left
    despButton.tooltip= function(tooltip)
        local bankAutoDepositReagents =C_CVar.GetCVarBool('bankAutoDepositReagents')
        tooltip:AddDoubleLine(
            '|A:Banker:0:0|a'
            ..(e.onlyChinese and '存放所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, ALL), ITEMS))..e.Icon.right,

            (bankAutoDepositReagents and '|cnGREEN_FONT_COLOR:' or '|cff828282')..(e.onlyChinese and '材料' or BAG_FILTER_REAGENTS)
        )
    end
    function despButton.checkBagFunc(bag, slot)
        if WoWTools_BankMixin:GetIndex()~=1 then
            return
        end
        return C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, ItemLocation:CreateFromBagAndSlot(bag, slot))
    end
    Set_Button(despButton)

    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox:HookScript('OnLeave', function()
        AccountBankPanel.ItemDepositFrame.DepositButton:set_text()
    end)

--添加，整理
    local btnSort= CreateFrame("Button", 'WoWToolsAutoSortAccountBankButton', btnAllOut, 'BankAutoSortButtonTemplate')
    btnSort:SetSize(32, 32)
    btnSort:SetPoint('RIGHT', despButton, 'LEFT', -2, 0)--整理材料银行
    btnSort:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '清理战团银行' or BAG_CLEANUP_ACCOUNT_BANK)
        local cvar= C_CVar.GetCVarBool('bankConfirmTabCleanUp')
        e.tips:AddLine(
            (cvar and '|cnGREEN_FONT_COLOR:' or '|cff828282')
            ..(e.onlyChinese and '确认清理战团银行' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RPE_CONFIRM, BAG_CLEANUP_ACCOUNT_BANK))
        )

        e.tips:Show()
    end)
    btnSort:SetScript('OnClick', function()
        if GetCVarBool("bankConfirmTabCleanUp") then
			StaticPopupSpecial_Show(BankCleanUpConfirmationPopup);
		else
			C_Container.SortAccountBankBags()
		end
    end)





--包括可交易的材料
    local check= AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox
    check:ClearAllPoints()
    check:SetPoint('RIGHT', btnSort, 'LEFT')
    check:HookScript('OnLeave', GameTooltip_Hide)
    check:HookScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '包括可交易的材料' or BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL)
        e.tips:Show()
    end)
    check.Text:SetText('')
    check.Text:Hide()

--标签，战团银行
    local label= WoWTools_LabelMixin:Create(AccountBankPanel.ItemDepositFrame, {size=14, color=true})
    label:SetPoint('RIGHT', check, 'LEFT')
    label:SetText('|A:questlog-questtypeicon-account:0:0|a'..(e.onlyChinese and '战团' or ACCOUNT_QUEST_LABEL))

--清除，标签，名称
    AccountBankPanel.Header:ClearAllPoints()
    function AccountBankPanel:RefreshHeaderText()
    end

--钱    
    AccountBankPanel.MoneyFrame.Border:Hide()
    AccountBankPanel.MoneyFrame.MoneyDisplay:ClearAllPoints()
    AccountBankPanel.MoneyFrame.MoneyDisplay:SetPoint('BOTTOM', AccountBankPanel.MoneyFrame.DepositButton, 'TOPLEFT', 6, -2)

--背景    
    AccountBankPanel.Background=AccountBankPanel:CreateTexture(nil, 'BACKGROUND')
    AccountBankPanel.Background:SetAllPoints()

    AccountBankPanel.NineSlice:ClearAllPoints()
    AccountBankPanel.NineSlice:SetAllPoints()
    WoWTools_PlusTextureMixin:SetNineSlice(AccountBankPanel, true, false, false, false)

--边框
    AccountBankPanel.NineSlice.LeftEdge:Hide()
    AccountBankPanel.EdgeShadows:Hide()

--钱，提示

    local icon= AccountBankPanel.MoneyFrame:CreateTexture()
    icon:SetPoint('RIGHT', AccountBankPanelGoldButton, 'LEFT', 0,2)
    icon:SetSize(16,16)
    icon:SetAtlas('questlog-questtypeicon-account')

    --C_Bank.DepositMoney(Enum.BankType.Account, 1000)
end




















--打开，银行，背包
local function Init_OpenAllBag_Button()
    local up= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS], {
        name='WoWToolsBankOpenAllBagButton',
        atlas='NPE_ArrowDown',
        size=22,
    })
    up:SetPoint('TOPLEFT', BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS], 'TOPRIGHT', 0,2)
    up:SetScript('OnLeave', GameTooltip_Hide)
    up:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '打开背包' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, BAGSLOT))
        e.tips:Show()
    end)
    up:SetScript('OnClick', function()
        do
            WoWTools_BankMixin:OpenBag()
        end
        WoWTools_BankMixin:Init_Plus()
    end)

    local down= WoWTools_ButtonMixin:Cbtn(up, {
        name='WoWToolsBankCloseAllBagButton',
        size=22,
        atlas='NPE_ArrowUp',
    })

    down:SetPoint('TOP', up, 'BOTTOM')
    down:SetScript('OnLeave', GameTooltip_Hide)
    down:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '关闭背包' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLOSE, BAGSLOT))
        e.tips:Show()
    end)
    down:SetScript('OnClick', function()
        do
            WoWTools_BankMixin:CloseBag()
        end
        WoWTools_BankMixin:Init_Plus()
    end)
end












local function AccountBankPanel_RefreshBankTabs(frame)
    if not frame.purchasedBankTabData then
        return
    end

    for btn in frame.bankTabPool:EnumerateActive() do
        if not btn.nameLabel then
            btn.nameLabel= WoWTools_LabelMixin:Create(btn, {color=true})
            btn.nameLabel:SetPoint('TOPLEFT', btn.Icon, 'BOTTOMLEFT', 0, 1)

            function btn:Settings()
                local enabled = self:IsEnabled()
                local isSelected= self:IsSelected() or GameTooltip:IsOwned(self)
                self.nameLabel:SetAlpha(enabled and 1 or 0)
                self:SetAlpha(enabled and isSelected and 1 or 0.5)
            end
            btn:HookScript('OnEnter', function(self)
                self.nameLabel:SetAlpha(1)
                self:SetAlpha(1)
            end)
            btn:HookScript('OnLeave', btn.Settings)
        end
        btn.Border:SetShown(false)
        btn.nameLabel:SetText(btn.tabData and btn.tabData.name or '')
    end
end
















local function Init()
    Init_BankSlotsFrame()
    Init_ReagentBankFrame()
    Init_AccountBankPanel()

    Init_OpenAllBag_Button()

--搜索框
    WoWTools_PlusTextureMixin:SetSearchBox(BankItemSearchBox)

--移动，搜索框
    hooksecurefunc('BankFrame_UpdateAnchoringForPanel', function()
        BankItemSearchBox:ClearAllPoints()
        BankItemSearchBox:SetPoint('TOP', 0,-33)
    end)

--战团，Tabs
    AccountBankPanel.PurchaseTab.Border:Hide()
    hooksecurefunc(AccountBankPanel, 'RefreshBankTabs', AccountBankPanel_RefreshBankTabs)
    hooksecurefunc(BankPanelTabMixin, 'RefreshVisuals', function(self)
        if self.Settings then self:Settings() end
    end)
    C_Timer.After(0.3, function() AccountBankPanel:RefreshBankTabs() end)

    WoWTools_PlusTextureMixin:SetFrame(BankFrameTab1, {notAlpha=true})
    WoWTools_PlusTextureMixin:SetFrame(BankFrameTab2, {notAlpha=true})
    WoWTools_PlusTextureMixin:SetFrame(BankFrameTab3, {notAlpha=true})
    WoWTools_PlusTextureMixin:SetNineSlice(BankFrame, true, false, false, false)
end







function WoWTools_BankMixin:Init_UI()
   Init()
end