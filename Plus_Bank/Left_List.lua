
--存取，分类，按钮

local function Save()
    return WoWToolsSave['Plus_Bank']
end

local ListButton
local Buttons={}












local function Set_Tooltip(self, tooltip, type)
    if Save().hideLeftListTooltip then
        return 1,1
    end
    tooltip:SetOwner(ListButton.frame.Background, "ANCHOR_LEFT")
    tooltip:ClearLines()
    local name, col
    local find=0
    if type==0 or type==1 then
        for itemID, count in pairs(self.bankItems or {}) do
            if find==0 then
                tooltip:AddDoubleLine(' ', (WoWTools_Mixin.onlyChinese and '银行' or BANK)..'|A:Banker:0:0|a')
            end

            find=find+1
            name= WoWTools_ItemMixin:GetName(itemID, nil, nil, {notCount=true})
            col= select(4, WoWTools_ItemMixin:GetColor(nil, {itemID=itemID}))

            tooltip:AddDoubleLine(
                name..(' x'..count),
                (col or '').. find
            )
        end
    end
    local find2=0
    if type==0 or type==2 then
        for itemID, count in pairs(self.bagItems or {}) do
            if find2==0 then
                tooltip:AddDoubleLine(' ', (WoWTools_Mixin.onlyChinese and '背包' or INVTYPE_BAG)..'|A:bag-main:0:0|a')
            end
            find2=find2+1
            name= WoWTools_ItemMixin:GetName(itemID, nil, nil, {notCount=true})
            col= select(4, WoWTools_ItemMixin:GetColor(nil, {itemID=itemID}))

            tooltip:AddDoubleLine(
                name..(' x'..count),
                (col or '').. find2
            )
        end
    end
    return find, find2
end








local function Init_Button_Menu(self, root)
    if not self.classID then
        return
    end

--提取             
    local sub=root:CreateButton(
        (self.bankNum==0 and '|cff828282' or '')
        ..'|A:Cursor_OpenHand_32:0:0|a'
        ..(WoWTools_Mixin.onlyChinese and '提取' or WITHDRAW)
        ..' '..(self.bankNumText or '')
        ..'  '..WoWTools_BagMixin:GetFree(self.classID==7),
    function()
        WoWTools_BankMixin:Take_Item(true, self.classID, self.subClassID)
    end)
    sub:SetTooltip(function(tooltip)
        local find, find2= Set_Tooltip(self, tooltip, 1)
        if find==0 and find2==0 then
            tooltip:AddLine(tooltip:AddLine('|A:common-icon-rotateright:0:0|a'..(WoWTools_Mixin.onlyChinese and '银行' or BANK)))
        end
    end)

--存放
    sub=root:CreateButton(
        (self.bagNum==0 and '|cff828282' or '')
        ..'|A:Cursor_buy_32:0:0|a'
        ..(WoWTools_Mixin.onlyChinese and '存放' or DEPOSIT)
        ..' '..(self.bagNumText or '')
        ..'  '..WoWTools_BankMixin:GetFree(),
    function()
        WoWTools_BankMixin:Take_Item(false, self.classID, self.subClassID)

    end)
    sub:SetTooltip(function(tooltip)
        local find, find2= Set_Tooltip(self, tooltip, 2)
        if find==0 and find2==0 then
            tooltip:AddLine('|A:common-icon-rotateright:0:0|a'..(WoWTools_Mixin.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL))
        end
    end)

    --root:CreateDivider()
    --root:CreateTitle(self.Text:GetText())--..' '..(self.classID..(self.subClassID and '-'..self.subClassID or '')))
end






local function Set_Button_Text(self)
    local name= self.subClassID
        and C_Item.GetItemSubClassInfo(self.classID, self.subClassID)
        or C_Item.GetItemClassInfo(self.classID)
    name= WoWTools_TextMixin:CN(name)
    name= name..' '..(self.subClassID or self.classID)
    self.Text:SetText(name or '')
end







local function Create_ListButton(index)
    local btn=WoWTools_ButtonMixin:Menu(ListButton.frame, {
        name='WoWToolsBankLeftListClassButton'..index,
        icon='hide',
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
        self.bankNumText=nil
        self.bagNumText=nil
        self.bankNum=nil
        self.bagNum=nil
    end


    function btn:set_tooltip()
        if not self.classID then
            return
        end

        local find, find2= Set_Tooltip(self, GameTooltip, 0)
        if find==0 and find2==0 then
            GameTooltip:AddLine((WoWTools_Mixin.onlyChinese and '提取/存放' or (WITHDRAW..'/'..DEPOSIT))..WoWTools_DataMixin.Icon.left)
            GameTooltip:AddLine('classID '..self.classID..(self.subClassID and '-'..self.subClassID or ''))
        end
        GameTooltip:Show()
    end

    btn:SetPoint('TOPRIGHT', index==1 and ListButton.frame or Buttons[index-1], 'BOTTOMRIGHT')

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', btn.set_tooltip)
    btn:SetScript('OnMouseDown', btn.set_tooltip)
    btn:SetScript('OnHide', btn.rest)

    btn:SetupMenu(function(...)
        Init_Button_Menu(...)
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
        for index, classID in pairs({0, 1, 2, 3, 4, 5, 7, 8, 9, 12, 13, 15, 16, 17, 19}) do
            num= index
            local btn= Buttons[index] or Create_ListButton(index)
            btn.classID= classID
            btn.subClassID= nil
            Set_Button_Text(btn)
            btn:SetShown(true)
        end
    elseif isReagent then
        for index= 1, 19 do
            num= num+1
            local btn= Buttons[num] or Create_ListButton(num)
            btn.classID= 7
            btn.subClassID= index
            Set_Button_Text(btn)
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
    if not ListButton.frame:IsVisible() then
        return
    end

    local isBank, isReagent, isAccount= WoWTools_BankMixin:GetActive()

    --生成,物品列表
    do
        Init_Button_List(isBank, isReagent, isAccount)
    end

    local bankClass={}
    local bagClass={}
    local bagItems, bankFree
--银行
    for _, data in pairs(WoWTools_BankMixin:Take_Item(true, nil, nil, nil, true)) do
        if isReagent and data.classID==7 or not isReagent then
            bankClass= Get_Item_Data(bankClass, isReagent and data.subClassID or data.classID, data.info)
        end
    end

--背包+材料包
    if isBank or isReagent or isAccount then
        bagItems, bankFree= WoWTools_BankMixin:Take_Item(false, nil, nil, nil, true)
        for _, data in pairs(bagItems) do
            if isReagent and data.classID==7 or not isReagent then
                bagClass= Get_Item_Data(bagClass, isReagent and data.subClassID or data.classID, data.info)
            end
        end
    end

--背景
    local maxWidth= 0
    local bank, bag, width, class, bankData, bagData
    for _, btn in pairs(Buttons) do
        if btn:IsShown() then
            class= isReagent and btn.subClassID or btn.classID

            bankData= bankClass[class] or {num=0, items={}}
            bagData= bagClass[class] or {num=0, items={}}

            bank= bankData.num
            bag= bagData.num

            btn.bankItems= bankData.items
            btn.bagItems= bagData.items

            btn.bankNumText= (bank==0 and '|cff9e9e9e' or '|cffffffff')..WoWTools_Mixin:MK(bank, 3)..'|A:Banker:0:0|a|r'
            btn.bagNumText= ( bag==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..WoWTools_Mixin:MK(bag, 3)..'|A:bag-main:0:0|a|r'

            btn.bankNum=bank
            btn.bagNum=bag

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
    end

--背景,设置左边
    ListButton.frame.Background:SetWidth(maxWidth==0 and 0 or maxWidth+8)

--提示，当前银行，类型
    ListButton.bankSlotFree= bankFree--空栏位
    ListButton:set_bank_type()
end
    --[[ListButton.isBank= isBank
    ListButton.isReagent= isReagent
    ListButton.isAccount= isAccount]]































local function Init()
    if not Save().left_List then
        return
    end

    ListButton=WoWTools_ButtonMixin:Menu(BankFrame, {
        name='WoWToolsBankLeftListButton',
        atlas='NPE_ArrowDownGlow',
    })
    ListButton:SetPoint('TOPRIGHT', BankFrame, 'TOPLEFT', -2, -20)

--提示，当前银行，类型
    ListButton.Text= WoWTools_LabelMixin:Create(ListButton, {justifyH='RIGHT', color=true})
    ListButton.Text:SetPoint('RIGHT', -2,0)

--控制Frame
    ListButton.frame=CreateFrame('Frame', nil, ListButton)
    ListButton.frame:SetPoint('BOTTOMRIGHT', 0, -12)
    ListButton.frame:SetSize(1,1)
    ListButton.frame:Hide()

--显示背景 frame.Background
    ListButton.frame.Background= ListButton.frame:CreateTexture('WoWToolsBankLeftListClassBackground', 'BACKGROUND')
    ListButton.frame.Background:SetPoint('TOPRIGHT', 2, 1)--右上角
    ListButton.frame.Background:EnableMouse(true)

--提示，当前银行，类型
    function ListButton:set_bank_type()
        if not self.frame:IsVisible() then
            self.Text:SetText('')
            self:SetWidth(23)
            return
        end

        local index= WoWTools_BankMixin:GetIndex()
        local text=
            index==1 and (WoWTools_Mixin.onlyChinese and '银行' or BANK)
            or index==2 and (WoWTools_Mixin.onlyChinese and '材料' or BANK_TAB_ASSIGN_REAGENTS_CHECKBOX)
            or index==3 and (WoWTools_Mixin.onlyChinese and '战团' or ACCOUNT_QUEST_LABEL)
--空栏位
        text= (self.bankSlotFree and self.bankSlotFree..' ' or '')..(text or '')

        self.Text:SetText(text)
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
        self:set_bank_type()--提示，当前银行，类型
        self:SetShown(show)
    end
    function ListButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_BankMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end


    ListButton:SetScript('OnLeave', function (self)
        self:Settings()
        GameTooltip:Hide()
    end)
    ListButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:SetAlpha(1)
    end)










--菜单
    ListButton:SetupMenu(function(self, root)
        local sub
        root:CreateCheckbox(
            WoWTools_Mixin.onlyChinese and '显示' or SHOW,
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

        sub:CreateCheckbox(
            WoWTools_Mixin.onlyChinese and 'HUD提示信息' or HUD_EDIT_MODE_HUD_TOOLTIP_LABEL,
        function()
            return not Save().hideLeftListTooltip
        end, function()
            Save().hideLeftListTooltip= not Save().hideLeftListTooltip and true or nil
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
    --AccountBankPanel.PurchaseTab:HookScript('OnClick', Set_Label)

    return true
end













--存取，分类，按钮
function WoWTools_BankMixin:Init_Left_List()
    if Init() then
        Init=function()
            ListButton:Settings()
            Set_Label()
        end
    end
end