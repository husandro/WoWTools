local id, e = ...
local addName= POWER_TYPE_FOOD
local Save={
    itemClass={},--物品类型
    noUseItems={},--禁用物品
    autoEnable=true,--启动,查询
    onlyMaxExpansion=true,--仅本版本物品
}

local panel=e.Cbtn2(nil, WoWToolsMountButton, true, nil)
panel.itemID= 5512--治疗石

local function setPanelPostion()--设置按钮位置
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('RIGHT', WoWToolsOpenItemsButton, 'LEFT')
    end
end

local function set_Cooldown(self)--图标冷却
    if self.itemID then
        local start, duration = GetItemCooldown(self.itemID)
        e.Ccool(self, start, duration, nil, true, nil, true)--冷却条
    end
end

local function set_Item_Count(self)--设置, 数量
    if self.itemID then
        local num=GetItemCount(self.itemID, nil, true, true)
        self.count:SetText(num>1 and num or (num==1 and Save.autoWho) and num or '')
        self.texture:SetDesaturated(num==0)
    end
end

--#########
--提示, 事件
--#########
local function set_Button_Init(self)
    if self.itemID then
        e.LoadSpellItemData(self.itemID)--加载法术, 物品数据

        self:SetAttribute("type", "item")
        self:SetAttribute("item", C_Item.GetItemNameByID(self.itemID))
        self.texture:SetTexture(C_Item.GetItemIconByID(self.itemID))

        if not self.count then--设置, 数量
            self.count= e.Cstr(self,10, nil,nil, true)
            self.count:SetPoint('BOTTOMRIGHT', -4,4)
        end

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

        self:RegisterEvent('BAG_UPDATE')
        self:RegisterEvent('BAG_UPDATE_COOLDOWN')
        if self~=panel then
            self:SetScript("OnEvent", function(self2, event)
            if event=='BAG_UPDATE' then
                    set_Item_Count(self2)
                elseif event=='BAG_UPDATE_COOLDOWN' then
                    set_Cooldown(self2)--图标冷却
                end
            end)
            self:SetScript('OnMouseDown',function(self2, d)
                if d=='RightButton' and IsShiftKeyDown() then
                    Save.noUseItems[self2.itemID]=true
                    local link= select(2, GetItemInfo(self2.itemID))
                    print(id, addName, DISABLE, link or self2.itemID, '|cnRED_FONT_COLOR:'..REQUIRES_RELOAD)
                end
            end)
        end

        set_Item_Count(self)
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
                local classID, subClassID, _, expacID = select(12, GetItemInfo(info.hyperlink))
                if classID==class and subClassID==subclass and (Save.onlyMaxExpansion and e.ExpansionLevel==expacID or not Save.onlyMaxExpansion) then
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


local itemClass={}--物品列表

for classID=0, 20 do
    if classID~=10 then
        local className=GetItemClassInfo(classID)--生成,物品列表
        if className then
            for subClassID= 0, 20 do
                local subclassName=GetItemSubClassInfo(classID, subClassID)
                if subclassName and subclassName~='' then
                    local tab={
                        className=className,
                        subclassName=subclassName,
                        classID=classID,
                        subClassID=subClassID
                    }
                    table.insert(itemClass, tab)
                else
                    break
                end
            end
        else
            break
        end
    end
end

local Button={}
local function set_Item_Button()--检查,物品
    if UnitAffectingCombat('player') then
        panel.bat=true
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end

    local index=1
    local created={}
    for _, tab in pairs(itemClass) do
        if Save.itemClass[tab.className..tab.subclassName] then
            local Tabs=find_Item_Type(tab.classID, tab.subClassID)
            for _, itemID in pairs(Tabs) do
                if not Save.noUseItems[itemID] and itemID~=panel.itemID and not created[itemID] then
                    local button= Button[index]
                    button= button or create_Button(Button[index-1])
                    button.itemID= itemID
                    Button[index]=button
                    set_Button_Init(button)
                    button:SetShown(true)
                    index= index +1
                    created[itemID]=true
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
local function get_Save_itemClass_Select()--已选中类别, 数量
    local num=0
    for _ in pairs(Save.itemClass) do
        num=num+1
    end
    return num
end

local function set_auto_Who_Event()--设置事件,自动更新
    if Save.autoWho and get_Save_itemClass_Select()>0 then
        panel:RegisterEvent('BAG_UPDATE_DELAYED')
    else
        panel:UnregisterEvent('BAG_UPDATE_DELAYED')
    end
end
local function get_Save_Numer_SubClass(name)--子类, 选中数量
    local num=0
    for className,_ in pairs(Save.itemClass) do
        if className:find(name..'(.+)') then
            num= num+1
        end
    end
    return num==0 and '' or '|cnGREEN_FONT_COLOR:'..num..'|r'
end

local function InitMenu(self, level, type)--主菜单
    local info
    local bat= UnitAffectingCombat('player')

    if type=='DISABLE' then
        for itemID, _ in pairs(Save.noUseItems) do
            local itemLink, _, _, _, _, _,_, _, itemTexture = select(2, GetItemInfo(itemID))
            info={
                text= itemLink or ('itemID '..itemID),
                notCheckable=true,
                disabled= bat,
                icon=itemTexture,
                tooltipOnButton=true,
                tooltipTitle=e.Icon.left..REMOVE,
                func=function()
                    Save.noUseItems[itemID]=nil
                    set_Item_Button()
                end
            }
            UIDropDownMenu_AddButton(info, level)
        end

        UIDropDownMenu_AddSeparator(level)
        info={--清除全部
            text=CLEAR_ALL,
            notCheckable=true,
            disabled=bat,
            func= function()
                Save.noUseItems={}
                set_Item_Button()
                print(id, addName, CLEAR_ALL, DISABLE, ITEMS, DONE)
            end
        }
        UIDropDownMenu_AddButton(info, level)

    elseif type=='WHO' then
        info= {--登录游戏,时,查询
            text= (LOGIN or SOCIAL_TWITTER_SIGN_IN)..GAME,
            tooltipOnButton=true,
            tooltipTitle=AUTO_JOIN:gsub(JOIN,WHO),
            tooltipText='1 '..VOICEMACRO_LABEL_CHARGE1,
            checked=Save.autoEnable,
            func= function()
                Save.autoEnable= not Save.autoEnable and true or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)

        
        info= {--自动, 更新物品, 查询
            text= UPDATE..ITEMS,
            tooltipOnButton=true,
            tooltipTitle=EVENTS_LABEL..': BAG_UPDATE_DELAYED',
            checked=Save.autoWho,
            func= function()
                Save.autoWho= not Save.autoWho and true or nil
                if Save.autoWho then
                    set_Item_Button()
                end
                set_auto_Who_Event()--设置事件,自动更新
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinse and '仅当前版本物品' or 	LFG_LIST_CROSS_FACTION:format(REFORGE_CURRENT..(VERSION or GAME_VERSION_LABEL)),
            checked= Save.onlyMaxExpansion,
            disabled= bat,
            tooltipOnButton=true,
            tooltipTitle= e.ExpansionLevel,
            func= function()
                Save.onlyMaxExpansion= not Save.onlyMaxExpansion and true or nil
                set_Item_Button()
            end,
        }
        UIDropDownMenu_AddButton(info, level)
    elseif type then
        for _, tab in pairs(itemClass) do
            if type==tab.className then
                info={
                    text=tab.subclassName,
                    checked= Save.itemClass[tab.className..tab.subclassName],
                    disabled= bat,
                    tooltipOnButton=true,
                    tooltipTitle= tab.className.. ' classID |cnGREEN_FONT_COLOR:'..tab.classID..'|r',
                    tooltipText= tab.subclassName..' subClassID |cnGREEN_FONT_COLOR:'..tab.subClassID..'|r',
                    func=function()
                        Save.itemClass[tab.className..tab.subclassName]= not Save.itemClass[tab.className..tab.subclassName] and true or nil
                        set_Item_Button()
                    end
                }
                UIDropDownMenu_AddButton(info, level)
            end
        end
    else
        local classNum=get_Save_itemClass_Select()
        info={
            text=WHO.. ' '..classNum,
            colorCode='|cff00ff00',
            notCheckable=true,
            disabled=bat or classNum==0,
            menuList='WHO',
            hasArrow=true,
            func= function()
                set_Item_Button()
            end
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        local find={}
        for _, tab in pairs(itemClass) do
            if not find[tab.className] then
                info={
                    text=get_Save_Numer_SubClass(tab.className)..tab.className,
                    notCheckable=true,
                    menuList=tab.className,
                    hasArrow=true,
                }
                UIDropDownMenu_AddButton(info, level)
                find[tab.className]=true
            end
        end

        info={--全部取消
            text=e.Icon.up2..CALENDAR_EVENT_REMOVED_MAIL_SUBJECT:format(ALL),
            colorCode= '|cffff0000',
            notCheckable=true,
            disabled=bat,
            func= function()
                Save.itemClass={}
                set_Item_Button()
                print(id, addName, CALENDAR_EVENT_REMOVED_MAIL_SUBJECT:format(ALL), DONE)
            end
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info= {
            text=DISABLE,
            notCheckable=true,
            menuList='DISABLE',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info= {
            text= e.Icon.right..NPE_MOVE,
            isTitle= true,
            notCheckable= true,
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text=RESET_POSITION,--还原位置
            notCheckable=true,
            colorCode= not Save.point and'|cff606060',
            disabled=bat,
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
    for itemID, _ in pairs(Save.noUseItems) do
        e.LoadSpellItemData(itemID)--加载法术, 物品数据
    end

    setPanelPostion()--设置按钮位置
    local size=e.toolsFrame.size or 30
    panel:SetSize(size,size)

    set_Button_Init(panel)--提示, 事件

    if Save.autoWho then
        set_auto_Who_Event()--设置事件,自动更新
    end
    if  get_Save_itemClass_Select()>0 and (Save.autoEnable or Save.autoWho) then
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
        CloseDropDownMenus()
    end)
    panel:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' then
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
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

    elseif event=='BAG_UPDATE' then--
        set_Item_Count(self)--更新物品,次数

    elseif event=='BAG_UPDATE_DELAYED' then
        set_Item_Button()--检查,物品
        
    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.bat then
            set_Item_Count(self)--更新物品
            panel.bat=nil
        end
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
    elseif event=='BAG_UPDATE_COOLDOWN' then
        set_Cooldown(self)--图标冷却
    end
end)