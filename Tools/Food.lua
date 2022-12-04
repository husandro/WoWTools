local id, e = ...
local addName= POWER_TYPE_FOOD
local Save={
    type={},
    noUseItems={}
}

local panel=e.Cbtn2(nil, WoWToolsMountButton, true, nil)
panel.itemID=5512--治疗石
if not C_Item.IsItemDataCachedByID(panel.itemID) then C_Item.RequestLoadItemDataByID(panel.itemID) end

local function setPanelPostion()--设置按钮位置
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('RIGHT', WoWToolsOpenItemsButton, 'LEFT')
    end
end

--#######
--图标冷却
--#######
local function set_Cooldown(self)--图标冷却
    if self.itemID then
        local start, duration = GetItemCooldown(self.itemID)
        e.Ccool(self, start, duration, nil, true, nil, true)--冷却条
    end
end

local function set_Item_Count(self)
    self.count:SetText(GetItemCount(self.itemID))
    self.texture:SetDesaturated(self.count==0)
end

--#########
--提示, 事件
--#########
local function set_Button_Init(self)
    if self.itemID then
        if not C_Item.IsItemDataCachedByID(self.itemID) then C_Item.RequestLoadItemDataByID(self.itemID) end

        panel:SetAttribute("type", "item")
        panel:SetAttribute("item", C_Item.GetItemNameByID(self.itemID))
        panel.texture:SetTexture(C_Item.GetItemIconByID(self.itemID))

        self:SetScript("OnEnter",function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:SetItemByID(self2.itemID)
            e.tips:AddLine(' ')
            if self==panel then
                e.tips:AddDoubleLine(MAINMENU or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            else
                e.tips:AddDoubleLine(DISABLE, 'Shift+'..e.Icon.right)
            end
            e.tips:Show()
        end)
        self:SetScript("OnLeave",function() e.tips:Hide() end)

        self.count= self.count or e.Cstr(self,nil, nil,nil, true)
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        self:RegisterEvent('BAG_UPDATE_COOLDOWN')
        if self~=panel then
            self:SetScript("OnEvent", function(self2, event)
            if event=='BAG_UPDATE_DELAYED' then
                    set_Item_Count(self2)
                elseif event=='BAG_UPDATE_COOLDOWN' then
                    set_Cooldown(self2)--图标冷却
                end
            end)
            self:SetScript('OnMouseDown',function(self2, d)
                if d=='RightButton' and IsShiftKeyDown() then
                    Save.noUseItems[self2.itemID]=true
                    print(id, addName, DISABLE, ITEMS, self2.itemID, REQUIRES_RELOAD)
                end
            end)
        end

        set_Item_Count(self2)
        set_Cooldown(self)--图标冷却
    else
        self:UnregisterAllEvents()
    end
end

local function find_Item_Type(class, subclass)
    local tab={}
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.hyperlink and info.itemID then
                local classID, subclassID = GetItemInfo(info.hyperlink)
                if classID==class and subclassID==subclass then
                    if not C_Item.IsItemDataCachedByID(info.itemID) then C_Item.RequestLoadItemDataByID(info.itemID) end
                    table.insert(tab, info.itemID)
                end
            end
        end
    end
    return tab
end

local function create_Button(self)
    self= self or panel
    local button= e.Cbtn2(nil, self, true, nil)
    button:SetPoint('RIGHT', self, 'LEFT')
    return button
end

local itemClass={
    {clasType=Consumable, type=Generic, class=0, subClass=0},
    {clasType=Consumable, type=Potion, class=0, subClass=1},
    {clasType=Consumable, type=Elixir, class=0, subClass=2},
    {clasType=Consumable, type=Scroll, class=0, subClass=3},
    {clasType=Consumable, type=Fooddrink, class=0, subClass=4},
    {clasType=Consumable, type=Itemenhancement, class=0, subClass=5},
    {clasType=Consumable, type=Bandage, class=0, subClass=6},
    {clasType=Consumable, type=Other, class=0, subClass=7},
}

local Button={}
local function set_Item_Button()
    local index=1
    for _, tab in pairst(itemClass) do
        if Save.type[tab.type] then
            local itemIDs=find_Item_Type(tab.class, tasb.subclass)
            for _, itemID in pairs(itemIDs) do
                if not Save.noUseItems[itemID] then
                    local button= Button[index]
                    button= button or create_Button(Button[index-1])
                    button.itemID= itemID
                    Button[index]=button
                    set_Button_Init(button)
                    button:SetShown(true)
                    index= index +1
                end
            end
        end
    end

    for i= index , #Button do
        local button= Button[i]
        button.itemID=nil
        set_Button_Init(button)
        button:SetShown(false)
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    local bat= UnitAffectingCombat('player')

    if type=='DISABLE' then
        for itemID, _ in pairs(Save.noUseItems) do
            info={
                text= C_Item.GetItemNameByID(itemID) or ('itemID '..itemID),
                notCheckable=true,
                disable= bat,
                func=function()
                    Save.noUseItems[itemID]=nil
                    set_Item_Button()
                end
            }
            UIDropDownMenu_AddButton(info, level)
            find[tab.clasType]=true
        end

    elseif type then
        for _, tab in pairs(itemClass) do
            if tab.clasType==type then
                info={
                    text=tab.type,
                    checked= Save.type[tab.type],
                    disable= bat,
                    func=function()
                        Save.type[tab.type]= not Save.type[tab.type] and ture or nil
                        set_Item_Button()
                    end
                }
                UIDropDownMenu_AddButton(info, level)
                find[tab.clasType]=true
            end
        end
    else
        info={
            text='CHECK',
            notCheckable=true,
            func= function()
                set_Item_Button()
            end
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        local find={}
        for _, tab in pairs(itemClass) do
            if not find[tab.clasType] then
                info={
                    text=tab.clasType,
                    notCheckable=true,
                    menuList=tab.clasType,
                    hasArrow=ture,
                }
                UIDropDownMenu_AddButton(info, level)
                find[tab.clasType]=true
            end
        end

        info= {
            text=DISABLE,
            notCheckable=true,
            menuList='DISABLE',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info= {
            text= AUTO_JOIN:gsub(JOIN, ENABLE),
            checked=Save.autoEnable,
            func= function()
                Save.autoEnable= not Save.autoEnable and true or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info= {
            text= e.Icon.right..NPE_MOVE,
            isTitle= ture,
            notCheckable= true,
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text=RESET_POSITION,--还原位置
            notCheckable=true,
            colorCode= not Save.Point and'|cff606060',
            func=function()
                Save.point=nil
                panel:ClearAllPoints()
                setPanelPostion()--设置按钮位置
            end,
        }
        UIDropDownMenu_AddButton(info, level)
    end
end

--####
--初始
--####
local function Init()
  
    setPanelPostion()--设置按钮位置
    local size=e.toolsFrame.size or 30
    panel:SetSize(size,size)
    
    set_Button_Init(panel)--提示, 事件
    
    if Save.autoEnable then
        set_Item_Button()
    end

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:RegisterForDrag("RightButton")
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:SetScript("OnDragStart", function(self,d )
        self:StartMoving()
    end)
    panel:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)
    panel:SetScript("OnMouseDown", function(self,d)
        ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
    end)
    panel:SetScript("OnMouseUp", function(self, d)
        ResetCursor()
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            Init()--初始
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='BAG_UPDATE_DELAYED' then
        set_Item_Count(self)

    elseif event=='BAG_UPDATE_COOLDOWN' then
        set_Cooldown(self)--图标冷却
    end
end)