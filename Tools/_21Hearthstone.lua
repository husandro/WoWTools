local id, e = ...
local Save={
    items={
        [193588]=true,--时光旅行者的炉石
        [188952]=true,--被统御的炉石
        [172179]=true,--永恒旅者的炉石
        [190237]=true,--掮灵传送矩阵
        [168907]=true,--全息数字化炉石
        [142542]=true,--城镇传送之书
        [162973]=true,--冬天爷爷的炉石
        [166746]=true,--吞火者的炉石
        [165802]=true,--复活节的炉石
        [165670]=true,--小匹德菲特的可爱炉石
        [163045]=true,--无头骑士的炉石
        [165669]=true,--春节长者的炉石
        [166747]=true,--美酒节狂欢者的炉石
        [391042]=true,--欧恩伊尔轻风贤者的炉石
        --[[93672,-- 
        172179,-- 
        6948,-- 
        188952,--]]
    },
    showBindNameShort=true,
    showBindName=true,
}
local addName= SLASH_RANDOM3:gsub('/','').. TUTORIAL_TITLE31
local panel=e.Cbtn2('HearthstoneToolsButton',WoWToolsMountButton)
panel:SetAttribute("type1", "item")
panel:SetAttribute("alt-type1", "item")
panel:SetAttribute("shift-type1", "item")
panel:SetAttribute("ctrl-type1", "item")
panel:SetPoint('RIGHT', WoWToolsMountButton, 'LEFT')

local ModifiedTab={
    alt=140192,--达拉然炉石
    shift=6948,--炉石
    ctrl=110560,--要塞炉石
}
for _, itemID in pairs(ModifiedTab) do
    e.LoadSpellItemData(itemID)--加载法术, 物品数据
end
panel.items={}--存放有效

local function getToy()--生成, 有效表格
    panel.items={}
    local find
    for itemID ,_ in pairs(Save.items) do
        if PlayerHasToy(itemID) then
            find=true
            table.insert(panel.items, itemID)
        end
    end
    if not find and GetItemCount( 6948)~=0 then
        panel.items={6948}
    end
end

local function setAtt()--设置属性
    if UnitAffectingCombat('player') then
        return
    end
    local icon
    local num=#panel.items
    if num>0 then
        local index=math.random(1, num)
        local itemID=panel.items[index]
        if itemID then
            icon = C_Item.GetItemIconByID(itemID)
            if icon then
                panel.texture:SetTexture(icon)
            end
            panel:SetAttribute('item1', C_Item.GetItemNameByID(itemID) or itemID)

            panel.itemID=itemID
        end
    else
        panel:SetAttribute('item1', nil)
        panel.itemID=nil
    end
    panel.texture:SetShown(icon)
end


--#############
--玩具界面, 菜单
--#############
local function setToyBox_ShowToyDropdown(itemID, anchorTo, offsetX, offsetY)
    if Save.disabled or not itemID then
        return
    end
    UIDropDownMenu_AddSeparator()
    local info={
            text='|T134414:0|t'..addName,
            checked=Save.items[itemID],
            func=function()
                if Save.items[itemID] then
                    Save.items[itemID]=nil
                else
                    Save.items[itemID]=true
                end
                getToy()--生成, 有效表格
                setAtt()--设置属性
                ToySpellButton_UpdateButton(anchorTo)
            end,
            tooltipOnButton=true,
            tooltipTitle=addName,
            tooltipText=id,
        }
    UIDropDownMenu_AddButton(info, 1)
end
local function setToySpellButton_UpdateButton(self)--标记, 是否已选取
    if Save.disabled or not self.itemID then
        return
    end
    local find = Save.items[self.itemID]
    if find and not self.hearthstone then
        self.hearthstone=self:CreateTexture(nil, 'ARTWORK')
        self.hearthstone:SetPoint('TOPLEFT',self.name,'BOTTOMLEFT')
        self.hearthstone:SetTexture(134414)
        self.hearthstone:SetSize(12, 12)
    end
    if self.hearthstone then
        self.hearthstone:SetShown(find)
    end
end

local function set_BindLocation()--显示, 炉石, 绑定位置
    local text
    if Save.showBindName then
        text= GetBindLocation()
        if text and Save.showBindNameShort then
            text= e.WA_Utf8Sub(text, 2, 5)
        end
    end
    if not panel.showBindNameText and text then
        panel.showBindNameText=e.Cstr(panel, 10, nil, nil, true, nil, 'CENTER')
        panel.showBindNameText:SetPoint('TOP', panel, 'BOTTOM',0,5)
    end
    if panel.showBindNameText then
        panel.showBindNameText:SetText(text or '')
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level, menuList)--主菜单
    local info
    if menuList=='TOY' then
        for itemID, _ in pairs(Save.items) do
            local find=PlayerHasToy(itemID)
            info={
                text= (C_Item.GetItemNameByID(itemID..'') or ('itemID '..itemID))..(not find and e.Icon.O2 or ''),
                colorCode=not find and '|cff606060',
                notCheckable=true,
                icon= C_Item.GetItemIconByID(itemID..''),
                func=function ()
                    Save.items[itemID]=nil
                    getToy()--生成, 有效表格
                    setAtt()--设置属性
                end,
                tooltipOnButton=true,
                tooltipTitle=REMOVE,
            }
            UIDropDownMenu_AddButton(info, level)
        end
    elseif menuList=='BIND' then--炉石, 绑定位置, 截取名称SHORT
        info={
            text=SHORT..NAME,
            checked=Save.showBindNameShort,
            func=function()
                Save.showBindNameShort= not Save.showBindNameShort and true or nil
                set_BindLocation()--显示, 炉石, 绑定位置
            end
        }
        UIDropDownMenu_AddButton(info, level)
    else
       info={
            text='|cnGREEN_FONT_COLOR:'..#panel.items..'|r'.. addName,
            notCheckable=true,
            menuList='TOY',
            hasArrow=true,
       }
       UIDropDownMenu_AddButton(info, level)
       info={
            text=TUTORIAL_TITLE31..NAME,
            checked=Save.showBindName,
            menuList='BIND',
            hasArrow=true,
            func=function()
                Save.showBindName = not Save.showBindName and true or nil
                set_BindLocation()--显示, 炉石, 绑定位置
            end
        }
        UIDropDownMenu_AddButton(info, level)
    end
end

--########################
--设置Shift, Ctrl, Alt 提示
--########################
local function setBagHearthstone()
    for type, itemID in pairs(ModifiedTab) do
        local find
        if GetItemCount(itemID)~=0 then
            local _, duration, enable = GetItemCooldown(itemID)
            find= duration<2 and enable==1
        end
        if find then
            if not panel['texture'..type] then
                panel['texture'..type]=panel:CreateTexture(nil,'OVERLAY')
                local size=(e.toolsFrame.size or 30)/3
                panel['texture'..type]:SetSize(size, size)
                if type=='alt' then
                    panel['texture'..type]:SetPoint('BOTTOMRIGHT',-3,3)
                elseif type=='shift' then
                    panel['texture'..type]:SetPoint('TOPLEFT',2,-2)
                else
                    panel['texture'..type]:SetPoint('BOTTOMLEFT',2,2)
                end
                panel['texture'..type]:SetDrawLayer('OVERLAY',2)
                panel['texture'..type]:AddMaskTexture(panel.mask)
                panel['texture'..type]:SetTexture(C_Item.GetItemIconByID(itemID))
            end
        end
        if panel['texture'..type] then
            panel['texture'..type]:SetShown(find)
        end
    end
end

--#########
--主图标冷却
--#########
local function setCooldown()
    if panel.itemID then
        local start, duration = GetItemCooldown(panel.itemID)
        e.Ccool(panel, start, duration, nil, true, nil, true)--冷却条
    else
        if panel.cooldown then
            panel.cooldown:Clear()
        end
    end
end

--####
--初始
--####
local function showTips(self)--显示提示
    if self.itemID then
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetToyByItemID(self.itemID)
        e.tips:AddLine(' ')
        for type, itemID in pairs(ModifiedTab) do
            if GetItemCount(itemID)~=0 then
                local name = C_Item.GetItemNameByID(itemID..'') or ('itemID: '..itemID)
                local icon = C_Item.GetItemIconByID(itemID..'')
                name= (icon and '|T'..icon..':0|t' or '')..name
                local startTime, duration, enable = GetItemCooldown(itemID)
                if duration>4 then
                    local t=GetTime()
                    if startTime>t then t=t+86400 end
                    t=t-startTime
                    t=duration-t
                    name= name..'|cnRED_FONT_COLOR: '..SecondsToTime(t)..'|r'
                end
                e.tips:AddDoubleLine(name, type..'+'..e.Icon.left)
            end
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinse and '菜单' or MAINMENU or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:Show()
        if e.tips.textRight then
            local text=GetBindLocation()--显示,绑定位置
            if text then
                e.tips.textRight:SetText(text)
            end
        end
    else
        e.tips:Hide()
    end
end

local function Init()
    for itemID, _ in pairs(Save.items) do
        e.LoadSpellItemData(itemID)--加载法术, 物品数据
    end

    if e.toolsFrame.size and e.toolsFrame.size~=30 then--设置大小
        panel:SetSize(e.toolsFrame.size, e.toolsFrame.size)
    end

    for type, itemID in pairs(ModifiedTab) do
        panel:SetAttribute(type.."-item1",  C_Item.GetItemNameByID(itemID) or itemID)
    end

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetScript("OnEnter",function(self)
        showTips(self)--显示提示
    end)
    panel:SetScript("OnLeave",function()
        e.tips:Hide()
    end)
    panel:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)

    panel:SetScript("OnMouseUp", function(self, d)
        if d=='LeftButton' and not IsModifierKeyDown() then
            setAtt()--设置属性
            showTips(self)--显示提示
        end
        ResetCursor()
    end)

    panel:SetScript('OnMouseWheel',function(self,d)
        setAtt()--设置属性
    end)

    getToy()--生成, 有效表格
    setAtt()--设置属性
    setCooldown()--主图标冷却
    setBagHearthstone()--设置Shift, Ctrl, Alt 提示

    C_Timer.After(2, function()
        setAtt()--设置属性
        set_BindLocation()--显示, 炉石, 绑定位置
        setCooldown()--主图标冷却
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent('NEW_TOY_ADDED')
panel:RegisterEvent('TOYS_UPDATED')

panel:RegisterEvent('BAG_UPDATE_DELAYED')
panel:RegisterEvent('BAG_UPDATE_COOLDOWN')

panel:RegisterEvent('HEARTHSTONE_BOUND')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
            if not e.toolsFrame.disabled then
                Init()--初始
                panel:UnregisterEvent('ADDON_LOADED')
            else
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        hooksecurefunc('ToyBox_ShowToyDropdown', setToyBox_ShowToyDropdown)
        hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end
    elseif event=='TOYS_UPDATED' or event=='NEW_TOY_ADDED' then
        getToy()--生成, 有效表格
        setAtt()--设置属性

    elseif event=='BAG_UPDATE_COOLDOWN' then
        setCooldown()--主图标冷却
        setBagHearthstone()--设置Shift, Ctrl, Alt 提示

    elseif event=='BAG_UPDATE_DELAYED' then
        if IsResting()  then
            setBagHearthstone()--设置Shift, Ctrl, Alt 提示
        end

    elseif event=='HEARTHSTONE_BOUND' then
        set_BindLocation()--显示, 炉石, 绑定位置

    end
end)