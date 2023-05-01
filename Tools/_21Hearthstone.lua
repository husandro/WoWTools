local id, e = ...
local addName= SLASH_RANDOM3:gsub('/','').. TUTORIAL_TITLE31
local Save={
    items={
        [142542]=true,--城镇传送之书
        [162973]=true,--冬天爷爷的炉石
        [163045]=true,--无头骑士的炉石
        [165669]=true,--春节长者的炉石
        [165670]=true,--小匹德菲特的可爱炉石
        [165802]=true,--复活节的炉石
        [166746]=true,--吞火者的炉石
        [166747]=true,--美酒节狂欢者的炉石
        [168907]=true,--全息数字化炉石
        [172179]=true,--永恒旅者的炉石
        [188952]=true,--被统御的炉石
        [190196]=true,--开悟者炉石
        [190237]=true,--掮灵传送矩阵
        [193588]=true,--时光旅行者的炉石
        [391042]=true,--欧恩伊尔轻风贤者的炉石, 找不到数据
    },
    showBindNameShort=true,
    showBindName=true,
}
local button--button.items={}--存放有效

local ModifiedTab={
    alt=140192,--达拉然炉石
    shift=6948,--炉石
    ctrl=110560,--要塞炉石
}
for _, itemID in pairs(ModifiedTab) do
    e.LoadDate({id=itemID, type='item'})
end
for itemID, _ in pairs(Save.items) do
    e.LoadDate({id=itemID, type='item'})
end

local function getToy()--生成, 有效表格
    button.items={}
    local find
    for itemID ,_ in pairs(Save.items) do
        if PlayerHasToy(itemID) then
            find=true
            table.insert(button.items, itemID)
        end
    end
    if not find and GetItemCount(6948)~=0 then
        button.items={6948}
    end
end

local function setAtt()--设置属性
    if UnitAffectingCombat('player') then
        return
    end
    local icon
    local num=#button.items
    if num>0 then
        local index=math.random(1, num)
        local itemID=button.items[index]
        if itemID then
            icon = C_Item.GetItemIconByID(itemID)
            if icon then
                button.texture:SetTexture(icon)
            end
            button:SetAttribute('item1', C_Item.GetItemNameByID(itemID) or itemID)

            button.itemID=itemID
        end
    else
        button:SetAttribute('item1', nil)
        button.itemID=nil
    end
    button.texture:SetShown(icon)
end


--#############
--玩具界面, 按钮
--#############
local function setToySpellButton_UpdateButton(self)--标记, 是否已选取
    if not self.hearthstone then
        self.hearthstone= e.Cbtn(self,{size={16,16}, texture=134414})
        self.hearthstone:SetPoint('TOPLEFT',self.name,'BOTTOMLEFT')
        self.hearthstone:SetScript('OnLeave', function() e.tips:Hide() end)
        self.hearthstone:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            local itemID=self2:GetParent().itemID
            e.tips:AddDoubleLine(itemID and C_ToyBox.GetToyLink(itemID) or itemID, e.GetEnabeleDisable(not Save.items[self.itemID])..e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id,'|T134414:0|t'..addName)
            e.tips:Show()
        end)
        self.hearthstone:SetScript('OnClick', function(self2, d)
            if d=='LeftButton' then
                local frame=self2:GetParent()
                local itemID= frame and frame.itemID
                if Save.items[itemID] then
                    Save.items[itemID]=nil
                else
                    Save.items[itemID]=true
                end
                getToy()--生成, 有效表格
                setAtt()--设置属性
                securecallfunction(ToySpellButton_UpdateButton, frame)
            else
                e.LibDD:ToggleDropDownMenu(1, nil, button.Menu, self2, 15, 0)
            end
        end)
    end
    self.hearthstone:SetAlpha(Save.items[self.itemID] and 1 or 0.1)
end

local function set_BindLocation()--显示, 炉石, 绑定位置
    local text
    if Save.showBindName then
        text= GetBindLocation()
        if text and Save.showBindNameShort then
            text= e.WA_Utf8Sub(text, 2, 5)
        end
    end
    if not button.showBindNameText and text then
        button.showBindNameText=e.Cstr(button, {size=10, color=true, justifyH='CENTER'})--10, nil, nil, true, nil, 'CENTER')
        button.showBindNameText:SetPoint('TOP', button, 'BOTTOM',0,5)
    end
    if button.showBindNameText then
        button.showBindNameText:SetText(text or '')
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level, menuList)--主菜单
    local info
    if menuList=='TOY' then
        for itemID, _ in pairs(Save.items) do
            local _, toyName, icon = C_ToyBox.GetToyInfo(itemID)
            info={
                text= toyName or itemID,
                icon= icon or C_Item.GetItemIconByID(itemID),
                colorCode=not PlayerHasToy(itemID) and '|cff606060',
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '添加/移除' or (ADD..'/'..REMOVE),
                tooltipText= (e.onlyChinese and '藏品->玩具箱' or (COLLECTIONS..'->'..TOY_BOX))..e.Icon.left,
                arg1= itemID,
                func=function(_, arg1)
                    if ToyBox and not ToyBox:IsVisible() then
                        ToggleCollectionsJournal(3)
                    end
                    local name= arg1 and select(2, C_ToyBox.GetToyInfo(arg1))
                    if name then
                        C_ToyBoxInfo.SetDefaultFilters()
                        if ToyBox.searchBox then
                            ToyBox.searchBox:SetText(name)
                        end
                    end
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
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
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    else
       info={
            text='|cnGREEN_FONT_COLOR:'..#button.items..'|r'.. addName,
            notCheckable=true,
            menuList='TOY',
            hasArrow=true,
       }
       e.LibDD:UIDropDownMenu_AddButton(info, level)
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
        e.LibDD:UIDropDownMenu_AddButton(info, level)
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
            if not button['texture'..type] then
                button['texture'..type]=button:CreateTexture(nil,'OVERLAY')
                local size=10
                button['texture'..type]:SetSize(size, size)
                if type=='alt' then
                    button['texture'..type]:SetPoint('BOTTOMRIGHT',-3,3)
                elseif type=='shift' then
                    button['texture'..type]:SetPoint('TOPLEFT',2,-2)
                else
                    button['texture'..type]:SetPoint('BOTTOMLEFT',2,2)
                end
                button['texture'..type]:SetDrawLayer('OVERLAY',2)
                button['texture'..type]:AddMaskTexture(button.mask)
                button['texture'..type]:SetTexture(C_Item.GetItemIconByID(itemID))
            end
        end
        if button['texture'..type] then
            button['texture'..type]:SetShown(find)
        end
    end
end

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
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
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


--###
--初始
--###
local function Init()
    for itemID, _ in pairs(Save.items) do
        e.LoadDate({id=itemID, type='item'})
    end

    button.Menu=CreateFrame("Frame", id..addName..'Menu', button, "UIDropDownMenuTemplate")
    e.LibDD:UIDropDownMenu_Initialize(button.Menu, InitMenu, 'MENU')

    button:SetSize(30, 30)

    for type, itemID in pairs(ModifiedTab) do
        button:SetAttribute(type.."-item1",  C_Item.GetItemNameByID(itemID) or itemID)
    end

    button:SetScript("OnEnter",function(self)
        showTips(self)--显示提示
    end)
    button:SetScript("OnLeave",function()
        e.tips:Hide()
    end)
    button:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)

    button:SetScript("OnMouseUp", function(self, d)
        if d=='LeftButton' and not IsModifierKeyDown() then
            setAtt()--设置属性
            showTips(self)--显示提示
        end
        ResetCursor()
    end)

    button:SetScript('OnMouseWheel',function(self,d)
        setAtt()--设置属性
    end)

    getToy()--生成, 有效表格
    setAtt()--设置属性
    e.SetItemSpellCool(button, button.itemID, nil)--主图标冷却
    setBagHearthstone()--设置Shift, Ctrl, Alt 提示

    C_Timer.After(2, function()
        setAtt()--设置属性
        set_BindLocation()--显示, 炉石, 绑定位置
        e.SetItemSpellCool(button, button.itemID, nil)--主图标冷却
    end)
end

--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName..'Tools'] or Save
            if not e.toolsFrame.disabled then
                button=e.Cbtn2('HearthstoneToolsButton', WoWToolsMountButton)
                button:SetAttribute("type1", "item")
                button:SetAttribute("alt-type1", "item")
                button:SetAttribute("shift-type1", "item")
                button:SetAttribute("ctrl-type1", "item")
                button:SetPoint('RIGHT', WoWToolsMountButton, 'LEFT')
                button.items={}--存放有效

                panel:RegisterEvent("PLAYER_LOGOUT")
                panel:RegisterEvent('NEW_TOY_ADDED')
                panel:RegisterEvent('TOYS_UPDATED')
                panel:RegisterEvent('BAG_UPDATE_DELAYED')
                panel:RegisterEvent('BAG_UPDATE_COOLDOWN')
                panel:RegisterEvent('HEARTHSTONE_BOUND')

                if not IsAddOnLoaded("Blizzard_Collections") then LoadAddOn('Blizzard_Collections') end
                Init()--初始
            else
                panel:UnregisterEvent('ADDON_LOADED')
            end

        elseif arg1=='Blizzard_Collections' then
            --hooksecurefunc('ToyBox_ShowToyDropdown', setToyBox_ShowToyDropdown)
            hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='TOYS_UPDATED' or event=='NEW_TOY_ADDED' then
        getToy()--生成, 有效表格
        setAtt()--设置属性

    elseif event=='BAG_UPDATE_COOLDOWN' then
        e.SetItemSpellCool(button, button.itemID, nil)--主图标冷却
        setBagHearthstone()--设置Shift, Ctrl, Alt 提示

    elseif event=='BAG_UPDATE_DELAYED' then
        if IsResting()  then
            setBagHearthstone()--设置Shift, Ctrl, Alt 提示
        end

    elseif event=='HEARTHSTONE_BOUND' then
        set_BindLocation()--显示, 炉石, 绑定位置

    end
end)