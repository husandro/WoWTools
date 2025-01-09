local e= select(2, ...)

local function Save()
    return WoWTools_SellBuyMixin.Save
end
















--商人 Plus, 加宽，物品，信息
local function Create_ItemButton()
    for i= 1, max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do--建立，索引，文本
        local btn= _G['MerchantItem'..i] or CreateFrame('Frame', 'MerchantItem'..i, MerchantFrame, 'MerchantItemTemplate', i)
        if not btn.IndexLable then
            btn.IndexLable= WoWTools_LabelMixin:Create(btn)
            btn.IndexLable:SetPoint('TOPRIGHT', btn, -1, 4)
            btn.IndexLable:SetAlpha(0.3)
            --btn.IndexLable:SetText(i)
            --建立，物品，背景
            btn.itemBG= btn:CreateTexture(nil, 'BACKGROUND')
            btn.itemBG:SetAtlas('ChallengeMode-guild-background')
            btn.itemBG:SetSize(100,43)
            btn.itemBG:SetPoint('TOPRIGHT',-7,-2)
            btn.itemBG:Hide()
            btn.ItemButton:HookScript('OnEnter', function(self)
                if MerchantFrame.selectedTab == 1 then
                    if self.hasItem then
                        WoWTools_BagMixin:Find(true, {itemName=self.name})
                    end
                elseif MerchantFrame.selectedTab == 2 then
                    WoWTools_BagMixin:Find(true, {BuybackIndex=self:GetID()})
                end
            end)
            btn.ItemButton:HookScript('OnLeave', function(self)
                if MerchantFrame.selectedTab == 1 then
                    if self.hasItem then
                        WoWTools_BagMixin:Find(false)
                    end
                elseif MerchantFrame.selectedTab == 2 then
                    local name= GetBuybackItemInfo(self:GetID())
                    if name then
                        WoWTools_BagMixin:Find(false)
                    end
                end
            end)
        end
    end

    local index= MERCHANT_ITEMS_PER_PAGE+1

    while _G['MerchantItem'..index] do--隐藏，多余
        _G['MerchantItem'..index]:SetShown(false)
        local itemButton = _G["MerchantItem"..index.."ItemButton"]
        itemButton.price = nil
        itemButton.hasItem = nil
        itemButton.name = nil
        itemButton.extendedCost = nil
        itemButton.link = nil
        itemButton.texture = nil
        _G["MerchantItem"..index.."Name"]:SetText("")
        index= index+1
    end
end


















local function Init_WidthX2()
    if C_AddOns.IsAddOnLoaded("CompactVendor") then
        print(e.addName, WoWTools_SellBuyMixin.addName, format(e.onlyChinese and "|cffff0000与%s发生冲突！|r" or ALREADY_BOUND, 'CompactVendor'), e.onlyChinese and '插件' or ADDONS)
    end

    MERCHANT_ITEMS_PER_PAGE= Save().MERCHANT_ITEMS_PER_PAGE or MERCHANT_ITEMS_PER_PAGE or 24
    Create_ItemButton()

    --物品数量
    MerchantFrameTab1.numLable= WoWTools_LabelMixin:Create(MerchantFrameTab1)
    MerchantFrameTab1.numLable:SetPoint('TOPRIGHT')
    MerchantFrame:HookScript('OnShow', function()
        local num= GetMerchantNumItems()
        MerchantFrameTab1.numLable:SetText(num and num>0 and num or '')
    end)

    --回购，数量，提示
    MerchantFrameTab2.numLable= WoWTools_LabelMixin:Create(MerchantFrameTab2)
    MerchantFrameTab2.numLable:SetPoint('TOPRIGHT')
    function MerchantFrameTab2:set_buyback_num()
        local num
        num= GetNumBuybackItems() or 0
        if num>0 then
            num= num==BUYBACK_ITEMS_PER_PAGE and '|cnRED_FONT_COLOR:'..num or num
        else
            num= ''
        end
        self.numLable:SetText(num)
    end












    --卖
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo', function()
        if not MerchantFrame:IsShown() then
            return
        end
        local w, h= 172, 146+(Save().numLine*52)--<Size x="336" y="444"/> <Size x="153" y="44"/>
        for i = 1, max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do
            local btn= _G['MerchantItem'..i]
            if i<=MERCHANT_ITEMS_PER_PAGE then
                btn:SetShown(true)
                btn.itemBG:SetShown(btn.ItemButton.hasItem)--Texture.lua
                if i>1 then
                    btn:ClearAllPoints()
                    btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-1)], 'BOTTOMLEFT', 0, -8)
                end
            else
                btn:Hide()
            end
            if btn.IndexLable then
                btn.IndexLable:SetText(btn.ItemButton.hasItem and btn.ItemButton:GetID() or '')
            end
        end
        local line= MerchantFrame.ResizeButton and Save().numLine or 6
        for i= line+1, MERCHANT_ITEMS_PER_PAGE, line do
            local btn= _G['MerchantItem'..i]
            btn:ClearAllPoints()
            btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-line)], 'TOPRIGHT', 8, 0)
            w= w+161
        end
        MerchantFrame:SetSize(max(w, 336), max(h, 440))
        WoWTools_SellBuyMixin:Set_Merchant_Info()--设置, 提示, 信息
        MerchantFrameTab2:set_buyback_num()--回购，数量，提示
        if MerchantFrame.ResizeButton then
            MerchantFrame.ResizeButton.setSize=true
        end
    end)












    --回购
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', function()
        local numBuybackItems = GetNumBuybackItems() or 0
        for i = 1, max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do
            local btn= _G['MerchantItem'..i]
            if i<= BUYBACK_ITEMS_PER_PAGE then
                btn:SetShown(true)
                if i>1 then
                    btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-1)], 'BOTTOMLEFT', 0, -8)
                end
                btn.itemBG:SetShown(numBuybackItems>=i)
            else
                btn:SetShown(false)
            end
        end
        _G['MerchantItem7']:SetPoint('TOPLEFT', _G['MerchantItem1'], 'TOPRIGHT', 8, 0)

        MerchantFrame:SetSize(336, 440)
        WoWTools_SellBuyMixin:Set_Merchant_Info()--设置, 提示, 信息
        MerchantFrameTab2:set_buyback_num()--回购，数量，提示
        if MerchantFrame.ResizeButton then
            MerchantFrame.ResizeButton.setSize=nil
        end
    end)

    --重新设置，按钮
    hooksecurefunc('MerchantFrame_UpdateRepairButtons', function()
        MerchantRepairItemButton:ClearAllPoints()--单个，修理
        MerchantRepairItemButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -289, 33)
        MerchantRepairAllButton:ClearAllPoints()--全部，修理
        MerchantRepairAllButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -241, 33)
        MerchantGuildBankRepairButton:ClearAllPoints()--公会，修理
        MerchantGuildBankRepairButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -193, 33)
        MerchantSellAllJunkButton:ClearAllPoints()--出售垃圾，修理
        MerchantSellAllJunkButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -145, 33)--36
    end)
    MerchantBuyBackItem:ClearAllPoints()--回购
    MerchantBuyBackItem:SetPoint('BOTTOMRIGHT', MerchantFrame, -16, 33)--115

    MerchantNextPageButton:ClearAllPoints()--下一页
    MerchantNextPageButton:SetPoint('RIGHT', MerchantFrame.FilterDropdown, 'LEFT', 4, 0)
    MerchantNextPageButton:SetFrameStrata('HIGH')
    local label, texture= MerchantNextPageButton:GetRegions()
    if texture and texture:GetObjectType()=='Texture' then texture:Hide() texture:SetTexture(0) end
    if label and label:GetObjectType()=='FontString' then label:Hide() label:SetText('') end

    MerchantPrevPageButton:ClearAllPoints()--上一页
    MerchantPrevPageButton:SetPoint('RIGHT', MerchantNextPageButton, 'LEFT',8,0)
    label, texture= MerchantPrevPageButton:GetRegions()
    if texture and texture:GetObjectType()=='Texture' then texture:Hide() texture:SetTexture(0) end
    if label and label:GetObjectType()=='FontString' then label:Hide() label:SetText('') end

    MerchantPageText:ClearAllPoints()--上页数
    MerchantPageText:SetPoint('RIGHT', MerchantPrevPageButton, 'LEFT', 0, 0)
    MerchantPageText:SetJustifyH('RIGHT')

    MerchantFrameBottomLeftBorder:ClearAllPoints()--外框
    MerchantFrameBottomLeftBorder:SetPoint('BOTTOMRIGHT', 0, 26)

    WoWTools_MoveMixin:Setup(MerchantFrame, {setSize=true, needSize=true, needMove=true, minW=329, minH=402, sizeUpdateFunc= function()
            local w, h= MerchantFrame:GetSize()
            Save().numLine= max(5, math.floor((h-144)/52))
            MERCHANT_ITEMS_PER_PAGE= max(10, max(2, math.floor(((w-8)/161)))* Save().numLine)
            do
                Create_ItemButton()
            end
            for i = 1, max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do
                local btn= _G['MerchantItem'..i]
                if i<=MERCHANT_ITEMS_PER_PAGE then
                    btn:SetShown(true)
                    if i>1 then
                        btn:ClearAllPoints()
                        btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-1)], 'BOTTOMLEFT', 0, -8)
                    end
                    if not btn.ItemButton.hasItem then
                        local info = C_MerchantFrame.GetItemInfo(i) or {}
                        _G["MerchantItem"..i.."Name"]:SetText(info.name or '')
                        SetItemButtonTexture(btn.ItemButton, info.texture or 0)
                    end
                else
                    btn:Hide()
                end
            end
            local line= Save().numLine
            for i= line+1, MERCHANT_ITEMS_PER_PAGE, line do
                local btn= _G['MerchantItem'..i]
                btn:ClearAllPoints()
                btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-line)], 'TOPRIGHT', 8, 0)
            end

            local numMerchantItems = GetMerchantNumItems()
            MerchantPageText:SetFormattedText(e.onlyChinese and '页数 %s/%s' or MERCHANT_PAGE_NUMBER, MerchantFrame.page, math.ceil(numMerchantItems / MERCHANT_ITEMS_PER_PAGE))
            -- Handle paging buttons
            if ( numMerchantItems > MERCHANT_ITEMS_PER_PAGE ) then
                MerchantPageText:SetShown(true)
                MerchantPrevPageButton:SetShown(true)
                MerchantNextPageButton:SetShown(true)
            else
                MerchantPageText:SetShown(false)
                MerchantPrevPageButton:SetShown(false)
                MerchantNextPageButton:SetShown(false)
            end

        end, sizeRestFunc= function()
            MERCHANT_ITEMS_PER_PAGE= 10
            Save().numLine= 5
            Create_ItemButton()
            e.call(MerchantFrame_UpdateMerchantInfo)
        end, sizeStopFunc= function()
            Save().MERCHANT_ITEMS_PER_PAGE= MERCHANT_ITEMS_PER_PAGE
            e.call(MerchantFrame_UpdateMerchantInfo)
        end
    })
end




















function WoWTools_SellBuyMixin:Init_WidthX2()
    Init_WidthX2()
end
