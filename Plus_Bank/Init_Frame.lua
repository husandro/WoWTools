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
    --local btnInAll= WoWTools_ButtonMixin:CreateBagButton(BankSlotsFrame, 'WoWTools_BankBagAllButton', nil)
    --btnInAll:SetNormalAtlas('poi-traveldirections-arrow')
    --btnInAll:GetNormalTexture():SetTexCoord(0,1,1,0)
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

    local label= e.Cstr(BankSlotsFrame, {color=true, size=18})
    label:SetPoint('RIGHT', btnInAll, 'LEFT')
    label:SetText(e.onlyChinese and '银行' or BANK)




    
    BankSlotsFrame.EdgeShadows:Hide()

    BankFrame:EnableDrawLayer('BACKGROUND')
    BankFrame.Background:ClearAllPoints()
    BankFrame.Background:SetPoint('TOPLEFT', BankFrame)
    BankFrame.Background:SetPoint('BOTTOMRIGHT', BankFrame)    
    WoWTools_BankFrameMixin:Set_Background_Texture(BankFrame.Background)

    
--隐藏，背景
    BankFrameBg:SetTexture(0)


--隐藏，ITEMSLOTTEXT"物品栏位" BAGSLOTTEXT"背包栏位"
    for _, region in pairs({BankSlotsFrame:GetRegions()}) do
        if region:GetObjectType()=='FontString' then
            region:SetText('')
        end
    end

--钱    
    BankFrameMoneyFrameBorder:Hide()

    e.Set_Alpha_Frame_Texture(ReagentBankFrame.EdgeShadows, {})
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
    --ReagentBankFrame.DespositButton:SetNormalAtlas('poi-traveldirections-arrow')
    --ReagentBankFrame.DespositButton:GetNormalTexture():SetTexCoord(0,1,1,0)
    ReagentBankFrame.DespositButton:SetHighlightAtlas('auctionhouse-nav-button-select')
    ReagentBankFrame.DespositButton:SetPushedAtlas('auctionhouse-nav-button-select')
    ReagentBankFrame.DespositButton:HookScript('OnLeave', GameTooltip_Hide)
    ReagentBankFrame.DespositButton:HookScript('OnEnter', function(s)
        e.tips:SetOwner(s, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '存放各种材料' or REAGENTBANK_DEPOSIT)
        e.tips:Show()
    end)

    local btnR= WoWTools_ButtonMixin:Cbtn(ReagentBankFrame.DespositButton, {size=23, icon='hide'})
    btnR:SetNormalAtlas('Cursor_OpenHandGlow_64')
    --btnR:SetNormalAtlas('poi-traveldirections-arrow')
    --btnR:GetNormalTexture():SetTexCoord(1,0,1,0)
    btnR:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', 2, 0)

    function btnR:get_bag_slot(frame)
        return frame.isBag and Enum.BagIndex.Bankbag or frame:GetParent():GetID(), frame:GetID()
    end

    btnR:SetScript('OnClick', function(self)
        local free= WoWTools_BagMixin:GetFree(true)--self:get_free()
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
    function btnR:set_tooltips()
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
    function btnR:show_tooltips()
        C_Timer.After(1, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btnR:HookScript('OnLeave', GameTooltip_Hide)
    btnR:HookScript('OnEnter', btnR.set_tooltips)


   

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
end















local function Init_AccountBankPanel()
--存放所有战团绑定物品    
    AccountBankPanel.ItemDepositFrame.DepositButton:SetPoint('BOTTOM', 0, 12)--原 10
    AccountBankPanel.ItemDepositFrame.DepositButton:SetSize(26, 26)
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
    local btnSort= CreateFrame("Button", nil, AccountBankPanel.ItemDepositFrame.DepositButton, 'BankAutoSortButtonTemplate')
    btnSort:SetSize(34, 34)
    btnSort:SetPoint('RIGHT', AccountBankPanel.ItemDepositFrame.DepositButton, 'LEFT', 0, -2)--整理材料银行
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

    
    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox.Text:SetText('')
    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox.Text:Hide()
    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox:HookScript('OnLeave', GameTooltip_Hide)
    AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox:HookScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '包括可交易的材料' or BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL)
        e.tips:Show()
    end)

--移动Frame    
    e.Set_Move_Frame(AccountBankPanel, {frame=BankFrame})

--钱    
    AccountBankPanel.MoneyFrame.Border:Hide()

--背景    
    AccountBankPanel.Background=AccountBankPanel:CreateTexture(nil, 'BACKGROUND')
    AccountBankPanel.Background:SetAllPoints()
    WoWTools_BankFrameMixin:Set_Background_Texture(AccountBankPanel.Background)

--标签，名称
    AccountBankPanel.Header:ClearAllPoints()
    AccountBankPanel.Header:SetPoint('TOPRIGHT', -8, -32)

    AccountBankPanel.Header.Text:ClearAllPoints()
    AccountBankPanel.Header.Text:SetPoint('RIGHT')
    e.Cstr(nil, {changeFont=AccountBankPanel.Header.Text, size=22, color=true, justifyH='RIGHT'})

end














--打开，银行，背包
local function Init_OpenAllBag_Button()
    local parent= BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS]
    if not parent then
        return
    end

    local up=  WoWTools_ButtonMixin:CreateUpButton(parent, nil, nil)
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
        WoWTools_BankFrameMixin:Settings_All_Bank()--设置，整合银行
    end)

    local down=  WoWTools_ButtonMixin:CreateDownButton(parent, nil, nil)
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
        WoWTools_BankFrameMixin:Settings_All_Bank()--设置，整合银行
    end)
end









local function Init()
    Init_BankSlotsFrame()
    Init_ReagentBankFrame()
    Init_AccountBankPanel()

    Init_OpenAllBag_Button()    

    hooksecurefunc('BankFrame_UpdateAnchoringForPanel', function()
--移动，搜索框
        --local index= BankFrame.activeTabIndex
        
            BankItemSearchBox:ClearAllPoints()
            BankItemSearchBox:SetPoint('TOP', 0,-33)
    end)

    e.Set_Alpha_Frame_Texture(BankFrameTab1, {notAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab2, {notAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab3, {notAlpha=true})
end







function WoWTools_BankFrameMixin:Init_Frame()
   Init()
end