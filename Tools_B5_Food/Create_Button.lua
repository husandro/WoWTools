
local function Save()
    return WoWToolsSave['Tools_Foods']
end



local Buttons={}




local function Set_Script(btn)
    if InCombatLockdown() then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            WoWTools_FoodMixin:Set_Button_Function(btn)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
        return
    end

    btn:SetAttribute("type1", "item")
    btn.count= WoWTools_LabelMixin:Create(btn, {size=12, color={r=1,g=1,b=1}})
    btn.count:SetPoint('BOTTOMRIGHT', -4,4)
    btn.numCount=0
    btn.enableCooldown=true

    function btn:set_attribute()
        local icon, name
        if self.itemID then
            WoWTools_DataMixin:Load(self.itemID, 'item')
            icon= select(5, C_Item.GetItemInfoInstant(self.itemID))
            name= C_Item.GetItemNameByID(self.itemID)
        end
        self.texture:SetTexture(icon or 0)

        if not icon or not name then
            self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
        end

        if self:CanChangeAttribute() then
            self:SetAttribute("item1", name)

        else
            self.isSetAttributeInCombat=true
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end

    end

    function btn:set_cool()
        local start, duration, enable
        if self.itemID then
            start, duration, enable = C_Item.GetItemCooldown(self.itemID)--C_Container.GetItemCooldown(self.itemID)
        end
        WoWTools_CooldownMixin:Setup(self, start, duration, nil, true, nil, true)--冷却条
        btn.enableCooldown= enable
    end

    function btn:set_alpha(alpha)
        self.texture:SetAlpha(alpha or (self.numCount and self.numCount>0 and 1) or 0.3)
    end

    function btn:set_count()
        local num
        if self.itemID then
            num= C_Item.GetItemCount(self.itemID, false, true, true, false)--  false, true, true)
        end

        self.count:SetText(num==0 and '|cff6262620|r' or (num~=1 and num) or '')
        self.numCount=num
        self:set_alpha()
    end


    function btn:set_desaturated()
        self.texture:SetDesaturated(not self.enableCooldown or not self.numCount or self.numCount==0)
    end


    function btn:settings()
        self:set_cool()
        self:set_count()
        self:set_desaturated()
        self:set_alpha()
        self.border:SetAlpha(Save().borderAlpha or 0.5)
    end

    function btn:set_event()
        if self:IsShown() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:RegisterEvent('BAG_UPDATE_COOLDOWN')
        else
            self:UnregisterAllEvents()
        end
    end


    btn:SetScript('OnShow', function(self)
        self:set_event()
    end)
    btn:SetScript('OnHide', function(self)
        self:set_event()
        self.itemID=nil
        if self:CanChangeAttribute() then
            self:SetAttribute("type1", nil)
            self:SetAttribute("item1", nil)
        end
        self.texture:SetTexture(0)
        WoWTools_CooldownMixin:Setup(self)
    end)

    btn:SetScript("OnEvent", function(self, event, arg1, arg2)
        if event=='BAG_UPDATE_DELAYED' then
            self:set_count()
            self:set_desaturated()

        elseif event=='BAG_UPDATE_COOLDOWN' then
            self:set_cool()
            self:set_desaturated()

        elseif event=='GET_ITEM_INFO_RECEIVED' then
            if arg1==self.itemID and arg2 then
                self:set_attribute()
                self:UnregisterEvent(event)
            end

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:set_attribute()
            self.isSetAttributeInCombat=nil
            self:UnregisterEvent(event)

        elseif event=='PLAYER_REGEN_DISABLED' then
            self:StopMovingOrSizing()
            self:UnregisterEvent(event)
        end
    end)

    btn:set_event()
end


















local function Create_Button(index)
    local name= 'WoWToolsFoodListButton'..index
    local btn= WoWTools_ButtonMixin:Cbtn(WoWTools_ToolsMixin:Get_ButtonForName('Food'), {
        setID=index,
        name= name,
        isType2=true,
        isSecure=true,
    })

    Set_Script(btn)

    function btn:set_tooltip()
        WoWTools_SetTooltipMixin:Frame(self, GameTooltip, {
            owner=WoWTools_ToolsMixin:Get_ButtonForName('Food'),
            anchor='ANCHOR_RIGHT',
            itemID=self.itemID,
            tooltip='|n|A:dressingroom-button-appearancelist-up:0:0|a'
                ..(self:CanChangeAttribute() and '' or '|cff626262')
                ..(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.right,
        })
    end

    btn:SetScript("OnLeave", function(self)
        self:SetScript('OnUpdate', nil)
        GameTooltip_Hide()
        WoWTools_BagMixin:Find()
        self:set_cool()
        self:set_alpha()
        self:set_count()
        self:set_desaturated()
    end)

    btn:SetScript('OnEnter', function(self)
        local e= 1
        self:SetScript('OnUpdate', function(s, elapsed)
            e= (e or 1) + elapsed
            if e>=1 then
                e=0
                s:set_tooltip()
            end
        end)

        self:settings()
        self:set_attribute()
        WoWTools_BagMixin:Find(true, {itemID= self.itemID})--查询，背包里物品
    end)

    btn:SetScript('OnMouseDown',function(self, d)
        if d=='RightButton' and self:CanChangeAttribute() then
            MenuUtil.CreateContextMenu(self, function(f, root)
                root:CreateButton('|T'..(select(5, C_Item.GetItemInfoInstant(f.itemID)) or 0)..':0|t'..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE), function()
                    Save().noUseItems[self.itemID]=true
                    Save().addItems[self.itemID]=nil
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_FoodMixin.addName, WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE, WoWTools_ItemMixin:GetLink(self.itemID))
                    WoWTools_FoodMixin:Check_Items()
                end)
            end)
        end
    end)

    function btn:set_point()
        self:ClearAllPoints()
        self:SetPoint('RIGHT', _G[Buttons[self:GetID()-1]] or WoWTools_ToolsMixin:Get_ButtonForName('Food'), 'LEFT')
    end



    table.insert(Buttons, name)--添加


    return btn
end

















--检查,物品
local IsChecking
function WoWTools_FoodMixin:Check_Items(isPrint)
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('Food')
    if IsChecking or not btn then--正在查询
        return
    elseif InCombatLockdown() then
        if btn.CheckFrame then
            btn.CheckFrame.isCheckInCombat=true
            btn.CheckFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
        return
    end
    IsChecking=true

    local new={}
    local items={}

    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local itemID= C_Container.GetContainerItemID(bag, slot)
            if WoWTools_FoodMixin:Get_Item_Valid(itemID) then
                items[itemID]=true
            end
        end
    end
    for itemID in pairs(items) do
        table.insert(new, itemID)
    end
    table.sort(new)

    items={}

    for itemID in pairs(Save().addItems) do
        if btn.itemID~=itemID and (Save().addItemsShowAll or C_Item.GetItemCount(itemID, false, true, true, false)>0) then
            table.insert(items, itemID)
        end
    end
    table.sort(items)
    for _, itemID in pairs(items) do
        table.insert(new, 1, itemID)
    end

    for index, itemID in pairs(new) do
        local b= _G[Buttons[index]] or Create_Button(index)--创建
        b.itemID= itemID
        b:settings()
        b:set_attribute()
        b:set_point()

        if not b:IsShown() then
            b:set_event()
            b:Show()
        end
    end

    local num= #new
    btn.Background:SetPoint('TOP', btn, 1, 1)
    for i=Save().numLine, num, Save().numLine do
        local b= _G[Buttons[i]]
        if b then
            b:ClearAllPoints()
            b:SetPoint('BOTTOM', _G[Buttons[i-Save().numLine]] or btn, 'TOP')
            btn.Background:SetPoint('TOP', b, 1, 1)
        end
    end
    btn.Background:SetPoint('LEFT', _G[Buttons[Save().numLine-1]] or _G[Buttons[num-1]] or btn, -1, -1)

    for i= num+1 , #Buttons do
        _G[Buttons[i]]:SetShown(false)
    end

    btn:settings()

    if isPrint then
        print(
            WoWTools_FoodMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_DataMixin.onlyChinese and '查询完成' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WHO, COMPLETE)
        )
    end
    IsChecking=nil
end











function WoWTools_FoodMixin:Set_Button_Function(btn)
    Set_Script(btn)
end