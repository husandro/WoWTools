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
--更新物品













local function Create_Lable(btn)
    if btn.itemBG then
        return
    end

    local name= btn:GetName()
--_G[name..'AltCurrencyFrame']
--_G[name..'MoneyFrame']


    _G[name..'NameFrame']:SetTexture(0)
    btn.ItemButton.NormalTexture:SetTexture(0)
    btn.SlotTexture:SetTexture(0)

--物品，名称
    btn.Name:SetPoint('RIGHT', -2,0)
    btn.Name:SetPoint('TOPLEFT', _G[name..'ItemButtonIconTexture'], 'TOPRIGHT', 2, 4)
    btn.Name:SetPoint('BOTTOM', _G[name..'AltCurrencyFrame'], 'TOP')


--建立，物品，背景
    btn.itemBG= btn:CreateTexture(nil, 'BACKGROUND')
    btn.itemBG:SetColorTexture(0, 0, 0)
    btn.itemBG:SetPoint('TOPLEFT', 1, -1)
    btn.itemBG:SetPoint('BOTTOMRIGHT')
    btn.itemBG:SetAlpha(Save().btnBgAlpha or 0.5)
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

    --btn:HookScript('OnHide', function(self)
    function btn:init_reset()
        self.ItemButton:Reset()
        self.ItemButton.price = nil
        self.ItemButton.hasItem = nil
        self.ItemButton.name = nil
        self.ItemButton.extendedCost = nil
        self.ItemButton.link = nil
        self.ItemButton.texture = nil
        self.Name:SetText('')
    end
end



--创建，设置，按钮
local function Create_ItemButton()
    local width= Save().numWidth or 153
    local bgAlpha= Save().btnBgAlpha or 1
    local btnNameScale= Save().btnNameScale or 1
    for i= 1, max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do--建立，索引，文本
        local btn= _G['MerchantItem'..i] or CreateFrame('Frame', 'MerchantItem'..i, MerchantFrame, 'MerchantItemTemplate', i)
        Create_Lable(btn)

        btn:SetWidth(width)
        btn.itemBG:SetAlpha(bgAlpha)
        btn.Name:SetScale(btnNameScale)
    end

    local index= MERCHANT_ITEMS_PER_PAGE+1
    while _G['MerchantItem'..index] do--隐藏，多余
        _G['MerchantItem'..index]:SetShown(false)
        index= index+1
    end
end







--移动，设置大小，缩放
local function Size_Update()
    do
        if MerchantFrame.page ~=1 then
            MerchantFrame.page=1
            MerchantFrame_CloseStackSplitFrame()
            MerchantFrame_Update();
        end
    end

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
    MerchantPageText:SetText(MerchantFrame.page..'/'..math.ceil(numMerchantItems / MERCHANT_ITEMS_PER_PAGE))
    --[[MerchantPageText:SetFormattedText(
        WoWTools_DataMixin.onlyChinese and '页数 %s/%s' or MERCHANT_PAGE_NUMBER,
        MerchantFrame.page,
        math.ceil(numMerchantItems / MERCHANT_ITEMS_PER_PAGE)
    )]]

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














--增加，按钮宽度，按钮，菜单
local function ResizeButton2_Menu(self, root)
    if not MerchantFrame.ResizeButton2 then
        return
    end

    local sub
    sub=root:CreateButton(
        '|A:common-icon-rotateright:0:0|a'
        ..((WoWTools_DataMixin.onlyChinese and '宽度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH)),
    function()
        return MenuResponse.Open
    end)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().numWidth or 153
        end, setValue=function(value)
            Save().numWidth=value
            Create_ItemButton()
            WoWTools_MerchantMixin:Update_MerchantFrame()--更新物品
        end,
        name=WoWTools_DataMixin.onlyChinese and '宽度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH ,
        minValue=153,
        maxValue=500,
        step=1,
        --bit='%.2f',    
    })
    sub:CreateSpacer()
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '重置' or RESET,
    function()
        Save().numWidth= nil
        Create_ItemButton()
        WoWTools_MerchantMixin:Update_MerchantFrame()--更新物品
        return MenuResponse.Refresh
    end)

--数量
    sub= root:CreateButton(
        '|A:GreenCross:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL),
    function()
        return MenuResponse.Open
    end)
    sub:SetEnabled(MerchantFrame.selectedTab==1)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().numLine or 5
        end, setValue=function(value)
            Save().numLine=value
            WoWTools_MerchantMixin:Update_MerchantFrame()--更新物品
        end,
        name=WoWTools_DataMixin.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS ,
        minValue=5,
        maxValue=15,
        step=1,
        --bit='%.2f',    
    })
    sub:CreateSpacer()

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return MERCHANT_ITEMS_PER_PAGE/(Save().numLine or 5)
        end, setValue=function(value)
            local num= value*(Save().numLine or 5)
            MERCHANT_ITEMS_PER_PAGE= num
            Save().MERCHANT_ITEMS_PER_PAGE= num
            Create_ItemButton()
            WoWTools_MerchantMixin:Update_MerchantFrame()--更新物品
        end,
        name=WoWTools_DataMixin.onlyChinese and '列数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_COLUMNS,
        minValue=2,
        maxValue=15,
        step=1,
        --bit='%.2f',    
    })
    sub:CreateSpacer()

--背景, 透明度
    WoWTools_MenuMixin:BgAplha(root, function()
        return Save().btnBgAlpha or 1
    end, function(value)
        Save().btnBgAlpha= value
        Create_ItemButton()
    end, nil, false)

--缩放
    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().btnNameScale or 1
    end, function(value)
        Save().btnNameScale= value
        Create_ItemButton()
    end)

    root:CreateDivider()
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO),
    function()
        return not Save().notItemInfo
    end, function()
        Save().notItemInfo= not Save().notItemInfo and true or nil
        WoWTools_MerchantMixin:Update_MerchantFrame()
    end)

--[[无法使用物品，alpha
    sub= root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '无法使用' or MOUNT_JOURNAL_FILTER_UNUSABLE)
        ..' '..(Save().notIsUsableAlpha or 1),
    function()
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:BgAplha(sub, function()
        return Save().notIsUsableAlpha or 1
    end, function(value)
        Save().notIsUsableAlpha= value
        WoWTools_MerchantMixin:Update_MerchantFrame()
    end, function()
        Save().notIsUsableAlpha= nil
        WoWTools_MerchantMixin:Update_MerchantFrame()
    end, true)]]

end
















--WidthX2
local function Init_WidthX2()
    if Save().notPlus then
        return
    end

--按钮，数量
    MERCHANT_ITEMS_PER_PAGE= Save().MERCHANT_ITEMS_PER_PAGE or MERCHANT_ITEMS_PER_PAGE or 24

--创建，设置，按钮
    Create_ItemButton()

--移动 WoWTools_MoveMixin
    WoWTools_MoveMixin:Setup(MerchantFrame, {
    minW=329,
    minH=402,
    sizeUpdateFunc= function()
        Size_Update()
    end, sizeRestFunc= function()
        MERCHANT_ITEMS_PER_PAGE= 10--按钮，数量
        Save().numLine= 5
        Create_ItemButton()
        WoWTools_MerchantMixin:Update_MerchantFrame()--更新物品
    end, sizeStopFunc= function()
        Save().MERCHANT_ITEMS_PER_PAGE= MERCHANT_ITEMS_PER_PAGE --按钮，数量
        WoWTools_MerchantMixin:Update_MerchantFrame()--更新物品
    end})






--出售，卖
    WoWTools_DataMixin:Hook('MerchantFrame_UpdateMerchantInfo', function()
        local numMerchantItems= GetMerchantNumItems()
        local index, info, btn
        local curNum= 0
        for i = 1, MERCHANT_ITEMS_PER_PAGE do--按钮，数量
            btn= _G['MerchantItem'..i]
            index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)

            if index <= numMerchantItems then
                info = C_MerchantFrame.GetItemInfo(index);
                btn:SetShown(true)

                btn.itemBG:SetShown(info)--Texture.lua
                curNum= curNum+1
            else
                btn:init_reset()
                btn:SetShown(false)
            end

            if i>1 then
                btn:ClearAllPoints()
                btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-1)], 'BOTTOMLEFT', 0, -8)
            end
        end

--换行
        local numWidth= (Save().numWidth or 153)+8
        local w= numWidth+ 15
        local line= Save().numLine or 5
        local h= 146+(line*52)

        for i= line+1, math.min(curNum, MERCHANT_ITEMS_PER_PAGE), line do--按钮，数量
            btn= _G['MerchantItem'..i]
            btn:ClearAllPoints()
            btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-line)], 'TOPRIGHT', 8, 0)
            w= w+ numWidth
        end

--设置，框加大小
        MerchantFrame:SetSize(max(w, 336), max(h, 444))

--隐藏，多余
        index= MERCHANT_ITEMS_PER_PAGE+1
        btn= _G['MerchantItem'..index]
        while btn do
            btn:SetShown(false)
            btn:init_reset()
            index= index+1
            btn= _G['MerchantItem'..index]
        end

        MerchantPageText:SetText(MerchantFrame.page..'/'..math.ceil(numMerchantItems / MERCHANT_ITEMS_PER_PAGE))

        if MerchantFrame.ResizeButton then
            MerchantFrame.ResizeButton.setSize=true
        end
    end)









--回购
    WoWTools_DataMixin:Hook('MerchantFrame_UpdateBuybackInfo', function()
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

        local width= ((Save().numWidth or 153)+8)*2+ 15
        width= math.max(width, 336)--336

        MerchantFrame:SetSize(width, 444)

--隐藏，多余
        local index= BUYBACK_ITEMS_PER_PAGE+1
        btn= _G['MerchantItem'..index]
        while btn do
            btn:SetShown(false)
            btn:init_reset()
            index= index+1
            btn= _G['MerchantItem'..index]
        end
        if MerchantFrame.ResizeButton then
            MerchantFrame.ResizeButton.setSize=nil
        end
    end)













--增加，按钮宽度，按钮
    MerchantFrame.ResizeButton2= WoWTools_ButtonMixin:Cbtn(MerchantFrame, {
        name='WoWToolsMerchantPlusToWidthButton',
        atlas='uitools-icon-chevron-right',
        addTexture=true,
        size={12, 32}
    })
    WoWTools_TextureMixin:SetAlphaColor(MerchantFrame.ResizeButton2.texture, true)
    MerchantFrame.ResizeButton2:SetPoint('RIGHT', 7, 0)
    MerchantFrame.ResizeButton2.texture:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b,0.3)
    MerchantFrame.ResizeButton2:SetScript('OnLeave', function(self)
        --self.texture:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b,0.3)
        GameTooltip:Hide()
    end)
    MerchantFrame.ResizeButton2:SetScript('OnEnter', function(self)
        --self.texture:SetVertexColor(1,1,1,1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '宽度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH)..WoWTools_DataMixin.Icon.left,
            WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
        )
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
            --SetCursor("UI_RESIZE_CURSOR")
            SetCursor('Interface\\CURSOR\\Crosshair\\UI-Cursor-SizeRight')
        else
--还原
            MenuUtil.CreateContextMenu(self, ResizeButton2_Menu)
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
        WoWTools_MerchantMixin:Update_MerchantFrame()--更新物品
        ResetCursor()
    end)


    MerchantFrame:HookScript('OnSizeChanged', function(self)
        if not self:IsVisible() or not self.ResizeButton2.isMovingToRight then
            return
        end
        local w= self:GetWidth()
        local line= Save().numLine or 5

        local numMerchantItems= GetMerchantNumItems()
        local curNum= 0
        local index
        for i = 1, MERCHANT_ITEMS_PER_PAGE do--按钮，数量
            index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)
            if index <= numMerchantItems then
                curNum= curNum+1
            end
        end
        curNum= math.max(10, curNum)
        curNum= math.min(curNum, MERCHANT_ITEMS_PER_PAGE)

        local left= MerchantFrame.selectedTab==2
                    and 2
                    or math.ceil(curNum/line)
        left= math.max(2, left)

        w= w-(left*8)-15

        Save().numWidth= math.max(153, w/left)

        Create_ItemButton()
    end)

    if MerchantFrame:IsShown() then
       WoWTools_MerchantMixin:Update_MerchantFrame()
    end

    --钱 MerchantFrame_UpdateCurrencies()
    --MerchantMoneyFrame:ClearAllPoints()
    --MerchantMoneyFrame:SetPoint('BOTTOMLEFT', 3, 3)

    Init_WidthX2=function()end
end

























function WoWTools_MerchantMixin:Init_WidthX2()
    Init_WidthX2()
end

function WoWTools_MerchantMixin:ResizeButton2_Menu(...)
    ResizeButton2_Menu(...)
end