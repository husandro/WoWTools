local e= select(2, ...)






local function Set_Button_Tooltip(self)
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()

    local free, all, regentsFree= WoWTools_BagMixin:GetFree(true)--背包，空位

    e.tips:AddLine(self.name)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(
        '|A:bag-main:0:0|a'..(e.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL)
        ..' |cnGREEN_FONT_COLOR:'..free..'|r (|cnRED_FONT_COLOR:'..(all-free)..'|r) / '..all,
        '(|cnGREEN_FONT_COLOR:'..(free-regentsFree)..'|r+|cnGREEN_FONT_COLOR:'..regentsFree..'|r)'
    )

    free, all= WoWTools_BankMixin:GetFree(1)
    e.tips:AddLine(
        '|A:Banker:0:0|a'..(e.onlyChinese and '银行' or BANK)
        ..' |cnGREEN_FONT_COLOR:'..free..'|r (|cnRED_FONT_COLOR:'..(all-free)..'|r) / '..all
    )

    e.tips:Show()
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
    btnOutAll.name= '|A:Cursor_OpenHand_64:0:0|a'..(
        e.onlyChinese and '取出所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WITHDRAW, ALL), ITEMS)
    )
    btnOutAll:SetPoint('RIGHT', BankItemAutoSortButton, 'LEFT', -2, 0)
    btnOutAll:SetScript('OnClick', function(self)
        WoWTools_BankMixin:Take_Item(true, nil, nil, 1, false)
    end)

    btnOutAll:SetScript('OnLeave', GameTooltip_Hide)
    btnOutAll:SetScript('OnEnter', Set_Button_Tooltip)

    btnOutAll.Text= WoWTools_LabelMixin:Create(btnOutAll, {color={1,1,1}})
    btnOutAll.Text:SetPoint('BOTTOM', btnOutAll, 'TOP', 0, -2)
    function btnOutAll:set_text()
        local  free, all= WoWTools_BankMixin:GetFree(1)
        local num= all-free
        self.Text:SetText((num==0 and '|cff828282' or '')..num)
        if GameTooltip:IsOwned(self) then
            Set_Button_Tooltip(self)
        end
    end
    function btnOutAll:set_event()
        if self:IsVisible() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:set_text()
        else
            self:UnregisterEvent('BAG_UPDATE_DELAYED')
        end
    end
    btnOutAll:SetScript('OnShow', btnOutAll.set_event)
    btnOutAll:SetScript('OnHide', btnOutAll.set_event)
    btnOutAll:SetScript('OnEvent', btnOutAll.set_text)
    C_Timer.After(1, function()
        btnOutAll:set_text()
    end)

--存放物品
    local btnInAll= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size=23, atlas='Crosshair_buy_64'})
    btnInAll:SetPoint('RIGHT', btnOutAll, 'LEFT', -2, 0)
    btnInAll:SetScript('OnClick', function(self)
        WoWTools_BankMixin:Take_Item(false, nil, nil, 1, false)
        self:show_tooltips()
    end)

    function btnInAll:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free=WoWTools_BankMixin:GetFree()--银行，空位
        e.tips:AddDoubleLine(e.onlyChinese and '存放所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GUILDCONTROL_DEPOSIT_ITEMS, ' ('..ALL..')'),
            format('|A:Banker:0:0|a%s #%s%d',
                e.onlyChinese and '银行' or BANK,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btnInAll:show_tooltips()
        C_Timer.After(1.5, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btnInAll:HookScript('OnLeave', GameTooltip_Hide)
    btnInAll:HookScript('OnEnter', btnInAll.set_tooltips)

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
    btnSort:SetScript('OnClick', function()
        C_Container.SortReagentBankBags()
    end)

--存放各种材料,系统自带
    ReagentBankFrame.DespositButton:ClearAllPoints()
    ReagentBankFrame.DespositButton:SetSize(26, 26)
    ReagentBankFrame.DespositButton:SetPoint('LEFT', btnSort, 'RIGHT', 2, 2)
    ReagentBankFrame.DespositButton:SetText('')
    ReagentBankFrame.DespositButton.Middle:Hide()
    ReagentBankFrame.DespositButton.Right:Hide()
    ReagentBankFrame.DespositButton.Left:Hide()
    ReagentBankFrame.DespositButton:SetNormalAtlas('Crosshair_buy_64')
    ReagentBankFrame.DespositButton:SetHighlightAtlas('auctionhouse-nav-button-select')
    ReagentBankFrame.DespositButton:SetPushedAtlas('auctionhouse-nav-button-select')
    ReagentBankFrame.DespositButton:HookScript('OnLeave', GameTooltip_Hide)
    ReagentBankFrame.DespositButton:HookScript('OnEnter', function(s)
        e.tips:SetOwner(s, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '存放各种材料' or REAGENTBANK_DEPOSIT)
        e.tips:Show()
    end)

--取出所有物品
    local btnAllOut= WoWTools_ButtonMixin:Cbtn(ReagentBankFrame.DespositButton, {size=23, atlas='Cursor_OpenHand_64'})
    btnAllOut:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', 2, 0)
    btnAllOut:SetScript('OnClick', function(self)
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
    btnAllOut:HookScript('OnEnter', btnAllOut.set_tooltips)

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
end





















local function Init_AccountBankPanel()

--添加，取出所有物品
    local btnAllOut= WoWTools_ButtonMixin:Cbtn(AccountBankPanel.ItemDepositFrame, {size=23, atlas='Cursor_OpenHand_64'})
    btnAllOut:SetPoint('TOPRIGHT', AccountBankPanel, -16, -31)

    btnAllOut:SetScript('OnClick', function(self)
        WoWTools_BankMixin:Take_Item(true, nil, nil, 3, false)
        self:show_tooltips()
    end)

    function btnAllOut:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()

        local selectedBankTabData = AccountBankPanel:GetTabData(AccountBankPanel.selectedTabID);
        if selectedBankTabData and selectedBankTabData.name then
            e.tips:AddLine(selectedBankTabData.name)
            e.tips:AddLine(" ")
        end

        local free= WoWTools_BagMixin:GetFree(C_CVar.GetCVarBool('bankAutoDepositReagents'))
        e.tips:AddDoubleLine(e.onlyChinese and '取出所有战团物品' or 'Take out all account bank',
            format('|A:4549254:0:0|a%s #%s%d',
                e.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )

        e.tips:Show()
    end
    function btnAllOut:show_tooltips()
        C_Timer.After(1, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btnAllOut:HookScript('OnLeave', GameTooltip_Hide)
    btnAllOut:HookScript('OnEnter', btnAllOut.set_tooltips)

--存放所有战团绑定物品    
    AccountBankPanel.ItemDepositFrame.DepositButton:ClearAllPoints()
    AccountBankPanel.ItemDepositFrame.DepositButton:SetPoint('RIGHT', btnAllOut, 'LEFT', -2, 0)
    AccountBankPanel.ItemDepositFrame.DepositButton:SetSize(24, 24)
    AccountBankPanel.ItemDepositFrame.DepositButton:SetText('')
    AccountBankPanel.ItemDepositFrame.DepositButton.Middle:Hide()
    AccountBankPanel.ItemDepositFrame.DepositButton.Right:Hide()
    AccountBankPanel.ItemDepositFrame.DepositButton.Left:Hide()
    AccountBankPanel.ItemDepositFrame.DepositButton:SetNormalAtlas('Crosshair_buy_64')
    AccountBankPanel.ItemDepositFrame.DepositButton:SetHighlightAtlas('auctionhouse-nav-button-select')
    AccountBankPanel.ItemDepositFrame.DepositButton:SetPushedAtlas('auctionhouse-nav-button-select')
    AccountBankPanel.ItemDepositFrame.DepositButton:HookScript('OnLeave', GameTooltip_Hide)
    AccountBankPanel.ItemDepositFrame.DepositButton:HookScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '存放所有战团绑定物品' or ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL)
        e.tips:Show()
    end)

--添加，整理
    local btnSort= CreateFrame("Button", 'WoWToolsAutoSortAccountBankButton', btnAllOut, 'BankAutoSortButtonTemplate')
    btnSort:SetSize(32, 32)
    btnSort:SetPoint('RIGHT', AccountBankPanel.ItemDepositFrame.DepositButton, 'LEFT', -2, 0)--整理材料银行
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
			C_Container.SortAccountBankBags();
		end
    end)
        --BankFrame_AutoSortButtonOnClick()
		    --StaticPopup_Show("BANK_CONFIRM_CLEANUP", nil, nil, { bankType = 2 });
        --C_Container.SortAccountBankBags()
    --end)





--包括可交易的材料
    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox:ClearAllPoints()
    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox:SetPoint('RIGHT', btnSort, 'LEFT')
    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox:HookScript('OnLeave', GameTooltip_Hide)
    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox:HookScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '包括可交易的材料' or BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL)
        e.tips:Show()
    end)
    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox.Text:SetText('')
    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox.Text:Hide()



--标签，名称
    AccountBankPanel.Header:ClearAllPoints()
    AccountBankPanel.Header:SetPoint('RIGHT', AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox, 'LEFT')

    AccountBankPanel.Header.Text:ClearAllPoints()
    AccountBankPanel.Header.Text:SetPoint('RIGHT')
    WoWTools_LabelMixin:Create(nil, {changeFont=AccountBankPanel.Header.Text, size=14, color=true, justifyH='RIGHT'})

    local texture= AccountBankPanel.Header:CreateTexture()
    texture:SetSize(22,22)
    texture:SetPoint('RIGHT', AccountBankPanel.Header.Text, 'LEFT',3,0)
    texture:SetAtlas('questlog-questtypeicon-account')

--标签，战团银行
    if AccountBankPanel.selectedTabID and AccountBankPanel.selectedTabID>=0 then
        local label= WoWTools_LabelMixin:Create(BankSlotsFrame, {size=14})
        label:SetPoint('TOP', AccountBankPanel, 0, -6)
        label:SetText(e.onlyChinese and '战团' or ACCOUNT_QUEST_LABEL)
    end


--钱    
    AccountBankPanel.MoneyFrame.Border:Hide()
    AccountBankPanel.MoneyFrame.MoneyDisplay:ClearAllPoints()
    AccountBankPanel.MoneyFrame.MoneyDisplay:SetPoint('BOTTOM', AccountBankPanel.MoneyFrame.DepositButton, 'TOPLEFT', 6, -2)

--背景    
    AccountBankPanel.Background=AccountBankPanel:CreateTexture(nil, 'BACKGROUND')
    AccountBankPanel.Background:SetAllPoints()
    --WoWTools_BankMixin:Set_Background_Texture(AccountBankPanel.Background)

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

    WoWTools_PlusTextureMixin:SetFrame(BankFrameTab1, {notAlpha=true})
    WoWTools_PlusTextureMixin:SetFrame(BankFrameTab2, {notAlpha=true})
    WoWTools_PlusTextureMixin:SetFrame(BankFrameTab3, {notAlpha=true})
    WoWTools_PlusTextureMixin:SetNineSlice(BankFrame, true, false, false, false)
end







function WoWTools_BankMixin:Init_UI()
   Init()
end