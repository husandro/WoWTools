local id, e = ...
local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TUTORIAL_TITLE31)
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
        [209035]=true,--烈焰炉石
        [212337]=true,--炉之石
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

local panel= CreateFrame("Frame")
















local function getToy()--生成, 有效表格
    button.items={}
    local find
    for itemID ,_ in pairs(Save.items) do
        if PlayerHasToy(itemID) then
            find=true
            table.insert(button.items, itemID)
        end
    end
    if not find and C_Item.GetItemCount(6948)~=0 then
        button.items={6948}
    end
end

local function setAtt()--设置属性
    --if UnitAffectingCombat('player') then
    if not button:CanChangeAttribute()  then
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
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
local function setToySpellButton_UpdateButton(btn)--标记, 是否已选取
    if not btn.hearthstone then
        btn.hearthstone= e.Cbtn(btn,{size={16,16}, texture=134414})
        btn.hearthstone:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT')

        function btn.hearthstone:get_itemID()
            return self:GetParent().itemID
        end
        function btn.hearthstone:set_alpha()
            self:SetAlpha(Save.items[self:get_itemID()] and 1 or 0.1)
        end
        function btn.hearthstone:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id,'Tools |T134414:0|t'..(e.onlyChinese and '随机炉石' or addName))
            e.tips:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            e.tips:AddLine(' ')
            local itemID=self:get_itemID()
            local icon= C_Item.GetItemIconByID(itemID)
            e.tips:AddDoubleLine(
                (icon and '|T'..icon..':0|t' or '')..(itemID and C_ToyBox.GetToyLink(itemID) or itemID),
                e.GetEnabeleDisable(Save.items[itemID])..e.Icon.left
            )
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
            self:SetAlpha(1)
        end
        btn.hearthstone:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                local itemID=self:get_itemID()
                Save.items[itemID]= not Save.items[itemID] and true or nil
                getToy()--生成, 有效表格
                setAtt()--设置属性
                self:set_tooltips()
                self:set_alpha()
            else
                e.LibDD:ToggleDropDownMenu(1, nil, button.Menu, self, 15, 0)
            end
        end)
        btn.hearthstone:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha() end)
        btn.hearthstone:SetScript('OnEnter', btn.hearthstone.set_tooltips)
    end
    btn.hearthstone:set_alpha()
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
local function InitMenu(_, level, menuList)--主菜单
    local info
    if menuList=='TOY' then
        for itemID, _ in pairs(Save.items) do
            local _, toyName, icon = C_ToyBox.GetToyInfo(itemID)
            info={
                text= toyName or itemID,
                icon= icon or C_Item.GetItemIconByID(itemID),
                colorCode=not PlayerHasToy(itemID) and '|cff9e9e9e',
                notCheckable=true,
                keepShownOnClick=true,
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
            text=e.onlyChinese and '截取名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHORT, NAME),
            checked=Save.showBindNameShort,
            func=function()
                Save.showBindNameShort= not Save.showBindNameShort and true or nil
                set_BindLocation()--显示, 炉石, 绑定位置
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    else
       info={
            text='|cnGREEN_FONT_COLOR:'..#button.items..'|r'.. (e.onlyChinese and '随机炉石' or addName),
            notCheckable=true,
            menuList='TOY',
            hasArrow=true,
            keepShownOnClick=true,
       }
       e.LibDD:UIDropDownMenu_AddButton(info, level)
       info={
            text= e.onlyChinese and '绑定位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TUTORIAL_TITLE31, NAME),
            checked=Save.showBindName,
            menuList='BIND',
            hasArrow=true,
            keepShownOnClick=true,
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
        if PlayerHasToy(itemID) or C_Item.GetItemCount(itemID)>=0 then
            local _, duration, enable = C_Container.GetItemCooldown(itemID)
            find= (duration and duration<2 or enable)
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



























--###
--初始
--###
local function Init()
    for itemID, _ in pairs(Save.items) do
        e.LoadDate({id=itemID, type='item'})
    end

    button.Menu=CreateFrame("Frame", nil, button, "UIDropDownMenuTemplate")
    e.LibDD:UIDropDownMenu_Initialize(button.Menu, InitMenu, 'MENU')

    button:SetSize(30, 30)

    for type, itemID in pairs(ModifiedTab) do
        button:SetAttribute(type.."-item1",  C_Item.GetItemNameByID(itemID) or select(2,  C_ToyBox.GetToyInfo(itemID)))
    end

    function button:set_tooltips()
        if self.itemID then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:SetItemByID(self.itemID)
            --e.tips:SetToyByItemID(self.itemID)
            e.tips:AddLine(' ')
            for type, itemID in pairs(ModifiedTab) do
                if PlayerHasToy(itemID) or C_Item.GetItemCount(itemID)>0 then
                    local name = C_Item.GetItemNameByID(itemID..'') or ('itemID: '..itemID)
                    local icon = C_Item.GetItemIconByID(itemID..'')
                    name= (icon and '|T'..icon..':0|t' or '')..name
                    local cd= e.GetSpellItemCooldown(nil, itemID)--冷却
                    e.tips:AddDoubleLine(name..(cd or ''), type..'+'..e.Icon.left)
                end
            end
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
            if e.tips.textLeft then
                local text=GetBindLocation()--显示,绑定位置
                if text then
                    e.tips.textLeft:SetText(e.Player.col..text)
                end
            end
        else
            e.tips:Hide()
        end
    end


    button:SetScript("OnEnter",function(self)
        
        self:set_tooltips()
        self:SetScript('OnUpdate', function (self, elapsed)
            self.elapsed = (self.elapsed or 0.3) + elapsed
            if self.elapsed > 0.3 and self.itemID then
                self.elapsed = 0
                if GameTooltip:IsOwned(self) and select(3, GameTooltip:GetItem())~=self.itemID then
                    self:set_tooltips()
                end
            end
        end)
    end)
    button:SetScript("OnLeave",function(self)
        GameTooltip_Hide()
        self:SetScript('OnUpdate',nil)
        self.elapsed=nil
        setAtt()
    end)
    button:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)

    button:SetScript("OnMouseUp", function(self, d)
        if d=='LeftButton' and not IsModifierKeyDown() then
            self.elapsed=nil
        end
        ResetCursor()
    end)

    button:SetScript('OnMouseWheel', setAtt)--设置属性

   
    setBagHearthstone()--设置Shift, Ctrl, Alt 提示

    C_Timer.After(2, function()
        --getToy()--生成, 有效表格
        --setAtt()--设置属性
        set_BindLocation()--显示, 炉石, 绑定位置
        e.SetItemSpellCool(button, {item=button.itemID})--主图标冷却
    end)
end


























--###########
--加载保存数据
--###########

panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('NEW_TOY_ADDED')
panel:RegisterEvent('TOYS_UPDATED')
panel:RegisterEvent('BAG_UPDATE_DELAYED')
panel:RegisterEvent('BAG_UPDATE_COOLDOWN')
panel:RegisterEvent('HEARTHSTONE_BOUND')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then

            --[[if WoWToolsSave[addName..'Tools'] then
                Save= WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TUTORIAL_TITLE31)..'Tools']
                WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TUTORIAL_TITLE31)..'Tools']=nil
            else
                Save= WoWToolsSave['Tools_Hearthstone'] or Save
            end]]
            
            --addName= '|T6948:0|t'..(e.onlyChinese and '炉石' or TUTORIAL_TITLE31)

            Save= WoWToolsSave[addName..'Tools'] or Save
            button= WoWTools_ToolsButtonMixin:CreateButton('Hearthstone', '|T134414:0|t'..(e.onlyChinese and '炉石' or TUTORIAL_TITLE31), false, true)

            if button then
                button:SetAttribute("type1", "item")
                button:SetAttribute("alt-type1", "item")
                button:SetAttribute("shift-type1", "item")
                button:SetAttribute("ctrl-type1", "item")
                
                button.items={}--存放有效

                CollectionsJournal_LoadUI()
                --[[if not C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
                    C_AddOns.LoadAddOn('Blizzard_Collections')
                end
                ]]

                getToy()--生成, 有效表格
                setAtt()--设置属性

                Init()--初始
            else
                self:UnregisterAllEvents()
                self:RegisterEvent("PLAYER_LOGOUT")
            end

        elseif arg1=='Blizzard_Collections' then
            hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='TOYS_UPDATED' or event=='NEW_TOY_ADDED' or 'PLAYER_ENTERING_WORLD' then
        getToy()--生成, 有效表格
        setAtt()--设置属性

    elseif event=='BAG_UPDATE_COOLDOWN' then
        e.SetItemSpellCool(button, {item=button.itemID})--主图标冷却
        setBagHearthstone()--设置Shift, Ctrl, Alt 提示

    elseif event=='BAG_UPDATE_DELAYED' then
        if IsResting()  then
            setBagHearthstone()--设置Shift, Ctrl, Alt 提示
        end

    elseif event=='HEARTHSTONE_BOUND' then
        set_BindLocation()--显示, 炉石, 绑定位置

    elseif event=='PLAYER_REGEN_ENABLED' then
        setAtt()
        self:UnregisterEvent('PLAYER_REGEN_ENABLED')

    end
end)