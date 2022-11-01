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
        --[[93672,-- 
        172179,-- 
        6948,-- 
        188952,--]]
    }
}
local addName= SLASH_RANDOM3:gsub('/','').. TUTORIAL_TITLE31
local panel=e.Cbtn2()
panel:SetAttribute("type1", "item")
panel:SetAttribute("alt-type1", "item")
panel:SetAttribute("shift-type1", "item")
panel:SetAttribute("ctrl-type1", "item")

e.toolsFrame=CreateFrame('Frame', nil, panel)--TOOLS 框架
e.toolsFrame:SetPoint('BOTTOMRIGHT', panel, 'TOPRIGHT',-1,0)--设置, TOOLS 位置
e.toolsFrame:SetSize(1,1)
e.toolsFrame:SetShown(false)

e.toolsFrame.last=e.toolsFrame

--[[

e.toolsFrame.texture=e.toolsFrame:CreateTexture()
e.toolsFrame.texture:SetAtlas(e.Icon.icon)
e.toolsFrame.texture:SetAllPoints(e.toolsFrame)



]]



local ModifiedTab={
    alt=140192,--达拉然炉石
    shift=6948,--炉石
    ctrl=110560,--要塞炉石
}
for _, itemID in pairs(ModifiedTab) do
    if not C_Item.IsItemDataCachedByID(itemID) then
        C_Item.RequestLoadItemDataByID(itemID)
    end
end

panel.items={}--存放有效

local function setPanelPostion()--设置按钮位置
    local p=Save.Point
    if p and p[1] and p[3] and p[4] and p[5] then
        panel:SetPoint(p[1],  UIParent, p[3], p[4], p[5])
    else
        panel:SetPoint('RIGHT', CharacterReagentBag0Slot, 'LEFT',-30, 0)
    end
end

local function getToy()--生成, 有效表格
    panel.items={}
    local find
    for itemID ,_ in pairs(Save.items) do
        if PlayerHasToy(itemID) then
            if not C_Item.IsItemDataCachedByID(itemID) then
                C_Item.RequestLoadItemDataByID(itemID)
            end
            find=true
            table.insert(panel.items, itemID)
        end
    end
    if not find and GetItemCount( 6948)~=0 then
        panel.items={6948}
    end
end
local function setAtt(init)--设置属性
    if UnitAffectingCombat('player') and not init then
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

--#####
--主菜单
--#####
local function InitMenu(self, level, menuList)--主菜单
    local info
    if menuList then
        if menuList=='TOY' then
            for itemID, _ in pairs(Save.items) do
                info={
                    text= (C_Item.GetItemNameByID(itemID) or ('itemID '..itemID))..(not PlayerHasToy(itemID) and e.Icon.O2 or ''),
                    textCode=not PlayerHasToy(itemID) and '|cff606060',
                    notCheckable=true,
                    icon= C_Item.GetItemIconByID(itemID),
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
        elseif menuList=='SETTINGS' then--设置菜单
            if Save.Point then--还原位置
                info={text=RESET_POSITION}
            else
                info={text='Alt +'..e.Icon.right..' '..NPE_MOVE}
                info.disabled=true
            end
            info.func=function()
                Save.Point=nil
                panel:ClearAllPoints()
                setPanelPostion()--设置按钮位置
                CloseDropDownMenus()
            end
            info.tooltipOnButton=true
            info.notCheckable=true
            UIDropDownMenu_AddButton(info, level)

            info={
                text=id,
                isTitle=true,
                notCheckable=true,
            }
            UIDropDownMenu_AddButton(info,level)
        end
    else
       info={
            text='|cnGREEN_FONT_COLOR:'..#panel.items..'|r'.. addName,
            notCheckable=true,
            menuList='TOY',
            hasArrow=true,
       }
       UIDropDownMenu_AddButton(info, level)
       -- UIDropDownMenu_AddSeparator()
        info={
            text=SETTINGS,
            notCheckable=true,
            menuList='SETTINGS',
            hasArrow=true,
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
                panel['texture'..type]:SetSize(8,8)
                if type=='alt' then
                    panel['texture'..type]:SetPoint('BOTTOMRIGHT',-6,5)
                elseif type=='shift' then
                    panel['texture'..type]:SetPoint('TOPLEFT',5,-5)
                else
                    panel['texture'..type]:SetPoint('BOTTOMLEFT',5,5)
                end
                panel['texture'..type]:SetDrawLayer('OVERLAY',2)
                panel['texture'..type]:SetAlpha(0.5)
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
                local name = C_Item.GetItemNameByID(itemID) or ('itemID: '..itemID)
                local icon = C_Item.GetItemIconByID(itemID)
                name= (icon and '|T'..icon..':0|t' or '')..name

                e.tips:AddDoubleLine(name..(e.GetItemCooldown(itemID) or ''), type..'+'..e.Icon.left)
            end
        end
        e.tips:Show()
    else
        e.tips:Hide()
    end
end

local function Init()
    setPanelPostion()--设置按钮位置
    getToy()--生成, 有效表格
    setAtt(true)--设置属性
    setCooldown()--主图标冷却
    setBagHearthstone()--设置Shift, Ctrl, Alt 提示
    
    for type, itemID in pairs(ModifiedTab) do
        panel:SetAttribute(type.."-item1",  C_Item.GetItemNameByID(itemID) or itemID)
    end

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:RegisterForDrag("RightButton")
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)

    panel:SetScript("OnEnter",function(self)
        showTips(self)--显示提示
        if not UnitAffectingCombat('player') then
            e.toolsFrame:SetShown(true)--设置, TOOLS 框架, 显示
        end
    end)
    panel:SetScript("OnLeave",function()
        e.tips:Hide()
    end)
    panel:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)

    panel:SetScript("OnDragStart", function(self,d )
        if IsAltKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    panel:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
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

    panel.Up=panel:CreateTexture(nil,'OVERLAY')
    panel.Up:SetPoint('TOP',-1, 9)
    panel.Up:SetAtlas('NPE_ArrowUp')
    panel.Up:SetSize(20,20)
    --panel.Up:SetDesaturated(true)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent('NEW_TOY_ADDED')
panel:RegisterEvent('TOYS_UPDATED')

panel:RegisterEvent('BAG_UPDATE_DELAYED')
panel:RegisterEvent('BAG_UPDATE_COOLDOWN')

panel:RegisterEvent('PLAYER_REGEN_DISABLED')
panel:RegisterEvent('PLAYER_STARTED_MOVING')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
            end)
            if not Save.disabled then
                Init()--初始
            else
                e.toolsFrame.disabled=true
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

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

    elseif event=='PLAYER_REGEN_DISABLED' then
        if e.toolsFrame:IsShown() then
            e.toolsFrame:SetShown(false)--设置, TOOLS 框架,隐藏
        end
    elseif event=='PLAYER_STARTED_MOVING' then
        if not UnitAffectingCombat('player') and e.toolsFrame:IsShown() then
            e.toolsFrame:SetShown(false)--设置, TOOLS 框架,隐藏
        end
    end
end)