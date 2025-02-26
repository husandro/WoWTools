
--存取，分类，按钮
local e= select(2, ...)
local function Save()
    return WoWTools_BankMixin.Save
end

local ListButton
local Buttons={}
local isRun










--取出，ClassID 物品
local function Take_Item(isOutItem, classID, subClassID)
    if isRun then
        return
    end
    isRun= true

    local isBagAllItem= classID==7 or subClassID
    local free= isOutItem
            and WoWTools_BankMixin:GetFree()--银行，空位
            or WoWTools_BagMixin:GetFree(isBagAllItem)--背包，空位

    if free==0 then
        isRun=nil
        return
    end

    local Tabs= isOutItem
            and WoWTools_BankMixin:GetItems(BankFrame.activeTabIndex)
            or WoWTools_BagMixin:GetItems(isBagAllItem)

    if not Tabs then
        isRun=nil
        return
    end

    local bankType= ListButton.isAccount and Enum.BankType.Account or Enum.BankType.Character
    local reagentBankOpen= ListButton.isReagent and true or false

    for _, data in pairs(Tabs or {}) do

        if IsModifierKeyDown() or free<=0 then
            isRun=nil
            return
        end
        do
            if not data.info.isLocked then
                local classID2, subClassID2 = select(6, C_Item.GetItemInfoInstant(data.info.itemID))
                if classID== classID2
                    and (
                        subClassID==subClassID2
                        or not subClassID
                    )
                then

                    do
                        C_Container.UseContainerItem(data.bag, data.slot, nil, bankType, reagentBankOpen)
                    end
                    free= free-1
                end
            end
        end
    end
    isRun=nil
end





















local function Create_ListButton(index)
    local btn=WoWTools_ButtonMixin:CreateMenu(ListButton.frame, {
        name='WoWToolsBankLeftListClassButton'..index,
        hideIcon=true,
    })

--名称
    btn.Text= WoWTools_LabelMixin:Create(btn, {justifyH='RIGHT'})
    btn.Text:SetPoint('RIGHT', -2,0)

--数量
    btn.Label= WoWTools_LabelMixin:Create(btn, {justifyH='RIGHT'})
    btn.Label:SetPoint('RIGHT', btn.Text, 'LEFT', -2, 0)

    function btn:rest()
        self.Text:SetText('')
        self.Label:SetText('')
        self.classID= nil
        self.subClassID= nil
        self.bankItems= nil
        self.bagItems= nil
    end

    function btn:set_text()
        local name= self.subClassID
            and C_Item.GetItemSubClassInfo(self.classID, self.subClassID)
            or C_Item.GetItemClassInfo(self.classID)
        name= e.cn(name)
        name= name..' '..(self.subClassID or self.classID)
        self.Text:SetText(name or '')
    end

    function btn:set_tooltip()
        e.tips:SetOwner(self:GetParent().Background, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local find=0
        for itemID, count in pairs(self.bankItems or {}) do
            if find==0 then
                e.tips:AddDoubleLine(' ', (e.onlyChinese and '银行' or BANK)..'|A:Banker:0:0|a')
            end
            e.tips:AddLine(
                WoWTools_ItemMixin:GetName(itemID, nil, nil, {notCount=true})..(' x'..count)
            )
            find=find+1
        end
        local find2=0
        for itemID, count in pairs(self.bagItems or {}) do
            if find2==0 then
                e.tips:AddDoubleLine(' ', (e.onlyChinese and '背包' or INVTYPE_BAG)..'|A:bag-main:0:0|a')
            end
            e.tips:AddLine(
                WoWTools_ItemMixin:GetName(itemID, nil, nil, {notCount=true})..(' x'..count)
            )
            find2=find2+1
        end
        if find==0 and find2==0 then
            e.tips:AddLine((e.onlyChinese and '提取/存放' or (WITHDRAW..'/'..DEPOSIT))..e.Icon.left)
            e.tips:AddLine('classID '..self.classID..(self.subClassID and '-'..self.subClassID or ''))
        end
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
            Take_Item(true, data.classID, data.subClassID)
        end, {classID=self.classID, subClassID=self.subClassID})
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(tooltip:AddLine('|A:common-icon-rotateright:0:0|a'..(e.onlyChinese and '银行' or BANK)))
        end)

        sub=root:CreateButton('|A:Cursor_buy_32:0:0|a'..(e.onlyChinese and '存放' or DEPOSIT)..' '..(self.bagNumText or ''), function(data)
            Take_Item(false, data.classID, data.subClassID)
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
--生成,物品列表
local function Init_Button_List(isBank, isReagent, isAccount)
    local num=0
    if isBank or isAccount then
        for index, classID in pairs({0, 1, 2, 3, 4, 5, 7, 8, 9, 12, 13, 15, 16, 17}) do
            num= index
            local btn= Buttons[index] or Create_ListButton(index)
            btn.classID= classID
            btn.subClassID= nil
            btn:set_text()
            btn:SetShown(true)
        end
    elseif isReagent then
        for index= 0, 19 do
            num= num+1
            local btn= Buttons[num] or Create_ListButton(num)
            btn.classID= 7
            btn.subClassID= index
            btn:set_text()
            btn:SetShown(true)
        end
    end

--背景,设置右下角 frame.Background
    --ListButton.frame.Background:SetPoint('BOTTOMRIGHT', Buttons[num] or ListButton, 2, -2)
    ListButton.frame.Background:SetHeight(num*23+4)
    ListButton.frame.Background:SetShown(num>0)

--隐藏，并清除数据
    for index= num+1, #Buttons do
        local btn=Buttons[index]
        btn:SetShown(false)
    end
end










local function Get_Item_Data(tab, class, info)
    tab[class]= tab[class] or
                {
                    num=0,
                    items={}
                }
    tab[class].num= tab[class].num+ (info.stackCount or 1)
    tab[class].items[info.itemID]= (tab[class].items[info.itemID] or 0) +(info.stackCount or 1)
    return tab
end










local function Set_Label()
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

    for _, data in pairs(
        isBank and WoWTools_BankMixin:GetItems(1)--银行
        or (isReagent and WoWTools_BankMixin:GetItems(2))--材料银行
        or (isAccount and WoWTools_BankMixin:GetItems(3))--战团银行
    ) do
        if not data.info.isLocked then
            local classID, subClassID = select(6, C_Item.GetItemInfoInstant(data.info.itemID))
            if isReagent then--材料银行
                if classID==7 and subClassID then
                    --bankClass[subClassID]= (bankClass[subClassID] or 0)+ (data.info.stackCount or 1)
                    bankClass= Get_Item_Data(bankClass, subClassID, data.info)
                end
            elseif classID then
                --bankClass[classID]= (bankClass[classID] or 0)+ (data.info.stackCount or 1)
                bankClass= Get_Item_Data(bankClass, classID, data.info)
            end
        end
    end

--背包+材料包
    if isBank or isReagent or isAccount then
        for _, data in pairs(WoWTools_BagMixin:GetItems(true) or {}) do
            if not data.info.isLocked then
                local classID, subClassID = select(6, C_Item.GetItemInfoInstant(data.info.itemID))

                if isReagent then--材料银行
                    if classID==7 and subClassID then
                        --bagClass[subClassID]= (bagClass[subClassID] or 0)+ (data.info.stackCount or 1)
                        bagClass= Get_Item_Data(bagClass, subClassID, data.info)
                    end
                elseif classID then
                    bagClass= Get_Item_Data(bagClass, classID, data.info)
                    --bagClass[classID]= (bagClass[classID] or 0)+ (data.info.stackCount or 1)
                end
            end
        end
    end

--背景
    local maxWidth= 0
    local bank, bag, width, class, bankData, bagData
    for _, btn in pairs(Buttons) do
        class= btn.subClassID or btn.classID

        bankData= bankClass[class] or {num=0, items={}}
        bagData= bagClass[class] or {num=0, items={}}

        bank= bankData.num
        bag= bagData.num

        btn.bankItems= bankData.items
        btn.bagItems= bagData.items

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
    ListButton.frame.Background:SetWidth(maxWidth==0 and 0 or maxWidth+8)

    ListButton.isBank= isBank
    ListButton.isReagent= isReagent
    ListButton.isAccount= isAccount


    isRun=nil
end






























local function Init()
    --ListButton= WoWTools_ButtonMixin:Cbtn(BankFrame, {size=23, icon='hide', name='WoWTools_BankMixinLeftListButton'})
    ListButton=WoWTools_ButtonMixin:CreateMenu(BankFrame, {
        name='WoWToolsBankLeftListButton',
        hideIcon=true,
        atlas='NPE_ArrowDownGlow',
    })

--提示，当前银行，类型
    ListButton.Text= WoWTools_LabelMixin:Create(ListButton, {justifyH='RIGHT', color=true})
    ListButton.Text:SetPoint('RIGHT', -2,0)

--控制Frame
    ListButton.frame=CreateFrame('Frame', nil, ListButton)
    ListButton.frame:SetPoint('BOTTOMRIGHT')
    ListButton.frame:SetSize(1,1)
    ListButton.frame:Hide()

--显示背景 frame.Background
    ListButton.frame.Background= ListButton.frame:CreateTexture(nil, 'BACKGROUND')
    ListButton.frame.Background:SetPoint('TOPRIGHT', 2, 1)--右上角
    ListButton.frame.Background:EnableMouse(true)

--提示，当前银行，类型
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



    function ListButton:Settings()
        local show= Save().left_List
        local showLeftList= Save().showLeftList
        if show and showLeftList then
            local showBackground= Save().showBackground
            self.frame.Background:SetAtlas(showBackground and 'bank-frame-background' or 'UI-Frame-DialogBox-BackgroundTile')
            self.frame.Background:SetAlpha(showBackground and 1 or 0.7)
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










--菜单
    ListButton:SetupMenu(function(self, root)
        local sub
        root:CreateCheckbox(
            e.onlyChinese and '显示' or SHOW,
        function()
            return Save().showLeftList
        end, function()
            Save().showLeftList= not Save().showLeftList and true or nil
            self:Settings()
            self:set_tooltip()
            if Save().showLeftList then
                Set_Label()
            end
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
    end)










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













--存取，分类，按钮
function WoWTools_BankMixin:Init_Left_List()
    if self.Save.left_List and not ListButton then
        Init()
    elseif ListButton then
        ListButton:Settings()
        Set_Label()
    end
end