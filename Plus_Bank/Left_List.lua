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






local function Set_Label()
    local self= ListButton.frame
    if not self:IsVisible() or self.isRun then
        return
    end

    self.isRun=true

    local bankClass={}
    for i=1, NUM_BANKGENERIC_SLOTS do--28
        local itemInfo= WoWTools_BankMixin:GetItemInfo(BankSlotsFrame["Item"..i])
        if itemInfo then
            local classID = select(6, C_Item.GetItemInfoInstant(itemInfo.itemID))
            bankClass[classID]= (bankClass[classID] or 0)+ (itemInfo.stackCount or 1)
        end
    end

    for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
        for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID then
                local classID = select(6, C_Item.GetItemInfoInstant(info.itemID))
                bankClass[classID]= (bankClass[classID] or 0)+ (info.stackCount or 1)
            end
        end
    end

    local bagClass={}
    for bag= BACKPACK_CONTAINER, NUM_BAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot) or {}
            local classID = info.itemID and not info.isLocked and select(6, C_Item.GetItemInfoInstant(info.itemID))
            if classID then
                bagClass[classID]= (bagClass[classID] or 0)+ (info.stackCount or 1)
            end
        end
    end


    local maxWidth= 0--背景
    local bank,bag,width
    for _, btn in pairs(Buttons) do
        bank= bankClass[btn.classID] or 0
        bag= bagClass[btn.classID] or 0

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
    self.Background:SetWidth(maxWidth+8)

    self.isRun=nil
end














local function Init_btn_Menu(self, root)
    local sub=root:CreateButton('|A:Cursor_OpenHand_32:0:0|a'..(e.onlyChinese and '提取' or WITHDRAW)..' '..(self.bankNumText or ''), function(data)
        take_out_item(data.classID)
    end, {classID=self.classID})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(tooltip:AddLine('|A:common-icon-rotateright:0:0|a'..(e.onlyChinese and '银行' or BANK)))
    end)

    sub=root:CreateButton('|A:Cursor_buy_32:0:0|a'..(e.onlyChinese and '存放' or DEPOSIT)..' '..(self.bagNumText or ''), function(data)
        desposit_item(data.classID)
    end, {classID=self.classID})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('|A:common-icon-rotateleft:0:0|a'..(e.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL))
    end)

    root:CreateDivider()
    root:CreateTitle(self.Text:GetText()..' '..self:GetID())
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
    --ListButton= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size=23, icon='hide', name='WoWTools_BankMixinLeftListButton'})
    ListButton=WoWTools_ButtonMixin:CreateMenu(BankSlotsFrame, {
        name='WoWToolsBankLeftListButton',
        hideIcon=true,
        atlas='NPE_ArrowDownGlow',
    })
    --ListButton:SetPushedAtlas('NPE_ArrowDown')
    ListButton:SetPoint('TOPRIGHT', BankFrame, 'TOPLEFT', -2, -32)

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

        end
        self.frame:SetShown(showLeftList and show)
        self:SetAlpha(showLeftList and 1 or 0.3)
        if showLeftList then
            self:SetNormalTexture(0)
        else
            self:SetNormalAtlas('NPE_ArrowRightGlow')
        end

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

    local last
--生成,物品列表
    for classID=0, Enum.ItemClassMeta.NumValues-1 do
        if classID~=6--弹药 Projectile
        and classID~=11--Quiver
        and classID~=10--货币代币 CurrencyTokenObsolete
        and classID~=14--PermanentObsolete
        and classID~=18--时光徽章
        --and classID~=7 绷带
    then
            local className=C_Item.GetItemClassInfo(classID)
            if className then

                local btn=WoWTools_ButtonMixin:CreateMenu(ListButton.frame, {
                    name='WoWToolsBankLeftListClass'..classID..'Button',
                    hideIcon=true,
                    setID= classID,
                })

                btn.Text= WoWTools_LabelMixin:Create(btn, {justifyH='RIGHT'})
                btn.Text:SetPoint('RIGHT', -2,0)
                btn.Text:SetText(e.cn(className))--..' '..classID)

                btn.Label= WoWTools_LabelMixin:Create(btn, {justifyH='RIGHT'})
                btn.Label:SetPoint('RIGHT', btn.Text, 'LEFT', -2, 0)

                function btn:set_tooltip()
                    e.tips:SetOwner(self.Label, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddLine((e.onlyChinese and '提取/存放' or (WITHDRAW..'/'..DEPOSIT))..e.Icon.left)
                    e.tips:AddLine('classID '..self.classID)
                    e.tips:Show()
                end

                btn:SetScript('OnLeave', GameTooltip_Hide)
                btn:SetScript('OnEnter', btn.set_tooltip)
                btn:SetScript('OnMouseDown', btn.set_tooltip)
                btn:SetPoint('TOPRIGHT', last or ListButton.frame, 'BOTTOMRIGHT')
                btn:SetupMenu(Init_btn_Menu)
                btn:SetSize(btn.Text:GetWidth()+4, 18)

                btn.classID= classID
                table.insert(Buttons, btn)

                last=btn
            end
        end
    end

--背景,设置右下角 frame.Background
    ListButton.frame.Background:SetPoint('BOTTOMRIGHT', last, 2, -2)




--事件
    function ListButton.frame:set_event()
        if self:IsVisible() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            Set_Label(self)
        else
            self:UnregisterEvent('BAG_UPDATE_DELAYED')
        end
    end

    ListButton.frame:SetScript('OnShow', ListButton.frame.set_event)
    ListButton.frame:SetScript('OnHide', ListButton.frame.set_event)
    ListButton.frame:SetScript('OnEvent', Set_Label)

    ListButton:Settings()

    function ListButton:set_parent()
        --local frame= _G[BANK_PANELS[BankFrame.activeTabIndex].name]
       --self:SetParent(frame or )
    end

    if e.Player.husandro then
        C_Timer.After(0.3, function()
            hooksecurefunc('BankFrame_ShowPanel', Set_Label)
        end)
    end
end









--分类，存取,
function WoWTools_BankMixin:Init_Left_List()
    if self.Save.left_List and not ListButton then
        Init()
    elseif ListButton then
        ListButton:Settings()
    end
end