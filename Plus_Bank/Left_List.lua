local e= select(2, ...)

local function Save()
    return WoWTools_BankMixin.Save
end











local function Init_Menu(self, root)
    local sub=root:CreateButton('|A:Cursor_OpenHand_32:0:0|a'..(e.onlyChinese and '提取' or WITHDRAW)..' '..(self.bankNumText or ''), function(data)
        self:GetParent():take_out_item(data.classID)
    end, {classID=self.classID})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(tooltip:AddLine('|A:common-icon-rotateright:0:0|a'..(e.onlyChinese and '银行' or BANK)))
    end)
    
    sub=root:CreateButton('|A:Cursor_buy_32:0:0|a'..(e.onlyChinese and '存放' or DEPOSIT)..' '..(self.bagNumText or ''), function(data)
        self:GetParent():desposit_item(data.classID)
    end, {classID=self.classID})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('|A:common-icon-rotateleft:0:0|a'..(e.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL))
    end)

    root:CreateDivider()
    root:CreateTitle(self.Text:GetText())
end














--大包时，显示，存取，分类，按钮
local ListButton
local function Init()
    ListButton= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size=23, icon='hide', name='WoWTools_BankMixinLeftListButton'})
    ListButton:SetPoint('TOPRIGHT', BankFrame, 'TOPLEFT', -2, -32)

    ListButton.frame=CreateFrame('Frame', nil, ListButton)
    ListButton.frame:SetPoint('BOTTOMRIGHT')
    ListButton.frame:SetSize(1,1)

    function ListButton:settings()
        self:SetNormalAtlas(Save().showLeftList and 'NPE_ArrowDown' or 'RedButton-MiniCondense')
        self:SetAlpha(Save().showLeftList and 1 or 0.3)
        self.frame:SetShown(Save().showLeftList)
        self.frame:SetScale(Save().leftListScale or 1)
    end
    function ListButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_BankMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(Save().showLeftList), e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..': |cnGREEN_FONT_COLOR:'..(Save().leftListScale or 1), e.Icon.mid)
        e.tips:Show()
    end
    ListButton:SetScript('OnClick', function(self)
        Save().showLeftList= not Save().showLeftList and true or nil
        self:settings()
        self:set_tooltips()
    end)
    ListButton:SetScript('OnMouseWheel', function(self, d)
        local n
        n= Save().leftListScale or 1
        n= d==1 and n-0.05 or n
        n= d==-1 and n+0.05 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        if n==1 then n=nil end
        Save().leftListScale= n
        self:settings()
        self:set_tooltips()
    end)
    ListButton:SetScript('OnLeave', GameTooltip_Hide)
    ListButton:SetScript('OnEnter', ListButton.set_tooltips)
    ListButton:settings()













    ListButton.buttons={}

--取出，ClassID 物品
    function ListButton.frame:take_out_item(classID)
        local free= WoWTools_BagMixin:GetFree()--背包，空位
        if free==0 then
            return
        end
        for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
            for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
                if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID and select(6, C_Item.GetItemInfoInstant(info.itemID))==classID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
        for i=NUM_BANKGENERIC_SLOTS, 1, -1 do--28
            if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
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
    function ListButton.frame:desposit_item(classID)
        local free= WoWTools_BankMixin:GetFree()--银行，空位
        if free==0 then
            return
        end
        for bag= NUM_BAG_FRAMES,  BACKPACK_CONTAINER, -1 do-- + NUM_REAGENTBAG_FRAMES do--NUM_TOTAL_EQUIPPED_BAG_SLOTS
            for slot= C_Container.GetContainerNumSlots(bag), 1, -1 do
                if not self:IsVisible() or IsModifierKeyDown() or free==0 then
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.itemID and select(6, C_Item.GetItemInfoInstant(info.itemID))==classID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
    end

    local last= ListButton.frame
--生成,物品列表
    for classID=0, 20 do
        if classID~=6--弹药 Projectile
        and classID~=10--货币代币 CurrencyTokenObsolete
        and classID~=14--PermanentObsolete
        and classID~=11--Quiver
        --and classID~=7 绷带
    then
            local className=C_Item.GetItemClassInfo(classID)
            if className then
                local frame= WoWTools_ButtonMixin:Cbtn(ListButton.frame, {icon='hide'})
                frame.Text= WoWTools_LabelMixin:Create(frame, {justifyH='RIGHT'})
                frame.Text:SetPoint('RIGHT', -2,0)
                frame.Text:SetText(e.cn(className)..' '..classID)
                frame.Label= WoWTools_LabelMixin:Create(frame, {justifyH='RIGHT'})
                frame.Label:SetPoint('RIGHT', frame, 'LEFT', -4, 0)
                frame:SetSize(frame.Text:GetWidth()+4, 18)
                frame:SetPoint('TOPRIGHT', last, 'BOTTOMRIGHT')
                frame:SetScript('OnClick', function(self)
                    MenuUtil.CreateContextMenu(self, Init_Menu)
                end)
                frame:SetScript('OnLeave', GameTooltip_Hide)
                frame:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(self.Label, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddLine((e.onlyChinese and '提取/存放' or (WITHDRAW..'/'..DEPOSIT))..e.Icon.left)
                    e.tips:AddLine('classID '..self.classID)
                    e.tips:Show()
                end)
                frame.classID= classID
                last=frame
                table.insert(ListButton.buttons, frame)
            end
        end
    end

--事件
    function ListButton:set_event()
        if self:IsShown() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:set_label()
        else
            self:UnregisterAllEvents()
        end
    end

--设置，label
    function ListButton:set_label()
        if not self:IsShown() or self.isRun then return end
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
                local classID = info.itemID and select(6, C_Item.GetItemInfoInstant(info.itemID))
                if classID then
                    bagClass[classID]= (bagClass[classID] or 0)+ (info.stackCount or 1)
                end
            end
        end
        for _, frame in pairs(self.buttons) do
            local bank= bankClass[frame.classID] or 0
            local bag= bagClass[frame.classID] or 0

            frame.bankNumText= '|A:Banker:0:0|a'..(bank==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..WoWTools_Mixin:MK(bank, 3)
            frame.bagNumText= '|A:bag-main:0:0|a'..( bag==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..WoWTools_Mixin:MK(bag, 3)

            if bank==0 and bag==0 then
                frame.Label:SetText('')
            else
                frame.Label:SetText(frame.bankNumText..' '..frame.bagNumText)
            end
        end
        self.isRun=nil
    end

    ListButton:SetScript('OnShow', ListButton.set_event)
    ListButton:SetScript('OnHide', ListButton.set_event)
    ListButton:SetScript('OnEvent', ListButton.set_label)
end









--分类，存取,
function WoWTools_BankMixin:Init_Left_List()
    if self.Save.left_List and not ListButton then
        Init()
    elseif ListButton then
        ListButton:SetShown(self.Save.left_List)
    end
end