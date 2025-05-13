local function Save()
    return WoWToolsSave['Plus_SellBuy']
end
--[[
MERCHANT_ITEMS_PER_PAGE = 10;
BUYBACK_ITEMS_PER_PAGE = 12;
MAX_ITEM_COST = 3;
MAX_MERCHANT_CURRENCIES = 6;
<Size x="336" y="444"/>
<Size x="153" y="44"/>
]]












local function Create_Lable(btn)
    if btn.IndexLable then
        return
    end

    btn.IndexLable= WoWTools_LabelMixin:Create(btn)
    btn.IndexLable:SetPoint('BOTTOMRIGHT', btn, 'TOPRIGHT')
    btn.IndexLable:SetAlpha(0.3)

--隐藏，背景框
    local nameFrame= _G[btn:GetName()..'NameFrame']
    nameFrame:Hide()
    nameFrame:SetTexture(0)

--物品，名称
    btn.Name:SetPoint('RIGHT', -2, 0)

--建立，物品，背景
    btn.itemBG= btn:CreateTexture(nil, 'BACKGROUND')
    btn.itemBG:SetColorTexture(0, 0, 0, 0.95)
    btn.itemBG:SetPoint('TOPLEFT', -1, -2)
    btn.itemBG:SetPoint('BOTTOMRIGHT', -2, 0)
    btn.itemBG:Hide()

--查询，背包，物品
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
            local name2= GetBuybackItemInfo(self:GetID())
            if name2 then
                WoWTools_BagMixin:Find(false)
            end
        end
    end)

    btn:HookScript('OnHide', function(self)
        self.ItemButton:Reset()
        self.ItemButton.price = nil
        self.ItemButton.hasItem = nil
        self.ItemButton.name = nil
        self.ItemButton.extendedCost = nil
        self.ItemButton.link = nil
        self.ItemButton.texture = nil
        self.Name:SetText('')
        self.IndexLable:SetText('')
    end)
end



--创建，设置，按钮
local function Create_ItemButton()
    local width= Save().numWidth or 153
    for i= 1, max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do--建立，索引，文本
        local btn= _G['MerchantItem'..i] or CreateFrame('Frame', 'MerchantItem'..i, MerchantFrame, 'MerchantItemTemplate', i)
        Create_Lable(btn)
        btn:SetWidth(width)
    end

    local index= MERCHANT_ITEMS_PER_PAGE+1
    while _G['MerchantItem'..index] do--隐藏，多余
        _G['MerchantItem'..index]:SetShown(false)
        index= index+1
    end
end







--移动，设置大小，缩放
local function Size_Update()
    local w, h= MerchantFrame:GetSize()

    local line= max(5, math.floor((h-144)/52))
    Save().numLine= line

    local left= math.floor((w-8)/ ((Save().numWidth or 153)+8))

    MERCHANT_ITEMS_PER_PAGE= max(10, max(2, left*line))

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


    for i= line+1, MERCHANT_ITEMS_PER_PAGE, line do
        local btn= _G['MerchantItem'..i]
        btn:ClearAllPoints()
        btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-line)], 'TOPRIGHT', 8, 0)
    end

    local numMerchantItems = GetMerchantNumItems()
    MerchantPageText:SetFormattedText(
        WoWTools_DataMixin.onlyChinese and '页数 %s/%s' or MERCHANT_PAGE_NUMBER,
        MerchantFrame.page,
        math.ceil(numMerchantItems / MERCHANT_ITEMS_PER_PAGE)
    )

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
end






















local function Init()
--按钮，数量
    MERCHANT_ITEMS_PER_PAGE= Save().MERCHANT_ITEMS_PER_PAGE or MERCHANT_ITEMS_PER_PAGE or 24

--创建，设置，按钮
    Create_ItemButton()

--移动 WoWTools_MoveMixin
    WoWTools_MoveMixin:Setup(MerchantFrame, {
        setSize=true, minW=329, minH=402,
    sizeUpdateFunc= function()
        Size_Update()
    end, sizeRestFunc= function()
        MERCHANT_ITEMS_PER_PAGE= 10--按钮，数量
        Save().numLine= 5
        Create_ItemButton()
        WoWTools_Mixin:Call(MerchantFrame_UpdateMerchantInfo)
    end, sizeStopFunc= function()
        Save().MERCHANT_ITEMS_PER_PAGE= MERCHANT_ITEMS_PER_PAGE --按钮，数量
        WoWTools_Mixin:Call(MerchantFrame_UpdateMerchantInfo)
    end})








--出售，卖
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo', function()
        local numMerchantItems= GetMerchantNumItems()
        local index, info, btn
        for i = 1, MERCHANT_ITEMS_PER_PAGE do--按钮，数量
            btn= _G['MerchantItem'..i]
            index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)

            if index <= numMerchantItems then
                info = C_MerchantFrame.GetItemInfo(index);
                btn:SetShown(true)

                btn.itemBG:SetShown(info)--Texture.lua
                btn.IndexLable:SetText(info and  btn.ItemButton:GetID() or '')
            end

            if i>1 then
                btn:ClearAllPoints()
                btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-1)], 'BOTTOMLEFT', 0, -8)
            end
        end
--换行
        local numWidth= Save().numWidth or 153
        local w= numWidth+ 20--172
        local line= Save().numLine or 6
        local h= 146+(line*52)

        for i= line+1, MERCHANT_ITEMS_PER_PAGE, line do--按钮，数量
            btn= _G['MerchantItem'..i]
            btn:ClearAllPoints()
            btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-line)], 'TOPRIGHT', 8, 0)
            w= w+ numWidth+ 8
        end
--设置，框加大小
        MerchantFrame:SetSize(max(w, 336), max(h, 440))

--隐藏，多余
        index= MERCHANT_ITEMS_PER_PAGE+1
        while _G['MerchantItem'..index] do
            _G['MerchantItem'..index]:SetShown(false)
            index= index+1
        end

--设置, 提示, 信息
        WoWTools_MerchantMixin:Set_Merchant_Info()
--回购，数量，提示
        MerchantFrameTab2:set_buyback_num()

        MerchantFrame.ResizeButton.setSize=true
    end)









--回购
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', function()
        local numBuybackItems = GetNumBuybackItems() or 0
        local btn

        for i = 1, BUYBACK_ITEMS_PER_PAGE do
            btn= _G['MerchantItem'..i]
            btn:SetShown(true)
            if i>1 then
                btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-1)], 'BOTTOMLEFT', 0, -8)
            end
            btn.itemBG:SetShown(numBuybackItems>=i)
        end

        _G['MerchantItem7']:SetPoint('TOPLEFT', _G['MerchantItem1'], 'TOPRIGHT', 8, 0)

        local width= (Save().numWidth or 153)*2+ 30
        width= math.max(width, 418)--336

        MerchantFrame:SetSize(width, 440)

--隐藏，多余
        local index= BUYBACK_ITEMS_PER_PAGE+1
        btn= _G['MerchantItem'..index]
        while btn do
            btn:SetShown(false)
            index= index+1
            btn= _G['MerchantItem'..index]
        end

        WoWTools_MerchantMixin:Set_Merchant_Info()--设置, 提示, 信息
        MerchantFrameTab2:set_buyback_num()--回购，数量，提示

        MerchantFrame.ResizeButton.setSize=nil
    end)













--增加，按钮宽度，按钮
    MerchantFrame.ResizeButton2= WoWTools_ButtonMixin:Cbtn(MerchantFrame, {
        name='WoWToolsMerchantPlusToWidthButton',
        atlas='uitools-icon-chevron-right',
        addTexture=true,
        size={12, 32}
    })
    MerchantFrame.ResizeButton2:SetPoint('RIGHT', 7, 0)
    MerchantFrame.ResizeButton2.texture:SetVertexColor(0.7,0.7,0.7,0.3)
    MerchantFrame.ResizeButton2:SetScript('OnLeave', function(self)
        self.texture:SetVertexColor(0.7,0.7,0.7,0.3)
        GameTooltip:Hide()
    end)
    MerchantFrame.ResizeButton2:SetScript('OnEnter', function(self)
        self.texture:SetVertexColor(1,1,1,1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(WoWTools_MerchantMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '宽度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH)..WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '默认' or HUD_EDIT_MODE_SETTING_MICRO_MENU_ORDER_DEFAULT)..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end)

    MerchantFrame.ResizeButton2:SetClampedToScreen(true)

    MerchantFrame.ResizeButton2:SetScript('OnMouseDown', function(self, d)
--移动
        if d=='LeftButton' then
            local p= self:GetParent()
            self.isMovingToRight= true
            p:SetResizable(true)
            p:StartSizing('RIGHT', true)
            SetCursor("UI_RESIZE_CURSOR")
        else
--还原
            MenuUtil.CreateContextMenu(self, function(_, root)
                root:CreateCheckbox(
                    (WoWTools_DataMixin.onlyChinese and '默认' or HUD_EDIT_MODE_SETTING_MICRO_MENU_ORDER_DEFAULT)..' 153',
                function()
                    return not Save().numWidth
                end, function(data)
                    Save().numWidth= not Save().numWidth and data.width or nil
                    Create_ItemButton()
                    WoWTools_Mixin:Call(MerchantFrame_UpdateMerchantInfo)
                end, {width=Save().numWidth})
            end)
        end
    end)
    MerchantFrame.ResizeButton2:SetScript('OnHide', function(self)
        if self.isMovingToRight then
            self:GetParent():StopMovingOrSizing()
            ResetCursor()
        end
    end)
    MerchantFrame.ResizeButton2:SetScript('OnMouseUp', function(self)
        self:GetParent():StopMovingOrSizing()
        self.isMovingToRight=nil
        WoWTools_Mixin:Call(MerchantFrame_UpdateMerchantInfo)
        ResetCursor()
    end)


    MerchantFrame:HookScript('OnSizeChanged', function(self)
        if not self:IsVisible() or not self.ResizeButton2.isMovingToRight then
            return
        end
        local w= self:GetWidth()
        local line= Save().numLine or 6

        local left= math.floor(MERCHANT_ITEMS_PER_PAGE/line)
        w= w-(left*8)-12

        Save().numWidth= math.max(153, w/left)

        Create_ItemButton()
    end)


    Init=function()end
end






















local function Init_UI()
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
--回购
    MerchantBuyBackItem:ClearAllPoints()
    MerchantBuyBackItem:SetPoint('BOTTOMRIGHT', MerchantFrame, -16, 33)--115

--下一页
    MerchantNextPageButton:ClearAllPoints()
    MerchantNextPageButton:SetPoint('RIGHT', MerchantFrame.FilterDropdown, 'LEFT', 4, 0)
    MerchantNextPageButton:SetFrameStrata('HIGH')
    local label, texture= MerchantNextPageButton:GetRegions()
    if texture and texture:GetObjectType()=='Texture' then texture:Hide() texture:SetTexture(0) end
    if label and label:GetObjectType()=='FontString' then label:Hide() label:SetText('') end

--上一页
    MerchantPrevPageButton:ClearAllPoints()
    MerchantPrevPageButton:SetPoint('RIGHT', MerchantNextPageButton, 'LEFT',8,0)
    label, texture= MerchantPrevPageButton:GetRegions()
    if texture and texture:GetObjectType()=='Texture' then texture:Hide() texture:SetTexture(0) end
    if label and label:GetObjectType()=='FontString' then label:Hide() label:SetText('') end

--上页数
    MerchantPageText:ClearAllPoints()
    MerchantPageText:SetPoint('RIGHT', MerchantPrevPageButton, 'LEFT', 0, 0)
    MerchantPageText:SetJustifyH('RIGHT')

--外框
    MerchantFrameBottomLeftBorder:ClearAllPoints()
    MerchantFrameBottomLeftBorder:SetPoint('BOTTOMRIGHT', 0, 26)



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



    if C_AddOns.IsAddOnLoaded("CompactVendor") then
        print(
            WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName,
            format(WoWTools_DataMixin.onlyChinese and "|cffff0000与%s发生冲突！|r" or ALREADY_BOUND, 'Compact Vendor'),
            WoWTools_DataMixin.onlyChinese and '插件' or ADDONS
        )
    end

    Init_UI=function()end
end



function WoWTools_MerchantMixin:Init_WidthX2()
    Init()
    Init_UI()
end
