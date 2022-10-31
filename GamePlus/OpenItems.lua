local id, e = ...
local Save={use={}, no={}, pet=true, open=true, toy=true, mount=true, mago=true, ski=true, noItemHide=true}
local addName=TUTORIAL_TITLE9
local Combat, Bag= nil, {}

local panel= CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
panel:RegisterForClicks('LeftButtonDown')
panel.texture=panel:CreateTexture(nil,'ARTWORK')
panel.mask= panel:CreateMaskTexture()
panel.tips=CreateFrame("GameTooltip", id..addName, panel, "GameTooltipTemplate")
panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
panel.count=e.Cstr(panel, 10, nil, nil, true)

local function setPanelPostion()--设置按钮位置
    local p=Save.Point
    if p and p[1] and p[3] and p[4] and p[5] then
        panel:SetPoint(p[1],  UIParent, p[3], p[4], p[5])
    else
        panel:SetPoint('RIGHT', CharacterReagentBag0Slot, 'LEFT',-60, 0)
    end
end

local getTip=function(bag, slot)--取得提示内容
    panel.tips:SetOwner(panel, "ANCHOR_NONE")
    panel.tips:ClearLines()
    panel.tips:SetBagItem(bag,slot)
    for n=1, panel.tips:NumLines() do
        local line=_G[id..addName..'TextLeft'..n]
        if line then
            local rgb=e.HEX(line:GetTextColor())
            --print(rgb,line:GetText())
            if rgb=='fefe1f1f' or rgb=='fefe7f3f' or rgb=='ffff2020'then
                return
            end
        end
        line=_G[id..addName..'TextRight'..n]
        if line and line:GetText() then
            local rgb=e.HEX(line:GetTextColor())
            if rgb=='fefe1f1f' or rgb=='fefe7f3f' or rgb=='ffff2020' then
                return
            end
        end
    end
    return true
end

local function setCooldown()--冷却条
    if panel:IsShown() then
        if Bag.bag and Bag.slot then
            local itemID = GetContainerItemID(Bag.bag, Bag.slot)
            if itemID then
                local start, duration, enable = GetItemCooldown(itemID)
                e.Ccool(panel, start, duration, nil, true,nil, true)
                return
            end
        end
        if panel.cooldown then
            panel.cooldown:Clear()
        end
    end
end

local function setAtt(bag, slot, icon, itemID)--设置属性
    if UnitAffectingCombat('player') then
        Combat=true
        return
    end
    local num
    if bag and slot then
        local m='/use '..bag..' '..slot
        Bag={bag=bag, slot=slot}
        panel:SetAttribute("type", "macro")
        panel:SetAttribute("macrotext", m)
        panel.texture:SetTexture(icon)
        num = GetItemCount(itemID)
        num= num~=1 and num or ''
        panel:SetShown(true)
        setCooldown()--冷却条
    else
        panel:SetAttribute("macrotext", nil)
        panel:SetShown(not Save.noItemHide)
        if panel.cooldown then
            panel.cooldown:Clear()
        end
    end
    panel.count:SetText(num or '')
    panel.texture:SetShown(bag and slot)
    Combat=nil
end

local function getItems()--取得背包物品信息
    if UnitAffectingCombat('player') then
        Combat=true
        return
    end
    Bag={}
    for bag=0, NUM_BAG_SLOTS do
        for slot=1,GetContainerNumSlots(bag) do
            local icon, itemCount, locked, quality, _, lootable, itemLink, _, _, itemID, isBound = GetContainerItemInfo(bag, slot)
            if itemID and Save.use[itemID] then
                if Save.use[itemID]<=itemCount then
                    setAtt(bag, slot, icon, itemID)
                    return
                end
            elseif not locked and itemLink and itemID and icon and not Save.no[itemID] then
                local _, _, _, _, itemMinLevel, _, _,_, _, _, _, classID, subclassID, _,_, setID= GetItemInfo(itemLink)
                if (classID==2 or classID==4 )  or setID then--幻化
                    if Save.mago and not isBound then
                        if setID then
                            local setInfo= C_TransmogSets.GetSetInfo(setID)
                            if setInfo and not setInfo.collected then
                                setAtt(bag, slot, icon, itemID)
                                return
                            end
                        elseif not isBound and not C_TransmogCollection.PlayerHasTransmog(itemID) then
                            local sourceID=select(2,C_TransmogCollection.GetItemInfo(itemLink))
                            if sourceID then
                                local hasItemData, canCollect =  C_TransmogCollection.PlayerCanCollectSource(sourceID)
                                if hasItemData and canCollect then
                                    local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
                                    if sourceInfo and not sourceInfo.isCollected then
                                        if itemMinLevel and itemMinLevel<=UnitLevel('player') or not itemMinLevel then
                                            setAtt(bag, slot, icon, itemID)
                                            return
                                        end
                                    end
                                end
                            end
                        end
                    end
                elseif not classID or (classID==15 and subclassID==2) then
                    local speciesID = itemLink:match('Hbattlepet:(%d+)') or select(13, C_PetJournal.GetPetInfoByItemID(itemID))--宠物物品                        
                    if speciesID then
                        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)--已收集数量
                        if numCollected and limit and numCollected <  limit then
                            setAtt(bag, slot, icon, itemID)
                            return
                        end
                    end
                elseif quality and quality > 0 and classID and subclassID then
                    local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))--宠物物品
                    if speciesID  or (classID==15 and subclassID==2) then--PET
                        if Save.pet then
                            speciesID =speciesID  or select(13,C_PetJournal.GetPetInfoByItemID(itemID))
                            if speciesID then
                                local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)--已收集数量
                                if numCollected and limit and numCollected <  limit then
                                    setAtt(bag, slot, icon, itemID)
                                    return
                                end
                            end
                        end
                    elseif classID==9 and subclassID >0 then--配方                    
                            if Save.ski and getTip(bag, slot) then
                                setAtt(bag, slot, icon, itemID)
                                return
                            end

                    elseif lootable then--可打开
                        if Save.open then
                            if (not quality or (quality and quality <=4)) and getTip(bag, slot) then
                                setAtt(bag, slot, icon, itemID)
                                return
                            end
                        end

                    elseif classID==15 and  subclassID==5 then--坐骑
                        if Save.mount then
                            local mountID = C_MountJournal.GetMountFromItem(itemID)
                            if mountID then
                                local isCollected =select(11, C_MountJournal.GetMountInfoByID(mountID))
                                if not isCollected then
                                    setAtt(bag, slot, icon, itemID)
                                    return
                                end
                            end
                        end

                    elseif classID==15 and subclassID==4 then
                        if Save.alt and IsUsableItem(itemLink) and not  C_Item.IsAnimaItemByID(itemLink)  then
                            setAtt(bag, slot, icon, itemID)
                            return
                        end

                    elseif C_ToyBox.GetToyInfo(itemID) and not PlayerHasToy(itemID) then--玩具 
                        if Save.toy then
                            setAtt(bag, slot, icon, itemID)
                            return
                        end
                    end
                end
            end
        end
    end
    setAtt()
end

local function setDisableCursorItem()--禁用当物品
    if Bag.bag and Bag.slot then
        local itemID=GetContainerItemID(Bag.bag, Bag.slot)
        if itemID then
            Save.no[itemID]=true
            Save.use[itemID]=nil
        end
    end
    getItems()
end

--####
--菜单
--####
local function setUseMenu(level)--二级, 使用
    local t=UIDropDownMenu_CreateInfo()
    t.text= CLEAR_ALL--清除所有
    t.notCheckable=true
    t.func=function()
        Save.use={}
        getItems()
        CloseDropDownMenus()
    end
    UIDropDownMenu_AddButton(t,level)
    for itemID, num in pairs(Save.use) do
        t=UIDropDownMenu_CreateInfo()
        t.text= select(2, GetItemInfo(itemID)) or  ('itemID: '..itemID)
        if num>1 then
            t.text= t.text..' |cnGREEN_FONT_COLOR:x'..num..'|r'
        end
        t.icon= C_Item.GetItemIconByID(itemID)
        t.checked=true
        t.func=function()
            Save.use[itemID]=nil
            getItems()
        end
        t.tooltipOnButton=true
        t.tooltipTitle=REMOVE
        if num>1 then
           t.tooltipText='\n'..COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS)..'\n'..AUCTION_STACK_SIZE..': '..num
        end
        UIDropDownMenu_AddButton(t,level)
    end
end
local function setNoMenu(level)--二级,禁用
    local t=UIDropDownMenu_CreateInfo()
    t.text= CLEAR_ALL--清除所有
    t.notCheckable=true
    t.func=function()
        Save.no={}
        getItems()
        CloseDropDownMenus()
    end
    UIDropDownMenu_AddButton(t,level)
    for itemID, _ in pairs(Save.no) do
        t=UIDropDownMenu_CreateInfo()
        t.text=select(2, GetItemInfo(itemID)) or  ('itemID: '..itemID)
        t.icon=C_Item.GetItemIconByID(itemID)
        t.checked=true
        t.func=function()
            Save.no[itemID]=nil
            getItems()
        end
        t.tooltipOnButton=true
        t.tooltipTitle=REMOVE
        UIDropDownMenu_AddButton(t,level)
    end
end
local function setMenuList(self, level, menuList)--主菜单
    if menuList=='USE' then
        setUseMenu(level)
        return
    elseif menuList=='NO' then
        setNoMenu(level)
        return
    end

    local t=UIDropDownMenu_CreateInfo()
    t.notCheckable=true
    if Bag.bag and Bag.slot then
        t.text=GetContainerItemLink(Bag.bag, Bag.slot) or ('bag: '..bag ..' slot: '..slot)
        t.icon=GetContainerItemInfo(Bag.bag, Bag.slot)
        t.func=function()
            setDisableCursorItem()--禁用当物品
        end
        t.tooltipOnButton=true
        t.tooltipTitle='|cnRED_FONT_COLOR:'..DISABLE..'|r'..e.Icon.mid..KEY_MOUSEWHEELUP
    else
        t.text=addName..': '..NONE
        t.isTitle=true
        
        t.tooltipOnButton=true
        t.tooltipTitle=USE..'/'..DISABLE
        t.tooltipText=DRAG_MODEL..ITEMS
    end
    
    UIDropDownMenu_AddButton(t)
    UIDropDownMenu_AddSeparator()

    local no,use= 0, 0
    for _ in pairs(Save.no) do
        no=no+1
    end
    for _ in pairs(Save.use) do
        use=use+1
    end
    t=UIDropDownMenu_CreateInfo()--自定义禁用列表
    t.text= DISABLE..' #'..no
    t.notCheckable=1
    t.menuList='NO'
    t.hasArrow=true
    UIDropDownMenu_AddButton(t)

    t=UIDropDownMenu_CreateInfo()--自定义使用列表
    t.text= USE..' #'..use
    t.notCheckable=1
    t.menuList='USE'
    t.hasArrow=true
    UIDropDownMenu_AddButton(t)

    t=UIDropDownMenu_CreateInfo()
    t.text=ITEM_OPENABLE
    if Save.open then t.checked=true end
    t.func=function()
        if Save.open then
            Save.open=nil
        else
            Save.open=true
        end
        getItems()
    end
    UIDropDownMenu_AddButton(t)

    t=UIDropDownMenu_CreateInfo()
    t.text=PET
    if Save.pet then t.checked=true end
    t.func=function()
        if Save.pet then
            Save.pet=nil
        else
            Save.pet=true
        end
        getItems()
    end
    UIDropDownMenu_AddButton(t)

    t=UIDropDownMenu_CreateInfo()
    t.text=TOY
    t.checked=Save.toy
    t.func=function()
        if Save.toy then
            Save.toy=nil
        else
            Save.toy=true
        end
        getItems()
    end
    UIDropDownMenu_AddButton(t)

    t=UIDropDownMenu_CreateInfo()
    t.text=MOUNTS
    t.checked=Save.mount
    t.func=function()
        if Save.mount then
            Save.mount=nil
        else
            Save.mount=true
        end
        getItems()
    end
    UIDropDownMenu_AddButton(t)

    t=UIDropDownMenu_CreateInfo()
    t.text=TRANSMOGRIFY
    t.checked=Save.mago
    t.func=function()
        if Save.mago then
            Save.mago=nil
        else
            Save.mago=true
        end
        getItems()
    end
    UIDropDownMenu_AddButton(t)

    t=UIDropDownMenu_CreateInfo()
    t.text=TRADESKILL_SERVICE_LEARN
    t.checked=Save.ski
    t.func=function()
        if Save.ski then
            Save.ski=nil
        else
            Save.ski=true
        end
        getItems()
    end
    UIDropDownMenu_AddButton(t)

    t=UIDropDownMenu_CreateInfo()
    t.text=BINDING_HEADER_OTHER
    t.checked=Save.alt
    t.func=function()
        if Save.alt then
            Save.alt=nil
        else
            Save.alt=true
        end
        getItems()
    end
    UIDropDownMenu_AddButton(t)

    t=UIDropDownMenu_CreateInfo()--还原位置
    if Save.Point then
        t.text=RRESET_POSITION or HUD_EDIT_MODE_RESET_POSITION
    else
        t.text='Alt +'..e.Icon.right..' '..NPE_MOVE
        t.disabled=true
    end
    t.func=function()
        Save.Point=nil
        panel:ClearAllPoints()
        setPanelPostion()--设置按钮位置
    end
    t.tooltipOnButton=true
    t.notCheckable=true
    
    UIDropDownMenu_AddButton(t)
end


--########
--设置属性
StaticPopupDialogs['OpenItmesUseOrDisableItem']={
    text=id..' '..addName..'\n\n%s\n%s\n\n'..COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS)..' >1: ',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
	timeout = 60,
    hasEditBox=1,
    button1='|cnGREEN_FONT_COLOR:'..USE..'|r',
    button2=CANCEL,
    button3='|cnRED_FONT_COLOR:'..DISABLE..'|r',
    OnShow = function(self, data)
        self.editBox:SetNumeric(true)
        local num=Save.use[data.itemID]
        if num and num>1 then
            self.editBox:SetNumber(num)
        end
        --self.editBox:SetAutoFocus(false)
	end,
    OnAccept = function(self, data)
		local num= self.editBox:GetNumber()
        num = num<1 and 1 or num
        Save.use[data.itemID]=num
        Save.no[data.itemID]=nil
        getItems()--取得背包物品信息
        print(id, '|cnGREEN_FONT_COLOR:'..addName..'|r', num>1 and COMBINED_BAG_TITLE:gsub(INVTYPE_BAG,ITEMS)..': '..'|cnGREEN_FONT_COLOR:'..num..'|r' or '', data.itemLink)
	end,
    OnAlt = function(self, data)
        Save.no[data.itemID]=true
        Save.use[data.itemID]=nil
        getItems()--取得背包物品信息
        print(id, addName, '|cnRED_FONT_COLOR:'..DISABLE..'|r', data.itemLink)
    end,
    EditBoxOnTextChanged=function(self)
       local num= self:GetNumber()
        if num>1 then
           self:GetParent().button1:SetText('|cnGREEN_FONT_COLOR:'..AUCTION_STACK_SIZE..num..'|r')
        else
            self:GetParent().button1:SetText('|cnGREEN_FONT_COLOR:'..USE..'|r');
        end
    end,
    EditBoxOnEscapePressed = function(s)
        s:GetParent():Hide()
    end,
}

local function shoTips(self)--显示提示
    if e.tips:IsShown() then
        e.tips:Hide()
    end
    if (BattlePetTooltip) then
		BattlePetTooltip:Hide();
	end
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    if Bag.bag and Bag.slot then
        local battlePetLink= GetContainerItemLink(Bag.bag, Bag.slot)
        if battlePetLink and battlePetLink:find('Hbattlepet:%d+') then
            BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(battlePetLink))
        else
            e.tips:SetBagItem(Bag.bag, Bag.slot)
        end
    else
        e.tips:AddDoubleLine(id, addName)
    end
    e.tips:Show()
end
panel:SetScript("OnEnter",function(self)
    local infoType, itemID, itemLink = GetCursorInfo()
    if infoType == "item" and itemID and itemLink then
        if Bag.bag and Bag.slot and itemLink== GetContainerItemLink(Bag.bag, Bag.slot) then
            return
        end
        local icon
        icon= C_Item.GetItemIconByID(itemID)
        icon = icon and '|T'..icon..':0|t'..itemLink or ''
        local list=Save.use[itemID] and PROFESSIONS_CURRENT_LISTINGS..': |cff00ff00'..USE..'|r' or Save.no[itemID] and PROFESSIONS_CURRENT_LISTINGS..': |cffff0000'..DISABLE..'|r' or ''
        StaticPopup_Show('OpenItmesUseOrDisableItem',icon,list, {itemID=itemID, itemLink=itemLink})
        ClearCursor()
    else
        shoTips(self)--显示提示
    end
end)
panel:SetScript("OnLeave",function()
    e.tips:Hide()
    BattlePetTooltip:Hide()
    ResetCursor()
end)
panel:SetScript("OnMouseDown", function(self,d)
    if d=='RightButton' and IsAltKeyDown() then
        SetCursor('UI_MOVE_CURSOR')
    elseif (d=='RightButton' and not IsModifierKeyDown()) or not(Bag.bag and Bag.slot) then
        ToggleDropDownMenu(1,nil,panel.Menu,self,self:GetWidth(),0)
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
panel:SetScript("OnMouseUp", function()
    ResetCursor()
end)

panel:SetScript('OnMouseWheel',function(self,d)
    if d == 1 and not IsModifierKeyDown() then
        if Bag.slot and Bag.bag then
            setDisableCursorItem()--禁用当物品
            CloseDropDownMenus()
            shoTips(self)--显示提示
        end
    end
end)


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('BAG_UPDATE_DELAYED')

panel:RegisterEvent('PLAYER_REGEN_DISABLED')
panel:RegisterEvent('PLAYER_REGEN_ENABLED')
panel:RegisterEvent('BAG_UPDATE_COOLDOWN')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
            if not Save.disabled then
                panel:SetSize(30,30)
                panel:EnableMouseWheel(true)
                panel:RegisterForDrag("RightButton")
                panel:SetMovable(true)
                panel:SetClampedToScreen(true)
                panel:SetNormalAtlas('bag-reagent-border-empty')
                panel:SetHighlightAtlas('bag-border')
                panel:SetPushedAtlas('bag-border-highlight')

                panel.texture:SetPoint('CENTER')
                panel.texture:SetSize(22,22)
                panel.texture:SetAtlas('bag-border')

                panel.mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
                panel.mask:SetAllPoints(panel.texture)
                panel.texture:AddMaskTexture(panel.mask)
                panel.texture:SetShown(false)

                panel.count:SetPoint('BOTTOM',0,2)

                UIDropDownMenu_Initialize(panel.Menu, setMenuList, 'MENU')
                setPanelPostion()--设置按钮位置
                getItems()--设置属性
            else
                panel:UnregisterAllEvents()
                panel:RegisterEvent("PLAYER_LOGOUT")
            end

             --添加控制面板        
             local check=e.CPanel(addName, not Save.disabled, true)
             check:SetScript('OnClick', function()
                 if Save.disabled then
                     Save.disabled=nil
                 else
                     Save.disabled=true
                 end
                 print(id, addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
             end)
            --未发现物品: 隐藏
             check.noItemHide=CreateFrame("CheckButton", nil, check, "InterfaceOptionsCheckButtonTemplate")
             check.noItemHide.Text:SetText(BROWSE_NO_RESULTS..': '..HIDE)
             check.noItemHide:SetPoint('LEFT', check.Text, 'RIGHT')
             check.noItemHide:SetChecked(Save.noItemHide)
             check.noItemHide:SetScript('OnClick', function()
                if Save.noItemHide then
                    Save.noItemHide=nil
                else
                    Save.noItemHide=true
                end
                getItems()--取得背包物品信息
                print(id, addName, e.GetEnabeleDisable(not Save.noItemHide))
            end)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='BAG_UPDATE_DELAYED' then
            getItems()
    elseif event=='PLAYER_REGEN_DISABLED' then
        if Save.noItemHide then
            panel:SetShown(false)
        end
    elseif event=='PLAYER_REGEN_ENABLED' then
        if Combat then
            getItems()
        else
            panel:SetShown(Bag.bag or not Save.noItemHide)
        end
    elseif event=='BAG_UPDATE_COOLDOWN' then
        setCooldown()--冷却条
    end
end)
