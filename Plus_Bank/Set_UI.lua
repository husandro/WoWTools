if not BankFrameTab2 then
    return
end

local function Save()
    return WoWToolsSave['Plus_Bank'] or {}
end






local function Set_Button_Tooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()

    local free, all, regentsFree= WoWTools_BagMixin:GetFree(true)--背包，空位

    local name= (self.index==1 and '|A:Banker:0:0|a'..(WoWTools_DataMixin.onlyChinese and '银行' or BANK))
                or (self.index==2 and '|A:CreationCatalyst-32x32:0:0|a'..(WoWTools_DataMixin.onlyChinese and '材料' or BAG_FILTER_REAGENTS))
                or (self.index==3 and '|A:questlog-questtypeicon-account:0:0|a'..(WoWTools_DataMixin.onlyChinese and '战团' or ACCOUNT_QUEST_LABEL))
                or ''
    GameTooltip:AddDoubleLine(self.name, name)
    if self.tooltip then
        self.tooltip(GameTooltip)
    end

    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(
        '|A:bag-main:0:0|a'..(WoWTools_DataMixin.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL)
        ..' |cnGREEN_FONT_COLOR:'..free..'|r (|cnRED_FONT_COLOR:'..(all-free)..'|r) / '..all,
        '(|cnGREEN_FONT_COLOR:'..(free-regentsFree)..'|r+|cnGREEN_FONT_COLOR:'..regentsFree..'|r)'
    )

    free, all= WoWTools_BankMixin:GetFree(self.index)

    GameTooltip:AddLine(
        name
        ..' |cnGREEN_FONT_COLOR:'..free..'|r'
        ..' (|cnRED_FONT_COLOR:'..(all-free)..'|r)'
        ..' / '..all
    )

    GameTooltip:Show()
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
    btnOutAll.name='|A:Cursor_OpenHand_64:0:0|a'..(WoWTools_DataMixin.onlyChinese and '取出所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ALL), ITEMS))
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
        ..(WoWTools_DataMixin.onlyChinese and '存放所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, ALL), ITEMS))
        ..'(|cff828282'..(WoWTools_DataMixin.onlyChinese and '材料' or BAG_FILTER_REAGENTS)..'|r)'
    Set_Button(btnInAll)
    --[[btnInAll:SetScript('OnClick', function()
        WoWTools_BankMixin:Take_Item(false, nil, nil, 1, false)
    end)]]


--提示，标签
    local label= WoWTools_LabelMixin:Create(btnInAll, {color=true, size=14})
    label:SetPoint('RIGHT', btnInAll, 'LEFT', 4,0)
    label:SetText(WoWTools_DataMixin.onlyChinese and '银行' or BANK)

--空栏位，数量
    --local label2= WoWTools_LabelMixin:Create(btnInAll, {color=true, size=12, name='WoWToolsBankFreeSlotLabel'})
    --label2:SetPoint('RIGHT', label, 'LEFT', -2,0)







--隐藏，ITEMSLOTTEXT"物品栏位" BAGSLOTTEXT"背包栏位"
    for _, region in pairs({BankSlotsFrame:GetRegions()}) do
        if region:GetObjectType()=='FontString' then
            region:SetText('')
        end
    end
end

























   --取出，所有，材料
local function Init_ReagentBankFrame()


--整理材料银行
    local btnSort= CreateFrame("Button", nil, ReagentBankFrame, 'BankAutoSortButtonTemplate')
    btnSort:SetSize(32,32)
    btnSort:SetPoint('LEFT', BankItemSearchBox, 'RIGHT', 2, 0)--整理材料银行
    btnSort:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '整理材料银行' or BAG_CLEANUP_REAGENT_BANK)
        GameTooltip:Show()
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
        GameTooltip:SetOwner(s, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '存放各种材料' or REAGENTBANK_DEPOSIT)
        GameTooltip:Show()
    end)]]
    despButton.index=2
    despButton.isOutItem=false
    despButton.name= '|A:Banker:0:0|a'
    ..(WoWTools_DataMixin.onlyChinese and '存放各种材料' or REAGENTBANK_DEPOSIT)
    ..'(|cff828282'..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS)..'|r)'
    Set_Button(despButton)


--取出所有物品
    local btnAllOut= WoWTools_ButtonMixin:Cbtn(ReagentBankFrame, {size=23, atlas='Cursor_OpenHand_64'})
    btnAllOut:SetPoint('LEFT', despButton, 'RIGHT', 2, 0)
    btnAllOut.index=2
    btnAllOut.isOutItem=true
    btnAllOut.name= '|A:Cursor_OpenHand_64:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '取出所有材料' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ALL), BAG_FILTER_REAGENTS))
        ..'(|cff828282'..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS)..'|r)'
        Set_Button(btnAllOut)

--提示，标签
    local label= WoWTools_LabelMixin:Create(btnAllOut, {color=true, size=14})
    label:SetPoint('LEFT', btnAllOut, 'RIGHT')
    label:SetText(WoWTools_DataMixin.onlyChinese and '材料' or BAG_FILTER_REAGENTS)

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
    btnAllOut.name='|A:Cursor_OpenHand_64:0:0|a'..(WoWTools_DataMixin.onlyChinese and '取出所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ALL), ITEMS))
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

    despButton:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    despButton.index=3
    despButton.isOutItem=false
    despButton.name= '|A:Banker:0:0|a'..(WoWTools_DataMixin.onlyChinese and '存放所有战团绑定物品' or ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL)..WoWTools_DataMixin.Icon.left
    despButton.tooltip= function(tooltip)
        local bankAutoDepositReagents =C_CVar.GetCVarBool('bankAutoDepositReagents')
        tooltip:AddDoubleLine(
            '|A:Banker:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '存放所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEPOSIT, ALL), ITEMS))..WoWTools_DataMixin.Icon.right,

            (bankAutoDepositReagents and '|cnGREEN_FONT_COLOR:' or '|cff828282')..(WoWTools_DataMixin.onlyChinese and '材料' or BAG_FILTER_REAGENTS)
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
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '清理战团银行' or BAG_CLEANUP_ACCOUNT_BANK)
        local cvar= C_CVar.GetCVarBool('bankConfirmTabCleanUp')
        GameTooltip:AddLine(
            (cvar and '|cnGREEN_FONT_COLOR:' or '|cff828282')
            ..(WoWTools_DataMixin.onlyChinese and '确认清理战团银行' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RPE_CONFIRM, BAG_CLEANUP_ACCOUNT_BANK))
        )

        GameTooltip:Show()
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
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '包括可交易的材料' or BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL)
        GameTooltip:Show()
    end)
    check.Text:SetText('')
    check.Text:Hide()

--标签，战团银行
    local label= WoWTools_LabelMixin:Create(AccountBankPanel.ItemDepositFrame, {size=14, color=true})
    label:SetPoint('RIGHT', check, 'LEFT')
    label:SetText('|A:questlog-questtypeicon-account:0:0|a'..(WoWTools_DataMixin.onlyChinese and '战团' or ACCOUNT_QUEST_LABEL))

--钱
    AccountBankPanel.MoneyFrame.MoneyDisplay:ClearAllPoints()
    AccountBankPanel.MoneyFrame.MoneyDisplay:SetPoint('BOTTOM', AccountBankPanel.MoneyFrame.DepositButton, 'TOPLEFT', 6, -2)

--边框
    AccountBankPanel.NineSlice.LeftEdge:Hide()
    AccountBankPanel.EdgeShadows:Hide()

--钱，提示

    local icon= AccountBankPanel.MoneyFrame:CreateTexture()
    icon:SetPoint('RIGHT', AccountBankPanelGoldButton, 'LEFT', 0,2)
    icon:SetSize(16,16)
    icon:SetAtlas('questlog-questtypeicon-account')
end




















--打开，银行，背包
local function Init_OpenAllBag_Button()
    local up= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS], {
        name='WoWToolsBankOpenAllBagButton',
        atlas='NPE_ArrowUp',
        size={18, 23},
    })
    up:SetPoint('TOPLEFT', BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS], 'TOPRIGHT', 0,4)
    up:SetScript('OnLeave', GameTooltip_Hide)
    up:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开背包' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, BAGSLOT))
        GameTooltip:Show()
    end)
    up:SetScript('OnClick', function()
        do
            WoWTools_BagMixin:OpenBag(nil, true)
        end
        WoWTools_BankMixin:Init_Plus()
    end)

    local down= WoWTools_ButtonMixin:Cbtn(up, {
        name='WoWToolsBankCloseAllBagButton',
        size={18, 23},
        atlas='NPE_ArrowDown',
    })

    down:SetPoint('TOP', up, 'BOTTOM')
    down:SetScript('OnLeave', GameTooltip_Hide)
    down:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '关闭背包' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLOSE, BAGSLOT))
        GameTooltip:Show()
    end)
    down:SetScript('OnClick', function()
        do
            WoWTools_BagMixin:CloseBag(nil, true)
        end
        WoWTools_BankMixin:Init_Plus()
    end)
end












local function AccountBankPanel_RefreshBankTabs(frame)
    frame= frame or AccountBankPanel
    if not frame.purchasedBankTabData then
        return
    end

   -- local allAccountBag= Save().allAccountBag and BankFrame.activeTabIndex==3

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
            btn:Settings()
            btn.Border:SetTexture(0)
        end
        btn.nameLabel:SetText(btn.tabData and btn.tabData.name  or '')
    end
end





local function Init_Texture(self)
   
    self:SetTabButton(BankFrameTab1)
    self:SetTabButton(BankFrameTab2)
    self:SetTabButton(BankFrameTab3)
    BankFrameTab2:SetText(WoWTools_DataMixin.onlyChinese and '材料' or PROFESSIONS_COLUMN_HEADER_REAGENTS)
    BankFrameTab3:SetText(WoWTools_DataMixin.onlyChinese and '战团' or ACCOUNT_QUEST_LABEL)
    PanelTemplates_TabResize(BankFrameTab2)
    PanelTemplates_TabResize(BankFrameTab3)

    self:SetButton(BankFrameCloseButton)

--搜索框
    WoWTools_TextureMixin:SetEditBox(BankItemSearchBox)
    self:HideTexture(BankFrame.TopTileStreaks)

    self:HideFrame(BankSlotsFrame)
    self:HideFrame(BankSlotsFrame.EdgeShadows)
    self:SetNineSlice(BankSlotsFrame)

--材料
    self:SetNineSlice(ReagentBankFrame)
--隐藏，背景
    self:HideFrame(ReagentBankFrame)
    self:HideFrame(ReagentBankFrame.EdgeShadows)
    ReagentBankFrame:HookScript('OnShow', function(f)
        if f.isSetPoint then--or not IsReagentBankUnlocked() then
            return
        end
        f.isSetPoint=true
        for _, region in pairs({f:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetTexture(0)
            end
        end
    end)

--清除，标签，名称
    AccountBankPanel.Header:ClearAllPoints()
    self:HideTexture(AccountBankPanel.PurchaseTab.Border)
    self:HideFrame(AccountBankPanel.MoneyFrame.Border)
    self:SetNineSlice(AccountBankPanel)

--背景
    self:HideFrame(BankFrame, {show={[BankFrame.Background]=true}})
    BankFrame.Background:ClearAllPoints()
    BankFrame.Background:SetPoint('TOPLEFT', BankFrame)
    BankFrame.Background:SetPoint('BOTTOMRIGHT', BankFrame)

    self:SetFrame(BankCleanUpConfirmationPopup.Border, {alpha=1})

    self:Init_BGMenu_Frame(BankFrame, {
        enabled=true,
        alpha=1,
        settings=function(_, texture, alpha)
            alpha= texture and 0 or alpha or 1
            BankFrame.Background:SetAlpha(alpha)
        end
    })

    Init_Texture=function()end
end

function WoWTools_TextureMixin.Frames:BankFrame()
    Init_Texture(self)
end











local function Init()
    Init_BankSlotsFrame()
    Init_ReagentBankFrame()
    Init_AccountBankPanel()

    Init_OpenAllBag_Button()
    Init_Texture(WoWTools_TextureMixin)



--移动，搜索框
    hooksecurefunc('BankFrame_UpdateAnchoringForPanel', function()
        BankItemSearchBox:ClearAllPoints()
        BankItemSearchBox:SetPoint('TOP', 0,-33)
    end)

--战团，Tabs
    hooksecurefunc(AccountBankPanel, 'RefreshBankTabs', AccountBankPanel_RefreshBankTabs)
    hooksecurefunc(BankPanelTabMixin, 'RefreshVisuals', function(frame)
        if frame.Settings then frame:Settings() end
    end)

--背包位
    for index=1, NUM_BANKBAGSLOTS do--NUM_BANKBAGSLOTS 7
        local btn= BankSlotsFrame['Bag'..index]
        if btn then
            btn:ClearAllPoints()
            if index==1 then
                btn:SetPoint('BOTTOMLEFT',6,6)
            else
                btn:SetPoint('LEFT', BankSlotsFrame['Bag'..(index-1)], 'RIGHT', Save().line, 0)
            end
        end
    end


--购买，背包栏
    BankFramePurchaseInfo:ClearAllPoints()
    BankFramePurchaseInfo:SetPoint('TOP', BankFrame, 'BOTTOM',0, -28)
    WoWTools_TextureMixin:CreateBG(BankFramePurchaseInfo, {isAllPoint=true})









    Init=function()end
end





function WoWTools_BankMixin:Init_UI()
    Init()
end