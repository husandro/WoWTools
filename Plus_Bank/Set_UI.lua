local e= select(2, ...)










local function Init_BankSlotsFrame()

--移动，整理按钮, 系统自带
    BankItemAutoSortButton:ClearAllPoints()
    BankItemAutoSortButton:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -6, 0)
    BankItemAutoSortButton:SetParent(BankSlotsFrame)
    BankItemAutoSortButton:SetSize(32, 32)


--添加，取出所有
    local btnOutAll= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size=23, icon='hide'})
    btnOutAll:SetNormalAtlas('Cursor_OpenHandGlow_64')
    btnOutAll:SetPoint('RIGHT', BankItemAutoSortButton, 'LEFT', -2, 0)
    btnOutAll:SetScript('OnClick', function(self)
        local free= WoWTools_BagMixin:GetFree()--背包，空位
        if free==0 then
            return
        end
        for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
            for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
                if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                    self:show_tooltips()
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end

        for i=NUM_BANKGENERIC_SLOTS, 1, -1 do--28
            if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                self:show_tooltips()
                return
            end
            local bag, slot= WoWTools_BankMixin:GetBagAndSlot(BankSlotsFrame["Item"..i])
            if bag and slot then
                local info= C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
        self:show_tooltips()
    end)
    function btnOutAll:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free= WoWTools_BagMixin:GetFree()--背包，空位
        e.tips:AddDoubleLine(e.onlyChinese and '取出所有物品' or 'Take out all items',
            format('|A:bag-main:0:0|a%s #%s%d',
                e.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btnOutAll:show_tooltips()
        C_Timer.After(1.5, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btnOutAll:HookScript('OnLeave', GameTooltip_Hide)
    btnOutAll:HookScript('OnEnter', btnOutAll.set_tooltips)


--存放物品
    local btnInAll= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size=23, icon='hide'})
    btnInAll:SetNormalAtlas('Crosshair_buy_64')
    btnInAll:SetPoint('RIGHT', btnOutAll, 'LEFT', -2, 0)
    btnInAll:SetScript('OnClick', function(self)
        local free= WoWTools_BankMixin:GetFree()--银行，空位
        if free==0 then
            return
        end
        for bag= NUM_BAG_FRAMES,  BACKPACK_CONTAINER, -1 do
            for slot= C_Container.GetContainerNumSlots(bag), 1, -1 do
                if not self:IsVisible() or IsModifierKeyDown() or free==0 then
                    self:show_tooltips()
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.hyperlink and not select(17, C_Item.GetItemInfo(info.hyperlink)) then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
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
    local label= WoWTools_LabelMixin:Create(btnInAll, {color=true, size=18})
    label:SetPoint('RIGHT', btnInAll, 'LEFT', 4,0)
    label:SetText(e.onlyChinese and '银行' or BANK)





    BankSlotsFrame.EdgeShadows:Hide()

    BankFrame:EnableDrawLayer('BACKGROUND')
    BankFrame.Background:ClearAllPoints()
    BankFrame.Background:SetPoint('TOPLEFT', BankFrame)
    BankFrame.Background:SetPoint('BOTTOMRIGHT', BankFrame)
    WoWTools_BankMixin:Set_Background_Texture(BankFrame.Background)


--背景
    BankFrameBg:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
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
    local btnAllOut= WoWTools_ButtonMixin:Cbtn(ReagentBankFrame.DespositButton, {size=23, icon='hide'})
    btnAllOut:SetNormalAtlas('Cursor_OpenHandGlow_64')
    btnAllOut:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', 2, 0)
    btnAllOut:SetScript('OnClick', function(self)
        local free= WoWTools_BagMixin:GetFree(true)
        if free==0 or not IsReagentBankUnlocked() then
            return
        end
        local tabs={}
        for _, frame in ReagentBankFrame:EnumerateItems() do
            table.insert(tabs, 1, frame)
        end
        for _, frame in pairs(tabs) do
            if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                self:show_tooltips()
                return
            end
            local bag, slot= WoWTools_BankMixin:GetBagAndSlot(frame)
            if bag and slot then
                local info= C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
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
    local label= WoWTools_LabelMixin:Create(btnAllOut, {color=true, size=18})
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
    local btnAllOut= WoWTools_ButtonMixin:Cbtn(AccountBankPanel, {size=23, icon='hide'})
    btnAllOut:SetNormalAtlas('Cursor_OpenHandGlow_64')
    btnAllOut:SetPoint('TOPRIGHT', -16, -26)

    btnAllOut:SetScript('OnClick', function(self)
        if self.isDoing then
            return
        end

        local isAll= C_CVar.GetCVarBool('bankAutoDepositReagents')--包括可交易的材料
        local free= WoWTools_BagMixin:GetFree(isAll)

        if free==0 or not C_PlayerInfo.HasAccountInventoryLock() then
            return
        end
        self.isDoing=true

        do
            for btn in AccountBankPanel:EnumerateValidItems() do
                if not self.isDoing or not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                    self:show_tooltips()
                    return
                end

                local bag, slot= btn:GetBankTabID(), btn:GetContainerSlotID()
                if bag and slot then
                    local info= C_Container.GetContainerItemInfo(bag, slot)
                    if info and info.itemID and (isAll or not select(10, C_Item.GetItemInfo(info.itemID))) then
                        do
                            C_Container.UseContainerItem(bag, slot)
                        end
                        free= free-1
                    end
                end
            end
        end
        self.isDoing=nil
        self:show_tooltips()
    end)
    function btnAllOut:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
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
    local btnSort= CreateFrame("Button", nil, AccountBankPanel, 'BankAutoSortButtonTemplate')
    btnSort:SetSize(32, 32)
    btnSort:SetPoint('RIGHT', AccountBankPanel.ItemDepositFrame.DepositButton, 'LEFT', -2, 0)--整理材料银行
    btnSort:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '清理战团银行' or BAG_CLEANUP_ACCOUNT_BANK)
        e.tips:Show()
    end)
    btnSort:SetScript('OnClick', function()
		    --StaticPopup_Show("BANK_CONFIRM_CLEANUP", nil, nil, { bankType = 2 });
        C_Container.SortAccountBankBags()
    end)





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
    --[[AccountBankPanel.Background=AccountBankPanel:CreateTexture(nil, 'BACKGROUND')
    AccountBankPanel.Background:SetAllPoints()
    WoWTools_BankMixin:Set_Background_Texture(AccountBankPanel.Background)]]

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
end




















--打开，银行，背包
local function Init_OpenAllBag_Button()
    local parent= BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS]



    local up= CreateFrame("Button", ('WoWToolsBankOpenAllBagButton'), parent)
    up:SetSize(23,23)
    up:SetNormalAtlas('128-RedButton-ArrowUpGlow')
    up:SetPushedAtlas('128-RedButton-ArrowUpGlow-Pressed')
    up:SetHighlightAtlas('Callings-BackHighlight')
    up:SetDisabledAtlas('128-RedButton-ArrowUpGlow-Disabled')
    up:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)

    up:SetPoint('BOTTOMLEFT', parent, 'RIGHT', 4, -3)
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


    local down= CreateFrame("Button", ('WoWToolsBankCloseAllBagButton'), parent)--ObjectiveTrackerContainerFilterButtonTemplate
    down:SetSize(23,23)
    down:SetNormalAtlas('128-RedButton-ArrowDown')
    down:SetPushedAtlas('128-RedButton-ArrowDown-Pressed')
    down:SetHighlightAtlas('128-RedButton-ArrowDown-Highlight')
    down:SetDisabledAtlas('128-RedButton-ArrowDown-Disabled')
    down:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)

    down:SetPoint('TOPLEFT', parent, 'RIGHT', 4, -3)
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


    hooksecurefunc('BankFrame_UpdateAnchoringForPanel', function()
        --local index= BankFrame.activeTabIndex
--移动，搜索框
        BankItemSearchBox:ClearAllPoints()
        BankItemSearchBox:SetPoint('TOP', 0,-33)
--与，战团边框
        --BankFrame.NineSlice.RightEdge:SetShown(index~=1)
        --BankFrame.NineSlice.TopRightCorner:SetShown(index~=1)
        --BankFrame.NineSlice.BottomRightCorner:SetShown(index~=1)
    end)


    WoWTools_PlusTextureMixin:SetFrame(BankFrameTab1, {notAlpha=true})
    WoWTools_PlusTextureMixin:SetFrame(BankFrameTab2, {notAlpha=true})
    WoWTools_PlusTextureMixin:SetFrame(BankFrameTab3, {notAlpha=true})
    WoWTools_PlusTextureMixin:SetNineSlice(BankFrame, true, false, false, false)

--钱    
    BankFrameMoneyFrameBorder:Hide()
    BankFrameMoneyFrame:ClearAllPoints()
    if IsReagentBankUnlocked() then
        BankFrameMoneyFrame:SetPoint('RIGHT', OptionButton, 'LEFT')
    else
        BankFrameMoneyFrame:SetPoint('BOTTOM', BankFrame, 'TOP')
        WoWTools_TextureMixin:CreateBackground(BankFrameMoneyFrame, {isAllPoint=true})
    end
    BankFrameMoneyFrame:SetFrameStrata(OptionButton:GetFrameStrata())
    BankFrameMoneyFrame:SetFrameLevel(OptionButton:GetFrameLevel()+1)

    BankFrameMoneyFrameGoldButton:HookScript("OnLeave", ResetCursor)
    BankFrameMoneyFrameGoldButton:HookScript('OnEnter', function()
        SetCursor('Interface\\Cursor\\Cast.blp')--Redlist.xml
    end)

    BankFrameMoneyFrameSilverButton:HookScript("OnLeave", ResetCursor)
    BankFrameMoneyFrameSilverButton:HookScript('OnEnter', function()
        SetCursor('Interface\\Cursor\\Cast.blp')--Redlist.xml
    end)

    BankFrameMoneyFrameCopperButton:HookScript("OnLeave", ResetCursor)
    BankFrameMoneyFrameCopperButton:HookScript('OnEnter', function()
        SetCursor('Interface\\Cursor\\Cast.blp')--Redlist.xml
    end)
end







function WoWTools_BankMixin:Init_UI()
   Init()
end