local e= select(2, ...)

local function Save()
    return WoWTools_BankMixin.Save
end
local ListButton
local Buttons={}







--取出，ClassID 物品
local function take_out_item(classID)
    local free= WoWTools_BagMixin:GetFree()--背包，空位
    if free==0 then
        return
    end
    for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
        for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
            if IsModifierKeyDown() or free<=0 then
                return
            end
            local info = C_Container.GetContainerItemInfo(bag, slot) or {}
            if info.itemID  and select(6, C_Item.GetItemInfoInstant(info.itemID))==classID then
                C_Container.UseContainerItem(bag, slot)
                free= free-1
            end
        end
    end
    for i=NUM_BANKGENERIC_SLOTS, 1, -1 do--28
        if IsModifierKeyDown() or free<=0 then
            return
        end
        local bag, slot= WoWTools_BankMixin:GetBagAndSlot(BankSlotsFrame["Item"..i])
        if bag and slot then
            local info= C_Container.GetContainerItemInfo(bag, slot) or {}
            if info.itemID and select(6, C_Item.GetItemInfoInstant(info.itemID))==classID then
                C_Container.UseContainerItem(bag, slot)
                free= free-1
            end
        end
    end
end







--存放，ClassID 物品
local function desposit_item(classID)
    local free= WoWTools_BankMixin:GetFree()--银行，空位
    if free==0 then
        return
    end
    for bag= NUM_BAG_FRAMES, BACKPACK_CONTAINER, -1 do-- + NUM_REAGENTBAG_FRAMES do--NUM_TOTAL_EQUIPPED_BAG_SLOTS
        for slot= C_Container.GetContainerNumSlots(bag), 1, -1 do
            if IsModifierKeyDown() or free==0 then
                return
            end
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID and not info.isLocked and select(6, C_Item.GetItemInfoInstant(info.itemID))==classID then
                C_Container.UseContainerItem(bag, slot)
                free= free-1
            end
        end
    end
end

















local function Create_ListButton(index)
    local btn=WoWTools_ButtonMixin:CreateMenu(ListButton.frame, {
        name='WoWToolsBankLeftListClassButton'..index,
        hideIcon=true,
    })

    btn.Text= WoWTools_LabelMixin:Create(btn, {justifyH='RIGHT'})
    btn.Text:SetPoint('RIGHT', -2,0)

    btn.Label= WoWTools_LabelMixin:Create(btn, {justifyH='RIGHT'})
    btn.Label:SetPoint('RIGHT', btn.Text, 'LEFT', -2, 0)

    function btn:rest()
        self.Text:SetText('')
        self.Label:SetText('')
        self.classID= nil
        self.subClassID= nil
    end

    function btn:set_text()
        local name= self.subClassID
            and C_Item.GetItemSubClassInfo(self.classID, self.subClassID)
            or C_Item.GetItemClassInfo(self.classID)
        self.Text:SetText(e.cn(name) or (self.classID..(self.subClassID and '-'..self.subClassID or '')))
    end

    function btn:set_tooltip()
        e.tips:SetOwner(self.Label, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine((e.onlyChinese and '提取/存放' or (WITHDRAW..'/'..DEPOSIT))..e.Icon.left)
        e.tips:AddLine('classID '..self.classID..(self.subClassID and '-'..self.subClassID or ''))
        e.tips:Show()
    end

    btn:SetPoint('TOPRIGHT', index==1 and ListButton.frame or Buttons[index-1], 'BOTTOMRIGHT')

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', btn.set_tooltip)
    btn:SetScript('OnMouseDown', btn.set_tooltip)
    btn:SetScript('OnHide', btn.rest)

    btn:SetupMenu(function(self, root)
        if not self.classID then
            return
        end
        local sub=root:CreateButton('|A:Cursor_OpenHand_32:0:0|a'..(e.onlyChinese and '提取' or WITHDRAW)..' '..(self.bankNumText or ''), function(data)
            take_out_item(data.classID)
        end, {classID=self.classID, subClassID=self.subClassID})
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(tooltip:AddLine('|A:common-icon-rotateright:0:0|a'..(e.onlyChinese and '银行' or BANK)))
        end)

        sub=root:CreateButton('|A:Cursor_buy_32:0:0|a'..(e.onlyChinese and '存放' or DEPOSIT)..' '..(self.bagNumText or ''), function(data)
            desposit_item(data.classID)
        end, {classID=self.classID, subClassID=self.subClassID})
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine('|A:common-icon-rotateleft:0:0|a'..(e.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL))
        end)

        root:CreateDivider()
        root:CreateTitle(self.Text:GetText()..' '..(self.classID..(self.subClassID and '-'..self.subClassID or '')))
    end)

    table.insert(Buttons, btn)
    return btn
end














--[[
for classID=0, Enum.ItemClassMeta.NumValues-1 do
    if classID~=6--弹药 Projectile
    and classID~=11--Quiver
    and classID~=10--货币代币 CurrencyTokenObsolete
    and classID~=14--PermanentObsolete
    and classID~=18--时光徽章
    --and classID~=7 绷带
]]

local function Init_Button_List(isBank, isReagent, isAccount)

--生成,物品列表
    local num=0
    if isBank or isAccount then
        for index, classID in pairs({0, 1, 2, 3, 4, 5, 7, 8, 9, 12, 13, 15, 16, 17}) do
            local btn= Buttons[index] or Create_ListButton(index)
            btn.classID= classID
            btn.subClassID= nil
            btn:set_text()
            btn:SetShown(true)
            num= index
        end
    elseif isReagent then
        for index= 0, 19 do
            local btn= Buttons[index] or Create_ListButton(index)
            btn.classID= 7
            btn.subClassID= index
            btn:set_text()
            btn:SetShown(true)
            num= index
        end
    end

--背景,设置右下角 frame.Background
    ListButton.frame.Background:SetPoint('BOTTOMRIGHT', Buttons[num] or ListButton, 2, -2)

--隐藏，并清除数据
    for index= num+1, #Buttons do
        local btn=Buttons[index]
        btn:SetShown(false)
    end
end
















local isRun
local function Set_Label()
    print('Set_Label', ListButton.frame:IsVisible() , isRun)
    if not ListButton.frame:IsVisible() or isRun then
        return
    end
    ListButton:set_bank_type()

    isRun=true


    local bankClass={}
    local bagClass={}
    local index= BankFrame.activeTabIndex

    local isBank= index==1
    local isReagent= index==2 and IsReagentBankUnlocked()
    local isAccount= index==3 and not AccountBankPanel.PurchaseTab:IsPurchaseTab()--not C_Bank.CanPurchaseBankTab(Enum.BankType.Account)

    Init_Button_List(isBank, isReagent, isAccount)

    if isBank or isAccount then
--银行
        for i=1, NUM_BANKGENERIC_SLOTS do--28
            local info= WoWTools_BankMixin:GetItemInfo(BankSlotsFrame["Item"..i])
            if info and info.itemID and not info.isLocked then
                local classID = select(6, C_Item.GetItemInfoInstant(info.itemID))
                bankClass[classID]= (bankClass[classID] or 0)+ (info.stackCount or 1)
            end
        end

--银行，背包
        for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
            for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.itemID and not info.isLocked then
                    local classID = select(6, C_Item.GetItemInfoInstant(info.itemID))
                    bankClass[classID]= (bankClass[classID] or 0)+ (info.stackCount or 1)
                end
            end
        end

--背包+材料包
        for bag= BACKPACK_CONTAINER, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                if info and info.itemID and not info.isLocked then
                    local classID = select(6, C_Item.GetItemInfoInstant(info.itemID))
                    if classID then
                        bagClass[classID]= (bagClass[classID] or 0)+ (info.stackCount or 1)
                    end
                end
            end
        end

    elseif isReagent then

        for _, btn in ReagentBankFrame:EnumerateItems() do
            local info= WoWTools_BankMixin:GetItemInfo(btn)
            if info and info.itemID then
                local classID, subClassID = select(6, C_Item.GetItemInfoInstant(info.itemID))
                if classID==7 and subClassID then
                    bankClass[subClassID]= (bankClass[subClassID] or 0)+ (info.stackCount or 1)
                end
            end
        end
        for bag= BACKPACK_CONTAINER, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.itemID and not info.isLocked then
                    local classID, subClassID = select(6, C_Item.GetItemInfoInstant(info.itemID))
                    if classID==7 and subClassID then
                        bagClass[classID]= (bagClass[classID] or 0)+ (info.stackCount or 1)
                    end
                end
            end
        end
    end



    local maxWidth= 0--背景
    local bank,bag,width
    for _, btn in pairs(Buttons) do
        if btn.subClassID then
            bank= bankClass[btn.subClassID] or 0
            bag= bagClass[btn.subClassID] or 0
        else
            bank= bankClass[btn.classID] or 0
            bag= bagClass[btn.classID] or 0
        end

        btn.bankNumText= (bank==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..WoWTools_Mixin:MK(bank, 3)..'|A:Banker:0:0|a'
        btn.bagNumText= ( bag==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..WoWTools_Mixin:MK(bag, 3)..'|A:bag-main:0:0|a'

        if bank==0 and bag==0 then
            btn.Label:SetText('')
            btn.Text:SetTextColor(0.62, 0.62, 0.62)
            btn:SetAlpha(0.5)
        else
            btn.Label:SetText(btn.bankNumText..btn.bagNumText)
            btn.Text:SetTextColor(1,0.82,0)
            btn:SetAlpha(1)
        end

        width= btn.Text:GetWidth()+btn.Label:GetWidth()
        btn:SetWidth(width+4)
        maxWidth= math.max(width, maxWidth)
    end

--背景,设置左边
    ListButton.frame.Background:SetWidth(maxWidth+8)

    isRun=nil
end

























local function Init_Menu(self, root)
    local sub
    root:CreateCheckbox(
        e.onlyChinese and '显示' or SHOW,
    function()
        return Save().showLeftList
    end, function()
        Save().showLeftList= not Save().showLeftList and true or nil
        self:Settings()
        self:set_tooltip()
    end)

    root:CreateDivider()
--打开选项界面
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BankMixin.addName})

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().leftListScale or 1
    end, function(value)
        Save().leftListScale= value
        self:Settings()
    end)
end








--大包时，显示，存取，分类，按钮

local function Init()
    --ListButton= WoWTools_ButtonMixin:Cbtn(BankFrame, {size=23, icon='hide', name='WoWTools_BankMixinLeftListButton'})
    ListButton=WoWTools_ButtonMixin:CreateMenu(BankFrame, {
        name='WoWToolsBankLeftListButton',
        hideIcon=true,
        atlas='NPE_ArrowDownGlow',
    })

    ListButton.Text= WoWTools_LabelMixin:Create(ListButton, {justifyH='RIGHT'})
    ListButton.Text:SetPoint('RIGHT', -2,0)

    function ListButton:set_bank_type()
        if not self.frame:IsVisible() then
            self.Text:SetText('')
            self:SetWidth(23)
            return
        end

        local index= BankFrame.activeTabIndex or 1
        local text=
            index==1 and (e.onlyChinese and '银行' or BANK)
            or index==2 and (e.onlyChinese and '材料' or BANK_TAB_ASSIGN_REAGENTS_CHECKBOX)
            or index==3 and (e.onlyChinese and '战团' or ACCOUNT_QUEST_LABEL)
        self.Text:SetText(text or '')
        self:SetWidth(text and self.Text:GetWidth()+8 or 23)
    end



    ListButton.frame=CreateFrame('Frame', nil, ListButton)
    ListButton.frame:SetPoint('BOTTOMRIGHT')
    ListButton.frame:SetSize(1,1)
    ListButton.frame:Hide()


    function ListButton:Settings()
        local show= Save().left_List
        local showLeftList= Save().showLeftList
        if show and showLeftList then
            local showBackground= Save().showBackground
            self.frame.Background:SetAtlas(showBackground and 'bank-frame-background' or 'UI-Frame-DialogBox-BackgroundTile')
            self.frame.Background:SetAlpha(showBackground and 1 or 0.3)
            self.frame:SetScale(Save().leftListScale or 1)
        else
            self.Text:SetText('')
        end
        self.frame:SetShown(showLeftList and show)
        self:SetAlpha(showLeftList and 1 or 0.3)
        if showLeftList then
            self:SetNormalTexture(0)
        else
            self:SetNormalAtlas('NPE_ArrowRightGlow')
        end
        self:set_bank_type()
        self:SetShown(show)
    end
    function ListButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_BankMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)
        e.tips:Show()
    end

    ListButton:SetPoint('TOPRIGHT', BankFrame, 'TOPLEFT', -2, -32)

    ListButton:SetScript('OnLeave', function (self)
        self:Settings()
        e.tips:Hide()
    end)
    ListButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:SetAlpha(1)
    end)

    ListButton:SetupMenu(Init_Menu)







--显示背景 frame.Background
    ListButton.frame.Background= ListButton.frame:CreateTexture(nil, 'BACKGROUND')
    ListButton.frame.Background:SetPoint('TOPRIGHT', 2, 1)--右上角
    ListButton.frame.Background:EnableMouse(true)






--事件
    function ListButton.frame:set_event()
        if self:IsVisible() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
        else
            self:UnregisterEvent('BAG_UPDATE_DELAYED')
        end
    end

    ListButton.frame:SetScript('OnShow', ListButton.frame.set_event)
    ListButton.frame:SetScript('OnHide', ListButton.frame.set_event)
    ListButton.frame:SetScript('OnEvent', Set_Label)

    ListButton:Settings()


    hooksecurefunc('BankFrame_ShowPanel', Set_Label)
    hooksecurefunc(BankPanelTabMixin, 'OnClick', Set_Label)
end









--分类，存取,
function WoWTools_BankMixin:Init_Left_List()
    if self.Save.left_List and not ListButton then
        Init()
    elseif ListButton then
        ListButton:Settings()
    end
end