
local function Save()
    return WoWToolsSave['Tools_Foods']
end



local Buttons={}









local function Set_Button_Function(btn)
    btn:SetAttribute("type1", "item")
    btn.count= WoWTools_LabelMixin:Create(btn, {size=12, color={r=1,g=1,b=1}})--10, nil,nil, true)
    btn.count:SetPoint('BOTTOMRIGHT', -4,4)
    btn.numCount=0
    btn.enableCooldown=true

    function btn:set_attribute()
        local icon= C_Item.GetItemIconByID(self.itemID)
        local name=  C_Item.GetItemNameByID(self.itemID)
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
        local start, duration, enable = C_Item.GetItemCooldown(self.itemID)--C_Container.GetItemCooldown(self.itemID)
        WoWTools_CooldownMixin:Setup(self, start, duration, nil, true, nil, true)--冷却条
        btn.enableCooldown= enable
    end

    function btn:set_alpha(alpha)
        self.texture:SetAlpha(alpha or (self.numCount>0 and 1) or 0.3)
    end

    function btn:set_count()
        local num= C_Item.GetItemCount(self.itemID, false, true, true, false)--  false, true, true)
        self.count:SetText(num==0 and '|cff9e9e9e0|r' or (num~=1 and num) or '')
        self.numCount=num
        self:set_alpha()
    end


    function btn:set_desaturated()
        self.texture:SetDesaturated(not self.enableCooldown or self.numCount==0)
    end


    function btn:settings()
        self:set_cool()
        self:set_count()
        self:set_desaturated()
        self:set_alpha()
        self.border:SetAlpha(Save().borderAlpha or 0.5)
    end

    function btn:set_event()
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        self:RegisterEvent('BAG_UPDATE_COOLDOWN')
    end


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
                self:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
            end

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:set_attribute()
            self.isSetAttributeInCombat=nil
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end)

    btn:set_event()
end


















local function Create_Button(index)
    local name= 'WoWToolsFoodListButton'..index
    local btn= WoWTools_ButtonMixin:Cbtn(WoWTools_FoodMixin.Button, {
        setID=index,
        name= name,
        isType2=true,
        isSecure=true,
    })

    Set_Button_Function(btn)

    btn:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        WoWTools_BagMixin:Find()
        self:set_cool()
        self:set_alpha()
        self:set_count()
        self:set_desaturated()
    end)
    btn:SetScript('OnEnter', function(self)
        local can= self:CanChangeAttribute()
        WoWTools_SetTooltipMixin:Frame(self, GameTooltip, {
            itemID=self.itemID,
            tooltip='|n|A:dressingroom-button-appearancelist-up:0:0|a'
                ..(can and '' or '|cff9e9e9e')
                ..(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.right,
        })
        self:settings()
        if can then
            self:set_attribute()
        end
        WoWTools_BagMixin:Find(true, {itemID= self.itemID})--查询，背包里物品
    end)

    btn:SetScript('OnMouseDown',function(self, d)
        if d=='RightButton' and self:CanChangeAttribute() then
            MenuUtil.CreateContextMenu(self, function(f, root)
                root:CreateButton('|T'..(C_Item.GetItemIconByID(f.itemID) or 0)..':0|t'..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE), function()
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
        self:SetPoint('RIGHT', _G[Buttons[self:GetID()-1]] or WoWTools_FoodMixin.Button, 'LEFT')
    end



    table.insert(Buttons, name)--添加


    return btn
end

















--检查,物品
function WoWTools_FoodMixin:Check_Items(isPrint)
    if not self.CheckFrame then
        return
    end

    if self.CheckFrame.isChecking then--正在查询
        return
    elseif not self:CanChangeAttribute() then
        self.CheckFrame.isCheckInCombat=true
        self.CheckFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
    self.CheckFrame.isChecking=true



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
        if WoWTools_FoodMixin.Button.itemID~=itemID and (Save().addItemsShowAll or C_Item.GetItemCount(itemID, false, true, true, false)>0) then
            table.insert(items, itemID)
        end
    end
    table.sort(items)
    for _, itemID in pairs(items) do
        table.insert(new, 1, itemID)
    end

    local index=0
    for _, itemID in pairs(new) do
        index= index +1
        local btn= _G[Buttons[index]] or Create_Button(index)--创建
        btn.itemID= itemID
        btn:settings()
        btn:set_attribute()

        btn:set_point()
        if not btn:IsShown() then
            btn:set_event()
            btn:Show()
        end
    end


    for i=Save().numLine, index, Save().numLine do
        local btn= _G[Buttons[i]]
        if btn then
            btn:ClearAllPoints()
            btn:SetPoint('BOTTOM', _G[Buttons[i-Save().numLine]] or WoWTools_FoodMixin.Button, 'TOP')
            self.Button.Background:SetPoint('TOP', btn, 1, 1)
        end
    end
    self.Button.Background:SetPoint('LEFT', _G[Buttons[Save().numLine-1]] or _G[Buttons[index-1]] or self.Button, -1, -1)


    for i= index , #Buttons do
        local btn= _G[Buttons[i]]
        if btn and btn:IsShown() then
            btn.itemID=nil
            btn:SetAttribute("type1", nil)
            btn:SetAttribute("item1", nil)
            btn.texture:SetTexture(0)
            btn:Hide()
            WoWTools_CooldownMixin:Setup(btn)
            btn:UnregisterAllEvents()
        end
    end

    WoWTools_FoodMixin.Button:settings()

    if isPrint then
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_FoodMixin.addName, WoWTools_DataMixin.onlyChinese and '查询完成' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WHO, COMPLETE) )
    end
    self.CheckFrame.isChecking=nil
end



















local function Init()
    WoWTools_FoodMixin.CheckFrame= CreateFrame('Frame')

    function WoWTools_FoodMixin.CheckFrame:set_event()
        self:UnregisterAllEvents()
        if Save().autoWho then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
        end
    end

    WoWTools_FoodMixin.CheckFrame:SetScript('OnEvent', function(self, event)
        WoWTools_FoodMixin:Check_Items()--检查,物品
        if event=='PLAYER_REGEN_ENABLED' then
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end)

    Init=function()end
end




function WoWTools_FoodMixin:Set_Button_Function(btn)
    Set_Button_Function(btn)
end

function WoWTools_FoodMixin:Init_Check()
    Init()
end