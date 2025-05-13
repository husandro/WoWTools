local function Save()
    return WoWToolsSave['Plus_SellBuy']
end












local function Create_Lable(btn)
    if btn.itemBG then
        return
    end

    btn.IndexLable= WoWTools_LabelMixin:Create(btn)
    btn.IndexLable:SetPoint('TOPRIGHT', btn, -1, 4)
    btn.IndexLable:SetAlpha(0.3)



    local name= btn:GetName()
    local nameFrame= _G[name..'NameFrame']
    nameFrame:Hide()
    nameFrame:SetTexture(0)
    --nameFrame:SetPoint('RIGHT', btn, 40, 0)

    btn.Name:SetPoint('RIGHT', -2, 0)

--建立，物品，背景
    btn.itemBG= btn:CreateTexture(nil, 'BACKGROUND')
    --btn.itemBG:SetAtlas('UI-HUD-CoolDownManager-Mask')
    btn.itemBG:SetColorTexture(0, 0, 0, 0.95)
    --btn.itemBG:SetSize(100,43)
    --btn.itemBG:SetPoint('TOPLEFT', btn.SlotTexture, 'TOPRIGHT', -9, -13)
    btn.itemBG:SetPoint('TOPLEFT', -1, -2)
    btn.itemBG:SetPoint('BOTTOMRIGHT', -2, 0)
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
            local name2= GetBuybackItemInfo(self:GetID())
            if name2 then
                WoWTools_BagMixin:Find(false)
            end
        end
    end)

    btn.ItemButton:HookScript('OnHide', function(self)
        self.price = nil
        self.hasItem = nil
        self.name = nil
        self.extendedCost = nil
        self.link = nil
        self.texture = nil
    end)
end



--商人 Plus, 加宽，物品，信息
--<Size x="153" y="44"/>
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
        --[[local itemButton = _G["MerchantItem"..index.."ItemButton"]
        itemButton.price = nil
        itemButton.hasItem = nil
        itemButton.name = nil
        itemButton.extendedCost = nil
        itemButton.link = nil
        itemButton.texture = nil
        _G["MerchantItem"..index.."Name"]:SetText("")]]
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









local function Init_WidthX2()
    MerchantItem11:SetID(11)
    MerchantItem12:SetID(12)



--移动 WoWTools_MoveMixin
    WoWTools_MoveMixin:Setup(MerchantFrame, {
        setSize=true, minW=329, minH=402,
    sizeUpdateFunc= function()
        Size_Update()
    end, sizeRestFunc= function()
        MERCHANT_ITEMS_PER_PAGE= 10
        Save().numLine= 5
        Create_ItemButton()
        WoWTools_Mixin:Call(MerchantFrame_UpdateMerchantInfo)
    end, sizeStopFunc= function()
        Save().MERCHANT_ITEMS_PER_PAGE= MERCHANT_ITEMS_PER_PAGE
        WoWTools_Mixin:Call(MerchantFrame_UpdateMerchantInfo)
        if WoWTools_DataMixin.Player.husandro then
            print(
                WoWTools_DataMixin.Icon.icon2..'MERCHANT_ITEMS_PER_PAGE',
                MERCHANT_ITEMS_PER_PAGE,
                '/',
                Save().numLine
            )
        end
    end})


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












--出售，卖
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo', function()
        --[[if not MerchantFrame:IsShown() then
            return
        end]]
        local numMerchantItems= GetMerchantNumItems()
        local index, info
        for i = 1, MERCHANT_ITEMS_PER_PAGE do--math.max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do
            local btn= _G['MerchantItem'..i]
            index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i);
            if index <= numMerchantItems then
                info = C_MerchantFrame.GetItemInfo(index);
                btn:SetShown(true)
                btn.itemBG:SetShown(info)--Texture.lua
                btn.IndexLable:SetText(info and  btn.ItemButton:GetID() or '')
            else
                btn:SetShown(false)
                btn.itemBG:SetShown(false)
                btn.IndexLable:SetText('')
            end

            if i>1 then
                btn:ClearAllPoints()
                btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-1)], 'BOTTOMLEFT', 0, -8)
            end
        end

        local numWidth= Save().numWidth or 153
        local w= numWidth+ 20--172
        local h= 146+(Save().numLine*52)--<Size x="336" y="444"/> <Size x="153" y="44"/>
        local line= Save().numLine or 6

        for i= line+1, MERCHANT_ITEMS_PER_PAGE, line do
            local btn= _G['MerchantItem'..i]
            btn:ClearAllPoints()
            btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-line)], 'TOPRIGHT', 8, 0)
            w= w+ numWidth+ 8
        end

        MerchantFrame:SetSize(max(w, 336), max(h, 440))

        WoWTools_MerchantMixin:Set_Merchant_Info()--设置, 提示, 信息
        MerchantFrameTab2:set_buyback_num()--回购，数量，提示

        MerchantFrame.ResizeButton.setSize=true
        --MerchantFrame.ResizeButton2:SetShown(true)
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
        local width= (Save().numWidth or 153)*2+ 30
        width= math.max(width, 418)--336

        MerchantFrame:SetSize(width, 440)

        WoWTools_MerchantMixin:Set_Merchant_Info()--设置, 提示, 信息
        MerchantFrameTab2:set_buyback_num()--回购，数量，提示

        MerchantFrame.ResizeButton.setSize=nil
        --MerchantFrame.ResizeButton2:SetShown(false)
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



    MerchantFrame.ResizeButton2= WoWTools_ButtonMixin:Cbtn(MerchantFrame, {
        name='WoWToolsMerchantPlusToWidthButton',
        atlas='uitools-icon-chevron-right',
        addTexture=true,
        size={12, 32}
    })
    MerchantFrame.ResizeButton2:SetPoint('RIGHT', 7, 0)
    MerchantFrame.ResizeButton2.texture:SetVertexColor(0.7,0.7,0.7,0.5)
    MerchantFrame.ResizeButton2:SetScript('OnLeave', function(self)
        self.texture:SetVertexColor(0.7,0.7,0.7,0.5)
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
        if d=='LeftButton' then
            local p= self:GetParent()
            self.isMovingToRight= true
            p:SetResizable(true)
            p:StartSizing('RIGHT', true)
        else
            Save().numWidth= nil
            self:settings()
            WoWTools_Mixin:Call(MerchantFrame_UpdateMerchantInfo)
        end
    end)
    MerchantFrame.ResizeButton2:SetScript('OnHide', function(self)
        if self.isMovingToRight then
            self:GetParent():StopMovingOrSizing()
        end
    end)
    MerchantFrame.ResizeButton2:SetScript('OnMouseUp', function(self)
        self:GetParent():StopMovingOrSizing()
        self.isMovingToRight=nil
        WoWTools_Mixin:Call(MerchantFrame_UpdateMerchantInfo)
    end)

    function MerchantFrame.ResizeButton2:settings()
        local width= Save().numWidth or 153
        local btn
        for i = 1, math.max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do
            btn= _G['MerchantItem'..i]
            if btn then
                btn:SetWidth(width)
            end
        end
    end
    MerchantFrame:HookScript('OnSizeChanged', function(self)
        if not self:IsVisible() or not self.ResizeButton2.isMovingToRight then
            return
        end
        local w= self:GetWidth()
        local line= Save().numLine or 6
        --local num= math.max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE)

        local left= MERCHANT_ITEMS_PER_PAGE/line

        w= w-12
        print(left, math.max(153, w/left))

        Save().numWidth= math.max(153, w/left)

        self.ResizeButton2:settings()
       -- WoWTools_Mixin:Call(MerchantFrame_UpdateMerchantInfo)
    end)

    if C_AddOns.IsAddOnLoaded("CompactVendor") then
        print(
            WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName,
            format(WoWTools_DataMixin.onlyChinese and "|cffff0000与%s发生冲突！|r" or ALREADY_BOUND, 'Compact Vendor'),
            WoWTools_DataMixin.onlyChinese and '插件' or ADDONS
        )
    end


    Init_WidthX2=function()end
end




















function WoWTools_MerchantMixin:Init_WidthX2()
    Init_WidthX2()
end
