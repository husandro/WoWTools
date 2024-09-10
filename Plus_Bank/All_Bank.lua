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
        end
        bagFrame:HookScript('OnShow', bagFrame.set_point_toleft)
    end
    bagFrame:set_point_toleft()
end

















local function Init_Button()
    local SetAllBank= WoWTools_ButtonMixin:Cbtn(BankFrame.TitleContainer, {size={22,22}, icon=true, name='WoWTools_SetAllBankButton'})

    SetAllBank:SetAlpha(0.5)
    SetAllBank:SetPoint('LEFT', 12,0)

    function SetAllBank:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_BankFrameMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS)..' |cnGREEN_FONT_COLOR:'..Save().num, e.Icon.mid)
        e.tips:AddDoubleLine((e.onlyChinese and '间隔' or 'Interval')..' |cnGREEN_FONT_COLOR:'..Save().line, 'Alt+'..e.Icon.mid)
        e.tips:Show()
        self:SetAlpha(1)
    end

    SetAllBank:SetScript('OnMouseWheel', function(self, d)
        if not IsModifierKeyDown() then--行数
            local n= Save().num
            if d==1 then
                n= n-1
            elseif d==-1 then
                n=n +1
            end
            n= n<4 and 4 or n
            n= n>32 and 32 or n
            Save().num= n
        elseif IsAltKeyDown() then
            local n= Save().line
            if d==1 then
                n= n-1
            elseif d==-1 then
                n= n+1
            end
            n=n<0 and 0 or n
            n=n>32 and 32 or n
            Save().line= n
        end

        self:settings()
        self:set_tooltips()
    end)

    



    SetAllBank:SetScript('OnLeave', function(self) self:SetAlpha(0.5) e.tips:Hide() end)
    SetAllBank:SetScript('OnEnter', SetAllBank.set_tooltips)


    --索引，提示
    function SetAllBank:set_index_label(btn, index)
        if not btn.indexLable and Save().showIndex then
            btn.indexLable= e.Cstr(btn, {layer='BACKGROUND', color={r=1,g=1,b=1}})
            btn.indexLable:SetPoint('CENTER')
            btn.indexLable:SetAlpha(0.2)
        end
        if btn.indexLable then
            btn.indexLable:SetText(Save().showIndex and index or '')
        end
    end

















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
                self:set_index_label(btn, i)--索引，提示
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
                        self:set_index_label(btn, num+NUM_BANKGENERIC_SLOTS)--索引，提示
                    else
                        btn:SetShown(false)
                    end
                    
               end
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
                table.insert(tab, btn)
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


    end










    --设置，材料，按钮
    function SetAllBank:set_reagent(tabindex)
        self.reagentNum= 0
        local btnNum=0
        for index, btn in ReagentBankFrame:EnumerateItems() do
            btn:ClearAllPoints()
            if index==1 then
                if tabindex==2 then
                    btn:ClearAllPoints()
                    btn:SetPoint('TOPLEFT', 8,-60)
                else
                    btn:SetPoint('LEFT', self.last, 'RIGHT', Save().line+6, 0)
                end
                self.last=btn
                self.reagentNum= self.reagentNum+1
            else
                btn:SetPoint('TOP', ReagentBankFrame["Item"..(index-1)], 'BOTTOM', 0, -Save().line)
            end
            if not btn.Bg then
                btn.Bg= btn:CreateTexture(nil, 'BACKGROUND')
                btn.Bg:SetAllPoints(btn)
                btn.Bg:SetAtlas('ChallengeMode-DungeonIconFrame')
                btn.Bg:SetAlpha(0.5)
            end
            self:set_index_label(btn, index)--索引，提示
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












--设置，外框，大小
    function SetAllBank:set_size(tabindex)
        if tabindex==1 then
            local num= SetAllBank.num + SetAllBank.reagentNum
            BankFrame:SetSize(
                8+(num*37)+((num-1)*Save().line)+8+8+2,
                (Save().num+1)*37 +((Save().num-1)*Save().line)+64+8+6
            )

        elseif tabindex==2 then
            local num= SetAllBank.reagentNum
            BankFrame:SetSize(
                8+(num*37)+((num-1)*Save().line),
                64+(Save().num*37)+(Save().num*Save().line)+8
            )
        end
    end







    function SetAllBank:settings(tabindex)
        tabindex= tabindex or BankFrame.activeTabIndex
        if tabindex==1 then
            do
                ReagentBankFrame:SetShown(true)
                AccountBankPanel:SetShown(true)
            end
            do self:set_bank() end
            do self:set_reagent(1) end

        elseif tabindex==2 then
            do self:set_reagent(2) end
        end
        SetAllBank:set_size(tabindex)--设置，外框，大小
    end




    hooksecurefunc('BankFrame_ShowPanel', function()
        local index= BankFrame.activeTabIndex
        if index==1 then
            ReagentBankFrame:SetShown(true)
            AccountBankPanel:SetShown(true)
        elseif index==2 then
        elseif index==3 then
        end
        SetAllBank:settings(index)
        if not IsReagentBankUnlocked() and ReagentBankFrame.UnlockInfo then
            ReagentBankFrame.UnlockInfo:SetShown(BankFrame.activeTabIndex==2)
        end
    end)

    hooksecurefunc('BankFrameItemButtonBag_OnClick', function()
        SetAllBank:settings()
    end)

    BankFramePurchaseButton:SetWidth(BankFramePurchaseButton:GetFontString():GetWidth()+12)

    hooksecurefunc('UpdateBagSlotStatus', function()
        if BankFramePurchaseInfo then
            BankFramePurchaseInfo:ClearAllPoints()
            BankFramePurchaseInfo:SetPoint('Top', BankFrame, 'BOTTOM')
            BankFramePurchaseButton:ClearAllPoints()
            if BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS] then
                BankFramePurchaseButton:SetPoint('LEFT', BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS], 'RIGHT', 2,0)
            else
                BankFramePurchaseButton:SetPoint('BOTTOM', BankFrame)
            end
        end
        SetAllBank:settings()
    end)


    hooksecurefunc(AccountBankPanel, 'GenerateItemSlotsForSelectedTab',function()
        local last
        local tab={}
        local num=0
        local index=0
        for btn in AccountBankPanel:EnumerateValidItems() do
            index= index+1
            btn:ClearAllPoints()
            if index==1 then
                btn:SetPoint("TOPLEFT", AccountBankPanel, "TOPLEFT", 0, -63)
                num= 1
            else
                btn:SetPoint('TOP', last, 'BOTTOM', 0, -Save().line)
            end
            last=btn
            table.insert(tab, btn)
        end
        
        last= tab[1]
        for i=Save().num+1, index, Save().num do
            num= num+1
            local btn= tab[i]
            btn:ClearAllPoints()
            btn:SetPoint('LEFT', last, 'RIGHT', Save().line, 0)
            last= btn
        end

        local tabindex= BankFrame.activeTabIndex
        if tabindex==1 then
            AccountBankPanel:ClearAllPoints()
            AccountBankPanel:SetPoint('TOPLEFT', BankFrame, 'TOPRIGHT')
                      
            AccountBankPanel:SetSize(
                8+(num*38)+((num-1)*Save().line),
                64+(Save().num*37)+(Save().num*Save().line)+8+64+6
            )
        elseif tabindex==3 then
            BankFrame:SetSize(
                8+(num*37)+((num-1)*Save().line)+8+8+2,
                (Save().num+1)*37 +((Save().num-1)*Save().line)+64+8+6+64
            )
            AccountBankPanel:ClearAllPoints()
            AccountBankPanel:SetAllPoints()
        end
    end)


    SetAllBank:set_bank()--设置，银行，按钮
end
































local function Init()
    ReagentBankFrame.NineSlice:Hide()
    BankFrameMoneyFrameBorder:Hide()
    AccountBankPanel.MoneyFrame.Border:Hide()

--隐藏，ITEMSLOTTEXT"物品栏位" BAGSLOTTEXT"背包栏位"
    for _, region in pairs({BankSlotsFrame:GetRegions()}) do
        if region:GetObjectType()=='FontString' then
            region:SetText('')
            region:Hide()
        end
    end

--移动，搜索框
    hooksecurefunc('BankFrame_UpdateAnchoringForPanel', function()
        BankItemSearchBox:ClearAllPoints()
        BankItemSearchBox:SetPoint('TOP', 0,-33)
    end)


--隐藏，材料包，背景
    ReagentBankFrame:HookScript('OnShow', function(self)
        if self.isSetPoint then--or not IsReagentBankUnlocked() then
            return
        end
        self.isSetPoint=true
        for _, region in pairs({ReagentBankFrame:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetTexture(0)
                region:Hide()
            end
        end

--移动，整理，按钮
        BankItemAutoSortButton:ClearAllPoints()
        BankItemAutoSortButton:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -6, 0)
        BankItemAutoSortButton:SetParent(BankSlotsFrame)
        ReagentBankFrame.autoSortButton:SetPoint('LEFT', BankItemSearchBox, 'RIGHT', 2, 0)--整理材料银行


--存放各种材料
        ReagentBankFrame.DespositButton:ClearAllPoints()
        ReagentBankFrame.DespositButton:SetSize(23, 23)
        ReagentBankFrame.DespositButton:SetPoint('LEFT', ReagentBankFrame.autoSortButton, 'RIGHT', 2, 0)
        ReagentBankFrame.DespositButton:SetText('')
        ReagentBankFrame.DespositButton.Middle:Hide()
        ReagentBankFrame.DespositButton.Right:Hide()
        ReagentBankFrame.DespositButton.Left:Hide()
        ReagentBankFrame.DespositButton:SetNormalAtlas('poi-traveldirections-arrow')
        ReagentBankFrame.DespositButton:GetNormalTexture():SetTexCoord(0,1,1,0)
        ReagentBankFrame.DespositButton:SetHighlightAtlas('auctionhouse-nav-button-select')
        ReagentBankFrame.DespositButton:SetPushedAtlas('auctionhouse-nav-button-select')
        ReagentBankFrame.DespositButton:HookScript('OnLeave', GameTooltip_Hide)
        ReagentBankFrame.DespositButton:HookScript('OnEnter', function(s)
            e.tips:SetOwner(s, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '存放各种材料' or REAGENTBANK_DEPOSIT)
            e.tips:Show()
        end)
    end)
end











--整合
function WoWTools_BankFrameMixin:Init_All_Bank()
    Init_Button()
    Init()
    
    --WoWTools_ButtonMixin:CreateButton(3)

    --显示背景 Background
    WoWTools_TextureMixin:CreateBackground(AccountBankPanel, {isAllPoint=true, alpha=1})

    --AccountBankPanel.Header.Text:ClearAllPoints()
    --AccountBankPanel.Header.Text:SetPoint('LEFT', AccountBankPanel.Header)

end

