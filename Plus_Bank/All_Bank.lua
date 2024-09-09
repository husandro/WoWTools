--整合，一起
local e= select(2, ...)

local function Save()
    return WoWTools_ButtonMixin.Save
end


local function Init()
    local SetAllBank= WoWTools_ButtonMixin:Cbtn(BankFrame.TitleContainer, {size={22,22}, icon=true, name='WoWTools_SetAllBankButton'})
    SetAllBank:SetAlpha(0.5)
    if _G['MoveZoomInButtonPerBankFrame'] then
        SetAllBank:SetPoint('RIGHT', _G['MoveZoomInButtonPerBankFrame'], 'LEFT')
    else
        SetAllBank:SetPoint('LEFT', 12,0)
    end
    function SetAllBank:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_ButtonMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS)..' |cnGREEN_FONT_COLOR:'..Save().num, e.Icon.mid)
        e.tips:AddDoubleLine((e.onlyChinese and '间隔' or 'Interval')..' |cnGREEN_FONT_COLOR:'..Save().line, 'Alt+'..e.Icon.mid)
        e.tips:Show()
        self:SetAlpha(1)
    end
    --设置，背景

    function SetAllBank:set_background()
        if Save().showBackground~=nil then
            if Save().showBackground then
                BankFrame:DisableDrawLayer('BACKGROUND')

                BankFrame.Background:ClearAllPoints()
                BankFrame.Background:SetAllPoints()
                BankFrame.Background:SetAtlas('bank-frame-background')
            else
                BankFrame:EnableDrawLayer('BACKGROUND')
                BankFrame.Background:ClearAllPoints()
                BankFrame.Background:SetPoint('TOPLEFT', BankFrame)
                BankFrame.Background:SetPoint('BOTTOMRIGHT', BankFrame)
                BankFrame.Background:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
            end
        end
    end

    SetAllBank:SetScript('OnMouseWheel', function(self, d)
        if not IsModifierKeyDown() then
            local n= Save().num
            if d==1 then
                n= n-1
            elseif d==-1 then
                n=n +1
            end
            n= n<4 and 4 or n
            n= n>24 and 24 or n
            Save().num= n
        elseif IsAltKeyDown() then
            local n= Save().line
            if d==1 then
                n= n-1
            elseif d==-1 then
                n= n+1
            end
            n=n<0 and 0 or n
            n=n>24 and 24 or n
            Save().line= n
        end

        self:set_bank()--设置，银行，按钮
        self:set_reagent()--设置，材料，按钮
        self:set_size()--设置，外框，大小
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
    function SetAllBank:set_bank()
        self.last=nil
        self.num=0
        local last
        local tab={}
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

        local num=0
        local bagindex
        local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES
        for i=1, NUM_BANKBAGSLOTS do
            local bag= i+ numBag
            bagindex= bagindex and bagindex+1 or bag
            local bagFrame= _G['ContainerFrame'..bag]
            local bagID= bagFrame and bagFrame:GetID() or 0
            if bagFrame and bagID>= numBag then

                bagFrame:ClearAllPoints()
                bagFrame:SetPoint('RIGHT', UIParent, 'LEFT', -40, 0)
                if not bagFrame.isHideFrame then
                    bagFrame.isHideFrame=true
                    bagFrame:HookScript('OnShow', function(f)
                        f:Hide()
                    end)
                end

               for _, btn in bagFrame:EnumerateValidItems()  do
                    if btn then
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
    function SetAllBank:set_reagent()
        self.reagentNum= 0
        local btnNum=0
        for index, btn in ReagentBankFrame:EnumerateItems() do
            btn:ClearAllPoints()
            if index==1 then
                if BankFrame.activeTabIndex==2 then
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
        self.last=nil
    end


    function SetAllBank:set_size()--设置，外框，大小
        if BankFrame.activeTabIndex==1 then
            local num= SetAllBank.num + SetAllBank.reagentNum
            BankFrame:SetSize(8+num*37+((num-1)*Save().line)+8+8+2, (Save().num+1)*37 +((Save().num-1)*Save().line)+64+8+6)
        elseif BankFrame.activeTabIndex==2 then
            local num= SetAllBank.reagentNum
            BankFrame:SetSize(8+(num*38)+((num-1)*Save().line), 64+(Save().num*37)+(Save().num*Save().line)+8)--设置，大小
        end
    end





    hooksecurefunc('BankFrame_ShowPanel', function()
        if BankFrame.activeTabIndex==1 then
            ReagentBankFrame:SetShown(true)
            SetAllBank:set_bank()--设置，银行，按钮
            SetAllBank:set_reagent()--设置，材料，按钮

        elseif BankFrame.activeTabIndex==2 then
            local btn= ReagentBankFrame["Item1"]
            if btn then
                btn:ClearAllPoints()
                btn:SetPoint('TOPLEFT', 8,-60)
            end
        end
        SetAllBank:set_size()--设置，外框，大小
        if not IsReagentBankUnlocked() and ReagentBankFrame.UnlockInfo then
            ReagentBankFrame.UnlockInfo:SetShown(BankFrame.activeTabIndex==2)
        end

    end)


    hooksecurefunc('BankFrameItemButtonBag_OnClick', function()
        SetAllBank:set_bank()--设置，银行，按钮
        SetAllBank:set_reagent()--设置，材料，按钮
        SetAllBank:set_size()--设置，外框，大小
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
    end)
    SetAllBank:set_bank()--设置，银行，按钮
    SetAllBank:set_background()--设置，背景












    ReagentBankFrame.NineSlice:Hide()
    if BankFrameMoneyFrameBorder then
        BankFrameMoneyFrameBorder:Hide()
    end

    --隐藏，ITEMSLOTTEXT"物品栏位" BAGSLOTTEXT"背包栏位"
    for _, region in pairs({BankSlotsFrame:GetRegions()}) do
        if region:GetObjectType()=='FontString' then
            region:SetText('')
            region:Hide()
        end
    end


    hooksecurefunc('BankFrame_UpdateAnchoringForPanel', function()
        BankItemSearchBox:ClearAllPoints()--移动，搜索框
        BankItemSearchBox:SetPoint('TOP', 0,-33)
    end)



    ReagentBankFrame:HookScript('OnShow', function(self)
        if self.isSetPoint then--or not IsReagentBankUnlocked() then
            return
        end
        self.isSetPoint=true


        for _, region in pairs({ReagentBankFrame:GetRegions()}) do--隐藏，材料包，背景
            if region:GetObjectType()=='Texture' then
                region:SetTexture(0)
                region:Hide()
            end
        end

        BankItemAutoSortButton:ClearAllPoints()--移动，整理，按钮
        BankItemAutoSortButton:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -6, 0)
        BankItemAutoSortButton:SetParent(BankSlotsFrame)

        ReagentBankFrame.autoSortButton:SetPoint('LEFT', BankItemSearchBox, 'RIGHT', 2, 0)--整理材料银行

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












function WoWTools_ButtonMixin:Init_All_Bank()
    Init()
    C_Timer.After(4, self.Init_DespositTakeOut_List)--分类，存取, 2秒为翻译加载时间
end