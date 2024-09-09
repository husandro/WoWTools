local e= select(2, ...)

local function Save()
    return WoWTools_ButtonMixin.Save
end



--大包时，显示，存取，分类，按钮
local function Init()
    local btn= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size=23, icon='hide'})
    btn:SetPoint('TOPRIGHT', BankFrame, 'TOPLEFT', -2, -32)
    btn.frame=CreateFrame('Frame', nil, btn)
    btn.frame:SetPoint('BOTTOMRIGHT')
    btn.frame:SetSize(1,1)
    function btn:settings()
        self:SetNormalAtlas(Save().show_AllBank_Type and 'NPE_ArrowDown' or e.Icon.disabled)
        self:SetAlpha(Save().show_AllBank_Type and 1 or 0.3)
        self.frame:SetShown(Save().show_AllBank_Type)
        self.frame:SetScale(Save().show_AllBank_Type_Scale or 1)
    end
    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(Save().show_AllBank_Type), e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..': |cnGREEN_FONT_COLOR:'..(Save().show_AllBank_Type_Scale or 1), e.Icon.mid)
        e.tips:Show()
    end
    btn:SetScript('OnClick', function(self)
        Save().show_AllBank_Type= not Save().show_AllBank_Type and true or nil
        self:settings()
        self:set_tooltips()
    end)
    btn:SetScript('OnMouseWheel', function(self, d)
        local n
        n= Save().show_AllBank_Type_Scale or 1
        n= d==1 and n-0.05 or n
        n= d==-1 and n+0.05 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        if n==1 then n=nil end
        Save().show_AllBank_Type_Scale= n
        self:settings()
        self:set_tooltips()
    end)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', btn.set_tooltips)
    btn:settings()

    btn.buttons={}
    function btn.frame:take_out_item(classID)--取出，ClassID 物品
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
    function btn.frame:desposit_item(classID)--存放，ClassID 物品
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
    local last= btn.frame
    for classID=0, 19 do
        if classID~=6 and classID~=10 and classID~=14 and classID~=11 and classID~=7 then
            local className=C_Item.GetItemClassInfo(classID)--生成,物品列表
            if className then
                local frame= WoWTools_ButtonMixin:Cbtn(btn.frame, {icon='hide'})
                frame.Text= e.Cstr(frame, {justifyH='RIGHT'})
                frame.Text:SetPoint('RIGHT', -2,0)
                frame.Text:SetText(e.cn(className)..' '..classID)
                frame.Label= e.Cstr(frame, {justifyH='RIGHT'})
                frame.Label:SetPoint('RIGHT', frame, 'LEFT', -4, 0)
                frame:SetSize(frame.Text:GetWidth()+4, 18)
                frame:SetPoint('TOPRIGHT', last, 'BOTTOMRIGHT')
                frame:SetScript('OnClick', function(self, d)
                    if d=='LeftButton' then--取出
                        self:GetParent():take_out_item(self.classID)
                    elseif d=='RightButton' then--存放
                        self:GetParent():desposit_item(self.classID)
                    end
                end)
                frame:SetScript('OnLeave', GameTooltip_Hide)
                frame:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    local text= self.Label:GetText() or ''

                    e.tips:AddDoubleLine(
                        e.Icon.left..(e.onlyChinese and '取出' or 'take out'),--..(text:match('(.-|A:Banker:0:0|a)') or ''),
                        (e.onlyChinese and '存放' or 'on bank')..e.Icon.right
                    )

                    e.tips:Show()
                end)
                frame.classID= classID
                last=frame
                table.insert(btn.buttons, frame)
            end
        end
    end
    function btn:set_event()
        if self:IsShown() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:set_label()
        else
            self:UnregisterAllEvents()
        end
    end


    function btn:set_label()
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
            if bank==0 and bag==0 then
                frame.Label:SetText('')
            else
                frame.Label:SetText(
                    (bank==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..e.MK(bank, 3)..'|A:Banker:0:0|a'
                    ..'|A:bag-main:0:0|a'..( bag==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..e.MK(bag, 3)
                )
            end
        end
        self.isRun=nil
    end
    btn:SetScript('OnShow', btn.set_event)
    btn:SetScript('OnHide', btn.set_event)
    btn:SetScript('OnEvent', btn.set_label)
end


function WoWTools_ButtonMixin:Init_DespositTakeOut_List()
    Init()
end